import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/templates/components/properties/text_format_options.dart';
import 'package:nahpu/screens/templates/components/properties/text_properties_panel.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/screens/templates/template_picture_grid.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/document_writer.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/templates/template_field_catalog.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  late Directory tempDir;
  late List<String> imagePaths;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('nahpu-picture-test');
    final png = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    );
    imagePaths = [
      for (var index = 0; index < 3; index++)
        (File('${tempDir.path}/image-$index.png')..writeAsBytesSync(png)).path,
    ];
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('picture paths resolve only from a direct media placeholder', () {
    final data = {kTemplatePicturePathsDataKey: jsonEncode(imagePaths)};

    expect(resolveTemplatePicturePaths('[media::media]', data), imagePaths);
    expect(resolveTemplatePicturePaths('[media]', data), imagePaths);
    expect(
      resolveTemplatePicturePaths('Images: [media::media]', data),
      isEmpty,
    );
    expect(resolveTemplatePicturePaths('[media::fileName]', data), isEmpty);
  });

  test('picture model serializes dimensions but not resolved paths', () {
    final picture = CustomTextElement(
      id: 'picture',
      text: '[media::media]',
      xMm: 4,
      yMm: 5,
      textType: kTemplatePictureTextType,
      pictureWidthMm: 42,
      pictureHeightMm: 24,
      resolvedPicturePaths: imagePaths,
    );

    final json = picture.toJson();
    final restored = CustomTextElement.fromJson(json);

    expect(json['pictureWidthMm'], 42);
    expect(json['pictureHeightMm'], 24);
    expect(json, isNot(contains('resolvedPicturePaths')));
    expect(restored.pictureWidthMm, 42);
    expect(restored.pictureHeightMm, 24);
    expect(restored.resolvedPicturePaths, isEmpty);
    expect(
      CustomTextElement.fromJson({
        'id': 'legacy',
        'text': 'Text',
        'xMm': 0,
        'yMm': 0,
      }).pictureWidthMm,
      20,
    );
  });

  test('picture is available as a text type', () {
    expect(
      kTextTypeOptions,
      contains((value: kTemplatePictureTextType, label: 'Picture')),
    );
  });

  test('picture grid dimensions use a row-major near-square grid', () {
    expect(templatePictureGridDimensions(0), (columns: 0, rows: 0));
    expect(templatePictureGridDimensions(1), (columns: 1, rows: 1));
    expect(templatePictureGridDimensions(2), (columns: 2, rows: 1));
    expect(templatePictureGridDimensions(3), (columns: 2, rows: 2));
    expect(templatePictureGridDimensions(5), (columns: 3, rows: 2));
  });

  testWidgets('picture widget creates one contained cell per image', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 100,
          child: TemplatePictureGrid(imagePaths: imagePaths),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Image), findsNWidgets(3));
    expect(find.byKey(const ValueKey('picture-cell-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('picture-cell-2')), findsOneWidget);
    for (final image in tester.widgetList<Image>(find.byType(Image))) {
      expect(image.fit, BoxFit.contain);
    }
  });

  testWidgets('empty picture widget can show or hide its placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TemplatePictureGrid(imagePaths: [], showPlaceholder: true),
      ),
    );
    expect(find.byKey(const Key('picture-placeholder')), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(home: TemplatePictureGrid(imagePaths: [])),
    );
    expect(find.byKey(const Key('picture-placeholder')), findsNothing);
  });

  testWidgets('picture properties show dedicated dimensions', (tester) async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    const picture = CustomTextElement(
      id: 'picture',
      text: '[media::media]',
      xMm: 0,
      yMm: 0,
      textType: kTemplatePictureTextType,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: TextPropertiesPanel(
              selectedElement: 'custom:1:picture',
              page1: true,
              template: const Template(
                name: 'Picture template',
                page1: TemplatePage(customTexts: [picture]),
                page2: TemplatePage(),
                widthMm: 100,
                heightMm: 100,
                recordType: RecordType.site,
              ),
              onUpdateCustomText: (_, _) {},
              onDeleteCustomText: (_, _) {},
              actionControls: const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Width (mm)'), findsOneWidget);
    expect(find.text('Height (mm)'), findsOneWidget);
    expect(find.text('Dynamic'), findsNothing);
    expect(find.text('Max Width (mm)'), findsNothing);
    expect(find.text('QR Code'), findsNothing);
  });

  test('media aggregate field is exposed only for record templates', () async {
    final db = Database.forTesting(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);

    for (final type in [
      RecordType.specimenRecord,
      RecordType.specimenParts,
      RecordType.site,
      RecordType.collEvent,
      RecordType.narrative,
    ]) {
      expect(availableTemplateFieldGroups(db, type)['media'], const [
        'media::media',
      ]);
    }
    expect(
      availableTemplateFieldGroups(db, RecordType.none),
      isNot(contains('media')),
    );
  });

  test('Typst output renders every picture in the configured grid bounds', () {
    final page = TemplatePage(
      customTexts: [
        CustomTextElement(
          id: 'pictures',
          text: '[media::media]',
          xMm: 5,
          yMm: 10,
          textType: kTemplatePictureTextType,
          pictureWidthMm: 40,
          pictureHeightMm: 20,
          resolvedPicturePaths: imagePaths,
        ),
      ],
    );

    final typst = DocumentWriter.renderSingleDocumentCellTypstForTesting(
      page: page,
      wPt: 200,
      hPt: 100,
    );

    for (final imagePath in imagePaths) {
      final typstImagePath = imagePath.replaceAll(r'\', r'\\');
      expect(typst, contains(typstImagePath));
    }
    expect(typst, contains('width: ${documentPdfMmToPt(40)}pt'));
    expect(typst, contains('height: ${documentPdfMmToPt(20)}pt'));

    final height = DocumentWriter.estimateTemplatePageContentHeightPtForTesting(
      page: page,
      wPt: 200,
      hPt: 100,
    );
    expect(height, closeTo(documentPdfMmToPt(30), 0.001));
  });
}
