import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre/maplibre.dart';
import 'package:nahpu/screens/shared/maps/maplibre_viewport_projection.dart';

void main() {
  const camera = MapCamera(
    center: Geographic(lon: 0, lat: 0),
    zoom: 1,
    bearing: 0,
    pitch: 0,
  );

  test('uses the supplied viewport size instead of a cached map size', () {
    final point = const Geographic(lon: 45, lat: 0);

    expect(
      mapLibreViewportScreenLocation(
        camera: camera,
        viewportSize: const Size(400, 200),
        point: point,
      ),
      const Offset(328, 100),
    );
    expect(
      mapLibreViewportScreenLocation(
        camera: camera,
        viewportSize: const Size(1200, 700),
        point: point,
      ),
      const Offset(728, 350),
    );
  });

  test('applies bearing and pitch consistently with MapLibre WebView', () {
    final result = mapLibreViewportScreenLocation(
      camera: const MapCamera(
        center: Geographic(lon: 0, lat: 0),
        zoom: 1,
        bearing: 90,
        pitch: 60,
      ),
      viewportSize: const Size(512, 512),
      point: const Geographic(lon: 0, lat: 45),
    );

    expect(result.dx, lessThan(256));
    expect(result.dy, closeTo(256, 0.001));
  });
}
