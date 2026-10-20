//! This file contains the services to create and restore full NAHPU backups.
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter/foundation.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/db_services.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/export/export_task.dart';
import 'package:nahpu/services/media/media_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/src/rust/api/archive.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite3;

const String nahpuBackupDatabaseName = 'nahpu.sqlite3';
const String _restoreStagingDirName = 'db-restore';

class DbArchiveDatabaseCandidate {
  const DbArchiveDatabaseCandidate({
    required this.archivePath,
    required this.displayName,
  });

  final String archivePath;
  final String displayName;
}

class DbArchiveInspection {
  const DbArchiveInspection({
    required this.databaseCandidates,
    this.previews = const {},
  });

  final List<DbArchiveDatabaseCandidate> databaseCandidates;

  /// What each root database holds, keyed by
  /// [DbArchiveDatabaseCandidate.archivePath].
  final Map<String, DbReplacementPreview> previews;
}

/// The rows a database summary reports, as label to table name.
///
/// Shared by the backup window and the replacement preview, so the current
/// database and a replacement file are always counted the same way. None of
/// these tables has been renamed by a schema migration.
const Map<String, String> dbSummaryTables = {
  'Projects': 'project',
  'Personnel': 'personnel',
  'Taxa': 'taxonomy',
  'Sites': 'site',
  'Collection events': 'collEvent',
  'Specimens': 'specimen',
  'Narratives': 'narrative',
  'Media records': 'media',
};

/// What a database file chosen to replace the current one holds.
class DbContentsSummary {
  const DbContentsSummary({
    required this.entries,
    required this.associatedFiles,
    required this.totalBytes,
    required this.schemaVersion,
  });

  /// Row counts by [dbSummaryTables] label. Null when the table is missing.
  final Map<String, int?> entries;

  /// Media and associated files the restore copies. Null for a bare database
  /// file, which carries none.
  final int? associatedFiles;

  /// Size of the database plus any associated files.
  final int totalBytes;

  /// SQLite `user_version`, which Drift uses as the schema version.
  final int schemaVersion;

  DbContentsSummary withAssociatedFiles(int count, int bytes) {
    return DbContentsSummary(
      entries: entries,
      associatedFiles: count,
      totalBytes: totalBytes + bytes,
      schemaVersion: schemaVersion,
    );
  }
}

/// Why a replacement file cannot be restored.
enum DbReplacementIssue {
  notNahpuDatabase(
    'This file is not a NAHPU database. Choose a NAHPU backup archive or '
    'database file.',
  ),
  newerSchema(
    'This database was made by a newer version of NAHPU. Update NAHPU, then '
    'restore it.',
  ),
  unreadable('This database could not be read. The file may be damaged.');

  const DbReplacementIssue(this.message);

  final String message;
}

/// A replacement file, read before anything is overwritten.
class DbReplacementPreview {
  const DbReplacementPreview({
    required this.contents,
    required this.issue,
    this.includesSettings = false,
  });

  /// Null when the database could not be read.
  final DbContentsSummary? contents;

  /// Why the file cannot be restored, or null when it can.
  final DbReplacementIssue? issue;

  /// Whether the restore also imports the archive's user configs.
  final bool includesSettings;

  /// Reads the database at [databasePath] and decides whether it can replace
  /// the current one. A file that cannot be read is reported, not thrown.
  static Future<DbReplacementPreview> read(
    String databasePath, {
    int? associatedFiles,
    int associatedBytes = 0,
    bool includesSettings = false,
  }) async {
    try {
      var contents = await readDatabaseContents(databasePath);
      if (associatedFiles != null) {
        contents = contents.withAssociatedFiles(
          associatedFiles,
          associatedBytes,
        );
      }
      return DbReplacementPreview(
        contents: contents,
        issue: replacementIssueFor(contents),
        includesSettings: includesSettings,
      );
    } catch (_) {
      return DbReplacementPreview(
        contents: null,
        issue: DbReplacementIssue.unreadable,
        includesSettings: includesSettings,
      );
    }
  }
}

