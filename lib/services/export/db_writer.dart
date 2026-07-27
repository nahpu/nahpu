//! This file contains the services to create and restore full NAHPU backups.
import 'dart:io';

import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter/foundation.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/db_services.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/media_services.dart';
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
  const DbBackupSummary({required this.entries});

  final Map<String, int> entries;
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
  if (lower.endsWith('.json.nl') || lower.endsWith('.jsonl')) return false;
  if (lower.endsWith('.sqlite3') || lower.endsWith('.db')) return false;
  final segments = lower.split('/');
  return lower.startsWith('appmedia/') ||
      lower.startsWith('userconfigs/maps/') ||
      lower.startsWith('userconfigs/fonts/') ||
      (segments.length >= 3 &&
          (segments[1] == 'media' || segments[1] == 'associateddata'));
}

/// Creates a complete NAHPU backup archive.
class DbExport extends AppServices {
  const DbExport({required super.ref, required this.filePath});

  final File filePath;

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
    return DbBackupSummary(entries: counts);
  }

  Future<File> write(DbArchiveFormat format) async {
    final tempRoot = await tempDirectory;
    final staging = Directory(
      p.join(
        tempRoot.path,
        'db-backup-${DateTime.now().microsecondsSinceEpoch}',
      ),
    );
    await staging.create(recursive: true);

    try {
      final databaseFile = File(p.join(staging.path, nahpuBackupDatabaseName));
      await dbAccess.exportInto(databaseFile);

      final settingsFile = File(p.join(staging.path, 'user_configs.json'));
      await rust_config.exportConfigToFile(
        filePath: settingsFile.path,
        isJson: true,
      );

      await _copyAssociatedFiles(staging);
      final archiveFiles = staging
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .map((file) => file.path)
          .toList();
      await _writeArchive(format, staging.path, archiveFiles);
      return filePath;
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
    files.addAll(await _collectDirectoryFiles(await userMapDir));
    files.addAll(await _collectDirectoryFiles(await userFontDir));
    return files.where((file) => file.existsSync()).toList();
  }

  Future<List<File>> _collectAssociatedDataFiles() async {
    final root = await nahpuDocumentDir;
    final rows = await dbAccess
        .customSelect(
          "SELECT projectUuid, uri FROM associatedData WHERE type = 'File'",
        )
        .get();
    File? associatedDataFile(QueryRow row) {
      final projectUuid = row.data['projectUuid'] as String?;
      final fileName = row.data['uri'] as String?;
      if (projectUuid == null || fileName == null || fileName.isEmpty) {
        return null;
      }
      return File(p.join(root.path, projectUuid, 'associatedData', fileName));
    }

    return rows
        .map(associatedDataFile)
        .whereType<File>()
        .where((file) => file.existsSync())
        .toList();
  }

  Future<void> _copyAssociatedFiles(Directory staging) async {
    final root = await nahpuDocumentDir;
    for (final source in await _collectAssociatedFiles()) {
      final relativePath = p.relative(source.path, from: root.path);
      final target = File(p.join(staging.path, relativePath));
      await target.parent.create(recursive: true);
      await source.copy(target.path);
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
    List<String> files,
  ) async {
    try {
      if (format == DbArchiveFormat.zip) {
        final writer = await ZipWriter.newInstance(
          parentDir: stagingPath,
          files: files,
          outputPath: filePath.path,
        );
        await writer.write();
      } else {
        final writer = await TarGzipWriter.newInstance(
          parentDir: stagingPath,
          files: files,
          outputPath: filePath.path,
        );
        await writer.write();
      }
    } catch (error) {
      throw Exception('Error creating database backup: $error');
    }
  }
}

/// Replaces the current database from a raw SQLite file or full backup archive.
class DbWriter extends AppServices {
  const DbWriter({required super.ref, required this.filePath});

  final File filePath;

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
  }) async {
    try {
      final dbImportPath = isArchived
          ? await _copyProjectData(databaseRelativePath)
          : filePath.path;
      if (backup) {
        final backupPath = await backupDir;
        await _backUpBeforeDelete(backupPath);
      }
      await _writeDb(dbImportPath);
    } finally {
      await _deleteTempDir();
    }
  }

  Future<Directory> _extractArchive() async {
    final tempDir = await tempDirectory;
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
    await tempDir.create(recursive: true);
    final lowerPath = filePath.path.toLowerCase();
    if (lowerPath.endsWith('.zip')) {
      final extractor = await ZipExtractor.newInstance(
        archivePath: filePath.path,
        outputDir: tempDir.path,
      );
      await extractor.extract();
    } else if (lowerPath.endsWith('.tar.gz')) {
      final extractor = await TarGzipExtractor.newInstance(
        archivePath: filePath.path,
        outputDir: tempDir.path,
      );
      await extractor.extract();
    } else {
      throw const FormatException(
        'Choose a NAHPU backup ZIP or TAR.GZ archive.',
      );
    }
    _validateExtraction(tempDir);
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

  Future<String> _copyProjectData(String? databaseRelativePath) async {
    final tempDir = await _extractArchive();
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
    for (final entity in files.whereType<File>()) {
      final relative = _relativeArchivePath(entity.path, tempDir.path);
      if (entity.path == selectedPath ||
          !isAssociatedBackupArchivePath(relative)) {
        continue;
      }
      final target = File(p.join(nahpuDir.path, relative));
      await target.parent.create(recursive: true);
      await entity.copy(target.path);
    }
    return selectedPath;
  }

  Future<void> _importSettings(List<FileSystemEntity> files) async {
    final settings = files.whereType<File>().where((file) {
      final name = p.basename(file.path).toLowerCase();
      return name == 'user_configs.json' ||
          name == 'settings.json' ||
          name.endsWith('.json.nl') ||
          name.endsWith('.jsonl');
    }).toList();
    if (settings.isEmpty) return;
    await rust_config.importConfigFromFile(filePath: settings.first.path);
  }

  String _relativeArchivePath(String filePath, String rootPath) {
    return p.relative(filePath, from: rootPath).replaceAll('\\', '/');
  }

  void _validateExtraction(Directory extraction) {
    final root = p.canonicalize(extraction.path);
    for (final entity in extraction.listSync(
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

  Future<void> _backUpBeforeDelete(File backupPath) async {
    if (backupPath.existsSync()) backupPath.deleteSync();
    await dbAccess.exportInto(backupPath);
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
