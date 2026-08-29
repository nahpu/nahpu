import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:maplibre/maplibre.dart';

const double _mapLibreTileSize = 512;

/// Projects a geographic point using the map camera and the Flutter viewport.
///
/// MapLibre's WebView controller keeps its own cached CSS size. That size can
/// lag behind Flutter during a route transition, so tooltip geometry must use
/// the size of the widget receiving the tap instead.
Offset mapLibreViewportScreenLocation({
  required MapCamera camera,
  required Size viewportSize,
  required Geographic point,
}) {
  final scale = math.pow(2.0, camera.zoom).toDouble();
  final worldSize = _mapLibreTileSize * scale;
  final center = _project(camera.center) * scale;
  var delta = _project(point) * scale - center;
  delta = Offset(_wrapDelta(delta.dx, worldSize), delta.dy);

  final bearing = -camera.bearing * math.pi / 180;
  final cosBearing = math.cos(bearing);
  final sinBearing = math.sin(bearing);
  delta = Offset(
    delta.dx * cosBearing - delta.dy * sinBearing,
    delta.dx * sinBearing + delta.dy * cosBearing,
  );
  delta = Offset(delta.dx, delta.dy * math.cos(camera.pitch * math.pi / 180));

  return Offset(
    viewportSize.width / 2 + delta.dx,
    viewportSize.height / 2 + delta.dy,
  );
}

Offset _project(Geographic point) {
  final longitude = point.lon.clamp(-180.0, 180.0).toDouble();
  final latitude = point.lat.clamp(-85.051129, 85.051129).toDouble();
  final sinLatitude = math.sin(latitude * math.pi / 180);
  return Offset(
    _mapLibreTileSize * (longitude + 180) / 360,
    _mapLibreTileSize *
        (0.5 - math.log((1 + sinLatitude) / (1 - sinLatitude)) / (4 * math.pi)),
  );
}

double _wrapDelta(double value, double worldSize) {
  var wrapped = (value + worldSize / 2) % worldSize;
  if (wrapped < 0) wrapped += worldSize;
  return wrapped - worldSize / 2;
}
