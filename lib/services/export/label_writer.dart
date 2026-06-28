import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:nahpu/services/io_services.dart';

import 'package:flutter/services.dart' show rootBundle, AssetManifest;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/export/labels/label_template_model.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/label_template_service.dart';
import 'package:nahpu/services/label_settings_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/export/dynamic_record_exporter.dart';
import 'package:nahpu/src/rust/api/export.dart' as rust_export;

/// Layout options for configuring the precise physical dimensions
/// and padding of a printed label sheet.
class LabelPrintLayoutOptions {
  /// Creates a new layout configuration.
  const LabelPrintLayoutOptions({
    required this.rowsPerPage,
    required this.colsPerPage,
    required this.pagePadTopMm,
    required this.pagePadLeftMm,
    required this.pagePadRightMm,
    required this.pagePadBottomMm,
    required this.labelPadTopMm,
    required this.labelPadLeftMm,
    required this.labelPadRightMm,
    required this.labelPadBottomMm,
  });

  final int rowsPerPage;
  final int colsPerPage;
  final double pagePadTopMm;
  final double pagePadLeftMm;
  final double pagePadRightMm;
  final double pagePadBottomMm;
  final double labelPadTopMm;
  final double labelPadLeftMm;
  final double labelPadRightMm;
  final double labelPadBottomMm;
}

/// Orchestrates the process of converting specimen data into a generated
/// PDF label file using the Typst rendering engine.
class LabelWriter {
  LabelWriter({required this.ref});

  final WidgetRef ref;

  Database get _db => ref.read(databaseProvider);

