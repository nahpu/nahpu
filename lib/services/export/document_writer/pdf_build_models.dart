part of '../document_writer.dart';

typedef _DocumentPageSubstitutor =
    Future<TemplatePage> Function(TemplatePage page, Map<String, String> data);

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

  _DocumentTemplateRenderProfile get profile =>
      _DocumentTemplateRenderProfile.fromTemplate(template);
}

/// Physical canvas and side settings stored with a template.
///
/// PDF output must be independent of the template most recently opened in the
/// editor, so legacy templates resolve to a deterministic simplex profile.
class _DocumentTemplateRenderProfile {
  const _DocumentTemplateRenderProfile({
    required this.widthPt,
    required this.heightPt,
    required this.duplex,
    required this.mirrorFront,
    required this.mirrorBack,
  });

  factory _DocumentTemplateRenderProfile.fromTemplate(Template template) {
    final options = template.printOptions;
    return _DocumentTemplateRenderProfile(
      widthPt: documentPdfMmToPt(template.widthMm),
      heightPt: documentPdfMmToPt(template.heightMm),
      duplex: options?.isDuplex ?? false,
      mirrorFront: options?.mirrorFront ?? false,
      mirrorBack: options?.mirrorBack ?? false,
    );
  }

  final double widthPt;
  final double heightPt;
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
    required this.autoFill,
    required this.forcePageBreakAfter,
  });

  final List<_DocumentSheetCell> cells;
  final int cols;
  final int rows;
  final double cellW;
  final double cellH;
  final bool autoFill;
  final bool forcePageBreakAfter;
}

class _DocumentSheetRow {
  const _DocumentSheetRow(this.cells);

  final List<_DocumentSheetCell> cells;

  double get heightPt =>
      cells.fold<double>(0, (height, cell) => math.max(height, cell.heightPt));
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
    required this.widthPt,
    required this.canvasHeightPt,
  });

  final TemplatePage page;
  final Map<String, String> data;
  final double heightPt;
  final rust_config.DocumentLayoutBlock block;
  final TemplateOutline? outline;
  final bool mirror;
  final bool autoHeight;
  final double widthPt;
  final double canvasHeightPt;

  _DocumentSheetCell copyWithHeight(double maxH) {
    return _DocumentSheetCell(
      page: page,
      data: data,
      heightPt: maxH,
      block: block,
      outline: outline,
      mirror: mirror,
      autoHeight: autoHeight,
      widthPt: widthPt,
      canvasHeightPt: canvasHeightPt,
    );
  }
}
