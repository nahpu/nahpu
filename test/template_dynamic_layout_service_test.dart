import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/template_dynamic_layout_service.dart';

void main() {
  const growingTable = CustomTextElement(
    id: 'table',
    text: '[coordinate::*]',
    xMm: 5,
    yMm: 10,
    heightMm: 8,
    textType: 'nestedList',
    isDynamic: true,
  );

  test('shifts every lower widget by dynamic content growth', () {
    final shift = TemplateDynamicLayoutService.verticalShiftMm(
      texts: const [growingTable],
      targetYmm: 25,
      contentHeightMmByTextId: const {'table': 18},
    );

    expect(shift, 10);
  });

  test('does not shift elements above or at a dynamic text origin', () {
    for (final targetY in [0.0, 10.0]) {
      final shift = TemplateDynamicLayoutService.verticalShiftMm(
        texts: const [growingTable],
        targetYmm: targetY,
        contentHeightMmByTextId: const {'table': 18},
      );

      expect(shift, 0);
    }
  });

  test('does not let a dynamic text shift itself', () {
    final shift = TemplateDynamicLayoutService.verticalShiftMm(
      texts: const [growingTable],
      targetYmm: 25,
      excludeTextId: 'table',
      contentHeightMmByTextId: const {'table': 18},
    );

    expect(shift, 0);
  });

  test('converts a flowed Y coordinate back to its saved position', () {
    final savedY = TemplateDynamicLayoutService.savedYmmForRenderedY(
      texts: const [growingTable],
      renderedYmm: 35,
      contentHeightMmByTextId: const {'table': 18},
    );

    expect(savedY, closeTo(25, 0.001));
  });

  test('ignores non-dynamic and non-rendered text', () {
    const staticText = CustomTextElement(
      id: 'static',
      text: 'Static',
      xMm: 0,
      yMm: 0,
      heightMm: 1,
    );
    const hiddenDynamic = CustomTextElement(
      id: 'hidden',
      text: 'Hidden',
      xMm: 0,
      yMm: 0,
      heightMm: 1,
      isDynamic: true,
      isVisible: false,
    );

    final shift = TemplateDynamicLayoutService.verticalShiftMm(
      texts: const [staticText, hiddenDynamic],
      targetYmm: 5,
      contentHeightMmByTextId: const {'static': 10, 'hidden': 10},
    );

    expect(shift, 0);
  });
}
