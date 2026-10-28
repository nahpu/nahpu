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
      containsAll(['HHA-1', 'HHA-2', 'Skin', 'Ctenophthalmus agyrtes']),
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

  testWidgets('linked record types can be picked for the start type', (
    tester,
  ) async {
    final container = await _pumpPanel(tester);
    final view = networkViewProvider('project-a');
    expect(
      find.byKey(const ValueKey('statistics-network-linked-taxon')),
      findsNothing,
      reason: 'the start type is not offered as a link',
    );
    final layout = container.read(networkLayoutProvider('project-a')).value!;
    final myotis = layout.nodes.firstWhere(
      (node) => node.label == 'Myotis lucifugus',
    );
    await _tapNode(tester, myotis);

    await tester.tap(
      find.byKey(const ValueKey('statistics-network-linked-site')),
    );
    await _settle(tester);
    expect(
      container.read(view).linkedTypes,
      isNot(contains(NetworkNodeType.site)),
    );
    final expanded = container.read(networkLayoutProvider('project-a')).value!;
    expect(
      expanded.nodes.map((node) => node.key.type),
      isNot(contains(NetworkNodeType.site)),
    );
    expect(container.read(view).isExpanded(myotis.key), isTrue);
  });

  testWidgets('the layered layout draws one column per record type', (
    tester,
  ) async {
    final container = await _pumpPanel(tester);

    await tester.tap(find.text('Layered'));
    await _settle(tester);

    final layout = container.read(networkLayoutProvider('project-a')).value!;
    expect(
      layout.columns.map((column) => column.column),
      networkDefaultColumns,
    );
    expect(
      find.byKey(const ValueKey('statistics-network-column-site')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('statistics-network-column-specimen')),
    );
    await _settle(tester);
    expect(
      container.read(networkViewProvider('project-a')).columns.last,
      const NetworkColumn(NetworkNodeType.specimen),
    );
  });

  testWidgets('fields of chosen types become columns, up to seven', (
    tester,
  ) async {
    final container = await _pumpPanel(tester);
    final view = networkViewProvider('project-a');
    await tester.tap(find.text('Layered'));
    await _settle(tester);

    expect(
      find.byKey(const ValueKey('statistics-network-field-specimenSex')),
      findsNothing,
      reason: 'fields are offered only for chosen record types',
    );
    expect(find.text('Up to 7 columns'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('statistics-network-field-siteCountry')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('statistics-network-field-eventYear')),
    );
    await _settle(tester);
    expect(container.read(view).columns, hasLength(networkMaxColumns));
    final layout = container.read(networkLayoutProvider('project-a')).value!;
    expect(
      layout.columns.last.column,
      NetworkColumn.field(NetworkField.eventYear),
    );
    expect(
      layout.nodes.map((node) => node.label),
      containsAll(['Indonesia', '2024']),
    );

    final media = tester.widget<FilterChip>(
      find.byKey(const ValueKey('statistics-network-column-media')),
    );
    expect(media.onSelected, isNull, reason: 'no eighth column');

    await tester.tap(
      find.byKey(const ValueKey('statistics-network-column-site')),
    );
    await _settle(tester);
    expect(
      container.read(view).columns,
      isNot(contains(NetworkColumn.field(NetworkField.siteCountry))),
      reason: 'a field leaves with its record type',
    );
  });

  testWidgets('selecting a site or specimen shows its details', (tester) async {
    final container = await _pumpPanel(tester);
    await tester.tap(find.text('Layered'));
    await _settle(tester);
    await tester.tap(
      find.byKey(const ValueKey('statistics-network-column-specimen')),
    );
    await _settle(tester);

    var layout = container.read(networkLayoutProvider('project-a')).value!;
    await _tapNode(tester, layout.nodes.firstWhere((n) => n.label == 'AL 1'));
    final facts = find.byKey(const ValueKey('statistics-network-record-facts'));
    expect(facts, findsOneWidget);
    for (final value in [
      'MUS-1',
      'Male',
      'Liver, Skin',
      'Ctenophthalmus agyrtes',
    ]) {
      expect(
        find.descendant(of: facts, matching: find.text(value)),
        findsOneWidget,
      );
    }

    layout = container.read(networkLayoutProvider('project-a')).value!;
    await _tapNode(tester, layout.nodes.firstWhere((n) => n.label == 'HHA-1'));
    expect(
      find.descendant(
        of: facts,
        matching: find.text('Sulawesi Selatan, Indonesia'),
      ),
      findsOneWidget,
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
    expect(
      find.byKey(const ValueKey('statistics-network-options-rail')),
      findsOneWidget,
      reason: 'full screen starts with the options folded',
    );

    await tester.tap(
      find.byKey(const ValueKey('statistics-network-exit-full-screen')),
    );
    await _settle(tester);
    expect(find.byType(NetworkStatisticsFullScreen), findsNothing);
  });

  testWidgets('the options fold into a rail to widen the network', (
    tester,
  ) async {
    final container = await _pumpPanel(tester);
    final pane = find.byKey(const ValueKey('statistics-network-options-pane'));
    final rail = find.byKey(const ValueKey('statistics-network-options-rail'));
    expect(pane, findsOneWidget);
    final canvasWidth = tester.getSize(find.byType(NetworkCanvas)).width;

    await tester.tap(
      find.byKey(const ValueKey('statistics-network-options-collapse')),
    );
    await _settle(tester);
    expect(pane, findsNothing);
    expect(rail, findsOneWidget);
    expect(
      tester.getSize(find.byType(NetworkCanvas)).width,
      greaterThan(canvasWidth),
    );

    await tester.tap(find.byTooltip('Layered'));
    await _settle(tester);
    expect(
      container.read(networkViewProvider('project-a')).layout,
      NetworkLayout.layered,
    );

    await tester.tap(
      find.byKey(const ValueKey('statistics-network-options-expand')),
    );
    await _settle(tester);
    expect(pane, findsOneWidget);
  });

  testWidgets('on a narrow screen a tapped record opens in a modal sheet', (
    tester,
  ) async {
    final container = await _pumpPanel(tester, size: const Size(390, 844));
    final sheet = find.byKey(const ValueKey('statistics-network-sheet'));
    final details = find.byKey(
      const ValueKey('statistics-network-node-details'),
    );
    expect(sheet, findsNothing, reason: 'the card leaves the canvas whole');

    final layout = container.read(networkLayoutProvider('project-a')).value!;
    final myotis = layout.nodes.firstWhere(
      (node) => node.label == 'Myotis lucifugus',
    );
    await _tapNode(tester, myotis);
    await tester.pumpAndSettle();

    expect(find.descendant(of: sheet, matching: details), findsOneWidget);
    expect(
      tester.getRect(sheet).bottom,
      844,
      reason: 'the sheet rises from the bottom of the screen',
    );

    await tester.tap(
      find.descendant(of: sheet, matching: find.text('Options')),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: sheet,
        matching: find.byKey(
          const ValueKey('statistics-network-layout-control'),
        ),
      ),
      findsOneWidget,
    );

    await tester.tapAt(const Offset(195, 40));
    await tester.pumpAndSettle();
    expect(sheet, findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('statistics-network-open-sheet')),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: sheet,
        matching: find.byKey(
          const ValueKey('statistics-network-layout-control'),
        ),
      ),
      findsOneWidget,
      reason: 'the options button opens the sheet on its options',
    );
  });

  testWidgets('on a wide screen the tools sit above the details', (
    tester,
  ) async {
    final container = await _pumpPanel(tester);
    final layout = container.read(networkLayoutProvider('project-a')).value!;
    await _tapNode(
      tester,
      layout.nodes.firstWhere((node) => node.label == 'Myotis lucifugus'),
    );

    final card = tester.getRect(
      find.byKey(const ValueKey('statistics-network-content')),
    );
    final tools = tester.getRect(
      find.byKey(const ValueKey('statistics-network-full-screen')),
    );
    final details = tester.getRect(
      find.byKey(const ValueKey('statistics-network-node-details')),
    );
    expect(
      tools.top - card.top,
      lessThan(100),
      reason: 'the tools stay in sight at the top of a tall card',
    );
    expect(tools.bottom, lessThan(details.top));
  });

  testWidgets('a narrow full screen opens with the selected record shown', (
    tester,
  ) async {
    final container = await _pumpPanel(tester, size: const Size(390, 844));
    final layout = container.read(networkLayoutProvider('project-a')).value!;
    await _tapNode(
      tester,
      layout.nodes.firstWhere((node) => node.label == 'Myotis lucifugus'),
    );
    await tester.pumpAndSettle();
    // Closes the modal sheet the tap raised over the card.
    await tester.tapAt(const Offset(195, 40));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('statistics-network-full-screen')),
    );
    await _settle(tester);
    await tester.pumpAndSettle();

    final fullScreen = find.byType(NetworkStatisticsFullScreen);
    final sheet = find.descendant(
      of: fullScreen,
      matching: find.byKey(const ValueKey('statistics-network-sheet')),
    );
    expect(
      find.descendant(
        of: sheet,
        matching: find.byKey(const ValueKey('statistics-network-node-details')),
      ),
      findsOneWidget,
    );
    expect(
      tester.getSize(sheet).height,
      greaterThan(844 * 0.4),
      reason: 'the sheet rises to show the record picked before',
    );

    await tester.tap(
      find.descendant(
        of: fullScreen,
        matching: find.byTooltip('Exit full screen'),
      ),
    );
    await tester.pumpAndSettle();
    expect(fullScreen, findsNothing);
  });

  testWidgets('the fit leaves room for controls over the canvas', (
    tester,
  ) async {
    final container = await _pumpPanel(tester);
    final layout = container.read(networkLayoutProvider('project-a')).value!;

    Future<Rect> fitted(EdgeInsets insets) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 800,
              height: 600,
              child: NetworkCanvas(
                key: UniqueKey(),
                layout: layout,
                selected: null,
                labels: NetworkCanvasLabels(
                  columnLabel: (_) => '',
                  overflowLabel: (_) => '',
                ),
                onNodeTap: (_) {},
                fitSignal: 0,
                fitInsets: insets,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      final points = [
        for (final node in layout.nodes) _screenPosition(tester, node.center),
      ];
      return points
          .skip(1)
          .fold<Rect>(
            Rect.fromPoints(points.first, points.first),
            (rect, point) =>
                rect.expandToInclude(Rect.fromPoints(point, point)),
          );
    }

    final canvasLeft = (1200 - 800) / 2;
    final plain = await fitted(EdgeInsets.zero);
    final inset = await fitted(const EdgeInsets.only(left: 400));
    expect(inset.left, greaterThan(plain.left));
    expect(
      inset.left,
      greaterThanOrEqualTo(canvasLeft + 400),
      reason: 'no node is fitted under the controls on the left',
    );
  });

  testWidgets('a tall canvas pans and zooms in both directions', (
    tester,
  ) async {
    final container = await _pumpPanel(tester);
    final layout = container.read(networkLayoutProvider('project-a')).value!;
    final canvas = find.byType(NetworkCanvas);
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 390,
            height: 1400,
            child: NetworkCanvas(
              layout: layout,
              selected: null,
              labels: NetworkCanvasLabels(
                columnLabel: (_) => '',
                overflowLabel: (_) => '',
              ),
              onNodeTap: (_) {},
              fitSignal: 0,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    final node = layout.nodes.first.center;

    final before = _screenPosition(tester, node);
    await tester.drag(canvas, const Offset(0, 200));
    await tester.pumpAndSettle();
    final after = _screenPosition(tester, node);
    expect(after.dy - before.dy, greaterThan(100), reason: 'pans vertically');

    final center = tester.getCenter(canvas);
    final first = await tester.startGesture(center - const Offset(0, 100));
    final second = await tester.startGesture(center + const Offset(0, 100));
    await first.moveTo(center - const Offset(0, 50));
    await second.moveTo(center + const Offset(0, 50));
    await first.up();
    await second.up();
    await tester.pumpAndSettle();
    final zoomed = (_screenPosition(tester, node) - center).distance;
    expect(zoomed, lessThan((after - center).distance), reason: 'zooms out');
  });
}

Future<ProviderContainer> _pumpPanel(
  WidgetTester tester, {
  Size size = const Size(1200, 1600),
}) async {
  tester.view.physicalSize = size;
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
              sectionSwitch: const Text('Graph'),
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
