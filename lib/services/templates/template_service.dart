import 'dart:io';

import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/bundled_template_preset_service.dart';
import 'package:nahpu/services/templates/template_settings_services.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

class TemplateService {
  const TemplateService();

  Future<List<String>> listTemplateNames() async {
    final names = await rust_config.listTemplatePresets();
    return names..sort();
  }

  Future<Template?> getTemplate(String name) async {
    final jsonStr = await rust_config.getTemplatePreset(name: name);
    if (jsonStr == null) return null;
    return Template.fromJsonString(jsonStr);
  }

  Future<void> saveTemplate(Template template) async {
    await rust_config.setTemplatePreset(
      name: template.name,
      value: template.toJsonString(),
    );
    await const BundledTemplatePresetService().restore(template.name);
    await DocumentSettingsServices().setCurrentTemplateName(template.name);
  }

  Future<void> deleteTemplate(String name) async {
    await rust_config.deleteTemplatePreset(name: name);
  }

  Future<Template> getCurrentTemplate() async {
    final names = await listTemplateNames();
    if (names.isEmpty) return DefaultTemplate.defaultTemplate();
    final prefsName = await DocumentSettingsServices().getCurrentTemplateName();
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
