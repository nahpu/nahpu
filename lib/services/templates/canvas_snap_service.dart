import 'dart:math' as math;
import 'dart:ui';

/// A horizontal and/or vertical canvas coordinate available for snapping.
class CanvasSnapTarget {
  /// Creates a snap target from optional template coordinates in millimeters.
  const CanvasSnapTarget({this.xMm, this.yMm});

  final double? xMm;
  final double? yMm;
}

/// The snapped position and guides produced by a snap calculation.
class CanvasSnapResult {
  /// Creates a resolved canvas position and any visible snap guides.
  const CanvasSnapResult({
    required this.position,
    this.verticalGuideMm,
    this.horizontalGuideMm,
  });

  final Offset position;
  final double? verticalGuideMm;
  final double? horizontalGuideMm;

  /// Whether either axis resolved to a snap guide.
  bool get hasGuide => verticalGuideMm != null || horizontalGuideMm != null;
}

/// Retains a snapped axis until the pointer leaves the release tolerance.
class CanvasSnapSession {
  double? _activeX;
  double? _activeY;

  /// Clears retained axis targets so the next resolution starts fresh.
  void reset() {
    _activeX = null;
    _activeY = null;
  }

  /// Resolves [position] against [snapTargets], retaining an active target
  /// until it exceeds the release tolerance.
  ///
  /// Coordinates and [toleranceMm] are expressed in template millimeters.
  /// When [snapEnabled] is false, this returns the original position.
  CanvasSnapResult resolve({
    required Offset position,
    required bool snapEnabled,
    required List<CanvasSnapTarget> snapTargets,
    required double toleranceMm,
  }) {
    if (!snapEnabled) {
      reset();
      return CanvasSnapResult(position: position);
    }

    final acquireToleranceMm = math.max(0.0, toleranceMm);
    final releaseToleranceMm = acquireToleranceMm * 1.5;
    _activeX = _resolveAxisSnap(
      value: position.dx,
      targets: snapTargets.map((target) => target.xMm),
      activeTarget: _activeX,
      acquireToleranceMm: acquireToleranceMm,
      releaseToleranceMm: releaseToleranceMm,
    );
    _activeY = _resolveAxisSnap(
      value: position.dy,
      targets: snapTargets.map((target) => target.yMm),
      activeTarget: _activeY,
      acquireToleranceMm: acquireToleranceMm,
      releaseToleranceMm: releaseToleranceMm,
    );

    return CanvasSnapResult(
      position: Offset(_activeX ?? position.dx, _activeY ?? position.dy),
      verticalGuideMm: _activeX,
      horizontalGuideMm: _activeY,
    );
  }

  double? _resolveAxisSnap({
    required double value,
    required Iterable<double?> targets,
    required double? activeTarget,
    required double acquireToleranceMm,
    required double releaseToleranceMm,
  }) {
    final availableTargets = targets
        .whereType<double>()
        .where((target) => target.isFinite)
        .toList(growable: false);

    if (activeTarget != null &&
        availableTargets.any(
          (target) => (target - activeTarget).abs() < 1e-6,
        ) &&
        (value - activeTarget).abs() <= releaseToleranceMm) {
      return activeTarget;
    }

    double? snapTarget;
    var bestDistance = acquireToleranceMm;
    for (final target in availableTargets) {
      final distance = (value - target).abs();
      if (distance <= bestDistance) {
        bestDistance = distance;
        snapTarget = target;
      }
    }
    return snapTarget;
  }
}

/// Resolves [position] to the closest target on each axis within
/// [toleranceMm], without retaining any previous snap state.
CanvasSnapResult resolveCanvasSnap({
  required Offset position,
  required List<CanvasSnapTarget> snapTargets,
  required double toleranceMm,
}) {
  double? snapX;
  double? snapY;
  var bestDx = toleranceMm;
  var bestDy = toleranceMm;

  for (final target in snapTargets) {
    final targetX = target.xMm;
    if (targetX != null) {
      final dx = (position.dx - targetX).abs();
      if (dx <= bestDx) {
        bestDx = dx;
        snapX = targetX;
      }
    }
    final targetY = target.yMm;
    if (targetY != null) {
      final dy = (position.dy - targetY).abs();
      if (dy <= bestDy) {
        bestDy = dy;
        snapY = targetY;
      }
    }
  }

  return CanvasSnapResult(
    position: Offset(snapX ?? position.dx, snapY ?? position.dy),
    verticalGuideMm: snapX,
    horizontalGuideMm: snapY,
  );
}

/// Resolves a canvas move when snapping is enabled; otherwise preserves
/// [position] and omits all guides.
CanvasSnapResult resolveCanvasMove({
  required Offset position,
  required bool snapEnabled,
  required List<CanvasSnapTarget> snapTargets,
  required double toleranceMm,
}) {
  if (!snapEnabled) {
    return CanvasSnapResult(position: position);
  }
  return resolveCanvasSnap(
    position: position,
    snapTargets: snapTargets,
    toleranceMm: toleranceMm,
  );
}
