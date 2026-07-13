part of '../document_writer.dart';

class _DocumentPdfLayoutMetrics {
  const _DocumentPdfLayoutMetrics._();

  static double usablePageWidthPt({
    required double sheetWidthPt,
    required double leftPaddingMm,
    required double rightPaddingMm,
  }) {
    return math.max(
      1.0,
      sheetWidthPt -
          documentPdfMmToPt(leftPaddingMm) -
          documentPdfMmToPt(rightPaddingMm),
    );
  }

  static double usablePageHeightPt({
    required double sheetHeightPt,
    required double topPaddingMm,
    required double bottomPaddingMm,
  }) {
    return math.max(
      1.0,
      sheetHeightPt -
          documentPdfMmToPt(topPaddingMm) -
          documentPdfMmToPt(bottomPaddingMm),
    );
  }

  static int maxAutoFillRepeatCount({
    required double rowHeight,
    required double usedHeight,
    required double usableHeight,
  }) {
    if (rowHeight <= 0 || usedHeight >= usableHeight) return 0;
    const tolerancePt = 0.001;
    return math.max(
      0,
      ((usableHeight - usedHeight + tolerancePt) / rowHeight).floor(),
    );
  }

  static double estimateAutoFillCellHeightPt({
    required TemplatePage page,
    required double wPt,
    required double hPt,
    required double templatePadTopMm,
    required double templatePadLeftMm,
    required double templatePadRightMm,
    required double templatePadBottomMm,
  }) {
    final bodyHeight = estimateTemplatePageContentHeightPt(
      page: page,
      wPt: wPt,
      hPt: hPt,
    );
    return math.max(hPt, bodyHeight) +
        documentPdfMmToPt(templatePadTopMm) +
        documentPdfMmToPt(templatePadBottomMm);
  }

  static double estimateTemplatePageContentHeightPt({
    required TemplatePage page,
    required double wPt,
    required double hPt,
  }) {
    final hasDynamicText = page.customTexts.any((text) =>
        text.isVisible &&
        text.isDynamic &&
        !text.isQrCode &&
        templateGenderIconFieldKeyFromBracketText(text.text) == null);
    if (hasDynamicText) {
      return _estimateFlowTemplateContentHeightPt(page: page, wPt: wPt);
    }

    var height = 0.0;
    var hasVisibleContent = false;
    for (final text in page.customTexts) {
      if (!text.isVisible) continue;
      hasVisibleContent = true;
      final genderIconKey =
          templateGenderIconFieldKeyFromBracketText(text.text);
      if (text.isQrCode) {
        height = math.max(
          height,
          documentPdfMmToPt(text.yMm + text.qrSizeMm),
        );
      } else if (genderIconKey != null) {
        height = math.max(
          height,
          documentPdfMmToPt(
            text.yMm +
                (text.iconHeightMm ?? kTemplateGenderIconDefaultHeightMm),
          ),
        );
      } else {
        final bottom = documentPdfMmToPt(text.yMm) +
            _estimateTextHeightPt(
              text.text,
              text.fontSizePt,
              _textContentWidthPt(text, wPt),
            ) +
            _textBoxVerticalExtraPt(text);
        height = math.max(height, bottom);
      }
    }

    for (final image in page.customImages) {
      if (!image.isVisible) continue;
      hasVisibleContent = true;
      height = math.max(height, _customImageBottomPt(image));
    }
    for (final line in page.customLines) {
      if (!line.isVisible) continue;
      hasVisibleContent = true;
      height = math.max(height, _customLineBottomPt(line));
    }
    for (final shape in page.customShapes) {
      if (!shape.isVisible) continue;
      hasVisibleContent = true;
      height = math.max(height, _customShapeBottomPt(shape));
    }
    return hasVisibleContent ? height : hPt;
  }

  static double _estimateFlowTemplateContentHeightPt({
    required TemplatePage page,
    required double wPt,
  }) {
    final dynamicTexts = page.customTexts
        .where((text) =>
            text.isVisible &&
            text.isDynamic &&
            !text.isQrCode &&
            templateGenderIconFieldKeyFromBracketText(text.text) == null)
        .toList()
      ..sort((a, b) => a.yMm.compareTo(b.yMm));
    final dynamicHeightByText = <CustomTextElement, double>{
      for (final text in dynamicTexts) text: _dynamicTextHeightPt(text, wPt),
    };
    final flowTopByText = <CustomTextElement, double>{};
    final clearanceBottomByText = <CustomTextElement, double>{};
    final dynamicGapPt = documentPdfMmToPt(2);

    for (final text in dynamicTexts) {
      var flowedTop = documentPdfMmToPt(text.yMm);
      for (final previous in dynamicTexts) {
        if (text.yMm - previous.yMm <=
            TemplateDynamicLayoutService.verticalRowToleranceMm) {
          continue;
        }
        flowedTop = math.max(flowedTop, clearanceBottomByText[previous]!);
      }
      flowTopByText[text] = flowedTop;
      clearanceBottomByText[text] =
          flowedTop + dynamicHeightByText[text]! + dynamicGapPt;
    }

    var height = 0.0;
    for (final element in _sortTemplateElements(page)) {
      final bottom = element is CustomTextElement &&
              dynamicHeightByText.containsKey(element)
          ? flowTopByText[element]! + dynamicHeightByText[element]!
          : _elementBottomPt(element, wPt) +
              _dynamicFlowShiftPt(
                dynamicTexts: dynamicTexts,
                clearanceBottomByText: clearanceBottomByText,
                targetYmm: _elementTopMm(element),
                excludeElement: element,
              );
      if (bottom > 0) height = math.max(height, bottom);
    }
    return height;
  }

