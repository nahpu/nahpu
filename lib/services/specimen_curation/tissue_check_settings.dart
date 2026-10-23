import 'dart:convert';

import 'package:nahpu/services/specimen_curation/tissue_box.dart';

/// The specimen part field a tissue check writes.
enum TissueCheckField {
  museumPermanent('Museum permanent'),
  museumLoan('Museum loan');

  const TissueCheckField(this.label);

  final String label;
}

/// How a scanned or typed code finds a specimen part.
enum TissueIdentifyBy {
  tissueId('Tissue ID or barcode'),
  fieldId('Field ID');

  const TissueIdentifyBy(this.label);

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
    this.identifyBy = TissueIdentifyBy.tissueId,
    this.partType,
    this.preservation,
  });

  final TissueCheckField field;
  final String value;
  final TissueBoxLayout layout;
  final String boxLabel;
  final int boxNumber;
  final bool overwrite;
  final TissueIdentifyBy identifyBy;

  /// The part type to match, such as Liver. Null matches any type.
  final String? partType;

  /// The treatment to match, such as ETOH. Null matches any treatment.
  final String? preservation;

  String get boxName => formatTissueBoxName(boxLabel, boxNumber);

  TissueCheckSettings copyWith({
    TissueCheckField? field,
    String? value,
    TissueBoxLayout? layout,
    String? boxLabel,
    int? boxNumber,
    bool? overwrite,
    TissueIdentifyBy? identifyBy,
    String? Function()? partType,
    String? Function()? preservation,
  }) {
    return TissueCheckSettings(
      field: field ?? this.field,
      value: value ?? this.value,
      layout: layout ?? this.layout,
      boxLabel: boxLabel ?? this.boxLabel,
      boxNumber: boxNumber ?? this.boxNumber,
      overwrite: overwrite ?? this.overwrite,
      identifyBy: identifyBy ?? this.identifyBy,
      partType: partType == null ? this.partType : partType(),
      preservation: preservation == null ? this.preservation : preservation(),
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
    'identifyBy': identifyBy.name,
    'partType': partType,
    'preservation': preservation,
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
        identifyBy: _byName(
          TissueIdentifyBy.values,
          json['identifyBy'],
          defaults.identifyBy,
        ),
        partType: _optionalText(json['partType']),
        preservation: _optionalText(json['preservation']),
      );
    } on FormatException {
      return defaults;
    }
  }

  static String? _optionalText(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  static T _byName<T extends Enum>(List<T> values, Object? name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
