import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/sites/components/coordinates.dart';
import 'package:nahpu/screens/shared/maps/coordinate_location_map.dart';
import 'package:nahpu/services/database/database.dart';

void main() {
  testWidgets('wide coordinate details put the map beside the details', (
    tester,
  ) async {
    await _pumpDetails(tester, const Size(900, 600));

    final map = tester.getCenter(find.byType(CoordinateLocationMap));
    final details = tester.getCenter(find.text('Elevation'));

    expect(map.dx, greaterThan(details.dx));
  });

  testWidgets('narrow coordinate details put the map above the details', (
    tester,
  ) async {
    await _pumpDetails(tester, const Size(420, 800));

    final map = tester.getCenter(find.byType(CoordinateLocationMap));
    final details = tester.getCenter(find.text('Elevation'));

    expect(map.dy, lessThan(details.dy));
  });
}

Future<void> _pumpDetails(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: CoordinateDetails(coordinate: _coordinate)),
      ),
    ),
  );
  await tester.pump();
}

const _coordinate = CoordinateData(
  id: 1,
  nameId: 'Alpha',
  decimalLatitude: 45,
  decimalLongitude: -93,
  datum: 'WGS84',
  siteID: 10,
);
