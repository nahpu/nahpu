import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_save_service.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/database/database.dart';

import 'data_table_test_db.dart';

void main() {
  late Database db;
  late DataTableSaveService service;

  setUp(() async {
    db = await seededDataTableDb();
    service = DataTableSaveService(db);
  });

  tearDown(() => db.close());

  DataTableEdit edit(
    Object key,
    String field,
    String value, {
    Map<String, String> row = const {},
    String? attributeTable,
  }) => DataTableEdit(
    cell: DataTableCellId(key, field),
    field: dataTableField(field),
    value: value,
    row: row,
    attributeTable: attributeTable,
  );

  Future<Map<String, Object?>> select(String sql, List<Object?> args) async {
    final rows = await db
        .customSelect(sql, variables: [for (final arg in args) Variable(arg)])
        .get();
    return rows.single.data;
  }

  test('writes specimen fields and clears empty ones', () async {
    final result = await service.save(DataTableRecordType.specimenRecords, [
      edit('s1', 'specimen::condition', 'Damaged'),
      edit('s1', 'specimen::preparationDate', ''),
      edit('s1', 'specimen::iDConfidence', '3'),
    ]);
    expect(result.errors, isEmpty);
    expect(result.saved, hasLength(3));
    expect(
      await select(
        'SELECT condition, prepDate, iDConfidence FROM specimen WHERE uuid = ?',
        ['s1'],
      ),
      {'condition': 'Damaged', 'prepDate': null, 'iDConfidence': 3},
    );
  });

  test('adds an attribute row from the taxon group when missing', () async {
    final result = await service.save(DataTableRecordType.specimenRecords, [
      edit('s2', 'measurement::wingspan', '12.5'),
    ]);
    expect(result.errors, isEmpty);
    expect(
      await select(
        'SELECT wingspan FROM birdAttribute WHERE specimenUuid = ?',
        ['s2'],
      ),
      {'wingspan': 12.5},
    );
  });

  test('coded fields store their code', () async {
    final result = await service.save(DataTableRecordType.specimenRecords, [
      edit('s1', 'measurement::sex', '1', attributeTable: 'mammalAttribute'),
      edit(
        's1',
        'measurement::testisLength',
        '',
        attributeTable: 'mammalAttribute',
      ),
    ]);
    expect(result.errors, isEmpty);
    expect(
      await select(
        'SELECT sex, testisLength FROM mammalAttribute WHERE specimenUuid = ?',
        ['s1'],
      ),
      {'sex': 1, 'testisLength': null},
    );
    final bad = await service.save(DataTableRecordType.specimenRecords, [
      edit('s1', 'measurement::sex', '42', attributeTable: 'mammalAttribute'),
    ]);
    expect(bad.errors.values.single, 'Choose one of the listed values');
  });

  test('refuses a measurement the taxon group does not record', () async {
    final result = await service.save(DataTableRecordType.specimenRecords, [
      edit(
        's1',
        'measurement::wingspan',
        '3',
        attributeTable: 'mammalAttribute',
      ),
    ]);
    expect(result.saved, isEmpty);
    expect(result.errors.values.single, contains('taxon group'));
  });

  test('a bad value fails its record only', () async {
    final result = await service.save(DataTableRecordType.specimenRecords, [
      edit('s1', 'specimen::preparationDate', 'tomorrow'),
      edit('s2', 'specimen::condition', 'Fine'),
    ]);
    expect(result.saved, {const DataTableCellId('s2', 'specimen::condition')});
    expect(
      result.errors[const DataTableCellId('s1', 'specimen::preparationDate')],
      'Enter a date as YYYY-MM-DD',
    );
  });

  test('fields of linked records are read-only', () async {
    final result = await service.save(DataTableRecordType.specimenRecords, [
      edit('s1', 'geography::country', 'Malaysia'),
      edit('s1', 'specimen::cataloger', 'Someone'),
    ]);
    expect(result.saved, isEmpty);
    expect(result.errors, hasLength(2));
  });

  test(
    'locality edits resolve a row instead of changing a shared one',
    () async {
      final result = await service.save(DataTableRecordType.sites, [
        edit(
          1,
          'geography::country',
          'Malaysia',
          row: const {
            'geography::country': 'Indonesia',
            'geography::stateProvince': 'Aceh',
            'geography::specificLocality': 'Camp 1',
          },
        ),
      ]);
      expect(result.errors, isEmpty);
      final shared = await select(
        'SELECT country FROM geography WHERE id = 1',
        const [],
      );
      expect(shared['country'], 'Indonesia');
      final site = await select(
        'SELECT g.country, g.stateProvince, g.locality FROM site s '
        'JOIN geography g ON g.id = s.geographyId WHERE s.id = 1',
        const [],
      );
      expect(site, {
        'country': 'Malaysia',
        'stateProvince': 'Aceh',
        'locality': 'Camp 1',
      });
      final other = await select(
        'SELECT geographyId FROM site WHERE id = 2',
        const [],
      );
      expect(other['geographyId'], 1);
    },
  );

  test('habitat and environment rows are added when missing', () async {
    final sites = await service.save(DataTableRecordType.sites, [
      edit(2, 'siteAttribute::habitatType', 'Montane forest'),
      edit(2, 'site::siteNotes', 'Steep'),
    ]);
    expect(sites.errors, isEmpty);
    expect(
      await select(
        'SELECT habitatType FROM siteAttribute WHERE siteID = 2',
        const [],
      ),
      {'habitatType': 'Montane forest'},
    );

    final events = await service.save(DataTableRecordType.events, [
      edit(1, 'environment::lowestDayTempC', '19'),
      edit(1, 'event::startTime', '06:30'),
    ]);
    expect(events.errors, isEmpty);
    expect(
      await select(
        'SELECT COUNT(*) AS c, MIN(lowestDayTempC) AS t FROM environment '
        'WHERE eventID = 1',
        const [],
      ),
      {'c': 1, 't': 19.0},
    );
  });

  test('a missing record is reported', () async {
    final result = await service.save(DataTableRecordType.narrative, [
      edit(99, 'narrative::narrative', 'Lost'),
    ]);
    expect(result.errors, hasLength(1));
  });
}
