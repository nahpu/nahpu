import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/templates/document_layout_service.dart';
import 'package:nahpu/services/templates/template_service.dart';
import 'package:nahpu/services/templates/template_transfer_service.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// The kind of preset a bundled config file holds, named by its file prefix.
enum BundledPresetKind {
  document('document'),
  record('record'),
  template('template');

  const BundledPresetKind(this.prefix);

  final String prefix;

  /// The kind whose prefix starts [fileName], or null for any other file.
  static BundledPresetKind? fromFileName(String fileName) {
    for (final kind in values) {
      if (fileName.startsWith('${kind.prefix}-')) return kind;
    }
    return null;
  }
}

/// One preset shipped with NAHPU under [BundledPresetService.configsDir].
class BundledPreset {
  const BundledPreset({
    required this.kind,
    required this.name,
    required this.description,
    required this.assetPath,
    this.catalogFmt,
  });

  final BundledPresetKind kind;
  final String name;
  final String description;
  final String assetPath;

  /// The catalog format the preset is written for, or null when it suits any.
  final CatalogFmt? catalogFmt;

  /// Whether the preset suits every catalog format, so Load defaults adds it.
  bool get isGeneric => catalogFmt == null;
}

class BundledPresetStatus {
  const BundledPresetStatus({required this.preset, required this.isInstalled});

  final BundledPreset preset;

  /// Whether a preset of the same kind and name is already saved.
  final bool isInstalled;
}

class BundledPresetLoadResult {
  const BundledPresetLoadResult({
    required this.added,
    required this.skippedCount,
  });

  final List<BundledPreset> added;

  /// Presets left alone because one with the same name is already saved.
  final int skippedCount;

  String get message {
    if (added.isNotEmpty) {
      return 'Added ${added.length} preset${added.length == 1 ? '' : 's'}';
    }
    return skippedCount == 0
        ? 'No default presets of this type'
        : 'Default presets are already loaded';
  }
}

/// Discovers and loads the presets bundled under [configsDir].
///
/// Generic presets sit directly in [configsDir] and are what Load defaults
/// adds. Presets written for one catalog format sit in a folder named after
/// that [CatalogFmt] and are only added when chosen in the setup wizard.
///
/// Loading never overwrites a saved preset with the same name, so a preset
/// the user edited or deleted is only ever restored on request.
class BundledPresetService {
  const BundledPresetService({this.bundle, this.assetPathsLoader});

  static const String configsDir = 'assets/configs';
  static const String loadedPrefKey = 'bundledPresetsLoaded';
  static const String _legacyLoadedPrefKey = 'defaultDocumentPresetsLoaded';

  /// Where preset files are read from; the root bundle when null.
  final AssetBundle? bundle;

  /// Lists asset paths instead of the asset manifest, for tests.
  final Future<List<String>> Function()? assetPathsLoader;

  /// Every bundled preset: generic ones first, then by catalog format, kind,
  /// and name.
  Future<List<BundledPreset>> list() async {
    return [for (final entry in await _readAll()) entry.preset];
  }

  /// The generic presets, limited to [kinds] when given.
  Future<List<BundledPreset>> defaults({Set<BundledPresetKind>? kinds}) async {
    return [
      for (final preset in await list())
        if (preset.isGeneric && (kinds == null || kinds.contains(preset.kind)))
          preset,
    ];
  }

  /// [presets] preceded by the bundled templates their layouts use, so a
  /// loaded layout never points at a missing template.
  Future<List<BundledPreset>> withTemplates(
    Iterable<BundledPreset> presets,
  ) async {
    final entries = _withTemplates(await _readAll(), presets);
    return [for (final entry in entries) entry.preset];
  }

  /// Generic presets plus those written for [catalogFmt], each marked with
  /// whether it is already saved.
  Future<List<BundledPresetStatus>> statuses({CatalogFmt? catalogFmt}) async {
    final installed = await _installedNames();
    return [
      for (final preset in await list())
        if (preset.isGeneric || preset.catalogFmt == catalogFmt)
          BundledPresetStatus(
            preset: preset,
            isInstalled: installed[preset.kind]!.contains(preset.name),
          ),
    ];
  }

  /// Adds the generic presets of [kinds], or of every kind when null.
  Future<BundledPresetLoadResult> loadDefaults({
    Set<BundledPresetKind>? kinds,
  }) async {
    return loadSelected(await defaults(kinds: kinds));
  }

  /// Adds [presets] and the templates they need, skipping saved names.
  Future<BundledPresetLoadResult> loadSelected(
    Iterable<BundledPreset> presets,
  ) async {
    final queue = _withTemplates(await _readAll(), presets);
    final installed = await _installedNames();
    final added = <BundledPreset>[];
    var skippedCount = 0;
    for (final entry in queue) {
      final names = installed[entry.preset.kind]!;
      if (names.contains(entry.preset.name)) {
        skippedCount++;
        continue;
      }
      await _write(entry);
      names.add(entry.preset.name);
      added.add(entry.preset);
    }
    return BundledPresetLoadResult(added: added, skippedCount: skippedCount);
  }

  /// Adds the generic presets once per installation.
  ///
  /// Later launches leave presets alone, so a deleted default stays deleted.
  Future<void> loadOnFirstLaunch(SharedPreferences prefs) async {
    await prefs.remove(_legacyLoadedPrefKey);
    if (prefs.getBool(loadedPrefKey) ?? false) return;
    await loadDefaults();
    await prefs.setBool(loadedPrefKey, true);
  }

  /// Parses the bundled file at [assetPath] with contents [raw].
  ///
  /// Throws a [FormatException] when the file is not a single preset of the
  /// kind its name promises.
  BundledPreset describe(String assetPath, String raw) {
    return _parse(assetPath, raw).preset;
  }

