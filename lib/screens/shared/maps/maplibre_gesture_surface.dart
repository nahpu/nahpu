import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:maplibre/maplibre.dart';

Set<Factory<OneSequenceGestureRecognizer>> mapLibreGestureRecognizers() => {
  Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
};

/// Handles pan, pinch, trackpad, and mouse-wheel input for embedded maps.
class MapLibreGestureSurface extends StatefulWidget {
  const MapLibreGestureSurface({super.key, this.onTapUp});

  final ValueChanged<MapLibreTapDetails>? onTapUp;

  @override
  State<MapLibreGestureSurface> createState() => _MapLibreGestureSurfaceState();
}

class _MapLibreGestureSurfaceState extends State<MapLibreGestureSurface> {
  double _lastScale = 1;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.biggest;
      return Listener(
        behavior: HitTestBehavior.opaque,
        onPointerSignal: _handlePointerSignal,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          trackpadScrollCausesScale: true,
          onScaleStart: (_) => _lastScale = 1,
          onScaleUpdate: _handleScaleUpdate,
          onTapUp: (details) {
            if (size.isEmpty) return;
            widget.onTapUp?.call(
              MapLibreTapDetails(
                localPosition: details.localPosition,
                viewportSize: size,
              ),
            );
          },
        ),
      );
    },
  );

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final zoomDelta = -event.scrollDelta.dy * 0.005;
    if (zoomDelta == 0) return;
    _moveCamera(Offset.zero, zoomDelta);
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final zoomDelta = math.log(details.scale / _lastScale) / math.ln2;
    _lastScale = details.scale;
    _moveCamera(details.focalPointDelta, zoomDelta);
  }

  void _moveCamera(Offset panDelta, double zoomDelta) {
    final controller = MapController.maybeOf(context);
    if (controller == null) return;
    final camera = controller.getCamera();
    final metersPerPixel = controller.getMetersPerPixelAtLatitude(
      camera.center.lat,
    );
    final latitude = (camera.center.lat + panDelta.dy * metersPerPixel / 110574)
        .clamp(-85, 85)
        .toDouble();
    final metersPerLongitude =
        111320 * math.cos(camera.center.lat * math.pi / 180);
    final longitude =
        camera.center.lon - panDelta.dx * metersPerPixel / metersPerLongitude;
    unawaited(
      controller.moveCamera(
        center: Geographic(lon: longitude, lat: latitude),
        zoom: (camera.zoom + zoomDelta).clamp(1, 16).toDouble(),
      ),
    );
  }
}

@immutable
class MapLibreTapDetails {
  const MapLibreTapDetails({
    required this.localPosition,
    required this.viewportSize,
  });

  final Offset localPosition;
  final Size viewportSize;
}
