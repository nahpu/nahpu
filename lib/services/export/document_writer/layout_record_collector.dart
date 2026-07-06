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
    } else if (recordType == RecordType.none) {
      final Map<String, String> m = {};
      final projectUuid = ref.read(projectUuidProvider);
      if (projectUuid.isNotEmpty) {
        try {
          final proj =
              await ProjectServices(ref: ref).getProjectByUuid(projectUuid);
          for (var entry in proj.toJson().entries) {
            m['project::${entry.key}'] = entry.value?.toString() ?? '';
          }
        } catch (_) {}

        try {
          final personnel = await PersonnelServices(ref: ref)
              .getPersonnelByProjectUuid(projectUuid);
          if (personnel.isNotEmpty) {
            final Set<String> keys = {};
            final List<Map<String, dynamic>> jsonList =
                personnel.map((p) => p.toJson()).toList();
            for (final json in jsonList) {
              keys.addAll(json.keys);
            }
            for (final key in keys) {
              final joined = jsonList
                  .map((json) => json[key]?.toString() ?? '')
                  .where((v) => v.isNotEmpty)
                  .join(' | ');
              m['personnel::$key'] = joined;
            }
          }
        } catch (_) {}
      }

      // Apply fallback values for preview
      m.putIfAbsent('project::name', () => 'Active Project');
      m.putIfAbsent('project::uuid', () => 'active-project-uuid');
      m.putIfAbsent('project::description', () => 'Active Project Description');
      m.putIfAbsent('project::principalInvestigator', () => 'Active Investigator');
      m.putIfAbsent('project::location', () => 'Active Project Location');
      m.putIfAbsent('project::timeZone', () => 'UTC');
      m.putIfAbsent('project::startDate', () => '2026-01-01');
      m.putIfAbsent('project::endDate', () => '2026-12-31');

      m.putIfAbsent('personnel::name', () => 'Active Personnel');
      m.putIfAbsent('personnel::role', () => 'Active Personnel Role');
      m.putIfAbsent('personnel::initial', () => 'AP');
      m.putIfAbsent('personnel::email', () => 'active@example.com');
      m.putIfAbsent('personnel::affiliation', () => 'Active Affiliation');

      out.add(m);
    }

    return out;
  }
}
