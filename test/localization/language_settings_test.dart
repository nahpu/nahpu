import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/application/application_settings.dart';
import 'package:nahpu/screens/settings/settings_destination.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/localization/app_language.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/providers/file_explorer.dart';
import 'package:nahpu/services/providers/localization.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/file_explorer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nahpu/services/localization/regional_format.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/screens/shared/layout/regional_format_rebuilder.dart';
import 'package:nahpu/screens/home/components/project_actions.dart';

void main() {
  setUpAll(initializeDateFormatting);

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  Widget app(SharedPreferences prefs, Widget home) {
    return ProviderScope(
      overrides: [
        settingProvider.overrideWithValue(prefs),
        deviceLocalesProvider.overrideWithValue(const [Locale('en', 'US')]),
        appFileTreeProvider.overrideWith(_UnscannedTree.new),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final locale = ref.watch(appLocaleProvider);
          return MaterialApp(
            locale: locale,
            supportedLocales: [locale, ...AppLocalizations.supportedLocales],
            localizationsDelegates: nahpuLocalizationsDelegates,
            builder: (context, child) => RegionalFormatRebuilder(child: child!),
            home: home,
          );
        },
      ),
    );
  }

  Widget applicationSettings() {
    return Scaffold(
      body: SingleChildScrollView(
        child: ApplicationSettings(selected: null, onOpen: (_) {}),
      ),
    );
  }

  testWidgets('language picker marks translations as beta', (tester) async {
    final prefs = await prefsWith({});
    await tester.pumpWidget(app(prefs, const LanguageSettings()));

    final note = find.byKey(const ValueKey('language-beta-note'));
    expect(note, findsOneWidget);
    expect(
      tester.getTopLeft(note).dy,
      greaterThan(
        tester.getTopLeft(find.byKey(const ValueKey('language-id'))).dy,
      ),
      reason: 'the beta note sits below the language list',
    );
    expect(
      find.descendant(
        of: note,
        matching: find.byKey(const ValueKey('language-help-translate')),
      ),
      findsOneWidget,
    );
    for (final code in ['pt', 'es', 'id']) {
      expect(
        find.descendant(
          of: find.byKey(ValueKey('language-$code')),
          matching: find.byType(BetaBadge),
        ),
        findsOneWidget,
        reason: code,
      );
    }
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('language-en')),
        matching: find.byType(BetaBadge),
      ),
      findsNothing,
    );
  });

  testWidgets('choosing a language saves it and relabels settings', (
    tester,
  ) async {
    final prefs = await prefsWith({});
    await tester.pumpWidget(app(prefs, const LanguageSettings()));

    await tester.tap(find.byKey(const ValueKey('language-id')));
    await tester.pumpAndSettle();
    expect(prefs.getString(appLanguagePrefKey), 'id');

    await tester.pumpWidget(app(prefs, applicationSettings()));
    await tester.pumpAndSettle();
    expect(find.text('Bahasa'), findsOneWidget);
    expect(find.text('Format regional'), findsOneWidget);
    // The language tile keeps its beta badge in every language.
    expect(find.text('Beta'), findsOneWidget);
  });

  testWidgets('regional format changes dates but not labels', (tester) async {
    final prefs = await prefsWith({
      appLanguagePrefKey: 'en',
      regionalFormatPrefKey: 'id_ID',
    });
    await tester.pumpWidget(app(prefs, const RegionalFormatSettings()));

    final today = DateFormat.yMMMd('id_ID').format(DateTime.now());
    expect(find.text('Regional format'), findsWidgets);
    expect(find.textContaining('Example: $today · 1.234,5'), findsOneWidget);

    await tester.pumpWidget(app(prefs, applicationSettings()));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    // The choice sits under the title, which keeps the full width.
    expect(find.text('Bahasa Indonesia (Indonesia)'), findsOneWidget);
  });

  testWidgets('changing the region redraws dates in place', (tester) async {
    final previous = Intl.defaultLocale;
    addTearDown(() => Intl.defaultLocale = previous);
    // main() sets the starting locale; the rebuilder handles changes.
    Intl.defaultLocale = 'en';
    final prefs = await prefsWith({appLanguagePrefKey: 'en'});
    await tester.pumpWidget(app(prefs, const Scaffold(body: _StoredDate())));
    expect(find.text('Mar 18, 2024'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(_StoredDate)),
    );
    await container
        .read(regionalFormatSettingProvider.notifier)
        .set(RegionalFormat.tryParse('en_GB'));
    await tester.pump();

    expect(find.text('18 Mar 2024'), findsOneWidget);
  });

  testWidgets('home quick actions follow the UI language', (tester) async {
    final prefs = await prefsWith({appLanguagePrefKey: 'id'});
    await tester.pumpWidget(
      app(
        prefs,
        const Scaffold(
          body: HomeProjectActions(layout: ProjectActionLayout.compact),
        ),
      ),
    );

    expect(find.text('Buat proyek'), findsOneWidget);
    expect(find.text('Impor proyek'), findsOneWidget);
    expect(find.text('Statistik'), findsOneWidget);
  });

  test('a region in the UI language joins the app locale', () async {
    final prefs = await prefsWith({
      appLanguagePrefKey: 'en',
      regionalFormatPrefKey: 'en_GB',
    });
    final container = ProviderContainer(
      overrides: [settingProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(appLocaleProvider), const Locale('en', 'GB'));
    expect(container.read(formatLocaleProvider), 'en_GB');

    await container
        .read(appLanguageSettingProvider.notifier)
        .set(AppLanguage.spanish);
    // Spanish labels keep the British date format.
    expect(container.read(appLocaleProvider), const Locale('es'));
    expect(container.read(formatLocaleProvider), 'en_GB');

    await container.read(regionalFormatSettingProvider.notifier).set(null);
    expect(container.read(formatLocaleProvider), 'es');
    expect(prefs.containsKey(regionalFormatPrefKey), isFalse);
  });

  test('settings destinations include language and regional format', () {
    expect(SettingsDestination.language.opensInPane, isTrue);
    expect(SettingsDestination.regionalFormat.opensInPane, isTrue);
  });
}

/// Keeps the data usage tile from scanning the app folders.
class _UnscannedTree extends AppFileTreeNotifier {
  @override
  Future<AppFileTree> build() async => throw StateError('Not scanned');
}

/// Formats a stored date the way record screens do, with no context, so it
/// redraws only when something rebuilds it.
class _StoredDate extends StatelessWidget {
  const _StoredDate();

  @override
  Widget build(BuildContext context) {
    return Text(dateStdToDateDisplay('2024-03-18') ?? '');
  }
}
