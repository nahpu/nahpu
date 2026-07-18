import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class NaturalEarthPolygon {
  const NaturalEarthPolygon({required this.points, required this.holes});

  final List<LatLng> points;
  final List<List<LatLng>> holes;
}

Future<List<NaturalEarthPolygon>> loadNaturalEarthPolygons() async {
  final source = await rootBundle.loadString(
    'assets/maps/ne_110m_admin_0_countries.geojson',
  );
  final collection = jsonDecode(source) as Map<String, dynamic>;
  final polygons = <NaturalEarthPolygon>[];
  for (final feature in collection['features'] as List<dynamic>) {
    final geometry =
        (feature as Map<String, dynamic>)['geometry'] as Map<String, dynamic>?;
    if (geometry == null) continue;
    final coordinates = geometry['coordinates'];
    switch (geometry['type']) {
      case 'Polygon':
        final polygon = _parsePolygon(coordinates);
        if (polygon != null) polygons.add(polygon);
        break;
      case 'MultiPolygon':
        if (coordinates is List<dynamic>) {
          for (final polygonCoordinates in coordinates) {
            final polygon = _parsePolygon(polygonCoordinates);
            if (polygon != null) polygons.add(polygon);
          }
        }
        break;
    }
  }
  return polygons;
}

NaturalEarthPolygon? _parsePolygon(Object? coordinates) {
  if (coordinates is! List<dynamic>) return null;
  final rings = coordinates
      .map(_parseRing)
      .where((ring) => ring.length >= 3)
      .toList(growable: false);
  if (rings.isEmpty) return null;
  return NaturalEarthPolygon(
    points: rings.first,
    holes: rings.skip(1).toList(),
  );
}

List<LatLng> _parseRing(Object? coordinates) {
  if (coordinates is! List<dynamic>) return const [];
  return coordinates
      .whereType<List<dynamic>>()
      .where((pair) => pair.length >= 2 && pair[0] is num && pair[1] is num)
      .map(
        (pair) =>
            LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble()),
      )
      .toList(growable: false);
}

String formatCoordinate(double? value, {required int decimals}) {
  if (value == null) return '—';
  return value.toStringAsFixed(decimals).replaceFirst(RegExp(r'\.?0+$'), '');
}

String formatCoordinateText(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '—' : trimmed;
}

String formatCoordinateInteger(int? value) => value?.toString() ?? '—';
