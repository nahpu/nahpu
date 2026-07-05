part of '../document_writer.dart';

class _DocumentTypstRenderer {
  const _DocumentTypstRenderer();

  void writeTiledDocumentSheet({
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
      writeSingleDocumentCell(
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

  void writeSingleDocumentCell({
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

    final allElements = sortElements(page);

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

  static List<dynamic> sortElements(TemplatePage page) {
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
