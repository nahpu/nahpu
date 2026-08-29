//! This file contains the services to create and restore full NAHPU backups.
import 'dart:io';

import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter/foundation.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/db_services.dart';
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

class DbArchiveDatabaseCandidate {
  const DbArchiveDatabaseCandidate({
    required this.archivePath,
    required this.displayName,
  });

  final String archivePath;
  final String displayName;
}

class DbArchiveInspection {
  const DbArchiveInspection({required this.databaseCandidates});

  final List<DbArchiveDatabaseCandidate> databaseCandidates;
}

class DbBackupSummary {
  const DbBackupSummary({
    required this.entries,
    required this.associatedFileBytes,
    required this.databaseBytes,
  });

  final Map<String, int> entries;

  /// Combined size of the media and associated files the backup will copy.
  final int associatedFileBytes;

  /// Size of the live database, used to estimate the work the backup starts with.
  final int databaseBytes;

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
      lower.startsWith('userconfigs/maps/') ||
      lower.startsWith('userconfigs/fonts/') ||
      (segments.length >= 3 &&
          (segments[1] == 'media' || segments[1] == 'associateddata'));
}

@visibleForTesting
List<String> globalBackupDirectoryPaths(String root) {
  return [
    p.join(root, userConfigDirName, userMapDirName),
    p.join(root, userConfigDirName, userFontDirName),
    p.join(root, appMediaDirName, templateMediaDirName),
  ];
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
      'Projects': await _countRows('project'),
      'Personnel': await _countRows('personnel'),
      'Taxa': await _countRows('taxonomy'),
      'Sites': await _countRows('site'),
      'Collection events': await _countRows('collEvent'),
      'Specimens': await _countRows('specimen'),
      'Narratives': await _countRows('narrative'),
      'Media records': await _countRows('media'),
    };
    final associatedFiles = await _collectAssociatedFiles();
    counts['Associated files'] = associatedFiles.length;
    return DbBackupSummary(
      entries: counts,
      associatedFileBytes: await _totalBytes(associatedFiles),
      databaseBytes: await _databaseBytes(),
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

  Future<List<File>> _collectAssociatedFiles() async {
    final files = <File>[...await MediaFinder(ref: ref).getAllMedia()];
    files.addAll(await _collectAssociatedDataFiles());
    final root = await nahpuDocumentDir;
    for (final directoryPath in globalBackupDirectoryPaths(root.path)) {
      final directory = Directory(directoryPath);
      await directory.create(recursive: true);
      files.addAll(await _collectDirectoryFiles(directory));
    }
    return files.where((file) => file.existsSync()).toList();
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

  Future<DbArchiveInspection> inspectArchive() async {
    final tempDir = await _extractArchive();
    try {
      final candidates = _databaseCandidates(tempDir);
      return DbArchiveInspection(databaseCandidates: candidates);
    } finally {
      await _deleteTempDir();
    }
  }

  Future<void> replace(
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
      if (backup) {
        await _backUpBeforeDelete(progress: progress, cancel: cancel);
      }
      cancel?.throwIfCancelled();
      progress?.beginPhase(ExportPhase.finalizing);
      await _writeDb(dbImportPath);
      progress?.complete();
    } finally {
      await _deleteTempDir();
    }
  }

  Future<Directory> _extractArchive({
    ExportProgressReporter? progress,
    ExportCancellation? cancel,
  }) async {
    final tempDir = await tempDirectory;
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
      final target = File(p.join(nahpuDir.path, relative));
      await target.parent.create(recursive: true);
      progress?.setCurrentItem(p.basename(entity.path));
      await entity.copy(target.path);
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

  Future<void> _deleteTempDir() async {
    try {
      final tempDir = await tempDirectory;
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    } catch (error) {
      if (kDebugMode) print('Error deleting temp dir: $error');
    }
  }
}
