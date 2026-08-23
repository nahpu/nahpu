import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/screens/settings/user_config_transfer_widgets.dart';
import 'package:nahpu/screens/shared/actions/export_action_bar.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/settings/user_config_transfer_service.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/styles/design_tokens.dart';

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
  List<CustomFieldDefinitionData> _customFields = const [];
  final Set<int> _selectedCustomFieldIds = {};
  Directory? _selectedDirectory;
  File? _savedFile;
  bool _isLoadingPreview = true;
  bool _isRunning = false;
  bool _appendDate = false;
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
    final isLargeScreen =
        MediaQuery.sizeOf(context).width >= NahpuBreakpoints.compact;
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
          if (_selectedSections.contains(
            rust_config.UserConfigSection.customFields,
          )) ...[
            const SizedBox(height: 8),
            _CustomFieldDefinitionPicker(
              definitions: _customFields,
              selectedIds: _selectedCustomFieldIds,
              enabled: !_isRunning,
              onChanged: (ids) {
                setState(() {
                  _selectedCustomFieldIds
                    ..clear()
                    ..addAll(ids);
                  _savedFile = null;
                });
                _refreshPreview();
              },
            ),
          ],
          const SizedBox(height: 8),
          GenericFileSettingsCard<UserConfigFileFormat>(
            exportCtr: _exportController,
            format: _format,
            formats: UserConfigFileFormat.values,
            formatLabel: (format) => format.label,
            extensionForFormat: (format) => format.extension,
            onFormatChanged: (format) {
              setState(() {
                _format = format;
                _savedFile = null;
              });
            },
            onFileNameChanged: (_) => setState(() => _savedFile = null),
            appendDate: _appendDate,
            onAppendDateChanged: (value) => setState(() {
              _appendDate = value;
              _savedFile = null;
            }),
          ),
          const SizedBox(height: 8),
          ExportLocationCard(
            selectedDir: _selectedDirectory,
            output: _savedFile,
            enabled: !_isRunning,
            onSelectDir: _selectDirectory,
            onClearDir: _clearDestination,
            onShare: _share,
            onOpenFolder: _openFolder,
            onDismiss: _clearDestination,
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

    final body = isLargeScreen
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
                  Tab(icon: Icon(Icons.settings_outlined), text: 'Settings'),
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
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Export user configs')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body),
            ExportActionBar(
              label: 'Export settings',
              repeatLabel: 'Export another',
              icon: Icons.file_upload_outlined,
              canExport: _canExport,
              isRunning: _isRunning,
              hasOutput: _savedFile != null,
              onExport: _export,
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
      final database = ref.read(databaseProvider);
      final projectUuid = ref.read(projectUuidProvider);
      final definitions = await _service.availableCustomFields(
        database,
        projectUuid: projectUuid.isEmpty ? null : projectUuid,
      );
      _selectedCustomFieldIds.addAll(
        definitions.map((definition) => definition.id!),
      );
      final preview = await _service.currentPreview(
        database: database,
        projectUuid: projectUuid.isEmpty ? null : projectUuid,
        selectedDefinitionIds: _selectedCustomFieldIds,
      );
      if (!mounted) return;
      setState(() {
        _customFields = definitions;
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

  Future<void> _refreshPreview() async {
    setState(() {
      _isLoadingPreview = true;
      _previewError = null;
    });
    try {
      final projectUuid = ref.read(projectUuidProvider);
      final preview = await _service.currentPreview(
        database: ref.read(databaseProvider),
        projectUuid: projectUuid.isEmpty ? null : projectUuid,
        selectedDefinitionIds: _selectedCustomFieldIds,
      );
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
        fileStem: _appendDate
            ? appendDateToFileStem(
                _exportController.fileNameCtr.text,
                DateTime.now(),
              )
            : _exportController.fileNameCtr.text.trim(),
        ext: _format.extension,
      ).getSavePath();
      await _service.export(
        output: output,
        format: _format,
        sections: _selectedSections,
        database: ref.read(databaseProvider),
        projectUuid: switch (ref.read(projectUuidProvider)) {
          final uuid when uuid.isNotEmpty => uuid,
          _ => null,
        },
        selectedDefinitionIds: _selectedCustomFieldIds,
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

  /// Closing the result also drops the directory, so one tap lands back on the
  /// directory input rather than on a filled-in path that needs clearing too.
  void _clearDestination() {
    setState(() {
      _selectedDirectory = null;
      _savedFile = null;
    });
  }

  Future<void> _openFolder() async {
    final file = _savedFile;
    if (file == null) return;
    try {
      await FilePickerServices().openContainingDirectory(file);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open the folder: $error')),
        );
      }
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

class _CustomFieldDefinitionPicker extends StatelessWidget {
  const _CustomFieldDefinitionPicker({
    required this.definitions,
    required this.selectedIds,
    required this.enabled,
    required this.onChanged,
  });

  final List<CustomFieldDefinitionData> definitions;
  final Set<int> selectedIds;
  final bool enabled;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Custom field templates',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: enabled
                    ? () => onChanged(
                        definitions.map((field) => field.id!).toSet(),
                      )
                    : null,
                child: const Text('Select all'),
              ),
              TextButton(
                onPressed: enabled && selectedIds.isNotEmpty
                    ? () => onChanged({})
                    : null,
                child: const Text('Clear'),
              ),
            ],
          ),
          if (definitions.isEmpty)
            const ListTile(title: Text('No custom fields available'))
          else
            for (final definition in definitions)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(definition.name),
                subtitle: Text(
                  '${definition.placement.label} • '
                  '${definition.fieldScope.name}',
                ),
                value: selectedIds.contains(definition.id),
                onChanged: enabled
                    ? (selected) {
                        final next = Set<int>.of(selectedIds);
                        if (selected ?? false) {
                          next.add(definition.id!);
                        } else {
                          next.remove(definition.id);
                        }
                        onChanged(next);
                      }
                    : null,
              ),
        ],
      ),
    );
  }
}
