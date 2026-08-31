import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/settings/application/file_tree.dart';
import 'package:nahpu/screens/settings/application/selection_review.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/common/file_export_services.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/providers/file_explorer.dart';
import 'package:nahpu/services/types/file_explorer.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Settings row showing total usage, linking to the explorer.
class DataUsage extends ConsumerWidget {
  const DataUsage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(appFileTreeProvider);
    return CommonSettingTile(
      icon: Icons.data_usage_outlined,
      isNavigation: true,
      title: 'Data usage',
      label: 'Browse and clean up the application folder',
      value: tree.when(
        data: (data) => formatByteSize(data.totalBytes),
        loading: () => null,
        error: (_, _) => null,
      ),
      trailing: tree.isLoading
          ? const SizedBox(
              height: NahpuControlSize.iconSmall,
              width: NahpuControlSize.iconSmall,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DataUsageSettings()),
      ),
    );
  }
}

/// The file explorer: totals, the prune action, and the directory tree.
class DataUsageSettings extends ConsumerStatefulWidget {
  const DataUsageSettings({super.key});

  @override
  ConsumerState<DataUsageSettings> createState() => _DataUsageSettingsState();
}

class _DataUsageSettingsState extends ConsumerState<DataUsageSettings> {
  bool _isSelecting = false;
  bool _isExporting = false;
  final Set<String> _selected = <String>{};
  final NahpuFileTreeController _fileTreeController = NahpuFileTreeController();

