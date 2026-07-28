import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/components/project_form.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_registry.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/export_columns.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('new projects can select the fossils project type', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({catalogFmtPrefKey: 'Mammals'});
    final preferences = await SharedPreferences.getInstance();
    final selectedFormats = <CatalogFmt?>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          home: Scaffold(
            body: TaxonGroupFields(onCatalogFmtChanged: selectedFormats.add),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Project type'), findsOneWidget);
    expect(find.text('Main taxon group'), findsOneWidget);

    await tester.tap(find.text('Extant taxa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fossils').last);
    await tester.pumpAndSettle();

    expect(selectedFormats.last, CatalogFmt.fossils);
    expect(find.text('Main taxon group'), findsNothing);
  });

  test('fossil exports use the mammal attribute compatibility fields', () {
    final columns = getAvailableExportColumns(
      recordType: RecordType.specimenRecord,
      specimenRecordType: SpecimenRecordType.fossils,
    );

    expect(columns, containsAll(mammalAttributeExportList));
    expect(
      matchCatalogFmtToRecordType(CatalogFmt.fossils),
      SpecimenRecordType.fossils,
    );
    expect(matchTaxonGroupToRecordType('Fossils'), SpecimenRecordType.fossils);
    expect(matchRecordTypeToTaxonGroup(SpecimenRecordType.fossils), 'Fossils');
  });

  testWidgets('collection record counts retain all four record types', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CollectionRecordCountsView(
            sites: 1,
            events: 2,
            specimens: 3,
            narratives: 4,
          ),
        ),
      ),
    );

    final richText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(CollectionRecordCountsView),
        matching: find.byType(RichText),
      ),
    );
    expect(
      richText.text.toPlainText(),
      '1 sites\n2 events\n3 specimens\n4 narrative',
    );
  });
}
