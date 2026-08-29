import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/components/canvas/template_canvas_editor.dart';
import 'package:nahpu/screens/templates/components/properties/text_properties_panel.dart';
import 'package:nahpu/screens/templates/template_live_preview.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/export/text_replacements.dart';

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
    await tester.tap(find.byTooltip('Conditional output'));
    await tester.pumpAndSettle();
    final controllingField = find.byWidgetPredicate(
      (widget) =>
          widget is InputDecorator &&
          widget.decoration.labelText == 'Controlling field',
    );
    expect(controllingField, findsOneWidget);
    final dialogCount = find.byType(Dialog).evaluate().length;
    await tester.tap(controllingField);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNWidgets(dialogCount));

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Search fields or tables',
    );
    await tester.enterText(searchField, 'accuracy');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('accuracy').last);
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

  testWidgets('template editor creates a conditional value replacement', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const text = CustomTextElement(
      id: 'conditional-value',
      text: '[sex]',
      xMm: 0,
      yMm: 0,
    );
    const template = Template(
      name: 'Conditional value',
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
              selectedElement: 'custom:1:conditional-value',
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
    await tester.tap(find.byTooltip('Conditional output'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Conditional brackets'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Conditional value').last);
    await tester.pumpAndSettle();

    final conditionValue = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Value',
    );
    final replacement = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Replacement text',
    );
    await tester.enterText(conditionValue, '0');
    await tester.enterText(replacement, 'Male');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(updated?.text, '[[sex][sex=="0"]=>"Male"]]');
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

  testWidgets('template live preview renders conditional replacement text', (
    tester,
  ) async {
    const template = Template(
      name: 'Conditional replacement preview',
      page1: TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'conditional-replacement-preview',
            text: 'Sex: [[sex][sex=="0"]=>"Male"]]',
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

    Future<void> pumpWithValue(String sex) => tester.pumpWidget(
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
            placeholderValues: {'sex': sex},
          ),
        ),
      ),
    );

    await pumpWithValue('0');
    await tester.pumpAndSettle();
    expect(find.text('Sex: Male'), findsOneWidget);

    await pumpWithValue('1');
    await tester.pumpAndSettle();
    expect(find.text('Sex: 1'), findsOneWidget);
  });

  testWidgets('template live preview applies ordered exact and regex rules', (
    tester,
  ) async {
    const template = Template(
      name: 'Text replacement preview',
      page1: TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'replacement-preview',
            text: 'ID: [catalogNum]',
            xMm: 0,
            yMm: 0,
            replacementRules: [
              TextReplacementRule(pattern: 'ID:', replacement: 'Catalog'),
              TextReplacementRule(
                pattern: r'(ABC)-(\d+)',
                replacement: r'$1/$2',
                matchType: TextReplacementMatchType.regex,
              ),
            ],
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
            placeholderValues: {'catalogNum': 'ABC-12'},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Catalog ABC/12'), findsOneWidget);
  });

  testWidgets('template find and replace dialog applies only on Apply', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const text = CustomTextElement(
      id: 'replace-editor',
      text: '[catalogNum]',
      xMm: 0,
      yMm: 0,
    );
    const template = Template(
      name: 'Replacement editor',
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
              selectedElement: 'custom:1:replace-editor',
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
    expect(find.byTooltip('Conditional output'), findsOneWidget);
    expect(find.byTooltip('Find and replace'), findsOneWidget);
    expect(find.text('Replace text'), findsNothing);

    await tester.tap(find.byTooltip('Find and replace'));
    await tester.pumpAndSettle();
    expect(find.text('Find and replace'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('add-replacement-rule')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('apply-replacement-rules')),
          )
          .onPressed,
      null,
    );
    await tester.tap(find.text('Exact'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Regex').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('replacement-find-0')),
      '(',
    );
    await tester.enterText(
      find.byKey(const ValueKey('replacement-text-0')),
      'XYZ',
    );
    await tester.pump();
    expect(updated, null);
    expect(find.textContaining('Invalid regular expression'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('apply-replacement-rules')),
          )
          .onPressed,
      null,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(updated, null);

    await tester.tap(find.byTooltip('Find and replace'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-replacement-rule')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('replacement-find-0')),
      'ABC',
    );
    await tester.enterText(
      find.byKey(const ValueKey('replacement-text-0')),
      'XYZ',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('apply-replacement-rules')));
    await tester.pumpAndSettle();

    expect(updated?.replacementRules.single.pattern, 'ABC');
    expect(updated?.replacementRules.single.replacement, 'XYZ');
  });

  testWidgets('template find and replace dialog can clear existing rules', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const text = CustomTextElement(
      id: 'clear-replacements',
      text: '[catalogNum]',
      xMm: 0,
      yMm: 0,
      replacementRules: [
        TextReplacementRule(pattern: 'ABC', replacement: 'XYZ'),
      ],
    );
    const template = Template(
      name: 'Clear replacements',
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
              selectedElement: 'custom:1:clear-replacements',
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

    final action = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is IconButton && widget.tooltip == 'Find and replace',
      ),
    );
    expect(action.isSelected, isTrue);
    await tester.tap(find.byTooltip('Find and replace'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(const ValueKey('replacement-find-0')),
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text,
      'ABC',
    );

    await tester.tap(find.byTooltip('Remove replacement'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('apply-replacement-rules')));
    await tester.pumpAndSettle();

    expect(updated?.replacementRules, isEmpty);
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
