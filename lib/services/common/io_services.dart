/// NAHPU Storage Structure
///
/// This file manages input/output operations and defines the project storage
/// structure. All NAHPU data is stored in the user's application documents
/// directory under the `nahpu` root directory, with temporary files placed in
/// the system temporary directory.
///
/// Storage layout:
/// ```text
/// Documents/
/// └── nahpu/                             # Root application directory (`nahpuAppDir`)
///     ├── nahpu.db                       # Main SQLite database file
///     ├── backup/                        # SQLite database backups (`nahpuBackupDir`)
///     │   └── nahpu_backup_YYYY-MM-DD-HH-MM-SS.sqlite3
///     ├── appMedia/                      # Global app media directory
///     │   └── personnel/                 # Personnel photos/images
///     ├── UserConfigs/                   # User configuration directory (`userConfigDirName`)
///     │   └── fonts/                     # Custom user fonts (`userFontDirName`)
///     │   └── maps/                      # Custom user maps (`userMapDirName`)
///     └── <project_uuid>/                # Individual project directories
///         ├── associatedData/            # Project associated-data files
///         │   ├── sites/                 # Files originating from sites
///         │   ├── events/                # Files originating from events
///         │   └── specimens/             # Files originating from specimens
///         └── media/                     # Project-specific media files (`mediaDir`)
///             ├── site/                  # Site photos/media
///             ├── event/                 # Event photos/media
///             ├── specimen/              # Specimen photos/media
///             └── narrative/             # Narrative photos/media
///
/// Temporary Directory:
/// <system_temp_dir>/
/// └── NahpuTemp/                         # Temporary/caching directory (`nahpuTempDir`)
/// ```
library;

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/media/media_services.dart';
import 'package:nahpu/services/projects/personnel_services.dart';
import 'package:nahpu/services/associated_data/associated_data_services.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/services/types/associated_data.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

const String nahpuBackupDir = 'backup';
const String nahpuAppDir = 'nahpu';
const String mediaDir = 'media';
const String associatedDataDir = 'associatedData';
const String associatedDataSitesDir = 'sites';
const String associatedDataEventsDir = 'events';
const String associatedDataSpecimensDir = 'specimens';
const String nahpuTempDir = 'NahpuTemp';
const String userConfigDirName = 'UserConfigs';
const String userFontDirName = 'fonts';
const String userMapDirName = 'maps';

String get dateTimeStamp {
  DateTime now = DateTime.now();
  String date = '${now.year}-${now.month}-${now.day}';
  String time = '${now.hour}-${now.minute}-${now.second}';
  return '$date-$time';
}

String formatFileDateSuffix(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '-$year-$month-$day';
}

String appendDateToFileStem(String fileStem, DateTime date) {
  final stem = fileStem.trim();
  if (RegExp(r'-\d{4}-\d{2}-\d{2}$').hasMatch(stem)) return stem;
  return '$stem${formatFileDateSuffix(date)}';
}

typedef OpenFilesCallback =
    Future<List<XFile>> Function({
      List<XTypeGroup>? acceptedTypeGroups,
      String? initialDirectory,
      String? confirmButtonText,
    });

Future<List<XFile>> _defaultOpenFiles({
  List<XTypeGroup>? acceptedTypeGroups,
  String? initialDirectory,
  String? confirmButtonText,
}) {
  return openFiles(
    acceptedTypeGroups: acceptedTypeGroups ?? const <XTypeGroup>[],
    initialDirectory: initialDirectory,
    confirmButtonText: confirmButtonText,
  );
}

class FilePickerServices {
  factory FilePickerServices({
    OpenFilesCallback openFiles = _defaultOpenFiles,
  }) {
    return FilePickerServices._(openFiles);
  }

  FilePickerServices._(this._openFiles);

  final OpenFilesCallback _openFiles;

  Future<void> shareFile(BuildContext context, File file) async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  Future<void> shareText(BuildContext context, String text) async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  Future<Directory?> selectDir() async {
    final result = Platform.isIOS
        ? await FilePicker.getDirectoryPath()
        : await getDirectoryPath();
    if (result != null) {
      if (kDebugMode) {
        print('Selected directory: $result');
      }
      return Directory(result);
    }
    return null;
  }

  Future<XFile?> selectAnyFile() async {
    final result = await FilePicker.pickFile();
    return result?.xFile;
  }

  Future<XFile?> selectJsonFile() async {
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    return result?.xFile;
  }

  Future<XFile?> selectRecordFile() async {
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json', 'zip', 'gz'],
    );
    return result?.xFile;
  }

  Future<XFile?> selectUserConfigFile() async {
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json', 'gz'],
    );
    return result?.xFile;
  }

  Future<List<XFile>> pickMultiFiles(List<XTypeGroup> allowedExtension) async {
    return await _openFiles(acceptedTypeGroups: allowedExtension);
  }
}

class AppIOServices {
  AppIOServices({required this.dir, required this.fileStem, required this.ext});

  final Directory? dir;
  final String fileStem;
  final String ext;

