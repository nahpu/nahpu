import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:nahpu/services/types/collecting.dart';
import 'package:nahpu/services/types/sites.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

// App settings keys (UI/Device states)
// Used for keeping track of user preferences and app states
// Not required for research reproducibility. Cannot be exported/imported.
// Internally, we call it `App Settings`
const String themeModePrefKey = 'themeMode';
const String catalogFmtPrefKey = 'catalogFmt';
const String spatialBasemapStylePrefKey = 'spatialBasemapStyle';
const String fieldIdModeDefaultMigratedPrefKey = 'fieldIdModeDefaultMigrated';

// User Configs keys (Project-level settings)
// User defined fields, formats, presets, and other user-configured fields.
// Required for research reproducibility. Can be exported/imported.
// Internally, we call it `User Configs`
const String siteTypePrefKey = 'siteTypes';
const String siteTypeFmtPrefKey = 'siteTypeFmt';
const String habitatTypePrefKey = 'habitatTypes';
const String habitatTypeFmtPrefKey = 'habitatTypeFmt';
const String collMethodPrefKey = 'collEventMethods';
const String collMethodFmtPrefKey = 'collEventMethodFmt';
const String collRolePrefKey = 'collPersonnelRoles';
const String collRoleFmtPrefKey = 'collPersonnelRoleFmt';
const String specimenTypePrefKey = 'specimenTypes';
const String specimenTypeFmtPrefKey = 'specimenTypeFmt';
const String treatmentPrefKey = 'specimenTreatment';
const String treatmentFmtPrefKey = 'treatmentFmt';
const String conditionPrefKey = 'specimenConditions';
const String conditionFmtPrefKey = 'conditionFmt';
const String fieldIdModePrefKey = 'fieldIdMode';
const String projectFieldIdAutoIncrementPrefKey = 'projectFieldIdAutoIncrement';
const String parasiteIdPrefixPrefKey = 'parasiteIdPrefix';
const String parasiteIdNumberPrefKey = 'parasiteIdNumber';
const String parasiteCategoryPrefKey = 'parasiteCategories';
const String parasiteCategoryFmtPrefKey = 'parasiteCategoryFmt';
const String parasiteDetectionMethodPrefKey = 'parasiteDetectionMethods';
const String parasiteDetectionMethodFmtPrefKey = 'parasiteDetectionMethodFmt';
const String parasitePreparationMethodPrefKey = 'parasitePreparationMethods';
const String parasitePreparationMethodFmtPrefKey =
    'parasitePreparationMethodFmt';
const String parasiteAnatomicalLocationPrefKey = 'parasiteAnatomicalLocations';
const String parasiteAnatomicalLocationFmtPrefKey =
    'parasiteAnatomicalLocationFmt';
const String parasiteStoragePrefKey = 'parasiteStorage';
const String parasiteStorageFmtPrefKey = 'parasiteStorageFmt';
const String parasiteTreatmentPrefKey = 'parasiteTreatments';
const String parasiteTreatmentFmtPrefKey = 'parasiteTreatmentFmt';

// Document Export settings
// User-configurable export presets and PDF document settings.
const String exportPresetPrefKey = 'exportPresets';

final settingProvider = Provider<SharedPreferences>((ref) {
  return throw UnimplementedError();
});

final themeSettingProvider = AsyncNotifierProvider<ThemeSetting, ThemeMode>(
  ThemeSetting.new,
);

class ThemeSetting extends AsyncNotifier<ThemeMode> {
  Future<ThemeMode> _fetchSetting() async {
    final prefs = ref.watch(settingProvider);
    final savedTheme = prefs.getString(themeModePrefKey);

    // Set to default system theme if no setting is found
    final ThemeMode currentTheme = _matchThemeMode(savedTheme);
    if (savedTheme == null) {
      await prefs.setString(
        themeModePrefKey,
        _matchThemeModeToString(currentTheme),
      );
    }

    return currentTheme;
  }

  @override
  Future<ThemeMode> build() async {
    return await _fetchSetting();
  }

