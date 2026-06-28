import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/types/export.dart';

class FormatOptionsCard extends StatelessWidget {
  const FormatOptionsCard({
    super.key,
    required this.recordType,
    required this.specimenExportFmt,
    required this.concatenateMultiEntry,
    required this.useFieldNamesOnly,
    required this.onSpecimenExportFmtChanged,
    this.onSelectFields,
    required this.onConcatenateMultiEntryChanged,
    required this.onUseFieldNamesOnlyChanged,
    this.isPreset = false,
  });

  final ExportRecordType? recordType;
  final SpecimenExportFmt specimenExportFmt;
  final bool concatenateMultiEntry;
  final bool useFieldNamesOnly;
  final void Function(SpecimenExportFmt?) onSpecimenExportFmtChanged;
  final VoidCallback? onSelectFields;
  final void Function(bool) onConcatenateMultiEntryChanged;
  final void Function(bool) onUseFieldNamesOnlyChanged;
  final bool isPreset;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Format Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Visibility(
              visible:
                  recordType == ExportRecordType.specimenRecord && !isPreset,
              child: DropdownButtonFormField<SpecimenExportFmt>(
                initialValue: specimenExportFmt,
                decoration: const InputDecoration(
                  labelText: 'Format options',
                ),
                items: specimenExportFmtList
                    .map((e) => DropdownMenuItem(
                          value: SpecimenExportFmt
                              .values[specimenExportFmtList.indexOf(e)],
                          child: CommonDropdownText(text: e),
                        ))
                    .toList(),
                onChanged: onSpecimenExportFmtChanged,
              ),
            ),
            if (onSelectFields != null &&
                specimenExportFmt == SpecimenExportFmt.selectFields)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: TextButton(
                    onPressed: onSelectFields,
                    child: const Text('Select fields'),
                  ),
                ),
              ),
            Visibility(
              visible: recordType == ExportRecordType.specimenRecord,
              child: SwitchField(
                value: concatenateMultiEntry,
                label: 'Concatenate multi-entry records',
                onPressed: onConcatenateMultiEntryChanged,
              ),
            ),
            Visibility(
              visible: !isPreset,
              child: SwitchField(
                value: useFieldNamesOnly,
                label: 'Field names only for headers',
                onPressed: onUseFieldNamesOnlyChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
