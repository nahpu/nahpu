part of '../document_writer.dart';

class _DocumentLayoutRecordCollector {
  const _DocumentLayoutRecordCollector({required this.ref, required this.db});

  final WidgetRef ref;
  final Database db;

  Future<List<Map<String, String>>> getRecordDataListForBlock(
    int bIdx,
    RecordType recordType,
    bool isPreview,
    List<String>? previewRecords,
  ) async {
    final Set<String> selectedIds;
    if (isPreview) {
      selectedIds = (previewRecords ?? const []).toSet();
    } else {
      final param =
          BlockRecordSelectionParam(blockIndex: bIdx, recordType: recordType);
      selectedIds = ref.read(blockRecordSelectionProvider(param));
    }

    final List<Map<String, String>> out = [];

    if (recordType == RecordType.specimenRecord) {
      final specimens = await SpecimenServices(ref: ref).getSpecimenList();
      final filtered = specimens.where((s) => selectedIds.contains(s.uuid));
      for (final s in filtered) {
        out.add(await documentFieldValuesForSpecimen(db, s, ref));
      }
    } else if (recordType == RecordType.site) {
      final sites = await SiteServices(ref: ref).getAllSites();
      final filtered =
          sites.where((s) => selectedIds.contains(s.id.toString()));
      for (final s in filtered) {
        out.add(await documentFieldValuesForSite(db, s, ref));
      }
    } else if (recordType == RecordType.collEvent) {
      final events = await CollEventServices(ref: ref).getAllCollEvents();
      final filtered =
          events.where((s) => selectedIds.contains(s.id.toString()));
      for (final s in filtered) {
        out.add(await documentFieldValuesForCollEvent(db, s, ref));
      }
    } else if (recordType == RecordType.narrative) {
      final narratives = await NarrativeServices(ref: ref).getAllNarrative();
      final filtered =
          narratives.where((s) => selectedIds.contains(s.id.toString()));
      for (final s in filtered) {
        out.add(await documentFieldValuesForNarrative(db, s, ref));
      }
    }

    return out;
  }
}