  Future<File> getSavePath() async {
    String fileName = '$fileStem.$ext';
    // Check if file exists
    File file = await _createSavePath(fileName);
    if (file.existsSync()) {
      int i = 1;
      while (file.existsSync()) {
        fileName = '$fileStem($i).$ext';
        file = await _createSavePath(fileName);
        i++;
      }
    }
    return file;
  }

  Future<File> _createSavePath(String fileName) async {
    Directory finalDir = await _getSaveDir();

    if (!finalDir.existsSync()) finalDir.createSync(recursive: true);

    String finalPath = path.join(finalDir.path, fileName);
    return File(finalPath);
  }

  Future<Directory> _getSaveDir() async {
    if (dir == null) {
      return await getApplicationDocumentsDirectory();
    }
    return dir!;
  }
}

class FileServices extends AppServices {
  FileServices({required super.ref});

  Future<Directory> get currentProjectDir async {
    final projectDir = await getProjectDirByUUID(currentProjectUuid);
    return projectDir;
  }

  Future<Directory> getProjectDirByUUID(String projectUuid) async {
    final documentDir = await nahpuDocumentDir;
    final projectDir = Directory(path.join(documentDir.path, projectUuid));
    return projectDir;
  }

  Future<File> copyFileToProjectDir(File from, Directory to) async {
    final projectDir = await currentProjectDir;
    final targetDir = path.join(projectDir.path, to.path);
    return _copyFileToDir(from, targetDir);
  }

  Future<Directory> getProjectAssociatedDataDirectory(
    String projectUuid,
  ) async {
    final projectDir = await getProjectDirByUUID(projectUuid);
    return Directory(path.join(projectDir.path, associatedDataDir));
  }

  Future<Directory> getAssociatedDataDirectory(
    AssociatedDataOrigin origin,
  ) async {
    final root = await getProjectAssociatedDataDirectory(currentProjectUuid);
    final directoryName = switch (origin) {
      AssociatedDataOrigin.sites => associatedDataSitesDir,
      AssociatedDataOrigin.events => associatedDataEventsDir,
      AssociatedDataOrigin.specimens => associatedDataSpecimensDir,
    };
    return Directory(path.join(root.path, directoryName));
  }

  Future<File> copyAssociatedDataFile(
    File from,
    AssociatedDataOrigin origin,
  ) async {
    final directory = await getAssociatedDataDirectory(origin);
    return _copyFileToDir(from, directory.path);
  }

  Future<String> associatedDataStorageKey(File file) async {
    final root = await getProjectAssociatedDataDirectory(currentProjectUuid);
    final absoluteRoot = path.absolute(root.path);
    final absoluteFile = path.absolute(file.path);
    if (!path.isWithin(absoluteRoot, absoluteFile)) {
      throw const FormatException(
        'Associated data file is outside the project directory.',
      );
    }
    return path
        .relative(absoluteFile, from: absoluteRoot)
        .replaceAll('\\', '/');
  }

  Future<File> resolveAssociatedDataFile(
    String projectUuid,
    String storageKey,
  ) async {
    final value = storageKey.trim();
    final rawSegments = value.replaceAll('\\', '/').split('/');
    if (value.isEmpty ||
        path.posix.isAbsolute(value) ||
        path.windows.isAbsolute(value) ||
        Uri.parse(value).hasScheme ||
        rawSegments.contains('..')) {
      throw const FormatException('Invalid associated data file path.');
    }
    final normalized = path.normalize(value.replaceAll('/', path.separator));
    if (normalized == '.' || path.split(normalized).contains('..')) {
      throw const FormatException('Invalid associated data file path.');
    }
    final root = await getProjectAssociatedDataDirectory(projectUuid);
    final absoluteRoot = path.absolute(root.path);
    final resolved = path.absolute(path.join(absoluteRoot, normalized));
    if (!path.isWithin(absoluteRoot, resolved)) {
      throw const FormatException('Invalid associated data file path.');
    }
    return File(resolved);
  }

  Future<File> copyFileToAppDir(File from, Directory to) async {
    final appDir = await nahpuDocumentDir;
    final targetDir = path.join(appDir.path, to.path);
    return _copyFileToDir(from, targetDir);
  }

  Future<File> _copyFileToDir(File from, String targetDir) async {
    await Directory(targetDir).create(recursive: true);
    final fileName = path.basename(from.path);
    final toPath = _uniqueFilePath(targetDir, fileName);
    await from.copy(toPath);
    return File(toPath);
  }

  String _uniqueFilePath(String targetDir, String fileName) {
    final stem = path.basenameWithoutExtension(fileName);
    final extension = path.extension(fileName);
    String candidate = path.join(targetDir, fileName);
    int index = 1;
    while (File(candidate).existsSync()) {
      candidate = path.join(targetDir, '${stem}_$index$extension');
      index++;
    }
    return candidate;
  }
}

class AppServices {
  const AppServices({required this.ref});

  final WidgetRef ref;

  Database get dbAccess => ref.read(databaseProvider);

  String get currentProjectUuid => ref.read(projectUuidProvider);

