import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/home/components/body.dart';
import 'package:nahpu/screens/home/components/menu_drawer.dart';
import 'package:nahpu/screens/settings/setup_wizard.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Database database;
  late SharedPreferences preferences;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    SharedPreferences.setMockInitialValues(const {});
    preferences = await SharedPreferences.getInstance();
  });

  tearDown(() => database.close());

  /// The step rail only appears past [NahpuBreakpoints.projectWizardRail], and
  /// the default test surface is narrower than that.
  void useWideSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpWizard(
    WidgetTester tester, {
    CatalogFmt catalogFmt = CatalogFmt.mammals,
    FieldIdMode fieldIdMode = FieldIdMode.personnel,
  }) async {
    useWideSurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          settingProvider.overrideWithValue(preferences),
          catalogFmtNotifierProvider.overrideWith(
            () => _TestCatalogFormat(catalogFmt),
          ),
          fieldIdModeNotifierProvider.overrideWith(
            () => _TestFieldIdMode(fieldIdMode),
          ),
        ],
        child: const MaterialApp(home: SetupWizardScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The rail refuses jumps past [maxVisitedStep], so steps are reached the
  /// way a user reaches them.
  Future<void> advance(WidgetTester tester, int steps) async {
    for (var i = 0; i < steps; i++) {
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('welcome explains the wizard and offers a skip', (tester) async {
    await pumpWizard(tester);

    expect(find.text('Set up NAHPU'), findsOneWidget);
    expect(find.textContaining('Every answer can be changed'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Skip setup'), findsOneWidget);
  });

  testWidgets('skipping from the welcome step closes the wizard', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          settingProvider.overrideWithValue(preferences),
          catalogFmtNotifierProvider.overrideWith(
            () => _TestCatalogFormat(CatalogFmt.mammals),
          ),
          fieldIdModeNotifierProvider.overrideWith(
            () => _TestFieldIdMode(FieldIdMode.personnel),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const SetupWizardScreen(),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Set up NAHPU'), findsOneWidget);

    await tester.tap(find.text('Skip setup'));
    await tester.pumpAndSettle();

    expect(find.text('Set up NAHPU'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('a parasite-capable format keeps the parasite step', (
    tester,
  ) async {
    await pumpWizard(tester, catalogFmt: CatalogFmt.mammals);

    expect(find.widgetWithText(ListTile, 'Parasites'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Specimens'), findsOneWidget);
  });

  testWidgets('arthropods drop the parasite step from the rail', (
    tester,
  ) async {
    await pumpWizard(tester, catalogFmt: CatalogFmt.arthropods);

    expect(find.widgetWithText(ListTile, 'Parasites'), findsNothing);
    expect(find.widgetWithText(ListTile, 'Specimens'), findsOneWidget);
  });

  testWidgets('the identifier step offers both ID schemes with their art', (
    tester,
  ) async {
    await pumpWizard(tester);
    await advance(tester, 2);

    expect(find.text('Personnel ID'), findsOneWidget);
    expect(find.text('Project ID'), findsOneWidget);
    // The cataloger/collector distinction is the point of the step.
    expect(find.textContaining('often called a collector'), findsOneWidget);
    expect(
      find.textContaining('changed for a different project'),
      findsOneWidget,
    );
  });

  testWidgets('choosing project ID writes the field ID mode', (tester) async {
    await pumpWizard(tester);
    await advance(tester, 2);

    final radios = tester
        .widgetList<Radio<FieldIdMode>>(find.byType(Radio<FieldIdMode>))
        .toList();
    expect(radios.map((e) => e.value), [
      FieldIdMode.personnel,
      FieldIdMode.project,
    ]);

    await tester.tap(find.text('Project ID'));
    await tester.pumpAndSettle();

    final group = RadioGroup.maybeOf<FieldIdMode>(
      tester.element(find.byType(Radio<FieldIdMode>).first),
    );
    expect(group?.groupValue, FieldIdMode.project);
  });

  testWidgets('the tissue question reveals the prefix and number fields', (
    tester,
  ) async {
    await pumpWizard(tester);
    await advance(tester, 2);

    expect(find.widgetWithText(TextField, 'Prefix'), findsNothing);

    await tester.tap(find.text('Use a separate tissue ID'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Prefix'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Tissue number'), findsOneWidget);
    expect(preferences.getBool('usesSeparateTissueId'), isTrue);
  });

  testWidgets('vocabulary steps follow sites, events, then specimens', (
    tester,
  ) async {
    await pumpWizard(tester);

    final railTitles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.title! as Text).data)
        .toList();

    expect(railTitles, [
      'Welcome',
      'Catalog format',
      'Identifiers',
      'Sites',
      'Events',
      'Specimens',
      'Parasites',
      'Finish',
    ]);
  });

  testWidgets('the empty project list offers the wizard', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          settingProvider.overrideWithValue(preferences),
          catalogFmtNotifierProvider.overrideWith(
            () => _TestCatalogFormat(CatalogFmt.mammals),
          ),
          fieldIdModeNotifierProvider.overrideWith(
            () => _TestFieldIdMode(FieldIdMode.personnel),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: ProjectNotFound())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No projects found.'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Setup NAHPU'));
    await tester.pumpAndSettle();

    expect(find.text('Set up NAHPU'), findsOneWidget);
  });

  testWidgets('the home drawer shows Setup NAHPU above How-to recipes', (
    tester,
  ) async {
    useWideSurface(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          settingProvider.overrideWithValue(preferences),
        ],
        child: const MaterialApp(
          home: Scaffold(drawer: HomeMenuDrawer(), body: SizedBox()),
        ),
      ),
    );
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();

    final setup = tester.getTopLeft(find.text('Setup NAHPU')).dy;
    final recipes = tester.getTopLeft(find.text('How-to recipes')).dy;
    expect(setup, lessThan(recipes));
  });
}

class _TestCatalogFormat extends CatalogFmtNotifier {
  _TestCatalogFormat(this._value);

  final CatalogFmt _value;

  @override
  Future<CatalogFmt> build() async => _value;
}

class _TestFieldIdMode extends FieldIdModeNotifier {
  _TestFieldIdMode(this._value);

  FieldIdMode _value;

  @override
  Future<FieldIdMode> build() async => _value;

  @override
  Future<void> set(FieldIdMode mode) async {
    _value = mode;
    state = AsyncValue.data(mode);
  }
}
