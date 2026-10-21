import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/components/data_table_cell_editor.dart';
import 'package:nahpu/services/data_table/data_table_edits.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_grid_controller.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/data_table/data_table_tsv.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Width a column gets, by the kind of value it holds.
double dataTableColumnWidth(DataTableColumn column) {
  final name = column.key.toLowerCase();
  const wide = ['narrative', 'remark', 'description', 'notes', 'coordinates'];
  if (wide.any(name.contains) || name.endsWith('::media')) {
    return NahpuDataTable.wideColumnWidth;
  }
  return switch (column.field.valueType) {
    DataTableValueType.text => NahpuDataTable.columnWidth,
    _ => NahpuDataTable.narrowColumnWidth,
  };
}

/// Spreadsheet grid for one page of records.
///
/// Rows are built lazily; the header stays pinned while rows scroll, and
/// both scroll sideways together. Keyboard input follows spreadsheet
/// conventions, with Command and Control interchangeable.
class DataTableGrid extends StatefulWidget {
  const DataTableGrid({
    super.key,
    required this.type,
    required this.page,
    required this.columns,
    required this.sort,
    required this.isEditMode,
    required this.grid,
    required this.edits,
    required this.onSort,
    required this.onRequestPage,
    required this.onSave,
    required this.onFocusSearch,
    required this.onMessage,
  });

  final DataTableRecordType type;
  final DataTablePageData page;
  final List<DataTableColumn> columns;
  final DataTableSort? sort;
  final bool isEditMode;
  final DataTableGridController grid;
  final DataTableEditController edits;
  final ValueChanged<String> onSort;

  /// Asks to move one page back (-1) or forward (1).
  final ValueChanged<int> onRequestPage;
  final VoidCallback onSave;
  final VoidCallback onFocusSearch;
  final ValueChanged<String> onMessage;

  @override
  State<DataTableGrid> createState() => DataTableGridState();
}

