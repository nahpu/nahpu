import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/file_operation.dart';
import 'package:nahpu/services/export/archive.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:path/path.dart' as p;

class BundleProjectForm extends ConsumerStatefulWidget {
  const BundleProjectForm({super.key});

  @override
  BundleProjectFormState createState() => BundleProjectFormState();
}

class BundleProjectFormState extends ConsumerState<BundleProjectForm> {
  FileOpCtrModel exportCtr = FileOpCtrModel.empty();
  Directory? _selectedDir;
  String _fileStem = 'export';
  bool _hasSaved = false;
  bool _isRunning = false;
  late File _savePath;
  bool _isInaccurateInBrackets = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bundle Project"),
        automaticallyImplyLeading: false,
      ),
      resizeToAvoidBottomInset: false,
      body: FileOperationPage(
        children: [
          const FileFormatIcon(path: 'assets/icons/zip.svg'),
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
          SwitchField(
              value: _isInaccurateInBrackets,
              label: 'Inaccurate in brackets',
              onPressed: (bool value) {
                setState(() {
                  _isInaccurateInBrackets = value;
                  _hasSaved = false;
                });
              }),
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
              SaveSecondaryButton(
                hasSaved: _hasSaved,
              ),
              !_hasSaved
                  ? ProgressButton(
                      label: 'Bundle',
                      onPressed: !exportCtr.isValid
                          ? null
                          : () async {
                              setState(() {
                                _isRunning = true;
                              });
                              try {
                                await _bundleProject();
                                _finishProcessing();
                              } catch (e) {
                                _showError(e.toString());
                              }
                            },
                      isRunning: _isRunning,
                      icon: Icons.archive_outlined,
                    )
                  : Builder(builder: (newContext) {
                      return ProgressButton(
                        label: 'Share',
                        onPressed: () async {
                          await _shareFile(newContext);
                        },
                        isRunning: _isRunning,
                        icon: Icons.adaptive.share_outlined,
                      );
                    }),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _bundleProject() async {
    _savePath = await AppIOServices(
      dir: _selectedDir,
      fileStem: _fileStem,
      ext: 'zip',
    ).getSavePath();
    final archiveServices = BundleWriter(
      ref: ref,
      outputFile: _savePath,
      isInaccurateInBrackets: _isInaccurateInBrackets,
    );
    await archiveServices.create();
  }

  Future<void> _shareFile(BuildContext newContext) async {
    try {
      await FilePickerServices().shareFile(newContext, _savePath);
    } catch (e) {
      if (context.mounted) {
        _showErrors(e.toString());
      }
    }
  }

  void _showErrors(String errors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errors),
      ),
    );
  }

  Future<void> _getDir() async {
    final Directory? dir = await FilePickerServices().selectDir();
    if (dir != null) {
      setState(() {
        _selectedDir = dir;
      });
    }
  }

  void _finishProcessing() {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: systemPlatform == PlatformType.desktop
              ? Text('Finished creating bundle: ${p.basename(_savePath.path)}')
              : const Text('Done!'),
          duration: const Duration(seconds: 8),
        ),
      );
      setState(() {
        _hasSaved = true;
        _isRunning = false;
      });
    }
  }

  void _showError(String errors) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errors),
      ),
    );
  }
}
