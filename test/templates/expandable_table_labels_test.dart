import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/exports/components/columns.dart';
import 'package:nahpu/screens/shared/document/column_picker.dart';
import 'package:nahpu/screens/templates/components/properties/text_element_editor.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/templates/print_specimen_table_columns.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  late Database database;

  setUp(() {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => database.close());

  test('database table labels match the table column selector style', () {
    expect(databaseTableDisplayTitle('collEvent'), 'Coll Event');
    expect(databaseTableDisplayTitle('specimenPart'), 'Specimen Part');
    expect(databaseTableDisplayTitle('mammalAttribute'), 'Mammal Attribute');
    expect(databaseTableDisplayTitle('associatedData'), 'Associated Data');
  });

  testWidgets('table column selector uses bold humanized table names', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: SpecimenTableColumnSelector(selectedColumns: []),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    _expectBoldTableHeader(tester, 'Associated Data');
    expect(find.text('ASSOCIATED DATA'), findsNothing);
  });

  testWidgets('template field list uses bold humanized table names', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: AvailableFieldsSection(
                recordType: RecordType.collEvent,
                onSelectField: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Insert Field'));
    await tester.pumpAndSettle();

    _expectBoldTableHeader(tester, 'Coll Event');
    expect(find.text('COLLEVENT'), findsNothing);
  });

  testWidgets('export column list uses bold humanized table names', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ColumnSelectionList(
            availableColumns: const [
              'collEvent::collEventID',
              'collEvent::siteID',
            ],
            selectedColumns: const ['collEvent::collEventID'],
            onSelectionChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    _expectBoldTableHeader(tester, 'Coll Event');
    expect(find.text('COLLEVENT'), findsNothing);
  });
}

void _expectBoldTableHeader(WidgetTester tester, String label) {
  final header = find.text(label, skipOffstage: false);
  expect(header, findsOneWidget);
  expect(tester.widget<Text>(header).style?.fontWeight, FontWeight.bold);
}
