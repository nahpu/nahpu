import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/services/templates/document_layout_service.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/file/file_settings.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/document_selection.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/templates/print_specimen_table_columns.dart';
import 'package:nahpu/services/templates/template_field_catalog.dart';
import 'package:nahpu/services/templates/template_table_preview_settings_service.dart';
import 'package:nahpu/screens/shared/document/column_picker.dart';
import 'package:nahpu/screens/shared/document/specimen_selection.dart';
import 'package:nahpu/screens/shared/document/specimen_part_selection.dart';
import 'package:nahpu/screens/shared/document/record_selection.dart';

class DocumentSettingsPane extends StatelessWidget {
  const DocumentSettingsPane({
    super.key,
    required this.layout,
    required this.setupNames,
    required this.selectedSetupName,
    required this.templateNames,
    required this.exportCtr,
    required this.isRunning,
    required this.appendDate,
    required this.onLayoutChanged,
    required this.onSetupSelected,
    required this.onFileNameChanged,
    required this.onAppendDateChanged,
    required this.locationCard,
    this.selectedCount = 0,
    this.totalCount = 0,
    this.onSelectSpecimens,
    required this.onManagePresets,
    this.onEditTemplate,
    required this.recordType,
    this.showSpecimenSelection = false,
  });

  final rust_config.DocumentLayoutPreset layout;
  final List<String> setupNames;
  final String selectedSetupName;
  final List<String> templateNames;

  final FileOpCtrModel exportCtr;
  final bool isRunning;
  final bool appendDate;

  final ValueChanged<rust_config.DocumentLayoutPreset> onLayoutChanged;
  final ValueChanged<String> onSetupSelected;

  final ValueChanged<String?> onFileNameChanged;
  final ValueChanged<bool> onAppendDateChanged;

  /// The destination, shown directly under the file settings it belongs to.
  final Widget locationCard;

  final int selectedCount;
  final int totalCount;
  final VoidCallback? onSelectSpecimens;
  final VoidCallback onManagePresets;
  final ValueChanged<String>? onEditTemplate;
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
                _RecordSelectionSummary(
                  label: _getRecordTypeLabel(context.l10n),
                  selectedCount: selectedCount,
                  totalCount: totalCount,
                  onSelect: onSelectSpecimens,
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
                showBlocks: showSpecimenSelection ? true : false,
                showSpecimenSelection: showSpecimenSelection,
                onManagePresets: onManagePresets,
                onEditTemplate: onEditTemplate,
              ),
              const SizedBox(height: 16),
              _FileSettingsSection(
                exportCtr: exportCtr,
                appendDate: appendDate,
                enabled: !isRunning,
                onFileNameChanged: onFileNameChanged,
                onAppendDateChanged: onAppendDateChanged,
              ),
              const SizedBox(height: 16),
              locationCard,
            ],
          ),
        ],
      ),
    );
  }

  String _getRecordTypeLabel(AppLocalizations l10n) {
    switch (recordType) {
      case RecordType.specimenRecord:
        return l10n.documentRecordsSpecimens;
      case RecordType.site:
        return l10n.documentRecordsSites;
      case RecordType.collEvent:
        return l10n.documentRecordsEvents;
      case RecordType.narrative:
        return l10n.documentRecordsNarratives;
      default:
        return l10n.documentRecordsGeneric;
    }
  }
}

class _RecordSelectionSummary extends StatelessWidget {
  const _RecordSelectionSummary({
    required this.label,
    required this.selectedCount,
    required this.totalCount,
    required this.onSelect,
  });

  final String label;
  final int selectedCount;
  final int totalCount;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    return NahpuPanel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  context.l10n.documentSelectedCount(selectedCount, totalCount),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onSelect,
            icon: const Icon(Icons.table_rows_outlined),
            label: Text(context.l10n.commonSelect),
          ),
        ],
      ),
    );
  }
}

class _FileSettingsSection extends StatelessWidget {
  const _FileSettingsSection({
    required this.exportCtr,
    required this.appendDate,
    required this.enabled,
    required this.onFileNameChanged,
    required this.onAppendDateChanged,
  });

  final FileOpCtrModel exportCtr;
  final bool appendDate;
  final bool enabled;
  final ValueChanged<String?> onFileNameChanged;
  final ValueChanged<bool> onAppendDateChanged;

