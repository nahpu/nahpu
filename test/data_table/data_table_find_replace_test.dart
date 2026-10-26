import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/data_table/data_table_find_replace.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';

void main() {
  const type = DataTableRecordType.specimenRecords;
  final columns = dataTableColumnsFromHeader(const [
    'specimen::specimenUUID',
    'measurement::remark',
    'measurement::testisLength',
    'measurement::sex',
  ]);
  DataTableRecordRow row(String key, String remark, {String length = '12'}) =>
      DataTableRecordRow(
        key: key,
        values: {
          'specimen::specimenUUID': 'uuid-$key',
          'measurement::remark': remark,
          'measurement::testisLength': length,
          'measurement::sex': 'Male',
        },
        raw: {
          'measurement::remark': remark,
          'measurement::testisLength': length,
          'measurement::sex': '0',
        },
        attributeTable: 'mammalAttribute',
      );

  group('DataTableFindOptions', () {
    test('ignores case unless asked', () {
      const options = DataTableFindOptions(text: 'note');
      expect(options.matches('A Note'), isTrue);
      const exact = DataTableFindOptions(text: 'note', matchCase: true);
      expect(exact.matches('A Note'), isFalse);
    });

    test('whole cell matches only the full value', () {
      const options = DataTableFindOptions(text: 'note', wholeCell: true);
      expect(options.matches('note'), isTrue);
      expect(options.matches('note 1'), isFalse);
    });

    test('replaces every match with the text as typed', () {
      const options = DataTableFindOptions(text: 'a.', replacement: r'$1');
      expect(options.replace('a.b a.c'), r'$1b $1c');
      expect(options.replace('abc'), 'abc');
    });
  });

  test('finds matches row by row in the scoped columns', () {
    final rows = [row('r1', 'note one'), row('r2', 'other')];
    expect(
      findDataTableMatches(
        rows,
        columns,
        const DataTableFindOptions(text: 'uuid'),
      ),
      [(row: 0, col: 0), (row: 1, col: 0)],
    );
    expect(
      findDataTableMatches(
        rows,
        columns,
        const DataTableFindOptions(text: 'o', columnKey: 'measurement::remark'),
      ),
      [(row: 0, col: 1), (row: 1, col: 1)],
    );
  });

  test('plans edits for plain editable fields only', () {
    final rows = [row('r1', 'Male note'), row('r2', 'female')];
    final plan = planDataTableReplacements(
      type,
      rows,
      columns,
      const DataTableFindOptions(text: 'male', replacement: 'M'),
    );
    expect([for (final (edit, _) in plan.edits) edit.value], ['M note', 'feM']);
    expect(
      [for (final (_, stored) in plan.edits) stored],
      ['Male note', 'female'],
    );
    expect(plan.recordCount, 2);
    expect(plan.edits.first.$1.attributeTable, 'mammalAttribute');
    // The UUID isn't editable, so it's left alone without counting.
    expect(plan.skippedChoices, 0);
  });

  test('counts dropdown matches and replacements that do not fit', () {
    final rows = [row('r1', 'x', length: '12')];
    final codes = planDataTableReplacements(
      type,
      rows,
      columns,
      const DataTableFindOptions(text: '0', columnKey: 'measurement::sex'),
    );
    expect(codes.edits, isEmpty);
    expect(codes.skippedChoices, 1);

    final numbers = planDataTableReplacements(
      type,
      rows,
      columns,
      const DataTableFindOptions(text: '1', replacement: 'one'),
    );
    expect(numbers.edits, isEmpty);
    expect(numbers.invalid, 1);
  });

  test('builds on pending values', () {
    final plan = planDataTableReplacements(
      type,
      [row('r1', 'stored')],
      columns,
      const DataTableFindOptions(text: 'draft', replacement: 'final'),
      pendingOf: (cell) =>
          cell.fieldKey == 'measurement::remark' ? 'draft' : null,
    );
    expect(plan.edits.single.$1.value, 'final');
    expect(plan.edits.single.$2, 'stored');
  });
}
