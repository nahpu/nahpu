import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/screens/shared/file_operation.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/export/document_export_services.dart';

class ExportPdfForm extends ConsumerStatefulWidget {
  const ExportPdfForm({super.key});

  @override
  ExportPdfFormState createState() => ExportPdfFormState();
}

class ExportPdfFormState extends ConsumerState<ExportPdfForm> {
  FileOpCtrModel exportCtr = FileOpCtrModel.empty();
  Directory? _selectedDir;
  DocumentExportType _exportType = DocumentExportType.narrative;
  DocumentExportFmt _exportFmt = DocumentExportFmt.pdf;
  String _fileStem = 'export';
  bool _hasSaved = false;
  late File _savePath;
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document Export"),
        automaticallyImplyLeading: false,
      ),
      body: FileOperationPage(
        children: [
          const FileFormatIcon(path: 'assets/icons/pdf.svg'),
          DropdownButtonFormField(
              initialValue: _exportType,
              decoration: const InputDecoration(
                labelText: 'Record type',
              ),
              items: documentExport.keys
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: CommonDropdownText(
                          text: documentExport[e] ?? '',
                        ),
                      ))
                  .toList(),
              onChanged: (DocumentExportType? value) {
                if (value != null) {
                  setState(() {
                    _exportType = value;
                    _hasSaved = false;
                  });
                }
              }),
          DropdownButtonFormField(
              initialValue: _exportFmt,
              decoration: const InputDecoration(
                labelText: 'Format',
              ),
              items: documentExportFmt.keys
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: CommonDropdownText(
                          text: documentExportFmt[e] ?? '',
                        ),
                      ))
                  .toList(),
              onChanged: (DocumentExportFmt? value) {
                if (value != null) {
                  setState(() {
                    _exportFmt = value;
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
                              await _writeDocument();
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

  Future<void> _writeDocument() async {
    try {
      _savePath = await AppIOServices(
              dir: _selectedDir, fileStem: _fileStem, ext: _exportFmt.name)
          .getSavePath();

      await DocumentExportServices(ref: ref).exportDocument(
        file: _savePath,
        type: _exportType,
        format: _exportFmt,
      );

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
