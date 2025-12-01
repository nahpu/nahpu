import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/taxonomy_services.dart';
import 'package:nahpu/services/validation/mammal_validation.dart';
import 'package:nahpu/services/validation/bird_validation.dart';
import 'package:nahpu/services/validation/models.dart';

class SpecimenValidationServices extends AppServices {
  const SpecimenValidationServices({required super.ref});

  Future<List<ValidationResult>> runValidation(
    List<int> taxonIds, {
    required bool detectOutliers,
    required bool findMissingFields,
    required List<String> fieldsToCheck,
  }) async {
    final validationResults = <String, ValidationResult>{};

    // 1. Validate selected taxa
    for (final taxonId in taxonIds) {
      // Optimization: Fetch taxonomy name ONCE per group
      final taxon = await TaxonomyServices(ref: ref).getTaxonById(taxonId);
      final speciesName = '${taxon.genus} ${taxon.specificEpithet}';

      final specimens =
          await SpecimenServices(ref: ref).getSpecimensByTaxonId(taxonId);
      if (specimens.isEmpty) {
        continue;
      }
      await _validateGroup(
        specimens,
        speciesName,
        validationResults,
        detectOutliers,
        findMissingFields,
        fieldsToCheck,
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
          "Unknown Species", // Use placeholder name
          validationResults,
          detectOutliers,
          findMissingFields,
          fieldsToCheck,
        );
      }
    }

    return validationResults.values.toList();
  }

  Future<void> _validateGroup(
    List<SpecimenData> specimens,
    String speciesName,
    Map<String, ValidationResult> validationResults,
    bool detectOutliers,
    bool findMissingFields,
    List<String> fieldsToCheck,
  ) async {
    if (specimens.isEmpty) return;

    final taxonGroup = specimens.first.taxonGroup;

    if (taxonGroup == 'General Mammals' || taxonGroup == 'Bats') {
      final validator = MammalValidation(
        ref: ref,
        specimens: specimens,
        detectOutliers: detectOutliers,
        findMissingFields: findMissingFields,
        fieldsToCheck: fieldsToCheck,
        speciesName: speciesName,
      );
      final results = await validator.validate();
      _mergeResults(validationResults, results);
    } else if (taxonGroup == 'Birds') {
      final validator = BirdValidation(
        ref: ref,
        specimens: specimens,
        detectOutliers: detectOutliers,
        findMissingFields: findMissingFields,
        fieldsToCheck: fieldsToCheck,
        speciesName: speciesName,
      );
      final results = await validator.validate();
      _mergeResults(validationResults, results);
    }
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