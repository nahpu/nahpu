import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_list.dart';
import 'package:nahpu/screens/settings/application/application_settings.dart';
import 'package:nahpu/screens/settings/records/catalog_format.dart';
import 'package:nahpu/screens/settings/settings.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/file_explorer.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/file_explorer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wide screens keep the section list beside the open page; narrow screens
/// keep pushing each page.
void main() {
  late SharedPreferences prefs;
  late Database db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => db.close());

  Future<_PushCounter> pumpSettings(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final observer = _PushCounter();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
          appFileTreeProvider.overrideWith(_UnscannedTree.new),
        ],
        child: MaterialApp(
          navigatorObservers: [observer],
          home: const AppSettings(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return observer;
  }

  testWidgets('wide screens open settings pages beside the list', (
    tester,
  ) async {
    final observer = await pumpSettings(tester, const Size(1280, 2400));
    final initialPushes = observer.pushes;

    expect(find.byType(SettingsDetailPane), findsOneWidget);
    expect(find.byType(CatalogFmtSelection), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    expect(
      tester.widget<ListTile>(find.widgetWithText(ListTile, 'Format')).selected,
      isTrue,
    );

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();

    expect(find.byType(ThemeSettings), findsOneWidget);
    expect(find.byType(CatalogFmtSelection), findsNothing);
    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    expect(observer.pushes, initialPushes);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    expect(find.byType(ThemeSettings), findsOneWidget);
    expect(prefs.getString(themeModePrefKey), 'light');
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Light'),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Taxa'));
    await tester.pumpAndSettle();

    expect(observer.pushes, initialPushes + 1);
    expect(find.byType(ManageTaxa), findsOneWidget);
    expect(find.byType(SettingsDetailPane), findsNothing);
  });

  testWidgets('narrow screens push settings pages', (tester) async {
    final observer = await pumpSettings(tester, const Size(600, 2400));
    final initialPushes = observer.pushes;

    expect(find.byType(SettingsDetailPane), findsNothing);
    expect(find.byType(CatalogFmtSelection), findsNothing);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();

    expect(observer.pushes, initialPushes + 1);
    expect(find.byType(ThemeSettings), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(find.byType(ThemeSettings), findsNothing);
    expect(find.byType(SettingsSectionList), findsOneWidget);
  });
}

class _PushCounter extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }
}

/// Skips the real filesystem scan behind the Data usage tile.
class _UnscannedTree extends AppFileTreeNotifier {
  @override
  Future<AppFileTree> build() async => throw StateError('Not scanned');
}
