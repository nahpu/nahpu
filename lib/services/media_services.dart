import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/narrative_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/personnel_services.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:drift/drift.dart' as db;
import 'package:path/path.dart' as path;

class MediaServices extends AppServices {
  const MediaServices({required super.ref});

  Future<int> createMedia(MediaCompanion form) {
    return MediaDbQuery(dbAccess).createMedia(form);
  }

  Future<void> updateMedia(
      int mediaID, String category, MediaCompanion form) async {
    await MediaDbQuery(dbAccess).updateMedia(mediaID, form);
    MediaCategory mediaCategory = matchMediaCategoryString(category);
    _invalidateMedia(mediaCategory);
  }

  Future<MediaData> getMediaById(int primaryId) async {
    return await MediaDbQuery(dbAccess).getMedia(primaryId);
  }

  Future<bool> isImageUsed(File file) async {
    final String fileName = path.basename(file.path);
    return await MediaDbQuery(dbAccess).isImageUsed(fileName);
  }

  Future<List<MediaData>> getAllMedia() {
    return MediaDbQuery(dbAccess).getAllMedia();
  }

  Future<List<MediaData>> getAllMediaByProject() {
    return MediaDbQuery(dbAccess).getMediaByProject(currentProjectUuid);
  }

  Future<void> renameMedia(int mediaID, String oldName, String newName,
      MediaCategory category) async {
    if (oldName == newName || newName.isEmpty) {
      return;
    }
    File oldPath =
        await ImageServices(ref: ref, category: category).getMediaPath(oldName);
    if (!oldPath.existsSync()) {
      throw Exception('File not found');
    }

    String ext = path.extension(oldPath.path);
    newName = newName.contains(' ') ? newName.replaceAll(' ', '_') : newName;
    String finalName = newName + ext;
    File newPath = await ImageServices(ref: ref, category: category)
        .getMediaPath(finalName);
    if (newPath.existsSync()) {
      throw Exception('File exists');
    }
    try {
      await oldPath.rename(newPath.path);
      await MediaDbQuery(dbAccess).updateMedia(
          mediaID,
          MediaCompanion(
            fileName: db.Value(finalName),
          ));
    } catch (e) {
      throw Exception('Failed to rename file');
    }

    _invalidateMedia(category);
  }

  Future<void> deleteMedia(int id, String category) async {
    MediaCategory mediaCategory = matchMediaCategoryString(category);
    await _deleteMatchingCategory(id, mediaCategory);
    await MediaDbQuery(dbAccess).deleteMedia(id);
  }

  Future<void> _deleteMatchingCategory(int id, MediaCategory category) async {
    switch (category) {
      case MediaCategory.narrative:
        await NarrativeQuery(dbAccess).deleteNarrativeMedia(id);

        break;
      case MediaCategory.site:
        await SiteQuery(dbAccess).deleteSiteMedia(id);
        break;
      case MediaCategory.specimen:
        await SpecimenQuery(dbAccess).deleteSpecimenMedia(id);
        break;
      case MediaCategory.personnel:
        break;
      default:
        break;
    }
    _invalidateMedia(category);
  }

  void _invalidateMedia(MediaCategory category) {
    switch (category) {
      case MediaCategory.narrative:
        ref.invalidate(narrativeMediaProvider);
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
}

class MediaFinder extends AppServices {
  const MediaFinder({required super.ref});

  Future<List<File>> getAllMedia() async {
    final List<MediaData> mediaList =
        await MediaServices(ref: ref).getAllMedia();
    final mediaPath = await _getAllPathForMedia(mediaList);

    final personnelPath = await getAllPersonnelMedia();
    if (kDebugMode) {
      print('Found ${mediaPath.length} media files');
      print('Found ${personnelPath.length} personnel files');
    }
    return [
      ...mediaPath,
      ...personnelPath,
    ];
  }

  Future<List<File>> getAllPersonnelMedia() async {
    List<PersonnelData> personnelList =
        await PersonnelServices(ref: ref).getAllPersonnel();
    final List<File> mediaPaths = [];
    for (final personnel in personnelList) {
      if (personnel.photoPath != null &&
          !personnel.photoPath!.startsWith(avatarPath)) {
        final mediaPath = await getPathForPersonnel(
            personnel.photoPath!, MediaCategory.personnel);
        _checkPath(mediaPath);
        mediaPaths.add(mediaPath);
      }
    }
    return mediaPaths;
  }

  Future<List<File>> getAllMediaFileByProject() async {
    final List<MediaData> mediaData =
        await MediaServices(ref: ref).getAllMediaByProject();
    final mediaPaths = await _getAllPathForMedia(mediaData);
    final personnelPaths = await getAllPersonnelMedia();
    return mediaPaths + personnelPaths;
  }

  Future<File> getPathForMedia(String filePath, MediaCategory category) async {
    Directory projectDir = await FileServices(ref: ref).currentProjectDir;
    return _getMediaPath(projectDir, filePath, category);
  }

  Future<File> getPathForPersonnel(
      String filePath, MediaCategory category) async {
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
        Directory projectDir = await FileServices(ref: ref)
            .getProjectDirByUUID(media.projectUuid!);
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
      Directory projectDir, String filePath, MediaCategory category) {
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
