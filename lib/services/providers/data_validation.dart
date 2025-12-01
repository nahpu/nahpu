import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  factory DataValidationState.initial() {
    return DataValidationState(
      selectedSpecies: [],
      selectedFields: MandatoryFieldService.allSpecimenFields.toSet(),
      detectOutliers: true,
      findMissingFields: true,
      sortOption: ValidationSort.species,
      results: null,
      isLoading: false,
    );
  }
}

class DataValidationNotifier extends Notifier<DataValidationState> {
  // Cache the original order of UUIDs to support "Page" sorting
  List<String> _originalOrder = [];

  @override
  DataValidationState build() {
    // Watch projectUuidProvider to reset state when project changes
    ref.watch(projectUuidProvider);
    return DataValidationState.initial();
  }

  void setSpeciesSelection(List<int> speciesIds) {
    state = state.copyWith(selectedSpecies: speciesIds);
  }

  void toggleField(String field) {
    final fields = Set<String>.from(state.selectedFields);
    if (fields.contains(field)) {
      fields.remove(field);
    } else {
      fields.add(field);
    }
    state = state.copyWith(selectedFields: fields);
  }

  void toggleFieldGroup(List<String> fields, bool select) {
    final currentFields = Set<String>.from(state.selectedFields);
    if (select) {
      currentFields.addAll(fields);
    } else {
      currentFields.removeAll(fields);
    }
    state = state.copyWith(selectedFields: currentFields);
  }

  void setDetectOutliers(bool value) {
    state = state.copyWith(detectOutliers: value);
  }

  void setFindMissingFields(bool value) {
    state = state.copyWith(findMissingFields: value);
  }

  void setSortOption(ValidationSort option) {
    state = state.copyWith(sortOption: option);
    _sortResults();
  }

  Future<void> validate() async {
    state = state.copyWith(isLoading: true);
    try {
      // Fetch original order for page number sorting
      _originalOrder = await SpecimenServices(ref: ref).getAllSpecimenUuids();

      final results =
          await SpecimenValidationServices(ref: ref).runValidation(
        state.selectedSpecies,
        detectOutliers: state.detectOutliers,
        findMissingFields: state.findMissingFields,
        fieldsToCheck: state.selectedFields.toList(),
      );
      state = state.copyWith(results: results, isLoading: false);
      _sortResults();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Error handling can be added here
    }
  }

  void _sortResults() {
    if (state.results == null) return;
    final sortedResults = List<ValidationResult>.from(state.results!);

    switch (state.sortOption) {
      case ValidationSort.species:
        sortedResults.sort((a, b) {
          // Check for Unknown species to put them at the bottom
          // We use the string check here assuming the service passes "Unknown Species"
          // or if speciesID is null in data.
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
          // Fallback to field number if original order is missing
          sortedResults.sort((a, b) => (a.specimen.fieldNumber ?? 0)
              .compareTo(b.specimen.fieldNumber ?? 0));
        }
        break;
    }
    state = state.copyWith(results: sortedResults);
  }
}

final dataValidationProvider =
    NotifierProvider<DataValidationNotifier, DataValidationState>(
        () => DataValidationNotifier());