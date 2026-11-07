import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:shared_preferences/shared_preferences.dart';

/// List settings named for parasites before v26, keyed by their legacy key.
const Map<String, String> legacySymbiontListConfigKeys = {
  'parasiteCategories': symbiontCategoryPrefKey,
  'parasiteDetectionMethods': symbiontDetectionMethodPrefKey,
  'parasitePreparationMethods': symbiontPreparationMethodPrefKey,
  'parasiteAnatomicalLocations': symbiontAnatomicalLocationPrefKey,
  'parasiteStorage': symbiontStoragePrefKey,
  'parasiteTreatments': symbiontTreatmentPrefKey,
};

/// String settings named for parasites before v26, keyed by their legacy key.
const Map<String, String> legacySymbiontStringConfigKeys = {
  'parasiteIdPrefix': symbiontIdPrefixPrefKey,
  'parasiteIdNumber': symbiontIdNumberPrefKey,
  'parasiteCategoryFmt': symbiontCategoryFmtPrefKey,
  'parasiteDetectionMethodFmt': symbiontDetectionMethodFmtPrefKey,
  'parasitePreparationMethodFmt': symbiontPreparationMethodFmtPrefKey,
  'parasiteAnatomicalLocationFmt': symbiontAnatomicalLocationFmtPrefKey,
  'parasiteStorageFmt': symbiontStorageFmtPrefKey,
  'parasiteTreatmentFmt': symbiontTreatmentFmtPrefKey,
};

/// The flag older installs set after seeding the parasite vocabularies.
const String legacySymbiontVocabularySeededPrefKey =
    'parasiteVocabularyDefaultsSeeded';

const String _migratedPrefKey = 'symbiontConfigKeysMigrated';

/// Moves user settings saved under `parasite*` keys to their `symbiont*`
/// keys once. A value already stored under the new key wins.
class SymbiontConfigMigration {
  const SymbiontConfigMigration();

  Future<void> runOnce(SharedPreferences prefs) async {
    if (prefs.getBool(_migratedPrefKey) ?? false) return;
    await migrateKeys();
    await prefs.setBool(_migratedPrefKey, true);
  }

  /// Moves any `parasite*` settings to their `symbiont*` keys. With
  /// [overwrite], used after importing an older settings file, the legacy
  /// value replaces the stored one.
  Future<void> migrateKeys({bool overwrite = false}) async {
    for (final MapEntry(key: legacy, value: key)
        in legacySymbiontListConfigKeys.entries) {
      final value = await rust_config.getUserConfigList(key: legacy);
      if (value == null) continue;
      final current = await rust_config.getUserConfigList(key: key);
      if (overwrite || current == null || current.isEmpty) {
        await rust_config.setUserConfigList(key: key, value: value);
      }
      await rust_config.deleteUserConfig(key: legacy);
    }
    for (final MapEntry(key: legacy, value: key)
        in legacySymbiontStringConfigKeys.entries) {
      final value = await rust_config.getUserConfigString(key: legacy);
      if (value == null) continue;
      final current = await rust_config.getUserConfigString(key: key);
      if (overwrite || current == null || current.isEmpty) {
        await rust_config.setUserConfigString(key: key, value: value);
      }
      await rust_config.deleteUserConfig(key: legacy);
    }
  }
}
