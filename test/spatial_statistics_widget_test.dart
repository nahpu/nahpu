import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_legend.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_table.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';

void main() {
  testWidgets('spatial table includes coordinate metrics', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SpatialStatisticsTable(
            kind: SpatialStatisticKind.specimens,
            rows: [
              SpatialStatisticDatum(
                coordinateId: 1,
                name: 'Alpha coordinate',
                decimalLatitude: 45.123456,
                decimalLongitude: -93.123456,
                elevationInMeter: 320,
                datum: 'WGS84',
                uncertaintyInMeters: 8,
                gpsUnit: 'GPS A',
                notes: 'Forest edge',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in [
      'Name',
      'Locality',
      'Latitude',
      'Longitude',
      'Elevation (m)',
      'Count',
      'Percent',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Alpha coordinate'), findsOneWidget);
    expect(find.text('—'), findsWidgets);
  });

  testWidgets('metric table includes count and percent', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SpatialStatisticsTable(
            kind: SpatialStatisticKind.specimens,
            rows: [
              SpatialStatisticDatum(
                coordinateId: 1,
                name: 'Alpha coordinate',
                decimalLatitude: 45,
                decimalLongitude: -93,
                elevationInMeter: 320,
                datum: null,
                uncertaintyInMeters: null,
                gpsUnit: null,
                notes: null,
                count: 4,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Count'), findsOneWidget);
    expect(find.text('Percent'), findsOneWidget);
    expect(find.text('100.0%'), findsOneWidget);
  });

  testWidgets('spatial legend centers true-size circles in one column', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SpatialStatisticsLegend(
            kind: SpatialStatisticKind.specimens,
            total: 21,
            maximumCount: 16,
            rows: [
              SpatialStatisticDatum(
                coordinateId: 1,
                name: 'One',
                decimalLatitude: 1,
                decimalLongitude: 1,
                elevationInMeter: null,
                datum: null,
                uncertaintyInMeters: null,
                gpsUnit: null,
                notes: null,
                count: 1,
              ),
              SpatialStatisticDatum(
                coordinateId: 2,
                name: 'Four',
                decimalLatitude: 2,
                decimalLongitude: 2,
                elevationInMeter: null,
                datum: null,
                uncertaintyInMeters: null,
                gpsUnit: null,
                notes: null,
                count: 4,
              ),
              SpatialStatisticDatum(
                coordinateId: 3,
                name: 'Sixteen',
                decimalLatitude: 3,
                decimalLongitude: 3,
                elevationInMeter: null,
                datum: null,
                uncertaintyInMeters: null,
                gpsUnit: null,
                notes: null,
                count: 16,
              ),
            ],
          ),
        ),
      ),
    );

    final circles = find
        .byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        )
        .evaluate()
        .toList();
    final circleWidths = [
      for (final circle in circles)
        (circle.renderObject! as RenderBox).size.width,
    ];

    expect(find.text('Specimens'), findsOneWidget);
    expect(find.text('1 (4.8%)'), findsOneWidget);
    expect(find.text('4 (19.0%)'), findsOneWidget);
    expect(find.text('16 (76.2%)'), findsOneWidget);
    expect(circleWidths, [19, 35, 67]);
  });
}
