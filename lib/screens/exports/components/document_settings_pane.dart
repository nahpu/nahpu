import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/services/document_layout_service.dart';
import 'package:nahpu/screens/shared/file_operation.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/services/types/controllers.dart';

class DocumentSettingsPane extends StatelessWidget {
  const DocumentSettingsPane({
    super.key,
    required this.layout,
    required this.setupNames,
    required this.selectedSetupName,
    required this.templateNames,
    required this.exportCtr,
    required this.selectedDir,
    required this.hasSaved,
    required this.isRunning,
    required this.onLayoutChanged,
    required this.onSetupSelected,
    required this.onSaveSetupAs,
    required this.onDeleteSetup,
    required this.onExportSetup,
    required this.onImportSetup,
    required this.onFileNameChanged,
    required this.onSelectDir,
    required this.onClearDir,
    required this.onExportPressed,
    required this.selectedCount,
    required this.totalCount,
    required this.onSelectSpecimens,
  });

  final rust_config.DocumentLayoutPreset layout;
  final List<String> setupNames;
  final String selectedSetupName;
  final List<String> templateNames;

  final FileOpCtrModel exportCtr;
  final Directory? selectedDir;
  final bool hasSaved;
  final bool isRunning;

  final ValueChanged<rust_config.DocumentLayoutPreset> onLayoutChanged;
  final ValueChanged<String> onSetupSelected;
  final VoidCallback onSaveSetupAs;
  final VoidCallback onDeleteSetup;
  final VoidCallback onExportSetup;
  final VoidCallback onImportSetup;

