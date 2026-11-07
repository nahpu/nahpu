import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/symbiont_config_migration.dart';
import 'package:nahpu/services/settings/user_config_settings_service.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:shared_preferences/shared_preferences.dart';

const symbiontVocabularyPrefKeys = [
  symbiontInteractionTypePrefKey,
  symbiontCategoryPrefKey,
  symbiontDetectionMethodPrefKey,
  symbiontPreparationMethodPrefKey,
  symbiontAnatomicalLocationPrefKey,
  symbiontStoragePrefKey,
  symbiontTreatmentPrefKey,
];

/// Returns the defaults to write for a symbiont vocabulary, or null to keep
/// the stored list. Only missing or empty lists are seeded.
List<String>? seedSymbiontVocabulary(
  List<String>? stored,
  List<String> defaults,
) {
  if (stored != null && stored.isNotEmpty) return null;
  return defaults;
}

/// Seeds symbiont vocabularies once for installs that stored empty lists
/// before defaults existed. Lists the user has filled are left untouched.
class SymbiontVocabularyDefaults {
  const SymbiontVocabularyDefaults();

  Future<void> seedOnce(SharedPreferences prefs) async {
    if (prefs.getBool(symbiontVocabularyDefaultsSeededPrefKey) ?? false) {
      return;
    }
    // Installs seeded before v26 only lack the interaction types.
    final seededLegacy =
        prefs.getBool(legacySymbiontVocabularySeededPrefKey) ?? false;
    const settings = UserConfigSettingsService();
    for (final prefKey in symbiontVocabularyPrefKeys) {
      if (seededLegacy && prefKey != symbiontInteractionTypePrefKey) continue;
      final stored = await rust_config.getUserConfigList(key: prefKey);
      final seed = seedSymbiontVocabulary(
        stored,
        getDefaultOptionsList(prefKey),
      );
      if (seed != null) await settings.replaceOptions(prefKey, seed);
    }
    await prefs.setBool(symbiontVocabularyDefaultsSeededPrefKey, true);
  }
}
