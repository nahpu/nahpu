import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/document_writer.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

rust_config.DocumentLayoutPreset _layout({
  required List<rust_config.DocumentLayoutBlock> blocks,
  String layoutType = 'WholePage',
  String multiBlockMode = 'Continuous',
}) {
  return rust_config.DocumentLayoutPreset(
    name: 'Test layout',
    layoutType: layoutType,
    pageSizeKey: 'Letter',
    pageOrientation: 'portrait',
    pagePadTopMm: 0,
    pagePadLeftMm: 0,
    pagePadRightMm: 0,
    pagePadBottomMm: 0,
    blocks: blocks,
    fillPage: false,
    multiBlockMode: multiBlockMode,
  );
}

rust_config.DocumentLayoutBlock _block({
  String templateName = 'template',
  required int templateCount,
  required int rows,
  required int cols,
}) {
  return rust_config.DocumentLayoutBlock(
    templateName: templateName,
    templateCount: templateCount,
    rows: rows,
    cols: cols,
    templatePadTopMm: 0,
    templatePadLeftMm: 0,
    templatePadRightMm: 0,
    templatePadBottomMm: 0,
    pageBreakAfter: false,
  );
}

Template _template(
  String name, {
  double widthMm = 10,
  double heightMm = 10,
  TemplatePrintOptions? printOptions,
}) {
  return Template(
    name: name,
    page1: const TemplatePage(),
    page2: const TemplatePage(),
    widthMm: widthMm,
    heightMm: heightMm,
    printOptions: printOptions,
  );
}

