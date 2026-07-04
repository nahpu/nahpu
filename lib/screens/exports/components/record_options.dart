import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/services/types/export.dart';

class RecordOptionsCard extends StatelessWidget {
  const RecordOptionsCard({
    super.key,
    required this.recordType,
    required this.taxonRecordType,
    required this.mammalRecordType,
    required this.inaccurateInBrackets,
    required this.isMammalSpecimenRecord,
    required this.onRecordTypeChanged,
    required this.onTaxonRecordTypeChanged,
    required this.onMammalRecordTypeChanged,
    required this.onInaccurateInBracketsChanged,
  });

  final ExportRecordType? recordType;
  final TaxonRecordType? taxonRecordType;
  final MammalRecordType mammalRecordType;
  final bool inaccurateInBrackets;
  final bool isMammalSpecimenRecord;
  final void Function(ExportRecordType?) onRecordTypeChanged;
  final void Function(TaxonRecordType?) onTaxonRecordTypeChanged;
  final void Function(MammalRecordType?) onMammalRecordTypeChanged;
  final void Function(bool) onInaccurateInBracketsChanged;

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
              'Record Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExportRecordType>(
              initialValue: recordType,
              decoration: const InputDecoration(
                labelText: 'Record type',
              ),
              items: recordTypeList
                  .map((e) => DropdownMenuItem(
                        value:
                            ExportRecordType.values[recordTypeList.indexOf(e)],
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: onRecordTypeChanged,
            ),
            Visibility(
              visible: recordType == ExportRecordType.specimenRecord,
              child: DropdownButtonFormField<TaxonRecordType?>(
                initialValue: taxonRecordType,
                decoration: const InputDecoration(
                  labelText: 'Taxon group',
                ),
                items: taxonRecordTypeList
                    .map((e) => DropdownMenuItem(
                          value: TaxonRecordType
                              .values[taxonRecordTypeList.indexOf(e)],
                          child: CommonDropdownText(text: e),
                        ))
                    .toList(),
                onChanged: onTaxonRecordTypeChanged,
              ),
            ),
            Visibility(
              visible: isMammalSpecimenRecord,
              child: DropdownButtonFormField<MammalRecordType>(
                initialValue: mammalRecordType,
                decoration: const InputDecoration(
                  labelText: 'Mammal group',
                ),
                items: mammalGroupList
                    .map((e) => DropdownMenuItem(
                          value: MammalRecordType
                              .values[mammalGroupList.indexOf(e)],
                          child: CommonDropdownText(text: e),
                        ))
                    .toList(),
                onChanged: onMammalRecordTypeChanged,
              ),
            ),
            Visibility(
              visible: isMammalSpecimenRecord,
              child: SwitchField(
                value: inaccurateInBrackets,
                label: 'Inaccurate in brackets',
                onPressed: onInaccurateInBracketsChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
