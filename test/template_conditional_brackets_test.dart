import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/components/canvas/template_canvas_editor.dart';
import 'package:nahpu/screens/templates/components/properties/text_properties_panel.dart';
import 'package:nahpu/screens/templates/template_live_preview.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  late Database db;

  setUp(() {
    db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() => db.close());

  testWidgets('template mammal accuracy condition auto-configures contains', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const text = CustomTextElement(
      id: 'conditional',
      text: '[tailLength]',
      xMm: 0,
      yMm: 0,
    );
    const template = Template(
      name: 'Mammal label',
      page1: TemplatePage(customTexts: [text]),
      page2: TemplatePage(),
      widthMm: 50,
      heightMm: 25,
      recordType: RecordType.specimenRecord,
    );
    CustomTextElement? updated;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: TextPropertiesPanel(
              selectedElement: 'custom:1:conditional',
              page1: true,
              template: template,
              onUpdateCustomText: (_, value) => updated = value,
              onDeleteCustomText: (_, _) {},
              actionControls: const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Text formatting options'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Conditional brackets'));
    await tester.pumpAndSettle();
    final controllingField = find.byWidgetPredicate(
      (widget) =>
          widget is InputDecorator &&
          widget.decoration.labelText == 'Controlling field',
    );
    expect(controllingField, findsOneWidget);
    await tester.tap(controllingField);
    await tester.pumpAndSettle();

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Search fields or tables',
    );
    await tester.enterText(searchField, 'accuracy');
    await tester.pumpAndSettle();
    await tester.tap(find.text('accuracy').last);
    await tester.pumpAndSettle();

    expect(find.text('Contains'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'tailLength'), findsWidgets);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(
      updated?.text,
      '[[tailLength][mammalAttribute::accuracy~="tailLength"]]',
    );
  });

  testWidgets('template live preview renders conditional brackets', (
    tester,
  ) async {
    const template = Template(
      name: 'Conditional preview',
      page1: TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'conditional-preview',
            text: 'TTL: [[totalLength][accuracy=="Tail cropped"]] mm',
            xMm: 0,
            yMm: 0,
          ),
        ],
      ),
      page2: TemplatePage(),
      widthMm: 50,
      heightMm: 25,
      recordType: RecordType.specimenRecord,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TemplateLivePreview(
            viewportSize: const Size(500, 300),
            showHeading: false,
            template: template,
            isDuplex: false,
            mirrorFront: false,
            mirrorBack: false,
            templateWidthMm: 50,
            templateHeightMm: 25,
            placeholderValues: const {
              'mammalAttribute::totalLength': '123',
              'mammalAttribute::accuracy': 'Tail cropped',
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TTL: [123] mm'), findsOneWidget);
    expect(find.textContaining('[['), findsNothing);
  });

  testWidgets('template canvas preview resolves values and blank fallbacks', (
    tester,
  ) async {
    const template = Template(
      name: 'Conditional canvas',
      page1: TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'conditional-canvas',
            text: 'TTL: [[totalLength][accuracy=="Tail cropped"]] mm',
            xMm: 0,
            yMm: 0,
          ),
        ],
      ),
      page2: TemplatePage(),
      widthMm: 50,
      heightMm: 25,
      recordType: RecordType.specimenRecord,
    );

    await tester.pumpWidget(
      _canvasPreview(template, const {
        'mammalAttribute::totalLength': '123',
        'mammalAttribute::accuracy': 'Tail cropped',
      }),
    );
    await tester.pumpAndSettle();

    expect(find.text('TTL: [123] mm'), findsOneWidget);
    expect(find.textContaining('totalLength'), findsNothing);

    await tester.pumpWidget(_canvasPreview(template, const {}));
    await tester.pumpAndSettle();

    expect(find.text('TTL:  mm'), findsOneWidget);
    expect(find.textContaining('totalLength'), findsNothing);
  });

  testWidgets('template live preview blanks missing conditional values', (
    tester,
  ) async {
    const template = Template(
      name: 'Conditional blank preview',
      page1: TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'conditional-blank-preview',
            text: 'TTL: [[totalLength][accuracy=="Tail cropped"]] mm',
            xMm: 0,
            yMm: 0,
          ),
        ],
      ),
      page2: TemplatePage(),
      widthMm: 50,
      heightMm: 25,
      recordType: RecordType.specimenRecord,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TemplateLivePreview(
            viewportSize: Size(500, 300),
            showHeading: false,
            template: template,
            isDuplex: false,
            mirrorFront: false,
            mirrorBack: false,
            templateWidthMm: 50,
            templateHeightMm: 25,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TTL:  mm'), findsOneWidget);
    expect(find.textContaining('totalLength'), findsNothing);
  });
}

Widget _canvasPreview(Template template, Map<String, String> values) {
  return MaterialApp(
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
          isPreviewMode: true,
          editorTemplateFieldPreview: values,
          selectedElement: null,
          templateStackKey: GlobalKey(),
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
  );
}
