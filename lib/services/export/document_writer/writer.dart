part of '../document_writer.dart';

/// Orchestrates the process of converting specimen data into a generated
/// PDF document file using the Typst rendering engine.
class DocumentWriter {
  /// Creates a document writer that reads selected records and settings from
  /// Riverpod providers.
  DocumentWriter({required this.ref});

  /// Provider reference used to access database, selection, and settings state.
  final WidgetRef ref;

  Database get _db => ref.read(databaseProvider);

  Future<File> _writeRecordsGeneric<T>({
    required List<T> picked,
    required Directory selectedDir,
    required String fileStem,
    required rust_config.DocumentLayoutPreset layout,
    required Future<Uint8List> Function(
            List<T> picked, double sheetWidthPt, double sheetHeightPt)
        generatePdf,
  }) async {
    double w = _getPageWidth(layout.pageSizeKey, layout.customPageWidthMm);
    double h = _getPageHeight(layout.pageSizeKey, layout.customPageHeightMm);

    if (layout.pageOrientation == 'landscape') {
      final tmp = w;
      w = h;
      h = tmp;
    }

    final pdfBytes = await generatePdf(
      picked,
      w * 72.0 / 25.4,
      h * 72.0 / 25.4,
    );

    final savePath =
        await AppIOServices(dir: selectedDir, fileStem: fileStem, ext: 'pdf')
            .getSavePath();
    await savePath.writeAsBytes(pdfBytes);
    return savePath;
  }

