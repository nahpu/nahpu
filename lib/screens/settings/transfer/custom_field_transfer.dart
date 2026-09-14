import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/screens/shared/dialogs/qr_code_dialog.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/settings/user_config_transfer_service.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/nahpu_icons.dart';
import 'package:nahpu/styles/design_tokens.dart';

enum CustomFieldExportMethod { file, qr }

class CustomFieldExportChoice {
  const CustomFieldExportChoice({required this.ids, required this.method});

  final Set<int> ids;
  final CustomFieldExportMethod method;
}

Future<CustomFieldExportChoice?> showCustomFieldExportSelection({
  required BuildContext context,
  required List<CustomFieldDefinitionData> definitions,
}) {
  return showAdaptiveSheetDialog<CustomFieldExportChoice>(
    context: context,
    builder: (_, isSheet) => _CustomFieldExportSelection(
      definitions: definitions,
      showCloseButton: !isSheet,
    ),
  );
}

Future<UserConfigImportDestination?> showCustomFieldImportPreview({
  required BuildContext context,
  required UserConfigImportSource source,
  required bool projectAvailable,
}) {
  return showAdaptiveSheetDialog<UserConfigImportDestination>(
    context: context,
    builder: (_, isSheet) => _CustomFieldImportPreview(
      source: source,
      projectAvailable: projectAvailable,
      showCloseButton: !isSheet,
    ),
  );
}

Future<void> showCustomFieldQrDialog({
  required BuildContext context,
  required String payload,
  required int definitionCount,
}) {
  const title = 'Custom fields QR code';
  final description =
      'Scan this code from another NAHPU device to import '
      '$definitionCount custom field '
      '${definitionCount == 1 ? 'definition' : 'definitions'}.';
  if (MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => QrCodeDialog(
        title: title,
        data: payload,
        description: description,
        showAsSheet: true,
      ),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (_) =>
        QrCodeDialog(title: title, data: payload, description: description),
  );
}

class _CustomFieldExportSelection extends StatefulWidget {
  const _CustomFieldExportSelection({
    required this.definitions,
    required this.showCloseButton,
  });

  final List<CustomFieldDefinitionData> definitions;
  final bool showCloseButton;

  @override
  State<_CustomFieldExportSelection> createState() =>
      _CustomFieldExportSelectionState();
}

class _CustomFieldExportSelectionState
    extends State<_CustomFieldExportSelection> {
  late final Set<int> _selectedIds = _allIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final definitions = widget.definitions;
    final hasSelection = _selectedIds.isNotEmpty;
    return AdaptiveSheetDialogBody(
      title: 'Export custom fields',
      showCloseButton: widget.showCloseButton,
      actions: [
        if (definitions.isNotEmpty) ...[
          OutlinedButton.icon(
            onPressed: hasSelection
                ? () => _choose(CustomFieldExportMethod.qr)
                : null,
            icon: const Icon(Icons.qr_code_2_outlined),
            label: const Text('Show QR'),
          ),
          FilledButton.icon(
            onPressed: hasSelection
                ? () => _choose(CustomFieldExportMethod.file)
                : null,
            icon: const Icon(Icons.file_upload_outlined),
            label: const Text('Export file'),
          ),
        ],
      ],
      child: definitions.isEmpty
          ? const Text('No custom fields are available to export.')
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectedIds.length} of ${definitions.length} '
                        'selected',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _selectedIds.length == definitions.length
                          ? null
                          : () => setState(() => _selectedIds.addAll(_allIds)),
                      child: const Text('Select all'),
                    ),
                    TextButton(
                      onPressed: hasSelection
                          ? () => setState(_selectedIds.clear)
                          : null,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                for (final definition in definitions)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(_placementIcon(definition.placement)),
                    title: Text(
                      definition.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${definition.placement.label} · '
                      '${definition.fieldScope == FieldScope.global ? 'Global' : 'Current project'}'
                      '${definition.archived ? ' · Archived' : ''}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    value: _selectedIds.contains(definition.id),
                    onChanged: (selected) => setState(() {
                      if (selected ?? false) {
                        _selectedIds.add(definition.id!);
                      } else {
                        _selectedIds.remove(definition.id);
                      }
                    }),
                  ),
              ],
            ),
    );
  }

  Set<int> get _allIds => {
    for (final definition in widget.definitions) definition.id!,
  };

  void _choose(CustomFieldExportMethod method) {
    Navigator.pop(
      context,
      CustomFieldExportChoice(ids: Set.of(_selectedIds), method: method),
    );
  }
}

class _CustomFieldImportPreview extends StatefulWidget {
  const _CustomFieldImportPreview({
    required this.source,
    required this.projectAvailable,
    required this.showCloseButton,
  });

  final UserConfigImportSource source;
  final bool projectAvailable;
  final bool showCloseButton;

  @override
  State<_CustomFieldImportPreview> createState() =>
      _CustomFieldImportPreviewState();
}

class _CustomFieldImportPreviewState extends State<_CustomFieldImportPreview> {
  late UserConfigImportDestination _destination = widget.projectAvailable
      ? UserConfigImportDestination.currentProject
      : UserConfigImportDestination.global;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templates = widget.source.preview.customFields;
    return AdaptiveSheetDialogBody(
      title: 'Import custom fields',
      description:
          '${templates.length} reusable '
          '${templates.length == 1 ? 'definition' : 'definitions'}',
      showCloseButton: widget.showCloseButton,
      actions: [
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, _destination),
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Import'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final template in templates)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.dynamic_form_outlined),
              title: Text(
                template.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${template.placement} · ${template.fieldType}'
                '${template.catalogFormat == null ? '' : ' · ${template.catalogFormat}'}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Divider(),
          const SizedBox(height: NahpuSpacing.md),
          DropdownButtonFormField<UserConfigImportDestination>(
            isExpanded: true,
            initialValue: _destination,
            decoration: const InputDecoration(labelText: 'Destination'),
            items: [
              const DropdownMenuItem(
                value: UserConfigImportDestination.global,
                child: CommonDropdownText(text: 'Global'),
              ),
              if (widget.projectAvailable)
                const DropdownMenuItem(
                  value: UserConfigImportDestination.currentProject,
                  child: CommonDropdownText(text: 'Current project'),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _destination = value);
            },
          ),
          const SizedBox(height: NahpuSpacing.lg),
          Text(
            'Definitions are preflighted before import. Matching template IDs '
            'are updated safely; unrelated fields remain unchanged.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _placementIcon(FieldUISection placement) => switch (placement) {
  FieldUISection.siteAttribute => Icons.place_outlined,
  FieldUISection.environmentalData => Icons.eco_outlined,
  FieldUISection.specimenAttribute => Icons.sell_outlined,
  FieldUISection.specimenPart => NahpuIcons.vialOutlined,
  FieldUISection.parasite => Icons.bug_report_outlined,
};
