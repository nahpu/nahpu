import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:nahpu/services/maps/coordinate_map_point.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';

class SpatialMapStyleService {
  SpatialMapStyleService._();

  static const naturalEarthAsset =
      'assets/maps/ne_110m_admin_0_countries.geojson';
  static const statisticsSourceId = 'nahpu-spatial-statistics';
  static const statisticsLayerId = 'nahpu-spatial-statistics-circles';
  static const coordinateSourceId = 'nahpu-coordinate-locations';
  static const coordinateLayerId = 'nahpu-coordinate-location-markers';
  static const naturalEarthSourceId = 'nahpu-natural-earth';
  static final _cache = <String, Future<String>>{};

  static Future<String> build({
    required SpatialBasemapStyle style,
    required bool isDark,
    required ColorScheme colorScheme,
    required SpatialStatisticKind kind,
    required List<SpatialStatisticDatum> rows,
    required int total,
    required UserMapCatalog catalog,
    required Directory userMapDirectory,
  }) {
    final resolved = style.resolve(isDark: isDark);
    final signature = [
      resolved.name,
      colorScheme.primary.toARGB32(),
      colorScheme.surface.toARGB32(),
      colorScheme.surfaceContainerHighest.toARGB32(),
      colorScheme.outlineVariant.toARGB32(),
      kind.name,
      total,
      for (final row in rows) '${row.coordinateId}:${row.count}',
      catalog.activeTerrainLayerId,
      for (final layer in catalog.layers)
        '${layer.id}:${layer.enabled}:${layer.opacity}',
    ].join('|');
    return _cache.putIfAbsent(
      signature,
      () => _build(
        style: resolved,
        colorScheme: colorScheme,
        kind: kind,
        rows: rows,
        total: total,
        catalog: catalog,
        userMapDirectory: userMapDirectory,
      ),
    );
  }

  /// Builds the read-only point style used outside spatial statistics.
  ///
  /// The remote OpenFreeMap style is used when it can be loaded. When it
  /// cannot, the same bundled Natural Earth source used by statistics becomes
  /// the base layer.
  static Future<String> buildCoordinatePoints({
    required SpatialBasemapStyle style,
    required bool isDark,
    required ColorScheme colorScheme,
    required UserMapCatalog catalog,
    required Directory userMapDirectory,
  }) {
    final resolved = style.resolve(isDark: isDark);
    final signature = [
      'coordinates',
      resolved.name,
      colorScheme.primary.toARGB32(),
      colorScheme.surface.toARGB32(),
      colorScheme.onSurfaceVariant.toARGB32(),
      colorScheme.surfaceContainerHighest.toARGB32(),
      colorScheme.outlineVariant.toARGB32(),
      catalog.activeTerrainLayerId,
      for (final layer in catalog.layers)
        '${layer.id}:${layer.enabled}:${layer.opacity}',
    ].join('|');
    return _cache.putIfAbsent(
      signature,
      () => _buildCoordinatePoints(
        style: resolved,
        colorScheme: colorScheme,
        catalog: catalog,
        userMapDirectory: userMapDirectory,
      ),
    );
  }

  static String coordinateFeatureCollection({
    required List<CoordinateMapPoint> points,
    required Set<int> selectedPointIds,
    required int? focusedPointId,
  }) {
    return jsonEncode({
      'type': 'FeatureCollection',
      'features': [
        for (final point in points.where((point) => point.isMappable))
          {
            'type': 'Feature',
            'id': point.id,
            'geometry': {
              'type': 'Point',
              'coordinates': [point.longitude, point.latitude],
            },
            'properties': {
              'coordinateId': point.id,
              'name': point.name,
              'selected': selectedPointIds.contains(point.id),
              'focused': point.id == focusedPointId,
            },
          },
      ],
    });
  }

