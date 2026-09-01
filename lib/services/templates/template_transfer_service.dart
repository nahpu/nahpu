import 'dart:convert';
import 'dart:io';

import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/template_service.dart';

/// Reads and writes the JSON files used to move templates between
/// installations.
///
/// One envelope covers both cases: an export always writes a map keyed by
/// template name, whether it holds one template or all of them, so a single
/// importer handles every file. Files written before that unification held a
/// bare template object, so those are still accepted.
class TemplateTransferService {
  const TemplateTransferService({
    this.templateService = const TemplateService(),
  });

  final TemplateService templateService;

  static const String bulkFileName = 'nahpu_templates.json';

  /// Maximum templates accepted from one file, matching the cap the other
  /// preset importers apply.
  static const int importLimit = 20;

  String encode(Iterable<Template> templates) {
    final payload = <String, dynamic>{
      for (final template in templates) template.name: template.toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Parses [content] as either a bare template or a name-keyed map.
  ///
  /// Names come from the template bodies rather than the map keys so that a
  /// hand-edited file cannot produce a template whose stored name disagrees
  /// with the key it was filed under.
  List<Template> decode(String content) {
    final decoded = jsonDecode(content);
    if (decoded is! Map) {
      throw const FormatException('Template files must contain a JSON object');
    }
    final map = Map<String, dynamic>.from(decoded);
    if (map.containsKey('page1') || map.containsKey('widthMm')) {
      return [Template.fromJson(map)];
    }
    final templates = <Template>[];
    for (final entry in map.entries) {
      if (entry.value is! Map) continue;
      final body = Map<String, dynamic>.from(entry.value as Map);
      final template = Template.fromJson(body);
      templates.add(
        template.name.trim().isEmpty
            ? template.copyWith(name: entry.key)
            : template,
      );
    }
    if (templates.isEmpty) {
      throw const FormatException('The file contains no templates');
    }
    return templates;
  }

  Future<List<Template>> readFile(File file) async =>
      decode(await file.readAsString());

  Future<void> writeFile(File file, Iterable<Template> templates) =>
      file.writeAsString(encode(templates), flush: true);

  /// Loads every saved template, in the order the list screen shows them.
  Future<List<Template>> loadAll() async {
    final names = await templateService.listTemplateNames();
    final templates = <Template>[];
    for (final name in names) {
      final template = await templateService.getTemplate(name);
      if (template != null) templates.add(template);
    }
    return templates;
  }

  /// Returns [base] when it is free, or the first `base_1`, `base_2`, … that
  /// is not in [taken]. Matches the suffixing the layout importer uses.
  String uniqueName(String base, Set<String> taken) {
    final trimmed = base.trim().isEmpty ? 'Imported' : base.trim();
    if (!taken.contains(trimmed)) return trimmed;
    var index = 1;
    while (taken.contains('${trimmed}_$index')) {
      index++;
    }
    return '${trimmed}_$index';
  }

  /// A file name for exporting a single template.
  String fileNameFor(Template template) {
    final raw = template.name.trim();
    final safe = raw.isEmpty
        ? 'template'
        : raw.replaceAll(RegExp(r'[^\w.\-]'), '_');
    return 'template_$safe.json';
  }
}