/// Counts what the database at [path] holds without changing it.
///
/// Runs on a background isolate, so a large file never blocks a frame.
@visibleForTesting
Future<DbContentsSummary> readDatabaseContents(String path) async {
  final bytes = await File(path).length();
  return Isolate.run(() {
    final database = sqlite3.sqlite3.open(
      path,
      mode: sqlite3.OpenMode.readOnly,
    );
    try {
      final tables = {
        for (final row in database.select(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        ))
          row['name'] as String,
      };
      return DbContentsSummary(
        entries: {
          for (final MapEntry(key: label, value: table)
              in dbSummaryTables.entries)
            label: tables.contains(table)
                ? database
                          .select('SELECT COUNT(*) AS count FROM "$table"')
                          .first['count']
                      as int
                : null,
        },
        associatedFiles: null,
        totalBytes: bytes,
        schemaVersion: database.userVersion,
      );
    } finally {
      database.close();
    }
  });
}

/// Whether [contents] can replace the current database.
///
/// Older schemas are accepted, because the migrations upgrade them when the
/// replaced database opens. A newer schema cannot be read by this app version.
@visibleForTesting
DbReplacementIssue? replacementIssueFor(DbContentsSummary contents) {
  if (contents.entries['Projects'] == null ||
      contents.entries['Specimens'] == null) {
    return DbReplacementIssue.notNahpuDatabase;
  }
  if (contents.schemaVersion > kSchemaVersion) {
    return DbReplacementIssue.newerSchema;
  }
  return null;
}

class DbBackupSummary {
  const DbBackupSummary({
    required this.entries,
    required this.associatedFileBytes,
    required this.databaseBytes,
    required this.schemaVersion,
  });

  final Map<String, int> entries;

  /// Combined size of the media and associated files the backup will copy.
  final int associatedFileBytes;

  /// Size of the live database, used to estimate the work the backup starts with.
  final int databaseBytes;

  /// The live database's schema version, from SQLite `user_version`.
  final int schemaVersion;

  int get totalBytes => associatedFileBytes + databaseBytes;
}

List<DbArchiveDatabaseCandidate> databaseCandidatesFromRelativePaths(
  Iterable<String> paths,
) {
  final candidates = paths
      .map((value) => value.replaceAll('\\', '/'))
      .where((value) => !value.contains('/'))
      .where((value) {
        final lower = value.toLowerCase();
        return lower.endsWith('.sqlite3') || lower.endsWith('.db');
      })
      .map(
        (value) => DbArchiveDatabaseCandidate(
          archivePath: value,
          displayName: p.basename(value),
        ),
      )
      .toList();
  candidates.sort(
    (left, right) => left.displayName.compareTo(right.displayName),
  );
  return candidates;
}

bool isAssociatedBackupArchivePath(String relative) {
  final normalized = relative.replaceAll('\\', '/');
  final lower = normalized.toLowerCase();
  if (lower == 'user_configs.json' || lower == 'settings.json') return false;
  if (lower.endsWith('.sqlite3') || lower.endsWith('.db')) return false;
  final segments = lower.split('/');
  return lower.startsWith('appmedia/') ||
      lower.startsWith('userconfigs/') ||
      (segments.length >= 3 &&
          (segments[1] == 'media' || segments[1] == 'associateddata'));
}

/// Where an archive file is written on restore, relative to the NAHPU folder.
///
/// Older backups kept personnel photos in the project media folder, as
/// `<project>/media/personnel/<file>`. `personnel.photoPath` holds only the
/// file name, which the app resolves under `appMedia/personnel`, so those
/// photos are restored there. Every other path is restored where it was.
@visibleForTesting
String restoredRelativePath(String archivePath) {
  final normalized = archivePath.replaceAll('\\', '/');
  final segments = normalized.split('/');
  final isLegacyPersonnelPhoto =
      segments.length >= 4 &&
      segments[1].toLowerCase() == mediaDir &&
      segments[2].toLowerCase() == 'personnel';
  if (!isLegacyPersonnelPhoto) return normalized;
  return [appMediaDirName, 'personnel', ...segments.sublist(3)].join('/');
}

/// The installation-wide directories a full backup copies in their entirety.
///
/// These are walked rather than read from the database so that files the
/// database no longer points at - an unlinked personnel photo, a font or map
/// dropped in by hand - still survive a restore.
@visibleForTesting
List<String> globalBackupDirectoryPaths(String root) {
  return [p.join(root, userConfigDirName), p.join(root, appMediaDirName)];
}

/// The per-project directories a full backup copies in their entirety.
@visibleForTesting
List<String> projectBackupDirectoryPaths(
  String root,
  Iterable<String> projectUuids,
) {
  return [
    for (final uuid in projectUuids) ...[
      p.join(root, uuid, mediaDir),
      p.join(root, uuid, associatedDataDir),
    ],
  ];
}

