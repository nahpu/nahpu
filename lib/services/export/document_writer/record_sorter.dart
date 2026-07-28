part of '../document_writer.dart';

class _DocumentRecordSorter {
  const _DocumentRecordSorter._();

  static List<Map<String, String>> sort(
    List<Map<String, String>> records,
    rust_config.DocumentLayoutBlock block,
  ) {
    final field = block.sortField?.trim();
    if (field == null || field.isEmpty || records.length < 2) {
      return List<Map<String, String>>.from(records);
    }

    final indexed = records.indexed.toList();
    indexed.sort((left, right) {
      final leftValue = _fieldValue(left.$2, field).trim();
      final rightValue = _fieldValue(right.$2, field).trim();
      final valueComparison = _compareValues(
        leftValue,
        rightValue,
        block.sortDirection,
      );
      return valueComparison != 0
          ? valueComparison
          : left.$1.compareTo(right.$1);
    });
    return indexed.map((entry) => entry.$2).toList(growable: false);
  }

  static String _fieldValue(Map<String, String> record, String field) {
    final exact = record[field];
    if (exact != null) return exact;
    final normalized = field.toLowerCase();
    for (final entry in record.entries) {
      if (entry.key.toLowerCase() == normalized) return entry.value;
    }
    return '';
  }

  static int _compareValues(
    String left,
    String right,
    rust_config.DocumentSortDirection direction,
  ) {
    final leftBlank = left.isEmpty;
    final rightBlank = right.isEmpty;
    if (leftBlank || rightBlank) {
      if (leftBlank == rightBlank) return 0;
      return leftBlank ? 1 : -1;
    }

    final comparison = _compareNonBlank(left, right);
    return direction == rust_config.DocumentSortDirection.descending
        ? -comparison
        : comparison;
  }

  static int _compareNonBlank(String left, String right) {
    final leftNumber = num.tryParse(left);
    final rightNumber = num.tryParse(right);
    if (leftNumber != null && rightNumber != null) {
      return leftNumber.compareTo(rightNumber);
    }

    final leftDate = DateTime.tryParse(left);
    final rightDate = DateTime.tryParse(right);
    if (leftDate != null && rightDate != null) {
      return leftDate.compareTo(rightDate);
    }

    return _compareNaturalText(left.toLowerCase(), right.toLowerCase());
  }

  static int _compareNaturalText(String left, String right) {
    final leftParts = RegExp(
      r'\d+|\D+',
    ).allMatches(left).map((match) => match.group(0)!).toList(growable: false);
    final rightParts = RegExp(
      r'\d+|\D+',
    ).allMatches(right).map((match) => match.group(0)!).toList(growable: false);
    final length = math.min(leftParts.length, rightParts.length);
    for (var index = 0; index < length; index++) {
      final leftPart = leftParts[index];
      final rightPart = rightParts[index];
      final leftNumber = BigInt.tryParse(leftPart);
      final rightNumber = BigInt.tryParse(rightPart);
      final comparison = leftNumber != null && rightNumber != null
          ? leftNumber.compareTo(rightNumber)
          : leftPart.compareTo(rightPart);
      if (comparison != 0) return comparison;
    }
    return leftParts.length.compareTo(rightParts.length);
  }
}
