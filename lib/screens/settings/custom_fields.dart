import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/forms/custom_field_definition_editor.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/specimens.dart';

class CustomFieldsSettings extends ConsumerStatefulWidget {
  const CustomFieldsSettings({
    super.key,
    required this.projectUuid,
    required this.currentCatalog,
  });

  final String? projectUuid;
  final CatalogFmt currentCatalog;

  @override
  ConsumerState<CustomFieldsSettings> createState() =>
      _CustomFieldsSettingsState();
}

class _CustomFieldsSettingsState extends ConsumerState<CustomFieldsSettings> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final definitions = ref.watch(
      manageableCustomFieldsProvider(widget.projectUuid),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Custom fields')),
      body: ScrollableConstrainedLayout(
        child: Column(
          children: [
            Card(
              child: SwitchListTile(
                title: const Text('Show archived fields'),
                value: _showArchived,
                onChanged: (value) => setState(() => _showArchived = value),
              ),
            ),
            definitions.when(
              data: _definitionGroups,
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('Unable to load fields: $error'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _definitionGroups(List<CustomFieldDefinitionData> definitions) {
    final visible = definitions
        .where((definition) => _showArchived || !definition.archived)
        .toList(growable: false);
    if (visible.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Text('No custom fields in this context.'),
      );
    }
    return Column(
      children: [
        for (final placement in FieldUISection.values)
          if (visible.any((definition) => definition.placement == placement))
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(placement.label),
                  ),
                  const Divider(height: 1),
                  for (final definition in visible.where(
                    (definition) => definition.placement == placement,
                  ))
                    _DefinitionTile(
                      definition: definition,
                      onInspect: () => _inspect(definition),
                      onEdit: () => _edit(definition),
                      onMove: (offset) =>
                          _move(definitions, definition, offset),
                      onArchive: () => _archive(definition),
                      onDiscardLegacy: () => _discardLegacy(definition),
                      onDelete: () => _delete(definition),
                    ),
                ],
              ),
            ),
      ],
    );
  }

  Future<void> _inspect(CustomFieldDefinitionData definition) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _DefinitionDetailsSheet(
        definition: definition,
        onEdit: () {
          Navigator.pop(sheetContext);
          _edit(definition);
        },
      ),
    );
  }

  Future<void> _edit(CustomFieldDefinitionData definition) async {
    final saved = await showCustomFieldDefinitionEditor(
      context: context,
      placement: definition.placement,
      creationContext: CustomFieldCreationContext(
        projectUuid: definition.projectUuid ?? widget.projectUuid ?? '',
        catalogFormat: widget.currentCatalog,
      ),
      definition: definition,
    );
    if (saved != null) _refresh();
  }

  Future<void> _move(
    List<CustomFieldDefinitionData> all,
    CustomFieldDefinitionData definition,
    int offset,
  ) async {
    final group = all
        .where(
          (candidate) =>
              candidate.uiSection == definition.uiSection &&
              candidate.scope == definition.scope &&
              candidate.projectUuid == definition.projectUuid,
        )
        .toList();
    final index = group.indexWhere((item) => item.id == definition.id);
    final target = index + offset;
    if (index < 0 || target < 0 || target >= group.length) return;
    final moved = group.removeAt(index);
    group.insert(target, moved);
    await _run(
      () => ref
          .read(customFieldServiceProvider)
          .reorder(group.map((item) => item.id!).toList()),
    );
  }

  Future<void> _archive(CustomFieldDefinitionData definition) {
    return _run(
      () => ref
          .read(customFieldServiceProvider)
          .setArchived(definition.id!, !definition.archived),
    );
  }

  Future<void> _discardLegacy(CustomFieldDefinitionData definition) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard legacy values?'),
        content: Text(
          'Legacy values for “${definition.name}” cannot be recovered after '
          'they are discarded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard values'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(
      () => ref
          .read(customFieldServiceProvider)
          .discardLegacyValues(definition.id!),
    );
  }

  Future<void> _delete(CustomFieldDefinitionData definition) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete custom field?'),
        content: Text(
          'Delete “${definition.name}” permanently? This action cannot be '
          'undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(
      () =>
          ref.read(customFieldServiceProvider).deleteDefinition(definition.id!),
    );
  }

  Future<void> _run(Future<Object?> Function() action) async {
    try {
      await action();
      _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _refresh() {
    ref.invalidate(manageableCustomFieldsProvider(widget.projectUuid));
    ref.invalidate(allCustomFieldDefinitionsProvider);
  }
}

class _DefinitionTile extends ConsumerWidget {
  const _DefinitionTile({
    required this.definition,
    required this.onInspect,
    required this.onEdit,
    required this.onMove,
    required this.onArchive,
    required this.onDiscardLegacy,
    required this.onDelete,
  });

  final CustomFieldDefinitionData definition;
  final VoidCallback onInspect;
  final VoidCallback onEdit;
  final ValueChanged<int> onMove;
  final VoidCallback onArchive;
  final VoidCallback onDiscardLegacy;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(customFieldUsageProvider(definition.id!));
    final currentUsage = usage.when(
      data: (value) => value,
      error: (_, _) => null,
      loading: () => null,
    );
    return ListTile(
      leading: Icon(
        definition.archived
            ? Icons.archive_outlined
            : Icons.dynamic_form_outlined,
      ),
      title: Text(definition.name),
      subtitle: Text(
        '${_fieldTypeLabel(definition.fieldType)} · '
        '${_scopeLabel(definition.fieldScope)} · '
        '${_catalogLabel(definition)}'
        '${definition.archived ? ' · Archived' : ''}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (action) {
          switch (action) {
            case 'inspect':
              onInspect();
            case 'edit':
              onEdit();
            case 'up':
              onMove(-1);
            case 'down':
              onMove(1);
            case 'archive':
              onArchive();
            case 'discardLegacy':
              onDiscardLegacy();
            case 'delete':
              onDelete();
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'inspect', child: Text('View definition')),
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'up', child: Text('Move up')),
          const PopupMenuItem(value: 'down', child: Text('Move down')),
          PopupMenuItem(
            value: 'archive',
            child: Text(definition.archived ? 'Restore' : 'Archive'),
          ),
          if (currentUsage?.legacyValueCount case final count? when count > 0)
            const PopupMenuItem(
              value: 'discardLegacy',
              child: Text('Discard legacy values'),
            ),
          PopupMenuItem(
            value: 'delete',
            enabled: currentUsage?.canDelete ?? false,
            child: Text(
              currentUsage?.canDelete == true
                  ? 'Delete'
                  : 'Delete (values in use)',
            ),
          ),
        ],
      ),
      onTap: onInspect,
    );
  }
}

