import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/components/canvas/template_canvas_editor.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/styles/themes.dart';

void main() {
  testWidgets('uses NAHPU light surface around the canvas in dark mode',
      (tester) async {
    const template = Template(
      name: 'Test template',
      page1: TemplatePage(),
      page2: TemplatePage(),
      widthMm: 100,
      heightMm: 50,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: NahpuTheme.darkTheme(),
        home: Scaffold(
          body: SizedBox(
            width: 500,
            height: 300,
            child: TemplateCanvasEditor(
              page1: true,
              template: template,
              templateWidthMm: template.widthMm,
              templateHeightMm: template.heightMm,
              zoom: 1,
              canvasMovementLocked: false,
              showGrid: false,
              snapEnabled: false,
              mirrorFront: false,
              mirrorBack: false,
              isPreviewMode: false,
              editorTemplateFieldPreview: const {},
              selectedElement: null,
              templateStackKey: GlobalKey(),
              templatePanGlobalDeltaToMm: (
                stackKey,
                globalPosition,
                globalDelta,
                scale,
              ) =>
                  null,
              onClearSelection: () {},
              onSelectElement: (_) {},
              onStartInlineEditing: (_) {},
              onScheduleTemplateImageUpdate: (_) {},
              onRemoveCustomImage: (_) {},
              onScheduleTemplateTextPositionUpdate: (_) {},
              onScheduleTemplateLineUpdate: (_) {},
              onRemoveCustomLine: (_) {},
              onScheduleTemplateShapeUpdate: (_) {},
              onRemoveCustomShape: (_) {},
              onZoomChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final workspace = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('template-canvas-workspace')),
    );
    expect(workspace.color, NahpuTheme.lightTheme().colorScheme.surface);
  });
}
