/// The parts of an auto-numbered ID, such as `FT-` + `0004` + `-A`.
///
/// Shared by tissue IDs and individual tag IDs.
class NumberedIdFormat {
  const NumberedIdFormat({
    this.prefix = '',
    this.number = '',
    this.suffix = '',
  });

  final String prefix;

  /// Digits of the next number. Its length sets the zero padding.
  final String number;
  final String suffix;

  /// The next ID, or null when no number is set.
  String? get nextTag {
    if (number.isEmpty) return null;
    return '$prefix$number$suffix';
  }

  /// [number] plus one, keeping its zero padding, so `0009` becomes `0010`.
  /// Returns null when [number] is not a whole number.
  String? get incrementedNumber {
    final value = int.tryParse(number);
    if (value == null || value < 0) return null;
    return (value + 1).toString().padLeft(number.length, '0');
  }
}

/// Where an auto-numbered ID keeps its prefix, next number, and suffix.
abstract interface class NumberedIdStore {
  NumberedIdFormat get format;

  Future<void> setPrefix(String prefix);

  /// Stores only the digits of [number].
  Future<void> setNumber(String number);

  Future<void> setSuffix(String suffix);
}

/// Keeps the digits of [number], so the counter can always advance.
String numberedIdDigits(String number) =>
    number.replaceAll(RegExp(r'[^0-9]'), '');
