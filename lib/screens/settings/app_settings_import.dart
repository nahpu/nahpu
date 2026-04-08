import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/file_operation.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nahpu/services/kdl_services.dart';

class AppSettingsImport extends ConsumerStatefulWidget {
  const AppSettingsImport({super.key});

  @override
  AppSettingsImportState createState() => AppSettingsImportState();
}

class AppSettingsImportState extends ConsumerState<AppSettingsImport> {
  XFile? _settingsFilePath;
  bool _hasSelected = false;
  bool _isLoading = false;
  bool _isSelectingFile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Replace app settings'),
        ),
        body: SafeArea(
          child: CommonSettingList(
            sections: [
              SettingsFileInputField(
                filePath: _settingsFilePath,
                isSelectingFile: _isSelectingFile,
                onPressed: () async {
                  try {
                    await _getSettingsFilePath();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Failed to select file!',
                          ),
                        ),
                      );
                    }
                  }
                },
                onCleared: () {
                  setState(() {
                    _settingsFilePath = null;
                    _hasSelected = false;
                  });
                },
                hasSelected: _hasSelected,
                isLoading: _isLoading,
                onReplaceSettings: () => _replaceAppSettings(),
              ),
            ],
          ),
        ));
  }

  Future<void> _getSettingsFilePath() async {
    setState(() {
      _isSelectingFile = true;
    });
    final settingsFilePath = await FilePickerServices().selectAnyFile();
    if (settingsFilePath != null) {
      setState(() {
        _settingsFilePath = settingsFilePath;
        _hasSelected = true;
        _isSelectingFile = false;
      });
    } else {
      setState(() {
        _isSelectingFile = false;
      });
    }
  }

  Future<void> _replaceAppSettings() async {
    Navigator.of(context).pop();

    try {
      setState(() {
        _isLoading = true;
      });

      // KDL writer
      await KdlServices().readAndUpdateSettings(_settingsFilePath!.path);

      setState(() {
        _isLoading = false;
      });

      if (context.mounted) {
        _showSuccess();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        _showError(e.toString());
      }
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Application settings have been updated!'),
      ),
    );
  }

  void _showError(String errors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Failed to update app settings!: $errors',
        ),
        duration: const Duration(seconds: 10),
      ),
    );
  }
}

class SettingsFileInputField extends StatelessWidget {
  const SettingsFileInputField({
    super.key,
    required this.filePath,
    required this.onPressed,
    required this.onCleared,
    required this.hasSelected,
    required this.isSelectingFile,
    required this.isLoading,
    required this.onReplaceSettings,
  });

  final XFile? filePath;
  final VoidCallback onPressed;
  final VoidCallback onCleared;
  final bool hasSelected;
  final bool isSelectingFile;
  final bool isLoading;
  final VoidCallback onReplaceSettings;

  @override
  Widget build(BuildContext context) {
    return CommonSettingSection(
      children: [
        const SizedBox(height: 8),
        Center(
          child: SelectFileField(
            filePath: filePath,
            width: 460,
            onPressed: onPressed,
            isLoading: isSelectingFile,
            onCleared: onCleared,
            supportedFormat: '.kdl',
            maxWidth: 460,
          ),
        ),
        const SizedBox(height: 16),
        SettingsReplaceButtons(
          hasSelected: hasSelected,
          isRunning: isLoading,
          onPressed: onReplaceSettings,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class SettingsReplaceButtons extends StatelessWidget {
  const SettingsReplaceButtons({
    super.key,
    required this.hasSelected,
    required this.isRunning,
    required this.onPressed,
  });

  final bool hasSelected;
  final bool isRunning;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ProgressButton(
      label: 'Replace',
      icon: Icons.refresh,
      isRunning: isRunning,
      onPressed: !hasSelected
          ? null
          : () async {
              // Alert users before replacing database
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Replace app settings'),
                  content: const SettingsWarningText(),
                  actions: [
                    PrimaryButton(
                      label: 'Cancel',
                      icon: Icons.cancel,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      onPressed: onPressed,
                      child: Text(
                        'Replace',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ),
              );
            },
    );
  }
}

class SettingsWarningText extends StatelessWidget {
  const SettingsWarningText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Replacing the application settings will overwrite all current settings, '
      'including custom setting options such as specimen part types, collection methods, etc. '
      'Continue?',
      textAlign: TextAlign.center,
    );
  }
}
