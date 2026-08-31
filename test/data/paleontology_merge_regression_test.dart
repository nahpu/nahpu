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
                value: CatalogFmt.mammals,
                onChanged: (value) => selected = value,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mammals'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fossils').last);
      await tester.pumpAndSettle();
      expect(selected, CatalogFmt.fossils);
      expect(preferences.getString(catalogFmtPrefKey), 'Mammals');
    },
  );

  test('fossil mappings preserve existing catalog and export enum codes', () {
    expect(CatalogFmt.arthropods.index, 3);
    expect(SpecimenRecordType.allTaxa.index, 6);
    expect(
      matchCatalogFmtToRecordType(CatalogFmt.fossils),
      SpecimenRecordType.fossils,
    );
    expect(matchTaxonGroupToRecordType('Fossils'), SpecimenRecordType.fossils);
    expect(matchRecordTypeToTaxonGroup(SpecimenRecordType.fossils), 'Fossils');
    expect(matchTaxonGroupToCatFmt('Fossils'), CatalogFmt.fossils);
  });
}
