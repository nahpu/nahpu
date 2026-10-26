import 'package:intl/intl.dart';

/// Formats for values NAHPU stores, exports, or migrates.
///
/// Each one is fixed to [locale], so the regional format a user picks changes
/// only what the screen shows, never what NAHPU writes. Display code keeps the
/// default `DateFormat` constructors, which follow the regional format.
abstract final class InvariantFormats {
  static const String locale = 'en_US';

  /// Stored dates, such as `2024-03-18`.
  static DateFormat get date => DateFormat('yyyy-MM-dd', locale);

  /// Stored timestamps, such as `2024-03-18 14:05:00`.
  static DateFormat get timestamp => DateFormat('yyyy-MM-dd HH:mm:ss', locale);

  /// Stored times, such as `14:05:00`.
  static DateFormat get time => DateFormat.Hms(locale);

  /// Dates written by older NAHPU versions, such as `Mar 18, 2024`.
  static DateFormat get legacyDate => DateFormat.yMMMd(locale);

  /// Times written by older NAHPU versions, such as `2:05 PM`.
  static DateFormat get legacyTime12 => DateFormat('h:m a', locale);

  /// Times written by older NAHPU versions, such as `14:05`.
  static DateFormat get legacyTime24 => DateFormat('H:m', locale);
}
