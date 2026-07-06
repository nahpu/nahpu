import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/export.dart';

class AvailableSymbolsWrap extends StatelessWidget {
  const AvailableSymbolsWrap({
    super.key,
    required this.onSelectSymbol,
  });

  final ValueChanged<String> onSelectSymbol;

  @override
  Widget build(BuildContext context) {
    const symbols = [
      '♂',
      '♀',
      '±',
      '×',
      '≈',
      '≡',
      '°',
      'µ',
      '≥',
      '≤',
    ];
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
        side: BorderSide(
          color: scheme.outlineVariant,
        ),
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
                Row(
                  children: [
                    if (widget.recordType == RecordType.specimenRecord ||
                        widget.recordType == RecordType.specimenParts) ...[
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
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _selectedTaxon = v;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8.0),
                    ],
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
                    const SizedBox(width: 8.0),
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
                    table.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                    ),
                  ),
                  dense: true,
                  childrenPadding: EdgeInsets.zero,
                  children: rowLabels.map((label) {
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      onTap: () => widget.onSelectField(label),
                      title: Text(
                        _getDisplayLabel(label),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13.0,
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
    final db = ref.read(databaseProvider);
    final Map<String, List<String>> groups = {};

    final Set<String> allowedTables;
    switch (widget.recordType) {
      case RecordType.none:
        allowedTables = {'personnel', 'project'};
        break;
      case RecordType.narrative:
        allowedTables = {'narrative', 'site', 'personnel'};
        break;
      case RecordType.site:
        allowedTables = {'site', 'personnel'};
        break;
      case RecordType.collEvent:
        allowedTables = {
          'collEvent',
          'site',
          'weather',
          'personnel',
          'collEffort'
        };
        break;
      case RecordType.specimenRecord:
      case RecordType.specimenParts:
        allowedTables = {
          'specimen',
          'taxonomy',
          'personnel',
          'project',
          'collEvent',
          'site',
          'coordinate',
          'weather',
          'mammalMeasurement',
          'avianMeasurement',
          'herpMeasurement',
          'specimenPart',
        };
        if (_selectedTaxon == 'Mammals') {
          allowedTables.remove('avianMeasurement');
          allowedTables.remove('herpMeasurement');
        } else if (_selectedTaxon == 'Birds') {
          allowedTables.remove('mammalMeasurement');
          allowedTables.remove('herpMeasurement');
        } else if (_selectedTaxon == 'Herpetofauna') {
          allowedTables.remove('mammalMeasurement');
          allowedTables.remove('avianMeasurement');
        }
        break;
    }

    for (var table in db.allTables) {
      final tableName = table.actualTableName;
      if (allowedTables.contains(tableName)) {
        groups[tableName] =
            table.$columns.map((c) => '$tableName::${c.name}').toList();
      }
    }
    return groups;
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
    final stripped = label.replaceAll('[', '').replaceAll(']', '');
    if (_fieldDisplayOption == 'short') {
      final parts = stripped.split('::');
      return parts.length > 1 ? parts.last : stripped;
    }
    return stripped;
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
  String _fieldDisplayOption = 'short';

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Text Input',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
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
                            _convertTextFormat(v);
                          }
                        },
                      ),
                    ],
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
                    AvailableSymbolsWrap(
                      onSelectSymbol: _handleInsert,
                    ),
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

  void _convertTextFormat(String targetFormat) {
    final text = _controller.text;
    final db = ref.read(databaseProvider);
    final Map<String, String> fieldToFull = {};
    final List<String> allFullFields = [];

    for (var table in db.allTables) {
      final tableName = table.actualTableName;
      for (var col in table.$columns) {
        final colName = col.name;
        final full = '$tableName::$colName';
        allFullFields.add(full);
        fieldToFull.putIfAbsent(colName, () => full);
        if (colName.endsWith('.sex')) {
          fieldToFull.putIfAbsent('$colName-img', () => '$full-img');
        }
      }
    }

    if (targetFormat == 'short') {
      String result = text;
      for (final full in allFullFields) {
        final parts = full.split('::');
        final short = parts.last;
        result = result.replaceAll('[$full]', '[$short]');
        if (full.endsWith('.sex')) {
          result = result.replaceAll('[$full-img]', '[$short-img]');
        }
      }
      _controller.value = TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
    } else {
      final regExp = RegExp(r'\[([^\]]+)\]');
      final matches = regExp.allMatches(text).toList();
      String result = text;
      for (final match in matches.reversed) {
        final matchedGroup = match.group(1);
        if (matchedGroup == null) continue;
        if (matchedGroup.contains('::')) {
          continue;
        }
        final isImg = matchedGroup.endsWith('-img');
        final baseName = isImg
            ? matchedGroup.substring(0, matchedGroup.length - 4)
            : matchedGroup;
        final fullBase = fieldToFull[baseName];
        if (fullBase != null) {
          final replacement = isImg ? '$fullBase-img' : fullBase;
          result =
              result.replaceRange(match.start, match.end, '[$replacement]');
        }
      }
      _controller.value = TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
    }
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
  String _fieldDisplayOption = 'short';

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
      constraints: BoxConstraints(
        maxHeight: media.size.height * 0.85,
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Text Input',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                    _convertTextFormat(v);
                  }
                },
              ),
            ],
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
                  AvailableSymbolsWrap(
                    onSelectSymbol: _handleInsert,
                  ),
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

  void _convertTextFormat(String targetFormat) {
    final text = _controller.text;
    final db = ref.read(databaseProvider);
    final Map<String, String> fieldToFull = {};
    final List<String> allFullFields = [];

    for (var table in db.allTables) {
      final tableName = table.actualTableName;
      for (var col in table.$columns) {
        final colName = col.name;
        final full = '$tableName::$colName';
        allFullFields.add(full);
        fieldToFull.putIfAbsent(colName, () => full);
        if (colName.endsWith('.sex')) {
          fieldToFull.putIfAbsent('$colName-img', () => '$full-img');
        }
      }
    }

    if (targetFormat == 'short') {
      String result = text;
      for (final full in allFullFields) {
        final parts = full.split('::');
        final short = parts.last;
        result = result.replaceAll('[$full]', '[$short]');
        if (full.endsWith('.sex')) {
          result = result.replaceAll('[$full-img]', '[$short-img]');
        }
      }
      _controller.value = TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
    } else {
      final regExp = RegExp(r'\[([^\]]+)\]');
      final matches = regExp.allMatches(text).toList();
      String result = text;
      for (final match in matches.reversed) {
        final matchedGroup = match.group(1);
        if (matchedGroup == null) continue;
        if (matchedGroup.contains('::')) {
          continue;
        }
        final isImg = matchedGroup.endsWith('-img');
        final baseName = isImg
            ? matchedGroup.substring(0, matchedGroup.length - 4)
            : matchedGroup;
        final fullBase = fieldToFull[baseName];
        if (fullBase != null) {
          final replacement = isImg ? '$fullBase-img' : fullBase;
          result =
              result.replaceRange(match.start, match.end, '[$replacement]');
        }
      }
      _controller.value = TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
    }
  }
}
