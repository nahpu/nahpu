import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which renderer the shared map widgets should build.
enum MapRenderer {
  /// Native MapLibre. Android and iOS only.
  mapLibre,

  /// `flutter_map` drawing OpenFreeMap vector tiles or the bundled Natural
  /// Earth polygons. Always available and works without the network.
  naturalEarth,
}

/// Whether this platform normally renders maps with MapLibre.
///
/// True only where `maplibre` has a native implementation. Desktop platforms
/// use `flutter_map` as their only renderer rather than as a fallback, which
/// keeps a web view, its loopback bridge and its CDN-hosted MapLibre GL JS
/// bundle out of the app.
bool get mapLibreIsExpected => Platform.isAndroid || Platform.isIOS;

final mapRendererProvider = NotifierProvider<MapRendererNotifier, MapRenderer>(
  MapRendererNotifier.new,
);

/// Picks the map renderer and latches the fallback once MapLibre has failed.
///
/// Desktop platforms have no native MapLibre, so they start on
/// [MapRenderer.naturalEarth]. Android and iOS start on MapLibre.
///
/// [markMapLibreUnavailable] latches the fallback for the rest of the session
/// so every later map uses `flutter_map` without trying MapLibre again.
class MapRendererNotifier extends Notifier<MapRenderer> {
  @override
  MapRenderer build() =>
      mapLibreIsExpected ? MapRenderer.mapLibre : MapRenderer.naturalEarth;

  /// Records that MapLibre never finished loading on this platform.
  ///
  /// Ignored on desktop, where the fallback is not a fallback but the only
  /// renderer.
  void markMapLibreUnavailable() {
    if (state == MapRenderer.naturalEarth) return;
    state = MapRenderer.naturalEarth;
  }

  /// Clears the latch so the next map tries MapLibre again.
  ///
  /// A user who reconnects should not have to restart the app to get
  /// detailed basemaps back.
  void retryMapLibre() {
    if (!mapLibreIsExpected || state == MapRenderer.mapLibre) return;
    state = MapRenderer.mapLibre;
  }
}
