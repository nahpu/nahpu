part of '../document_writer.dart';

/// Pure sheet batching and page-break decisions shared by rendering and tests.
class _DocumentPdfSheetPagination {
  const _DocumentPdfSheetPagination._();

  static List<bool> pageBreakPlan(
    List<bool> forcePageBreakAfter,
  ) {
    if (forcePageBreakAfter.isEmpty) return const [];
    return List<bool>.generate(
      forcePageBreakAfter.length,
      (index) =>
          index < forcePageBreakAfter.length - 1 && forcePageBreakAfter[index],
      growable: false,
    );
  }

  static List<_DocumentSheetBatch> batches({
    required List<_DocumentSheetCell> cells,
    required int cols,
    required int rows,
    required bool autoFill,
    required double usableH,
  }) {
    if (cells.isEmpty) return const [];
    if (!autoFill) return _fixedGridBatches(cells, cols * rows);
    return _autoFillBatches(cells, cols, usableH);
  }

  static List<_DocumentSheetBatch> _fixedGridBatches(
    List<_DocumentSheetCell> cells,
    int cellsPerSheet,
  ) {
    final safeCellsPerSheet = math.max(1, cellsPerSheet);
    return [
      for (var start = 0; start < cells.length; start += safeCellsPerSheet)
        _DocumentSheetBatch(
          cells: cells.sublist(
            start,
            math.min(start + safeCellsPerSheet, cells.length),
          ),
        ),
    ];
  }

  static List<_DocumentSheetBatch> _autoFillBatches(
    List<_DocumentSheetCell> cells,
    int cols,
    double usableH,
  ) {
    final rows = _rows(cells, cols);
    final batches = <_DocumentSheetBatch>[];
    var rowIndex = 0;
    while (rowIndex < rows.length) {
      final sheetRows = <_DocumentSheetRow>[];
      var usedHeight = 0.0;
      while (rowIndex < rows.length) {
        final row = rows[rowIndex];
        if (sheetRows.isNotEmpty && usedHeight + row.heightPt > usableH) {
          break;
        }
        sheetRows.add(row);
        usedHeight += row.heightPt;
        rowIndex++;
      }
      _fillWithShortestRow(sheetRows, usedHeight, usableH);
      batches.add(
        _DocumentSheetBatch(
          cells: sheetRows.expand((row) => row.cells).toList(),
        ),
      );
    }
    return batches;
  }

  static List<_DocumentSheetRow> _rows(
    List<_DocumentSheetCell> cells,
    int cols,
  ) {
    final safeCols = math.max(1, cols);
    return [
      for (var start = 0; start < cells.length; start += safeCols)
        _DocumentSheetRow(
          cells.sublist(start, math.min(start + safeCols, cells.length)),
        ),
    ];
  }

  static void _fillWithShortestRow(
    List<_DocumentSheetRow> rows,
    double usedHeight,
    double usableH,
  ) {
    final shortest = rows.reduce(
      (a, b) => a.heightPt <= b.heightPt ? a : b,
    );
    final repeats = _DocumentPdfLayoutMetrics.maxAutoFillRepeatCount(
      rowHeight: shortest.heightPt,
      usedHeight: usedHeight,
      usableHeight: usableH,
    );
    rows.addAll(List.filled(repeats, shortest));
  }
}
