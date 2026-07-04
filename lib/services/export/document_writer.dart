import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:nahpu/services/io_services.dart';

import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/template_service.dart';
import 'package:nahpu/services/template_settings_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/export/dynamic_record_exporter.dart';
import 'package:nahpu/src/rust/api/export.dart' as rust_export;
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:path/path.dart' as path;
import 'package:qr/qr.dart';

/// Layout options for configuring the precise physical dimensions
/// and padding of a printed document sheet.
class DocumentPrintLayoutOptions {
  /// Creates a new layout configuration.
  const DocumentPrintLayoutOptions({
    required this.rowsPerPage,
    required this.colsPerPage,
    required this.pagePadTopMm,
    required this.pagePadLeftMm,
    required this.pagePadRightMm,
    required this.pagePadBottomMm,
    required this.templatePadTopMm,
    required this.templatePadLeftMm,
    required this.templatePadRightMm,
    required this.templatePadBottomMm,
  });

  final int rowsPerPage;
  final int colsPerPage;
  final double pagePadTopMm;
  final double pagePadLeftMm;
  final double pagePadRightMm;
  final double pagePadBottomMm;
  final double templatePadTopMm;
  final double templatePadLeftMm;
  final double templatePadRightMm;
  final double templatePadBottomMm;
}

/// Orchestrates the process of converting specimen data into a generated
/// PDF document file using the Typst rendering engine.
class DocumentWriter {
  DocumentWriter({required this.ref});

  final WidgetRef ref;

  Database get _db => ref.read(databaseProvider);

  /// Generates the Typst PDF and writes it to the designated output file.
  Future<File> writeDocuments({
    required List<SpecimenData> picked,
    required Directory selectedDir,
    required String fileStem,
    required rust_config.DocumentLayoutPreset layout,
  }) async {
    double w = _getPageWidth(layout.pageSizeKey, layout.customPageWidthMm);
    double h = _getPageHeight(layout.pageSizeKey, layout.customPageHeightMm);

    if (layout.pageOrientation == 'landscape') {
      final tmp = w;
      w = h;
      h = tmp;
    }

    final pdfBytes = await generateDocumentsPdf(
      picked,
      sheetWidthPt: w * 72.0 / 25.4,
      sheetHeightPt: h * 72.0 / 25.4,
      layout: layout,
    );

    final savePath =
        await AppIOServices(dir: selectedDir, fileStem: fileStem, ext: 'pdf')
            .getSavePath();
    await savePath.writeAsBytes(pdfBytes);
    return savePath;
  }

  double _getPageWidth(String pageSizeKey, double? customPageWidthMm) {
    switch (pageSizeKey) {
      case 'A0':
        return 841.0;
      case 'A1':
        return 594.0;
      case 'A2':
        return 420.0;
      case 'A3':
        return 297.0;
      case 'Letter':
        return 215.9;
      case 'A5':
        return 148.0;
      case 'A6':
        return 105.0;
      case 'A7':
        return 74.0;
      case 'A8':
        return 52.0;
      case 'Legal':
        return 215.9;
      case 'Custom':
        return customPageWidthMm?.clamp(40.0, 1200.0) ?? 210.0;
      case 'A4':
      default:
        return 210.0;
    }
  }

  double _getPageHeight(String pageSizeKey, double? customPageHeightMm) {
    switch (pageSizeKey) {
      case 'A0':
        return 1188.0;
      case 'A1':
        return 841.0;
      case 'A2':
        return 594.0;
      case 'A3':
        return 420.0;
      case 'Letter':
        return 279.4;
      case 'A5':
        return 210.0;
      case 'A6':
        return 148.0;
      case 'A7':
        return 105.0;
      case 'A8':
        return 74.0;
      case 'Legal':
        return 355.6;
      case 'Custom':
        return customPageHeightMm?.clamp(40.0, 1200.0) ?? 297.0;
      case 'A4':
      default:
        return 297.0;
    }
  }

