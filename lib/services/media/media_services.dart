import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/projects/personnel_services.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/media.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:drift/drift.dart' as db;
import 'package:path/path.dart' as path;

class MediaServices extends AppServices {
  const MediaServices({required super.ref});

  Future<int> createMedia(MediaCompanion form) {
    return MediaDbQuery(dbAccess).createMedia(form);
  }

  Future<void> updateMedia(
    int mediaID,
    String category,
    MediaCompanion form,
  ) async {
    await MediaDbQuery(dbAccess).updateMedia(mediaID, form);
    MediaCategory mediaCategory = matchMediaCategoryString(category);
    _invalidateMedia(mediaCategory);
  }

  Future<MediaData> getMediaById(int primaryId) async {
    return await MediaDbQuery(dbAccess).getMedia(primaryId);
  }

  Future<bool> isMediaUsed(File file) async {
    final String fileName = path.basename(file.path);
    return await MediaDbQuery(dbAccess).isMediaUsed(fileName);
  }

  Future<List<MediaData>> getAllMedia() {
    return MediaDbQuery(dbAccess).getAllMedia();
  }

  Future<List<MediaData>> getAllMediaByProject() {
    return MediaDbQuery(dbAccess).getMediaByProject(currentProjectUuid);
  }

  Future<void> renameMedia(
    int mediaID,
    String oldName,
    String newName,
    MediaCategory category,
  ) async {
    if (oldName == newName || newName.isEmpty) {
      return;
    }
    File oldPath = await ImageServices(
      ref: ref,
      category: category,
    ).getMediaPath(oldName);
    if (!oldPath.existsSync()) {
      throw Exception('File not found');
    }

    String ext = path.extension(oldPath.path);
    newName = newName.contains(' ') ? newName.replaceAll(' ', '_') : newName;
    String finalName = newName + ext;
    File newPath = await ImageServices(
      ref: ref,
      category: category,
    ).getMediaPath(finalName);
    if (newPath.existsSync()) {
      throw Exception('File exists');
    }
    try {
      await oldPath.rename(newPath.path);
      await MediaDbQuery(
        dbAccess,
      ).updateMedia(mediaID, MediaCompanion(fileName: db.Value(finalName)));
    } catch (e) {
      throw Exception('Failed to rename file');
    }

    _invalidateMedia(category);
  }

  Future<void> updateMediaDetails({
    required MediaData media,
    required String fileName,
    required String caption,
    required String tag,
    required String? personnelId,
  }) async {
    final category = matchMediaCategoryString(media.category ?? '');
    final oldName = media.fileName ?? '';
    var normalizedName = fileName.trim().replaceAll(' ', '_');
    if (normalizedName.isEmpty) {
      throw Exception('File name cannot be empty');
    }
    if (path.basename(normalizedName) != normalizedName) {
      throw Exception('File name cannot contain a path');
    }

    final extension = path.extension(oldName);
    if (normalizedName.toLowerCase().endsWith(extension.toLowerCase())) {
      normalizedName = path.basenameWithoutExtension(normalizedName);
    }
    final finalName = '$normalizedName$extension';
    File? oldPath;
    File? newPath;
    var renamed = false;
    if (finalName != oldName) {
      oldPath = await ImageServices(
        ref: ref,
        category: category,
      ).getMediaPath(oldName);
      if (!await oldPath.exists()) {
        throw Exception('File not found');
      }
      newPath = await ImageServices(
        ref: ref,
        category: category,
      ).getMediaPath(finalName);
      if (await newPath.exists()) {
        throw Exception('File exists');
      }
      await oldPath.rename(newPath.path);
      renamed = true;
    }

    try {
      await MediaDbQuery(dbAccess).updateMedia(
        media.primaryId,
        MediaCompanion(
          fileName: db.Value(finalName),
          caption: db.Value(caption.trim().isEmpty ? null : caption.trim()),
          tag: db.Value(tag.trim().isEmpty ? null : tag.trim()),
          personnelId: db.Value(personnelId),
        ),
      );
    } catch (_) {
      if (renamed &&
          newPath != null &&
          oldPath != null &&
          await newPath.exists()) {
        await newPath.rename(oldPath.path);
      }
      rethrow;
    }
    _invalidateMedia(category);
  }

  Future<void> deleteMedia(int id, String category) async {
    final media = await MediaDbQuery(dbAccess).getMedia(id);
    await deleteMediaItems([_withCategoryFallback(media, category)]);
  }

  Future<void> deleteMediaFromList(List<int> ids, String category) async {
    if (ids.isEmpty) return;
    final query = MediaDbQuery(dbAccess);
    final media = <MediaData>[];
    for (final id in ids.toSet()) {
      media.add(_withCategoryFallback(await query.getMedia(id), category));
    }
    await deleteMediaItems(media);
  }

  Future<void> deleteMediaItems(Iterable<MediaData> items) async {
    final mediaById = <int, MediaData>{
      for (final item in items) item.primaryId: item,
    };
    if (mediaById.isEmpty) return;

    final filesByPath = <String, File>{};
    for (final media in mediaById.values) {
      final fileName = media.fileName;
      if (fileName == null || fileName.isEmpty) continue;
      final category = matchMediaCategoryString(media.category ?? '');
      final file = await MediaFinder(
        ref: ref,
      ).getPathForMedia(fileName, category);
      filesByPath[file.path] = file;
    }

    final query = MediaDbQuery(dbAccess);
    await dbAccess.transaction(() async {
      for (final media in mediaById.values) {
        await query.deleteMediaReferences(media.primaryId);
        await query.deleteMedia(media.primaryId);
      }
    });

    final failedPaths = <String>[];
    for (final file in filesByPath.values) {
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {
        failedPaths.add(file.path);
      }
    }
    _invalidateAllMedia();
    if (failedPaths.isNotEmpty) {
      throw MediaFileDeletionException(failedPaths);
    }
  }

