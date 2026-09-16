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
///     │   ├── personnel/                 # Personnel photos/images
///     │   └── template/                  # Shared template media (`templateMediaDirName`)
///     ├── UserConfigs/                   # User configuration directory (`userConfigDirName`)
///     │   ├── fonts/                     # Custom user fonts (`userFontDirName`)
///     │   │   ├── catalog.json           # Installed font families
///     │   │   └── <font_uuid>/           # One directory per installed family
///     │   │       ├── font.json          # Family metadata
///     │   │       └── *.ttf              # Font files for the family
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
///     ├── exports/                       # Share-only exports (`nahpuTempExportDirName`),
///     │                                  # emptied at the start of every export
///     └── <job>-<timestamp>/             # Per-job staging (backup, bundle, transfer)
/// ```
library;

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mime/mime.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/associated_data.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

const String nahpuBackupDir = 'backup';
const String nahpuAppDir = 'nahpu';
const String appMediaDirName = 'appMedia';
const String templateMediaDirName = 'template';
const String mediaDir = 'media';
const String associatedDataDir = 'associatedData';
const String associatedDataSitesDir = 'sites';
const String associatedDataEventsDir = 'events';
const String associatedDataSpecimensDir = 'specimens';
const String nahpuTempDir = 'NahpuTemp';
const String nahpuTempExportDirName = 'exports';
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

typedef SelectDirPathCallback = Future<String?> Function();

/// Asks the platform for a folder, and returns its path.
///
/// Mobile goes through `file_picker`. Its Android implementation opens the
/// Storage Access Framework tree picker and resolves the picked tree to a real
/// filesystem path, covering the Downloads provider and removable volumes that
/// `file_selector` rejects outright. Desktop stays on `file_selector`, which
/// already hands back a plain path.
Future<String?> _defaultSelectDirPath() {
  return Platform.isIOS || Platform.isAndroid
      ? FilePicker.getDirectoryPath()
      : getDirectoryPath();
}

class FilePickerServices {
  factory FilePickerServices({
    OpenFilesCallback openFiles = _defaultOpenFiles,
    SelectDirPathCallback selectDirPath = _defaultSelectDirPath,
  }) {
    return FilePickerServices._(openFiles, selectDirPath);
  }

  FilePickerServices._(this._openFiles, this._selectDirPath);

  final OpenFilesCallback _openFiles;
  final SelectDirPathCallback _selectDirPath;

  Future<void> shareFile(BuildContext context, File file) async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  /// Largest export that can go through the system "Save to..." dialog.
  ///
  /// [FilePicker.saveFile] takes the whole file as a `Uint8List` and copies it
  /// across the method channel, so peak usage is roughly twice the file size.
  /// Above this the directory picker is the right path: it streams to disk.
  static const int maxSaveCopyBytes = 100 * 1024 * 1024;

  /// Whether [saveCopyToDevice] can handle [file].
  bool canSaveCopyOf(File file) {
    if (!file.existsSync()) return false;
    return file.lengthSync() <= maxSaveCopyBytes;
  }

  /// Whether [file] is too big for [saveCopyToDevice], as opposed to simply
  /// not being there.
  ///
  /// The distinction matters to the UI: only a file that exists and is over
  /// the limit has earned an explanation of why the action is missing.
  bool exceedsSaveCopyLimit(File file) {
    if (!file.existsSync()) return false;
    return file.lengthSync() > maxSaveCopyBytes;
  }

  /// Opens the system "Save to..." dialog so the user can put a copy of [file]
  /// wherever they like.
  ///
  /// This is how Android reaches the Files app. Its share sheet is
  /// `ACTION_SEND`, which only lists apps that accept a file, so sharing alone
  /// leaves an export the user cannot file away; the save dialog is
  /// `ACTION_CREATE_DOCUMENT`, and writes through the content resolver rather
  /// than a raw path, so scoped storage never rejects it.
  ///
  /// Returns false when the user cancels.
  Future<bool> saveCopyToDevice(File file) async {
    final saved = await FilePicker.saveFile(
      fileName: path.basename(file.path),
      bytes: await file.readAsBytes(),
      mimeType: lookupMimeType(file.path) ?? 'application/octet-stream',
    );
    return saved != null;
  }

