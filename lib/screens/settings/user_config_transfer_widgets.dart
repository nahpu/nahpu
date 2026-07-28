import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

const userConfigSectionOrder = [
  rust_config.UserConfigSection.userConfigs,
  rust_config.UserConfigSection.recordExportPresets,
  rust_config.UserConfigSection.templatePresets,
  rust_config.UserConfigSection.documentLayouts,
];

extension UserConfigSectionDisplay on rust_config.UserConfigSection {
  String get label => switch (this) {
    rust_config.UserConfigSection.userConfigs =>
      'Controlled vocabularies and settings',
    rust_config.UserConfigSection.recordExportPresets =>
      'Tabular export presets',
    rust_config.UserConfigSection.templatePresets => 'Document templates',
    rust_config.UserConfigSection.documentLayouts => 'Document layout presets',
  };

  IconData get icon => switch (this) {
    rust_config.UserConfigSection.userConfigs => Icons.list_alt_outlined,
    rust_config.UserConfigSection.recordExportPresets =>
      Icons.table_view_outlined,
    rust_config.UserConfigSection.templatePresets => Icons.description_outlined,
    rust_config.UserConfigSection.documentLayouts =>
      Icons.dashboard_customize_outlined,
  };
}

class UserConfigSectionSelectionCard extends StatelessWidget {
  const UserConfigSectionSelectionCard({
    super.key,
    required this.availableSections,
    required this.selectedSections,
    required this.onChanged,
    required this.enabled,
  });

  final Set<rust_config.UserConfigSection> availableSections;
  final Set<rust_config.UserConfigSection> selectedSections;
  final ValueChanged<Set<rust_config.UserConfigSection>> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Config sections',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: enabled
                      ? () => onChanged(Set.of(availableSections))
                      : null,
                  child: const Text('Select all'),
                ),
                TextButton(
                  onPressed: enabled && selectedSections.isNotEmpty
                      ? () => onChanged({})
                      : null,
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            for (final section in userConfigSectionOrder)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(section.icon),
                title: Text(section.label),
                value: selectedSections.contains(section),
                onChanged: enabled && availableSections.contains(section)
                    ? (selected) {
                        final next = Set.of(selectedSections);
                        if (selected ?? false) {
                          next.add(section);
                        } else {
                          next.remove(section);
                        }
                        onChanged(next);
                      }
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

class UserConfigPreviewPane extends StatelessWidget {
  const UserConfigPreviewPane({
    super.key,
    required this.title,
    required this.preview,
    required this.selectedSections,
    required this.isLoading,
    this.error,
  });

  final String title;
  final rust_config.UserConfigTransferPreview? preview;
  final Set<rust_config.UserConfigSection> selectedSections;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: title,
      isExpanded: true,
      child: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(error!, textAlign: TextAlign.center),
              ),
            );
          }
          if (preview == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Choose a user-config file to preview its contents.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (selectedSections.isEmpty) {
            return const Center(
              child: Text(
                'Select at least one config section.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return Material(
            color: Colors.transparent,
            child: ListView(
              children: [
                for (final section in userConfigSectionOrder)
                  if (selectedSections.contains(section))
                    _SectionPreview(section: section, preview: preview!),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionPreview extends StatelessWidget {
  const _SectionPreview({required this.section, required this.preview});

  final rust_config.UserConfigSection section;
  final rust_config.UserConfigTransferPreview preview;

  @override
  Widget build(BuildContext context) {
    final count = switch (section) {
      rust_config.UserConfigSection.userConfigs => preview.userConfigs.length,
      rust_config.UserConfigSection.recordExportPresets =>
        preview.recordExportPresets.length,
      rust_config.UserConfigSection.templatePresets =>
        preview.templatePresets.length,
      rust_config.UserConfigSection.documentLayouts =>
        preview.documentLayouts.length,
    };
    return ExpansionTile(
      initiallyExpanded: true,
      leading: Icon(section.icon),
      title: Text(section.label),
      subtitle: Text('$count ${count == 1 ? 'entry' : 'entries'}'),
      children: [
        if (count == 0)
          const ListTile(title: Text('No saved entries'))
        else
          switch (section) {
            rust_config.UserConfigSection.userConfigs => _UserConfigsPreview(
              entries: preview.userConfigs,
            ),
            rust_config.UserConfigSection.recordExportPresets =>
              _RecordPresetsPreview(entries: preview.recordExportPresets),
            rust_config.UserConfigSection.templatePresets =>
              _TemplatePresetsPreview(entries: preview.templatePresets),
            rust_config.UserConfigSection.documentLayouts =>
              _DocumentLayoutsPreview(entries: preview.documentLayouts),
          },
      ],
    );
  }
}

class _UserConfigsPreview extends StatelessWidget {
  const _UserConfigsPreview({required this.entries});

  final List<rust_config.UserConfigValuePreview> entries;

  @override
  Widget build(BuildContext context) {
    final vocabularies = entries
        .where((entry) => entry.isControlledVocabulary)
        .toList(growable: false);
    final settings = entries
        .where((entry) => !entry.isControlledVocabulary)
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in vocabularies) _VocabularyPreview(entry: entry),
        if (settings.isNotEmpty) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Other settings',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          for (final entry in settings)
            ListTile(
              dense: true,
              title: Text(entry.label),
              subtitle: Text(
                entry.value ?? entry.values.join(', '),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ],
    );
  }
}

class _VocabularyPreview extends StatelessWidget {
  const _VocabularyPreview({required this.entry});

  final rust_config.UserConfigValuePreview entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          if (entry.values.isEmpty)
            const Text('No items')
          else
            for (final value in entry.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(value)),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _RecordPresetsPreview extends StatelessWidget {
  const _RecordPresetsPreview({required this.entries});

  final List<rust_config.RecordExportPresetPreview> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in entries)
          ListTile(
            dense: true,
            leading: Icon(
              entry.isCompatible
                  ? Icons.table_view_outlined
                  : Icons.warning_amber_outlined,
            ),
            title: Text(entry.name),
            subtitle: Text(
              entry.isCompatible
                  ? '${entry.mappingCount} mappings · ${entry.recordType}'
                  : 'Incompatible preset',
            ),
          ),
      ],
    );
  }
}

class _TemplatePresetsPreview extends StatelessWidget {
  const _TemplatePresetsPreview({required this.entries});

  final List<rust_config.TemplatePresetPreview> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in entries)
          ListTile(
            dense: true,
            leading: const Icon(Icons.description_outlined),
            title: Text(entry.name),
            subtitle: Text(
              entry.description.trim().isEmpty
                  ? entry.recordType
                  : '${entry.recordType} · ${entry.description}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _DocumentLayoutsPreview extends StatelessWidget {
  const _DocumentLayoutsPreview({required this.entries});

  final List<rust_config.DocumentLayoutPreview> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in entries)
          ListTile(
            dense: true,
            leading: const Icon(Icons.dashboard_customize_outlined),
            title: Text(entry.name),
            subtitle: Text(
              '${entry.layoutType} · ${entry.pageSizeKey} · '
              '${entry.blockCount} ${entry.blockCount == 1 ? 'block' : 'blocks'}',
            ),
          ),
      ],
    );
  }
}
