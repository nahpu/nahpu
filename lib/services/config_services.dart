import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:nahpu/services/document_layout_service.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

class ConfigDbService {
  static const String nahpuAppDir = 'nahpu';
  static const String configDbName = 'nahpu_configs.db';
  static const String defaultDocumentPresetsLoadedPrefKey =
      'defaultDocumentPresetsLoaded';

  static const List<String> _defaultDocumentPresetAssets = [
    'assets/configs/classic.json',
    'assets/configs/modern.json',
  ];

  Future<void> initDb() async {
    final dbDir = await getApplicationDocumentsDirectory();
    final nahpuDir = Directory(path.join(dbDir.path, nahpuAppDir));
    await nahpuDir.create(recursive: true);
    final dbPath = path.join(nahpuDir.path, configDbName);
    await rust_config.initConfigDb(path: dbPath);
  }

  Future<void> migrate(SharedPreferences prefs) async {
    // List of deprecated string/list configuration keys
    final listKeys = [
      'siteTypes',
      'habitatTypes',
      'collEventMethods',
      'collPersonnelRoles',
      'specimenTypes',
      'specimenTreatment',
    ];

    final stringKeys = [
      'siteTypeFmt',
      'habitatTypeFmt',
      'collEventMethodFmt',
      'collPersonnelRoleFmt',
      'specimenTypeFmt',
      'treatmentFmt',
      'fieldIdMode',
      'pdfExportFont',
    ];

    // Migrate simple list configs
    for (final key in listKeys) {
      if (prefs.containsKey(key)) {
        final value = prefs.getStringList(key);
        if (value != null) {
          await rust_config.setUserConfigList(key: key, value: value);
        }
      }
    }

    // Migrate simple string configs
    for (final key in stringKeys) {
      if (prefs.containsKey(key)) {
        final value = prefs.getString(key);
        if (value != null) {
          await rust_config.setUserConfigString(key: key, value: value);
        }
      }
    }

    // Migrate export presets
    if (prefs.containsKey('exportPresets')) {
      final presetString = prefs.getString('exportPresets');
      if (presetString != null) {
        try {
          final decoded = jsonDecode(presetString) as Map<String, dynamic>;
          for (final entry in decoded.entries) {
            final name = entry.key;
            final dynamic val = entry.value;

            Map<String, String> fields = {};
            List<rust_config.ConfigCombinedField> combinedFields = [];

            if (val is Map<String, dynamic> && val.containsKey('fields')) {
              // Version 2 format
              fields = Map<String, String>.from(val['fields'] as Map);
              combinedFields = (val['combined'] as List? ?? [])
                  .map((e) => rust_config.ConfigCombinedField(
                        fieldId: e['fieldId'] as String,
                        fields: List<String>.from(e['fields'] as List),
                      ))
                  .toList();
            } else if (val is Map) {
              // Version 1 format (legacy)
              fields = Map<String, String>.from(val);
            }

            final preset = rust_config.ConfigExportPreset(
              fields: fields,
              combinedFields: combinedFields,
            );
            await rust_config.setRecordExportPreset(name: name, preset: preset);
          }
        } catch (_) {
          // Ignore json decoding/migration errors for invalid legacy formats
        }
      }
    }

    // After migration, clear only the deprecated keys from SharedPreferences
    final allDeprecatedKeys = [
      ...listKeys,
      ...stringKeys,
      'exportPresets',
    ];

    for (final key in allDeprecatedKeys) {
      await prefs.remove(key);
    }
  }

  Future<void> loadDefaultDocumentPresetsOnce(
    SharedPreferences prefs, {
    AssetBundle? bundle,
  }) async {
    if (prefs.getBool(defaultDocumentPresetsLoadedPrefKey) ?? false) {
      return;
    }
    final assetBundle = bundle ?? rootBundle;

    final existingTemplateNames =
        (await rust_config.listTemplatePresets()).toSet();
    final existingLayoutNames =
        (await const DocumentLayoutService().listLayoutStatuses())
            .map((status) => status.name)
            .toSet();

    for (final assetPath in _defaultDocumentPresetAssets) {
      final raw = await assetBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw FormatException(
            'Default preset must be a JSON object: $assetPath');
      }
      final preset = Map<String, dynamic>.from(decoded);

      for (final templateJson in preset['templates'] as List? ?? const []) {
        final template = Template.fromJson(
          Map<String, dynamic>.from(templateJson as Map),
        );
        if (existingTemplateNames.contains(template.name)) continue;
        await rust_config.setTemplatePreset(
          name: template.name,
          value: template.toJsonString(),
        );
        existingTemplateNames.add(template.name);
      }

      for (final layoutJson in preset['layouts'] as List? ?? const []) {
        final layout = DocumentLayoutPresetJson.fromJson(
          Map<String, dynamic>.from(layoutJson as Map),
        );
        if (existingLayoutNames.contains(layout.name)) continue;
        await rust_config.setDocumentLayout(name: layout.name, layout: layout);
        existingLayoutNames.add(layout.name);
      }
    }

    await prefs.setBool(defaultDocumentPresetsLoadedPrefKey, true);
  }
}
