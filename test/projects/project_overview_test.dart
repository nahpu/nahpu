import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/components/project_info.dart';
import 'package:nahpu/screens/projects/components/overview.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/providers/database.dart';

void main() {
  late Database database;

  setUp(() async {
    database = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    await ProjectQuery(database).createProject(
      const ProjectCompanion(
        uuid: Value('project-uuid'),
        name: Value('Field Project'),
        description: Value(
          'A complete project description with enough information to span '
          'multiple lines while remaining fully visible to project members.',
        ),
        principalInvestigator: Value('A. Researcher'),
        accession: Value('ACC-2026-1'),
        location: Value('Java, Indonesia'),
        timeZone: Value('Asia/Jakarta'),
        startDate: Value('2026-01-01'),
        endDate: Value('2026-02-01'),
        created: Value('2026-01-01 08:00:00'),
        lastAccessed: Value('2026-01-02 09:00:00'),
      ),
    );
  });

  tearDown(() => database.close());

  Widget overview({required bool useHorizontalLayout}) {
    return ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        home: Scaffold(
          body: useHorizontalLayout
              ? Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 500,
                    height: 470,
                    child: ProjectOverview(
                      projectUuid: 'project-uuid',
                      useHorizontalLayout: true,
                      onEdit: () {},
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: ProjectOverview(
                    projectUuid: 'project-uuid',
                    useHorizontalLayout: false,
                    onEdit: () {},
                  ),
                ),
        ),
      ),
    );
  }

  testWidgets('wide project overview scrolls within its fixed-height panel', (
    tester,
  ) async {
    await tester.pumpWidget(overview(useHorizontalLayout: true));
    await tester.pumpAndSettle();

    final overviewScroll = find.byKey(
      const ValueKey('project-overview-scroll'),
    );
    expect(overviewScroll, findsOneWidget);
    final projectInfo = tester.widget<ProjectInfo>(find.byType(ProjectInfo));
    expect(projectInfo.useSectionContainers, isFalse);
    expect(_sectionContainers(find.byType(ProjectInfo)), findsNothing);
    final scrollable = find.descendant(
      of: overviewScroll,
      matching: find.byType(Scrollable),
    );
    expect(
      tester.state<ScrollableState>(scrollable.first).position.maxScrollExtent,
      greaterThan(0),
    );
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Export info'), findsOneWidget);
    expect(
      find.descendant(of: overviewScroll, matching: find.text('Edit')),
      findsNothing,
    );
    expect(
      find.descendant(of: overviewScroll, matching: find.text('Export info')),
      findsNothing,
    );
    await tester.drag(overviewScroll, const Offset(0, -200));
    await tester.pump();
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Export info'), findsOneWidget);
    expect(tester.takeException(), equals(null));
  });

  testWidgets('narrow project overview keeps its internal scroll', (
    tester,
  ) async {
    await tester.pumpWidget(overview(useHorizontalLayout: false));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('project-overview-scroll')),
      findsOneWidget,
    );
    expect(find.text('Record metadata'), findsOneWidget);
    expect(tester.takeException(), equals(null));
  });
}

Finder _sectionContainers(Finder ancestor) {
  return find.descendant(
    of: ancestor,
    matching: find.byWidgetPredicate((widget) {
      if (widget is! Container || widget.decoration is! BoxDecoration) {
        return false;
      }
      final decoration = widget.decoration! as BoxDecoration;
      return decoration.border != null &&
          decoration.borderRadius == BorderRadius.circular(16);
    }),
  );
}
