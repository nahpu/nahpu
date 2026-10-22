import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/data_table_screen.dart';
import 'package:nahpu/screens/home/components/global_search.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/database/app_exit.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/providers/data_table.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final loads = <(DataTableRecordType, DataTableQuery)>[];

  Future<void> pumpSearch(WidgetTester tester) async {
    loads.clear();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final database = Database.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
    addTearDown(database.close);
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appExitCoordinatorProvider.overrideWithValue(AppExitCoordinator()),
          databaseProvider.overrideWithValue(database),
          settingProvider.overrideWithValue(prefs),
          projectListProvider.overrideWith(
            (ref) async => const [
              ProjectSummary(
                uuid: 'p1',
                name: 'Ridge survey',
                created: null,
                lastAccessed: null,
              ),
              ProjectSummary(
                uuid: 'p2',
                name: 'Valley survey',
                created: null,
                lastAccessed: null,
              ),
            ],
          ),
          dataTablePageLoaderProvider.overrideWithValue((
            ref,
            type,
            query,
            specimenType,
          ) {
            loads.add((type, query));
            return Future.value(
              DataTablePageData(
                columns: dataTableColumnsFromHeader(const ['site::site']),
                rows: const [],
                totalRows: 0,
                page: 0,
                pageCount: 1,
                rowsPerPage: query.rowsPerPage,
              ),
            );
          }),
        ],
        child: MaterialApp(
          home: Scaffold(appBar: AppBar(actions: const [GlobalSearchButton()])),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('home-global-search')));
    await tester.pumpAndSettle();
  }

  testWidgets('search opens the data table across the picked projects', (
    tester,
  ) async {
    await pumpSearch(tester);

    expect(find.text('Search records'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('global-search-field')),
      ' Maxomys ',
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'Sites'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Valley survey'));
    await tester.tap(find.widgetWithText(FilterChip, 'No coordinates'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('global-search-submit')));
    await tester.pumpAndSettle();

    expect(find.byType(DataTableScreen), findsOneWidget);
    final (type, query) = loads.last;
    expect(type, DataTableRecordType.sites);
    expect(query.search, 'Maxomys');
    expect(query.allProjects, isTrue);
    expect(query.projectUuids, {'p2'});
    expect(query.quickFilters, {DataTableQuickFilter.noCoordinates});

    // The project limit shows as a chip, and removing it searches every
    // project.
    final chip = find.byKey(const ValueKey('data-table-project-scope'));
    expect(
      find.descendant(of: chip, matching: find.text('Project: Valley survey')),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(of: chip, matching: find.byIcon(Icons.clear)),
    );
    await tester.pumpAndSettle();
    expect(chip, findsNothing);
    expect(loads.last.$2.projectUuids, isEmpty);
    expect(loads.last.$2.allProjects, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing the record type swaps its quick filters', (
    tester,
  ) async {
    await pumpSearch(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Missing taxon'));
    await tester.pumpAndSettle();
    expect(find.text('Taxa'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Events'));
    await tester.pumpAndSettle();
    expect(find.text('Missing taxon'), findsNothing);
    expect(find.text('Taxa'), findsNothing);
    expect(find.text('No end date'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('global-search-submit')));
    await tester.pumpAndSettle();
    final (type, query) = loads.last;
    expect(type, DataTableRecordType.events);
    expect(query.quickFilters, isEmpty);
    expect(query.projectUuids, isEmpty);
  });
}
