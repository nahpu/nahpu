import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/styles/themes.dart';

void main() {
  const canopyTeal = Color(0xFF1B9E77);
  const mistySage = Color(0xFF4D625B);
  const mossShadow = Color(0xFF1E352F);

  group('NahpuTheme', () {
    test('uses fixed NAHPU brand colors in the light scheme', () {
      final theme = NahpuTheme.lightTheme();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, canopyTeal);
      expect(theme.colorScheme.secondary, mistySage);
    });

    test('uses fixed NAHPU brand colors in the dark scheme', () {
      final theme = NahpuTheme.darkTheme();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, canopyTeal);
      expect(theme.colorScheme.secondary, mistySage);
      expect(theme.colorScheme.tertiary, mossShadow);
    });

    test('exposes the light surface for the template editor workspace', () {
      expect(
        NahpuTheme.templateEditorWorkspaceSurface,
        NahpuTheme.lightTheme().colorScheme.surface,
      );
    });

    testWidgets('standard cards are flat in light and dark NAHPU themes',
        (tester) async {
      for (final theme in [NahpuTheme.lightTheme(), NahpuTheme.darkTheme()]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(body: Card(child: SizedBox(height: 20))),
          ),
        );

        final material = tester.widget<Material>(
          find.descendant(
              of: find.byType(Card), matching: find.byType(Material)),
        );
        expect(material.elevation, 0);
        expect(material.shadowColor, Colors.transparent);
        expect(material.surfaceTintColor, Colors.transparent);
      }
    });
  });
}
