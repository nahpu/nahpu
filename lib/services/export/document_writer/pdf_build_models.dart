part of '../document_writer.dart';

typedef _DocumentPageSubstitutor = Future<TemplatePage> Function(
  TemplatePage page,
  Map<String, String> data,
);

/// Inputs shared by the typed-record and mixed-record PDF entry points.
class _DocumentPdfBlockInput {
  const _DocumentPdfBlockInput({
    required this.block,
    required this.template,
    required this.data,
  });

  final rust_config.DocumentLayoutBlock block;
  final Template template;
  final List<Map<String, String>> data;
}

class _DocumentPdfBuildContext {
  const _DocumentPdfBuildContext({
    required this.wPt,
    required this.hPt,
    required this.duplex,
    required this.mirrorFront,
    required this.mirrorBack,
  });

  final double wPt;
  final double hPt;
  final bool duplex;
  final bool mirrorFront;
  final bool mirrorBack;
}

class _DocumentSheetBatch {
  const _DocumentSheetBatch({required this.cells});

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
