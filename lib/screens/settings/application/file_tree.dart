import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/providers/file_explorer.dart';
import 'package:nahpu/services/types/file_explorer.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Left inset of a top-level row.
///
/// Matches the effective text inset of [CommonSettingTile], whose `ListTile`
/// adds 16 inside an 8 padding, so tree rows line up with the summary tiles
/// above them instead of starting their own margin.
const double _rowInset = NahpuSpacing.xxl;

/// One indent step per depth level.
const double _indentStep = NahpuSpacing.xl;

/// Maximum height of the independently scrollable file-tree viewport.
const double _maxTreeHeight = 560;

/// Controls which directory rows are open in a [NahpuFileTreeView].
class NahpuFileTreeController extends ChangeNotifier {
  Set<String>? _expandedPaths;

  /// Whether the tree contains at least one directory that can be expanded.
  bool hasDirectories(NahpuDirectoryNode root) =>
      _directoryPaths(root).isNotEmpty;

  /// Whether every directory below [root] is currently open.
  bool areAllExpanded(NahpuDirectoryNode root) {
    final directories = _directoryPaths(root);
    if (directories.isEmpty) return false;
    final expanded = expandedPaths(root);
    return directories.every(expanded.contains);
  }

  /// Expands every directory below [root].
  void expandAll(NahpuDirectoryNode root) {
    _expandedPaths = _directoryPaths(root).toSet();
    notifyListeners();
  }

  /// Collapses every directory below [root].
  void collapseAll(NahpuDirectoryNode root) {
    _expandedPaths = <String>{};
    notifyListeners();
  }

  Set<String> expandedPaths(NahpuDirectoryNode root) {
    return _expandedPaths ?? _initialExpandedPaths(root);
  }

  void toggleDirectory(NahpuDirectoryNode root, String path) {
    final expanded = _expandedPaths ??= _initialExpandedPaths(root);
    if (!expanded.remove(path)) expanded.add(path);
    notifyListeners();
  }

  Set<String> _initialExpandedPaths(NahpuDirectoryNode root) {
    return {
      for (final child in root.children)
        if (child case NahpuDirectoryNode()) child.path,
    };
  }

  List<String> _directoryPaths(NahpuDirectoryNode root) {
    final paths = <String>[];
    void visit(NahpuTreeNode node) {
      if (node case NahpuDirectoryNode()) {
        paths.add(node.path);
        node.children.forEach(visit);
      }
    }

    root.children.forEach(visit);
    return paths;
  }
}

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
    this.controller,
    this.onSaveCopy,
    this.isSelecting = false,
    this.selected = const <String>{},
    this.onSelectionChanged,
    this.onDirectorySelectionChanged,
    this.onDeleteDirectory,
  });

  final NahpuDirectoryNode root;
  final ValueChanged<NahpuFileNode> onDeleteFile;
  final NahpuFileTreeController? controller;

  /// Saves a copy of a file out of the app folder before it is removed.
  final ValueChanged<NahpuFileNode>? onSaveCopy;

  /// Swaps every deletable row's actions for a checkbox.
  final bool isSelecting;
  final Set<String> selected;
  final ValueChanged<NahpuFileNode>? onSelectionChanged;

  /// Toggles every removable file in a folder's subtree at once.
  final ValueChanged<NahpuDirectoryNode>? onDirectorySelectionChanged;

  /// Removes an empty folder.
  final ValueChanged<NahpuDirectoryNode>? onDeleteDirectory;

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
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant NahpuFileTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final expanded = widget.controller?.expandedPaths(widget.root) ?? _expanded;
    final rows = flattenVisibleRows(widget.root, expanded);
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: Text(
          'The application folder is empty.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: _maxTreeHeight),
      child: ListView.builder(
        primary: false,
        shrinkWrap: true,
        // Keeps the last row off the section's bottom border.
        padding: const EdgeInsets.only(bottom: NahpuSpacing.md),
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final row = rows[index];
          final node = row.node;
          if (node is NahpuDirectoryNode) {
            return _DirectoryRow(
              node: node,
              depth: row.depth,
              isExpanded: expanded.contains(node.path),
              isSelecting: widget.isSelecting,
              selectionState: directorySelectionState(node, widget.selected),
              onSelectionChanged: widget.onDirectorySelectionChanged == null
                  ? null
                  : () => widget.onDirectorySelectionChanged!(node),
              onDelete: widget.onDeleteDirectory == null
                  ? null
                  : () => widget.onDeleteDirectory!(node),
              onToggle: () => widget.controller == null
                  ? setState(() {
                      if (!_expanded.remove(node.path)) {
                        _expanded.add(node.path);
                      }
                    })
                  : widget.controller!.toggleDirectory(widget.root, node.path),
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
      ),
    );
  }
}

/// Wraps a row so every line in the tree is the same height and inset.
///
/// Directory and file rows used to set their own padding, which left the list
/// visibly ragged and out of line with the settings tiles above it.
class _TreeRow extends StatelessWidget {
  const _TreeRow({required this.depth, required this.children, this.onTap});

