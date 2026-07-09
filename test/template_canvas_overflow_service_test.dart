import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/template_canvas_overflow_service.dart';

void main() {
  test('adds right and bottom hit padding for oversized text boxes', () {
    const page = TemplatePage(
      customTexts: [
        CustomTextElement(
          id: 'ct_1',
          text: 'large text box',
          xMm: 80,
          yMm: 45,
          maxWidthMm: 50,
          heightMm: 25,
        ),
      ],
    );

    final padding = calculateTemplateCanvasOverflowPadding(
      page: page,
      templateWidthMm: 100,
      templateHeightMm: 60,
      scalePxPerMm: 2,
      basePaddingPx: 10,
    );

    expect(padding.left, 20);
    expect(padding.top, 20);
    expect(padding.right, 70);
    expect(padding.bottom, 30);
  });

  test('accounts for rotated element bounds outside the canvas', () {
    const page = TemplatePage(
      customShapes: [
        CustomShapeElement(
          id: 'shape_1',
          xMm: 90,
          yMm: 20,
          widthMm: 40,
          heightMm: 20,
          shapeType: 'rect',
          rotationDegrees: 90,
        ),
      ],
    );

    final padding = calculateTemplateCanvasOverflowPadding(
      page: page,
      templateWidthMm: 100,
      templateHeightMm: 60,
      scalePxPerMm: 1,
      basePaddingPx: 8,
    );

    expect(padding.right, 28);
    expect(padding.left, 16);
    expect(padding.top, 16);
    expect(padding.bottom, 16);
  });

  test('accounts for widgets shifted by dynamic text growth', () {
    const page = TemplatePage(
      customTexts: [
        CustomTextElement(
          id: 'table',
          text: '[coordinate::*]',
          xMm: 0,
          yMm: 0,
          heightMm: 10,
          isDynamic: true,
        ),
      ],
      customShapes: [
        CustomShapeElement(
          id: 'below-table',
          xMm: 0,
          yMm: 45,
          widthMm: 20,
          heightMm: 10,
          shapeType: 'rect',
        ),
      ],
    );

    final padding = calculateTemplateCanvasOverflowPadding(
      page: page,
      templateWidthMm: 100,
      templateHeightMm: 60,
      scalePxPerMm: 1,
      basePaddingPx: 10,
      dynamicTextContentHeightMmById: const {'table': 30},
    );

    expect(padding.bottom, 25);
  });
}
