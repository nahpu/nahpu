import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Where focus goes after an edit is committed.
enum DataTableEditorExit { down, up, next, previous, stay }

/// In-cell editor. Enter commits and moves down, Tab commits and moves
/// right, Escape cancels, and leaving the cell commits in place.
class DataTableCellEditor extends ConsumerStatefulWidget {
  const DataTableCellEditor({
    super.key,
    required this.field,
    required this.initialText,
    required this.selectAll,
    required this.onCommit,
    required this.onCancel,
  });

  final DataTableField field;
  final String initialText;

  /// Selects the existing text (F2 or double-click); otherwise the caret
  /// goes after the character that started the edit.
  final bool selectAll;
  final void Function(String text, DataTableEditorExit exit) onCommit;
  final VoidCallback onCancel;

  @override
  ConsumerState<DataTableCellEditor> createState() =>
      _DataTableCellEditorState();
}

class _DataTableCellEditorState extends ConsumerState<DataTableCellEditor> {
  late final _controller = TextEditingController(text: widget.initialText);
  final _focusNode = FocusNode(debugLabel: 'data table cell editor');
  bool _done = false;

  /// True while a picker or option menu has focus, so leaving the text
  /// field for it doesn't commit.
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _controller.selection = widget.selectAll
        ? TextSelection(baseOffset: 0, extentOffset: _controller.text.length)
        : TextSelection.collapsed(offset: _controller.text.length);
    _focusNode.addListener(_onFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Focus(
      onKeyEvent: _onKey,
      child: Container(
        color: colorScheme.surface,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: _hint,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: NahpuSpacing.md,
                    vertical: NahpuSpacing.sm,
                  ),
                ),
              ),
            ),
            if (widget.field.optionKey != null)
              DataTableOptionMenu(
                optionKey: widget.field.optionKey!,
                onOpen: () => _isPicking = true,
                onClose: _endPicking,
                onSelected: (value) => _finish(value, DataTableEditorExit.stay),
              )
            else if (widget.field.valueType == DataTableValueType.date)
              IconButton(
                tooltip: 'Pick a date',
                iconSize: NahpuControlSize.iconSmall,
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: _pickDate,
              )
            else if (widget.field.valueType == DataTableValueType.time)
              IconButton(
                tooltip: 'Pick a time',
                iconSize: NahpuControlSize.iconSmall,
                icon: const Icon(Icons.schedule),
                onPressed: _pickTime,
              ),
          ],
        ),
      ),
    );
  }

  String? get _hint => switch (widget.field.valueType) {
    DataTableValueType.date => 'YYYY-MM-DD',
    DataTableValueType.time => 'HH:MM',
    _ => null,
  };

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      // Enter confirms an input method's composition first.
      if (_controller.value.composing.isValid) return KeyEventResult.ignored;
      _finish(
        _controller.text,
        shift ? DataTableEditorExit.up : DataTableEditorExit.down,
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.tab) {
      _finish(
        _controller.text,
        shift ? DataTableEditorExit.previous : DataTableEditorExit.next,
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      _done = true;
      widget.onCancel();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && !_isPicking) {
      _finish(_controller.text, DataTableEditorExit.stay);
    }
  }

  void _endPicking() {
    _isPicking = false;
    if (!_done) _focusNode.requestFocus();
  }

  void _finish(String text, DataTableEditorExit exit) {
    if (_done) return;
    _done = true;
    widget.onCommit(text, exit);
  }

  Future<void> _pickDate() async {
    _isPicking = true;
    final current = DateTime.tryParse(_controller.text.trim());
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(1700),
      lastDate: DateTime(2200),
    );
    if (!mounted) return;
    if (picked == null) {
      _endPicking();
      return;
    }
    _isPicking = false;
    _finish(DateFormat('yyyy-MM-dd').format(picked), DataTableEditorExit.stay);
  }

  Future<void> _pickTime() async {
    _isPicking = true;
    final parts = _controller.text.trim().split(':');
    final current = parts.length >= 2
        ? TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          )
        : TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: current);
    if (!mounted) return;
    if (picked == null) {
      _endPicking();
      return;
    }
    _isPicking = false;
    String two(int value) => value.toString().padLeft(2, '0');
    _finish(
      '${two(picked.hour)}:${two(picked.minute)}',
      DataTableEditorExit.stay,
    );
  }
}

/// Lists a field's controlled vocabulary while editing.
class DataTableOptionMenu extends ConsumerWidget {
  const DataTableOptionMenu({
    super.key,
    required this.optionKey,
    required this.onOpen,
    required this.onClose,
    required this.onSelected,
  });

  final String optionKey;
  final VoidCallback onOpen;
  final VoidCallback onClose;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options =
        ref.watch(effectiveUserDefinedFieldProvider(optionKey)).value ??
        const <String>[];
    return MenuAnchor(
      onOpen: onOpen,
      onClose: onClose,
      menuChildren: [
        for (final option in options)
          MenuItemButton(
            onPressed: () => onSelected(option),
            child: Text(option),
          ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: 'Choose a value',
        iconSize: NahpuControlSize.iconSmall,
        icon: const Icon(Icons.arrow_drop_down),
        onPressed: options.isEmpty
            ? null
            : () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
