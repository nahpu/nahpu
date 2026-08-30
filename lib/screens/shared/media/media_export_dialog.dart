import 'dart:io';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/media/media_export_service.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as path;

typedef PrepareMediaExportCallback = Future<MediaExportSource> Function();

typedef MediaExportCallback =
    Future<MediaExportResult> Function({
      required MediaExportSource source,
      required MediaExportFormat format,
      required String fileStem,
      Directory? destinationDirectory,
      int? width,
      int? height,
      required int jpegQuality,
    });

Future<void> showMediaExportDialog({
  required BuildContext context,
  required PrepareMediaExportCallback prepare,
  required MediaExportCallback onExport,
}) async {
  final content = MediaExportDialog(prepare: prepare, onExport: onExport);
  if (MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => content,
    );
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: NahpuContentWidth.form,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: content,
      ),
    ),
  );
}

class MediaExportDialog extends StatefulWidget {
  const MediaExportDialog({
    super.key,
    required this.prepare,
    required this.onExport,
  });

  final PrepareMediaExportCallback prepare;
  final MediaExportCallback onExport;

  @override
  State<MediaExportDialog> createState() => _MediaExportDialogState();
}

class _MediaExportDialogState extends State<MediaExportDialog> {
  late final FileOpCtrModel _exportCtr;
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  MediaExportSource? _source;
  Object? _loadError;
  Directory? _selectedDirectory;
  MediaExportResult? _output;
  MediaExportFormat _format = MediaExportFormat.original;
  bool _appendDate = false;
  bool _resize = false;
  bool _isRunning = false;
  int _jpegQuality = 85;

  @override
  void initState() {
    super.initState();
    _exportCtr = FileOpCtrModel.empty();
    _prepare();
  }