  Future<Uint8List> generateDocumentsPdf(
    List<SpecimenData> specimens, {
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
  }) async {
    final settings = DocumentSettingsServices();
    final templateService = const TemplateService();

    final wPt = documentPdfMmToPt(await settings.getDocumentWidthMm());
    final hPt = documentPdfMmToPt(await settings.getDocumentHeightMm());
    final duplex = await settings.getDuplex();
    final mirrorFront = await settings.getMirrorFront();
    final mirrorBack = await settings.getMirrorBack();

    // Preload templates
    final templates = <String, Template>{};
    for (final block in layout.blocks) {
      if (!templates.containsKey(block.templateName)) {
        final tmpl = await templateService.getTemplate(block.templateName);
        templates[block.templateName] =
            tmpl ?? DefaultTemplate.defaultTemplate(block.templateName);
      }
    }

    StringBuffer typst = StringBuffer();

    if (specimens.isEmpty) {
      typst.writeln(
          '#set page(width: ${sheetWidthPt}pt, height: ${sheetHeightPt}pt)');
      typst.writeln('#align(center + horizon)[No documents]');
    } else if (layout.layoutType == 'Continuous') {
      final List<_ContinuousPrintItem> continuousItems = [];

      for (final specimen in specimens) {
        for (final block in layout.blocks) {
          final tmpl = templates[block.templateName]!;
          for (var c = 0; c < block.templateCount; c++) {
            continuousItems.add(_ContinuousPrintItem(
              specimen: specimen,
              template: tmpl,
              pageTemplate: tmpl.page1,
              block: block,
              mirror: mirrorFront,
            ));
            if (duplex) {
              continuousItems.add(_ContinuousPrintItem(
                specimen: specimen,
                template: tmpl,
                pageTemplate: tmpl.page2,
                block: block,
                mirror: mirrorBack,
              ));
            }
          }
        }
      }

      for (var i = 0; i < continuousItems.length; i++) {
        final item = continuousItems[i];
        final cellWPt = wPt +
            documentPdfMmToPt(item.block.templatePadLeftMm) +
            documentPdfMmToPt(item.block.templatePadRightMm);
        final cellHPt = hPt +
            documentPdfMmToPt(item.block.templatePadTopMm) +
            documentPdfMmToPt(item.block.templatePadBottomMm);

        typst.writeln(
            '#set page(width: ${cellWPt}pt, height: ${cellHPt}pt, margin: 0pt)');

        final data =
            await documentFieldValuesForSpecimen(_db, item.specimen, ref);
        final subbedPage = await _substitutePage(item.pageTemplate, data);

        _writeSingleDocumentCell(
          typst: typst,
          page: subbedPage,
          data: data,
          wPt: wPt,
          hPt: hPt,
          templatePadTopMm: item.block.templatePadTopMm,
          templatePadLeftMm: item.block.templatePadLeftMm,
          templatePadRightMm: item.block.templatePadRightMm,
          templatePadBottomMm: item.block.templatePadBottomMm,
          mirror: item.mirror,
          outline: item.template.outline,
        );

        if (i < continuousItems.length - 1) {
          typst.writeln('#pagebreak()');
        }
      }
    } else {
      final ptTop = documentPdfMmToPt(layout.pagePadTopMm);
      final ptLeft = documentPdfMmToPt(layout.pagePadLeftMm);
      final ptBottom = documentPdfMmToPt(layout.pagePadBottomMm);
      final ptRight = documentPdfMmToPt(layout.pagePadRightMm);
      typst.writeln(
          '#set page(width: ${sheetWidthPt}pt, height: ${sheetHeightPt}pt, margin: (top: ${ptTop}pt, left: ${ptLeft}pt, bottom: ${ptBottom}pt, right: ${ptRight}pt))');

      final usableW = math.max(1.0, sheetWidthPt - ptLeft - ptRight);
      final usableH = math.max(1.0, sheetHeightPt - ptTop - ptBottom);

      for (var bIdx = 0; bIdx < layout.blocks.length; bIdx++) {
        final block = layout.blocks[bIdx];
        final tmpl = templates[block.templateName]!;
        final cols = block.cols > 0 ? block.cols : 4;
        final rows = block.rows > 0 ? block.rows : 8;
        final perSheet = cols * rows;

        final cellW = usableW / cols;
        final cellH = usableH / rows;

        final List<SpecimenData> blockSpecimens = [];
        for (final specimen in specimens) {
          for (var c = 0; c < block.templateCount; c++) {
            blockSpecimens.add(specimen);
          }
        }

        for (var start = 0; start < blockSpecimens.length; start += perSheet) {
          final end = math.min(start + perSheet, blockSpecimens.length);
          final batch = blockSpecimens.sublist(start, end);
          final isLastBatch = (start + perSheet) >= blockSpecimens.length;
          final isLastBlock = bIdx == layout.blocks.length - 1;

          final breakAfterFront = duplex ||
              !isLastBatch ||
              (isLastBatch && !isLastBlock && block.pageBreakAfter);
          final breakAfterBack = !isLastBatch ||
              (isLastBatch && !isLastBlock && block.pageBreakAfter);

          final frontPages = <TemplatePage>[];
          final frontDataList = <Map<String, String>>[];
          for (final specimen in batch) {
            final data =
                await documentFieldValuesForSpecimen(_db, specimen, ref);
            frontDataList.add(data);
            frontPages.add(await _substitutePage(tmpl.page1, data));
          }
          _writeTiledDocumentSheet(
            typst: typst,
            pages: frontPages,
            dataList: frontDataList,
            cols: cols,
            rows: rows,
            cellW: cellW,
            cellH: cellH,
            wPt: wPt,
            hPt: hPt,
            templatePadTopMm: block.templatePadTopMm,
            templatePadLeftMm: block.templatePadLeftMm,
            templatePadRightMm: block.templatePadRightMm,
            templatePadBottomMm: block.templatePadBottomMm,
            mirror: mirrorFront,
            outline: tmpl.outline,
            pageBreakAfter: breakAfterFront,
          );

          if (duplex) {
            final backPages = <TemplatePage>[];
            final backDataList = <Map<String, String>>[];
            for (final specimen in batch) {
              final data =
                  await documentFieldValuesForSpecimen(_db, specimen, ref);
              backDataList.add(data);
              backPages.add(await _substitutePage(tmpl.page2, data));
            }
            _writeTiledDocumentSheet(
              typst: typst,
              pages: backPages,
              dataList: backDataList,
              cols: cols,
              rows: rows,
              cellW: cellW,
              cellH: cellH,
              wPt: wPt,
              hPt: hPt,
              templatePadTopMm: block.templatePadTopMm,
              templatePadLeftMm: block.templatePadLeftMm,
              templatePadRightMm: block.templatePadRightMm,
              templatePadBottomMm: block.templatePadBottomMm,
              mirror: mirrorBack,
              outline: tmpl.outline,
              pageBreakAfter: breakAfterBack,
            );
          }
        }
      }
    }

    final fontBytesList = await _loadFontBytes();
    return await rust_export.compileTypstToPdf(
      typstContent: typst.toString(),
      fontBytes: fontBytesList,
    );
  }

