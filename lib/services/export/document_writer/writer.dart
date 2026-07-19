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

  _DocumentPdfBuilder get _pdfBuilder => _DocumentPdfBuilder(ref: ref, db: _db);

  Future<File> _writePdf({
    required Directory selectedDir,
    required String fileStem,
    required rust_config.DocumentLayoutPreset layout,
    required Future<Uint8List> Function(
      double sheetWidthPt,
      double sheetHeightPt,
    )
    generatePdf,
  }) async {
    final page = _DocumentPageGeometry.fromLayout(layout);
    final pdfBytes = await generatePdf(page.widthPt, page.heightPt);
    final savePath = await AppIOServices(
      dir: selectedDir,
      fileStem: fileStem,
      ext: 'pdf',
    ).getSavePath();
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
  }) {
    return _writePdf(
      selectedDir: selectedDir,
      fileStem: fileStem,
      layout: layout,
      generatePdf: (w, h) =>
          generateLayoutPdf(sheetWidthPt: w, sheetHeightPt: h, layout: layout),
    );
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
    return _writePdf(
      selectedDir: selectedDir,
      fileStem: fileStem,
      layout: layout,
      generatePdf: (w, h) => generateDocumentsPdf(
        picked,
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
    return _writePdf(
      selectedDir: selectedDir,
      fileStem: fileStem,
      layout: layout,
      generatePdf: (w, h) => generateSitesPdf(
        picked,
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
    return _writePdf(
      selectedDir: selectedDir,
      fileStem: fileStem,
      layout: layout,
      generatePdf: (w, h) => generateEventsPdf(
        picked,
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
    return _writePdf(
      selectedDir: selectedDir,
      fileStem: fileStem,
      layout: layout,
      generatePdf: (w, h) => generateNarrativesPdf(
        picked,
        sheetWidthPt: w,
        sheetHeightPt: h,
        layout: layout,
      ),
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
    return _pdfBuilder.generateDocumentsPdf(
      specimens,
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
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
    return _pdfBuilder.generateSitesPdf(
      sites,
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
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
    return _pdfBuilder.generateEventsPdf(
      events,
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
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
    return _pdfBuilder.generateNarrativesPdf(
      narratives,
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
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
  }) {
    return _pdfBuilder.generateLayoutPdf(
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
      isPreview: isPreview,
      previewRecords: previewRecords,
    );
  }

  /// Returns the production page-break flags for rendered sheets.
  @visibleForTesting
  static List<bool> sheetPageBreakPlanForTesting({
    required List<bool> forcePageBreakAfter,
  }) {
    return _DocumentPdfSheetPagination.pageBreakPlan(forcePageBreakAfter);
  }

  /// Returns all page elements sorted by their z-index.
  ///
  /// This mirrors the render order used when writing a template page to Typst.
  @visibleForTesting
  static List<dynamic> sortElementsForTesting(TemplatePage page) {
    return _DocumentTypstRenderer.sortElements(page);
  }

  @visibleForTesting
  static String renderSingleDocumentCellTypstForTesting({
    required TemplatePage page,
    required double wPt,
    required double hPt,
    Map<String, String> data = const {},
  }) {
    final typst = StringBuffer();
    const _DocumentTypstRenderer().writeSingleDocumentCell(
      typst: typst,
      page: page,
      data: data,
      wPt: wPt,
      hPt: hPt,
      templatePadTopMm: 0,
      templatePadLeftMm: 0,
      templatePadRightMm: 0,
      templatePadBottomMm: 0,
      mirror: false,
    );
    return typst.toString();
  }

  @visibleForTesting
  static double estimateTemplatePageContentHeightPtForTesting({
    required TemplatePage page,
    required double wPt,
    required double hPt,
  }) {
    return _DocumentPdfLayoutMetrics.estimateTemplatePageContentHeightPt(
      page: page,
      wPt: wPt,
      hPt: hPt,
    );
  }

  @visibleForTesting
  static double estimateAutoFillCellHeightPtForTesting({
    required TemplatePage page,
    required double wPt,
    required double hPt,
    required double templatePadTopMm,
    required double templatePadLeftMm,
    required double templatePadRightMm,
    required double templatePadBottomMm,
  }) {
    return _DocumentPdfLayoutMetrics.estimateAutoFillCellHeightPt(
      page: page,
      wPt: wPt,
      hPt: hPt,
      templatePadTopMm: templatePadTopMm,
      templatePadLeftMm: templatePadLeftMm,
      templatePadRightMm: templatePadRightMm,
      templatePadBottomMm: templatePadBottomMm,
    );
  }

  @visibleForTesting
  static int maxAutoFillRepeatCountForTesting({
    required double rowHeight,
    required double usedHeight,
    required double usableHeight,
  }) {
    return _DocumentPdfLayoutMetrics.maxAutoFillRepeatCount(
      rowHeight: rowHeight,
      usedHeight: usedHeight,
      usableHeight: usableHeight,
    );
  }

  @visibleForTesting
  static double usablePageHeightPtForTesting({
    required double sheetHeightPt,
    required double topPaddingMm,
    required double bottomPaddingMm,
  }) {
    return _DocumentPdfLayoutMetrics.usablePageHeightPt(
      sheetHeightPt: sheetHeightPt,
      topPaddingMm: topPaddingMm,
      bottomPaddingMm: bottomPaddingMm,
    );
  }

  /// Plans sheets with an identity page substitutor for regression tests.
  ///
  /// The optional side arguments emulate saved template print options for
  /// existing callers. Production planning always reads those options from the
  /// template attached to each block.
  @visibleForTesting
  static Future<
    List<
      ({
        List<Map<String, String>> cellData,
        List<bool> mirrors,
        List<double> canvasWidths,
        List<double> canvasHeights,
        bool autoFill,
        bool forcePageBreakAfter,
      })
    >
  >
  planDocumentSheetsForTesting({
    required rust_config.DocumentLayoutPreset layout,
    required List<Template> templates,
    required List<List<Map<String, String>>> dataByBlock,
    bool? duplex,
    bool? mirrorFront,
    bool? mirrorBack,
    double documentWidthPt = 100,
    double documentHeightPt = 100,
    bool useTemplateDimensions = false,
    double usableWidthPt = 200,
    double usableHeightPt = 200,
  }) async {
    if (templates.length != layout.blocks.length ||
        dataByBlock.length != layout.blocks.length) {
      throw ArgumentError(
        'Templates and dataByBlock must each match the layout block count.',
      );
    }
    final testTemplates = [
      for (final template in templates)
        template.copyWith(
          printOptions:
              duplex == null && mirrorFront == null && mirrorBack == null
              ? template.printOptions
              : TemplatePrintOptions(
                  isDuplex: duplex ?? template.printOptions?.isDuplex ?? false,
                  mirrorFront:
                      mirrorFront ??
                      template.printOptions?.mirrorFront ??
                      false,
                  mirrorBack:
                      mirrorBack ?? template.printOptions?.mirrorBack ?? false,
                ),
          widthMm: useTemplateDimensions
              ? template.widthMm
              : documentWidthPt * 25.4 / 72,
          heightMm: useTemplateDimensions
              ? template.heightMm
              : documentHeightPt * 25.4 / 72,
        ),
    ];
    final blocks = [
      for (var index = 0; index < layout.blocks.length; index++)
        _DocumentPdfBlockInput(
          block: layout.blocks[index],
          template: testTemplates[index],
          data: dataByBlock[index],
        ),
    ];
    final sheets =
        await _DocumentPdfSheetPlanner(
          substitutePage: (page, _) async => page,
        ).plan(
          layout: layout,
          blocks: blocks,
          usableW: usableWidthPt,
          usableH: usableHeightPt,
        );
    return [
      for (final sheet in sheets)
        (
          cellData: [for (final cell in sheet.cells) cell.data],
          mirrors: [for (final cell in sheet.cells) cell.mirror],
          canvasWidths: [for (final cell in sheet.cells) cell.widthPt],
          canvasHeights: [for (final cell in sheet.cells) cell.canvasHeightPt],
          autoFill: sheet.autoFill,
          forcePageBreakAfter: sheet.forcePageBreakAfter,
        ),
    ];
  }

  /// Plans continuous items without page substitution for regression tests.
  @visibleForTesting
  static List<({Map<String, String> data, bool mirror})>
  planContinuousItemsForTesting({
    required rust_config.DocumentLayoutPreset layout,
    required List<Template> templates,
    required List<List<Map<String, String>>> dataByBlock,
    bool? duplex,
    bool? mirrorFront,
    bool? mirrorBack,
  }) {
    if (templates.length != layout.blocks.length ||
        dataByBlock.length != layout.blocks.length) {
      throw ArgumentError(
        'Templates and dataByBlock must each match the layout block count.',
      );
    }
    final testTemplates = [
      for (final template in templates)
        template.copyWith(
          printOptions:
              duplex == null && mirrorFront == null && mirrorBack == null
              ? template.printOptions
              : TemplatePrintOptions(
                  isDuplex: duplex ?? template.printOptions?.isDuplex ?? false,
                  mirrorFront:
                      mirrorFront ??
                      template.printOptions?.mirrorFront ??
                      false,
                  mirrorBack:
                      mirrorBack ?? template.printOptions?.mirrorBack ?? false,
                ),
        ),
    ];
    final blocks = [
      for (var index = 0; index < layout.blocks.length; index++)
        _DocumentPdfBlockInput(
          block: layout.blocks[index],
          template: testTemplates[index],
          data: dataByBlock[index],
        ),
    ];
    return const _DocumentPdfContinuousPlanner()
        .plan(blocks: blocks, multiBlockMode: layout.multiBlockMode)
        .map((item) => (data: item.data, mirror: item.mirror))
        .toList(growable: false);
  }
}
