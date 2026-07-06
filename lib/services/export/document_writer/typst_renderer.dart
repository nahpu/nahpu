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

  void writeAutoFillDocumentSheet({
    required StringBuffer typst,
    required List<TemplatePage> pages,
    required List<Map<String, String>> dataList,
    required int cols,
    required double cellW,
    required double usableH,
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
    typst.writeln('#box(width: 100%, height: ${usableH}pt, clip: true)[');
    typst.writeln('#grid(');
    typst.writeln('  columns: (${cellW}pt, ) * $cols,');
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
        autoHeight: true,
      );
    }

    _fillRemainingGridSpaces(typst, pages.length, cols);
    typst.writeln(')');
    typst.writeln(']');
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
    bool continuous = false,
    bool autoHeight = false,
  }) {
    final padTop = documentPdfMmToPt(templatePadTopMm);
    final padBottom = documentPdfMmToPt(templatePadBottomMm);
    final padLeft = documentPdfMmToPt(templatePadLeftMm);
    final padRight = documentPdfMmToPt(templatePadRightMm);
    final cellWPt = wPt + padLeft + padRight;
    final cellHPt = hPt + padTop + padBottom;

    typst.writeln('  [');

    final dynamicTexts = page.customTexts
        .where((t) =>
            t.isDynamic &&
            !t.isQrCode &&
            templateGenderIconFieldKeyFromBracketText(t.text) == null)
        .toList();

    if (dynamicTexts.isNotEmpty) {
      final initialCellHeight =
          autoHeight ? _staticContentHeightPt(page, wPt) : hPt;
      typst.writeln('#style(styles => {');
      typst.writeln('  let cell_height = ${initialCellHeight}pt');
      for (final t in dynamicTexts) {
        final varSuffix = _typstVarSuffix(t.id);
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
        textProps += ', font: "${_typstTemplateFont(t.fontFamily)}"';

        final mwPt = t.maxWidthMm != null
            ? '${documentPdfMmToPt(t.maxWidthMm!)}pt'
            : '${wPt - documentPdfMmToPt(t.xMm)}pt';
        final dyPt = '${documentPdfMmToPt(t.yMm)}pt';
        final baselinePt =
            t.heightMm != null ? documentPdfMmToPt(t.heightMm!) : 0.0;
        final measureBoxArgs = _textBoxArgs(t, width: mwPt);
        final measureBox = measureBoxArgs.isEmpty
            ? 'box(width: $mwPt)'
            : 'box($measureBoxArgs)';

        typst.writeln(
            '  let h_$varSuffix = measure($measureBox[#text($textProps)[$content]], styles).height');
        typst.writeln(
            '  let grow_$varSuffix = calc.max(0pt, h_$varSuffix - ${baselinePt}pt)');
        typst.writeln(
            '  cell_height = calc.max(cell_height, $dyPt + h_$varSuffix)');
      }

      for (final el in sortElements(page)) {
        final shift = _dynamicShiftExpression(
          dynamicTexts,
          _elementTopMm(el),
          excludeElement: el,
        );
        if (el is CustomTextElement &&
            el.isDynamic &&
            !el.isQrCode &&
            templateGenderIconFieldKeyFromBracketText(el.text) == null) {
          final varSuffix = _typstVarSuffix(el.id);
          typst.writeln(
              '  cell_height = calc.max(cell_height, ${documentPdfMmToPt(el.yMm)}pt + h_$varSuffix${shift == '0pt' ? '' : ' + $shift'})');
        } else {
          final bottom = _elementBottomPt(el, wPt);
          if (bottom <= 0) continue;
          if (shift != '0pt') {
            typst.writeln(
                '  cell_height = calc.max(cell_height, ${bottom}pt + $shift)');
          }
        }
      }

      if (continuous || autoHeight) {
        final width = continuous ? '${cellWPt}pt' : '100%';
        typst.writeln(
            '  let outer_height = cell_height + ${padTop}pt + ${padBottom}pt');
        typst.writeln(
            '  box(width: $width, height: outer_height, inset: (top: ${padTop}pt, bottom: ${padBottom}pt, left: ${padLeft}pt, right: ${padRight}pt))[');
      } else {
        typst.writeln(
            '  box(width: 100%, height: 100%, inset: (top: ${padTop}pt, bottom: ${padBottom}pt, left: ${padLeft}pt, right: ${padRight}pt))[');
      }

      if (mirror) typst.writeln('    #rotate(180deg, origin: center)[');
      typst.writeln(
          '      #box(width: ${wPt}pt, height: cell_height, clip: false)[');
    } else {
      if (continuous || autoHeight) {
        final width = continuous ? '${cellWPt}pt' : '100%';
        typst.writeln(
            '#box(width: $width, height: ${cellHPt}pt, inset: (top: ${padTop}pt, bottom: ${padBottom}pt, left: ${padLeft}pt, right: ${padRight}pt))[');
      } else {
        typst.writeln(
            '#box(width: 100%, height: 100%, inset: (top: ${padTop}pt, bottom: ${padBottom}pt, left: ${padLeft}pt, right: ${padRight}pt))[');
      }

      if (mirror) typst.writeln('  #rotate(180deg, origin: center)[');
      typst
          .writeln('    #box(width: ${wPt}pt, height: ${hPt}pt, clip: false)[');
    }

    _writeOutline(typst, outline, wPt, hPt);

    final allElements = sortElements(page);

    for (final el in allElements) {
      final dyShift = _dynamicShiftExpression(
        dynamicTexts,
        _elementTopMm(el),
        excludeElement: el,
      );
      if (el is CustomImageElement) {
        _writeSingleCustomImage(typst, el, dyShift);
      } else if (el is CustomTextElement) {
        _writeSingleCustomText(typst, el, data, dyShift);
      } else if (el is CustomLineElement) {
        _writeSingleCustomLine(typst, el, dyShift);
      } else if (el is CustomShapeElement) {
        _writeSingleCustomShape(typst, el, dyShift);
      }
    }

    typst.writeln(']'); // close inner box
    if (mirror) typst.writeln(']'); // close rotate
    typst.writeln(']'); // close outer box / cell inset box
    if (dynamicTexts.isNotEmpty) {
      typst.writeln('})'); // close style
    }
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
          '  #place(dx: ${inset}pt, dy: ${inset}pt)[#rect(width: 100% - ${2 * inset}pt, height: 100% - ${2 * inset}pt, stroke: ${outline.widthPt}pt + rgb($r, $g, $b))]');
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

  String _typstVarSuffix(String id) {
    final sanitized = id.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
    if (sanitized.isEmpty) return 'text';
    if (RegExp(r'^[0-9]').hasMatch(sanitized)) return 'v_$sanitized';
    return sanitized;
  }

  String _dynamicShiftExpression(
    List<CustomTextElement> dynamicTexts,
    double yMm, {
    required dynamic excludeElement,
  }) {
    final shifts = <String>[];
    for (final text in dynamicTexts) {
      if (identical(text, excludeElement)) continue;
      if (yMm > text.yMm) {
        shifts.add('grow_${_typstVarSuffix(text.id)}');
      }
    }
    return shifts.isEmpty ? '0pt' : shifts.join(' + ');
  }

  String _dyPt(double yMm, String dyShift) {
    final base = '${documentPdfMmToPt(yMm)}pt';
    return dyShift == '0pt' ? base : '$base + $dyShift';
  }

  void _writeSingleCustomText(
    StringBuffer typst,
    CustomTextElement t,
    Map<String, String> data,
    String dyShift,
  ) {
    if (t.isQrCode) {
      if (t.tempPath == null || t.tempPath!.isEmpty) return;
      String cleanPath = t.tempPath!.replaceAll(r'\', r'\\');
      final sizePt = documentPdfMmToPt(t.qrSizeMm);
      typst.writeln(
          '  #place(dx: ${documentPdfMmToPt(t.xMm)}pt, dy: ${_dyPt(t.yMm, dyShift)})[#rotate(${t.rotationDegrees}deg, origin: center)[#image("$cleanPath", width: ${sizePt}pt, height: ${sizePt}pt, fit: "contain")]]');
      return;
    }

    final gKey = templateGenderIconFieldKeyFromBracketText(t.text);
    if (gKey != null) {
      _writeGenderIcon(typst, t, data, gKey, dyShift);
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
    textProps += ', font: "${_typstTemplateFont(t.fontFamily)}"';

    String textElem = '#text($textProps)[$content]';
    if (t.textAlign != 'left') {
      textElem = '#align(${t.textAlign})[$textElem]';
    }
    final hasWidth = t.maxWidthMm != null;
    final hasHeight = t.heightMm != null && !t.isDynamic;
    final hasBackground = t.backgroundColorArgb != null;
    final hasBorder = t.borderColorArgb != null && t.borderWidthPt > 0;
    if (hasWidth || hasHeight || hasBackground || hasBorder) {
      final wPart =
          hasWidth ? 'width: ${documentPdfMmToPt(t.maxWidthMm!)}pt' : '';
      final hPart =
          hasHeight ? 'height: ${documentPdfMmToPt(t.heightMm!)}pt' : '';
      final fillPart =
          hasBackground ? 'fill: ${_typstColor(t.backgroundColorArgb!)}' : '';
      final strokePart = hasBorder ? 'stroke: ${_typstTextStroke(t)}' : '';
      final radiusPart =
          t.cornerRadiusPt > 0 ? 'radius: ${t.cornerRadiusPt}pt' : '';
      final insetPart =
          (hasBackground || hasBorder) ? 'inset: ${t.paddingPt}pt' : '';
      final args = [wPart, hPart, fillPart, strokePart, radiusPart, insetPart]
          .where((p) => p.isNotEmpty)
          .join(', ');
      textElem = '#box($args)[$textElem]';
    }

    typst.writeln(
        '  #place(dx: ${documentPdfMmToPt(t.xMm)}pt, dy: ${_dyPt(t.yMm, dyShift)})[#rotate(${t.rotationDegrees}deg)[$textElem]]');
  }

  void _writeGenderIcon(StringBuffer typst, CustomTextElement t,
      Map<String, String> data, String gKey, String dyShift) {
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
        '  #place(dx: ${documentPdfMmToPt(t.xMm)}pt, dy: ${_dyPt(t.yMm, dyShift)})[#rotate(${t.rotationDegrees}deg, origin: center)[#box(width: ${iconWPt}pt, height: ${iconHPt}pt)[#align(center+horizon)[#text(size: ${fs}pt, font: "DejaVu Sans")[$ch]]]]]');
  }

  String _fieldValueCi(Map<String, String> m, String key) {
    if (m.containsKey(key)) return m[key] ?? '';
    final low = key.toLowerCase();
    for (final e in m.entries) {
      if (e.key.toLowerCase() == low) return e.value;
    }
    return '';
  }

  String _typstColor(int argb) {
    final hexColor = argb.toRadixString(16).padLeft(8, '0');
    return 'rgb("${hexColor.substring(2)}")';
  }

  String _typstTemplateFont(String fontFamily) {
    final font = fontFamily.trim();
    return font.isEmpty ? 'Merriweather' : font;
  }

  String _textBoxArgs(
    CustomTextElement text, {
    String? width,
    String? height,
  }) {
    final hasBackground = text.backgroundColorArgb != null;
    final hasBorder = text.borderColorArgb != null && text.borderWidthPt > 0;
    if (!hasBackground && !hasBorder) return '';
    final fillPart =
        hasBackground ? 'fill: ${_typstColor(text.backgroundColorArgb!)}' : '';
    final strokePart = hasBorder ? 'stroke: ${_typstTextStroke(text)}' : '';
    final radiusPart =
        text.cornerRadiusPt > 0 ? 'radius: ${text.cornerRadiusPt}pt' : '';
    return [
      if (width != null) 'width: $width',
      if (height != null) 'height: $height',
      fillPart,
      strokePart,
      radiusPart,
      'inset: ${text.paddingPt}pt',
    ].where((p) => p.isNotEmpty).join(', ');
  }

  String _typstTextStroke(CustomTextElement text) {
    final dash = text.borderStrokeStyle == 'dashed'
        ? ', dash: "dashed"'
        : text.borderStrokeStyle == 'dotted'
            ? ', dash: "dotted"'
            : '';
    return '(paint: ${_typstColor(text.borderColorArgb!)}, thickness: ${text.borderWidthPt}pt$dash)';
  }

  double _staticContentHeightPt(TemplatePage page, double wPt) {
    var height = 0.0;

    for (final text in page.customTexts) {
      final genderIconKey =
          templateGenderIconFieldKeyFromBracketText(text.text);
      if (text.isDynamic && !text.isQrCode && genderIconKey == null) {
        continue;
      }

      if (text.isQrCode) {
        height = math.max(
          height,
          documentPdfMmToPt(text.yMm + text.qrSizeMm),
        );
        continue;
      }

      if (genderIconKey != null) {
        height = math.max(
          height,
          documentPdfMmToPt(
            text.yMm +
                (text.iconHeightMm ?? kTemplateGenderIconDefaultHeightMm),
          ),
        );
        continue;
      }

      height = math.max(
        height,
        documentPdfMmToPt(text.yMm) +
            _estimateTextHeightPt(
              text.text,
              text.fontSizePt,
              _textContentWidthPt(text, wPt),
            ) +
            _textBoxVerticalExtraPt(text),
      );
    }

    for (final image in page.customImages) {
      height = math.max(height, _customImageBottomPt(image));
    }

    for (final line in page.customLines) {
      height = math.max(height, _customLineBottomPt(line));
    }

    for (final shape in page.customShapes) {
      height = math.max(height, _customShapeBottomPt(shape));
    }

    return height;
  }

  double _elementTopMm(dynamic element) {
    if (element is CustomImageElement) return element.yMm;
    if (element is CustomTextElement) return element.yMm;
    if (element is CustomLineElement) return element.yMm;
    if (element is CustomShapeElement) return element.yMm;
    return 0;
  }

  double _elementBottomPt(dynamic element, double wPt) {
    if (element is CustomImageElement) return _customImageBottomPt(element);
    if (element is CustomLineElement) return _customLineBottomPt(element);
    if (element is CustomShapeElement) return _customShapeBottomPt(element);
    if (element is CustomTextElement) {
      final genderIconKey =
          templateGenderIconFieldKeyFromBracketText(element.text);
      if (element.isQrCode) {
        return documentPdfMmToPt(element.yMm + element.qrSizeMm);
      }
      if (genderIconKey != null) {
        return documentPdfMmToPt(
          element.yMm +
              (element.iconHeightMm ?? kTemplateGenderIconDefaultHeightMm),
        );
      }
      final heightPt = element.heightMm != null
          ? documentPdfMmToPt(element.heightMm!)
          : _estimateTextHeightPt(
                element.text,
                element.fontSizePt,
                _textContentWidthPt(element, wPt),
              ) +
              _textBoxVerticalExtraPt(element);
      return documentPdfMmToPt(element.yMm) + heightPt;
    }
    return 0;
  }

  double _textMaxWidthPt(CustomTextElement text, double wPt) {
    return text.maxWidthMm == null
        ? wPt - documentPdfMmToPt(text.xMm)
        : documentPdfMmToPt(text.maxWidthMm!);
  }

  double _textContentWidthPt(CustomTextElement text, double wPt) {
    final padding = _textBoxPaddingTotalPt(text);
    return math.max(1.0, _textMaxWidthPt(text, wPt) - padding);
  }

  double _textBoxVerticalExtraPt(CustomTextElement text) {
    return _textBoxPaddingTotalPt(text);
  }

  double _textBoxPaddingTotalPt(CustomTextElement text) {
    return _hasTextBoxInset(text) ? math.max(0.0, text.paddingPt) * 2 : 0.0;
  }

  bool _hasTextBoxInset(CustomTextElement text) {
    return text.backgroundColorArgb != null ||
        (text.borderColorArgb != null && text.borderWidthPt > 0);
  }

  double _customImageBottomPt(CustomImageElement image) {
    return documentPdfMmToPt(image.yMm) +
        _rotatedRectBottomExtentPt(
          widthPt: documentPdfMmToPt(image.widthMm),
          heightPt: documentPdfMmToPt(image.heightMm),
          rotationDegrees: image.rotationDegrees,
        );
  }

  double _customShapeBottomPt(CustomShapeElement shape) {
    return documentPdfMmToPt(shape.yMm) +
        _rotatedRectBottomExtentPt(
          widthPt: documentPdfMmToPt(shape.widthMm),
          heightPt: documentPdfMmToPt(shape.heightMm),
          rotationDegrees: shape.rotationDegrees,
        ) +
        shape.strokeThicknessPt;
  }

  double _customLineBottomPt(CustomLineElement line) {
    final angle = line.rotationDegrees * math.pi / 180.0;
    final lengthPt = documentPdfMmToPt(line.lengthMm);
    final yExtentPt = math.max(0.0, math.sin(angle) * lengthPt);
    final strokeExtentPt =
        line.thicknessPt * (line.strokeStyle == 'double' ? 3.5 : 1.5);
    return documentPdfMmToPt(line.yMm) + yExtentPt + strokeExtentPt;
  }

  double _rotatedRectBottomExtentPt({
    required double widthPt,
    required double heightPt,
    required int rotationDegrees,
  }) {
    final angle = rotationDegrees * math.pi / 180.0;
    final sinA = math.sin(angle);
    final cosA = math.cos(angle);
    final ys = <double>[
      0,
      widthPt * sinA,
      heightPt * cosA,
      widthPt * sinA + heightPt * cosA,
    ];
    return ys.reduce(math.max);
  }

  double _estimateTextHeightPt(
      String text, double fontSizePt, double maxWidthPt) {
    if (text.trim().isEmpty) return fontSizePt * 1.2;
    final safeWidth = math.max(1.0, maxWidthPt);
    final charsPerLine = math.max(1, (safeWidth / (fontSizePt * 0.52)).floor());
    var lineCount = 0;
    for (final line in text.split('\n')) {
      lineCount += math.max(1, (line.length / charsPerLine).ceil());
    }
    return lineCount * fontSizePt * 1.2;
  }

  static List<dynamic> sortElements(TemplatePage page) {
    return <dynamic>[
      ...page.customImages,
      ...page.customTexts,
      ...page.customLines,
      ...page.customShapes,
    ]..sort((a, b) => (a.zIndex as int).compareTo(b.zIndex as int));
  }

  void _writeSingleCustomImage(
      StringBuffer typst, CustomImageElement im, String dyShift) {
    if (!isTemplateImagePathUsable(im.imagePath)) return;
    String path = im.imagePath.replaceAll(r'\', r'\\');

    typst.writeln(
        '  #place(dx: ${documentPdfMmToPt(im.xMm)}pt, dy: ${_dyPt(im.yMm, dyShift)})[#rotate(${im.rotationDegrees}deg, origin: center)[#image("$path", width: ${documentPdfMmToPt(im.widthMm)}pt, height: ${documentPdfMmToPt(im.heightMm)}pt, fit: "contain")]]');
  }

  void _writeSingleCustomLine(
      StringBuffer typst, CustomLineElement line, String dyShift) {
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
        '  #place(dx: ${documentPdfMmToPt(line.xMm)}pt, dy: ${_dyPt(line.yMm, dyShift)})[#rotate(${line.rotationDegrees}deg, origin: center)[$elem]]');
  }

  void _writeSingleCustomShape(
      StringBuffer typst, CustomShapeElement shape, String dyShift) {
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
        '  #place(dx: ${documentPdfMmToPt(shape.xMm)}pt, dy: ${_dyPt(shape.yMm, dyShift)})[#rotate(${shape.rotationDegrees}deg, origin: center)[$elem]]');
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
