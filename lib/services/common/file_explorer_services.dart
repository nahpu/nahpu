/// Explores the NAHPU application directory and identifies removable files.
///
/// The safety rule here is an allowlist. A file is only ever offered for
/// deletion when it sits in a directory whose role NAHPU defines — a project's
/// `media/<category>/` or `associatedData/<origin>/`, or `appMedia/personnel/`
/// — and nothing in the database points at it. Files anywhere else are shown
/// and sized but never removed.
///
/// The inversion matters because "no reference found" is much weaker than it
/// looks. A database restored from an older backup keeps every newer project's
/// media on disk with no rows to match ([DbRestore] only copies files in, it
/// never removes them), a map layer exists on disk before its catalog entry is
/// written, and backups may be `.zip` or `.tar.gz` rather than `.sqlite3`. In
/// each case the reference lookup correctly reports "nothing points here" about
/// a file the user very much wants to keep.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/personnel_queries.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/types/file_explorer.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:path/path.dart' as path;

/// Files touched more recently than this are never pruned.
///
/// Media import copies a file to disk *before* inserting its row
/// (`MultimediaServices._copySingleFile`), so a file that lands between the
/// scan and the delete is unreferenced by construction. The window also covers
/// partial copies, since `FileServices._copyFileToDir` is a plain, non-atomic
/// `File.copy`.
const Duration pruneSafetyWindow = Duration(minutes: 15);

/// Directory names NAHPU creates and re-creates, which the empty-directory
/// sweep must leave in place.
const Set<String> _mediaCategoryDirs = {
  'site',
  'event',
  'specimen',
  'narrative',
};

const Set<String> _associatedDataOriginDirs = {
  associatedDataSitesDir,
  associatedDataEventsDir,
  associatedDataSpecimensDir,
};

/// Directories at the app root that belong to the Flutter runtime, not to
/// NAHPU, and are skipped entirely rather than shown as unmanaged.
const Set<String> excludedRootDirs = {'flutter_engine'};

/// Bookkeeping files that inflate the count without being interesting.
bool _isNoiseFile(String basename) {
  return basename == '.DS_Store' ||
      basename == 'Thumbs.db' ||
      basename.startsWith('._');
}

/// Reduces an absolute reference to a key comparable with the scan.
///
/// The documents directory commonly reaches one tree by two names (`/var` and
/// `/private/var` on macOS), and a reference stored under one spelling would
/// never match a file found under the other. Everything is keyed by its path
/// relative to the canonical root instead of by an absolute string.
String? referenceKeyFor(String root, String absolutePath) {
  final normalized = path.normalize(absolutePath);
  if (path.isWithin(root, normalized)) {
    return path.relative(normalized, from: root);
  }
  // The reference may spell the same file through an unresolved symlink.
  try {
    final parent = Directory(path.dirname(normalized));
    if (parent.existsSync()) {
      final resolved = path.join(
        parent.resolveSymbolicLinksSync(),
        path.basename(normalized),
      );
      if (path.isWithin(root, resolved)) {
        return path.relative(resolved, from: root);
      }
    }
  } on FileSystemException {
    // Fall through: an unreachable parent simply is not inside the app dir.
  }
  return null;
}

/// Case-folds on platforms whose filesystems are case-insensitive.
///
/// Folding *widens* the reference set, so a mismatch locks a file rather than
/// exposing it. That is the safe direction: SQLite compares TEXT byte-exactly
/// while APFS and NTFS do not, and the disagreement must never cost a file.
String _foldKey(String value) {
  final trimmed = value.trim();
  return Platform.isMacOS || Platform.isWindows
      ? trimmed.toLowerCase()
      : trimmed;
}

/// Everything the database and the app layout know about files on disk.
class AppFileReferenceIndex {
  const AppFileReferenceIndex({
    required this.linkedBasenames,
    required this.linkedPaths,
    required this.knownProjectUuids,
    required this.projectNames,
    required this.unresolvedReferenceCount,
    required this.hasAnyReferenceRows,
  });

  /// Values of `media.fileName` and `personnel.photoPath`, folded.
  ///
  /// `personnel.photoPath` goes in as its raw column value, never as a
  /// basename: `PersonnelQuery.isImageUsed` compares the whole column against a
  /// basename, so a bundled `assets/avatars/x.png` row can never match a real
  /// file. Reducing it to `x.png` would start locking unrelated files.
  final Set<String> linkedBasenames;

