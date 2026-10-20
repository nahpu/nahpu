import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/components/project_form.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'fossils are selectable without changing a project draft globally',
    (tester) async {
      SharedPreferences.setMockInitialValues({catalogFmtPrefKey: 'Mammals'});
      final preferences = await SharedPreferences.getInstance();
      CatalogFmt? selected;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [settingProvider.overrideWithValue(preferences)],
          child: MaterialApp(
            home: Scaffold(
              body: TaxonGroupFields(
                value: CatalogFmt.mammalogy,
                onChanged: (value) => selected = value,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mammalogy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Paleontology').last);
      await tester.pumpAndSettle();
      expect(selected, CatalogFmt.paleontology);
      expect(preferences.getString(catalogFmtPrefKey), 'Mammals');
    },
  );

  test('fossil mappings preserve existing catalog and export enum codes', () {
    expect(CatalogFmt.invertebrateZoology.index, 3);
    expect(SpecimenRecordType.allTaxa.index, 7);
    expect(
      matchCatalogFmtToRecordType(CatalogFmt.paleontology),
      SpecimenRecordType.fossils,
    );
    expect(matchTaxonGroupToRecordType('Fossils'), SpecimenRecordType.fossils);
    expect(matchRecordTypeToTaxonGroup(SpecimenRecordType.fossils), 'Fossils');
    expect(matchTaxonGroupToCatFmt('Fossils'), CatalogFmt.paleontology);
  });
}
