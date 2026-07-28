import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/settings/user_config_transfer_widgets.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/user_config_transfer_service.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

class ExportSettingsForm extends ConsumerStatefulWidget {
  const ExportSettingsForm({super.key});

  @override
  ConsumerState<ExportSettingsForm> createState() => _ExportSettingsFormState();
}

class _ExportSettingsFormState extends ConsumerState<ExportSettingsForm>
    with SingleTickerProviderStateMixin {
  final FileOpCtrModel _exportController = FileOpCtrModel.empty();
  final UserConfigTransferService _service = const UserConfigTransferService();
  final Set<rust_config.UserConfigSection> _selectedSections = Set.of(
    userConfigSectionOrder,
  );
  late final TabController _tabController;
  UserConfigFileFormat _format = UserConfigFileFormat.json;
  rust_config.UserConfigTransferPreview? _preview;
  Directory? _selectedDirectory;
  File? _savedFile;
  bool _isLoadingPreview = true;
  bool _isRunning = false;
  String? _previewError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _exportController.fileNameCtr.text = 'nahpu-user-configs';
    _loadPreview();
  }

  @override
  void dispose() {
    _exportController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.sizeOf(context).width > 600;
    final settingsPane = ScrollableConstrainedLayout(
      child: Column(
        children: [
          const FileFormatIcon(path: 'assets/icons/settings.svg'),
          UserConfigSectionSelectionCard(
            availableSections: Set.of(userConfigSectionOrder),
            selectedSections: _selectedSections,
            enabled: !_isRunning,
            onChanged: (sections) {
              setState(() {
                _selectedSections
                  ..clear()
                  ..addAll(sections);
                _savedFile = null;
              });
            },
          ),
          const SizedBox(height: 8),
          GenericFileSettingsCard<UserConfigFileFormat>(
            exportCtr: _exportController,
            selectedDir: _selectedDirectory,
            format: _format,
            formats: UserConfigFileFormat.values,
            formatLabel: (format) => format.label,
            onFormatChanged: (format) {
              setState(() {
                _format = format;
                _savedFile = null;
              });
            },
            onFileNameChanged: (_) => setState(() => _savedFile = null),
            onSelectDir: _selectDirectory,
            onClearDir: () => setState(() {
              _selectedDirectory = null;
              _savedFile = null;
            }),
          ),
          const SizedBox(height: 24),
          ExportShareButton(
            hasExported: _savedFile != null,
            isRunning: _isRunning,
            onExport: _canExport ? _export : null,
            onShare: _share,
          ),
        ],
      ),
    );
    final previewPane = Padding(
      padding: const EdgeInsets.all(16),
      child: UserConfigPreviewPane(
        title: 'Will export',
        preview: _preview,
        selectedSections: _selectedSections,
        isLoading: _isLoadingPreview,
        error: _previewError,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Export user configs')),
      body: SafeArea(
        child: isLargeScreen
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: settingsPane),
                  Expanded(child: previewPane),
                ],
              )
            : Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.settings_outlined),
                        text: 'Settings',
                      ),
                      Tab(icon: Icon(Icons.preview_outlined), text: 'Preview'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [settingsPane, previewPane],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  bool get _canExport =>
      !_isLoadingPreview &&
      _previewError == null &&
      _exportController.isValid &&
      _selectedSections.isNotEmpty &&
      !_isRunning;

  Future<void> _loadPreview() async {
    try {
      final preview = await _service.currentPreview();
      if (!mounted) return;
      setState(() {
        _preview = preview;
        _isLoadingPreview = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _previewError = error.toString();
        _isLoadingPreview = false;
      });
    }
  }

  Future<void> _selectDirectory() async {
    final selected = await FilePickerServices().selectDir();
    if (selected == null || !mounted) return;
    setState(() {
      _selectedDirectory = selected;
      _savedFile = null;
    });
  }

  Future<void> _export() async {
    setState(() => _isRunning = true);
    try {
      final output = await AppIOServices(
        dir: _selectedDirectory,
        fileStem: _exportController.fileNameCtr.text.trim(),
        ext: _format.extension,
      ).getSavePath();
      await _service.export(
        output: output,
        format: _format,
        sections: _selectedSections,
      );
      if (!mounted) return;
      setState(() => _savedFile = output);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User configs exported to ${output.path}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ErrorText(error: error.toString()),
          duration: const Duration(seconds: 10),
        ),
      );
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  Future<void> _share() async {
    final file = _savedFile;
    if (file == null) return;
    try {
      await FilePickerServices().shareFile(context, file);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: ErrorText(error: error.toString())));
    }
  }
}
