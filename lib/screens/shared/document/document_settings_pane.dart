import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/services/document_layout_service.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/providers/document_selection.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/screens/shared/document/specimen_selection.dart';
import 'package:nahpu/screens/shared/document/record_selection.dart';
class DocumentSettingsPane extends StatelessWidget {
  const DocumentSettingsPane({
    super.key,
    required this.layout,
    required this.setupNames,
    required this.selectedSetupName,
    required this.templateNames,
    required this.exportCtr,
    required this.selectedDir,
    required this.isRunning,
    required this.onLayoutChanged,
    required this.onSetupSelected,
    required this.onFileNameChanged,
    required this.onSelectDir,
    required this.onClearDir,
    required this.onExportPressed,
    this.selectedCount = 0,
    this.totalCount = 0,
    this.onSelectSpecimens,
    required this.onManagePresets,
    required this.recordType,
    this.showSpecimenSelection = false,
  });

  final rust_config.DocumentLayoutPreset layout;
  final List<String> setupNames;
  final String selectedSetupName;
  final List<String> templateNames;

  final FileOpCtrModel exportCtr;
  final Directory? selectedDir;
  final bool isRunning;

  final ValueChanged<rust_config.DocumentLayoutPreset> onLayoutChanged;
  final ValueChanged<String> onSetupSelected;

