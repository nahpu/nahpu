import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/services/types/export.dart';

class RecordOptionsCard extends StatelessWidget {
  const RecordOptionsCard({
    super.key,
    required this.recordType,
    required this.taxonRecordType,
    required this.mammalRecordType,
    required this.isMammalSpecimenRecord,
    required this.onRecordTypeChanged,
    required this.onTaxonRecordTypeChanged,
    required this.onMammalRecordTypeChanged,
  });

  final RecordType? recordType;
  final TaxonRecordType? taxonRecordType;
  final MammalRecordType mammalRecordType;
  final bool isMammalSpecimenRecord;
  final void Function(RecordType?) onRecordTypeChanged;
  final void Function(TaxonRecordType?) onTaxonRecordTypeChanged;
  final void Function(MammalRecordType?) onMammalRecordTypeChanged;

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
            DropdownButtonFormField<RecordType>(
              initialValue: recordType,
              decoration: const InputDecoration(
                labelText: 'Record type',
              ),
              items: recordTypeList
                  .map((e) => DropdownMenuItem(
                        value: RecordType.values[recordTypeList.indexOf(e)],
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: onRecordTypeChanged,
            ),
            Visibility(
              visible: recordType == RecordType.specimenRecord,
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
          ],
        ),
      ),
    );
  }
}
