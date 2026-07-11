import 'package:flutter/material.dart';
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
  });
}
