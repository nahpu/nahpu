import 'dart:convert';

import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/import/batch/batch_column_matcher.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the column choices a user made, per record type, mode, and
/// set of file headers, so the next file laid out the same way maps the
/// same way.
class BatchMappingStore {
  const BatchMappingStore(this.prefs);

  final SharedPreferences prefs;

  /// Saved choices by normalized header: a field key, or an empty string
  /// for a skipped column.
  Map<String, String> load(
    DataTableRecordType type,
    BatchImportMode mode,
    List<String> headers, {
    bool linked = false,
  }) {
    final raw = prefs.getString(
      storageKey(type, mode, headers, linked: linked),
    );
    if (raw == null) return const {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries)
          if (entry.value is String) entry.key: entry.value as String,
      };
    } on FormatException {
      return const {};
    }
  }

  /// Saves the columns the user chose themselves; automatic matches are
  /// found again next time.
  Future<void> save(
    DataTableRecordType type,
    BatchImportMode mode,
    List<BatchColumnMatch> matches, {
    bool linked = false,
  }) async {
    final headers = [for (final match in matches) match.header];
    final choices = {
      for (final match in matches)
        if (match.origin == BatchMatchOrigin.user ||
            match.origin == BatchMatchOrigin.saved)
          normalizeBatchHeader(match.header): match.fieldKey ?? '',
    };
    final key = storageKey(type, mode, headers, linked: linked);
    if (choices.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, jsonEncode(choices));
    }
  }

  /// The same for any order of the same headers. [linked] imports keep
  /// their own choices, whatever [type] is.
  static String storageKey(
    DataTableRecordType type,
    BatchImportMode mode,
    List<String> headers, {
    bool linked = false,
  }) {
    final normalized = [for (final h in headers) normalizeBatchHeader(h)]
      ..sort();
    final scope = linked ? 'linked' : type.name;
    return 'batchImportMapping.$scope.${mode.name}.'
        '${_fnv1a(normalized.join('|'))}';
  }

  /// A hash that stays the same across app runs, unlike [String.hashCode].
  static String _fnv1a(String text) {
    var hash = 0x811c9dc5;
    for (final unit in utf8.encode(text)) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