  @override
  void dispose() {
    _fileTreeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tree = ref.watch(appFileTreeProvider);
    final scannedTree = tree.asData?.value;
    final deletablePaths = scannedTree == null
        ? const <String>[]
        : collectDeletablePaths(scannedTree.root);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data usage'),
        actions: [
          IconButton(
            tooltip: 'Rescan',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: tree.isLoading
                ? null
                : () => ref.read(appFileTreeProvider.notifier).refresh(),
          ),
        ],
      ),
      body: tree.when(
        loading: () => const Center(child: CommonProgressIndicator()),
        error: (error, _) => _ScanError(error: error),
        data: (data) => CommonSettingList(
          sections: [
            _SummarySection(tree: data),
            _PrunePanel(tree: data),
            SizedBox(
              width: double.infinity,
              child: CommonSettingSection(
                title: 'Files',
                children: [
                  _FileTreeHeader(
                    root: data.root,
                    controller: _fileTreeController,
                    isSelecting: _isSelecting,
                    onSelect: () => setState(() => _isSelecting = true),
                    onSelectAll:
                        deletablePaths.any((path) => !_selected.contains(path))
                        ? () => setState(() {
                            _selected
                              ..clear()
                              ..addAll(deletablePaths);
                          })
                        : null,
                  ),
                  Divider(
                    height: NahpuStroke.thin,
                    thickness: NahpuStroke.thin,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  NahpuFileTreeView(
                    root: data.root,
                    controller: _fileTreeController,
                    isSelecting: _isSelecting,
                    selected: _selected,
                    onSelectionChanged: (node) => setState(() {
                      if (!_selected.remove(node.path)) {
                        _selected.add(node.path);
                      }
                    }),
                    onDirectorySelectionChanged: _toggleDirectory,
                    onDeleteDirectory: _confirmDeleteDirectory,
                    onSaveCopy: _saveCopy,
                    onDeleteFile: _confirmDeleteFile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isSelecting
          ? _SelectionToolbar(
              selectedCount: _selected.length,
              canReview: _selected.isNotEmpty && scannedTree != null,
              isReviewing: _isExporting,
              onClear: _selected.isEmpty
                  ? null
                  : () => setState(_selected.clear),
              onReview: scannedTree == null
                  ? null
                  : () => _reviewSelection(scannedTree),
              onDone: () => setState(() {
                _isSelecting = false;
                _selected.clear();
              }),
            )
          : null,
    );
  }

  /// Selects or clears every removable file in a folder.
  ///
  /// Locked files in the subtree are skipped rather than blocking the folder,
  /// so a project with one linked photo is still selectable; the child rows
  /// keep their lock icons to show what was left behind.
  void _toggleDirectory(NahpuDirectoryNode node) {
    final paths = collectDeletablePaths(node);
    if (paths.isEmpty) return;
    final allSelected = paths.every(_selected.contains);
    setState(() {
      if (allSelected) {
        _selected.removeAll(paths);
      } else {
        _selected.addAll(paths);
      }
    });
  }

  /// Summarises the selection, then routes to export or delete.
  Future<void> _reviewSelection(AppFileTree tree) async {
    final paths = _selected.toList();
    if (paths.isEmpty) return;
    final root = ref.read(appFileTreeProvider.notifier).rootPath;
    if (root == null) return;

    final groups = summarizeSelection(
      root: root,
      paths: paths,
      tree: tree.root,
    );
    final totalBytes = groups.fold<int>(0, (sum, g) => sum + g.sizeBytes);

    final review = await showSelectionReview(
      context: context,
      groups: groups,
      fileCount: paths.length,
      sizeBytes: totalBytes,
    );
    if (!mounted || review == null) return;

    switch (review.action) {
      case SelectionAction.delete:
        await _confirmDeleteSelection();
      case SelectionAction.export:
        final settings = review.exportSettings;
        if (settings != null) {
          await _exportSelection(root, paths, settings);
        }
    }
  }

  /// Writes the selection to an archive, then offers to reclaim the space.
  ///
  /// The removal prompt is only reached once the archive is on disk and
  /// non-empty, so a failed or cancelled export never costs the user a file.
  Future<void> _exportSelection(
    String root,
    List<String> paths,
    SelectionExportSettings settings,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isExporting = true);
    try {
      final result = await const SelectionExportService().export(
        root: root,
        paths: paths,
        destination: settings.destination,
        format: settings.format,
        fileStem: settings.appendDate
            ? appendDateToFileStem(settings.fileStem, DateTime.now())
            : settings.fileStem.trim(),
      );
      if (!mounted) return;
      setState(() => _isExporting = false);

      final removeOriginals = await _confirm(
        title: 'Remove the originals?',
        body:
            '${result.fileCount} '
            '${result.fileCount == 1 ? 'file was' : 'files were'} written to '
            '${result.archive.path.split(Platform.pathSeparator).last} '
            '(${formatByteSize(result.sizeBytes)}).\n\n'
            'Removing them from NAHPU frees the space. The archive keeps your '
            'copy, and this cannot be undone.',
      );
      if (removeOriginals) {
        await _delete(result.exportedPaths);
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text('Exported to ${result.archive.path}')),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _isExporting = false);
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $error')));
    }
  }

  /// Saves a copy out of the app folder, so a file can be kept before it goes.
  Future<void> _saveCopy(NahpuFileNode node) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FilePickerServices().shareFile(context, File(node.path));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save ${node.name}: $error')),
      );
    }
  }

  Future<void> _confirmDeleteFile(NahpuFileNode node) async {
    final confirmed = await _confirm(
      title: 'Remove this file?',
      body:
          '${node.name} (${formatByteSize(node.sizeBytes)}) is not linked to '
          'any record. This cannot be undone.',
    );
    if (confirmed) await _delete([node.path]);
  }

  /// Removes a folder the tree showed as empty.
  ///
  /// Only reachable for folders with nothing in them, so there is no content to
  /// enumerate in the prompt — the question is just whether the folder goes.
  Future<void> _confirmDeleteDirectory(NahpuDirectoryNode node) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await _confirm(
      title: 'Remove this empty folder?',
      body:
          '${node.name} holds no files. Removing it does not affect any '
          'record.',
    );
    if (!confirmed) return;

    try {
      final result = await ref
          .read(appFileTreeProvider.notifier)
          .deleteDirectories([node.path]);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.deletedCount > 0
                ? 'Removed ${node.name}.'
                : 'Could not remove ${node.name}.',
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  Future<void> _confirmDeleteSelection() async {
    final count = _selected.length;
    final confirmed = await _confirm(
      title: 'Delete $count selected ${count == 1 ? 'file' : 'files'}?',
      body: 'These files are not linked to any record. This cannot be undone.',
      confirmLabel: 'Delete permanently',
    );
    if (confirmed) await _delete(_selected.toList());
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    String confirmLabel = 'Remove',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _delete(List<String> paths) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await ref
          .read(appFileTreeProvider.notifier)
          .deleteFiles(paths);
      if (mounted) setState(_selected.clear);
      messenger.showSnackBar(SnackBar(content: Text(_summarize(result))));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('$error')));
    }
  }
}

/// Stays above the independently scrolling rows, inside the Files surface.
class _FileTreeHeader extends StatelessWidget {
  const _FileTreeHeader({
    required this.root,
    required this.controller,
    required this.isSelecting,
    required this.onSelect,
    required this.onSelectAll,
  });

