import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/services/common/file_export_services.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/file_explorer.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as path;

/// What the user chose to do with a selection.
enum SelectionAction { export, delete }

/// The settings needed to write a selected-file archive.
class SelectionExportSettings {
  const SelectionExportSettings({
    required this.format,
    required this.fileStem,
    required this.appendDate,
    required this.destination,
  });

  final DbArchiveFormat format;
  final String fileStem;
  final bool appendDate;
  final Directory destination;
}

/// The result of the review surface.
class SelectionReviewResult {
  const SelectionReviewResult._({required this.action, this.exportSettings});

  const SelectionReviewResult.delete() : this._(action: SelectionAction.delete);

  const SelectionReviewResult.export(SelectionExportSettings settings)
    : this._(action: SelectionAction.export, exportSettings: settings);

  final SelectionAction action;
  final SelectionExportSettings? exportSettings;
}

/// One top-level location in the selection summary.
///
/// Grouping by location rather than by file type is deliberate: "clear up
/// space" is a question about which project or folder is holding the bytes, and
/// a flat list of two hundred filenames answers nothing.
class SelectionGroup {
  const SelectionGroup({
    required this.label,
    required this.detail,
    required this.fileCount,
    required this.sizeBytes,
  });

  final String label;

  /// Secondary line: the project name, and the mix of file kinds.
  final String detail;
  final int fileCount;
  final int sizeBytes;
}

/// Summarises [paths] by their top-level folder under the app directory.
///
/// [applicationFolderLabel] names files sitting directly in the app folder;
/// screens pass the localized label.
List<SelectionGroup> summarizeSelection({
  required String root,
  required List<String> paths,
  required NahpuDirectoryNode tree,
  String applicationFolderLabel = 'Application folder',
}) {
  final sizes = <String, int>{};
  final counts = <String, int>{};
  final kinds = <String, Map<MediaKind, int>>{};
  final subtitles = <String, String>{};

  final nodesByPath = <String, NahpuFileNode>{};
  final directoryLabels = <String, String>{};
  void index(NahpuTreeNode node) {
    switch (node) {
      case NahpuFileNode():
        nodesByPath[node.path] = node;
      case NahpuDirectoryNode():
        directoryLabels[node.path] = node.subtitle ?? '';
        node.children.forEach(index);
    }
  }

  index(tree);

  for (final filePath in paths) {
    final relative = path.isWithin(root, filePath)
        ? path.relative(filePath, from: root)
        : filePath;
    final segments = path.split(relative);
    // A file sitting directly in the app folder has no folder to group under.
    final key = segments.length > 1 ? segments.first : '.';

    counts[key] = (counts[key] ?? 0) + 1;
    sizes[key] = (sizes[key] ?? 0) + (nodesByPath[filePath]?.sizeBytes ?? 0);

    final kind = matchMediaKindFromPath(filePath);
    kinds.putIfAbsent(key, () => <MediaKind, int>{});
    kinds[key]![kind] = (kinds[key]![kind] ?? 0) + 1;

    if (key != '.' && !subtitles.containsKey(key)) {
      final label = directoryLabels[path.join(root, key)] ?? '';
      // The scanner writes "12 files · Project Name"; only the name is wanted.
      final parts = label.split(' · ');
      if (parts.length > 1) subtitles[key] = parts.sublist(1).join(' · ');
    }
  }

  final groups = counts.keys.map((key) {
    final detail = <String>[];
    final name = subtitles[key];
    if (name != null && name.isNotEmpty) detail.add(name);
    final kindCounts = kinds[key] ?? const <MediaKind, int>{};
    final ordered = kindCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    detail.addAll(
      ordered.map(
        (entry) =>
            '${entry.value} ${matchMediaKindLabel(entry.key).toLowerCase()}',
      ),
    );
    return SelectionGroup(
      label: key == '.' ? applicationFolderLabel : key,
      detail: detail.join(' · '),
      fileCount: counts[key]!,
      sizeBytes: sizes[key]!,
    );
  }).toList();

  groups.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
  return groups;
}

/// Shows what the user selected and offers the two ways out of it.
Future<SelectionReviewResult?> showSelectionReview({
  required BuildContext context,
  required List<SelectionGroup> groups,
  required int fileCount,
  required int sizeBytes,
  Directory? initialDirectory,
  ExportDestinationMode? destinationMode,
}) {
  final mode = destinationMode ?? platformExportDestination;
  final compact = MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact;
  final dialog = SelectionReviewDialog(
    groups: groups,
    fileCount: fileCount,
    sizeBytes: sizeBytes,
    initialDirectory: initialDirectory,
    destinationMode: mode,
    isBottomSheet: compact,
  );
  if (compact) {
    return showModalBottomSheet<SelectionReviewResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => dialog,
    );
  }
  return showDialog<SelectionReviewResult>(
    context: context,
    builder: (context) => dialog,
  );
}

class SelectionReviewDialog extends StatefulWidget {
  const SelectionReviewDialog({
    super.key,
    required this.groups,
    required this.fileCount,
    required this.sizeBytes,
    this.initialDirectory,
    this.destinationMode,
    this.isBottomSheet = false,
  });

  final List<SelectionGroup> groups;
  final int fileCount;
  final int sizeBytes;
  final Directory? initialDirectory;
  final ExportDestinationMode? destinationMode;
  final bool isBottomSheet;

