import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/templates/canvas_snap_service.dart';
import 'package:nahpu/screens/templates/template_editor_math.dart';

void main() {
  group('angle conversion helpers', () {
    test('convert degrees to radians and back', () {
      expect(degreesToRadians(0), 0);
      expect(degreesToRadians(180), closeTo(math.pi, 1e-9));
      expect(radiansToDegrees(math.pi / 2), closeTo(90, 1e-9));
      expect(radiansToDegrees(degreesToRadians(315)), closeTo(315, 1e-9));
    });

    test('normalize radians delta across wrap boundary', () {
      expect(
        normalizeRadiansDelta(math.pi + 0.25),
        closeTo(-math.pi + 0.25, 1e-9),
      );
      expect(
        normalizeRadiansDelta(-math.pi - 0.25),
        closeTo(math.pi - 0.25, 1e-9),
      );
      expect(normalizeRadiansDelta(math.pi / 3), closeTo(math.pi / 3, 1e-9));
    });
  });

  group('scale and delta conversion helpers', () {
    test('safe canvas scale guards zero and invalid values', () {
      expect(safeCanvasScale(2.5), 2.5);
      expect(safeCanvasScale(0), 1e-9);
      expect(safeCanvasScale(double.nan), 1e-9);
      expect(safeCanvasScale(double.infinity), 1e-9);
    });

    test('convert screen pixels to template millimeters', () {
      expectOffsetClose(
        pixelsToTemplateMm(const Offset(20, -10), 4),
        const Offset(5, -2.5),
      );
    });

    test('rotate template delta into local element axes', () {
      expectOffsetClose(
        templateDeltaToElementLocalMm(const Offset(10, 0), 90),
        const Offset(0, -10),
      );
      expectOffsetClose(
        templateDeltaToElementLocalMm(const Offset(0, 8), -90),
        const Offset(-8, 0),
      );
    });

    test('project rotated resize drag in the visual handle direction', () {
      expectOffsetClose(
        templateDeltaToElementLocalMm(const Offset(0, 8), 90),
        const Offset(8, 0),
      );
      expectOffsetClose(
        templateDeltaToElementLocalMm(const Offset(0, -8), 90),
        const Offset(-8, 0),
      );
      expectOffsetClose(
        templateDeltaToElementLocalMm(const Offset(0, -8), -90),
        const Offset(8, 0),
      );
    });
  });

  group('bounds and clamp helpers', () {
    test('clamp finite millimeter values after ordering bounds', () {
      expect(clampFiniteMm(10, 20, 0), 10);
      expect(clampFiniteMm(-5, 20, 0), 0);
      expect(clampFiniteMm(25, 20, 0), 20);
      expect(clampFiniteMm(double.nan, 20, 0), 0);
    });

    test('compute rotated bounds half size', () {
      final halfBounds = rotatedBoundsHalfSize(
        widthMm: 40,
        heightMm: 20,
        rotationDegrees: 90,
      );
      expect(halfBounds.width, closeTo(10, 1e-9));
      expect(halfBounds.height, closeTo(20, 1e-9));
    });

    test('clamp rotated rectangle top left inside canvas', () {
      final clamped = clampRotatedRectTopLeft(
        positionMm: const Offset(-100, 500),
        widthMm: 40,
        heightMm: 20,
        rotationDegrees: 90,
        canvasWidthMm: 100,
        canvasHeightMm: 60,
      );

      expectOffsetClose(clamped, const Offset(-10, 30));
    });
  });

  group('canvas snap', () {
    test('snaps to the nearest target within tolerance', () {
      final result = resolveCanvasMove(
        position: const Offset(49.4, 12.2),
        snapEnabled: true,
        snapTargets: const [
          CanvasSnapTarget(xMm: 50, yMm: 10),
          CanvasSnapTarget(xMm: 60, yMm: 12),
        ],
        toleranceMm: 1,
      );

      expectOffsetClose(result.position, const Offset(50, 12));
      expect(result.verticalGuideMm, 50);
      expect(result.horizontalGuideMm, 12);
    });

    test('returns raw position and no guides when snap is disabled', () {
      final result = resolveCanvasMove(
        position: const Offset(49.4, 12.2),
        snapEnabled: false,
        snapTargets: const [CanvasSnapTarget(xMm: 50, yMm: 12)],
        toleranceMm: 1,
      );

      expectOffsetClose(result.position, const Offset(49.4, 12.2));
      expect(result.hasGuide, isFalse);
    });

    test('holds a snapped target briefly then releases outside hysteresis', () {
      final session = CanvasSnapSession();
      const targets = [CanvasSnapTarget(xMm: 50, yMm: 12)];

      final acquired = session.resolve(
        position: const Offset(49.6, 12.3),
        snapEnabled: true,
        snapTargets: targets,
        toleranceMm: 0.5,
      );
      expectOffsetClose(acquired.position, const Offset(50, 12));

      final held = session.resolve(
        position: const Offset(50.7, 12.7),
        snapEnabled: true,
        snapTargets: targets,
        toleranceMm: 0.5,
      );
      expectOffsetClose(held.position, const Offset(50, 12));

      final released = session.resolve(
        position: const Offset(50.8, 12.8),
        snapEnabled: true,
        snapTargets: targets,
        toleranceMm: 0.5,
      );
      expectOffsetClose(released.position, const Offset(50.8, 12.8));
      expect(released.hasGuide, isFalse);
    });
  });

  group('rotated rectangle resize', () {
    test('resize from bottom right for an unrotated rectangle', () {
      final resized = resizedRotatedRectFromCorner(
        startMm: const Rect.fromLTWH(10, 15, 20, 30),
        localDeltaMm: const Offset(5, -10),
        corner: 'br',
        rotationDegrees: 0,
        maxWidthMm: 100,
        maxHeightMm: 100,
      );

      expectRectClose(resized, const Rect.fromLTWH(10, 15, 25, 20));
    });

    test('keep the opposite rotated corner fixed while resizing', () {
      const start = Rect.fromLTWH(20, 30, 40, 20);
      final expectedFixedCorner = rotatedRectCorner(start, 30, 'tl');

      final resized = resizedRotatedRectFromCorner(
        startMm: start,
        localDeltaMm: const Offset(6, 4),
        corner: 'br',
        rotationDegrees: 30,
        maxWidthMm: 200,
        maxHeightMm: 200,
      );

      final actualFixedCorner = rotatedRectCorner(resized, 30, 'tl');
      expectOffsetClose(actualFixedCorner, expectedFixedCorner);
    });

    test('preserve the fixed corner when resized past canvas bounds', () {
      const start = Rect.fromLTWH(2, 2, 20, 20);
      final expectedFixedCorner = rotatedRectCorner(start, 45, 'br');

      final resized = resizedRotatedRectFromCorner(
        startMm: start,
        localDeltaMm: const Offset(50, 50),
        corner: 'tl',
        rotationDegrees: 45,
        maxWidthMm: 30,
        maxHeightMm: 30,
      );

      expect(resized.width, 2);
      expect(resized.height, 2);
      expectOffsetClose(
        rotatedRectCorner(resized, 45, 'br'),
        expectedFixedCorner,
      );
    });
  });
}

