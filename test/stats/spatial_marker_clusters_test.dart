import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_markers.dart';
import 'package:nahpu/services/statistics/spatial_marker_clusters.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';

typedef _Item = ({String id, double x, double y, int count});

List<MarkerCluster<_Item>> _cluster(List<_Item> items, {double radius = 10}) =>
    clusterOverlappingMarkers<_Item>(
      items: items,
      position: (item) => math.Point(item.x, item.y),
      count: (item) => item.count,
      radius: (_) => radius,
    );

SpatialStatisticDatum _row(
  int id, {
  required double latitude,
  required double longitude,
  int? count,
  double? elevation,
}) => SpatialStatisticDatum(
  coordinateId: id,
  name: 'Site $id',
  decimalLatitude: latitude,
  decimalLongitude: longitude,
  elevationInMeter: elevation,
  datum: null,
  uncertaintyInMeters: null,
  gpsUnit: null,
  notes: null,
  count: count,
);

/// Every map label must sit fully inside its circle's 2px outline.
void _expectLabelsInsideCircles(WidgetTester tester) {
  final labels = find.descendant(
    of: find.byType(SpatialStatisticsMarkerLayer),
    matching: find.byType(Text),
  );
  expect(labels, findsWidgets);
  for (final label in labels.evaluate()) {
    final circle = find.ancestor(
      of: find.byWidget(label.widget),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            (widget.decoration as BoxDecoration?)?.shape == BoxShape.circle,
      ),
    );
    final circleRect = tester.getRect(circle.first);
    final textRect = tester.getRect(find.byWidget(label.widget));
    final radius = circleRect.width / 2 - 2;
    for (final corner in [
      textRect.topLeft,
      textRect.topRight,
      textRect.bottomLeft,
      textRect.bottomRight,
    ]) {
      expect(
        (corner - circleRect.center).distance,
        lessThanOrEqualTo(radius),
        reason: '"${(label.widget as Text).data}" touches its circle',
      );
    }
  }
}

