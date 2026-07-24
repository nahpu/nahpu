part of '../document_writer.dart';

/// Plans physical sheet sides from template-owned print profiles.
///
/// A simplex template creates only a front-side cell. A duplex template creates
/// a paired front/back unit. Runs are split when their physical side mode or
/// grid geometry changes so a simplex block never receives an empty back page.
class _DocumentPdfSheetPlanner {
  const _DocumentPdfSheetPlanner({required this.substitutePage});

  final _DocumentPageSubstitutor substitutePage;

  Future<List<_DocumentSheetRenderSpec>> plan({
    required rust_config.DocumentLayoutPreset layout,
    required List<_DocumentPdfBlockInput> blocks,
    required double usableW,
    required double usableH,
  }) async {
    if (layout.multiBlockMode == 'Alternate') {
      final entries = <_DocumentPdfCellInput>[];
      final maxLength = blocks.fold<int>(
        0,
        (max, block) => math.max(max, block.data.length),
      );
      for (var index = 0; index < maxLength; index++) {
        for (final block in blocks) {
          if (index < block.data.length) {
            entries.add(
              _DocumentPdfCellInput(block: block, data: block.data[index]),
            );
          }
        }
      }
      return _appendRuns(
        units: await _createUnits(
          entries: entries,
          layout: layout,
          usableH: usableH,
        ),
        usableW: usableW,
        usableH: usableH,
        forceFinalBreak: true,
      );
    }

    final specs = <_DocumentSheetRenderSpec>[];
    for (final block in blocks) {
      final units = await _createUnits(
        entries: [
          for (final data in block.data)
            _DocumentPdfCellInput(block: block, data: data),
        ],
        layout: layout,
        usableH: usableH,
      );
      specs.addAll(
        _appendRuns(
          units: units,
          usableW: usableW,
          usableH: usableH,
          forceFinalBreak: block.block.pageBreakAfter,
        ),
      );
    }
    return specs;
  }

  Future<List<_DocumentPdfPrintUnit>> _createUnits({
    required Iterable<_DocumentPdfCellInput> entries,
    required rust_config.DocumentLayoutPreset layout,
    required double usableH,
  }) async {
    final units = <_DocumentPdfPrintUnit>[];
    for (final entry in entries) {
      final block = entry.block.block;
      final profile = entry.block.profile;
      final autoFill = _usesAutoFill(layout, block);
      final fixedHeight = usableH / block.fixedRows;
      for (var copy = 0; copy < block.templateCount; copy++) {
        final frontPage = await substitutePage(
          entry.block.template.page1,
          entry.data,
        );
        var front = _cell(
          page: frontPage,
          entry: entry,
          height: autoFill
              ? _autoHeight(frontPage, block, profile)
              : fixedHeight,
          mirror: profile.mirrorFront,
          autoFill: autoFill,
        );
        _DocumentSheetCell? back;
        if (profile.duplex) {
          final backPage = await substitutePage(
            entry.block.template.page2,
            entry.data,
          );
          back = _cell(
            page: backPage,
            entry: entry,
            height: autoFill
                ? _autoHeight(backPage, block, profile)
                : fixedHeight,
            mirror: profile.mirrorBack,
            autoFill: autoFill,
          );
          final height = math.max(front.heightPt, back.heightPt);
          front = front.copyWithHeight(height);
          back = back.copyWithHeight(height);
        }
        units.add(_DocumentPdfPrintUnit(front: front, back: back));
      }
    }
    return units;
  }

  _DocumentSheetCell _cell({
    required TemplatePage page,
    required _DocumentPdfCellInput entry,
    required double height,
    required bool mirror,
    required bool autoFill,
  }) {
    final profile = entry.block.profile;
    return _DocumentSheetCell(
      page: page,
      data: entry.data,
      heightPt: height,
      block: entry.block.block,
      outline: entry.block.template.outline,
      mirror: mirror,
      autoHeight: autoFill,
      widthPt: profile.widthPt,
      canvasHeightPt: profile.heightPt,
    );
  }

  double _autoHeight(
    TemplatePage page,
    rust_config.DocumentLayoutBlock block,
    _DocumentTemplateRenderProfile profile,
  ) {
    return _DocumentPdfLayoutMetrics.estimateAutoFillCellHeightPt(
      page: page,
      wPt: profile.widthPt,
      hPt: profile.heightPt,
      templatePadTopMm: block.templatePadTopMm,
      templatePadLeftMm: block.templatePadLeftMm,
      templatePadRightMm: block.templatePadRightMm,
      templatePadBottomMm: block.templatePadBottomMm,
    );
  }

