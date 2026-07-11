import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/styles/themes.dart';

void main() {
  const _canopyTeal = Color(0xFF1B9E77);
  const _mistySage = Color(0xFF4D625B);
  const _mossShadow = Color(0xFF1E352F);

  group('NahpuTheme', () {
    test('uses fixed NAHPU brand colors in the light scheme', () {
      final theme = NahpuTheme.lightTheme();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, _canopyTeal);
      expect(theme.colorScheme.secondary, _mistySage);
      ;
    });

    test('uses fixed NAHPU brand colors in the dark scheme', () {
      final theme = NahpuTheme.darkTheme();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, _canopyTeal);
      expect(theme.colorScheme.secondary, _mistySage);
      expect(theme.colorScheme.tertiary, _mossShadow);
    });
  });
}