  @override
  Widget build(BuildContext context) {
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.documentFileSettings,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          FileNameField(
            controller: exportCtr.fileNameCtr,
            extension: 'pdf',
            appendDate: appendDate,
            enabled: enabled,
            onChanged: onFileNameChanged,
          ),
          AppendDateSwitch(
            value: appendDate,
            enabled: enabled,
            onChanged: onAppendDateChanged,
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
    this.onEditTemplate,
    this.showFileActions = true,
    this.showBlocks = true,
    this.showBlockOverrideToggle = true,
    this.onManagePresets,
    this.incompatibleSetupNames = const {},
    this.showProfileDropdown = true,
    this.showSpecimenSelection = false,
    this.showBlockOrderingImmediately = false,
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
  final ValueChanged<String>? onEditTemplate;
  final bool showFileActions;
  final bool showBlocks;
  final bool showBlockOverrideToggle;
  final VoidCallback? onManagePresets;
  final Set<String> incompatibleSetupNames;
  final bool showProfileDropdown;
  final bool showSpecimenSelection;
  final bool showBlockOrderingImmediately;

  @override
  ConsumerState<DocumentLayoutSection> createState() =>
      _DocumentLayoutSectionState();
}

class _DocumentLayoutSectionState extends ConsumerState<DocumentLayoutSection> {
  bool _showMorePageSetup = false;
  bool _overrideTemplateBlocks = false;
  final Map<int, bool> _expandedBlocks = {};

  static const double _wideFieldWidth = 240;
  static const double _blockTemplateFieldWidth = 220;

  /// Page size keys, which are saved in the layout, with their UI labels.
  static Map<String, String> _pageSizeLabels(AppLocalizations l10n) => {
    'A0': 'A0 (841 x 1188 mm)',
    'A1': 'A1 (594 x 841 mm)',
    'A2': 'A2 (420 x 594 mm)',
    'A3': 'A3 (297 x 420 mm)',
    'A4': 'A4 (210 x 297 mm)',
    'A5': 'A5 (148 x 210 mm)',
    'A6': 'A6 (105 x 148 mm)',
    'A7': 'A7 (74 x 105 mm)',
    'A8': 'A8 (52 x 74 mm)',
    'Letter': l10n.documentPageSizeLetter,
    'Legal': l10n.documentPageSizeLegal,
    'Custom': l10n.documentPageSizeCustom,
  };

  /// Orientation keys, which are saved in the layout, with their UI labels.
  static Map<String, String> _pageOrientationLabels(AppLocalizations l10n) => {
    'portrait': l10n.documentOrientationPortrait,
    'landscape': l10n.documentOrientationLandscape,
  };

  @override
  Widget build(BuildContext context) {
    const isContinuous = false;
    final l10n = context.l10n;

    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showProfileDropdown) ...[
            _LayoutProfileControls(
              selectedSetupName: widget.selectedSetupName,
              setupNames: widget.setupNames,
              incompatibleSetupNames: widget.incompatibleSetupNames,
              onSetupSelected: widget.onSetupSelected,
              onManagePresets: widget.onManagePresets,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
          ],
          if (!isContinuous)
            _PageSetupControls(
              layout: widget.layout,
              showMore: _showMorePageSetup,
              wideFieldWidth: _wideFieldWidth,
              pageSizeLabels: _pageSizeLabels(l10n),
              pageOrientationLabels: _pageOrientationLabels(l10n),
              onToggleShowMore: _togglePageSetup,
              onLayoutChanged: widget.onLayoutChanged,
              parseMmOrCurrent: _parseMmOrCurrent,
            ),
          if (widget.showBlocks && widget.showBlockOverrideToggle) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  l10n.documentOverrideBlocks,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Switch(
                  value: _overrideTemplateBlocks,
                  onChanged: (value) {
                    setState(() {
                      _overrideTemplateBlocks = value;
                    });
                  },
                ),
              ],
            ),
          ],
          if (_overrideTemplateBlocks || !widget.showBlockOverrideToggle) ...[
            if (widget.showBlocks) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.documentTemplateBlocks,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextButton.icon(
                    onPressed: _addBlock,
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(l10n.documentAddBlock),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.layout.blocks.length > 1) ...[
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  key: ValueKey(
                    'multi-block-mode-${widget.layout.multiBlockMode}',
                  ),
                  initialValue: widget.layout.multiBlockMode,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.documentMultiBlockMode,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Continuous',
                      child: Text(
                        l10n.documentMultiBlockContinuous,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Alternate',
                      child: Text(
                        l10n.documentMultiBlockAlternate,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      widget.onLayoutChanged(
                        widget.layout.copyWith(multiBlockMode: v),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
              ...widget.layout.blocks.asMap().entries.map((entry) {
                final idx = entry.key;
                final block = entry.value;
                final isExpanded = _expandedBlocks[idx] ?? false;
                final templateExists = widget.templateNames.contains(
                  block.templateName,
                );
                final selectedTemplateName = block.templateName;
                final templateNames = [
                  if (!templateExists) block.templateName,
                  ...widget.templateNames,
                ];
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
                                l10n.documentBlockNumber(idx + 1),
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
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
                                    icon: Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                    ),
                                    label: Text(
                                      isExpanded
                                          ? l10n.documentShowLess
                                          : l10n.documentShowMore,
                                    ),
                                  ),
                                  if (widget.layout.blocks.length > 1)
                                    IconButton(
                                      onPressed: () => _deleteBlock(idx),
                                      icon: const Icon(
                                        Icons.delete_sweep_outlined,
                                        color: Colors.red,
                                      ),
                                      tooltip: l10n.documentDeleteBlock,
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
                              _ResponsiveFieldBox(
                                width: _blockTemplateFieldWidth,
                                child: DropdownButtonFormField<String>(
                                  key: ValueKey(
                                    'block-template-$idx-${block.templateName}',
                                  ),
                                  initialValue: selectedTemplateName,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: l10n.documentBlockTemplate,
                                    border: const OutlineInputBorder(),
                                    isDense: true,
                                    errorText: templateExists
                                        ? null
                                        : l10n.documentTemplateMissing,
                                  ),
                                  selectedItemBuilder: (context) =>
                                      templateNames
                                          .map(
                                            (name) => Text(
                                              templateExists ||
                                                      name != block.templateName
                                                  ? name
                                                  : l10n.documentMissingItem(
                                                      name,
                                                    ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                          .toList(),
                                  items: templateNames
                                      .map(
                                        (name) => DropdownMenuItem<String>(
                                          value: name,
                                          child: Text(
                                            templateExists ||
                                                    name != block.templateName
                                                ? name
                                                : l10n.documentMissingItem(
                                                    name,
                                                  ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      _updateBlock(
                                        idx,
                                        block.copyWith(templateName: v),
                                      );
                                    }
                                  },
                                ),
                              ),
                              if (widget.onEditTemplate != null)
                                IconButton.outlined(
                                  onPressed: !templateExists
                                      ? null
                                      : () => widget.onEditTemplate!(
                                          selectedTemplateName,
                                        ),
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: l10n.documentEditTemplate,
                                ),
                              const SizedBox(width: 8),
                              NumberField(
                                label: l10n.documentBlockCopies,
                                initialValue: '${block.templateCount}',
                                onChanged: (value) {
                                  _updateBlock(
                                    idx,
                                    block.copyWith(
                                      templateCount: _parseIntOrCurrent(
                                        value,
                                        block.templateCount,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (widget.showBlockOrderingImmediately)
                                _BlockOrderControls(
                                  blockIndex: idx,
                                  block: block,
                                  onChanged: (updated) =>
                                      _updateBlock(idx, updated),
                                ),
                            ],
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 12),
                            if (!widget.showBlockOrderingImmediately) ...[
                              _BlockOrderControls(
                                blockIndex: idx,
                                block: block,
                                onChanged: (updated) =>
                                    _updateBlock(idx, updated),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (!isContinuous) ...[
                                  if (!_isAutoFillEnabled(block))
                                    NumberField(
                                      label: l10n.documentBlockRows,
                                      initialValue: '${block.fixedRows}',
                                      onChanged: (value) {
                                        _updateBlock(
                                          idx,
                                          block.copyWith(
                                            rows: _parseIntOrCurrent(
                                              value,
                                              block.fixedRows,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  NumberField(
                                    label: l10n.documentBlockCols,
                                    initialValue: '${block.cols}',
                                    onChanged: (value) {
                                      _updateBlock(
                                        idx,
                                        block.copyWith(
                                          cols: _parseIntOrCurrent(
                                            value,
                                            block.cols,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: _isAutoFillEnabled(block),
                                        onChanged: (v) {
                                          if (v != null) {
                                            _updateBlockAutoFill(idx, v);
                                          }
                                        },
                                      ),
                                      Text(l10n.documentAutoFillPage),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.documentTemplatePadding,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                NumberField(
                                  label: l10n.documentPaddingTop,
                                  initialValue: block.templatePadTopMm
                                      .toStringAsFixed(1),
                                  onChanged: (value) {
                                    _updateBlock(
                                      idx,
                                      block.copyWith(
                                        templatePadTopMm: _parseMmOrCurrent(
                                          value,
                                          block.templatePadTopMm,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                NumberField(
                                  label: l10n.documentPaddingLeft,
                                  initialValue: block.templatePadLeftMm
                                      .toStringAsFixed(1),
                                  onChanged: (value) {
                                    _updateBlock(
                                      idx,
                                      block.copyWith(
                                        templatePadLeftMm: _parseMmOrCurrent(
                                          value,
                                          block.templatePadLeftMm,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                NumberField(
                                  label: l10n.documentPaddingRight,
                                  initialValue: block.templatePadRightMm
                                      .toStringAsFixed(1),
                                  onChanged: (value) {
                                    _updateBlock(
                                      idx,
                                      block.copyWith(
                                        templatePadRightMm: _parseMmOrCurrent(
                                          value,
                                          block.templatePadRightMm,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                NumberField(
                                  label: l10n.documentPaddingBottom,
                                  initialValue: block.templatePadBottomMm
                                      .toStringAsFixed(1),
                                  onChanged: (value) {
                                    _updateBlock(
                                      idx,
                                      block.copyWith(
                                        templatePadBottomMm: _parseMmOrCurrent(
                                          value,
                                          block.templatePadBottomMm,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                          if (!isContinuous && isExpanded) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.documentPageBreakAfter,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: block.pageBreakAfter,
                                      onChanged: (v) {
                                        if (v != null) {
                                          _updateBlock(
                                            idx,
                                            block.copyWith(pageBreakAfter: v),
                                          );
                                        }
                                      },
                                    ),
                                    Text(l10n.documentPageBreakAfterHint),
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
                                final recordTypeAsync = ref.watch(
                                  templateRecordTypeProvider(
                                    block.templateName,
                                  ),
                                );
                                return recordTypeAsync.when(
                                  data: (recordType) {
                                    final param = BlockRecordSelectionParam(
                                      blockIndex: idx,
                                      recordType: recordType,
                                    );
                                    final selectedIds = ref.watch(
                                      blockRecordSelectionProvider(param),
                                    );

                                    int totalCount = 0;
                                    String label = '';
                                    if (recordType == RecordType.none) {
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  l10n.documentCurrentProjectSelection,
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.titleSmall,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  l10n.documentActiveProjectDocument,
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    if (recordType ==
                                        RecordType.specimenRecord) {
                                      totalCount =
                                          ref
                                              .watch(specimenEntryProvider)
                                              .value
                                              ?.length ??
                                          0;
                                      label = l10n.documentSelectionSpecimens;
                                    } else if (recordType ==
                                        RecordType.specimenParts) {
                                      totalCount =
                                          ref
                                              .watch(specimenPartEntryProvider)
                                              .value
                                              ?.length ??
                                          0;
                                      label =
                                          l10n.documentSelectionSpecimenParts;
                                    } else if (recordType == RecordType.site) {
                                      totalCount =
                                          ref
                                              .watch(siteEntryProvider)
                                              .value
                                              ?.length ??
                                          0;
                                      label = l10n.documentSelectionSites;
                                    } else if (recordType ==
                                        RecordType.collEvent) {
                                      totalCount =
                                          ref
                                              .watch(collEventEntryProvider)
                                              .value
                                              ?.length ??
                                          0;
                                      label = l10n.documentSelectionEvents;
                                    } else if (recordType ==
                                        RecordType.narrative) {
                                      totalCount =
                                          ref
                                              .watch(narrativeEntryProvider)
                                              .value
                                              ?.length ??
                                          0;
                                      label = l10n.documentSelectionNarratives;
                                    }
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                label,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleSmall,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                l10n.documentSelectedCount(
                                                  selectedIds.length,
                                                  totalCount,
                                                ),
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                        RecordNavigationButton(
                                          recordType: recordType,
                                          selectedIds: selectedIds,
                                          param: param,
                                        ),
                                      ],
                                    );
                                  },
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, _) => const SizedBox.shrink(),
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

  bool _isAutoFillEnabled(rust_config.DocumentLayoutBlock block) {
    return block.autoFillPage || widget.layout.fillPage;
  }

  void _updateBlockAutoFill(int index, bool enabled) {
    final blocks = widget.layout.blocks
        .map(
          (block) =>
              widget.layout.fillPage ? block.copyWithAutoFill(true) : block,
        )
        .toList();
    blocks[index] = blocks[index].copyWithAutoFill(enabled);
    widget.onLayoutChanged(
      widget.layout.copyWith(blocks: blocks, fillPage: false),
    );
  }

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

  void _togglePageSetup() {
    setState(() {
      _showMorePageSetup = !_showMorePageSetup;
    });
  }

  void _addBlock() {
    final newBlocks = List<rust_config.DocumentLayoutBlock>.from(
      widget.layout.blocks,
    );
    final defaultTemplate = widget.templateNames.isNotEmpty
        ? widget.templateNames.first
        : 'Default';
    newBlocks.add(
      rust_config.DocumentLayoutBlock(
        templateName: defaultTemplate,
        templateCount: 1,
        rows: 1,
        cols: 1,
        templatePadTopMm: 0,
        templatePadLeftMm: 0,
        templatePadRightMm: 0,
        templatePadBottomMm: 0,
        pageBreakAfter: false,
        sortField: null,
        sortDirection: rust_config.DocumentSortDirection.ascending,
      ),
    );
    widget.onLayoutChanged(widget.layout.copyWith(blocks: newBlocks));
  }

  void _updateBlock(int index, rust_config.DocumentLayoutBlock block) {
    final newBlocks = List<rust_config.DocumentLayoutBlock>.from(
      widget.layout.blocks,
    );
    newBlocks[index] = block;
    widget.onLayoutChanged(widget.layout.copyWith(blocks: newBlocks));
  }

  void _deleteBlock(int index) {
    if (widget.layout.blocks.length <= 1) return;
    final newBlocks = List<rust_config.DocumentLayoutBlock>.from(
      widget.layout.blocks,
    );
    newBlocks.removeAt(index);
    widget.onLayoutChanged(widget.layout.copyWith(blocks: newBlocks));
  }
}

class _BlockOrderControls extends ConsumerWidget {
  const _BlockOrderControls({
    required this.blockIndex,
    required this.block,
    required this.onChanged,
  });

  final int blockIndex;
  final rust_config.DocumentLayoutBlock block;
  final ValueChanged<rust_config.DocumentLayoutBlock> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordTypeAsync = ref.watch(
      templateRecordTypeProvider(block.templateName),
    );
    return recordTypeAsync.when(
      data: (recordType) {
        final groups = availableTemplateFieldGroups(
          ref.watch(databaseProvider),
          recordType,
        );
        final selectedField = block.sortField?.trim() ?? '';
        final l10n = context.l10n;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _ResponsiveFieldBox(
              width: 260,
              child: _OrderFieldPicker(
                key: ValueKey(
                  'block-order-field-$blockIndex-${block.templateName}-$selectedField',
                ),
                value: selectedField,
                groups: groups,
                onChanged: (field) {
                  onChanged(
                    field.isEmpty
                        ? block.copyWith(clearSortField: true)
                        : block.copyWith(sortField: field),
                  );
                },
              ),
            ),
            _ResponsiveFieldBox(
              width: 160,
              child: DropdownButtonFormField<rust_config.DocumentSortDirection>(
                key: ValueKey(
                  'block-order-direction-$blockIndex-${block.sortDirection.name}',
                ),
                initialValue: block.sortDirection,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.documentSortDirection,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  DropdownMenuItem(
                    value: rust_config.DocumentSortDirection.ascending,
                    child: Text(l10n.documentSortAscending),
                  ),
                  DropdownMenuItem(
                    value: rust_config.DocumentSortDirection.descending,
                    child: Text(l10n.documentSortDescending),
                  ),
                ],
                onChanged: selectedField.isEmpty
                    ? null
                    : (direction) {
                        if (direction != null) {
                          onChanged(block.copyWith(sortDirection: direction));
                        }
                      },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => Text(context.l10n.documentSortFieldsLoadError),
    );
  }
}

class _OrderFieldPicker extends StatelessWidget {
  const _OrderFieldPicker({
    super.key,
    required this.value,
    required this.groups,
    required this.onChanged,
  });

  final String value;
  final Map<String, List<String>> groups;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasSelection = value.isNotEmpty;
    final isMissing =
        hasSelection && !groups.values.any((fields) => fields.contains(value));
    final fieldTitle = hasSelection
        ? specimenColumnDisplayTitle(value)
        : l10n.documentSortOriginalOrder;
    final tableTitle = hasSelection
        ? databaseTableLocalizedTitle(context.l10n, _orderFieldTableName(value))
        : null;

    return Semantics(
      button: true,
      label: l10n.documentSortOrderBy,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () async {
          final selected = await _showOrderFieldPicker(
            context,
            groups: groups,
            selectedValue: value,
          );
          if (selected == null || !context.mounted) return;
          onChanged(selected);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: l10n.documentSortOrderBy,
            border: const OutlineInputBorder(),
            isDense: true,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMissing ? l10n.documentMissingItem(fieldTitle) : fieldTitle,
                overflow: TextOverflow.ellipsis,
              ),
              if (tableTitle != null)
                Text(
                  tableTitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> _showOrderFieldPicker(
  BuildContext context, {
  required Map<String, List<String>> groups,
  required String selectedValue,
}) {
  final isLargeScreen = MediaQuery.sizeOf(context).width > 600;
  final content = _OrderFieldPickerContent(
    groups: groups,
    selectedValue: selectedValue,
    autofocusSearch: isLargeScreen,
  );
  if (isLargeScreen) {
    final availableHeight = MediaQuery.sizeOf(context).height * .85;
    return showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: SizedBox(
          width: 520,
          height: availableHeight < 560 ? availableHeight : 560,
          child: content,
        ),
      ),
    );
  }
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SafeArea(
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .8,
          child: content,
        ),
      ),
    ),
  );
}

class _OrderFieldPickerContent extends StatefulWidget {
  const _OrderFieldPickerContent({
    required this.groups,
    required this.selectedValue,
    required this.autofocusSearch,
  });

  final Map<String, List<String>> groups;
  final String selectedValue;
  final bool autofocusSearch;

  @override
  State<_OrderFieldPickerContent> createState() =>
      _OrderFieldPickerContentState();
}

class _OrderFieldPickerContentState extends State<_OrderFieldPickerContent> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()..addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onQueryChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final groups = _filteredAndSortedGroups(query);
    final selectedTable = widget.selectedValue.isEmpty
        ? null
        : _orderFieldTableName(widget.selectedValue);
    final selectedIsMissing =
        widget.selectedValue.isNotEmpty &&
        !widget.groups.values.any(
          (fields) => fields.contains(widget.selectedValue),
        );
    final showMissingField = selectedIsMissing && _missingFieldMatches(query);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.documentSortOrderRecordsBy,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: l10n.documentSortClosePicker,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: TextField(
            controller: _searchController,
            autofocus: widget.autofocusSearch,
            decoration: InputDecoration(
              labelText: l10n.exportFieldsSearchFields,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        const Divider(height: 2),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.format_line_spacing),
                title: Text(l10n.documentSortOriginalOrder),
                selected: widget.selectedValue.isEmpty,
                trailing: widget.selectedValue.isEmpty
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, ''),
              ),
              if (showMissingField)
                ListTile(
                  leading: Icon(
                    Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    l10n.documentMissingItem(
                      specimenColumnDisplayTitle(widget.selectedValue),
                    ),
                  ),
                  subtitle: Text(
                    l10n.documentSortFieldUnavailable(
                      databaseTableLocalizedTitle(
                        l10n,
                        _orderFieldTableName(widget.selectedValue),
                      ),
                    ),
                  ),
                  selected: true,
                  trailing: const Icon(Icons.check),
                  onTap: () => Navigator.pop(context, widget.selectedValue),
                ),
              if (groups.isEmpty && !showMissingField)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l10n.exportFieldsNoMatchingFields)),
                )
              else
                for (final entry in groups.entries)
                  ExpansionTile(
                    key: ValueKey('order-field-${entry.key}-$query'),
                    initiallyExpanded:
                        query.isNotEmpty || entry.key == selectedTable,
                    title: Text(
                      databaseTableLocalizedTitle(context.l10n, entry.key),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(l10n.documentFieldCount(entry.value.length)),
                    children: [
                      for (final field in entry.value)
                        ListTile(
                          title: Text(specimenColumnDisplayTitle(field)),
                          selected: field == widget.selectedValue,
                          trailing: field == widget.selectedValue
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () => Navigator.pop(context, field),
                        ),
                    ],
                  ),
            ],
          ),
        ),
      ],
    );
  }

  void _onQueryChanged() => setState(() {});

  Map<String, List<String>> _filteredAndSortedGroups(String query) {
    final entries = widget.groups.entries.toList()
      ..sort((left, right) {
        final leftTitle = databaseTableLocalizedTitle(
          context.l10n,
          left.key,
        ).toLowerCase();
        final rightTitle = databaseTableLocalizedTitle(
          context.l10n,
          right.key,
        ).toLowerCase();
        final labelComparison = leftTitle.compareTo(rightTitle);
        return labelComparison != 0
            ? labelComparison
            : left.key.toLowerCase().compareTo(right.key.toLowerCase());
      });
    final filtered = <String, List<String>>{};
    for (final entry in entries) {
      final fields = _matchingFields(entry.key, entry.value, query);
      if (fields.isNotEmpty) filtered[entry.key] = fields;
    }
    return filtered;
  }

  List<String> _matchingFields(
    String table,
    List<String> fields,
    String query,
  ) {
    final tableMatches =
        query.isEmpty ||
        table.toLowerCase().contains(query) ||
        databaseTableLocalizedTitle(
          context.l10n,
          table,
        ).toLowerCase().contains(query);
    final matches = tableMatches
        ? List<String>.from(fields)
        : fields
              .where(
                (field) =>
                    field.toLowerCase().contains(query) ||
                    specimenColumnDisplayTitle(
                      field,
                    ).toLowerCase().contains(query),
              )
              .toList();
    matches.sort((left, right) {
      final leftTitle = specimenColumnDisplayTitle(left).toLowerCase();
      final rightTitle = specimenColumnDisplayTitle(right).toLowerCase();
      final labelComparison = leftTitle.compareTo(rightTitle);
      return labelComparison != 0
          ? labelComparison
          : left.toLowerCase().compareTo(right.toLowerCase());
    });
    return matches;
  }

  bool _missingFieldMatches(String query) {
    if (query.isEmpty) return true;
    return widget.selectedValue.toLowerCase().contains(query) ||
        specimenColumnDisplayTitle(
          widget.selectedValue,
        ).toLowerCase().contains(query) ||
        databaseTableLocalizedTitle(
          context.l10n,
          _orderFieldTableName(widget.selectedValue),
        ).toLowerCase().contains(query);
  }
}

String _orderFieldTableName(String field) {
  final separator = field.indexOf('::');
  return separator == -1 ? 'Other' : field.substring(0, separator);
}

class _LayoutProfileControls extends StatelessWidget {
  const _LayoutProfileControls({
    required this.selectedSetupName,
    required this.setupNames,
    required this.incompatibleSetupNames,
    required this.onSetupSelected,
    required this.onManagePresets,
  });

  final String selectedSetupName;
  final List<String> setupNames;
  final Set<String> incompatibleSetupNames;
  final ValueChanged<String> onSetupSelected;
  final VoidCallback? onManagePresets;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.documentLayoutTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            key: ValueKey('setup-$selectedSetupName'),
            initialValue: selectedSetupName,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.documentLayoutProfile,
              helperText: l10n.documentLayoutProfileHelper,
            ),
            selectedItemBuilder: (context) =>
                setupNames.map((n) => _setupDropdownText(context, n)).toList(),
            items: setupNames
                .map(
                  (n) => DropdownMenuItem<String>(
                    value: n,
                    child: _setupDropdownText(context, n),
                  ),
                )
                .toList(),
            onChanged: _selectSetup,
          ),
        ),
        if (onManagePresets != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onManagePresets,
              icon: const Icon(Icons.settings_outlined, size: 16),
              label: Text(l10n.documentManagePresets),
            ),
          ),
        ],
      ],
    );
  }

  Widget _setupDropdownText(BuildContext context, String name) {
    return _DropdownText(
      name,
      leadingIcon: incompatibleSetupNames.contains(name)
          ? Icon(
              Icons.warning_amber_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.error,
            )
          : null,
    );
  }

  void _selectSetup(String? value) {
    if (value != null) {
      onSetupSelected(value);
    }
  }
}

class _PageSetupControls extends StatelessWidget {
  const _PageSetupControls({
    required this.layout,
    required this.showMore,
    required this.wideFieldWidth,
    required this.pageSizeLabels,
    required this.pageOrientationLabels,
    required this.onToggleShowMore,
    required this.onLayoutChanged,
    required this.parseMmOrCurrent,
  });

  final rust_config.DocumentLayoutPreset layout;
  final bool showMore;
  final double wideFieldWidth;
  final Map<String, String> pageSizeLabels;
  final Map<String, String> pageOrientationLabels;
  final VoidCallback onToggleShowMore;
  final ValueChanged<rust_config.DocumentLayoutPreset> onLayoutChanged;
  final double Function(String value, double current) parseMmOrCurrent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.documentPageSetup,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextButton.icon(
              onPressed: onToggleShowMore,
              icon: Icon(showMore ? Icons.expand_less : Icons.expand_more),
              label: Text(
                showMore ? l10n.documentShowLess : l10n.documentShowMore,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _ResponsiveFieldBox(
              width: wideFieldWidth,
              child: DropdownButtonFormField<String>(
                key: ValueKey('page-size-${layout.pageSizeKey}'),
                initialValue: layout.pageSizeKey,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.documentPageSize,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                items: pageSizeLabels.entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: _setPageSize,
              ),
            ),
            if (showMore) ...[
              if (layout.pageSizeKey == 'Custom') ...[
                NumberField(
                  label: l10n.documentPageWidthMm,
                  initialValue: (layout.customPageWidthMm ?? 210.0)
                      .toStringAsFixed(1),
                  onChanged: _setCustomPageWidth,
                ),
                NumberField(
                  label: l10n.documentPageHeightMm,
                  initialValue: (layout.customPageHeightMm ?? 297.0)
                      .toStringAsFixed(1),
                  onChanged: _setCustomPageHeight,
                ),
              ],
              _ResponsiveFieldBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  key: ValueKey('orientation-${layout.pageOrientation}'),
                  initialValue: layout.pageOrientation,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.documentOrientation,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: pageOrientationLabels.entries
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e.key,
                          child: Text(e.value, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: _setPageOrientation,
                ),
              ),
            ],
          ],
        ),
        if (showMore) ...[
          const SizedBox(height: 12),
          Text(
            l10n.documentPagePadding,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              NumberField(
                label: l10n.documentPaddingTop,
                initialValue: layout.pagePadTopMm.toStringAsFixed(1),
                onChanged: _setPagePadTop,
              ),
              NumberField(
                label: l10n.documentPaddingLeft,
                initialValue: layout.pagePadLeftMm.toStringAsFixed(1),
                onChanged: _setPagePadLeft,
              ),
              NumberField(
                label: l10n.documentPaddingRight,
                initialValue: layout.pagePadRightMm.toStringAsFixed(1),
                onChanged: _setPagePadRight,
              ),
              NumberField(
                label: l10n.documentPaddingBottom,
                initialValue: layout.pagePadBottomMm.toStringAsFixed(1),
                onChanged: _setPagePadBottom,
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _setPageSize(String? value) {
    if (value != null) {
      onLayoutChanged(layout.copyWith(pageSizeKey: value));
    }
  }

  void _setPageOrientation(String? value) {
    if (value != null) {
      onLayoutChanged(layout.copyWith(pageOrientation: value));
    }
  }

  void _setCustomPageWidth(String value) {
    onLayoutChanged(
      layout.copyWith(
        customPageWidthMm: parseMmOrCurrent(
          value,
          layout.customPageWidthMm ?? 210.0,
        ),
      ),
    );
  }

  void _setCustomPageHeight(String value) {
    onLayoutChanged(
      layout.copyWith(
        customPageHeightMm: parseMmOrCurrent(
          value,
          layout.customPageHeightMm ?? 297.0,
        ),
      ),
    );
  }

  void _setPagePadTop(String value) {
    onLayoutChanged(
      layout.copyWith(
        pagePadTopMm: parseMmOrCurrent(value, layout.pagePadTopMm),
      ),
    );
  }

  void _setPagePadLeft(String value) {
    onLayoutChanged(
      layout.copyWith(
        pagePadLeftMm: parseMmOrCurrent(value, layout.pagePadLeftMm),
      ),
    );
  }

  void _setPagePadRight(String value) {
    onLayoutChanged(
      layout.copyWith(
        pagePadRightMm: parseMmOrCurrent(value, layout.pagePadRightMm),
      ),
    );
  }

  void _setPagePadBottom(String value) {
    onLayoutChanged(
      layout.copyWith(
        pagePadBottomMm: parseMmOrCurrent(value, layout.pagePadBottomMm),
      ),
    );
  }
}

class RecordNavigationButton extends ConsumerWidget {
  const RecordNavigationButton({
    super.key,
    required this.recordType,
    required this.selectedIds,
    required this.param,
  });

  final RecordType recordType;
  final Set<String> selectedIds;
  final BlockRecordSelectionParam param;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => _openSelection(context),
      icon: const Icon(Icons.table_rows_outlined),
      label: Text(context.l10n.commonSelect),
    );
  }

  Future<void> _openSelection(BuildContext context) async {
    if (recordType == RecordType.specimenRecord) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _BlockSpecimenSelectionScreen(
            initialSelectedIds: selectedIds,
            param: param,
          ),
        ),
      );
    } else if (recordType == RecordType.specimenParts) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _BlockSpecimenPartSelectionScreen(
            initialSelectedIds: selectedIds,
            param: param,
          ),
        ),
      );
    } else if (recordType == RecordType.site) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _BlockSiteSelectionScreen(
            initialSelectedIds: _parseRecordIds(selectedIds),
            param: param,
          ),
        ),
      );
    } else if (recordType == RecordType.collEvent) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _BlockEventSelectionScreen(
            initialSelectedIds: _parseRecordIds(selectedIds),
            param: param,
          ),
        ),
      );
    } else if (recordType == RecordType.narrative) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _BlockNarrativeSelectionScreen(
            initialSelectedIds: _parseRecordIds(selectedIds),
            param: param,
          ),
        ),
      );
    }
  }

  Set<int> _parseRecordIds(Set<String> ids) {
    return ids.map(int.tryParse).whereType<int>().toSet();
  }
}

class _BlockSpecimenPartSelectionScreen extends ConsumerStatefulWidget {
  const _BlockSpecimenPartSelectionScreen({
    required this.initialSelectedIds,
    required this.param,
  });

  final Set<String> initialSelectedIds;
  final BlockRecordSelectionParam param;

  @override
  ConsumerState<_BlockSpecimenPartSelectionScreen> createState() =>
      _BlockSpecimenPartSelectionScreenState();
}

class _BlockSpecimenPartSelectionScreenState
    extends ConsumerState<_BlockSpecimenPartSelectionScreen> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<String>.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.documentSelectSpecimenParts)),
      body: SafeArea(
        child: SpecimenPartSelectionView(
          selectedIds: _selectedIds,
          onSelectionChanged: (next) {
            setState(() => _selectedIds = next);
            ref
                .read(blockRecordSelectionProvider(widget.param).notifier)
                .updateSelection(next);
          },
        ),
      ),
    );
  }
}

class _BlockSpecimenSelectionScreen extends ConsumerStatefulWidget {
  const _BlockSpecimenSelectionScreen({
    required this.initialSelectedIds,
    required this.param,
  });

  final Set<String> initialSelectedIds;
  final BlockRecordSelectionParam param;

  @override
  ConsumerState<_BlockSpecimenSelectionScreen> createState() =>
      _BlockSpecimenSelectionScreenState();
}

class _BlockSpecimenSelectionScreenState
    extends ConsumerState<_BlockSpecimenSelectionScreen> {
  late Set<String> _selectedIds;
  List<String> _visibleColumnIds = [];

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<String>.from(widget.initialSelectedIds);
    _loadColumns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.documentSpecimenSelectTitle)),
      body: SafeArea(
        child: SpecimenSelectionView(
          selectedUuidList: _selectedIds,
          visibleColumnIds: _visibleColumnIds,
          onSelectionChanged: _updateSelection,
          onColumnsChanged: _pickColumns,
        ),
      ),
    );
  }

