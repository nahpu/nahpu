import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Returns the nearest candidate whose projected hit area contains a tap.
T? closestMapPoint<T>({
  required Offset tapPosition,
  required Iterable<T> points,
  required Offset Function(T point) screenPosition,
  required double Function(T point) hitRadius,
}) {
  T? closest;
  var closestDistanceSquared = double.infinity;
  for (final point in points) {
    final delta = screenPosition(point) - tapPosition;
    final distanceSquared = delta.distanceSquared;
    final radius = hitRadius(point);
    if (distanceSquared <= radius * radius &&
        distanceSquared < closestDistanceSquared) {
      closest = point;
      closestDistanceSquared = distanceSquared;
    }
  }
  return closest;
}

double mapMarkerHitRadius(double visualRadius) =>
    math.max(24, visualRadius + 4).toDouble();
