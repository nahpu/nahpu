import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/narrative_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/types/record_sort.dart';
import 'package:nahpu/services/types/specimens.dart';

/// Covers the sort-aware `getAll*` queries behind the record viewers' "Sort
/// records" action: every offered field in both directions, blanks last in
/// both, and a total order so a refetch never reshuffles the pages.
void main() {
  const projectUuid = 'project-sort';

  late Database database;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await database
        .into(database.project)
        .insert(
          const ProjectCompanion(
            uuid: Value(projectUuid),
            name: Value('Sort project'),
          ),
        );
  });

  tearDown(() => database.close());

  RecordSort sortBy(
    RecordSortField field, [
    RecordSortDirection direction = RecordSortDirection.ascending,
  ]) => RecordSort(field: field, direction: direction);

  Future<int> insertSite({String? siteId, String? state, String? locality}) {
    return database
        .into(database.site)
        .insert(
          SiteCompanion(
            projectUuid: const Value(projectUuid),
            siteID: Value(siteId),
            stateProvince: Value(state),
            locality: Value(locality),
          ),
        );
  }

  group('sites', () {
    test('orders by site ID in both directions', () async {
      final c = await insertSite(siteId: 'C');
      final a = await insertSite(siteId: 'A');
      final b = await insertSite(siteId: 'B');
      final query = SiteQuery(database);

      final ascending = await query.getAllSites(
        projectUuid,
        sort: sortBy(RecordSortField.siteName),
      );
      expect(ascending.map((site) => site.id), [a, b, c]);

      final descending = await query.getAllSites(
        projectUuid,
        sort: sortBy(RecordSortField.siteName, RecordSortDirection.descending),
      );
      expect(descending.map((site) => site.id), [c, b, a]);
    });

    test('orders by state and locality', () async {
      final west = await insertSite(state: 'West Java', locality: 'Cibodas');
      final aceh = await insertSite(state: 'Aceh', locality: 'Ketambe');
      final query = SiteQuery(database);

      expect(
        (await query.getAllSites(
          projectUuid,
          sort: sortBy(RecordSortField.stateProvince),
        )).map((site) => site.id),
        [aceh, west],
      );
      expect(
        (await query.getAllSites(
          projectUuid,
          sort: sortBy(RecordSortField.locality),
        )).map((site) => site.id),
        [west, aceh],
      );
    });

    test('keeps blanks last in both directions', () async {
      final nullSite = await insertSite();
      final emptySite = await insertSite(siteId: '');
      final filled = await insertSite(siteId: 'A');
      final query = SiteQuery(database);

      // A blank is absence of data, not a value, so reversing the direction
      // must not float NULLs and empty strings to the top. Their order
      // relative to each other is unspecified — both are simply "blank".
      for (final direction in RecordSortDirection.values) {
        final sites = await query.getAllSites(
          projectUuid,
          sort: sortBy(RecordSortField.siteName, direction),
        );
        expect(sites.first.id, filled, reason: '$direction');
        expect(
          sites.map((site) => site.id).skip(1),
          unorderedEquals([nullSite, emptySite]),
          reason: '$direction',
        );
      }
    });

    test('breaks ties on id so refetching cannot reshuffle pages', () async {
      final first = await insertSite(siteId: 'Same');
      final second = await insertSite(siteId: 'Same');
      final third = await insertSite(siteId: 'Same');
      final query = SiteQuery(database);
      final sort = sortBy(
        RecordSortField.siteName,
        RecordSortDirection.descending,
      );

      final once = await query.getAllSites(projectUuid, sort: sort);
      final twice = await query.getAllSites(projectUuid, sort: sort);
      expect(once.map((site) => site.id), [first, second, third]);
      expect(twice.map((site) => site.id), once.map((site) => site.id));
    });

    test('the default keeps insertion order', () async {
      final first = await insertSite(siteId: 'Z');
      final second = await insertSite(siteId: 'A');
      expect(
        (await SiteQuery(database).getAllSites(projectUuid)).map((s) => s.id),
        [first, second],
      );
    });
  });

  group('collecting events', () {
    Future<int> insertEvent({int? siteId, String? startDate, String? suffix}) {
      return database
          .into(database.collEvent)
          .insert(
            CollEventCompanion(
              projectUuid: const Value(projectUuid),
              siteID: Value(siteId),
              startDate: Value(startDate),
              idSuffix: Value(suffix),
            ),
          );
    }

    test('orders by start date, ISO text sorting chronologically', () async {
      final later = await insertEvent(startDate: '2024-11-02');
      final earlier = await insertEvent(startDate: '2024-03-15');
      final query = CollEventQuery(database);

      expect(
        (await query.getAllCollEvents(
          projectUuid,
          sort: sortBy(RecordSortField.startDate),
        )).map((event) => event.id),
        [earlier, later],
      );
      expect(
        (await query.getAllCollEvents(
          projectUuid,
          sort: sortBy(
            RecordSortField.startDate,
            RecordSortDirection.descending,
          ),
        )).map((event) => event.id),
        [later, earlier],
      );
    });

    test('orders by event id components, site first', () async {
      final siteB = await insertSite(siteId: 'B');
      final siteA = await insertSite(siteId: 'A');
      final onB = await insertEvent(siteId: siteB, startDate: '2024-01-01');
      final onALate = await insertEvent(siteId: siteA, startDate: '2024-05-05');
      final onAEarly = await insertEvent(
        siteId: siteA,
        startDate: '2024-01-01',
      );

      // Site A's events come first, in date order, then site B's.
      expect(
        (await CollEventQuery(database).getAllCollEvents(
          projectUuid,
          sort: sortBy(RecordSortField.eventId),
        )).map((event) => event.id),
        [onAEarly, onALate, onB],
      );
    });

    test('keeps events whose site link is missing', () async {
      final orphan = await insertEvent(startDate: '2024-01-01');
      final linkedSite = await insertSite(siteId: 'A');
      final linked = await insertEvent(
        siteId: linkedSite,
        startDate: '2024-01-01',
      );

      // A left outer join must not drop the orphan; its blank site id sorts
      // last, the same as any other blank.
      expect(
        (await CollEventQuery(database).getAllCollEvents(
          projectUuid,
          sort: sortBy(RecordSortField.eventId),
        )).map((event) => event.id),
        [linked, orphan],
      );
    });
  });

  group('narratives', () {
    Future<String> insertPersonnel(String uuid, String? name) async {
      await database
          .into(database.personnel)
          .insert(PersonnelCompanion(uuid: Value(uuid), name: Value(name)));
      return uuid;
    }

    Future<int> insertNarrative({String? date, int? siteId, String? writerId}) {
      return database
          .into(database.narrative)
          .insert(
            NarrativeCompanion(
              projectUuid: const Value(projectUuid),
              date: Value(date),
              siteID: Value(siteId),
              writerId: Value(writerId),
            ),
          );
    }

    test('orders by date', () async {
      final later = await insertNarrative(date: '2024-08-09');
      final earlier = await insertNarrative(date: '2024-02-01');
      expect(
        (await NarrativeQuery(database).getAllNarrative(
          projectUuid,
          sort: sortBy(RecordSortField.narrativeDate),
        )).map((narrative) => narrative.id),
        [earlier, later],
      );
    });

    test('orders by the site ID shown on the form, not the raw key', () async {
      // Insertion order gives the "Z" site the lower primary key, so ordering
      // by the foreign key would reverse the user-visible result.
      final siteZ = await insertSite(siteId: 'Z');
      final siteA = await insertSite(siteId: 'A');
      final onZ = await insertNarrative(siteId: siteZ);
      final onA = await insertNarrative(siteId: siteA);

      expect(
        (await NarrativeQuery(database).getAllNarrative(
          projectUuid,
          sort: sortBy(RecordSortField.narrativeSite),
        )).map((narrative) => narrative.id),
        [onA, onZ],
      );
    });

    test('orders by writer name, keeping unwritten narratives last', () async {
      final zoe = await insertPersonnel('writer-z', 'Zoe');
      final ada = await insertPersonnel('writer-a', 'Ada');
      final byZoe = await insertNarrative(writerId: zoe);
      final unassigned = await insertNarrative();
      final byAda = await insertNarrative(writerId: ada);

      expect(
        (await NarrativeQuery(database).getAllNarrative(
          projectUuid,
          sort: sortBy(RecordSortField.writer),
        )).map((narrative) => narrative.id),
        [byAda, byZoe, unassigned],
      );
    });
  });

  group('specimens', () {
    Future<String> insertSpecimen({
      required String uuid,
      int? fieldNumber,
      int? projectFieldNumber,
      String? catalogerId,
      int? speciesId,
    }) async {
      await database
          .into(database.specimen)
          .insert(
            SpecimenCompanion(
              uuid: Value(uuid),
              projectUuid: const Value(projectUuid),
              fieldNumber: Value(fieldNumber),
              projectFieldNumber: Value(projectFieldNumber),
              catalogerID: Value(catalogerId),
              speciesID: Value(speciesId),
            ),
          );
      return uuid;
    }

    test('field id follows the active field ID mode', () async {
      await insertSpecimen(
        uuid: 'spec-1',
        fieldNumber: 1,
        projectFieldNumber: 20,
      );
      await insertSpecimen(
        uuid: 'spec-2',
        fieldNumber: 2,
        projectFieldNumber: 10,
      );
      final query = SpecimenQuery(database);
      final sort = sortBy(RecordSortField.fieldId);

      expect(
        (await query.getAllSpecimens(
          projectUuid,
          sort: sort,
          fieldIdMode: FieldIdMode.personnel,
        )).map((specimen) => specimen.uuid),
        ['spec-1', 'spec-2'],
      );
      expect(
        (await query.getAllSpecimens(
          projectUuid,
          sort: sort,
          fieldIdMode: FieldIdMode.project,
        )).map((specimen) => specimen.uuid),
        ['spec-2', 'spec-1'],
      );
    });

    test('orders by cataloger name, keeping uncatalogued last', () async {
      await database
          .into(database.personnel)
          .insert(
            const PersonnelCompanion(uuid: Value('cat-z'), name: Value('Zoe')),
          );
      await database
          .into(database.personnel)
          .insert(
            const PersonnelCompanion(uuid: Value('cat-a'), name: Value('Ada')),
          );
      await insertSpecimen(uuid: 'spec-z', catalogerId: 'cat-z');
      await insertSpecimen(uuid: 'spec-none');
      await insertSpecimen(uuid: 'spec-a', catalogerId: 'cat-a');

      expect(
        (await SpecimenQuery(database).getAllSpecimens(
          projectUuid,
          sort: sortBy(RecordSortField.cataloger),
        )).map((specimen) => specimen.uuid),
        ['spec-a', 'spec-z', 'spec-none'],
      );
    });

    test('orders by genus then specific epithet', () async {
      final rattusNorvegicus = await database
          .into(database.taxonomy)
          .insert(
            const TaxonomyCompanion(
              genus: Value('Rattus'),
              specificEpithet: Value('norvegicus'),
            ),
          );
      final rattusExulans = await database
          .into(database.taxonomy)
          .insert(
            const TaxonomyCompanion(
              genus: Value('Rattus'),
              specificEpithet: Value('exulans'),
            ),
          );
      final musMusculus = await database
          .into(database.taxonomy)
          .insert(
            const TaxonomyCompanion(
              genus: Value('Mus'),
              specificEpithet: Value('musculus'),
            ),
          );
      await insertSpecimen(uuid: 'spec-rn', speciesId: rattusNorvegicus);
      await insertSpecimen(uuid: 'spec-mm', speciesId: musMusculus);
      await insertSpecimen(uuid: 'spec-re', speciesId: rattusExulans);

      expect(
        (await SpecimenQuery(database).getAllSpecimens(
          projectUuid,
          sort: sortBy(RecordSortField.species),
        )).map((specimen) => specimen.uuid),
        ['spec-mm', 'spec-re', 'spec-rn'],
      );
    });

    test('breaks ties so refetching cannot reshuffle pages', () async {
      await insertSpecimen(uuid: 'spec-1');
      await insertSpecimen(uuid: 'spec-2');
      await insertSpecimen(uuid: 'spec-3');
      final query = SpecimenQuery(database);
      final sort = sortBy(
        RecordSortField.cataloger,
        RecordSortDirection.descending,
      );

      final once = await query.getAllSpecimens(projectUuid, sort: sort);
      final twice = await query.getAllSpecimens(projectUuid, sort: sort);
      expect(once.map((specimen) => specimen.uuid), [
        'spec-1',
        'spec-2',
        'spec-3',
      ]);
      expect(
        twice.map((specimen) => specimen.uuid),
        once.map((specimen) => specimen.uuid),
      );
    });
  });
}
