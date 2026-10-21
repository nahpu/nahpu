import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_grid_controller.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/data_table/data_table_tsv.dart';
import 'package:nahpu/services/export/coll_event_writer.dart';
import 'package:nahpu/services/export/site_writer.dart';
import 'package:nahpu/services/export/specimen_part_records.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  group('grid controller', () {
    DataTableGridController grid() {
      final controller = DataTableGridController()..setSize(5, 4);
      addTearDown(controller.dispose);
      return controller;
    }

    test('arrows move and stop at the edges', () {
      final controller = grid()
        ..move(-1, 0)
        ..move(0, -1);
      expect(controller.focus, (row: 0, col: 0));
      controller.move(9, 9);
      expect(controller.focus, (row: 4, col: 3));
    });

    test('Tab wraps to the next row, Shift+Tab to the previous', () {
      final controller = grid()..moveTo(0, 3);
      controller.tab();
      expect(controller.focus, (row: 1, col: 0));
      controller.tab(backward: true);
      expect(controller.focus, (row: 0, col: 3));
    });

    test('shift extends the selection from the anchor', () {
      final controller = grid()
        ..moveTo(1, 1)
        ..move(2, 1, extend: true);
      final selection = controller.selection;
      expect(
        (selection.top, selection.left, selection.bottom, selection.right),
        (1, 1, 3, 2),
      );
      controller.collapse();
      expect(controller.selection.isSingleCell, isTrue);
    });

    test('edge, row, and page jumps', () {
      final controller = grid()..moveTo(2, 2);
      controller.toEdge(0, 1);
      expect(controller.focus, (row: 2, col: 3));
      controller.rowStart();
      expect(controller.focus, (row: 2, col: 0));
      controller.pageEnd();
      expect(controller.focus, (row: 4, col: 3));
      controller.selectAll();
      expect(controller.selection.top, 0);
      expect(controller.selection.right, 3);
    });

    test('shrinking the grid keeps focus inside and ends editing', () {
      final controller = grid()
        ..moveTo(4, 3)
        ..beginEdit(seed: 'x');
      controller.setSize(2, 2);
      expect(controller.focus, (row: 1, col: 1));
      expect(controller.isEditing, isFalse);
    });
  });

  group('TSV', () {
    test('round-trips tabs, newlines, and quotes', () {
      final rows = [
        ['plain', 'with\ttab', 'say "hi"'],
        ['two\nlines', '', 'end'],
      ];
      expect(decodeDataTableTsv(encodeDataTableTsv(rows)), rows);
    });

    test('ignores the trailing newline spreadsheets add', () {
      expect(decodeDataTableTsv('a\tb\r\nc\td\r\n'), [
        ['a', 'b'],
        ['c', 'd'],
      ]);
      expect(decodeDataTableTsv('a\t'), [
        ['a', ''],
      ]);
    });
  });

  group('field catalog', () {
    final headers = {
      DataTableRecordType.specimenParts: SpecimenPartWriter.header,
      DataTableRecordType.sites: SiteWriterServices.header,
      DataTableRecordType.events: CollEventRecordWriter.header,
      DataTableRecordType.narrative: narrativeExportList,
      DataTableRecordType.specimenRecords: [
        ...collectingRecordExportList,
        ...siteExportList,
        ...collEventExportList,
        ...mammalAttributeExportList,
        ...birdAttributeExportList,
        ...herpAttributeExportList,
        ...invertebrateAttributeExportList,
        ...fishAttributeExportList,
        ...fossilAttributeExportList,
      ],
    };

    test('every default column is in its export header', () {
      for (final entry in headers.entries) {
        expect(entry.value, containsAll(entry.key.defaultColumnKeys));
      }
    });

    test('editable fields have a column and type that fit', () {
      for (final header in headers.values) {
        for (final key in header) {
          final field = dataTableField(key);
          if (field.writeTarget == null) continue;
          expect(field.column, isNotNull, reason: key);
          expect(field.isFilterable, isTrue, reason: key);
        }
      }
    });

    test('only a record type\'s own fields are editable', () {
      final columns = dataTableColumnsFromHeader(
        headers[DataTableRecordType.specimenRecords]!,
      );
      final editable = {
        for (final column in columns)
          if (column.isEditableIn(DataTableRecordType.specimenRecords))
            column.key,
      };
      expect(editable, contains('specimen::condition'));
      expect(editable, contains('measurement::weight'));
      expect(editable, isNot(contains('specimen::cataloger')));
      expect(editable, isNot(contains('geography::country')));
      expect(editable, isNot(contains('measurement::sex')));
      expect(editable, isNot(contains('measurement::standardLength')));
    });

    test('unknown and derived keys are computed', () {
      expect(dataTableField('custom::x').isComputed, isTrue);
      expect(dataTableField('site::coordinates').isComputed, isTrue);
      expect(dataTableField('event::collEventID').isSortable, isTrue);
      expect(dataTableField('event::collEventID').isFilterable, isFalse);
    });

    test('labels use field names and tell shared names apart', () {
      final columns = dataTableColumnsFromHeader(const [
        'specimen::fieldNumber',
        'measurement::remark',
        'parasite::remark',
      ]);
      expect(columns.map((c) => c.label), [
        'fieldNumber',
        'remark (measurement)',
        'remark (parasite)',
      ]);
    });

    test('rows pair values with keys and pad short rows', () {
      expect(dataTableRowFromValues(const ['a::x', 'a::y'], const [' 1 ']), {
        'a::x': '1',
        'a::y': '',
      });
    });
  });
}
