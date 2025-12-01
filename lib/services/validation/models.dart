import 'package:nahpu/services/database/database.dart';

class ValidationResult {
  final SpecimenData specimen;
  final String speciesName;
  final List<String> issues;

  ValidationResult({
    required this.specimen,
    required this.speciesName,
    required this.issues,
  });
}

enum ValidationSort { species, fieldNumber, pageNumber }