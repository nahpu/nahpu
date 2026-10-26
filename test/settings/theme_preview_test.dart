import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/application/application_settings.dart';
import 'package:nahpu/screens/settings/application/theme_preview.dart';
import 'package:nahpu/screens/shared/common/tropical_mountains.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/styles/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The theme page offers each mode as a skyline preview card.
void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpThemeSettings(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: NahpuTheme.lightTheme(),
          darkTheme: NahpuTheme.darkTheme(),
          themeMode: ThemeMode.dark,
          home: const ThemeSettings(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool isSelected(WidgetTester tester, String label) => tester
      .widget<ThemePreviewCard>(find.widgetWithText(ThemePreviewCard, label))
      .isSelected;

  testWidgets('shows a skyline card per mode with system selected', (
    tester,
  ) async {
    await pumpThemeSettings(tester, const Size(1000, 1200));

    expect(find.byType(ThemePreviewCard), findsNWidgets(3));
    // Light and dark draw one skyline each; system draws both halves.
    expect(find.byType(TropicalMountainsBackdrop), findsNWidgets(4));
    expect(isSelected(tester, 'System'), isTrue);
    expect(isSelected(tester, 'Light'), isFalse);
    expect(isSelected(tester, 'Dark'), isFalse);
  });

  testWidgets('previews keep their own theme under the dark app theme', (
    tester,
  ) async {
    await pumpThemeSettings(tester, const Size(1000, 1200));

    final lightCard = find.widgetWithText(ThemePreviewCard, 'Light');
    final skylineTheme = Theme.of(
      tester.element(
        find
            .descendant(
              of: lightCard,
              matching: find.byType(TropicalMountainsBackdrop),
            )
            .first,
      ),
    );
    expect(skylineTheme.brightness, Brightness.light);
  });

  testWidgets('tapping a card saves and selects that mode', (tester) async {
    await pumpThemeSettings(tester, const Size(1000, 1200));

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(prefs.getString(themeModePrefKey), 'dark');
    expect(isSelected(tester, 'Dark'), isTrue);
    expect(isSelected(tester, 'System'), isFalse);
  });

  testWidgets('three cards fit side by side on a phone', (tester) async {
    await pumpThemeSettings(tester, const Size(360, 800));

    expect(find.byType(ThemePreviewCard), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