  /// Absolute paths resolved from `associatedData.uri`, folded. Holds both the
  /// parsed path and the raw column value, since either form may be what a row
  /// stores.
  final Set<String> linkedPaths;

  final Set<String> knownProjectUuids;
  final Map<String, String> projectNames;

  /// Rows whose `uri` could not be resolved. Non-zero blocks bulk pruning.
  final int unresolvedReferenceCount;

  /// False when media, personnel, and associated data are all empty — which
  /// looks identical to a failed or mid-migration read.
  final bool hasAnyReferenceRows;

  bool isLinkedBasename(String basename) =>
      linkedBasenames.contains(_foldKey(basename));

  /// [relativePath] is relative to the canonical app directory.
  bool isLinkedPath(String relativePath) =>
      linkedPaths.contains(_foldKey(relativePath));
}

/// Builds the reference index, then walks and classifies the app directory.
class FileExplorerServices {
  const FileExplorerServices({required this.db});

  final Database db;

  /// Reads every reference the database holds, in four queries.
  ///
  /// Throws if any query fails. The caller must let that propagate: a partial
  /// index would mark referenced files as dangling.
  Future<AppFileReferenceIndex> buildIndex() async {
    final mediaRows = await MediaDbQuery(db).getAllMedia();
    final personnelRows = await PersonnelQuery(db).getAllPersonnel();
    final associatedRows = await AssociatedDataQuery(db).getAllAssociatedRows();
    final projects = await ProjectQuery(db).getAllProjects();

    final basenames = <String>{};
    for (final row in mediaRows) {
      final fileName = row.fileName;
      if (fileName != null && fileName.trim().isNotEmpty) {
        basenames.add(_foldKey(fileName));
      }
      // Legacy rows may carry a path here even though resolution no longer
      // uses it. Cheap to honour, and unreadable to lose a file over.
      final uri = row.uri;
      if (uri != null && uri.trim().isNotEmpty) {
        basenames.add(_foldKey(path.basename(uri)));
      }
    }

    for (final row in personnelRows) {
      final photoPath = row.photoPath;
      if (photoPath == null || photoPath.trim().isEmpty) continue;
      // Bundled avatars are assets, never files under the app directory.
      if (photoPath.startsWith('assets/')) continue;
      basenames.add(_foldKey(photoPath));
    }

    final root = await canonicalRoot();
    final linkedPaths = <String>{};
    var unresolved = 0;
    for (final row in associatedRows) {
      final uri = row.uri;
      // Deliberately not filtered by `type == 'File'`: a stale type value must
      // not cost the user a file.
      if (uri == null || uri.trim().isEmpty) continue;
      // The raw value too, since a managed row stores its key verbatim.
      linkedPaths.add(_foldKey(uri));
      try {
        final resolved = _resolveReference(root, row.projectUuid, uri);
        if (resolved != null) {
          final key = referenceKeyFor(root, resolved);
          if (key != null) linkedPaths.add(_foldKey(key));
        }
      } catch (error) {
        // An unreadable reference is a reason to keep files, not delete them.
        unresolved += 1;
        if (kDebugMode) {
          debugPrint('Unresolvable associated data uri "$uri": $error');
        }
        basenames.add(_foldKey(path.basename(uri.replaceAll('\\', '/'))));
      }
    }

    return AppFileReferenceIndex(
      linkedBasenames: basenames,
      linkedPaths: linkedPaths,
      knownProjectUuids: projects.map((e) => e.uuid).toSet(),
      projectNames: {for (final p in projects) p.uuid: p.name},
      unresolvedReferenceCount: unresolved,
      hasAnyReferenceRows:
          mediaRows.isNotEmpty ||
          personnelRows.isNotEmpty ||
          associatedRows.isNotEmpty,
    );
  }