  Future<void> setTheme(String mode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      String value = mode.toLowerCase();
      final prefs = ref.watch(settingProvider);
      final themeMode = _matchThemeMode(value);
      await prefs.setString(themeModePrefKey, value);
      return themeMode;
    });
  }

  ThemeMode _matchThemeMode(String? savedTheme) {
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'dark':
          return ThemeMode.dark;
        case 'light':
          return ThemeMode.light;
        case 'system':
          return ThemeMode.system;
      }
    }
    return ThemeMode.system;
  }

  String _matchThemeModeToString(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }
}

final spatialBasemapStyleProvider =
    AsyncNotifierProvider<SpatialBasemapStyleSetting, SpatialBasemapStyle>(
      SpatialBasemapStyleSetting.new,
    );

class SpatialBasemapStyleSetting extends AsyncNotifier<SpatialBasemapStyle> {
  @override
  Future<SpatialBasemapStyle> build() async {
    final prefs = ref.watch(settingProvider);
    final saved = prefs.getString(spatialBasemapStylePrefKey);
    final style = SpatialBasemapStyle.values
        .where((candidate) => candidate.name == saved)
        .firstOrNull;
    final resolved = style ?? SpatialBasemapStyle.automatic;
    if (style == null) {
      await prefs.setString(spatialBasemapStylePrefKey, resolved.name);
    }
    return resolved;
  }

  Future<void> setStyle(SpatialBasemapStyle style) async {
    final prefs = ref.read(settingProvider);
    await prefs.setString(spatialBasemapStylePrefKey, style.name);
    state = AsyncValue.data(style);
  }
}

List<String> getDefaultOptionsList(String prefKey) {
  switch (prefKey) {
    case habitatTypePrefKey:
      return defaultHabitatTypes;
    case siteTypePrefKey:
      return defaultSiteTypes;
    case collMethodPrefKey:
      return defaultCollMethods;
    case collRolePrefKey:
      return defaultCollRoles;
    case specimenTypePrefKey:
      return defaultSpecimenType;
    case treatmentPrefKey:
      return defaultTreatment;
    case conditionPrefKey:
      return defaultCondition;
    default:
      return [];
  }
}

final catalogFmtNotifierProvider =
    AsyncNotifierProvider.autoDispose<CatalogFmtNotifier, CatalogFmt>(
      CatalogFmtNotifier.new,
    );

class CatalogFmtNotifier extends AsyncNotifier<CatalogFmt> {
  Future<CatalogFmt> _fetchSetting() async {
    final prefs = ref.watch(settingProvider);
    final savedFmt = prefs.getString(catalogFmtPrefKey);

    // Set to default general mammals if no setting is found
    final CatalogFmt currentFmt = matchTaxonGroupToCatFmt(savedFmt);
    if (savedFmt == null) {
      await prefs.setString(
        catalogFmtPrefKey,
        matchCatFmtToTaxonGroup(currentFmt),
      );
    }

    return currentFmt;
  }

  @override
  FutureOr<CatalogFmt> build() async {
    return await _fetchSetting();
  }

  Future<void> set(CatalogFmt fmt) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      final value = prefs.getString(catalogFmtPrefKey);
      final setFmt = matchTaxonGroupToCatFmt(value);
      if (setFmt == fmt) return fmt;
      await prefs.setString(catalogFmtPrefKey, matchCatFmtToTaxonGroup(fmt));
      return fmt;
    });
  }
}

final userDefinedFieldProvider = AsyncNotifierProvider.family
    .autoDispose<UserDefinedField, List<String>, String>(UserDefinedField.new);

class UserDefinedField extends AsyncNotifier<List<String>> {
  UserDefinedField(this.prefKey);
  final String prefKey;

  Future<List<String>> _fetchSettings() async {
    final optionList = await rust_config.getUserConfigList(key: prefKey);
    List<String> currentOptions = optionList ?? getDefaultOptionsList(prefKey);

    if (optionList == null) {
      await rust_config.setUserConfigList(key: prefKey, value: currentOptions);
    }

    return currentOptions;
  }

  @override
  Future<List<String>> build() async {
    return await _fetchSettings();
  }

