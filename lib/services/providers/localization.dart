import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/localization/app_language.dart';
import 'package:nahpu/services/localization/regional_format.dart';
import 'package:nahpu/services/providers/settings.dart';

/// The device's preferred locales, in order. Overridden in tests.
final deviceLocalesProvider = Provider<List<Locale>>(
  (ref) => PlatformDispatcher.instance.locales,
);

/// The UI language the user picked on this device. Null follows the device.
final appLanguageSettingProvider =
    NotifierProvider<AppLanguageSettingNotifier, AppLanguage?>(
      AppLanguageSettingNotifier.new,
    );

class AppLanguageSettingNotifier extends Notifier<AppLanguage?> {
  @override
  AppLanguage? build() => AppLanguage.tryParse(
    ref.watch(settingProvider).getString(appLanguagePrefKey),
  );

  Future<void> set(AppLanguage? language) async {
    state = language;
    final prefs = ref.read(settingProvider);
    if (language == null) {
      await prefs.remove(appLanguagePrefKey);
    } else {
      await prefs.setString(appLanguagePrefKey, language.code);
    }
  }
}

/// The language labels and documentation open in.
final appLanguageProvider = Provider<AppLanguage>((ref) {
  return ref.watch(appLanguageSettingProvider) ??
      AppLanguage.resolve(ref.watch(deviceLocalesProvider));
});

/// The regional format the user picked on this device. Null matches the
/// UI language.
final regionalFormatSettingProvider =
    NotifierProvider<RegionalFormatSettingNotifier, RegionalFormat?>(
      RegionalFormatSettingNotifier.new,
    );

class RegionalFormatSettingNotifier extends Notifier<RegionalFormat?> {
  @override
  RegionalFormat? build() => RegionalFormat.tryParse(
    ref.watch(settingProvider).getString(regionalFormatPrefKey),
  );

  Future<void> set(RegionalFormat? format) async {
    state = format;
    final prefs = ref.read(settingProvider);
    if (format == null) {
      await prefs.remove(regionalFormatPrefKey);
    } else {
      await prefs.setString(regionalFormatPrefKey, format.tag);
    }
  }
}

/// The intl locale for dates and numbers on screen.
final formatLocaleProvider = Provider<String>((ref) {
  return ref.watch(regionalFormatSettingProvider)?.tag ??
      ref.watch(appLanguageProvider).formatLocale;
});

/// The locale the app runs in.
///
/// Labels come from the language alone. When the regional format shares that
/// language, its country joins the locale, so Material's own date pickers
/// follow the region too, such as English (United Kingdom) dates.
final appLocaleProvider = Provider<Locale>((ref) {
  final language = ref.watch(appLanguageProvider);
  final format = ref.watch(regionalFormatSettingProvider);
  if (format != null && format.languageCode == language.code) {
    return format.locale;
  }
  return language.locale;
});
