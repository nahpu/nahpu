import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/components/data_table_toolbar.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';
import 'package:nahpu/services/data_table/data_table_link_service.dart';
import 'package:nahpu/services/data_table/data_table_save_service.dart';
import 'package:nahpu/services/data_table/data_table_services.dart';
import 'package:nahpu/services/providers/data_table.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Opens the dialog for a linked cell: a bottom sheet on small screens and
/// a dialog elsewhere. Returns true when something was saved.
Future<bool> showDataTableLinkDialog(
  BuildContext context, {
  required DataTableRecordType type,
  required DataTableRecordRow row,
  required DataTableColumn column,
  required DataTableLink link,
}) async {
  final saved = await showAdaptiveSheetDialog<bool>(
    context: context,
    isDismissible: false,
    builder: (context, isSheet) => link.isRelink
        ? DataTableRelinkDialog(
            type: type,
            row: row,
            column: column,
            link: link,
            isSheet: isSheet,
          )
        : DataTableLinkedRecordDialog(
            type: type,
            row: row,
            link: link,
            isSheet: isSheet,
          ),
  );
  return saved ?? false;
}

/// Picks another record for a linked cell.
class DataTableRelinkDialog extends ConsumerStatefulWidget {
  const DataTableRelinkDialog({
    super.key,
    required this.type,
    required this.row,
    required this.column,
    required this.link,
    required this.isSheet,
  });

  final DataTableRecordType type;
  final DataTableRecordRow row;
  final DataTableColumn column;
  final DataTableLink link;
  final bool isSheet;

  @override
  ConsumerState<DataTableRelinkDialog> createState() =>
      _DataTableRelinkDialogState();
}

class _DataTableRelinkDialogState extends ConsumerState<DataTableRelinkDialog> {
  late final Future<List<DataTableLinkOption>> _options = DataTableLinkService(
    ref: ref,
  ).options(widget.link);
  final _search = TextEditingController();
  DataTableLinkOption? _selected;
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.row.values[widget.column.key] ?? '';
    return AdaptiveSheetDialogBody(
      title: dataTableLinkTitle(widget.link),
      showCloseButton: !widget.isSheet,
      isCloseEnabled: !_isSaving,
      description: [if (current.isNotEmpty) 'Now: $current.', ?_note].join(' '),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selected == null || _isSaving ? null : _apply,
          child: const Text('Apply'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DataTableSearchField(
            controller: _search,
            hint: 'Search',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: NahpuSpacing.md),
          FutureBuilder<List<DataTableLinkOption>>(
            future: _options,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(NahpuSpacing.xxl),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const Text('Couldn\'t load the choices.');
              }
              return DataTableSearchableList(
                options: snapshot.data!,
                query: _search.text,
                selected: _selected,
                onSelected: (option) => setState(() => _selected = option),
              );
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: NahpuSpacing.md),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  String? get _note => switch (widget.link) {
    DataTableLink.cataloger =>
      'The field number follows the new cataloger. The determiner and '
          'preparator change too when they were the previous cataloger.',
    DataTableLink.event =>
      'The collecting method and personnel are cleared, and the coordinate '
          'follows the new event\'s site.',
    DataTableLink.taxon =>
      'Order, family, genus, and epithet all come from the chosen taxon.',
    _ => null,
  };

  Future<void> _apply() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await DataTableLinkService(
        ref: ref,
      ).relink(widget.type, widget.row, widget.link, _selected!.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _error = 'Couldn\'t save: $e';
      });
    }
  }
}

/// A filterable list of link choices.
class DataTableSearchableList extends StatelessWidget {
  const DataTableSearchableList({
    super.key,
    required this.options,
    required this.query,
    required this.selected,
    required this.onSelected,
  });

  final List<DataTableLinkOption> options;
  final String query;
  final DataTableLinkOption? selected;
  final ValueChanged<DataTableLinkOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final needle = query.trim().toLowerCase();
    final shown = [
      for (final option in options)
        if (needle.isEmpty ||
            option.label.toLowerCase().contains(needle) ||
            (option.detail?.toLowerCase().contains(needle) ?? false))
          option,
    ];
    if (shown.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(NahpuSpacing.xl),
        child: Text('Nothing matches.', textAlign: TextAlign.center),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: NahpuDashboardPanel.height),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: shown.length,
        itemBuilder: (context, index) {
          final option = shown[index];
          final isSelected = identical(option, selected);
          final detail = option.detail;
          return ListTile(
            dense: true,
            selected: isSelected,
            title: Text(option.label),
            subtitle: detail == null || detail.isEmpty ? null : Text(detail),
            trailing: isSelected ? const Icon(Icons.check) : null,
            onTap: () => onSelected(option),
          );
        },
      ),
    );
  }
}

/// Edits the site or event a record is linked to. The change shows on
/// every record linked to it, which the dialog says up front.
class DataTableLinkedRecordDialog extends ConsumerStatefulWidget {
  const DataTableLinkedRecordDialog({
    super.key,
    required this.type,
    required this.row,
    required this.link,
    required this.isSheet,
  });

  final DataTableRecordType type;
  final DataTableRecordRow row;
  final DataTableLink link;
  final bool isSheet;

  @override
  ConsumerState<DataTableLinkedRecordDialog> createState() =>
      _DataTableLinkedRecordDialogState();
}

