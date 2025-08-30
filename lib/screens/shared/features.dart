import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/utility_services.dart';

class SpecimenSearchChips extends StatelessWidget {
  const SpecimenSearchChips({
    super.key,
    required this.selectedValue,
    required this.onSelected,
  });

  final int selectedValue;
  final void Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: List.generate(SpecimenSearchOption.values.length, (index) {
        return CommonChip(
          index: index,
          label: Text(SpecimenSearchOption.values[index].name.toSentenceCase()),
          selectedValue: selectedValue,
          onSelected: (selected) {
            if (selected) {
              onSelected(index);
            }
          },
        );
      }),
    );
  }
}

class SiteIdField extends ConsumerWidget {
  const SiteIdField({
    super.key,
    required this.onChanges,
    required this.siteData,
    required this.value,
  });

  final void Function(int?) onChanges;
  final List<SiteData> siteData;
  final int? value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButtonFormField(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Site ID',
        hintText: 'Enter a site',
      ),
      items: siteData
          .map((site) => DropdownMenuItem(
                value: site.id,
                child: CommonDropdownText(text: site.siteID ?? ''),
              ))
          .toList(),
      onChanged: onChanges,
    );
  }
}