  /// Opens the folder a saved file went into, in the system file browser.
  ///
  /// Telling a desktop user the path is not the same as getting them to the
  /// file, and every platform names this action differently.
  Future<void> openContainingDirectory(File file) async {
    final uri = Uri.file(path.dirname(file.path), windows: Platform.isWindows);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw FormatException('Could not open $uri');
    }
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

  /// Lets the user pick a destination folder on every platform.
  Future<Directory?> selectDir() async {
    final result = await _selectDirPath();
    if (result == null) {
      return null;
    }
    if (kDebugMode) {
      print('Selected directory: $result');
    }
    return _isOpenablePath(result) ? Directory(result) : null;
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

  /// Whether [candidate] is something `dart:io` can actually open.
  ///
  /// Android answers with a Storage Access Framework tree URI when the picked
  /// folder has no filesystem path. Wrapping one in a [Directory] only defers
  /// the failure to the first write, so treat it as no selection instead.
  bool _isOpenablePath(String candidate) => !candidate.startsWith('content://');
}

class AppIOServices {
  AppIOServices({required this.dir, required this.fileStem, required this.ext});

  final Directory? dir;
  final String fileStem;
  final String ext;

  Future<File> getSavePath() async {
    String fileName = _fileName(fileStem);
    // Check if file exists
    File file = await _createSavePath(fileName);
    if (file.existsSync()) {
      int i = 1;
      while (file.existsSync()) {
        fileName = _fileName('$fileStem($i)');
        file = await _createSavePath(fileName);
        i++;
      }
    }
    return file;
  }

  String _fileName(String stem) => ext.isEmpty ? stem : '$stem.$ext';

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

  Future<Directory> get tempDirectory => nahpuTemporaryDir;

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
    return getUserFontDirectory();
  }

  Future<Directory> get userMapDir async {
    return getUserMapDirectory();
  }

  Future<Directory> get templateMediaDir async {
    return getTemplateMediaDirectory();
  }
}

Future<Directory> getUserFontDirectory() async {
  final documentDir = await nahpuDocumentDir;
  final userFontDir = Directory(
    path.join(documentDir.path, userConfigDirName, userFontDirName),
  );
  await userFontDir.create(recursive: true);
  return userFontDir;
}

Future<Directory> getUserMapDirectory() async {
  final documentDir = await nahpuDocumentDir;
  final userMapDir = Directory(
    path.join(documentDir.path, userConfigDirName, userMapDirName),
  );
  await userMapDir.create(recursive: true);
  return userMapDir;
}

Future<Directory> getTemplateMediaDirectory() async {
  final documentDir = await nahpuDocumentDir;
  final templateMediaDir = Directory(
    path.join(documentDir.path, appMediaDirName, templateMediaDirName),
  );
  await templateMediaDir.create(recursive: true);
  return templateMediaDir;
}

/// `<system temp>/NahpuTemp/`, created on demand.
///
/// Free-standing twin of [AppServices.tempDirectory], for services that have
/// no [WidgetRef].
Future<Directory> get nahpuTemporaryDir async {
  final tempDir = await getTemporaryDirectory();
  final nahpuTemp = Directory(path.join(tempDir.path, nahpuTempDir));
  await nahpuTemp.create(recursive: true);
  return nahpuTemp;
}

Future<Directory> get nahpuDocumentDir async {
  final dbDir = await getApplicationDocumentsDirectory();
  final nahpuDir = Directory(path.join(dbDir.path, nahpuAppDir));
  await nahpuDir.create(recursive: true);
  return nahpuDir;
}
