import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/bundled_template_preset_service.dart';
import 'package:nahpu/services/templates/template_service.dart';
import 'package:nahpu/services/templates/template_settings_services.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

class TemplatePresetSummary {
  const TemplatePresetSummary({required this.template, required this.usages});

  final Template template;
  final List<rust_config.TemplatePresetUsage> usages;

  int get blockCount =>
      usages.fold(0, (total, usage) => total + usage.blockIndices.length);
}

class TemplatePresetDeletionResult {
  const TemplatePresetDeletionResult({
    required this.updatedLayoutCount,
    required this.updatedBlockCount,
  });

  final int updatedLayoutCount;
  final int updatedBlockCount;
}

/// Coordinates template deletion with template-block references and startup
/// seeding metadata.
class TemplatePresetManagementService {
  const TemplatePresetManagementService({
    this.templateService = const TemplateService(),
    this.bundledTemplateService = const BundledTemplatePresetService(),
  });

  final TemplateService templateService;
  final BundledTemplatePresetService bundledTemplateService;

  Future<List<TemplatePresetSummary>> loadSummaries() async {
    final names = await templateService.listTemplateNames();
    final summaries = await Future.wait(
      names.map((name) async {
        final template = await templateService.getTemplate(name);
        if (template == null) {
          throw StateError('Template preset "$name" no longer exists');
        }
        final usages = await rust_config.getTemplatePresetUsages(name: name);
        return TemplatePresetSummary(template: template, usages: usages);
      }),
    );
    summaries.sort((a, b) => a.template.name.compareTo(b.template.name));
    return summaries;
  }

  Future<List<rust_config.TemplatePresetUsage>> getUsages(String name) {
    return rust_config.getTemplatePresetUsages(name: name);
  }

  /// Renames a template and repoints everything that referenced the old name.
  ///
  /// redb has no rename primitive, so this is composed from a write under the
  /// new name followed by a delete-with-replacement of the old one. That
  /// delete already rewrites every layout block that referenced the template,
  /// which is exactly the second half of a rename.
  Future<TemplatePresetDeletionResult> renameTemplate({
    required String currentName,
    required String newName,
  }) async {
    final from = currentName.trim();
    final to = newName.trim();
    if (to.isEmpty) {
      throw ArgumentError('A template name cannot be empty');
    }
    if (from == to) {
      return const TemplatePresetDeletionResult(
        updatedLayoutCount: 0,
        updatedBlockCount: 0,
      );
    }
    final existing = await templateService.getTemplate(from);
    if (existing == null) {
      throw StateError('Template preset "$from" no longer exists');
    }
    final taken = await templateService.listTemplateNames();
    if (taken.contains(to)) {
      throw StateError('A template named "$to" already exists');
    }

    await rust_config.setTemplatePreset(
      name: to,
      value: existing.copyWith(name: to).toJsonString(),
    );
    final wasSuppressed = await bundledTemplateService.suppress(from);
    try {
      final result = await rust_config.deleteTemplatePresetWithReplacement(
        name: from,
        replacementName: to,
      );
      final settings = DocumentSettingsServices();
      if (await settings.getCurrentTemplateName() == from) {
        await settings.setCurrentTemplateName(to);
      }
      return TemplatePresetDeletionResult(
        updatedLayoutCount: result.updatedLayoutCount,
        updatedBlockCount: result.updatedBlockCount,
      );
    } catch (_) {
      if (wasSuppressed) {
        await bundledTemplateService.restore(from);
      }
      await rust_config.deleteTemplatePreset(name: to);
      rethrow;
    }
  }

  Future<TemplatePresetDeletionResult> deleteTemplate({
    required String name,
    String? replacementName,
  }) async {
    final wasSuppressed = await bundledTemplateService.suppress(name);
    try {
      final result = await rust_config.deleteTemplatePresetWithReplacement(
        name: name,
        replacementName: replacementName,
      );
      final current = await DocumentSettingsServices().getCurrentTemplateName();
      if (current == name) {
        await DocumentSettingsServices().setCurrentTemplateName(
          replacementName,
        );
      }
      return TemplatePresetDeletionResult(
        updatedLayoutCount: result.updatedLayoutCount,
        updatedBlockCount: result.updatedBlockCount,
      );
    } catch (_) {
      if (wasSuppressed) {
        await bundledTemplateService.restore(name);
      }
      rethrow;
    }
  }
}
