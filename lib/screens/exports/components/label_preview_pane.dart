import 'package:flutter/material.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/screens/exports/components/label_page_preview.dart';

class LabelPreviewPane extends StatelessWidget {
  const LabelPreviewPane({
    super.key,
    required this.showPreview,
    required this.layout,
    required this.selectedUuidList,
    required this.previewVersion,
    required this.isPreviewStale,
    required this.onGeneratePreview,
  });

  final bool showPreview;
  final rust_config.DocumentLayoutPreset? layout;
  final List<String> selectedUuidList;
  final int previewVersion;
  final bool isPreviewStale;
  final VoidCallback onGeneratePreview;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
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
                  : layout == null
                      ? const Center(child: Text('No layout loaded.'))
                      : LabelPageLivePreview(
                          key: ValueKey(previewVersion),
                          selectedUuidList: selectedUuidList,
                          layout: layout!,
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
