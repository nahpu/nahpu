import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/statistics/spatial_map_style.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

    test('none and offline Natural Earth do not use a remote style', () {
      expect(
        SpatialBasemapStyle.none.resolve(isDark: false),
        SpatialBasemapStyle.none,
      );
      expect(
        SpatialBasemapStyle.naturalEarthOffline.resolve(isDark: true),
        SpatialBasemapStyle.naturalEarthOffline,
      );
      expect(SpatialBasemapStyle.none.styleUrl, isNull);
      expect(SpatialBasemapStyle.naturalEarthOffline.styleUrl, isNull);
    });
  });

  test(
    'base layer styles distinguish none from offline Natural Earth',
    () async {
      final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
      final none = await SpatialMapStyleService.build(
        style: SpatialBasemapStyle.none,
        isDark: false,
        colorScheme: colorScheme,
        kind: SpatialStatisticKind.specimens,
        rows: const [],
        total: 0,
        catalog: const UserMapCatalog(),
        userMapDirectory: Directory.systemTemp,
      );
      final offline = await SpatialMapStyleService.build(
        style: SpatialBasemapStyle.naturalEarthOffline,
        isDark: false,
        colorScheme: colorScheme,
        kind: SpatialStatisticKind.specimens,
        rows: const [],
        total: 0,
        catalog: const UserMapCatalog(),
        userMapDirectory: Directory.systemTemp,
      );

      final noneStyle = Map<String, dynamic>.from(jsonDecode(none) as Map);
      final offlineStyle = Map<String, dynamic>.from(
        jsonDecode(offline) as Map,
      );
      final noneSources = Map<String, dynamic>.from(
        noneStyle['sources'] as Map,
      );
      final offlineSources = Map<String, dynamic>.from(
        offlineStyle['sources'] as Map,
      );

      expect(
        noneSources,
        isNot(contains(SpatialMapStyleService.naturalEarthSourceId)),
      );
      expect(
        offlineSources,
        contains(SpatialMapStyleService.naturalEarthSourceId),
      );
    },
  );

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