  static double _dynamicFlowShiftPt({
    required List<CustomTextElement> dynamicTexts,
    required Map<CustomTextElement, double> clearanceBottomByText,
    required double targetYmm,
    required dynamic excludeElement,
  }) {
    final base = documentPdfMmToPt(targetYmm);
    var renderedTop = base;
    for (final text in dynamicTexts) {
      if (identical(text, excludeElement)) continue;
      if (targetYmm - text.yMm >
          TemplateDynamicLayoutService.verticalRowToleranceMm) {
        renderedTop = math.max(renderedTop, clearanceBottomByText[text]!);
      }
    }
    return renderedTop - base;
  }

  static double _dynamicTextHeightPt(CustomTextElement text, double wPt) {
    return _estimateTextHeightPt(
          formatTemplateText(
            text.text,
            text.textType,
            text.formatOption,
            text.caseFormat,
          ),
          text.fontSizePt,
          _textContentWidthPt(text, wPt),
        ) +
        _textBoxVerticalExtraPt(text);
  }

  static List<dynamic> _sortTemplateElements(TemplatePage page) {
    return <dynamic>[
      ...page.customImages.where((e) => e.isVisible),
      ...page.customTexts.where((e) => e.isVisible),
      ...page.customLines.where((e) => e.isVisible),
      ...page.customShapes.where((e) => e.isVisible),
    ]..sort((a, b) => (a.zIndex as int).compareTo(b.zIndex as int));
  }

  static double _elementTopMm(dynamic element) {
    if (element is CustomImageElement) return element.yMm;
    if (element is CustomTextElement) return element.yMm;
    if (element is CustomLineElement) return element.yMm;
    if (element is CustomShapeElement) return element.yMm;
    return 0;
  }

  static double _elementBottomPt(dynamic element, double wPt) {
    if (element is CustomImageElement) return _customImageBottomPt(element);
    if (element is CustomLineElement) return _customLineBottomPt(element);
    if (element is CustomShapeElement) return _customShapeBottomPt(element);
    if (element is! CustomTextElement) return 0;
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
              formatTemplateText(
                element.text,
                element.textType,
                element.formatOption,
                element.caseFormat,
              ),
              element.fontSizePt,
              _textContentWidthPt(element, wPt),
            ) +
            _textBoxVerticalExtraPt(element);
    return documentPdfMmToPt(element.yMm) + heightPt;
  }

  static double _customImageBottomPt(CustomImageElement image) {
    return documentPdfMmToPt(image.yMm) +
        _rotatedRectBottomExtentPt(
          widthPt: documentPdfMmToPt(image.widthMm),
          heightPt: documentPdfMmToPt(image.heightMm),
          rotationDegrees: image.rotationDegrees,
        );
  }

  static double _customShapeBottomPt(CustomShapeElement shape) {
    return documentPdfMmToPt(shape.yMm) +
        _rotatedRectBottomExtentPt(
          widthPt: documentPdfMmToPt(shape.widthMm),
          heightPt: documentPdfMmToPt(shape.heightMm),
          rotationDegrees: shape.rotationDegrees,
        ) +
        shape.strokeThicknessPt;
  }

  static double _customLineBottomPt(CustomLineElement line) {
    final angle = line.rotationDegrees * math.pi / 180.0;
    final lengthPt = documentPdfMmToPt(line.lengthMm);
    final yExtentPt = math.max(0.0, math.sin(angle) * lengthPt);
    final strokeExtentPt =
        line.thicknessPt * (line.strokeStyle == 'double' ? 3.5 : 1.5);
    return documentPdfMmToPt(line.yMm) + yExtentPt + strokeExtentPt;
  }

  static double _textMaxWidthPt(CustomTextElement text, double wPt) {
    return text.maxWidthMm == null
        ? wPt - documentPdfMmToPt(text.xMm)
        : documentPdfMmToPt(text.maxWidthMm!);
  }

  static double _textContentWidthPt(CustomTextElement text, double wPt) {
    return math.max(
        1.0, _textMaxWidthPt(text, wPt) - _textBoxPaddingTotalPt(text));
  }

  static double _textBoxVerticalExtraPt(CustomTextElement text) {
    return _textBoxPaddingTotalPt(text);
  }

  static double _textBoxPaddingTotalPt(CustomTextElement text) {
    return _hasTextBoxInset(text) ? math.max(0.0, text.paddingPt) * 2 : 0.0;
  }

  static bool _hasTextBoxInset(CustomTextElement text) {
    return text.backgroundColorArgb != null ||
        (text.borderColorArgb != null && text.borderWidthPt > 0);
  }

  static double _rotatedRectBottomExtentPt({
    required double widthPt,
    required double heightPt,
    required int rotationDegrees,
  }) {
    final angle = rotationDegrees * math.pi / 180.0;
    final sinA = math.sin(angle);
    final cosA = math.cos(angle);
    return <double>[
      0,
      widthPt * sinA,
      heightPt * cosA,
      widthPt * sinA + heightPt * cosA,
    ].reduce(math.max);
  }

  static double _estimateTextHeightPt(
    String text,
    double fontSizePt,
    double maxWidthPt,
  ) {
    if (text.trim().isEmpty) return fontSizePt * 1.2;
    final safeWidth = math.max(1.0, maxWidthPt);
    final charsPerLine = math.max(1, (safeWidth / (fontSizePt * 0.52)).floor());
    var lineCount = 0;
    for (final line in text.split('\n')) {
      lineCount += math.max(1, (line.length / charsPerLine).ceil());
    }
    return lineCount * fontSizePt * 1.2;
  }
}