  Future<File> get backupDir async {
    final documentDir = await nahpuDocumentDir;
    final backupDir = Directory(path.join(documentDir.path, nahpuBackupDir));
    await backupDir.create(recursive: true);
    final backupFile = File(
      path.join(backupDir.path, 'nahpu_backup$dateTimeStamp.sqlite3'),
    );
    return backupFile;
  }

  Future<Directory> get tempDirectory async {
    final Directory tempDir = await getTemporaryDirectory();
    final nahpuTemp = Directory(path.join(tempDir.path, nahpuTempDir));
    await nahpuTemp.create(recursive: true);
    return nahpuTemp;
  }

  Directory getMediaDir(MediaCategory category) {
    switch (category) {
      case MediaCategory.site:
        return Directory('$mediaDir/site');
      case MediaCategory.event:
        return Directory('$mediaDir/event');
      case MediaCategory.specimen:
        return Directory('$mediaDir/specimen');
      case MediaCategory.narrative:
        return Directory('$mediaDir/narrative');
      case MediaCategory.personnel:
        // Personnel media is stored in the app directory
        // in lieu of the project directory
        return Directory('appMedia/personnel');
      default:
        throw Exception('Unsupported media category');
    }
  }

  Future<Directory> get userConfigDir async {
    final documentDir = await nahpuDocumentDir;
    final userConfigDir = Directory(
      path.join(documentDir.path, userConfigDirName),
    );
    await userConfigDir.create(recursive: true);
    return userConfigDir;
  }

  Future<Directory> get userFontDir async {
    final userConfigDir = await this.userConfigDir;
    final userFontDir = Directory(
      path.join(userConfigDir.path, userFontDirName),
    );
    await userFontDir.create(recursive: true);
    return userFontDir;
  }

  Future<Directory> get userMapDir async {
    return getUserMapDirectory();
  }
}

Future<Directory> getUserMapDirectory() async {
  final documentDir = await nahpuDocumentDir;
  final userMapDir = Directory(
    path.join(documentDir.path, userConfigDirName, userMapDirName),
  );
  await userMapDir.create(recursive: true);
  return userMapDir;
}

Future<Directory> get nahpuDocumentDir async {
  final dbDir = await getApplicationDocumentsDirectory();
  final nahpuDir = Directory(path.join(dbDir.path, nahpuAppDir));
  await nahpuDir.create(recursive: true);
  return nahpuDir;
}

class DataUsageServices extends AppServices {
  const DataUsageServices({required super.ref});

  Future<String> get appDataUsage async {
    final nahpuDir = await nahpuDocumentDir;
    final dirSize = nahpuDir.listSync(recursive: true);
    int size = 0;
    for (final file in dirSize) {
      if (file is File) {
        size += file.lengthSync();
      }
    }
    return '${(size / 1024 / 1024).toStringAsFixed(2)} MB';
  }

  Future<int> get fileCount async {
    final nahpuDir = await nahpuDocumentDir;
    final dirSize = nahpuDir.listSync(recursive: true);
    int count = 0;
    for (final file in dirSize) {
      if (file is File) {
        count++;
      }
    }
    return count;
  }

  Future<int> get mediaCount async {
    final nahpuDir = await nahpuDocumentDir;
    final dirSize = nahpuDir.listSync(recursive: true).whereType<File>();
    int count = 0;
    for (final file in dirSize) {
      if (_isSupportedMediaFile(file)) {
        count++;
      }
    }
    return count;
  }

  Future<List<NahpuFile>> get fileList async {
    final nahpuDir = await nahpuDocumentDir;
    final fileList = nahpuDir.listSync(recursive: true).whereType<File>();

    List<NahpuFile> nahpuFileList = [];
    for (final file in fileList) {
      final format = _matchFormat(file);
      final isDeletable = await _isDeletable(file, format);
      nahpuFileList.add(
        NahpuFile(path: file, isDeletable: isDeletable, format: format),
      );
    }

    return nahpuFileList;
  }

  NahpuFileFormat _matchFormat(File file) {
    return matchNahpuFormatFromPath(file.path);
  }

  Future<bool> _isDeletable(File file, NahpuFileFormat format) async {
    if (format == NahpuFileFormat.database) {
      return false;
    }

    if (isSupportedMediaFormat(format)) {
      bool isUsedByMedia = await MediaServices(ref: ref).isMediaUsed(file);
      bool isUsedByPersonnel = await PersonnelServices(
        ref: ref,
      ).isImageUsedInPersonnelPhoto(file);
      bool isUsedInAssociatedData = await AssociatedDataServices(
        ref: ref,
      ).isFileUsed(file);
      return !(isUsedByMedia || isUsedByPersonnel || isUsedInAssociatedData);
    }

    if (format == NahpuFileFormat.other) {
      bool isUsedInAssociatedData = await AssociatedDataServices(
        ref: ref,
      ).isFileUsed(file);
      return !isUsedInAssociatedData;
    }

    return true;
  }

  bool _isSupportedMediaFile(File file) {
    return isSupportedMediaPath(file.path);
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
