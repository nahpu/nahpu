import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre/maplibre.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/providers/map_layers.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/statistics/spatial.dart';
import 'package:nahpu/services/statistics/spatial_map_style.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_legend.dart';

class MapLibreSpatialStatisticsMap extends ConsumerWidget {
  const MapLibreSpatialStatisticsMap({
    super.key,
    required this.kind,
    required this.rows,
    required this.total,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basemap =
        ref.watch(spatialBasemapStyleProvider).value ??
        SpatialBasemapStyle.automatic;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catalog =
        ref.watch(userMapCatalogProvider).value ?? const UserMapCatalog();
    final style = getUserMapDirectory().then(
      (directory) => SpatialMapStyleService.build(
        style: basemap,
        isDark: isDark,
        colorScheme: colorScheme,
        kind: kind,
        rows: rows,
        total: total,
        catalog: catalog,
        userMapDirectory: directory,
      ),
    );
    return FutureBuilder<String>(
      future: style,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _MapLibreMessage(
            message: 'Unable to prepare the map: ${snapshot.error}',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _MapLibreMap(
          key: ValueKey(snapshot.data.hashCode),
          kind: kind,
          rows: rows,
          total: total,
          style: snapshot.data!,
        );
      },
    );
  }
}

class _MapLibreMap extends StatefulWidget {
  const _MapLibreMap({
    super.key,
    required this.kind,
    required this.rows,
    required this.total,
    required this.style,
  });

  final SpatialStatisticKind kind;
  final List<SpatialStatisticDatum> rows;
  final int total;
  final String style;

  @override
  State<_MapLibreMap> createState() => _MapLibreMapState();
}

class _MapLibreMapState extends State<_MapLibreMap> {
  MapController? _controller;

  @override
  Widget build(BuildContext context) {
    final first = widget.rows.firstOrNull;
    final maximumCount = widget.rows.fold<int>(
      0,
      (maximum, row) => math.max(maximum, row.count ?? 0),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          MapLibreMap(
            options: MapOptions(
              initStyle: widget.style,
              initCenter: Geographic(
                lon: first?.decimalLongitude ?? 0,
                lat: first?.decimalLatitude ?? 18,
              ),
              initZoom: widget.rows.length == 1 ? 12 : 1.5,
              minZoom: 1,
              maxZoom: 16,
              maxPitch: 60,
              gestures: const MapGestures(
                pan: true,
                zoom: true,
                rotate: false,
                pitch: false,
              ),
            ),
            onMapCreated: (controller) => _controller = controller,
            onStyleLoaded: (_) => _fitRows(),
            onEvent: _handleEvent,
            children: [
              const Positioned(
                left: 8,
                bottom: 8,
                child: _MapLibreAttribution(),
              ),
              Positioned(
                left: 8,
                top: 56,
                child: _MapLibreControls(onReset: _resetCamera),
              ),
              // Scale bar to right bottom
              const Positioned(right: 8, bottom: 8, child: MapScalebar()),
            ],
          ),
          if (widget.rows.isEmpty)
            const Positioned.fill(
              child: _MapLibreMessage(
                message: 'No valid coordinates are available to map.',
              ),
            ),
          if (widget.rows.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: SpatialStatisticsLegend(
                kind: widget.kind,
                rows: widget.rows,
                total: widget.total,
                maximumCount: maximumCount,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _fitRows() async {
    final controller = _controller;
    if (controller == null || widget.rows.length < 2) return;
    await controller.fitBounds(
      bounds: LngLatBounds.fromPoints([
        for (final row in widget.rows)
          Geographic(lon: row.decimalLongitude!, lat: row.decimalLatitude!),
      ]),
      padding: const EdgeInsets.all(40),
      webMaxZoom: 14,
    );
  }

  Future<void> _resetCamera() async {
    final controller = _controller;
    if (controller == null) return;
    if (widget.rows.length > 1) return _fitRows();
    final row = widget.rows.firstOrNull;
    await controller.animateCamera(
      center: Geographic(
        lon: row?.decimalLongitude ?? 0,
        lat: row?.decimalLatitude ?? 18,
      ),
      zoom: row == null ? 1.5 : 12,
      nativeDuration: const Duration(milliseconds: 250),
    );
  }

  void _handleEvent(MapEvent event) {
    if (event is! MapEventClick) return;
    final feature = _controller
        ?.featuresAtPoint(
          event.screenPoint,
          layerIds: const [SpatialMapStyleService.statisticsLayerId],
        )
        .firstOrNull;
    final coordinateId = feature?.properties['coordinateId'];
    if (coordinateId is! num) return;
    final row = widget.rows
        .where((candidate) => candidate.coordinateId == coordinateId.toInt())
        .firstOrNull;
    if (row != null) _showDetails(row);
  }

  void _showDetails(SpatialStatisticDatum row) {
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
              if (row.locality != null) Text(row.locality!),
              if (row.elevationInMeter != null)
                Text(
                  '${formatCoordinate(row.elevationInMeter, decimals: 2)} m',
                ),
              if (widget.kind.hasCounts) ...[
                const SizedBox(height: 8),
                Text('${row.count} ${widget.kind.countLabel}'),
                Text(
                  '${spatialStatisticPercent(row, widget.total).toStringAsFixed(1)}%',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MapLibreControls extends StatelessWidget {
  const _MapLibreControls({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MapLibreControlButton(
          tooltip: 'Zoom in',
          icon: Icons.add,
          onPressed: () => _changeZoom(context, 1),
        ),
        _MapLibreControlButton(
          tooltip: 'Zoom out',
          icon: Icons.remove,
          onPressed: () => _changeZoom(context, -1),
        ),
        _MapLibreControlButton(
          tooltip: 'Center map on statistics',
          icon: Icons.center_focus_strong_outlined,
          onPressed: onReset,
        ),
      ],
    ),
  );

  Future<void> _changeZoom(BuildContext context, double amount) async {
    final controller = MapController.maybeOf(context);
    if (controller == null) return;
    await controller.animateCamera(
      zoom: controller.getCamera().zoom + amount,
      nativeDuration: const Duration(milliseconds: 200),
    );
  }
}

class _MapLibreControlButton extends StatelessWidget {
  const _MapLibreControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    visualDensity: VisualDensity.compact,
    onPressed: onPressed,
    icon: Icon(icon),
  );
}

class _MapLibreAttribution extends StatelessWidget {
  const _MapLibreAttribution();

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(4),
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Text(
        '© OpenStreetMap contributors · OpenFreeMap · Natural Earth',
        style: TextStyle(fontSize: 10),
      ),
    ),
  );
}

class _MapLibreMessage extends StatelessWidget {
  const _MapLibreMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(
      context,
    ).colorScheme.surfaceContainerLow.withValues(alpha: 0.82),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    ),
  );
}
