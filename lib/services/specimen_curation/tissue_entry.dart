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

/// Whether [value] matches any of [filters]. An empty set matches anything.
bool matchesAnyTissueFilter(String? value, Set<String> filters) {
  if (filters.isEmpty) return true;
  return filters.any((filter) => matchesTissueFilter(value, filter));
}

String? _find(List<String> values, String phrase) {
  for (final value in values) {
    if (_normalize(value) == phrase) return value;
  }
  return null;
}

String _normalize(String text) =>
    text.toLowerCase().split(_separators).where((e) => e.isNotEmpty).join(' ');

/// The [codes] that contain [text], ignoring case, spaces, and
/// punctuation, with those that start with it first. At most [limit]. None
/// for blank text, or when the only match is the text itself, so a finished
/// code shows no suggestions.
List<String> suggestTissueCodes(
  List<String> codes,
  String text, {
  int limit = 8,
}) {
  final query = _compact(text);
  if (query.isEmpty) return const [];
  final starts = <String>[];
  final contains = <String>[];
  for (final code in codes) {
    final compact = _compact(code);
    if (compact.startsWith(query)) {
      starts.add(code);
    } else if (compact.contains(query)) {
      contains.add(code);
    }
  }
  final matches = [...starts, ...contains];
  if (matches.length == 1 && _compact(matches.single) == query) {
    return const [];
  }
  return matches.take(limit).toList(growable: false);
}

final _invisible = RegExp(
  r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F​-‍⁠﻿]',
);

/// The texts a scanned payload may name a tube by, tried in order: the
/// whole text, each line, and for a web link its last path segment and
/// query values. Control and zero-width characters are dropped first, so a
/// plain code yields just itself.
List<String> tissueScanCandidates(String raw) {
  final text = raw
      .replaceAll(_invisible, '')
      .replaceAll(' ', ' ')
      .replaceAll('\r', '\n')
      .trim();
  if (text.isEmpty) return const [];
  final candidates = <String>[text];
  final lines = text
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty);
  for (final line in lines) {
    candidates.add(line);
    final uri = Uri.tryParse(line);
    if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')) {
      continue;
    }
    final segment = uri.pathSegments.lastWhere(
      (e) => e.trim().isNotEmpty,
      orElse: () => '',
    );
    candidates
      ..add(segment)
      ..addAll(uri.queryParameters.values);
  }
  final seen = <String>{};
  return [
    for (final candidate in candidates.map((e) => e.trim()))
      if (candidate.isNotEmpty && seen.add(candidate)) candidate,
  ];
}

/// The [codes] close to [scanned], for when nothing matches it exactly.
/// Codes that differ only in case, spaces, or punctuation come first, then
/// codes found inside the scan (longest first), then codes that contain
/// it, then codes one or two characters off. At most [limit]. Scans under
/// three letters or digits get only the case and punctuation matches.
List<String> nearTissueCodes(
  List<String> codes,
  String scanned, {
  int limit = 5,
}) {
  final query = _compact(scanned);
  if (query.isEmpty) return const [];
  final loose = query.length >= 3;
  final maxDistance = query.length <= 6 ? 1 : 2;
  final equal = <String>[];
  final inside = <String>[];
  final containing = <String>[];
  final close = <(int, String)>[];
  for (final code in codes) {
    if (code.trim() == scanned.trim()) continue;
    final compact = _compact(code);
    if (compact.isEmpty) continue;
    if (compact == query) {
      equal.add(code);
    } else if (!loose) {
      continue;
    } else if (compact.length >= 3 && query.contains(compact)) {
      inside.add(code);
    } else if (compact.contains(query)) {
      containing.add(code);
    } else {
      final distance = _editDistance(query, compact, maxDistance);
      if (distance <= maxDistance) close.add((distance, code));
    }
  }
  inside.sort((a, b) => _compact(b).length.compareTo(_compact(a).length));
  containing.sort((a, b) => a.length.compareTo(b.length));
  close.sort((a, b) => a.$1.compareTo(b.$1));
  final seen = <String>{};
  return [
    for (final code in [...equal, ...inside, ...containing])
      if (seen.add(code)) code,
    for (final (_, code) in close)
      if (seen.add(code)) code,
  ].take(limit).toList(growable: false);
}

/// Levenshtein distance, or [limit] + 1 once it is sure to exceed [limit].
int _editDistance(String a, String b, int limit) {
  if ((a.length - b.length).abs() > limit) return limit + 1;
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0)..[0] = i;
    var rowMin = current[0];
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      current[j] = [
        previous[j] + 1,
        current[j - 1] + 1,
        previous[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
      if (current[j] < rowMin) rowMin = current[j];
    }
    if (rowMin > limit) return limit + 1;
    previous = current;
  }
  return previous[b.length];
}

String _compact(String text) =>
    text.toLowerCase().replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '');