  /// Resolves one `associatedData.uri` without touching the filesystem.
  ///
  /// [FileServices.resolveAssociatedDataFile] would do this, but it awaits
  /// `nahpuDocumentDir`, which calls `create(recursive: true)`. Creating
  /// directories while building an index that feeds an empty-directory sweep
  /// races the sweep against itself, so this joins paths instead.
  String? _resolveReference(String root, String? projectUuid, String uri) {
    final value = uri.trim();
    final parsed = Uri.tryParse(value);
    if (parsed != null && parsed.scheme == 'file') {
      // The `file://` branch of `AssociatedDataServices.isFileUsed` ignores
      // the project, so this must too.
      return path.normalize(parsed.toFilePath(windows: Platform.isWindows));
    }
    if (projectUuid == null || projectUuid.trim().isEmpty) return null;

    final segments = value.replaceAll('\\', '/').split('/');
    if (segments.contains('..') ||
        path.posix.isAbsolute(value) ||
        path.windows.isAbsolute(value)) {
      throw FormatException('Invalid associated data path: $value');
    }
    final normalized = path.normalize(value.replaceAll('/', path.separator));
    if (normalized == '.' || path.split(normalized).contains('..')) {
      throw FormatException('Invalid associated data path: $value');
    }
    final resolved = path.join(
      root,
      projectUuid,
      associatedDataDir,
      normalized,
    );
    if (!path.isWithin(root, resolved)) {
      throw FormatException('Associated data path escapes the app directory.');
    }
    return path.normalize(resolved);
  }

  /// Resolves the app directory once, through any symlinks.
  ///
  /// The documents directory commonly reaches the same tree by two names
  /// (`/var` vs `/private/var` on macOS). Comparing raw absolute strings across
  /// that boundary silently fails every reference match, so every later
  /// comparison is made relative to this one canonical root.
  Future<String> canonicalRoot() async {
    final dir = await nahpuDocumentDir;
    try {
      return dir.resolveSymbolicLinksSync();
    } on FileSystemException {
      return path.normalize(dir.absolute.path);
    }
  }
}

/// Where a path sits relative to the directories NAHPU manages.
enum NahpuFileLocation {
  /// A project's `media/<category>/` or `associatedData/<origin>/`, or
  /// `appMedia/personnel/`. The only place files may be pruned.
  managed,

  /// The database, its sidecars, `backup/`, and `UserConfigs/`.
  locked,

  /// Anything else under the app directory.
  unmanaged,
}

class NahpuLocationVerdict {
  const NahpuLocationVerdict(this.location, [this.lockReason]);

  final NahpuFileLocation location;
  final NahpuLockReason? lockReason;
}

/// Classifies one path by where it sits, before any reference lookup.
///
/// Location is decided from path segments alone, never from
/// [NahpuFileFormat]: `matchNahpuFormatFromPath` runs `split('.').last` over
/// the *whole* path, so an extension-less file inside a dot-named directory
/// (the `.<uuid>.import` map staging dirs) yields nonsense like `import/data`.
/// Format is display only.
NahpuLocationVerdict classifyLocation(
  List<String> segments,
  AppFileReferenceIndex index,
) {
  if (segments.isEmpty) {
    return const NahpuLocationVerdict(NahpuFileLocation.unmanaged);
  }

  final first = segments.first;

  // `backup/` is locked wholesale. Backups are written as `.sqlite3`, `.zip`,
  // or `.tar.gz`, and the archive forms would otherwise read as ordinary files.
  if (first == nahpuBackupDir) {
    return const NahpuLocationVerdict(
      NahpuFileLocation.locked,
      NahpuLockReason.backup,
    );
  }

  // All of `UserConfigs/` is locked by path. Custom fonts have no manifest at
  // all, and a map layer's directory is populated *before* its catalog entry is
  // written — so the catalog can never be a delete authority.
  if (first == userConfigDirName) {
    return const NahpuLocationVerdict(
      NahpuFileLocation.locked,
      NahpuLockReason.userConfig,
    );
  }

  if (segments.length == 1) {
    final name = segments.first;
    if (name == 'nahpu.db' || name == 'nahpu_configs.db') {
      return const NahpuLocationVerdict(
        NahpuFileLocation.locked,
        NahpuLockReason.database,
      );
    }
    if (_isDatabaseSidecar(name)) {
      return const NahpuLocationVerdict(
        NahpuFileLocation.locked,
        NahpuLockReason.databaseSidecar,
      );
    }
    // A loose file at the app root is something the user put there, such as an
    // export saved through the directory picker. Never ours to delete.
    return const NahpuLocationVerdict(NahpuFileLocation.unmanaged);
  }

  // appMedia/personnel/<file>
  if (first == 'appMedia') {
    final isPersonnel = segments.length >= 3 && segments[1] == 'personnel';
    return NahpuLocationVerdict(
      isPersonnel ? NahpuFileLocation.managed : NahpuFileLocation.unmanaged,
    );
  }

  // <project_uuid>/... — only for a project the database still knows.
  //
  // An unrecognized folder has two indistinguishable causes: a project delete
  // whose rmdir failed, and a database restored to an older backup, which
  // leaves every newer project's media on disk with no rows. Only the first is
  // garbage, and guessing wrong destroys the only copy.
  if (!index.knownProjectUuids.contains(first)) {
    return const NahpuLocationVerdict(
      NahpuFileLocation.unmanaged,
      NahpuLockReason.unknownProject,
    );
  }

  if (segments.length >= 4 &&
      segments[1] == mediaDir &&
      _mediaCategoryDirs.contains(segments[2])) {
    return const NahpuLocationVerdict(NahpuFileLocation.managed);
  }
  if (segments.length >= 4 &&
      segments[1] == associatedDataDir &&
      _associatedDataOriginDirs.contains(segments[2])) {
    return const NahpuLocationVerdict(NahpuFileLocation.managed);
  }
  return const NahpuLocationVerdict(NahpuFileLocation.unmanaged);
}

