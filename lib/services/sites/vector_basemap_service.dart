import 'package:nahpu/services/types/map_layers.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

/// Loads OpenFreeMap styles for `flutter_map`, the only renderer on Linux.
///
/// MapLibre reads these styles itself; `vector_map_tiles` needs them parsed
/// into a theme, tile sources, and sprites first.
class VectorBasemapService {
  const VectorBasemapService();

  /// Matches the remote style timeout in `SpatialMapStyleService` so an
  /// offline first map falls back to Natural Earth in the same time.
  static const loadTimeout = Duration(seconds: 8);

  /// Reads [style], which must already be resolved for the app brightness.
  ///
  /// Throws when the style has no URL or cannot be fetched; callers draw the
  /// bundled Natural Earth map instead.
  Future<Style> load(SpatialBasemapStyle style) async {
    final styleUrl = style.styleUrl;
    if (styleUrl == null) {
      throw ArgumentError.value(style, 'style', 'has no online style');
    }
    final loaded = await StyleReader(uri: styleUrl).read().timeout(loadTimeout);
    return Style(
      name: loaded.name,
      theme: loaded.theme.copyWith(id: themeId(style)),
      providers: loaded.providers,
      sprites: loaded.sprites,
      center: loaded.center,
      zoom: loaded.zoom,
    );
  }

  /// OpenFreeMap styles carry no `id`, so `ThemeReader` names every one
  /// `default`. `vector_map_tiles` keys its rendered tile caches by theme id,
  /// so without a distinct id every style draws the first one's tiles.
  static String themeId(SpatialBasemapStyle style) =>
      'openfreemap-${style.name}';
}
