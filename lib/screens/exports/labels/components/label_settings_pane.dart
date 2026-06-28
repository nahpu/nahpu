import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/file_operation.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/services/types/controllers.dart';

class LabelSettingsPane extends StatelessWidget {
  const LabelSettingsPane({
    super.key,
    required this.setupNames,
    required this.selectedSetupName,
    required this.pageSizeKey,
    required this.pageOrientation,
    required this.customPageWidthMm,
    required this.customPageHeightMm,
    required this.rowsPerPage,
    required this.colsPerPage,
    required this.pagePadTopMm,
    required this.pagePadLeftMm,
    required this.pagePadRightMm,
    required this.pagePadBottomMm,
    required this.labelPadTopMm,
    required this.labelPadLeftMm,
    required this.labelPadRightMm,
    required this.labelPadBottomMm,
    required this.exportCtr,
    required this.selectedDir,
    required this.hasSaved,
    required this.isRunning,
    required this.onSetupSelected,
    required this.onSaveSetupAs,
    required this.onDeleteSetup,
    required this.onExportSetup,
    required this.onImportSetup,
    required this.onPageSizeKeyChanged,
    required this.onCustomPageWidthChanged,
    required this.onCustomPageHeightChanged,
    required this.onOrientationChanged,
    required this.onPagePadTopChanged,
    required this.onPagePadLeftChanged,
    required this.onPagePadRightChanged,
    required this.onPagePadBottomChanged,
    required this.onRowsPerPageChanged,
    required this.onColsPerPageChanged,
    required this.onLabelPadTopChanged,
    required this.onLabelPadLeftChanged,
    required this.onLabelPadRightChanged,
    required this.onLabelPadBottomChanged,
    required this.onFileNameChanged,
    required this.onSelectDir,
    required this.onExportPressed,
  });

  final List<String> setupNames;
  final String selectedSetupName;
  final String pageSizeKey;
  final String pageOrientation;
  final double customPageWidthMm;
  final double customPageHeightMm;
  final int rowsPerPage;
  final int colsPerPage;
  final double pagePadTopMm;
  final double pagePadLeftMm;
  final double pagePadRightMm;
  final double pagePadBottomMm;
  final double labelPadTopMm;
  final double labelPadLeftMm;
  final double labelPadRightMm;
  final double labelPadBottomMm;

  final FileOpCtrModel exportCtr;
  final Directory? selectedDir;
  final bool hasSaved;
  final bool isRunning;

  final ValueChanged<String> onSetupSelected;
  final VoidCallback onSaveSetupAs;
  final VoidCallback onDeleteSetup;
  final VoidCallback onExportSetup;
  final VoidCallback onImportSetup;
  final ValueChanged<String> onPageSizeKeyChanged;
  final ValueChanged<double> onCustomPageWidthChanged;
  final ValueChanged<double> onCustomPageHeightChanged;
  final ValueChanged<String> onOrientationChanged;
  final ValueChanged<double> onPagePadTopChanged;
  final ValueChanged<double> onPagePadLeftChanged;
  final ValueChanged<double> onPagePadRightChanged;
  final ValueChanged<double> onPagePadBottomChanged;
  final ValueChanged<int> onRowsPerPageChanged;
  final ValueChanged<int> onColsPerPageChanged;
  final ValueChanged<double> onLabelPadTopChanged;
  final ValueChanged<double> onLabelPadLeftChanged;
  final ValueChanged<double> onLabelPadRightChanged;
  final ValueChanged<double> onLabelPadBottomChanged;

