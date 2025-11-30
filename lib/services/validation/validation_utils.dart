import 'package:nahpu/services/validation/mandatory_fields.dart';

class ValidationUtils {
  static List<String> checkMissingFields(
      Map<String, dynamic> data, List<String> fields) {
    final List<String> missingFields = [];
    for (String field in fields) {
      if (!data.containsKey(field) ||
          data[field] == null ||
          (data[field] is String && (data[field] as String).isEmpty)) {
        String label = MandatoryFieldService.fieldLabels[field] ?? field;
        missingFields.add('Missing: $label');
      }
    }
    return missingFields;
  }
}