class _DefinitionDetailsSheet extends ConsumerWidget {
  const _DefinitionDetailsSheet({
    required this.definition,
    required this.onEdit,
  });

  final CustomFieldDefinitionData definition;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(customFieldUsageProvider(definition.id!));
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    definition.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Target', value: definition.placement.label),
            _DetailRow(
              label: 'Type',
              value: _fieldTypeLabel(definition.fieldType),
            ),
            _DetailRow(
              label: 'Scope',
              value: _scopeLabel(definition.fieldScope),
            ),
            if (definition.projectUuid != null)
              _DetailRow(label: 'Project UUID', value: definition.projectUuid!),
            _DetailRow(
              label: 'Catalog applicability',
              value: _catalogLabel(definition),
            ),
            _DetailRow(
              label: 'Status',
              value: definition.archived ? 'Archived' : 'Active',
            ),
            _DetailRow(label: 'Definition UUID', value: definition.uuid),
            _DetailRow(
              label: 'Source template UUID',
              value:
                  definition.sourceTemplateUuid ??
                  'Not imported from a template',
            ),
            if (definition.fieldType == FieldType.dropdown)
              _DetailRow(
                label: 'Dropdown options',
                value: definition.dropdownOptions
                    .map(
                      (option) => option.isArchived
                          ? '${option.label} (archived)'
                          : option.label,
                    )
                    .join(', '),
              ),
            if (definition.dwcMapping case final mapping?) ...[
              _DetailRow(label: 'Darwin Core target', value: mapping.target),
              _DetailRow(label: 'Darwin Core field', value: mapping.field),
              _DetailRow(
                label: 'Mapping mode',
                value: mapping.mode == DwcMappingMode.direct
                    ? 'Direct field'
                    : 'Repeatable measurement / fact',
              ),
              if (mapping.mode == DwcMappingMode.direct)
                _DetailRow(
                  label: 'Duplicate values acknowledged',
                  value: mapping.allowConflict ? 'Yes' : 'No',
                ),
            ],
            usage.when(
              data: (value) => Column(
                children: [
                  _DetailRow(
                    label: 'Stored values',
                    value: value.valueCount.toString(),
                  ),
                  _DetailRow(
                    label: 'Legacy values',
                    value: value.legacyValueCount.toString(),
                  ),
                  _DetailRow(
                    label: 'Deletion',
                    value: value.canDelete
                        ? 'Available'
                        : 'Unavailable until all stored values are cleared',
                  ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Unable to load usage: $error'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit definition'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          SelectableText(value),
        ],
      ),
    );
  }
}

String _fieldTypeLabel(FieldType type) => switch (type) {
  FieldType.text => 'Text',
  FieldType.number => 'Number',
  FieldType.boolean => 'Yes / No',
  FieldType.dropdown => 'Dropdown',
};

String _scopeLabel(FieldScope scope) => switch (scope) {
  FieldScope.global => 'Global',
  FieldScope.project => 'Current project',
};

String _catalogLabel(CustomFieldDefinitionData definition) {
  final catalog = definition.applicableCatalog;
  return catalog == null
      ? 'All catalog formats'
      : '${matchCatFmtToTaxonGroup(catalog)} only';
}