/// True for `nahpu.db-wal`, `-shm`, `-journal` and their `.` variants.
///
/// These are not caught by an extension check: `.db-wal` is not `.db`. Deleting
/// a live write-ahead log corrupts the database.
bool _isDatabaseSidecar(String basename) {
  const stems = ['nahpu.db', 'nahpu_configs.db'];
  const suffixes = ['-wal', '-shm', '-journal'];
  for (final stem in stems) {
    for (final suffix in suffixes) {
      if (basename == '$stem$suffix' ||
          basename == '$stem.${suffix.substring(1)}') {
        return true;
      }
    }
  }
  return false;
}

/// Decides the status of a single file that has already been located.
NahpuFileNode classifyFile({
  required String absolutePath,
  required String relativePath,
  required String basename,
  required int sizeBytes,
  required DateTime modified,
  required NahpuLocationVerdict verdict,
  required AppFileReferenceIndex index,
  required DateTime now,
}) {
  final format = matchNahpuFormatFromPath(basename);

  NahpuFileNode node(NahpuFileStatus status, [NahpuLockReason? reason]) {
    return NahpuFileNode(
      path: absolutePath,
      name: basename,
      sizeBytes: sizeBytes,
      format: format,
      status: status,
      lockReason: reason,
    );
  }

  if (verdict.location == NahpuFileLocation.locked) {
    return node(NahpuFileStatus.locked, verdict.lockReason);
  }

  // Reference checks run everywhere, so an unmanaged file still shows *why* it
  // is kept when a record happens to point at it.
  if (index.isLinkedPath(relativePath)) {
    return node(NahpuFileStatus.linked, NahpuLockReason.associatedData);
  }
  if (index.isLinkedBasename(basename)) {
    return node(NahpuFileStatus.linked, NahpuLockReason.mediaRecord);
  }

  if (verdict.location == NahpuFileLocation.unmanaged) {
    return node(
      NahpuFileStatus.unmanaged,
      verdict.lockReason ?? NahpuLockReason.unmanagedLocation,
    );
  }

  if (now.difference(modified) < pruneSafetyWindow) {
    return node(NahpuFileStatus.locked, NahpuLockReason.recentlyModified);
  }

  return node(NahpuFileStatus.dangling);
}

/// Walks the application directory and builds the classified tree.
class AppFileTreeScanner {
  const AppFileTreeScanner({required this.index, required this.root});

  final AppFileReferenceIndex index;

  /// Canonical app directory path, already resolved through symlinks.
  final String root;

  Future<AppFileTree> scan() async {
    final now = DateTime.now();
    final rootNode = await _scanDirectory(root, <String>[], now);

    final prunable = <String>[];
    _collectPrunable(rootNode, prunable);

    return AppFileTree(
      root: rootNode,
      totalBytes: rootNode.sizeBytes,
      fileCount: rootNode.fileCount,
      mediaCount: _countMedia(rootNode),
      danglingCount: rootNode.danglingCount,
      danglingBytes: rootNode.danglingBytes,
      prunablePaths: prunable,
      pruneBlockedReason: _pruneBlockedReason(rootNode),
    );
  }

