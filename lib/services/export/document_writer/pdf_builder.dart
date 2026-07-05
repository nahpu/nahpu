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
        final perSheet = cols * rows;

        final cellW = usableW / cols;
        final cellH = usableH / rows;

        final List<T> blockRecords = [];
        for (final record in records) {
          for (var c = 0; c < block.templateCount; c++) {
            blockRecords.add(record);
          }
        }

        for (var start = 0; start < blockRecords.length; start += perSheet) {
          final end = math.min(start + perSheet, blockRecords.length);
          final batch = blockRecords.sublist(start, end);
          final isLastBatch = (start + perSheet) >= blockRecords.length;
          final isLastBlock = bIdx == layout.blocks.length - 1;

          final breakAfterFront = duplex ||
              !isLastBatch ||
              (isLastBatch && !isLastBlock && block.pageBreakAfter);
          final breakAfterBack = !isLastBatch ||
              (isLastBatch && !isLastBlock && block.pageBreakAfter);

          final frontPages = <TemplatePage>[];
          final frontDataList = <Map<String, String>>[];
          for (final record in batch) {
            final data = await recordToFields(record);
            frontDataList.add(data);
            frontPages.add(await _substitutor.substitutePage(tmpl.page1, data));
          }
          if (layout.fillPage && frontPages.length < perSheet) {
            final paddingCount = perSheet - frontPages.length;
            final originalFrontDataList = List<Map<String, String>>.from(frontDataList);
            final originalFrontPages = List<TemplatePage>.from(frontPages);
            for (var p = 0; p < paddingCount; p++) {
              final repeatIdx = p % originalFrontPages.length;
              frontDataList.add(originalFrontDataList[repeatIdx]);
              frontPages.add(originalFrontPages[repeatIdx]);
            }
          }
          _renderer.writeTiledDocumentSheet(
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
            for (final record in batch) {
              final data = await recordToFields(record);
              backDataList.add(data);
              backPages
                  .add(await _substitutor.substitutePage(tmpl.page2, data));
            }
            if (layout.fillPage && backPages.length < perSheet) {
              final paddingCount = perSheet - backPages.length;
              final originalBackDataList = List<Map<String, String>>.from(backDataList);
              final originalBackPages = List<TemplatePage>.from(backPages);
              for (var p = 0; p < paddingCount; p++) {
                final repeatIdx = p % originalBackPages.length;
                backDataList.add(originalBackDataList[repeatIdx]);
                backPages.add(originalBackPages[repeatIdx]);
              }
            }
            _renderer.writeTiledDocumentSheet(
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
        final perSheet = cols * rows;

        final cellW = usableW / cols;
        final cellH = usableH / rows;

        final dataList = blockDataMaps[bIdx] ?? [];
        final List<Map<String, String>> blockRecords = [];
        for (final data in dataList) {
          for (var c = 0; c < block.templateCount; c++) {
            blockRecords.add(data);
          }
        }

        for (var start = 0; start < blockRecords.length; start += perSheet) {
          final end = math.min(start + perSheet, blockRecords.length);
          final batch = blockRecords.sublist(start, end);
          final isLastBatch = (start + perSheet) >= blockRecords.length;
          final isLastBlock = bIdx == layout.blocks.length - 1;

          final breakAfterFront = duplex ||
              !isLastBatch ||
              (isLastBatch && !isLastBlock && block.pageBreakAfter);
          final breakAfterBack = !isLastBatch ||
              (isLastBatch && !isLastBlock && block.pageBreakAfter);

          final frontPages = <TemplatePage>[];
          final frontDataList = <Map<String, String>>[];
          for (final data in batch) {
            frontDataList.add(data);
            frontPages.add(await _substitutor.substitutePage(tmpl.page1, data));
          }
          if (layout.fillPage && frontPages.length < perSheet) {
            final paddingCount = perSheet - frontPages.length;
            final originalFrontDataList = List<Map<String, String>>.from(frontDataList);
            final originalFrontPages = List<TemplatePage>.from(frontPages);
            for (var p = 0; p < paddingCount; p++) {
              final repeatIdx = p % originalFrontPages.length;
              frontDataList.add(originalFrontDataList[repeatIdx]);
              frontPages.add(originalFrontPages[repeatIdx]);
            }
          }
          _renderer.writeTiledDocumentSheet(
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
            for (final data in batch) {
              backDataList.add(data);
              backPages
                  .add(await _substitutor.substitutePage(tmpl.page2, data));
            }
            if (layout.fillPage && backPages.length < perSheet) {
              final paddingCount = perSheet - backPages.length;
              final originalBackDataList = List<Map<String, String>>.from(backDataList);
              final originalBackPages = List<TemplatePage>.from(backPages);
              for (var p = 0; p < paddingCount; p++) {
                final repeatIdx = p % originalBackPages.length;
                backDataList.add(originalBackDataList[repeatIdx]);
                backPages.add(originalBackPages[repeatIdx]);
              }
            }
            _renderer.writeTiledDocumentSheet(
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

    final fontBytesList = await _fontLoader.loadFontBytes();
    return await rust_export.compileTypstToPdf(
      typstContent: typst.toString(),
      fontBytes: fontBytesList,
    );
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
