import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/home/components/how_to_recipes.dart';
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
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Português'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('Bahasa Indonesia'), findsOneWidget);

    await tester.tap(find.text('Português'));
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

  testWidgets('How-to Recipes categories expand and collapse independently', (
    tester,
  ) async {
    _setSize(tester, const Size(900, 800));
    await tester.pumpWidget(_testApp(child: const HowToRecipesScreen()));
    await tester.pumpAndSettle();

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

  testWidgets('wide Cookbook selects the first recipe in a split view', (
    tester,
  ) async {
    _setSize(tester, const Size(900, 800));
    await tester.pumpWidget(_testApp(child: const HowToRecipesScreen()));
    await tester.pumpAndSettle();

    expect(find.text('How-to Recipes'), findsOneWidget);
    final sidePanelTitle = tester.widget<Text>(find.text('Recipes'));
    expect(sidePanelTitle.textAlign, TextAlign.center);
    expect(find.text('Prepare'), findsOneWidget);
    expect(find.text('English recipe'), findsNWidgets(2));
    expect(find.text('English purpose.'), findsOneWidget);

    final recipeTile = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'English recipe'),
    );
    final tileBorder = recipeTile.shape! as RoundedRectangleBorder;
    expect(
      tileBorder.side.color,
      Theme.of(
        tester.element(find.byType(ListTile).first),
      ).colorScheme.outlineVariant,
    );

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(find.text('Preparar'), findsOneWidget);
    expect(find.text('Propósito en español.'), findsOneWidget);
  });

  testWidgets('Cookbook Markdown links use the text button color', (
    tester,
  ) async {
    const document = MarkdownDocument(
      id: 'link',
      title: 'Links',
      markdown: '[NAHPU](https://nahpu.app/)',
      assetPath: 'test/link.md',
      order: 1,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: NahpuTheme.lightTheme(),
        home: const Scaffold(body: MarkdownDocumentView(document: document)),
      ),
    );

    final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    expect(
      markdown.styleSheet?.a?.color,
      Theme.of(tester.element(find.byType(MarkdownBody))).colorScheme.primary,
    );
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
    expect(style.a!.color, theme.colorScheme.primary);
  });

  testWidgets('phone Cookbook opens recipe content in a bottom sheet', (
    tester,
  ) async {
    _setSize(tester, const Size(500, 800));
    await tester.pumpWidget(_testApp(child: const HowToRecipesScreen()));
    await tester.pumpAndSettle();

    expect(find.text('English recipe'), findsOneWidget);
    expect(find.text('English purpose.'), findsNothing);

    await tester.tap(find.text('English recipe'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('English purpose.'), findsOneWidget);
  });
}

Widget _testApp({required Widget child, String infoBody = 'Helpful details.'}) {
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

  for (final language in localized.entries) {
    final values = language.value;
    assets['assets/docs/cookbook/${language.key}/prepare/index.md'] = _markdown(
      values.$1,
      1,
      'Category purpose.',
    );
    assets['assets/docs/cookbook/${language.key}/prepare/first.md'] = _markdown(
      values.$2,
      1,
      '${values.$3}\n\n## ${values.$4}\n\n1. Start.\n2. Continue.\n3. Finish.',
    );
    final collect = collectTitles[language.key]!;
    assets['assets/docs/cookbook/${language.key}/collect/index.md'] = _markdown(
      collect.$1,
      2,
      'Collection purpose.',
    );
    assets['assets/docs/cookbook/${language.key}/collect/collect.md'] =
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
