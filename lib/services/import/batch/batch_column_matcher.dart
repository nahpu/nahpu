import 'dart:math' as math;

import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_import_targets.dart';

/// Fuzzy name scores below this leave a column unmapped.
const batchFuzzyThreshold = 0.75;

/// Matches file columns to NAHPU fields.
///
/// Darwin Core terms match exactly. Column names match the field's export
/// key, its label, or a common alias exactly, then loosely by shared words
/// and edit distance. Each field takes at most one column, the closest.
class BatchColumnMatcher {
  const BatchColumnMatcher({required this.targets, this.dwcTerms = const {}});

  final List<BatchImportTarget> targets;

  /// Darwin Core term by field key, such as `specimen::genus` to `genus`.
  final Map<String, String> dwcTerms;

  /// One match per header, in order. [saved] maps a normalized header
  /// (see [normalizeBatchHeader]) to a field key, or to an empty string for
  /// a column the user skipped; it wins over every other match.
  List<BatchColumnMatch> match(
    List<String> headers, {
    BatchImportHeaderMode mode = BatchImportHeaderMode.auto,
    Map<String, String> saved = const {},
  }) {
    final keys = {for (final target in targets) target.key};
    final result = <int, BatchColumnMatch>{};
    final taken = <String>{};

    void assign(int column, String? key, BatchMatchOrigin origin, double s) {
      result[column] = BatchColumnMatch(
        column: column,
        header: headers[column],
        fieldKey: key,
        origin: origin,
        score: s,
      );
      if (key != null) taken.add(key);
    }

    for (final (column, header) in headers.indexed) {
      final choice = saved[normalizeBatchHeader(header)];
      if (choice == null) continue;
      if (choice.isEmpty) {
        assign(column, null, BatchMatchOrigin.saved, 0);
      } else if (keys.contains(choice) && !taken.contains(choice)) {
        assign(column, choice, BatchMatchOrigin.saved, 1);
      }
    }

    if (mode != BatchImportHeaderMode.names) {
      final byTerm = <String, String>{};
      for (final entry in dwcTerms.entries) {
        if (!keys.contains(entry.key)) continue;
        byTerm.putIfAbsent(normalizeBatchHeader(entry.value), () => entry.key);
      }
      for (final (column, header) in headers.indexed) {
        if (result.containsKey(column)) continue;
        final key = byTerm[normalizeBatchHeader(header)];
        if (key != null && !taken.contains(key)) {
          assign(column, key, BatchMatchOrigin.darwinCore, 1);
        }
      }
    }

    if (mode != BatchImportHeaderMode.darwinCore) {
      final names = {for (final target in targets) target.key: _names(target)};
      for (final (column, header) in headers.indexed) {
        if (result.containsKey(column)) continue;
        final normalized = normalizeBatchHeader(header);
        for (final target in targets) {
          if (taken.contains(target.key)) continue;
          if (names[target.key]!.contains(normalized)) {
            assign(column, target.key, BatchMatchOrigin.exactName, 1);
            break;
          }
        }
      }

      final candidates = <(int, String, double)>[];
      for (final (column, header) in headers.indexed) {
        if (result.containsKey(column)) continue;
        final normalized = normalizeBatchHeader(header);
        for (final target in targets) {
          if (taken.contains(target.key)) continue;
          final score = names[target.key]!
              .map((name) => batchNameSimilarity(normalized, name))
              .fold(0.0, math.max);
          if (score >= batchFuzzyThreshold) {
            candidates.add((column, target.key, score));
          }
        }
      }
      candidates.sort((a, b) => b.$3.compareTo(a.$3));
      for (final (column, key, score) in candidates) {
        if (result.containsKey(column) || taken.contains(key)) continue;
        assign(column, key, BatchMatchOrigin.fuzzyName, score);
      }
    }

    return [
      for (final (column, header) in headers.indexed)
        result[column] ?? BatchColumnMatch(column: column, header: header),
    ];
  }

  Set<String> _names(BatchImportTarget target) => {
    normalizeBatchHeader(target.key),
    normalizeBatchHeader(target.key.split('::').last),
    normalizeBatchHeader(target.label),
    if (dwcTerms[target.key] case final term?) normalizeBatchHeader(term),
    for (final alias in batchHeaderAliases[target.key] ?? const <String>[])
      normalizeBatchHeader(alias),
  }..remove('');
}

