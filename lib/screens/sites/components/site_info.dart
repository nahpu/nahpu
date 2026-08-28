import 'package:material_ui/material_ui.dart';
import 'package:drift/drift.dart' as db;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';

class SiteInfo extends ConsumerWidget {
  const SiteInfo({
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
    List<PersonnelData> personnelList = [];
    final personnelEntry = ref.watch(projectPersonnelProvider);
    personnelEntry.whenData((personnelEntry) => personnelList = personnelEntry);

    return FormCard(
      isPrimary: true,
      title: 'Site Identity',
      infoTopic: InfoTopic.siteOverview,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      child: AdaptiveLayout(
        useHorizontalLayout: useHorizontalLayout,
        children: [
          TextField(
            controller: siteFormCtr.siteIDCtr,
            inputFormatters: [
              LengthLimitingTextInputFormatter(40),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-_]+')),
            ],
            decoration: const InputDecoration(
              labelText: 'Site ID',
              hintText:
                  'Enter a site ID (max. 40 chars), e.g. "CAMP-01", "LINE-1"',
            ),
            onChanged: (value) {
              siteFormCtr.siteIDCtr.value = TextEditingValue(
                text: value.toUpperCase(),
                selection: siteFormCtr.siteIDCtr.selection,
              );
              SiteServices(ref: ref).updateSite(
                id,
                SiteCompanion(siteID: db.Value(siteFormCtr.siteIDCtr.text)),
              );
            },
          ),
          DropdownButtonFormField(
            initialValue: siteFormCtr.leadStaffCtr,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Site Leader',
              hintText: 'Choose a person name',
            ),
            items: personnelList
                .map(
                  (e) => DropdownMenuItem(
                    value: e.uuid,
                    child: CommonDropdownText(text: e.name ?? ''),
                  ),
                )
                .toList(),
            onChanged: (String? uuid) {
              SiteServices(
                ref: ref,
              ).updateSite(id, SiteCompanion(leadStaffId: db.Value(uuid)));
            },
          ),
          ref
              .watch(effectiveUserDefinedFieldProvider(siteTypePrefKey))
              .when(
                data: (data) {
                  final options = includeCurrentVocabularyValue(
                    data,
                    siteFormCtr.siteTypeCtr,
                  );
                  final items = options
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: CommonDropdownText(text: e),
                        ),
                      )
                      .toList();

                  return DropdownButtonFormField<String?>(
                    initialValue: siteFormCtr.siteTypeCtr,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Site Type',
                      hintText: 'Choose a site type',
                    ),
                    items: items,
                    onChanged: (String? value) {
                      if (value != null) {
                        SiteServices(ref: ref).updateSite(
                          id,
                          SiteCompanion(siteType: db.Value(value)),
                        );
                      }
                    },
                  );
                },
                loading: () => const CommonProgressIndicator(),
                error: (e, _) => Text(e.toString()),
              ),
        ],
      ),
    );
  }
}
