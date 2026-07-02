import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/template_editor/label_template_model.dart';
import 'package:nahpu/services/export/label_writer.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:pdfrx/pdfrx.dart';

class LabelPageLivePreview extends ConsumerStatefulWidget {
  const LabelPageLivePreview({
    super.key,
    required this.selectedUuidList,
    required this.template,
    required this.layout,
    required this.pageWidthMm,
    required this.pageHeightMm,
  });

  final List<String> selectedUuidList;
  final LabelTemplate template;
  final LabelPrintLayoutOptions layout;
  final double pageWidthMm;
  final double pageHeightMm;

  @override
  ConsumerState<LabelPageLivePreview> createState() =>
      _LabelPageLivePreviewState();
}

class _LabelPageLivePreviewState extends ConsumerState<LabelPageLivePreview> {
  bool _isLoading = true;
  String? _error;
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final all = await SpecimenServices(ref: ref).getSpecimenList();
      final picked = all
          .where((s) => widget.selectedUuidList.contains(s.uuid))
          .take(500)
          .toList();

      final wPt = widget.pageWidthMm * 72.0 / 25.4;
      final hPt = widget.pageHeightMm * 72.0 / 25.4;

      final writer = LabelWriter(ref: ref);
      final bytes = await writer.generateLabelsPdf(
        picked,
        template: widget.template,
        sheetWidthPt: wPt,
        sheetHeightPt: hPt,
        layout: widget.layout,
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
    return Stack(
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error generating PDF:\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          )
        else if (_pdfBytes != null)
          Positioned.fill(
            child: PdfViewer.data(
              _pdfBytes!,
              sourceName: 'preview.pdf',
              params: const PdfViewerParams(
                backgroundColor: Colors.transparent,
              ),
            ),
          )
        else
          const Center(child: Text('No preview available.')),
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: _isLoading ? null : _generatePdf,
            tooltip: 'Refresh Preview',
            child: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }
}