  /// Generates the Typst PDF and writes it to the designated output file.
  ///
  /// [picked] The list of specimens to print labels for.
  /// [selectedDir] The destination directory for the generated PDF.
  /// [fileStem] The base name (without extension) of the output file.
  /// [template] The label template containing design specifications.
  /// [pageSizeKey] The selected page size preset (e.g. 'A4', 'Letter', 'Custom').
  /// [pageOrientation] The orientation of the page ('portrait' or 'landscape').
  /// [customPageWidthMm] The custom width in millimeters if pageSizeKey is 'Custom'.
  /// [customPageHeightMm] The custom height in millimeters if pageSizeKey is 'Custom'.
  /// [layout] The layout options defining rows, columns, and padding.
  Future<void> writeLabels({
    required List<SpecimenData> picked,
    required Directory selectedDir,
    required String fileStem,
    required LabelTemplate? template,
    required String pageSizeKey,
    required String pageOrientation,
    required double? customPageWidthMm,
    required double? customPageHeightMm,
    required LabelPrintLayoutOptions layout,
  }) async {
    double w = _getPageWidth(pageSizeKey, customPageWidthMm);
    double h = _getPageHeight(pageSizeKey, customPageHeightMm);

    if (pageOrientation == 'landscape') {
      final tmp = w;
      w = h;
      h = tmp;
    }

    final pdfBytes = await generateLabelsPdf(
      picked,
      template: template,
      sheetWidthPt: w * 72.0 / 25.4,
      sheetHeightPt: h * 72.0 / 25.4,
      layout: layout,
    );

    final savePath =
        await AppIOServices(dir: selectedDir, fileStem: fileStem, ext: 'pdf')
            .getSavePath();
    await savePath.writeAsBytes(pdfBytes);
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

  Future<Uint8List> generateLabelsPdf(
    List<SpecimenData> specimens, {
    LabelTemplate? template,
    required double sheetWidthPt,
    required double sheetHeightPt,
    required LabelPrintLayoutOptions layout,
  }) async {
    final settings = LabelSettingsServices();
    final tmpl =
        template ?? await const LabelTemplateService().getCurrentTemplate();

    final wPt = labelPdfMmToPt(await settings.getLabelWidthMm());
    final hPt = labelPdfMmToPt(await settings.getLabelHeightMm());
    final duplex = await settings.getDuplex();

    final usableW = math.max(
        1.0,
        sheetWidthPt -
            labelPdfMmToPt(layout.pagePadLeftMm) -
            labelPdfMmToPt(layout.pagePadRightMm));
    final usableH = math.max(
        1.0,
        sheetHeightPt -
            labelPdfMmToPt(layout.pagePadTopMm) -
            labelPdfMmToPt(layout.pagePadBottomMm));

    final s = _calculateScale(usableW, usableH, wPt, hPt);
    final cellW =
        layout.colsPerPage > 0 ? usableW / layout.colsPerPage : wPt * s;
    final cellH =
        layout.rowsPerPage > 0 ? usableH / layout.rowsPerPage : hPt * s;

    final cols = layout.colsPerPage > 0
        ? layout.colsPerPage
        : math.max(1, (usableW / cellW).floor());
    final rows = layout.rowsPerPage > 0
        ? layout.rowsPerPage
        : math.max(1, (usableH / cellH).floor());

    StringBuffer typst = StringBuffer();
    _writePageSetup(typst, sheetWidthPt, sheetHeightPt, layout);

    if (specimens.isEmpty) {
      typst.writeln('#align(center + horizon)[No labels]');
    } else {
      await _writeSpecimenLabels(
        typst: typst,
        specimens: specimens,
        tmpl: tmpl,
        layout: layout,
        cols: cols,
        rows: rows,
        cellW: cellW,
        cellH: cellH,
        wPt: wPt,
        hPt: hPt,
        duplex: duplex,
        mirrorFront: await settings.getMirrorFront(),
        mirrorBack: await settings.getMirrorBack(),
      );
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

  double _calculateScale(
      double usableW, double usableH, double wPt, double hPt) {
    final fitScale = math.min(1.0, math.min(usableW / wPt, usableH / hPt));
    return fitScale <= 0 ? 1e-6 : fitScale;
  }

  void _writePageSetup(StringBuffer typst, double sheetWidthPt,
      double sheetHeightPt, LabelPrintLayoutOptions layout) {
    final ptTop = labelPdfMmToPt(layout.pagePadTopMm);
    final ptLeft = labelPdfMmToPt(layout.pagePadLeftMm);
    final ptBottom = labelPdfMmToPt(layout.pagePadBottomMm);
    final ptRight = labelPdfMmToPt(layout.pagePadRightMm);
    typst.writeln(
        '#set page(width: ${sheetWidthPt}pt, height: ${sheetHeightPt}pt, margin: (top: ${ptTop}pt, left: ${ptLeft}pt, bottom: ${ptBottom}pt, right: ${ptRight}pt))');
  }

  Future<void> _writeSpecimenLabels({
    required StringBuffer typst,
    required List<SpecimenData> specimens,
    required LabelTemplate tmpl,
    required LabelPrintLayoutOptions layout,
    required int cols,
    required int rows,
    required double cellW,
    required double cellH,
    required double wPt,
    required double hPt,
    required bool duplex,
    required bool mirrorFront,
    required bool mirrorBack,
  }) async {
    final perSheet = cols * rows;
    for (var start = 0; start < specimens.length; start += perSheet) {
      final end = math.min(start + perSheet, specimens.length);
      final batch = specimens.sublist(start, end);

      await _writeLabelSide(
        typst: typst,
        batch: batch,
        pageTemplate: tmpl.page1,
        layout: layout,
        cols: cols,
        rows: rows,
        cellW: cellW,
        cellH: cellH,
        wPt: wPt,
        hPt: hPt,
        mirror: mirrorFront,
        outline: tmpl.outline,
      );

      if (duplex) {
        await _writeLabelSide(
          typst: typst,
          batch: batch,
          pageTemplate: tmpl.page2,
          layout: layout,
          cols: cols,
          rows: rows,
          cellW: cellW,
          cellH: cellH,
          wPt: wPt,
          hPt: hPt,
          mirror: mirrorBack,
          outline: tmpl.outline,
        );
      }
    }
  }

  Future<void> _writeLabelSide({
    required StringBuffer typst,
    required List<SpecimenData> batch,
    required LabelPageTemplate pageTemplate,
    required LabelPrintLayoutOptions layout,
    required int cols,
    required int rows,
    required double cellW,
    required double cellH,
    required double wPt,
    required double hPt,
    required bool mirror,
    LabelTemplateOutline? outline,
  }) async {
    final dataList = <Map<String, String>>[];
    final pages = <LabelPageTemplate>[];

    for (final specimen in batch) {
      final data = await fieldValuesForSpecimen(_db, specimen, ref);
      dataList.add(data);
      pages.add(await _substitutePage(pageTemplate, data));
    }

    _writeTiledLabelSheet(
      typst: typst,
      pages: pages,
      dataList: dataList,
      cols: cols,
      rows: rows,
      cellW: cellW,
      cellH: cellH,
      wPt: wPt,
      hPt: hPt,
      layout: layout,
      mirror: mirror,
      outline: outline,
    );
  }

  Future<LabelPageTemplate> _substitutePage(
    LabelPageTemplate page,
    Map<String, String> data,
  ) async {
    final texts = <CustomTextElement>[];
    for (final ct in page.customTexts) {
      texts.add(ct.copyWith(text: substituteLabelPlaceholders(ct.text, data)));
    }
    return page.copyWith(customTexts: texts);
  }

  void _writeTiledLabelSheet({
    required StringBuffer typst,
    required List<LabelPageTemplate> pages,
    required List<Map<String, String>> dataList,
    required int cols,
    required int rows,
    required double cellW,
    required double cellH,
    required double wPt,
    required double hPt,
    required LabelPrintLayoutOptions layout,
    required bool mirror,
    LabelTemplateOutline? outline,
  }) {
    typst.writeln('#grid(');
    typst.writeln('  columns: (${cellW}pt, ) * $cols,');
    typst.writeln('  rows: (${cellH}pt, ) * $rows,');
    typst.writeln('  column-gutter: 0pt,');
    typst.writeln('  row-gutter: 0pt,');

    for (var i = 0; i < pages.length; i++) {
      _writeSingleLabelCell(
        typst: typst,
        page: pages[i],
        data: dataList[i],
        wPt: wPt,
        hPt: hPt,
        layout: layout,
        mirror: mirror,
        outline: outline,
      );
    }

    _fillRemainingGridSpaces(typst, pages.length, cols);
    typst.writeln(')');
    typst.writeln('#pagebreak()');
  }

  void _writeSingleLabelCell({
    required StringBuffer typst,
    required LabelPageTemplate page,
    required Map<String, String> data,
    required double wPt,
    required double hPt,
    required LabelPrintLayoutOptions layout,
    required bool mirror,
    LabelTemplateOutline? outline,
  }) {
    final padTop = labelPdfMmToPt(layout.labelPadTopMm);
    final padBottom = labelPdfMmToPt(layout.labelPadBottomMm);
    final padLeft = labelPdfMmToPt(layout.labelPadLeftMm);
    final padRight = labelPdfMmToPt(layout.labelPadRightMm);

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

  void _writeOutline(StringBuffer typst, LabelTemplateOutline? outline,
      double wPt, double hPt) {
    if (outline == null) return;

    String strokeStyle = outline.style == LabelTemplateOutlineStyle.dashed
        ? '"dashed"'
        : outline.style == LabelTemplateOutlineStyle.dotted
            ? '"dotted"'
            : '"solid"';

    final r = (outline.colorArgb >> 16) & 0xFF;
    final g = (outline.colorArgb >> 8) & 0xFF;
    final b = outline.colorArgb & 0xFF;

    if (outline.style == LabelTemplateOutlineStyle.doubleLine) {
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
    final gKey = labelGenderIconFieldKeyFromBracketText(t.text);
    if (gKey != null) {
      _writeGenderIcon(typst, t, data, gKey);
      return;
    }

    String content =
        _escapeTypstMarkup(formatTextWithCase(t.text, t.caseFormat));
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
      textElem = '#box(width: ${labelPdfMmToPt(t.maxWidthMm!)}pt)[$textElem]';
    }

    typst.writeln(
        '  #place(dx: ${labelPdfMmToPt(t.xMm)}pt, dy: ${labelPdfMmToPt(t.yMm)}pt)[#rotate(${t.rotationDegrees}deg)[$textElem]]');
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
        labelPdfMmToPt(t.iconWidthMm ?? kLabelGenderIconDefaultWidthMm);
    final iconHPt =
        labelPdfMmToPt(t.iconHeightMm ?? kLabelGenderIconDefaultHeightMm);
    final fs = math.min(iconWPt, iconHPt) * 0.88;

    typst.writeln(
        '  #place(dx: ${labelPdfMmToPt(t.xMm)}pt, dy: ${labelPdfMmToPt(t.yMm)}pt)[#rotate(${t.rotationDegrees}deg)[#box(width: ${iconWPt}pt, height: ${iconHPt}pt)[#align(center+horizon)[#text(size: ${fs}pt, font: "DejaVu Sans")[$ch]]]]]');
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
  static List<dynamic> sortElementsForTesting(LabelPageTemplate page) {
    return <dynamic>[
      ...page.customImages,
      ...page.customTexts,
      ...page.customLines,
      ...page.customShapes,
    ]..sort((a, b) => (a.zIndex as int).compareTo(b.zIndex as int));
  }

  void _writeSingleCustomImage(StringBuffer typst, CustomImageElement im) {
    if (!isLabelImagePathUsable(im.imagePath)) return;
    String path = im.imagePath.replaceAll(r'\', r'\\');

    typst.writeln(
        '  #place(dx: ${labelPdfMmToPt(im.xMm)}pt, dy: ${labelPdfMmToPt(im.yMm)}pt)[#rotate(${im.rotationDegrees}deg)[#image("$path", width: ${labelPdfMmToPt(im.widthMm)}pt, height: ${labelPdfMmToPt(im.heightMm)}pt, fit: "contain")]]');
  }

  void _writeSingleCustomLine(StringBuffer typst, CustomLineElement line) {
    final hexColor = line.colorArgb.toRadixString(16).padLeft(8, '0');
    final colorStr =
        'rgb("${hexColor.substring(2)}")'; // ignores alpha for now, assuming 100%

    final lengthPt = labelPdfMmToPt(line.lengthMm);
    final elem =
        '#line(length: ${lengthPt}pt, stroke: ${line.thicknessPt}pt + $colorStr)';

    typst.writeln(
        '  #place(dx: ${labelPdfMmToPt(line.xMm)}pt, dy: ${labelPdfMmToPt(line.yMm)}pt)[#rotate(${line.rotationDegrees}deg)[$elem]]');
  }

  void _writeSingleCustomShape(StringBuffer typst, CustomShapeElement shape) {
    final strokeHex = shape.strokeColorArgb.toRadixString(16).padLeft(8, '0');
    final strokeColor = 'rgb("${strokeHex.substring(2)}")';

    String fillOpt = '';
    if (shape.fillColorArgb != null) {
      final fillHex = shape.fillColorArgb!.toRadixString(16).padLeft(8, '0');
      fillOpt = ', fill: rgb("${fillHex.substring(2)}")';
    }

    final wPt = labelPdfMmToPt(shape.widthMm);
    final hPt = labelPdfMmToPt(shape.heightMm);

    final kind = shape.shapeType == 'ellipse' ? 'ellipse' : 'rect';
    final elem =
        '#$kind(width: ${wPt}pt, height: ${hPt}pt, stroke: ${shape.strokeThicknessPt}pt + $strokeColor$fillOpt)';

    typst.writeln(
        '  #place(dx: ${labelPdfMmToPt(shape.xMm)}pt, dy: ${labelPdfMmToPt(shape.yMm)}pt)[#rotate(${shape.rotationDegrees}deg)[$elem]]');
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
double labelPdfMmToPt(double mm) => mm * 72.0 / 25.4;

/// Replaces bracket placeholders in the provided [input] string with corresponding
/// values from the [data] map.
///
/// If a placeholder key (e.g. `[catalogNum]`) is found in [data], it is replaced
/// with the associated value. Matches are performed case-insensitively.
String substituteLabelPlaceholders(String input, Map<String, String> data) {
  if (isLabelBracketGenderIconText(input)) return input;
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

/// Extracts and aggregates a dictionary of all supported label variables
/// for a specific [s] SpecimenData record from the [db] database.
///
/// The returned map contains key-value pairs representing data fields (e.g.,
/// 'catalogNum', 'species', 'locality') ready to be injected into a label template.
Future<Map<String, String>> fieldValuesForSpecimen(
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
