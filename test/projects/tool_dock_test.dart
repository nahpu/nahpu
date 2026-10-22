import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/components/tool_dock.dart';
import 'package:nahpu/screens/projects/specimen_check/specimen_check.dart';
import 'package:nahpu/screens/settings/application/project_tool_settings.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/project_tools.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> createContainer([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [settingProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> pump(
    WidgetTester tester,
    ProviderContainer container,
    Widget child,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ProjectTool', () {
    test('defaults to the data table and templates', () {
      expect(ProjectTool.decode(null), [
        ProjectTool.dataTable,
        ProjectTool.templates,
      ]);
    });

    test('decodes in dock order and skips unknown names', () {
      expect(ProjectTool.decode(['settings', 'removedTool', 'dataTable']), [
        ProjectTool.dataTable,
        ProjectTool.settings,
      ]);
    });

    test('an emptied list stays empty', () {
      expect(ProjectTool.decode(const []), isEmpty);
    });
  });

  group('projectToolsProvider', () {
    test('persists enabled tools and resets to defaults', () async {
      final container = await createContainer();
      final notifier = container.read(projectToolsProvider.notifier);

      await notifier.setEnabled(ProjectTool.backupDatabase, true);
      await notifier.setEnabled(ProjectTool.templates, false);
      expect(container.read(projectToolsProvider), [
        ProjectTool.dataTable,
        ProjectTool.backupDatabase,
      ]);
      final prefs = container.read(settingProvider);
      expect(prefs.getStringList(projectToolsPrefKey), [
        'dataTable',
        'backupDatabase',
      ]);

      await notifier.reset();
      expect(container.read(projectToolsProvider), ProjectTool.defaults);
      expect(prefs.getStringList(projectToolsPrefKey), isNull);
    });
  });

  testWidgets('specimen check opens its screen', (tester) async {
    Widget? screen;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          screen = const ProjectToolScreen(
            tool: ProjectTool.specimenCheck,
            projectUuid: 'project-a',
          ).build(context);
          return const SizedBox.shrink();
        },
      ),
    );
    expect(screen, isA<SpecimenCheckScreen>());
  });

  group('ToolDock', () {
    testWidgets('shows the default tools', (tester) async {
      final container = await createContainer();
      await pump(tester, container, const ToolDock());

      expect(find.text('Data table'), findsOneWidget);
      expect(find.text('Templates'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);
      // Only the divider before the edit launcher.
      expect(find.byType(ToolDockDivider), findsOneWidget);
    });

    testWidgets('adds a divider between categories', (tester) async {
      final container = await createContainer({
        projectToolsPrefKey: [
          'dataTable',
          'templates',
          'exportRecords',
          'exportDocuments',
          'settings',
        ],
      });
      await pump(tester, container, const ToolDock());

      // Utilities | records | configuration | edit.
      expect(find.byType(ToolDockDivider), findsNWidgets(3));
    });
  });

  testWidgets('settings switch adds a tool to the dock', (tester) async {
    final container = await createContainer();
    await pump(tester, container, const ProjectToolSettings());

    expect(find.text('Delete project'), findsNothing);
    await tester.tap(find.text('Merge project'));
    await tester.pumpAndSettle();

    expect(container.read(projectToolsProvider), [
      ProjectTool.dataTable,
      ProjectTool.templates,
      ProjectTool.mergeProject,
    ]);
  });
}
