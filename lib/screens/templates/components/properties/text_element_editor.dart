import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/templates/print_specimen_table_columns.dart';
import 'package:nahpu/services/templates/template_field_catalog.dart';
import 'package:nahpu/services/types/export.dart';

String _fieldIdFromBracketLabel(String label) {
  return label.replaceAll('[', '').replaceAll(']', '');
}

String _placeholderForDisplayOption(String label, String displayOption) {
  final fieldId = _fieldIdFromBracketLabel(label);
  if (displayOption == 'full') return '[$fieldId]';
  final isImageField = fieldId.endsWith('-img');
  final baseField = isImageField
      ? fieldId.substring(0, fieldId.length - 4)
      : fieldId;
  final parts = baseField.split('::');
  final shortField = parts.length > 1 ? parts.last : baseField;
  return isImageField ? '[$shortField-img]' : '[$shortField]';
}

class AvailableSymbolsWrap extends StatelessWidget {
  const AvailableSymbolsWrap({super.key, required this.onSelectSymbol});

  final ValueChanged<String> onSelectSymbol;

  @override
  Widget build(BuildContext context) {
    const symbols = ['♂', '♀', '±', '×', '≈', '≡', '°', 'µ', '≥', '≤'];
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        for (final sym in symbols)
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () => onSelectSymbol(sym),
            child: Text(
              sym,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class AvailableFieldsSection extends ConsumerStatefulWidget {
  const AvailableFieldsSection({
    super.key,
    required this.onSelectField,
    required this.recordType,
  });

  final ValueChanged<String> onSelectField;
  final RecordType recordType;

  @override
  ConsumerState<AvailableFieldsSection> createState() =>
      _AvailableFieldsSectionState();
}

class _AvailableFieldsSectionState
    extends ConsumerState<AvailableFieldsSection> {
  bool _showFields = false;
  String _fieldDisplayOption = 'short';
  String _selectedTaxon = 'All Taxa';

  @override
  Widget build(BuildContext context) {
    if (!_showFields) {
      return Center(
        child: TextButton.icon(
          onPressed: () {
            setState(() {
              _showFields = true;
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Insert Field'),
        ),
      );
    }

    final groups = _getAllGroups();
    final groupKeys = groups.keys.toList();
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Fields',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      if (widget.recordType == RecordType.specimenRecord ||
                          widget.recordType == RecordType.specimenParts)
                        DropdownButton<String>(
                          value: _selectedTaxon,
                          isDense: true,
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem(
                              value: 'All Taxa',
                              child: Text(
                                'All Taxa',
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Mammals',
                              child: Text(
                                'Mammals',
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Birds',
                              child: Text(
                                'Birds',
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Herpetofauna',
                              child: Text(
                                'Herpetofauna',
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Arthropods',
                              child: Text(
                                'Arthropods',
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _selectedTaxon = v;
                              });
                            }
                          },
                        ),
                      DropdownButton<String>(
                        value: _fieldDisplayOption,
                        isDense: true,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(
                            value: 'full',
                            child: Text(
                              'Table::Field',
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'short',
                            child: Text(
                              'Field Only',
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _fieldDisplayOption = v;
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18.0),
                        onPressed: () {
                          setState(() {
                            _showFields = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1.0),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: groupKeys.length,
              itemBuilder: (context, index) {
                final table = groupKeys[index];
                final fields = groups[table]!;
                final rowLabels = _fieldPanelRowLabels(fields);
                return ExpansionTile(
                  title: Text(
                    databaseTableDisplayTitle(table),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  dense: true,
                  childrenPadding: EdgeInsets.zero,
                  children: rowLabels.map((label) {
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      onTap: () => widget.onSelectField(
                        _placeholderForDisplayOption(
                          label,
                          _fieldDisplayOption,
                        ),
                      ),
                      title: Text(
                        _getDisplayLabel(label),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<String>> _getAllGroups() {
    return availableTemplateFieldGroups(
      ref.read(databaseProvider),
      widget.recordType,
      selectedTaxon: _selectedTaxon,
    );
  }

  List<String> _fieldPanelRowLabels(List<String> fieldIds) {
    final out = <String>[];
    for (final id in fieldIds) {
      if (id.toLowerCase().endsWith('.sex')) {
        out.add('[$id]');
        out.add('[$id]-img');
      } else {
        out.add('[$id]');
      }
    }
    return out;
  }

  String _getDisplayLabel(String label) {
    final stripped = _fieldIdFromBracketLabel(label);
    if (_fieldDisplayOption == 'short') {
      final parts = stripped.split('::');
      return '[${parts.length > 1 ? parts.last : stripped}]';
    }
    return '[$stripped]';
  }
}

class TextElementEditorDialog extends ConsumerStatefulWidget {
  const TextElementEditorDialog({
    super.key,
    required this.initialText,
    required this.recordType,
    required this.onSave,
  });

  final String initialText;
  final RecordType recordType;
  final ValueChanged<String> onSave;

  @override
  ConsumerState<TextElementEditorDialog> createState() =>
      _TextElementEditorDialogState();
}

class _TextElementEditorDialogState
    extends ConsumerState<TextElementEditorDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Custom Text'),
      content: SizedBox(
        width: 800.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Text Input',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _controller,
                    maxLines: 8,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Enter text or insert fields...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24.0),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Available Symbols',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    AvailableSymbolsWrap(onSelectSymbol: _handleInsert),
                    const SizedBox(height: 16.0),
                    AvailableFieldsSection(
                      recordType: widget.recordType,
                      onSelectField: _handleInsert,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_controller.text);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _handleInsert(String val) {
    final text = _controller.text;
    final sel = _controller.selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final newText = text.replaceRange(
      start < 0 ? 0 : start,
      end < 0 ? 0 : end,
      val,
    );
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: (start < 0 ? 0 : start) + val.length,
      ),
    );
  }
}

class TextElementEditorBottomSheet extends ConsumerStatefulWidget {
  const TextElementEditorBottomSheet({
    super.key,
    required this.initialText,
    required this.recordType,
    required this.onSave,
  });

  final String initialText;
  final RecordType recordType;
  final ValueChanged<String> onSave;

  @override
  ConsumerState<TextElementEditorBottomSheet> createState() =>
      _TextElementEditorBottomSheetState();
}

class _TextElementEditorBottomSheetState
    extends ConsumerState<TextElementEditorBottomSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16.0,
        8.0,
        16.0,
        media.viewInsets.bottom + 16.0,
      ),
      constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.0,
              height: 4.0,
              margin: const EdgeInsets.only(bottom: 12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Custom Text',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave(_controller.text);
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
          Text(
            'Text Input',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _controller,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter text...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Available Symbols',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  AvailableSymbolsWrap(onSelectSymbol: _handleInsert),
                  const SizedBox(height: 16.0),
                  AvailableFieldsSection(
                    recordType: widget.recordType,
                    onSelectField: _handleInsert,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleInsert(String val) {
    final text = _controller.text;
    final sel = _controller.selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    final newText = text.replaceRange(
      start < 0 ? 0 : start,
      end < 0 ? 0 : end,
      val,
    );
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: (start < 0 ? 0 : start) + val.length,
      ),
    );
  }
}