  final ValueChanged<String?> onFileNameChanged;
  final Future<void> Function() onSelectDir;
  final VoidCallback onClearDir;
  final VoidCallback? onExportPressed;
  final int selectedCount;
  final int totalCount;
  final VoidCallback? onSelectSpecimens;
  final VoidCallback onManagePresets;
  final RecordType recordType;
  final bool showSpecimenSelection;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FileOperationPage(
            children: [
              const FileFormatIcon(path: 'assets/icons/pdf.svg'),
              if (!showSpecimenSelection && onSelectSpecimens != null) ...[
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
                              recordType == RecordType.site
                                  ? 'Sites'
                                  : recordType == RecordType.collEvent
                                      ? 'Collecting Events'
                                      : recordType == RecordType.narrative
                                          ? 'Narratives'
                                          : 'Specimens',
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
                const SizedBox(height: 8),
              ],
              DocumentLayoutSection(
                layout: layout,
                setupNames: setupNames,
                selectedSetupName: selectedSetupName,
                templateNames: templateNames,
                onLayoutChanged: onLayoutChanged,
                onSetupSelected: onSetupSelected,
                showPresetActions: false,
                showBlocks: showSpecimenSelection ? true : false,
                showSpecimenSelection: showSpecimenSelection,
                onManagePresets: onManagePresets,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File settings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    FileNameField(
                      controller: exportCtr,
                      onChanged: onFileNameChanged,
                    ),
                    if (!Platform.isIOS && !Platform.isAndroid) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Save to',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedDir != null
                                      ? selectedDir!.path
                                      : 'Select directory',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          selectedDir == null
                              ? OutlinedButton.icon(
                                  onPressed: onSelectDir,
                                  icon: const Icon(
                                    Icons.folder_outlined,
                                  ),
                                  label: const Text('Browse'),
                                )
                              : IconButton(
                                  onPressed: onClearDir,
                                  icon: const Icon(Icons.clear_rounded),
                                ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
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

class DocumentLayoutSection extends ConsumerStatefulWidget {
  const DocumentLayoutSection({
    super.key,
    required this.layout,
    required this.setupNames,
    required this.selectedSetupName,
    required this.templateNames,
    required this.onLayoutChanged,
    required this.onSetupSelected,
    this.onCreatePreset,
    this.onSaveSetupAs,
    this.onDeleteSetup,
    this.onExportSetup,
    this.onImportSetup,
    this.onCreateTemplate,
    this.showFileActions = true,
    this.showPresetActions = true,
    this.showBlocks = true,
    this.onManagePresets,
    this.incompatibleSetupNames = const {},
    this.showProfileDropdown = true,
    this.showSpecimenSelection = false,
  });

  final rust_config.DocumentLayoutPreset layout;
  final List<String> setupNames;
  final String selectedSetupName;
  final List<String> templateNames;
  final ValueChanged<rust_config.DocumentLayoutPreset> onLayoutChanged;
  final ValueChanged<String> onSetupSelected;
  final VoidCallback? onCreatePreset;
  final VoidCallback? onSaveSetupAs;
  final VoidCallback? onDeleteSetup;
  final VoidCallback? onExportSetup;
  final VoidCallback? onImportSetup;
  final VoidCallback? onCreateTemplate;
  final bool showFileActions;
  final bool showPresetActions;
  final bool showBlocks;
  final VoidCallback? onManagePresets;
  final Set<String> incompatibleSetupNames;
  final bool showProfileDropdown;
  final bool showSpecimenSelection;

  @override
  ConsumerState<DocumentLayoutSection> createState() => _DocumentLayoutSectionState();
}

class _DocumentLayoutSectionState extends ConsumerState<DocumentLayoutSection> {
  bool _showMorePageSetup = false;
  bool _showAdvanced = false;
  final Map<int, bool> _expandedBlocks = {};

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
    final newBlocks =
        List<rust_config.DocumentLayoutBlock>.from(widget.layout.blocks);
    final defaultTemplate = widget.templateNames.isNotEmpty
        ? widget.templateNames.first
        : 'Default';
    newBlocks.add(rust_config.DocumentLayoutBlock(
      templateName: defaultTemplate,
      templateCount: 1,
      rows: 8,
      cols: 4,
      templatePadTopMm: 1.0,
      templatePadLeftMm: 1.0,
      templatePadRightMm: 1.0,
      templatePadBottomMm: 1.0,
      pageBreakAfter: false,
    ));
    widget.onLayoutChanged(widget.layout.copyWith(blocks: newBlocks));
  }

  void _updateBlock(int index, rust_config.DocumentLayoutBlock block) {
    final newBlocks =
        List<rust_config.DocumentLayoutBlock>.from(widget.layout.blocks);
    newBlocks[index] = block;
    widget.onLayoutChanged(widget.layout.copyWith(blocks: newBlocks));
  }

  void _deleteBlock(int index) {
    if (widget.layout.blocks.length <= 1) return;
    final newBlocks =
        List<rust_config.DocumentLayoutBlock>.from(widget.layout.blocks);
    newBlocks.removeAt(index);
    widget.onLayoutChanged(widget.layout.copyWith(blocks: newBlocks));
  }

  @override
  Widget build(BuildContext context) {
    final isContinuous = widget.layout.layoutType == 'Continuous';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showProfileDropdown) ...[
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
                    key: ValueKey('setup-${widget.selectedSetupName}'),
                    initialValue: widget.selectedSetupName,
                    decoration: const InputDecoration(
                      labelText: 'Layout profile',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: widget.setupNames
                        .map(
                          (n) => DropdownMenuItem<String>(
                            value: n,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.incompatibleSetupNames
                                    .contains(n)) ...[
                                  Icon(
                                    Icons.warning_amber_outlined,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(child: Text(n)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) widget.onSetupSelected(v);
                    },
                  ),
                ),
                if (widget.showPresetActions) ...[
                  OutlinedButton.icon(
                    onPressed: widget.onCreatePreset,
                    icon: const Icon(Icons.add),
                    label: const Text('New'),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.onSaveSetupAs,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save As'),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.selectedSetupName == 'Default'
                        ? null
                        : widget.onDeleteSetup,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                  if (widget.showFileActions) ...[
                    OutlinedButton.icon(
                      onPressed: widget.onImportSetup,
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Import'),
                    ),
                    OutlinedButton.icon(
                      onPressed: widget.onExportSetup,
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Export'),
                    ),
                  ],
                ] else if (widget.onManagePresets != null) ...[
                  OutlinedButton.icon(
                    onPressed: widget.onManagePresets,
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Presets'),
                  ),
                ],
              ],
            ),
          ],
          if (widget.showProfileDropdown) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
          ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page Setup',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showMorePageSetup = !_showMorePageSetup;
                    });
                  },
                  icon: Icon(
                    _showMorePageSetup ? Icons.expand_less : Icons.expand_more,
                  ),
                  label: Text(_showMorePageSetup ? 'Show less' : 'Show more'),
                ),
              ],
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
                  key: ValueKey('layout-type-${widget.layout.layoutType}'),
                  initialValue: widget.layout.layoutType,
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
                      widget.onLayoutChanged(
                          widget.layout.copyWith(layoutType: v));
                    }
                  },
                ),
              ),
              if (!isContinuous) ...[
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('page-size-${widget.layout.pageSizeKey}'),
                    initialValue: widget.layout.pageSizeKey,
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
                        widget.onLayoutChanged(
                            widget.layout.copyWith(pageSizeKey: v));
                      }
                    },
                  ),
                ),
                if (_showMorePageSetup) ...[
                  if (widget.layout.pageSizeKey == 'Custom') ...[
                    NumberField(
                      label: 'Width mm',
                      initialValue: (widget.layout.customPageWidthMm ?? 210.0)
                          .toStringAsFixed(1),
                      onChanged: (value) {
                        widget.onLayoutChanged(widget.layout.copyWith(
                            customPageWidthMm: _parseMmOrCurrent(value,
                                widget.layout.customPageWidthMm ?? 210.0)));
                      },
                    ),
                    NumberField(
                      label: 'Height mm',
                      initialValue: (widget.layout.customPageHeightMm ?? 297.0)
                          .toStringAsFixed(1),
                      onChanged: (value) {
                        widget.onLayoutChanged(widget.layout.copyWith(
                            customPageHeightMm: _parseMmOrCurrent(value,
                                widget.layout.customPageHeightMm ?? 297.0)));
                      },
                    ),
                  ],
                  SizedBox(
                    width: 160,
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(
                          'orientation-${widget.layout.pageOrientation}'),
                      initialValue: widget.layout.pageOrientation,
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
                          widget.onLayoutChanged(
                              widget.layout.copyWith(pageOrientation: v));
                        }
                      },
                    ),
                  ),
                  NumberField(
                    label: 'Page top',
                    initialValue: widget.layout.pagePadTopMm.toStringAsFixed(1),
                    onChanged: (value) {
                      widget.onLayoutChanged(widget.layout.copyWith(
                          pagePadTopMm: _parseMmOrCurrent(
                              value, widget.layout.pagePadTopMm)));
                    },
                  ),
                  NumberField(
                    label: 'Page left',
                    initialValue:
                        widget.layout.pagePadLeftMm.toStringAsFixed(1),
                    onChanged: (value) {
                      widget.onLayoutChanged(widget.layout.copyWith(
                          pagePadLeftMm: _parseMmOrCurrent(
                              value, widget.layout.pagePadLeftMm)));
                    },
                  ),
                  NumberField(
                    label: 'Page right',
                    initialValue:
                        widget.layout.pagePadRightMm.toStringAsFixed(1),
                    onChanged: (value) {
                      widget.onLayoutChanged(widget.layout.copyWith(
                          pagePadRightMm: _parseMmOrCurrent(
                              value, widget.layout.pagePadRightMm)));
                    },
                  ),
                  NumberField(
                    label: 'Page bottom',
                    initialValue:
                        widget.layout.pagePadBottomMm.toStringAsFixed(1),
                    onChanged: (value) {
                      widget.onLayoutChanged(widget.layout.copyWith(
                          pagePadBottomMm: _parseMmOrCurrent(
                              value, widget.layout.pagePadBottomMm)));
                    },
                  ),
                ],
              ],
            ],
          ),
          if (!widget.showPresetActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Advanced options',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Switch(
                  value: _showAdvanced,
                  onChanged: (v) {
                    setState(() {
                      _showAdvanced = v;
                    });
                  },
                ),
              ],
            ),
          ],
          if (widget.showPresetActions || _showAdvanced) ...[
            if (widget.showBlocks) ...[
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
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: widget.onCreateTemplate,
                      icon: const Icon(Icons.edit_note_outlined),
                      label: const Text('Create Preset'),
                    ),
                    TextButton.icon(
                      onPressed: _addBlock,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add Block'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...widget.layout.blocks.asMap().entries.map((entry) {
              final idx = entry.key;
              final block = entry.value;
              final isExpanded = _expandedBlocks[idx] ?? false;
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _expandedBlocks[idx] = !isExpanded;
                                    });
                                  },
                                  icon: Icon(isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more),
                                  label: Text(
                                      isExpanded ? 'Show less' : 'Show more'),
                                ),
                                if (widget.layout.blocks.length > 1)
                                  IconButton(
                                    onPressed: () => _deleteBlock(idx),
                                    icon: const Icon(
                                        Icons.delete_sweep_outlined,
                                        color: Colors.red),
                                    tooltip: 'Delete Block',
                                  ),
                              ],
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
                                initialValue: widget.templateNames
                                        .contains(block.templateName)
                                    ? block.templateName
                                    : (widget.templateNames.isNotEmpty
                                        ? widget.templateNames.first
                                        : null),
                                decoration: const InputDecoration(
                                  labelText: 'Template preset',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: widget.templateNames
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
                              initialValue: '${block.templateCount}',
                              onChanged: (value) {
                                _updateBlock(
                                  idx,
                                  block.copyWith(
                                    templateCount: _parseIntOrCurrent(
                                        value, block.templateCount),
                                  ),
                                );
                              },
                            ),
                            if (isExpanded) ...[
                              if (!isContinuous)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    NumberField(
                                      label: 'Rows',
                                      initialValue: '${block.rows}',
                                      onChanged: (value) {
                                        _updateBlock(
                                          idx,
                                          block.copyWith(
                                            rows: _parseIntOrCurrent(
                                                value, block.rows),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    NumberField(
                                      label: 'Cols',
                                      initialValue: '${block.cols}',
                                      onChanged: (value) {
                                        _updateBlock(
                                          idx,
                                          block.copyWith(
                                            cols: _parseIntOrCurrent(
                                                value, block.cols),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              NumberField(
                                label: 'Template top',
                                initialValue:
                                    block.templatePadTopMm.toStringAsFixed(1),
                                onChanged: (value) {
                                  _updateBlock(
                                    idx,
                                    block.copyWith(
                                      templatePadTopMm: _parseMmOrCurrent(
                                          value, block.templatePadTopMm),
                                    ),
                                  );
                                },
                              ),
                              NumberField(
                                label: 'Template left',
                                initialValue:
                                    block.templatePadLeftMm.toStringAsFixed(1),
                                onChanged: (value) {
                                  _updateBlock(
                                    idx,
                                    block.copyWith(
                                      templatePadLeftMm: _parseMmOrCurrent(
                                          value, block.templatePadLeftMm),
                                    ),
                                  );
                                },
                              ),
                              NumberField(
                                label: 'Template right',
                                initialValue:
                                    block.templatePadRightMm.toStringAsFixed(1),
                                onChanged: (value) {
                                  _updateBlock(
                                    idx,
                                    block.copyWith(
                                      templatePadRightMm: _parseMmOrCurrent(
                                          value, block.templatePadRightMm),
                                    ),
                                  );
                                },
                              ),
                              NumberField(
                                label: 'Template bottom',
                                initialValue: block.templatePadBottomMm
                                    .toStringAsFixed(1),
                                onChanged: (value) {
                                  _updateBlock(
                                    idx,
                                    block.copyWith(
                                      templatePadBottomMm: _parseMmOrCurrent(
                                          value, block.templatePadBottomMm),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                        if (!isContinuous && isExpanded) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Page break after',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Checkbox(
                                    value: block.pageBreakAfter,
                                    onChanged: (v) {
                                      if (v != null) {
                                        _updateBlock(idx,
                                            block.copyWith(pageBreakAfter: v));
                                      }
                                    },
                                  ),
                                  const Text(
                                      'Insert page break after this block'),
                                ],
                              ),
                            ],
                          ),
                        ],
                        if (widget.showSpecimenSelection) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Consumer(
                            builder: (context, ref, child) {
                              final recordTypeAsync = ref.watch(templateRecordTypeProvider(block.templateName));
                              return recordTypeAsync.when(
                                data: (recordType) {
                                  final param = BlockRecordSelectionParam(blockIndex: idx, recordType: recordType);
                                  final selectedIds = ref.watch(blockRecordSelectionProvider(param));
                                  
                                  int totalCount = 0;
                                  String label = '';
                                  if (recordType == RecordType.specimenRecord) {
                                    totalCount = ref.watch(specimenEntryProvider).value?.length ?? 0;
                                    label = 'Specimens';
                                  } else if (recordType == RecordType.site) {
                                    totalCount = ref.watch(siteEntryProvider).value?.length ?? 0;
                                    label = 'Sites';
                                  } else if (recordType == RecordType.collEvent) {
                                    totalCount = ref.watch(collEventEntryProvider).value?.length ?? 0;
                                    label = 'Collecting Events';
                                  } else if (recordType == RecordType.narrative) {
                                    totalCount = ref.watch(narrativeEntryProvider).value?.length ?? 0;
                                    label = 'Narratives';
                                  }
                                  
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$label Selection',
                                              style: Theme.of(context).textTheme.titleSmall,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${selectedIds.length} of $totalCount selected',
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () async {
                                          if (recordType == RecordType.specimenRecord) {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Scaffold(
                                                  appBar: AppBar(
                                                    title: const Text('Select specimens'),
                                                  ),
                                                  body: SafeArea(
                                                    child: SpecimenSelectionView(
                                                      selectedUuidList: selectedIds,
                                                      visibleColumnIds: const [],
                                                      onSelectionChanged: (nextSelection) {
                                                        ref.read(blockRecordSelectionProvider(param).notifier).updateSelection(nextSelection);
                                                      },
                                                      onColumnsChanged: () {},
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else if (recordType == RecordType.site) {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SiteSelectionScreen(
                                                  selectedIds: selectedIds.map((e) => int.tryParse(e) ?? 0).toSet(),
                                                  onSelectionChanged: (nextSelection) {
                                                    ref.read(blockRecordSelectionProvider(param).notifier).updateSelection(
                                                      nextSelection.map((e) => e.toString()).toSet(),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          } else if (recordType == RecordType.collEvent) {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EventSelectionScreen(
                                                  selectedIds: selectedIds.map((e) => int.tryParse(e) ?? 0).toSet(),
                                                  onSelectionChanged: (nextSelection) {
                                                    ref.read(blockRecordSelectionProvider(param).notifier).updateSelection(
                                                      nextSelection.map((e) => e.toString()).toSet(),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          } else if (recordType == RecordType.narrative) {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => NarrativeSelectionScreen(
                                                  selectedIds: selectedIds.map((e) => int.tryParse(e) ?? 0).toSet(),
                                                  onSelectionChanged: (nextSelection) {
                                                    ref.read(blockRecordSelectionProvider(param).notifier).updateSelection(
                                                      nextSelection.map((e) => e.toString()).toSet(),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.table_rows_outlined),
                                        label: const Text('Select'),
                                      ),
                                    ],
                                  );
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
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
