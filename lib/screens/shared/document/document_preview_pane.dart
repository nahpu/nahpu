import 'package:flutter/material.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/screens/shared/document/document_page_preview.dart';

class DocumentPreviewPane extends StatefulWidget {
  const DocumentPreviewPane({
    super.key,
    required this.showPreview,
    required this.layout,
    required this.selectedUuidList,
    required this.previewVersion,
    required this.isPreviewStale,
    required this.onGeneratePreview,
    this.isBlockSelection = false,
  });

  final bool showPreview;
  final rust_config.DocumentLayoutPreset? layout;
  final List<String> selectedUuidList;
  final int previewVersion;
  final bool isPreviewStale;
  final VoidCallback onGeneratePreview;
  final bool isBlockSelection;

  @override
  State<DocumentPreviewPane> createState() => _DocumentPreviewPaneState();
}

class _DocumentPreviewPaneState extends State<DocumentPreviewPane> {
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void didUpdateWidget(covariant DocumentPreviewPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.previewVersion != oldWidget.previewVersion) {
      _currentPage = 1;
      _totalPages = 0;
    }
  }

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
              child: !widget.showPreview
                  ? const Center(child: Text('Preview has not been generated.'))
                  : widget.layout == null
                      ? const Center(child: Text('No layout loaded.'))
                      : DocumentPageLivePreview(
                          key: ValueKey(widget.previewVersion),
                          selectedUuidList: widget.selectedUuidList,
                          layout: widget.layout!,
                          isBlockSelection: widget.isBlockSelection,
                          onPageChanged: (current, total) {
                            setState(() {
                              _currentPage = current;
                              _totalPages = total;
                            });
                          },
                        ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: FilledButton.icon(
                onPressed: widget.onGeneratePreview,
                icon: Icon(
                  widget.showPreview ? Icons.update : Icons.visibility_outlined,
                ),
                label: Text(
                  widget.showPreview ? 'Update preview' : 'Generate preview',
                ),
              ),
            ),
            if (widget.showPreview && widget.isPreviewStale)
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
            if (widget.showPreview && _totalPages > 0)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Page $_currentPage of $_totalPages',
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
