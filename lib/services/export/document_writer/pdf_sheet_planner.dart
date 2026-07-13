part of '../document_writer.dart';

class _DocumentPdfSheetPlanner {
  const _DocumentPdfSheetPlanner({required this.substitutePage});

  final _DocumentPageSubstitutor substitutePage;

  Future<List<_DocumentSheetRenderSpec>> plan({
    required rust_config.DocumentLayoutPreset layout,
    required List<_DocumentPdfBlockInput> blocks,
    required _DocumentPdfBuildContext context,
    required double usableW,
    required double usableH,
  }) async {
    if (layout.multiBlockMode == 'Alternate') {
      return _planAlternate(
        layout: layout,
        blocks: blocks,
        context: context,
        usableW: usableW,
        usableH: usableH,
      );
    }
    return _planGrouped(
      layout: layout,
      blocks: blocks,
      context: context,
      usableW: usableW,
      usableH: usableH,
    );
  }

  Future<List<_DocumentSheetRenderSpec>> _planAlternate({
    required rust_config.DocumentLayoutPreset layout,
    required List<_DocumentPdfBlockInput> blocks,
    required _DocumentPdfBuildContext context,
    required double usableW,
    required double usableH,
  }) async {
    final entries = <_DocumentPdfCellInput>[];
    final maxLength = blocks.fold<int>(
      0,
      (max, block) => math.max(max, block.data.length),
    );
    for (var index = 0; index < maxLength; index++) {
      for (final block in blocks) {
        if (index >= block.data.length) continue;
        entries.add(
          _DocumentPdfCellInput(block: block, data: block.data[index]),
        );
      }
    }

    final cells = _equalizeDuplexHeights(
        await _createCells(
          entries: entries,
          layout: layout,
          context: context,
          usableH: usableH,
        ),
        context.duplex);
    final frontCells = cells.front;
    final backCells = cells.back;
    return _appendAlternatingSpecs(
      frontCells: frontCells,
      backCells: backCells,
      context: context,
      usableW: usableW,
      usableH: usableH,
    );
  }

  Future<List<_DocumentSheetRenderSpec>> _planGrouped({
    required rust_config.DocumentLayoutPreset layout,
    required List<_DocumentPdfBlockInput> blocks,
    required _DocumentPdfBuildContext context,
    required double usableW,
    required double usableH,
  }) async {
    final specs = <_DocumentSheetRenderSpec>[];
    for (final block in blocks) {
      final entries = [
        for (final data in block.data)
          _DocumentPdfCellInput(block: block, data: data),
      ];
      final cells = _equalizeDuplexHeights(
          await _createCells(
            entries: entries,
            layout: layout,
            context: context,
            usableH: usableH,
          ),
          context.duplex);
      _appendGroupedSpecs(
        specs: specs,
        block: block.block,
        frontCells: cells.front,
        backCells: cells.back,
        context: context,
        usableW: usableW,
        usableH: usableH,
      );
    }
    return specs;
  }

  Future<_DocumentPdfCellPair> _createCells({
    required Iterable<_DocumentPdfCellInput> entries,
    required rust_config.DocumentLayoutPreset layout,
    required _DocumentPdfBuildContext context,
    required double usableH,
  }) async {
    final front = <_DocumentSheetCell>[];
    final back = <_DocumentSheetCell>[];
    for (final entry in entries) {
      final block = entry.block.block;
      final autoFill = _usesAutoFill(layout, block);
      final rows = block.fixedRows;
      final fixedHeight = usableH / rows;
      for (var copy = 0; copy < block.templateCount; copy++) {
        final frontPage = await substitutePage(
          entry.block.template.page1,
          entry.data,
        );
        front.add(
          _cell(
            page: frontPage,
            entry: entry,
            height: autoFill
                ? _autoHeight(frontPage, entry.block.block, context)
                : fixedHeight,
            mirror: context.mirrorFront,
            autoFill: autoFill,
          ),
        );
        if (!context.duplex) continue;
        final backPage = await substitutePage(
          entry.block.template.page2,
          entry.data,
        );
        back.add(
          _cell(
            page: backPage,
            entry: entry,
            height: autoFill
                ? _autoHeight(backPage, entry.block.block, context)
                : fixedHeight,
            mirror: context.mirrorBack,
            autoFill: autoFill,
          ),
        );
      }
    }
    return _DocumentPdfCellPair(front: front, back: back);
  }

  _DocumentSheetCell _cell({
    required TemplatePage page,
    required _DocumentPdfCellInput entry,
    required double height,
    required bool mirror,
    required bool autoFill,
  }) {
    return _DocumentSheetCell(
      page: page,
      data: entry.data,
      heightPt: height,
      block: entry.block.block,
      outline: entry.block.template.outline,
      mirror: mirror,
      autoHeight: autoFill,
    );
  }

  double _autoHeight(
    TemplatePage page,
    rust_config.DocumentLayoutBlock block,
    _DocumentPdfBuildContext context,
  ) {
    return _DocumentPdfLayoutMetrics.estimateAutoFillCellHeightPt(
      page: page,
      wPt: context.wPt,
      hPt: context.hPt,
      templatePadTopMm: block.templatePadTopMm,
      templatePadLeftMm: block.templatePadLeftMm,
      templatePadRightMm: block.templatePadRightMm,
      templatePadBottomMm: block.templatePadBottomMm,
    );
  }

  static bool _usesAutoFill(
    rust_config.DocumentLayoutPreset layout,
    rust_config.DocumentLayoutBlock block,
  ) {
    return layout.fillPage || block.autoFillPage;
  }

