import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/home/components/body.dart';
import 'package:nahpu/screens/projects/new_project.dart';
import 'package:nahpu/screens/projects/components/project_info.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  const project = ProjectData(
    uuid: 'uuid',
    name: 'Project',
    catalogNumberPrefix: 'P-',
    currentCatalogNumber: 12,
    catalogNumberSuffix: '-M',
  );

  testWidgets('project info shows text actions without embedding a QR', (
    tester,
  ) async {
    var edited = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fieldIdModeNotifierProvider.overrideWith(_TestFieldIdMode.personnel),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProjectInfo(
                projectData: project,
                onEdit: () => edited = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ProjectQrIcon), findsNothing);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Export info'), findsOneWidget);

    await tester.ensureVisible(find.text('Edit'));
    await tester.tap(find.text('Edit'));
    expect(edited, isTrue);
    expect(find.textContaining('Catalog number'), findsNothing);
  });

  testWidgets('project info omits project ID settings in project mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fieldIdModeNotifierProvider.overrideWith(_TestFieldIdMode.project),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProjectInfo(projectData: project),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Catalog number'), findsNothing);
  });

  testWidgets('project info groups fields and shows the full description', (
    tester,
  ) async {
    const description =
        'A detailed project description covering sampling goals, collection '
        'context, regional priorities, partner responsibilities, and the '
        'information needed to interpret the resulting specimen records.';
    const detailedProject = ProjectData(
      uuid: 'detailed-uuid',
      name: 'Detailed project',
      description: description,
      principalInvestigator: 'A. Researcher',
      accession: 'ACC-2026-1',
      location: 'Java, Indonesia',
      timeZone: 'Asia/Jakarta',
      startDate: '2026-01-01',
      endDate: '2026-02-01',
      created: '2026-01-01 08:00:00',
      lastAccessed: '2026-01-02 09:00:00',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectInfo(projectData: detailedProject),
          ),
        ),
      ),
    );

    expect(find.text('Identity'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Project details'), findsOneWidget);
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Record metadata'), findsOneWidget);
    final projectInfo = tester.widget<ProjectInfo>(find.byType(ProjectInfo));
    expect(projectInfo.useSectionContainers, isTrue);
    expect(_sectionContainers(find.byType(ProjectInfo)), findsNWidgets(5));
    final descriptionText = tester.widget<Text>(find.text(description));
    expect(descriptionText.maxLines, isNull);
    expect(descriptionText.overflow, isNull);
  });

  testWidgets('home project menu exposes Show QR', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ProjectPopUpMenu(
              project: ProjectSummary(
                uuid: 'uuid',
                name: 'Project',
                created: null,
                lastAccessed: null,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<MenuSelection>));
    await tester.pumpAndSettle();

    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Show QR'), findsOneWidget);
    expect(find.text('Export info'), findsOneWidget);
    expect(find.text('Edit info'), findsOneWidget);
    expect(find.byType(PopupMenuDivider), findsNWidgets(2));
  });

  testWidgets('new project form exposes project-info JSON import', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: ImportJsonButton(onPressed: () {})),
    );

    expect(find.text('Import project-info JSON'), findsOneWidget);
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

class _TestFieldIdMode extends FieldIdModeNotifier {
  _TestFieldIdMode(this.mode);

  _TestFieldIdMode.personnel() : mode = FieldIdMode.personnel;

  _TestFieldIdMode.project() : mode = FieldIdMode.project;

  final FieldIdMode mode;

  @override
  Future<FieldIdMode> build() async => mode;
}
