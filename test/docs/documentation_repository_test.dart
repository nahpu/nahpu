import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';

void main() {
  test('front matter parses and is removed from rendered Markdown', () {
    final repository = DocumentationRepository();
    final document = repository.parseDocument(
      assetPath: 'assets/docs/cookbook/en/prepare/test-recipe.mdoc',
      source:
          '''
---
title: "Test recipe"
sidebar:
  order: 7
---

Do the useful thing.

## Steps

1. Start.
2. Finish.
'''
              .trimLeft(),
    );

    expect(document.id, 'test-recipe');
    expect(document.title, 'Test recipe');
    expect(document.order, 7);
    expect(document.language, DocsLanguage.english);
    expect(document.markdown, startsWith('Do the useful thing.'));
    expect(document.markdown, isNot(contains('sidebar:')));
  });

  test('document locale and ID are derived from an mdoc asset path', () {
    final document = DocumentationRepository().parseDocument(
      assetPath: 'assets/docs/cookbook/pt/prepare/test-recipe.mdoc',
      source: _document('Receita', 1),
    );

    expect(document.id, 'test-recipe');
    expect(document.language, DocsLanguage.portuguese);
  });

  test('authors front matter accepts a single name or a list', () {
    final repository = DocumentationRepository();

    final none = repository.parseDocument(
      assetPath: 'assets/docs/info/id/project-overview.md',
      source: '---\ntitle: "Ikhtisar"\nsidebar:\n  order: 1\n---\n\nIsi.\n',
    );
    expect(none.authors, isEmpty);

    final single = repository.parseDocument(
      assetPath: 'assets/docs/info/id/project-overview.md',
      source:
          '---\ntitle: "Ikhtisar"\nauthors: Heru Handika\n'
          'sidebar:\n  order: 1\n---\n\nIsi.\n',
    );
    expect(single.authors, ['Heru Handika']);

    final several = repository.parseDocument(
      assetPath: 'assets/docs/info/pt/tag-printing.md',
      source:
          '---\ntitle: "Etiquetas"\nauthors:\n  - Andre Moncrieff\n'
          '  - Heru Handika\nsidebar:\n  order: 1\n---\n\nCorpo.\n',
    );
    expect(several.authors, ['Andre Moncrieff', 'Heru Handika']);
  });

  test('localized info falls back to English', () async {
    const englishPath = 'assets/docs/info/en/project-overview.md';
    final repository = DocumentationRepository(
      assetBundle: _MapAssetBundle({
        englishPath: _document('English project help', 1),
      }),
    );

    final document = await repository.loadInfo(
      InfoTopic.projectOverview,
      DocsLanguage.spanish,
    );

    expect(document.title, 'English project help');
    expect(document.assetPath, englishPath);
  });

  test(
    'Cookbook discovery sorts categories and recipes by front matter',
    () async {
      final assets = {
        'assets/docs/cookbook/en/second/index.md': _document('Second', 2),
        'assets/docs/cookbook/en/second/later.mdoc': _document('Later', 8),
        'assets/docs/cookbook/en/first/index.md': _document('First', 1),
        'assets/docs/cookbook/en/first/b.mdoc': _document('B recipe', 2),
        'assets/docs/cookbook/en/first/a.mdoc': _document('A recipe', 1),
      };
      final repository = DocumentationRepository(
        assetBundle: _MapAssetBundle(assets),
        assetPathsLoader: () async => assets.keys.toList(),
      );

      final categories = await repository.loadCookbook(DocsLanguage.english);

      expect(categories.map((category) => category.title), ['First', 'Second']);
      expect(categories.first.recipes.map((recipe) => recipe.document.title), [
        'A recipe',
        'B recipe',
      ]);
    },
  );

  test('missing localized Cookbook falls back to English', () async {
    final assets = {
      'assets/docs/cookbook/en/prepare/index.md': _document('Prepare', 1),
      'assets/docs/cookbook/en/prepare/first.mdoc': _document(
        'English recipe',
        1,
      ),
    };
    final repository = DocumentationRepository(
      assetBundle: _MapAssetBundle(assets),
      assetPathsLoader: () async => assets.keys.toList(),
    );

    final categories = await repository.loadCookbook(DocsLanguage.indonesian);

    expect(categories.single.title, 'Prepare');
    expect(categories.single.recipes.single.document.title, 'English recipe');
  });

  test('missing English documentation reports an error', () async {
    final repository = DocumentationRepository(
      assetBundle: _MapAssetBundle(const {}),
    );

    await expectLater(
      repository.loadInfo(InfoTopic.projectOverview, DocsLanguage.english),
      throwsA(isA<StateError>()),
    );
  });
}

String _document(String title, int order) =>
    '''
---
title: "$title"
sidebar:
  order: $order
---

Purpose sentence.
'''
        .trimLeft();

class _MapAssetBundle extends CachingAssetBundle {
  _MapAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final source = assets[key];
    if (source == null) {
      throw StateError('Missing test asset: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(source));
    return ByteData.sublistView(bytes);
  }
}
