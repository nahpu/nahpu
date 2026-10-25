import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_item.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/styles/themes.dart';

/// What a tapped filled cell holds, shown below the box grid: each tube's
/// label, its specimen details, and a button for all of its fields.
class TissueCellInspector extends StatelessWidget {
  const TissueCellInspector({
    super.key,
    required this.cellLabel,
    required this.items,
    required this.labelFor,
    required this.detailFor,
    required this.onDetails,
    required this.onClose,
  });

  final String cellLabel;
  final List<TissueItemRecord> items;
  final String Function(TissueItemRecord record) labelFor;

  /// Field ID, type or Parasite, and treatment.
  final String Function(TissueItemRecord record) detailFor;
  final ValueChanged<TissueItemRecord> onDetails;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isShared = items.length > 1;
    return DecoratedBox(
      key: const ValueKey('tissue-cell-inspector'),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(NahpuRadius.sm),
        border: Border.all(
          color: isShared
              ? NahpuTheme.warningText(theme.colorScheme)
              : theme.colorScheme.outlineVariant,
          width: NahpuStroke.thin,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          NahpuSpacing.lg,
          NahpuSpacing.sm,
          NahpuSpacing.xs,
          NahpuSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(cellLabel, style: theme.textTheme.titleSmall),
                if (isShared) ...[
                  const SizedBox(width: NahpuSpacing.md),
                  Expanded(
                    child: Text(
                      context.l10n.projectTissueSharedCell(items.length),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: NahpuTheme.warningText(theme.colorScheme),
                      ),
                    ),
                  ),
                ] else
                  const Spacer(),
                IconButton(
                  tooltip: context.l10n.commonClose,
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            for (final item in items)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(labelFor(item), style: theme.textTheme.bodyLarge),
                        Text(
                          detailFor(item),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => onDetails(item),
                    child: Text(context.l10n.projectTissueDetails),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Every curation field of one tube, with a way to its specimen record.
/// Shown with [showAdaptiveSheetDialog]: a bottom sheet on phones, a dialog
/// on wider screens.
class TissueItemDetails extends StatelessWidget {
  const TissueItemDetails({
    super.key,
    required this.record,
    required this.label,
    required this.fieldId,
    required this.isSheet,
    required this.onOpenRecord,
  });

  final TissueItemRecord record;
  final String label;
  final String fieldId;

  /// A bottom sheet closes with its drag handle, so it shows no close button.
  final bool isSheet;
  final VoidCallback onOpenRecord;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = <(String, String?)>[
      (
        record.isParasite
            ? l10n.projectBatchKeyParasiteId
            : l10n.recordsSpecimenTissueId,
        record.code,
      ),
      if (!record.isParasite) (l10n.projectTissueBarcode, record.barcode),
      (l10n.recordsSpecimenFieldId, fieldId),
      if (record.isParasite)
        (l10n.projectTissueParasiteCategory, record.category)
      else
        (l10n.projectTissueType, record.type),
      (l10n.projectTissuePreservation, record.treatment),
      (l10n.projectTissueCountLabel, record.count),
      (l10n.projectTissueStorageLocation, record.storageLocation),
      for (final field in TissueCheckField.values)
        (field.localizedLabel(l10n), record.readField(field)),
    ];
    return AdaptiveSheetDialogBody(
      key: const ValueKey('tissue-item-details'),
      title: label,
      description: record.isParasite ? l10n.projectTissueParasite : null,
      showCloseButton: !isSheet,
      actions: [
        FilledButton.icon(
          onPressed: onOpenRecord,
          icon: const Icon(Icons.open_in_new),
          label: Text(l10n.projectTissueOpenRecord),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (name, value) in rows)
            TissueDetailRow(name: name, value: value),
        ],
      ),
    );
  }
}

/// A field name and its value; empty values read as an em dash.
class TissueDetailRow extends StatelessWidget {
  const TissueDetailRow({super.key, required this.name, required this.value});

  final String name;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = value?.trim() ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: NahpuSpacing.md),
          Expanded(
            flex: 3,
            child: Text(
              text.isEmpty ? '—' : text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
