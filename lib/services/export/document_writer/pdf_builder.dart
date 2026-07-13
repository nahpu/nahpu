part of '../document_writer.dart';

class _DocumentPdfBuilder {
  _DocumentPdfBuilder({required this.ref, required this.db})
      : _collector = _DocumentLayoutRecordCollector(ref: ref, db: db),
        _substitutor = _DocumentTemplateSubstitutor(ref: ref);

  final WidgetRef ref;
  final Database db;
  final _DocumentLayoutRecordCollector _collector;
  final _DocumentTemplateSubstitutor _substitutor;
  final _DocumentTypstRenderer _renderer = const _DocumentTypstRenderer();
  final _DocumentFontLoader _fontLoader = const _DocumentFontLoader();

  static bool _usesAutoFill(
    rust_config.DocumentLayoutPreset layout,
    rust_config.DocumentLayoutBlock block,
  ) {
    return layout.fillPage || block.autoFillPage;
  }

  /// Writes a sequence of already planned sheet sections.
  ///
  /// Pagination belongs to the document builder rather than an individual
  /// block.  In particular, a block may be followed by another block and the
  /// final section must not emit a trailing page break.  Keeping this decision
  /// here also makes duplex front/back ordering explicit.
  void _writeSheetSequence({
    required StringBuffer typst,
    required List<_DocumentSheetRenderSpec> sheets,
  }) {
    final pageBreaks = _sheetPageBreakPlan(sheets.length);
    for (var index = 0; index < sheets.length; index++) {
      final sheet = sheets[index];
      final pageBreakAfter = pageBreaks[index] && sheet.forcePageBreakAfter;
      if (sheet.autoFill) {
        _renderer.writeAutoFillDocumentSheet(
          typst: typst,
          cells: sheet.cells,
          cols: sheet.cols,
          cellW: sheet.cellW,
          wPt: sheet.wPt,
          hPt: sheet.hPt,
        );
      } else {
        _renderer.writeTiledDocumentSheet(
          typst: typst,
          cells: sheet.cells,
          cols: sheet.cols,
          rows: sheet.rows,
          cellW: sheet.cellW,
          cellH: sheet.cellH,
          wPt: sheet.wPt,
          hPt: sheet.hPt,
        );
      }
      if (pageBreakAfter) {
        typst.writeln('#pagebreak(weak: true)');
      }
    }
  }

  static List<bool> _sheetPageBreakPlan(int sheetCount) {
    if (sheetCount <= 0) return const [];
    return List<bool>.generate(
      sheetCount,
      (index) => index < sheetCount - 1,
      growable: false,
    );
  }

  @visibleForTesting
  static List<bool> sheetPageBreakPlanForTesting({required int sheetCount}) {
    return _sheetPageBreakPlan(sheetCount);
  }

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

