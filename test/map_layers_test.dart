import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/types/map_layers.dart';

void main() {
  group('SpatialBasemapStyle', () {
    test('automatic follows app brightness', () {
      expect(
        SpatialBasemapStyle.automatic.resolve(isDark: false),
        SpatialBasemapStyle.positron,
      );
      expect(
        SpatialBasemapStyle.automatic.resolve(isDark: true),
        SpatialBasemapStyle.dark,
      );
    });

    test('uses OpenFreeMap style endpoints', () {
      expect(
        SpatialBasemapStyle.liberty.styleUrl,
        'https://tiles.openfreemap.org/styles/liberty',
      );
      expect(
        SpatialBasemapStyle.bright.styleUrl,
        'https://tiles.openfreemap.org/styles/bright',
      );
    });
  });

  test('user map catalog preserves layer and terrain configuration', () {
    final catalog = UserMapCatalog(
      activeTerrainLayerId: 'dem',
      layers: [
        UserMapLayer(
          id: 'dem',
          name: 'Local DEM',
          kind: UserMapLayerKind.demPmtiles,
          dataFile: 'data.pmtiles',
          originalFileName: 'terrain.pmtiles',
          sourceHash: 'abc',
          addedAt: DateTime.utc(2026, 7, 18),
          bounds: const UserMapBounds(
            west: -92,
            south: 35,
            east: -90,
            north: 37,
          ),
          demEncoding: 'terrarium',
        ),
      ],
    );

    final restored = UserMapCatalog.fromJson(catalog.toJson());

    expect(restored.activeTerrainLayerId, 'dem');
    expect(restored.layers.single.kind, UserMapLayerKind.demPmtiles);
    expect(restored.layers.single.bounds?.values, [-92, 35, -90, 37]);
    expect(restored.layers.single.demEncoding, 'terrarium');
  });
}
