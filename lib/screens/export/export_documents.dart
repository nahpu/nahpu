import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/screens/shared/file_operation.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/export/document_exports.dart';
import 'package:printing/printing.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ExportPdfForm extends ConsumerStatefulWidget {
  const ExportPdfForm({super.key});

  @override
  ExportPdfFormState createState() => ExportPdfFormState();
}

class ExportPdfFormState extends ConsumerState<ExportPdfForm>
    with SingleTickerProviderStateMixin {
  FileOpCtrModel exportCtr = FileOpCtrModel.empty();
  Directory? _selectedDir;
  DocumentExportType _exportType = DocumentExportType.narrative;
  DocumentExportFmt _exportFmt = DocumentExportFmt.pdf;
  String _fileStem = 'export';
  bool _hasSaved = false;
  bool _showPreview = false;
  late File _savePath;
  bool _isRunning = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Document Export"),
        automaticallyImplyLeading: false,
      ),
      body: isLargeScreen
          ? Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildSettings(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPreview(),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Settings'),
                    Tab(text: 'Preview'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSettings(),
                      _buildPreview(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSettings() {
    return FileOperationPage(
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
                  _showPreview = false;
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
                  _showPreview = false;
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
    );
  }

  Widget _buildPreview() {
    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(16.0),
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.4),
      child: !_showPreview
          ? Center(
              child: FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _showPreview = true;
                  });
                },
                icon: const Icon(Icons.visibility),
                label: const Text('Generate Preview'),
              ),
            )
          : _exportFmt == DocumentExportFmt.pdf
              ? PdfPreview(
                  build: (format) async {
                    return await DocumentExportServices(ref: ref)
                        .generateBytes(type: _exportType, format: _exportFmt);
                  },
                  useActions: false,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                )
              : FutureBuilder<Uint8List>(
                  future: DocumentExportServices(ref: ref)
                      .generateBytes(type: _exportType, format: _exportFmt),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No data'));
                    }

                    final text = utf8.decode(snapshot.data!);

                    if (_exportFmt == DocumentExportFmt.md) {
                      return Markdown(data: text);
                    } else {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: SelectableText(text),
                      );
                    }
                  },
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
