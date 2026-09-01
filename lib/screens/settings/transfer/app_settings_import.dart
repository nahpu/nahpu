import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/templates/components/dialogs/missing_font_dialog.dart';
import 'package:nahpu/screens/settings/transfer/user_config_transfer_widgets.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/settings/user_config_transfer_service.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

class AppSettingsImport extends ConsumerStatefulWidget {
  const AppSettingsImport({super.key});

  @override
  ConsumerState<AppSettingsImport> createState() => _AppSettingsImportState();
}

class _AppSettingsImportState extends ConsumerState<AppSettingsImport>
    with SingleTickerProviderStateMixin {
  final UserConfigTransferService _service = const UserConfigTransferService();
  final Set<rust_config.UserConfigSection> _selectedSections = {};
  late final TabController _tabController;
  UserConfigImportSource? _source;
  bool _isSelectingFile = false;
  bool _isImporting = false;
  String? _error;
  UserConfigImportDestination _destination = UserConfigImportDestination.global;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    unawaited(_source?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.sizeOf(context).width > 600;
    final availableSections = _source?.preview.includedSections.toSet() ?? {};
    final settingsPane = ScrollableConstrainedLayout(
      child: Column(
        children: [
          const FileFormatIcon(path: 'assets/icons/settings.svg'),
          Card(
            elevation: 0,
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectFileField(
                filePath: _source?.input,
                width: 520,
                maxWidth: 520,
                isLoading: _isSelectingFile,
                onPressed: _selectFile,
                onCleared: _clearFile,
                supportedFormat: '.json, .json.gz',
              ),
            ),
          ),
          const SizedBox(height: 8),
          UserConfigSectionSelectionCard(
            availableSections: availableSections,
            selectedSections: _selectedSections,
            enabled: _source != null && !_isImporting,
            onChanged: (sections) {
              setState(() {
                _selectedSections
                  ..clear()
                  ..addAll(sections);
              });
            },
          ),
          if (_selectedSections.contains(
            rust_config.UserConfigSection.customFields,
          )) ...[
            const SizedBox(height: 8),
            _CustomFieldDestinationCard(
              destination: _destination,
              projectAvailable: ref.watch(projectUuidProvider).isNotEmpty,
              enabled: !_isImporting,
              onChanged: (destination) {
                setState(() => _destination = destination);
              },
            ),
          ],
          const SizedBox(height: 24),
          ProgressButton(
            label: 'Import selected configs',
            icon: Icons.refresh_rounded,
            isRunning: _isImporting,
            onPressed: _canImport ? _confirmImport : null,
          ),
        ],
      ),
    );
    final previewPane = Padding(
      padding: const EdgeInsets.all(16),
      child: UserConfigPreviewPane(
        title: 'Will import',
        preview: _source?.preview,
        selectedSections: _selectedSections,
        isLoading: _isSelectingFile,
        error: _error,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Import user configs')),
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

  bool get _canImport =>
      _source != null && _selectedSections.isNotEmpty && !_isImporting;

  Future<void> _selectFile() async {
    setState(() {
      _isSelectingFile = true;
      _error = null;
    });
    try {
      final selected = await FilePickerServices().selectUserConfigFile();
      if (selected == null) return;
      final nextSource = await _service.inspect(selected);
      if (!mounted) {
        await nextSource.dispose();
        return;
      }
      final previousSource = _source;
      setState(() {
        _source = nextSource;
        _selectedSections
          ..clear()
          ..addAll(nextSource.preview.includedSections);
      });
      await previousSource?.dispose();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSelectingFile = false);
    }
  }

  void _clearFile() {
    final previousSource = _source;
    setState(() {
      _source = null;
      _selectedSections.clear();
      _error = null;
    });
    unawaited(previousSource?.dispose());
  }

  Future<void> _confirmImport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import selected configs?'),
        content: _ImportConfirmation(sections: _selectedSections),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _import();
  }

  Future<void> _import() async {
    final source = _source;
    if (source == null) return;
    setState(() => _isImporting = true);
    try {
      await _service.import(
        source,
        _selectedSections,
        database: ref.read(databaseProvider),
        destination: _destination,
        projectUuid: switch (ref.read(projectUuidProvider)) {
          final uuid when uuid.isNotEmpty => uuid,
          _ => null,
        },
      );
      _invalidateSettingsProviders();
      if (!mounted) return;
      // Imported templates can name fonts this installation does not have,
      // so repair them before the user opens one and finds it unrenderable.
      if (_selectedSections.contains(
        rust_config.UserConfigSection.templatePresets,
      )) {
        await resolveStoredTemplateFonts(context, ref);
        if (!mounted) return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected user configs were imported.')),
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
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _invalidateSettingsProviders() {
    ref.invalidate(userDefinedFieldProvider);
    ref.invalidate(specimenSexVocabularyProvider);
    ref.invalidate(textCaseFmtProvider);
    ref.invalidate(fieldIdModeNotifierProvider);
    ref.invalidate(projectFieldIdAutoIncrementProvider);
    ref.invalidate(exportPresetNotifierProvider);
    invalidateCustomFieldDefinitionProviders(ref);
  }
}

class _ImportConfirmation extends StatelessWidget {
  const _ImportConfirmation({required this.sections});

  final Set<rust_config.UserConfigSection> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The selected groups will be replaced. Custom fields are matched '
          'by template ID and merged, so existing definitions are kept. '
          'Unselected groups remain unchanged.',
        ),
        const SizedBox(height: 12),
        for (final section in userConfigSectionOrder)
          if (sections.contains(section))
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• ${section.label}'),
            ),
      ],
    );
  }
}

class _CustomFieldDestinationCard extends StatelessWidget {
  const _CustomFieldDestinationCard({
    required this.destination,
    required this.projectAvailable,
    required this.enabled,
    required this.onChanged,
  });

  final UserConfigImportDestination destination;
  final bool projectAvailable;
  final bool enabled;
  final ValueChanged<UserConfigImportDestination> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = projectAvailable
        ? destination
        : UserConfigImportDestination.global;
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<UserConfigImportDestination>(
          key: ValueKey(value),
          initialValue: value,
          decoration: const InputDecoration(
            labelText: 'Custom field destination',
          ),
          items: [
            const DropdownMenuItem(
              value: UserConfigImportDestination.global,
              child: Text('Global'),
            ),
            if (projectAvailable)
              const DropdownMenuItem(
                value: UserConfigImportDestination.currentProject,
                child: Text('Current project'),
              ),
          ],
          onChanged: enabled
              ? (next) {
                  if (next != null) onChanged(next);
                }
              : null,
        ),
      ),
    );
  }
}
