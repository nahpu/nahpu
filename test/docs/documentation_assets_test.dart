import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';
import 'package:path/path.dart' as path;

void main() {
  final repository = DocumentationRepository();

  test('all 23 info topics exist in every supported language', () {
    expect(InfoTopic.values, hasLength(23));

    for (final language in DocsLanguage.values) {
      for (final topic in InfoTopic.values) {
        final path = 'assets/docs/info/${language.code}/${topic.assetSlug}.md';
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Missing $path');

        final document = repository.parseDocument(
          assetPath: path,
          source: file.readAsStringSync(),
        );
        expect(document.title, isNotEmpty, reason: path);
        expect(document.markdown, isNot(startsWith('---')), reason: path);
      }
    }
  });

  test('Cookbook paths and ordering match across locales', () {
    final english = _cookbookMetadata(DocsLanguage.english, repository);
    expect(english.recipePaths, hasLength(29));
    expect(english.categoryPaths, hasLength(4));
    expect(english.orders[path.join('prepare', 'index.md')], 1);
    expect(english.orders[path.join('collect', 'index.md')], 2);
    expect(
      english.orders[path.join('protect-and-collaborate', 'index.md')],
      3,
    );
    expect(english.orders[path.join('export-and-print', 'index.md')], 4);

    for (final language in DocsLanguage.values.skip(1)) {
      final localized = _cookbookMetadata(language, repository);
      expect(localized.recipePaths, english.recipePaths, reason: language.code);
      expect(
        localized.categoryPaths,
        english.categoryPaths,
        reason: language.code,
      );
      expect(localized.orders, english.orders, reason: language.code);
      expect(localized.titles.keys, english.titles.keys, reason: language.code);
      expect(
        localized.titles.values.every((title) => title.trim().isNotEmpty),
        isTrue,
        reason: language.code,
      );
    }
  });

  test('every recipe follows the concise numbered format', () {
    const stepsHeadings = {
      DocsLanguage.english: '## Steps',
      DocsLanguage.portuguese: '## Etapas',
      DocsLanguage.spanish: '## Pasos',
      DocsLanguage.indonesian: '## Langkah',
    };
    const learnMoreHeadings = {
      DocsLanguage.english: '## Learn more',
      DocsLanguage.portuguese: '## Saiba mais',
      DocsLanguage.spanish: '## Más información',
      DocsLanguage.indonesian: '## Pelajari lebih lanjut',
    };

    for (final language in DocsLanguage.values) {
      final root = Directory('assets/docs/cookbook/${language.code}');
      final recipes = root
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (file) => file.path.endsWith('.mdoc') && !_isIndexFile(file.path),
          );

      for (final file in recipes) {
        final document = repository.parseDocument(
          assetPath: file.path,
          source: file.readAsStringSync(),
        );
        final paragraphs = document.markdown.split('\n\n');
        expect(paragraphs.first.split('\n'), hasLength(1), reason: file.path);
        expect(
          document.markdown,
          contains(stepsHeadings[language]!),
          reason: file.path,
        );
        expect(
          document.markdown,
          contains(learnMoreHeadings[language]!),
          reason: file.path,
        );
        expect(document.markdown, contains('{% steps %}'), reason: file.path);
        expect(document.markdown, contains('{% /steps %}'), reason: file.path);
        final stepsBlock = RegExp(
          r'{% steps %}([\s\S]*?){% /steps %}',
        ).firstMatch(document.markdown);
        expect(stepsBlock, isNotNull, reason: file.path);
        final steps = RegExp(
          r'^\d+\.\s',
          multiLine: true,
        ).allMatches(stepsBlock!.group(1)!);
        expect(steps.length, inInclusiveRange(3, 8), reason: file.path);
        expect(document.markdown, isNot(contains('<Tabs')), reason: file.path);

        final asides = RegExp(
          r'{% aside type="(note|caution|tip)"(?: title="[^"]+")? %}',
          multiLine: true,
        ).allMatches(document.markdown);
        expect(asides.length, lessThanOrEqualTo(1), reason: file.path);
        expect(
          RegExp(
            r'^> \*\*.+?:\*\*',
            multiLine: true,
          ).hasMatch(document.markdown),
          isFalse,
          reason: file.path,
        );
        final tagNames = RegExp(
          r'{%\s+/?([a-z-]+)',
        ).allMatches(document.markdown).map((match) => match.group(1)).toSet();
        expect(tagNames.difference({'steps', 'aside'}), isEmpty);
        expect(
          document.markdown,
          contains('https://nahpu.app/${language.code}/'),
          reason: file.path,
        );
      }
    }
  });
}

_CookbookMetadata _cookbookMetadata(
  DocsLanguage language,
  DocumentationRepository repository,
) {
  final root = Directory('assets/docs/cookbook/${language.code}');
  expect(root.existsSync(), isTrue);
  final recipePaths = <String>{};
  final categoryPaths = <String>{};
  final orders = <String, int>{};
  final titles = <String, String>{};

  for (final file in root.listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('.md') && !file.path.endsWith('.mdoc')) continue;
    final relativePath = file.path.substring(root.path.length + 1);
    final document = repository.parseDocument(
      assetPath: file.path,
      source: file.readAsStringSync(),
    );
    orders[relativePath] = document.order;
    titles[relativePath] = document.title;
    if (_isCategoryIndex(relativePath)) {
      categoryPaths.add(relativePath);
    } else if (!_isIndexFile(relativePath)) {
      recipePaths.add(relativePath);
    }
  }

  return _CookbookMetadata(
    recipePaths: recipePaths,
    categoryPaths: categoryPaths,
    orders: orders,
    titles: titles,
  );
}

bool _isIndexFile(String path) =>
    path.split(Platform.pathSeparator).last.toLowerCase() == 'index.md';

bool _isCategoryIndex(String path) =>
    _isIndexFile(path) && path.contains(Platform.pathSeparator);

class _CookbookMetadata {
  const _CookbookMetadata({
    required this.recipePaths,
    required this.categoryPaths,
    required this.orders,
    required this.titles,
  });

  final Set<String> recipePaths;
  final Set<String> categoryPaths;
  final Map<String, int> orders;
  final Map<String, String> titles;
}
