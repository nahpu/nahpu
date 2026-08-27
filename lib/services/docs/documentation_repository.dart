import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaml/yaml.dart';

enum DocsLanguage {
  english('en', 'English', 'EN'),
  portuguese('pt', 'Português', 'BR'),
  spanish('es', 'Español', 'ES'),
  indonesian('id', 'Bahasa Indonesia', 'ID');

  const DocsLanguage(this.code, this.nativeLabel, this.shortLabel);

  final String code;
  final String nativeLabel;

  /// Two-letter label shown on the compact language chips.
  final String shortLabel;
}

enum InfoTopic {
  projectOverview('project-overview'),
  projectPersonnel('project-personnel'),
  taxonRegistry('taxon-registry'),
  recordStatistics('record-statistics'),
  siteOverview('site-overview'),
  siteGeography('site-geography'),
  siteHabitat('site-habitat'),
  siteCoordinates('site-coordinates'),
  eventOverview('event-overview'),
  eventActivity('event-activity'),
  eventEffort('event-effort'),
  eventPersonnel('event-personnel'),
  eventWeather('event-weather'),
  specimenGeneralRecord('specimen-general-record'),
  specimenTaxonomy('specimen-taxonomy'),
  specimenCapture('specimen-capture'),
  specimenAttributes('specimen-attributes'),
  specimenParts('specimen-parts'),
  specimenParasites('specimen-parasites'),
  associatedData('associated-data'),
  media('media'),
  tabularExportPresets('tabular-export-presets'),
  documentPresets('document-presets');

  const InfoTopic(this.assetSlug);

  final String assetSlug;
}

class MarkdownDocument {
  const MarkdownDocument({
    required this.id,
    required this.title,
    required this.markdown,
    required this.assetPath,
    required this.order,
    this.language = DocsLanguage.english,
    this.authors = const [],
  });

  final String id;
  final String title;
  final String markdown;
  final String assetPath;
  final int order;
  final DocsLanguage language;

  /// Contributors who authored or revised this document.
  ///
  /// A translation with authors has been checked by a person; one without them
  /// is machine output that nobody has reviewed yet.
  final List<String> authors;
}

class CookbookRecipe {
  const CookbookRecipe({required this.id, required this.document});

  final String id;
  final MarkdownDocument document;
}

class CookbookCategory {
  const CookbookCategory({
    required this.id,
    required this.title,
    required this.order,
    required this.recipes,
  });

  final String id;
  final String title;
  final int order;
  final List<CookbookRecipe> recipes;
}

typedef DocumentationAssetPathsLoader = Future<List<String>> Function();

class DocumentationRepository {
  factory DocumentationRepository({
    AssetBundle? assetBundle,
    DocumentationAssetPathsLoader? assetPathsLoader,
  }) {
    return DocumentationRepository._(
      assetBundle ?? rootBundle,
      assetPathsLoader,
    );
  }

  DocumentationRepository._(this._assetBundle, this._assetPathsLoader);

  final AssetBundle _assetBundle;
  final DocumentationAssetPathsLoader? _assetPathsLoader;
  final Map<String, Future<MarkdownDocument>> _documentCache = {};
  final Map<DocsLanguage, Future<List<CookbookCategory>>> _cookbookCache = {};

  Future<MarkdownDocument> loadInfo(
    InfoTopic topic,
    DocsLanguage language,
  ) async {
    try {
      return await loadDocument(
        'assets/docs/info/${language.code}/${topic.assetSlug}.md',
      );
    } on Object {
      if (language == DocsLanguage.english) rethrow;
      return loadDocument(
        'assets/docs/info/${DocsLanguage.english.code}/${topic.assetSlug}.md',
      );
    }
  }

  Future<List<CookbookCategory>> loadCookbook(DocsLanguage language) {
    return _cookbookCache.putIfAbsent(
      language,
      () => _loadCookbookWithFallback(language),
    );
  }

  Future<MarkdownDocument> loadDocument(String assetPath) {
    return _documentCache.putIfAbsent(assetPath, () async {
      final source = await _assetBundle.loadString(assetPath);
      return parseDocument(assetPath: assetPath, source: source);
    });
  }

