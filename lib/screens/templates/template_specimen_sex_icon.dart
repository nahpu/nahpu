import 'package:flutter/material.dart';
import 'package:nahpu/services/types/specimens.dart';

IconData templateSpecimenSexIconDataForDisplayValue(String? display) {
  if (display == null || display.trim().isEmpty) {
    return Icons.question_mark;
  }
  final t = display.trim();
  final i = specimenSexList.indexWhere(
    (e) => e.toLowerCase() == t.toLowerCase(),
  );
  if (i == 0) return Icons.male;
  if (i == 1) return Icons.female;
  if (i == 2) return Icons.question_mark;
  return Icons.question_mark;
}

IconData templateSpecimenSexIconForFieldKey(
    Map<String, String> data, String fieldKey) {
  String? v;
  if (data.containsKey(fieldKey)) {
    v = data[fieldKey];
  } else {
    final low = fieldKey.toLowerCase();
    for (final e in data.entries) {
      if (e.key.toLowerCase() == low) {
        v = e.value;
        break;
      }
    }
  }
  return templateSpecimenSexIconDataForDisplayValue(v);
}