/// Reports whether [target] already holds exactly the bytes in [source].
///
/// A restore writes to the archive's own relative paths, so an unchanged file
/// would be rewritten byte for byte on every run. Comparing first skips that
/// write without ever renaming a file out of the way.
@visibleForTesting
Future<bool> hasIdenticalFileContent(File source, File target) async {
  if (!await target.exists()) return false;
  if (await source.length() != await target.length()) return false;

  final sourceChunks = StreamIterator(source.openRead());
  final targetChunks = StreamIterator(target.openRead());
  final sourceBuffer = BytesBuilder(copy: false);
  final targetBuffer = BytesBuilder(copy: false);
  try {
    while (true) {
      // The two streams chunk independently, so the buffers hold whatever has
      // been read but not yet compared, and only the overlap is checked here.
      while (sourceBuffer.isEmpty && await sourceChunks.moveNext()) {
        sourceBuffer.add(sourceChunks.current);
      }
      while (targetBuffer.isEmpty && await targetChunks.moveNext()) {
        targetBuffer.add(targetChunks.current);
      }
      if (sourceBuffer.isEmpty || targetBuffer.isEmpty) {
        return sourceBuffer.isEmpty && targetBuffer.isEmpty;
      }
      final sourceBytes = sourceBuffer.takeBytes();
      final targetBytes = targetBuffer.takeBytes();
      final shared = sourceBytes.length < targetBytes.length
          ? sourceBytes.length
          : targetBytes.length;
      for (var index = 0; index < shared; index++) {
        if (sourceBytes[index] != targetBytes[index]) return false;
      }
      sourceBuffer.add(Uint8List.sublistView(sourceBytes, shared));
      targetBuffer.add(Uint8List.sublistView(targetBytes, shared));
    }
  } finally {
    await sourceChunks.cancel();
    await targetChunks.cancel();
  }
}

/// Creates a complete NAHPU backup archive.
class DbExport extends AppServices {
  const DbExport({required super.ref, required this.filePath});

  final File filePath;

  /// Describes the stages of a backup, weighted by the bytes each one moves.
  ///
  /// Equal weights would leave the bar crawling through whichever stage happens
  /// to hold the media library, so the sizes from [getSummary] set the shares.
  static List<ExportPhaseStep> backupPhases(DbBackupSummary summary) {
    final database = summary.databaseBytes.toDouble();
    final associated = summary.associatedFileBytes.toDouble();
    final hasSizes = database > 0 || associated > 0;
    return [
      ExportPhaseStep(
        phase: ExportPhase.preparing,
        label: 'Prepare backup',
        weight: hasSizes ? database : 1,
      ),
      ExportPhaseStep(
        phase: ExportPhase.copyingFiles,
        label: 'Copy media and files',
        weight: hasSizes ? associated : 1,
      ),
      ExportPhaseStep(
        phase: ExportPhase.compressing,
        label: 'Compress archive',
        weight: hasSizes ? database + associated : 1,
      ),
    ];
  }

  Future<DbBackupSummary> getSummary() async {
    final counts = <String, int>{
      for (final MapEntry(key: label, value: table) in dbSummaryTables.entries)
        label: await _countRows(table),
    };
    final associatedFiles = await _collectAssociatedFiles();
    counts['Associated files'] = associatedFiles.length;
    return DbBackupSummary(
      entries: counts,
      associatedFileBytes: await _totalBytes(associatedFiles),
      databaseBytes: await _databaseBytes(),
      schemaVersion: await _schemaVersion(),
    );
  }

