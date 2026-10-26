import 'dart:ui' show Locale;

/// A language NAHPU ships, for both UI labels and bundled documentation.
///
/// [code] names the ARB file under `lib/l10n/` and the documentation folders
/// under `assets/docs/`, so a new language needs all three.
enum AppLanguage {
  english('en', null, 'English', 'EN'),
  portuguese('pt', 'BR', 'Português', 'BR'),
  spanish('es', null, 'Español', 'ES'),
  indonesian('id', null, 'Bahasa Indonesia', 'ID');

  const AppLanguage(
    this.code,
    this.countryCode,
    this.nativeLabel,
    this.shortLabel,
  );

  final String code;

  /// The country of the variant NAHPU translates into, such as Brazil for
  /// Portuguese. Null when the translation is not regional.
  final String? countryCode;

  final String nativeLabel;

  /// Two-letter label shown on the compact language chips.
  final String shortLabel;

  Locale get locale => Locale(code, countryCode);

  /// The intl locale for dates and numbers when the regional format follows
  /// the language.
  String get formatLocale =>
      countryCode == null ? code : '${code}_$countryCode';

  /// Whether the UI translation is still in beta. English is the source
  /// language, so only the translations carry the label.
  bool get isBeta => this != english;

  /// The language saved under [code], or null for an unknown or missing code.
  static AppLanguage? tryParse(String? code) {
    for (final language in values) {
      if (language.code == code) return language;
    }
    return null;
  }

  /// The first of [preferred] that NAHPU ships, or English.
  static AppLanguage resolve(Iterable<Locale> preferred) {
    for (final locale in preferred) {
      final language = tryParse(locale.languageCode);
      if (language != null) return language;
    }
    return english;
  }
}
