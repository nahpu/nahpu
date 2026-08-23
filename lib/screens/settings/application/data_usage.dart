import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/settings/application/file_tree.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
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
  final Set<String> _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final tree = ref.watch(appFileTreeProvider);
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
            CommonSettingSection(
              title: 'Files',
              children: [
                SelectItemsInterface(
                  isSelecting: _isSelecting,
                  onClearPressed: _selected.isEmpty
                      ? null
                      : () => setState(_selected.clear),
                  onSelectAllPressed: () => setState(() {
                    _selected
                      ..clear()
                      ..addAll(_deletablePaths(data.root));
                  }),
                  onSelectPressed: () => setState(() {
                    _isSelecting = !_isSelecting;
                    if (!_isSelecting) _selected.clear();
                  }),
                ),
                if (_isSelecting && _selected.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: NahpuSpacing.xl,
                      vertical: NahpuSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_selected.length} selected',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Remove selected'),
                          onPressed: _confirmDeleteSelection,
                        ),
                      ],
                    ),
                  ),
                NahpuFileTreeView(
                  root: data.root,
                  isSelecting: _isSelecting,
                  selected: _selected,
                  onSelectionChanged: (node) => setState(() {
                    if (!_selected.remove(node.path)) _selected.add(node.path);
                  }),
                  onSaveCopy: _saveCopy,
                  onDeleteFile: _confirmDeleteFile,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Every file in the tree the user is allowed to remove by hand.
  List<String> _deletablePaths(NahpuDirectoryNode root) {
    final paths = <String>[];
    void visit(NahpuTreeNode node) {
      switch (node) {
        case NahpuFileNode():
          if (node.isManuallyDeletable) paths.add(node.path);
        case NahpuDirectoryNode():
          node.children.forEach(visit);
      }
    }

    visit(root);
    return paths;
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

  Future<void> _confirmDeleteSelection() async {
    final count = _selected.length;
    final confirmed = await _confirm(
      title: 'Remove $count selected ${count == 1 ? 'file' : 'files'}?',
      body: 'These files are not linked to any record. This cannot be undone.',
    );
    if (confirmed) await _delete(_selected.toList());
  }

  Future<bool> _confirm({required String title, required String body}) async {
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
            child: const Text('Remove'),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: NahpuSpacing.xl),
      child: NahpuPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remove unlinked files',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: NahpuSpacing.md),
            Text(
              'Unlinked files sit in the application folder but no longer '
              'belong to any record — leftovers from deleted media and '
              'cancelled imports. Removing them deletes the files and the '
              'empty folders they leave behind.\n\n'
              'Your database and its backups, every file still linked to a '
              'record, your custom fonts and map layers, and anything outside '
              "the folders NAHPU manages are never touched.",
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
