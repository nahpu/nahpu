import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/screens/shared/media/media_export_dialog.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/media/media_export_service.dart';
import 'package:nahpu/styles/design_tokens.dart';

class QrCodeDialog extends ConsumerStatefulWidget {
  const QrCodeDialog({
    super.key,
    required this.title,
    required this.data,
    required this.description,
    this.showAsSheet = false,
  });

  final String title;
  final String data;
  final String description;

  /// Lays the content out for a bottom sheet instead of an [AlertDialog].
  final bool showAsSheet;

  @override
  ConsumerState<QrCodeDialog> createState() => _QrCodeDialogState();
}

class _QrCodeDialogState extends ConsumerState<QrCodeDialog> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QrCodeViewer(data: widget.data),
        const SizedBox(height: NahpuSpacing.lg),
        Text(widget.description, textAlign: TextAlign.center),
      ],
    );
    final exportButton = IconButton(
      icon: const Icon(Icons.download_outlined),
      tooltip: 'Export QR code as an image',
      onPressed: _isExporting ? null : _exportImage,
    );
    final closeButton = TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Close'),
    );
    if (widget.showAsSheet) {
      return AdaptiveSheetDialogBody(
        title: widget.title,
        showCloseButton: false,
        actions: [exportButton, closeButton],
        child: content,
      );
    }
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(child: content),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [exportButton, closeButton],
        ),
      ],
    );
  }

  Future<void> _exportImage() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isExporting = true);
    try {
      final bytes = await renderQrCodePng(data: widget.data);
      if (!mounted) return;
      if (bytes == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('This data is too large for a QR code image.'),
          ),
        );
        return;
      }
      // Built before the pop because this route owns [ref].
      final service = MediaExportService(ref: ref);
      navigator.pop();
      await showMediaExportDialog(
        context: navigator.context,
        prepare: () =>
            service.prepareImageBytes(bytes: bytes, fileStem: widget.title),
        onExport:
            ({
              required source,
              required format,
              required fileStem,
              destinationDirectory,
              width,
              height,
              required jpegQuality,
            }) => service.export(
              source: source,
              format: format,
              fileStem: fileStem,
              destinationDirectory: destinationDirectory,
              width: width,
              height: height,
              jpegQuality: jpegQuality,
            ),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
