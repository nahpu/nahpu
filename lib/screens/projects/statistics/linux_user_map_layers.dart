import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_pmtiles/flutter_map_pmtiles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/providers/map_layers.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:path/path.dart' as path;

class LinuxUserMapLayers extends ConsumerWidget {
  const LinuxUserMapLayers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(userMapCatalogProvider).value;
    final supported =
        catalog?.layers
            .where((layer) => layer.enabled && layer.kind.isSupportedOnLinux)
            .toList(growable: false) ??
        const <UserMapLayer>[];
    return FutureBuilder<List<Widget>>(
      future: _buildLayers(supported),
      builder: (context, snapshot) =>
          Stack(children: snapshot.data ?? const []),
    );
  }

  Future<List<Widget>> _buildLayers(List<UserMapLayer> layers) async {
    final root = await getUserMapDirectory();
    final widgets = <Widget>[];
    for (final layer in layers) {
      final dataPath = path.join(root.path, layer.id, layer.dataFile);
      switch (layer.kind) {
        case UserMapLayerKind.geoJson:
          final data = await _parseGeoJson(File(dataPath));
          final color = Color(layer.color);
          widgets.addAll([
            PolygonLayer(
              polygons: [
                for (final polygon in data.polygons)
                  Polygon(
                    points: polygon,
                    color: color.withValues(
                      alpha: layer.fillOpacity * layer.opacity,
                    ),
                    borderColor: color.withValues(alpha: layer.opacity),
                    borderStrokeWidth: layer.lineWidth,
                  ),
              ],
            ),
            PolylineLayer(
              polylines: [
                for (final line in data.lines)
                  Polyline(
                    points: line,
                    color: color.withValues(alpha: layer.opacity),
                    strokeWidth: layer.lineWidth,
                  ),
              ],
            ),
            MarkerLayer(
              markers: [
                for (final point in data.points)
                  Marker(
                    point: point,
                    width: layer.pointRadius * 2,
                    height: layer.pointRadius * 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: layer.opacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ]);
        case UserMapLayerKind.rasterPmtiles:
          final provider = await PmTilesTileProvider.fromSource(dataPath);
          widgets.add(
            Opacity(
              opacity: layer.opacity,
              child: TileLayer(tileProvider: provider),
            ),
          );
        case UserMapLayerKind.vectorPmtiles || UserMapLayerKind.demPmtiles:
          break;
      }
    }
    return widgets;
  }

  Future<_LinuxGeoJsonData> _parseGeoJson(File file) async {
    final decoded = jsonDecode(await file.readAsString());
    final points = <LatLng>[];
    final lines = <List<LatLng>>[];
    final polygons = <List<LatLng>>[];

    void geometry(Object? value) {
      if (value is! Map) return;
      final type = value['type'];
      final coordinates = value['coordinates'];
      switch (type) {
        case 'Point':
          final point = _point(coordinates);
          if (point != null) points.add(point);
        case 'MultiPoint':
          if (coordinates is List) {
            points.addAll(coordinates.map(_point).whereType<LatLng>());
          }
        case 'LineString':
          final line = _line(coordinates);
          if (line.isNotEmpty) lines.add(line);
        case 'MultiLineString':
          if (coordinates is List) {
            lines.addAll(
              coordinates.map(_line).where((line) => line.isNotEmpty),
            );
          }
        case 'Polygon':
          if (coordinates is List && coordinates.isNotEmpty) {
            final polygon = _line(coordinates.first);
            if (polygon.isNotEmpty) polygons.add(polygon);
          }
        case 'MultiPolygon':
          if (coordinates is List) {
            for (final item in coordinates) {
              if (item is List && item.isNotEmpty) {
                final polygon = _line(item.first);
                if (polygon.isNotEmpty) polygons.add(polygon);
              }
            }
          }
        case 'GeometryCollection':
          if (value['geometries'] is List) {
            for (final item in value['geometries'] as List) {
              geometry(item);
            }
          }
      }
    }

    if (decoded is Map && decoded['features'] is List) {
      for (final feature in decoded['features'] as List) {
        if (feature is Map) geometry(feature['geometry']);
      }
    }
    return _LinuxGeoJsonData(points: points, lines: lines, polygons: polygons);
  }

  LatLng? _point(Object? value) {
    if (value is! List || value.length < 2) return null;
    final longitude = value[0];
    final latitude = value[1];
    if (longitude is! num || latitude is! num) return null;
    return LatLng(latitude.toDouble(), longitude.toDouble());
  }

  List<LatLng> _line(Object? value) => value is List
      ? value.map(_point).whereType<LatLng>().toList(growable: false)
      : const [];
}

class _LinuxGeoJsonData {
  const _LinuxGeoJsonData({
    required this.points,
    required this.lines,
    required this.polygons,
  });

  final List<LatLng> points;
  final List<List<LatLng>> lines;
  final List<List<LatLng>> polygons;
}
