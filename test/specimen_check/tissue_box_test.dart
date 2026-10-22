import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/specimen_check/tissue_box.dart';
import 'package:nahpu/services/specimen_check/tissue_check_settings.dart';

void main() {
  group('TissueBoxLayout', () {
    test('row fill with alphanumeric labels', () {
      const layout = TissueBoxLayout();
      final labels = layout.orderedCells.map(layout.cellLabel).toList();
      expect(labels.length, 81);
      expect(labels.take(10), [
        'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'B1', //
      ]);
      expect(labels.last, 'I9');
    });

    test('column fill runs down each column', () {
      const layout = TissueBoxLayout(fillOrder: TissueFillOrder.columnMajor);
      final labels = layout.orderedCells.map(layout.cellLabel).toList();
      expect(labels.take(3), ['A1', 'B1', 'C1']);
      expect(labels[9], 'A2');
    });

    test('serpentine fill reverses every other row', () {
      const layout = TissueBoxLayout(fillOrder: TissueFillOrder.serpentine);
      final labels = layout.orderedCells.map(layout.cellLabel).toList();
      expect(labels[8], 'A9');
      expect(labels[9], 'B9');
      expect(labels[17], 'B1');
      expect(labels[18], 'C1');
    });

    test('sequential numbers follow the fill order', () {
      const layout = TissueBoxLayout(
        size: TissueBoxSize.cells100,
        numbering: TissueCellNumbering.sequential,
        fillOrder: TissueFillOrder.serpentine,
      );
      expect(layout.cellLabel(const TissueCell(0, 0)), '1');
      expect(layout.cellLabel(const TissueCell(1, 9)), '11');
      expect(layout.cellLabel(const TissueCell(9, 0)), '100');
    });

    test('row-column labels', () {
      const layout = TissueBoxLayout(
        size: TissueBoxSize.cells100,
        numbering: TissueCellNumbering.rowColumn,
      );
      expect(layout.cellLabel(const TissueCell(9, 9)), '10-10');
      expect(layout.rowLabel(9), '10');
    });

    test('labels parse back to their cells for every layout', () {
      for (final size in TissueBoxSize.values) {
        for (final numbering in TissueCellNumbering.values) {
          for (final order in TissueFillOrder.values) {
            final layout = TissueBoxLayout(
              size: size,
              numbering: numbering,
              fillOrder: order,
            );
            final cells = layout.orderedCells;
            expect(cells.toSet().length, size.capacity);
            for (final (index, cell) in cells.indexed) {
              expect(layout.indexOf(cell), index);
              expect(layout.parseCellLabel(layout.cellLabel(cell)), cell);
            }
          }
        }
      }
    });

    test('rejects labels outside the box', () {
      const layout = TissueBoxLayout();
      expect(layout.parseCellLabel('J1'), isNull);
      expect(layout.parseCellLabel('A10'), isNull);
      expect(layout.parseCellLabel('note'), isNull);
    });

    test('first free cell skips occupied cells from a start', () {
      const layout = TissueBoxLayout();
      final occupied = {const TissueCell(0, 0), const TissueCell(0, 2)};
      expect(layout.firstFree(occupied), const TissueCell(0, 1));
      expect(
        layout.firstFree(occupied, from: const TissueCell(0, 2)),
        const TissueCell(0, 3),
      );
      final full = layout.orderedCells.toSet();
      expect(layout.firstFree(full), isNull);
    });
  });

  group('Tissue locations', () {
    test('format and parse with and without a label', () {
      expect(formatTissueLocation('Box', 12, 'A1'), 'Box 12: A1');
      expect(formatTissueLocation('  ', 3, 'B2'), '3: B2');
      const layout = TissueBoxLayout();
      expect(
        parseTissueLocation(
          layout,
          boxLabel: 'Box',
          boxNumber: 12,
          location: 'Box 12: C4',
        ),
        const TissueCell(2, 3),
      );
      expect(
        parseTissueLocation(
          layout,
          boxLabel: 'Box',
          boxNumber: 1,
          location: 'Box 12: C4',
        ),
        isNull,
      );
    });
  });

  group('TissueCheckSettings', () {
    test('defaults to museum permanent and round-trips', () {
      final defaults = TissueCheckSettings.decode(null);
      expect(defaults.field, TissueCheckField.museumPermanent);
      expect(defaults.layout.size, TissueBoxSize.cells81);

      final settings = defaults.copyWith(
        field: TissueCheckField.museumLoan,
        value: 'EXM',
        layout: const TissueBoxLayout(
          size: TissueBoxSize.cells100,
          numbering: TissueCellNumbering.rowColumn,
          fillOrder: TissueFillOrder.serpentine,
        ),
        boxLabel: 'Rack',
        boxNumber: 4,
        overwrite: true,
      );
      final decoded = TissueCheckSettings.decode(settings.encode());
      expect(decoded.field, TissueCheckField.museumLoan);
      expect(decoded.value, 'EXM');
      expect(decoded.layout.size, TissueBoxSize.cells100);
      expect(decoded.layout.numbering, TissueCellNumbering.rowColumn);
      expect(decoded.layout.fillOrder, TissueFillOrder.serpentine);
      expect(decoded.boxName, 'Rack 4');
      expect(decoded.overwrite, isTrue);
    });

    test('falls back to defaults for bad data', () {
      expect(TissueCheckSettings.decode('not json').boxNumber, 1);
      expect(
        TissueCheckSettings.decode('{"field":"gone","boxNumber":-2}').field,
        TissueCheckField.museumPermanent,
      );
    });
  });
}