  /// Writes the backup archive, reporting to [progress] as each stage runs.
  ///
  /// A cancelled or failed run leaves nothing behind: the staging directory and
  /// any half-written archive are removed before the error reaches the caller.
  Future<File> write(
    DbArchiveFormat format, {
    ExportProgressReporter? progress,
    ExportCancellation? cancel,
  }) async {
    final tempRoot = await tempDirectory;
    final staging = Directory(
      p.join(
        tempRoot.path,
        'db-backup-${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    await staging.create(recursive: true);

    try {
      // Exporting the database and settings happens inside calls that report
      // nothing, so this stage runs an indeterminate bar rather than a
      // determinate one frozen at zero.
      progress?.beginPhase(ExportPhase.preparing, indeterminate: true);
      cancel?.throwIfCancelled();
      final databaseFile = File(p.join(staging.path, nahpuBackupDatabaseName));
      progress?.setCurrentItem(nahpuBackupDatabaseName);
      await dbAccess.exportInto(databaseFile);

      final settingsFile = File(p.join(staging.path, 'user_configs.json'));
      progress?.setCurrentItem(p.basename(settingsFile.path));
      await rust_config.exportConfigToFile(
        filePath: settingsFile.path,
        sections: rust_config.UserConfigSection.values,
        customFieldTemplates: const [],
      );

      cancel?.throwIfCancelled();
      await _copyAssociatedFiles(staging, progress: progress, cancel: cancel);

      cancel?.throwIfCancelled();
      final archiveFiles = await _stagedFilePaths(staging);
      await _writeArchive(
        format,
        staging.path,
        archiveFiles,
        progress: progress,
        cancel: cancel,
      );
      cancel?.throwIfCancelled();
      progress?.complete();
      return filePath;
    } catch (_) {
      await _deleteIncompleteOutput();
      rethrow;
    } finally {
      if (staging.existsSync()) {
        await staging.delete(recursive: true);
      }
    }
  }

  Future<int> _countRows(String tableName) async {
    final row = await dbAccess
        .customSelect('SELECT COUNT(*) AS count FROM $tableName')
        .getSingle();
    return row.read<int>('count');
  }

  Future<int> _schemaVersion() async {
    final row = await dbAccess.customSelect('PRAGMA user_version').getSingle();
    return row.read<int>('user_version');
  }

  /// Gathers every file the backup archive carries alongside the database.
  ///
  /// The managed directories are walked first so the archive is a copy of what
  /// is on disk rather than only what the database points at. The row-driven
  /// lists are folded in afterwards, keyed by path, to catch legacy records
  /// pointing outside those directories without staging anything twice.
  Future<List<File>> _collectAssociatedFiles() async {
    final root = await nahpuDocumentDir;
    final projects = await ProjectQuery(dbAccess).getAllProjects();
    final directoryPaths = [
      ...globalBackupDirectoryPaths(root.path),
      ...projectBackupDirectoryPaths(
        root.path,
        projects.map((project) => project.uuid),
      ),
    ];

    final byPath = <String, File>{};
    for (final directoryPath in directoryPaths) {
      for (final file in await _collectDirectoryFiles(
        Directory(directoryPath),
      )) {
        byPath[p.normalize(file.path)] = file;
      }
    }
    final recorded = [
      ...await MediaFinder(ref: ref).getAllMedia(),
      ...await _collectAssociatedDataFiles(),
    ];
    for (final file in recorded) {
      byPath.putIfAbsent(p.normalize(file.path), () => file);
    }
    return byPath.values.where((file) => file.existsSync()).toList();
  }

  Future<List<File>> _collectAssociatedDataFiles() async {
    final rows = await dbAccess
        .customSelect(
          "SELECT projectUuid, uri FROM associatedData WHERE type = 'File'",
        )
        .get();
    Future<File?> associatedDataFile(QueryRow row) async {
      final projectUuid = row.data['projectUuid'] as String?;
      final storageKey = row.data['uri'] as String?;
      if (projectUuid == null ||
          storageKey == null ||
          storageKey.isEmpty ||
          Uri.tryParse(storageKey)?.scheme == 'file') {
        return null;
      }
      try {
        return await FileServices(
          ref: ref,
        ).resolveAssociatedDataFile(projectUuid, storageKey);
      } on FormatException {
        return null;
      }
    }

    final files = await Future.wait(rows.map(associatedDataFile));
    return files.whereType<File>().where((file) => file.existsSync()).toList();
  }

  Future<void> _copyAssociatedFiles(
    Directory staging, {
    ExportProgressReporter? progress,
    ExportCancellation? cancel,
  }) async {
    final root = await nahpuDocumentDir;
    final sources = await _collectAssociatedFiles();
    progress?.beginPhase(
      ExportPhase.copyingFiles,
      totalUnits: sources.length,
      totalBytes: await _totalBytes(sources),
    );
    for (final source in sources) {
      cancel?.throwIfCancelled();
      final relativePath = p.relative(source.path, from: root.path);
      final target = File(p.join(staging.path, relativePath));
      await target.parent.create(recursive: true);
      progress?.setCurrentItem(p.basename(source.path));
      final bytes = await _fileLength(source);
      await source.copy(target.path);
      progress?.advanceItem(bytes: bytes);
    }
  }

  Future<List<File>> _collectDirectoryFiles(Directory directory) async {
    if (!directory.existsSync()) return const [];
    return directory
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .toList();
  }

  Future<void> _writeArchive(
    DbArchiveFormat format,
    String stagingPath,
    List<String> files, {
    ExportProgressReporter? progress,
    ExportCancellation? cancel,
  }) async {
    progress?.beginPhase(ExportPhase.compressing, totalUnits: files.length);
    try {
      if (format == DbArchiveFormat.zip) {
        final writer = await ZipWriter.newInstance(
          parentDir: stagingPath,
          files: files,
          outputPath: filePath.path,
        );
        await followArchiveProgress(
          writer.writeWithProgress(),
          progress: progress,
          cancel: cancel,
        );
      } else {
        final writer = await TarGzipWriter.newInstance(
          parentDir: stagingPath,
          files: files,
          outputPath: filePath.path,
        );
        await followArchiveProgress(
          writer.writeWithProgress(),
          progress: progress,
          cancel: cancel,
        );
      }
    } on ExportCancelledException {
      rethrow;
    } catch (error) {
      throw Exception('Error creating database backup: $error');
    }
  }

  /// Lists the staged files without blocking the UI isolate.
  ///
  /// A recursive `listSync` over a large media library freezes the frame that a
  /// live progress bar is drawn in, which reads to the user as a hang.
  Future<List<String>> _stagedFilePaths(Directory staging) async {
    final paths = <String>[];
    await for (final entity in staging.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File) paths.add(entity.path);
    }
    return paths;
  }

  Future<int> _databaseBytes() async {
    final database = await dBPath;
    return _fileLength(database);
  }

  Future<int> _totalBytes(List<File> files) async {
    var total = 0;
    for (final file in files) {
      total += await _fileLength(file);
    }
    return total;
  }

  Future<int> _fileLength(File file) async {
    try {
      return await file.length();
    } on FileSystemException {
      return 0;
    }
  }

  /// Removes a partially written archive so a failed run leaves no broken file.
  Future<void> _deleteIncompleteOutput() async {
    try {
      if (filePath.path.isNotEmpty && filePath.existsSync()) {
        await filePath.delete();
      }
    } on FileSystemException catch (error) {
      if (kDebugMode) print('Error deleting partial backup: $error');
    }
  }
}

/// Replaces the current database from a raw SQLite file or full backup archive.
/// Format of the safety archive taken before a database replace.
///
/// tar.gz rather than zip: these are written unattended on every restore, and
/// the smaller output matters more here than opening without extra tools.
const DbArchiveFormat preReplaceBackupFormat = DbArchiveFormat.tarGzip;

class DbWriter extends AppServices {
  const DbWriter({required super.ref, required this.filePath});