  void _invalidateMedia(MediaCategory category) {
    ref.invalidate(projectMediaProvider);
    switch (category) {
      case MediaCategory.narrative:
        ref.invalidate(narrativeMediaProvider);
        break;
      case MediaCategory.event:
        ref.invalidate(eventMediaProvider);
        break;
      case MediaCategory.site:
        ref.invalidate(siteMediaProvider);
        break;
      case MediaCategory.specimen:
        ref.invalidate(specimenMediaProvider);
        break;
      default:
        break;
    }
  }

  void _invalidateAllMedia() {
    ref.invalidate(projectMediaProvider);
    ref.invalidate(narrativeMediaProvider);
    ref.invalidate(eventMediaProvider);
    ref.invalidate(siteMediaProvider);
    ref.invalidate(specimenMediaProvider);
    ref.invalidate(taxonRegistryProvider);
    ref.invalidate(taxonProvider);
    ref.invalidate(taxonDataProvider);
  }

  MediaData _withCategoryFallback(MediaData media, String category) {
    if (media.category?.isNotEmpty ?? false) return media;
    return media.copyWith(category: db.Value(category));
  }
}

class MediaFileDeletionException implements Exception {
  const MediaFileDeletionException(this.paths);

  final List<String> paths;

  @override
  String toString() {
    final count = paths.length;
    return 'Media records were deleted, but $count media '
        '${count == 1 ? 'file' : 'files'} could not be removed from disk.';
  }
}

class MediaFinder extends AppServices {
  const MediaFinder({required super.ref});

  Future<List<File>> getAllMedia() async {
    final List<MediaData> mediaList = await MediaServices(
      ref: ref,
    ).getAllMedia();
    final mediaPath = await _getAllPathForMedia(mediaList);

    final personnelPath = await getAllPersonnelMedia();
    if (kDebugMode) {
      print('Found ${mediaPath.length} media files');
      print('Found ${personnelPath.length} personnel files');
    }
    return [...mediaPath, ...personnelPath];
  }

  Future<List<File>> getAllPersonnelMedia() async {
    List<PersonnelData> personnelList = await PersonnelServices(
      ref: ref,
    ).getAllPersonnel();
    final List<File> mediaPaths = [];
    for (final personnel in personnelList) {
      if (personnel.photoPath != null &&
          !personnel.photoPath!.startsWith(avatarPath)) {
        final mediaPath = await getPathForPersonnel(
          personnel.photoPath!,
          MediaCategory.personnel,
        );
        _checkPath(mediaPath);
        mediaPaths.add(mediaPath);
      }
    }
    return mediaPaths;
  }

  Future<List<File>> getAllPersonnelMediaByProject() async {
    List<PersonnelData> personnelList = await PersonnelServices(
      ref: ref,
    ).getPersonnelByProjectUuid(currentProjectUuid);
    final List<File> mediaPaths = [];
    for (final personnel in personnelList) {
      if (personnel.photoPath != null &&
          !personnel.photoPath!.startsWith(avatarPath)) {
        final mediaPath = await getPathForPersonnel(
          personnel.photoPath!,
          MediaCategory.personnel,
        );
        _checkPath(mediaPath);
        mediaPaths.add(mediaPath);
      }
    }
    return mediaPaths;
  }

  Future<List<File>> getAllMediaFileByProject() async {
    final List<MediaData> mediaData = await MediaServices(
      ref: ref,
    ).getAllMediaByProject();
    final mediaPaths = await _getAllPathForMedia(mediaData);
    final personnelPaths = await getAllPersonnelMediaByProject();
    return mediaPaths + personnelPaths;
  }

  Future<File> getPathForMedia(String filePath, MediaCategory category) async {
    Directory projectDir = await FileServices(ref: ref).currentProjectDir;
    return _getMediaPath(projectDir, filePath, category);
  }

  Future<File> getPathForPersonnel(
    String filePath,
    MediaCategory category,
  ) async {
    Directory mediaDir = getMediaDir(category);
    Directory appDir = await nahpuDocumentDir;
    String fullPath = path.join(appDir.path, mediaDir.path, filePath);
    return File(fullPath);
  }

  Future<List<File>> _getAllPathForMedia(List<MediaData> data) async {
    final List<File> mediaPaths = [];
    for (final media in data) {
      if (media.fileName != null && media.category != null) {
        final category = matchMediaCategoryString(media.category!);
        Directory projectDir = await FileServices(
          ref: ref,
        ).getProjectDirByUUID(media.projectUuid!);
        File mediaPath = _getMediaPath(projectDir, media.fileName!, category);
        if (kDebugMode) print(mediaPath.path);
        if (_checkPath(mediaPath)) {
          mediaPaths.add(mediaPath);
        } else {
          if (kDebugMode) {
            print('Media file not found: ${media.fileName}');
          }
        }
        // mediaPaths.add(mediaPath);
      }
    }
    return mediaPaths;
  }

  File _getMediaPath(
    Directory projectDir,
    String filePath,
    MediaCategory category,
  ) {
    Directory mediaDir = getMediaDir(category);
    String fullPath = path.join(projectDir.path, mediaDir.path, filePath);
    return File(fullPath);
  }

  bool _checkPath(File file) {
    return file.existsSync();
    // if (!file.existsSync()) {
    //   throw Exception('File not found ${file.path}. Please, check the file');
    // }
  }
}