  final NahpuDirectoryNode root;
  final NahpuFileTreeController controller;
  final bool isSelecting;
  final VoidCallback onSelect;
  final VoidCallback? onSelectAll;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.md),
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final allExpanded = controller.areAllExpanded(root);
            final hasDirectories = controller.hasDirectories(root);
            final buttonStyle = TextButton.styleFrom(
              minimumSize: const Size(0, NahpuControlSize.touchTarget),
            );
            return Wrap(
              alignment: WrapAlignment.end,
              spacing: NahpuSpacing.xs,
              runSpacing: NahpuSpacing.xs,
              children: [
                TextButton.icon(
                  style: buttonStyle,
                  icon: Icon(
                    allExpanded ? Icons.unfold_less : Icons.unfold_more,
                  ),
                  label: Text(allExpanded ? 'Collapse all' : 'Expand all'),
                  onPressed: hasDirectories
                      ? () {
                          if (allExpanded) {
                            controller.collapseAll(root);
                          } else {
                            controller.expandAll(root);
                          }
                        }
                      : null,
                ),
                TextButton.icon(
                  style: buttonStyle,
                  icon: const Icon(Icons.checklist_rounded),
                  label: Text(isSelecting ? 'Select all' : 'Select'),
                  onPressed: isSelecting ? onSelectAll : onSelect,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SelectionToolbar extends StatelessWidget {
  const _SelectionToolbar({
    required this.selectedCount,
    required this.canReview,
    required this.isReviewing,
    required this.onClear,
    required this.onReview,
    required this.onDone,
  });

  final int selectedCount;
  final bool canReview;
  final bool isReviewing;
  final VoidCallback? onClear;
  final VoidCallback? onReview;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: NahpuElevation.low,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: NahpuContentWidth.settings,
            ),
            child: Padding(
              padding: const EdgeInsets.all(NahpuSpacing.md),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact =
                      constraints.maxWidth < NahpuBreakpoints.compact;
                  final left = _ClearSelectionAction(
                    compact: compact,
                    onClear: onClear,
                  );
                  final right = _ReviewActions(
                    compact: compact,
                    selectedCount: selectedCount,
                    isReviewing: isReviewing,
                    canReview: canReview,
                    onReview: onReview,
                    onDone: onDone,
                  );
                  return OverflowBar(
                    alignment: MainAxisAlignment.spaceBetween,
                    overflowAlignment: OverflowBarAlignment.end,
                    spacing: NahpuSpacing.md,
                    overflowSpacing: NahpuSpacing.xs,
                    children: [left, right],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClearSelectionAction extends StatelessWidget {
  const _ClearSelectionAction({required this.compact, required this.onClear});

  final bool compact;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = TextButton.styleFrom(
      minimumSize: const Size(0, NahpuControlSize.touchTarget),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? NahpuSpacing.sm : NahpuSpacing.md,
      ),
    );
    return TextButton(
      style: buttonStyle,
      onPressed: onClear,
      child: const Text('Clear'),
    );
  }
}

class _ReviewActions extends StatelessWidget {
  const _ReviewActions({
    required this.compact,
    required this.selectedCount,
    required this.isReviewing,
    required this.canReview,
    required this.onReview,
    required this.onDone,
  });

  final bool compact;
  final int selectedCount;
  final bool isReviewing;
  final bool canReview;
  final VoidCallback? onReview;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final review = FilledButton.icon(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, NahpuControlSize.touchTarget),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? NahpuSpacing.sm : NahpuSpacing.md,
        ),
      ),
      onPressed: canReview && !isReviewing ? onReview : null,
      icon: isReviewing
          ? const SizedBox.square(
              dimension: NahpuControlSize.indicator,
              child: CircularProgressIndicator(
                strokeWidth: NahpuStroke.regular,
              ),
            )
          : compact
          ? null
          : const Icon(Icons.fact_check_outlined),
      label: Text('Review $selectedCount'),
    );
    final done = OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, NahpuControlSize.touchTarget),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? NahpuSpacing.sm : NahpuSpacing.md,
        ),
      ),
      onPressed: onDone,
      icon: compact ? null : const Icon(Icons.done_rounded),
      label: const Text('Done'),
    );
    return Wrap(
      alignment: compact ? WrapAlignment.end : WrapAlignment.end,
      spacing: NahpuSpacing.md,
      runSpacing: NahpuSpacing.xs,
      children: [review, done],
    );
  }
}

