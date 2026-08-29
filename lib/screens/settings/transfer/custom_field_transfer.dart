import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/settings/user_config_transfer_service.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/nahpu_icons.dart';

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
  final selectedIds = definitions.map((definition) => definition.id!).toSet();
  return showDialog<CustomFieldExportChoice>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Export custom fields'),
        content: SizedBox(
          width: 520,
          child: definitions.isEmpty
              ? const Text('No custom fields are available to export.')
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Select reusable definitions'),
                          ),
                          TextButton(
                            onPressed: () => setState(
                              () => selectedIds
                                ..clear()
                                ..addAll(
                                  definitions.map(
                                    (definition) => definition.id!,
                                  ),
                                ),
                            ),
                            child: const Text('Select all'),
                          ),
                          TextButton(
                            onPressed: selectedIds.isEmpty
                                ? null
                                : () => setState(selectedIds.clear),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      for (final definition in definitions)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          secondary: Icon(_placementIcon(definition.placement)),
                          title: Text(definition.name),
                          subtitle: Text(
                            '${definition.placement.label} · '
                            '${definition.fieldScope == FieldScope.global ? 'Global' : 'Current project'}'
                            '${definition.archived ? ' · Archived' : ''}',
                          ),
                          value: selectedIds.contains(definition.id),
                          onChanged: (selected) => setState(() {
                            if (selected ?? false) {
                              selectedIds.add(definition.id!);
                            } else {
                              selectedIds.remove(definition.id);
                            }
                          }),
                        ),
                    ],
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          OutlinedButton.icon(
            onPressed: selectedIds.isEmpty
                ? null
                : () => Navigator.pop(
                    dialogContext,
                    CustomFieldExportChoice(
                      ids: Set.of(selectedIds),
                      method: CustomFieldExportMethod.qr,
                    ),
                  ),
            icon: const Icon(Icons.qr_code_2_outlined),
            label: const Text('Show QR'),
          ),
          FilledButton.icon(
            onPressed: selectedIds.isEmpty
                ? null
                : () => Navigator.pop(
                    dialogContext,
                    CustomFieldExportChoice(
                      ids: Set.of(selectedIds),
                      method: CustomFieldExportMethod.file,
                    ),
                  ),
            icon: const Icon(Icons.file_upload_outlined),
            label: const Text('Export file'),
          ),
        ],
      ),
    ),
  );
}

Future<UserConfigImportDestination?> showCustomFieldImportPreview({
  required BuildContext context,
  required UserConfigImportSource source,
  required bool projectAvailable,
}) {
  var destination = projectAvailable
      ? UserConfigImportDestination.currentProject
      : UserConfigImportDestination.global;
  return showDialog<UserConfigImportDestination>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Import custom fields'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${source.preview.customFields.length} reusable '
                  '${source.preview.customFields.length == 1 ? 'definition' : 'definitions'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                for (final template in source.preview.customFields)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.dynamic_form_outlined),
                    title: Text(template.label),
                    subtitle: Text(
                      '${template.placement} · ${template.fieldType}'
                      '${template.catalogFormat == null ? '' : ' · ${template.catalogFormat}'}',
                    ),
                  ),
                const Divider(),
                DropdownButtonFormField<UserConfigImportDestination>(
                  initialValue: destination,
                  decoration: const InputDecoration(labelText: 'Destination'),
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
                  onChanged: (value) {
                    if (value != null) setState(() => destination = value);
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Definitions are preflighted before import. Matching '
                  'template IDs are updated safely; unrelated fields remain '
                  'unchanged.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, destination),
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Import'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showCustomFieldQrDialog({
  required BuildContext context,
  required String payload,
  required int definitionCount,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Custom fields QR code'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: payload,
              size: 280,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              'Scan this code from another NAHPU device to import '
              '$definitionCount custom field '
              '${definitionCount == 1 ? 'definition' : 'definitions'}.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

IconData _placementIcon(FieldUISection placement) => switch (placement) {
  FieldUISection.siteAttribute => Icons.place_outlined,
  FieldUISection.environmentalData => Icons.eco_outlined,
  FieldUISection.specimenAttribute => Icons.sell_outlined,
  FieldUISection.specimenPart => NahpuIcons.vialOutlined,
  FieldUISection.parasite => Icons.bug_report_outlined,
};
