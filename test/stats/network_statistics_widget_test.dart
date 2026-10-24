import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/network_canvas.dart';
import 'package:nahpu/screens/projects/statistics/network_statistics.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/network_statistics.dart';
import 'package:nahpu/services/statistics/network_layout.dart';
import 'package:nahpu/services/types/network_statistics.dart';

import '../data/network_fixture.dart';

void main() {
  testWidgets('tapping a record shows what links to it', (tester) async {
    final container = await _pumpPanel(tester);
    final view = networkViewProvider('project-a');

    expect(find.byType(NetworkCanvas), findsOneWidget);
    final layout = container.read(networkLayoutProvider('project-a')).value!;
    final myotis = layout.nodes.firstWhere(
      (node) => node.label == 'Myotis lucifugus',
    );
    await _tapNode(tester, myotis);

    expect(container.read(view).isExpanded(myotis.key), isTrue);
    expect(
      find.byKey(const ValueKey('statistics-network-node-details')),
      findsOneWidget,
    );
    expect(find.text('3 specimens'), findsOneWidget);
    final expanded = container.read(networkLayoutProvider('project-a')).value!;
    expect(
      expanded.nodes.map((node) => node.label),
      containsAll(['HHA-1', 'HHA-2', 'Ana Lee', 'Bo Smith']),
    );

    await tester.tap(find.text('Hide links'));
    await _settle(tester);
    expect(container.read(view).isExpanded(myotis.key), isFalse);
  });

  testWidgets('the tapped record stays put while the network grows', (
    tester,
  ) async {
    final container = await _pumpPanel(tester);
    final canvasState = tester.state(find.byType(NetworkCanvas));
    final before = container.read(networkLayoutProvider('project-a')).value!;
    final myotis = before.nodes.firstWhere(
      (node) => node.label == 'Myotis lucifugus',
    );
    final onScreen = _screenPosition(tester, myotis.center);

    await _tapNode(tester, myotis);

    final after = container.read(networkLayoutProvider('project-a')).value!;
    expect(after.nodes.length, greaterThan(before.nodes.length));
    expect(
      tester.state(find.byType(NetworkCanvas)),
      same(canvasState),
      reason: 'opening the details panel keeps the canvas and its view',
    );
    final moved = _screenPosition(tester, after.nodeFor(myotis.key)!.center);
    expect((moved - onScreen).distance, lessThan(1));
  });

  testWidgets('the layered layout draws one column per record type', (
    tester,
  ) async {
    final container = await _pumpPanel(tester);

    await tester.tap(find.text('Layered'));
    await _settle(tester);

    final layout = container.read(networkLayoutProvider('project-a')).value!;
    expect(layout.columns.map((column) => column.type), networkDefaultColumns);
    expect(
      find.byKey(const ValueKey('statistics-network-column-site')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('statistics-network-column-media')),
    );
    await _settle(tester);
    expect(
      container.read(networkViewProvider('project-a')).columns.last,
      NetworkNodeType.media,
    );
  });

  testWidgets('full screen shares the network state', (tester) async {
    final container = await _pumpPanel(tester);
    final layout = container.read(networkLayoutProvider('project-a')).value!;
    final site = layout.nodes.firstWhere(
      (node) => node.kind == NetworkNodeKind.record,
    );
    await _tapNode(tester, site);

    await tester.tap(
      find.byKey(const ValueKey('statistics-network-full-screen')),
    );
    await _settle(tester);

    expect(find.byType(NetworkStatisticsFullScreen), findsOneWidget);
    expect(
      container.read(networkViewProvider('project-a')).isExpanded(site.key),
      isTrue,
    );
    expect(find.byType(NetworkCanvas), findsOneWidget);
  });
}

Future<ProviderContainer> _pumpPanel(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final database = await tester.runAsync(() async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await seedNetworkStatistics(db);
    return db;
  });
  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(database!)],
  );
  addTearDown(() async {
    container.dispose();
    await tester.runAsync(database.close);
  });

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NetworkStatisticsPanel(
              projectUuid: 'project-a',
              projectName: 'Project A',
              height: 900,
              sectionSwitch: const Text('Network'),
            ),
          ),
        ),
      ),
    ),
  );
  await _settle(tester);
  return container;
}

/// Lets the database streams deliver and the canvas fit itself.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Taps [node] through the canvas, mapping network space to the screen.
Future<void> _tapNode(WidgetTester tester, NetworkLayoutNode node) async {
  await tester.tapAt(_screenPosition(tester, node.center));
  await _settle(tester);
}

/// Maps a point in network space to the screen through the canvas's pan and
/// zoom.
Offset _screenPosition(WidgetTester tester, Offset point) {
  final paint = find.descendant(
    of: find.byType(NetworkCanvas),
    matching: find.byType(CustomPaint),
  );
  return tester.renderObject<RenderBox>(paint.last).localToGlobal(point);
}
