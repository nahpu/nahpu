import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_table.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';

void main() {
  testWidgets('coordinate table includes all coordinate form fields', (
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
            kind: SpatialStatisticKind.coordinate,
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
      'Decimal Latitude',
      'Decimal Longitude',
      'Elevation (m)',
      'Datum',
      'Uncertainty (m)',
      'GPS Unit',
      'Notes',
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
}