/// Shown when the reference index could not be built.
///
/// The tree is deliberately not rendered in this state: without a trustworthy
/// index every file would read as unlinked.
class _ScanError extends ConsumerWidget {
  const _ScanError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: NahpuControlSize.iconLarge,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: NahpuSpacing.lg),
            Text(
              'Could not read the application folder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: NahpuSpacing.md),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: NahpuSpacing.xl),
            SecondaryButton(
              text: 'Try again',
              onPressed: () => ref.read(appFileTreeProvider.notifier).refresh(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.tree});

  final AppFileTree tree;

  @override
  Widget build(BuildContext context) {
    return CommonSettingSection(
      isDivided: true,
      children: [
        CommonSettingTile(
          icon: Icons.data_usage_outlined,
          title: 'Total usage',
          value: formatByteSize(tree.totalBytes),
          onTap: null,
        ),
        CommonSettingTile(
          icon: Icons.file_copy_outlined,
          title: 'Files',
          label: 'Include images and other files',
          value: '${tree.fileCount}',
          onTap: null,
        ),
        CommonSettingTile(
          icon: Icons.photo_library_outlined,
          title: 'Media files',
          label: 'Images, audio, video',
          value: '${tree.mediaCount}',
          onTap: null,
        ),
        CommonSettingTile(
          icon: Icons.link_off,
          title: 'Reclaimable',
          label: 'Unlinked files that can be removed',
          value: tree.danglingCount == 0
              ? 'None'
              : '${tree.danglingCount} · ${formatByteSize(tree.danglingBytes)}',
          onTap: null,
        ),
      ],
    );
  }
}

/// The single prune action, with the explanation it needs to be safe to press.
class _PrunePanel extends ConsumerStatefulWidget {
  const _PrunePanel({required this.tree});

  final AppFileTree tree;

  @override
  ConsumerState<_PrunePanel> createState() => _PrunePanelState();
}

class _PrunePanelState extends ConsumerState<_PrunePanel> {
  bool _isPruning = false;

  @override
  Widget build(BuildContext context) {
    final tree = widget.tree;
    final colors = Theme.of(context).colorScheme;

    return CommonSettingSection(
      children: [
        Padding(
          padding: const EdgeInsets.all(NahpuSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remove unlinked files',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: NahpuSpacing.md),
              Text(
                'Unlinked files are no longer used by any record, such as '
                'leftovers from deleted media or cancelled imports. Removing '
                'them also deletes any empty folders they leave behind. Linked '
                'files, databases and backups, custom fonts, map layers, and '
                'files outside NAHPU-managed folders are not affected.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (tree.pruneBlockedReason != null) ...[
                const SizedBox(height: NahpuSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: NahpuControlSize.iconSmall,
                      color: colors.error,
                    ),
                    const SizedBox(width: NahpuSpacing.md),
                    Expanded(
                      child: Text(
                        tree.pruneBlockedReason!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: colors.error),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: NahpuSpacing.xl),
              Center(
                child: tree.danglingCount == 0
                    ? Text(
                        'Nothing to reclaim.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      )
                    : PrimaryButton(
                        icon: Icons.cleaning_services_outlined,
                        label:
                            'Remove ${tree.danglingCount} unlinked '
                            '${tree.danglingCount == 1 ? 'file' : 'files'} '
                            '(${formatByteSize(tree.danglingBytes)})',
                        isRunning: _isPruning,
                        onPressed: tree.canPrune ? _confirmPrune : null,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmPrune() async {
    final tree = widget.tree;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${tree.danglingCount} unlinked files?'),
        content: Text(
          'This frees ${formatByteSize(tree.danglingBytes)}. Files still '
          'linked to your records, your database and its backups, and your '
          'custom fonts and map layers are not affected.\n\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isPruning = true);
    try {
      final result = await ref.read(appFileTreeProvider.notifier).prune();
      messenger.showSnackBar(SnackBar(content: Text(_summarize(result))));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _isPruning = false);
    }
  }
}

String _summarize(PruneResult result) {
  final files = result.deletedCount == 1 ? 'file' : 'files';
  final base =
      'Removed ${result.deletedCount} $files '
      '(${formatByteSize(result.freedBytes)})';
  if (!result.hasFailures) return '$base.';
  final kept = result.failedPaths.length;
  return '$base. $kept ${kept == 1 ? 'file was' : 'files were'} kept because '
      'they changed during the scan.';
}
