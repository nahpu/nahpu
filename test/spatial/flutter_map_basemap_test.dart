import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:nahpu/screens/shared/maps/flutter_map_basemap.dart';
import 'package:nahpu/screens/shared/maps/offline_basemap_notice.dart';
import 'package:nahpu/services/providers/map_layers.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/sites/natural_earth.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _polygons = [
  NaturalEarthPolygon(
    points: [LatLng(0, 0), LatLng(0, 10), LatLng(10, 10), LatLng(0, 0)],
    holes: [],
  ),
];

Widget _map(SpatialBasemapStyle style, {bool isFallback = false}) =>
    ProviderScope(
      overrides: [
        vectorBasemapStyleProvider.overrideWith(
          (ref, style) => Future.error(StateError('offline')),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(5, 5),
                    initialZoom: 2,
                  ),
                  children: [
                    FlutterMapBasemap(
                      style: style,
                      polygons: _polygons,
                      isFallback: isFallback,
                    ),
                  ],
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: FlutterMapBasemapAttribution(
                    style: style,
                    isFallback: isFallback,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('falls back to Natural Earth when the online style fails', (
    tester,
  ) async {
    await tester.pumpWidget(_map(SpatialBasemapStyle.positron));
    await tester.pumpAndSettle();

    expect(find.byType(PolygonLayer), findsOneWidget);
    expect(find.byType(OfflineBasemapNotice), findsOneWidget);
  });

  testWidgets('offline Natural Earth draws polygons with plain attribution', (
    tester,
  ) async {
    await tester.pumpWidget(_map(SpatialBasemapStyle.naturalEarthOffline));
    await tester.pumpAndSettle();

    expect(find.byType(PolygonLayer), findsOneWidget);
    expect(find.byType(NaturalEarthAttribution), findsOneWidget);
  });

  testWidgets('none draws no base layer', (tester) async {
    await tester.pumpWidget(_map(SpatialBasemapStyle.none));
    await tester.pumpAndSettle();

    expect(find.byType(PolygonLayer), findsNothing);
    expect(find.byType(NaturalEarthAttribution), findsNothing);
  });

  group('SpatialBasemapStyleSetting', () {
    Future<SpatialBasemapStyle> savedStyle(String name) async {
      SharedPreferences.setMockInitialValues({
        spatialBasemapStylePrefKey: name,
      });
      final container = ProviderContainer(
        overrides: [
          settingProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container.read(spatialBasemapStyleProvider.future);
    }

    test('keeps a saved style this platform can draw', () async {
      expect(await savedStyle('liberty'), SpatialBasemapStyle.liberty);
    });

    test('falls back to automatic for an unknown style', () async {
      expect(await savedStyle('satellite'), SpatialBasemapStyle.automatic);
    });
  });
}
