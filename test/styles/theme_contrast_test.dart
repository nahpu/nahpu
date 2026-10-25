import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/styles/themes.dart';

/// WCAG 2.2 AA minimum for body text (1.4.3).
const _textContrast = 4.5;

/// WCAG 2.2 AA minimum for UI components and graphics (1.4.11).
const _graphicContrast = 3.0;

void main() {
  for (final theme in [NahpuTheme.lightTheme(), NahpuTheme.darkTheme()]) {
    final scheme = theme.colorScheme;
    final surfaces = {
      'surface': scheme.surface,
      'surfaceContainerLow': scheme.surfaceContainerLow,
      'surfaceContainer': scheme.surfaceContainer,
      'surfaceContainerHighest': scheme.surfaceContainerHighest,
    };

    group('${scheme.brightness.name} theme contrast', () {
      test('text roles read at 4.5:1 on every surface', () {
        final textRoles = {
          'onSurface': scheme.onSurface,
          'onSurfaceVariant': scheme.onSurfaceVariant,
          'primary': scheme.primary,
          'secondary': scheme.secondary,
          'tertiary': scheme.tertiary,
          'error': scheme.error,
          'pendingChange': NahpuTheme.pendingChange(scheme),
          'warningText': NahpuTheme.warningText(scheme),
        };
        for (final role in textRoles.entries) {
          for (final surface in surfaces.entries) {
            _expectContrast(
              role.value,
              surface.value,
              _textContrast,
              '${role.key} on ${surface.key}',
            );
          }
        }
      });

      test('on-colors read at 4.5:1 on their fills', () {
        final pairs = {
          'onPrimary/primary': (scheme.onPrimary, scheme.primary),
          'onSecondary/secondary': (scheme.onSecondary, scheme.secondary),
          'onTertiary/tertiary': (scheme.onTertiary, scheme.tertiary),
          'onError/error': (scheme.onError, scheme.error),
          'onPrimaryContainer/primaryContainer': (
            scheme.onPrimaryContainer,
            scheme.primaryContainer,
          ),
          'onSecondaryContainer/secondaryContainer': (
            scheme.onSecondaryContainer,
            scheme.secondaryContainer,
          ),
          'onTertiaryContainer/tertiaryContainer': (
            scheme.onTertiaryContainer,
            scheme.tertiaryContainer,
          ),
          'onErrorContainer/errorContainer': (
            scheme.onErrorContainer,
            scheme.errorContainer,
          ),
          'onInverseSurface/inverseSurface': (
            scheme.onInverseSurface,
            scheme.inverseSurface,
          ),
          'inversePrimary/inverseSurface': (
            scheme.inversePrimary,
            scheme.inverseSurface,
          ),
          'onPrimaryAction/primaryAction': (
            NahpuTheme.onPrimaryAction,
            NahpuTheme.primaryAction,
          ),
        };
        for (final pair in pairs.entries) {
          final (foreground, background) = pair.value;
          _expectContrast(foreground, background, _textContrast, pair.key);
        }
      });

      test('outlines and graphics read at 3:1 on every surface', () {
        final graphics = {
          'outline': scheme.outline,
          'focusedMapMarker': NahpuTheme.focusedMapMarker(scheme),
          for (final (i, color) in NahpuTheme.networkTypeColors(scheme).indexed)
            'networkType[$i]': color,
        };
        for (final graphic in graphics.entries) {
          for (final surface in surfaces.entries) {
            _expectContrast(
              graphic.value,
              surface.value,
              _graphicContrast,
              '${graphic.key} on ${surface.key}',
            );
          }
        }
      });
    });
  }

  test('Red List pills read at 4.5:1', () {
    const categories = ['EX', 'EW', 'CR', 'EN', 'VU', 'NT', 'LC', 'DD'];
    for (final category in categories) {
      final background = matchRedListCategoryColor(category);
      // Mirrors the label color choice in RedListCategoryPill.
      final text = background.computeLuminance() > 0.3
          ? Colors.black
          : Colors.white;
      _expectContrast(text, background, _textContrast, category);
    }
  });
}

void _expectContrast(
  Color foreground,
  Color background,
  double minimum,
  String reason,
) {
  final ratio = _contrastRatio(foreground, background);
  expect(
    ratio,
    greaterThanOrEqualTo(minimum),
    reason: '$reason is ${ratio.toStringAsFixed(2)}:1',
  );
}

double _contrastRatio(Color a, Color b) {
  final lumA = a.computeLuminance();
  final lumB = b.computeLuminance();
  return (math.max(lumA, lumB) + 0.05) / (math.min(lumA, lumB) + 0.05);
}
