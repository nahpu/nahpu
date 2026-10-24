import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/docs/documentation_widgets.dart';
import 'package:nahpu/screens/shared/docs/mdoc_body.dart';
import 'package:nahpu/services/docs/day_one_figures.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';
import 'package:nahpu/styles/themes.dart';
import 'package:path/path.dart' as p;

void main() {
  final illustrations = p.join('assets', 'docs', 'illustrations');
  final figures = DayOneFigures.fromJson(
    File(p.join(illustrations, 'figures.json')).readAsStringSync(),
  );

  group('MdocParser', () {
    test('parses a record map and a field trail', () {
      final blocks = const MdocParser().parse(_sample);

      final recordMap = blocks.whereType<MdocRecordMapBlock>().single;
      expect(recordMap.label, 'How records relate.');
      expect(recordMap.hint, 'Select a record.');
      expect(recordMap.nodes.map((node) => node.id), ['site', 'event']);
      expect(recordMap.nodes.first.detail, 'A place you can visit again.');

      final trail = blocks.whereType<MdocFieldTrailBlock>().single;
      expect(trail.progress, '{visited} of {total} visited');
      final trailIndex = blocks.indexOf(trail);
      expect(blocks[trailIndex + 1], isA<MdocStepsBlock>());
    });

    test('keeps malformed figure tags as Markdown', () {
      final blocks = const MdocParser().parse('''
{% recordmap label="Map" hint="Hint" %}
Stray text.
{% /recordmap %}

{% fieldtrail label="Trail" hint="Hint" /%}
''');

      expect(blocks, hasLength(1));
      final markdown = (blocks.single as MdocMarkdownBlock).markdown;
      expect(markdown, contains('Stray text.'));
      expect(markdown, contains('fieldtrail'));
    });

    test('reads a step title from its bold lead', () {
      const step = MdocStep(
        number: 1,
        markdown: '**Create a practice site**\n\nOpen Sites.',
      );

      expect(step.title, 'Create a practice site');
    });
  });

  test('bundled artwork and geometry match every Day One locale', () {
    for (final name in ['record-map.svg', 'field-trail.svg']) {
      final file = File(p.join(illustrations, name));
      expect(file.existsSync(), isTrue, reason: file.path);
    }
    final boxIds = figures.recordBoxes.map((box) => box.id).toSet();

    for (final language in DocsLanguage.values) {
      final path = p.join(
        'assets',
        'docs',
        'cookbook',
        language.code,
        'day-one.mdoc',
      );
      final blocks = const MdocParser().parse(File(path).readAsStringSync());

      final recordMap = blocks.whereType<MdocRecordMapBlock>().single;
      expect(
        recordMap.nodes.map((node) => node.id).toSet(),
        boxIds,
        reason: path,
      );
      final trailIndex = blocks.indexWhere(
        (block) => block is MdocFieldTrailBlock,
      );
      expect(trailIndex, isNot(-1), reason: path);
      final steps = blocks[trailIndex + 1] as MdocStepsBlock;
      expect(steps.steps, hasLength(figures.waypoints.length), reason: path);
      expect(steps.steps.every((step) => step.title.isNotEmpty), isTrue);
    }
  });

  testWidgets('selecting a record shows its detail', (tester) async {
    await tester.pumpWidget(_testApp(figures: figures, data: _sample));
    await tester.pumpAndSettle();

    expect(find.text('Select a record.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('day-one-record-event')));
    await tester.pumpAndSettle();

    expect(find.text('Work at one site.'), findsOneWidget);
    expect(find.text('Select a record.'), findsNothing);
  });

  testWidgets('places the record detail beside the map on wide screens', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(_testApp(figures: figures, data: _sample));
    await tester.pumpAndSettle();

    final node = tester.getRect(
      find.byKey(const ValueKey('day-one-record-site')),
    );
    final hint = tester.getRect(find.text('Select a record.'));
    expect(hint.left, greaterThan(node.right));
  });

  testWidgets('a waypoint scrolls to its step and checks it off', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(figures: figures, data: _sample));
    await tester.pumpAndSettle();

    final step = find.textContaining('Open Events.');
    final before = tester.getTopLeft(step).dy;
    await tester.tap(find.byKey(const ValueKey('day-one-waypoint-1')));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(step).dy, lessThan(before));
    expect(find.text('2. Add a practice event'), findsOneWidget);
    expect(find.text('1 of 2 visited'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('day-one-waypoint-0')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('day-one-waypoint-0')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('day-one-waypoint-1')),
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsOneWidget,
    );
    expect(find.text('2 of 2 visited'), findsOneWidget);
  });
}

const _sample = '''
{% recordmap label="How records relate." hint="Select a record." %}
{% recordnode id="site" title="Site" summary="A place" detail="A place you can visit again." /%}
{% recordnode id="event" title="Event" summary="Work there" detail="Work at one site." /%}
{% /recordmap %}

Spacer paragraph one.

{% fieldtrail label="Practice trail." hint="Select a waypoint." progress="{visited} of {total} visited" /%}

{% steps %}
1. **Create a practice site**

    Open Sites.

2. **Add a practice event**

    Open Events.
{% /steps %}
''';

Widget _testApp({required DayOneFigures figures, required String data}) {
  return ProviderScope(
    overrides: [dayOneFiguresProvider.overrideWithValue(AsyncData(figures))],
    child: MaterialApp(
      theme: NahpuTheme.lightTheme(),
      home: Scaffold(
        body: Builder(
          builder: (context) => SingleChildScrollView(
            child: Column(
              children: [
                MdocBody(
                  data: data,
                  language: DocsLanguage.english,
                  styleSheet: documentationMarkdownStyleSheet(context),
                ),
                const SizedBox(height: 2000),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
