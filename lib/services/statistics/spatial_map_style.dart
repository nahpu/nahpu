import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:nahpu/services/types/map_layers.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';

class SpatialMapStyleService {
  SpatialMapStyleService._();

  static const naturalEarthAsset =
      'assets/maps/ne_110m_admin_0_countries.geojson';
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
      // The circles are a Flutter overlay, but keying on the data still gives
      // each result its own map, which fits its camera to the new rows.
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
        catalog: catalog,
        userMapDirectory: userMapDirectory,
      ),
    );
  }

  /// Builds the base style for the coordinate maps outside spatial
  /// statistics. Their markers are a Flutter overlay, as in statistics.
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
      colorScheme.surface.toARGB32(),
      colorScheme.surfaceContainerHighest.toARGB32(),
      colorScheme.outlineVariant.toARGB32(),
      catalog.activeTerrainLayerId,
      for (final layer in catalog.layers)
        '${layer.id}:${layer.enabled}:${layer.opacity}',
    ].join('|');
    return _cache.putIfAbsent(
      signature,
      () => _build(
        style: resolved,
        colorScheme: colorScheme,
        catalog: catalog,
        userMapDirectory: userMapDirectory,
      ),
    );
  }

  static Future<String> _build({
    required SpatialBasemapStyle style,
    required ColorScheme colorScheme,
    required UserMapCatalog catalog,
    required Directory userMapDirectory,
  }) async {
    final loadedBase = await _loadBaseStyle(style, colorScheme);
    final base = loadedBase.style;
    final sources = Map<String, dynamic>.from(base['sources'] as Map? ?? {});
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
