import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/styles/design_tokens.dart';

void main() {
  group('NAHPU design tokens', () {
    test('use positive even-number values', () {
      const values = <double>[
        NahpuSpacing.xxs,
        NahpuSpacing.xs,
        NahpuSpacing.sm,
        NahpuSpacing.md,
        NahpuSpacing.lg,
        NahpuSpacing.xl,
        NahpuSpacing.xxl,
        NahpuSpacing.xxxl,
        NahpuSpacing.display,
        NahpuSpacing.displayLarge,
        NahpuRadius.xs,
        NahpuRadius.sm,
        NahpuRadius.md,
        NahpuRadius.lg,
        NahpuRadius.xl,
        NahpuStroke.regular,
        NahpuElevation.low,
        NahpuElevation.medium,
        NahpuElevation.high,
        NahpuElevation.overlay,
        NahpuControlSize.indicator,
        NahpuControlSize.iconSmall,
        NahpuControlSize.iconMedium,
        NahpuControlSize.icon,
        NahpuControlSize.iconLarge,
        NahpuControlSize.control,
        NahpuControlSize.touchTarget,
        NahpuControlSize.prominent,
        NahpuBreakpoints.compact,
        NahpuBreakpoints.projectWizardRail,
        NahpuBreakpoints.desktop,
        NahpuBreakpoints.laptop,
        NahpuContentWidth.form,
        NahpuContentWidth.projectForm,
        NahpuContentWidth.projectWizard,
        NahpuContentWidth.home,
        NahpuContentWidth.settings,
      ];

      for (final value in values) {
        expect(value, greaterThan(0));
        expect(value % 2, 0, reason: '$value is not divisible by two');
      }
    });

    test('exclude legacy spacing and radius values', () {
      const spacing = <double>[
        NahpuSpacing.xxs,
        NahpuSpacing.xs,
        NahpuSpacing.sm,
        NahpuSpacing.md,
        NahpuSpacing.lg,
        NahpuSpacing.xl,
        NahpuSpacing.xxl,
        NahpuSpacing.xxxl,
        NahpuSpacing.display,
        NahpuSpacing.displayLarge,
      ];
      const radii = <double>[
        NahpuRadius.xs,
        NahpuRadius.sm,
        NahpuRadius.md,
        NahpuRadius.lg,
        NahpuRadius.xl,
      ];

      expect(spacing, isNot(contains(5)));
      expect(spacing, isNot(contains(10)));
      expect(radii, isNot(contains(5)));
      expect(radii, isNot(contains(10)));
      expect(spacing.toSet().length, spacing.length);
      expect(radii.toSet().length, radii.length);
    });
  });
}
