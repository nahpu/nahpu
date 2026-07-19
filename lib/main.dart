import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nahpu/src/rust/api/common.dart';
import 'package:timezone/data/latest.dart';
import 'package:nahpu/src/rust/frb_generated.dart';
import 'package:nahpu/styles/themes.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nahpu/services/config_services.dart';
import 'package:pdfrx/pdfrx.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  final prefs = await SharedPreferences.getInstance();
  await RustLib.init();
  final configService = ConfigDbService();
  await configService.initDb();
  await configService.migrate(prefs);
  await configService.loadDefaultDocumentPresetsOnce(prefs);
  pdfrxFlutterInitialize();
  if (kDebugMode) {
    print(await checkRust());
  }
  initializeTimeZones();
  runApp(ProviderScope(
      overrides: [settingProvider.overrideWithValue(prefs)],
      child: const NahpuApp()));
}

class NahpuApp extends ConsumerWidget {
  const NahpuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'NAHPU',
      home: const Home(),
      debugShowCheckedModeBanner: false,
      theme: NahpuTheme.lightTheme(),
      darkTheme: NahpuTheme.darkTheme(),
      themeMode: ref.watch(themeSettingProvider).when(
            data: (theme) => theme,
            loading: () => ThemeMode.system,
            error: (error, stackTrace) => ThemeMode.system,
          ),
    );
  }
}