  final File filePath;

  /// Describes the stages of a restore, in the order they run.
  ///
  /// Archive contents are unknown until the archive is opened, so the stages
  /// carry equal weight and the running counts carry the detail.
  static const List<ExportPhaseStep> restorePhases = [
    ExportPhaseStep(phase: ExportPhase.extracting, label: 'Extract archive'),
    ExportPhaseStep(
      phase: ExportPhase.copyingFiles,
      label: 'Restore media and files',
    ),
    // The safety archive copies the whole media library, so it carries real
    // weight rather than flashing past as a formality.
    ExportPhaseStep(
      phase: ExportPhase.collecting,
      label: 'Back up current data',
      weight: 2,
    ),
    ExportPhaseStep(
      phase: ExportPhase.finalizing,
      label: 'Replace database',
      weight: 2,
    ),
  ];

  /// Lists the archive's root databases and reads what each would restore.
  ///
  /// This is the extraction the file picker already runs, so reading the
  /// databases and counting the archive's files here costs no extra pass.
  Future<DbArchiveInspection> inspectArchive() async {
    final tempDir = await _extractArchive();
    try {
      final candidates = _databaseCandidates(tempDir);
      var associatedFiles = 0;
      var associatedBytes = 0;
      var includesSettings = false;
      final files = tempDir
          .listSync(recursive: true, followLinks: false)
          .whereType<File>();
      for (final file in files) {
        final relative = _relativeArchivePath(file.path, tempDir.path);
        final name = p.basename(relative).toLowerCase();
        if (name == 'user_configs.json' || name == 'settings.json') {
          includesSettings = true;
        }
        // The same filter the restore copies with, so the count matches what
        // lands on disk.
        if (isAssociatedBackupArchivePath(relative)) {
          associatedFiles++;
          associatedBytes += await file.length();
        }
      }
      final previews = <String, DbReplacementPreview>{
        for (final candidate in candidates)
          candidate.archivePath: await DbReplacementPreview.read(
            p.join(tempDir.path, candidate.archivePath),
            associatedFiles: associatedFiles,
            associatedBytes: associatedBytes,
            includesSettings: includesSettings,
          ),
      };
      return DbArchiveInspection(
        databaseCandidates: candidates,
        previews: previews,
      );
    } finally {
      await _deleteTempDir();
    }
  }

