import 'dart:ui' show Locale;

import 'package:intl/intl.dart';

/// A regional format for dates and numbers on screen, chosen apart from the
/// UI language so a reader can, say, keep English labels with Indonesian dates.
///
/// Only display follows it. Stored and exported values use
/// `InvariantFormats`.
class RegionalFormat {
  const RegionalFormat(this.tag, this.nativeLabel);

  /// The intl locale, such as `en_GB`.
  final String tag;

  /// The region's own name for itself, shown in the picker.
  final String nativeLabel;

  String get languageCode => tag.split('_').first;

  String? get countryCode {
    final parts = tag.split('_');
    return parts.length > 1 ? parts.last : null;
  }

  Locale get locale => Locale(languageCode, countryCode);

  /// The formats offered in settings. Every one writes Latin digits, so a
  /// displayed number still reads the same as the stored one.
  static const List<RegionalFormat> all = [
    RegionalFormat('en_US', 'English (United States)'),
    RegionalFormat('en_GB', 'English (United Kingdom)'),
    RegionalFormat('en_AU', 'English (Australia)'),
    RegionalFormat('en_CA', 'English (Canada)'),
    RegionalFormat('en_IN', 'English (India)'),
    RegionalFormat('en_ZA', 'English (South Africa)'),
    RegionalFormat('pt_BR', 'Português (Brasil)'),
    RegionalFormat('pt_PT', 'Português (Portugal)'),
    RegionalFormat('es_ES', 'Español (España)'),
    RegionalFormat('es_MX', 'Español (México)'),
    RegionalFormat('es_US', 'Español (Estados Unidos)'),
    RegionalFormat('es_419', 'Español (Latinoamérica)'),
    RegionalFormat('id_ID', 'Bahasa Indonesia (Indonesia)'),
    RegionalFormat('ms_MY', 'Bahasa Melayu (Malaysia)'),
    RegionalFormat('fil_PH', 'Filipino (Pilipinas)'),
    RegionalFormat('vi_VN', 'Tiếng Việt (Việt Nam)'),
    RegionalFormat('fr_FR', 'Français (France)'),
    RegionalFormat('fr_CA', 'Français (Canada)'),
    RegionalFormat('de_DE', 'Deutsch (Deutschland)'),
    RegionalFormat('nl_NL', 'Nederlands (Nederland)'),
    RegionalFormat('it_IT', 'Italiano (Italia)'),
    RegionalFormat('sw_KE', 'Kiswahili (Kenya)'),
  ];

  /// The offered format saved under [tag], or null for "match language".
  static RegionalFormat? tryParse(String? tag) {
    for (final format in all) {
      if (format.tag == tag) return format;
    }
    return null;
  }
}

/// A sample date and number in the [formatLocale], so a reader can compare
/// formats before choosing one.
({String date, String number}) regionalFormatSample(
  String formatLocale,
  DateTime date,
) {
  return (
    date: DateFormat.yMMMd(formatLocale).format(date),
    number: NumberFormat.decimalPattern(formatLocale).format(1234.5),
  );
}
