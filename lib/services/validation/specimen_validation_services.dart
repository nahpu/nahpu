import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/validation/mammal_validation.dart';
import 'package:nahpu/services/validation/bird_validation.dart';
import 'package:nahpu/services/validation/models.dart';

class SpecimenValidationServices extends AppServices {
  const SpecimenValidationServices({required super.ref});

  Future<List<ValidationResult>> runValidation(
    List<int> taxonIds, {
    required bool detectOutliers,
    required bool findMissingFields,
  }) async {
    final validationResults = <String, ValidationResult>{};

    for (final taxonId in taxonIds) {
      final specimens =
          await SpecimenServices(ref: ref).getSpecimensByTaxonId(taxonId);
      if (specimens.isEmpty) {
        continue;
      }

      final taxonGroup = specimens.first.taxonGroup;

      if (taxonGroup == 'General Mammals' || taxonGroup == 'Bats') {
        final validator = MammalValidation(
          ref: ref,
          specimens: specimens,
          detectOutliers: detectOutliers,
          findMissingFields: findMissingFields,
        );
        final results = await validator.validate();
        for (var result in results) {
          if (validationResults.containsKey(result.specimen.uuid)) {
            validationResults[result.specimen.uuid]!
                .issues
                .addAll(result.issues);
          } else {
            validationResults[result.specimen.uuid] = result;
          }
        }
      } else if (taxonGroup == 'Birds') {
        final validator = BirdValidation(
          ref: ref,
          specimens: specimens,
          detectOutliers: detectOutliers,
          findMissingFields: findMissingFields,
        );
        final results = await validator.validate();
        for (var result in results) {
          if (validationResults.containsKey(result.specimen.uuid)) {
            validationResults[result.specimen.uuid]!
                .issues
                .addAll(result.issues);
          } else {
            validationResults[result.specimen.uuid] = result;
          }
        }
      }
    }
    return validationResults.values.toList();
  }
}