  Future<void> add(String newOption) async {
    if (newOption.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final optionList = await rust_config.getUserConfigList(key: prefKey);
      if (optionList != null && isListContains(optionList, newOption)) {
        return optionList;
      }

      List<String> newList = [...optionList ?? [], newOption];
      await rust_config.setUserConfigList(key: prefKey, value: newList);
      return newList;
    });
  }

  Future<void> replaceAll(List<String> newOptions) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await rust_config.setUserConfigList(key: prefKey, value: newOptions);
      return newOptions;
    });
  }

  Future<void> remove(String option) async {
    if (option.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final optionsList = await rust_config.getUserConfigList(key: prefKey);
      if (optionsList == null || optionsList.isEmpty) return [];

      if (!optionsList.contains(option)) return optionsList;

      List<String> newOptions = [...optionsList]..remove(option);
      await rust_config.setUserConfigList(key: prefKey, value: newOptions);
      return newOptions;
    });
  }

  Future<void> clear() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await rust_config.deleteUserConfig(key: prefKey);
      return [];
    });
  }
}

final textCaseFmtNotifierProvider = AsyncNotifierProvider.family
    .autoDispose<TextCaseFmtNotifier, TextCaseFmt, String>(
      TextCaseFmtNotifier.new,
    );

class TextCaseFmtNotifier extends AsyncNotifier<TextCaseFmt> {
  TextCaseFmtNotifier(this.prefKey);
  final String prefKey;

  Future<TextCaseFmt> _fetchSettings() async {
    final fmtString = await rust_config.getUserConfigString(key: prefKey);

    final defaultFormat = prefKey == conditionFmtPrefKey
        ? TextCaseFmt.sentenceCase
        : TextCaseFmt.anyCase;
    TextCaseFmt fmt = TextCaseFmt.values.byName(
      fmtString ?? defaultFormat.name,
    );

    if (fmtString == null) {
      await rust_config.setUserConfigString(key: prefKey, value: fmt.name);
    }

    return fmt;
  }

  @override
  Future<TextCaseFmt> build() async {
    return await _fetchSettings();
  }

  Future<void> set(String prefKey, TextCaseFmt fmt) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final fmtString = await rust_config.getUserConfigString(key: prefKey);
      final defaultFormat = prefKey == conditionFmtPrefKey
          ? TextCaseFmt.sentenceCase
          : TextCaseFmt.anyCase;
      final setFmt = TextCaseFmt.values.byName(fmtString ?? defaultFormat.name);

      if (setFmt == fmt) return fmt;

      await rust_config.setUserConfigString(key: prefKey, value: fmt.name);
      return fmt;
    });
  }
}

final fieldIdModeNotifierProvider =
    AsyncNotifierProvider.autoDispose<FieldIdModeNotifier, FieldIdMode>(
      FieldIdModeNotifier.new,
    );

class FieldIdModeNotifier extends AsyncNotifier<FieldIdMode> {
  Future<FieldIdMode> _fetchSettings() async {
    final fieldIdModeString = await rust_config.getUserConfigString(
      key: fieldIdModePrefKey,
    );

    final fieldIdMode = FieldIdMode.values.byName(
      fieldIdModeString ?? FieldIdMode.personnel.name,
    );
    final prefs = ref.read(settingProvider);
    final defaultMigrated =
        prefs.getBool(fieldIdModeDefaultMigratedPrefKey) ?? false;
    if (!defaultMigrated) {
      await prefs.setBool(fieldIdModeDefaultMigratedPrefKey, true);
      if (fieldIdModeString == null || fieldIdMode == FieldIdMode.project) {
        await rust_config.setUserConfigString(
          key: fieldIdModePrefKey,
          value: FieldIdMode.personnel.name,
        );
        return FieldIdMode.personnel;
      }
    }
    if (fieldIdModeString == null) {
      await rust_config.setUserConfigString(
        key: fieldIdModePrefKey,
        value: FieldIdMode.personnel.name,
      );
    }

    return fieldIdMode;
  }

  @override
  Future<FieldIdMode> build() async {
    return await _fetchSettings();
  }

  Future<void> set(FieldIdMode mode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final fieldIdModeString = await rust_config.getUserConfigString(
        key: fieldIdModePrefKey,
      );
      final setFieldIdMode = FieldIdMode.values.byName(
        fieldIdModeString ?? FieldIdMode.personnel.name,
      );

      if (setFieldIdMode == mode) return mode;

      await rust_config.setUserConfigString(
        key: fieldIdModePrefKey,
        value: mode.name,
      );
      return mode;
    });
  }
}

