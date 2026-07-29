import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/controlled_vocabulary_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String newDbPref = 'isNewDb';

class DbServices extends AppServices {
  const DbServices({required super.ref});

  SharedPreferences get prefs => ref.read(settingProvider);

  Future<void> setNewDatabase() async {
    await prefs.setBool(newDbPref, true);
  }

  Future<void> syncSettingWithDb() async {
    for (final prefKey in controlledVocabularyPrefKeys) {
      ref.invalidate(userDefinedFieldProvider(prefKey));
    }
    invalidateEffectiveControlledVocabularies(ref);
    await _inValidateSettings();
  }

  Future<void> deleteDatabase() async {
    try {
      dbAccess.close();
      final appDb = await dBPath;
      if (appDb.existsSync()) {
        appDb.deleteSync();
      }
    } catch (e) {
      throw Exception('Error deleting database: $e');
    }
  }

  Future<bool> checkNewDatabase() async {
    final isNewDb = prefs.getBool(newDbPref) ?? false;
    return isNewDb;
  }

  Future<void> _inValidateSettings() async {
    await prefs.setBool(newDbPref, false);
  }
}
