import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/export/pdf/narrative_pdf.dart';
import 'package:nahpu/services/export/pdf/specimen_pdf.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/screens/shared/file_operation.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportPdfForm extends ConsumerStatefulWidget {
  const ExportPdfForm({super.key});

  @override
  ExportPdfFormState createState() => ExportPdfFormState();
}

class ExportPdfFormState extends ConsumerState<ExportPdfForm> {
  FileOpCtrModel exportCtr = FileOpCtrModel.empty();
  Directory? _selectedDir;
  PdfExportType _pdfExportType = PdfExportType.narrative;
  PdfPageFormat _pdfPageFormat = PdfPageFormat.letter;
  pw.PageOrientation _pdfPageOrientation = pw.PageOrientation.portrait;
  String _fileStem = 'export';
  bool _hasSaved = false;
  late File _savePath;
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Export to PDF"),
        automaticallyImplyLeading: false,
      ),
      body: FileOperationPage(
        children: [
          const FileFormatIcon(path: 'assets/icons/pdf.svg'),
          DropdownButtonFormField(
              initialValue: PdfExportType.narrative,
              decoration: const InputDecoration(
                labelText: 'Record type',
              ),
              items: pdfExport.keys
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: CommonDropdownText(
                          text: pdfExport[e] ?? '',
                        ),
                      ))
                  .toList(),
              onChanged: (PdfExportType? value) {
                if (value != null) {
                  setState(() {
                    _pdfExportType = value;
                    _hasSaved = false;
                  });
                }
              }),
          DropdownButtonFormField(
              initialValue: _pdfPageFormat,
              decoration: const InputDecoration(
                labelText: 'Page format',
              ),
              items: pdfExportPageFormat.keys
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: CommonDropdownText(
                          text: pdfExportPageFormat[e] ?? '',
                        ),
                      ))
                  .toList(),
              onChanged: (PdfPageFormat? value) {
                if (value != null) {
                  setState(() {
                    _pdfPageFormat = value;
                    _hasSaved = false;
                  });
                }
              }),
          DropdownButtonFormField(
              initialValue: _pdfPageOrientation,
              decoration: const InputDecoration(
                labelText: 'Page orientation',
              ),
              items: pdfExportOrientation.keys
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: CommonDropdownText(
                          text: pdfExportOrientation[e] ?? '',
                        ),
                      ))
                  .toList(),
              onChanged: (pw.PageOrientation? value) {
                if (value != null) {
                  setState(() {
                    _pdfPageOrientation = value;
                    _hasSaved = false;
                  });
                }
              }),
          FileNameField(
            controller: exportCtr,
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _fileStem = value;
                  _hasSaved = false;
                });
              }
            },
          ),
          SelectDirField(
            dirPath: _selectedDir,
            onPressed: () {
              _getDir();
            },
            onCanceled: () {
              setState(() {
                _selectedDir = null;
                _hasSaved = false;
              });
            },
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 20,
            children: [
              SaveSecondaryButton(hasSaved: _hasSaved),
              !_hasSaved
                  ? ProgressButton(
                      label: 'Save',
                      isRunning: _isRunning,
                      icon: Icons.save_alt_outlined,
                      onPressed: !exportCtr.isValid
                          ? null
                          : () async {
                              setState(() {
                                _isRunning = true;
                              });
                              await _writePdf();
                              setState(() {
                                _isRunning = false;
                              });
                            },
                    )
                  : Builder(
                      builder: (BuildContext context) {
                        return ShareButton(onPressed: () {
                          _shareFile(context);
                        });
                      },
                    ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _writePdf() async {
    try {
      _savePath = await AppIOServices(
              dir: _selectedDir, fileStem: _fileStem, ext: 'pdf')
          .getSavePath();
      await _matchExportTypeToWriter(_savePath);
      setState(() {
        _hasSaved = true;
      });
    } catch (e) {
      if (context.mounted) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String errors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errors),
      ),
    );
  }

  Future<void> _matchExportTypeToWriter(File file) async {
    switch (_pdfExportType) {
      case PdfExportType.narrative:
        await NarrativePdfWriter(
          ref: ref,
          pageFormat: _pdfPageFormat,
          filePath: file,
          pageOrientation: _pdfPageOrientation,
        ).generatePdf();
        break;
      case PdfExportType.specimen:
        await SpecimenPdfWriter(
          ref: ref,
          pageFormat: _pdfPageFormat,
          filePath: file,
          pageOrientation: _pdfPageOrientation,
        ).generatePdf();
        break;
    }
  }

  Future<void> _shareFile(BuildContext context) async {
    try {
      await FilePickerServices().shareFile(context, _savePath);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _getDir() async {
    Directory? path = await FilePickerServices().selectDir();
    setState(() {
      _selectedDir = path;
    });
  }
}