/// A header as words separated by single spaces: lowercase, camelCase
/// split, with any Darwin Core prefix or term URI removed.
String normalizeBatchHeader(String header) {
  var text = header.trim();
  final slash = text.lastIndexOf('/');
  if (text.startsWith('http') && slash != -1) {
    text = text.substring(slash + 1);
  }
  text = text.replaceFirst(RegExp(r'^(dwc|dc|dcterms|ac|chrono):'), '');
  return batchSplitWords(text).join(' ');
}

/// How alike two normalized names are, from 0 to 1: the better of their
/// shared-word overlap and their edit distance over the longer name.
double batchNameSimilarity(String a, String b) {
  if (a.isEmpty || b.isEmpty) return 0;
  if (a == b) return 1;
  final wordsA = a.split(' ').toSet();
  final wordsB = b.split(' ').toSet();
  final jaccard =
      wordsA.intersection(wordsB).length / wordsA.union(wordsB).length;
  final compactA = a.replaceAll(' ', '');
  final compactB = b.replaceAll(' ', '');
  // Short names such as "tl" or "fa" only match exactly or by alias.
  if (math.min(compactA.length, compactB.length) < 4) return jaccard;
  final longest = math.max(compactA.length, compactB.length);
  final edit = 1 - _levenshtein(compactA, compactB) / longest;
  return math.max(jaccard, edit);
}

int _levenshtein(String a, String b) {
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      current[j] = math.min(
        math.min(current[j - 1] + 1, previous[j] + 1),
        previous[j - 1] + cost,
      );
    }
    previous = current;
  }
  return previous[b.length];
}

/// Other names field sheets and collection databases use for a field.
const batchHeaderAliases = <String, List<String>>{
  'specimen::specimenUUID': ['uuid', 'occurrence id', 'specimen id'],
  batchCatalogNumberKey: ['catalog no', 'cat no', 'catalog', 'field id'],
  batchScientificNameKey: ['species', 'taxon', 'binomial', 'scientific name'],
  'specimen::cataloger': ['collector', 'recorded by', 'cataloged by'],
  'specimen::fieldNumber': ['field no', 'field num', 'record number', 'fn'],
  'specimen::preparator': ['prepared by', 'preparer', 'prep by'],
  'specimen::order': ['taxon order'],
  'specimen::family': ['taxon family'],
  'specimen::specificEpithet': ['epithet', 'species epithet'],
  'specimen::preparationDate': ['prep date', 'date prepared'],
  'specimen::collectionTime': ['time collected'],
  'event::collEventID': ['event', 'collecting event'],
  'measurement::totalLength': ['tl', 'total', 'total length mm'],
  'measurement::tailLength': ['tail', 'tal', 'tv', 'tail vertebrae'],
  'measurement::hindFootLength': ['hf', 'hind foot', 'hindfoot', 'hfl'],
  'measurement::earLength': ['ear', 'efn', 'ear from notch'],
  'measurement::forearm': ['fa', 'forearm length'],
  'measurement::weight': ['wt', 'mass', 'body mass', 'body weight'],
  'measurement::sex': ['gender'],
  'measurement::svl': ['snout vent length'],
  'measurement::remark': ['remarks', 'notes', 'comments'],
  'part::tissueID': ['tissue', 'tissue no', 'tissue number'],
  'part::barcodeID': ['barcode'],
  'part::type': ['part', 'part name', 'preparation'],
  'part::count': ['quantity', 'number of parts'],
  'part::treatment': ['preservation', 'preservative'],
  'site::site': ['site id', 'site code', 'location id', 'station'],
  'geography::specificLocality': ['locality', 'site name'],
  'coordinate::decimalLatitude': ['lat', 'latitude', 'decimal latitude'],
  'coordinate::decimalLongitude': ['long', 'lon', 'lng', 'longitude'],
  'coordinate::elevationInMeter': ['elev', 'elevation', 'altitude', 'alt'],
  'coordinate::uncertaintyInMeters': ['uncertainty', 'coordinate error'],
  'coordinate::datum': ['geodetic datum'],
  'geography::stateProvince': ['state', 'province'],
  'geography::county': ['district', 'regency'],
  'geography::islandGroup': ['island'],
  'siteAttribute::habitatType': ['habitat'],
  'site::siteNotes': ['site remarks', 'location remarks'],
  'event::Activity': ['method', 'collecting method', 'sampling protocol'],
  'event::startDate': ['date', 'event date', 'collection date', 'start'],
  'event::endDate': ['end'],
  'narrative::narrative': ['entry', 'notes', 'journal'],
  'narrative::date': ['date'],
  'narrative::verbatimLocality': ['site', 'site id'],
};