  List<_DocumentSheetRenderSpec> _appendRuns({
    required List<_DocumentPdfPrintUnit> units,
    required double usableW,
    required double usableH,
    required bool forceFinalBreak,
  }) {
    final specs = <_DocumentSheetRenderSpec>[];
    var start = 0;
    while (start < units.length) {
      final first = units[start];
      var end = start + 1;
      while (end < units.length && _sameRun(units[end], first)) {
        end++;
      }
      _appendRunSpecs(
        specs: specs,
        units: units.sublist(start, end),
        usableW: usableW,
        usableH: usableH,
        forceFinalBreak: end < units.length || forceFinalBreak,
      );
      start = end;
    }
    return specs;
  }

  void _appendRunSpecs({
    required List<_DocumentSheetRenderSpec> specs,
    required List<_DocumentPdfPrintUnit> units,
    required double usableW,
    required double usableH,
    required bool forceFinalBreak,
  }) {
    if (units.isEmpty) return;
    final first = units.first.front;
    final cols = first.block.cols > 0 ? first.block.cols : 4;
    final rows = first.block.fixedRows;
    final autoFill = first.autoHeight;
    final frontBatches = _DocumentPdfSheetPagination.batches(
      cells: [for (final unit in units) unit.front],
      cols: cols,
      rows: rows,
      autoFill: autoFill,
      usableH: usableH,
    );
    final duplex = units.first.back != null;
    final backBatches = duplex
        ? _DocumentPdfSheetPagination.batches(
            cells: [for (final unit in units) unit.back!],
            cols: cols,
            rows: rows,
            autoFill: autoFill,
            usableH: usableH,
          )
        : const <_DocumentSheetBatch>[];
    assert(!duplex || frontBatches.length == backBatches.length);
    final cellW = usableW / cols;
    final cellH = usableH / rows;
    for (var index = 0; index < frontBatches.length; index++) {
      final boundaryBreak = index < frontBatches.length - 1 || forceFinalBreak;
      specs.add(
        _spec(
          batch: frontBatches[index],
          cols: cols,
          rows: rows,
          cellW: cellW,
          cellH: cellH,
          autoFill: autoFill,
          forceBreak: duplex || boundaryBreak,
        ),
      );
      if (duplex) {
        specs.add(
          _spec(
            batch: backBatches[index],
            cols: cols,
            rows: rows,
            cellW: cellW,
            cellH: cellH,
            autoFill: autoFill,
            forceBreak: boundaryBreak,
          ),
        );
      }
    }
  }

  static bool _usesAutoFill(
    rust_config.DocumentLayoutPreset layout,
    rust_config.DocumentLayoutBlock block,
  ) => layout.fillPage || block.autoFillPage;

  static bool _sameRun(
    _DocumentPdfPrintUnit candidate,
    _DocumentPdfPrintUnit first,
  ) {
    final cell = candidate.front;
    final firstCell = first.front;
    final cols = cell.block.cols > 0 ? cell.block.cols : 4;
    final firstCols = firstCell.block.cols > 0 ? firstCell.block.cols : 4;
    return (candidate.back != null) == (first.back != null) &&
        cols == firstCols &&
        cell.block.fixedRows == firstCell.block.fixedRows &&
        cell.autoHeight == firstCell.autoHeight;
  }

  static _DocumentSheetRenderSpec _spec({
    required _DocumentSheetBatch batch,
    required int cols,
    required int rows,
    required double cellW,
    required double cellH,
    required bool autoFill,
    required bool forceBreak,
  }) => _DocumentSheetRenderSpec(
    cells: batch.cells,
    cols: cols,
    rows: rows,
    cellW: cellW,
    cellH: cellH,
    autoFill: autoFill,
    forcePageBreakAfter: forceBreak,
  );
}

class _DocumentPdfCellInput {
  const _DocumentPdfCellInput({required this.block, required this.data});

  final _DocumentPdfBlockInput block;
  final Map<String, String> data;
}

class _DocumentPdfPrintUnit {
  const _DocumentPdfPrintUnit({required this.front, required this.back});

  final _DocumentSheetCell front;
  final _DocumentSheetCell? back;
}
