import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/common/file_explorer_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/file_explorer.dart';
import 'package:path/path.dart' as path;

/// One scan of the application directory, shared by every tile on the data
/// usage screen.
///
/// The screen used to walk the whole tree four separate times to paint three
/// numbers. This holds a single scan instead.
final appFileTreeProvider =
    AsyncNotifierProvider<AppFileTreeNotifier, AppFileTree>(
      AppFileTreeNotifier.new,
    );

class AppFileTreeNotifier extends AsyncNotifier<AppFileTree> {
  AppFileReferenceIndex? _index;
  String? _root;

  /// Canonical application directory the current tree was scanned from.
  ///
  /// Exposed so the export can hand the archive writer the same root the paths
  /// are relative to, rather than resolving it a second time.
  String? get rootPath => _root;

  @override
  Future<AppFileTree> build() => _scan();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_scan);
  }

  /// Deletes the files the current scan identified, then rescans.
  ///
  /// Takes the paths from [AppFileTree.prunablePaths] rather than recomputing
  /// them, so only what the user was shown can be removed.
  Future<PruneResult> prune() async {
    final tree = state.value;
    if (tree == null) {
      throw StateError('Cannot remove files before the scan completes.');
    }
    if (!tree.canPrune) {
      throw StateError(
        tree.pruneBlockedReason ?? 'There are no unlinked files to remove.',
      );
    }

    final result = await _pruner().prune(tree.prunablePaths);
    await refresh();
    return result;
  }

  /// Removes files the user picked out, by row action or by selection.
  ///
  /// Wider than [prune]: backups and other files no record points at can be
  /// removed this way, because the user chose them individually.
  Future<PruneResult> deleteFiles(List<String> paths) async {
    if (paths.isEmpty) {
      return const PruneResult(deletedCount: 0, freedBytes: 0, failedPaths: []);
    }
    final result = await _pruner().deleteSelected(paths);
    await refresh();
    return result;
  }

  /// Removes empty folders the user picked out, then rescans.
  Future<PruneResult> deleteDirectories(List<String> paths) async {
    if (paths.isEmpty) {
      return const PruneResult(deletedCount: 0, freedBytes: 0, failedPaths: []);
    }
    final result = await _pruner().deleteDirectories(paths);
    await refresh();
    return result;
  }

  AppFilePruner _pruner() {
    final index = _index;
    final root = _root;
    if (index == null || root == null) {
      throw StateError('Cannot remove files before the scan completes.');
    }
    return AppFilePruner(
      index: index,
      root: root,
      structuralDirs: buildStructuralDirs(root, index.knownProjectUuids),
    );
  }

  Future<AppFileTree> _scan() async {
    final services = FileExplorerServices(db: ref.read(databaseProvider));
    // Let a failure here propagate: a partial index would report referenced
    // files as unlinked, and the screen must show an error instead.
    final index = await services.buildIndex();
    final root = await services.canonicalRoot();
    _index = index;
    _root = root;
    return AppFileTreeScanner(index: index, root: root).scan();
  }
}

/// Directory nodes flattened into the rows currently visible.
///
/// Building rows this way keeps a library of thousands of files on a
/// `ListView.builder`, instead of nesting `ExpansionTile`s that would build
/// every descendant whether or not it is on screen.
List<FileTreeRow> flattenVisibleRows(
  NahpuDirectoryNode root,
  Set<String> expandedPaths,
) {
  final rows = <FileTreeRow>[];

  void visit(NahpuTreeNode node, int depth) {
    rows.add(FileTreeRow(node: node, depth: depth));
    if (node is NahpuDirectoryNode && expandedPaths.contains(node.path)) {
      for (final child in node.children) {
        visit(child, depth + 1);
      }
    }
  }

  for (final child in root.children) {
    visit(child, 0);
  }
  return rows;
}

/// Every file under [node] the user may remove by hand.
///
/// Selection always stores file paths, never directory paths, so deletion and
/// the review summary need no special case for a folder.
List<String> collectDeletablePaths(NahpuTreeNode node) {
  final paths = <String>[];
  void visit(NahpuTreeNode current) {
    switch (current) {
      case NahpuFileNode():
        if (current.isManuallyDeletable) paths.add(current.path);
      case NahpuDirectoryNode():
        current.children.forEach(visit);
    }
  }

  visit(node);
  return paths;
}

/// Checkbox state for a directory row: all, none, or some of its deletable
/// files are selected. Null renders the indeterminate box.
bool? directorySelectionState(NahpuDirectoryNode node, Set<String> selected) {
  final paths = collectDeletablePaths(node);
  if (paths.isEmpty) return false;
  var chosen = 0;
  for (final path in paths) {
    if (selected.contains(path)) chosen += 1;
  }
  if (chosen == 0) return false;
  if (chosen == paths.length) return true;
  return null;
}

class FileTreeRow {
  const FileTreeRow({required this.node, required this.depth});

  final NahpuTreeNode node;
  final int depth;

  String get key => node.path;
}

/// Path of [node] relative to the application directory, for display.
String displayRelativePath(String root, String nodePath) {
  if (!path.isWithin(root, nodePath)) return nodePath;
  return path.relative(nodePath, from: root);
}
