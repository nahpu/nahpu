import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/sites/components/coordinates.dart';
import 'package:nahpu/services/import/coordinate_tabular_reader.dart';
import 'package:nahpu/services/types/coordinate_import.dart';

void main() {
  testWidgets('shows inferred mappings and allows column overrides', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const reader = CoordinateTabularReader();
    final data = reader.fromRows(const [
      ['latitude', 'longitude', 'field notes'],
      ['12.3', '45.6', 'Ridge'],
    ], worksheetName: 'Waypoints');
    var mapping = Map<CoordinateImportField, int?>.of(data.inferredMapping);
    CoordinateImportField? changedField;
    int? changedColumn;
    var reviewed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => CoordinateColumnMapping(
              data: data,
              mapping: mapping,
              errorText: 'Select a source column for Latitude.',
              onMappingChanged: (field, column) {
                setState(() {
                  mapping = Map.of(mapping)..[field] = column;
                  changedField = field;
                  changedColumn = column;
                });
              },
              onReview: () => reviewed = true,
              onChooseAnother: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Match columns'), findsOneWidget);
    expect(find.textContaining('worksheet "Waypoints"'), findsOneWidget);
    expect(find.text('Latitude *'), findsOneWidget);
    expect(find.text('Longitude *'), findsOneWidget);
    expect(find.text('GPS unit'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Select a source column for Latitude.'), findsOneWidget);

    final notesDropdown = find.byKey(const ValueKey('coordinate-import-notes'));
    await tester.ensureVisible(notesDropdown);
    await tester.tap(notesDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('field notes (column 3)').last);
    await tester.pumpAndSettle();

    expect(changedField, CoordinateImportField.notes);
    expect(changedColumn, 2);

    final reviewButton = find.text('Review coordinates');
    await tester.ensureVisible(reviewButton);
    await tester.tap(reviewButton);
    expect(reviewed, isTrue);
  });
}
