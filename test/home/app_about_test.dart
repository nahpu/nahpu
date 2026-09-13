import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/home/components/menu_drawer.dart';
import 'package:nahpu/screens/shared/common/tropical_mountains.dart';
import 'package:nahpu/services/database/database.dart' show kSchemaVersion;
import 'package:nahpu/services/providers/app_info.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// About used to be a fixed 360px dialog with no schema version. It now
/// adapts to the screen and shows what the app and its database are running.
void main() {
  Future<void> openAbout(
    WidgetTester tester,
    Size size, {
    int schemaVersion = kSchemaVersion,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: 'NAHPU',
              packageName: 'com.hhandika.nahpu',
              version: '1.2.3',
              buildNumber: '4',
            ),
          ),
          databaseSchemaVersionProvider.overrideWith(
            (ref) async => schemaVersion,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(drawer: HomeMenuDrawer(), body: SizedBox()),
        ),
      ),
    );
    tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
    // A short screen only builds the drawer tiles that fit, so the list is
    // scrolled until the About tile exists.
    await tester.scrollUntilVisible(
      find.text('About'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(HomeMenuDrawer),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
  }

  testWidgets('compact screens open About as a bottom sheet', (tester) async {
    await openAbout(tester, const Size(360, 640));

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('v1.2.3 (build 4)'), findsOneWidget);
    expect(find.text('Tropical Mountains'), findsOneWidget);
    expect(find.text('v$kSchemaVersion'), findsOneWidget);
    expect(find.textContaining('App supports'), findsNothing);
    expect(find.byType(TropicalMountainsBackdrop), findsOneWidget);
    expect(find.byTooltip('Close'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide screens open About as a dialog', (tester) async {
    await openAbout(tester, const Size(1200, 900));

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.text('Codename'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a schema mismatch names the version this app supports', (
    tester,
  ) async {
    await openAbout(
      tester,
      const Size(1200, 900),
      schemaVersion: kSchemaVersion - 1,
    );

    expect(find.text('v${kSchemaVersion - 1}'), findsOneWidget);
    expect(find.text('App supports v$kSchemaVersion'), findsOneWidget);
  });

  testWidgets('Licenses opens the license page', (tester) async {
    await openAbout(tester, const Size(1200, 900));

    await tester.tap(find.text('Licenses'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(LicensePage), findsOneWidget);
  });
}
