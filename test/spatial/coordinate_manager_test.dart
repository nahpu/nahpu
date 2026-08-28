import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/sites/components/coordinates.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/types/geography.dart';

void main() {
  testWidgets('coordinate manager keeps export selection separate from focus', (
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
    expect(find.byTooltip('View map'), findsNothing);
    expect(find.byTooltip('View map full screen'), findsOneWidget);
    expect(_checkbox(tester, 1).value, isTrue);
    expect(_checkbox(tester, 2).value, isTrue);

    await tester.tap(find.text('Clear all'));
    await tester.pump();

    expect(_checkbox(tester, 1).value, isFalse);
    expect(_checkbox(tester, 2).value, isFalse);
    expect(_opacity(tester, 1).opacity, 0.55);
    expect(find.text('0 of 2 coordinates'), findsOneWidget);
    expect(find.text('Export coordinates (0)'), findsOneWidget);
    expect(_opacity(tester, 2).opacity, 0.55);

    await tester.tap(find.text('Alpha'));
    await tester.pump();

    expect(_checkbox(tester, 1).value, isFalse);
    expect(_checkbox(tester, 2).value, isFalse);
    expect(_opacity(tester, 1).opacity, 0.55);
    expect(
      tester
          .widget<Material>(
            find.byKey(const ValueKey('coordinate-manager-tile-1')),
          )
          .color,
      isNot(
        Theme.of(
          tester.element(
            find.byKey(const ValueKey('coordinate-manager-tile-1')),
          ),
        ).colorScheme.surfaceContainerHighest,
      ),
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('coordinate-manager-export')),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('coordinate-manager-tile-1')),
        matching: find.byType(Checkbox),
      ),
    );
    await tester.pump();

    expect(_checkbox(tester, 1).value, isTrue);
    expect(find.text('1 of 2 coordinates'), findsOneWidget);
    expect(find.text('Export coordinates (1)'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('coordinate-manager-export')),
          )
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Select all'));
    await tester.pump();

    expect(_checkbox(tester, 1).value, isTrue);
    expect(_checkbox(tester, 2).value, isTrue);
    expect(find.text('2 coordinates'), findsOneWidget);
  });

  testWidgets('small coordinate manager opens the map in a full-screen route', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 900);
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

    expect(find.byTooltip('View map'), findsOne);
    expect(find.byType(TabBar), findsNothing);

    await tester.tap(find.byTooltip('View map'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Coordinate map'), findsOneWidget);
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

const _sites = [SiteRecord(site: SiteData(id: 10, siteID: 'Site A'))];

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
