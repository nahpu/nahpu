import 'dart:convert';

import 'package:nahpu/services/specimen_check/tissue_box.dart';

/// The specimen part field a tissue check writes.
enum TissueCheckField {
  museumPermanent('Museum permanent'),
  museumLoan('Museum loan');

  const TissueCheckField(this.label);

  final String label;
}

/// The tissue check setup, kept on this device between sessions.
class TissueCheckSettings {
  const TissueCheckSettings({
    this.field = TissueCheckField.museumPermanent,
    this.value = '',
    this.layout = const TissueBoxLayout(),
    this.boxLabel = 'Box',
    this.boxNumber = 1,
    this.overwrite = false,
  });

  final TissueCheckField field;
  final String value;
  final TissueBoxLayout layout;
  final String boxLabel;
  final int boxNumber;
  final bool overwrite;

  String get boxName => formatTissueBoxName(boxLabel, boxNumber);

  TissueCheckSettings copyWith({
    TissueCheckField? field,
    String? value,
    TissueBoxLayout? layout,
    String? boxLabel,
    int? boxNumber,
    bool? overwrite,
  }) {
    return TissueCheckSettings(
      field: field ?? this.field,
      value: value ?? this.value,
      layout: layout ?? this.layout,
      boxLabel: boxLabel ?? this.boxLabel,
      boxNumber: boxNumber ?? this.boxNumber,
      overwrite: overwrite ?? this.overwrite,
    );
  }

  String encode() => jsonEncode({
    'field': field.name,
    'value': value,
    'size': layout.size.name,
    'numbering': layout.numbering.name,
    'fillOrder': layout.fillOrder.name,
    'boxLabel': boxLabel,
    'boxNumber': boxNumber,
    'overwrite': overwrite,
  });

  /// Reads [encoded], falling back to defaults for missing or unknown values.
  static TissueCheckSettings decode(String? encoded) {
    const defaults = TissueCheckSettings();
    if (encoded == null) return defaults;
    try {
      final json = jsonDecode(encoded);
      if (json is! Map<String, dynamic>) return defaults;
      final boxNumber = json['boxNumber'];
      return TissueCheckSettings(
        field: _byName(TissueCheckField.values, json['field'], defaults.field),
        value: json['value'] is String ? json['value'] as String : '',
        layout: TissueBoxLayout(
          size: _byName(
            TissueBoxSize.values,
            json['size'],
            defaults.layout.size,
          ),
          numbering: _byName(
            TissueCellNumbering.values,
            json['numbering'],
            defaults.layout.numbering,
          ),
          fillOrder: _byName(
            TissueFillOrder.values,
            json['fillOrder'],
            defaults.layout.fillOrder,
          ),
        ),
        boxLabel: json['boxLabel'] is String
            ? json['boxLabel'] as String
            : defaults.boxLabel,
        boxNumber: boxNumber is int && boxNumber > 0 ? boxNumber : 1,
        overwrite: json['overwrite'] == true,
      );
    } on FormatException {
      return defaults;
    }
  }

  static T _byName<T extends Enum>(List<T> values, Object? name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
