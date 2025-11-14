import 'package:nahpu/services/database/database.dart';

class ValidationResult {
  final SpecimenData specimen;
  final List<String> issues;

  ValidationResult({required this.specimen, required this.issues});
}