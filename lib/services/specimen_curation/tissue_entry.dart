/// A scanned or typed tube entry: the ID, plus the part type and treatment
/// typed after it, if any.
class TissueQuery {
  const TissueQuery(this.id, {this.partType, this.preservation});

  final String id;

  /// The part type typed with the ID, as the vocabulary spells it.
  final String? partType;

  /// The treatment typed with the ID, as the vocabulary spells it.
  final String? preservation;
}

final _separators = RegExp(r'[\s·|,;]+');

/// Splits [text] such as `ABC123 liver etoh` into the ID and the trailing
/// words that name a part type or treatment. Matching ignores case, and
/// multi-word values such as `RNA later` are tried first. The rest of the
/// text, which may hold spaces, is the ID.
TissueQuery parseTissueEntry(
  String text, {
  required List<String> types,
  required List<String> treatments,
}) {
  final tokens = text.split(_separators).where((e) => e.isNotEmpty).toList();
  String? partType;
  String? preservation;
  var matched = true;
  while (matched && tokens.length > 1) {
    matched = false;
    for (var size = tokens.length - 1; size > 0; size--) {
      final phrase = _normalize(tokens.sublist(tokens.length - size).join(' '));
      final type = partType == null ? _find(types, phrase) : null;
      final treatment = type == null && preservation == null
          ? _find(treatments, phrase)
          : null;
      if (type == null && treatment == null) continue;
      partType ??= type;
      preservation ??= treatment;
      tokens.removeRange(tokens.length - size, tokens.length);
      matched = true;
      break;
    }
  }
  return TissueQuery(
    tokens.join(' '),
    partType: partType,
    preservation: preservation,
  );
}

/// Whether [value] matches [filter], ignoring case and spacing. A null or
/// empty filter matches anything.
bool matchesTissueFilter(String? value, String? filter) {
  if (filter == null || filter.trim().isEmpty) return true;
  return _normalize(value ?? '') == _normalize(filter);
}

String? _find(List<String> values, String phrase) {
  for (final value in values) {
    if (_normalize(value) == phrase) return value;
  }
  return null;
}

String _normalize(String text) =>
    text.toLowerCase().split(_separators).where((e) => e.isNotEmpty).join(' ');
