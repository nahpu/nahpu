part of '../document_writer.dart';

class _DocumentTypstRenderer {
  const _DocumentTypstRenderer();

  void writeTiledDocumentSheet({
    required StringBuffer typst,
    required List<_DocumentSheetCell> cells,
    required int cols,
    required int rows,
    required double cellW,
    required double cellH,
  }) {
    typst.writeln('#grid(');
    typst.writeln('  columns: (${cellW}pt, ) * $cols,');
    typst.writeln('  rows: (${cellH}pt, ) * $rows,');
    typst.writeln('  column-gutter: 0pt,');
    typst.writeln('  row-gutter: 0pt,');

    for (var i = 0; i < cells.length; i++) {
      final cell = cells[i];
      writeSingleDocumentCell(
        typst: typst,
        page: cell.page,
        data: cell.data,
        wPt: cell.widthPt,
        hPt: cell.canvasHeightPt,
        templatePadTopMm: cell.block.templatePadTopMm,
        templatePadLeftMm: cell.block.templatePadLeftMm,
        templatePadRightMm: cell.block.templatePadRightMm,
        templatePadBottomMm: cell.block.templatePadBottomMm,
        mirror: cell.mirror,
        outline: cell.outline,
      );
    }

    _fillRemainingGridSpaces(typst, cells.length, cols);
    typst.writeln(')');
  }

  void writeAutoFillDocumentSheet({
    required StringBuffer typst,
    required List<_DocumentSheetCell> cells,
    required int cols,
    required double cellW,
  }) {
    // Do not reserve the whole usable page for every batch. The grid's natural
    // height is the sum of its rows, so the next template or block starts
    // immediately after the preceding row. Height estimates are used only for
    // pagination; Typst remains the source of truth for dynamic text
    // measurement.
    typst.writeln('#grid(');
    typst.writeln('  columns: (${cellW}pt, ) * $cols,');
    typst.writeln('  column-gutter: 0pt,');
    typst.writeln('  row-gutter: 0pt,');

    for (var i = 0; i < cells.length; i++) {
      final cell = cells[i];
      if (cell.autoHeight &&
          !cell.mirror &&
          _flowingDynamicTexts(cell.page).isNotEmpty) {
        writeBreakableAutoHeightDocumentCell(
          typst: typst,
          page: cell.page,
          data: cell.data,
          wPt: cell.widthPt,
          hPt: cell.canvasHeightPt,
          templatePadTopMm: cell.block.templatePadTopMm,
          templatePadLeftMm: cell.block.templatePadLeftMm,
          templatePadRightMm: cell.block.templatePadRightMm,
          templatePadBottomMm: cell.block.templatePadBottomMm,
          outline: cell.outline,
        );
      } else {
        writeSingleDocumentCell(
          typst: typst,
          page: cell.page,
          data: cell.data,
          wPt: cell.widthPt,
          hPt: cell.canvasHeightPt,
          templatePadTopMm: cell.block.templatePadTopMm,
          templatePadLeftMm: cell.block.templatePadLeftMm,
          templatePadRightMm: cell.block.templatePadRightMm,
          templatePadBottomMm: cell.block.templatePadBottomMm,
          mirror: cell.mirror,
          outline: cell.outline,
          autoHeight: cell.autoHeight,
        );
      }
    }

    _fillRemainingGridSpaces(typst, cells.length, cols);
    typst.writeln(')');
  }

