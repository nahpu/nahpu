import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_legend.dart';
import 'package:nahpu/services/maps/coordinate_format.dart';
import 'package:nahpu/services/maps/natural_earth.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_maplibre.dart';
import 'package:nahpu/screens/projects/statistics/linux_user_map_layers.dart';
import 'package:nahpu/screens/settings/map_settings.dart';

class SpatialStatisticsMap extends StatefulWidget {
  const SpatialStatisticsMap({
    super.key,
    required this.kind,
    required this.rows,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;

  @override
  State<SpatialStatisticsMap> createState() => _SpatialStatisticsMapState();
}

class _SpatialStatisticsMapState extends State<SpatialStatisticsMap> {
  static final Future<List<NaturalEarthPolygon>> _naturalEarthPolygons =
      loadNaturalEarthPolygons();

  @override
  Widget build(BuildContext context) {
    final mappable = mappableSpatialStatistics(widget.rows);
    final omittedCount = widget.rows.length - mappable.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (omittedCount > 0) ...[
          Text(
            '$omittedCount ${omittedCount == 1 ? 'record is' : 'records are'} '
            'listed in the table but cannot be mapped because latitude or '
            'longitude is missing or invalid.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: 480,
          child: Stack(
            children: [
              Positioned.fill(
                child: Platform.isLinux
                    ? FutureBuilder<List<NaturalEarthPolygon>>(
                        future: _naturalEarthPolygons,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _MapMessage(
                              icon: Icons.public_off_outlined,
                              message:
                                  'Unable to load the offline Natural Earth map.',
                            );
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return _NaturalEarthMap(
                            key: ValueKey(
                              '${widget.kind.name}-${mappable.map((row) => row.coordinateId).join(',')}',
                            ),
                            kind: widget.kind,
                            rows: mappable,
                            total: spatialStatisticTotal(widget.rows),
                            polygons: snapshot.data!,
                          );
                        },
                      )
                    : MapLibreSpatialStatisticsMap(
                        kind: widget.kind,
                        rows: mappable,
                        total: spatialStatisticTotal(widget.rows),
                      ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Material(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(8),
                  child: IconButton(
                    tooltip: 'Custom map layers',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserMapLayerSettings(),
                      ),
                    ),
                    icon: const Icon(Icons.layers_outlined),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NaturalEarthMap extends StatelessWidget {
  const _NaturalEarthMap({
    super.key,
    required this.kind,
    required this.rows,
    required this.total,
    required this.polygons,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;
  final int total;
  final List<NaturalEarthPolygon> polygons;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final points = [
      for (final row in rows)
        LatLng(row.decimalLatitude!, row.decimalLongitude!),
    ];
    final maximumCount = rows.fold<int>(
      0,
      (maximum, row) => math.max(maximum, row.count ?? 0),
    );
    final markers = [...rows]
      ..sort((a, b) => (b.count ?? 0).compareTo(a.count ?? 0));

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: points.length == 1
                  ? points.single
                  : const LatLng(18, 0),
              initialZoom: points.length == 1 ? 12 : 1.5,
              initialCameraFit: points.length > 1
                  ? CameraFit.coordinates(
                      coordinates: points,
                      padding: const EdgeInsets.all(40),
                      maxZoom: 14,
                    )
                  : null,
              minZoom: 1,
              maxZoom: 16,
              backgroundColor: colorScheme.surfaceContainerLowest,
            ),
            children: [
              PolygonLayer(
                polygons: [
                  for (final polygon in polygons)
                    Polygon(
                      points: polygon.points,
                      holePointsList: polygon.holes,
                      color: colorScheme.surfaceContainerHighest,
                      borderColor: colorScheme.outlineVariant,
                      borderStrokeWidth: 0.6,
                    ),
                ],
              ),
              const LinuxUserMapLayers(),
              if (rows.isNotEmpty)
                MarkerLayer(
                  markers: [
                    for (final row in markers)
                      _marker(
                        context,
                        row,
                        maximumCount: maximumCount,
                        total: total,
                        colorScheme: colorScheme,
                      ),
                  ],
                ),
            ],
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: _MapAttribution(colorScheme: colorScheme),
          ),
          if (rows.isEmpty)
            const Positioned.fill(
              child: _MapMessage(
                icon: Icons.location_off_outlined,
                message: 'No valid coordinates are available to map.',
              ),
            ),
          if (rows.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: SpatialStatisticsLegend(
                kind: kind,
                rows: rows,
                total: total,
                maximumCount: maximumCount,
              ),
            ),
        ],
      ),
    );
  }

  Marker _marker(
    BuildContext context,
    SpatialStatisticDatum row, {
    required int maximumCount,
    required int total,
    required ColorScheme colorScheme,
  }) {
    final radius = spatialMarkerRadius(
      kind: kind,
      count: row.count ?? 0,
      maximumCount: maximumCount,
    );
    final diameter = radius * 2 + 3;
    final countText = kind.hasCounts
        ? ', ${row.count} ${kind.countLabel} '
              '(${spatialStatisticPercent(row, total).toStringAsFixed(1)}%)'
        : '';
    return Marker(
      point: LatLng(row.decimalLatitude!, row.decimalLongitude!),
      width: diameter,
      height: diameter,
      child: Semantics(
        button: true,
        label: '${row.displayName}$countText',
        child: Tooltip(
          message: '${row.displayName}$countText',
          child: GestureDetector(
            onTap: () => _showDetails(context, row, total),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.32),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.86),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDetails(
    BuildContext context,
    SpatialStatisticDatum row,
    int total,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${formatCoordinate(row.decimalLatitude, decimals: 6)}, '
                '${formatCoordinate(row.decimalLongitude, decimals: 6)}',
              ),
              if (row.elevationInMeter != null)
                Text(
                  '${formatCoordinate(row.elevationInMeter, decimals: 2)} m',
                ),
              if (kind.hasCounts) ...[
                const SizedBox(height: 8),
                Text('${row.count} ${kind.countLabel}'),
                Text(
                  '${spatialStatisticPercent(row, total).toStringAsFixed(1)}%',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MapAttribution extends StatelessWidget {
  const _MapAttribution({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) => Material(
    color: colorScheme.surface.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(4),
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Text('Natural Earth', style: TextStyle(fontSize: 10)),
    ),
  );
}

class _MapMessage extends StatelessWidget {
  const _MapMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(
      context,
    ).colorScheme.surfaceContainerLow.withValues(alpha: 0.82),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}
