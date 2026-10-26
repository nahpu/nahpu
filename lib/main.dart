import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nahpu/src/rust/api/common.dart';
import 'package:timezone/data/latest.dart';
import 'package:nahpu/src/rust/frb_generated.dart';
import 'package:nahpu/styles/themes.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/localization.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/screens/home/home.dart';
import 'package:nahpu/screens/shared/layout/app_exit_handler.dart';
import 'package:nahpu/screens/shared/layout/regional_format_rebuilder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nahpu/services/settings/bundled_preset_service.dart';
import 'package:nahpu/services/settings/config_services.dart';
import 'package:nahpu/services/settings/parasite_vocabulary_defaults.dart';
import 'package:nahpu/services/templates/font_registry.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:fvp/fvp.dart' as fvp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await RustLib.init();
  final configService = ConfigDbService();
  await configService.initDb();
  await configService.migrate(prefs);
  await const ParasiteVocabularyDefaults().seedOnce(prefs);
  await const BundledPresetService().loadOnFirstLaunch(prefs);
  await registerUserFonts();
  pdfrxFlutterInitialize();
  fvp.registerWith(
    options: {
      'platforms': ['macos', 'ios'],
    },
  );
  if (kDebugMode) {
    print(await checkRust());
  }
  initializeTimeZones();
  await initializeDateFormatting();
  final container = ProviderContainer(
    overrides: [settingProvider.overrideWithValue(prefs)],
  );
  // On-screen dates and numbers follow the regional format through intl's
  // default locale. Stored values use InvariantFormats and ignore it.
  container.listen<String>(
    formatLocaleProvider,
    (_, formatLocale) => Intl.defaultLocale = formatLocale,
    fireImmediately: true,
  );
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AppExitHandler(child: NahpuApp()),
    ),
  );
}

class NahpuApp extends ConsumerWidget {
  const NahpuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    return MaterialApp(
      title: 'NAHPU',
      home: const Home(),
      locale: locale,
      // Listed first so a regional variant, such as en_GB, is kept as is
      // instead of resolving to its bare language.
      supportedLocales: [locale, ...AppLocalizations.supportedLocales],
      localizationsDelegates: nahpuLocalizationsDelegates,
      builder: (context, child) =>
          RegionalFormatRebuilder(child: child ?? const SizedBox.shrink()),
      debugShowCheckedModeBanner: false,
      theme: NahpuTheme.lightTheme(),
      darkTheme: NahpuTheme.darkTheme(),
      themeMode: ref
          .watch(themeSettingProvider)
          .when(
            data: (theme) => theme,
            loading: () => ThemeMode.system,
            error: (error, stackTrace) => ThemeMode.system,
          ),
    );
  }
}