class _DataTableLinkedRecordDialogState
    extends ConsumerState<DataTableLinkedRecordDialog> {
  late final int? _id = widget.link == DataTableLink.linkedSite
      ? widget.row.siteId
      : widget.row.eventId;
  late final Future<_LinkedRecord> _record = _loadRecord();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _errors = {};
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noun = widget.link == DataTableLink.linkedSite ? 'site' : 'event';
    return AdaptiveSheetDialogBody(
      title: dataTableLinkTitle(widget.link),
      showCloseButton: !widget.isSheet,
      isCloseEnabled: !_isSaving,
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _id == null || _isSaving ? null : _apply,
          child: const Text('Apply'),
        ),
      ],
      child: _id == null
          ? Text('This record isn\'t linked to a $noun yet.')
          : FutureBuilder<_LinkedRecord>(
              future: _record,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(NahpuSpacing.xxl),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Couldn\'t load the $noun.');
                }
                return _form(context, snapshot.data!, noun);
              },
            ),
    );
  }

  Widget _form(BuildContext context, _LinkedRecord record, String noun) {
    final theme = Theme.of(context);
    final records = record.sharing == 1
        ? '1 ${widget.type.label.toLowerCase()} record'
        : '${record.sharing} ${widget.type.label.toLowerCase()} records';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(NahpuSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(NahpuRadius.md),
          ),
          child: Row(
            children: [
              Icon(Icons.link, color: theme.colorScheme.onSecondaryContainer),
              const SizedBox(width: NahpuSpacing.md),
              Expanded(
                child: Text(
                  'Changes apply to $records linked to this $noun.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        for (final column in record.columns)
          Padding(
            padding: const EdgeInsets.only(bottom: NahpuSpacing.md),
            child: DataTableLinkedField(
              column: column,
              controller: _controllers.putIfAbsent(
                column.key,
                // Dropdown fields keep the stored value, such as a code.
                () => TextEditingController(text: record.raw[column.key] ?? ''),
              ),
              error: _errors[column.key],
            ),
          ),
        if (_error != null)
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
      ],
    );
  }

  Future<_LinkedRecord> _loadRecord() async {
    final service = DataTableLinkService(ref: ref);
    final (linkedType, columns, raw) = await service.linkedRecord(
      widget.link,
      _id!,
    );
    final sharing = await service.sharingCount(widget.type, widget.link, _id);
    return _LinkedRecord(linkedType, columns, raw, sharing);
  }

  Future<void> _apply() async {
    final record = await _record;
    if (!mounted) return;
    final edits = <DataTableEdit>[];
    final errors = <String, String>{};
    for (final column in record.columns) {
      final field = column.field;
      final stored = record.raw[column.key] ?? '';
      final text = _controllers[column.key]?.text ?? '';
      if (text.trim() == stored.trim()) continue;
      try {
        dataTableStoredValue(field, text);
      } on FormatException catch (e) {
        errors[column.key] = e.message;
        continue;
      }
      edits.add(
        DataTableEdit(
          cell: DataTableCellId(_id!, column.key),
          field: field,
          value: text,
          row: record.raw,
        ),
      );
    }
    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
      _error = null;
    });
    if (errors.isNotEmpty) return;
    if (edits.isEmpty) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() => _isSaving = true);
    final result = await DataTableLinkService(
      ref: ref,
    ).saveLinked(record.linkedType, edits);
    if (!mounted) return;
    if (result.errors.isEmpty) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isSaving = false;
      _errors.addAll({
        for (final entry in result.errors.entries)
          entry.key.fieldKey: entry.value,
      });
      _error = 'Some changes couldn\'t be saved.';
    });
  }
}

class _LinkedRecord {
  const _LinkedRecord(this.linkedType, this.columns, this.raw, this.sharing);

  final DataTableRecordType linkedType;
  final List<DataTableColumn> columns;
  final Map<String, String> raw;
  final int sharing;
}

/// One field of the linked-record form: a dropdown for listed values, as
/// in the record forms, and a text field otherwise.
class DataTableLinkedField extends StatelessWidget {
  const DataTableLinkedField({
    super.key,
    required this.column,
    required this.controller,
    required this.error,
  });

  final DataTableColumn column;
  final TextEditingController controller;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final field = column.field;
    if (dataTableHasChoices(field)) {
      return DataTableLinkedChoiceField(
        column: column,
        controller: controller,
        error: error,
      );
    }
    final hint = switch (field.valueType) {
      DataTableValueType.date => 'YYYY-MM-DD',
      DataTableValueType.time => 'HH:MM',
      _ => null,
    };
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: column.label,
        hintText: hint,
        errorText: error,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class DataTableLinkedChoiceField extends ConsumerStatefulWidget {
  const DataTableLinkedChoiceField({
    super.key,
    required this.column,
    required this.controller,
    required this.error,
  });

  final DataTableColumn column;

  /// Holds the chosen stored value.
  final TextEditingController controller;
  final String? error;

  @override
  ConsumerState<DataTableLinkedChoiceField> createState() =>
      _DataTableLinkedChoiceFieldState();
}

class _DataTableLinkedChoiceFieldState
    extends ConsumerState<DataTableLinkedChoiceField> {
  /// The stored value when the dialog opened, kept in the list even if the
  /// vocabulary no longer has it.
  late final String _initial = widget.controller.text;

  @override
  Widget build(BuildContext context) {
    final field = widget.column.field;
    final choices = dataTableChoicesWithCurrent(
      field,
      ref.watch(dataTableChoicesProvider(field.key)).value ?? const [],
      _initial,
    );
    final value = widget.controller.text.trim();
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: widget.column.label,
        errorText: widget.error,
        border: const OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text('None')),
        for (final choice in choices)
          DropdownMenuItem(value: choice.value, child: Text(choice.label)),
      ],
      onChanged: (chosen) =>
          setState(() => widget.controller.text = chosen ?? ''),
    );
  }
}