final projectFieldIdAutoIncrementProvider =
    AsyncNotifierProvider.autoDispose<
      ProjectFieldIdAutoIncrementNotifier,
      bool
    >(ProjectFieldIdAutoIncrementNotifier.new);

class ProjectFieldIdAutoIncrementNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final value = await rust_config.getUserConfigString(
      key: projectFieldIdAutoIncrementPrefKey,
    );
    if (value == null) {
      await rust_config.setUserConfigString(
        key: projectFieldIdAutoIncrementPrefKey,
        value: false.toString(),
      );
      return false;
    }
    return value == true.toString();
  }

  Future<void> set(bool value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await rust_config.setUserConfigString(
        key: projectFieldIdAutoIncrementPrefKey,
        value: value.toString(),
      );
      return value;
    });
  }
}

final exportPresetNotifierProvider =
    AsyncNotifierProvider.autoDispose<
      ExportPresetNotifier,
      Map<String, ExportPresetModel>
    >(ExportPresetNotifier.new);

class ExportPresetNotifier
    extends AsyncNotifier<Map<String, ExportPresetModel>> {
  static const _presetPayloadKey = '__nahpu_record_export_preset_v2__';

  Future<Map<String, ExportPresetModel>> _fetchSettings() async {
    final presets = await rust_config.getAllRecordExportPresets();
    final Map<String, ExportPresetModel> mapped = {};
    final legacyPresetNames = <String>[];
    for (var entry in presets) {
      final preset = _mapConfigToModel(entry.preset);
      if (preset == null) {
        legacyPresetNames.add(entry.name);
      } else {
        mapped[entry.name] = preset;
      }
    }
    // v1 presets do not have the required record type and mapping metadata.
    // Remove them deliberately rather than silently treating them as specimen
    // presets with guessed behavior.
    for (final name in legacyPresetNames) {
      await rust_config.deleteRecordExportPreset(name: name);
    }
    return mapped;
  }

  @override
  Future<Map<String, ExportPresetModel>> build() async {
    return await _fetchSettings();
  }

  Future<void> savePreset(String name, ExportPresetModel preset) async {
    try {
      await rust_config.setRecordExportPreset(
        name: name,
        preset: _mapModelToConfig(preset),
      );
      final current = state.asData?.value ?? await _fetchSettings();
      state = AsyncValue.data({...current, name: preset});
    } on Object catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deletePreset(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await rust_config.deleteRecordExportPreset(name: name);
      return await _fetchSettings();
    });
  }

  /// Renames a preset without risking deletion before its replacement exists.
  ///
  /// redb does not currently expose a transactional rename operation, so write
  /// the replacement first and delete the old key only after that succeeds.
  Future<void> renamePreset(
    String previousName,
    String nextName,
    ExportPresetModel preset,
  ) async {
    if (previousName == nextName) {
      await savePreset(nextName, preset);
      return;
    }

    final current = state.asData?.value ?? await _fetchSettings();
    if (current.containsKey(nextName)) {
      throw StateError('A preset named "$nextName" already exists.');
    }

    try {
      await rust_config.setRecordExportPreset(
        name: nextName,
        preset: _mapModelToConfig(preset),
      );
      await rust_config.deleteRecordExportPreset(name: previousName);
      state = AsyncValue.data(
        {...current}
          ..remove(previousName)
          ..[nextName] = preset,
      );
    } on Object catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  ExportPresetModel? _mapConfigToModel(rust_config.ConfigExportPreset config) {
    final payload = config.fields[_presetPayloadKey];
    if (payload == null) return null;
    try {
      return ExportPresetModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(payload) as Map),
      );
    } on FormatException {
      return null;
    } on Object {
      return null;
    }
  }

  rust_config.ConfigExportPreset _mapModelToConfig(ExportPresetModel model) {
    return rust_config.ConfigExportPreset(
      fields: {_presetPayloadKey: jsonEncode(model.toJson())},
      combinedFields: const [],
    );
  }
}