  /// Refuses to offer pruning when the index cannot be trusted.
  String? _pruneBlockedReason(NahpuDirectoryNode rootNode) {
    if (index.unresolvedReferenceCount > 0) {
      final n = index.unresolvedReferenceCount;
      return '$n associated data ${n == 1 ? 'record' : 'records'} could not be '
          'read, so some files cannot be checked. Removing files is disabled '
          'until that is resolved.';
    }
    // An index with no references at all is indistinguishable from a failed or
    // mid-migration read. If there are managed files on disk but nothing in the
    // database claims any of them, assume the read is wrong, not the disk.
    if (!index.hasAnyReferenceRows && rootNode.danglingCount > 0) {
      return 'The database reports no linked files at all, which usually means '
          'it is still opening. Reopen this screen before removing anything.';
    }
    return null;
  }

  Future<NahpuDirectoryNode> _scanDirectory(
    String absolutePath,
    List<String> segments,
    DateTime now,
  ) async {
    final children = <NahpuTreeNode>[];

    List<FileSystemEntity> entries;
    try {
      // followLinks is false throughout. A symlink under the app directory
      // would otherwise let the walk — and then the delete — escape the tree
      // entirely, and a link loop would hang the scan.
      entries = Directory(
        absolutePath,
      ).listSync(recursive: false, followLinks: false);
    } on FileSystemException {
      entries = const [];
    }
    entries.sort(
      (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()),
    );

    for (final entity in entries) {
      final name = path.basename(entity.path);
      final type = FileSystemEntity.typeSync(entity.path, followLinks: false);

      if (type == FileSystemEntityType.directory) {
        if (segments.isEmpty && excludedRootDirs.contains(name)) continue;
        children.add(
          await _scanDirectory(entity.path, [...segments, name], now),
        );
        continue;
      }
      // Symlinks and anything else exotic are shown as unmanaged, never
      // followed and never deleted.
      if (type != FileSystemEntityType.file) continue;
      if (_isNoiseFile(name)) continue;

      FileStat stat;
      try {
        stat = entity.statSync();
      } on FileSystemException {
        continue;
      }

      // Each file is classified by its own path, not by the folder it sits
      // in: `nahpu.db` at the app root is a different case from the root
      // directory itself.
      final fileSegments = [...segments, name];
      children.add(
        classifyFile(
          absolutePath: entity.path,
          relativePath: path.joinAll(fileSegments),
          basename: name,
          sizeBytes: stat.size,
          modified: stat.modified,
          verdict: classifyLocation(fileSegments, index),
          index: index,
          now: now,
        ),
      );
      // Yield between files so a large library does not stall a frame.
      if (children.length % 128 == 0) await Future<void>.delayed(Duration.zero);
    }

    return _foldDirectory(absolutePath, segments, children);
  }

  NahpuDirectoryNode _foldDirectory(
    String absolutePath,
    List<String> segments,
    List<NahpuTreeNode> children,
  ) {
    var size = 0;
    var files = 0;
    var dangling = 0;
    var reclaimable = 0;
    var unmanaged = 0;

    for (final child in children) {
      size += child.sizeBytes;
      switch (child) {
        case NahpuFileNode():
          files += 1;
          if (child.status == NahpuFileStatus.dangling) {
            dangling += 1;
            reclaimable += child.sizeBytes;
          } else if (child.status == NahpuFileStatus.unmanaged) {
            unmanaged += 1;
          }
        case NahpuDirectoryNode():
          files += child.fileCount;
          dangling += child.danglingCount;
          reclaimable += child.danglingBytes;
          unmanaged += child.unmanagedCount;
      }
    }

    final isProjectDir =
        segments.length == 1 &&
        index.knownProjectUuids.contains(segments.first);
    final projectName = isProjectDir
        ? (index.projectNames[segments.first] ?? segments.first)
        : null;

    return NahpuDirectoryNode(
      path: absolutePath,
      // A project folder is named for its project, with its file count on the
      // same line: the UUID alone tells the user nothing.
      name: projectName != null
          ? '$projectName · $files ${files == 1 ? 'file' : 'files'}'
          : (segments.isEmpty ? nahpuAppDir : segments.last),
      subtitle: isProjectDir ? segments.first : null,
      sizeBytes: size,
      children: children,
      fileCount: files,
      danglingCount: dangling,
      danglingBytes: reclaimable,
      unmanagedCount: unmanaged,
      isEntirelyDangling: files > 0 && dangling == files,
    );
  }

