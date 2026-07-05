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

        final cellW = usableW / cols;
        final cellH = usableH / rows;

        final List<T> blockRecords = [];
        for (final record in records) {
          for (var c = 0; c < block.templateCount; c++) {
            blockRecords.add(record);
          }
        }

        final frontPages = <TemplatePage>[];
        final frontDataList = <Map<String, String>>[];
        for (final record in blockRecords) {
          final data = await recordToFields(record);
          frontDataList.add(data);
          frontPages.add(await _substitutor.substitutePage(tmpl.page1, data));
        }

        final frontBatches = layout.fillPage
            ? _buildAutoFillBatches(
                pages: frontPages,
                dataList: frontDataList,
                cols: cols,
                usableH: usableH,
                wPt: wPt,
                hPt: hPt,
                templatePadTopMm: block.templatePadTopMm,
                templatePadLeftMm: block.templatePadLeftMm,
                templatePadRightMm: block.templatePadRightMm,
                templatePadBottomMm: block.templatePadBottomMm,
              )
            : _buildFixedGridBatches(
                pages: frontPages,
                dataList: frontDataList,
                perSheet: cols * rows,
              );

        List<_DocumentSheetBatch>? backBatches;
        if (duplex) {
          final backPages = <TemplatePage>[];
          final backDataList = <Map<String, String>>[];
          for (final record in blockRecords) {
            final data = await recordToFields(record);
            backDataList.add(data);
            backPages.add(await _substitutor.substitutePage(tmpl.page2, data));
          }
          backBatches = layout.fillPage
              ? _buildAutoFillBatches(
                  pages: backPages,
                  dataList: backDataList,
                  cols: cols,
                  usableH: usableH,
                  wPt: wPt,
                  hPt: hPt,
                  templatePadTopMm: block.templatePadTopMm,
                  templatePadLeftMm: block.templatePadLeftMm,
                  templatePadRightMm: block.templatePadRightMm,
                  templatePadBottomMm: block.templatePadBottomMm,
                )
              : _buildFixedGridBatches(
                  pages: backPages,
                  dataList: backDataList,
                  perSheet: cols * rows,
                );
        }

        for (var batchIdx = 0; batchIdx < frontBatches.length; batchIdx++) {
          final isLastBatch = batchIdx == frontBatches.length - 1;
          final isLastBlock = bIdx == layout.blocks.length - 1;
          final breakAfterFront = duplex ||
              !isLastBatch ||
              (isLastBatch && !isLastBlock && block.pageBreakAfter);
          final breakAfterBack = !isLastBatch ||
              (isLastBatch && !isLastBlock && block.pageBreakAfter);

          final frontBatch = frontBatches[batchIdx];
          if (layout.fillPage) {
            _renderer.writeAutoFillDocumentSheet(
              typst: typst,
              pages: frontBatch.pages,
              dataList: frontBatch.dataList,
              cols: cols,
              cellW: cellW,
              usableH: usableH,
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
          } else {
            _renderer.writeTiledDocumentSheet(
              typst: typst,
              pages: frontBatch.pages,
              dataList: frontBatch.dataList,
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
          }

          if (duplex) {
            final backBatch = backBatches![batchIdx];
            if (layout.fillPage) {
              _renderer.writeAutoFillDocumentSheet(
                typst: typst,
                pages: backBatch.pages,
                dataList: backBatch.dataList,
                cols: cols,
                cellW: cellW,
                usableH: usableH,
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
            } else {
              _renderer.writeTiledDocumentSheet(
                typst: typst,
                pages: backBatch.pages,
                dataList: backBatch.dataList,
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

        final cellW = usableW / cols;
        final cellH = usableH / rows;

        final dataList = blockDataMaps[bIdx] ?? [];
        final List<Map<String, String>> blockRecords = [];
        for (final data in dataList) {
          for (var c = 0; c < block.templateCount; c++) {
            blockRecords.add(data);
          }
        }

        final frontPages = <TemplatePage>[];
        final frontDataList = <Map<String, String>>[];
        for (final data in blockRecords) {
          frontDataList.add(data);
          frontPages.add(await _substitutor.substitutePage(tmpl.page1, data));
        }

        final frontBatches = layout.fillPage
            ? _buildAutoFillBatches(
                pages: frontPages,
                dataList: frontDataList,
                cols: cols,
                usableH: usableH,
                wPt: wPt,
                hPt: hPt,
                templatePadTopMm: block.templatePadTopMm,
                templatePadLeftMm: block.templatePadLeftMm,
                templatePadRightMm: block.templatePadRightMm,
                templatePadBottomMm: block.templatePadBottomMm,
              )
            : _buildFixedGridBatches(
                pages: frontPages,
                dataList: frontDataList,
                perSheet: cols * rows,
              );

        List<_DocumentSheetBatch>? backBatches;
        if (duplex) {
          final backPages = <TemplatePage>[];
          final backDataList = <Map<String, String>>[];
          for (final data in blockRecords) {
            backDataList.add(data);
            backPages.add(await _substitutor.substitutePage(tmpl.page2, data));
          }
          backBatches = layout.fillPage
              ? _buildAutoFillBatches(
                  pages: backPages,
                  dataList: backDataList,
                  cols: cols,
                  usableH: usableH,
                  wPt: wPt,
                  hPt: hPt,
                  templatePadTopMm: block.templatePadTopMm,
                  templatePadLeftMm: block.templatePadLeftMm,
                  templatePadRightMm: block.templatePadRightMm,
                  templatePadBottomMm: block.templatePadBottomMm,
                )
              : _buildFixedGridBatches(
                  pages: backPages,
                  dataList: backDataList,
                  perSheet: cols * rows,
                );
        }

        for (var batchIdx = 0; batchIdx < frontBatches.length; batchIdx++) {
          final isLastBatch = batchIdx == frontBatches.length - 1;
          final isLastBlock = bIdx == layout.blocks.length - 1;
          final breakAfterFront = duplex ||
              !isLastBatch ||
              (isLastBatch && !isLastBlock && block.pageBreakAfter);
          final breakAfterBack = !isLastBatch ||
              (isLastBatch && !isLastBlock && block.pageBreakAfter);

          final frontBatch = frontBatches[batchIdx];
          if (layout.fillPage) {
            _renderer.writeAutoFillDocumentSheet(
              typst: typst,
              pages: frontBatch.pages,
              dataList: frontBatch.dataList,
              cols: cols,
              cellW: cellW,
              usableH: usableH,
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
          } else {
            _renderer.writeTiledDocumentSheet(
              typst: typst,
              pages: frontBatch.pages,
              dataList: frontBatch.dataList,
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
          }

          if (duplex) {
            final backBatch = backBatches![batchIdx];
            if (layout.fillPage) {
              _renderer.writeAutoFillDocumentSheet(
                typst: typst,
                pages: backBatch.pages,
                dataList: backBatch.dataList,
                cols: cols,
                cellW: cellW,
                usableH: usableH,
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
            } else {
              _renderer.writeTiledDocumentSheet(
                typst: typst,
                pages: backBatch.pages,
                dataList: backBatch.dataList,
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
    }

    final fontBytesList = await _fontLoader.loadFontBytes();
    return await rust_export.compileTypstToPdf(
      typstContent: typst.toString(),
      fontBytes: fontBytesList,
    );
  }

  List<_DocumentSheetBatch> _buildFixedGridBatches({
    required List<TemplatePage> pages,
    required List<Map<String, String>> dataList,
    required int perSheet,
  }) {
    if (pages.isEmpty) return const [];
    final batches = <_DocumentSheetBatch>[];
    final safePerSheet = math.max(1, perSheet);
    for (var start = 0; start < pages.length; start += safePerSheet) {
      final end = math.min(start + safePerSheet, pages.length);
      batches.add(_DocumentSheetBatch(
        pages: pages.sublist(start, end),
        dataList: dataList.sublist(start, end),
      ));
    }
    return batches;
  }

  List<_DocumentSheetBatch> _buildAutoFillBatches({
    required List<TemplatePage> pages,
    required List<Map<String, String>> dataList,
    required int cols,
    required double usableH,
    required double wPt,
    required double hPt,
    required double templatePadTopMm,
    required double templatePadLeftMm,
    required double templatePadRightMm,
    required double templatePadBottomMm,
  }) {
    if (pages.isEmpty) return const [];

    final cells = <_DocumentSheetCell>[];
    for (var i = 0; i < pages.length; i++) {
      cells.add(_DocumentSheetCell(
        page: pages[i],
        data: dataList[i],
        heightPt: estimateAutoFillCellHeightPt(
          page: pages[i],
          wPt: wPt,
          hPt: hPt,
          templatePadTopMm: templatePadTopMm,
          templatePadLeftMm: templatePadLeftMm,
          templatePadRightMm: templatePadRightMm,
          templatePadBottomMm: templatePadBottomMm,
        ),
      ));
    }

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

      final repeatRows = List<_DocumentSheetRow>.from(sheetRows);
      var repeatIndex = 0;
      while (repeatRows.isNotEmpty) {
        final row = repeatRows[repeatIndex % repeatRows.length];
        if (usedHeight + row.heightPt > usableH) break;
        sheetRows.add(row);
        usedHeight += row.heightPt;
        repeatIndex++;
      }

      batches.add(_DocumentSheetBatch.fromRows(sheetRows));
    }

    return batches;
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
    return bodyHeight + padTop + padBottom;
  }

  static double estimateTemplatePageContentHeightPt({
    required TemplatePage page,
    required double wPt,
    required double hPt,
  }) {
    final hasDynamicText = page.customTexts.any((text) =>
        text.isDynamic &&
        !text.isQrCode &&
        templateGenderIconFieldKeyFromBracketText(text.text) == null);
    var height = hasDynamicText
        ? _estimateStaticTemplateContentHeightPt(page: page, wPt: wPt)
        : hPt;

    for (final text in page.customTexts) {
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
            text.maxWidthMm == null
                ? wPt - documentPdfMmToPt(text.xMm)
                : documentPdfMmToPt(text.maxWidthMm!),
          );
      height = math.max(height, bottom);
    }

    for (final image in page.customImages) {
      height = math.max(
        height,
        documentPdfMmToPt(image.yMm + image.heightMm),
      );
    }

    for (final shape in page.customShapes) {
      height = math.max(
        height,
        documentPdfMmToPt(shape.yMm + shape.heightMm),
      );
    }

    return height;
  }

  static double _estimateStaticTemplateContentHeightPt({
    required TemplatePage page,
    required double wPt,
  }) {
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

      final bottom = documentPdfMmToPt(text.yMm) +
          _estimateTextHeightPt(
            text.text,
            text.fontSizePt,
            text.maxWidthMm == null
                ? wPt - documentPdfMmToPt(text.xMm)
                : documentPdfMmToPt(text.maxWidthMm!),
          );
      height = math.max(height, bottom);
    }

    for (final image in page.customImages) {
      height = math.max(
        height,
        documentPdfMmToPt(image.yMm + image.heightMm),
      );
    }

    for (final shape in page.customShapes) {
      height = math.max(
        height,
        documentPdfMmToPt(shape.yMm + shape.heightMm),
      );
    }

    return height;
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
    required this.pages,
    required this.dataList,
  });

  factory _DocumentSheetBatch.fromRows(List<_DocumentSheetRow> rows) {
    final cells = rows.expand((row) => row.cells).toList();
    return _DocumentSheetBatch(
      pages: cells.map((cell) => cell.page).toList(),
      dataList: cells.map((cell) => cell.data).toList(),
    );
  }

  final List<TemplatePage> pages;
  final List<Map<String, String>> dataList;
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
  });

  final TemplatePage page;
  final Map<String, String> data;
  final double heightPt;
}