  Future<void> _loadColumns() async {
    final db = ref.read(databaseProvider);
    final visible = await const TemplateTablePreviewSettingsService()
        .getColumns(db);
    if (mounted) {
      setState(() {
        _visibleColumnIds = visible;
      });
    }
  }

  void _updateSelection(Set<String> nextSelection) {
    setState(() {
      _selectedIds = nextSelection;
    });
    ref
        .read(blockRecordSelectionProvider(widget.param).notifier)
        .updateSelection(nextSelection);
  }

  Future<void> _pickColumns() async {
    final db = ref.read(databaseProvider);
    final order = List<String>.from(_visibleColumnIds);
    List<String>? result;

    if (systemPlatform == PlatformType.mobile) {
      result = await showModalBottomSheet<List<String>>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return FractionallySizedBox(
            heightFactor: 0.9,
            child: Scaffold(
              appBar: AppBar(
                title: Text(context.l10n.presetsTableColumns),
                automaticallyImplyLeading: false,
              ),
              body: SpecimenTableColumnSelector(
                selectedColumns: _visibleColumnIds,
              ),
            ),
          );
        },
      );
    } else {
      result = await showDialog<List<String>>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(context.l10n.presetsTableColumns),
            content: SizedBox(
              width: 420,
              height: 420,
              child: SpecimenTableColumnSelector(
                selectedColumns: _visibleColumnIds,
              ),
            ),
          );
        },
      );
    }

    if (result != null && mounted) {
      final columns = await const TemplateTablePreviewSettingsService()
          .saveColumns(db: db, previousOrder: order, selectedColumns: result);
      if (!mounted) return;
      setState(() {
        _visibleColumnIds = columns;
      });
    }
  }
}

