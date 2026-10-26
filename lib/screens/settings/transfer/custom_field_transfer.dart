import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/screens/shared/dialogs/qr_code_dialog.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
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
  final l10n = context.l10n;
  final title = l10n.transferCustomFieldsQrTitle;
  final description = l10n.transferCustomFieldsQrDescription(definitionCount);
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
    final l10n = context.l10n;
    return AdaptiveSheetDialogBody(
      title: l10n.transferExportCustomFields,
      showCloseButton: widget.showCloseButton,
      actions: [
        if (definitions.isNotEmpty) ...[
          OutlinedButton.icon(
            onPressed: hasSelection
                ? () => _choose(CustomFieldExportMethod.qr)
                : null,
            icon: const Icon(Icons.qr_code_2_outlined),
            label: Text(l10n.transferShowQr),
          ),
          FilledButton.icon(
            onPressed: hasSelection
                ? () => _choose(CustomFieldExportMethod.file)
                : null,
            icon: const Icon(Icons.file_upload_outlined),
            label: Text(l10n.transferExportFile),
          ),
        ],
      ],
      child: definitions.isEmpty
          ? Text(l10n.transferNoCustomFields)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.transferSelectedCount(
                          _selectedIds.length,
                          definitions.length,
                        ),
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
                      child: Text(l10n.commonSelectAll),
                    ),
                    TextButton(
                      onPressed: hasSelection
                          ? () => setState(_selectedIds.clear)
                          : null,
                      child: Text(l10n.commonClear),
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
                      [
                        definition.placement.localizedLabel(l10n),
                        definition.fieldScope == FieldScope.global
                            ? l10n.transferScopeGlobal
                            : l10n.transferScopeCurrentProject,
                        if (definition.archived) l10n.transferArchived,
                      ].join(' · '),
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
    final l10n = context.l10n;
    return AdaptiveSheetDialogBody(
      title: l10n.transferImportCustomFields,
      description: l10n.transferReusableDefinitions(templates.length),
      showCloseButton: widget.showCloseButton,
      actions: [
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, _destination),
          icon: const Icon(Icons.file_download_outlined),
          label: Text(l10n.commonImport),
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
            decoration: InputDecoration(labelText: l10n.transferDestination),
            items: [
              DropdownMenuItem(
                value: UserConfigImportDestination.global,
                child: CommonDropdownText(text: l10n.transferScopeGlobal),
              ),
              if (widget.projectAvailable)
                DropdownMenuItem(
                  value: UserConfigImportDestination.currentProject,
                  child: CommonDropdownText(
                    text: l10n.transferScopeCurrentProject,
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _destination = value);
            },
          ),
          const SizedBox(height: NahpuSpacing.lg),
          Text(
            l10n.transferCustomFieldImportNote,
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
