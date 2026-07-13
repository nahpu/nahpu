part of '../document_writer.dart';

class _DocumentPdfComposer {
  _DocumentPdfComposer({required this.substitutePage})
      : _renderer = const _DocumentTypstRenderer(),
        _continuousPlanner = const _DocumentPdfContinuousPlanner();

  final _DocumentPageSubstitutor substitutePage;
  final _DocumentTypstRenderer _renderer;
  final _DocumentPdfContinuousPlanner _continuousPlanner;

  Future<String> compose({
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
    required _DocumentPdfBuildContext context,
    required List<_DocumentPdfBlockInput> blocks,
  }) async {
    final typst = StringBuffer();
    final hasRecords = blocks.any((block) => block.data.isNotEmpty);
    if (!hasRecords) {
      _writeEmpty(typst, sheetWidthPt, sheetHeightPt);
    } else if (layout.layoutType == 'Continuous') {
      await _writeContinuous(
        typst: typst,
        layout: layout,
        blocks: blocks,
        context: context,
      );
    } else {
      await _writeTiled(
        typst: typst,
        sheetWidthPt: sheetWidthPt,
        sheetHeightPt: sheetHeightPt,
        layout: layout,
        blocks: blocks,
        context: context,
      );
    }
    return typst.toString();
  }

  void _writeEmpty(StringBuffer typst, double widthPt, double heightPt) {
    typst.writeln('#set page(width: ${widthPt}pt, height: ${heightPt}pt)');
    typst.writeln('#align(center + horizon)[No documents]');
  }

  Future<void> _writeContinuous({
    required StringBuffer typst,
    required rust_config.DocumentLayoutPreset layout,
    required List<_DocumentPdfBlockInput> blocks,
    required _DocumentPdfBuildContext context,
  }) async {
    final items = _continuousPlanner.plan(
      blocks: blocks,
      duplex: context.duplex,
      mirrorFront: context.mirrorFront,
      mirrorBack: context.mirrorBack,
      multiBlockMode: layout.multiBlockMode,
    );
    for (final item in items) {
      await _writeContinuousItem(
        typst: typst,
        item: item,
        context: context,
      );
    }
  }

  Future<void> _writeContinuousItem({
    required StringBuffer typst,
    required _DocumentContinuousPrintItem item,
    required _DocumentPdfBuildContext context,
  }) async {
    final block = item.block;
    final cellW = context.wPt +
        documentPdfMmToPt(block.templatePadLeftMm) +
        documentPdfMmToPt(block.templatePadRightMm);
    typst.writeln('#set page(width: ${cellW}pt, height: auto, margin: 0pt)');
    final page = await substitutePage(
      item.pageTemplate,
      item.data,
    );
    _renderer.writeSingleDocumentCell(
      typst: typst,
      page: page,
      data: item.data,
      wPt: context.wPt,
      hPt: context.hPt,
      templatePadTopMm: block.templatePadTopMm,
      templatePadLeftMm: block.templatePadLeftMm,
      templatePadRightMm: block.templatePadRightMm,
      templatePadBottomMm: block.templatePadBottomMm,
      mirror: item.mirror,
      outline: item.template.outline,
      continuous: true,
    );
  }

  Future<void> _writeTiled({
    required StringBuffer typst,
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
    required List<_DocumentPdfBlockInput> blocks,
    required _DocumentPdfBuildContext context,
  }) async {
    _writePageSetup(
      typst: typst,
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
    );
    final usableW = _DocumentPdfLayoutMetrics.usablePageWidthPt(
      sheetWidthPt: sheetWidthPt,
      leftPaddingMm: layout.pagePadLeftMm,
      rightPaddingMm: layout.pagePadRightMm,
    );
    final usableH = _DocumentPdfLayoutMetrics.usablePageHeightPt(
      sheetHeightPt: sheetHeightPt,
      topPaddingMm: layout.pagePadTopMm,
      bottomPaddingMm: layout.pagePadBottomMm,
    );
    final sheets = await _DocumentPdfSheetPlanner(
      substitutePage: substitutePage,
    ).plan(
      layout: layout,
      blocks: blocks,
      context: context,
      usableW: usableW,
      usableH: usableH,
    );
    _writeSheetSequence(typst: typst, sheets: sheets);
  }

  void _writePageSetup({
    required StringBuffer typst,
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
  }) {
    final top = documentPdfMmToPt(layout.pagePadTopMm);
    final left = documentPdfMmToPt(layout.pagePadLeftMm);
    final bottom = documentPdfMmToPt(layout.pagePadBottomMm);
    final right = documentPdfMmToPt(layout.pagePadRightMm);
    typst.writeln(
      '#set page(width: ${sheetWidthPt}pt, height: ${sheetHeightPt}pt, '
      'margin: (top: ${top}pt, left: ${left}pt, bottom: ${bottom}pt, '
      'right: ${right}pt))',
    );
  }

  void _writeSheetSequence({
    required StringBuffer typst,
    required List<_DocumentSheetRenderSpec> sheets,
  }) {
    final pageBreaks = _DocumentPdfSheetPagination.pageBreakPlan(
      [for (final sheet in sheets) sheet.forcePageBreakAfter],
    );
    for (var index = 0; index < sheets.length; index++) {
      final sheet = sheets[index];
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
      if (pageBreaks[index]) {
        typst.writeln('#pagebreak(weak: true)');
      }
    }
  }
}
