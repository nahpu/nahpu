import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/templates/canvas_viewport_service.dart';

void main() {
  group('TemplateCanvasViewportService.fitScale', () {
    test('a phone-width workspace fits a letter page by its width', () {
      final scale = TemplateCanvasViewportService.fitScale(
        viewport: const Size(390, 600),
        templateWidthMm: 216,
        templateHeightMm: 279,
      );

      // (390 - 2 × 16) / 216 is smaller than (600 - 16 - 72) / 279.
      expect(scale, closeTo(358 / 216, 0.0001));
    });

    test('a wide workspace fits a short label by its height', () {
      final scale = TemplateCanvasViewportService.fitScale(
        viewport: const Size(1000, 200),
        templateWidthMm: 100,
        templateHeightMm: 34,
      );

      expect(scale, closeTo((200 - 16 - 72) / 34, 0.0001));
    });

    test('falls back to 1 without a usable size', () {
      expect(
        TemplateCanvasViewportService.fitScale(
          viewport: const Size(390, 600),
          templateWidthMm: 0,
          templateHeightMm: 279,
        ),
        1,
      );
      expect(
        TemplateCanvasViewportService.fitScale(
          viewport: const Size(20, 60),
          templateWidthMm: 216,
          templateHeightMm: 279,
        ),
        1,
      );
    });
  });

  test('centering moves the canvas centre to the middle of the fit area', () {
    final translation = TemplateCanvasViewportService.centeringTranslation(
      viewport: const Size(390, 600),
      canvasCenter: const Offset(267, 300),
    );

    // Fit area is (16, 16) to (374, 528), centred at (195, 272).
    expect(translation, const Offset(-72, -28));
  });
}