void main() {
  group('clusterOverlappingMarkers', () {
    test('keeps circles that do not overlap apart', () {
      final clusters = _cluster([
        (id: 'a', x: 0, y: 0, count: 3),
        (id: 'b', x: 50, y: 0, count: 1),
      ]);
      expect(clusters, hasLength(2));
      expect(clusters.every((cluster) => cluster.isSingle), isTrue);
    });

    test('merges overlapping circles at a count-weighted center', () {
      final clusters = _cluster([
        (id: 'small', x: 10, y: 0, count: 1),
        (id: 'large', x: 0, y: 0, count: 3),
      ]);
      expect(clusters, hasLength(1));
      final cluster = clusters.single;
      expect(cluster.count, 4);
      expect(cluster.members.map((item) => item.id), ['large', 'small']);
      expect(cluster.center.x, closeTo(2.5, 1e-9));
      expect(cluster.center.y, closeTo(0, 1e-9));
    });

    test('merges groups that grow into each other', () {
      // a and c start apart; once b joins a, the larger group reaches c.
      final clusters = clusterOverlappingMarkers<_Item>(
        items: [
          (id: 'a', x: 0, y: 0, count: 5),
          (id: 'c', x: 30, y: 0, count: 5),
          (id: 'b', x: 12, y: 0, count: 3),
        ],
        position: (item) => math.Point(item.x, item.y),
        count: (item) => item.count,
        radius: (count) => count * 2.0,
      );
      expect(clusters, hasLength(1));
      expect(clusters.single.count, 13);
    });
  });

  group('spatial cluster helpers', () {
    test('centers a group on its count-weighted position', () {
      final center = spatialClusterCenter([
        _row(1, latitude: 10, longitude: 20, count: 3),
        _row(2, latitude: 14, longitude: 24, count: 1),
      ]);
      expect(center.latitude, closeTo(11, 1e-9));
      expect(center.longitude, closeTo(21, 1e-9));
    });

    test('still weighs coordinates that have no count', () {
      final center = spatialClusterCenter([
        _row(1, latitude: 0, longitude: 0, count: 0),
        _row(2, latitude: 10, longitude: 10, count: null),
      ]);
      expect(center.latitude, closeTo(5, 1e-9));
    });

    test('summarizes a group and caps the listed members', () {
      final members = [
        for (var id = 1; id <= 7; id++)
          _row(id, latitude: 0, longitude: 0, count: 8 - id),
      ];
      expect(
        spatialClusterTitle(SpatialStatisticKind.specimens, members, 28),
        '7 coordinates · 28 specimens',
      );
      final details = spatialClusterDetails(members, canZoomIn: true);
      expect(details, hasLength(spatialClusterDetailLimit + 2));
      expect(details.first, 'Site 1: 7');
      expect(details[spatialClusterDetailLimit], '+2 more');
      expect(details.last, 'Tap to zoom in');
      expect(spatialClusterDetails(members, canZoomIn: false).last, '+2 more');
    });

    test('draws small groups at a legible size', () {
      expect(
        spatialClusterDisplayRadius(count: 2, maximumCount: 100),
        spatialClusterMinimumDisplayRadius,
      );
      expect(
        spatialClusterDisplayRadius(count: 400, maximumCount: 100),
        spatialClusterMaxRadius,
      );
    });
  });

  group('SpatialStatisticSummary', () {
    test('totals counts and finds the top coordinate and elevation', () {
      final summary = SpatialStatisticSummary.fromRows([
        _row(1, latitude: 0, longitude: 0, count: 2, elevation: 1200),
        _row(2, latitude: 0, longitude: 0, count: 7, elevation: 150),
        _row(3, latitude: 0, longitude: 0, count: null),
      ]);
      expect(summary.coordinateCount, 3);
      expect(summary.total, 9);
      expect(summary.average, 3);
      expect(summary.top?.coordinateId, 2);
      expect(summary.minimumElevation, 150);
      expect(summary.maximumElevation, 1200);
    });

    test('has no top coordinate when every count is zero', () {
      final summary = SpatialStatisticSummary.fromRows([
        _row(1, latitude: 0, longitude: 0, count: 0),
      ]);
      expect(summary.top, isNull);
      expect(summary.minimumElevation, isNull);
    });
  });

  testWidgets('metric strip sums specimens but averages species', (
    tester,
  ) async {
    final rows = [
      _row(1, latitude: 0, longitude: 0, count: 4, elevation: 120),
      _row(2, latitude: 0, longitude: 0, count: 2, elevation: 1450),
    ];
    Future<void> pump(SpatialStatisticKind kind) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpatialMetricStrip(
            kind: kind,
            summary: SpatialStatisticSummary.fromRows(rows),
          ),
        ),
      ),
    );

    await pump(SpatialStatisticKind.specimens);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Coordinates'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('Specimens'), findsOneWidget);
    expect(find.text('Top: Site 1'), findsOneWidget);
    expect(find.text('120–1450 m'), findsOneWidget);

    await pump(SpatialStatisticKind.species);
    expect(find.text('3.0'), findsOneWidget);
    expect(find.text('Mean species per coordinate'), findsOneWidget);
    expect(find.text('6'), findsNothing);
  });

  testWidgets('overlapping map circles group and split when zoomed in', (
    tester,
  ) async {
    final rows = [
      _row(1, latitude: 10, longitude: 10, count: 6),
      _row(2, latitude: 10.001, longitude: 10.001, count: 3),
      _row(3, latitude: -30, longitude: 60, count: 1),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            height: 400,
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(0, 30),
                initialZoom: 2,
                maxZoom: 16,
              ),
              children: [
                SpatialStatisticsMarkerLayer(
                  kind: SpatialStatisticKind.specimens,
                  rows: rows,
                  total: 10,
                  maximumCount: 6,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final bubble = find.byWidgetPredicate(
      (widget) =>
          widget is Tooltip &&
          (widget.message?.startsWith('2 coordinates · 9 specimens') ?? false),
    );
    expect(bubble, findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.byTooltip('Site 3, 1 specimens (10.0%)'), findsOneWidget);

    _expectLabelsInsideCircles(tester);

    await tester.tap(bubble);
    await tester.pumpAndSettle();
    _expectLabelsInsideCircles(tester);

    expect(bubble, findsNothing);
    expect(find.byTooltip('Site 1, 6 specimens (60.0%)'), findsOneWidget);
    expect(find.byTooltip('Site 2, 3 specimens (30.0%)'), findsOneWidget);
  });
}
