import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/export/document_writer.dart';
import 'package:nahpu/src/rust/api/document.dart' as rust_document;
import 'package:nahpu/src/rust/frb_generated.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      final dylibPath = Platform.isMacOS
          ? 'rust/target/debug/librust_lib_nahpu.dylib'
          : Platform.isWindows
          ? 'rust/target/debug/rust_lib_nahpu.dll'
          : 'rust/target/debug/librust_lib_nahpu.so';
      await RustLib.init(externalLibrary: ExternalLibrary.open(dylibPath));
    } else {
      await RustLib.init();
    }
  });

  test('conditional brackets and generated markup compile to PDF', () async {
    final conditionalText = resolveDocumentTemplatePlaceholders(
      text: 'TTL: [[totalLength][accuracy=="Tail cropped"]] mm',
      data: const {
        'mammalAttribute::totalLength': '123',
        'mammalAttribute::accuracy': 'Tail cropped',
      },
      textType: 'normal',
      formatOption: 'normal',
    );
    final scientificName = resolveDocumentTemplatePlaceholders(
      text: '[[scientificName][genus=="Aeromys"]]',
      data: const {
        'taxon::scientificName': 'Aeromys tephromelas',
        'taxon::genus': 'Aeromys',
      },
      textType: 'normal',
      formatOption: 'normal',
    );
    final replacementText = resolveDocumentTemplatePlaceholders(
      text: 'Sex: [[sex][sex=="0"]=>"Male"]]',
      data: const {'mammalAttribute::sex': '0'},
      textType: 'normal',
      formatOption: 'normal',
    );
    final markdownTypst = await rust_document.markdownToTypst(
      markdownContent: '''
| Field | Value |
| --- | --- |
| Total length | [123] |
''',
    );
    final page = TemplatePage(
      customTexts: [
        CustomTextElement(
          id: 'conditional-pdf',
          text: conditionalText,
          xMm: 2,
          yMm: 2,
        ),
        CustomTextElement(
          id: 'markdown-pdf',
          text: markdownTypst,
          xMm: 2,
          yMm: 16,
          textType: 'markdown',
          maxWidthMm: 55,
        ),
        CustomTextElement(
          id: 'scientific-name-pdf',
          text: scientificName,
          xMm: 2,
          yMm: 9,
        ),
        CustomTextElement(
          id: 'conditional-replacement-pdf',
          text: replacementText,
          xMm: 30,
          yMm: 2,
        ),
      ],
    );
    final cell = DocumentWriter.renderSingleDocumentCellTypstForTesting(
      page: page,
      wPt: 180,
      hPt: 100,
    );
    final source =
        '''
#set page(width: 180pt, height: 100pt, margin: 0pt)
#grid(
  columns: (180pt,),
  rows: (100pt,),
$cell
)
''';
    final font = await rootBundle.load('assets/fonts/Merriweather-Regular.ttf');

    final pdf = await rust_document.compileTypstToPdf(
      typstContent: source,
      fontBytes: [font.buffer.asUint8List()],
    );

    expect(conditionalText, 'TTL: [123] mm');
    expect(scientificName, '[Aeromys tephromelas]');
    expect(replacementText, 'Sex: Male');
    expect(cell, contains(r'\[123\]'));
    expect(cell, contains(r'\[Aeromys tephromelas\]'));
    expect(cell, contains('Sex: Male'));
    expect(cell, contains(markdownTypst));
    expect(String.fromCharCodes(pdf.take(4)), '%PDF');
  });

  test('long dynamic auto-fill text continues on later PDF pages', () async {
    final narrative = [
      'BEGIN_FLOW',
      ...List.generate(260, (index) => 'narrative$index'),
      'END_FLOW',
    ].join(' ');
    final page = TemplatePage(
      customTexts: [
        const CustomTextElement(
          id: 'header',
          text: 'HEADER_ONCE',
          xMm: 2,
          yMm: 2,
          fontSizePt: 9,
        ),
        CustomTextElement(
          id: 'narrative',
          text: narrative,
          xMm: 2,
          yMm: 10,
          fontSizePt: 9,
          maxWidthMm: 55,
          isDynamic: true,
        ),
        const CustomTextElement(
          id: 'footer',
          text: 'AFTER_FLOW',
          xMm: 2,
          yMm: 20,
          fontSizePt: 9,
        ),
      ],
    );
    final cell = DocumentWriter.renderSingleDocumentCellTypstForTesting(
      page: page,
      wPt: documentPdfMmToPt(60),
      hPt: documentPdfMmToPt(30),
      autoHeight: true,
      templatePadTopMm: 2,
      templatePadBottomMm: 2,
    );
    final widthPt = documentPdfMmToPt(60);
    final source =
        '''
#set page(width: ${widthPt}pt, height: 120pt, margin: 0pt)
#grid(
  columns: (${widthPt}pt,),
  column-gutter: 0pt,
  row-gutter: 0pt,
$cell
)
''';
    final font = await rootBundle.load('assets/fonts/Merriweather-Regular.ttf');
    final pdf = await rust_document.compileTypstToPdf(
      typstContent: source,
      fontBytes: [font.buffer.asUint8List()],
    );
    final pdfSource = String.fromCharCodes(pdf);
    final pageCount = RegExp(r'/Type /Page\b').allMatches(pdfSource).length;

    expect(String.fromCharCodes(pdf.take(4)), '%PDF');
    expect(pageCount, greaterThan(1));
  });
}
