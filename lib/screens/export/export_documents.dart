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
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:nahpu/services/providers/settings.dart';

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
                    child: DocumentExportSettings(
                      exportType: _exportType,
                      exportFmt: _exportFmt,
                      fileStem: _fileStem,
                      hasSaved: _hasSaved,
                      isRunning: _isRunning,
                      selectedDir: _selectedDir,
                      exportCtr: exportCtr,
                      onExportTypeChanged: (DocumentExportType? value) {
                        if (value != null) {
                          setState(() {
                            _exportType = value;
                            _hasSaved = false;
                            _showPreview = false;
                          });
                        }
                      },
                      onExportFmtChanged: (DocumentExportFmt? value) {
                        if (value != null) {
                          setState(() {
                            _exportFmt = value;
                            _hasSaved = false;
                            _showPreview = false;
                          });
                        }
                      },
                      onFileStemChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _fileStem = value;
                            _hasSaved = false;
                          });
                        }
                      },
                      onDirSelected: _getDir,
                      onDirCleared: () {
                        setState(() {
                          _selectedDir = null;
                          _hasSaved = false;
                        });
                      },
                      onSave: () async {
                        setState(() {
                          _isRunning = true;
                        });
                        await _writeDocument();
                        setState(() {
                          _isRunning = false;
                        });
                      },
                      onShare: (context) {
                        _shareFile(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DocumentExportPreview(
                      showPreview: _showPreview,
                      exportFmt: _exportFmt,
                      exportType: _exportType,
                      onGeneratePreview: () {
                        setState(() {
                          _showPreview = true;
                        });
                      },
                    ),
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
                      DocumentExportSettings(
                        exportType: _exportType,
                        exportFmt: _exportFmt,
                        fileStem: _fileStem,
                        hasSaved: _hasSaved,
                        isRunning: _isRunning,
                        selectedDir: _selectedDir,
                        exportCtr: exportCtr,
                        onExportTypeChanged: (DocumentExportType? value) {
                          if (value != null) {
                            setState(() {
                              _exportType = value;
                              _hasSaved = false;
                              _showPreview = false;
                            });
                          }
                        },
                        onExportFmtChanged: (DocumentExportFmt? value) {
                          if (value != null) {
                            setState(() {
                              _exportFmt = value;
                              _hasSaved = false;
                              _showPreview = false;
                            });
                          }
                        },
                        onFileStemChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _fileStem = value;
                              _hasSaved = false;
                            });
                          }
                        },
                        onDirSelected: _getDir,
                        onDirCleared: () {
                          setState(() {
                            _selectedDir = null;
                            _hasSaved = false;
                          });
                        },
                        onSave: () async {
                          setState(() {
                            _isRunning = true;
                          });
                          await _writeDocument();
                          setState(() {
                            _isRunning = false;
                          });
                        },
                        onShare: (context) {
                          _shareFile(context);
                        },
                      ),
                      DocumentExportPreview(
                        showPreview: _showPreview,
                        exportFmt: _exportFmt,
                        exportType: _exportType,
                        onGeneratePreview: () {
                          setState(() {
                            _showPreview = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
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

class DocumentExportSettings extends StatelessWidget {
  const DocumentExportSettings({
    super.key,
    required this.exportType,
    required this.exportFmt,
    required this.fileStem,
    required this.hasSaved,
    required this.isRunning,
    required this.selectedDir,
    required this.exportCtr,
    required this.onExportTypeChanged,
    required this.onExportFmtChanged,
    required this.onFileStemChanged,
    required this.onDirSelected,
    required this.onDirCleared,
    required this.onSave,
    required this.onShare,
  });

  final DocumentExportType exportType;
  final DocumentExportFmt exportFmt;
  final String fileStem;
  final bool hasSaved;
  final bool isRunning;
  final Directory? selectedDir;
  final FileOpCtrModel exportCtr;
  final void Function(DocumentExportType?) onExportTypeChanged;
  final void Function(DocumentExportFmt?) onExportFmtChanged;
  final void Function(String?) onFileStemChanged;
  final VoidCallback onDirSelected;
  final VoidCallback onDirCleared;
  final VoidCallback onSave;
  final void Function(BuildContext) onShare;

  @override
  Widget build(BuildContext context) {
    return FileOperationPage(
      children: [
        const FileFormatIcon(path: 'assets/icons/pdf.svg'),
        DropdownButtonFormField(
            initialValue: exportType,
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
            onChanged: onExportTypeChanged),
        DropdownButtonFormField(
            initialValue: exportFmt,
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
            onChanged: onExportFmtChanged),
        FileNameField(
          controller: exportCtr,
          onChanged: onFileStemChanged,
        ),
        SelectDirField(
          dirPath: selectedDir,
          onPressed: onDirSelected,
          onCanceled: onDirCleared,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 20,
          children: [
            SaveSecondaryButton(hasSaved: hasSaved),
            !hasSaved
                ? ProgressButton(
                    label: 'Save',
                    isRunning: isRunning,
                    icon: Icons.save_alt_outlined,
                    onPressed: !exportCtr.isValid ? null : onSave,
                  )
                : Builder(
                    builder: (BuildContext context) {
                      return ShareButton(onPressed: () => onShare(context));
                    },
                  ),
          ],
        )
      ],
    );
  }
}

class DocumentExportPreview extends ConsumerStatefulWidget {
  const DocumentExportPreview({
    super.key,
    required this.showPreview,
    required this.exportFmt,
    required this.exportType,
    required this.onGeneratePreview,
  });

  final bool showPreview;
  final DocumentExportFmt exportFmt;
  final DocumentExportType exportType;
  final VoidCallback onGeneratePreview;

  @override
  ConsumerState<DocumentExportPreview> createState() => _DocumentExportPreviewState();
}

class _DocumentExportPreviewState extends ConsumerState<DocumentExportPreview> {
  Future<Uint8List>? _bytesFuture;

  @override
  void initState() {
    super.initState();
    if (widget.showPreview) {
      _fetchData();
    }
  }

  @override
  void didUpdateWidget(DocumentExportPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPreview &&
        (!oldWidget.showPreview ||
            widget.exportFmt != oldWidget.exportFmt ||
            widget.exportType != oldWidget.exportType)) {
      _fetchData();
    } else if (!widget.showPreview) {
      _bytesFuture = null;
    }
  }

  void _fetchData() {
    final fmt = widget.exportFmt == DocumentExportFmt.pdf
        ? DocumentExportFmt.md
        : widget.exportFmt;
    _bytesFuture = DocumentExportServices(ref: ref)
        .generateBytes(type: widget.exportType, format: fmt);
  }

  @override
  Widget build(BuildContext context) {


    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(16.0),
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.4),
      child: !widget.showPreview
          ? Center(
              child: FilledButton.icon(
                onPressed: widget.onGeneratePreview,
                icon: const Icon(Icons.visibility),
                label: const Text('Generate Preview'),
              ),
            )
          : FutureBuilder<Uint8List>(
                  future: _bytesFuture,
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
                    final fontName =
                        ref.watch(pdfExportFontNotifierProvider).value ??
                            'Merriweather';

                    final isPdfPreview = widget.exportFmt == DocumentExportFmt.pdf;
                    final isMd = widget.exportFmt == DocumentExportFmt.md || isPdfPreview;

                    Widget content;
                    if (isMd) {
                      content = Markdown(
                        data: text,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(fontFamily: fontName),
                          h1: TextStyle(fontFamily: fontName),
                          h2: TextStyle(fontFamily: fontName),
                          h3: TextStyle(fontFamily: fontName),
                          h4: TextStyle(fontFamily: fontName),
                          h5: TextStyle(fontFamily: fontName),
                          h6: TextStyle(fontFamily: fontName),
                          listBullet: TextStyle(fontFamily: fontName),
                        ),
                      );
                    } else {
                      content = SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: SelectableText(text),
                      );
                    }

                    if (isPdfPreview) {
                      return Column(
                        children: [
                          Container(
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'Previewing as Markdown (Export will be PDF)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(child: content),
                        ],
                      );
                    }

                    return content;
                  },
                ),
    );
  }
}
