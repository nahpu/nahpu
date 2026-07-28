import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/home/components/body.dart';
import 'package:nahpu/screens/projects/new_project.dart';
import 'package:nahpu/screens/projects/components/project_info.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';

void main() {
  const project = ProjectData(uuid: 'uuid', name: 'Project');

  testWidgets('project info shows text actions without embedding a QR', (
    tester,
  ) async {
    var edited = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ProjectInfo(projectData: project, onEdit: () => edited = true),
      ),
    );

    expect(find.byType(ProjectQrIcon), findsNothing);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Export info'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    expect(edited, isTrue);
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
