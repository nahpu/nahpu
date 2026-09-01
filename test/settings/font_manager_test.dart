import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/presets/font_manager.dart';
import 'package:nahpu/screens/shared/fonts/font_preview.dart';
import 'package:nahpu/services/providers/fonts.dart';
import 'package:nahpu/services/templates/font_registry.dart';
import 'package:nahpu/services/types/user_fonts.dart';

void main() {
  final userFont = UserFont(
    id: 'font-1',
    family: 'Field Sans',
    addedAt: DateTime.utc(2026, 9, 1),
    variants: const [
      UserFontVariant(
        fileName: 'Field_Sans-Regular.ttf',
        subfamily: 'Regular',
        weight: 400,
        italic: false,
        byteSize: 2048,
      ),
    ],
  );

  Future<void> pumpManager(
    WidgetTester tester, {
    List<UserFont> userFonts = const [],
    Size size = const Size(1200, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fontRegistryProvider.overrideWith(
            () => _FakeFontRegistryNotifier(FontRegistry(userFonts: userFonts)),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: FontManager())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists the bundled families', (tester) async {
    await pumpManager(tester);

    expect(find.text('Bundled with NAHPU'), findsOneWidget);
    expect(find.text('Merriweather'), findsWidgets);
    expect(find.text('Plus Jakarta Sans'), findsWidgets);
    expect(find.text('Installed by you'), findsNothing);
  });

  testWidgets('previews the selected font with every sample text', (
    tester,
  ) async {
    await pumpManager(tester);

    expect(find.byType(FontSamplePreview), findsOneWidget);
    expect(kFontPreviewSamples, hasLength(3));
    for (final sample in kFontPreviewSamples) {
      expect(find.textContaining(sample), findsWidgets, reason: sample);
    }
  });

  test('the samples carry their intended details', () {
    // These read as prose in the preview panel, so guard the specifics that
    // make each one useful rather than the whole string.
    expect(kFontPreviewSampleA, contains('in one sitting'));
    expect(kFontPreviewSampleA, contains('I definitely should not have eaten'));
    expect(kFontPreviewSampleB, contains('northern Sumatra'));
    expect(kFontPreviewSampleC, contains('github.com/nahpu/nahpu/issues'));
    expect(kFontPreviewSampleC, contains('a quick brown fox'));
  });

  testWidgets('shows installed fonts in their own section with a delete '
      'action', (tester) async {
    await pumpManager(tester, userFonts: [userFont]);

    expect(find.text('Installed by you'), findsOneWidget);
    expect(find.text('Field Sans'), findsWidgets);
    expect(find.byTooltip('Delete font'), findsOneWidget);
  });

  testWidgets('bundled fonts cannot be deleted', (tester) async {
    await pumpManager(tester);

    expect(find.byTooltip('Delete font'), findsNothing);
  });

  testWidgets('searching filters the list', (tester) async {
    await pumpManager(tester, userFonts: [userFont]);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search fonts'),
      'libertinus',
    );
    await tester.pumpAndSettle();

    expect(find.text('Libertinus Sans'), findsWidgets);
    expect(find.text('Field Sans'), findsNothing);
    expect(find.text('Merriweather'), findsNothing);
  });

  testWidgets('an unmatched search reports that nothing matched', (
    tester,
  ) async {
    await pumpManager(tester);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search fonts'),
      'nothing-matches-this',
    );
    await tester.pumpAndSettle();

    expect(find.text('No fonts match your search'), findsOneWidget);
  });

  testWidgets('selecting a font moves the preview to it', (tester) async {
    await pumpManager(tester, userFonts: [userFont]);

    await tester.tap(find.text('Field Sans').first);
    await tester.pumpAndSettle();

    final preview = tester.widget<FontSamplePreview>(
      find.byType(FontSamplePreview),
    );
    expect(preview.family, 'Field Sans');
    expect(preview.showStyles, isTrue);
  });

  testWidgets('narrow layouts split the list and preview into tabs', (
    tester,
  ) async {
    await pumpManager(tester, size: const Size(500, 900));

    expect(find.text('Fonts'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
  });
}

class _FakeFontRegistryNotifier extends FontRegistryNotifier {
  _FakeFontRegistryNotifier(this.registry);

  final FontRegistry registry;

  @override
  Future<FontRegistry> build() async => registry;
}
