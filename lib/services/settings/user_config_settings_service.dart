import 'package:nahpu/src/rust/api/config.dart' as rust_config;

class UserConfigSettingsService {
  const UserConfigSettingsService();

  Future<List<String>> loadOptions(
    String prefKey,
    List<String> defaultOptions,
  ) async {
    final optionList = await rust_config.getUserConfigList(key: prefKey);
    final currentOptions = optionList ?? defaultOptions;

    if (optionList == null) {
      await rust_config.setUserConfigList(key: prefKey, value: currentOptions);
    }

    return currentOptions;
  }

  Future<void> addOption(String prefKey, String newOption) async {
    if (newOption.isEmpty) return;
    final optionList = await rust_config.getUserConfigList(key: prefKey);
    final containsOption =
        optionList?.any(
          (option) => option.toLowerCase() == newOption.toLowerCase(),
        ) ??
        false;
    if (containsOption) return;

    await rust_config.setUserConfigList(
      key: prefKey,
      value: [...optionList ?? [], newOption],
    );
  }

  Future<void> replaceOptions(String prefKey, List<String> newOptions) {
    return rust_config.setUserConfigList(key: prefKey, value: newOptions);
  }

  Future<void> removeOption(String prefKey, String option) async {
    if (option.isEmpty) return;
    final optionList = await rust_config.getUserConfigList(key: prefKey);
    if (optionList == null || !optionList.contains(option)) return;

    await rust_config.setUserConfigList(
      key: prefKey,
      value: [...optionList]..remove(option),
    );
  }

  Future<void> clearOptions(String prefKey) {
    return rust_config.deleteUserConfig(key: prefKey);
  }

  Future<String> loadTextCaseFormat(
    String prefKey,
    String defaultFormat,
  ) async {
    final format = await rust_config.getUserConfigString(key: prefKey);
    final currentFormat = format ?? defaultFormat;

    if (format == null) {
      await rust_config.setUserConfigString(key: prefKey, value: currentFormat);
    }

    return currentFormat;
  }

  Future<void> setTextCaseFormat(String prefKey, String format) async {
    final currentFormat = await rust_config.getUserConfigString(key: prefKey);
    if (currentFormat == format) return;

    await rust_config.setUserConfigString(key: prefKey, value: format);
  }
}
