import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/docs/documentation_widgets.dart';
import 'package:nahpu/screens/shared/docs/mdoc_body.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';
import 'package:nahpu/styles/themes.dart';

void main() {
  group('MdocParser', () {
    test('parses Markdown around steps and keeps continuation content', () {
      final blocks = const MdocParser().parse('''
Intro with **emphasis**.

{% steps %}

1. Open the project.
    Continue the first step with a [link](https://nahpu.app/).
2. Save the project.
{% /steps %}

Finish the task.
''');

      expect(blocks, hasLength(3));
      expect(
        (blocks.first as MdocMarkdownBlock).markdown,
        'Intro with **emphasis**.',
      );
      final steps = (blocks[1] as MdocStepsBlock).steps;
      expect(steps.map((step) => step.number), [1, 2]);
      expect(steps.first.markdown, contains('Continue the first step'));
      expect(steps.first.markdown, isNot(contains('    Continue')));
      expect((blocks.last as MdocMarkdownBlock).markdown, 'Finish the task.');
    });

    test('parses all aside types and optional titles', () {
      final blocks = const MdocParser().parse('''
{% aside type="note" %}
Note body.
{% /aside %}

{% aside type="caution" title="Back up first" %}
Caution body.
{% /aside %}

{% aside type="tip" %}
Tip body.
{% /aside %}
''');

      final asides = blocks.whereType<MdocAsideBlock>().toList();
      expect(asides.map((aside) => aside.type), MdocAsideType.values);
      expect(asides[1].title, 'Back up first');
      expect(asides[2].markdown, 'Tip body.');
    });

    test('keeps unsupported and malformed tags as Markdown', () {
      const source = '''
{% tabs %}
Standard content.
{% /tabs %}

{% aside type="danger" %}
Unsupported aside.
{% /aside %}
''';
      final blocks = const MdocParser().parse(source);

      expect(blocks, hasLength(1));
      expect(blocks.single, isA<MdocMarkdownBlock>());
      final markdown = (blocks.single as MdocMarkdownBlock).markdown;
      expect(markdown, contains('{% tabs %}'));
      expect(markdown, contains('type="danger"'));
    });
  });

  testWidgets('renders connected steps with Markdown content', (tester) async {
    await tester.pumpWidget(
      _testApp(
        data: '''
{% steps %}
1. Choose **Project**.
2. Open the [guide](https://nahpu.app/).
3. Finish.
{% /steps %}
''',
      ),
    );

    expect(find.byKey(const ValueKey('mdoc-steps')), findsOneWidget);
    expect(find.byKey(const ValueKey('mdoc-step-connector-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('mdoc-step-connector-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('mdoc-step-connector-2')), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.textContaining('Project'), findsOneWidget);
    final stepMarkdown = tester.widgetList<MarkdownBody>(
      find.descendant(
        of: find.byKey(const ValueKey('mdoc-steps')),
        matching: find.byType(MarkdownBody),
      ),
    );
    expect(stepMarkdown.any((body) => body.data.contains('[guide]')), isTrue);
  });

  testWidgets('step colors meet WCAG AA in both themes', (tester) async {
    for (final theme in [NahpuTheme.lightTheme(), NahpuTheme.darkTheme()]) {
      await tester.pumpWidget(
        _testApp(
          theme: theme,
          data: '''
{% steps %}
1. Start.
2. Finish.
{% /steps %}
''',
        ),
      );

      final markerFinder = find.byKey(const ValueKey('mdoc-step-marker-0'));
      final marker = tester.widget<Container>(markerFinder);
      final markerDecoration = marker.decoration! as BoxDecoration;
      final markerBackground = markerDecoration.color!;
      final markerBorder = markerDecoration.border! as Border;
      final markerText = tester.widget<Text>(
        find.descendant(of: markerFinder, matching: find.text('1')),
      );
      expect(
        _contrastRatio(markerText.style!.color!, markerBackground),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(markerBorder.top.color, markerBackground),
        greaterThanOrEqualTo(3.0),
      );

      final connector = tester.widget<Container>(
        find.byKey(const ValueKey('mdoc-step-connector-0')),
      );
      final renderedTheme = Theme.of(
        tester.element(find.byKey(const ValueKey('mdoc-step-connector-0'))),
      );
      expect(
        _contrastRatio(connector.color!, renderedTheme.scaffoldBackgroundColor),
        greaterThanOrEqualTo(3.0),
        reason:
            '${connector.color} on ${renderedTheme.scaffoldBackgroundColor}',
      );
    }
  });

  testWidgets('localizes aside defaults and honors a custom title', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        language: DocsLanguage.portuguese,
        data: '''
{% aside type="note" %}
Note body.
{% /aside %}
{% aside type="caution" title="Atenção" %}
Caution body.
{% /aside %}
{% aside type="tip" %}
Tip body.
{% /aside %}
''',
      ),
    );

    expect(find.text('Nota'), findsOneWidget);
    expect(find.text('Atenção'), findsOneWidget);
    expect(find.text('Dica'), findsOneWidget);
    for (final label in ['Nota', 'Atenção', 'Dica']) {
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.label == label,
        ),
        findsOneWidget,
      );
    }
    for (final type in MdocAsideType.values) {
      expect(find.byKey(ValueKey('mdoc-aside-${type.name}')), findsOneWidget);
    }
  });

  testWidgets('aside colors meet WCAG AA in both themes', (tester) async {
    const titles = {
      MdocAsideType.note: 'Note',
      MdocAsideType.caution: 'Caution',
      MdocAsideType.tip: 'Tip',
    };
    for (final theme in [NahpuTheme.lightTheme(), NahpuTheme.darkTheme()]) {
      await tester.pumpWidget(
        _testApp(
          theme: theme,
          data: '''
{% aside type="note" %}
[Note details](https://nahpu.app/).
{% /aside %}
{% aside type="caution" %}
[Caution details](https://nahpu.app/).
{% /aside %}
{% aside type="tip" %}
[Tip details](https://nahpu.app/).
{% /aside %}
''',
        ),
      );

      for (final type in MdocAsideType.values) {
        final finder = find.byKey(ValueKey('mdoc-aside-${type.name}'));
        final container = tester.widget<Container>(finder);
        final decoration = container.decoration! as BoxDecoration;
        final background = decoration.color!;
        final border = decoration.border! as Border;
        final title = tester.widget<Text>(
          find.descendant(of: finder, matching: find.text(titles[type]!)),
        );
        final icon = tester.widget<Icon>(
          find.descendant(of: finder, matching: find.byType(Icon)),
        );
        final markdown = tester.widget<MarkdownBody>(
          find.descendant(of: finder, matching: find.byType(MarkdownBody)),
        );

        expect(
          _contrastRatio(title.style!.color!, background),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrastRatio(markdown.styleSheet!.p!.color!, background),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrastRatio(markdown.styleSheet!.a!.color!, background),
          greaterThanOrEqualTo(4.5),
        );
        expect(markdown.styleSheet!.a!.decoration, TextDecoration.underline);
        expect(
          _contrastRatio(icon.color!, background),
          greaterThanOrEqualTo(3.0),
        );
        expect(
          _contrastRatio(border.left.color, background),
          greaterThanOrEqualTo(3.0),
        );
      }
    }
  });
}

Widget _testApp({
  required String data,
  DocsLanguage language = DocsLanguage.english,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme ?? NahpuTheme.lightTheme(),
    home: Scaffold(
      body: Builder(
        builder: (context) => MdocBody(
          data: data,
          language: language,
          styleSheet: documentationMarkdownStyleSheet(context),
        ),
      ),
    ),
  );
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
