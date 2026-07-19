import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/sites/components/coordinates.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/sites.dart';

void main() {
  testWidgets('coordinate manager supports bulk and row selection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coordinateByProjectProvider.overrideWith((ref) async => _coordinates),
          siteEntryProvider.overrideWithBuild((ref, notifier) async => _sites),
        ],
        child: const MaterialApp(home: CoordinateManager()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Select all'), findsOneWidget);
    expect(find.text('Clear all'), findsOneWidget);
    expect(_checkbox(tester, 1).value, isTrue);
    expect(_checkbox(tester, 2).value, isTrue);

    await tester.tap(find.text('Clear all'));
    await tester.pump();

    expect(_checkbox(tester, 1).value, isFalse);
    expect(_checkbox(tester, 2).value, isFalse);
    expect(_opacity(tester, 1).opacity, 0.55);
    expect(_opacity(tester, 2).opacity, 0.55);

    await tester.tap(find.text('Alpha'));
    await tester.pump();

    expect(_checkbox(tester, 1).value, isTrue);
    expect(_checkbox(tester, 2).value, isFalse);
    expect(_opacity(tester, 1).opacity, 1);
    expect(find.text('Share coordinate'), findsOneWidget);

    await tester.tap(find.text('Select all'));
    await tester.pump();

    expect(_checkbox(tester, 1).value, isTrue);
    expect(_checkbox(tester, 2).value, isTrue);
  });
}

Checkbox _checkbox(WidgetTester tester, int coordinateId) {
  return tester.widget<Checkbox>(
    find.descendant(
      of: find.byKey(ValueKey('coordinate-manager-tile-$coordinateId')),
      matching: find.byType(Checkbox),
    ),
  );
}

Opacity _opacity(WidgetTester tester, int coordinateId) {
  return tester.widget<Opacity>(
    find.descendant(
      of: find.byKey(ValueKey('coordinate-manager-tile-$coordinateId')),
      matching: find.byType(Opacity),
    ),
  );
}

const _sites = [SiteData(id: 10, siteID: 'Site A')];

const _coordinates = [
  CoordinateData(
    id: 1,
    nameId: 'Alpha',
    decimalLatitude: 45,
    decimalLongitude: -93,
    datum: 'WGS84',
    siteID: 10,
  ),
  CoordinateData(
    id: 2,
    nameId: 'Beta',
    decimalLatitude: 46,
    decimalLongitude: -94,
    datum: 'WGS84',
    siteID: 10,
  ),
];
