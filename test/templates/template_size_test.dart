import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_size_selector.dart';

void main() {
  setUp(() {
    // Set a larger screen size so everything is visible and clickable in test runs
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(1024, 768);
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
  });

  group('TemplatePreset Unit Tests', () {
    test('standard paper presets have correct values', () {
      final a4 = globalPaperPresets.firstWhere((p) => p.name == 'A4');
      expect(a4.widthMm, 210.0);
      expect(a4.heightMm, 297.0);
      expect(a4.dimensionsIn, '8.27 × 11.69 in');

      final letter = globalPaperPresets.firstWhere((p) => p.name == 'Letter');
      expect(letter.widthMm, 215.9);
      expect(letter.heightMm, 279.4);
    });

    test('cryotube presets have correct values', () {
      final vial = cryotubePresets.firstWhere(
        (p) => p.name == '1.5 - 2.0 mL Vial Side',
      );
      expect(vial.widthMm, 33.0);
      expect(vial.heightMm, 13.0);
      expect(vial.dimensionsIn, '1.30 × 0.50 in');
    });

    test('specimen curation presets have correct values', () {
      final tag = specimenPresets.firstWhere(
        (p) => p.name == 'Vertebrate Specimen Tag (Medium)',
      );
      expect(tag.widthMm, 100.0);
      expect(tag.heightMm, 34.0);
      expect(tag.dimensionsIn, '3.94 × 1.34 in');
    });
  });

  group('TemplateSizeDialog Widget Tests', () {
    testWidgets('renders dialog with standard tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TemplateSizeDialog(currentWidth: 50.0, currentHeight: 25.0),
          ),
        ),
      );

      // Verify header title
      expect(find.text('Template Size Preset'), findsOneWidget);

      // Verify tabs exist
      expect(find.text('Paper'), findsOneWidget);
      expect(find.text('Cryotubes'), findsOneWidget);
      expect(find.text('Curation'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);

      // Verify Standard Paper list items are visible
      expect(find.text('A4'), findsOneWidget);
      expect(find.text('Letter'), findsOneWidget);

      // Switch to Cryotubes tab
      await tester.tap(find.text('Cryotubes'));
      await tester.pumpAndSettle();

      // Verify Cryotube items render
      expect(find.text('1.5 - 2.0 mL Vial Side'), findsOneWidget);
    });

    testWidgets('Custom Size validation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TemplateSizeDialog(currentWidth: 50.0, currentHeight: 25.0),
          ),
        ),
      );

      // Switch to Custom tab
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();

      // Verify inputs exist by key
      expect(find.byKey(const Key('custom-width-field')), findsOneWidget);
      expect(find.byKey(const Key('custom-height-field')), findsOneWidget);

      // Try typing invalid values
      await tester.enterText(find.byKey(const Key('custom-width-field')), '5');
      await tester.enterText(
        find.byKey(const Key('custom-height-field')),
        '600',
      );

      await tester.tap(find.byKey(const Key('custom-apply-button')));
      await tester.pumpAndSettle();

      // Verify validation errors are shown
      expect(find.text('Must be between 10 and 500'), findsNWidgets(2));
    });
  });
}
