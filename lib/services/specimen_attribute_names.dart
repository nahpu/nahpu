/// Canonical specimen-attribute table names keyed by their legacy names.
const Map<String, String> specimenAttributeTableAliases = {
  'mammalMeasurement': 'mammalAttribute',
  'avianMeasurement': 'birdAttribute',
  'herpMeasurement': 'herpAttribute',
};

const Map<String, String> specimenAttributeFieldAliases = {
  'footColor': 'toeColor',
  'footHex': 'toeHex',
};

/// Returns the canonical specimen-attribute table name for [name].
String canonicalizeSpecimenAttributeTableName(String name) =>
    specimenAttributeTableAliases[name] ?? name;

/// Returns the canonical `table::field` form of [sourceKey].
String canonicalizeSpecimenAttributeSourceKey(String sourceKey) {
  final separator = sourceKey.indexOf('::');
  if (separator < 0) {
    return canonicalizeSpecimenAttributeTableName(sourceKey);
  }
  final table = sourceKey.substring(0, separator);
  final field = sourceKey.substring(separator + 2);
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