  void _collectPrunable(NahpuTreeNode node, List<String> out) {
    switch (node) {
      case NahpuFileNode(:final status, :final path):
        if (status == NahpuFileStatus.dangling) out.add(path);
      case NahpuDirectoryNode(:final children):
        for (final child in children) {
          _collectPrunable(child, out);
        }
    }
  }

  int _countMedia(NahpuTreeNode node) {
    switch (node) {
      case NahpuFileNode(:final format):
        return isSupportedMediaFormat(format) ? 1 : 0;
      case NahpuDirectoryNode(:final children):
        var total = 0;
        for (final child in children) {
          total += _countMedia(child);
        }
        return total;
    }
  }
}

/// Deletes the files a scan identified, re-checking each one first.
///
/// Prune never re-derives its own list. It deletes only paths the user was
/// shown, and re-verifies each immediately before unlinking, because a media
/// import writes the file to disk before inserting its row and could have
/// landed in between.
class AppFilePruner {
  const AppFilePruner({
    required this.index,
    required this.root,
    required this.structuralDirs,
  });

  final AppFileReferenceIndex index;
  final String root;

  /// Directories that stay even when empty, because NAHPU re-creates them.
  final Set<String> structuralDirs;

  Future<PruneResult> prune(List<String> paths) async {
    var deleted = 0;
    var freed = 0;
    final failed = <String>[];
    final touchedDirs = <String>{};
    final now = DateTime.now();

    for (final target in paths) {
      try {
        if (!_isStillSafeToDelete(target, now)) {
          failed.add(target);
          continue;
        }
        final file = File(target);
        final size = file.statSync().size;
        file.deleteSync();
        deleted += 1;
        freed += size;
        touchedDirs.add(path.dirname(target));
      } on FileSystemException catch (error) {
        if (kDebugMode) debugPrint('Could not delete $target: $error');
        failed.add(target);
      }
    }

    _sweepEmptyDirectories(touchedDirs);

    return PruneResult(
      deletedCount: deleted,
      freedBytes: freed,
      failedPaths: failed,
    );
  }

  /// Deletes files the user picked out by hand.
  ///
  /// Uses the wider [NahpuFileNode.isManuallyDeletable] rule rather than the
  /// prune rule: an old backup or a stray export is the user's to remove, even
  /// though bulk pruning would never touch it. The live database, its sidecars,
  /// and anything a record still points at are still refused.
  Future<PruneResult> deleteSelected(List<String> paths) async {
    var deleted = 0;
    var freed = 0;
    final failed = <String>[];
    final touchedDirs = <String>{};
    final now = DateTime.now();

    for (final target in paths) {
      try {
        if (!_isManuallyDeletable(target, now)) {
          failed.add(target);
          continue;
        }
        final file = File(target);
        final size = file.statSync().size;
        file.deleteSync();
        deleted += 1;
        freed += size;
        touchedDirs.add(path.dirname(target));
      } on FileSystemException catch (error) {
        if (kDebugMode) debugPrint('Could not delete $target: $error');
        failed.add(target);
      }
    }

    _sweepEmptyDirectories(touchedDirs);

    return PruneResult(
      deletedCount: deleted,
      freedBytes: freed,
      failedPaths: failed,
    );
  }

  /// Maps [target] onto the canonical root, or null if it is not inside it.
  ///
  /// Callers may hold a path spelled through an unresolved symlink (`/var`
  /// rather than `/private/var`), which a raw containment check would reject.
  String? _within(String target) {
    if (FileSystemEntity.typeSync(target, followLinks: false) !=
        FileSystemEntityType.file) {
      return null;
    }
    final key = referenceKeyFor(root, target);
    return key == null ? null : path.join(root, key);
  }

  /// Re-classifies [target] from scratch and asks whether it may be removed.
  bool _isManuallyDeletable(String target, DateTime now) {
    final resolved = _within(target);
    if (resolved == null) return false;
    target = resolved;

    final relative = path.relative(target, from: root);
    final segments = path.split(relative);
    final basename = path.basename(target);

    FileStat stat;
    try {
      stat = File(target).statSync();
    } on FileSystemException {
      return false;
    }

    final node = classifyFile(
      absolutePath: target,
      relativePath: relative,
      basename: basename,
      sizeBytes: stat.size,
      modified: stat.modified,
      verdict: classifyLocation(segments, index),
      index: index,
      now: now,
    );
    return node.isManuallyDeletable;
  }

