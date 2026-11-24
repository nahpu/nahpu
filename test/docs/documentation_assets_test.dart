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

  test('every info topic points to the documentation site', () {
    const learnMoreHeadings = {
      DocsLanguage.english: '## Learn more',
      DocsLanguage.portuguese: '## Saiba mais',
      DocsLanguage.spanish: '## Más información',
      DocsLanguage.indonesian: '## Pelajari lebih lanjut',
    };

    for (final language in DocsLanguage.values) {
      for (final topic in InfoTopic.values) {
        final assetPath =
            'assets/docs/info/${language.code}/${topic.assetSlug}.md';
        final document = repository.parseDocument(
          assetPath: assetPath,
          source: File(assetPath).readAsStringSync(),
        );

        // Darwin Core mappings live on the website, not in the app panels.
        expect(
          document.markdown,
          isNot(contains('Darwin Core context')),
          reason: assetPath,
        );
        expect(
          document.markdown,
          contains(learnMoreHeadings[language]!),
          reason: assetPath,
        );

        // Panels link to reference pages, which the app cannot resolve on its
        // own, so every link needs a scheme and the reader's own locale.
        final links = RegExp(
          r'\[[^\]]+\]\(([^)]+)\)',
        ).allMatches(document.markdown).map((match) => match.group(1)!);
        expect(links, isNotEmpty, reason: assetPath);
        for (final link in links) {
          expect(
            link,
            startsWith('https://nahpu.app/${language.code}/usages/'),
            reason: assetPath,
          );
        }
      }
    }
  });

  test('info topics link to the same pages in every language', () {
    for (final topic in InfoTopic.values) {
      final english = _infoLinkPaths(repository, DocsLanguage.english, topic);
      for (final language in DocsLanguage.values.skip(1)) {
        expect(
          _infoLinkPaths(repository, language, topic),
          english,
          reason: '${language.code}/${topic.assetSlug}',
        );
      }
    }
  });

  test('Cookbook paths and ordering match across locales', () {
    final english = _cookbookMetadata(DocsLanguage.english, repository);
    expect(english.recipePaths, hasLength(34));
    expect(english.categoryPaths, hasLength(4));
    expect(english.orders[path.join('prepare', 'index.md')], 1);
    expect(english.orders[path.join('collect', 'index.md')], 2);
    expect(english.orders[path.join('protect-and-collaborate', 'index.md')], 3);
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

  test('the Cookbook overview links to Day One on the website', () {
    final repository = DocumentationRepository();
    for (final language in DocsLanguage.values) {
      final root = path.join('assets', 'docs', 'cookbook', language.code);
      // Day One lives only on the website.
      expect(
        File(path.join(root, 'day-one.mdoc')).existsSync(),
        isFalse,
        reason: language.code,
      );

      final overviewPath = path.join(root, 'index.md');
      final document = repository.parseDocument(
        assetPath: overviewPath,
        source: File(overviewPath).readAsStringSync(),
      );
      expect(document.title, isNotEmpty, reason: overviewPath);
      expect(document.language, language, reason: overviewPath);
      expect(
        document.markdown,
        contains('https://nahpu.app/${language.code}/day-one/'),
        reason: overviewPath,
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
        final prose = document.markdown.replaceAll(
          RegExp('```.*?```', dotAll: true),
          '',
        );
        final links = RegExp(
          r'\[[^\]]+\]\(([^)]+)\)',
        ).allMatches(prose).map((match) => match.group(1)!).toList();
        expect(links, isNotEmpty, reason: file.path);
        for (final link in links) {
          expect(
            link,
            startsWith('https://nahpu.app/${language.code}/'),
            reason: file.path,
          );
        }
      }
    }
  });
}

/// The linked website pages of one info topic, with the locale segment removed.
List<String> _infoLinkPaths(
  DocumentationRepository repository,
  DocsLanguage language,
  InfoTopic topic,
) {
  final assetPath = 'assets/docs/info/${language.code}/${topic.assetSlug}.md';
  final document = repository.parseDocument(
    assetPath: assetPath,
    source: File(assetPath).readAsStringSync(),
  );
  return RegExp(r'\[[^\]]+\]\(([^)]+)\)')
      .allMatches(document.markdown)
      .map(
        (match) => match
            .group(1)!
            .replaceFirst('https://nahpu.app/${language.code}/', ''),
      )
      .toList();
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
