const List<String> defaultCollMethods = [
  'Hands',
  'Mist net',
  'Sweep net',
  'Snap trap',
  'Cage trap',
  'Pitfall',
  'Malaise trap',
  'Light trap',
  'Beating sheet',
  'Aspirator',
  'Local snare',
  'Pellet gun',
  'Other',
];

const List<String> defaultCollActivities = [
  'Collecting',
  'Recording',
  'Observing',
];

const List<String> defaultCollRoles = ['Leader', 'Helper'];

const List<String> environmentalDataFields = [
  'lowestDayTempC',
  'highestDayTempC',
  'lowestNightTempC',
  'highestNightTempC',
  'averageHumidity',
  'dewPointTemp',
  'cloudCover',
  'rainfallInMm',
  'ambientTemperature',
  'ambientHumidity',
  'waterTemperature',
  'pH',
  'dissolvedOxygen',
  'dissolvedOxygenPercent',
  'conductivity',
  'flowVelocity',
  'sunriseTime',
  'sunsetTime',
  'moonPhase',
  'notes',
];

const List<String> defaultVisibleEnvironmentalDataFields = [
  'ambientTemperature',
  'ambientHumidity',
  'cloudCover',
  'rainfallInMm',
  'notes',
];

const Map<String, String> environmentalDataFieldLabels = {
  'lowestDayTempC': 'Day lowest temperature',
  'highestDayTempC': 'Day highest temperature',
  'lowestNightTempC': 'Night lowest temperature',
  'highestNightTempC': 'Night highest temperature',
  'averageHumidity': 'Average humidity',
  'dewPointTemp': 'Dew point',
  'cloudCover': 'Cloud cover',
  'rainfallInMm': 'Rainfall',
  'ambientTemperature': 'Ambient temperature',
  'ambientHumidity': 'Ambient humidity',
  'waterTemperature': 'Water temperature',
  'pH': 'pH',
  'dissolvedOxygen': 'Dissolved oxygen',
  'dissolvedOxygenPercent': 'Dissolved oxygen saturation',
  'conductivity': 'Conductivity',
  'flowVelocity': 'Flow velocity',
  'sunriseTime': 'Sunrise',
  'sunsetTime': 'Sunset',
  'moonPhase': 'Moon phase',
  'notes': 'Notes',
};

/// Units for environmental measurement fields. Fields without a measurement
/// unit, such as pH, sunrise, moon phase, and notes, are absent.
///
/// The single source for the units shown in settings, on the event form, and
/// in Darwin Core event assertions.
const Map<String, String> environmentalDataFieldUnits = {
  'lowestDayTempC': '°C',
  'highestDayTempC': '°C',
  'lowestNightTempC': '°C',
  'highestNightTempC': '°C',
  'averageHumidity': '%',
  'dewPointTemp': '°C',
  'cloudCover': 'okta',
  'rainfallInMm': 'mm',
  'ambientTemperature': '°C',
  'ambientHumidity': '%',
  'waterTemperature': '°C',
  'dissolvedOxygen': 'mg/L',
  'dissolvedOxygenPercent': '%',
  'conductivity': 'µS/cm',
  'flowVelocity': 'm/s',
};

/// Returns the field label followed by its unit, such as
/// `Conductivity (µS/cm)`, or the plain label when the field has no unit.
String environmentalDataFieldLabelWithUnit(String field) {
  final label = environmentalDataFieldLabels[field] ?? field;
  final unit = environmentalDataFieldUnits[field];
  return unit == null ? label : '$label ($unit)';
}

const List<String> environmentMoonPhaseOptions = [
  'New Moon',
  'Waxing Crescent',
  'First Quarter',
  'Waxing Gibbous',
  'Full Moon',
  'Waning Gibbous',
  'Last Quarter',
  'Waning Crescent',
];

/// Environmental fields stored as numbers.
const Set<String> environmentalNumericFields = {
  'lowestDayTempC',
  'highestDayTempC',
  'lowestNightTempC',
  'highestNightTempC',
  'averageHumidity',
  'dewPointTemp',
  'rainfallInMm',
  'ambientTemperature',
  'ambientHumidity',
  'waterTemperature',
  'pH',
  'dissolvedOxygen',
  'dissolvedOxygenPercent',
  'conductivity',
  'flowVelocity',
};

const Set<String> _environmentTextFields = {
  'sunriseTime',
  'sunsetTime',
  'moonPhase',
  'cloudCover',
  'notes',
};

const Set<String> _cloudCoverOptions = {
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
};

/// Raw environmental values prepared for an editable form.
///
/// SQLite can retain values whose storage type does not match a column's
/// declared affinity. Keeping those raw values here lets the editor show and
/// repair one malformed field without losing the rest of the record.
class EditableEnvironmentData {
  EditableEnvironmentData._({
    required Map<String, Object?> values,
    required Map<String, String> fieldErrors,
  }) : values = Map.unmodifiable(values),
       fieldErrors = Map.unmodifiable(fieldErrors);

