import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_query.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/file_format.dart';

import 'data_table_test_db.dart';

void main() {
  late Database db;
  late DataTablePageQuery pages;

  setUp(() async {
    db = await seededDataTableDb();
    pages = DataTablePageQuery(db);
  });

  tearDown(() => db.close());

  Future<DataTableKeyPage> specimens(
    DataTableQuery query, {
    SpecimenRecordType taxa = SpecimenRecordType.allTaxa,
  }) => pages.run(
    DataTableRecordType.specimenRecords,
    query,
    projectUuid: 'p1',
    taxa: taxa,
  );

  test('counts and pages only the project\'s records', () async {
    final first = await specimens(const DataTableQuery(rowsPerPage: 2));
    expect(first.totalRows, 3);
    expect(first.pageCount, 2);
    expect(first.keys, ['s1', 's2']);

    final past = await specimens(const DataTableQuery(rowsPerPage: 2, page: 9));
    expect(past.page, 1);
    expect(past.keys, ['s3']);
  });

  test('limits specimens to a taxon group', () async {
    final birds = await specimens(
      const DataTableQuery(),
      taxa: SpecimenRecordType.birds,
    );
    expect(birds.keys, ['s2']);
  });

  test('search matches % and _ literally', () async {
    final literal = await specimens(
      const DataTableQuery(search: '%_', searchKeys: ['specimen::condition']),
    );
    expect(literal.keys, ['s2']);

    final wildcard = await specimens(
      const DataTableQuery(search: 'G_od', searchKeys: ['specimen::condition']),
    );
    expect(wildcard.keys, isEmpty);
  });

  test('search covers the given fields, or one chosen field', () async {
    final byGenus = await specimens(
      const DataTableQuery(
        search: 'rattus',
        searchKeys: ['specimen::genus', 'specimen::condition'],
      ),
    );
    expect(byGenus.keys, ['s1']);

    final scoped = await specimens(
      const DataTableQuery(
        search: 'rattus',
        searchField: 'specimen::condition',
        searchKeys: ['specimen::genus'],
      ),
    );
    expect(scoped.keys, isEmpty);
  });

  test('a search over only calculated fields matches nothing', () async {
    final result = await specimens(
      const DataTableQuery(search: 'x', searchKeys: ['media::media']),
    );
    expect(result.totalRows, 0);
  });

  test('field rules combine with AND', () async {
    final heavy = await specimens(
      const DataTableQuery(
        rules: [
          DataTableFilterRule(
            fieldKey: 'measurement::weight',
            op: DataTableFilterOp.between,
            value: '40',
            value2: '50',
          ),
        ],
      ),
    );
    expect(heavy.keys, ['s1']);

    final both = await specimens(
      const DataTableQuery(
        rules: [
          DataTableFilterRule(
            fieldKey: 'specimen::preparationDate',
            op: DataTableFilterOp.greaterThan,
            value: '2026-03-01',
          ),
          DataTableFilterRule(
            fieldKey: 'specimen::condition',
            op: DataTableFilterOp.contains,
            value: 'off',
          ),
        ],
      ),
    );
    expect(both.keys, ['s2']);

    final empty = await specimens(
      const DataTableQuery(
        rules: [
          DataTableFilterRule(
            fieldKey: 'specimen::fieldNumber',
            op: DataTableFilterOp.isEmpty,
          ),
        ],
      ),
    );
    expect(empty.keys, ['s3']);
  });

  test('rejects rules on calculated fields and bad values', () async {
    expect(
      () => specimens(
        const DataTableQuery(
          rules: [
            DataTableFilterRule(
              fieldKey: 'specimen::specimenCoordinates',
              op: DataTableFilterOp.contains,
              value: 'x',
            ),
          ],
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => specimens(
        const DataTableQuery(
          rules: [
            DataTableFilterRule(
              fieldKey: 'specimen::preparationDate',
              op: DataTableFilterOp.greaterThan,
              value: 'March',
            ),
          ],
        ),
      ),
      throwsFormatException,
    );
  });

  test('coded fields search by label and filter by code', () async {
    final search = await specimens(
      const DataTableQuery(search: 'mal', searchKeys: ['measurement::sex']),
    );
    expect(search.keys, ['s1']);
    final rule = await specimens(
      const DataTableQuery(
        rules: [
          DataTableFilterRule(
            fieldKey: 'measurement::sex',
            op: DataTableFilterOp.equals,
            value: 'Male',
          ),
        ],
      ),
    );
    expect(rule.keys, ['s1']);
    expect(
      () => specimens(
        const DataTableQuery(
          rules: [
            DataTableFilterRule(
              fieldKey: 'measurement::sex',
              op: DataTableFilterOp.equals,
              value: 'Unicorn',
            ),
          ],
        ),
      ),
      throwsFormatException,
    );
  });

  test('quick filters narrow the page', () async {
    final missing = await specimens(
      const DataTableQuery(quickFilters: {DataTableQuickFilter.missingTaxon}),
    );
    expect(missing.keys, ['s3']);
    final withParts = await specimens(
      const DataTableQuery(quickFilters: {DataTableQuickFilter.hasParts}),
    );
    expect(withParts.keys, ['s1']);
  });

  test('sorting keeps blanks last in both directions', () async {
    final up = await specimens(
      const DataTableQuery(
        sort: DataTableSort(columnKey: 'specimen::fieldNumber'),
      ),
    );
    expect(up.keys, ['s2', 's1', 's3']);
    final down = await specimens(
      const DataTableQuery(
        sort: DataTableSort(
          columnKey: 'specimen::fieldNumber',
          ascending: false,
        ),
      ),
    );
    expect(down.keys, ['s1', 's2', 's3']);
  });

  test('pages every record type in its own project', () async {
    Future<List<Object>> keys(DataTableRecordType type) async =>
        (await pages.run(type, const DataTableQuery(), projectUuid: 'p1')).keys;
    expect(await keys(DataTableRecordType.specimenParts), [1]);
    expect(await keys(DataTableRecordType.parasites), [1, 2]);
    expect(await keys(DataTableRecordType.sites), [1, 2]);
    expect(await keys(DataTableRecordType.events), [1]);
    expect(await keys(DataTableRecordType.narrative), [1, 2]);

    final noSite = await pages.run(
      DataTableRecordType.narrative,
      const DataTableQuery(quickFilters: {DataTableQuickFilter.noSite}),
      projectUuid: 'p1',
    );
    expect(noSite.keys, [2]);
    final cool = await pages.run(
      DataTableRecordType.events,
      const DataTableQuery(
        rules: [
          DataTableFilterRule(
            fieldKey: 'environment::lowestDayTempC',
            op: DataTableFilterOp.lessThan,
            value: '22',
          ),
        ],
      ),
      projectUuid: 'p1',
    );
    expect(cool.keys, [1]);
  });

  test('reads stored values and the attribute table for edits', () async {
    final raw = await pages.rawValues(
      DataTableRecordType.specimenRecords,
      ['s1', 's3'],
      [
        dataTableField('specimen::condition'),
        dataTableField('measurement::weight'),
      ],
    );
    expect(raw.values['s1'], {
      'specimen::condition': 'Good',
      'measurement::weight': '42',
    });
    expect(raw.attributes['s1'], 'mammalAttribute');
    expect(raw.attributes.containsKey('s3'), isFalse);
  });

  test('a key scope limits rows and count', () async {
    final scoped = await specimens(
      const DataTableQuery(
        scope: DataTableKeyScope(keys: {'s1', 's3', 'other'}, label: 'Pick'),
      ),
    );
    expect(scoped.totalRows, 2);
    expect(scoped.keys, ['s1', 's3']);

    final sites = await pages.run(
      DataTableRecordType.sites,
      const DataTableQuery(
        scope: DataTableKeyScope(keys: {2}, label: 'Pick'),
      ),
      projectUuid: 'p1',
    );
    expect(sites.keys, [2]);
  });

  test('a key scope combines with search and rules', () async {
    final scoped = await specimens(
      const DataTableQuery(
        scope: DataTableKeyScope(keys: {'s1', 's2'}, label: 'Pick'),
        search: 'Good',
        searchKeys: ['specimen::condition'],
      ),
    );
    expect(scoped.keys, ['s1']);
  });

  test('reads media file names by record, and parts by specimen', () async {
    Future<void> media(int id, String file) => db.customStatement(
      'INSERT INTO media (primaryId, projectUuid, fileName) VALUES (?, ?, ?)',
      [id, 'p1', file],
    );
    await media(1, 'skull.JPG');
    await media(2, 'call.wav');
    await media(3, 'site.mp4');
    await db.customStatement(
      'INSERT INTO specimenMedia (specimenUuid, mediaId) VALUES (?, ?), (?, ?)',
      ['s1', 1, 's1', 2],
    );
    await db.customStatement(
      'INSERT INTO siteMedia (siteId, mediaId) VALUES (?, ?)',
      [2, 3],
    );

    final specimenFiles = await pages.mediaFiles(
      DataTableRecordType.specimenRecords,
      ['s1', 's2'],
    );
    expect(specimenFiles.keys, ['s1']);
    expect(dataTableMediaKinds(specimenFiles['s1']!), {
      MediaKind.image,
      MediaKind.audio,
    });

    final partFiles = await pages.mediaFiles(
      DataTableRecordType.specimenParts,
      [1],
    );
    expect(partFiles[1], hasLength(2));

    final siteFiles = await pages.mediaFiles(DataTableRecordType.sites, [1, 2]);
    expect(dataTableMediaKinds(siteFiles[2]!), {MediaKind.video});
    expect(siteFiles.containsKey(1), isFalse);
  });

  test('without a project, pages records from every project', () async {
    final page = await pages.run(
      DataTableRecordType.specimenRecords,
      const DataTableQuery(),
      projectUuid: null,
    );
    expect(page.totalRows, 4);
    expect(page.keys, containsAll(['s1', 'other']));

    final raw = await pages.rawValues(DataTableRecordType.specimenRecords, [
      's1',
      'other',
    ], const []);
    expect(raw.projectUuids, {'s1': 'p1', 'other': 'p2'});
  });

  test('default columns keep their listed order, sex near the front', () {
    final columns = dataTableColumnsFromHeader(const [
      'specimen::cataloger',
      'specimen::condition',
      'specimen::extraNote',
      'event::collEventID',
      'measurement::sex',
    ]);
    expect(
      orderDataTableColumns(
        DataTableRecordType.specimenRecords,
        columns,
      ).map((column) => column.key),
      [
        'specimen::cataloger',
        'specimen::condition',
        'measurement::sex',
        'event::collEventID',
        'specimen::extraNote',
      ],
    );
  });

  test('mammals include the legacy General Mammals and Bats labels', () async {
    await db.customStatement(
      "UPDATE specimen SET taxonGroup = 'Mammals' WHERE uuid = 's3'",
    );
    await db.customStatement(
      'INSERT INTO specimen (uuid, projectUuid, taxonGroup) '
      "VALUES ('bat', 'p1', 'Bats')",
    );
    final page = await specimens(
      const DataTableQuery(),
      taxa: SpecimenRecordType.mammals,
    );
    expect(page.keys.toSet(), {'s1', 's3', 'bat'});
  });

  test('bat measurements are found only where recorded', () async {
    final query = SpecimenQuery(db);
    expect(await query.hasBatMeasurements(projectUuid: 'p1'), isFalse);

    await db.customStatement(
      "UPDATE mammalAttribute SET forearm = 41.5 WHERE specimenUuid = 's1'",
    );
    expect(await query.hasBatMeasurements(projectUuid: 'p1'), isTrue);
    expect(await query.hasBatMeasurements(projectUuids: {'p2'}), isFalse);
    expect(await query.hasBatMeasurements(), isTrue);

    await db.customStatement(
      'UPDATE mammalAttribute SET forearm = NULL, showBatFields = 1',
    );
    expect(await query.hasBatMeasurements(projectUuid: 'p1'), isTrue);
  });

  test('project scope labels name up to two projects', () {
    expect(dataTableProjectScopeLabel(['Ridge']), 'Project: Ridge');
    expect(
      dataTableProjectScopeLabel(['Ridge', 'Valley']),
      'Projects: Ridge, Valley',
    );
    expect(dataTableProjectScopeLabel(['A', 'B', 'C']), '3 projects');
  });

  test('without a project, limits records to the picked projects', () async {
    final page = await pages.run(
      DataTableRecordType.specimenRecords,
      const DataTableQuery(allProjects: true, projectUuids: {'p2'}),
      projectUuid: null,
    );
    expect(page.keys, ['other']);
  });

  test('every record type can be limited to records with media', () async {
    await db.customStatement(
      'INSERT INTO media (primaryId, projectUuid, fileName) '
      'VALUES (1, ?, ?), (2, ?, ?)',
      ['p1', 'skull.JPG', 'p1', 'site.mp4'],
    );
    await db.customStatement(
      'INSERT INTO specimenMedia (specimenUuid, mediaId) VALUES (?, 1)',
      ['s1'],
    );
    await db.customStatement(
      'INSERT INTO siteMedia (siteId, mediaId) VALUES (2, 2)',
    );

    Future<List<Object>> withMedia(DataTableRecordType type) async {
      final filter = type.quickFilters.singleWhere(
        (filter) => filter.label == 'Has media',
      );
      final page = await pages.run(
        type,
        DataTableQuery(quickFilters: {filter}),
        projectUuid: 'p1',
      );
      return page.keys;
    }

    expect(await withMedia(DataTableRecordType.specimenRecords), ['s1']);
    expect(await withMedia(DataTableRecordType.specimenParts), [1]);
    expect(await withMedia(DataTableRecordType.sites), [2]);
    expect(await withMedia(DataTableRecordType.events), isEmpty);
    expect(await withMedia(DataTableRecordType.narrative), isEmpty);
  });

  test('parasites search, filter, and sort by their own fields', () async {
    Future<List<Object>> parasites(DataTableQuery query) async =>
        (await pages.run(
          DataTableRecordType.parasites,
          query,
          projectUuid: 'p1',
        )).keys;
    expect(
      await parasites(
        const DataTableQuery(
          search: 'diminuta',
          searchKeys: ['parasite::scientificName'],
        ),
      ),
      [1],
    );
    expect(
      await parasites(
        const DataTableQuery(
          rules: [
            DataTableFilterRule(
              fieldKey: 'parasite::identifierID',
              op: DataTableFilterOp.equals,
              value: 'Ben Oru',
            ),
          ],
        ),
      ),
      [1],
    );
    expect(
      await parasites(
        const DataTableQuery(
          rules: [
            DataTableFilterRule(
              fieldKey: 'parasite::associationStatus',
              op: DataTableFilterOp.equals,
              value: 'Confirmed',
            ),
          ],
        ),
      ),
      [1, 2],
    );
    expect(
      await parasites(
        const DataTableQuery(quickFilters: {DataTableQuickFilter.noParasiteId}),
      ),
      [2],
    );
    expect(
      await parasites(
        const DataTableQuery(
          quickFilters: {DataTableQuickFilter.parasiteMissingTaxon},
        ),
      ),
      [2],
    );
    expect(
      await parasites(
        const DataTableQuery(
          sort: DataTableSort(columnKey: 'parasite::count', ascending: false),
        ),
      ),
      [1, 2],
    );
  });

  test('raw values carry the parent specimen of a parasite', () async {
    final raw = await pages.rawValues(
      DataTableRecordType.parasites,
      [1],
      [dataTableField('parasite::scientificName')],
    );
    expect(raw.specimenUuids[1], 's2');
    expect(raw.values[1], {'parasite::scientificName': 'Hymenolepis diminuta'});
  });

  test('raw values carry the parent specimen of a part', () async {
    final raw = await pages.rawValues(DataTableRecordType.specimenParts, [
      1,
    ], const []);
    expect(raw.specimenUuids[1], 's1');
  });
}
