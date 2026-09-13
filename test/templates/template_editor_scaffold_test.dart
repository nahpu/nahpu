import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/components/canvas/template_canvas_workspace.dart';
import 'package:nahpu/screens/templates/components/controls/template_editor_toolbar.dart';
import 'package:nahpu/screens/templates/components/layout/template_editor_scaffold.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpScaffold(
    WidgetTester tester, {
    double width = 390,
    bool isBorderPanelOpen = false,
    List<String> savedNames = const ['Labels', 'Tags'],
    ValueChanged<String>? onTemplateSelected,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(const {});
    final preferences = await SharedPreferences.getInstance();
    final tabController = TabController(length: 2, vsync: const TestVSync());
    addTearDown(tabController.dispose);
    final template = DefaultTemplate.defaultTemplate('Labels');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          home: TemplateEditorScaffold(
            savedNames: savedNames,
            template: template,
            isDuplex: false,
            isPage1: true,
            mirrorFront: false,
            mirrorBack: false,
            templateWidthMm: template.widthMm,
            templateHeightMm: template.heightMm,
            isBorderPanelOpen: isBorderPanelOpen,
            showGrid: false,
            snapEnabled: false,
            canvasMovementLocked: false,
            selectedElement: null,
            tabController: tabController,
            zoom: 1,
            isPreviewMode: false,
            editorTemplateFieldPreview: const {},
            frontStackKey: GlobalKey(),
            backStackKey: GlobalKey(),
            templatePanGlobalDeltaToMm: (_, _, _, _) => null,
            fieldDisplayOption: 'short',
            canDeleteSavedTemplate: false,
            onCreateNewTemplate: () {},
            onSaveTemplate: () {},
            onSaveAsTemplate: () {},
            onImportTemplate: () {},
            onExportTemplate: () {},
            onDeleteTemplate: () {},
            onTemplateSelected: onTemplateSelected ?? (_) {},
            onTemplateSettingsPressed: () {},
            onPageChanged: (_) {},
            onTemplateSizeChanged: (_, _) {},
            onAddText: () {},
            onAddImage: () {},
            onAddLine: () {},
            onAddShape: () {},
            onMirrorToggled: () {},
            onBorderPanelToggled: () {},
            onGridToggled: () {},
            onSnapToggled: () {},
            onCanvasMovementLockToggled: () {},
            onSelectPreviewSpecimen: () {},
            onShowElements: () {},
            onClearSelection: () {},
            onSelectElement: (_) {},
            onStartInlineEditing: (_) {},
            onScheduleTemplateImageUpdate: (_, _) {},
            onRemoveCustomImage: (_, _) {},
            onScheduleTemplateTextPositionUpdate: (_, _) {},
            onScheduleTemplateLineUpdate: (_, _) {},
            onRemoveCustomLine: (_, _) {},
            onScheduleTemplateShapeUpdate: (_, _) {},
            onRemoveCustomShape: (_, _) {},
            onUpdateCustomText: (_, _) {},
            onDeleteCustomText: (_, _) {},
            onUpdateCustomImage: (_, _) {},
            onUpdateCustomLine: (_, _) {},
            onUpdateCustomShape: (_, _) {},
            onDismissProperties: () {},
            onZoomChanged: (_) {},
            onUndo: null,
            onRedo: null,
            canUndo: false,
            canRedo: false,
            onDuplicateElement: (_) {},
            onCopyElement: (_) {},
            onPasteElement: () {},
            canPasteElement: false,
            borderPanel: const SizedBox(
              key: ValueKey('border-panel'),
              height: 80,
              child: Text('Border panel'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('phone properties sit under the toolbar, not at the bottom', (
    tester,
  ) async {
    await pumpScaffold(tester, isBorderPanelOpen: true);

    expect(tester.widget<Scaffold>(find.byType(Scaffold)).bottomSheet, isNull);
    final panelTop = tester.getTopLeft(
      find.byKey(const ValueKey('border-panel')),
    );
    final toolbarBottom = tester
        .getBottomLeft(find.byType(TemplateEditorToolbar))
        .dy;
    final canvasTop = tester
        .getTopLeft(find.byType(TemplateCanvasWorkspace))
        .dy;
    expect(panelTop.dy, greaterThanOrEqualTo(toolbarBottom));
    expect(panelTop.dy, lessThan(canvasTop));
  });

  testWidgets('phones pick templates from the app bar title', (tester) async {
    final selected = <String>[];
    await pumpScaffold(tester, onTemplateSelected: selected.add);

    expect(find.text('Template Editor'), findsNothing);
    expect(find.text('Preset template'), findsNothing);

    await tester.tap(find.byTooltip('Choose template'));
    await tester.pumpAndSettle();

    expect(find.text('Templates'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.tap(find.text('Tags'));
    await tester.pumpAndSettle();

    expect(selected, ['Tags']);
  });

  testWidgets('wide screens keep the title and the template dropdown', (
    tester,
  ) async {
    await pumpScaffold(tester, width: 1000);

    expect(find.text('Template Editor'), findsOneWidget);
    expect(find.text('Preset template'), findsWidgets);
    expect(find.byTooltip('Choose template'), findsNothing);
  });
}
