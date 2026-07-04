import 'dart:io';

import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/template_settings_services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const String _templatesDirName = 'templates';

class TemplateService {
  const TemplateService();

  Future<Directory> _templatesDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, _templatesDirName));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  Future<List<String>> listTemplateNames() async {
    final dir = await _templatesDir();
    return dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .map((f) => p.basenameWithoutExtension(f.path))
        .toList()
      ..sort();
  }

  Future<Template?> getTemplate(String name) async {
    final dir = await _templatesDir();
    final file = File(p.join(dir.path, '$name.json'));
    if (!file.existsSync()) return null;
    return Template.fromJsonString(await file.readAsString());
  }

  Future<void> saveTemplate(Template template) async {
    final dir = await _templatesDir();
    final file = File(p.join(dir.path, '${template.name}.json'));
    await file.writeAsString(template.toJsonString());
    await LabelSettingsServices().setCurrentTemplateName(template.name);
  }

  Future<void> deleteTemplate(String name) async {
    final dir = await _templatesDir();
    final file = File(p.join(dir.path, '$name.json'));
    if (file.existsSync()) await file.delete();
  }

  Future<Template> getCurrentTemplate() async {
    final names = await listTemplateNames();
    if (names.isEmpty) return DefaultTemplate.defaultTemplate();
    final prefsName = await LabelSettingsServices().getCurrentTemplateName();
    final pick = (prefsName != null && names.contains(prefsName))
        ? prefsName
        : names.first;
    return (await getTemplate(pick)) ?? DefaultTemplate.defaultTemplate(pick);
  }

  Future<Template?> importFromPath(String path) async {
    try {
      final text = await File(path).readAsString();
      return Template.fromJsonString(text);
    } catch (_) {
      return null;
    }
  }
}
