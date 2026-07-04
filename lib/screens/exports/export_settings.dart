import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/screens/shared/file_operation.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

class ExportSettingsForm extends ConsumerStatefulWidget {
  const ExportSettingsForm({super.key});

  @override
  ExportSettingsFormState createState() => ExportSettingsFormState();
}

class ExportSettingsFormState extends ConsumerState<ExportSettingsForm> {
  ConfigExportFmt exportFmt = ConfigExportFmt.json;
  FileOpCtrModel exportCtr = FileOpCtrModel.empty();
  String _fileStem = 'backup';
  Directory? _selectedDir;
  bool _hasSaved = false;
  bool _isRunning = false;
  late File _savePath;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    exportCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export settings'),
        automaticallyImplyLeading: false,
      ),
      body: FileOperationPage(
        children: [
          FileFormatIcon(path: 'assets/icons/settings.svg'),
          DropdownButtonFormField(
            initialValue: exportFmt,
            decoration: const InputDecoration(
              labelText: 'Settings format',
            ),
            items: configExportFmt.entries
                .map(
                  (e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  ),
                )
                .toList(),
            onChanged: (ConfigExportFmt? value) {
              if (value != null) {
                setState(() {
                  exportFmt = value;
                  _hasSaved = false;
                });
              }
            },
          ),
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
            onPressed: () async {
              await _getDir();
            },
            onCanceled: () {
              setState(() {
                _selectedDir = null;
                _hasSaved = false;
              });
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 20,
            children: [
              SaveSecondaryButton(hasSaved: _hasSaved),
              !_hasSaved
                  ? ProgressButton(
                      label: 'Save',
                      icon: Icons.save_alt_outlined,
                      isRunning: _isRunning,
                      onPressed: exportCtr.isValid
                          ? () async {
                              setState(() {
                                _isRunning = true;
                              });
                              await _writeDb();
                            }
                          : null,
                    )
                  : Builder(
                      builder: (context) {
                        return ShareButton(
                          onPressed: () async {
                            await _shareFile(context);
                          },
                        );
                      },
                    ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _writeDb() async {
    try {
      _savePath = await AppIOServices(
        dir: _selectedDir,
        fileStem: _fileStem,
        ext: exportFmt == ConfigExportFmt.json ? 'json' : 'kdl',
      ).getSavePath();
      await rust_config.exportConfigToFile(
        filePath: _savePath.path,
        isJson: exportFmt == ConfigExportFmt.json,
      );
      setState(() {
        _hasSaved = true;
      });
      if (context.mounted) {
        _showSuccess();
      }
    } catch (e) {
      if (context.mounted) {
        _showError(e.toString());
      }
    }

    setState(() {
      _isRunning = false;
    });
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File saved as $_savePath'),
      ),
    );
  }

  void _showError(String errors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ErrorText(error: errors),
        duration: const Duration(seconds: 10),
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
            content: ErrorText(error: e.toString()),
          ),
        );
      }
    }
  }

  Future<void> _getDir() async {
    final path = await FilePickerServices().selectDir();
    if (path != null) {
      setState(() {
        _selectedDir = path;
      });
    }
  }
}
