import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/providers/database.dart';

class CombinedFieldDialog extends ConsumerStatefulWidget {
  const CombinedFieldDialog({super.key, this.initialField});

  final CombinedField? initialField;

  @override
  CombinedFieldDialogState createState() => CombinedFieldDialogState();
}

class CombinedFieldDialogState extends ConsumerState<CombinedFieldDialog> {
  late TextEditingController _fieldIdController;
  List<String> _components = [];
  List<String> _availableFields = [];
  String? _selectedField;
  String _separator = '-';

  @override
  void initState() {
    super.initState();
    _fieldIdController =
        TextEditingController(text: widget.initialField?.fieldId ?? '');
    if (widget.initialField != null) {
      _components = List.from(widget.initialField!.fields);
    }
    _loadAvailableFields();
  }

  void _loadAvailableFields() {
    final db = ref.read(databaseProvider);
    final List<String> fields = [];
    for (var table in db.allTables) {
      final tableName = table.actualTableName;
      for (var col in table.$columns) {
        fields.add('$tableName::${col.name}');
      }
    }
    setState(() {
      _availableFields = fields;
      if (_availableFields.isNotEmpty) {
        _selectedField = _availableFields.first;
      }
    });
  }

  @override
  void dispose() {
    _fieldIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialField == null
          ? 'New Combined Field'
          : 'Edit Combined Field'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _fieldIdController,
                decoration: const InputDecoration(
                  labelText: 'Field ID (Name)',
                  hintText: 'e.g. Specimen ID',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedField,
                      isExpanded: true,
                      items: _availableFields.map((f) {
                        return DropdownMenuItem(
                            value: f,
                            child: Text(f, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedField = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  PrimaryButton(
                    label: 'Add Field',
                    icon: Icons.add,
                    onPressed: () {
                      if (_selectedField != null) {
                        setState(() {
                          _components.add(_selectedField!);
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _separator,
                      decoration: const InputDecoration(
                          labelText: 'Separator (e.g. -, _, space)'),
                      onChanged: (val) {
                        _separator = val;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  SecondaryButton(
                    text: 'Add Separator',
                    onPressed: () {
                      setState(() {
                        _components.add('SEP:$_separator');
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text('Components (Drag to reorder)'),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  itemCount: _components.length,
                  onReorderItem: (oldIndex, newIndex) {
                    setState(() {
                      final item = _components.removeAt(oldIndex);
                      _components.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final comp = _components[index];
                    final isSep = comp.startsWith('SEP:');
                    final display = isSep
                        ? 'Separator: "${comp.substring(4)}"'
                        : 'Field: $comp';
                    return ListTile(
                      key: ValueKey('$index-$comp'),
                      title: Text(display),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _components.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          label: 'Save',
          icon: Icons.save,
          onPressed: () {
            if (_fieldIdController.text.isNotEmpty && _components.isNotEmpty) {
              Navigator.pop(
                  context,
                  CombinedField(
                      fieldId: _fieldIdController.text, fields: _components));
            }
          },
        ),
      ],
    );
  }
}

Future<CombinedField?> showCombinedFieldDialog(BuildContext context,
    [CombinedField? initialField]) {
  bool isLargeScreen = MediaQuery.sizeOf(context).width > 600;
  if (isLargeScreen) {
    return showDialog<CombinedField>(
      context: context,
      builder: (context) => CombinedFieldDialog(initialField: initialField),
    );
  } else {
    return showModalBottomSheet<CombinedField>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: CombinedFieldDialog(initialField: initialField),
      ),
    );
  }
}