  factory EditableEnvironmentData.fromRaw(Map<String, Object?> raw) {
    final values = <String, Object?>{
      for (final field in environmentalDataFields) field: raw[field],
    };
    final errors = <String, String>{};

    for (final field in environmentalNumericFields) {
      final value = values[field];
      if (value == null) continue;
      if (value is! num || !value.toDouble().isFinite) {
        errors[field] =
            'Stored value is not a finite number. Enter a valid number.';
      }
    }
    for (final field in _environmentTextFields) {
      final value = values[field];
      if (value != null && value is! String) {
        errors[field] = 'Stored value must be text. Enter a valid value.';
      }
    }

    _validateRange(values, errors, 'averageHumidity', 0, 100);
    _validateRange(values, errors, 'ambientHumidity', 0, 100);
    _validateRange(values, errors, 'pH', 0, 14);
    _validateRange(values, errors, 'dissolvedOxygenPercent', 0, 500);
    _validateRange(values, errors, 'conductivity', 0, double.maxFinite);

    final cloudCover = values['cloudCover'];
    if (cloudCover is String && !_cloudCoverOptions.contains(cloudCover)) {
      errors['cloudCover'] = 'Select a cloud cover value from 0 to 9.';
    }
    final moonPhase = values['moonPhase'];
    if (moonPhase is String &&
        !environmentMoonPhaseOptions.contains(moonPhase)) {
      errors['moonPhase'] = 'Select a supported moon phase.';
    }

    return EditableEnvironmentData._(values: values, fieldErrors: errors);
  }

  final Map<String, Object?> values;
  final Map<String, String> fieldErrors;

  Object? value(String field) => values[field];

  String displayValue(String field) => values[field]?.toString() ?? '';

  static void _validateRange(
    Map<String, Object?> values,
    Map<String, String> errors,
    String field,
    num minimum,
    num maximum,
  ) {
    final value = values[field];
    if (value is num &&
        value.toDouble().isFinite &&
        (value < minimum || value > maximum)) {
      errors[field] = maximum == double.maxFinite
          ? 'Enter a value of $minimum or more'
          : 'Enter a value from $minimum to $maximum';
    }
  }
}

/// Icon vocabulary for collecting methods.
///
/// This exists only to pick an SVG for a collection method row. Methods themselves stay
/// free text, so [CollMethodIcon.fromMethod] matches case-insensitively on
/// substrings rather than on exact values.
enum CollMethodIcon {
  mistNet,
  sweepNet,
  malaiseTrap,
  lightTrap,
  beatingSheet,
  aspirator,
  localSnare,
  pitfall,
  hands,
  snapTrap,
  cageTrap,
  gun,
  other;

  /// Resolves [method] to an icon, falling back to [CollMethodIcon.other] for
  /// unknown values and null.
  ///
  /// Specific traps and nets are matched before the generic `trap` and `net`
  /// keywords so that, for example, `Snap trap` does not resolve to
  /// [CollMethodIcon.other] and `Sweep net` does not resolve to
  /// [CollMethodIcon.mistNet].
  factory CollMethodIcon.fromMethod(String? method) {
    final name = method?.toLowerCase().trim() ?? '';
    if (name.contains('snap')) {
      return CollMethodIcon.snapTrap;
    } else if (name.contains('cage') ||
        name.contains('box trap') ||
        name.contains('live trap')) {
      return CollMethodIcon.cageTrap;
    } else if (name.contains('malaise') || name.contains('intercept')) {
      return CollMethodIcon.malaiseTrap;
    } else if (name.contains('light') ||
        name.contains('uv') ||
        name.contains('lamp')) {
      return CollMethodIcon.lightTrap;
    } else if (name.contains('beat')) {
      return CollMethodIcon.beatingSheet;
    } else if (name.contains('aspirator') || name.contains('pooter')) {
      return CollMethodIcon.aspirator;
    } else if (name.contains('sweep') ||
        name.contains('aerial') ||
        name.contains('insect net') ||
        name.contains('butterfly')) {
      return CollMethodIcon.sweepNet;
    } else if (name.contains('pitfall') ||
        name.contains('bucket') ||
        name.contains('pan trap') ||
        name.contains('bowl')) {
      return CollMethodIcon.pitfall;
    } else if (name.contains('net')) {
      return CollMethodIcon.mistNet;
    } else if (name.contains('snare') || name.contains('noose')) {
      return CollMethodIcon.localSnare;
    } else if (name.contains('gun') ||
        name.contains('rifle') ||
        name.contains('shotgun') ||
        name.contains('pellet') ||
        name.contains('air')) {
      return CollMethodIcon.gun;
    } else if (name.contains('hand')) {
      return CollMethodIcon.hands;
    }
    return CollMethodIcon.other;
  }

  String get iconPath => switch (this) {
    CollMethodIcon.mistNet => 'assets/icons/mist_net.svg',
    CollMethodIcon.sweepNet => 'assets/icons/sweep_net.svg',
    CollMethodIcon.malaiseTrap => 'assets/icons/malaise_trap.svg',
    CollMethodIcon.lightTrap => 'assets/icons/light_trap.svg',
    CollMethodIcon.beatingSheet => 'assets/icons/beating_sheet.svg',
    CollMethodIcon.aspirator => 'assets/icons/aspirator.svg',
    CollMethodIcon.localSnare => 'assets/icons/snare.svg',
    CollMethodIcon.pitfall => 'assets/icons/pitfall.svg',
    CollMethodIcon.hands => 'assets/icons/hand.svg',
    CollMethodIcon.snapTrap => 'assets/icons/snap_trap.svg',
    CollMethodIcon.cageTrap => 'assets/icons/cage_trap.svg',
    CollMethodIcon.gun => 'assets/icons/gun.svg',
    CollMethodIcon.other => 'assets/icons/trap.svg',
  };
}
