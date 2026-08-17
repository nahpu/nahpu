import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/components/project_info.dart';
import 'package:nahpu/screens/projects/components/overview.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/record_exchange/project_exchange_service.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/styles/design_tokens.dart';

const _project = ProjectData(
  uuid: 'project-uuid',
  name: 'Field Project',
  description:
      'A complete project description with enough information to span '
      'multiple lines while remaining fully visible to project members.',
  principalInvestigator: 'A. Researcher',
  accession: 'ACC-2026-1',
  location: 'Java, Indonesia',
  timeZone: 'Asia/Jakarta',
  startDate: '2026-01-01',
  endDate: '2026-02-01',
  created: '2026-01-01 08:00:00',
  lastAccessed: '2026-01-02 09:00:00',
);

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
    _expectQrPayload(tester);

    final qrRect = tester.getRect(
      find.byKey(const ValueKey('project-overview-qr')),
    );
    final identityRect = tester.getRect(
      find.byKey(const ValueKey('project-info-identity')),
    );
    expect(qrRect.left, greaterThan(identityRect.center.dx));
    final identityDetailsRect = tester.getRect(find.text('Field Project'));
    expect(qrRect.top, closeTo(identityDetailsRect.top, 1));
    final qrCodeContainer = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(ProjectQrCode),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(qrCodeContainer.padding, EdgeInsets.all(NahpuSpacing.xs));
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
    _expectQrPayload(tester);

    final qrRect = tester.getRect(
      find.byKey(const ValueKey('project-overview-qr')),
    );
    final identityRect = tester.getRect(
      find.byKey(const ValueKey('project-info-identity')),
    );
    expect(qrRect.center.dx, closeTo(identityRect.center.dx, 1));
    expect(qrRect.bottom, lessThan(identityRect.top));
    expect(tester.takeException(), equals(null));
  });

  testWidgets('project overview QR opens the full-size dialog', (tester) async {
    await tester.pumpWidget(overview(useHorizontalLayout: false));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('project-overview-qr')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is ProjectQrCodeViewer && widget.isFullScreen,
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}

void _expectQrPayload(WidgetTester tester) {
  final qr = tester.widget<ProjectQrIcon>(
    find.byKey(const ValueKey('project-overview-qr')),
  );
  expect(qr.data, ProjectExchangeService.encodeQr(_project));
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
