import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/custom_field_transfer.dart';
import 'package:nahpu/screens/shared/actions/preset_actions.dart';
import 'package:nahpu/screens/shared/forms/custom_field_definition_editor.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/settings/user_config_transfer_service.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/nahpu_icons.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

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
      appBar: AppBar(
        title: const Text('Custom fields'),
        actions: [
          PresetAppBarActions(
            itemName: 'custom field',
            onCreate: _create,
            onScanQr: _scanQr,
            onImport: _importFile,
            onExport: _export,
          ),
        ],
      ),
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
                    leading: Icon(_placementIcon(placement)),
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

  Future<void> _create() async {
    final placement = await showDialog<FieldUISection>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Create custom field'),
        children: [
          for (final value in FieldUISection.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, value),
              child: ListTile(
                leading: Icon(_placementIcon(value)),
                title: Text(value.label),
                contentPadding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
    if (placement == null || !mounted) return;
    final saved = await showCustomFieldDefinitionEditor(
      context: context,
      placement: placement,
      creationContext: CustomFieldCreationContext(
        projectUuid: widget.projectUuid ?? '',
        catalogFormat: placement.isSpecimenRelated
            ? widget.currentCatalog
            : null,
      ),
    );
    if (saved != null) _refresh();
  }

  Future<void> _scanQr() async {
    final payload = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ScannerScreen(
          onDetect: (capture) {
            final rawValue = capture.barcodes.firstOrNull?.rawValue;
            if (rawValue != null) Navigator.of(context).pop(rawValue);
          },
        ),
      ),
    );
    if (payload == null || !mounted) return;
    UserConfigImportSource? source;
    try {
      source = await const UserConfigTransferService()
          .inspectCustomFieldPayload(payload);
      if (!mounted) return;
      await _importSource(source);
    } catch (error) {
      if (mounted) _showError('Unable to import QR code: $error');
    } finally {
      await source?.dispose();
    }
  }

  Future<void> _importFile() async {
    UserConfigImportSource? source;
    try {
      final selected = await FilePickerServices().selectUserConfigFile();
      if (selected == null) return;
      source = await const UserConfigTransferService().inspect(selected);
      if (!mounted) return;
      await _importSource(source);
    } catch (error) {
      if (mounted) _showError('Unable to import custom fields: $error');
    } finally {
      await source?.dispose();
    }
  }

  Future<void> _importSource(UserConfigImportSource source) async {
    if (source.preview.customFields.isEmpty) {
      throw const FormatException(
        'This user-config payload has no custom field templates.',
      );
    }
    final destination = await showCustomFieldImportPreview(
      context: context,
      source: source,
      projectAvailable: widget.projectUuid?.isNotEmpty ?? false,
    );
    if (destination == null || !mounted) return;
    await const UserConfigTransferService().import(
      source,
      const {rust_config.UserConfigSection.customFields},
      database: ref.read(databaseProvider),
      destination: destination,
      projectUuid: widget.projectUuid,
    );
    _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Imported ${source.preview.customFields.length} custom field '
          '${source.preview.customFields.length == 1 ? 'definition' : 'definitions'}.',
        ),
      ),
    );
  }

  Future<void> _export() async {
    try {
      final definitions = await ref.read(
        manageableCustomFieldsProvider(widget.projectUuid).future,
      );
      if (!mounted) return;
      final choice = await showCustomFieldExportSelection(
        context: context,
        definitions: definitions,
      );
      if (choice == null || !mounted) return;
      switch (choice.method) {
        case CustomFieldExportMethod.file:
          await _exportFile(choice.ids);
        case CustomFieldExportMethod.qr:
          await _showQr(choice.ids);
      }
    } catch (error) {
      if (mounted) _showError('Unable to export custom fields: $error');
    }
  }

  Future<void> _exportFile(Set<int> definitionIds) async {
    final directory = await FilePickerServices().selectDir();
    if (directory == null) return;
    final output = await AppIOServices(
      dir: directory,
      fileStem: 'nahpu-custom-fields',
      ext: 'json',
    ).getSavePath();
    await const UserConfigTransferService().export(
      output: output,
      format: UserConfigFileFormat.json,
      sections: const {rust_config.UserConfigSection.customFields},
      database: ref.read(databaseProvider),
      projectUuid: widget.projectUuid,
      selectedDefinitionIds: definitionIds,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Custom fields exported to ${output.path}')),
    );
  }

  Future<void> _showQr(Set<int> definitionIds) async {
    final payload = await const UserConfigTransferService()
        .exportCustomFieldPayload(
          database: ref.read(databaseProvider),
          projectUuid: widget.projectUuid,
          selectedDefinitionIds: definitionIds,
        );
    if (!mounted) return;
    if (!canEncodeQrPayload(payload)) {
      final exportFile = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('QR code is too large'),
          content: const Text(
            'The selected custom fields contain too much data for one QR '
            'code. Export them as a file instead.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('Export file'),
            ),
          ],
        ),
      );
      if (exportFile == true) await _exportFile(definitionIds);
      return;
    }
    await showCustomFieldQrDialog(
      context: context,
      payload: payload,
      definitionCount: definitionIds.length,
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
    invalidateCustomFieldDefinitionProviders(ref);
  }

  IconData _placementIcon(FieldUISection placement) => switch (placement) {
    FieldUISection.siteAttribute => Icons.place_outlined,
    FieldUISection.environmentalData => Icons.eco_outlined,
    FieldUISection.specimenAttribute => matchCatFmtToIcon(
      widget.currentCatalog,
    ),
    FieldUISection.specimenPart => NahpuIcons.vialOutlined,
    FieldUISection.parasite => Icons.bug_report_outlined,
  };

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      trailing: MediaQuery.sizeOf(context).width < 600
          ? IconButton(
              key: const ValueKey('custom-field-actions-bottom-sheet'),
              icon: const Icon(Icons.more_vert),
              tooltip: 'Definition actions',
              onPressed: () => _showActionSheet(context, currentUsage),
            )
          : PopupMenuButton<_DefinitionAction>(
              tooltip: 'Definition actions',
              onSelected: _selectAction,
              itemBuilder: (_) => _popupItems(currentUsage),
            ),
      onTap: onInspect,
    );
  }

  List<PopupMenuEntry<_DefinitionAction>> _popupItems(
    CustomFieldUsage? usage,
  ) => [
    const PopupMenuItem(
      value: _DefinitionAction.inspect,
      child: Text('View definition'),
    ),
    const PopupMenuItem(value: _DefinitionAction.edit, child: Text('Edit')),
    const PopupMenuDivider(height: 8),
    const PopupMenuItem(value: _DefinitionAction.up, child: Text('Move up')),
    const PopupMenuItem(
      value: _DefinitionAction.down,
      child: Text('Move down'),
    ),
    const PopupMenuDivider(height: 8),
    PopupMenuItem(
      value: _DefinitionAction.archive,
      child: Text(definition.archived ? 'Restore' : 'Archive'),
    ),
    if (usage?.legacyValueCount case final count? when count > 0)
      const PopupMenuItem(
        value: _DefinitionAction.discardLegacy,
        child: Text('Discard legacy values'),
      ),
    PopupMenuItem(
      value: _DefinitionAction.delete,
      enabled: usage?.canDelete ?? false,
      child: Text(
        usage?.canDelete == true ? 'Delete' : 'Delete (values in use)',
      ),
    ),
  ];

  Future<void> _showActionSheet(
    BuildContext context,
    CustomFieldUsage? usage,
  ) async {
    final action = await showModalBottomSheet<_DefinitionAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DefinitionActionTile(
              icon: Icons.visibility_outlined,
              label: 'View definition',
              action: _DefinitionAction.inspect,
            ),
            _DefinitionActionTile(
              icon: Icons.edit_outlined,
              label: 'Edit',
              action: _DefinitionAction.edit,
            ),
            const Divider(height: 1),
            const _DefinitionActionTile(
              icon: Icons.arrow_upward,
              label: 'Move up',
              action: _DefinitionAction.up,
            ),
            const _DefinitionActionTile(
              icon: Icons.arrow_downward,
              label: 'Move down',
              action: _DefinitionAction.down,
            ),
            const Divider(height: 1),
            _DefinitionActionTile(
              icon: definition.archived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
              label: definition.archived ? 'Restore' : 'Archive',
              action: _DefinitionAction.archive,
            ),
            if (usage?.legacyValueCount case final count? when count > 0)
              const _DefinitionActionTile(
                icon: Icons.delete_sweep_outlined,
                label: 'Discard legacy values',
                action: _DefinitionAction.discardLegacy,
              ),
            _DefinitionActionTile(
              icon: Icons.delete_outline,
              label: usage?.canDelete == true
                  ? 'Delete'
                  : 'Delete (values in use)',
              action: _DefinitionAction.delete,
              enabled: usage?.canDelete ?? false,
            ),
          ],
        ),
      ),
    );
    if (action != null) _selectAction(action);
  }

  void _selectAction(_DefinitionAction action) {
    switch (action) {
      case _DefinitionAction.inspect:
        onInspect();
      case _DefinitionAction.edit:
        onEdit();
      case _DefinitionAction.up:
        onMove(-1);
      case _DefinitionAction.down:
        onMove(1);
      case _DefinitionAction.archive:
        onArchive();
      case _DefinitionAction.discardLegacy:
        onDiscardLegacy();
      case _DefinitionAction.delete:
        onDelete();
    }
  }
}

enum _DefinitionAction {
  inspect,
  edit,
  up,
  down,
  archive,
  discardLegacy,
  delete,
}

class _DefinitionActionTile extends StatelessWidget {
  const _DefinitionActionTile({
    required this.icon,
    required this.label,
    required this.action,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final _DefinitionAction action;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: enabled,
      leading: Icon(icon),
      title: Text(label),
      onTap: enabled ? () => Navigator.pop(context, action) : null,
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