  /// Writes a PDF preview of the configured [layout] to [selectedDir].
  ///
  /// The generated file name is derived from [fileStem], with collisions handled
  /// by the app IO service.
  Future<File> writeLayout({
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

    final pdfBytes = await generateLayoutPdf(
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

  /// Writes specimen document records as a PDF using [layout].
  ///
  /// Each selected specimen in [picked] is converted to document field values
  /// before being placed into the configured template blocks.
  Future<File> writeDocuments({
    required List<SpecimenData> picked,
    required Directory selectedDir,
    required String fileStem,
    required rust_config.DocumentLayoutPreset layout,
  }) {
    return _writeRecordsGeneric<SpecimenData>(
      picked: picked,
      selectedDir: selectedDir,
      fileStem: fileStem,
      layout: layout,
      generatePdf: (p, w, h) => generateDocumentsPdf(
        p,
        sheetWidthPt: w,
        sheetHeightPt: h,
        layout: layout,
      ),
    );
  }

  /// Writes site document records as a PDF using [layout].
  ///
  /// Each selected site in [picked] is converted to document field values before
  /// rendering.
  Future<File> writeSites({
    required List<SiteData> picked,
    required Directory selectedDir,
    required String fileStem,
    required rust_config.DocumentLayoutPreset layout,
  }) {
    return _writeRecordsGeneric<SiteData>(
      picked: picked,
      selectedDir: selectedDir,
      fileStem: fileStem,
      layout: layout,
      generatePdf: (p, w, h) => generateSitesPdf(
        p,
        sheetWidthPt: w,
        sheetHeightPt: h,
        layout: layout,
      ),
    );
  }

  /// Writes collecting event document records as a PDF using [layout].
  ///
  /// Each selected event in [picked] is expanded with related site, effort, and
  /// personnel values before rendering.
  Future<File> writeEvents({
    required List<CollEventData> picked,
    required Directory selectedDir,
    required String fileStem,
    required rust_config.DocumentLayoutPreset layout,
  }) {
    return _writeRecordsGeneric<CollEventData>(
      picked: picked,
      selectedDir: selectedDir,
      fileStem: fileStem,
      layout: layout,
      generatePdf: (p, w, h) => generateEventsPdf(
        p,
        sheetWidthPt: w,
        sheetHeightPt: h,
        layout: layout,
      ),
    );
  }

  /// Writes narrative document records as a PDF using [layout].
  ///
  /// Each selected narrative in [picked] is expanded with related site and
  /// personnel values before rendering.
  Future<File> writeNarratives({
    required List<NarrativeData> picked,
    required Directory selectedDir,
    required String fileStem,
    required rust_config.DocumentLayoutPreset layout,
  }) {
    return _writeRecordsGeneric<NarrativeData>(
      picked: picked,
      selectedDir: selectedDir,
      fileStem: fileStem,
      layout: layout,
      generatePdf: (p, w, h) => generateNarrativesPdf(
        p,
        sheetWidthPt: w,
        sheetHeightPt: h,
        layout: layout,
      ),
    );
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
        final cellHPt = hPt +
            documentPdfMmToPt(item.block.templatePadTopMm) +
            documentPdfMmToPt(item.block.templatePadBottomMm);

        typst.writeln(
            '#set page(width: ${cellWPt}pt, height: ${cellHPt}pt, margin: 0pt)');

        final data = await recordToFields(item.record);
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
            for (final record in batch) {
              final data = await recordToFields(record);
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
      recordToFields: (s) => documentFieldValuesForSpecimen(_db, s, ref),
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
      recordToFields: (s) => documentFieldValuesForSite(_db, s, ref),
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
      recordToFields: (s) => documentFieldValuesForCollEvent(_db, s, ref),
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
      recordToFields: (s) => documentFieldValuesForNarrative(_db, s, ref),
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
      final dataList = await _getRecordDataListForBlock(
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
        final cellHPt = hPt +
            documentPdfMmToPt(item.block.templatePadTopMm) +
            documentPdfMmToPt(item.block.templatePadBottomMm);

        typst.writeln(
            '#set page(width: ${cellWPt}pt, height: ${cellHPt}pt, margin: 0pt)');

        final subbedPage = await _substitutePage(item.pageTemplate, item.data);

        _writeSingleDocumentCell(
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
            for (final data in batch) {
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

  Future<List<Map<String, String>>> _getRecordDataListForBlock(
    int bIdx,
    RecordType recordType,
    bool isPreview,
    List<String>? previewRecords,
  ) async {
    final Set<String> selectedIds;
    if (isPreview) {
      selectedIds = (previewRecords ?? const []).toSet();
    } else {
      final param =
          BlockRecordSelectionParam(blockIndex: bIdx, recordType: recordType);
      selectedIds = ref.read(blockRecordSelectionProvider(param));
    }

    final List<Map<String, String>> out = [];

    if (recordType == RecordType.specimenRecord) {
      final specimens = await SpecimenServices(ref: ref).getSpecimenList();
      final filtered = specimens.where((s) => selectedIds.contains(s.uuid));
      for (final s in filtered) {
        out.add(await documentFieldValuesForSpecimen(_db, s, ref));
      }
    } else if (recordType == RecordType.site) {
      final sites = await SiteServices(ref: ref).getAllSites();
      final filtered =
          sites.where((s) => selectedIds.contains(s.id.toString()));
      for (final s in filtered) {
        out.add(await documentFieldValuesForSite(_db, s, ref));
      }
    } else if (recordType == RecordType.collEvent) {
      final events = await CollEventServices(ref: ref).getAllCollEvents();
      final filtered =
          events.where((s) => selectedIds.contains(s.id.toString()));
      for (final s in filtered) {
        out.add(await documentFieldValuesForCollEvent(_db, s, ref));
      }
    } else if (recordType == RecordType.narrative) {
      final narratives = await NarrativeServices(ref: ref).getAllNarrative();
      final filtered =
          narratives.where((s) => selectedIds.contains(s.id.toString()));
      for (final s in filtered) {
        out.add(await documentFieldValuesForNarrative(_db, s, ref));
      }
    }

    return out;
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

  /// Returns the page-break plan used by tiled document rendering.
  ///
  /// This exposes pagination behavior for regression tests without generating a
  /// full Typst document.
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

  /// Returns all page elements sorted by their z-index.
  ///
  /// This mirrors the render order used when writing a template page to Typst.
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
