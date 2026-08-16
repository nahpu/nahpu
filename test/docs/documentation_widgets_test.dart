import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/home/components/how_to_recipes.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';

void main() {
  testWidgets('info opens in English, switches language, and resets', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(child: const InfoButton(topic: InfoTopic.projectOverview)),
    );

    await tester.tap(find.byTooltip('Show information'));
    await tester.pumpAndSettle();
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

  testWidgets('wide Cookbook selects the first recipe in a split view', (
    tester,
  ) async {
    _setSize(tester, const Size(900, 800));
    await tester.pumpWidget(_testApp(child: const HowToRecipesScreen()));
    await tester.pumpAndSettle();

    expect(find.text('How-to Recipes'), findsOneWidget);
    expect(find.text('Prepare'), findsOneWidget);
    expect(find.text('English recipe'), findsNWidgets(2));
    expect(find.text('English purpose.'), findsOneWidget);

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(find.text('Preparar'), findsOneWidget);
    expect(find.text('Propósito en español.'), findsOneWidget);
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

Widget _testApp({required Widget child}) {
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
    assets['assets/docs/info/${language.key}/project-overview.md'] = _markdown(
      infoTitles[language.key]!,
      1,
      '${values.$3}\n\nHelpful details.',
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