  static Future<String> _buildCoordinatePoints({
    required SpatialBasemapStyle style,
    required ColorScheme colorScheme,
    required UserMapCatalog catalog,
    required Directory userMapDirectory,
  }) async {
    final loadedBase = await _loadBaseStyle(style, colorScheme);
    final base = loadedBase.style;
    final sources = Map<String, dynamic>.from(base['sources'] as Map? ?? {});
    sources[coordinateSourceId] = {
      'type': 'geojson',
      'data': jsonDecode(
        coordinateFeatureCollection(
          points: const [],
          selectedPointIds: const {},
          focusedPointId: null,
        ),
      ),
    };
    base['sources'] = sources;
    final layers = (base['layers'] as List? ?? const [])
        .map((layer) => Map<String, dynamic>.from(layer as Map))
        .toList();
    if (loadedBase.showsNaturalEarth) {
      await _addNaturalEarthBase(
        sources: sources,
        layers: layers,
        colorScheme: colorScheme,
      );
    }
    await _addUserLayers(
      base: base,
      sources: sources,
      layers: layers,
      catalog: catalog,
      directory: userMapDirectory,
    );
    layers.add({
      'id': coordinateLayerId,
      'type': 'circle',
      'source': coordinateSourceId,
      'paint': {
        'circle-radius': [
          'case',
          ['get', 'focused'],
          11,
          ['get', 'selected'],
          8,
          7,
        ],
        'circle-color': [
          'case',
          ['get', 'focused'],
          _hex(_focusedCoordinateColor(colorScheme)),
          ['get', 'selected'],
          _hex(colorScheme.primary),
          _hex(colorScheme.onSurfaceVariant),
        ],
        'circle-opacity': [
          'case',
          ['get', 'focused'],
          1,
          ['get', 'selected'],
          0.78,
          0.62,
        ],
        'circle-stroke-color': _hex(colorScheme.surface),
        'circle-stroke-width': 2,
      },
    });
    base['layers'] = layers;
    return jsonEncode(base);
  }

  static Future<String> _build({
    required SpatialBasemapStyle style,
    required ColorScheme colorScheme,
    required SpatialStatisticKind kind,
    required List<SpatialStatisticDatum> rows,
    required int total,
    required UserMapCatalog catalog,
    required Directory userMapDirectory,
  }) async {
    final loadedBase = await _loadBaseStyle(style, colorScheme);
    final base = loadedBase.style;
    final sources = Map<String, dynamic>.from(base['sources'] as Map? ?? {});
    sources[statisticsSourceId] = {
      'type': 'geojson',
      'data': _statisticsFeatureCollection(kind, rows, total),
    };
    base['sources'] = sources;

    final layers = (base['layers'] as List? ?? const [])
        .map((layer) => Map<String, dynamic>.from(layer as Map))
        .toList();
    if (loadedBase.showsNaturalEarth) {
      await _addNaturalEarthBase(
        sources: sources,
        layers: layers,
        colorScheme: colorScheme,
      );
    }
    await _addUserLayers(
      base: base,
      sources: sources,
      layers: layers,
      catalog: catalog,
      directory: userMapDirectory,
    );
    layers.add({
      'id': statisticsLayerId,
      'type': 'circle',
      'source': statisticsSourceId,
      'paint': {
        'circle-radius': ['get', 'radius'],
        'circle-color': _hex(colorScheme.primary),
        'circle-opacity': 0.32,
        'circle-stroke-color': _hex(colorScheme.primary),
        'circle-stroke-opacity': 0.86,
        'circle-stroke-width': 1.5,
      },
    });
    base['layers'] = layers;
    return jsonEncode(base);
  }

