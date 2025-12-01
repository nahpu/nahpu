import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/taxonomy_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/validation/mandatory_fields.dart';
import 'package:nahpu/services/validation/models.dart';
import 'package:nahpu/services/validation/specimen_validation_services.dart';

class DataValidationState {
  final List<int> selectedSpecies;
  final Set<String> selectedFields;
  final bool detectOutliers;
  final bool findMissingFields;
  final ValidationSort sortOption;
  final List<ValidationResult>? results;
  final bool isLoading;

  DataValidationState({
    required this.selectedSpecies,
    required this.selectedFields,
    required this.detectOutliers,
    required this.findMissingFields,
    required this.sortOption,
    this.results,
    required this.isLoading,
  });

  DataValidationState copyWith({
    List<int>? selectedSpecies,
    Set<String>? selectedFields,
    bool? detectOutliers,
    bool? findMissingFields,
    ValidationSort? sortOption,
    List<ValidationResult>? results,
    bool? isLoading,
  }) {
    return DataValidationState(
      selectedSpecies: selectedSpecies ?? this.selectedSpecies,
      selectedFields: selectedFields ?? this.selectedFields,
      detectOutliers: detectOutliers ?? this.detectOutliers,
      findMissingFields: findMissingFields ?? this.findMissingFields,
      sortOption: sortOption ?? this.sortOption,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DataValidationNotifier
    extends AutoDisposeAsyncNotifier<DataValidationState> {
  List<String> _originalOrder = [];

  @override
  Future<DataValidationState> build() async {
    final projectUuid = ref.watch(projectUuidProvider);

    // Fetch all taxa with specimen data to initialize selection
    final taxa = await TaxonomyQuery(ref.read(databaseProvider))
        .getAllTaxaWithSpecimenData(projectUuid);
    
    final allSpeciesIds = taxa.map((e) => e.id).toList();

    return DataValidationState(
      selectedSpecies: allSpeciesIds, // Default: Select All
      selectedFields: MandatoryFieldService.allSpecimenFields.toSet(),
      detectOutliers: true,
      findMissingFields: true,
      sortOption: ValidationSort.species,
      results: null,
      isLoading: false,
    );
  }

  void setSpeciesSelection(List<int> speciesIds) {
    state = AsyncValue.data(state.value!.copyWith(selectedSpecies: speciesIds));
  }

  void toggleField(String field) {
    final currentState = state.value;
    if (currentState == null) return;

    final fields = Set<String>.from(currentState.selectedFields);
    if (fields.contains(field)) {
      fields.remove(field);
    } else {
      fields.add(field);
    }
    state = AsyncValue.data(currentState.copyWith(selectedFields: fields));
  }

  void toggleFieldGroup(List<String> fields, bool select) {
    final currentState = state.value;
    if (currentState == null) return;

    final currentFields = Set<String>.from(currentState.selectedFields);
    if (select) {
      currentFields.addAll(fields);
    } else {
      currentFields.removeAll(fields);
    }
    state = AsyncValue.data(currentState.copyWith(selectedFields: currentFields));
  }

  void setDetectOutliers(bool value) {
    state = AsyncValue.data(state.value!.copyWith(detectOutliers: value));
  }

  void setFindMissingFields(bool value) {
    state = AsyncValue.data(state.value!.copyWith(findMissingFields: value));
  }

  void setSortOption(ValidationSort option) {
    state = AsyncValue.data(state.value!.copyWith(sortOption: option));
    _sortResults();
  }

  Future<void> validate() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true));
    
    try {
      // Fetch original order for page number sorting
      _originalOrder = await SpecimenServices(ref: ref).getAllSpecimenUuids();

      final results =
          await SpecimenValidationServices(ref: ref).runValidation(
        currentState.selectedSpecies,
        detectOutliers: currentState.detectOutliers,
        findMissingFields: currentState.findMissingFields,
        fieldsToCheck: currentState.selectedFields.toList(),
      );

      // We need to re-read state because it might have changed (though unlikely during await)
      // but safer to use current pattern
      state = AsyncValue.data(state.value!.copyWith(results: results, isLoading: false));
      _sortResults();
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(isLoading: false));
    }
  }

  void _sortResults() {
    final currentState = state.value;
    if (currentState == null || currentState.results == null) return;

    final sortedResults = List<ValidationResult>.from(currentState.results!);

    switch (currentState.sortOption) {
      case ValidationSort.species:
        sortedResults.sort((a, b) {
          final aIsUnknown = a.specimen.speciesID == null;
          final bIsUnknown = b.specimen.speciesID == null;

          if (aIsUnknown && !bIsUnknown) return 1;
          if (!aIsUnknown && bIsUnknown) return -1;

          return a.speciesName.compareTo(b.speciesName);
        });
        break;
      case ValidationSort.fieldNumber:
        sortedResults.sort((a, b) => (a.specimen.fieldNumber ?? 0)
            .compareTo(b.specimen.fieldNumber ?? 0));
        break;
      case ValidationSort.pageNumber:
        if (_originalOrder.isNotEmpty) {
          sortedResults.sort((a, b) => _originalOrder
              .indexOf(a.specimen.uuid)
              .compareTo(_originalOrder.indexOf(b.specimen.uuid)));
        } else {
          sortedResults.sort((a, b) => (a.specimen.fieldNumber ?? 0)
              .compareTo(b.specimen.fieldNumber ?? 0));
        }
        break;
    }
    state = AsyncValue.data(currentState.copyWith(results: sortedResults));
  }
}

final dataValidationProvider =
    AsyncNotifierProvider.autoDispose<DataValidationNotifier, DataValidationState>(
        () => DataValidationNotifier());