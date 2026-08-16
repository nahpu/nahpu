import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaml/yaml.dart';

enum DocsLanguage {
  english('en', 'English'),
  portuguese('pt', 'Português'),
  spanish('es', 'Español'),
  indonesian('id', 'Bahasa Indonesia');

  const DocsLanguage(this.code, this.nativeLabel);

  final String code;
  final String nativeLabel;
}

enum InfoTopic {
  projectOverview('project-overview'),
  projectPersonnel('project-personnel'),
  taxonRegistry('taxon-registry'),
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
  });

  final String id;
  final String title;
  final String markdown;
  final String assetPath;
  final int order;
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
  DocumentationRepository({
    AssetBundle? assetBundle,
    DocumentationAssetPathsLoader? assetPathsLoader,
  }) : _assetBundle = assetBundle ?? rootBundle,
       _assetPathsLoader = assetPathsLoader;

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
    final filename = assetPath.split('/').last;
    final id = filename.substring(0, filename.length - '.md'.length);
    final markdown = normalized.substring(closingIndex + 5).trim();

    return MarkdownDocument(
      id: id,
      title: title.trim(),
      markdown: markdown,
      assetPath: assetPath,
      order: order,
    );
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
      if (!path.startsWith(prefix) || !path.endsWith('.md')) return false;
      final relativeParts = path.substring(prefix.length).split('/');
      return relativeParts.length == 2 && relativeParts.last != 'index.md';
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
