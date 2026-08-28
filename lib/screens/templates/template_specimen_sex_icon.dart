import 'package:nahpu/services/types/specimens.dart';

String templateSpecimenSexGlyphForDisplayValue(String? display) {
  final sex = specimenSexFromDisplayValue(display);
  return sex == null ? '?' : specimenSexSymbol[sex]!;
}

String templateSpecimenSexGlyphForFieldKey(
  Map<String, String> data,
  String fieldKey,
) {
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
  return templateSpecimenSexGlyphForDisplayValue(v);
}
