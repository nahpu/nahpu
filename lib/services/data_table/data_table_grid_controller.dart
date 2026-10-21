import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// A cell position on the current page.
typedef DataTableCellPos = ({int row, int col});

/// The rectangle between two cells, inclusive.
class DataTableSelection {
  const DataTableSelection(this.top, this.left, this.bottom, this.right);

  final int top;
  final int left;
  final int bottom;
  final int right;

  bool contains(int row, int col) =>
      row >= top && row <= bottom && col >= left && col <= right;

  bool get isSingleCell => top == bottom && left == right;
}

/// Spreadsheet-style focus and selection for the data table grid.
///
/// Pure state with no widgets, so keyboard behavior is unit-testable. The
/// focused cell moves; the anchor stays put while a selection is extended.
class DataTableGridController extends ChangeNotifier {
  int _rows = 0;
  int _cols = 0;
  DataTableCellPos _focus = (row: 0, col: 0);
  DataTableCellPos _anchor = (row: 0, col: 0);
  DataTableCellPos? _editing;
  String? _editSeed;

  int get rowCount => _rows;
  int get columnCount => _cols;
  DataTableCellPos get focus => _focus;
  DataTableCellPos get anchor => _anchor;

  /// The cell being edited, if any.
  DataTableCellPos? get editing => _editing;

  /// Text that started the edit, such as a typed character, replacing the
  /// cell's value. Null when the edit keeps the value (F2, double-click).
  String? get editSeed => _editSeed;
  bool get isEditing => _editing != null;
  bool get hasCells => _rows > 0 && _cols > 0;

  DataTableSelection get selection => DataTableSelection(
    math.min(_focus.row, _anchor.row),
    math.min(_focus.col, _anchor.col),
    math.max(_focus.row, _anchor.row),
    math.max(_focus.col, _anchor.col),
  );

  /// Updates the grid size, keeping focus inside it.
  void setSize(int rows, int cols) {
    if (rows == _rows && cols == _cols) return;
    _rows = rows;
    _cols = cols;
    _focus = _clamp(_focus);
    _anchor = _clamp(_anchor);
    if (_editing != null && !_inside(_editing!)) _editing = null;
    notifyListeners();
  }

  void moveTo(int row, int col, {bool extend = false}) {
    if (!hasCells) return;
    _focus = _clamp((row: row, col: col));
    if (!extend) _anchor = _focus;
    notifyListeners();
  }

  void move(int dRow, int dCol, {bool extend = false}) =>
      moveTo(_focus.row + dRow, _focus.col + dCol, extend: extend);

  /// Tab and Shift+Tab: move along the row, wrapping to the next or
  /// previous row at its end.
  void tab({bool backward = false}) {
    if (!hasCells) return;
    var row = _focus.row;
    var col = _focus.col + (backward ? -1 : 1);
    if (col >= _cols) {
      col = 0;
      row = math.min(row + 1, _rows - 1);
    } else if (col < 0) {
      col = _cols - 1;
      row = math.max(row - 1, 0);
    }
    moveTo(row, col);
  }

  /// Ctrl or Cmd plus an arrow: jump to the edge of the page in that
  /// direction.
  void toEdge(int dRow, int dCol, {bool extend = false}) => moveTo(
    dRow == 0 ? _focus.row : (dRow < 0 ? 0 : _rows - 1),
    dCol == 0 ? _focus.col : (dCol < 0 ? 0 : _cols - 1),
    extend: extend,
  );

  void rowStart({bool extend = false}) => moveTo(_focus.row, 0, extend: extend);

  void rowEnd({bool extend = false}) =>
      moveTo(_focus.row, _cols - 1, extend: extend);

  void pageStart({bool extend = false}) => moveTo(0, 0, extend: extend);

  void pageEnd({bool extend = false}) =>
      moveTo(_rows - 1, _cols - 1, extend: extend);

  void selectAll() {
    if (!hasCells) return;
    _anchor = (row: 0, col: 0);
    _focus = (row: _rows - 1, col: _cols - 1);
    notifyListeners();
  }

  /// Collapses the selection to the focused cell.
  void collapse() {
    if (_anchor == _focus) return;
    _anchor = _focus;
    notifyListeners();
  }

  void beginEdit({String? seed}) {
    if (!hasCells) return;
    _anchor = _focus;
    _editing = _focus;
    _editSeed = seed;
    notifyListeners();
  }

  void endEdit() {
    if (_editing == null) return;
    _editing = null;
    _editSeed = null;
    notifyListeners();
  }

  bool _inside(DataTableCellPos pos) =>
      pos.row >= 0 && pos.row < _rows && pos.col >= 0 && pos.col < _cols;

  DataTableCellPos _clamp(DataTableCellPos pos) => (
    row: _rows == 0 ? 0 : pos.row.clamp(0, _rows - 1),
    col: _cols == 0 ? 0 : pos.col.clamp(0, _cols - 1),
  );
}
