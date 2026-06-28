import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/export/export_label_service.dart';

void main() {
  group('ExportLabelService', () {
    test(
        'mergeColumnOrder preserves previous order and appends new columns alphabetically',
        () {
      final service = const ExportLabelService();

      final previousOrder = ['specimenUuid', 'catalogerID', 'fieldNumber'];
      final selected = {'specimenUuid', 'fieldNumber', 'species', 'family'};

      final merged = service.mergeColumnOrder(previousOrder, selected);

      // Expected logic:
      // 1. previousOrder items that are in selected are kept in order.
      // 2. remaining selected items are sorted alphabetically by their display title and appended.
      // specimenUuid -> "Specimen UUID"
      // fieldNumber -> "Field Number"
      // species -> "Species"
      // family -> "Family"
      // Alphabetical order for 'family' vs 'species': 'family' comes first.

      expect(merged.length, 4);
      expect(merged[0], 'specimenUuid');
      expect(merged[1], 'fieldNumber');

      // The exact alphabetical sorting might depend on specimenColumnDisplayTitle implementation.
      // Assuming 'family' < 'species'
      expect(merged[2], 'family');
      expect(merged[3], 'species');
    });

    test('mergeColumnOrder removes unselected columns', () {
      final service = const ExportLabelService();

      final previousOrder = ['specimenUuid', 'catalogerID', 'fieldNumber'];
      final selected = {'specimenUuid', 'fieldNumber'};

      final merged = service.mergeColumnOrder(previousOrder, selected);

      expect(merged.length, 2);
      expect(merged, ['specimenUuid', 'fieldNumber']);
    });
  });
}