  @override
  State<SelectionReviewDialog> createState() => _SelectionReviewDialogState();
}

class _SelectionReviewDialogState extends State<SelectionReviewDialog> {
  late final FileOpCtrModel _exportController;
  late final ExportDestinationMode _mode;
  DbArchiveFormat _format = DbArchiveFormat.tarGzip;
  Directory? _selectedDirectory;
  bool _appendDate = true;

  @override
  void initState() {
    super.initState();
    _mode = widget.destinationMode ?? platformExportDestination;
    _selectedDirectory = widget.initialDirectory;
    _exportController = FileOpCtrModel.empty();
    _exportController.fileNameCtr.text = selectionExportStem;
  }

  @override
  void dispose() {
    _exportController.dispose();
    super.dispose();
  }

  /// Export needs a folder NAHPU can write to, and this screen offers to
  /// delete the originals straight afterwards — so it never routes to the
  /// temporary directory, whose contents the next export clears.
  bool get _canExport =>
      _mode == ExportDestinationMode.chooseDirectory &&
      _selectedDirectory != null &&
      _exportController.isValid &&
      _exportController.fileNameCtr.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return widget.isBottomSheet ? _buildSheet(context) : _buildDialog(context);
  }

  Widget _buildDialog(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.settingsSelectionTitle(widget.fileCount)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: NahpuContentWidth.form),
        child: _scrollableContent(context),
      ),
      actions: [
        _ReviewActions(
          compact: MediaQuery.sizeOf(context).width < 480,
          onDelete: _delete,
          onExport: _canExport ? _export : null,
        ),
      ],
    );
  }

  Widget _buildSheet(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          NahpuSpacing.xl,
          NahpuSpacing.md,
          NahpuSpacing.xl,
          NahpuSpacing.xl,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.86,
            maxWidth: NahpuContentWidth.form,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.settingsSelectionTitle(widget.fileCount),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Flexible(child: _scrollableContent(context)),
              const SizedBox(height: NahpuSpacing.lg),
              _ReviewActions(
                compact: true,
                onDelete: _delete,
                onExport: _canExport ? _export : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scrollableContent(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: NahpuSpacing.sm),
          Center(
            child: Text(
              formatByteSize(widget.sizeBytes),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: NahpuSpacing.lg),
          for (final group in widget.groups) _GroupRow(group: group),
          const SizedBox(height: NahpuSpacing.lg),
          if (_mode == ExportDestinationMode.chooseDirectory)
            GenericFileSettingsCard<DbArchiveFormat>(
              exportCtr: _exportController,
              selectedDir: _selectedDirectory,
              format: _format,
              formats: DbArchiveFormat.values,
              formatLabel: (format) => format.label,
              extensionForFormat: (format) => format.extension,
              formatFieldLabel: l10n.settingsSelectionArchiveFormat,
              onFormatChanged: (format) => setState(() => _format = format),
              onFileNameChanged: (_) => setState(() {}),
              appendDate: _appendDate,
              onAppendDateChanged: (value) =>
                  setState(() => _appendDate = value),
              onSelectDir: _selectDirectory,
              onClearDir: _clearDirectory,
            )
          else
            Text(
              l10n.settingsSelectionNoFolder,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          const SizedBox(height: NahpuSpacing.lg),
          Text(
            _mode == ExportDestinationMode.chooseDirectory
                ? l10n.settingsSelectionExportNote
                : l10n.settingsSelectionDeleteNote,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDirectory() async {
    final directory = await FilePickerServices().selectDir();
    if (!mounted || directory == null) return;
    setState(() => _selectedDirectory = directory);
  }

  void _clearDirectory() {
    setState(() => _selectedDirectory = null);
  }

  void _delete() {
    Navigator.pop(context, const SelectionReviewResult.delete());
  }

  void _export() {
    final directory = _selectedDirectory;
    final fileStem = _exportController.fileNameCtr.text.trim();
    if (!_canExport || directory == null || fileStem.isEmpty) return;
    Navigator.pop(
      context,
      SelectionReviewResult.export(
        SelectionExportSettings(
          format: _format,
          fileStem: fileStem,
          appendDate: _appendDate,
          destination: directory,
        ),
      ),
    );
  }
}

class _ReviewActions extends StatelessWidget {
  const _ReviewActions({
    required this.compact,
    required this.onDelete,
    required this.onExport,
  });

  final bool compact;
  final VoidCallback onDelete;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: colors.error),
              onPressed: onDelete,
              child: Text(l10n.settingsSelectionDeletePermanently),
            ),
          ),
          const SizedBox(height: NahpuSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.commonCancel),
              ),
              const SizedBox(width: NahpuSpacing.sm),
              FilledButton.icon(
                onPressed: onExport,
                icon: const Icon(Icons.archive_outlined),
                label: Text(l10n.commonExport),
              ),
            ],
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: colors.error),
          onPressed: onDelete,
          child: Text(l10n.settingsSelectionDeletePermanently),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        const SizedBox(width: NahpuSpacing.sm),
        FilledButton.icon(
          onPressed: onExport,
          icon: const Icon(Icons.archive_outlined),
          label: Text(l10n.commonExport),
        ),
      ],
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.group});

  final SelectionGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (group.detail.isNotEmpty)
                  Text(
                    group.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: NahpuSpacing.lg),
          Flexible(
            child: Text(
              '${group.fileCount} · ${formatByteSize(group.sizeBytes)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
