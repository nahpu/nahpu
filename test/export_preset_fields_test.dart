import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/settings/export_preset_fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  late Database db;

  setUp(() {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => db.close());

  testWidgets('list mapping presents output modes and indexed preview',
      (tester) async {
    const preset = ExportPresetModel(
      recordType: RecordType.site,
      specimenRecordType: SpecimenRecordType.allTaxa,
      headerFormat: ExportHeaderFormat.fieldName,
      mappings: [
        ExportFieldMapping(
          expression: '[site::habitatType]',
          textType: 'list',
          formatOption: 'comma',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: ExportPresetFieldsScreen(preset: preset),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Apply source fields'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);

    await tester.tap(find.byTooltip('Customize'));
    await tester.pumpAndSettle();

    expect(find.text('List output'), findsOneWidget);
    expect(find.text('One column'), findsOneWidget);
    expect(find.text('Indexed columns'), findsOneWidget);
    expect(find.text('Output example'), findsOneWidget);

    await tester.tap(find.text('Indexed columns'));
    await tester.pumpAndSettle();

    expect(find.text('Indexed column names'), findsOneWidget);
    expect(find.text('habitatType_1'), findsOneWidget);
    expect(find.text('habitatType_2'), findsOneWidget);
    expect(find.text('habitatType_3'), findsOneWidget);
  });
}
