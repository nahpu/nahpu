import 'package:flutter/material.dart';
import 'package:nahpu/screens/export/labels/label_template_model.dart';
import 'package:nahpu/screens/export/components/label_page_preview.dart';
import 'package:nahpu/services/export/label_writer.dart';

class LabelPreviewPane extends StatelessWidget {
  const LabelPreviewPane({
    super.key,
    required this.showPreview,
    required this.template,
    required this.selectedUuidList,
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
    required this.customPageWidthMm,
    required this.customPageHeightMm,
    required this.onGeneratePreview,
  });

  final bool showPreview;
  final LabelTemplate? template;
  final List<String> selectedUuidList;
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
  final double customPageWidthMm;
  final double customPageHeightMm;
  final VoidCallback onGeneratePreview;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(16.0),
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.4),
      child: !showPreview
          ? Center(
              child: FilledButton.icon(
                onPressed: onGeneratePreview,
                icon: const Icon(Icons.visibility),
                label: const Text('Generate Preview'),
              ),
            )
          : template == null
              ? const Center(child: Text('No template selected.'))
              : LabelPageLivePreview(
                  selectedUuidList: selectedUuidList,
                  template: template!,
                  layout: LabelPrintLayoutOptions(
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
                  ),
                  pageWidthMm: customPageWidthMm,
                  pageHeightMm: customPageHeightMm,
                ),
    );
  }
}
