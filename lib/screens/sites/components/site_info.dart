import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as db;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/site_services.dart';

const List<String> siteTypeList = [
  'City',
  'Town',
  'Hotel',
  'Village',
  'Camp',
  'Trail',
  'Trapline',
  'Netline',
  'Cave',
  'Other',
];

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
    personnelEntry.whenData(
      (personnelEntry) => personnelList = personnelEntry,
    );

    return FormCard(
      isPrimary: true,
      title: 'Site Info',
      infoContent: const SiteInfoContent(),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      child: AdaptiveLayout(
        useHorizontalLayout: useHorizontalLayout,
        children: [
          TextField(
            controller: siteFormCtr.siteIDCtr,
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-_]+'))
            ],
            decoration: const InputDecoration(
              labelText: 'Site ID',
              hintText:
                  'Enter a site ID (max. 15 chars), e.g. "CAMP-01", "LINE-1"',
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
              SiteServices(ref: ref).updateSite(
                id,
                SiteCompanion(leadStaffId: db.Value(uuid)),
              );
            },
          ),
          DropdownButtonFormField<String?>(
            initialValue: siteFormCtr.siteTypeCtr,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Site Type',
              hintText: 'Choose a site type',
            ),
            items: siteTypeList
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: CommonDropdownText(text: e),
                  ),
                )
                .toList(),
            onChanged: (String? value) {
              if (value != null) {
                SiteServices(ref: ref).updateSite(
                  id,
                  SiteCompanion(siteType: db.Value(value)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class SiteInfoContent extends StatelessWidget {
  const SiteInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          header: 'Overview',
          content: 'Basic information about the site.'
              ' We recommend developing a naming convention for your sites.'
              ' For example, "CAMP-01" for the first campsite, '
              '"L1" for the first line. You could prefix the site ID with the'
              ' project ID or location ID to make it unique.',
        ),
        InfoContent(
            content:
                'To avoid inputting the same information when creating a new site,'
                ' you can duplicate a site using the menu button in the top right corner.'
                ' It will create a new site with the same information as the current site,'
                ' except that the site ID and coordinates will be empty.'),
      ],
    );
  }
}
