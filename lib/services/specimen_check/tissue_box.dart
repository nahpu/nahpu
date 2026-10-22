/// The tube capacity of a tissue box. Each box is a square grid.
enum TissueBoxSize {
  cells81(9),
  cells100(10);

  const TissueBoxSize(this.side);

  /// The number of rows, which equals the number of columns.
  final int side;

  int get capacity => side * side;

  String get label => '$capacity ($side×$side)';
}

/// How cells are named in the storage location.
enum TissueCellNumbering {
  alphanumeric('A1, A2, A3…'),
  sequential('1, 2, 3…'),
  rowColumn('1-1, 1-2, 1-3…');

  const TissueCellNumbering(this.label);

  final String label;
}

/// The order in which tubes fill a box.
enum TissueFillOrder {
  rowMajor('Rows, left to right'),
  columnMajor('Columns, top to bottom'),
  serpentine('Serpentine rows');

  const TissueFillOrder(this.label);

  final String label;
}

/// A zero-based cell position in a tissue box.
class TissueCell {
  const TissueCell(this.row, this.column);

  final int row;
  final int column;

  @override
  bool operator ==(Object other) =>
      other is TissueCell && other.row == row && other.column == column;

  @override
  int get hashCode => Object.hash(row, column);

  @override
  String toString() => 'TissueCell($row, $column)';
}

/// The shape, numbering, and fill order of a tissue box.
class TissueBoxLayout {
  const TissueBoxLayout({
    this.size = TissueBoxSize.cells81,
    this.numbering = TissueCellNumbering.alphanumeric,
    this.fillOrder = TissueFillOrder.rowMajor,
  });

  static const _rowLetters = 'ABCDEFGHIJ';

  final TissueBoxSize size;
  final TissueCellNumbering numbering;
  final TissueFillOrder fillOrder;

  int get side => size.side;

  /// Every cell in the order tubes go into the box.
  List<TissueCell> get orderedCells {
    final cells = <TissueCell>[];
    for (var outer = 0; outer < side; outer++) {
      for (var inner = 0; inner < side; inner++) {
        cells.add(switch (fillOrder) {
          TissueFillOrder.rowMajor => TissueCell(outer, inner),
          TissueFillOrder.columnMajor => TissueCell(inner, outer),
          TissueFillOrder.serpentine => TissueCell(
            outer,
            outer.isOdd ? side - 1 - inner : inner,
          ),
        });
      }
    }
    return cells;
  }

  /// The zero-based fill position of [cell].
  int indexOf(TissueCell cell) => switch (fillOrder) {
    TissueFillOrder.rowMajor => cell.row * side + cell.column,
    TissueFillOrder.columnMajor => cell.column * side + cell.row,
    TissueFillOrder.serpentine =>
      cell.row * side + (cell.row.isOdd ? side - 1 - cell.column : cell.column),
  };

  bool contains(TissueCell cell) =>
      cell.row >= 0 &&
      cell.row < side &&
      cell.column >= 0 &&
      cell.column < side;

  String rowLabel(int row) => numbering == TissueCellNumbering.alphanumeric
      ? _rowLetters[row]
      : '${row + 1}';

  String columnLabel(int column) => '${column + 1}';

  String cellLabel(TissueCell cell) => switch (numbering) {
    TissueCellNumbering.alphanumeric =>
      '${rowLabel(cell.row)}${columnLabel(cell.column)}',
    TissueCellNumbering.sequential => '${indexOf(cell) + 1}',
    TissueCellNumbering.rowColumn => '${cell.row + 1}-${cell.column + 1}',
  };

  /// Reads a label written by [cellLabel]. Returns null for anything else.
  TissueCell? parseCellLabel(String label) {
    final text = label.trim().toUpperCase();
    final cell = switch (numbering) {
      TissueCellNumbering.alphanumeric => _parseAlphanumeric(text),
      TissueCellNumbering.sequential => _parseSequential(text),
      TissueCellNumbering.rowColumn => _parseRowColumn(text),
    };
    return cell != null && contains(cell) ? cell : null;
  }

  /// The first cell not in [occupied], starting at [from] in fill order.
  TissueCell? firstFree(Set<TissueCell> occupied, {TissueCell? from}) {
    final cells = orderedCells;
    final start = from == null ? 0 : indexOf(from);
    for (var i = start; i < cells.length; i++) {
      if (!occupied.contains(cells[i])) return cells[i];
    }
    return null;
  }

  TissueCell? _parseAlphanumeric(String text) {
    if (text.length < 2) return null;
    final row = _rowLetters.indexOf(text[0]);
    final column = int.tryParse(text.substring(1));
    if (row < 0 || column == null) return null;
    return TissueCell(row, column - 1);
  }

  TissueCell? _parseSequential(String text) {
    final number = int.tryParse(text);
    if (number == null || number < 1 || number > size.capacity) return null;
    return orderedCells[number - 1];
  }

  TissueCell? _parseRowColumn(String text) {
    final parts = text.split('-');
    if (parts.length != 2) return null;
    final row = int.tryParse(parts[0]);
    final column = int.tryParse(parts[1]);
    if (row == null || column == null) return null;
    return TissueCell(row - 1, column - 1);
  }
}

/// The box name used in storage locations, such as `Box 12`.
String formatTissueBoxName(String boxLabel, int boxNumber) {
  final label = boxLabel.trim();
  return label.isEmpty ? '$boxNumber' : '$label $boxNumber';
}

/// The storage location written for a tube, such as `Box 12: A1`.
String formatTissueLocation(String boxLabel, int boxNumber, String cellLabel) {
  return '${formatTissueBoxName(boxLabel, boxNumber)}: $cellLabel';
}

/// The cell [location] points to in the named box, or null when it belongs
/// to another box or uses another numbering.
TissueCell? parseTissueLocation(
  TissueBoxLayout layout, {
  required String boxLabel,
  required int boxNumber,
  required String location,
}) {
  final prefix = '${formatTissueBoxName(boxLabel, boxNumber)}: ';
  final text = location.trim();
  if (!text.startsWith(prefix)) return null;
  return layout.parseCellLabel(text.substring(prefix.length));
}