  /// Re-runs every safety check against the live filesystem and index.
  bool _isStillSafeToDelete(String target, DateTime now) {
    // Must still be a real file, not a directory or a symlink someone swapped
    // in, and must still be inside the app directory.
    final resolved = _within(target);
    if (resolved == null) return false;
    target = resolved;

    final relative = path.relative(target, from: root);
    final segments = path.split(relative);
    if (classifyLocation(segments, index).location !=
        NahpuFileLocation.managed) {
      return false;
    }

    if (index.isLinkedPath(relative) ||
        index.isLinkedBasename(path.basename(target))) {
      return false;
    }

    try {
      final stat = File(target).statSync();
      // A file written since the scan may be an import still in flight.
      if (now.difference(stat.modified) < pruneSafetyWindow) return false;
    } on FileSystemException {
      return false;
    }
    return true;
  }

  /// Removes directories the prune emptied, deepest first.
  ///
  /// Structural directories stay: several are re-created on demand by the
  /// getters in `io_services.dart`, so deleting them only churns.
  void _sweepEmptyDirectories(Set<String> touched) {
    final ordered = touched.toList()
      ..sort((a, b) => path.split(b).length.compareTo(path.split(a).length));

    for (final dir in ordered) {
      var current = dir;
      while (path.isWithin(root, current)) {
        if (structuralDirs.contains(current)) break;
        final directory = Directory(current);
        try {
          if (!directory.existsSync()) break;
          if (directory.listSync(followLinks: false).isNotEmpty) break;
          directory.deleteSync();
        } on FileSystemException {
          break;
        }
        current = path.dirname(current);
      }
    }
  }
}

/// The directories NAHPU re-creates, which must survive an empty sweep.
Set<String> buildStructuralDirs(String root, Set<String> projectUuids) {
  final dirs = <String>{
    root,
    path.join(root, nahpuBackupDir),
    path.join(root, 'appMedia'),
    path.join(root, 'appMedia', 'personnel'),
    path.join(root, userConfigDirName),
    path.join(root, userConfigDirName, userFontDirName),
    path.join(root, userConfigDirName, userMapDirName),
  };
  for (final uuid in projectUuids) {
    dirs.add(path.join(root, uuid));
    dirs.add(path.join(root, uuid, mediaDir));
    dirs.add(path.join(root, uuid, associatedDataDir));
    for (final category in _mediaCategoryDirs) {
      dirs.add(path.join(root, uuid, mediaDir, category));
    }
    for (final origin in _associatedDataOriginDirs) {
      dirs.add(path.join(root, uuid, associatedDataDir, origin));
    }
  }
  return dirs;
}

class DataUsageServices extends AppServices {
  const DataUsageServices({required super.ref});

  Future<String> get appDataUsage async {
    final tree = await _scan();
    return formatByteSize(tree.totalBytes);
  }

  Future<int> get fileCount async => (await _scan()).fileCount;

  Future<int> get mediaCount async => (await _scan()).mediaCount;

  /// Every file under the app directory, flagged with whether it may be
  /// removed.
  ///
  /// Delegates to the file explorer's classifier so this and the explorer
  /// screen can never disagree about which files are safe to delete.
  Future<List<NahpuFile>> get fileList async {
    final tree = await _scan();
    final files = <NahpuFile>[];
    _collectFiles(tree.root, files);
    return files;
  }

  Future<AppFileTree> _scan() async {
    final services = FileExplorerServices(db: dbAccess);
    final index = await services.buildIndex();
    final root = await services.canonicalRoot();
    return AppFileTreeScanner(index: index, root: root).scan();
  }

  void _collectFiles(NahpuTreeNode node, List<NahpuFile> out) {
    switch (node) {
      case NahpuFileNode():
        out.add(
          NahpuFile(
            path: File(node.path),
            isDeletable: node.isDangling,
            format: node.format,
          ),
        );
      case NahpuDirectoryNode():
        for (final child in node.children) {
          _collectFiles(child, out);
        }
    }
  }
}

class NahpuFile {
  const NahpuFile({
    required this.path,
    required this.isDeletable,
    required this.format,
  });
  final File path;
  final bool isDeletable;
  final NahpuFileFormat format;
}
