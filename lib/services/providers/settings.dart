import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:nahpu/services/types/collecting.dart';
import 'package:nahpu/services/types/sites.dart';
import 'package:nahpu/services/types/export.dart';

const String themeModePrefKey = 'themeMode';
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
const String fieldIdModePrefKey = 'fieldIdMode';
const String exportPresetPrefKey = 'exportPresets';

final settingProvider = Provider<SharedPreferences>((ref) {
  return throw UnimplementedError();
});

final themeSettingProvider =
    AsyncNotifierProvider<ThemeSetting, ThemeMode>(ThemeSetting.new);

class ThemeSetting extends AsyncNotifier<ThemeMode> {
  Future<ThemeMode> _fetchSetting() async {
    final prefs = ref.watch(settingProvider);
    final savedTheme = prefs.getString(themeModePrefKey);

    // Set to default system theme if no setting is found
    final ThemeMode currentTheme = _matchThemeMode(savedTheme);
    if (savedTheme == null) {
      await prefs.setString(
          themeModePrefKey, _matchThemeModeToString(currentTheme));
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
    default:
      return [];
  }
}

final userDefinedFieldProvider = AsyncNotifierProvider.family
    .autoDispose<UserDefinedField, List<String>, String>(UserDefinedField.new);

class UserDefinedField extends AsyncNotifier<List<String>> {
  UserDefinedField(this.prefKey);
  final String prefKey;

  Future<List<String>> _fetchSettings() async {
    final prefs = ref.watch(settingProvider);
    final optionList = prefs.getStringList(prefKey);

    List<String> currentOptions = optionList ?? getDefaultOptionsList(prefKey);

    if (optionList == null) {
      await prefs.setStringList(prefKey, currentOptions);
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
      final prefs = ref.watch(settingProvider);
      final optionList = prefs.getStringList(prefKey);
      if (optionList != null && isListContains(optionList, newOption)) {
        return optionList;
      }

      // Add new type to list or create new list if null
      // and then add a new type to the list
      List<String> newList = [...optionList ?? [], newOption];
      await prefs.setStringList(prefKey, newList);
      return newList;
    });
  }

  Future<void> replaceAll(List<String> newOptions) async {
    if (newOptions.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      await prefs.setStringList(prefKey, newOptions);
      return newOptions;
    });
  }

  Future<void> remove(String option) async {
    if (option.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      final optionsList = prefs.getStringList(prefKey);
      if (optionsList == null || optionsList.isEmpty) return [];

      // Remove type from list
      if (!optionsList.contains(option)) return optionsList;

      List<String> newOptions = [...optionsList]..remove(option);
      await prefs.setStringList(prefKey, newOptions);
      return newOptions;
    });
  }

  Future<void> clear() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      await prefs.remove(prefKey);
      return [];
    });
  }
}

final textCaseFmtNotifierProvider = AsyncNotifierProvider.family
    .autoDispose<TextCaseFmtNotifier, TextCaseFmt, String>(
        TextCaseFmtNotifier.new);

class TextCaseFmtNotifier extends AsyncNotifier<TextCaseFmt> {
  TextCaseFmtNotifier(this.prefKey);
  final String prefKey;

  Future<TextCaseFmt> _fetchSettings() async {
    final prefs = ref.watch(settingProvider);
    final fmtString = prefs.getString(prefKey);

    TextCaseFmt fmt =
        TextCaseFmt.values.byName(fmtString ?? TextCaseFmt.anyCase.name);

    if (fmtString == null) {
      await prefs.setString(prefKey, fmt.name);
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
      final prefs = ref.watch(settingProvider);
      final fmtString = prefs.getString(prefKey);
      final setFmt =
          TextCaseFmt.values.byName(fmtString ?? TextCaseFmt.anyCase.name);

      if (setFmt == fmt) return fmt;

      await prefs.setString(prefKey, fmt.name);
      return fmt;
    });
  }
}

final fieldIdModeNotifierProvider =
    AsyncNotifierProvider.autoDispose<FieldIdModeNotifier, FieldIdMode>(
        FieldIdModeNotifier.new);

class FieldIdModeNotifier extends AsyncNotifier<FieldIdMode> {
  Future<FieldIdMode> _fetchSettings() async {
    final prefs = ref.watch(settingProvider);
    final fieldIdModeString = prefs.getString(fieldIdModePrefKey);

    FieldIdMode fieldIdMode = FieldIdMode.values
        .byName(fieldIdModeString ?? FieldIdMode.personnel.name);

    if (fieldIdModeString == null) {
      await prefs.setString(fieldIdModePrefKey, fieldIdMode.name);
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
      final prefs = ref.watch(settingProvider);
      final fieldIdModeString = prefs.getString(fieldIdModePrefKey);
      final setFieldIdMode = FieldIdMode.values
          .byName(fieldIdModeString ?? FieldIdMode.personnel.name);

      if (setFieldIdMode == mode) return mode;

      await prefs.setString(fieldIdModePrefKey, mode.name);
      return mode;
    });
  }
}

final exportPresetNotifierProvider = AsyncNotifierProvider.autoDispose<
    ExportPresetNotifier,
    Map<String, ExportPresetModel>>(ExportPresetNotifier.new);

class ExportPresetNotifier
    extends AsyncNotifier<Map<String, ExportPresetModel>> {
  Future<Map<String, ExportPresetModel>> _fetchSettings() async {
    final prefs = ref.watch(settingProvider);
    final presetString = prefs.getString(exportPresetPrefKey);
    if (presetString == null) {
      return {};
    }
    try {
      final decoded = jsonDecode(presetString) as Map<String, dynamic>;
      final Map<String, ExportPresetModel> mapped = {};
      for (var entry in decoded.entries) {
        if (entry.value is Map<String, dynamic> &&
            (entry.value as Map<String, dynamic>).containsKey('fields')) {
          // Version 2 format
          mapped[entry.key] =
              ExportPresetModel.fromJson(entry.value as Map<String, dynamic>);
        } else {
          // Version 1 format (legacy)
          mapped[entry.key] = ExportPresetModel(
            fields: Map<String, String>.from(entry.value as Map),
            combinedFields: [],
          );
        }
      }
      return mapped;
    } catch (e) {
      return {};
    }
  }

  @override
  Future<Map<String, ExportPresetModel>> build() async {
    return await _fetchSettings();
  }

  Future<void> savePreset(String name, ExportPresetModel preset) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final current = await _fetchSettings();
      current[name] = preset;
      final prefs = ref.watch(settingProvider);
      await prefs.setString(exportPresetPrefKey, jsonEncode(current));
      return current;
    });
  }

  Future<void> deletePreset(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final current = await _fetchSettings();
      current.remove(name);
      final prefs = ref.watch(settingProvider);
      await prefs.setString(exportPresetPrefKey, jsonEncode(current));
      return current;
    });
  }
}