  Future<List<Uint8List>> _loadFontBytes() async {
    final AssetManifest manifest =
        await AssetManifest.loadFromAssetBundle(rootBundle);
    final List<String> fontAssets = manifest
        .listAssets()
        .where((String key) =>
            key.startsWith('assets/fonts/') &&
            key.endsWith('.ttf') &&
            !key.contains('nahpu_font.ttf'))
        .toList();

    List<Uint8List> fontBytesList = [];
    for (var asset in fontAssets) {
      final byteData = await rootBundle.load(asset);
      fontBytesList.add(byteData.buffer.asUint8List());
    }
    return fontBytesList;
  }

  @visibleForTesting
  static List<bool> pageBreakPlanForTesting({
    required int specimenCount,
    required int documentsPerSheet,
    required bool duplex,
  }) {
    if (specimenCount <= 0 || documentsPerSheet <= 0) return const [];
    final breaks = <bool>[];
    for (var start = 0; start < specimenCount; start += documentsPerSheet) {
      final end = math.min(start + documentsPerSheet, specimenCount);
      final isLastBatch = end >= specimenCount;
      breaks.add(duplex || !isLastBatch);
      if (duplex) breaks.add(!isLastBatch);
    }
    return breaks;
  }

  Future<TemplatePage> _substitutePage(
    TemplatePage page,
    Map<String, String> data,
  ) async {
    final texts = <CustomTextElement>[];
    final tempDir = await AppServices(ref: ref).tempDirectory;
    for (final ct in page.customTexts) {
      final subbedText = substituteDocumentPlaceholders(ct.text, data);
      if (ct.isQrCode) {
        final formattedText = formatTemplateText(
          subbedText,
          ct.textType,
          ct.formatOption,
          ct.caseFormat,
        );
        final fgColorHex = _colorToHex(ct.colorArgb);
        final bgColorHex = _colorToHex(ct.qrBgColorArgb);
        final svgString = _generateQrSvg(
          formattedText,
          fgColorHex,
          bgColorHex,
          ct.qrShape,
        );
        final tempFile = File(path.join(
          tempDir.path,
          'qr_${DateTime.now().microsecondsSinceEpoch}_${ct.id}.svg',
        ));
        await tempFile.writeAsString(svgString);
        texts.add(ct.copyWith(
          text: formattedText,
          tempPath: tempFile.path,
        ));
      } else {
        texts.add(ct.copyWith(text: subbedText));
      }
    }
    return page.copyWith(customTexts: texts);
  }