  static _DocumentPdfCellPair _equalizeDuplexHeights(
    _DocumentPdfCellPair cells,
    bool duplex,
  ) {
    if (!duplex) return cells;
    assert(cells.front.length == cells.back.length);
    final front = <_DocumentSheetCell>[];
    final back = <_DocumentSheetCell>[];
    for (var index = 0; index < cells.front.length; index++) {
      final height = math.max(
        cells.front[index].heightPt,
        cells.back[index].heightPt,
      );
      front.add(cells.front[index].copyWithHeight(height));
      back.add(cells.back[index].copyWithHeight(height));
    }
    return _DocumentPdfCellPair(front: front, back: back);
  }

  void _appendGroupedSpecs({
    required List<_DocumentSheetRenderSpec> specs,
    required rust_config.DocumentLayoutBlock block,
    required List<_DocumentSheetCell> frontCells,
    required List<_DocumentSheetCell> backCells,
    required _DocumentPdfBuildContext context,
    required double usableW,
    required double usableH,
  }) {
    final cols = block.cols > 0 ? block.cols : 4;
    final rows = block.fixedRows;
    final autoFill = frontCells.any((cell) => cell.autoHeight);
    final batches = _DocumentPdfSheetPagination.batches(
      cells: frontCells,
      cols: cols,
      rows: rows,
      autoFill: autoFill,
      usableH: usableH,
    );
    final backBatches = context.duplex
        ? _DocumentPdfSheetPagination.batches(
            cells: backCells,
            cols: cols,
            rows: rows,
            autoFill: autoFill,
            usableH: usableH,
          )
        : const <_DocumentSheetBatch>[];
    final cellW = usableW / cols;
    final cellH = usableH / rows;
    for (var index = 0; index < batches.length; index++) {
      final isLast = index == batches.length - 1;
      final boundaryBreak = !isLast || block.pageBreakAfter;
      specs.add(
        _spec(
          batch: batches[index],
          cols: cols,
          rows: rows,
          cellW: cellW,
          cellH: cellH,
          context: context,
          autoFill: autoFill,
          forceBreak: context.duplex || boundaryBreak,
        ),
      );
      if (context.duplex) {
        specs.add(
          _spec(
            batch: backBatches[index],
            cols: cols,
            rows: rows,
            cellW: cellW,
            cellH: cellH,
            context: context,
            autoFill: autoFill,
            forceBreak: boundaryBreak,
          ),
        );
      }
    }
  }

  List<_DocumentSheetRenderSpec> _appendAlternatingSpecs({
    required List<_DocumentSheetCell> frontCells,
    required List<_DocumentSheetCell> backCells,
    required _DocumentPdfBuildContext context,
    required double usableW,
    required double usableH,
  }) {
    final specs = <_DocumentSheetRenderSpec>[];
    var start = 0;
    while (start < frontCells.length) {
      final first = frontCells[start];
      final cols = first.block.cols > 0 ? first.block.cols : 4;
      final rows = first.block.fixedRows;
      final autoFill = first.autoHeight;
      var end = start + 1;
      while (end < frontCells.length &&
          _sameGeometry(frontCells[end], cols, rows, autoFill)) {
        end++;
      }
      final frontBatches = _DocumentPdfSheetPagination.batches(
        cells: frontCells.sublist(start, end),
        cols: cols,
        rows: rows,
        autoFill: autoFill,
        usableH: usableH,
      );
      final backBatches = context.duplex
          ? _DocumentPdfSheetPagination.batches(
              cells: backCells.sublist(start, end),
              cols: cols,
              rows: rows,
              autoFill: autoFill,
              usableH: usableH,
            )
          : const <_DocumentSheetBatch>[];
      for (var index = 0; index < frontBatches.length; index++) {
        final cellW = usableW / cols;
        final cellH = usableH / rows;
        specs.add(
          _spec(
            batch: frontBatches[index],
            cols: cols,
            rows: rows,
            cellW: cellW,
            cellH: cellH,
            context: context,
            autoFill: autoFill,
            forceBreak: true,
          ),
        );
        if (context.duplex) {
          specs.add(
            _spec(
              batch: backBatches[index],
              cols: cols,
              rows: rows,
              cellW: cellW,
              cellH: cellH,
              context: context,
              autoFill: autoFill,
              forceBreak: true,
            ),
          );
        }
      }
      start = end;
    }
    return specs;
  }

  static bool _sameGeometry(
    _DocumentSheetCell cell,
    int cols,
    int rows,
    bool autoFill,
  ) {
    final cellCols = cell.block.cols > 0 ? cell.block.cols : 4;
    return cellCols == cols &&
        cell.block.fixedRows == rows &&
        cell.autoHeight == autoFill;
  }

  static _DocumentSheetRenderSpec _spec({
    required _DocumentSheetBatch batch,
    required int cols,
    required int rows,
    required double cellW,
    required double cellH,
    required _DocumentPdfBuildContext context,
    required bool autoFill,
    required bool forceBreak,
  }) {
    return _DocumentSheetRenderSpec(
      cells: batch.cells,
      cols: cols,
      rows: rows,
      cellW: cellW,
      cellH: cellH,
      wPt: context.wPt,
      hPt: context.hPt,
      autoFill: autoFill,
      forcePageBreakAfter: forceBreak,
    );
  }
}

class _DocumentPdfCellInput {
  const _DocumentPdfCellInput({required this.block, required this.data});

  final _DocumentPdfBlockInput block;
  final Map<String, String> data;
}

class _DocumentPdfCellPair {
  const _DocumentPdfCellPair({required this.front, required this.back});

  final List<_DocumentSheetCell> front;
  final List<_DocumentSheetCell> back;
}
