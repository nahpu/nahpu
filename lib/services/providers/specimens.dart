import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/record_sort.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/record_sort.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/database/parasite_queries.dart';

final specimenEntryProvider =
    AsyncNotifierProvider.autoDispose<SpecimenEntry, List<SpecimenData>>(
      SpecimenEntry.new,
    );

class SpecimenEntry extends AsyncNotifier<List<SpecimenData>> {
  Future<List<SpecimenData>> _fetchSpecimenEntry() async {
    final projectUuid = ref.watch(projectUuidProvider);
    // Watched, not read: changing the sort has to refetch the list.
    final sort = ref.watch(recordSortProvider(RecordViewer.specimen));
    // Which column the field-id sort reads follows the active mode. Resolved
    // only for that sort: the mode lives in the Rust config store, and every
    // other ordering would pay for a round trip it never reads.
    final fieldIdMode = sort.field == RecordSortField.fieldId
        ? await ref.watch(fieldIdModeNotifierProvider.future)
        : FieldIdMode.personnel;

    final specimenEntries = await SpecimenQuery(
      ref.read(databaseProvider),
    ).getAllSpecimens(projectUuid, sort: sort, fieldIdMode: fieldIdMode);

    return specimenEntries;
  }

  @override
  FutureOr<List<SpecimenData>> build() async {
    return await _fetchSpecimenEntry();
  }
}

final fossilAttributeProvider = FutureProvider.autoDispose
    .family<FossilAttributeData?, String>((ref, specimenUuid) {
      return FossilSpecimenQuery(
        ref.watch(databaseProvider),
      ).getByUuid(specimenUuid);
    });

final partBySpecimenProvider = FutureProvider.family
    .autoDispose<List<SpecimenPartData>, String>(
      (ref, specimenUuid) => SpecimenPartQuery(
        ref.read(databaseProvider),
      ).getSpecimenParts(specimenUuid),
    );

final parasiteDetectionProvider = FutureProvider.family
    .autoDispose<ParasiteDetectionData?, String>(
      (ref, specimenUuid) =>
          ParasiteQuery(ref.read(databaseProvider)).getDetection(specimenUuid),
    );

final parasiteBySpecimenProvider = FutureProvider.family
    .autoDispose<List<ParasiteData>, String>(
      (ref, specimenUuid) =>
          ParasiteQuery(ref.read(databaseProvider)).getParasites(specimenUuid),
    );

/// All printable parts in the active project, paired with their parent
/// specimen. A part, not a specimen, is the document-record unit.
final specimenPartEntryProvider =
    FutureProvider.autoDispose<List<SpecimenPartProjectRecord>>((ref) async {
      final projectUuid = ref.watch(projectUuidProvider);
      return SpecimenPartQuery(
        ref.read(databaseProvider),
      ).getSpecimenPartsForProject(projectUuid);
    });

final specimenMediaProvider = FutureProvider.family
    .autoDispose<List<MediaData>, String>((ref, specimenUuid) async {
      final database = ref.read(databaseProvider);
      List<SpecimenMediaData> mediaList = await SpecimenQuery(
        database,
      ).getSpecimenMedia(specimenUuid);
      List<MediaData> mediaDataList = [];
      for (SpecimenMediaData media in mediaList) {
        if (media.mediaId != null) {
          mediaDataList.add(
            await MediaDbQuery(database).getMedia(media.mediaId!),
          );
        }
      }
      return mediaDataList;
    });
