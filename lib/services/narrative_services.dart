import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/narrative_queries.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:path/path.dart';

class NarrativeServices extends AppServices {
  const NarrativeServices({required super.ref});

  Future<int> createNewNarrative() async {
    int narrativeID =
        await NarrativeQuery(dbAccess).createNarrative(NarrativeCompanion(
      projectUuid: db.Value(currentProjectUuid),
    ));
    invalidateNarrative();
    return narrativeID;
  }

  Future<List<NarrativeData>> getAllNarrative() async {
    return await NarrativeQuery(dbAccess).getAllNarrative(currentProjectUuid);
  }

  Future<NarrativeData> getNarrative(int narrativeId) async {
    return await NarrativeQuery(dbAccess).getNarrativeById(narrativeId);
  }

  Future<void> updateNarrative(int id, NarrativeCompanion entries) async {
    try {
      await NarrativeQuery(dbAccess).updateNarrativeEntry(id, entries);
    } catch (e) {
      // Handle missing column errors for older DBs by attempting to add the
      // column and retrying the update. Query the table info first to avoid
      // duplicate ALTER TABLE attempts when multiple callers race.
      final msg = e.toString();
      if (msg.contains('no such column')) {
        try {
          // Check whether the 'time' column already exists to avoid duplicate
          // ALTER TABLE statements from concurrent callers.
          final List<db.QueryRow> rows =
              await dbAccess.customSelect("PRAGMA table_info('narrative')").get();
          bool hasTime = false;
          for (final row in rows) {
            try {
              final colName = row.read<String>('name');
              if (colName == 'time') {
                hasTime = true;
                break;
              }
            } catch (_) {
              // ignore read failures for unexpected rows
            }
          }

          if (!hasTime) {
            await dbAccess.customStatement('ALTER TABLE narrative ADD COLUMN time TEXT');
          }

          await NarrativeQuery(dbAccess).updateNarrativeEntry(id, entries);
        } catch (e2) {
          // If this still fails (for example due to race conditions), log in
          // debug builds but don't crash the app.
          if (kDebugMode) {
            print('Failed to add narrative.time column during update: $e2');
          }
        }
      } else {
        if (kDebugMode) {
          print('Failed to update narrative entry: $e');
        }
      }
    } finally {
      // Refresh narrative provider so UI reflects persisted change
      ref.invalidate(narrativeEntryProvider);
    }
  }

  /// Update the writer for a narrative.
  Future<void> updateNarrativeWriter(int id, String? writerUuid) async {
    await NarrativeQuery(dbAccess).updateNarrativeWriter(id, writerUuid);
    // Refresh narrative provider so UI reflects persisted change
    ref.invalidate(narrativeEntryProvider);
  }

  Future<void> createNarrativeMediaFromList(
      int narrativeId, List<String> filePaths) async {
    for (String filePath in filePaths) {
      await createNarrativeMedia(narrativeId, filePath);
    }
  }

  Future<void> createNarrativeMedia(int narrativeId, String filePath) async {
    ExifData exifData = ExifData.empty();
    await exifData.readExif(File(filePath));
    int mediaId = await MediaDbQuery(dbAccess).createMedia(MediaCompanion(
      projectUuid: db.Value(currentProjectUuid),
      fileName: db.Value(basename(filePath)),
      category: db.Value(matchMediaCategory(MediaCategory.narrative)),
      taken: db.Value(exifData.dateTaken),
      camera: db.Value(exifData.camera),
      lenses: db.Value(exifData.lenseModel),
      additionalExif: db.Value(exifData.additionalExif),
    ));
    NarrativeMediaCompanion entries = NarrativeMediaCompanion(
      narrativeId: db.Value(narrativeId),
      mediaId: db.Value(mediaId),
    );
    await NarrativeQuery(dbAccess).createNarrativeMedia(entries);
    ref.invalidate(narrativeMediaProvider);
  }

  Future<List<NarrativeMediaData>> getNarrativeMedia(int narrativeId) async {
    return NarrativeQuery(dbAccess).getNarrativeMedia(narrativeId);
  }

  Future<NarrativeMediaData> getNarrativeMediaByMediaId(int id) async {
    return await NarrativeQuery(dbAccess).getNarrativeMediaById(id);
  }

  Future<void> deleteNarrative(int id) async {
    deleteAllNarrativeMedia(id);
    await NarrativeQuery(dbAccess).deleteNarrative(id);
    invalidateNarrative();
  }

  Future<void> deleteAllNarrativeMedia(int narrativeId) async {
    await NarrativeQuery(dbAccess).deleteAllNarrativeMedia(narrativeId);
  }

  Future<void> deleteAllNarrative(String projectUuid) async {
    List<NarrativeData> narratives =
        await NarrativeQuery(dbAccess).getAllNarrative(projectUuid);
    for (NarrativeData narrative in narratives) {
      await deleteAllNarrativeMedia(narrative.id);
    }
    NarrativeQuery(dbAccess).deleteAllNarrative(projectUuid);
    invalidateNarrative();
  }

  void invalidateNarrative() {
    ref.invalidate(narrativeEntryProvider);
  }
}

class NarrativeSearchServices {
  NarrativeSearchServices({required this.narrativeEntries});

  final List<NarrativeData> narrativeEntries;

  List<NarrativeData> search(String query) {
    List<NarrativeData> filteredNarratives = narrativeEntries
        .where((element) => _isMatch(element.narrative, query))
        .toList();
    return filteredNarratives;
  }

  bool _isMatch(String? value, String query) {
    if (value == null) return false;
    return value.toLowerCase().contains(query);
  }
}