  /// Reads a bare database file chosen as the replacement.
  Future<DbReplacementPreview> inspectDatabaseFile() {
    return DbReplacementPreview.read(filePath.path);
  }

  /// Returns the safety backup written before the replace, or null when
  /// [backup] is false.
  Future<File?> replace(
    bool backup,
    bool isArchived, {
    String? databaseRelativePath,
    ExportProgressReporter? progress,
    ExportCancellation? cancel,
  }) async {
    try {
      final dbImportPath = isArchived
          ? await _copyProjectData(
              databaseRelativePath,
              progress: progress,
              cancel: cancel,
            )
          : filePath.path;
      cancel?.throwIfCancelled();
      final backupFile = backup
          ? await _backUpBeforeDelete(progress: progress, cancel: cancel)
          : null;
      cancel?.throwIfCancelled();
      progress?.beginPhase(ExportPhase.finalizing);
      await _writeDb(dbImportPath);
      progress?.complete();
      return backupFile;
    } finally {
      await _deleteTempDir();
    }
  }

  Future<Directory> _extractArchive({
    ExportProgressReporter? progress,
    ExportCancellation? cancel,
  }) async {
    final tempDir = await _restoreStagingDir();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
    await tempDir.create(recursive: true);
    progress?.beginPhase(ExportPhase.extracting);
    final lowerPath = filePath.path.toLowerCase();
    if (lowerPath.endsWith('.zip')) {
      final extractor = await ZipExtractor.newInstance(
        archivePath: filePath.path,
        outputDir: tempDir.path,
      );
      await followArchiveProgress(
        extractor.extractWithProgress(),
        progress: progress,
        cancel: cancel,
      );
    } else if (lowerPath.endsWith('.tar.gz')) {
      final extractor = await TarGzipExtractor.newInstance(
        archivePath: filePath.path,
        outputDir: tempDir.path,
      );
      await followArchiveProgress(
        extractor.extractWithProgress(),
        progress: progress,
        cancel: cancel,
      );
    } else {
      throw const FormatException(
        'Choose a NAHPU backup ZIP or TAR.GZ archive.',
      );
    }
    await _validateExtraction(tempDir);
    return tempDir;
  }

  List<DbArchiveDatabaseCandidate> _databaseCandidates(Directory tempDir) {
    return databaseCandidatesFromRelativePaths(
      tempDir
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .map((file) => _relativeArchivePath(file.path, tempDir.path)),
    );
  }

  Future<String> _copyProjectData(
    String? databaseRelativePath, {
    ExportProgressReporter? progress,
    ExportCancellation? cancel,
  }) async {
    final tempDir = await _extractArchive(progress: progress, cancel: cancel);
    final candidates = _databaseCandidates(tempDir);
    if (candidates.isEmpty) {
      throw const FormatException(
        'The backup archive does not contain a database at its root.',
      );
    }
    final selected = databaseRelativePath == null
        ? candidates.singleOrNull
        : candidates
              .where(
                (candidate) => candidate.archivePath == databaseRelativePath,
              )
              .firstOrNull;
    if (selected == null) {
      throw const FormatException(
        'Select one of the database files at the archive root.',
      );
    }

    final selectedPath = p.join(tempDir.path, selected.archivePath);
    final files = tempDir.listSync(recursive: true, followLinks: false);
    await _importSettings(files);
    final nahpuDir = await nahpuDocumentDir;
    final restorable = files.whereType<File>().where((entity) {
      final relative = _relativeArchivePath(entity.path, tempDir.path);
      return entity.path != selectedPath &&
          isAssociatedBackupArchivePath(relative);
    }).toList();
    progress?.beginPhase(
      ExportPhase.copyingFiles,
      totalUnits: restorable.length,
    );
    for (final entity in restorable) {
      cancel?.throwIfCancelled();
      final relative = _relativeArchivePath(entity.path, tempDir.path);
      // Older backups kept personnel photos where the app no longer looks.
      final target = File(
        p.joinAll([
          nahpuDir.path,
          ...restoredRelativePath(relative).split('/'),
        ]),
      );
      await target.parent.create(recursive: true);
      progress?.setCurrentItem(p.basename(entity.path));
      // Each file goes to its restored path, so a file already sitting there is
      // overwritten rather than gaining a renamed sibling, and an identical one
      // is left alone.
      if (!await hasIdenticalFileContent(entity, target)) {
        await entity.copy(target.path);
      }
      progress?.advanceItem();
    }
    return selectedPath;
  }