  /// Whether [assetPath] is a preset file directly in [configsDir] or in one
  /// of its catalog-format folders.
  static bool isPresetAsset(String assetPath) {
    if (p.url.extension(assetPath) != '.json') return false;
    if (BundledPresetKind.fromFileName(p.url.basename(assetPath)) == null) {
      return false;
    }
    final folder = p.url.dirname(assetPath);
    return folder == configsDir ||
        (p.url.dirname(folder) == configsDir &&
            CatalogFmt.values.asNameMap().containsKey(p.url.basename(folder)));
  }

  /// The catalog format named by the folder holding [assetPath], or null for
  /// a file directly in [configsDir].
  static CatalogFmt? catalogFmtFor(String assetPath) {
    final folder = p.url.dirname(assetPath);
    if (folder == configsDir) return null;
    return CatalogFmt.values.asNameMap()[p.url.basename(folder)];
  }

  Future<List<_BundledEntry>> _readAll() async {
    final assetBundle = bundle ?? rootBundle;
    final entries = <_BundledEntry>[];
    for (final path in (await _loadAssetPaths()).where(isPresetAsset)) {
      entries.add(_parse(path, await assetBundle.loadString(path)));
    }
    entries.sort((a, b) {
      final byFormat = (a.preset.catalogFmt?.index ?? -1).compareTo(
        b.preset.catalogFmt?.index ?? -1,
      );
      if (byFormat != 0) return byFormat;
      final byKind = a.preset.kind.index.compareTo(b.preset.kind.index);
      return byKind != 0 ? byKind : a.preset.name.compareTo(b.preset.name);
    });
    return entries;
  }

  List<_BundledEntry> _withTemplates(
    List<_BundledEntry> all,
    Iterable<BundledPreset> presets,
  ) {
    final paths = presets.map((preset) => preset.assetPath).toSet();
    final selected = all.where(
      (entry) => paths.contains(entry.preset.assetPath),
    );
    final templates = {
      for (final entry in all)
        if (entry.value is Template) entry.preset.name: entry,
    };
    final queue = <_BundledEntry>[];
    for (final entry in selected) {
      final value = entry.value;
      if (value is! rust_config.DocumentLayoutPreset) continue;
      for (final block in value.blocks) {
        final template = templates[block.templateName];
        if (template != null && !queue.contains(template)) queue.add(template);
      }
    }
    for (final entry in selected) {
      if (!queue.contains(entry)) queue.add(entry);
    }
    return queue;
  }

  Future<Map<BundledPresetKind, Set<String>>> _installedNames() async {
    final layouts = await const DocumentLayoutService().listLayoutStatuses();
    final records = await rust_config.getAllRecordExportPresets();
    return {
      BundledPresetKind.document: layouts.map((layout) => layout.name).toSet(),
      BundledPresetKind.record: records.map((record) => record.name).toSet(),
      BundledPresetKind.template: (await rust_config.listTemplatePresets())
          .toSet(),
    };
  }

  Future<void> _write(_BundledEntry entry) async {
    final value = entry.value;
    if (value is Template) {
      await const TemplateService().updateTemplate(value);
    } else if (value is rust_config.DocumentLayoutPreset) {
      await const DocumentLayoutService().saveLayout(value);
    } else if (value is ExportPresetModel) {
      await rust_config.setRecordExportPreset(
        name: entry.preset.name,
        preset: ExportPresetNotifier.toConfig(value),
      );
    }
  }

  _BundledEntry _parse(String assetPath, String raw) {
    final fileName = p.url.basename(assetPath);
    final kind = BundledPresetKind.fromFileName(fileName);
    if (kind == null) {
      throw FormatException('Not a bundled preset file: $assetPath');
    }
    final catalogFmt = catalogFmtFor(assetPath);
    BundledPreset preset(String name, String? description) => BundledPreset(
      kind: kind,
      name: name,
      description: description?.trim() ?? '',
      assetPath: assetPath,
      catalogFmt: catalogFmt,
    );

    switch (kind) {
      case BundledPresetKind.template:
        final templates = const TemplateTransferService().decode(raw);
        if (templates.length != 1) {
          throw FormatException('Expected one template in $assetPath');
        }
        final template = templates.single;
        return _BundledEntry(
          preset(template.name, template.description),
          template,
        );
      case BundledPresetKind.document:
        final body = _singlePreset(raw, assetPath).value;
        final layout = DocumentLayoutPresetJson.fromJson(body);
        return _BundledEntry(preset(layout.name, layout.description), layout);
      case BundledPresetKind.record:
        final entry = _singlePreset(raw, assetPath);
        final model = ExportPresetModel.fromJson(entry.value);
        return _BundledEntry(preset(entry.key, model.description), model);
    }
  }

  /// The one name-keyed preset a layout or record file holds.
  MapEntry<String, Map<String, dynamic>> _singlePreset(
    String raw,
    String assetPath,
  ) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map ||
        decoded.length != 1 ||
        decoded.values.single is! Map) {
      throw FormatException('Expected one name-keyed preset in $assetPath');
    }
    return MapEntry(
      decoded.keys.single as String,
      Map<String, dynamic>.from(decoded.values.single as Map),
    );
  }

  Future<List<String>> _loadAssetPaths() async {
    final customLoader = assetPathsLoader;
    if (customLoader != null) return customLoader();
    final manifest = await AssetManifest.loadFromAssetBundle(
      bundle ?? rootBundle,
    );
    return manifest.listAssets();
  }
}

/// A parsed bundled preset: a [Template], a layout, or an
/// [ExportPresetModel].
class _BundledEntry {
  const _BundledEntry(this.preset, this.value);

  final BundledPreset preset;
  final Object value;
}
