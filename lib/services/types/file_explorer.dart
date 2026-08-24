/// Model for the application-directory file explorer.
///
/// The explorer answers one question for every file under the NAHPU
/// application directory: is this file still owned by something, or is it a
/// leftover? Files that are owned stay locked, and only the leftovers can be
/// removed. Nodes carry plain [String] paths rather than `File` handles so the
/// tree stays cheap to compare and safe to hand to another isolate if the walk
/// ever needs to move off the main thread.
library;

import 'package:nahpu/services/types/file_format.dart';

/// Whether a file may be removed by the explorer.
///
/// The rule is an allowlist, not a denylist. A file becomes [dangling] only
/// when it sits in a directory whose role NAHPU defines *and* nothing in the
/// database points at it. Everything else is [unmanaged] and is left alone,
/// because "we found no reference" and "we understand this location" are
/// different claims, and only the second one makes deletion safe.
enum NahpuFileStatus {
  /// Owned by the application: the database, its sidecars and backups, and
  /// user configuration.
  locked,

  /// Referenced by a record in the database.
  linked,

  /// Inside the app folder but outside any directory NAHPU manages — a file
  /// saved into the app folder by hand, an in-flight import, a project folder
  /// with no matching row. Displayed and sized, never removed.
  unmanaged,

  /// In a managed directory with nothing pointing at it. The only removable
  /// state.
  dangling,
}

/// Why a file cannot be removed.
///
/// Each value names the owner the user would recognize, not the rule that
/// matched, because the value is surfaced verbatim in the row tooltip.
enum NahpuLockReason {
  database,
  databaseSidecar,
  backup,
  userConfig,
  mediaRecord,
  personnelPhoto,
  associatedData,

  /// A reference row that could not be resolved to a path. The file is locked
  /// defensively: an unreadable reference is a reason to keep a file, never a
  /// reason to delete it.
  unresolvedReference,

  /// Recently modified, so it may be a copy still in flight. See
  /// [pruneSafetyWindow].
  recentlyModified,

  /// Outside every managed directory.
  unmanagedLocation,

  /// A project folder with no matching project row. Cannot be distinguished
  /// from a database restored to an older backup, so it is never bulk-pruned.
  unknownProject,
}

extension NahpuLockReasonLabel on NahpuLockReason {
  /// Short phrase for the lock tooltip, phrased as what owns the file.
  String get label => switch (this) {
    NahpuLockReason.database => 'Application database',
    NahpuLockReason.databaseSidecar => 'Database working file',
    NahpuLockReason.backup => 'Database backup',
    NahpuLockReason.userConfig => 'Custom fonts and map layers',
    NahpuLockReason.mediaRecord => 'Linked to a media record',
    NahpuLockReason.personnelPhoto => 'Linked to a personnel photo',
    NahpuLockReason.associatedData => 'Linked to associated data',
    NahpuLockReason.unresolvedReference =>
      'A record points here but could not be read',
    NahpuLockReason.recentlyModified =>
      'Changed just now, may still be copying',
    NahpuLockReason.unmanagedLocation => 'Not in a folder NAHPU manages',
    NahpuLockReason.unknownProject => 'Folder of a project not in the database',
  };
}

/// A node in the application-directory tree.
sealed class NahpuTreeNode {
  const NahpuTreeNode({
    required this.path,
    required this.name,
    required this.sizeBytes,
  });

  /// Absolute path on disk.
  final String path;

  /// Base name, or a friendly label for project directories.
  final String name;

  /// Size of this file, or the rolled-up size of this subtree.
  final int sizeBytes;
}

/// A directory, with its children and subtree rollups already computed.
class NahpuDirectoryNode extends NahpuTreeNode {
  const NahpuDirectoryNode({
    required super.path,
    required super.name,
    required super.sizeBytes,
    required this.children,
    required this.fileCount,
    required this.danglingCount,
    required this.danglingBytes,
    required this.unmanagedCount,
    required this.deletableCount,
    required this.deletableBytes,
    required this.isEntirelyDangling,
    required this.isStructural,
    this.subtitle,
  });

  final List<NahpuTreeNode> children;

