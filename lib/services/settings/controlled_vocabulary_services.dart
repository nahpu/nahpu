import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/database/parasite_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/specimens.dart';

const controlledVocabularyPrefKeys = [
  siteTypePrefKey,
  habitatTypePrefKey,
  datumPrefKey,
  collMethodPrefKey,
  collRolePrefKey,
  specimenTypePrefKey,
  treatmentPrefKey,
  conditionPrefKey,
  specimenSexPrefKey,
  idMethodPrefKey,
  lifeStagePrefKey,
  parasiteCategoryPrefKey,
  parasiteDetectionMethodPrefKey,
  parasitePreparationMethodPrefKey,
  parasiteAnatomicalLocationPrefKey,
  parasiteStoragePrefKey,
  parasiteTreatmentPrefKey,
];

final effectiveUserDefinedFieldProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, prefKey) async {
      final configuredFuture = ref.watch(
        userDefinedFieldProvider(prefKey).future,
      );
      final database = ref.watch(databaseProvider);
      final configured = await configuredFuture;
      if (prefKey == specimenSexPrefKey) {
        return normalizeSpecimenSexOptions(
          configured,
        ).map((sex) => specimenSexLabel[sex]!).toList(growable: false);
      }
      final stored = switch (prefKey) {
        siteTypePrefKey => await SiteQuery(database).getDistinctSiteTypes(),
        habitatTypePrefKey => await SiteQuery(
          database,
        ).getDistinctHabitatTypes(),
        datumPrefKey => await CoordinateQuery(database).getDistinctDatums(),
        collMethodPrefKey => await CollEffortQuery(
          database,
        ).getDistinctMethods(),
        collRolePrefKey => await CollPersonnelQuery(
          database,
        ).getDistinctRoles(),
        specimenTypePrefKey => await SpecimenPartQuery(
          database,
        ).getDistinctTypes(),
        treatmentPrefKey => await SpecimenPartQuery(
          database,
        ).getDistinctTreatments(),
        conditionPrefKey => await SpecimenQuery(
          database,
        ).getDistinctConditions(),
        idMethodPrefKey => await SpecimenQuery(database).getDistinctIdMethods(),
        lifeStagePrefKey => await SpecimenQuery(
          database,
        ).getDistinctLifeStages(),
        parasiteCategoryPrefKey => await ParasiteQuery(
          database,
        ).getDistinctCategories(),
        parasiteDetectionMethodPrefKey => await ParasiteQuery(
          database,
        ).getDistinctDetectionMethods(),
        parasitePreparationMethodPrefKey => await ParasiteQuery(
          database,
        ).getDistinctPreparationMethods(),
        parasiteAnatomicalLocationPrefKey => await ParasiteQuery(
          database,
        ).getDistinctAnatomicalLocations(),
        parasiteStoragePrefKey => await ParasiteQuery(
          database,
        ).getDistinctStorageValues(),
        parasiteTreatmentPrefKey => await ParasiteQuery(
          database,
        ).getDistinctTreatments(),
        _ => const <String>[],
      };

      return mergeVocabularyOptions(configured, stored);
    });

final specimenSexVocabularyProvider =
    FutureProvider.autoDispose<List<SpecimenSex>>((ref) async {
      final settings = ref.watch(userConfigSettingsServiceProvider);
      final configured = await settings.loadOptions(
        specimenSexPrefKey,
        defaultSpecimenSexLabels,
      );
      final normalized = normalizeSpecimenSexOptions(configured);
      final normalizedLabels = normalized
          .map((sex) => specimenSexLabel[sex]!)
          .toList(growable: false);
      if (!_sameOptions(configured, normalizedLabels)) {
        await settings.replaceOptions(specimenSexPrefKey, normalizedLabels);
      }
      return List.unmodifiable(normalized);
    });

bool _sameOptions(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

List<String> mergeVocabularyOptions(
  Iterable<String> configured,
  Iterable<String> stored,
) {
  final options = <String>[];
  final seen = <String>{};

  void add(String value) {
    if (value.trim().isEmpty || !seen.add(value)) return;
    options.add(value);
  }

  configured.forEach(add);
  final databaseOnly =
      stored
          .where((value) => value.trim().isNotEmpty && !seen.contains(value))
          .toSet()
          .toList()
        ..sort(
          (left, right) => left.toLowerCase().compareTo(right.toLowerCase()),
        );
  databaseOnly.forEach(add);
  return List.unmodifiable(options);
}

List<String> includeCurrentVocabularyValue(
  Iterable<String> options,
  String? currentValue,
) {
  return mergeVocabularyOptions(
    options,
    currentValue == null ? const [] : [currentValue],
  );
}

void invalidateEffectiveControlledVocabularies(WidgetRef ref) {
  for (final prefKey in controlledVocabularyPrefKeys) {
    ref.invalidate(effectiveUserDefinedFieldProvider(prefKey));
  }
}
