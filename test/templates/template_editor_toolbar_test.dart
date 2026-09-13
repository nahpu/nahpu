import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/components/controls/template_editor_toolbar.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues(const {});
    preferences = await SharedPreferences.getInstance();
  });

  Future<void> pumpToolbar(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final template = DefaultTemplate.defaultTemplate('Labels');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingProvider.overrideWithValue(preferences)],
        child: MaterialApp(
          home: Scaffold(
            body: TemplateEditorToolbar(
              savedNames: const ['Labels'],
              template: template,
              isDuplex: false,
              isPage1: true,
              mirrorFront: false,
              mirrorBack: false,
              templateWidthMm: template.widthMm,
              templateHeightMm: template.heightMm,
              isBorderPanelOpen: false,
              showGrid: false,
              snapEnabled: false,
              canvasMovementLocked: false,
              onSaveTemplate: () {},
              onTemplateSelected: (_) {},
              onTemplateSettingsPressed: () {},
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
              onUndo: () {},
              onRedo: () {},
              canUndo: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder groupControl() =>
      find.byWidgetPredicate((widget) => widget is SegmentedButton);

  Finder sidewaysScroll() => find.byWidgetPredicate(
    (widget) =>
        widget is SingleChildScrollView &&
        widget.scrollDirection == Axis.horizontal,
  );

  testWidgets('phones show tool groups instead of a sideways strip', (
    tester,
  ) async {
    await pumpToolbar(tester, 390);

    expect(groupControl(), findsOneWidget);
    for (final label in ['Add', 'Page', 'View', 'Template']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(sidewaysScroll(), findsNothing);
    // The template picker lives in the app bar on phones.
    expect(find.text('Preset template'), findsNothing);
    expect(find.byTooltip('Elements'), findsOneWidget);
    expect(find.byTooltip('Add text'), findsOneWidget);
    expect(find.byTooltip('Show grid'), findsNothing);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Redo'), findsOneWidget);

    await tester.tap(find.text('View'));
    await tester.pump();

    expect(find.byTooltip('Add text'), findsNothing);
    expect(find.byTooltip('Show grid'), findsOneWidget);
    expect(find.byTooltip('Enable snap'), findsOneWidget);
    expect(find.byTooltip('Lock canvas movement'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);

    await tester.tap(find.text('Template'));
    await tester.pump();

    expect(find.byTooltip('Save template'), findsOneWidget);
    expect(find.byTooltip('Template settings'), findsOneWidget);
  });

  testWidgets('wide screens keep the single tool row', (tester) async {
    await pumpToolbar(tester, 1000);

    expect(groupControl(), findsNothing);
    expect(sidewaysScroll(), findsOneWidget);
    expect(find.text('Preset template'), findsWidgets);
    expect(find.byTooltip('Elements'), findsOneWidget);
    for (final tooltip in [
      'Add text',
      'Template border',
      'Show grid',
      'Save template',
      'Template settings',
      'Undo',
    ]) {
      expect(find.byTooltip(tooltip), findsOneWidget, reason: tooltip);
    }
  });
}
