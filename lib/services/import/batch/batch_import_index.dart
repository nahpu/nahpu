import 'package:drift/drift.dart';
import 'package:nahpu/services/data_table/data_table_save_service.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/narrative_queries.dart';
import 'package:nahpu/services/database/personnel_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/taxonomy_queries.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';

/// A specimen as a batch import identifies it.
class BatchSpecimenRef {
  const BatchSpecimenRef({
    required this.uuid,
    required this.catalogNumber,
    this.catalogerUuid,
    this.fieldNumber,
    this.attributeTable,
  });

  final String uuid;

  /// The catalog number as labels show it, normalized with
  /// [normalizeBatchId].
  final String catalogNumber;
  final String? catalogerUuid;
  final int? fieldNumber;

  /// The table holding its measurements, such as `birdAttribute`.
  final String? attributeTable;
}

/// A person a row can name, by name or initials.
class BatchPersonRef {
  const BatchPersonRef({required this.uuid, this.name, this.initial});

  final String uuid;
  final String? name;
  final String? initial;
}

/// The open project's records a batch import matches rows against, read
/// once before the review.
class BatchImportIndex {
  const BatchImportIndex({
    this.specimens = const [],
    this.people = const [],
    this.taxa = const [],
    this.sites = const {},
    this.events = const {},
    this.tissueIds = const {},
    this.barcodeIds = const {},
    this.narrativeDates = const {},
  });

  final List<BatchSpecimenRef> specimens;
  final List<BatchPersonRef> people;
  final List<TaxonomyData> taxa;

  /// Row ids by normalized ID or date.
  final Map<String, List<int>> sites;
  final Map<String, List<int>> events;
  final Map<String, List<int>> tissueIds;
  final Map<String, List<int>> barcodeIds;
  final Map<String, List<int>> narrativeDates;

  static Future<BatchImportIndex> load(Database db, String projectUuid) async {
    final project = await (db.select(
      db.project,
    )..where((t) => t.uuid.equals(projectUuid))).getSingleOrNull();
    final specimenRows = await db
        .customSelect(
          'SELECT s.uuid, s.catalogerID, s.fieldNumber, s.projectFieldNumber, '
          's.taxonGroup, '
          'p.initial FROM specimen s '
          'LEFT JOIN personnel p ON p.uuid = s.catalogerID '
          'WHERE s.projectUuid = ?',
          variables: [Variable.withString(projectUuid)],
          readsFrom: const {},
        )
        .get();
    final specimens = [
      for (final row in specimenRows)
        BatchSpecimenRef(
          uuid: row.read<String>('uuid'),
          catalogerUuid: row.readNullable<String>('catalogerID'),
          fieldNumber: row.readNullable<int>('fieldNumber'),
          attributeTable: dataTableAttributeTableForGroup(
            row.readNullable<String>('taxonGroup'),
          ),
          catalogNumber: normalizeBatchId(
            formatSpecimenFieldId(
              catalogNumberPrefix: project?.catalogNumberPrefix,
              catalogNumberSuffix: project?.catalogNumberSuffix,
              catalogerInitial: row.readNullable<String>('initial'),
              fieldNumber: row.readNullable<int>('fieldNumber'),
              projectFieldNumber: row.readNullable<int>('projectFieldNumber'),
            ),
          ),
        ),
    ];

    final people = [
      for (final person in await PersonnelQuery(
        db,
      ).getPersonnelByProjectUuid(projectUuid))
        BatchPersonRef(
          uuid: person.uuid,
          name: person.name,
          initial: person.initial,
        ),
    ];

    final siteRecords = await SiteQuery(db).getAllSites(projectUuid);
    final sitesById = {for (final site in siteRecords) site.id: site};
    final events = await CollEventQuery(db).getAllCollEvents(projectUuid);
    final narratives = await NarrativeQuery(db).getAllNarrative(projectUuid);
    final parts = await db
        .customSelect(
          'SELECT sp.id, sp.tissueID, sp.barcodeID FROM specimenPart sp '
          'JOIN specimen s ON s.uuid = sp.specimenUuid '
          'WHERE s.projectUuid = ?',
          variables: [Variable.withString(projectUuid)],
          readsFrom: const {},
        )
        .get();

    return BatchImportIndex(
      specimens: specimens,
      people: people,
      taxa: await TaxonomyQuery(db).getTaxonList(),
      sites: _group([for (final site in siteRecords) (site.siteID, site.id)]),
      events: _group([
        for (final event in events)
          (formatCollEventId(event, sitesById[event.siteID]), event.id),
      ]),
      tissueIds: _group([
        for (final part in parts)
          (part.readNullable<String>('tissueID'), part.read<int>('id')),
      ]),
      barcodeIds: _group([
        for (final part in parts)
          (part.readNullable<String>('barcodeID'), part.read<int>('id')),
      ]),
      narrativeDates: _group([
        for (final narrative in narratives) (narrative.date, narrative.id),
      ]),
    );
  }

  static Map<String, List<int>> _group(List<(String?, int)> pairs) {
    final groups = <String, List<int>>{};
    for (final (id, key) in pairs) {
      final normalized = normalizeBatchId(id ?? '');
      if (normalized.isEmpty) continue;
      groups.putIfAbsent(normalized, () => []).add(key);
    }
    return groups;
  }
}

/// An identifier for comparison: lowercase, with spaces, dashes, and other
/// punctuation removed, so "ABC 12" and "abc-12" match.
String normalizeBatchId(String id) =>
    id.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