void expectOffsetClose(
  Offset actual,
  Offset expected, {
  double tolerance = 1e-9,
}) {
  expect(actual.dx, closeTo(expected.dx, tolerance));
  expect(actual.dy, closeTo(expected.dy, tolerance));
}

void expectRectClose(Rect actual, Rect expected, {double tolerance = 1e-9}) {
  expect(actual.left, closeTo(expected.left, tolerance));
  expect(actual.top, closeTo(expected.top, tolerance));
  expect(actual.width, closeTo(expected.width, tolerance));
  expect(actual.height, closeTo(expected.height, tolerance));
}

Offset rotatedRectCorner(Rect rect, int rotationDegrees, String corner) {
  final radians = degreesToRadians(rotationDegrees);
  final cosTheta = math.cos(radians);
  final sinTheta = math.sin(radians);
  final center = rect.center;

  late final Offset localCorner;
  switch (corner) {
    case 'tr':
      localCorner = Offset(rect.width / 2, -rect.height / 2);
      break;
    case 'bl':
      localCorner = Offset(-rect.width / 2, rect.height / 2);
      break;
    case 'br':
      localCorner = Offset(rect.width / 2, rect.height / 2);
      break;
    case 'tl':
    default:
      localCorner = Offset(-rect.width / 2, -rect.height / 2);
      break;
  }

  final rotated = Offset(
    localCorner.dx * cosTheta - localCorner.dy * sinTheta,
    localCorner.dx * sinTheta + localCorner.dy * cosTheta,
  );
  return center + rotated;
}
