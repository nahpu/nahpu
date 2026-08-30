import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/home/components/cookbook.dart';
import 'package:nahpu/screens/shared/docs/documentation_widgets.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';
import 'package:nahpu/styles/themes.dart';

void main() {
  testWidgets('info opens in English, switches language, and resets', (
    tester,
  ) async {
    _setSize(tester, const Size(600, 800));
    await tester.pumpWidget(
      _testApp(child: const InfoButton(topic: InfoTopic.projectOverview)),
    );

    await tester.tap(find.byTooltip('Show information'));
    await tester.pumpAndSettle();
    final dialogSurface = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(Material),
    );
    expect(tester.getSize(dialogSurface.first).height, lessThan(600));
    expect(find.text('English info'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('BR'), findsOneWidget);
    expect(find.text('ES'), findsOneWidget);
    expect(find.text('ID'), findsOneWidget);

    await tester.tap(find.text('BR'));
    await tester.pumpAndSettle();
    expect(find.text('Informação em português'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Show information'));
    await tester.pumpAndSettle();
    expect(find.text('English info'), findsOneWidget);
  });

  testWidgets('mobile info sizes short content and scrolls long content', (
    tester,
  ) async {
    _setSize(tester, const Size(500, 800));
    await tester.pumpWidget(
      _testApp(
        child: const InfoButton(
          topic: InfoTopic.projectOverview,
          platformOverride: PlatformType.mobile,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Show information'));
    await tester.pumpAndSettle();
    final shortSheet = find.byType(BottomSheet);
    expect(tester.getSize(shortSheet).height, lessThan(600));
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    Navigator.of(tester.element(shortSheet)).pop();
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      _testApp(
        infoBody: List.generate(
          80,
          (index) => 'Long information paragraph $index.',
        ).join('\n\n'),
        child: const InfoButton(
          topic: InfoTopic.projectOverview,
          platformOverride: PlatformType.mobile,
        ),
      ),
    );
    await tester.tap(find.byTooltip('Show information'));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(
      tester.getSize(find.byType(BottomSheet)).height,
      lessThanOrEqualTo(800 * 0.9),
    );
  });

  testWidgets('mobile info content clears the bottom safe area', (
    tester,
  ) async {
    _setSize(tester, const Size(390, 844));
    tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 47, bottom: 34);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(
      _testApp(
        infoBody: List.generate(
          40,
          (index) => 'Long information paragraph $index.',
        ).join('\n\n'),
        child: const InfoButton(
          topic: InfoTopic.projectOverview,
          platformOverride: PlatformType.mobile,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Show information'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -4000),
    );
    await tester.pumpAndSettle();

    final lastParagraph = find.textContaining('Long information paragraph 39.');
    expect(lastParagraph, findsOneWidget);
    expect(tester.getRect(lastParagraph).bottom, lessThanOrEqualTo(844 - 34));
  });

  testWidgets('language chips show two-letter codes and stay legible', (
    tester,
  ) async {
    _setSize(tester, const Size(600, 800));
    await tester.pumpWidget(
      _testApp(child: const InfoButton(topic: InfoTopic.projectOverview)),
    );

    await tester.tap(find.byTooltip('Show information'));
    await tester.pumpAndSettle();

    final colorScheme = Theme.of(
      tester.element(find.byType(ChoiceChip).first),
    ).colorScheme;
    final selected = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'EN'),
    );
    expect(selected.selected, isTrue);
    expect(
      selected.onSelected,
      isNotNull,
      reason: 'selected chip stays enabled',
    );
    expect(selected.labelStyle?.color, colorScheme.onSecondaryContainer);
    expect(selected.selectedColor, colorScheme.secondaryContainer);

    final unselected = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'BR'),
    );
    expect(unselected.selected, isFalse);
    expect(unselected.labelStyle?.color, colorScheme.onSurfaceVariant);
    expect(unselected.tooltip, 'Português');
  });

  testWidgets('Cookbook categories expand and collapse independently', (
    tester,
  ) async {
    _setSize(tester, const Size(900, 800));
    await tester.pumpWidget(_testApp(child: const CookbookScreen()));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, 'Day One'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'English recipe'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Collect recipe'), findsOneWidget);
    expect(find.byTooltip('Collapse Prepare'), findsOneWidget);
    expect(find.byTooltip('Collapse Collect'), findsOneWidget);

    await tester.tap(find.byTooltip('Collapse Prepare'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, 'English recipe'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Collect recipe'), findsOneWidget);
    expect(find.byTooltip('Expand Prepare'), findsOneWidget);
    expect(find.byTooltip('Collapse Collect'), findsOneWidget);

    await tester.tap(find.byTooltip('Collapse Collect'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Collect recipe'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Day One'), findsOneWidget);

    await tester.tap(find.byTooltip('Expand Prepare'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'English recipe'), findsOneWidget);

    await tester.tap(find.byTooltip('Expand Collect'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Collect recipe'), findsOneWidget);

    await tester.tap(find.text('Collect recipe'));
    await tester.pumpAndSettle();
    expect(find.text('Collection steps.'), findsOneWidget);
  });

  testWidgets('wide Cookbook opens on Day One in a split view', (
    tester,
  ) async {
    _setSize(tester, const Size(900, 800));
    await tester.pumpWidget(_testApp(child: const CookbookScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Cookbook'), findsOneWidget);
    final sidePanelTitle = tester.widget<Text>(find.text('Contents'));
    expect(sidePanelTitle.textAlign, TextAlign.center);
    expect(find.text('Prepare'), findsOneWidget);
    expect(find.text('Day One'), findsNWidgets(2));
    expect(find.text('Day One purpose.'), findsOneWidget);

    final dayOneTile = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Day One'),
    );
    final tileBorder = dayOneTile.shape! as RoundedRectangleBorder;
    expect(
      tileBorder.side.color,
      Theme.of(
        tester.element(find.byType(ListTile).first),
      ).colorScheme.outlineVariant,
    );

    await tester.tap(find.text('English recipe'));
    await tester.pumpAndSettle();
    expect(find.text('English purpose.'), findsOneWidget);

    await tester.tap(find.text('ES'));
    await tester.pumpAndSettle();
    expect(find.text('Preparar'), findsOneWidget);
    expect(find.text('Propósito en español.'), findsOneWidget);
  });

  testWidgets('wide Cookbook keeps an opaque title above the scrolling list', (
    tester,
  ) async {
    _setSize(tester, const Size(900, 600));
    await tester.pumpWidget(
      _testApp(child: const CookbookScreen(), recipeCount: 20),
    );
    await tester.pumpAndSettle();

    final header = find.byKey(const ValueKey('cookbook-list-header'));
    final list = find.byType(ListView);
    final headerTop = tester.getTopLeft(header).dy;
    final headerMaterial = tester.widget<Material>(header);

    expect(headerMaterial.color?.a, 1);
    expect(
      tester.getRect(list).top,
      greaterThanOrEqualTo(tester.getRect(header).bottom),
    );

    await tester.fling(list, const Offset(0, -1200), 1800);
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(header).dy, headerTop);
    expect(
      tester.getRect(list).top,
      greaterThanOrEqualTo(tester.getRect(header).bottom),
    );
  });

  testWidgets('documentation links meet WCAG AA in both themes', (
    tester,
  ) async {
    const document = MarkdownDocument(
      id: 'link',
      title: 'Links',
      markdown: '[NAHPU](https://nahpu.app/)',
      assetPath: 'test/link.md',
      order: 1,
    );
    for (final theme in [NahpuTheme.lightTheme(), NahpuTheme.darkTheme()]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: MarkdownDocumentView(document: document)),
        ),
      );

      final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
      final linkStyle = markdown.styleSheet!.a!;
      final colorScheme = Theme.of(
        tester.element(find.byType(MarkdownBody)),
      ).colorScheme;
      for (final background in [
        colorScheme.surface,
        colorScheme.surfaceContainerLow,
        colorScheme.surfaceContainer,
        colorScheme.surfaceContainerHigh,
        colorScheme.surfaceContainerHighest,
      ]) {
        expect(
          _contrastRatio(linkStyle.color!, background),
          greaterThanOrEqualTo(4.5),
        );
      }
      expect(linkStyle.decoration, TextDecoration.underline);
    }
  });

  testWidgets('documentation Markdown uses dark theme colors', (tester) async {
    const document = MarkdownDocument(
      id: 'dark-theme',
      title: 'Dark theme',
      markdown: '## Details\n\nHelpful details.\n\n> **Tip:** Keep going.',
      assetPath: 'test/dark-theme.md',
      order: 1,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: NahpuTheme.darkTheme(),
        home: const Scaffold(body: MarkdownDocumentView(document: document)),
      ),
    );

    final context = tester.element(find.byType(MarkdownBody));
    final theme = Theme.of(context);
    final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    final style = markdown.styleSheet!;
    final blockquote = style.blockquoteDecoration! as BoxDecoration;

    expect(style.p!.color, theme.colorScheme.onSurface);
    expect(style.h2!.color, theme.colorScheme.onSurface);
    expect(blockquote.color, theme.colorScheme.surfaceContainerHighest);
    expect(
      _contrastRatio(style.a!.color!, theme.colorScheme.surface),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('only translated documents carry the AI translation notice', (
    tester,
  ) async {
    const english = MarkdownDocument(
      id: 'english',
      title: 'English info',
      markdown: 'Body.',
      assetPath: 'assets/docs/info/en/project-overview.md',
      order: 1,
    );
    await tester.pumpWidget(
      _documentApp(document: english, theme: NahpuTheme.lightTheme()),
    );
    expect(find.byType(AiTranslationNotice), findsNothing);

    const translated = MarkdownDocument(
      id: 'translated',
      title: 'Informasi Indonesia',
      markdown: 'Isi.',
      assetPath: 'assets/docs/info/id/project-overview.md',
      order: 1,
      language: DocsLanguage.indonesian,
    );
    await tester.pumpWidget(
      _documentApp(document: translated, theme: NahpuTheme.lightTheme()),
    );
    expect(find.byType(AiTranslationNotice), findsOneWidget);
    expect(
      find.byKey(const ValueKey('ai-translation-notice-unreviewed')),
      findsOneWidget,
    );
    expect(_noticeText(tester), 'AI-assisted translation. Check for accuracy');
  });

  testWidgets('reviewed translations name their reviewers', (tester) async {
    const reviewed = MarkdownDocument(
      id: 'reviewed',
      title: 'Impressão de Etiquetas',
      markdown: 'Corpo.',
      assetPath: 'assets/docs/info/pt/tag-printing.md',
      order: 1,
      language: DocsLanguage.portuguese,
      authors: ['Andre Moncrieff', 'Heru Handika'],
    );
    await tester.pumpWidget(
      _documentApp(document: reviewed, theme: NahpuTheme.lightTheme()),
    );

    expect(
      find.byKey(const ValueKey('ai-translation-notice-reviewed')),
      findsOneWidget,
    );
    expect(
      _noticeText(tester),
      'AI-assisted translation. Human-checked and revised by '
      'Andre Moncrieff and Heru Handika.',
    );
  });

  testWidgets('translation notice colors meet WCAG AA in both themes', (
    tester,
  ) async {
    for (final theme in [NahpuTheme.lightTheme(), NahpuTheme.darkTheme()]) {
      for (final authors in [
        const <String>[],
        const ['Heru Handika'],
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(body: AiTranslationNotice(authors: authors)),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(AiTranslationNotice),
            matching: find.byType(Container),
          ),
        );
        final decoration = container.decoration! as BoxDecoration;
        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(
          _contrastRatio(icon.color!, decoration.color!),
          greaterThanOrEqualTo(4.5),
        );
      }
    }
  });

  testWidgets('phone Cookbook opens recipe content in a bottom sheet', (
    tester,
  ) async {
    _setSize(tester, const Size(500, 800));
    await tester.pumpWidget(_testApp(child: const CookbookScreen()));
    await tester.pumpAndSettle();

    expect(find.text('English recipe'), findsOneWidget);
    expect(find.text('English purpose.'), findsNothing);

    await tester.tap(find.text('English recipe'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('English purpose.'), findsOneWidget);
  });

  testWidgets('phone Cookbook opens Day One in a bottom sheet', (tester) async {
    _setSize(tester, const Size(500, 800));
    await tester.pumpWidget(_testApp(child: const CookbookScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Day One'), findsOneWidget);
    expect(find.text('Day One purpose.'), findsNothing);

    await tester.tap(find.text('Day One'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Day One purpose.'), findsOneWidget);
  });
}

Widget _testApp({
  required Widget child,
  String infoBody = 'Helpful details.',
  int recipeCount = 1,
}) {
  final assets = <String, String>{};
  const localized = {
    'en': ('Prepare', 'English recipe', 'English purpose.', 'Steps'),
    'pt': (
      'Preparar',
      'Receita em português',
      'Objetivo em português.',
      'Etapas',
    ),
    'es': ('Preparar', 'Receta en español', 'Propósito en español.', 'Pasos'),
    'id': ('Persiapan', 'Resep Indonesia', 'Tujuan Indonesia.', 'Langkah'),
  };
  const infoTitles = {
    'en': 'English info',
    'pt': 'Informação em português',
    'es': 'Información en español',
    'id': 'Informasi Indonesia',
  };
  const collectTitles = {
    'en': ('Collect', 'Collect recipe'),
    'pt': ('Coletar', 'Receita de coleta'),
    'es': ('Recopilar', 'Receta de recopilación'),
    'id': ('Mengumpulkan', 'Resep pengumpulan'),
  };
  const dayOneTitles = {
    'en': ('Day One', 'Day One purpose.'),
    'pt': ('Dia 1', 'Objetivo do Dia 1.'),
    'es': ('Día 1', 'Propósito del Día 1.'),
    'id': ('Hari Ke-1', 'Tujuan Hari Ke-1.'),
  };

  for (final language in localized.entries) {
    final values = language.value;
    final dayOne = dayOneTitles[language.key]!;
    assets['assets/docs/cookbook/${language.key}/day-one.mdoc'] = _markdown(
      dayOne.$1,
      0,
      dayOne.$2,
    );
    assets['assets/docs/cookbook/${language.key}/prepare/index.md'] = _markdown(
      values.$1,
      1,
      'Category purpose.',
    );
    assets['assets/docs/cookbook/${language.key}/prepare/first.mdoc'] =
        _markdown(
          values.$2,
          1,
          '${values.$3}\n\n## ${values.$4}\n\n{% steps %}\n\n'
          '1. Start.\n2. Continue.\n3. Finish.\n{% /steps %}',
        );
    for (var index = 2; index <= recipeCount; index++) {
      assets['assets/docs/cookbook/${language.key}/prepare/recipe-$index.mdoc'] =
          _markdown(
            '${values.$2} $index',
            index,
            '${values.$3}\n\n## ${values.$4}\n\n{% steps %}\n\n'
                '1. Start.\n2. Continue.\n3. Finish.\n{% /steps %}',
          );
    }
    final collect = collectTitles[language.key]!;
    assets['assets/docs/cookbook/${language.key}/collect/index.md'] = _markdown(
      collect.$1,
      2,
      'Collection purpose.',
    );
    assets['assets/docs/cookbook/${language.key}/collect/collect.mdoc'] =
        _markdown(collect.$2, 1, 'Collection steps.');
    assets['assets/docs/info/${language.key}/project-overview.md'] = _markdown(
      infoTitles[language.key]!,
      1,
      '${values.$3}\n\n$infoBody',
    );
  }

  final repository = DocumentationRepository(
    assetBundle: _MapAssetBundle(assets),
    assetPathsLoader: () async => assets.keys.toList(),
  );
  return ProviderScope(
    overrides: [documentationRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

Widget _documentApp({
  required MarkdownDocument document,
  required ThemeData theme,
}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: MarkdownDocumentView(document: document)),
  );
}

String _noticeText(WidgetTester tester) {
  final text = tester.widget<Text>(
    find.descendant(
      of: find.byType(AiTranslationNotice),
      matching: find.byType(Text),
    ),
  );
  return text.textSpan!.toPlainText();
}

void _setSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

String _markdown(String title, int order, String body) =>
    '''
---
title: "$title"
sidebar:
  order: $order
---

$body
'''
        .trimLeft();

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

class _MapAssetBundle extends CachingAssetBundle {
  _MapAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final source = assets[key];
    if (source == null) throw StateError('Missing test asset: $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }
}