  MarkdownDocument parseDocument({
    required String assetPath,
    required String source,
  }) {
    final normalized = source.replaceAll('\r\n', '\n');
    if (!normalized.startsWith('---\n')) {
      throw FormatException('Missing YAML front matter in $assetPath');
    }
    final closingIndex = normalized.indexOf('\n---\n', 4);
    if (closingIndex == -1) {
      throw FormatException('Unclosed YAML front matter in $assetPath');
    }

    final frontMatter = loadYaml(normalized.substring(4, closingIndex));
    if (frontMatter is! YamlMap) {
      throw FormatException('Invalid YAML front matter in $assetPath');
    }
    final title = frontMatter['title'];
    if (title is! String || title.trim().isEmpty) {
      throw FormatException('Missing document title in $assetPath');
    }
    final sidebar = frontMatter['sidebar'];
    final rawOrder = sidebar is YamlMap ? sidebar['order'] : null;
    final order = rawOrder is num ? rawOrder.toInt() : 0;
    final normalizedPath = assetPath.replaceAll('\\', '/');
    final filename = normalizedPath.split('/').last;
    final extensionIndex = filename.lastIndexOf('.');
    if (extensionIndex <= 0) {
      throw FormatException('Missing document extension in $assetPath');
    }
    final id = filename.substring(0, extensionIndex);
    final markdown = normalized.substring(closingIndex + 5).trim();
    final pathParts = normalizedPath.split('/');
    final language = DocsLanguage.values.firstWhere(
      (language) => pathParts.contains(language.code),
      orElse: () => DocsLanguage.english,
    );

    return MarkdownDocument(
      id: id,
      title: title.trim(),
      markdown: markdown,
      assetPath: assetPath,
      order: order,
      language: language,
      authors: _parseAuthors(frontMatter['authors']),
    );
  }

  /// Accepts a single name or a list, matching the website front matter.
  List<String> _parseAuthors(Object? value) {
    final names = switch (value) {
      final String author => [author],
      final YamlList authors => authors.whereType<String>().toList(),
      _ => const <String>[],
    };
    return [
      for (final name in names)
        if (name.trim().isNotEmpty) name.trim(),
    ];
  }

  Future<List<CookbookCategory>> _loadCookbookWithFallback(
    DocsLanguage language,
  ) async {
    try {
      return await _loadCookbook(language);
    } on Object {
      if (language == DocsLanguage.english) rethrow;
      return _loadCookbook(DocsLanguage.english);
    }
  }

  Future<List<CookbookCategory>> _loadCookbook(DocsLanguage language) async {
    final assets = await _loadAssetPaths();
    final prefix = 'assets/docs/cookbook/${language.code}/';
    final recipePaths = assets.where((path) {
      if (!path.startsWith(prefix) || !path.endsWith('.mdoc')) return false;
      final relativeParts = path.substring(prefix.length).split('/');
      return relativeParts.length == 2;
    }).toList()..sort();
    if (recipePaths.isEmpty) {
      throw StateError('No cookbook recipes found for ${language.code}');
    }

    final categoryIds =
        recipePaths
            .map((path) => path.substring(prefix.length).split('/').first)
            .toSet()
            .toList()
          ..sort();
    final categories = <CookbookCategory>[];
    for (final categoryId in categoryIds) {
      final categoryDocument = await loadDocument(
        '${prefix + categoryId}/index.md',
      );
      final documents = await Future.wait(
        recipePaths
            .where((path) => path.startsWith('$prefix$categoryId/'))
            .map(loadDocument),
      );
      documents.sort((left, right) {
        final order = left.order.compareTo(right.order);
        return order != 0 ? order : left.title.compareTo(right.title);
      });
      categories.add(
        CookbookCategory(
          id: categoryId,
          title: categoryDocument.title,
          order: categoryDocument.order,
          recipes: [
            for (final document in documents)
              CookbookRecipe(id: document.id, document: document),
          ],
        ),
      );
    }
    categories.sort((left, right) {
      final order = left.order.compareTo(right.order);
      return order != 0 ? order : left.title.compareTo(right.title);
    });
    return categories;
  }

  Future<List<String>> _loadAssetPaths() async {
    final customLoader = _assetPathsLoader;
    if (customLoader != null) return customLoader();
    final manifest = await AssetManifest.loadFromAssetBundle(_assetBundle);
    return manifest.listAssets();
  }
}

final documentationRepositoryProvider = Provider<DocumentationRepository>(
  (ref) => DocumentationRepository(),
);
