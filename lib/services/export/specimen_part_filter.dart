import 'package:nahpu/services/database/specimen_queries.dart';

enum SpecimenPartNumberType { fieldNumber, projectNumber }

class SpecimenPartTypeOption {
  const SpecimenPartTypeOption({required this.value, required this.label});

  final String value;
  final String label;
}

/// Temporary list filters. Export selection remains a separate set of part IDs.
class SpecimenPartFilter {
  SpecimenPartFilter({
    Set<String> partTypes = const {},
    this.numberType = SpecimenPartNumberType.fieldNumber,
    this.from,
    this.to,
  }) : partTypes = Set.unmodifiable(partTypes.map(_normalizeType)) {
    if ((from != null && from! < 0) || (to != null && to! < 0)) {
      throw ArgumentError('Number bounds must be non-negative.');
    }
    if (from != null && to != null && from! > to!) {
      throw ArgumentError('From must be less than or equal to To.');
    }
  }

  const SpecimenPartFilter.empty()
    : partTypes = const {},
      numberType = SpecimenPartNumberType.fieldNumber,
      from = null,
      to = null;

  /// Normalized types; the empty string represents a missing part type.
  final Set<String> partTypes;
  final SpecimenPartNumberType numberType;
  final int? from;
  final int? to;

  bool get hasNumberRange => from != null || to != null;

  bool get isActive => partTypes.isNotEmpty || hasNumberRange;

  bool matches(SpecimenPartProjectRecord record, {String query = ''}) {
    final part = record.part;
    final specimen = record.specimen;
    if (partTypes.isNotEmpty &&
        !partTypes.contains(_normalizeType(part.type))) {
      return false;
    }
    if (hasNumberRange) {
      final number = switch (numberType) {
        SpecimenPartNumberType.fieldNumber => specimen.fieldNumber,
        SpecimenPartNumberType.projectNumber => specimen.projectFieldNumber,
      };
      if (number == null ||
          (from != null && number < from!) ||
          (to != null && number > to!)) {
        return false;
      }
    }
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;
    final text = [
      part.tissueID,
      part.barcodeID,
      part.type,
      part.treatment,
      specimen.fieldNumber?.toString(),
      specimen.projectFieldNumber?.toString(),
      specimen.museumID,
    ].whereType<String>().join(' ').toLowerCase();
    return text.contains(normalizedQuery);
  }

  static List<SpecimenPartTypeOption> typeOptionsFor(
    Iterable<SpecimenPartProjectRecord> records,
  ) {
    final labels = <String, String>{};
    for (final record in records) {
      final type = record.part.type?.trim() ?? '';
      labels.putIfAbsent(
        _normalizeType(type),
        () => type.isEmpty ? 'Unspecified' : type,
      );
    }
    final options =
        labels.entries
            .map(
              (entry) =>
                  SpecimenPartTypeOption(value: entry.key, label: entry.value),
            )
            .toList()
          ..sort(
            (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
          );
    return List.unmodifiable(options);
  }

  static String? validateNumber(String? input) {
    final text = input?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^\d+$').hasMatch(text) || int.tryParse(text) == null) {
      return 'Enter a non-negative whole number.';
    }
    return null;
  }

  static String? validateRange(String from, String to) {
    final start = int.tryParse(from.trim());
    final end = int.tryParse(to.trim());
    if (start != null && end != null && start > end) {
      return 'From must be less than or equal to To.';
    }
    return null;
  }

  static String _normalizeType(String? type) =>
      type?.trim().toLowerCase() ?? '';
}
