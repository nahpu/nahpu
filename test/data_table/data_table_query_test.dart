import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_query.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/export.dart';

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
}
