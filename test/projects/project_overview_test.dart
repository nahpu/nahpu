import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/projects/components/project_info.dart';
import 'package:nahpu/screens/projects/components/overview.dart';
import 'package:nahpu/screens/shared/dialogs/qr_code_dialog.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/record_exchange/project_exchange_service.dart';
import 'package:nahpu/services/providers/database.dart';

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

    final qr = find.byType(ProjectQrIcon);
    final qrRect = tester.getRect(qr);
    final identitySection = _identitySection();
    final identityRect = tester.getRect(identitySection);
    final wideRow = find.ancestor(of: qr, matching: find.byType(Row));
    expect(wideRow, findsOneWidget);
    expect(
      find.descendant(of: wideRow, matching: find.text('Identity')),
      findsOneWidget,
    );
    expect(find.descendant(of: wideRow, matching: qr), findsOneWidget);
    expect(find.descendant(of: identitySection, matching: qr), findsNothing);
    expect(qrRect.left, greaterThan(identityRect.right));
    expect(qrRect.top, closeTo(identityRect.top, 1));
    final qrViewer = tester.widget<QrCodeViewer>(
      find.descendant(of: qr, matching: find.byType(QrCodeViewer)),
    );
    expect(qrViewer.maxSize, 112);
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
    expect(
      find.ancestor(of: find.byType(ProjectQrIcon), matching: find.byType(Row)),
      findsNothing,
    );
    expect(find.text('Record metadata'), findsOneWidget);
    _expectQrPayload(tester);

    final qrRect = tester.getRect(find.byType(ProjectQrIcon));
    final identityRect = tester.getRect(_identitySection());
    expect(qrRect.center.dx, closeTo(identityRect.center.dx, 1));
    expect(qrRect.bottom, lessThan(identityRect.top));
    expect(tester.takeException(), equals(null));
  });

  testWidgets('project overview QR opens the full-size dialog', (tester) async {
    await tester.pumpWidget(overview(useHorizontalLayout: false));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ProjectQrIcon));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(QrCodeDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(QrCodeDialog),
        matching: find.byType(QrCodeViewer),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}

void _expectQrPayload(WidgetTester tester) {
  final qr = tester.widget<ProjectQrIcon>(find.byType(ProjectQrIcon));
  expect(qr.data, ProjectExchangeService.encodeQr(_project));
}

Finder _identitySection() {
  return find.ancestor(
    of: find.text('Identity'),
    matching: find.byWidgetPredicate((widget) {
      if (widget is! Padding || widget.padding != const EdgeInsets.all(8)) {
        return false;
      }
      final child = widget.child;
      return child is Flex &&
          child.direction == Axis.vertical &&
          child.children.any(
            (child) => child is Text && child.data == 'Identity',
          );
    }),
  );
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
