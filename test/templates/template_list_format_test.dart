import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/components/canvas/template_canvas_editor.dart';
import 'package:nahpu/screens/templates/components/properties/text_properties_panel.dart';
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

  test('legacy template list formats load as pipe', () {
    CustomTextElement restoreWith([String? formatOption]) {
      return CustomTextElement.fromJson({
        'id': 'list',
        'text': '[site::habitatType]',
        'xMm': 0,
        'yMm': 0,
        'textType': 'list',
        'formatOption': ?formatOption,
      });
    }

    expect(restoreWith().formatOption, 'pipe');
    expect(restoreWith('normal').formatOption, 'pipe');
    expect(restoreWith('custom: - ').formatOption, 'custom: - ');
  });

  testWidgets('template editor preserves custom separator whitespace', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const listText = CustomTextElement(
      id: 'list',
      text: '[site::habitatType]',
      xMm: 0,
      yMm: 0,
      textType: 'list',
      formatOption: 'custom:',
    );
    const template = Template(
      name: 'List template',
      page1: TemplatePage(customTexts: [listText]),
      page2: TemplatePage(),
      widthMm: 50,
      heightMm: 25,
      recordType: RecordType.site,
    );
    CustomTextElement? updated;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: TextPropertiesPanel(
              selectedElement: 'custom:1:list',
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
    await tester.enterText(
      find.byKey(const ValueKey('list-custom-separator-list')),
      ' - ',
    );
    await tester.pump();

    expect(updated?.formatOption, 'custom: - ');
  });

  testWidgets('template canvas formats compact repeated values', (
    tester,
  ) async {
    const template = Template(
      name: 'List preview',
      page1: TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'list',
            text: '[site::habitatType]',
            xMm: 0,
            yMm: 0,
            textType: 'list',
            formatOption: 'comma',
          ),
        ],
      ),
      page2: TemplatePage(),
      widthMm: 50,
      heightMm: 25,
      recordType: RecordType.site,
    );

    await tester.pumpWidget(
      _canvasPreview(template, const {'site::habitatType': 'forest|wetland'}),
    );
    await tester.pumpAndSettle();

    expect(find.text('forest, wetland'), findsOneWidget);
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
