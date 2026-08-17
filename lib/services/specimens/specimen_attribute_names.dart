/// Canonical specimen-attribute table names keyed by their legacy names.
const Map<String, String> specimenAttributeTableAliases = {
  'mammalMeasurement': 'mammalAttribute',
  'avianMeasurement': 'birdAttribute',
  'herpMeasurement': 'herpAttribute',
  'weather': 'environment',
};

const Map<String, String> specimenAttributeFieldAliases = {
  'footColor': 'toeColor',
  'footHex': 'toeHex',
};

const Map<String, String> _v19SourceAliases = {
  'arthropodAttribute::canopyCover': 'siteAttribute::canopyCover',
  'arthropodAttribute::ambientTemperature': 'environment::ambientTemperature',
  'arthropodAttribute::ambientHumidity': 'environment::ambientHumidity',
  'arthropodAttribute::waterTemperature': 'environment::waterTemperature',
  'arthropodAttribute::pH': 'environment::pH',
  'arthropodAttribute::dissolvedOxygen': 'environment::dissolvedOxygen',
  'arthropodAttribute::flowVelocity': 'environment::flowVelocity',
};

/// Returns the canonical specimen-attribute table name for [name].
String canonicalizeSpecimenAttributeTableName(String name) =>
    specimenAttributeTableAliases[name] ?? name;

/// Returns the canonical `table::field` form of [sourceKey].
String canonicalizeSpecimenAttributeSourceKey(String sourceKey) {
  final v19Alias = _v19SourceAliases[sourceKey];
  if (v19Alias != null) return v19Alias;
  final separator = sourceKey.indexOf('::');
  if (separator < 0) {
    return canonicalizeSpecimenAttributeTableName(sourceKey);
  }
  final table = sourceKey.substring(0, separator);
  final field = sourceKey.substring(separator + 2);
  if (table == 'site' &&
      const {
        'habitatType',
        'habitatCondition',
        'habitatDescription',
      }.contains(field)) {
    return 'siteAttribute::$field';
  }
  if (const {
        'mammalMeasurement',
        'mammalAttribute',
        'herpMeasurement',
        'herpAttribute',
      }.contains(table) &&
      field == 'age') {
    return '${canonicalizeSpecimenAttributeTableName(table)}::lifeStage';
  }
  return '${canonicalizeSpecimenAttributeTableName(table)}'
      '::${specimenAttributeFieldAliases[field] ?? field}';
}

/// Rewrites legacy specimen-attribute namespaces embedded in [expression].
String canonicalizeSpecimenAttributeExpression(String expression) {
  var canonical = expression;
  for (final entry in specimenAttributeTableAliases.entries) {
    canonical = canonical.replaceAll('${entry.key}::', '${entry.value}::');
  }
  for (final entry in specimenAttributeFieldAliases.entries) {
    canonical = canonical.replaceAll('::${entry.key}', '::${entry.value}');
  }
  canonical = canonical
      .replaceAll('site::habitatType', 'siteAttribute::habitatType')
      .replaceAll('site::habitatCondition', 'siteAttribute::habitatCondition')
      .replaceAll(
        'site::habitatDescription',
        'siteAttribute::habitatDescription',
      )
      .replaceAll('mammalAttribute::age', 'mammalAttribute::lifeStage')
      .replaceAll('herpAttribute::age', 'herpAttribute::lifeStage');
  for (final entry in _v19SourceAliases.entries) {
    canonical = canonical.replaceAll(entry.key, entry.value);
  }
  return canonical;
}

/// Returns the legacy alias for a canonical source key, when one exists.
String? legacySpecimenAttributeSourceKey(String sourceKey) {
  for (final entry in specimenAttributeTableAliases.entries) {
    final prefix = '${entry.value}::';
    if (sourceKey.startsWith(prefix)) {
      return '${entry.key}::${sourceKey.substring(prefix.length)}';
    }
  }
  return null;
}
