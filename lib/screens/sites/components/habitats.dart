import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/providers/sites.dart';

class Habitat extends ConsumerWidget {
  const Habitat(
      {super.key,
      required this.id,
      required this.useHorizontalLayout,
      required this.siteFormCtr});

  final int id;
  final bool useHorizontalLayout;
  final SiteFormCtrModel siteFormCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormCard(
      title: 'Habitat',
      infoContent: const HabitatInfoContent(),
      mainAxisAlignment: MainAxisAlignment.start,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            ref.watch(habitatTypeProvider).when(
                  data: (data) {
                    return DropdownButtonFormField<String?>(
                      initialValue: siteFormCtr.habitatTypeCtr.text.isEmpty
                          ? null
                          : siteFormCtr.habitatTypeCtr.text,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        hintText: 'Select a habitat type',
                      ),
                      items: data
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: CommonDropdownText(text: e),
                            ),
                          )
                          .toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          siteFormCtr.habitatTypeCtr.text = newValue;
                          SiteServices(ref: ref).updateSite(
                            id,
                            SiteCompanion(habitatType: db.Value(newValue)),
                          );
                        }
                      },
                    );
                  },
                  loading: () => const CommonProgressIndicator(),
                  error: (e, __) => Text(e.toString()),
                ),
            TextFormField(
              controller: siteFormCtr.habitatConditionCtr,
              decoration: const InputDecoration(
                labelText: 'Condition',
                hintText: 'E.g. "Pristine", "Disturbed", "etc."',
              ),
              onChanged: (value) => SiteServices(ref: ref).updateSite(
                id,
                SiteCompanion(habitatCondition: db.Value(value)),
              ),
            ),
            TextFormField(
              maxLines: 6,
              controller: siteFormCtr.habitatDescriptionCtr,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText:
                    'Describe the site, e.g. "A camp site in the middle of the forest."',
              ),
              onChanged: (value) => SiteServices(ref: ref).updateSite(
                id,
                SiteCompanion(habitatDescription: db.Value(value)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HabitatInfoContent extends StatelessWidget {
  const HabitatInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
            content: 'Information about the habitat of the site.'
                ' Note important information about the habitat in the description.'
                ' For example, the dominant tree species, ground cover, etc.'),
      ],
    );
  }
}