  @override
  void dispose() {
    _exportCtr.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        NahpuSpacing.xl,
        NahpuSpacing.md,
        NahpuSpacing.xl,
        MediaQuery.viewInsetsOf(context).bottom + NahpuSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Export media',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: NahpuSpacing.xl),
          if (_loadError != null)
            _LoadError(error: _loadError!)
          else if (_source == null)
            const Padding(
              padding: EdgeInsets.all(NahpuSpacing.xxxl),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ..._buildForm(_source!),
        ],
      ),
    );
  }

  List<Widget> _buildForm(MediaExportSource source) {
    return [
      Text(
        compactMediaExportPath(source.file.path),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: NahpuSpacing.xl),
      GenericFileSettingsCard<MediaExportFormat>(
        exportCtr: _exportCtr,
        selectedDir: _selectedDirectory,
        format: _format,
        formats: source.availableFormats,
        formatLabel: (format) => format.label(source.originalExtension),
        extensionForFormat: (format) =>
            format.extension(source.originalExtension),
        onFormatChanged: (format) => setState(() {
          _format = format;
          _output = null;
        }),
        onFileNameChanged: (_) => _resetOutput(),
        appendDate: _appendDate,
        onAppendDateChanged: (value) => setState(() {
          _appendDate = value;
          _output = null;
        }),
        onSelectDir: _selectDirectory,
        onClearDir: () => setState(() {
          _selectedDirectory = null;
          _output = null;
        }),
        enabled: !_isRunning,
      ),
      if (source.conversionUnavailableReason != null) ...[
        const SizedBox(height: NahpuSpacing.lg),
        _ConversionUnavailable(message: source.conversionUnavailableReason!),
      ],
      if (_format != MediaExportFormat.original &&
          source.imageInfo != null) ...[
        const SizedBox(height: NahpuSpacing.lg),
        _buildImageOptions(source),
      ],
      const SizedBox(height: NahpuSpacing.xxl),
      ExportShareButton(
        hasExported: _output != null,
        isRunning: _isRunning,
        onExport: _canExport ? _export : null,
        onShare: _share,
      ),
    ];
  }

  Widget _buildImageOptions(MediaExportSource source) {
    final info = source.imageInfo!;
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image Settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: NahpuSpacing.xs),
          Text(
            'Original: ${info.width} × ${info.height} px',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Resize image'),
            subtitle: const Text('Aspect ratio is locked'),
            value: _resize,
            onChanged: _isRunning
                ? null
                : (value) => setState(() {
                    _resize = value;
                    _output = null;
                  }),
          ),
          if (_resize) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _widthController,
                    enabled: !_isRunning,
                    decoration: InputDecoration(
                      labelText: 'Width (px)',
                      helperText: 'Max ${info.width}',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _updateFromWidth(source),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    NahpuSpacing.md,
                    NahpuSpacing.lg,
                    NahpuSpacing.md,
                    0,
                  ),
                  child: Icon(Icons.link),
                ),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    enabled: !_isRunning,
                    decoration: InputDecoration(
                      labelText: 'Height (px)',
                      helperText: 'Max ${info.height}',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _updateFromHeight(source),
                  ),
                ),
              ],
            ),
          ],
          if (_format == MediaExportFormat.jpeg) ...[
            const SizedBox(height: NahpuSpacing.lg),
            Row(
              children: [
                const Text('JPEG quality'),
                const Spacer(),
                Text('$_jpegQuality%'),
              ],
            ),
            Slider(
              value: _jpegQuality.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              label: '$_jpegQuality',
              onChanged: _isRunning
                  ? null
                  : (value) => setState(() {
                      _jpegQuality = value.round();
                      _output = null;
                    }),
            ),
          ],
        ],
      ),
    );
  }

  bool get _canExport {
    if (_source == null || _isRunning || !_exportCtr.isValid) return false;
    if (_format == MediaExportFormat.original || !_resize) return true;
    return int.tryParse(_widthController.text) != null &&
        int.tryParse(_heightController.text) != null;
  }

  Future<void> _prepare() async {
    try {
      final source = await widget.prepare();
      if (!mounted) return;
      final info = source.imageInfo;
      setState(() {
        _source = source;
        _exportCtr.fileNameCtr.text = source.defaultFileStem;
        if (info != null) {
          _widthController.text = info.width.toString();
          _heightController.text = info.height.toString();
        }
      });
    } catch (error) {
      if (mounted) setState(() => _loadError = error);
    }
  }

  void _updateFromWidth(MediaExportSource source) {
    final width = int.tryParse(_widthController.text);
    if (width == null) {
      _resetOutput();
      return;
    }
    final info = source.imageInfo!;
    final dimensions = dimensionsForWidth(
      originalWidth: info.width,
      originalHeight: info.height,
      width: width,
    );
    _setDimensions(dimensions);
  }

  void _updateFromHeight(MediaExportSource source) {
    final height = int.tryParse(_heightController.text);
    if (height == null) {
      _resetOutput();
      return;
    }
    final info = source.imageInfo!;
    final dimensions = dimensionsForHeight(
      originalWidth: info.width,
      originalHeight: info.height,
      height: height,
    );
    _setDimensions(dimensions);
  }

  void _setDimensions(ImagePixelDimensions dimensions) {
    setState(() {
      _widthController.value = TextEditingValue(
        text: dimensions.width.toString(),
        selection: TextSelection.collapsed(
          offset: dimensions.width.toString().length,
        ),
      );
      _heightController.value = TextEditingValue(
        text: dimensions.height.toString(),
        selection: TextSelection.collapsed(
          offset: dimensions.height.toString().length,
        ),
      );
      _output = null;
    });
  }

  void _resetOutput() {
    if (mounted) setState(() => _output = null);
  }

  Future<void> _selectDirectory() async {
    final directory = await FilePickerServices().selectDir();
    if (directory != null && mounted) {
      setState(() {
        _selectedDirectory = directory;
        _output = null;
      });
    }
  }

  Future<void> _export() async {
    final source = _source;
    if (source == null) return;
    setState(() => _isRunning = true);
    try {
      final result = await widget.onExport(
        source: source,
        format: _format,
        fileStem: _appendDate
            ? appendDateToFileStem(_exportCtr.fileNameCtr.text, DateTime.now())
            : _exportCtr.fileNameCtr.text,
        destinationDirectory: _selectedDirectory,
        width: _format != MediaExportFormat.original && _resize
            ? int.parse(_widthController.text)
            : null,
        height: _format != MediaExportFormat.original && _resize
            ? int.parse(_heightController.text)
            : null,
        jpegQuality: _jpegQuality,
      );
      if (!mounted) return;
      setState(() => _output = result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            systemPlatform == PlatformType.desktop
                ? 'Exported to ${compactMediaExportPath(result.file.path)}'
                : 'Export complete!',
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  Future<void> _share() async {
    final output = _output;
    if (output == null) return;
    try {
      await FilePickerServices().shareFile(context, output.file);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

String compactMediaExportPath(String filePath) {
  final normalizedPath = path.normalize(filePath);
  final components = <String>[path.basename(normalizedPath)];
  var directory = path.dirname(normalizedPath);

  for (var index = 0; index < 2; index++) {
    final parent = path.basename(directory);
    if (parent.isEmpty || parent == path.separator || parent == '.') break;
    components.insert(0, parent);
    final nextDirectory = path.dirname(directory);
    if (nextDirectory == directory) break;
    directory = nextDirectory;
  }

  return '…${path.separator}${path.joinAll(components)}';
}

class _ConversionUnavailable extends StatelessWidget {
  const _ConversionUnavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: NahpuControlSize.iconMedium,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: NahpuSpacing.md),
        Expanded(child: Text(message)),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: NahpuControlSize.prominent,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: NahpuSpacing.lg),
        Text(error.toString(), textAlign: TextAlign.center),
        const SizedBox(height: NahpuSpacing.xl),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
