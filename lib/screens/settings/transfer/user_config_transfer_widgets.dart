import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

const userConfigSectionOrder = [
  rust_config.UserConfigSection.userConfigs,
  rust_config.UserConfigSection.recordExportPresets,
  rust_config.UserConfigSection.templatePresets,
  rust_config.UserConfigSection.documentLayouts,
  rust_config.UserConfigSection.templateTablePreview,
  rust_config.UserConfigSection.customFields,
];

extension UserConfigSectionDisplay on rust_config.UserConfigSection {
  String label(AppLocalizations l10n) => switch (this) {
    rust_config.UserConfigSection.userConfigs =>
      l10n.transferSectionUserConfigs,
    rust_config.UserConfigSection.recordExportPresets =>
      l10n.transferSectionRecordExportPresets,
    rust_config.UserConfigSection.templatePresets =>
      l10n.transferSectionTemplatePresets,
    rust_config.UserConfigSection.documentLayouts =>
      l10n.transferSectionDocumentLayouts,
    rust_config.UserConfigSection.templateTablePreview =>
      l10n.transferSectionTemplateTablePreview,
    rust_config.UserConfigSection.customFields =>
      l10n.transferSectionCustomFields,
  };

  IconData get icon => switch (this) {
    rust_config.UserConfigSection.userConfigs => Icons.list_alt_outlined,
    rust_config.UserConfigSection.recordExportPresets =>
      Icons.table_view_outlined,
    rust_config.UserConfigSection.templatePresets => Icons.description_outlined,
    rust_config.UserConfigSection.documentLayouts =>
      Icons.dashboard_customize_outlined,
    rust_config.UserConfigSection.templateTablePreview =>
      Icons.view_column_outlined,
    rust_config.UserConfigSection.customFields => Icons.dynamic_form_outlined,
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
    final l10n = context.l10n;
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.transferConfigSections,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: enabled
                    ? () => onChanged(Set.of(availableSections))
                    : null,
                child: Text(l10n.commonSelectAll),
              ),
              TextButton(
                onPressed: enabled && selectedSections.isNotEmpty
                    ? () => onChanged({})
                    : null,
                child: Text(l10n.commonClear),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final section in userConfigSectionOrder)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(section.icon),
              title: Text(section.label(l10n)),
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.l10n.transferChooseFileToPreview,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (selectedSections.isEmpty) {
            return Center(
              child: Text(
                context.l10n.transferSelectAtLeastOneSection,
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
      rust_config.UserConfigSection.templateTablePreview =>
        preview.templateTablePreviewColumns.length,
      rust_config.UserConfigSection.customFields => preview.customFields.length,
    };
    final l10n = context.l10n;
    return ExpansionTile(
      initiallyExpanded: true,
      leading: Icon(section.icon),
      title: Text(section.label(l10n)),
      subtitle: Text(l10n.transferEntryCount(count)),
      children: [
        if (count == 0)
          ListTile(title: Text(l10n.transferNoSavedEntries))
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
            rust_config.UserConfigSection.templateTablePreview =>
              _TemplateTablePreviewColumnsPreview(
                columns: preview.templateTablePreviewColumns,
              ),
            rust_config.UserConfigSection.customFields => _CustomFieldsPreview(
              entries: preview.customFields,
            ),
          },
      ],
    );
  }
}

class _CustomFieldsPreview extends StatelessWidget {
  const _CustomFieldsPreview({required this.entries});

  final List<rust_config.CustomFieldTemplate> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in entries)
          ListTile(
            dense: true,
            leading: const Icon(Icons.dynamic_form_outlined),
            title: Text(entry.label),
            subtitle: Text(
              '${entry.placement} • ${entry.fieldType}'
              '${entry.catalogFormat == null ? '' : ' • ${entry.catalogFormat}'}'
              '${entry.dwcField == null ? '' : ' • ${entry.dwcField}'}',
            ),
          ),
      ],
    );
  }
}

class _TemplateTablePreviewColumnsPreview extends StatelessWidget {
  const _TemplateTablePreviewColumnsPreview({required this.columns});

  final List<String> columns;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final column in columns)
          ListTile(
            dense: true,
            leading: const Icon(Icons.table_rows_outlined),
            title: Text(column),
          ),
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
              context.l10n.transferOtherSettings,
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
            Text(context.l10n.transferNoItems)
          else
            for (final value in entry.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
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
                  ? '${context.l10n.transferMappingCount(entry.mappingCount)}'
                        ' · ${entry.recordType}'
                  : context.l10n.transferIncompatiblePreset,
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
              '${context.l10n.transferBlockCount(entry.blockCount)}',
            ),
          ),
      ],
    );
  }
}
