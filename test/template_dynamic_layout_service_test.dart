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

  test('shifts every lower widget below dynamic content plus the gap', () {
    final shift = TemplateDynamicLayoutService.verticalShiftMm(
      texts: const [growingTable],
      targetYmm: 25,
      contentHeightMmByTextId: const {'table': 18},
    );

    expect(shift, 5);
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

    expect(savedY, closeTo(35, 0.001));
  });

  test('clamps a target coordinate inside a dynamic clearance gap', () {
    final savedY = TemplateDynamicLayoutService.savedYmmForRenderedY(
      texts: const [growingTable],
      renderedYmm: 20,
      contentHeightMmByTextId: const {'table': 18},
    );

    expect(savedY, closeTo(11.0, 0.001));
  });

  test('flows each lower dynamic text after the previous rendered bottom', () {
    const secondText = CustomTextElement(
      id: 'second',
      text: '[second]',
      xMm: 5,
      yMm: 22,
      heightMm: 5,
      isDynamic: true,
    );
    const thirdText = CustomTextElement(
      id: 'third',
      text: '[third]',
      xMm: 5,
      yMm: 30,
      heightMm: 5,
      isDynamic: true,
    );

    final secondShift = TemplateDynamicLayoutService.verticalShiftMm(
      texts: const [growingTable, secondText, thirdText],
      targetYmm: secondText.yMm,
      excludeTextId: secondText.id,
      contentHeightMmByTextId: const {
        'table': 18,
        'second': 10,
        'third': 6,
      },
    );
    final thirdShift = TemplateDynamicLayoutService.verticalShiftMm(
      texts: const [growingTable, secondText, thirdText],
      targetYmm: thirdText.yMm,
      excludeTextId: thirdText.id,
      contentHeightMmByTextId: const {
        'table': 18,
        'second': 10,
        'third': 6,
      },
    );

    expect(secondText.yMm + secondShift, 30);
    expect(thirdText.yMm + thirdShift, 42);
  });

  test('keeps dynamic text at the same saved Y layered', () {
    const layeredText = CustomTextElement(
      id: 'layered',
      text: '[layered]',
      xMm: 5,
      yMm: 10,
      isDynamic: true,
    );

    final shift = TemplateDynamicLayoutService.verticalShiftMm(
      texts: const [growingTable, layeredText],
      targetYmm: layeredText.yMm,
      excludeTextId: layeredText.id,
      contentHeightMmByTextId: const {'table': 18, 'layered': 20},
    );

    expect(shift, 0);
  });

  test('keeps elements within one millimeter in the same visual row', () {
    final alignedShift = TemplateDynamicLayoutService.verticalShiftMm(
      texts: const [growingTable],
      targetYmm: 10.9,
      contentHeightMmByTextId: const {'table': 18},
    );
    final lowerRowShift = TemplateDynamicLayoutService.verticalShiftMm(
      texts: const [growingTable],
      targetYmm: 11.01,
      contentHeightMmByTextId: const {'table': 18},
    );

    expect(alignedShift, 0);
    expect(lowerRowShift, greaterThan(0));
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