class DataTableGridState extends State<DataTableGrid> {
  final _focusNode = FocusNode(debugLabel: 'data table grid');
  final _horizontal = ScrollController();
  final _vertical = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.grid.addListener(_onGridChanged);
    _syncSize();
  }

  @override
  void didUpdateWidget(DataTableGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.grid != widget.grid) {
      oldWidget.grid.removeListener(_onGridChanged);
      widget.grid.addListener(_onGridChanged);
    }
    _syncSize();
  }

  @override
  void dispose() {
    widget.grid.removeListener(_onGridChanged);
    _focusNode.dispose();
    _horizontal.dispose();
    _vertical.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widths = [
      for (final column in widget.columns) dataTableColumnWidth(column),
    ];
    final totalWidth =
        NahpuDataTable.rowNumberWidth + widths.fold(0.0, (sum, w) => sum + w);
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scrollbar(
        controller: _horizontal,
        child: SingleChildScrollView(
          controller: _horizontal,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalWidth,
            child: Column(
              children: [
                DataTableHeaderRow(
                  columns: widget.columns,
                  widths: widths,
                  type: widget.type,
                  sort: widget.sort,
                  isEditMode: widget.isEditMode,
                  onSort: widget.onSort,
                ),
                Expanded(
                  child: ListenableBuilder(
                    listenable: Listenable.merge([widget.grid, widget.edits]),
                    builder: (context, _) => ListView.builder(
                      controller: _vertical,
                      itemExtent: NahpuDataTable.rowHeight,
                      itemCount: widget.page.rows.length,
                      itemBuilder: (context, index) => DataTableGridRow(
                        index: index,
                        number: widget.page.firstRowIndex + index + 1,
                        row: widget.page.rows[index],
                        columns: widget.columns,
                        widths: widths,
                        type: widget.type,
                        isEditMode: widget.isEditMode,
                        grid: widget.grid,
                        edits: widget.edits,
                        onTapCell: _onTapCell,
                        onEditCell: _onDoubleTapCell,
                        onCommit: _commitEdit,
                        onCancel: _cancelEdit,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Resizes the controller after this frame: resizing can move focus,
  /// which notifies listeners and scrolls, neither of which may happen
  /// mid-build.
  void _syncSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.grid.setSize(widget.page.rows.length, widget.columns.length);
    });
  }

  bool _isEditable(int col) =>
      widget.isEditMode && widget.columns[col].isEditableIn(widget.type);

  void _onTapCell(int row, int col) {
    final extend = HardwareKeyboard.instance.isShiftPressed;
    // An open editor commits itself when it loses focus.
    widget.grid.moveTo(row, col, extend: extend);
    _focusNode.requestFocus();
  }

  void _onDoubleTapCell(int row, int col) {
    widget.grid.moveTo(row, col);
    _beginEdit();
  }

  void _beginEdit({String? seed}) {
    final col = widget.grid.focus.col;
    if (!_isEditable(col)) {
      if (widget.isEditMode) {
        widget.onMessage('${widget.columns[col].label} is read-only here.');
      }
      return;
    }
    widget.grid.beginEdit(seed: seed);
  }

  /// Commits the editor's text, then moves like Enter or Tab would.
  void _commitEdit(
    DataTableCellPos pos,
    String text,
    DataTableEditorExit exit,
  ) {
    _setValues({pos: text});
    // The editor may commit after focus already moved to another cell, such
    // as when another cell is tapped; then there is nothing more to do.
    if (widget.grid.editing != pos) return;
    widget.grid.endEdit();
    switch (exit) {
      case DataTableEditorExit.down:
        widget.grid.move(1, 0);
      case DataTableEditorExit.up:
        widget.grid.move(-1, 0);
      case DataTableEditorExit.next:
        widget.grid.tab();
      case DataTableEditorExit.previous:
        widget.grid.tab(backward: true);
      case DataTableEditorExit.stay:
        break;
    }
    _focusNode.requestFocus();
  }

  void _cancelEdit() {
    widget.grid.endEdit();
    _focusNode.requestFocus();
  }

  /// Queues edits for editable cells. Returns how many were read-only.
  int _setValues(Map<DataTableCellPos, String> values) {
    var skipped = 0;
    final edits = <(DataTableEdit, String)>[];
    for (final entry in values.entries) {
      final pos = entry.key;
      if (!_isEditable(pos.col)) {
        skipped++;
        continue;
      }
      final row = widget.page.rows[pos.row];
      final column = widget.columns[pos.col];
      edits.add((
        DataTableEdit(
          cell: DataTableCellId(row.key, column.key),
          field: column.field,
          value: entry.value,
          row: row.raw,
          attributeTable: row.attributeTable,
        ),
        row.raw[column.key] ?? '',
      ));
    }
    if (edits.isNotEmpty) widget.edits.commit(edits);
    return skipped;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || widget.grid.isEditing) {
      return KeyEventResult.ignored;
    }
    final keyboard = HardwareKeyboard.instance;
    final command = keyboard.isMetaPressed || keyboard.isControlPressed;
    final shift = keyboard.isShiftPressed;
    final grid = widget.grid;
    final key = event.logicalKey;

    if (command) {
      if (key == LogicalKeyboardKey.arrowUp) {
        grid.toEdge(-1, 0, extend: shift);
      } else if (key == LogicalKeyboardKey.arrowDown) {
        grid.toEdge(1, 0, extend: shift);
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        grid.toEdge(0, -1, extend: shift);
      } else if (key == LogicalKeyboardKey.arrowRight) {
        grid.toEdge(0, 1, extend: shift);
      } else if (key == LogicalKeyboardKey.home) {
        grid.pageStart(extend: shift);
      } else if (key == LogicalKeyboardKey.end) {
        grid.pageEnd(extend: shift);
      } else if (key == LogicalKeyboardKey.keyA) {
        grid.selectAll();
      } else if (key == LogicalKeyboardKey.keyC) {
        _copy();
      } else if (key == LogicalKeyboardKey.keyV) {
        _paste();
      } else if (key == LogicalKeyboardKey.keyF) {
        widget.onFocusSearch();
      } else if (key == LogicalKeyboardKey.keyS) {
        widget.onSave();
      } else if (key == LogicalKeyboardKey.keyZ) {
        if (widget.isEditMode) widget.edits.undoLast();
      } else {
        return KeyEventResult.ignored;
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      grid.move(-1, 0, extend: shift);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      grid.move(1, 0, extend: shift);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      grid.move(0, -1, extend: shift);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      grid.move(0, 1, extend: shift);
    } else if (key == LogicalKeyboardKey.tab) {
      grid.tab(backward: shift);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      grid.move(shift ? -1 : 1, 0);
    } else if (key == LogicalKeyboardKey.home) {
      grid.rowStart(extend: shift);
    } else if (key == LogicalKeyboardKey.end) {
      grid.rowEnd(extend: shift);
    } else if (key == LogicalKeyboardKey.pageUp) {
      _pageMove(-1, extend: shift);
    } else if (key == LogicalKeyboardKey.pageDown) {
      _pageMove(1, extend: shift);
    } else if (key == LogicalKeyboardKey.f2) {
      _beginEdit();
    } else if (key == LogicalKeyboardKey.escape) {
      grid.collapse();
    } else if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      _clearSelection();
    } else if (_isTyping(event)) {
      _beginEdit(seed: event.character);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  bool _isTyping(KeyEvent event) {
    final character = event.character;
    if (character == null || character.isEmpty) return false;
    final code = character.codeUnitAt(0);
    return code >= 0x20 && code != 0x7f;
  }

  /// PageUp and PageDown scroll a screen of rows; at the first or last row
  /// they turn the page.
  void _pageMove(int direction, {bool extend = false}) {
    final grid = widget.grid;
    final atEdge = direction < 0
        ? grid.focus.row == 0
        : grid.focus.row == grid.rowCount - 1;
    if (atEdge && !extend) {
      widget.onRequestPage(direction);
      return;
    }
    final visible = _vertical.hasClients
        ? (_vertical.position.viewportDimension / NahpuDataTable.rowHeight)
              .floor()
              .clamp(1, 1 << 20)
        : 10;
    grid.move(direction * visible, 0, extend: extend);
  }

  void _clearSelection() {
    if (!widget.isEditMode) return;
    final selection = widget.grid.selection;
    final skipped = _setValues({
      for (var row = selection.top; row <= selection.bottom; row++)
        for (var col = selection.left; col <= selection.right; col++)
          (row: row, col: col): '',
    });
    if (skipped > 0) widget.onMessage('Skipped $skipped read-only cells.');
  }

  String _shownValue(int row, int col) {
    final record = widget.page.rows[row];
    final column = widget.columns[col];
    final pending = widget.edits.pendingFor(
      DataTableCellId(record.key, column.key),
    );
    return pending?.value ?? record.values[column.key] ?? '';
  }

  Future<void> _copy() async {
    final selection = widget.grid.selection;
    final text = encodeDataTableTsv([
      for (var row = selection.top; row <= selection.bottom; row++)
        [
          for (var col = selection.left; col <= selection.right; col++)
            _shownValue(row, col),
        ],
    ]);
    await Clipboard.setData(ClipboardData(text: text));
    final count =
        (selection.bottom - selection.top + 1) *
        (selection.right - selection.left + 1);
    widget.onMessage(count == 1 ? 'Copied 1 cell.' : 'Copied $count cells.');
  }

  Future<void> _paste() async {
    if (!widget.isEditMode) {
      widget.onMessage('Switch to edit mode to paste.');
      return;
    }
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty || !mounted) return;
    final rows = decodeDataTableTsv(text);
    final start = widget.grid.focus;
    final values = <DataTableCellPos, String>{};
    var cutOff = false;
    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < rows[r].length; c++) {
        final pos = (row: start.row + r, col: start.col + c);
        if (pos.row >= widget.grid.rowCount ||
            pos.col >= widget.grid.columnCount) {
          cutOff = true;
          continue;
        }
        values[pos] = rows[r][c];
      }
    }
    final skipped = _setValues(values);
    final notes = [
      if (skipped > 0) 'skipped $skipped read-only cells',
      if (cutOff) 'cut off at the edge of the page',
    ];
    if (notes.isNotEmpty) widget.onMessage('Pasted; ${notes.join(' and ')}.');
  }

  void _onGridChanged() {
    if (!mounted) return;
    final focus = widget.grid.focus;
    if (_vertical.hasClients) {
      final top = focus.row * NahpuDataTable.rowHeight;
      final bottom = top + NahpuDataTable.rowHeight;
      final position = _vertical.position;
      if (top < position.pixels) {
        _vertical.jumpTo(top);
      } else if (bottom > position.pixels + position.viewportDimension) {
        _vertical.jumpTo(bottom - position.viewportDimension);
      }
    }
    if (_horizontal.hasClients && focus.col < widget.columns.length) {
      var left = NahpuDataTable.rowNumberWidth;
      for (var i = 0; i < focus.col; i++) {
        left += dataTableColumnWidth(widget.columns[i]);
      }
      final right = left + dataTableColumnWidth(widget.columns[focus.col]);
      final position = _horizontal.position;
      // Keep the row numbers in view when moving to the first column.
      final visibleLeft = focus.col == 0 ? 0.0 : left;
      if (visibleLeft < position.pixels) {
        _horizontal.jumpTo(visibleLeft);
      } else if (right > position.pixels + position.viewportDimension) {
        _horizontal.jumpTo(
          (right - position.viewportDimension).clamp(
            0.0,
            position.maxScrollExtent,
          ),
        );
      }
    }
  }
}

class DataTableHeaderRow extends StatelessWidget {
  const DataTableHeaderRow({
    super.key,
    required this.columns,
    required this.widths,
    required this.type,
    required this.sort,
    required this.isEditMode,
    required this.onSort,
  });

  final List<DataTableColumn> columns;
  final List<double> widths;
  final DataTableRecordType type;
  final DataTableSort? sort;
  final bool isEditMode;
  final ValueChanged<String> onSort;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: NahpuDataTable.rowHeight,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: NahpuStroke.thin,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: NahpuDataTable.rowNumberWidth),
          for (var i = 0; i < columns.length; i++)
            DataTableHeaderCell(
              column: columns[i],
              width: widths[i],
              sort: sort?.columnKey == columns[i].key ? sort : null,
              isLocked: isEditMode && !columns[i].isEditableIn(type),
              onSort: () => onSort(columns[i].key),
            ),
        ],
      ),
    );
  }
}