  static Future<void> _addUserLayers({
    required Map<String, dynamic> base,
    required Map<String, dynamic> sources,
    required List<Map<String, dynamic>> layers,
    required UserMapCatalog catalog,
    required Directory directory,
  }) async {
    for (final layer in catalog.layers.where((layer) => layer.enabled)) {
      final sourceId = 'nahpu-user-${layer.id}';
      final dataPath = '${directory.path}/${layer.id}/${layer.dataFile}';
      final color = _hex(Color(layer.color));
      switch (layer.kind) {
        case UserMapLayerKind.geoJson:
          final file = File(dataPath);
          if (!await file.exists()) continue;
          sources[sourceId] = {
            'type': 'geojson',
            'data': jsonDecode(await file.readAsString()),
            if (layer.attribution != null) 'attribution': layer.attribution,
          };
          layers.addAll(_vectorLayers(layer, sourceId, color));
        case UserMapLayerKind.rasterPmtiles:
          sources[sourceId] = {
            'type': 'raster',
            'url': _pmTilesUri(dataPath),
            'tileSize': 256,
            'minzoom': layer.minZoom,
            'maxzoom': layer.maxZoom,
            if (layer.attribution != null) 'attribution': layer.attribution,
          };
          layers.add({
            'id': '$sourceId-raster',
            'type': 'raster',
            'source': sourceId,
            'paint': {'raster-opacity': layer.opacity},
          });
        case UserMapLayerKind.vectorPmtiles:
          sources[sourceId] = {
            'type': 'vector',
            'url': _pmTilesUri(dataPath),
            'minzoom': layer.minZoom,
            'maxzoom': layer.maxZoom,
            if (layer.attribution != null) 'attribution': layer.attribution,
          };
          for (final sourceLayer in layer.vectorLayerNames) {
            layers.addAll(
              _vectorLayers(layer, sourceId, color, sourceLayer: sourceLayer),
            );
          }
        case UserMapLayerKind.demPmtiles:
          sources[sourceId] = {
            'type': 'raster-dem',
            'url': _pmTilesUri(dataPath),
            'tileSize': 256,
            'encoding': layer.demEncoding ?? 'terrarium',
            if (layer.attribution != null) 'attribution': layer.attribution,
          };
          layers.add({
            'id': '$sourceId-hillshade',
            'type': 'hillshade',
            'source': sourceId,
            'paint': {'hillshade-exaggeration': layer.opacity},
          });
          if (catalog.activeTerrainLayerId == layer.id) {
            base['terrain'] = {'source': sourceId, 'exaggeration': 1};
          }
      }
    }
    base['sources'] = sources;
  }

  static Future<void> _addNaturalEarthBase({
    required Map<String, dynamic> sources,
    required List<Map<String, dynamic>> layers,
    required ColorScheme colorScheme,
  }) async {
    sources[naturalEarthSourceId] = {
      'type': 'geojson',
      'data': jsonDecode(await rootBundle.loadString(naturalEarthAsset)),
      'attribution': 'Natural Earth',
    };
    layers.addAll([
      {
        'id': 'nahpu-natural-earth-fill',
        'type': 'fill',
        'source': naturalEarthSourceId,
        'paint': {
          'fill-color': _hex(colorScheme.surfaceContainerHighest),
          'fill-opacity': 1,
        },
      },
      {
        'id': 'nahpu-natural-earth-outline',
        'type': 'line',
        'source': naturalEarthSourceId,
        'paint': {
          'line-color': _hex(colorScheme.outlineVariant),
          'line-width': 0.6,
        },
      },
    ]);
  }