  void writeBreakableAutoHeightDocumentCell({
    required StringBuffer typst,
    required TemplatePage page,
    required Map<String, String> data,
    required double wPt,
    required double hPt,
    required double templatePadTopMm,
    required double templatePadLeftMm,
    required double templatePadRightMm,
    required double templatePadBottomMm,
    TemplateOutline? outline,
  }) {
    final padTop = documentPdfMmToPt(templatePadTopMm);
    final padBottom = documentPdfMmToPt(templatePadBottomMm);
    final padLeft = documentPdfMmToPt(templatePadLeftMm);
    final padRight = documentPdfMmToPt(templatePadRightMm);
    final dynamicTexts = _flowingDynamicTexts(page);
    final dynamicRows = _dynamicFlowRows(dynamicTexts);
    final dynamicIds = dynamicTexts.map((text) => text.id).toSet();
    final staticElements = sortElements(
      page,
    ).where((element) => !_isDynamicTextWithId(element, dynamicIds)).toList();
    final events = _breakableFlowEvents(dynamicRows, staticElements);
    final staticContentHeightPt = _staticContentHeightPt(page, wPt);
    final initialCellHeightPt = math.max(hPt, staticContentHeightPt);

    typst.writeln('  grid.cell(breakable: true)[');
    typst.writeln('#style(styles => {');
    typst.writeln('  let cell_height = ${initialCellHeightPt}pt');
    for (final text in dynamicTexts) {
      final varSuffix = _typstVarSuffix(text.id);
      final textElem = _typstTextElement(text, applyBox: false);
      final widthPt = _textMaxWidthPt(text, wPt);
      final measureBoxArgs = _textBoxArgs(text, width: '${widthPt}pt');
      final measureBox = measureBoxArgs.isEmpty
          ? 'box(width: ${widthPt}pt)'
          : 'box($measureBoxArgs)';
      typst.writeln(
        '  let h_$varSuffix = measure($measureBox[$textElem], styles).height',
      );
    }
    _writeDynamicFlowVariables(typst, dynamicTexts);

    for (final element in sortElements(page)) {
      final shift = _dynamicShiftExpression(
        dynamicTexts,
        _elementTopMm(element),
        excludeElement: element,
      );
      if (_isFlowingDynamicText(element)) {
        final suffix = _typstVarSuffix((element as CustomTextElement).id);
        typst.writeln(
          '  cell_height = calc.max(cell_height, flow_top_$suffix + h_$suffix)',
        );
      } else {
        final bottom = _elementBottomPt(element, wPt);
        if (bottom > 0 && shift != '0pt') {
          typst.writeln(
            '  cell_height = calc.max(cell_height, ${bottom}pt + $shift)',
          );
        }
      }
    }

    typst.writeln(
      '  block(width: 100%, breakable: true, above: 0pt, below: 0pt)[',
    );
    if (padTop > 0) typst.writeln('    #v(${padTop}pt)');
    typst.writeln('    #pad(left: ${padLeft}pt, right: ${padRight}pt)[');
    typst.writeln(
      '      #block(width: ${wPt}pt, breakable: true, above: 0pt, below: 0pt)[',
    );
    _writeFlowOutline(typst, outline, wPt, hPt);

    var cursor = '0pt';
    for (final event in events) {
      if (event is _DocumentDynamicFlowRow) {
        final rowTop = _dynamicRowTopExpression(event);
        _writeFlowAdvance(typst, cursor: cursor, target: rowTop);
        for (final companion in event.companions) {
          final companionTop = _dynamicFlowTopExpression(
            dynamicTexts,
            _elementTopMm(companion),
            excludeElement: companion,
          );
          _writeFlowPositionedElement(
            typst,
            companion,
            data,
            dy: '$companionTop - $rowTop',
          );
        }
        _writeBreakableDynamicRow(
          typst: typst,
          row: event,
          rowTop: rowTop,
          wPt: wPt,
        );
        cursor = _dynamicRowBottomExpression(event);
      } else if (event is _DocumentStaticFlowEvent) {
        final target = _dynamicFlowTopExpression(
          dynamicTexts,
          _elementTopMm(event.element),
          excludeElement: event.element,
        );
        _writeFlowAdvance(typst, cursor: cursor, target: target);
        _writeFlowPositionedElement(typst, event.element, data, dy: '0pt');
        cursor = target;
      }
    }
    _writeFlowAdvance(typst, cursor: cursor, target: 'cell_height');
    typst.writeln('      ]');
    typst.writeln('    ]');
    if (padBottom > 0) typst.writeln('    #v(${padBottom}pt)');
    typst.writeln('  ]');
    typst.writeln('})');
    typst.writeln('  ],');
  }

  List<CustomTextElement> _flowingDynamicTexts(TemplatePage page) {
    return page.customTexts
        .where(TemplateDynamicLayoutService.isFlowingDynamicText)
        .toList()
      ..sort((a, b) => a.yMm.compareTo(b.yMm));
  }

  bool _isFlowingDynamicText(dynamic element) {
    return element is CustomTextElement &&
        TemplateDynamicLayoutService.isFlowingDynamicText(element);
  }

  bool _isDynamicTextWithId(dynamic element, Set<String> ids) {
    return element is CustomTextElement && ids.contains(element.id);
  }

  List<_DocumentDynamicFlowRow> _dynamicFlowRows(
    List<CustomTextElement> texts,
  ) {
    final rows = <_DocumentDynamicFlowRow>[];
    for (final text in texts) {
      if (rows.isEmpty ||
          text.yMm - rows.last.yMm >
              TemplateDynamicLayoutService.verticalRowToleranceMm) {
        rows.add(_DocumentDynamicFlowRow([text]));
      } else {
        rows.last.texts.add(text);
      }
    }
    return rows;
  }

  List<_DocumentBreakableFlowEvent> _breakableFlowEvents(
    List<_DocumentDynamicFlowRow> rows,
    List<dynamic> staticElements,
  ) {
    final events = <_DocumentBreakableFlowEvent>[...rows];
    for (final element in staticElements) {
      final yMm = _elementTopMm(element);
      _DocumentDynamicFlowRow? companionRow;
      var closestDistance = double.infinity;
      for (final row in rows) {
        final distance = (yMm - row.yMm).abs();
        if (distance <= TemplateDynamicLayoutService.verticalRowToleranceMm &&
            distance < closestDistance) {
          companionRow = row;
          closestDistance = distance;
        }
      }
      if (companionRow != null) {
        companionRow.companions.add(element);
      } else {
        events.add(_DocumentStaticFlowEvent(element));
      }
    }
    for (final row in rows) {
      row.companions.sort(
        (a, b) => (a.zIndex as int).compareTo(b.zIndex as int),
      );
    }
    events.sort((a, b) {
      final yResult = a.yMm.compareTo(b.yMm);
      if (yResult != 0) return yResult;
      return a.zIndex.compareTo(b.zIndex);
    });
    return events;
  }

