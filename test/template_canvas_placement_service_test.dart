import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/templates/canvas_placement_service.dart';

void main() {
  group('TemplateCanvasPlacementService.centeredPosition', () {
    test('centers an element using the active template dimensions', () {
      final position = TemplateCanvasPlacementService.centeredPosition(
        templateWidthMm: 85.6,
        templateHeightMm: 54,
        elementWidthMm: 10,
        elementHeightMm: 10,
      );

      expect(position.dx, closeTo(37.8, 0.001));
      expect(position.dy, 22);
    });

    test('does not position oversized elements outside the template', () {
      final position = TemplateCanvasPlacementService.centeredPosition(
        templateWidthMm: 8,
        templateHeightMm: 10,
        elementWidthMm: 10,
        elementHeightMm: 6,
      );

      expect(position.dx, 0);
      expect(position.dy, 2);
    });
  });
}
