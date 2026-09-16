import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/settings/transfer/custom_field_transfer.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
import 'package:nahpu/screens/shared/actions/preset_actions.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/screens/shared/forms/custom_field_definition_editor.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/master_detail.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/custom_fields/custom_field_order.dart';
import 'package:nahpu/services/export/export_destination.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/settings/user_config_transfer_service.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;
import 'package:nahpu/styles/design_tokens.dart';

/// Custom field definitions managed like presets: pick a location with the
/// chips, pick a field from its list, and edit it in the form beside the list.
class CustomFieldsSettings extends ConsumerStatefulWidget {
  const CustomFieldsSettings({
    super.key,
    required this.projectUuid,
    required this.currentCatalog,
    this.initialPlacement,
  });

  final String? projectUuid;
  final CatalogFmt currentCatalog;

  /// The location selected when the screen opens. Defaults to the first
  /// location that has active fields.
  final FieldUISection? initialPlacement;

  @override
  ConsumerState<CustomFieldsSettings> createState() =>
      _CustomFieldsSettingsState();
}

class _CustomFieldsSettingsState extends ConsumerState<CustomFieldsSettings>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );
  final ExportDestinationService _destination = ExportDestinationService();
  late FieldUISection? _placement = widget.initialPlacement;
  int? _selectedId;
  bool _isCreating = false;

  /// Bumped to rebuild the form, which restores its saved values.
  int _formRevision = 0;
  bool _showArchived = false;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= NahpuBreakpoints.compact;
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
            onExportAll: _export,
          ),
        ],
      ),
      body: SafeArea(
        child: definitions.when(
          data: (definitions) {
            final placement = _placement ?? _defaultPlacement(definitions);
            final inPlacement = [
              for (final definition in definitions)
                if (definition.placement == placement) definition,
            ];
            final visible = _visibleDefinitions(
              inPlacement,
              showArchived: _showArchived,
            );
            final selected = inPlacement
                .where((definition) => definition.id == _selectedId)
                .firstOrNull;
            final list = _FieldListColumn(
              placement: placement,
              definitions: visible,
              hasArchived: inPlacement.any((definition) => definition.archived),
              showArchived: _showArchived,
              selectedId: selected?.id,
              onShowArchivedChanged: (value) =>
                  setState(() => _showArchived = value),
              onCreate: _create,
              onSelected: _select,
              onAction: (definition, action) =>
                  _handleAction(definitions, visible, definition, action),
            );
            final editor = _FieldEditColumn(
              placement: placement,
              definition: _isCreating ? null : selected,
              isCreating: _isCreating,
              formRevision: _formRevision,
              creationContext: CustomFieldCreationContext(
                projectUuid: selected?.projectUuid ?? widget.projectUuid ?? '',
                catalogFormat: selected != null || placement.isSpecimenRelated
                    ? widget.currentCatalog
                    : null,
              ),
              onSaved: _saved,
              onCancel: _cancelEdit,
            );
            return Column(
              children: [
                _LocationChips(
                  selected: placement,
                  counts: {
                    for (final value in FieldUISection.values)
                      value: definitions
                          .where(
                            (definition) =>
                                definition.placement == value &&
                                !definition.archived,
                          )
                          .length,
                  },
                  onSelected: _selectPlacement,
                ),
                if (isWide)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        NahpuSpacing.md,
                        0,
                        NahpuSpacing.md,
                        NahpuSpacing.xl,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: list),
                          const SizedBox(width: NahpuSpacing.lg),
                          Expanded(child: editor),
                        ],
                      ),
                    ),
                  )
                else ...[
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Fields'),
                      Tab(text: 'Edit field'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [list, editor],
                    ),
                  ),
                ],
              ],
            );
          },
          loading: () => const CommonProgressIndicator(),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(NahpuSpacing.xl),
              child: Text('Unable to load fields: $error'),
            ),
          ),
        ),
      ),
    );
  }

  void _selectPlacement(FieldUISection placement) {
    setState(() {
      _placement = placement;
      _selectedId = null;
      _isCreating = false;
    });
    _tabController.animateTo(0);
  }

  void _select(CustomFieldDefinitionData definition) {
    setState(() {
      _selectedId = definition.id;
      _isCreating = false;
    });
    _tabController.animateTo(1);
  }

  Future<void> _create() async {
    final placement =
        _placement ??
        _defaultPlacement(
          await ref.read(
            manageableCustomFieldsProvider(widget.projectUuid).future,
          ),
        );
    if (!mounted) return;
    setState(() {
      _placement = placement;
      _selectedId = null;
      _isCreating = true;
      _formRevision++;
    });
    _tabController.animateTo(1);
  }

  void _saved(CustomFieldDefinitionData saved) {
    setState(() {
      _placement = saved.placement;
      _selectedId = saved.id;
      _isCreating = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Saved “${saved.name}”.')));
  }

  void _cancelEdit() {
    if (!_isCreating) {
      setState(() => _formRevision++);
      return;
    }
    setState(() => _isCreating = false);
    _tabController.animateTo(0);
  }

  void _handleAction(
    List<CustomFieldDefinitionData> all,
    List<CustomFieldDefinitionData> visible,
    CustomFieldDefinitionData definition,
    _DefinitionAction action,
  ) {
    switch (action) {
      case _DefinitionAction.up:
        _move(all, visible, definition, -1);
      case _DefinitionAction.down:
        _move(all, visible, definition, 1);
      case _DefinitionAction.archive:
        _archive(definition);
      case _DefinitionAction.discardLegacy:
        _discardLegacy(definition);
      case _DefinitionAction.delete:
        _delete(definition);
    }
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

  /// Exports the selected definitions, asking for a folder only where one can
  /// be honoured.
  ///
  /// This screen has no result card to hang Share off, so it performs the
  /// platform's own follow-up action itself: on iOS the file is temporary and
  /// only reaches the user through Share, and on Android an app-private path
  /// is not worth printing in a snackbar.
  Future<void> _exportFile(Set<int> definitionIds) async {
    Directory? picked;
    if (_destination.canChooseDirectory) {
      picked = await FilePickerServices().selectDir();
      // An explicit cancel still means "not now".
      if (picked == null) return;
    }
    final output = await AppIOServices(
      dir: await _destination.resolve(picked),
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
    await _deliverExport(output, picked);
  }

  Future<void> _deliverExport(File output, Directory? picked) async {
    switch (_destination.mode) {
      case ExportDestinationMode.temporary:
        await FilePickerServices().shareFile(context, output);
      case ExportDestinationMode.chooseDirectory:
        if (platformSavedFileAction == SavedFileAction.saveCopy) {
          await FilePickerServices().saveCopyToDevice(output);
          return;
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              picked != null
                  ? 'Custom fields exported to ${output.path}'
                  : 'Custom fields exported',
            ),
          ),
        );
    }
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
      final exportFile = await showAdaptiveConfirmation(
        context: context,
        title: 'QR code is too large',
        message:
            'The selected custom fields contain too much data for one QR '
            'code. Export them as a file instead.',
        confirmLabel: 'Export file',
        confirmIcon: Icons.file_upload_outlined,
      );
      if (exportFile) await _exportFile(definitionIds);
      return;
    }
    await showCustomFieldQrDialog(
      context: context,
      payload: payload,
      definitionCount: definitionIds.length,
    );
  }

  Future<void> _move(
    List<CustomFieldDefinitionData> all,
    List<CustomFieldDefinitionData> visible,
    CustomFieldDefinitionData definition,
    int offset,
  ) async {
    final ids = CustomFieldOrder.movedDefinitionIds(
      all: all,
      visible: visible,
      definition: definition,
      offset: offset,
    );
    if (ids == null) return;
    await _run(() => ref.read(customFieldServiceProvider).reorder(ids));
  }

  Future<void> _archive(CustomFieldDefinitionData definition) async {
    await _run(
      () => ref
          .read(customFieldServiceProvider)
          .setArchived(definition.id!, !definition.archived),
    );
  }

  Future<void> _discardLegacy(CustomFieldDefinitionData definition) async {
    final confirmed = await showAdaptiveConfirmation(
      context: context,
      title: 'Discard legacy values?',
      message:
          'Legacy values for “${definition.name}” cannot be recovered after '
          'they are discarded.',
      confirmLabel: 'Discard values',
      isDestructive: true,
    );
    if (!confirmed) return;
    await _run(
      () => ref
          .read(customFieldServiceProvider)
          .discardLegacyValues(definition.id!),
    );
  }

  Future<void> _delete(CustomFieldDefinitionData definition) async {
    final confirmed = await showAdaptiveConfirmation(
      context: context,
      title: 'Delete custom field?',
      message:
          'Delete “${definition.name}” permanently? This action cannot be '
          'undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;
    final deleted = await _run(
      () =>
          ref.read(customFieldServiceProvider).deleteDefinition(definition.id!),
    );
    if (!deleted || !mounted || _selectedId != definition.id) return;
    setState(() => _selectedId = null);
    _tabController.animateTo(0);
  }

  /// Runs [action] and refreshes the definitions. Returns false and reports
  /// the error when it fails.
  Future<bool> _run(Future<Object?> Function() action) async {
    try {
      await action();
      _refresh();
      return true;
    } catch (error) {
      if (mounted) _showError(error.toString());
      return false;
    }
  }

  void _refresh() {
    invalidateCustomFieldDefinitionProviders(ref);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Radio-button chips that choose which location's fields are listed.
class _LocationChips extends StatelessWidget {
  const _LocationChips({
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final FieldUISection selected;

  /// Active fields in each location.
  final Map<FieldUISection, int> counts;
  final ValueChanged<FieldUISection> onSelected;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(
      horizontal: NahpuSpacing.lg,
      vertical: NahpuSpacing.md,
    );
    final chips = [
      for (final placement in FieldUISection.values)
        _LocationChip(
          placement: placement,
          count: counts[placement] ?? 0,
          isSelected: placement == selected,
          onSelected: onSelected,
        ),
    ];
    // Wide screens wrap, so every location stays in view.
    if (MediaQuery.sizeOf(context).width >= NahpuBreakpoints.compact) {
      return Padding(
        padding: padding,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: NahpuSpacing.md,
          runSpacing: NahpuSpacing.md,
          children: chips,
        ),
      );
    }
    // Phones keep the chips on one scrolling line, leaving room for the list.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(spacing: NahpuSpacing.md, children: chips),
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({
    required this.placement,
    required this.count,
    required this.isSelected,
    required this.onSelected,
  });

  final FieldUISection placement;
  final int count;
  final bool isSelected;
  final ValueChanged<FieldUISection> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = isSelected
        ? colors.onSecondaryContainer
        : colors.onSurfaceVariant;
    return ChoiceChip(
      selected: isSelected,
      showCheckmark: false,
      avatar: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        size: NahpuControlSize.iconMedium,
        color: foreground,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: NahpuSpacing.sm,
        children: [
          Text(placement.label),
          if (count > 0)
            Badge.count(
              count: count,
              backgroundColor: isSelected ? colors.secondary : colors.outline,
              textColor: isSelected ? colors.onSecondary : colors.surface,
            ),
        ],
      ),
      labelStyle: theme.textTheme.labelLarge?.copyWith(color: foreground),
      backgroundColor: colors.surfaceContainerHighest,
      selectedColor: colors.secondaryContainer,
      side: BorderSide(
        color: isSelected ? colors.secondary : colors.outlineVariant,
        width: NahpuStroke.thin,
      ),
      onSelected: (_) => onSelected(placement),
    );
  }
}

/// The fields in the selected location, chosen with a radio button like a
/// preset list.
class _FieldListColumn extends StatelessWidget {
  const _FieldListColumn({
    required this.placement,
    required this.definitions,
    required this.hasArchived,
    required this.showArchived,
    required this.selectedId,
    required this.onShowArchivedChanged,
    required this.onCreate,
    required this.onSelected,
    required this.onAction,
  });

  final FieldUISection placement;

  /// The definitions to list, already filtered to the location.
  final List<CustomFieldDefinitionData> definitions;
  final bool hasArchived;
  final bool showArchived;
  final int? selectedId;
  final ValueChanged<bool> onShowArchivedChanged;
  final VoidCallback onCreate;
  final ValueChanged<CustomFieldDefinitionData> onSelected;
  final void Function(
    CustomFieldDefinitionData definition,
    _DefinitionAction action,
  )
  onAction;

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Select fields',
      isWithSidePadding: false,
      isExpanded: true,
      child: Column(
        children: [
          // Offered only when this location has something archived to show.
          if (hasArchived)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.md),
              child: SwitchSettings(
                label: 'Show archived fields',
                value: showArchived,
                onChanged: onShowArchivedChanged,
              ),
            ),
          Expanded(
            child: definitions.isEmpty
                ? PresetEmptyState(
                    message: hasArchived
                        ? 'All custom fields in ${placement.label} are '
                              'archived.'
                        : 'No custom fields in ${placement.label} yet.',
                    secondaryLabel: 'Add custom field',
                    secondaryIcon: Icons.add_circle_outline_rounded,
                    onSecondary: onCreate,
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: definitions.length,
                    itemBuilder: (context, index) {
                      final definition = definitions[index];
                      return _DefinitionTile(
                        key: ValueKey(definition.id),
                        definition: definition,
                        isSelected: definition.id == selectedId,
                        moves: CustomFieldOrder.moves(definitions, definition),
                        onTap: () => onSelected(definition),
                        onAction: (action) => onAction(definition, action),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DefinitionTile extends ConsumerWidget {
  const _DefinitionTile({
    super.key,
    required this.definition,
    required this.isSelected,
    required this.moves,
    required this.onTap,
    required this.onAction,
  });

  final CustomFieldDefinitionData definition;
  final bool isSelected;

  /// Null when the definition is alone in its group and cannot move.
  final CustomFieldMoves? moves;
  final VoidCallback onTap;
  final ValueChanged<_DefinitionAction> onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final usage = ref.watch(customFieldUsageProvider(definition.id!));
    final currentUsage = usage.when(
      data: (value) => value,
      error: (_, _) => null,
      loading: () => null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NahpuSpacing.md,
        vertical: NahpuSpacing.xs,
      ),
      child: Material(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NahpuRadius.lg),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  definition.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (definition.archived) ...[
                const SizedBox(width: NahpuSpacing.md),
                const BetaBadge(label: 'Archived'),
              ],
            ],
          ),
          subtitle: Text(
            '${_fieldTypeLabel(definition.fieldType)} · '
            '${_scopeLabel(definition.fieldScope)} · '
            '${_catalogLabel(definition)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: AdaptiveMenuButton<_DefinitionAction>(
            tooltip: 'Definition actions',
            itemBuilder: () => _items(currentUsage),
            onSelected: onAction,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  List<AdaptiveMenuItem<_DefinitionAction>> _items(CustomFieldUsage? usage) {
    final moves = this.moves;
    return [
      if (moves != null) ...[
        AdaptiveMenuItem(
          value: _DefinitionAction.up,
          icon: Icons.arrow_upward,
          label: 'Move up',
          enabled: moves.canMoveUp,
        ),
        AdaptiveMenuItem(
          value: _DefinitionAction.down,
          icon: Icons.arrow_downward,
          label: 'Move down',
          enabled: moves.canMoveDown,
        ),
      ],
      AdaptiveMenuItem(
        value: _DefinitionAction.archive,
        icon: definition.archived
            ? Icons.unarchive_outlined
            : Icons.archive_outlined,
        label: definition.archived ? 'Restore' : 'Archive',
        hasDividerBefore: true,
      ),
      if (usage?.legacyValueCount case final count? when count > 0)
        const AdaptiveMenuItem(
          value: _DefinitionAction.discardLegacy,
          icon: Icons.delete_sweep_outlined,
          label: 'Discard legacy values',
          isDestructive: true,
        ),
      AdaptiveMenuItem(
        value: _DefinitionAction.delete,
        icon: Icons.delete_outline,
        label: usage?.canDelete == true ? 'Delete' : 'Delete (values in use)',
        enabled: usage?.canDelete ?? false,
        isDestructive: true,
      ),
    ];
  }
}

enum _DefinitionAction { up, down, archive, discardLegacy, delete }

/// The form for the selected field, or for a new one in the selected
/// location, with the field's read-only details below it.
class _FieldEditColumn extends StatelessWidget {
  const _FieldEditColumn({
    required this.placement,
    required this.definition,
    required this.isCreating,
    required this.formRevision,
    required this.creationContext,
    required this.onSaved,
    required this.onCancel,
  });

  final FieldUISection placement;
  final CustomFieldDefinitionData? definition;
  final bool isCreating;
  final int formRevision;
  final CustomFieldCreationContext creationContext;
  final ValueChanged<CustomFieldDefinitionData> onSaved;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final definition = this.definition;
    if (!isCreating && definition == null) {
      return const FormCard(
        title: 'Edit field',
        isExpanded: true,
        child: EmptyDetailsPrompt(
          message: 'Select a custom field to edit, or add a new one.',
        ),
      );
    }
    final formPlacement = definition?.placement ?? placement;
    return FormCard(
      title: definition == null
          ? 'New custom field'
          : 'Edit ${definition.name}',
      isExpanded: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(NahpuSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Shown in ${formPlacement.label}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: NahpuSpacing.lg),
            CustomFieldDefinitionForm(
              key: ValueKey(
                '${definition?.id ?? 'new-${formPlacement.name}'}'
                '-$formRevision',
              ),
              isInline: true,
              placement: formPlacement,
              creationContext: creationContext,
              definition: definition,
              onSaved: onSaved,
              onCancel: onCancel,
            ),
            if (definition != null) ...[
              const SizedBox(height: NahpuSpacing.xxl),
              _DefinitionDetails(definition: definition),
            ],
          ],
        ),
      ),
    );
  }
}

class _DefinitionDetails extends ConsumerWidget {
  const _DefinitionDetails({required this.definition});

  final CustomFieldDefinitionData definition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(customFieldUsageProvider(definition.id!));
    return NahpuPanel(
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Details', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: NahpuSpacing.xs),
          _DetailRow(
            label: 'Status',
            value: definition.archived ? 'Archived' : 'Active',
          ),
          _DetailRow(label: 'Scope', value: _scopeLabel(definition.fieldScope)),
          usage.when(
            data: (value) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
          if (definition.projectUuid != null)
            _DetailRow(label: 'Project UUID', value: definition.projectUuid!),
          _DetailRow(label: 'Definition UUID', value: definition.uuid),
          _DetailRow(
            label: 'Source template UUID',
            value:
                definition.sourceTemplateUuid ?? 'Not imported from a template',
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: NahpuSpacing.xxs),
          SelectableText(value),
        ],
      ),
    );
  }
}

/// The first location with active fields, so the screen opens on something.
FieldUISection _defaultPlacement(List<CustomFieldDefinitionData> definitions) {
  for (final placement in FieldUISection.values) {
    if (definitions.any(
      (definition) => definition.placement == placement && !definition.archived,
    )) {
      return placement;
    }
  }
  return definitions.firstOrNull?.placement ?? FieldUISection.values.first;
}

List<CustomFieldDefinitionData> _visibleDefinitions(
  List<CustomFieldDefinitionData> definitions, {
  required bool showArchived,
}) {
  return definitions
      .where((definition) => showArchived || !definition.archived)
      .toList(growable: false);
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
      : '${catalogFmtDisplayName(catalog)} only';
}
