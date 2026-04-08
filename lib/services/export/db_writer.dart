//! This file contains the class to write the database into a file
//! and replace the current database with a new one.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nahpu/services/db_services.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/media_services.dart';
import 'package:nahpu/src/rust/api/archive.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:nahpu/services/database/database.dart';
import 'package:path/path.dart' as p;
import 'package:nahpu/services/kdl_services.dart';

/// Export the database into a file
/// If [isWithProjectData] is true, the project data will be included
/// If [isWithAppSettings] is true, the app settings will be included
/// If either are true, the file will be zipped.
/// Otherwise, the database file will be exported as a sqlite3 file.
class DbExport extends AppServices {
  const DbExport({required super.ref, required this.filePath});

  final File filePath;

  Future<File> write(bool isWithProjectData, bool isWithAppSettings) async {
    final nahpuDir = await nahpuDocumentDir;
    final dbPath =
        await _writeSqlite(nahpuDir, isWithProjectData, isWithAppSettings);
    File? settingsFile;

    if (isWithProjectData || isWithAppSettings) {
      String archivePath = p.setExtension(filePath.path, '.zip');
      List<String> allAppFiles = [];

      if (isWithProjectData) {
        allAppFiles = await _collectAppFiles(nahpuDir);
      }

      if (isWithAppSettings) {
        String settingsPath = p.join(nahpuDir.path, 'settings.kdl');
        settingsFile = await KdlServices().write(settingsPath);
        allAppFiles.add(settingsFile.path);
      }

      allAppFiles.add(dbPath.path);
      if (kDebugMode) print('Archiving files: ${allAppFiles.length}');
      await _archiveFiles(nahpuDir, allAppFiles, archivePath);

      // Delete the newly created KDL app settings file, if it was created
      settingsFile?.deleteSync();

      // Delete the newly created database file
      dbPath.deleteSync();

      return File(archivePath);
    }
    return filePath;
  }

  Future<File> _writeSqlite(
      Directory nahpuDir, bool withProjectData, bool isWithAppSettings) async {
    if (withProjectData || isWithAppSettings) {
      final fileName = p.basename(filePath.path);
      final outputPath = File(p.join(nahpuDir.path, fileName));
      await dbAccess.exportInto(outputPath);
      return outputPath;
    } else {
      await dbAccess.exportInto(filePath);
      return filePath;
    }
  }

  Future<List<String>> _collectAppFiles(Directory nahpuDir) async {
    final mediaFiles = await MediaFinder(ref: ref).getAllMedia();
    return mediaFiles.map((e) => e.path).toList();
  }

  Future<void> _archiveFiles(
    Directory nahpuDir,
    List<String> files,
    String archivePath,
  ) async {
    try {
      await ZipWriter(
        parentDir: nahpuDir.path,
        files: files,
        outputPath: archivePath,
      ).write();
    } catch (e) {
      throw Exception('Error creating archive: $e');
    }
  }
}

/// Write the database into a file
/// and replace the current database with a new one.
/// If [backup] is true, the current database will be backed up.
/// If [isArchived] is true, the backup file is zipped and may contain
/// either project data or app settings
class DbWriter extends AppServices {
  const DbWriter({required super.ref, required this.filePath});

  final File filePath;

  /// Replace the current database with a new one.
  Future<void> replace(bool backup, bool isArchived) async {
    String dbImportPath = filePath.path;
    if (isArchived) {
      dbImportPath = await _copyProjectData(filePath);
    }
    if (backup) {
      File backupPath = await backupDir;
      await _backUpBeforeDelete(backupPath);
    }
    await _writeDb(dbImportPath);
    await _deleteTempDir();
  }

  Future<void> _deleteTempDir() async {
    // Try delete ignore if error
    try {
      final tempDir = await tempDirectory;
      tempDir.deleteSync(recursive: true);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting temp dir: $e');
      }
    }
  }

  Future<String> _copyProjectData(File file) async {
    final tempDir = await tempDirectory;
    await ZipExtractor(
      archivePath: file.path,
      outputDir: tempDir.path,
    ).extract();
    final files = tempDir.listSync(recursive: true);
    final dbPath = await _findSqlite3InTempDir(files);
    final nahpuDir = await nahpuDocumentDir;
    // Remove all .db files if exist in the zip file
    if (files.any((file) => file.path.endsWith('.db'))) {
      files.removeWhere((file) => file.path.endsWith('.db'));
    }

    // Process app settings file
    if (files.any((file) => file.path.endsWith('.kdl'))) {
      FileSystemEntity settingsFileEntity =
          files.firstWhere((file) => file.path.endsWith('.kdl'));
      File settingsFile = File(settingsFileEntity.path);
      KdlServices().readAndUpdateSettings(settingsFile.path);
      files.remove(settingsFile);
    }

    for (var file in files) {
      if (file is File) {
        final filename = p.relative(file.path, from: tempDir.path);
        final newPath = p.join(nahpuDir.path, filename);
        // Create directory if not exist
        final newDir = Directory(p.dirname(newPath));
        if (!newDir.existsSync()) {
          newDir.createSync(recursive: true);
        }
        if (!File(newPath).existsSync()) {
          file.copySync(newPath);
        }
      }
    }
    return dbPath;
  }

  Future<void> _writeDb(String dbImportPath) async {
    final newDb = sqlite3.sqlite3.open(dbImportPath);
    dbAccess.close();
    final appDb = await dBPath;
    if (appDb.existsSync()) {
      appDb.deleteSync();
    }
    await DbServices(ref: ref).setNewDatabase();
    newDb.execute('VACUUM INTO ?', [appDb.path]);

    if (kDebugMode) {
      print('Mark new database!');
    }

    newDb.dispose();
  }

  Future<String> _findSqlite3InTempDir(List<FileSystemEntity> files) async {
    for (var file in files) {
      if (file is File) {
        if (file.path.endsWith('.sqlite3')) {
          return file.path;
        }
      }
    }

    throw Exception('No sqlite3 file found in the archive!');
  }

  Future<void> _backUpBeforeDelete(File backupPath) async {
    if (backupPath.existsSync()) {
      backupPath.deleteSync();
    }

    await dbAccess.exportInto(backupPath);
  }
}