  final ValueChanged<String?> onFileNameChanged;
  final Future<void> Function() onSelectDir;
  final VoidCallback onClearDir;
  final VoidCallback? onExportPressed;
  final int selectedCount;
  final int totalCount;
  final VoidCallback onSelectSpecimens;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FileOperationPage(
            children: [
              const FileFormatIcon(path: 'assets/icons/pdf.svg'),
              DocumentLayoutSection(
                layout: layout,
                setupNames: setupNames,
                selectedSetupName: selectedSetupName,
                templateNames: templateNames,
                onLayoutChanged: onLayoutChanged,
                onSetupSelected: onSetupSelected,
                onSaveSetupAs: onSaveSetupAs,
                onDeleteSetup: onDeleteSetup,
                onExportSetup: onExportSetup,
                onImportSetup: onImportSetup,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Specimens',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$selectedCount of $totalCount selected',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onSelectSpecimens,
                      icon: const Icon(
                        Icons.table_rows_outlined,
                      ),
                      label: const Text('Select'),
                    ),
                  ],
                ),
              ),
              FileNameField(
                controller: exportCtr,
                onChanged: onFileNameChanged,
              ),
              const SizedBox(height: 10),
              SelectDirField(
                dirPath: selectedDir,
                onPressed: onSelectDir,
                onCanceled: onClearDir,
              ),
              const SizedBox(height: 24),
              hasSaved
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(
                        'Saved successfully to: ${selectedDir!.path}/${exportCtr.fileNameCtr.text}.pdf',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ProgressButton(
                    label: 'Export Documents',
                    icon: Icons.upload_outlined,
                    isRunning: isRunning,
                    onPressed: isRunning ? null : onExportPressed,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DocumentLayoutSection extends StatelessWidget {
  const DocumentLayoutSection({
    super.key,
    required this.layout,
    required this.setupNames,
    required this.selectedSetupName,
    required this.templateNames,
    required this.onLayoutChanged,
    required this.onSetupSelected,
    required this.onSaveSetupAs,
    required this.onDeleteSetup,
    required this.onExportSetup,
    required this.onImportSetup,
  });

  final rust_config.DocumentLayoutPreset layout;
  final List<String> setupNames;
  final String selectedSetupName;
  final List<String> templateNames;
  final ValueChanged<rust_config.DocumentLayoutPreset> onLayoutChanged;
  final ValueChanged<String> onSetupSelected;
  final VoidCallback onSaveSetupAs;
  final VoidCallback onDeleteSetup;
  final VoidCallback onExportSetup;
  final VoidCallback onImportSetup;

  static const Map<String, String> _pageSizeLabels = {
    'A0': 'A0 (841 x 1188 mm)',
    'A1': 'A1 (594 x 841 mm)',
    'A2': 'A2 (420 x 594 mm)',
    'A3': 'A3 (297 x 420 mm)',
    'A4': 'A4 (210 x 297 mm)',
    'A5': 'A5 (148 x 210 mm)',
    'A6': 'A6 (105 x 148 mm)',
    'A7': 'A7 (74 x 105 mm)',
    'A8': 'A8 (52 x 74 mm)',
    'Letter': 'US Letter (8.5 x 11 in)',
    'Legal': 'US Legal',
    'Custom': 'Custom',
  };

  static const Map<String, String> _pageOrientationLabels = {
    'portrait': 'Portrait',
    'landscape': 'Landscape',
  };

  static const Map<String, String> _layoutTypeLabels = {
    'WholePage': 'Whole Page',
    'Continuous': 'Continuous Roll',
  };

  double _parseMmOrCurrent(String value, double current) {
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return current;
    return parsed.clamp(0.0, 1000.0);
  }

  int _parseIntOrCurrent(String value, int current) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return current;
    return parsed.clamp(1, 200);
  }

  void _addBlock() {
    final newBlocks = List<rust_config.DocumentLayoutBlock>.from(layout.blocks);
    final defaultTemplate =
        templateNames.isNotEmpty ? templateNames.first : 'Default';
    newBlocks.add(rust_config.DocumentLayoutBlock(
      templateName: defaultTemplate,
      labelCount: 1,
      rows: 8,
      cols: 4,
      labelPadTopMm: 1.0,
      labelPadLeftMm: 1.0,
      labelPadRightMm: 1.0,
      labelPadBottomMm: 1.0,
      pageBreakAfter: false,
    ));
    onLayoutChanged(layout.copyWith(blocks: newBlocks));
  }

  void _updateBlock(int index, rust_config.DocumentLayoutBlock block) {
    final newBlocks = List<rust_config.DocumentLayoutBlock>.from(layout.blocks);
    newBlocks[index] = block;
    onLayoutChanged(layout.copyWith(blocks: newBlocks));
  }

  void _deleteBlock(int index) {
    if (layout.blocks.length <= 1) return;
    final newBlocks = List<rust_config.DocumentLayoutBlock>.from(layout.blocks);
    newBlocks.removeAt(index);
    onLayoutChanged(layout.copyWith(blocks: newBlocks));
  }

  @override
  Widget build(BuildContext context) {
    final isContinuous = layout.layoutType == 'Continuous';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Document Layout',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<String>(
                  key: ValueKey('setup-$selectedSetupName'),
                  initialValue: selectedSetupName,
                  decoration: const InputDecoration(
                    labelText: 'Layout profile',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: setupNames
                      .map(
                        (n) => DropdownMenuItem<String>(
                          value: n,
                          child: Text(n),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onSetupSelected(v);
                  },
                ),
              ),
              OutlinedButton.icon(
                onPressed: onSaveSetupAs,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save As'),
              ),
              OutlinedButton.icon(
                onPressed:
                    selectedSetupName == 'Default' ? null : onDeleteSetup,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
              OutlinedButton.icon(
                onPressed: onImportSetup,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Import'),
              ),
              OutlinedButton.icon(
                onPressed: onExportSetup,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Export'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Page Setup',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  key: ValueKey('layout-type-${layout.layoutType}'),
                  initialValue: layout.layoutType,
                  decoration: const InputDecoration(
                    labelText: 'Layout style',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _layoutTypeLabels.entries
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      onLayoutChanged(layout.copyWith(layoutType: v));
                    }
                  },
                ),
              ),
              if (!isContinuous) ...[
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('page-size-${layout.pageSizeKey}'),
                    initialValue: layout.pageSizeKey,
                    decoration: const InputDecoration(
                      labelText: 'Page size',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _pageSizeLabels.entries
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        onLayoutChanged(layout.copyWith(pageSizeKey: v));
                      }
                    },
                  ),
                ),
                if (layout.pageSizeKey == 'Custom') ...[
                  NumberField(
                    label: 'Width mm',
                    initialValue:
                        (layout.customPageWidthMm ?? 210.0).toStringAsFixed(1),
                    onChanged: (value) {
                      onLayoutChanged(layout.copyWith(
                          customPageWidthMm: _parseMmOrCurrent(
                              value, layout.customPageWidthMm ?? 210.0)));
                    },
                  ),
                  NumberField(
                    label: 'Height mm',
                    initialValue:
                        (layout.customPageHeightMm ?? 297.0).toStringAsFixed(1),
                    onChanged: (value) {
                      onLayoutChanged(layout.copyWith(
                          customPageHeightMm: _parseMmOrCurrent(
                              value, layout.customPageHeightMm ?? 297.0)));
                    },
                  ),
                ],
                SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('orientation-${layout.pageOrientation}'),
                    initialValue: layout.pageOrientation,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Orientation',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _pageOrientationLabels.entries
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        onLayoutChanged(layout.copyWith(pageOrientation: v));
                      }
                    },
                  ),
                ),
                NumberField(
                  label: 'Page top',
                  initialValue: layout.pagePadTopMm.toStringAsFixed(1),
                  onChanged: (value) {
                    onLayoutChanged(layout.copyWith(
                        pagePadTopMm:
                            _parseMmOrCurrent(value, layout.pagePadTopMm)));
                  },
                ),
                NumberField(
                  label: 'Page left',
                  initialValue: layout.pagePadLeftMm.toStringAsFixed(1),
                  onChanged: (value) {
                    onLayoutChanged(layout.copyWith(
                        pagePadLeftMm:
                            _parseMmOrCurrent(value, layout.pagePadLeftMm)));
                  },
                ),
                NumberField(
                  label: 'Page right',
                  initialValue: layout.pagePadRightMm.toStringAsFixed(1),
                  onChanged: (value) {
                    onLayoutChanged(layout.copyWith(
                        pagePadRightMm:
                            _parseMmOrCurrent(value, layout.pagePadRightMm)));
                  },
                ),
                NumberField(
                  label: 'Page bottom',
                  initialValue: layout.pagePadBottomMm.toStringAsFixed(1),
                  onChanged: (value) {
                    onLayoutChanged(layout.copyWith(
                        pagePadBottomMm:
                            _parseMmOrCurrent(value, layout.pagePadBottomMm)));
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Layout Blocks',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextButton.icon(
                onPressed: _addBlock,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Block'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...layout.blocks.asMap().entries.map((entry) {
            final idx = entry.key;
            final block = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Block #${idx + 1}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (layout.blocks.length > 1)
                            IconButton(
                              onPressed: () => _deleteBlock(idx),
                              icon: const Icon(Icons.delete_sweep_outlined,
                                  color: Colors.red),
                              tooltip: 'Delete Block',
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            child: DropdownButtonFormField<String>(
                              key: ValueKey(
                                  'block-template-$idx-${block.templateName}'),
                              initialValue:
                                  templateNames.contains(block.templateName)
                                      ? block.templateName
                                      : (templateNames.isNotEmpty
                                          ? templateNames.first
                                          : null),
                              decoration: const InputDecoration(
                                labelText: 'Template preset',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: templateNames
                                  .map(
                                    (name) => DropdownMenuItem<String>(
                                      value: name,
                                      child: Text(name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  _updateBlock(
                                      idx, block.copyWith(templateName: v));
                                }
                              },
                            ),
                          ),
                          NumberField(
                            label: 'Copies',
                            initialValue: '${block.labelCount}',
                            onChanged: (value) {
                              _updateBlock(
                                idx,
                                block.copyWith(
                                  labelCount: _parseIntOrCurrent(
                                      value, block.labelCount),
                                ),
                              );
                            },
                          ),
                          if (!isContinuous) ...[
                            NumberField(
                              label: 'Rows',
                              initialValue: '${block.rows}',
                              onChanged: (value) {
                                _updateBlock(
                                  idx,
                                  block.copyWith(
                                    rows: _parseIntOrCurrent(value, block.rows),
                                  ),
                                );
                              },
                            ),
                            NumberField(
                              label: 'Cols',
                              initialValue: '${block.cols}',
                              onChanged: (value) {
                                _updateBlock(
                                  idx,
                                  block.copyWith(
                                    cols: _parseIntOrCurrent(value, block.cols),
                                  ),
                                );
                              },
                            ),
                          ],
                          NumberField(
                            label: 'Label top',
                            initialValue:
                                block.labelPadTopMm.toStringAsFixed(1),
                            onChanged: (value) {
                              _updateBlock(
                                idx,
                                block.copyWith(
                                  labelPadTopMm: _parseMmOrCurrent(
                                      value, block.labelPadTopMm),
                                ),
                              );
                            },
                          ),
                          NumberField(
                            label: 'Label left',
                            initialValue:
                                block.labelPadLeftMm.toStringAsFixed(1),
                            onChanged: (value) {
                              _updateBlock(
                                idx,
                                block.copyWith(
                                  labelPadLeftMm: _parseMmOrCurrent(
                                      value, block.labelPadLeftMm),
                                ),
                              );
                            },
                          ),
                          NumberField(
                            label: 'Label right',
                            initialValue:
                                block.labelPadRightMm.toStringAsFixed(1),
                            onChanged: (value) {
                              _updateBlock(
                                idx,
                                block.copyWith(
                                  labelPadRightMm: _parseMmOrCurrent(
                                      value, block.labelPadRightMm),
                                ),
                              );
                            },
                          ),
                          NumberField(
                            label: 'Label bottom',
                            initialValue:
                                block.labelPadBottomMm.toStringAsFixed(1),
                            onChanged: (value) {
                              _updateBlock(
                                idx,
                                block.copyWith(
                                  labelPadBottomMm: _parseMmOrCurrent(
                                      value, block.labelPadBottomMm),
                                ),
                              );
                            },
                          ),
                          if (!isContinuous)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Page break after'),
                                Checkbox(
                                  value: block.pageBreakAfter,
                                  onChanged: (v) {
                                    if (v != null) {
                                      _updateBlock(idx,
                                          block.copyWith(pageBreakAfter: v));
                                    }
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class NumberField extends StatefulWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      if (!_focusNode.hasFocus) {
        _controller.text = widget.initialValue;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: widget.onChanged,
      ),
    );
  }
}