  void _writeDynamicFlowVariables(
    StringBuffer typst,
    List<CustomTextElement> dynamicTexts,
  ) {
    for (var index = 0; index < dynamicTexts.length; index++) {
      final text = dynamicTexts[index];
      final suffix = _typstVarSuffix(text.id);
      typst.writeln(
        '  let flow_top_$suffix = ${documentPdfMmToPt(text.yMm)}pt',
      );
      for (var priorIndex = 0; priorIndex < index; priorIndex++) {
        final prior = dynamicTexts[priorIndex];
        if (text.yMm - prior.yMm <=
            TemplateDynamicLayoutService.verticalRowToleranceMm) {
          continue;
        }
        typst.writeln(
          '  flow_top_$suffix = calc.max(flow_top_$suffix, flow_clearance_${_typstVarSuffix(prior.id)})',
        );
      }
      typst.writeln(
        '  let flow_clearance_$suffix = flow_top_$suffix + h_$suffix + ${documentPdfMmToPt(TemplateDynamicLayoutService.verticalGapMm)}pt',
      );
    }
  }

  String _dynamicRowTopExpression(_DocumentDynamicFlowRow row) {
    return 'flow_top_${_typstVarSuffix(row.texts.first.id)}';
  }

  String _dynamicRowBottomExpression(_DocumentDynamicFlowRow row) {
    final bottoms = row.texts.map((text) {
      final suffix = _typstVarSuffix(text.id);
      return 'flow_top_$suffix + h_$suffix';
    }).toList();
    if (bottoms.length == 1) return bottoms.single;
    return 'calc.max(${bottoms.join(', ')})';
  }

  String _dynamicFlowTopExpression(
    List<CustomTextElement> dynamicTexts,
    double yMm, {
    required dynamic excludeElement,
  }) {
    var target = '${documentPdfMmToPt(yMm)}pt';
    for (final text in dynamicTexts) {
      if (identical(text, excludeElement)) continue;
      if (yMm - text.yMm >
          TemplateDynamicLayoutService.verticalRowToleranceMm) {
        target =
            'calc.max($target, flow_clearance_${_typstVarSuffix(text.id)})';
      }
    }
    return target;
  }

  void _writeFlowAdvance(
    StringBuffer typst, {
    required String cursor,
    required String target,
  }) {
    typst.writeln('        #v(calc.max(0pt, ($target) - ($cursor)))');
  }

  void _writeBreakableDynamicRow({
    required StringBuffer typst,
    required _DocumentDynamicFlowRow row,
    required String rowTop,
    required double wPt,
  }) {
    final texts = [...row.texts]..sort((a, b) => a.xMm.compareTo(b.xMm));
    var rightEdge = 0.0;
    var hasOverlap = false;
    for (final text in texts) {
      final left = documentPdfMmToPt(text.xMm);
      if (left < rightEdge - 0.001) hasOverlap = true;
      rightEdge = math.max(rightEdge, left + _textMaxWidthPt(text, wPt));
    }
    if (hasOverlap) {
      _writeOverlappingDynamicRow(
        typst: typst,
        row: row,
        rowTop: rowTop,
        wPt: wPt,
      );
      return;
    }

    final columns = <_DocumentDynamicFlowColumn>[];
    var cursorX = 0.0;
    for (final text in texts) {
      final left = documentPdfMmToPt(text.xMm).clamp(0.0, wPt);
      if (left > cursorX + 0.001) {
        columns.add(_DocumentDynamicFlowColumn(widthPt: left - cursorX));
      }
      final width = math.max(
        1.0,
        math.min(_textMaxWidthPt(text, wPt), math.max(1.0, wPt - left)),
      );
      columns.add(_DocumentDynamicFlowColumn(widthPt: width, text: text));
      cursorX = left + width;
    }
    if (cursorX < wPt - 0.001) {
      columns.add(_DocumentDynamicFlowColumn(widthPt: wPt - cursorX));
    }

    typst.writeln('        #grid(');
    typst.writeln(
      '          columns: (${columns.map((column) => '${column.widthPt}pt').join(', ')}),',
    );
    typst.writeln('          rows: (auto,),');
    typst.writeln('          column-gutter: 0pt,');
    typst.writeln('          row-gutter: 0pt,');
    for (final column in columns) {
      final text = column.text;
      if (text == null) {
        typst.writeln('          [],');
        continue;
      }
      final suffix = _typstVarSuffix(text.id);
      typst.writeln('          grid.cell(breakable: true)[');
      typst.writeln(
        '            #v(calc.max(0pt, flow_top_$suffix - $rowTop))',
      );
      _writeBreakableTextBlock(typst, text, indent: '            ');
      typst.writeln('          ],');
    }
    typst.writeln('        )');
  }

