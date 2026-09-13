import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/presets/document_presets.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/types/export.dart';

import '../data/specimen_part_fixture.dart';

void main() {
  testWidgets('the preview part picker follows each toggle while it is open', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 900);
    addTearDown(tester.view.reset);
    final changes = <Set<String>>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          specimenPartEntryProvider.overrideWith(
            (ref) async => [
              specimenPartFixture(id: 1, type: 'Blood'),
              specimenPartFixture(id: 2, type: 'Liver'),
            ],
          ),
        ],
        child: MaterialApp(
          home: PreviewRecordSelectionScreen(
            selectedUuids: const {},
            recordType: RecordType.specimenParts,
            onSelectionChanged: changes.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    bool? checked(String title) => tester
        .widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, title))
        .value;

    await tester.tap(find.text('T-1 · Blood'));
    await tester.pumpAndSettle();
    expect(checked('T-1 · Blood'), isTrue);

    await tester.tap(find.text('T-2 · Liver'));
    await tester.pumpAndSettle();
    expect(checked('T-1 · Blood'), isTrue);
    expect(checked('T-2 · Liver'), isTrue);
    expect(changes.last, hasLength(2));

    await tester.tap(find.text('T-1 · Blood'));
    await tester.pumpAndSettle();
    expect(checked('T-1 · Blood'), isFalse);
    expect(find.text('Showing 2 of 2 parts · Selected 1'), findsOneWidget);
    expect(changes, hasLength(3));
  });
}