  final int depth;
  final List<Widget> children;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact;
    // Bound compact indentation so deeply nested files still have room for
    // their names, sizes, and actions.
    final leftInset = compact
        ? NahpuSpacing.md +
              (depth * NahpuSpacing.md).clamp(0.0, NahpuSpacing.xxl)
        : _rowInset + depth * _indentStep;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: NahpuControlSize.touchTarget,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          leftInset,
          NahpuSpacing.xs,
          // A trailing gutter, so row buttons and checkboxes keep clear of the
          // section's rounded border.
          NahpuSpacing.lg,
          NahpuSpacing.xs,
        ),
        child: Row(children: children),
      ),
    );
    if (onTap == null) return row;
    // Self-contained Material so the row keeps its ink response wherever the
    // tree is embedded.
    return Material(
      type: MaterialType.transparency,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

class _DirectoryRow extends StatelessWidget {
  const _DirectoryRow({
    required this.node,
    required this.depth,
    required this.isExpanded,
    required this.isSelecting,
    required this.selectionState,
    required this.onSelectionChanged,
    required this.onDelete,
    required this.onToggle,
  });

  final NahpuDirectoryNode node;
  final int depth;
  final bool isExpanded;
  final bool isSelecting;

  /// True, false, or null for a folder only partly selected.
  final bool? selectionState;
  final VoidCallback? onSelectionChanged;
  final VoidCallback? onDelete;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact;
    final spacing = compact ? NahpuSpacing.sm : NahpuSpacing.lg;
    return _TreeRow(
      depth: depth,
      onTap: onToggle,
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
        SizedBox(width: spacing),
        Icon(
          isExpanded ? Icons.folder_open_outlined : Icons.folder_outlined,
          size: NahpuControlSize.iconMedium,
          color: colors.primary,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        SizedBox(width: spacing),
        Text(
          formatByteSize(node.sizeBytes),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        SizedBox(width: spacing),
        _DirectoryAffordance(
          node: node,
          isSelecting: isSelecting,
          selectionState: selectionState,
          onSelectionChanged: onSelectionChanged,
          onDelete: onDelete,
        ),
      ],
    );
  }

  String _subtitle() {
    // The scanner already puts the file count, and the project name for a
    // project folder, on this line.
    final parts = <String>[node.subtitle ?? ''];
    if (node.danglingCount > 0) parts.add('${node.danglingCount} unlinked');
    return parts.where((part) => part.isNotEmpty).join(' · ');
  }
}

/// A folder's trailing slot: a checkbox while selecting, otherwise nothing.
///
/// The box appears only when the subtree actually holds something removable,
/// and goes indeterminate when only part of it is selected, so its state always
/// matches what tapping it would do.
class _DirectoryAffordance extends StatelessWidget {
  const _DirectoryAffordance({
    required this.node,
    required this.isSelecting,
    required this.selectionState,
    required this.onSelectionChanged,
    required this.onDelete,
  });

  final NahpuDirectoryNode node;
  final bool isSelecting;
  final bool? selectionState;
  final VoidCallback? onSelectionChanged;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    if (!isSelecting && node.isRemovableWhenEmpty && onDelete != null) {
      return IconButton(
        tooltip: 'Remove this empty folder',
        visualDensity: VisualDensity.compact,
        iconSize: NahpuControlSize.iconMedium,
        color: Theme.of(context).colorScheme.error,
        icon: const Icon(Icons.delete_outline_rounded),
        onPressed: onDelete,
      );
    }
    if (!isSelecting || !node.isSelectable) {
      return const SizedBox(width: NahpuControlSize.touchTarget);
    }
    return Tooltip(
      message: node.deletableCount == node.fileCount
          ? 'Select this folder'
          : 'Select the ${node.deletableCount} removable '
                '${node.deletableCount == 1 ? 'file' : 'files'} here',
      child: Checkbox(
        tristate: true,
        value: selectionState,
        onChanged: onSelectionChanged == null
            ? null
            : (_) => onSelectionChanged!(),
      ),
    );
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
    final compact = MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact;
    final spacing = compact ? NahpuSpacing.sm : NahpuSpacing.lg;
    return _TreeRow(
      depth: depth,
      children: [
        // Reserve the chevron column so file icons align with folder icons.
        SizedBox(width: NahpuControlSize.iconMedium + spacing),
        Icon(
          _formatIcon(node.format),
          size: NahpuControlSize.iconMedium,
          color: colors.onSurfaceVariant,
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Text(
            node.name,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        SizedBox(width: spacing),
        Text(
          formatByteSize(node.sizeBytes),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        SizedBox(width: spacing),
        _StatusAffordance(
          node: node,
          isSelecting: isSelecting,
          isSelected: isSelected,
          onSelectionChanged: onSelectionChanged,
          onSaveCopy: onSaveCopy,
          onDelete: onDelete,
        ),
      ],
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
      return SizedBox(
        width: NahpuControlSize.touchTarget,
        child: Checkbox(
          value: isSelected,
          onChanged: onSelectionChanged == null
              ? null
              : (_) => onSelectionChanged!(),
        ),
      );
    }

    if (!node.isManuallyDeletable) return _LockBadge(node: node);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (node.isDangling)
          Padding(
            padding: const EdgeInsets.only(right: NahpuSpacing.xs),
            child: Icon(
              Icons.link_off,
              size: NahpuControlSize.iconSmall,
              color: colors.error,
            ),
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
    // Same width as the checkbox that replaces it, so a row does not shift
    // sideways when selection mode turns on.
    return Tooltip(
      message: node.lockReason?.label ?? 'Kept',
      child: SizedBox(
        width: NahpuControlSize.touchTarget,
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