  /// Files in this subtree, at any depth.
  final int fileCount;
  final int danglingCount;
  final int danglingBytes;
  final int unmanagedCount;

  /// Files in this subtree the user may remove by hand.
  ///
  /// Drives whether the row offers a checkbox at all: a folder holding only the
  /// database and linked media has nothing to select, and showing a box the
  /// user cannot act on would be a lie.
  final int deletableCount;
  final int deletableBytes;

  /// True when every file below is dangling and the directory is not
  /// structural, so the whole subtree can be offered as one action instead of
  /// making the user remove an abandoned project folder file by file.
  final bool isEntirelyDangling;

  /// Secondary line: the file count, and the project name for a project folder.
  final String? subtitle;

  /// True for a folder NAHPU creates and re-creates on demand.
  ///
  /// Removing one of these accomplishes nothing — the next export or import
  /// puts it straight back — so they are never offered for deletion even when
  /// they are empty.
  final bool isStructural;

  bool get isEmpty => children.isEmpty;

  /// Whether the row offers a selection checkbox.
  bool get isSelectable => deletableCount > 0;

  /// Whether the user may remove this folder outright.
  ///
  /// Only empty folders qualify. A folder with contents is cleared by removing
  /// its files, which keeps one rule — nothing disappears that the user has not
  /// seen listed.
  bool get isRemovableWhenEmpty => isEmpty && !isStructural;
}

/// A file, already classified.
class NahpuFileNode extends NahpuTreeNode {
  const NahpuFileNode({
    required super.path,
    required super.name,
    required super.sizeBytes,
    required this.format,
    required this.status,
    this.lockReason,
  });

  final NahpuFileFormat format;
  final NahpuFileStatus status;

  /// Set whenever [status] is not [NahpuFileStatus.dangling].
  final NahpuLockReason? lockReason;

  bool get isDangling => status == NahpuFileStatus.dangling;

  /// Whether the user may delete this file by hand.
  ///
  /// Wider than [isDangling]: bulk pruning is conservative because it acts on
  /// files the user never looked at, but a file the user picked out themselves
  /// — an old backup, an export they saved here — is their call. Only files the
  /// app is actively using, and files a record may still point at, are refused.
  bool get isManuallyDeletable {
    if (status == NahpuFileStatus.linked) return false;
    return switch (lockReason) {
      NahpuLockReason.database ||
      NahpuLockReason.databaseSidecar ||
      NahpuLockReason.mediaRecord ||
      NahpuLockReason.personnelPhoto ||
      NahpuLockReason.associatedData ||
      NahpuLockReason.unresolvedReference => false,
      _ => true,
    };
  }
}

/// One scan of the application directory.
class AppFileTree {
  const AppFileTree({
    required this.root,
    required this.totalBytes,
    required this.fileCount,
    required this.mediaCount,
    required this.danglingCount,
    required this.danglingBytes,
    required this.prunablePaths,
    this.pruneBlockedReason,
  });

  final NahpuDirectoryNode root;
  final int totalBytes;
  final int fileCount;
  final int mediaCount;
  final int danglingCount;
  final int danglingBytes;

  /// The exact paths Prune will delete, captured at scan time.
  ///
  /// Prune operates on this list rather than re-deriving "everything dangling"
  /// later, so the user can only ever delete what the screen showed them.
  final List<String> prunablePaths;

  /// Set when the scan succeeded but pruning must not be offered — an
  /// unreadable reference row, or an index too empty to trust. Prune is
  /// disabled and this explains why.
  final String? pruneBlockedReason;

  bool get hasDangling => danglingCount > 0;

  bool get canPrune => pruneBlockedReason == null && danglingCount > 0;
}

/// Outcome of a prune, reported back to the user.
///
/// Failures are collected rather than thrown so one undeletable file does not
/// strand the rest of the sweep.
class PruneResult {
  const PruneResult({
    required this.deletedCount,
    required this.freedBytes,
    required this.failedPaths,
  });

  final int deletedCount;
  final int freedBytes;
  final List<String> failedPaths;

  bool get hasFailures => failedPaths.isNotEmpty;
}
