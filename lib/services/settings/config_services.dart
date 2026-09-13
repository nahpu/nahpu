import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

class ConfigDbService {
  static const String nahpuAppDir = 'nahpu';
  static const String configDbName = 'nahpu_configs.db';

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

    const previewColumnKeys = [
      'document_print_table_columns',
      'label_print_table_columns',
    ];
    final existingPreviewColumns = await rust_config
        .getTemplateTablePreviewColumns();
    if (existingPreviewColumns == null) {
      final rawColumns =
          prefs.getString(previewColumnKeys.first) ??
          prefs.getString(previewColumnKeys.last);
      if (rawColumns != null && rawColumns.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawColumns);
          if (decoded is List) {
            await rust_config.setTemplateTablePreviewColumns(
              columns: decoded.map((value) => value.toString()).toList(),
            );
          }
        } on FormatException {
          // Ignore corrupt legacy state and let the preview use its defaults.
        }
      }
    }

    // Record export presets from SharedPreferences used the unsupported v1
    // schema. They are intentionally not migrated because they lack record
    // type and mapping metadata required for reproducible exports.
    if (prefs.containsKey('exportPresets')) {
      // Cleared below with the remaining deprecated SharedPreferences keys.
    }

    // After migration, clear only the deprecated keys from SharedPreferences
    final allDeprecatedKeys = [
      ...listKeys,
      ...stringKeys,
      'exportPresets',
      ...previewColumnKeys,
    ];

    for (final key in allDeprecatedKeys) {
      await prefs.remove(key);
    }
  }
}