class _BlockSiteSelectionScreen extends ConsumerStatefulWidget {
  const _BlockSiteSelectionScreen({
    required this.initialSelectedIds,
    required this.param,
  });

  final Set<int> initialSelectedIds;
  final BlockRecordSelectionParam param;

  @override
  ConsumerState<_BlockSiteSelectionScreen> createState() =>
      _BlockSiteSelectionScreenState();
}

class _BlockSiteSelectionScreenState
    extends ConsumerState<_BlockSiteSelectionScreen> {
  late Set<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<int>.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return SiteSelectionScreen(
      selectedIds: _selectedIds,
      onSelectionChanged: _updateSelection,
    );
  }

  void _updateSelection(Set<int> nextSelection) {
    setState(() {
      _selectedIds = nextSelection;
    });
    ref
        .read(blockRecordSelectionProvider(widget.param).notifier)
        .updateSelection(nextSelection.map((e) => e.toString()).toSet());
  }
}

class _BlockEventSelectionScreen extends ConsumerStatefulWidget {
  const _BlockEventSelectionScreen({
    required this.initialSelectedIds,
    required this.param,
  });

  final Set<int> initialSelectedIds;
  final BlockRecordSelectionParam param;

  @override
  ConsumerState<_BlockEventSelectionScreen> createState() =>
      _BlockEventSelectionScreenState();
}