  String _colorToHex(int colorArgb) {
    final hex = colorArgb.toRadixString(16).padLeft(8, '0');
    final aa = hex.substring(0, 2);
    final rgb = hex.substring(2);
    if (aa == '00') return 'none';
    if (aa == 'ff') return '#$rgb';
    return '#$rgb$aa';
  }

  String _generateQrSvg(
    String data,
    String fgColorHex,
    String bgColorHex,
    String shape,
  ) {
    final qrCode = QrCode(
      payload: QrPayload.fromString(data.isEmpty ? ' ' : data),
      errorCorrectLevel: QrErrorCorrectLevel.low,
    );
    final qrImage = QrImage(qrCode);
    final moduleCount = qrImage.moduleCount;

    final sb = StringBuffer();
    sb.writeln(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $moduleCount $moduleCount" shape-rendering="crispEdges">');
    sb.writeln(
        '  <rect width="$moduleCount" height="$moduleCount" fill="$bgColorHex"/>');

    if (shape == 'circle') {
      for (int y = 0; y < moduleCount; y++) {
        for (int x = 0; x < moduleCount; x++) {
          if (qrImage.isDark(y, x)) {
            sb.writeln(
                '  <circle cx="${x + 0.5}" cy="${y + 0.5}" r="0.5" fill="$fgColorHex"/>');
          }
        }
      }
    } else {
      sb.writeln('  <path fill="$fgColorHex" d="');
      for (int y = 0; y < moduleCount; y++) {
        for (int x = 0; x < moduleCount; x++) {
          if (qrImage.isDark(y, x)) {
            sb.write('M$x ${y}h1v1h-1z ');
          }
        }
      }
      sb.writeln('"/>');
    }
    sb.writeln('</svg>');
    return sb.toString();
  }

  void _writeTiledDocumentSheet({
    required StringBuffer typst,
    required List<TemplatePage> pages,
    required List<Map<String, String>> dataList,
    required int cols,
    required int rows,
    required double cellW,
    required double cellH,
    required double wPt,
    required double hPt,
    required double templatePadTopMm,
    required double templatePadLeftMm,
    required double templatePadRightMm,
    required double templatePadBottomMm,
    required bool mirror,
    required bool pageBreakAfter,
    TemplateOutline? outline,
  }) {
    typst.writeln('#grid(');
    typst.writeln('  columns: (${cellW}pt, ) * $cols,');
    typst.writeln('  rows: (${cellH}pt, ) * $rows,');
    typst.writeln('  column-gutter: 0pt,');
    typst.writeln('  row-gutter: 0pt,');

    for (var i = 0; i < pages.length; i++) {
      _writeSingleDocumentCell(
        typst: typst,
        page: pages[i],
        data: dataList[i],
        wPt: wPt,
        hPt: hPt,
        templatePadTopMm: templatePadTopMm,
        templatePadLeftMm: templatePadLeftMm,
        templatePadRightMm: templatePadRightMm,
        templatePadBottomMm: templatePadBottomMm,
        mirror: mirror,
        outline: outline,
      );
    }

    _fillRemainingGridSpaces(typst, pages.length, cols);
    typst.writeln(')');
    if (pageBreakAfter) {
      typst.writeln('#pagebreak()');
    }
  }

  void _writeSingleDocumentCell({
    required StringBuffer typst,
    required TemplatePage page,
    required Map<String, String> data,
    required double wPt,
    required double hPt,
    required double templatePadTopMm,
    required double templatePadLeftMm,
    required double templatePadRightMm,
    required double templatePadBottomMm,
    required bool mirror,
    TemplateOutline? outline,
  }) {
    final padTop = documentPdfMmToPt(templatePadTopMm);
    final padBottom = documentPdfMmToPt(templatePadBottomMm);
    final padLeft = documentPdfMmToPt(templatePadLeftMm);
    final padRight = documentPdfMmToPt(templatePadRightMm);

    typst.writeln('  [');
    typst.writeln(
        '#box(width: 100%, height: 100%, inset: (top: ${padTop}pt, bottom: ${padBottom}pt, left: ${padLeft}pt, right: ${padRight}pt))[');

    if (mirror) typst.writeln('#rotate(180deg, ref: "center")[');
    typst.writeln('#box(width: ${wPt}pt, height: ${hPt}pt, clip: false)[');

    _writeOutline(typst, outline, wPt, hPt);

    final allElements = sortElementsForTesting(page);

    for (final el in allElements) {
      if (el is CustomImageElement) {
        _writeSingleCustomImage(typst, el);
      } else if (el is CustomTextElement) {
        _writeSingleCustomText(typst, el, data);
      } else if (el is CustomLineElement) {
        _writeSingleCustomLine(typst, el);
      } else if (el is CustomShapeElement) {
        _writeSingleCustomShape(typst, el);
      }
    }

    typst.writeln(']'); // close box
    if (mirror) typst.writeln(']'); // close rotate
    typst.writeln(']'); // close cell inset box
    typst.writeln('],'); // close grid item
  }

  void _writeOutline(
      StringBuffer typst, TemplateOutline? outline, double wPt, double hPt) {
    if (outline == null) return;

    String strokeStyle = outline.style == TemplateOutlineStyle.dashed
        ? '"dashed"'
        : outline.style == TemplateOutlineStyle.dotted
            ? '"dotted"'
            : '"solid"';

    final r = (outline.colorArgb >> 16) & 0xFF;
    final g = (outline.colorArgb >> 8) & 0xFF;
    final b = outline.colorArgb & 0xFF;

    if (outline.style == TemplateOutlineStyle.doubleLine) {
      typst.writeln(
          '  #place(dx: 0pt, dy: 0pt)[#rect(width: 100%, height: 100%, stroke: ${outline.widthPt}pt + rgb($r, $g, $b))]');
      final inset = outline.widthPt + math.max(1.0, outline.widthPt * 1.25);
      typst.writeln(
          '  #place(dx: ${inset}pt, dy: ${inset}pt)[#rect(width: ${wPt - 2 * inset}pt, height: ${hPt - 2 * inset}pt, stroke: ${outline.widthPt}pt + rgb($r, $g, $b))]');
    } else {
      typst.writeln(
          '  #place(dx: 0pt, dy: 0pt)[#rect(width: 100%, height: 100%, stroke: (paint: rgb($r, $g, $b), thickness: ${outline.widthPt}pt, dash: $strokeStyle))]');
    }
  }

  String _escapeTypstMarkup(String text) {
    var content = text.replaceAll(r'\', r'\\');
    final activeChars = RegExp(r'([#$*_[\]<@~="+-])');
    content = content.replaceAllMapped(activeChars, (m) => '\\${m.group(0)}');
    return content;
  }

  void _writeSingleCustomText(
      StringBuffer typst, CustomTextElement t, Map<String, String> data) {
    if (t.isQrCode) {
      if (t.tempPath == null || t.tempPath!.isEmpty) return;
      String cleanPath = t.tempPath!.replaceAll(r'\', r'\\');
      final sizePt = documentPdfMmToPt(t.qrSizeMm);
      typst.writeln(
          '  #place(dx: ${documentPdfMmToPt(t.xMm)}pt, dy: ${documentPdfMmToPt(t.yMm)}pt)[#rotate(${t.rotationDegrees}deg)[#image("$cleanPath", width: ${sizePt}pt, height: ${sizePt}pt, fit: "contain")]]');
      return;
    }

    final gKey = templateGenderIconFieldKeyFromBracketText(t.text);
    if (gKey != null) {
      _writeGenderIcon(typst, t, data, gKey);
      return;
    }

    final formatted = formatTemplateText(
      t.text,
      t.textType,
      t.formatOption,
      t.caseFormat,
    );
    String content = _escapeTypstMarkup(formatted);
    final hexColor = t.colorArgb.toRadixString(16).padLeft(8, '0');
    final colorStr = 'rgb("${hexColor.substring(2)}")';
    String textProps = 'size: ${t.fontSizePt}pt, fill: $colorStr';
    if (t.bold) textProps += ', weight: "bold"';
    if (t.italic) textProps += ', style: "italic"';
    if (t.fontFamily.isNotEmpty) textProps += ', font: "${t.fontFamily}"';

    String textElem = '#text($textProps)[$content]';
    if (t.textAlign != 'left') {
      textElem = '#align(${t.textAlign})[$textElem]';
    }
    if (t.maxWidthMm != null) {
      textElem =
          '#box(width: ${documentPdfMmToPt(t.maxWidthMm!)}pt)[$textElem]';
    }

    typst.writeln(
        '  #place(dx: ${documentPdfMmToPt(t.xMm)}pt, dy: ${documentPdfMmToPt(t.yMm)}pt)[#rotate(${t.rotationDegrees}deg)[$textElem]]');
  }

  void _writeGenderIcon(StringBuffer typst, CustomTextElement t,
      Map<String, String> data, String gKey) {
    final display = _fieldValueCi(data, gKey);
    final s = display.trim().toLowerCase();
    final ch = s == 'male'
        ? '\u2642'
        : s == 'female'
            ? '\u2640'
            : '?';

    final iconWPt =
        documentPdfMmToPt(t.iconWidthMm ?? kTemplateGenderIconDefaultWidthMm);
    final iconHPt =
        documentPdfMmToPt(t.iconHeightMm ?? kTemplateGenderIconDefaultHeightMm);
    final fs = math.min(iconWPt, iconHPt) * 0.88;

    typst.writeln(
        '  #place(dx: ${documentPdfMmToPt(t.xMm)}pt, dy: ${documentPdfMmToPt(t.yMm)}pt)[#rotate(${t.rotationDegrees}deg)[#box(width: ${iconWPt}pt, height: ${iconHPt}pt)[#align(center+horizon)[#text(size: ${fs}pt, font: "DejaVu Sans")[$ch]]]]]');
  }

  String _fieldValueCi(Map<String, String> m, String key) {
    if (m.containsKey(key)) return m[key] ?? '';
    final low = key.toLowerCase();
    for (final e in m.entries) {
      if (e.key.toLowerCase() == low) return e.value;
    }
    return '';
  }

  @visibleForTesting
  static List<dynamic> sortElementsForTesting(TemplatePage page) {
    return <dynamic>[
      ...page.customImages,
      ...page.customTexts,
      ...page.customLines,
      ...page.customShapes,
    ]..sort((a, b) => (a.zIndex as int).compareTo(b.zIndex as int));
  }

  void _writeSingleCustomImage(StringBuffer typst, CustomImageElement im) {
    if (!isTemplateImagePathUsable(im.imagePath)) return;
    String path = im.imagePath.replaceAll(r'\', r'\\');

    typst.writeln(
        '  #place(dx: ${documentPdfMmToPt(im.xMm)}pt, dy: ${documentPdfMmToPt(im.yMm)}pt)[#rotate(${im.rotationDegrees}deg)[#image("$path", width: ${documentPdfMmToPt(im.widthMm)}pt, height: ${documentPdfMmToPt(im.heightMm)}pt, fit: "contain")]]');
  }

  void _writeSingleCustomLine(StringBuffer typst, CustomLineElement line) {
    final hexColor = line.colorArgb.toRadixString(16).padLeft(8, '0');
    final colorStr =
        'rgb("${hexColor.substring(2)}")'; // ignores alpha for now, assuming 100%

    final lengthPt = documentPdfMmToPt(line.lengthMm);
    String elem;
    if (line.strokeStyle == 'double') {
      final gap = line.thicknessPt * 1.25;
      final halfOffset = (line.thicknessPt + gap) / 2;
      final line1 =
          '#place(dy: -${halfOffset}pt)[#line(length: ${lengthPt}pt, stroke: ${line.thicknessPt}pt + $colorStr)]';
      final line2 =
          '#place(dy: ${halfOffset}pt)[#line(length: ${lengthPt}pt, stroke: ${line.thicknessPt}pt + $colorStr)]';
      elem = '[$line1$line2]';
    } else {
      final strokeDash = line.strokeStyle == 'dashed'
          ? '"dashed"'
          : line.strokeStyle == 'dotted'
              ? '"dotted"'
              : '"solid"';
      elem =
          '#line(length: ${lengthPt}pt, stroke: (paint: $colorStr, thickness: ${line.thicknessPt}pt, dash: $strokeDash))';
    }

    typst.writeln(
        '  #place(dx: ${documentPdfMmToPt(line.xMm)}pt, dy: ${documentPdfMmToPt(line.yMm)}pt)[#rotate(${line.rotationDegrees}deg)[$elem]]');
  }

  void _writeSingleCustomShape(StringBuffer typst, CustomShapeElement shape) {
    final strokeHex = shape.strokeColorArgb.toRadixString(16).padLeft(8, '0');
    final strokeColor = 'rgb("${strokeHex.substring(2)}")';

    String fillOpt = '';
    if (shape.fillColorArgb != null) {
      final fillHex = shape.fillColorArgb!.toRadixString(16).padLeft(8, '0');
      fillOpt = ', fill: rgb("${fillHex.substring(2)}")';
    }

    final wPt = documentPdfMmToPt(shape.widthMm);
    final hPt = documentPdfMmToPt(shape.heightMm);

    final kind = shape.shapeType == 'ellipse' ? 'ellipse' : 'rect';
    String elem;
    if (shape.shapeType == 'circle' ||
        shape.shapeType == 'triangle' ||
        shape.shapeType == 'polygon') {
      elem = _typstCustomShapeElement(
        shape,
        strokeColor,
        fillOpt,
        wPt,
        hPt,
      );
    } else if (shape.strokeStyle == 'double') {
      final outerStroke = '${shape.strokeThicknessPt}pt + $strokeColor';
      final outerElem =
          '#$kind(width: ${wPt}pt, height: ${hPt}pt, stroke: $outerStroke$fillOpt)';

      final gap = (shape.strokeThicknessPt * 1.25).clamp(1.0, 10.0);
      final doubleInset = shape.strokeThicknessPt + gap;
      final innerWPt = wPt - 2 * doubleInset;
      final innerHPt = hPt - 2 * doubleInset;

      if (innerWPt > 0 && innerHPt > 0) {
        final innerElem =
            '#place(dx: ${doubleInset}pt, dy: ${doubleInset}pt)[#$kind(width: ${innerWPt}pt, height: ${innerHPt}pt, stroke: ${shape.strokeThicknessPt}pt + $strokeColor)]';
        elem = '[$outerElem$innerElem]';
      } else {
        elem = outerElem;
      }
    } else {
      final strokeDash = shape.strokeStyle == 'dashed'
          ? '"dashed"'
          : shape.strokeStyle == 'dotted'
              ? '"dotted"'
              : '"solid"';
      elem =
          '#$kind(width: ${wPt}pt, height: ${hPt}pt, stroke: (paint: $strokeColor, thickness: ${shape.strokeThicknessPt}pt, dash: $strokeDash)$fillOpt)';
    }

    typst.writeln(
        '  #place(dx: ${documentPdfMmToPt(shape.xMm)}pt, dy: ${documentPdfMmToPt(shape.yMm)}pt)[#rotate(${shape.rotationDegrees}deg)[$elem]]');
  }

  String _typstCustomShapeElement(
    CustomShapeElement shape,
    String strokeColor,
    String fillOpt,
    double wPt,
    double hPt,
  ) {
    final strokeDash = shape.strokeStyle == 'dashed'
        ? '"dashed"'
        : shape.strokeStyle == 'dotted'
            ? '"dotted"'
            : '"solid"';
    final stroke =
        '(paint: $strokeColor, thickness: ${shape.strokeThicknessPt}pt, dash: $strokeDash)';

    if (shape.shapeType == 'circle') {
      final side = math.min(wPt, hPt);
      final dx = (wPt - side) / 2;
      final dy = (hPt - side) / 2;
      if (shape.strokeStyle == 'double') {
        final outerStroke = '${shape.strokeThicknessPt}pt + $strokeColor';
        final outerElem =
            '#place(dx: ${dx}pt, dy: ${dy}pt)[#ellipse(width: ${side}pt, height: ${side}pt, stroke: $outerStroke$fillOpt)]';
        final gap = (shape.strokeThicknessPt * 1.25).clamp(1.0, 10.0);
        final doubleInset = shape.strokeThicknessPt + gap;
        final innerSide = side - 2 * doubleInset;
        if (innerSide <= 0) return outerElem;
        final innerDx = dx + doubleInset;
        final innerDy = dy + doubleInset;
        final innerElem =
            '#place(dx: ${innerDx}pt, dy: ${innerDy}pt)[#ellipse(width: ${innerSide}pt, height: ${innerSide}pt, stroke: ${shape.strokeThicknessPt}pt + $strokeColor)]';
        return '[$outerElem$innerElem]';
      }
      return '#place(dx: ${dx}pt, dy: ${dy}pt)[#ellipse(width: ${side}pt, height: ${side}pt, stroke: $stroke$fillOpt)]';
    }

    if (shape.strokeStyle == 'double') {
      final outerStroke = '${shape.strokeThicknessPt}pt + $strokeColor';
      final outerVertices = _typstRegularPolygonVertices(
        widthPt: wPt,
        heightPt: hPt,
        sides:
            shape.shapeType == 'triangle' ? 3 : shape.polygonSides.clamp(3, 12),
      );
      final outerElem =
          '#polygon(stroke: $outerStroke$fillOpt, $outerVertices)';
      final gap = (shape.strokeThicknessPt * 1.25).clamp(1.0, 10.0);
      final doubleInset = shape.strokeThicknessPt + gap;
      final innerWPt = wPt - 2 * doubleInset;
      final innerHPt = hPt - 2 * doubleInset;
      if (innerWPt <= 0 || innerHPt <= 0) return outerElem;
      final innerVertices = _typstRegularPolygonVertices(
        widthPt: innerWPt,
        heightPt: innerHPt,
        offsetXPt: doubleInset,
        offsetYPt: doubleInset,
        sides:
            shape.shapeType == 'triangle' ? 3 : shape.polygonSides.clamp(3, 12),
      );
      final innerElem =
          '#polygon(stroke: ${shape.strokeThicknessPt}pt + $strokeColor, $innerVertices)';
      return '[$outerElem$innerElem]';
    }

    final vertices = _typstRegularPolygonVertices(
      widthPt: wPt,
      heightPt: hPt,
      sides:
          shape.shapeType == 'triangle' ? 3 : shape.polygonSides.clamp(3, 12),
    );
    return '#polygon(stroke: $stroke$fillOpt, $vertices)';
  }

  String _typstRegularPolygonVertices({
    required double widthPt,
    required double heightPt,
    required int sides,
    double offsetXPt = 0,
    double offsetYPt = 0,
  }) {
    final cx = offsetXPt + widthPt / 2;
    final cy = offsetYPt + heightPt / 2;
    final rx = widthPt / 2;
    final ry = heightPt / 2;
    final points = <String>[];
    for (var i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / sides;
      final x = cx + rx * math.cos(angle);
      final y = cy + ry * math.sin(angle);
      points.add('(${x}pt, ${y}pt)');
    }
    return points.join(', ');
  }

  void _fillRemainingGridSpaces(StringBuffer typst, int pagesLength, int cols) {
    int totalCells = pagesLength;
    while (totalCells % cols != 0) {
      typst.writeln('  [],');
      totalCells++;
    }
  }
}

/// Converts a measurement in millimeters to its equivalent in typographical points.
/// A standard point is defined as 1/72 of an inch.
double documentPdfMmToPt(double mm) => mm * 72.0 / 25.4;

/// Replaces bracket placeholders in the provided [input] string with corresponding
/// values from the [data] map.
///
/// If a placeholder key (e.g. `[catalogNum]`) is found in [data], it is replaced
/// with the associated value. Matches are performed case-insensitively.
String substituteDocumentPlaceholders(String input, Map<String, String> data) {
  if (isTemplateBracketGenderIconText(input)) return input;
  return input.replaceAllMapped(RegExp(r'\[([^\]]+)\]'), (m) {
    final k = m.group(1)!.trim();
    if (data.containsKey(k)) return data[k]!;
    final lower = k.toLowerCase();
    for (final e in data.entries) {
      if (e.key.toLowerCase() == lower) return e.value;
    }
    return m.group(0)!;
  });
}

/// Extracts and aggregates a dictionary of all supported document variables
/// for a specific [s] SpecimenData record from the [db] database.
///
/// The returned map contains key-value pairs representing data fields (e.g.,
/// 'catalogNum', 'species', 'locality') ready to be injected into a template.
Future<Map<String, String>> documentFieldValuesForSpecimen(
  Database db,
  SpecimenData s,
  WidgetRef ref,
) async {
  final m = <String, String>{};

  try {
    final exporter =
        DynamicRecordExporter(ref: ref, concatenateMultiEntry: true);
    final records = await exporter.getRecord(s);
    if (records.isNotEmpty) {
      m.addAll(records.first);
    }
  } catch (_) {}

  return m;
}

class _ContinuousPrintItem {
  _ContinuousPrintItem({
    required this.specimen,
    required this.template,
    required this.pageTemplate,
    required this.block,
    required this.mirror,
  });
  final SpecimenData specimen;
  final Template template;
  final TemplatePage pageTemplate;
  final rust_config.DocumentLayoutBlock block;
  final bool mirror;
}
