import 'dart:convert';
import 'dart:io';

import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/templates/document_layout_service.dart';
import 'package:nahpu/services/templates/template_service.dart';
import 'package:nahpu/services/templates/template_transfer_service.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

/// Print layouts read from a preset file, with the templates packed alongside.
class DocumentPresetBundle {
  const DocumentPresetBundle({
    required this.layouts,
    this.templates = const [],
  });

  final List<rust_config.DocumentLayoutPreset> layouts;
  final List<Template> templates;
}

class DocumentPresetImportResult {
  const DocumentPresetImportResult({
    required this.layoutNames,
    required this.addedTemplateCount,
    required this.renamedTemplates,
  });

  /// The names the layouts were saved under.
  final List<String> layoutNames;
  final int addedTemplateCount;

  /// Templates saved under a new name, keyed by the name in the file.
  final Map<String, String> renamedTemplates;

  String get message {
    final layouts =
        'Imported ${layoutNames.length} preset'
        '${layoutNames.length == 1 ? '' : 's'}';
    if (addedTemplateCount == 0) return layouts;
    return '$layouts and $addedTemplateCount template'
        '${addedTemplateCount == 1 ? '' : 's'}';
  }
}

/// Reads and writes the files used to move presets between installations.
///
/// A print layout file carries the templates its blocks use unless the user
/// leaves them out, so the layout still prints on another device.
class PresetTransferService {
  const PresetTransferService({
    this.layoutService = const DocumentLayoutService(),
    this.templateService = const TemplateService(),
  });

  static const String documentPresetsKey = 'nahpu_document_presets';
  static const int documentPresetsVersion = 1;
  static const String _layoutsKey = 'document_layouts';
  static const String _templatesKey = 'template_presets';

  final DocumentLayoutService layoutService;
  final TemplateService templateService;

  /// Writes [content] as `<fileStem>.json` in [directory], or in the app
  /// documents directory when null, without replacing an existing file.
  Future<File> save({
    required String content,
    required String fileStem,
    Directory? directory,
  }) async {
    final output = await AppIOServices(
      dir: directory,
      fileStem: safeFileStem(fileStem),
      ext: 'json',
    ).getSavePath();
    await output.writeAsString(content, flush: true);
    return output;
  }

  /// [value] reduced to letters, digits, dashes, and underscores.
  static String safeFileStem(String value, [String fallback = 'preset']) {
    final withoutExtension = value.trim().replaceFirst(
      RegExp(r'\.json$', caseSensitive: false),
      '',
    );
    final cleaned = withoutExtension
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? fallback : cleaned;
  }

  /// The template names [layouts] print with, in first-use order.
  static List<String> linkedTemplateNames(
    Iterable<rust_config.DocumentLayoutPreset> layouts,
  ) {
    final names = <String>{};
    for (final layout in layouts) {
      for (final block in layout.blocks) {
        names.add(block.templateName);
      }
    }
    return names.toList();
  }

  /// A note that images in [templates] do not travel with the file, or null
  /// when none of them use images.
  static String? imageNote(Iterable<Template> templates) {
    final count = templates
        .where(
          (template) =>
              template.page1.customImages.isNotEmpty ||
              template.page2.customImages.isNotEmpty,
        )
        .length;
    if (count == 0) return null;
    return '$count template${count == 1 ? '' : 's'} use images, which are '
        'referenced by name rather than stored in the file. On another '
        'installation those images have to be added again.';
  }

  String encodeLayouts(
    Iterable<rust_config.DocumentLayoutPreset> layouts, {
    Iterable<Template> templates = const [],
  }) {
    return const JsonEncoder.withIndent('  ').convert({
      documentPresetsKey: documentPresetsVersion,
      _layoutsKey: {for (final layout in layouts) layout.name: layout.toJson()},
      if (templates.isNotEmpty)
        _templatesKey: {
          for (final template in templates) template.name: template.toJson(),
        },
    });
  }

  /// Parses a layout file: the current envelope, an older name-keyed map of
  /// layouts, or a single layout.
  DocumentPresetBundle decodeLayouts(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Preset files must contain a JSON object');
    }
    final map = Map<String, dynamic>.from(decoded);
    if (map.containsKey(documentPresetsKey)) {
      final version = map[documentPresetsKey];
      if (version is! int || version > documentPresetsVersion) {
        throw const FormatException('Unsupported document preset file version');
      }
      final templates = map[_templatesKey];
      return DocumentPresetBundle(
        layouts: _layoutsFrom(map[_layoutsKey]),
        templates: templates is Map && templates.isNotEmpty
            ? const TemplateTransferService().decode(jsonEncode(templates))
            : const [],
      );
    }
    if (map.containsKey('name') && map.containsKey('layoutType')) {
      return DocumentPresetBundle(
        layouts: [DocumentLayoutPresetJson.fromJson(map)],
      );
    }
    return DocumentPresetBundle(layouts: _layoutsFrom(map));
  }

  /// Saves [templates] and then [bundle]'s layouts.
  ///
  /// [templates] are the bundle's templates after any font substitution. A
  /// template identical to a saved one is reused; a different template with a
  /// taken name is saved under a free name and the layouts are repointed.
  Future<DocumentPresetImportResult> importLayouts(
    DocumentPresetBundle bundle, {
    required List<Template> templates,
  }) async {
    const transfer = TemplateTransferService();
    final takenTemplates = (await templateService.listTemplateNames()).toSet();
    final renamed = <String, String>{};
    var addedTemplateCount = 0;
    for (final template in templates) {
      if (takenTemplates.contains(template.name)) {
        final saved = await templateService.getTemplate(template.name);
        if (saved?.toJsonString() == template.toJsonString()) continue;
      }
      final name = transfer.uniqueName(template.name, takenTemplates);
      takenTemplates.add(name);
      if (name != template.name) renamed[template.name] = name;
      await templateService.updateTemplate(template.copyWith(name: name));
      addedTemplateCount++;
    }

    final takenLayouts = (await layoutService.listLayoutStatuses())
        .map((status) => status.name)
        .toSet();
    final layoutNames = <String>[];
    for (final layout in bundle.layouts) {
      var name = layout.name;
      for (var index = 1; takenLayouts.contains(name); index++) {
        name = '${layout.name}_$index';
      }
      takenLayouts.add(name);
      await layoutService.saveLayout(
        layout.copyWith(
          name: name,
          blocks: [
            for (final block in layout.blocks)
              block.copyWith(
                templateName: renamed[block.templateName] ?? block.templateName,
              ),
          ],
        ),
      );
      layoutNames.add(name);
    }
    if (layoutNames.isNotEmpty) {
      await layoutService.setCurrentLayoutName(layoutNames.first);
    }
    return DocumentPresetImportResult(
      layoutNames: layoutNames,
      addedTemplateCount: addedTemplateCount,
      renamedTemplates: renamed,
    );
  }

  /// The name-keyed tabular preset file.
  String encodeRecordPresets(Map<String, ExportPresetModel> presets) {
    return jsonEncode({
      for (final entry in presets.entries) entry.key: entry.value.toJson(),
    });
  }

  List<rust_config.DocumentLayoutPreset> _layoutsFrom(Object? json) {
    if (json is! Map || json.isEmpty) {
      throw const FormatException('The file contains no print layouts');
    }
    return [
      for (final entry in json.entries)
        DocumentLayoutPresetJson.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        ).copyWith(name: entry.key as String),
    ];
  }
}
