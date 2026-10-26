import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/user_config_settings_service.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:shared_preferences/shared_preferences.dart';

const parasiteVocabularyPrefKeys = [
  parasiteCategoryPrefKey,
  parasiteDetectionMethodPrefKey,
  parasitePreparationMethodPrefKey,
  parasiteAnatomicalLocationPrefKey,
  parasiteStoragePrefKey,
  parasiteTreatmentPrefKey,
];

/// Returns the defaults to write for a parasite vocabulary, or null to keep
/// the stored list. Only missing or empty lists are seeded.
List<String>? seedParasiteVocabulary(
  List<String>? stored,
  List<String> defaults,
) {
  if (stored != null && stored.isNotEmpty) return null;
  return defaults;
}

/// Seeds parasite vocabularies once for installs that stored empty lists
/// before defaults existed. Lists the user has filled are left untouched.
class ParasiteVocabularyDefaults {
  const ParasiteVocabularyDefaults();

  Future<void> seedOnce(SharedPreferences prefs) async {
    if (prefs.getBool(parasiteVocabularyDefaultsSeededPrefKey) ?? false) {
      return;
    }
    const settings = UserConfigSettingsService();
    for (final prefKey in parasiteVocabularyPrefKeys) {
      final stored = await rust_config.getUserConfigList(key: prefKey);
      final seed = seedParasiteVocabulary(
        stored,
        getDefaultOptionsList(prefKey),
      );
      if (seed != null) await settings.replaceOptions(prefKey, seed);
    }
    await prefs.setBool(parasiteVocabularyDefaultsSeededPrefKey, true);
  }
}
