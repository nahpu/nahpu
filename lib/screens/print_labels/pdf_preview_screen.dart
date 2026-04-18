import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// Paper sizes for the print preview toolbar (plus [Custom], edited via toolbar icon).
Map<String, PdfPageFormat> _labelPrintPageFormats(PdfPageFormat custom) {
  final inch = PdfPageFormat.inch;
  final mm = PdfPageFormat.mm;
  final cm = PdfPageFormat.cm;

  /// ISO-style sheet with 2 cm margins (matches [PdfPageFormat.a3]/[PdfPageFormat.a4]).
  PdfPageFormat iso216(double wMm, double hMm) =>
      PdfPageFormat(wMm * mm, hMm * mm, marginAll: 2.0 * cm);

  return {
    'ISO A0 (841×1189 mm)': iso216(841, 1189),
    'ISO A1 (594×841 mm)': iso216(594, 841),
    'ISO A2 (420×594 mm)': iso216(420, 594),
    'ISO A3 (297×420 mm)': PdfPageFormat.a3,
    'ISO A4 (210×297 mm)': PdfPageFormat.a4,
    'ISO A5 (148×210 mm)': PdfPageFormat.a5,
    'ISO A6 (105×148 mm)': PdfPageFormat.a6,
    'US · Letter 8.5×11 in (ANSI A)': PdfPageFormat.letter,
    'US · Legal': PdfPageFormat.legal,
    'US · Tabloid / Ledger (ANSI B)':
        PdfPageFormat(11 * inch, 17 * inch, marginAll: inch),
    'ANSI C (432×559 mm)': iso216(432, 559),
    'ANSI D (559×864 mm)': iso216(559, 864),
    'ANSI E (864×1118 mm)': iso216(864, 1118),
    'Arch A (229×305 mm)': iso216(229, 305),
    'Arch B (305×457 mm)': iso216(305, 457),
    'Arch C (457×610 mm)': iso216(457, 610),
    'Arch D (610×914 mm)': iso216(610, 914),
    'Arch E (914×1219 mm)': iso216(914, 1219),
    'Arch E1 (762×1067 mm)': iso216(762, 1067),
    'Executive (7.25×10.5 in)':
        PdfPageFormat(7.25 * inch, 10.5 * inch, marginAll: inch),
    'Statement (5.5×8.5 in)':
        PdfPageFormat(5.5 * inch, 8.5 * inch, marginAll: inch),
    'ISO B4 (250×353 mm)':
        PdfPageFormat(250 * mm, 353 * mm, marginAll: 2.0 * cm),
    'ISO B5 (176×250 mm)':
        PdfPageFormat(176 * mm, 250 * mm, marginAll: 2.0 * cm),
    'Custom': custom,
  };
}

class PdfPreviewScreen extends StatefulWidget {
  const PdfPreviewScreen({
    super.key,
    required this.pdfBuilder,
    this.title = 'Labels',
    this.canChangePageFormat = true,
    this.canCustomizePageSize = true,
    this.templateNames = const [],
    this.initialTemplateName,
  });

  /// Regenerated when the user changes paper size or orientation in the preview.
  final Future<Uint8List> Function(PdfPageFormat format, String? templateName)
      pdfBuilder;
  final String title;
  final bool canChangePageFormat;
  final bool canCustomizePageSize;
  final List<String> templateNames;
  final String? initialTemplateName;

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  /// User-defined size for the "Custom" entry (width × height, PDF points).
  late PdfPageFormat _customFormat;
  int _previewKey = 0;
  String? _selectedTemplateName;

  @override
  void initState() {
    super.initState();
    _customFormat = PdfPageFormat(
      210 * PdfPageFormat.mm,
      297 * PdfPageFormat.mm,
      marginAll: PdfPageFormat.cm,
    );
    _selectedTemplateName = widget.initialTemplateName;
  }

  Future<void> _openCustomPageSize(BuildContext ctx) async {
    final wCtr = TextEditingController(
      text: (_customFormat.width / PdfPageFormat.mm).toStringAsFixed(1),
    );
    final hCtr = TextEditingController(
      text: (_customFormat.height / PdfPageFormat.mm).toStringAsFixed(1),
    );
    try {
      final ok = await showDialog<bool>(
        context: ctx,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Custom page size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: wCtr,
                decoration: const InputDecoration(
                  labelText: 'Width (mm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hCtr,
                decoration: const InputDecoration(
                  labelText: 'Height (mm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Apply'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      final nw = double.tryParse(wCtr.text.replaceAll(',', '.')) ??
          _customFormat.width / PdfPageFormat.mm;
      final nh = double.tryParse(hCtr.text.replaceAll(',', '.')) ??
          _customFormat.height / PdfPageFormat.mm;
      setState(() {
        _customFormat = PdfPageFormat(
          nw.clamp(40.0, 1200.0) * PdfPageFormat.mm,
          nh.clamp(40.0, 1200.0) * PdfPageFormat.mm,
          marginAll: PdfPageFormat.cm,
        );
        _previewKey++;
      });
    } finally {
      wCtr.dispose();
      hCtr.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formats = _labelPrintPageFormats(_customFormat);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.templateNames.isNotEmpty)
            PopupMenuButton<String>(
              tooltip: 'Template',
              icon: const Icon(Icons.description_outlined),
              initialValue: _selectedTemplateName,
              onSelected: (name) {
                setState(() {
                  _selectedTemplateName = name;
                  _previewKey++;
                });
              },
              itemBuilder: (context) => [
                for (final name in widget.templateNames)
                  PopupMenuItem<String>(
                    value: name,
                    child: Row(
                      children: [
                        Expanded(child: Text(name)),
                        if (name == _selectedTemplateName)
                          const Icon(Icons.check, size: 16),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: PdfPreview(
        key: ValueKey(_previewKey),
        build: (format) => widget.pdfBuilder(format, _selectedTemplateName),
        canChangePageFormat: widget.canChangePageFormat,
        canChangeOrientation: true,
        canDebug: false,
        pageFormats: formats,
        initialPageFormat: _previewKey > 0 ? _customFormat : null,
        actions: widget.canCustomizePageSize
            ? [
                PdfPreviewAction(
                  icon: const Icon(Icons.tune),
                  onPressed: (ctx, build, pageFormat) {
                    _openCustomPageSize(ctx);
                  },
                ),
              ]
            : const [],
      ),
    );
  }
}