  static List<Map<String, dynamic>> _vectorLayers(
    UserMapLayer layer,
    String sourceId,
    String color, {
    String? sourceLayer,
  }) {
    final suffix = sourceLayer == null ? '' : '-$sourceLayer';
    final common = <String, dynamic>{
      'source': sourceId,
      'source-layer': ?sourceLayer,
      'minzoom': layer.minZoom,
      'maxzoom': layer.maxZoom,
    };
    return [
      {
        'id': '$sourceId$suffix-fill',
        'type': 'fill',
        ...common,
        'filter': [
          '==',
          ['geometry-type'],
          'Polygon',
        ],
        'paint': {
          'fill-color': color,
          'fill-opacity': layer.fillOpacity * layer.opacity,
          'fill-outline-color': color,
        },
      },
      {
        'id': '$sourceId$suffix-line',
        'type': 'line',
        ...common,
        'filter': [
          '==',
          ['geometry-type'],
          'LineString',
        ],
        'paint': {
          'line-color': color,
          'line-width': layer.lineWidth,
          'line-opacity': layer.opacity,
        },
      },
      {
        'id': '$sourceId$suffix-circle',
        'type': 'circle',
        ...common,
        'filter': [
          '==',
          ['geometry-type'],
          'Point',
        ],
        'paint': {
          'circle-color': color,
          'circle-radius': layer.pointRadius,
          'circle-opacity': layer.opacity,
        },
      },
    ];
  }

  static String _pmTilesUri(String filePath) =>
      'pmtiles://${Uri.file(filePath)}';

  static Future<_LoadedBaseStyle> _loadBaseStyle(
    SpatialBasemapStyle style,
    ColorScheme colorScheme,
  ) async {
    if (style == SpatialBasemapStyle.none) {
      return _LoadedBaseStyle(_blankBaseStyle(colorScheme));
    }
    if (style == SpatialBasemapStyle.naturalEarthOffline) {
      return _LoadedBaseStyle(
        _blankBaseStyle(colorScheme, name: 'NAHPU Natural Earth'),
        showsNaturalEarth: true,
      );
    }
    final styleUrl = style.styleUrl;
    if (styleUrl == null) return _LoadedBaseStyle(_blankBaseStyle(colorScheme));
    try {
      final response = await http
          .get(Uri.parse(styleUrl))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _LoadedBaseStyle(
          Map<String, dynamic>.from(jsonDecode(response.body) as Map),
        );
      }
    } catch (_) {
      // The local Natural Earth style below is the intentional offline path.
    }
    return _LoadedBaseStyle(
      _blankBaseStyle(colorScheme, name: 'NAHPU Offline'),
      showsNaturalEarth: true,
    );
  }

  static Map<String, dynamic> _blankBaseStyle(
    ColorScheme colorScheme, {
    String name = 'NAHPU',
  }) => {
    'version': 8,
    'name': name,
    'sources': <String, dynamic>{},
    'layers': [
      {
        'id': 'nahpu-background',
        'type': 'background',
        'paint': {'background-color': _hex(colorScheme.surface)},
      },
    ],
  };

  static Map<String, dynamic> _statisticsFeatureCollection(
    SpatialStatisticKind kind,
    List<SpatialStatisticDatum> rows,
    int total,
  ) {
    final maximumCount = rows.fold<int>(
      0,
      (maximum, row) => mathMax(maximum, row.count ?? 0),
    );
    return {
      'type': 'FeatureCollection',
      'features': [
        for (final row in rows)
          {
            'type': 'Feature',
            'id': row.coordinateId,
            'geometry': {
              'type': 'Point',
              'coordinates': [row.decimalLongitude, row.decimalLatitude],
            },
            'properties': {
              'coordinateId': row.coordinateId,
              'name': row.displayName,
              'count': row.count ?? 0,
              'percent': spatialStatisticPercent(row, total),
              'radius': spatialMarkerRadius(
                kind: kind,
                count: row.count ?? 0,
                maximumCount: maximumCount,
              ),
            },
          },
      ],
    };
  }

  static int mathMax(int first, int second) => first > second ? first : second;

  static Color _focusedCoordinateColor(ColorScheme colorScheme) =>
      colorScheme.brightness == Brightness.dark
      ? const Color(0xFF90CAF9)
      : const Color(0xFF1565C0);

  static String _hex(Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2)}';
  }
}

class _LoadedBaseStyle {
  const _LoadedBaseStyle(this.style, {this.showsNaturalEarth = false});

  final Map<String, dynamic> style;
  final bool showsNaturalEarth;
}