class _BlockEventSelectionScreenState
    extends ConsumerState<_BlockEventSelectionScreen> {
  late Set<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<int>.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return EventSelectionScreen(
      selectedIds: _selectedIds,
      onSelectionChanged: _updateSelection,
    );
  }

  void _updateSelection(Set<int> nextSelection) {
    setState(() {
      _selectedIds = nextSelection;
    });
    ref
        .read(blockRecordSelectionProvider(widget.param).notifier)
        .updateSelection(nextSelection.map((e) => e.toString()).toSet());
  }
}

class _BlockNarrativeSelectionScreen extends ConsumerStatefulWidget {
  const _BlockNarrativeSelectionScreen({
    required this.initialSelectedIds,
    required this.param,
  });

  final Set<int> initialSelectedIds;
  final BlockRecordSelectionParam param;

  @override
  ConsumerState<_BlockNarrativeSelectionScreen> createState() =>
      _BlockNarrativeSelectionScreenState();
}

class _BlockNarrativeSelectionScreenState
    extends ConsumerState<_BlockNarrativeSelectionScreen> {
  late Set<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<int>.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return NarrativeSelectionScreen(
      selectedIds: _selectedIds,
      onSelectionChanged: _updateSelection,
    );
  }

  void _updateSelection(Set<int> nextSelection) {
    setState(() {
      _selectedIds = nextSelection;
    });
    ref
        .read(blockRecordSelectionProvider(widget.param).notifier)
        .updateSelection(nextSelection.map((e) => e.toString()).toSet());
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

class _ResponsiveFieldBox extends StatelessWidget {
  const _ResponsiveFieldBox({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final resolvedWidth = maxWidth.isFinite && maxWidth < width
            ? maxWidth
            : width;
        return SizedBox(width: resolvedWidth, child: child);
      },
    );
  }
}

class _DropdownText extends StatelessWidget {
  const _DropdownText(this.text, {this.leadingIcon});

  final String text;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[leadingIcon!, const SizedBox(width: 6)],
        Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
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