void main() {
  group('DocumentWriter text substitutions', () {
    test('substituteDocumentPlaceholders replaces keys exactly', () {
      final text = 'Specimen: [catalogNum] ([tissueId])';
      final data = {
        'catalogNum': '1234',
        'tissueId': 'T-100',
      };

      final result = substituteDocumentPlaceholders(text, data);
      expect(result, 'Specimen: 1234 (T-100)');
    });

    test('substituteDocumentPlaceholders replaces keys case-insensitively', () {
      final text = 'Sex: [SEX] - Locality: [Locality]';
      final data = {
        'sex': 'Male',
        'locality': 'Forest edge',
      };

      final result = substituteDocumentPlaceholders(text, data);
      expect(result, 'Sex: Male - Locality: Forest edge');
    });

    test('substituteDocumentPlaceholders handles missing keys gracefully', () {
      final text = 'Age: [age] - Weight: [weight]';
      final data = {
        'age': 'Adult',
      };

      final result = substituteDocumentPlaceholders(text, data);
      expect(result, 'Age: Adult - Weight: [weight]');
    });

    test('substituteDocumentPlaceholders uses fallback for missing keys', () {
      final text =
          'Catalog: [specimen::catalogNumber??specimen::catalogNumber]';
      final result = substituteDocumentPlaceholders(text, {});

      expect(result, 'Catalog: specimen::catalogNumber');
    });

    test('substituteDocumentPlaceholders uses fallback for empty values', () {
      final text = 'Weight: [weight??N/A]';
      final result = substituteDocumentPlaceholders(text, {'weight': ''});

      expect(result, 'Weight: N/A');
    });

    test('substituteDocumentPlaceholders resolves short fallback keys', () {
      final text = 'Catalog: [catalogNum??specimen::catalogNum]';
      final result = substituteDocumentPlaceholders(
        text,
        {'specimen::catalogNum': 'NAHPU-001'},
      );

      expect(result, 'Catalog: NAHPU-001');
    });

    test('substituteDocumentPlaceholders resolves full keys from short data',
        () {
      final text = 'Catalog: [specimen::catalogNum??specimen::catalogNum]';
      final result = substituteDocumentPlaceholders(
        text,
        {'catalogNum': 'NAHPU-002'},
      );

      expect(result, 'Catalog: NAHPU-002');
    });

    test('substituteDocumentPlaceholders uses text property null fallback', () {
      const text = 'Weight: [weight]';
      final result = substituteDocumentPlaceholders(
        text,
        {'weight': ''},
        nullFallbackOption: kTemplateNullFallbackNa,
      );

      expect(result, 'Weight: N/A');
      expect(text, 'Weight: [weight]');
    });

    test('substituteDocumentPlaceholders uses field name null fallback', () {
      final result = substituteDocumentPlaceholders(
        'Catalog: [specimen::catalogNum]',
        {},
        nullFallbackOption: kTemplateNullFallbackField,
      );

      expect(result, 'Catalog: specimen::catalogNum');
    });

    test(
        'substituteDocumentPlaceholders maps encoded fields using enum default',
        () {
      final text = 'Testis: [mammalAttribute::testisPosition]';
      final data = {
        'mammalAttribute::testisPosition': '0',
      };
      final result = substituteDocumentPlaceholders(
        text,
        data,
        textType: 'encoded',
        formatOption: 'enum',
      );
      expect(result, 'Testis: Scrotal');
    });

    test(
        'substituteDocumentPlaceholders maps encoded fields using custom mappings',
        () {
      final text = 'Sex: [measurement::sex]';
      final data = {
        'measurement::sex': '1',
      };
      final result = substituteDocumentPlaceholders(
        text,
        data,
        textType: 'encoded',
        formatOption: 'custom_map:0=M,1=F,2=U',
      );
      expect(result, 'Sex: F');
    });

    test(
        'substituteDocumentPlaceholders maps encoded short keys using enum default',
        () {
      final text = 'Testis: [testisPosition]';
      final data = {
        'mammalAttribute::testisPosition': '0',
      };
      final result = substituteDocumentPlaceholders(
        text,
        data,
        textType: 'encoded',
        formatOption: 'enum',
      );
      expect(result, 'Testis: Scrotal');
    });
  });

  group('Site coordinate field values', () {
    test('buildCoordinateFieldValues exposes coordinate namespace fields', () {
      final values = buildCoordinateFieldValues([
        const CoordinateData(
          id: 7,
          nameId: 'COORD-A',
          decimalLatitude: 1.2345,
          decimalLongitude: 6.789,
          elevationInMeter: 12.0,
          datum: 'WGS84',
          uncertaintyInMeters: 25,
          gpsUnit: 'GPS',
          notes: 'First',
          siteID: 3,
        ),
        const CoordinateData(
          id: 8,
          nameId: 'COORD-B',
          decimalLatitude: -2.5,
          decimalLongitude: 10.25,
          siteID: 3,
        ),
      ]);

      expect(values['coordinate::id'], '7|8');
      expect(values['coordinate::nameId'], 'COORD-A|COORD-B');
      expect(values['coordinate::decimalLatitude'], '1.2345|-2.5');
      expect(values['coordinate::decimalLongitude'], '6.789|10.25');
      expect(values['coordinate::datum'], 'WGS84');
      expect(values['coordinate::notes'], 'First');
      expect(values['coordinate::siteID'], '3|3');
    });
  });

  group('Collecting personnel field values', () {
    test('uses collPersonnel rows and preserves event-specific roles', () {
      final values = buildCollPersonnelFieldValues(const [
        CollPersonnelData(
          id: 1,
          eventID: 7,
          personnelId: 'person-a',
          name: 'Collector A',
          role: 'Recorder',
        ),
        CollPersonnelData(
          id: 2,
          eventID: 7,
          personnelId: 'person-b',
          name: 'Collector B',
          role: 'Preparator',
        ),
      ]);

      expect(values['collPersonnel::name'], 'Collector A|Collector B');
      expect(values['collPersonnel::role'], 'Recorder|Preparator');
      expect(values['collPersonnel::personnelId'], 'person-a|person-b');
      expect(values, isNot(contains('personnel::role')));
      expect(
        buildCollPersonnelSummary(const [
          CollPersonnelData(
            id: 1,
            eventID: 7,
            personnelId: 'person-a',
            name: 'Collector A',
            role: 'Recorder',
          ),
          CollPersonnelData(
            id: 2,
            eventID: 7,
            personnelId: 'person-b',
            name: 'Collector B',
            role: 'Preparator',
          ),
        ]),
        'Collector A;Recorder|Collector B;Preparator',
      );
    });

    test('does not create a summary row without an event personnel name', () {
      expect(
        buildCollPersonnelSummary(const [
          CollPersonnelData(
            id: 1,
            eventID: 7,
            personnelId: 'person-a',
            name: null,
            role: 'Recorder',
          ),
        ]),
        isEmpty,
      );
    });
  });

  group('DocumentWriter z-index tests', () {
    test('Elements are correctly sorted by zIndex', () {
      final page = TemplatePage(customImages: [
        CustomImageElement(
            id: 'img1',
            imagePath: 'path1.png',
            xMm: 0,
            yMm: 0,
            widthMm: 10,
            heightMm: 10,
            zIndex: 10),
      ], customTexts: [
        CustomTextElement(
            id: 'txt1', text: 'Top text', xMm: 0, yMm: 0, zIndex: 20),
        CustomTextElement(
            id: 'txt2', text: 'Bottom text', xMm: 0, yMm: 0, zIndex: -10),
      ], customLines: [
        CustomLineElement(id: 'line1', xMm: 0, yMm: 0, lengthMm: 10, zIndex: 5),
      ], customShapes: [
        CustomShapeElement(
            id: 'shape1',
            shapeType: 'rect',
            xMm: 0,
            yMm: 0,
            widthMm: 10,
            heightMm: 10,
            zIndex: 0),
      ]);

      final sortedElements = DocumentWriter.sortElementsForTesting(page);

      expect(sortedElements.length, 5);

      expect(sortedElements[0] is CustomTextElement, isTrue);
      expect((sortedElements[0] as CustomTextElement).id, 'txt2');

      expect(sortedElements[1] is CustomShapeElement, isTrue);
      expect((sortedElements[1] as CustomShapeElement).id, 'shape1');

      expect(sortedElements[2] is CustomLineElement, isTrue);
      expect((sortedElements[2] as CustomLineElement).id, 'line1');

      expect(sortedElements[3] is CustomImageElement, isTrue);
      expect((sortedElements[3] as CustomImageElement).id, 'img1');

      expect(sortedElements[4] is CustomTextElement, isTrue);
      expect((sortedElements[4] as CustomTextElement).id, 'txt1');
    });
  });

  group('Custom shape model tests', () {
    test('polygon side count serializes and clamps on read', () {
      const shape = CustomShapeElement(
        id: 'shape_polygon',
        shapeType: 'polygon',
        polygonSides: 7,
        xMm: 1,
        yMm: 2,
        widthMm: 10,
        heightMm: 12,
      );

      final json = shape.toJson();
      expect(json['polygonSides'], 7);

      final decoded = CustomShapeElement.fromJson(json);
      expect(decoded.shapeType, 'polygon');
      expect(decoded.polygonSides, 7);

      final clamped = CustomShapeElement.fromJson({
        ...json,
        'polygonSides': 99,
      });
      expect(clamped.polygonSides, 12);
    });
  });

  group('DocumentWriter sheet planning tests', () {
    test('uses production page-break policy without a trailing break', () {
      expect(
        DocumentWriter.sheetPageBreakPlanForTesting(
          forcePageBreakAfter: const [],
        ),
        isEmpty,
      );
      expect(
        DocumentWriter.sheetPageBreakPlanForTesting(
          forcePageBreakAfter: const [true],
        ),
        [false],
      );
      expect(
        DocumentWriter.sheetPageBreakPlanForTesting(
          forcePageBreakAfter: const [true, false, true],
        ),
        [true, false, false],
      );
    });

    test('grouped fixed-grid planning repeats every configured template',
        () async {
      final sheets = await DocumentWriter.planDocumentSheetsForTesting(
        layout: _layout(
          blocks: [_block(templateCount: 3, rows: 2, cols: 2)],
        ),
        templates: [_template('grouped')],
        dataByBlock: const [
          [
            {'id': 'A'},
            {'id': 'B'},
          ],
        ],
      );

      expect(sheets.map((sheet) => sheet.cellData.length), [4, 2]);
      expect(
        [
          for (final sheet in sheets)
            for (final data in sheet.cellData) data['id'],
        ],
        ['A', 'A', 'A', 'B', 'B', 'B'],
      );
      expect(
        DocumentWriter.sheetPageBreakPlanForTesting(
          forcePageBreakAfter: [
            for (final sheet in sheets) sheet.forcePageBreakAfter,
          ],
        ),
        [true, false],
      );
    });

    test('continuous planning repeats every configured template', () {
      final items = DocumentWriter.planContinuousItemsForTesting(
        layout: _layout(
          layoutType: 'Continuous',
          blocks: [_block(templateCount: 3, rows: 1, cols: 1)],
        ),
        templates: [_template('continuous')],
        dataByBlock: const [
          [
            {'id': 'A'},
          ],
        ],
        duplex: true,
        mirrorBack: true,
      );

      expect(
        items.map((item) => item.data['id']),
        ['A', 'A', 'A', 'A', 'A', 'A'],
      );
      expect(
        items.map((item) => item.mirror),
        [false, true, false, true, false, true],
      );
    });

    test('continuous planning uses each template side profile', () {
      final items = DocumentWriter.planContinuousItemsForTesting(
        layout: _layout(
          layoutType: 'Continuous',
          multiBlockMode: 'Alternate',
          blocks: [
            _block(templateName: 'duplex', templateCount: 1, rows: 1, cols: 1),
            _block(templateName: 'simplex', templateCount: 1, rows: 1, cols: 1),
          ],
        ),
        templates: [
          _template(
            'duplex',
            printOptions: const TemplatePrintOptions(
              isDuplex: true,
              mirrorFront: false,
              mirrorBack: true,
            ),
          ),
          _template(
            'simplex',
            printOptions: const TemplatePrintOptions(
              isDuplex: false,
              mirrorFront: false,
              mirrorBack: false,
            ),
          ),
        ],
        dataByBlock: const [
          [
            {'id': 'A'},
          ],
          [
            {'id': 'B'},
          ],
        ],
      );

      expect(items.map((item) => item.data['id']), ['A', 'A', 'B']);
      expect(items.map((item) => item.mirror), [false, true, false]);
    });

    test('alternate planning preserves record, block, and copy order',
        () async {
      final sheets = await DocumentWriter.planDocumentSheetsForTesting(
        layout: _layout(
          multiBlockMode: 'Alternate',
          blocks: [
            _block(templateName: 'first', templateCount: 2, rows: 2, cols: 4),
            _block(
              templateName: 'second',
              templateCount: 1,
              rows: 2,
              cols: 4,
            ),
          ],
        ),
        templates: [_template('first'), _template('second')],
        dataByBlock: const [
          [
            {'id': 'A1'},
            {'id': 'A2'},
          ],
          [
            {'id': 'B1'},
          ],
        ],
      );

      expect(
        [
          for (final sheet in sheets)
            for (final data in sheet.cellData) data['id'],
        ],
        ['A1', 'A1', 'B1', 'A2', 'A2'],
      );
    });

    test('duplex planning pairs copies and omits the last back-side break',
        () async {
      final sheets = await DocumentWriter.planDocumentSheetsForTesting(
        layout: _layout(
          blocks: [_block(templateCount: 2, rows: 1, cols: 1)],
        ),
        templates: [_template('duplex')],
        dataByBlock: const [
          [
            {'id': 'A'},
          ],
        ],
        duplex: true,
        mirrorBack: true,
      );

      expect(sheets.map((sheet) => sheet.cellData.length), [1, 1, 1, 1]);
      expect(sheets.map((sheet) => sheet.mirrors.single),
          [false, true, false, true]);
      expect(
        DocumentWriter.sheetPageBreakPlanForTesting(
          forcePageBreakAfter: [
            for (final sheet in sheets) sheet.forcePageBreakAfter,
          ],
        ),
        [true, true, true, false],
      );
    });

    test('alternate planning splits simplex and duplex template runs',
        () async {
      final sheets = await DocumentWriter.planDocumentSheetsForTesting(
        layout: _layout(
          multiBlockMode: 'Alternate',
          blocks: [
            _block(templateName: 'duplex', templateCount: 1, rows: 1, cols: 1),
            _block(templateName: 'simplex', templateCount: 1, rows: 1, cols: 1),
          ],
        ),
        templates: [
          _template(
            'duplex',
            printOptions: const TemplatePrintOptions(
              isDuplex: true,
              mirrorFront: false,
              mirrorBack: true,
            ),
          ),
          _template(
            'simplex',
            printOptions: const TemplatePrintOptions(
              isDuplex: false,
              mirrorFront: false,
              mirrorBack: false,
            ),
          ),
        ],
        dataByBlock: const [
          [
            {'id': 'A1'},
            {'id': 'A2'},
          ],
          [
            {'id': 'B1'},
            {'id': 'B2'},
          ],
        ],
      );

      expect(
        [for (final sheet in sheets) sheet.cellData.single['id']],
        ['A1', 'A1', 'B1', 'A2', 'A2', 'B2'],
      );
      expect(
        [for (final sheet in sheets) sheet.mirrors.single],
        [false, true, false, false, true, false],
      );
      expect(
        DocumentWriter.sheetPageBreakPlanForTesting(
          forcePageBreakAfter: [
            for (final sheet in sheets) sheet.forcePageBreakAfter,
          ],
        ),
        [true, true, true, true, true, false],
      );
    });

    test('legacy templates default to simplex output', () async {
      final sheets = await DocumentWriter.planDocumentSheetsForTesting(
        layout: _layout(
          blocks: [_block(templateCount: 1, rows: 1, cols: 1)],
        ),
        templates: [_template('legacy')],
        dataByBlock: const [
          [
            {'id': 'A'},
          ],
        ],
      );

      expect(sheets, hasLength(1));
      expect(sheets.single.mirrors, [false]);
    });

    test('uses each block template canvas dimensions', () async {
      final sheets = await DocumentWriter.planDocumentSheetsForTesting(
        layout: _layout(
          blocks: [
            _block(templateName: 'small', templateCount: 1, rows: 1, cols: 1),
            _block(templateName: 'large', templateCount: 1, rows: 1, cols: 1),
          ],
        ),
        templates: [
          _template('small', widthMm: 25, heightMm: 10),
          _template('large', widthMm: 50, heightMm: 20),
        ],
        dataByBlock: const [
          [
            {'id': 'A'},
          ],
          [
            {'id': 'B'},
          ],
        ],
        useTemplateDimensions: true,
      );

      expect(sheets.map((sheet) => sheet.canvasWidths.single), [
        closeTo(25 * 72 / 25.4, 0.001),
        closeTo(50 * 72 / 25.4, 0.001),
      ]);
      expect(sheets.map((sheet) => sheet.canvasHeights.single), [
        closeTo(10 * 72 / 25.4, 0.001),
        closeTo(20 * 72 / 25.4, 0.001),
      ]);
    });

    test('nonpositive template counts produce no tiled cells', () async {
      final sheets = await DocumentWriter.planDocumentSheetsForTesting(
        layout: _layout(
          blocks: [_block(templateCount: 0, rows: 1, cols: 1)],
        ),
        templates: [_template('none')],
        dataByBlock: const [
          [
            {'id': 'A'},
          ],
        ],
      );

      expect(sheets, isEmpty);
    });

    test('auto-fill planning repeats configured copies before fill rows',
        () async {
      final sheets = await DocumentWriter.planDocumentSheetsForTesting(
        layout: _layout(
          blocks: [_block(templateCount: 2, rows: -1, cols: 2)],
        ),
        templates: [_template('auto-fill')],
        dataByBlock: const [
          [
            {'id': 'A'},
          ],
        ],
        documentHeightPt: 100,
        usableHeightPt: 100,
      );

      expect(sheets, hasLength(1));
      expect(sheets.single.autoFill, isTrue);
      expect(sheets.single.cellData.map((data) => data['id']), ['A', 'A']);
    });
  });

  group('DocumentWriter auto-fill sizing tests', () {
    test('fills every complete row without exceeding the usable page', () {
      expect(
        DocumentWriter.maxAutoFillRepeatCountForTesting(
          rowHeight: 24,
          usedHeight: 48,
          usableHeight: 120,
        ),
        3,
      );
      expect(
        DocumentWriter.maxAutoFillRepeatCountForTesting(
          rowHeight: 24,
          usedHeight: 49,
          usableHeight: 120,
        ),
        2,
      );
    });

    test('page padding reduces the height available to auto-fill rows', () {
      final usableHeight = DocumentWriter.usablePageHeightPtForTesting(
        sheetHeightPt: documentPdfMmToPt(297),
        topPaddingMm: 10,
        bottomPaddingMm: 20,
      );

      expect(usableHeight, closeTo(documentPdfMmToPt(267), 0.001));
      expect(
        DocumentWriter.maxAutoFillRepeatCountForTesting(
          rowHeight: documentPdfMmToPt(50),
          usedHeight: 0,
          usableHeight: usableHeight,
        ),
        5,
      );
    });

    test('static auto-fill height expands to the visible image bottom', () {
      final page = TemplatePage(
        customImages: const [
          CustomImageElement(
            id: 'image',
            imagePath: 'logo.png',
            xMm: 0,
            yMm: 42,
            widthMm: 20,
            heightMm: 16,
          ),
        ],
      );

      final height = DocumentWriter.estimateAutoFillCellHeightPtForTesting(
        page: page,
        wPt: 180,
        hPt: documentPdfMmToPt(50),
        templatePadTopMm: 0,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 0,
      );

      expect(height, closeTo(documentPdfMmToPt(58), 0.001));
    });

    test('static auto-fill height expands to the visible shape bottom', () {
      final page = TemplatePage(
        customShapes: const [
          CustomShapeElement(
            id: 'shape',
            shapeType: 'rect',
            polygonSides: 4,
            xMm: 0,
            yMm: 24,
            widthMm: 35,
            heightMm: 12,
            strokeThicknessPt: 2,
          ),
        ],
      );

      final height = DocumentWriter.estimateAutoFillCellHeightPtForTesting(
        page: page,
        wPt: 180,
        hPt: documentPdfMmToPt(30),
        templatePadTopMm: 0,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 0,
      );

      expect(height, closeTo(documentPdfMmToPt(36) + 2, 0.001));
    });

    test('static auto-fill height expands to the visible line bottom', () {
      final page = TemplatePage(
        customLines: const [
          CustomLineElement(
            id: 'line',
            xMm: 0,
            yMm: 64,
            lengthMm: 55,
            thicknessPt: 1,
          ),
        ],
      );

      final height = DocumentWriter.estimateAutoFillCellHeightPtForTesting(
        page: page,
        wPt: 180,
        hPt: documentPdfMmToPt(60),
        templatePadTopMm: 0,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 0,
      );

      expect(height, closeTo(documentPdfMmToPt(64) + 1.5, 0.001));
    });

    test('auto-fill retains the configured template height for short content',
        () {
      final page = TemplatePage(customTexts: [
        CustomTextElement(
          id: 'short',
          text: 'Short label',
          xMm: 0,
          yMm: 0,
          fontSizePt: 10,
          maxWidthMm: 55,
        ),
      ]);

      final height = DocumentWriter.estimateAutoFillCellHeightPtForTesting(
        page: page,
        wPt: 180,
        hPt: documentPdfMmToPt(50),
        templatePadTopMm: 2,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 3,
      );

      expect(height, closeTo(documentPdfMmToPt(55), 0.001));
    });

    test('estimates taller cells for wrapped auto-height text', () {
      final shortPage = TemplatePage(customTexts: [
        CustomTextElement(
          id: 'short',
          text: 'Short narrative.',
          xMm: 0,
          yMm: 0,
          fontSizePt: 10,
          maxWidthMm: 55,
        ),
      ]);
      final longPage = TemplatePage(customTexts: [
        CustomTextElement(
          id: 'long',
          text: List.filled(30, 'Long narrative text').join(' '),
          xMm: 0,
          yMm: 0,
          fontSizePt: 10,
          maxWidthMm: 55,
        ),
      ]);

      final shortHeight =
          DocumentWriter.estimateTemplatePageContentHeightPtForTesting(
        page: shortPage,
        wPt: 180,
        hPt: 20,
      );
      final longHeight =
          DocumentWriter.estimateTemplatePageContentHeightPtForTesting(
        page: longPage,
        wPt: 180,
        hPt: 20,
      );

      expect(longHeight, greaterThan(shortHeight));
    });

    test('includes template padding in auto-fill cell height', () {
      final page = TemplatePage(customTexts: [
        CustomTextElement(
          id: 'text',
          text: 'Text',
          xMm: 0,
          yMm: 0,
          fontSizePt: 10,
          maxWidthMm: 55,
        ),
      ]);

      final withoutPadding =
          DocumentWriter.estimateAutoFillCellHeightPtForTesting(
        page: page,
        wPt: 180,
        hPt: 20,
        templatePadTopMm: 0,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 0,
      );
      final withPadding = DocumentWriter.estimateAutoFillCellHeightPtForTesting(
        page: page,
        wPt: 180,
        hPt: 20,
        templatePadTopMm: 2,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 2,
      );

      expect(withPadding, greaterThan(withoutPadding));
    });

    test('dynamic text without fixed height can grow past template height', () {
      final page = TemplatePage(customTexts: [
        CustomTextElement(
          id: 'dynamic',
          text: List.filled(20, 'Dynamic narrative text').join(' '),
          xMm: 0,
          yMm: 0,
          fontSizePt: 10,
          maxWidthMm: 55,
          isDynamic: true,
        ),
      ]);

      final height = DocumentWriter.estimateAutoFillCellHeightPtForTesting(
        page: page,
        wPt: 180,
        hPt: documentPdfMmToPt(10),
        templatePadTopMm: 0,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 0,
      );

      expect(height, greaterThan(documentPdfMmToPt(10)));
    });

    test('dynamic text element includes its own growth in estimated height',
        () {
      final page = TemplatePage(customTexts: [
        CustomTextElement(
          id: 'dynamic',
          text: List.filled(20, 'Very long dynamic text narrative').join(' '),
          xMm: 0,
          yMm: 0,
          fontSizePt: 10,
          maxWidthMm: 55,
          heightMm: 5,
          isDynamic: true,
        ),
      ]);

      final height = DocumentWriter.estimateAutoFillCellHeightPtForTesting(
        page: page,
        wPt: 180,
        hPt: documentPdfMmToPt(10),
        templatePadTopMm: 0,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 0,
      );

      expect(height, greaterThan(documentPdfMmToPt(20)));
    });

    test('dynamic text row height includes bottom line elements', () {
      final page = TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'dynamic',
            text: 'Short dynamic narrative.',
            xMm: 0,
            yMm: 0,
            fontSizePt: 10,
            maxWidthMm: 55,
            isDynamic: true,
          ),
        ],
        customLines: const [
          CustomLineElement(
            id: 'bottom-line',
            xMm: 0,
            yMm: 80,
            lengthMm: 55,
            thicknessPt: 1,
          ),
        ],
      );

      final height = DocumentWriter.estimateAutoFillCellHeightPtForTesting(
        page: page,
        wPt: 180,
        hPt: documentPdfMmToPt(10),
        templatePadTopMm: 0,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 0,
      );

      expect(height, greaterThan(documentPdfMmToPt(80)));
      expect(height, lessThan(documentPdfMmToPt(100)));
    });

    test('dynamic text growth pushes lower elements in row height', () {
      final page = TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'dynamic',
            text: List.filled(30, 'Long narrative text').join(' '),
            xMm: 0,
            yMm: 0,
            fontSizePt: 10,
            maxWidthMm: 55,
            heightMm: 8,
            isDynamic: true,
          ),
        ],
        customLines: const [
          CustomLineElement(
            id: 'below-dynamic',
            xMm: 0,
            yMm: 12,
            lengthMm: 55,
            thicknessPt: 1,
          ),
        ],
      );

      final height = DocumentWriter.estimateAutoFillCellHeightPtForTesting(
        page: page,
        wPt: 180,
        hPt: documentPdfMmToPt(10),
        templatePadTopMm: 0,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 0,
      );

      expect(height, greaterThan(documentPdfMmToPt(35)));
      expect(height, lessThan(documentPdfMmToPt(100)));
    });

    test('dynamic text without height pushes lower elements', () {
      final page = TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'dynamic',
            text: List.filled(12, 'Dynamic text').join(' '),
            xMm: 0,
            yMm: 0,
            fontSizePt: 10,
            maxWidthMm: 55,
            isDynamic: true,
          ),
        ],
        customLines: const [
          CustomLineElement(
            id: 'below-dynamic',
            xMm: 0,
            yMm: 8,
            lengthMm: 55,
            thicknessPt: 1,
          ),
        ],
      );

      final height = DocumentWriter.estimateAutoFillCellHeightPtForTesting(
        page: page,
        wPt: 180,
        hPt: documentPdfMmToPt(10),
        templatePadTopMm: 0,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 0,
      );

      expect(height, greaterThan(documentPdfMmToPt(20)));
    });

    test('dynamic markdown tables are measured as rendered Typst content', () {
      const page = TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'dynamic_table',
            text: '#table(columns: 3, [Name], [Lat], [Long], [A], [1], [2])',
            xMm: 0,
            yMm: 0,
            fontSizePt: 10,
            maxWidthMm: 55,
            heightMm: 4,
            textType: 'markdown',
            isDynamic: true,
          ),
        ],
        customLines: [
          CustomLineElement(
            id: 'below-table',
            xMm: 0,
            yMm: 8,
            lengthMm: 55,
            thicknessPt: 1,
          ),
        ],
      );

      final typst = DocumentWriter.renderSingleDocumentCellTypstForTesting(
        page: page,
        wPt: 180,
        hPt: 90,
      );

      expect(
        typst,
        contains('measure(box(width: ${documentPdfMmToPt(55)}pt)['
            '#block(above: 0pt, below: 0pt)[#set text(size: 10.0pt'),
      );
      expect(typst, contains('#table(columns: 3'));
      expect(typst, contains('flow_clearance_dynamic_table'));
      expect(typst, contains('${documentPdfMmToPt(2)}pt'));
      expect(typst, isNot(contains(r'\#table')));
    });

    test('multiple dynamic texts flow with clearance before lower elements',
        () {
      final page = TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'first',
            text: List.filled(12, 'First dynamic paragraph').join(' '),
            xMm: 0,
            yMm: 0,
            fontSizePt: 10,
            maxWidthMm: 55,
            isDynamic: true,
          ),
          CustomTextElement(
            id: 'second',
            text: List.filled(12, 'Second dynamic paragraph').join(' '),
            xMm: 0,
            yMm: 6,
            fontSizePt: 10,
            maxWidthMm: 55,
            isDynamic: true,
          ),
        ],
        customLines: const [
          CustomLineElement(
            id: 'below-dynamic',
            xMm: 0,
            yMm: 10,
            lengthMm: 55,
            thicknessPt: 1,
          ),
        ],
      );

      final typst = DocumentWriter.renderSingleDocumentCellTypstForTesting(
        page: page,
        wPt: 180,
        hPt: documentPdfMmToPt(10),
      );
      final estimatedHeight =
          DocumentWriter.estimateAutoFillCellHeightPtForTesting(
        page: page,
        wPt: 180,
        hPt: documentPdfMmToPt(10),
        templatePadTopMm: 0,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 0,
      );

      expect(
        typst,
        contains('flow_top_second = calc.max(flow_top_second, '
            'flow_clearance_first)'),
      );
      expect(typst, contains('flow_clearance_second'));
      expect(typst, contains('${documentPdfMmToPt(2)}pt'));
      expect(estimatedHeight, greaterThan(documentPdfMmToPt(25)));
    });

    test('near-aligned dynamic texts stay in the same PDF flow row', () {
      const page = TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'left',
            text: 'Left dynamic text',
            xMm: 0,
            yMm: 10,
            fontSizePt: 10,
            maxWidthMm: 25,
            isDynamic: true,
          ),
          CustomTextElement(
            id: 'right',
            text: 'Right dynamic text',
            xMm: 30,
            yMm: 10.8,
            fontSizePt: 10,
            maxWidthMm: 25,
            isDynamic: true,
          ),
        ],
      );

      final typst = DocumentWriter.renderSingleDocumentCellTypstForTesting(
        page: page,
        wPt: 180,
        hPt: documentPdfMmToPt(30),
      );

      expect(
        typst,
        isNot(contains('flow_top_right = calc.max(flow_top_right')),
      );
    });

    test('uses the canvas top-left origin for template element placement', () {
      const page = TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'rotated-text',
            text: 'Text',
            xMm: 12,
            yMm: 18,
            rotationDegrees: 90,
          ),
        ],
        customLines: [
          CustomLineElement(
            id: 'line',
            xMm: 20,
            yMm: 24,
            lengthMm: 30,
          ),
        ],
        customShapes: [
          CustomShapeElement(
            id: 'shape',
            xMm: 6,
            yMm: 8,
            widthMm: 10,
            heightMm: 12,
            shapeType: 'rect',
          ),
        ],
      );

      final typst = DocumentWriter.renderSingleDocumentCellTypstForTesting(
        page: page,
        wPt: 180,
        hPt: 90,
      );

      expect(
        typst,
        contains(
          '#place(top + left, dx: ${documentPdfMmToPt(12)}pt, '
          'dy: ${documentPdfMmToPt(18)}pt)[#rotate(90deg, '
          'origin: top + left)',
        ),
      );
      expect(
        typst,
        contains('#place(top + left, dx: ${documentPdfMmToPt(20)}pt, '
            'dy: ${documentPdfMmToPt(24)}pt)'),
      );
      expect(
        typst,
        contains('#place(top + left, dx: ${documentPdfMmToPt(6)}pt, '
            'dy: ${documentPdfMmToPt(8)}pt)'),
      );
    });

    test('text box background and stroke add configured padding', () {
      final plainPage = TemplatePage(customTexts: [
        CustomTextElement(
          id: 'plain',
          text: 'Text',
          xMm: 0,
          yMm: 0,
          fontSizePt: 10,
          maxWidthMm: 55,
        ),
      ]);
      final styledPage = TemplatePage(customTexts: [
        CustomTextElement(
          id: 'styled',
          text: 'Text',
          xMm: 0,
          yMm: 0,
          fontSizePt: 10,
          maxWidthMm: 55,
          backgroundColorArgb: 0xFFFFFFFF,
          borderColorArgb: 0xFF000000,
          borderWidthPt: 1,
          paddingPt: 5,
        ),
      ]);

      final plainHeight =
          DocumentWriter.estimateTemplatePageContentHeightPtForTesting(
        page: plainPage,
        wPt: 180,
        hPt: 0,
      );
      final styledHeight =
          DocumentWriter.estimateTemplatePageContentHeightPtForTesting(
        page: styledPage,
        wPt: 180,
        hPt: 0,
      );

      expect(styledHeight - plainHeight, greaterThanOrEqualTo(10));
    });
  });

  group('Document text formatting tests', () {
    test('formatTextWithCase applies correct capitalization styles', () {
      const text = 'hello world test';
      expect(formatTextWithCase(text, 'uppercase'), 'HELLO WORLD TEST');
      expect(formatTextWithCase(text, 'lowercase'), 'hello world test');
      expect(formatTextWithCase(text, 'capitalize'), 'Hello World Test');
      expect(formatTextWithCase(text, 'normal'), 'hello world test');
    });

    test(
        'CustomTextElement JSON serialization retains textAlign and caseFormat',
        () {
      final ct = CustomTextElement(
        id: 'txt1',
        text: 'hello',
        xMm: 10,
        yMm: 20,
        textAlign: 'center',
        caseFormat: 'uppercase',
      );
      final json = ct.toJson();
      expect(json['textAlign'], 'center');
      expect(json['caseFormat'], 'uppercase');

      final deserialized = CustomTextElement.fromJson(json);
      expect(deserialized.textAlign, 'center');
      expect(deserialized.caseFormat, 'uppercase');
    });

    test(
        'CustomTextElement defaults textAlign and caseFormat on missing json keys',
        () {
      final json = {
        'id': 'txt1',
        'text': 'hello',
        'xMm': 10,
        'yMm': 20,
      };
      final deserialized = CustomTextElement.fromJson(json);
      expect(deserialized.textAlign, 'left');
      expect(deserialized.caseFormat, 'normal');
      expect(deserialized.textType, 'normal');
      expect(deserialized.formatOption, 'normal');
    });

    test(
        'CustomTextElement JSON serialization retains textType and formatOption',
        () {
      final ct = CustomTextElement(
        id: 'txt1',
        text: 'hello',
        xMm: 10,
        yMm: 20,
        textType: 'coordinates',
        formatOption: 'dms',
      );
      final json = ct.toJson();
      expect(json['textType'], 'coordinates');
      expect(json['formatOption'], 'dms');

      final deserialized = CustomTextElement.fromJson(json);
      expect(deserialized.textType, 'coordinates');
      expect(deserialized.formatOption, 'dms');
    });

    test('Coordinates formatting handles DMS and cardinal directions correctly',
        () {
      const text = '45.12345, -122.54321';
      final dms = formatTemplateText(text, 'coordinates', 'dms');
      expect(dms, '45° 7\' 24.4" N, 122° 32\' 35.6" W');

      final ddm = formatTemplateText(text, 'coordinates', 'ddm');
      expect(ddm, '45° 7.407\' N, 122° 32.593\' W');

      final cardinal =
          formatTemplateText(text, 'coordinates', 'cardinalDecimal');
      expect(cardinal, '45.12345° N, 122.54321° W');
    });

    test('List formatting handles normal separators and custom separators', () {
      const listText = 'mammal | bird | reptile';
      final commaList = formatTemplateText(listText, 'list', 'comma');
      expect(commaList, 'mammal, bird, reptile');

      final customList = formatTemplateText(listText, 'list', 'custom: - ');
      expect(customList, 'mammal - bird - reptile');
    });

    test('Date formatting parses and formats ISO dates correctly', () {
      const dateText = '2026-06-28';
      final formatted = formatTemplateText(dateText, 'date', 'month-dd-yyyy');
      expect(formatted, 'June 28, 2026');

      final abbr = formatTemplateText(dateText, 'date', 'dd-month-abbr-yyyy');
      expect(abbr, '28 Jun 2026');
    });

    test('Date and time formatting handles common global formats', () {
      const dateTimeText = '2026-06-28T14:05:09';

      expect(
        formatTemplateText(dateTimeText, 'datetime', 'yyyy-mm-dd-hm'),
        '2026-06-28 14:05',
      );
      expect(
        formatTemplateText(dateTimeText, 'datetime', 'dd/mm/yyyy-hm'),
        '28/06/2026 14:05',
      );
      expect(
        formatTemplateText(dateTimeText, 'datetime', 'mm/dd/yyyy-hm'),
        '06/28/2026 2:05 PM',
      );
      expect(
        formatTemplateText(dateTimeText, 'datetime', 'month-dd-yyyy-hm'),
        'June 28, 2026 2:05 PM',
      );
      expect(
        formatTemplateText(dateTimeText, 'datetime', 'time-24-seconds'),
        '14:05:09',
      );
    });

    test('Sex formatting parses Male/Female/Unknown indices and text', () {
      expect(formatTemplateText('0', 'sex', 'symbol:unknown'), '\u2642');
      expect(formatTemplateText('Male', 'sex', 'letter:na'), 'M');
      expect(formatTemplateText('m', 'sex', 'text:none'), 'Male');

      expect(formatTemplateText('1', 'sex', 'symbol:unknown'), '\u2640');
      expect(formatTemplateText('Female', 'sex', 'letter:na'), 'F');
      expect(formatTemplateText('f', 'sex', 'text:none'), 'Female');

      expect(formatTemplateText('2', 'sex', 'symbol:unknown'), '?');
      expect(formatTemplateText('', 'sex', 'letter:na'), 'N/A');
      expect(formatTemplateText('Unknown', 'sex', 'text:none'), '');

      // PDF export formats substituted text a second time while building the
      // Typst document. Already-rendered symbols must remain stable.
      expect(formatTemplateText('\u2642', 'sex', 'symbol:unknown'), '\u2642');
      expect(formatTemplateText('\u2640', 'sex', 'symbol:unknown'), '\u2640');
      expect(formatTemplateText('\u2642', 'sex', 'letter:na'), 'M');
      expect(formatTemplateText('\u2640', 'sex', 'text:none'), 'Female');
    });

    test('Typst keeps sex symbols and selects a glyph-capable font', () {
      const page = TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'sex-symbol',
            text: '\u2642',
            xMm: 0,
            yMm: 0,
            fontFamily: 'Merriweather',
            textType: 'sex',
            formatOption: 'symbol:unknown',
          ),
        ],
      );

      final typst = DocumentWriter.renderSingleDocumentCellTypstForTesting(
        page: page,
        wPt: 180,
        hPt: 90,
      );

      expect(typst, contains('font: "DejaVu Sans")[\u2642]'));
      expect(typst, isNot(contains('font: "Merriweather")[?]')));
    });

    test('gender icon export accepts encoded sex values', () {
      const page = TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'sex-icon',
            text: '[mammal.sex]-img',
            xMm: 0,
            yMm: 0,
          ),
        ],
      );

      final typst = DocumentWriter.renderSingleDocumentCellTypstForTesting(
        page: page,
        wPt: 180,
        hPt: 90,
        data: {'mammal.sex': '0'},
      );

      expect(typst, contains('font: "DejaVu Sans")[\u2642]'));
      expect(typst, isNot(contains('font: "DejaVu Sans")[?]')));
    });

    test('Field display formatting displays full/field-only placeholders', () {
      const text = '[specimen::catalogNum] [site::locality]';
      expect(
        formatFieldPlaceholderText(text, false),
        '[specimen::catalogNum] [site::locality]',
      );
      expect(
        formatFieldPlaceholderText(text, true),
        '[catalogNum] [locality]',
      );

      const textWithFallback = '[specimen::catalogNum??specimen::catalogNum]';
      expect(
        formatFieldPlaceholderText(textWithFallback, true),
        '[catalogNum??specimen::catalogNum]',
      );
    });

    test('Number formatting formats double values to specified decimals', () {
      const pureFloat = '12.3456';
      expect(formatTemplateText(pureFloat, 'number', 'original'), '12.3456');
      expect(formatTemplateText(pureFloat, 'number', '0'), '12');
      expect(formatTemplateText(pureFloat, 'number', '1'), '12.3');
      expect(formatTemplateText(pureFloat, 'number', '2'), '12.35');
      expect(formatTemplateText(pureFloat, 'number', '3'), '12.346');

      const integerText = '12';
      expect(formatTemplateText(integerText, 'number', '1'), '12.0');

      const textWithUnits = 'Weight: 12.34 g';
      expect(
          formatTemplateText(textWithUnits, 'number', '1'), 'Weight: 12.3 g');
    });

    test('export text normalization removes only trailing decimal zeroes', () {
      expect(truncateTrailingDecimalZeroText('12.0'), '12');
      expect(truncateTrailingDecimalZeroText('-12.0, 0.5, 12.00'),
          '-12, 0.5, 12.00');
      expect(
        formatExportTemplateText(
          'Weight: 12.0 g',
          'normal',
          'normal',
        ),
        'Weight: 12 g',
      );
      expect(
        formatTemplateText('Weight: 12.0 g', 'normal', 'normal'),
        'Weight: 12.0 g',
      );
    });

    test('PDF text rendering normalizes trailing decimal zeroes', () {
      const page = TemplatePage(
        customTexts: [
          CustomTextElement(
            id: 'weight',
            text: 'Weight: 12.0 g',
            xMm: 0,
            yMm: 0,
          ),
        ],
      );

      final typst = DocumentWriter.renderSingleDocumentCellTypstForTesting(
        page: page,
        wPt: 180,
        hPt: 90,
        data: const {},
      );

      expect(typst, contains('Weight: 12 g'));
      expect(typst, isNot(contains('Weight: 12.0 g')));
    });

    test('Encoded text formatting applies casing styles to mapped values', () {
      expect(
        formatTemplateText('scrotal', 'encoded', 'enum', 'uppercase'),
        'SCROTAL',
      );
      expect(
        formatTemplateText('scrotal', 'encoded', 'enum', 'capitalize'),
        'Scrotal',
      );
    });

    group('Integrated Text-to-QR tests', () {
      test(
          'CustomTextElement JSON serialization retains isQrCode, qrSizeMm, qrBgColorArgb, and qrShape',
          () {
        final ct = CustomTextElement(
          id: 'ct_1',
          text: '[catalogNum]',
          xMm: 10,
          yMm: 20,
          isQrCode: true,
          qrSizeMm: 18.5,
          qrBgColorArgb: 0xFF000000,
          qrShape: 'circle',
        );
        final json = ct.toJson();
        expect(json['id'], 'ct_1');
        expect(json['text'], '[catalogNum]');
        expect(json['isQrCode'], true);
        expect(json['qrSizeMm'], 18.5);
        expect(json['qrBgColorArgb'], 0xFF000000);
        expect(json['qrShape'], 'circle');

        final deserialized = CustomTextElement.fromJson(json);
        expect(deserialized.id, 'ct_1');
        expect(deserialized.text, '[catalogNum]');
        expect(deserialized.isQrCode, true);
        expect(deserialized.qrSizeMm, 18.5);
        expect(deserialized.qrBgColorArgb, 0xFF000000);
        expect(deserialized.qrShape, 'circle');
      });

      test('CustomTextElement default properties on missing json keys', () {
        final ct = CustomTextElement.fromJson({
          'id': 'ct_2',
          'text': 'Hello',
          'xMm': 0,
          'yMm': 0,
        });
        expect(ct.isQrCode, false);
        expect(ct.qrSizeMm, 15.0);
        expect(ct.qrBgColorArgb, 0xFFFFFFFF);
        expect(ct.qrShape, 'square');
        expect(ct.isDynamic, false);
        expect(ct.nullFallbackOption, kTemplateNullFallbackBlank);
        expect(ct.customNullFallbackText, isEmpty);
        expect(ct.backgroundColorArgb, isNull);
        expect(ct.borderColorArgb, isNull);
        expect(ct.borderWidthPt, 0);
        expect(ct.borderStrokeStyle, 'solid');
        expect(ct.cornerRadiusPt, 0);
        expect(ct.paddingPt, 2);
      });

      test('CustomTextElement JSON serialization retains isDynamic', () {
        final ct = CustomTextElement(
          id: 'ct_3',
          text: 'Hello Dynamic',
          xMm: 10,
          yMm: 20,
          isDynamic: true,
        );
        final json = ct.toJson();
        expect(json['isDynamic'], true);

        final deserialized = CustomTextElement.fromJson(json);
        expect(deserialized.isDynamic, true);
      });

      test('CustomTextElement migrates legacy placeholder fallbacks', () {
        final ct = CustomTextElement.fromJson({
          'id': 'ct_legacy_null',
          'text': 'Catalog: [specimen::catalogNum??N/A]',
          'xMm': 0,
          'yMm': 0,
        });

        expect(ct.text, 'Catalog: [specimen::catalogNum]');
        expect(ct.nullFallbackOption, kTemplateNullFallbackNa);
      });

      test('CustomTextElement JSON serialization retains background and border',
          () {
        const ct = CustomTextElement(
          id: 'ct_style',
          text: 'Styled text',
          xMm: 10,
          yMm: 20,
          backgroundColorArgb: 0xFFEFEFEF,
          borderColorArgb: 0xFF111111,
          borderWidthPt: 1.5,
          borderStrokeStyle: 'dashed',
          cornerRadiusPt: 4,
          paddingPt: 6,
        );
        final json = ct.toJson();
        expect(json['backgroundColorArgb'], 0xFFEFEFEF);
        expect(json['borderColorArgb'], 0xFF111111);
        expect(json['borderWidthPt'], 1.5);
        expect(json['borderStrokeStyle'], 'dashed');
        expect(json['cornerRadiusPt'], 4);
        expect(json['paddingPt'], 6);

        final deserialized = CustomTextElement.fromJson(json);
        expect(deserialized.backgroundColorArgb, 0xFFEFEFEF);
        expect(deserialized.borderColorArgb, 0xFF111111);
        expect(deserialized.borderWidthPt, 1.5);
        expect(deserialized.borderStrokeStyle, 'dashed');
        expect(deserialized.cornerRadiusPt, 4);
        expect(deserialized.paddingPt, 6);
      });

      test('CustomTextElement JSON serialization retains heightMm', () {
        final ct = CustomTextElement(
          id: 'ct_4',
          text: 'Hello Height',
          xMm: 10,
          yMm: 20,
          heightMm: 45.5,
        );
        final json = ct.toJson();
        expect(json['heightMm'], 45.5);

        final deserialized = CustomTextElement.fromJson(json);
        expect(deserialized.heightMm, 45.5);
      });
    });
  });
}