  void _writeOverlappingDynamicRow({
    required StringBuffer typst,
    required _DocumentDynamicFlowRow row,
    required String rowTop,
    required double wPt,
  }) {
    final driver = row.texts.reduce((a, b) {
      final aHeight = _estimatedDynamicTextBottomPt(a, row.yMm, wPt);
      final bHeight = _estimatedDynamicTextBottomPt(b, row.yMm, wPt);
      return aHeight >= bHeight ? a : b;
    });
    for (final text in row.texts) {
      if (identical(text, driver)) continue;
      final suffix = _typstVarSuffix(text.id);
      final element = _typstTextElement(text, applyBox: true);
      typst.writeln(
        '        #place(left, dx: ${documentPdfMmToPt(text.xMm)}pt, '
        'dy: flow_top_$suffix - $rowTop)[$element]',
      );
    }
    final left = documentPdfMmToPt(driver.xMm).clamp(0.0, wPt);
    final width = math.max(
      1.0,
      math.min(_textMaxWidthPt(driver, wPt), math.max(1.0, wPt - left)),
    );
    final right = math.max(0.0, wPt - left - width);
    final suffix = _typstVarSuffix(driver.id);
    typst.writeln('        #pad(left: ${left}pt, right: ${right}pt)[');
    typst.writeln('          #v(calc.max(0pt, flow_top_$suffix - $rowTop))');
    _writeBreakableTextBlock(typst, driver, indent: '          ');
    typst.writeln('        ]');
  }

  double _estimatedDynamicTextBottomPt(
    CustomTextElement text,
    double rowYmm,
    double wPt,
  ) {
    return documentPdfMmToPt(text.yMm - rowYmm) +
        _estimateTextHeightPt(
          text.text,
          text.fontSizePt,
          _textContentWidthPt(text, wPt),
        ) +
        _textBoxVerticalExtraPt(text);
  }

  void _writeBreakableTextBlock(
    StringBuffer typst,
    CustomTextElement text, {
    required String indent,
  }) {
    final textElem = _typstTextElement(text, applyBox: false);
    final args = _textBoxArgs(text);
    final decoration = args.isEmpty ? '' : ', $args';
    typst.writeln(
      '$indent#block(width: 100%, breakable: true, above: 0pt, '
      'below: 0pt$decoration)[',
    );
    if (text.rotationDegrees == 0) {
      typst.writeln('$indent  $textElem');
    } else {
      typst.writeln(
        '$indent  #rotate(${text.rotationDegrees}deg, origin: top + left)[$textElem]',
      );
    }
    typst.writeln('$indent]');
  }

  void _writeFlowPositionedElement(
    StringBuffer typst,
    dynamic element,
    Map<String, String> data, {
    required String dy,
  }) {
    if (element is CustomImageElement) {
      _writeSingleCustomImage(typst, element, '0pt', dyOverridePt: dy);
    } else if (element is CustomTextElement) {
      _writeSingleCustomText(typst, element, data, '0pt', dyOverridePt: dy);
    } else if (element is CustomLineElement) {
      _writeSingleCustomLine(typst, element, '0pt', dyOverridePt: dy);
    } else if (element is CustomShapeElement) {
      _writeSingleCustomShape(typst, element, '0pt', dyOverridePt: dy);
    }
  }

