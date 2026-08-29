import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/taxonomy/add_taxon.dart';
import 'package:nahpu/services/types/controllers.dart';

void main() {
  test('new taxon controllers default to species', () {
    final ctr = TaxonRegistryCtrModel.empty();
    addTearDown(ctr.dispose);

    expect(ctr.taxonRankCtr, 'species');
  });

  testWidgets(
    'manual add taxon uses the shared segmented screen and sections',
    (tester) async {
      _setViewport(tester, const Size(1000, 900));

      await tester.pumpWidget(const MaterialApp(home: AddTaxon()));
      await tester.pumpAndSettle();

      expect(find.text('Manual'), findsOneWidget);
      expect(find.text('Classification'), findsOneWidget);
      expect(find.text('Additional details'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Import'), findsOneWidget);
    },
  );

  testWidgets('compact import mode exposes setup and preview tabs', (
    tester,
  ) async {
    _setViewport(tester, const Size(390, 844));

    await tester.pumpWidget(const MaterialApp(home: AddTaxon()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Setup'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Select file'), findsOneWidget);

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();
    expect(find.textContaining('map its columns'), findsOneWidget);
  });
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
