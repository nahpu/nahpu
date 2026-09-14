import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/components/canvas/template_canvas_editor.dart';
import 'package:nahpu/screens/templates/components/controls/zoom_controls.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/canvas_viewport_service.dart';

void main() {
  const letter = Template(
    name: 'Letter',
    page1: TemplatePage(),
    page2: TemplatePage(),
    widthMm: 216,
    heightMm: 279,
  );

  /// Pumps the canvas in a [workspace]-sized box at the top-left of the screen
  /// and returns the key of its template stack.
  Future<GlobalKey> pumpCanvas(
    WidgetTester tester, {
    required Size workspace,
    double zoom = 1,
  }) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final stackKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox.fromSize(
              size: workspace,
              child: TemplateCanvasEditor(
                page1: true,
                template: letter,
                templateWidthMm: letter.widthMm,
                templateHeightMm: letter.heightMm,
                zoom: zoom,
                canvasMovementLocked: false,
                showGrid: false,
                snapEnabled: false,
                mirrorFront: false,
                mirrorBack: false,
                isPreviewMode: false,
                editorTemplateFieldPreview: const {},
                selectedElement: null,
                templateStackKey: stackKey,
                templatePanGlobalDeltaToMm: (_, _, _, _) => null,
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
      ),
    );
    // Centring is applied after the first frame.
    await tester.pump();
    return stackKey;
  }

  /// Centre of the fit area inside a workspace of [size].
  Offset fitCenter(Size size) => Offset(
    size.width / 2,
    TemplateCanvasViewportService.margin +
        (size.height -
                TemplateCanvasViewportService.margin -
                TemplateCanvasViewportService.bottomControlsReserve) /
            2,
  );

  for (final workspace in const [Size(390, 600), Size(1100, 800)]) {
    testWidgets('a letter page opens centred and fitted in $workspace', (
      tester,
    ) async {
      final stackKey = await pumpCanvas(tester, workspace: workspace);

      // An empty page has equal hit padding on every side, so the stack and
      // the page share a centre.
      final center = tester.getCenter(find.byKey(stackKey));
      expect(center.dx, closeTo(fitCenter(workspace).dx, 1));
      expect(center.dy, closeTo(fitCenter(workspace).dy, 1));

      final scale = TemplateCanvasViewportService.fitScale(
        viewport: workspace,
        templateWidthMm: letter.widthMm,
        templateHeightMm: letter.heightMm,
      );
      final pageWidth = letter.widthMm * scale;
      final pageHeight = letter.heightMm * scale;
      expect(pageWidth, lessThanOrEqualTo(workspace.width - 32 + 0.01));
      expect(
        pageHeight,
        lessThanOrEqualTo(
          workspace.height -
              TemplateCanvasViewportService.margin -
              TemplateCanvasViewportService.bottomControlsReserve +
              0.01,
        ),
      );
    });
  }

  testWidgets('a zoomed page stays centred', (tester) async {
    const workspace = Size(390, 600);
    final stackKey = await pumpCanvas(tester, workspace: workspace, zoom: 2);

    final center = tester.getCenter(find.byKey(stackKey));
    expect(center.dx, closeTo(fitCenter(workspace).dx, 1));
    expect(center.dy, closeTo(fitCenter(workspace).dy, 1));
  });

  testWidgets('tapping the zoom percentage fits the template', (tester) async {
    var fits = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ZoomControls(
              zoom: 1.5,
              onZoomChanged: (_) {},
              onFitToScreen: () => fits++,
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Fit to screen'), findsOneWidget);
    await tester.tap(find.text('150%'));
    expect(fits, 1);
  });
}