  Future<Uint8List> _generateRecordsPdfGeneric<T>(
    List<T> records, {
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
    required Future<Map<String, String>> Function(T) recordToFields,
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

    if (records.isEmpty) {
      typst.writeln(
          '#set page(width: ${sheetWidthPt}pt, height: ${sheetHeightPt}pt)');
      typst.writeln('#align(center + horizon)[No documents]');
    } else if (layout.layoutType == 'Continuous') {
      final List<_ContinuousPrintItemGeneric<T>> continuousItems = [];

      if (layout.multiBlockMode == 'Alternate') {
        for (final record in records) {
          for (final block in layout.blocks) {
            final tmpl = templates[block.templateName]!;
            for (var c = 0; c < block.templateCount; c++) {
              continuousItems.add(_ContinuousPrintItemGeneric<T>(
                record: record,
                template: tmpl,
                pageTemplate: tmpl.page1,
                block: block,
                mirror: mirrorFront,
              ));
              if (duplex) {
                continuousItems.add(_ContinuousPrintItemGeneric<T>(
                  record: record,
                  template: tmpl,
                  pageTemplate: tmpl.page2,
                  block: block,
                  mirror: mirrorBack,
                ));
              }
            }
          }
        }
      } else {
        for (final block in layout.blocks) {
          final tmpl = templates[block.templateName]!;
          for (final record in records) {
            for (var c = 0; c < block.templateCount; c++) {
              continuousItems.add(_ContinuousPrintItemGeneric<T>(
                record: record,
                template: tmpl,
                pageTemplate: tmpl.page1,
                block: block,
                mirror: mirrorFront,
              ));
              if (duplex) {
                continuousItems.add(_ContinuousPrintItemGeneric<T>(
                  record: record,
                  template: tmpl,
                  pageTemplate: tmpl.page2,
                  block: block,
                  mirror: mirrorBack,
                ));
              }
            }
          }
        }
      }

      for (var i = 0; i < continuousItems.length; i++) {
        final item = continuousItems[i];
        final cellWPt = wPt +
            documentPdfMmToPt(item.block.templatePadLeftMm) +
            documentPdfMmToPt(item.block.templatePadRightMm);

        typst.writeln(
            '#set page(width: ${cellWPt}pt, height: auto, margin: 0pt)');

        final data = await recordToFields(item.record);
        final subbedPage =
            await _substitutor.substitutePage(item.pageTemplate, data);

        _renderer.writeSingleDocumentCell(
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
          continuous: true,
        );
      }
    } else {
      final ptTop = documentPdfMmToPt(layout.pagePadTopMm);
      final ptLeft = documentPdfMmToPt(layout.pagePadLeftMm);
      final ptBottom = documentPdfMmToPt(layout.pagePadBottomMm);
      final ptRight = documentPdfMmToPt(layout.pagePadRightMm);
      typst.writeln(
          '#set page(width: ${sheetWidthPt}pt, height: ${sheetHeightPt}pt, margin: (top: ${ptTop}pt, left: ${ptLeft}pt, bottom: ${ptBottom}pt, right: ${ptRight}pt))');

      final usableW = usablePageWidthPt(
        sheetWidthPt: sheetWidthPt,
        leftPaddingMm: layout.pagePadLeftMm,
        rightPaddingMm: layout.pagePadRightMm,
      );
      final usableH = usablePageHeightPt(
        sheetHeightPt: sheetHeightPt,
        topPaddingMm: layout.pagePadTopMm,
        bottomPaddingMm: layout.pagePadBottomMm,
      );

      if (layout.multiBlockMode == 'Alternate') {
        final List<_DocumentSheetCell> allFrontCells = [];
        final List<_DocumentSheetCell> allBackCells = [];

        for (final record in records) {
          final data = await recordToFields(record);
          for (final block in layout.blocks) {
            final tmpl = templates[block.templateName]!;
            final rows = block.fixedRows;
            final cellH = usableH / rows;

            for (var c = 0; c < block.templateCount; c++) {
              final frontPage =
                  await _substitutor.substitutePage(tmpl.page1, data);
              final frontAutoFill = _usesAutoFill(layout, block);
              final frontHeight = frontAutoFill
                  ? estimateAutoFillCellHeightPt(
                      page: frontPage,
                      wPt: wPt,
                      hPt: hPt,
                      templatePadTopMm: block.templatePadTopMm,
                      templatePadLeftMm: block.templatePadLeftMm,
                      templatePadRightMm: block.templatePadRightMm,
                      templatePadBottomMm: block.templatePadBottomMm,
                    )
                  : cellH;

              allFrontCells.add(_DocumentSheetCell(
                page: frontPage,
                data: data,
                heightPt: frontHeight,
                block: block,
                outline: tmpl.outline,
                mirror: mirrorFront,
                autoHeight: frontAutoFill,
              ));

              if (duplex) {
                final backPage =
                    await _substitutor.substitutePage(tmpl.page2, data);
                final backAutoFill = _usesAutoFill(layout, block);
                final backHeight = backAutoFill
                    ? estimateAutoFillCellHeightPt(
                        page: backPage,
                        wPt: wPt,
                        hPt: hPt,
                        templatePadTopMm: block.templatePadTopMm,
                        templatePadLeftMm: block.templatePadLeftMm,
                        templatePadRightMm: block.templatePadRightMm,
                        templatePadBottomMm: block.templatePadBottomMm,
                      )
                    : cellH;

                allBackCells.add(_DocumentSheetCell(
                  page: backPage,
                  data: data,
                  heightPt: backHeight,
                  block: block,
                  outline: tmpl.outline,
                  mirror: mirrorBack,
                  autoHeight: backAutoFill,
                ));
              }
            }
          }
        }

        if (duplex) {
          for (var i = 0; i < allFrontCells.length; i++) {
            final maxH =
                math.max(allFrontCells[i].heightPt, allBackCells[i].heightPt);
            allFrontCells[i] = allFrontCells[i].copyWithHeight(maxH);
            allBackCells[i] = allBackCells[i].copyWithHeight(maxH);
          }
        }

        final sheets = <_DocumentSheetRenderSpec>[];
        _appendAlternatingRenderSpecs(
          frontCells: allFrontCells,
          backCells: allBackCells,
          usableW: usableW,
          usableH: usableH,
          wPt: wPt,
          hPt: hPt,
          duplex: duplex,
          sheets: sheets,
        );
        _writeSheetSequence(typst: typst, sheets: sheets);
      } else {
        final sheets = <_DocumentSheetRenderSpec>[];
        for (var bIdx = 0; bIdx < layout.blocks.length; bIdx++) {
          final block = layout.blocks[bIdx];
          final tmpl = templates[block.templateName]!;
          final cols = block.cols > 0 ? block.cols : 4;
          final rows = block.fixedRows;

          final cellW = usableW / cols;
          final cellH = usableH / rows;

          final List<_DocumentSheetCell> blockFrontCells = [];
          final List<_DocumentSheetCell> blockBackCells = [];

          for (final record in records) {
            final data = await recordToFields(record);
            for (var c = 0; c < block.templateCount; c++) {
              final frontPage =
                  await _substitutor.substitutePage(tmpl.page1, data);
              final frontAutoFill = _usesAutoFill(layout, block);
              final frontHeight = frontAutoFill
                  ? estimateAutoFillCellHeightPt(
                      page: frontPage,
                      wPt: wPt,
                      hPt: hPt,
                      templatePadTopMm: block.templatePadTopMm,
                      templatePadLeftMm: block.templatePadLeftMm,
                      templatePadRightMm: block.templatePadRightMm,
                      templatePadBottomMm: block.templatePadBottomMm,
                    )
                  : cellH;

              blockFrontCells.add(_DocumentSheetCell(
                page: frontPage,
                data: data,
                heightPt: frontHeight,
                block: block,
                outline: tmpl.outline,
                mirror: mirrorFront,
                autoHeight: frontAutoFill,
              ));

              if (duplex) {
                final backPage =
                    await _substitutor.substitutePage(tmpl.page2, data);
                final backAutoFill = _usesAutoFill(layout, block);
                final backHeight = backAutoFill
                    ? estimateAutoFillCellHeightPt(
                        page: backPage,
                        wPt: wPt,
                        hPt: hPt,
                        templatePadTopMm: block.templatePadTopMm,
                        templatePadLeftMm: block.templatePadLeftMm,
                        templatePadRightMm: block.templatePadRightMm,
                        templatePadBottomMm: block.templatePadBottomMm,
                      )
                    : cellH;

                blockBackCells.add(_DocumentSheetCell(
                  page: backPage,
                  data: data,
                  heightPt: backHeight,
                  block: block,
                  outline: tmpl.outline,
                  mirror: mirrorBack,
                  autoHeight: backAutoFill,
                ));
              }
            }
          }

          if (duplex) {
            for (var i = 0; i < blockFrontCells.length; i++) {
              final maxH = math.max(
                  blockFrontCells[i].heightPt, blockBackCells[i].heightPt);
              blockFrontCells[i] = blockFrontCells[i].copyWithHeight(maxH);
              blockBackCells[i] = blockBackCells[i].copyWithHeight(maxH);
            }
          }

          final blockAutoFill = _usesAutoFill(layout, block);
          final frontBatches = blockAutoFill
              ? _buildAutoFillBatches(
                  cells: blockFrontCells,
                  cols: cols,
                  usableH: usableH,
                )
              : _buildFixedGridBatches(
                  cells: blockFrontCells,
                  perSheet: cols * rows,
                );

          List<_DocumentSheetBatch>? backBatches;
          if (duplex) {
            backBatches = blockAutoFill
                ? _buildAutoFillBatches(
                    cells: blockBackCells,
                    cols: cols,
                    usableH: usableH,
                  )
                : _buildFixedGridBatches(
                    cells: blockBackCells,
                    perSheet: cols * rows,
                  );
          }

          for (var batchIdx = 0; batchIdx < frontBatches.length; batchIdx++) {
            final isLastBatch = batchIdx == frontBatches.length - 1;
            final blockBoundaryBreak = !isLastBatch || block.pageBreakAfter;
            final frontBatch = frontBatches[batchIdx];
            sheets.add(_DocumentSheetRenderSpec(
              cells: frontBatch.cells,
              cols: cols,
              rows: rows,
              cellW: cellW,
              cellH: cellH,
              wPt: wPt,
              hPt: hPt,
              autoFill: blockAutoFill,
              forcePageBreakAfter: duplex || blockBoundaryBreak,
            ));

            if (duplex) {
              final backBatch = backBatches![batchIdx];
              sheets.add(_DocumentSheetRenderSpec(
                cells: backBatch.cells,
                cols: cols,
                rows: rows,
                cellW: cellW,
                cellH: cellH,
                wPt: wPt,
                hPt: hPt,
                autoFill: blockAutoFill,
                forcePageBreakAfter: blockBoundaryBreak,
              ));
            }
          }
        }
        _writeSheetSequence(typst: typst, sheets: sheets);
      }
    }

    final fontBytesList = await _fontLoader.loadFontBytes();
    return await rust_export.compileTypstToPdf(
      typstContent: typst.toString(),
      fontBytes: fontBytesList,
    );
  }

  /// Generates PDF bytes for specimen document records without writing a file.
  ///
  /// [sheetWidthPt] and [sheetHeightPt] are the physical output page dimensions
  /// in Typst points.
  Future<Uint8List> generateDocumentsPdf(
    List<SpecimenData> specimens, {
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
  }) {
    return _generateRecordsPdfGeneric<SpecimenData>(
      specimens,
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
      recordToFields: (s) => documentFieldValuesForSpecimen(db, s, ref),
    );
  }

  /// Generates PDF bytes for site document records without writing a file.
  ///
  /// [sheetWidthPt] and [sheetHeightPt] are the physical output page dimensions
  /// in Typst points.
  Future<Uint8List> generateSitesPdf(
    List<SiteData> sites, {
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
  }) {
    return _generateRecordsPdfGeneric<SiteData>(
      sites,
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
      recordToFields: (s) => documentFieldValuesForSite(db, s, ref),
    );
  }

  /// Generates PDF bytes for collecting event document records without writing
  /// a file.
  ///
  /// [sheetWidthPt] and [sheetHeightPt] are the physical output page dimensions
  /// in Typst points.
  Future<Uint8List> generateEventsPdf(
    List<CollEventData> events, {
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
  }) {
    return _generateRecordsPdfGeneric<CollEventData>(
      events,
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
      recordToFields: (s) => documentFieldValuesForCollEvent(db, s, ref),
    );
  }

  /// Generates PDF bytes for narrative document records without writing a file.
  ///
  /// [sheetWidthPt] and [sheetHeightPt] are the physical output page dimensions
  /// in Typst points.
  Future<Uint8List> generateNarrativesPdf(
    List<NarrativeData> narratives, {
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
  }) {
    return _generateRecordsPdfGeneric<NarrativeData>(
      narratives,
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
      recordToFields: (s) => documentFieldValuesForNarrative(db, s, ref),
    );
  }

  /// Generates PDF bytes for the full mixed-record document [layout].
  ///
  /// When [isPreview] is true, [previewRecords] supplies the record identifiers
  /// used for each template block instead of the current provider selection.
  Future<Uint8List> generateLayoutPdf({
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
    bool isPreview = false,
    List<String>? previewRecords,
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

    // Collect all data maps per block
    final Map<int, List<Map<String, String>>> blockDataMaps = {};
    int totalRecordCount = 0;
    for (var bIdx = 0; bIdx < layout.blocks.length; bIdx++) {
      final block = layout.blocks[bIdx];
      final tmpl = templates[block.templateName]!;
      final dataList = await _collector.getRecordDataListForBlock(
        bIdx,
        tmpl.recordType,
        isPreview,
        previewRecords,
      );
      blockDataMaps[bIdx] = dataList;
      totalRecordCount += dataList.length;
    }

    if (totalRecordCount == 0) {
      typst.writeln(
          '#set page(width: ${sheetWidthPt}pt, height: ${sheetHeightPt}pt)');
      typst.writeln('#align(center + horizon)[No documents]');
    } else if (layout.layoutType == 'Continuous') {
      final List<_ContinuousPrintItem> continuousItems = [];

      if (layout.multiBlockMode == 'Alternate') {
        int maxDataLength = 0;
        for (var bIdx = 0; bIdx < layout.blocks.length; bIdx++) {
          final len = (blockDataMaps[bIdx] ?? []).length;
          if (len > maxDataLength) {
            maxDataLength = len;
          }
        }

        for (var idx = 0; idx < maxDataLength; idx++) {
          for (var bIdx = 0; bIdx < layout.blocks.length; bIdx++) {
            final block = layout.blocks[bIdx];
            final dataList = blockDataMaps[bIdx] ?? [];
            if (idx >= dataList.length) {
              continue;
            }
            final data = dataList[idx];
            final tmpl = templates[block.templateName]!;

            for (var c = 0; c < block.templateCount; c++) {
              continuousItems.add(_ContinuousPrintItem(
                data: data,
                template: tmpl,
                pageTemplate: tmpl.page1,
                block: block,
                mirror: mirrorFront,
              ));
              if (duplex) {
                continuousItems.add(_ContinuousPrintItem(
                  data: data,
                  template: tmpl,
                  pageTemplate: tmpl.page2,
                  block: block,
                  mirror: mirrorBack,
                ));
              }
            }
          }
        }
      } else {
        for (var bIdx = 0; bIdx < layout.blocks.length; bIdx++) {
          final block = layout.blocks[bIdx];
          final tmpl = templates[block.templateName]!;
          final dataList = blockDataMaps[bIdx] ?? [];

          for (final data in dataList) {
            for (var c = 0; c < block.templateCount; c++) {
              continuousItems.add(_ContinuousPrintItem(
                data: data,
                template: tmpl,
                pageTemplate: tmpl.page1,
                block: block,
                mirror: mirrorFront,
              ));
              if (duplex) {
                continuousItems.add(_ContinuousPrintItem(
                  data: data,
                  template: tmpl,
                  pageTemplate: tmpl.page2,
                  block: block,
                  mirror: mirrorBack,
                ));
              }
            }
          }
        }
      }

      for (var i = 0; i < continuousItems.length; i++) {
        final item = continuousItems[i];
        final cellWPt = wPt +
            documentPdfMmToPt(item.block.templatePadLeftMm) +
            documentPdfMmToPt(item.block.templatePadRightMm);

        typst.writeln(
            '#set page(width: ${cellWPt}pt, height: auto, margin: 0pt)');

        final subbedPage =
            await _substitutor.substitutePage(item.pageTemplate, item.data);

        _renderer.writeSingleDocumentCell(
          typst: typst,
          page: subbedPage,
          data: item.data,
          wPt: wPt,
          hPt: hPt,
          templatePadTopMm: item.block.templatePadTopMm,
          templatePadLeftMm: item.block.templatePadLeftMm,
          templatePadRightMm: item.block.templatePadRightMm,
          templatePadBottomMm: item.block.templatePadBottomMm,
          mirror: item.mirror,
          outline: item.template.outline,
          continuous: true,
        );
      }
    } else {
      final ptTop = documentPdfMmToPt(layout.pagePadTopMm);
      final ptLeft = documentPdfMmToPt(layout.pagePadLeftMm);
      final ptBottom = documentPdfMmToPt(layout.pagePadBottomMm);
      final ptRight = documentPdfMmToPt(layout.pagePadRightMm);
      typst.writeln(
          '#set page(width: ${sheetWidthPt}pt, height: ${sheetHeightPt}pt, margin: (top: ${ptTop}pt, left: ${ptLeft}pt, bottom: ${ptBottom}pt, right: ${ptRight}pt))');

      final usableW = usablePageWidthPt(
        sheetWidthPt: sheetWidthPt,
        leftPaddingMm: layout.pagePadLeftMm,
        rightPaddingMm: layout.pagePadRightMm,
      );
      final usableH = usablePageHeightPt(
        sheetHeightPt: sheetHeightPt,
        topPaddingMm: layout.pagePadTopMm,
        bottomPaddingMm: layout.pagePadBottomMm,
      );

      if (layout.multiBlockMode == 'Alternate') {
        final List<_DocumentSheetCell> allFrontCells = [];
        final List<_DocumentSheetCell> allBackCells = [];

        int maxDataLength = 0;
        for (var bIdx = 0; bIdx < layout.blocks.length; bIdx++) {
          final len = (blockDataMaps[bIdx] ?? []).length;
          if (len > maxDataLength) {
            maxDataLength = len;
          }
        }

        for (var idx = 0; idx < maxDataLength; idx++) {
          for (var bIdx = 0; bIdx < layout.blocks.length; bIdx++) {
            final block = layout.blocks[bIdx];
            final dataList = blockDataMaps[bIdx] ?? [];
            if (idx >= dataList.length) {
              continue;
            }
            final data = dataList[idx];
            final tmpl = templates[block.templateName]!;
            final rows = block.fixedRows;
            final cellH = usableH / rows;

            for (var c = 0; c < block.templateCount; c++) {
              final frontPage =
                  await _substitutor.substitutePage(tmpl.page1, data);
              final frontAutoFill = _usesAutoFill(layout, block);
              final frontHeight = frontAutoFill
                  ? estimateAutoFillCellHeightPt(
                      page: frontPage,
                      wPt: wPt,
                      hPt: hPt,
                      templatePadTopMm: block.templatePadTopMm,
                      templatePadLeftMm: block.templatePadLeftMm,
                      templatePadRightMm: block.templatePadRightMm,
                      templatePadBottomMm: block.templatePadBottomMm,
                    )
                  : cellH;

              allFrontCells.add(_DocumentSheetCell(
                page: frontPage,
                data: data,
                heightPt: frontHeight,
                block: block,
                outline: tmpl.outline,
                mirror: mirrorFront,
                autoHeight: frontAutoFill,
              ));

              if (duplex) {
                final backPage =
                    await _substitutor.substitutePage(tmpl.page2, data);
                final backAutoFill = _usesAutoFill(layout, block);
                final backHeight = backAutoFill
                    ? estimateAutoFillCellHeightPt(
                        page: backPage,
                        wPt: wPt,
                        hPt: hPt,
                        templatePadTopMm: block.templatePadTopMm,
                        templatePadLeftMm: block.templatePadLeftMm,
                        templatePadRightMm: block.templatePadRightMm,
                        templatePadBottomMm: block.templatePadBottomMm,
                      )
                    : cellH;

                allBackCells.add(_DocumentSheetCell(
                  page: backPage,
                  data: data,
                  heightPt: backHeight,
                  block: block,
                  outline: tmpl.outline,
                  mirror: mirrorBack,
                  autoHeight: backAutoFill,
                ));
              }
            }
          }
        }

        if (duplex) {
          for (var i = 0; i < allFrontCells.length; i++) {
            final maxH =
                math.max(allFrontCells[i].heightPt, allBackCells[i].heightPt);
            allFrontCells[i] = allFrontCells[i].copyWithHeight(maxH);
            allBackCells[i] = allBackCells[i].copyWithHeight(maxH);
          }
        }

        final sheets = <_DocumentSheetRenderSpec>[];
        _appendAlternatingRenderSpecs(
          frontCells: allFrontCells,
          backCells: allBackCells,
          usableW: usableW,
          usableH: usableH,
          wPt: wPt,
          hPt: hPt,
          duplex: duplex,
          sheets: sheets,
        );
        _writeSheetSequence(typst: typst, sheets: sheets);
      } else {
        final sheets = <_DocumentSheetRenderSpec>[];
        for (var bIdx = 0; bIdx < layout.blocks.length; bIdx++) {
          final block = layout.blocks[bIdx];
          final tmpl = templates[block.templateName]!;
          final cols = block.cols > 0 ? block.cols : 4;
          final rows = block.fixedRows;

          final cellW = usableW / cols;
          final cellH = usableH / rows;

          final dataList = blockDataMaps[bIdx] ?? [];
          final List<_DocumentSheetCell> blockFrontCells = [];
          final List<_DocumentSheetCell> blockBackCells = [];

          for (final data in dataList) {
            for (var c = 0; c < block.templateCount; c++) {
              final frontPage =
                  await _substitutor.substitutePage(tmpl.page1, data);
              final frontAutoFill = _usesAutoFill(layout, block);
              final frontHeight = frontAutoFill
                  ? estimateAutoFillCellHeightPt(
                      page: frontPage,
                      wPt: wPt,
                      hPt: hPt,
                      templatePadTopMm: block.templatePadTopMm,
                      templatePadLeftMm: block.templatePadLeftMm,
                      templatePadRightMm: block.templatePadRightMm,
                      templatePadBottomMm: block.templatePadBottomMm,
                    )
                  : cellH;

              blockFrontCells.add(_DocumentSheetCell(
                page: frontPage,
                data: data,
                heightPt: frontHeight,
                block: block,
                outline: tmpl.outline,
                mirror: mirrorFront,
                autoHeight: frontAutoFill,
              ));

              if (duplex) {
                final backPage =
                    await _substitutor.substitutePage(tmpl.page2, data);
                final backAutoFill = _usesAutoFill(layout, block);
                final backHeight = backAutoFill
                    ? estimateAutoFillCellHeightPt(
                        page: backPage,
                        wPt: wPt,
                        hPt: hPt,
                        templatePadTopMm: block.templatePadTopMm,
                        templatePadLeftMm: block.templatePadLeftMm,
                        templatePadRightMm: block.templatePadRightMm,
                        templatePadBottomMm: block.templatePadBottomMm,
                      )
                    : cellH;

                blockBackCells.add(_DocumentSheetCell(
                  page: backPage,
                  data: data,
                  heightPt: backHeight,
                  block: block,
                  outline: tmpl.outline,
                  mirror: mirrorBack,
                  autoHeight: backAutoFill,
                ));
              }
            }
          }

          if (duplex) {
            for (var i = 0; i < blockFrontCells.length; i++) {
              final maxH = math.max(
                  blockFrontCells[i].heightPt, blockBackCells[i].heightPt);
              blockFrontCells[i] = blockFrontCells[i].copyWithHeight(maxH);
              blockBackCells[i] = blockBackCells[i].copyWithHeight(maxH);
            }
          }

          final blockAutoFill = _usesAutoFill(layout, block);
          final frontBatches = blockAutoFill
              ? _buildAutoFillBatches(
                  cells: blockFrontCells,
                  cols: cols,
                  usableH: usableH,
                )
              : _buildFixedGridBatches(
                  cells: blockFrontCells,
                  perSheet: cols * rows,
                );

          List<_DocumentSheetBatch>? backBatches;
          if (duplex) {
            backBatches = blockAutoFill
                ? _buildAutoFillBatches(
                    cells: blockBackCells,
                    cols: cols,
                    usableH: usableH,
                  )
                : _buildFixedGridBatches(
                    cells: blockBackCells,
                    perSheet: cols * rows,
                  );
          }

          for (var batchIdx = 0; batchIdx < frontBatches.length; batchIdx++) {
            final isLastBatch = batchIdx == frontBatches.length - 1;
            final blockBoundaryBreak = !isLastBatch || block.pageBreakAfter;
            final frontBatch = frontBatches[batchIdx];
            sheets.add(_DocumentSheetRenderSpec(
              cells: frontBatch.cells,
              cols: cols,
              rows: rows,
              cellW: cellW,
              cellH: cellH,
              wPt: wPt,
              hPt: hPt,
              autoFill: blockAutoFill,
              forcePageBreakAfter: duplex || blockBoundaryBreak,
            ));

            if (duplex) {
              final backBatch = backBatches![batchIdx];
              sheets.add(_DocumentSheetRenderSpec(
                cells: backBatch.cells,
                cols: cols,
                rows: rows,
                cellW: cellW,
                cellH: cellH,
                wPt: wPt,
                hPt: hPt,
                autoFill: blockAutoFill,
                forcePageBreakAfter: blockBoundaryBreak,
              ));
            }
          }
        }
        _writeSheetSequence(typst: typst, sheets: sheets);
      }
    }

    final fontBytesList = await _fontLoader.loadFontBytes();
    return await rust_export.compileTypstToPdf(
      typstContent: typst.toString(),
      fontBytes: fontBytesList,
    );
  }

  List<_DocumentSheetBatch> _buildFixedGridBatches({
    required List<_DocumentSheetCell> cells,
    required int perSheet,
  }) {
    if (cells.isEmpty) return const [];
    final batches = <_DocumentSheetBatch>[];
    final safePerSheet = math.max(1, perSheet);
    for (var start = 0; start < cells.length; start += safePerSheet) {
      final end = math.min(start + safePerSheet, cells.length);
      batches.add(_DocumentSheetBatch(
        cells: cells.sublist(start, end),
      ));
    }
    return batches;
  }

  /// Appends renderable sheets for Alternate mode while respecting each
  /// block's grid geometry.
  ///
  /// Alternate mode interleaves cells from different blocks.  A single grid
  /// cannot safely use the first block's column/row settings for every cell,
  /// so contiguous cells with the same geometry are planned as independent
  /// sections.
  void _appendAlternatingRenderSpecs({
    required List<_DocumentSheetCell> frontCells,
    required List<_DocumentSheetCell> backCells,
    required double usableW,
    required double usableH,
    required double wPt,
    required double hPt,
    required bool duplex,
    required List<_DocumentSheetRenderSpec> sheets,
  }) {
    var start = 0;
    while (start < frontCells.length) {
      final first = frontCells[start];
      final cols = first.block.cols > 0 ? first.block.cols : 4;
      final rows = first.block.fixedRows;
      final autoFill = first.autoHeight;

      var end = start + 1;
      while (end < frontCells.length) {
        final cell = frontCells[end];
        final cellCols = cell.block.cols > 0 ? cell.block.cols : 4;
        if (cellCols != cols ||
            cell.block.fixedRows != rows ||
            cell.autoHeight != autoFill) {
          break;
        }
        end++;
      }

      final segmentFront = frontCells.sublist(start, end);
      final cellW = usableW / cols;
      final cellH = usableH / rows;
      final frontBatches = autoFill
          ? _buildAutoFillBatches(
              cells: segmentFront,
              cols: cols,
              usableH: usableH,
            )
          : _buildFixedGridBatches(
              cells: segmentFront,
              perSheet: cols * rows,
            );

      List<_DocumentSheetBatch>? backBatches;
      if (duplex) {
        final segmentBack = backCells.sublist(start, end);
        backBatches = autoFill
            ? _buildAutoFillBatches(
                cells: segmentBack,
                cols: cols,
                usableH: usableH,
              )
            : _buildFixedGridBatches(
                cells: segmentBack,
                perSheet: cols * rows,
              );
      }

      for (var batchIndex = 0; batchIndex < frontBatches.length; batchIndex++) {
        final frontBatch = frontBatches[batchIndex];
        sheets.add(_DocumentSheetRenderSpec(
          cells: frontBatch.cells,
          cols: cols,
          rows: rows,
          cellW: cellW,
          cellH: cellH,
          wPt: wPt,
          hPt: hPt,
          autoFill: autoFill,
          forcePageBreakAfter: true,
        ));

        if (duplex) {
          final backBatch = backBatches![batchIndex];
          sheets.add(_DocumentSheetRenderSpec(
            cells: backBatch.cells,
            cols: cols,
            rows: rows,
            cellW: cellW,
            cellH: cellH,
            wPt: wPt,
            hPt: hPt,
            autoFill: autoFill,
            forcePageBreakAfter: true,
          ));
        }
      }

      start = end;
    }
  }

  List<_DocumentSheetBatch> _buildAutoFillBatches({
    required List<_DocumentSheetCell> cells,
    required int cols,
    required double usableH,
  }) {
    if (cells.isEmpty) return const [];

    final originalRows = <_DocumentSheetRow>[];
    final safeCols = math.max(1, cols);
    for (var start = 0; start < cells.length; start += safeCols) {
      final end = math.min(start + safeCols, cells.length);
      originalRows.add(_DocumentSheetRow(cells.sublist(start, end)));
    }

    final batches = <_DocumentSheetBatch>[];
    var rowIndex = 0;
    while (rowIndex < originalRows.length) {
      final sheetRows = <_DocumentSheetRow>[];
      var usedHeight = 0.0;

      while (rowIndex < originalRows.length) {
        final row = originalRows[rowIndex];
        if (sheetRows.isNotEmpty && usedHeight + row.heightPt > usableH) {
          break;
        }
        sheetRows.add(row);
        usedHeight += row.heightPt;
        rowIndex++;
      }

      if (sheetRows.isNotEmpty) {
        final shortestRow = sheetRows.reduce(
          (a, b) => a.heightPt <= b.heightPt ? a : b,
        );
        final repeatCount = maxAutoFillRepeatCount(
          rowHeight: shortestRow.heightPt,
          usedHeight: usedHeight,
          usableHeight: usableH,
        );
        sheetRows.addAll(List.filled(repeatCount, shortestRow));
      }

      batches.add(_DocumentSheetBatch(
        cells: sheetRows.expand((row) => row.cells).toList(),
      ));
    }

    return batches;
  }

  static int maxAutoFillRepeatCount({
    required double rowHeight,
    required double usedHeight,
    required double usableHeight,
  }) {
    if (rowHeight <= 0 || usedHeight >= usableHeight) return 0;
    const floatingPointTolerancePt = 0.001;
    return math.max(
      0,
      ((usableHeight - usedHeight + floatingPointTolerancePt) / rowHeight)
          .floor(),
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
    final padTop = documentPdfMmToPt(templatePadTopMm);
    final padBottom = documentPdfMmToPt(templatePadBottomMm);
    final bodyHeight = estimateTemplatePageContentHeightPt(
      page: page,
      wPt: wPt,
      hPt: hPt,
    );
    // A template's configured canvas height is its minimum physical height.
    // Dynamic content may extend that canvas, but sparse content must not make
    // neighbouring templates move closer together than the template design
    // permits.
    return math.max(hPt, bodyHeight) + padTop + padBottom;
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
      if (hasDynamicText &&
          !text.isDynamic &&
          !text.isQrCode &&
          genderIconKey == null) {
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

      final bottom = documentPdfMmToPt(text.yMm) +
          _estimateTextHeightPt(
            text.text,
            text.fontSizePt,
            _textContentWidthPt(text, wPt),
          ) +
          _textBoxVerticalExtraPt(text);
      height = math.max(height, bottom);
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
      if (bottom <= 0) continue;
      height = math.max(height, bottom);
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
    return 0;
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
    final padding = _textBoxPaddingTotalPt(text);
    return math.max(1.0, _textMaxWidthPt(text, wPt) - padding);
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
    final ys = <double>[
      0,
      widthPt * sinA,
      heightPt * cosA,
      widthPt * sinA + heightPt * cosA,
    ];
    return ys.reduce(math.max);
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
}

class _DocumentSheetBatch {
  const _DocumentSheetBatch({
    required this.cells,
  });

  final List<_DocumentSheetCell> cells;
}

class _DocumentSheetRenderSpec {
  const _DocumentSheetRenderSpec({
    required this.cells,
    required this.cols,
    required this.rows,
    required this.cellW,
    required this.cellH,
    required this.wPt,
    required this.hPt,
    required this.autoFill,
    required this.forcePageBreakAfter,
  });

  final List<_DocumentSheetCell> cells;
  final int cols;
  final int rows;
  final double cellW;
  final double cellH;
  final double wPt;
  final double hPt;
  final bool autoFill;
  final bool forcePageBreakAfter;
}

class _DocumentSheetRow {
  const _DocumentSheetRow(this.cells);

  final List<_DocumentSheetCell> cells;

  double get heightPt => cells.fold<double>(
        0,
        (height, cell) => math.max(height, cell.heightPt),
      );
}

class _DocumentSheetCell {
  const _DocumentSheetCell({
    required this.page,
    required this.data,
    required this.heightPt,
    required this.block,
    required this.outline,
    required this.mirror,
    required this.autoHeight,
  });

  final TemplatePage page;
  final Map<String, String> data;
  final double heightPt;
  final rust_config.DocumentLayoutBlock block;
  final TemplateOutline? outline;
  final bool mirror;
  final bool autoHeight;

  _DocumentSheetCell copyWithHeight(double maxH) {
    return _DocumentSheetCell(
      page: page,
      data: data,
      heightPt: maxH,
      block: block,
      outline: outline,
      mirror: mirror,
      autoHeight: autoHeight,
    );
  }
}
