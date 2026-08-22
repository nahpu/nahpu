import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/services/export/document_writer.dart';
import 'package:pdfrx/pdfrx.dart';

class DocumentPageLivePreview extends ConsumerStatefulWidget {
  const DocumentPageLivePreview({
    super.key,
    required this.selectedUuidList,
    required this.layout,
    this.isBlockSelection = false,
    this.onPageChanged,
  });

  final List<String> selectedUuidList;
  final rust_config.DocumentLayoutPreset layout;
  final bool isBlockSelection;
  final void Function(int current, int total)? onPageChanged;

  @override
  ConsumerState<DocumentPageLivePreview> createState() =>
      _DocumentPageLivePreviewState();
}

class _DocumentPageLivePreviewState
    extends ConsumerState<DocumentPageLivePreview> {
  bool _isLoading = true;
  String? _error;
  Uint8List? _pdfBytes;
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  @override
  void didUpdateWidget(covariant DocumentPageLivePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.layout != oldWidget.layout ||
        widget.selectedUuidList != oldWidget.selectedUuidList) {
      _generatePdf();
    }
  }

  double _getPageWidth(String pageSizeKey, double? customPageWidthMm) {
    switch (pageSizeKey) {
      case 'A0':
        return 841.0;
      case 'A1':
        return 594.0;
      case 'A2':
        return 420.0;
      case 'A3':
        return 297.0;
      case 'Letter':
        return 215.9;
      case 'A5':
        return 148.0;
      case 'A6':
        return 105.0;
      case 'A7':
        return 74.0;
      case 'A8':
        return 52.0;
      case 'Legal':
        return 215.9;
      case 'Custom':
        return customPageWidthMm?.clamp(40.0, 1200.0) ?? 210.0;
      case 'A4':
      default:
        return 210.0;
    }
  }

  double _getPageHeight(String pageSizeKey, double? customPageHeightMm) {
    switch (pageSizeKey) {
      case 'A0':
        return 1188.0;
      case 'A1':
        return 841.0;
      case 'A2':
        return 594.0;
      case 'A3':
        return 420.0;
      case 'Letter':
        return 279.4;
      case 'A5':
        return 210.0;
      case 'A6':
        return 148.0;
      case 'A7':
        return 105.0;
      case 'A8':
        return 74.0;
      case 'Legal':
        return 355.6;
      case 'Custom':
        return customPageHeightMm?.clamp(40.0, 1200.0) ?? 297.0;
      case 'A4':
      default:
        return 297.0;
    }
  }

  Future<void> _generatePdf() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      double w = _getPageWidth(
        widget.layout.pageSizeKey,
        widget.layout.customPageWidthMm,
      );
      double h = _getPageHeight(
        widget.layout.pageSizeKey,
        widget.layout.customPageHeightMm,
      );

      if (widget.layout.pageOrientation == 'landscape') {
        final tmp = w;
        w = h;
        h = tmp;
      }

      final wPt = w * 72.0 / 25.4;
      final hPt = h * 72.0 / 25.4;

      final writer = DocumentWriter(ref: ref);
      Uint8List bytes = await writer.generateLayoutPdf(
        sheetWidthPt: wPt,
        sheetHeightPt: hPt,
        layout: widget.layout,
        isPreview: !widget.isBlockSelection,
        previewRecords: widget.selectedUuidList,
      );

      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error generating PDF:\n$_error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    if (_pdfBytes != null) {
      return SizedBox.expand(
        child: PdfViewer.data(
          _pdfBytes!,
          sourceName: 'preview.pdf',
          controller: _pdfViewerController,
          params: PdfViewerParams(
            backgroundColor: Colors.transparent,
            onViewerReady: (document, controller) {
              final total = controller.pageCount;
              final current = controller.pageNumber ?? 1;
              widget.onPageChanged?.call(current, total);
            },
            onPageChanged: (pageNumber) {
              if (pageNumber != null) {
                widget.onPageChanged?.call(
                  pageNumber,
                  _pdfViewerController.pageCount,
                );
              }
            },
          ),
        ),
      );
    }
    return const Center(child: Text('No preview available.'));
  }
}