  void _writeFlowOutline(
    StringBuffer typst,
    TemplateOutline? outline,
    double wPt,
    double hPt,
  ) {
    if (outline == null) return;
    final r = (outline.colorArgb >> 16) & 0xFF;
    final g = (outline.colorArgb >> 8) & 0xFF;
    final b = outline.colorArgb & 0xFF;
    final strokeStyle = outline.style == TemplateOutlineStyle.dashed
        ? '"dashed"'
        : outline.style == TemplateOutlineStyle.dotted
        ? '"dotted"'
        : '"solid"';
    typst.writeln(
      '        #place(top + left)[#rect(width: ${wPt}pt, height: ${hPt}pt, '
      'stroke: (paint: rgb($r, $g, $b), thickness: ${outline.widthPt}pt, '
      'dash: $strokeStyle))]',
    );
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
    final staticContentHeightPt = _staticContentHeightPt(page, wPt);
    // Auto-fill templates retain their configured canvas height as a minimum.
    // Their visible content can grow beyond it, but it cannot collapse the
    // template and override the spacing defined by template padding.
    final autoContentHeightPt = math.max(
      hPt,
      staticContentHeightPt > 0 ? staticContentHeightPt : hPt,
    );
    final fixedCellHPt = hPt + padTop + padBottom;
    final autoCellHPt = autoContentHeightPt + padTop + padBottom;

    typst.writeln('  [');

    final dynamicTexts =
        page.customTexts
            .where(
              (t) =>
                  t.isVisible &&
                  t.isDynamic &&
                  !t.isQrCode &&
                  templateSpecimenSexIconFieldKeyFromBracketText(t.text) ==
                      null,
            )
            .toList()
          ..sort((a, b) => a.yMm.compareTo(b.yMm));

    if (dynamicTexts.isNotEmpty) {
      final initialCellHeight = autoHeight ? autoContentHeightPt : hPt;
      typst.writeln('#style(styles => {');
      typst.writeln('  let cell_height = ${initialCellHeight}pt');
      for (final t in dynamicTexts) {
        final varSuffix = _typstVarSuffix(t.id);
        final textElem = _typstTextElement(t, applyBox: false);

        final mwPt = t.maxWidthMm != null
            ? '${documentPdfMmToPt(t.maxWidthMm!)}pt'
            : '${wPt - documentPdfMmToPt(t.xMm)}pt';
        final measureBoxArgs = _textBoxArgs(t, width: mwPt);
        final measureBox = measureBoxArgs.isEmpty
            ? 'box(width: $mwPt)'
            : 'box($measureBoxArgs)';

        typst.writeln(
          '  let h_$varSuffix = measure($measureBox[$textElem], styles).height',
        );
      }

      for (var index = 0; index < dynamicTexts.length; index++) {
        final text = dynamicTexts[index];
        final varSuffix = _typstVarSuffix(text.id);
        typst.writeln(
          '  let flow_top_$varSuffix = ${documentPdfMmToPt(text.yMm)}pt',
        );
        for (var priorIndex = 0; priorIndex < index; priorIndex++) {
          final prior = dynamicTexts[priorIndex];
          if (text.yMm - prior.yMm <=
              TemplateDynamicLayoutService.verticalRowToleranceMm) {
            continue;
          }
          typst.writeln(
            '  flow_top_$varSuffix = calc.max(flow_top_$varSuffix, flow_clearance_${_typstVarSuffix(prior.id)})',
          );
        }
        typst.writeln(
          '  let flow_clearance_$varSuffix = flow_top_$varSuffix + h_$varSuffix + ${documentPdfMmToPt(2)}pt',
        );
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
            templateSpecimenSexIconFieldKeyFromBracketText(el.text) == null) {
          final varSuffix = _typstVarSuffix(el.id);
          typst.writeln(
            '  cell_height = calc.max(cell_height, flow_top_$varSuffix + h_$varSuffix)',
          );
        } else {
          final bottom = _elementBottomPt(el, wPt);
          if (bottom <= 0) continue;
          if (shift != '0pt') {
            typst.writeln(
              '  cell_height = calc.max(cell_height, ${bottom}pt + $shift)',
            );
          }
        }
      }

      if (continuous || autoHeight) {
        final width = continuous ? '${cellWPt}pt' : '100%';
        typst.writeln(
          '  let outer_height = cell_height + ${padTop}pt + ${padBottom}pt',
        );
        typst.writeln(
          '  box(width: $width, height: outer_height, inset: (top: ${padTop}pt, bottom: ${padBottom}pt, left: ${padLeft}pt, right: ${padRight}pt))[',
        );
      } else {
        typst.writeln(
          '  box(width: 100%, height: 100%, inset: (top: ${padTop}pt, bottom: ${padBottom}pt, left: ${padLeft}pt, right: ${padRight}pt))[',
        );
      }

      if (mirror) typst.writeln('    #rotate(180deg, origin: center)[');
      typst.writeln(
        '      #box(width: ${wPt}pt, height: cell_height, clip: false)[',
      );
    } else {
      if (continuous || autoHeight) {
        final width = continuous ? '${cellWPt}pt' : '100%';
        final height = autoHeight ? autoCellHPt : fixedCellHPt;
        final contentHeight = autoHeight ? autoContentHeightPt : hPt;
        typst.writeln(
          '#box(width: $width, height: ${height}pt, inset: (top: ${padTop}pt, bottom: ${padBottom}pt, left: ${padLeft}pt, right: ${padRight}pt))[',
        );
        if (mirror) typst.writeln('  #rotate(180deg, origin: center)[');
        typst.writeln(
          '    #box(width: ${wPt}pt, height: ${contentHeight}pt, clip: false)[',
        );
      } else {
        typst.writeln(
          '#box(width: 100%, height: 100%, inset: (top: ${padTop}pt, bottom: ${padBottom}pt, left: ${padLeft}pt, right: ${padRight}pt))[',
        );
        if (mirror) typst.writeln('  #rotate(180deg, origin: center)[');
        typst.writeln(
          '    #box(width: ${wPt}pt, height: ${hPt}pt, clip: false)[',
        );
      }
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
    StringBuffer typst,
    TemplateOutline? outline,
    double wPt,
    double hPt,
  ) {
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
        '  #place(top + left, dx: 0pt, dy: 0pt)[#rect(width: 100%, height: 100%, stroke: ${outline.widthPt}pt + rgb($r, $g, $b))]',
      );
      final inset = outline.widthPt + math.max(1.0, outline.widthPt * 1.25);
      typst.writeln(
        '  #place(top + left, dx: ${inset}pt, dy: ${inset}pt)[#rect(width: 100% - ${2 * inset}pt, height: 100% - ${2 * inset}pt, stroke: ${outline.widthPt}pt + rgb($r, $g, $b))]',
      );
    } else {
      typst.writeln(
        '  #place(top + left, dx: 0pt, dy: 0pt)[#rect(width: 100%, height: 100%, stroke: (paint: rgb($r, $g, $b), thickness: ${outline.widthPt}pt, dash: $strokeStyle))]',
      );
    }
  }

  String _escapeTypstMarkup(String text) {
    var content = text.replaceAll(r'\', r'\\');
    final activeChars = RegExp(r'([#$*_[\]<@~="+-])');
    content = content.replaceAllMapped(activeChars, (m) => '\\${m.group(0)}');
    content = content.replaceAll('\n', ' #linebreak() ');
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
    final base = '${documentPdfMmToPt(yMm)}pt';
    var requiredBottom = base;
    for (final text in dynamicTexts) {
      if (identical(text, excludeElement)) continue;
      if (yMm - text.yMm >
          TemplateDynamicLayoutService.verticalRowToleranceMm) {
        requiredBottom =
            'calc.max($requiredBottom, flow_clearance_${_typstVarSuffix(text.id)})';
      }
    }
    return requiredBottom == base ? '0pt' : '$requiredBottom - $base';
  }

  String _dyPt(double yMm, String dyShift) {
    final base = '${documentPdfMmToPt(yMm)}pt';
    return dyShift == '0pt' ? base : '$base + $dyShift';
  }

  void _writeSingleCustomText(
    StringBuffer typst,
    CustomTextElement t,
    Map<String, String> data,
    String dyShift, {
    String? dyOverridePt,
  }) {
    final alignment = dyOverridePt == null ? 'top + left' : 'left';
    final dy = dyOverridePt ?? _dyPt(t.yMm, dyShift);
    if (t.isQrCode) {
      if (t.tempPath == null || t.tempPath!.isEmpty) return;
      String cleanPath = t.tempPath!.replaceAll(r'\', r'\\');
      final sizePt = documentPdfMmToPt(t.qrSizeMm);
      typst.writeln(
        '  #place($alignment, dx: ${documentPdfMmToPt(t.xMm)}pt, dy: $dy)[#rotate(${t.rotationDegrees}deg, origin: center)[#image("$cleanPath", width: ${sizePt}pt, height: ${sizePt}pt, fit: "contain")]]',
      );
      return;
    }

    final gKey = templateSpecimenSexIconFieldKeyFromBracketText(t.text);
    if (gKey != null) {
      _writeSpecimenSexIcon(
        typst,
        t,
        data,
        gKey,
        dyShift,
        dyOverridePt: dyOverridePt,
      );
      return;
    }

    final textElem = _typstTextElement(t, applyBox: true);

    typst.writeln(
      '  #place($alignment, dx: ${documentPdfMmToPt(t.xMm)}pt, dy: $dy)[#rotate(${t.rotationDegrees}deg, origin: top + left)[$textElem]]',
    );
  }

  String _typstTextElement(CustomTextElement t, {required bool applyBox}) {
    final formatted = formatExportTemplateText(
      t.text,
      t.textType,
      t.formatOption,
      t.caseFormat,
    );
    final isMarkdown = t.textType == 'markdown';
    final content = isMarkdown ? formatted : _escapeTypstMarkup(formatted);
    final hexColor = t.colorArgb.toRadixString(16).padLeft(8, '0');
    final colorStr = 'rgb("${hexColor.substring(2)}")';
    String textProps = 'size: ${t.fontSizePt}pt, fill: $colorStr';
    if (t.bold) textProps += ', weight: "bold"';
    if (t.italic) textProps += ', style: "italic"';
    // Merriweather and several Google fonts used by templates do not contain
    // the male/female symbols. Typst renders a missing glyph as `?`, even
    // though Flutter's editor can obtain the symbol from its fallback fonts.
    // Use the bundled DejaVu Sans face whenever the final text contains one of
    // these symbols so the exported PDF always embeds a glyph-capable font.
    final typstFont = _containsSexSymbol(formatted)
        ? 'DejaVu Sans'
        : _typstTemplateFont(t.fontFamily);
    textProps += ', font: "$typstFont"';

    String textElem = isMarkdown
        ? '#block(above: 0pt, below: 0pt)[#set text($textProps)\n$content]'
        : '#text($textProps)[$content]';
    if (t.underline) {
      textElem = '#underline[$textElem]';
    }
    if (t.strikethrough) {
      textElem = '#strike[$textElem]';
    }
    if (t.textAlign != 'left') {
      textElem = '#align(${t.textAlign})[$textElem]';
    }
    if (!applyBox) return textElem;

    final hasWidth = t.maxWidthMm != null;
    final hasHeight = t.heightMm != null && !t.isDynamic;
    final hasBackground = t.backgroundColorArgb != null;
    final hasBorder = t.borderColorArgb != null && t.borderWidthPt > 0;
    if (hasWidth || hasHeight || hasBackground || hasBorder) {
      final wPart = hasWidth
          ? 'width: ${documentPdfMmToPt(t.maxWidthMm!)}pt'
          : '';
      final hPart = hasHeight
          ? 'height: ${documentPdfMmToPt(t.heightMm!)}pt'
          : '';
      final fillPart = hasBackground
          ? 'fill: ${_typstColor(t.backgroundColorArgb!)}'
          : '';
      final strokePart = hasBorder ? 'stroke: ${_typstTextStroke(t)}' : '';
      final radiusPart = t.cornerRadiusPt > 0
          ? 'radius: ${t.cornerRadiusPt}pt'
          : '';
      final insetPart = (hasBackground || hasBorder)
          ? 'inset: ${t.paddingPt}pt'
          : '';
      final args = [
        wPart,
        hPart,
        fillPart,
        strokePart,
        radiusPart,
        insetPart,
      ].where((p) => p.isNotEmpty).join(', ');
      textElem = '#box($args)[$textElem]';
    }
    return textElem;
  }

  void _writeSpecimenSexIcon(
    StringBuffer typst,
    CustomTextElement t,
    Map<String, String> data,
    String gKey,
    String dyShift, {
    String? dyOverridePt,
  }) {
    final display = _fieldValueCi(data, gKey);
    final ch = _genderSymbolForDisplayValue(display);
    final alignment = dyOverridePt == null ? 'top + left' : 'left';
    final dy = dyOverridePt ?? _dyPt(t.yMm, dyShift);

    final iconWPt = documentPdfMmToPt(
      t.iconWidthMm ?? kTemplateSpecimenSexIconDefaultWidthMm,
    );
    final iconHPt = documentPdfMmToPt(
      t.iconHeightMm ?? kTemplateSpecimenSexIconDefaultHeightMm,
    );
    final fs = math.min(iconWPt, iconHPt) * 0.88;

    typst.writeln(
      '  #place($alignment, dx: ${documentPdfMmToPt(t.xMm)}pt, dy: $dy)[#rotate(${t.rotationDegrees}deg, origin: center)[#box(width: ${iconWPt}pt, height: ${iconHPt}pt)[#align(center+horizon)[#text(size: ${fs}pt, font: "DejaVu Sans")[$ch]]]]]',
    );
  }

  String _genderSymbolForDisplayValue(String display) {
    final sex = specimenSexFromDisplayValue(display);
    return sex == null ? '?' : specimenSexSymbol[sex]!;
  }

  bool _containsSexSymbol(String text) => text.runes.any(
    (rune) => rune == 0x2640 || rune == 0x2642 || rune == 0x26A5,
  );

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
    if (font.isEmpty) return 'Merriweather';
    switch (font) {
      case 'DejaVuSans':
        return 'DejaVu Sans';
      case 'DejaVuSerif':
        return 'DejaVu Serif';
      case 'LibertinusSans':
        return 'Libertinus Sans';
      case 'LibertinusSerif':
        return 'Libertinus Serif';
      case 'PlusJakartaSans':
        return 'Plus Jakarta Sans';
      default:
        return font;
    }
  }

  String _textBoxArgs(CustomTextElement text, {String? width, String? height}) {
    final hasBackground = text.backgroundColorArgb != null;
    final hasBorder = text.borderColorArgb != null && text.borderWidthPt > 0;
    if (!hasBackground && !hasBorder) return '';
    final fillPart = hasBackground
        ? 'fill: ${_typstColor(text.backgroundColorArgb!)}'
        : '';
    final strokePart = hasBorder ? 'stroke: ${_typstTextStroke(text)}' : '';
    final radiusPart = text.cornerRadiusPt > 0
        ? 'radius: ${text.cornerRadiusPt}pt'
        : '';
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
      if (!text.isVisible) continue;
      final specimenSexIconKey = templateSpecimenSexIconFieldKeyFromBracketText(
        text.text,
      );
      if (text.isDynamic && !text.isQrCode && specimenSexIconKey == null) {
        continue;
      }

      if (text.isQrCode) {
        height = math.max(height, documentPdfMmToPt(text.yMm + text.qrSizeMm));
        continue;
      }

      if (specimenSexIconKey != null) {
        height = math.max(
          height,
          documentPdfMmToPt(
            text.yMm +
                (text.iconHeightMm ?? kTemplateSpecimenSexIconDefaultHeightMm),
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
      if (!image.isVisible) continue;
      height = math.max(height, _customImageBottomPt(image));
    }

    for (final line in page.customLines) {
      if (!line.isVisible) continue;
      height = math.max(height, _customLineBottomPt(line));
    }

    for (final shape in page.customShapes) {
      if (!shape.isVisible) continue;
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
      final specimenSexIconKey = templateSpecimenSexIconFieldKeyFromBracketText(
        element.text,
      );
      if (element.isQrCode) {
        return documentPdfMmToPt(element.yMm + element.qrSizeMm);
      }
      if (specimenSexIconKey != null) {
        return documentPdfMmToPt(
          element.yMm +
              (element.iconHeightMm ?? kTemplateSpecimenSexIconDefaultHeightMm),
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

  static List<dynamic> sortElements(TemplatePage page) {
    return <dynamic>[
      ...page.customImages.where((e) => e.isVisible),
      ...page.customTexts.where((e) => e.isVisible),
      ...page.customLines.where((e) => e.isVisible),
      ...page.customShapes.where((e) => e.isVisible),
    ]..sort((a, b) => (a.zIndex as int).compareTo(b.zIndex as int));
  }

  void _writeSingleCustomImage(
    StringBuffer typst,
    CustomImageElement im,
    String dyShift, {
    String? dyOverridePt,
  }) {
    if (!isTemplateImagePathUsable(im.imagePath)) return;
    String path = im.imagePath.replaceAll(r'\', r'\\');
    final alignment = dyOverridePt == null ? 'top + left' : 'left';
    final dy = dyOverridePt ?? _dyPt(im.yMm, dyShift);

    typst.writeln(
      '  #place($alignment, dx: ${documentPdfMmToPt(im.xMm)}pt, dy: $dy)[#rotate(${im.rotationDegrees}deg, origin: center)[#image("$path", width: ${documentPdfMmToPt(im.widthMm)}pt, height: ${documentPdfMmToPt(im.heightMm)}pt, fit: "contain")]]',
    );
  }

  void _writeSingleCustomLine(
    StringBuffer typst,
    CustomLineElement line,
    String dyShift, {
    String? dyOverridePt,
  }) {
    final hexColor = line.colorArgb.toRadixString(16).padLeft(8, '0');
    final colorStr =
        'rgb("${hexColor.substring(2)}")'; // ignores alpha for now, assuming 100%

    final lengthPt = documentPdfMmToPt(line.lengthMm);
    String elem;
    if (line.strokeStyle == 'double') {
      final gap = line.thicknessPt * 1.25;
      final halfOffset = (line.thicknessPt + gap) / 2;
      final line1 =
          '#place(top + left, dy: -${halfOffset}pt)[#line(length: ${lengthPt}pt, stroke: ${line.thicknessPt}pt + $colorStr)]';
      final line2 =
          '#place(top + left, dy: ${halfOffset}pt)[#line(length: ${lengthPt}pt, stroke: ${line.thicknessPt}pt + $colorStr)]';
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

    final alignment = dyOverridePt == null ? 'top + left' : 'left';
    final dy = dyOverridePt ?? _dyPt(line.yMm, dyShift);
    typst.writeln(
      '  #place($alignment, dx: ${documentPdfMmToPt(line.xMm)}pt, dy: $dy)[#rotate(${line.rotationDegrees}deg, origin: center)[$elem]]',
    );
  }

  void _writeSingleCustomShape(
    StringBuffer typst,
    CustomShapeElement shape,
    String dyShift, {
    String? dyOverridePt,
  }) {
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
      elem = _typstCustomShapeElement(shape, strokeColor, fillOpt, wPt, hPt);
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
            '#place(top + left, dx: ${doubleInset}pt, dy: ${doubleInset}pt)[#$kind(width: ${innerWPt}pt, height: ${innerHPt}pt, stroke: ${shape.strokeThicknessPt}pt + $strokeColor)]';
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

    final alignment = dyOverridePt == null ? 'top + left' : 'left';
    final dy = dyOverridePt ?? _dyPt(shape.yMm, dyShift);
    typst.writeln(
      '  #place($alignment, dx: ${documentPdfMmToPt(shape.xMm)}pt, dy: $dy)[#rotate(${shape.rotationDegrees}deg, origin: center)[$elem]]',
    );
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
            '#place(top + left, dx: ${dx}pt, dy: ${dy}pt)[#ellipse(width: ${side}pt, height: ${side}pt, stroke: $outerStroke$fillOpt)]';
        final gap = (shape.strokeThicknessPt * 1.25).clamp(1.0, 10.0);
        final doubleInset = shape.strokeThicknessPt + gap;
        final innerSide = side - 2 * doubleInset;
        if (innerSide <= 0) return outerElem;
        final innerDx = dx + doubleInset;
        final innerDy = dy + doubleInset;
        final innerElem =
            '#place(top + left, dx: ${innerDx}pt, dy: ${innerDy}pt)[#ellipse(width: ${innerSide}pt, height: ${innerSide}pt, stroke: ${shape.strokeThicknessPt}pt + $strokeColor)]';
        return '[$outerElem$innerElem]';
      }
      return '#place(top + left, dx: ${dx}pt, dy: ${dy}pt)[#ellipse(width: ${side}pt, height: ${side}pt, stroke: $stroke$fillOpt)]';
    }

    if (shape.strokeStyle == 'double') {
      final outerStroke = '${shape.strokeThicknessPt}pt + $strokeColor';
      final outerVertices = _typstRegularPolygonVertices(
        widthPt: wPt,
        heightPt: hPt,
        sides: shape.shapeType == 'triangle'
            ? 3
            : shape.polygonSides.clamp(3, 12),
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
        sides: shape.shapeType == 'triangle'
            ? 3
            : shape.polygonSides.clamp(3, 12),
      );
      final innerElem =
          '#polygon(stroke: ${shape.strokeThicknessPt}pt + $strokeColor, $innerVertices)';
      return '[$outerElem$innerElem]';
    }

    final vertices = _typstRegularPolygonVertices(
      widthPt: wPt,
      heightPt: hPt,
      sides: shape.shapeType == 'triangle'
          ? 3
          : shape.polygonSides.clamp(3, 12),
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

abstract class _DocumentBreakableFlowEvent {
  const _DocumentBreakableFlowEvent();

  double get yMm;
  int get zIndex;
}

class _DocumentDynamicFlowRow extends _DocumentBreakableFlowEvent {
  _DocumentDynamicFlowRow(this.texts);

  final List<CustomTextElement> texts;
  final List<dynamic> companions = [];

  @override
  double get yMm => texts.first.yMm;

  @override
  int get zIndex => texts
      .map((text) => text.zIndex)
      .reduce((minimum, value) => math.min(minimum, value));
}

class _DocumentStaticFlowEvent extends _DocumentBreakableFlowEvent {
  const _DocumentStaticFlowEvent(this.element);

  final dynamic element;

  @override
  double get yMm {
    if (element is CustomImageElement) {
      return (element as CustomImageElement).yMm;
    }
    if (element is CustomTextElement) {
      return (element as CustomTextElement).yMm;
    }
    if (element is CustomLineElement) {
      return (element as CustomLineElement).yMm;
    }
    if (element is CustomShapeElement) {
      return (element as CustomShapeElement).yMm;
    }
    return 0;
  }

  @override
  int get zIndex => element.zIndex as int;
}

class _DocumentDynamicFlowColumn {
  const _DocumentDynamicFlowColumn({required this.widthPt, this.text});

  final double widthPt;
  final CustomTextElement? text;
}
