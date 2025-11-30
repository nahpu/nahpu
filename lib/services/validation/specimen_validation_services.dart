import 'package:nahpu/services/database/database.dart';
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

    // 1. Validate selected taxa
    for (final taxonId in taxonIds) {
      final specimens =
          await SpecimenServices(ref: ref).getSpecimensByTaxonId(taxonId);
      if (specimens.isEmpty) {
        continue;
      }
      await _validateGroup(
        specimens,
        validationResults,
        detectOutliers,
        findMissingFields,
      );
    }

    // 2. Validate specimens with null speciesID (not associated with any taxon yet)
    final nullSpeciesSpecimens =
        await SpecimenServices(ref: ref).getSpecimensWithNullSpecies();
    
    if (nullSpeciesSpecimens.isNotEmpty) {
      // Group them by taxon group (e.g. 'General Mammals', 'Birds') to apply the correct validator.
      final Map<String, List<SpecimenData>> byGroup = {};
      for (var s in nullSpeciesSpecimens) {
        final group = s.taxonGroup ?? 'Unknown';
        byGroup.putIfAbsent(group, () => []).add(s);
      }

      for (var entry in byGroup.entries) {
        await _validateGroup(
          entry.value,
          validationResults,
          detectOutliers,
          findMissingFields,
        );
      }
    }

    return validationResults.values.toList();
  }

  Future<void> _validateGroup(
    List<SpecimenData> specimens,
    Map<String, ValidationResult> validationResults,
    bool detectOutliers,
    bool findMissingFields,
  ) async {
    if (specimens.isEmpty) return;
    
    final taxonGroup = specimens.first.taxonGroup;

    if (taxonGroup == 'General Mammals' || taxonGroup == 'Bats') {
      final validator = MammalValidation(
        ref: ref,
        specimens: specimens,
        detectOutliers: detectOutliers,
        findMissingFields: findMissingFields,
      );
      final results = await validator.validate();
      _mergeResults(validationResults, results);
    } else if (taxonGroup == 'Birds') {
      final validator = BirdValidation(
        ref: ref,
        specimens: specimens,
        detectOutliers: detectOutliers,
        findMissingFields: findMissingFields,
      );
      final results = await validator.validate();
      _mergeResults(validationResults, results);
    }
    // Note: If taxonGroup is unknown or null, we currently skip specific validation.
    // You could add a generic validator here that only checks shared fields (cataloger, prep date, etc.)
    // if desired.
  }

  void _mergeResults(Map<String, ValidationResult> source,
      List<ValidationResult> newResults) {
    for (var result in newResults) {
      if (source.containsKey(result.specimen.uuid)) {
        source[result.specimen.uuid]!.issues.addAll(result.issues);
      } else {
        source[result.specimen.uuid] = result;
      }
    }
  }
}