class DataTableHeaderCell extends StatelessWidget {
  const DataTableHeaderCell({
    super.key,
    required this.column,
    required this.width,
    required this.sort,
    required this.isLocked,
    required this.onSort,
  });

  final DataTableColumn column;
  final double width;
  final DataTableSort? sort;
  final bool isLocked;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final field = column.field;
    final notes = [
      column.key,
      if (field.isComputed)
        'Calculated during export: not searchable, sortable, or filterable.',
      if (isLocked) 'Read-only here.',
    ];
    final current = sort;
    return Tooltip(
      message: notes.join('\n'),
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: field.isSortable ? onSort : null,
        child: SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.md),
            child: Row(
              children: [
                if (isLocked) ...[
                  Icon(
                    Icons.lock_outline,
                    size: NahpuControlSize.iconSmall,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: NahpuSpacing.xs),
                ],
                Expanded(
                  child: Text(
                    column.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: field.isComputed
                          ? theme.colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                ),
                if (current != null)
                  Icon(
                    current.ascending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: NahpuControlSize.iconSmall,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DataTableGridRow extends StatelessWidget {
  const DataTableGridRow({
    super.key,
    required this.index,
    required this.number,
    required this.row,
    required this.columns,
    required this.widths,
    required this.type,
    required this.isEditMode,
    required this.grid,
    required this.edits,
    required this.onTapCell,
    required this.onEditCell,
    required this.onCommit,
    required this.onCancel,
  });

  final int index;
  final int number;
  final DataTableRecordRow row;
  final List<DataTableColumn> columns;
  final List<double> widths;
  final DataTableRecordType type;
  final bool isEditMode;
  final DataTableGridController grid;
  final DataTableEditController edits;
  final void Function(int row, int col) onTapCell;
  final void Function(int row, int col) onEditCell;
  final void Function(
    DataTableCellPos pos,
    String text,
    DataTableEditorExit exit,
  )
  onCommit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selection = grid.selection;
    final focus = grid.focus;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: NahpuStroke.thin,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: NahpuDataTable.rowNumberWidth,
            child: Center(
              child: Text(
                '$number',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          for (var col = 0; col < columns.length; col++)
            DataTableGridCell(
              width: widths[col],
              row: row,
              column: columns[col],
              isReadOnly: isEditMode && !columns[col].isEditableIn(type),
              isFocused: focus.row == index && focus.col == col,
              isSelected:
                  !selection.isSingleCell && selection.contains(index, col),
              isEditing: grid.editing == (row: index, col: col),
              editSeed: grid.editSeed,
              edits: edits,
              onTap: () => onTapCell(index, col),
              onDoubleTap: () => onEditCell(index, col),
              onCommit: (text, exit) =>
                  onCommit((row: index, col: col), text, exit),
              onCancel: onCancel,
            ),
        ],
      ),
    );
  }
}

class DataTableGridCell extends StatelessWidget {
  const DataTableGridCell({
    super.key,
    required this.width,
    required this.row,
    required this.column,
    required this.isReadOnly,
    required this.isFocused,
    required this.isSelected,
    required this.isEditing,
    required this.editSeed,
    required this.edits,
    required this.onTap,
    required this.onDoubleTap,
    required this.onCommit,
    required this.onCancel,
  });

  final double width;
  final DataTableRecordRow row;
  final DataTableColumn column;
  final bool isReadOnly;
  final bool isFocused;
  final bool isSelected;
  final bool isEditing;
  final String? editSeed;
  final DataTableEditController edits;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final void Function(String text, DataTableEditorExit exit) onCommit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cell = DataTableCellId(row.key, column.key);
    final pending = edits.pendingFor(cell);
    final error = edits.errorFor(cell);
    final text = pending?.value ?? row.values[column.key] ?? '';
    final background = pending != null
        ? colorScheme.tertiaryContainer
        : isSelected
        ? colorScheme.primaryContainer
        : isReadOnly
        ? colorScheme.surfaceContainerLow
        : null;
    final borderColor = error != null
        ? colorScheme.error
        : isFocused
        ? colorScheme.primary
        : null;
    final content = isEditing
        ? DataTableCellEditor(
            field: column.field,
            initialText:
                editSeed ?? pending?.value ?? row.raw[column.key] ?? '',
            selectAll: editSeed == null,
            onCommit: onCommit,
            onCancel: onCancel,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.md),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontStyle: dataTableItalicColumnKeys.contains(column.key)
                      ? FontStyle.italic
                      : null,
                  color: pending != null
                      ? colorScheme.onTertiaryContainer
                      : null,
                ),
              ),
            ),
          );
    final tooltip = error ?? (edits.isSavingCell(cell) ? 'Saving…' : null);
    // Selection follows the pointer going down, as in a spreadsheet; a tap
    // handler would wait out the double-tap window first.
    final cellBox = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: isEditing ? null : (_) => onTap(),
      child: GestureDetector(
        onDoubleTap: isEditing ? null : onDoubleTap,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: background,
            border: borderColor == null
                ? null
                : Border.all(color: borderColor, width: NahpuStroke.regular),
          ),
          child: content,
        ),
      ),
    );
    return tooltip == null
        ? cellBox
        : Tooltip(message: tooltip, child: cellBox);
  }
}
