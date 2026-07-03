import 'package:flutter/material.dart';
import 'package:nahpu/screens/exports/components/label_page_preview.dart';
import 'package:nahpu/screens/templates/template_model.dart';
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
    required this.previewVersion,
    required this.isPreviewStale,
    required this.onGeneratePreview,
  });

  final bool showPreview;
  final Template? template;
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
  final int previewVersion;
  final bool isPreviewStale;
  final VoidCallback onGeneratePreview;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.4),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: !showPreview
                  ? const Center(child: Text('Preview has not been generated.'))
                  : template == null
                      ? const Center(child: Text('No template selected.'))
                      : LabelPageLivePreview(
                          key: ValueKey(previewVersion),
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
            ),
            Positioned(
              top: 12,
              right: 12,
              child: FilledButton.icon(
                onPressed: onGeneratePreview,
                icon: Icon(
                  showPreview ? Icons.update : Icons.visibility_outlined,
                ),
                label:
                    Text(showPreview ? 'Update preview' : 'Generate preview'),
              ),
            ),
            if (showPreview && isPreviewStale)
              Positioned(
                left: 12,
                top: 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Text(
                      'Preview options changed',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
