import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/providers/file_explorer.dart';
import 'package:nahpu/services/types/file_explorer.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Expandable tree of the application directory.
///
/// Rows are flattened to the currently visible set and rendered through a
/// `ListView.builder`, so expanding a project with thousands of media files
/// costs one row per visible line rather than one widget per file.
class NahpuFileTreeView extends StatefulWidget {
  const NahpuFileTreeView({
    super.key,
    required this.root,
    required this.onDeleteFile,
    this.onSaveCopy,
    this.isSelecting = false,
    this.selected = const <String>{},
    this.onSelectionChanged,
  });

  final NahpuDirectoryNode root;
  final ValueChanged<NahpuFileNode> onDeleteFile;

  /// Saves a copy of a file out of the app folder before it is removed.
  final ValueChanged<NahpuFileNode>? onSaveCopy;

  /// Swaps every deletable row's actions for a checkbox.
  final bool isSelecting;
  final Set<String> selected;
  final ValueChanged<NahpuFileNode>? onSelectionChanged;

  @override
  State<NahpuFileTreeView> createState() => _NahpuFileTreeViewState();
}

class _NahpuFileTreeViewState extends State<NahpuFileTreeView> {
  final Set<String> _expanded = <String>{};

  @override
  void initState() {
    super.initState();
    // Open the first level so the screen never opens on a single closed row.
    for (final child in widget.root.children) {
      if (child is NahpuDirectoryNode) _expanded.add(child.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = flattenVisibleRows(widget.root, _expanded);
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: Text(
          'The application folder is empty.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        final node = row.node;
        if (node is NahpuDirectoryNode) {
          return _DirectoryRow(
            node: node,
            depth: row.depth,
            isExpanded: _expanded.contains(node.path),
            onToggle: () => setState(() {
              if (!_expanded.remove(node.path)) _expanded.add(node.path);
            }),
          );
        }
        final file = node as NahpuFileNode;
        return _FileRow(
          node: file,
          depth: row.depth,
          isSelecting: widget.isSelecting,
          isSelected: widget.selected.contains(file.path),
          onSelectionChanged: widget.onSelectionChanged == null
              ? null
              : () => widget.onSelectionChanged!(file),
          onSaveCopy: widget.onSaveCopy == null
              ? null
              : () => widget.onSaveCopy!(file),
          onDelete: () => widget.onDeleteFile(file),
        );
      },
    );
  }
}

class _DirectoryRow extends StatelessWidget {
  const _DirectoryRow({
    required this.node,
    required this.depth,
    required this.isExpanded,
    required this.onToggle,
  });

  final NahpuDirectoryNode node;
  final int depth;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Self-contained Material so the row keeps its ink response wherever the
    // tree is embedded.
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            NahpuSpacing.md + depth * NahpuSpacing.xl,
            NahpuSpacing.md,
            NahpuSpacing.md,
            NahpuSpacing.md,
          ),
          child: Row(
            children: [
              AnimatedRotation(
                turns: isExpanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  Icons.chevron_right,
                  size: NahpuControlSize.iconMedium,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: NahpuSpacing.md),
              Icon(
                isExpanded ? Icons.folder_open_outlined : Icons.folder_outlined,
                size: NahpuControlSize.iconMedium,
                color: colors.primary,
              ),
              const SizedBox(width: NahpuSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      _subtitle(),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: NahpuSpacing.md),
              Text(
                formatByteSize(node.sizeBytes),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[];
    // A project folder already carries its file count in the title, so the
    // second line shows the UUID instead of repeating it.
    if (node.subtitle != null) {
      parts.add(node.subtitle!);
    } else {
      parts.add('${node.fileCount} ${node.fileCount == 1 ? 'file' : 'files'}');
    }
    if (node.danglingCount > 0) parts.add('${node.danglingCount} unlinked');
    return parts.join(' · ');
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.node,
    required this.depth,
    required this.isSelecting,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onSaveCopy,
    required this.onDelete,
  });

  final NahpuFileNode node;
  final int depth;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback? onSelectionChanged;
  final VoidCallback? onSaveCopy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        NahpuSpacing.md + depth * NahpuSpacing.xl,
        NahpuSpacing.sm,
        NahpuSpacing.md,
        NahpuSpacing.sm,
      ),
      child: Row(
        children: [
          const SizedBox(width: NahpuControlSize.iconMedium),
          const SizedBox(width: NahpuSpacing.md),
          Icon(
            _formatIcon(node.format),
            size: NahpuControlSize.iconMedium,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: NahpuSpacing.lg),
          Expanded(
            child: Text(
              node.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: NahpuSpacing.md),
          Text(
            formatByteSize(node.sizeBytes),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(width: NahpuSpacing.lg),
          _StatusAffordance(
            node: node,
            isSelecting: isSelecting,
            isSelected: isSelected,
            onSelectionChanged: onSelectionChanged,
            onSaveCopy: onSaveCopy,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}

/// The trailing controls for a file row.
///
/// A file the user cannot remove gets no delete button at all rather than a
/// disabled one — a greyed-out control invites them to hunt for a way to enable
/// it, when the answer is that the file is spoken for.
class _StatusAffordance extends StatelessWidget {
  const _StatusAffordance({
    required this.node,
    required this.isSelecting,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onSaveCopy,
    required this.onDelete,
  });

  final NahpuFileNode node;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback? onSelectionChanged;
  final VoidCallback? onSaveCopy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (isSelecting) {
      // Files that cannot be removed still show a slot, so rows stay aligned.
      if (!node.isManuallyDeletable) {
        return _LockBadge(node: node);
      }
      return Checkbox(
        value: isSelected,
        onChanged: onSelectionChanged == null
            ? null
            : (_) => onSelectionChanged!(),
      );
    }

    if (!node.isManuallyDeletable) return _LockBadge(node: node);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (node.isDangling)
          Icon(
            Icons.link_off,
            size: NahpuControlSize.iconSmall,
            color: colors.error,
          ),
        if (onSaveCopy != null)
          IconButton(
            tooltip: 'Save a copy',
            visualDensity: VisualDensity.compact,
            iconSize: NahpuControlSize.iconMedium,
            color: colors.onSurfaceVariant,
            icon: const Icon(Icons.download_outlined),
            onPressed: onSaveCopy,
          ),
        IconButton(
          tooltip: 'Remove this file',
          visualDensity: VisualDensity.compact,
          iconSize: NahpuControlSize.iconMedium,
          color: colors.error,
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: onDelete,
        ),
      ],
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge({required this.node});

  final NahpuFileNode node;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: node.lockReason?.label ?? 'Kept',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.md),
        child: Icon(
          Icons.lock_outline,
          size: NahpuControlSize.iconSmall,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

IconData _formatIcon(NahpuFileFormat format) => switch (format) {
  NahpuFileFormat.image => Icons.image_outlined,
  NahpuFileFormat.audio => Icons.audiotrack_outlined,
  NahpuFileFormat.video => Icons.movie_outlined,
  NahpuFileFormat.pdf => Icons.picture_as_pdf_outlined,
  NahpuFileFormat.tabulated => Icons.table_chart_outlined,
  NahpuFileFormat.database => Icons.storage_outlined,
  NahpuFileFormat.other => Icons.insert_drive_file_outlined,
};
