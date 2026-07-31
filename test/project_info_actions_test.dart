import 'package:flutter/material.dart';
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
          home: ProjectInfo(projectData: project, onEdit: () => edited = true),
        ),
      ),
    );

    expect(find.byType(ProjectQrIcon), findsNothing);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Export info'), findsOneWidget);

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
        child: const MaterialApp(home: ProjectInfo(projectData: project)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Catalog number'), findsNothing);
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

  testWidgets('new project form exposes Import JSON', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ImportJsonButton(onPressed: () {})),
    );

    expect(find.text('Import JSON'), findsOneWidget);
  });
}

class _TestFieldIdMode extends FieldIdModeNotifier {
  _TestFieldIdMode(this.mode);

  _TestFieldIdMode.personnel() : mode = FieldIdMode.personnel;

  _TestFieldIdMode.project() : mode = FieldIdMode.project;

  final FieldIdMode mode;

  @override
  Future<FieldIdMode> build() async => mode;
}