  Future<void> _importSettings(List<FileSystemEntity> files) async {
    final settings = files.whereType<File>().where((file) {
      final name = p.basename(file.path).toLowerCase();
      return name == 'user_configs.json' || name == 'settings.json';
    }).toList();
    if (settings.isEmpty) return;
    await rust_config.importConfigFromFile(
      filePath: settings.first.path,
      sections: rust_config.UserConfigSection.values,
    );
  }

  String _relativeArchivePath(String filePath, String rootPath) {
    return p.relative(filePath, from: rootPath).replaceAll('\\', '/');
  }

  /// Rejects an archive whose entries escape the extraction directory.
  ///
  /// The walk is asynchronous so a large restore does not block the frame that
  /// draws the progress panel.
  Future<void> _validateExtraction(Directory extraction) async {
    final root = p.canonicalize(extraction.path);
    await for (final entity in extraction.list(
      recursive: true,
      followLinks: false,
    )) {
      final candidate = p.canonicalize(entity.path);
      if (!p.isWithin(root, candidate) || entity is Link) {
        throw const FormatException(
          'The backup archive contains an unsafe path.',
        );
      }
    }
  }

  Future<void> _writeDb(String dbImportPath) async {
    final newDb = sqlite3.sqlite3.open(dbImportPath);
    dbAccess.close();
    final appDb = await dBPath;
    if (appDb.existsSync()) appDb.deleteSync();
    await DbServices(ref: ref).setNewDatabase();
    newDb.execute('VACUUM INTO ?', [appDb.path]);
    if (kDebugMode) print('Mark new database!');
    newDb.close();
  }

  /// Writes a full archive before the database is overwritten.
  ///
  /// This used to be a bare `.sqlite3` snapshot, which meant the safety net
  /// under the most destructive operation in the app held no media at all — a
  /// user who restored the wrong archive got their records back and their
  /// photos never. It now goes through [DbExport], so the fallback is the same
  /// zip or tar.gz with every media file that the backup window produces.
  Future<File> _backUpBeforeDelete({
    ExportProgressReporter? progress,
    ExportCancellation? cancel,
  }) async {
    final documentDir = await nahpuDocumentDir;
    final directory = Directory(p.join(documentDir.path, nahpuBackupDir));
    await directory.create(recursive: true);
    final target = await AppIOServices(
      dir: directory,
      fileStem: 'nahpu_backup-$dateTimeStamp',
      ext: preReplaceBackupFormat.extension,
    ).getSavePath();

    // [DbExport] reports against its own stages, which are not part of a
    // restore job, so this stage runs indeterminate and names the file instead
    // of forwarding a reporter that would assert on unknown phases.
    progress?.beginPhase(ExportPhase.collecting, indeterminate: true);
    progress?.setCurrentItem(p.basename(target.path));

    await DbExport(
      ref: ref,
      filePath: target,
    ).write(preReplaceBackupFormat, cancel: cancel);
    return target;
  }

  /// Where an archive is unpacked during a restore.
  ///
  /// A subdirectory rather than the `NahpuTemp` root, because siblings there
  /// belong to other jobs — including the export directory a share sheet may
  /// still be reading from.
  Future<Directory> _restoreStagingDir() async {
    final tempRoot = await tempDirectory;
    return Directory(p.join(tempRoot.path, _restoreStagingDirName));
  }

  Future<void> _deleteTempDir() async {
    try {
      final tempDir = await _restoreStagingDir();
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    } catch (error) {
      if (kDebugMode) print('Error deleting temp dir: $error');
    }
  }
}
