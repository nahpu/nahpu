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
    this.partTypes = const {},
    this.preservations = const {},
    this.includeParasites = false,
    this.parasiteCategories = const {},
    this.customLabels = false,
  });

  final TissueCheckField field;
  final String value;

  /// The box as configured, including a custom numbering and label format
  /// that apply only while [customLabels] is on. Use [effectiveLayout] to
  /// fill and read boxes.
  final TissueBoxLayout layout;
  final String boxLabel;
  final int boxNumber;
  final bool overwrite;
  final TissueIdentifyBy identifyBy;

  /// The part types to match, such as Liver. Empty matches any type.
  /// Parasites have no part type, so this never excludes them.
  final Set<String> partTypes;

  /// The treatments to match, such as ETOH. Empty matches any treatment.
  final Set<String> preservations;

  /// Whether scans and the work list also find parasites.
  final bool includeParasites;

  /// The parasite categories to match, such as Ectoparasite. Empty matches
  /// any category.
  final Set<String> parasiteCategories;

  /// Whether cell labels use the numbering and format in [layout] instead
  /// of the standard `Box 1: A1`.
  final bool customLabels;

  String get boxName => formatTissueBoxName(boxLabel, boxNumber);

  /// The layout boxes are filled and read with: [layout] as configured with
  /// [customLabels] on, or with standard `A1` labels with it off. Turning
  /// the toggle off keeps the custom values for when it is turned back on.
  TissueBoxLayout get effectiveLayout => customLabels
      ? layout
      : layout.copyWith(
          numbering: TissueCellNumbering.alphanumeric,
          labelFormat: const TissueLabelFormat.standard(),
        );

  TissueCheckSettings copyWith({
    TissueCheckField? field,
    String? value,
    TissueBoxLayout? layout,
    String? boxLabel,
    int? boxNumber,
    bool? overwrite,
    TissueIdentifyBy? identifyBy,
    Set<String>? partTypes,
    Set<String>? preservations,
    bool? includeParasites,
    Set<String>? parasiteCategories,
    bool? customLabels,
  }) {
    return TissueCheckSettings(
      field: field ?? this.field,
      value: value ?? this.value,
      layout: layout ?? this.layout,
      boxLabel: boxLabel ?? this.boxLabel,
      boxNumber: boxNumber ?? this.boxNumber,
      overwrite: overwrite ?? this.overwrite,
      identifyBy: identifyBy ?? this.identifyBy,
      partTypes: partTypes ?? this.partTypes,
      preservations: preservations ?? this.preservations,
      includeParasites: includeParasites ?? this.includeParasites,
      parasiteCategories: parasiteCategories ?? this.parasiteCategories,
      customLabels: customLabels ?? this.customLabels,
    );
  }

  String encode() => jsonEncode({
    'field': field.name,
    'value': value,
    'size': layout.size.name,
    'numbering': layout.numbering.name,
    'fillOrder': layout.fillOrder.name,
    'customLabels': customLabels,
    'boxSeparator': layout.labelFormat.boxSeparator,
    'rowColumnSeparator': layout.labelFormat.rowColumnSeparator,
    'zeroPad': layout.labelFormat.zeroPad,
    'boxLabel': boxLabel,
    'boxNumber': boxNumber,
    'overwrite': overwrite,
    'identifyBy': identifyBy.name,
    'partTypes': partTypes.toList(),
    'preservations': preservations.toList(),
    'includeParasites': includeParasites,
    'parasiteCategories': parasiteCategories.toList(),
  });

  /// Reads [encoded], falling back to defaults for missing or unknown values.
  static TissueCheckSettings decode(String? encoded) {
    const defaults = TissueCheckSettings();
    if (encoded == null) return defaults;
    try {
      final json = jsonDecode(encoded);
      if (json is! Map<String, dynamic>) return defaults;
      final boxNumber = json['boxNumber'];
      final numbering = _byName(
        TissueCellNumbering.values,
        json['numbering'],
        defaults.layout.numbering,
      );
      const standard = TissueLabelFormat.standard();
      final customLabels = json['customLabels'];
      return TissueCheckSettings(
        // Setups saved before the toggle keep a numbering they chose.
        customLabels: customLabels is bool
            ? customLabels
            : numbering != TissueCellNumbering.alphanumeric,
        field: _byName(TissueCheckField.values, json['field'], defaults.field),
        value: json['value'] is String ? json['value'] as String : '',
        layout: TissueBoxLayout(
          size: _byName(
            TissueBoxSize.values,
            json['size'],
            defaults.layout.size,
          ),
          numbering: numbering,
          fillOrder: _byName(
            TissueFillOrder.values,
            json['fillOrder'],
            defaults.layout.fillOrder,
          ),
          labelFormat: TissueLabelFormat(
            boxSeparator: json['boxSeparator'] is String
                ? json['boxSeparator'] as String
                : standard.boxSeparator,
            rowColumnSeparator: json['rowColumnSeparator'] is String
                ? json['rowColumnSeparator'] as String
                : standard.rowColumnSeparator,
            zeroPad: json['zeroPad'] == true,
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
        partTypes: _textSet(json['partTypes'], legacy: json['partType']),
        preservations: _textSet(
          json['preservations'],
          legacy: json['preservation'],
        ),
        includeParasites: json['includeParasites'] == true,
        parasiteCategories: _textSet(json['parasiteCategories']),
      );
    } on FormatException {
      return defaults;
    }
  }

  /// Reads a list of values, or the single value older setups saved.
  static Set<String> _textSet(Object? values, {Object? legacy}) {
    final items = values is List ? values : [legacy];
    return {
      for (final item in items)
        if (item is String && item.trim().isNotEmpty) item.trim(),
    };
  }

  static T _byName<T extends Enum>(List<T> values, Object? name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
