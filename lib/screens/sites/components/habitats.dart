import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/services/types/custom_field.dart';

class Habitat extends ConsumerWidget {
  const Habitat({
    super.key,
    required this.id,
    required this.useHorizontalLayout,
    required this.siteFormCtr,
  });

  final int id;
  final bool useHorizontalLayout;
  final SiteFormCtrModel siteFormCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormCard(
      title: 'Site Attributes',
      infoTopic: InfoTopic.siteHabitat,
      mainAxisAlignment: MainAxisAlignment.start,
      child: SizedBox(
        height: 484,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                ref
                    .watch(
                      effectiveUserDefinedFieldProvider(habitatTypePrefKey),
                    )
                    .when(
                      data: (data) {
                        final current = siteFormCtr.habitatTypeCtr.text;
                        final options = includeCurrentVocabularyValue(
                          data,
                          current.isEmpty ? null : current,
                        );
                        final items = options
                            .map(
                              (e) => DropdownMenuItem<String?>(
                                value: e,
                                child: CommonDropdownText(text: e),
                              ),
                            )
                            .toList();

                        final initialValue = current.isEmpty ? null : current;

                        return DropdownButtonFormField<String?>(
                          isExpanded: true,
                          initialValue: initialValue,
                          decoration: const InputDecoration(
                            labelText: 'Habitat Type',
                            hintText: 'Select a habitat type',
                          ),
                          items: items,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              siteFormCtr.habitatTypeCtr.text = newValue;
                              SiteServices(ref: ref).updateSiteAttribute(
                                id,
                                SiteAttributeCompanion(
                                  habitatType: db.Value(newValue),
                                ),
                              );
                            }
                          },
                        );
                      },
                      loading: () => const CommonProgressIndicator(),
                      error: (e, _) => Text(e.toString()),
                    ),
                TextFormField(
                  controller: siteFormCtr.habitatConditionCtr,
                  decoration: const InputDecoration(
                    labelText: 'Habitat Condition',
                    hintText: 'E.g. "Pristine", "Disturbed", "etc."',
                  ),
                  onChanged: (value) =>
                      SiteServices(ref: ref).updateSiteAttribute(
                        id,
                        SiteAttributeCompanion(
                          habitatCondition: db.Value(value),
                        ),
                      ),
                ),
                TextFormField(
                  maxLines: 10,
                  controller: siteFormCtr.habitatDescriptionCtr,
                  decoration: const InputDecoration(
                    labelText: 'Habitat Description',
                    hintText:
                        'Describe the site, e.g. "A camp site in the middle of the forest."',
                  ),
                  onChanged: (value) =>
                      SiteServices(ref: ref).updateSiteAttribute(
                        id,
                        SiteAttributeCompanion(
                          habitatDescription: db.Value(value),
                        ),
                      ),
                ),
                TextFormField(
                  controller: siteFormCtr.canopyCoverCtr,
                  decoration: const InputDecoration(
                    labelText: 'Canopy Cover',
                    hintText: 'Enter canopy cover',
                  ),
                  onChanged: (value) =>
                      SiteServices(ref: ref).updateSiteAttribute(
                        id,
                        SiteAttributeCompanion(canopyCover: db.Value(value)),
                      ),
                ),
                CustomFieldForm(owner: CustomFieldOwner.site(id)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
