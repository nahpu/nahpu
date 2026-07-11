import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/styles/themes.dart';

void main() {
  const primary = Color(0xFF1B9E77);
  const secondary = Color(0xFFF1BE29);

  group('NahpuTheme', () {
    test('uses fixed NAHPU brand colors in the light scheme', () {
      final theme = NahpuTheme.lightTheme();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, primary);
      expect(theme.colorScheme.secondary, secondary);
    });

    test('uses fixed NAHPU brand colors in the dark scheme', () {
      final theme = NahpuTheme.darkTheme();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, primary);
      expect(theme.colorScheme.secondary, secondary);
    });
  });
}