  final ValueChanged<String?> onFileNameChanged;
  final Future<void> Function() onSelectDir;
  final VoidCallback? onExportPressed;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FileOperationPage(
            children: [
              const FileFormatIcon(path: 'assets/icons/pdf.svg'),
              PrintLayoutSection(
                setupNames: setupNames,
                selectedSetupName: selectedSetupName,
                pageSizeKey: pageSizeKey,
                pageOrientation: pageOrientation,
                customPageWidthMm: customPageWidthMm,
                customPageHeightMm: customPageHeightMm,
                rowsPerPage: rowsPerPage,
                colsPerPage: colsPerPage,
                pagePadTopMm: pagePadTopMm,
                pagePadLeftMm: pagePadLeftMm,
                pagePadRightMm: pagePadRightMm,
                pagePadBottomMm: pagePadBottomMm,
                labelPadTopMm: labelPadTopMm,
                labelPadLeftMm: labelPadLeftMm,
                labelPadRightMm: labelPadRightMm,
                labelPadBottomMm: labelPadBottomMm,
                onSetupSelected: onSetupSelected,
                onSaveSetupAs: onSaveSetupAs,
                onDeleteSetup: onDeleteSetup,
                onExportSetup: onExportSetup,
                onImportSetup: onImportSetup,
                onPageSizeKeyChanged: onPageSizeKeyChanged,
                onCustomPageWidthChanged: onCustomPageWidthChanged,
                onCustomPageHeightChanged: onCustomPageHeightChanged,
                onOrientationChanged: onOrientationChanged,
                onPagePadTopChanged: onPagePadTopChanged,
                onPagePadLeftChanged: onPagePadLeftChanged,
                onPagePadRightChanged: onPagePadRightChanged,
                onPagePadBottomChanged: onPagePadBottomChanged,
                onRowsPerPageChanged: onRowsPerPageChanged,
                onColsPerPageChanged: onColsPerPageChanged,
                onLabelPadTopChanged: onLabelPadTopChanged,
                onLabelPadLeftChanged: onLabelPadLeftChanged,
                onLabelPadRightChanged: onLabelPadRightChanged,
                onLabelPadBottomChanged: onLabelPadBottomChanged,
              ),
              FileNameField(
                controller: exportCtr,
                onChanged: onFileNameChanged,
              ),
              SelectDirField(
                dirPath: selectedDir,
                onPressed: onSelectDir,
                onCanceled: () {
                  // This callback would need to be handled carefully,
                  // or we just call onSelectDir which could handle null if we change it,
                  // but SelectDirField needs onCanceled. We'll pass it as a separate callback if needed,
                  // or just define a handler.
                },
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 20,
                children: [
                  SaveSecondaryButton(hasSaved: hasSaved),
                  !hasSaved
                      ? ProgressButton(
                          label: 'Export PDF',
                          isRunning: isRunning,
                          icon: Icons.save_alt_outlined,
                          onPressed: onExportPressed,
                        )
                      : Builder(
                          builder: (BuildContext context) {
                            return ShareButton(onPressed: () async {
                              // Share functionality
                            });
                          },
                        ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

class PrintLayoutSection extends StatelessWidget {
  const PrintLayoutSection({
    super.key,
    required this.setupNames,
    required this.selectedSetupName,
    required this.pageSizeKey,
    required this.pageOrientation,
    required this.customPageWidthMm,
    required this.customPageHeightMm,
    required this.rowsPerPage,
    required this.colsPerPage,
    required this.pagePadTopMm,
    required this.pagePadLeftMm,
    required this.pagePadRightMm,
    required this.pagePadBottomMm,
    required this.labelPadTopMm,
    required this.labelPadLeftMm,
    required this.labelPadRightMm,
    required this.labelPadBottomMm,
    required this.onSetupSelected,
    required this.onSaveSetupAs,
    required this.onDeleteSetup,
    required this.onExportSetup,
    required this.onImportSetup,
    required this.onPageSizeKeyChanged,
    required this.onCustomPageWidthChanged,
    required this.onCustomPageHeightChanged,
    required this.onOrientationChanged,
    required this.onPagePadTopChanged,
    required this.onPagePadLeftChanged,
    required this.onPagePadRightChanged,
    required this.onPagePadBottomChanged,
    required this.onRowsPerPageChanged,
    required this.onColsPerPageChanged,
    required this.onLabelPadTopChanged,
    required this.onLabelPadLeftChanged,
    required this.onLabelPadRightChanged,
    required this.onLabelPadBottomChanged,
  });

  final List<String> setupNames;
  final String selectedSetupName;
  final String pageSizeKey;
  final String pageOrientation;
  final double customPageWidthMm;
  final double customPageHeightMm;
  final int rowsPerPage;
  final int colsPerPage;
  final double pagePadTopMm;
  final double pagePadLeftMm;
  final double pagePadRightMm;
  final double pagePadBottomMm;
  final double labelPadTopMm;
  final double labelPadLeftMm;
  final double labelPadRightMm;
  final double labelPadBottomMm;

  final ValueChanged<String> onSetupSelected;
  final VoidCallback onSaveSetupAs;
  final VoidCallback onDeleteSetup;
  final VoidCallback onExportSetup;
  final VoidCallback onImportSetup;
  final ValueChanged<String> onPageSizeKeyChanged;
  final ValueChanged<double> onCustomPageWidthChanged;
  final ValueChanged<double> onCustomPageHeightChanged;
  final ValueChanged<String> onOrientationChanged;
  final ValueChanged<double> onPagePadTopChanged;
  final ValueChanged<double> onPagePadLeftChanged;
  final ValueChanged<double> onPagePadRightChanged;
  final ValueChanged<double> onPagePadBottomChanged;
  final ValueChanged<int> onRowsPerPageChanged;
  final ValueChanged<int> onColsPerPageChanged;
  final ValueChanged<double> onLabelPadTopChanged;
  final ValueChanged<double> onLabelPadLeftChanged;
  final ValueChanged<double> onLabelPadRightChanged;
  final ValueChanged<double> onLabelPadBottomChanged;

  static const Map<String, String> _printPageSizeLabels = {
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

  double _parseMmOrCurrent(String value, double current) {
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return current;
    return parsed.clamp(0.0, 200.0);
  }

  int _parseIntOrCurrent(String value, int current) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return current;
    return parsed.clamp(1, 200);
  }

  @override
  Widget build(BuildContext context) {
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
            'Print layout',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 360,
                child: DropdownButtonFormField<String>(
                  key: ValueKey('setup-$selectedSetupName'),
                  initialValue: selectedSetupName,
                  decoration: const InputDecoration(
                    labelText: 'Page setup',
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
                label: const Text('Save'),
              ),
              OutlinedButton.icon(
                onPressed: onDeleteSetup,
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
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: DropdownButtonFormField<String>(
                  key: ValueKey('page-size-$pageSizeKey'),
                  initialValue: pageSizeKey,
                  decoration: const InputDecoration(
                    labelText: 'Page size',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _printPageSizeLabels.entries
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onPageSizeKeyChanged(v);
                  },
                ),
              ),
              if (pageSizeKey == 'Custom') ...[
                NumberField(
                  label: 'Width mm',
                  initialValue: customPageWidthMm.toStringAsFixed(1),
                  onChanged: (value) {
                    onCustomPageWidthChanged(
                        _parseMmOrCurrent(value, customPageWidthMm));
                  },
                ),
                NumberField(
                  label: 'Height mm',
                  initialValue: customPageHeightMm.toStringAsFixed(1),
                  onChanged: (value) {
                    onCustomPageHeightChanged(
                        _parseMmOrCurrent(value, customPageHeightMm));
                  },
                ),
              ],
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  key: ValueKey('orientation-$pageOrientation'),
                  initialValue: pageOrientation,
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
                    if (v != null) onOrientationChanged(v);
                  },
                ),
              ),
              NumberField(
                label: 'Page top',
                initialValue: pagePadTopMm.toStringAsFixed(1),
                onChanged: (value) {
                  onPagePadTopChanged(_parseMmOrCurrent(value, pagePadTopMm));
                },
              ),
              NumberField(
                label: 'Page left',
                initialValue: pagePadLeftMm.toStringAsFixed(1),
                onChanged: (value) {
                  onPagePadLeftChanged(_parseMmOrCurrent(value, pagePadLeftMm));
                },
              ),
              NumberField(
                label: 'Page right',
                initialValue: pagePadRightMm.toStringAsFixed(1),
                onChanged: (value) {
                  onPagePadRightChanged(
                      _parseMmOrCurrent(value, pagePadRightMm));
                },
              ),
              NumberField(
                label: 'Page bottom',
                initialValue: pagePadBottomMm.toStringAsFixed(1),
                onChanged: (value) {
                  onPagePadBottomChanged(
                      _parseMmOrCurrent(value, pagePadBottomMm));
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              NumberField(
                label: 'Rows / page',
                initialValue: '$rowsPerPage',
                onChanged: (value) {
                  onRowsPerPageChanged(_parseIntOrCurrent(value, rowsPerPage));
                },
              ),
              NumberField(
                label: 'Cols / page',
                initialValue: '$colsPerPage',
                onChanged: (value) {
                  onColsPerPageChanged(_parseIntOrCurrent(value, colsPerPage));
                },
              ),
              NumberField(
                label: 'Label top',
                initialValue: labelPadTopMm.toStringAsFixed(1),
                onChanged: (value) {
                  onLabelPadTopChanged(_parseMmOrCurrent(value, labelPadTopMm));
                },
              ),
              NumberField(
                label: 'Label left',
                initialValue: labelPadLeftMm.toStringAsFixed(1),
                onChanged: (value) {
                  onLabelPadLeftChanged(
                      _parseMmOrCurrent(value, labelPadLeftMm));
                },
              ),
              NumberField(
                label: 'Label right',
                initialValue: labelPadRightMm.toStringAsFixed(1),
                onChanged: (value) {
                  onLabelPadRightChanged(
                      _parseMmOrCurrent(value, labelPadRightMm));
                },
              ),
              NumberField(
                label: 'Label bottom',
                initialValue: labelPadBottomMm.toStringAsFixed(1),
                onChanged: (value) {
                  onLabelPadBottomChanged(
                      _parseMmOrCurrent(value, labelPadBottomMm));
                },
              ),
            ],
          ),
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
      width: 112,
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
