import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/projects/personnel/manage_personnel.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_list.dart';
import 'package:nahpu/screens/settings/catalog_format.dart';
import 'package:nahpu/screens/settings/collevent_settings.dart';
import 'package:nahpu/screens/settings/site_settings.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/settings/db_settings.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/settings/application_settings.dart';
import 'package:nahpu/screens/settings/specimen_settings.dart';

class AppSettings extends ConsumerStatefulWidget {
  const AppSettings({super.key});

  @override
  ProjectSettingState createState() => ProjectSettingState();
}

class ProjectSettingState extends ConsumerState<AppSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: CommonSettingList(
          sections: [
            ref.watch(catalogFmtNotifierProvider).when(
                  data: (data) => CatalogSettings(ref: ref, catalogFmt: data),
                  loading: () => const CommonProgressIndicator(),
                  error: (e, s) => const Text('Error'),
                ),
            const DatabaseSettingSections(),
            const ApplicationSettings(),
          ],
        ),
      ),
    );
  }
}

class CatalogSettings extends StatelessWidget {
  const CatalogSettings({
    super.key,
    required this.ref,
    required this.catalogFmt,
  });

  final WidgetRef ref;
  final CatalogFmt catalogFmt;

  @override
  Widget build(BuildContext context) {
    return CommonSettingSection(
      title: 'Catalogs',
      isDivided: true,
      children: [
        CatalogFmtSection(selectedFmt: matchCatFmtToTaxonGroup(catalogFmt)),
        const CollEventSection(),
        CommonSettingTile(
          title: 'Sites',
          icon: Icons.place_outlined,
          label: 'Edit habitat types and site metadata',
          isNavigation: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SiteSelection(),
            ),
          ),
        ),
        SpecimenSection(catalogFmt: catalogFmt),
      ],
    );
  }
}

class DatabaseSettingSections extends StatelessWidget {
  const DatabaseSettingSections({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonSettingSection(
      title: 'Database',
      isDivided: true,
      children: [
        CommonSettingTile(
            title: 'Taxa',
            label: 'Edit and remove taxa',
            isNavigation: true,
            icon: Icons.emoji_nature_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TaxonRegistryPage(),
                ),
              );
            }),
        CommonSettingTile(
            title: 'Personnel',
            icon: Icons.group_outlined,
            label: 'Edit and remove personnel',
            isNavigation: true,
            onTap: (() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManagePersonnel(),
                ),
              );
            })),
        CommonSettingTile(
          isNavigation: true,
          icon: MdiIcons.databaseOutline,
          title: 'Replace database',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DatabaseSettings(),
            ),
          ),
        ),
      ],
    );
  }
}

class CatalogFmtSection extends StatelessWidget {
  const CatalogFmtSection({super.key, required this.selectedFmt});

  final String selectedFmt;

  @override
  Widget build(BuildContext context) {
    return CommonSettingTile(
        isNavigation: true,
        icon: MdiIcons.fileCabinet,
        title: 'Format',
        value: selectedFmt,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CatalogFmtSelection(
                selectedFmt: selectedFmt,
              ),
            ),
          );
        });
  }
}

class SpecimenSection extends StatelessWidget {
  const SpecimenSection({super.key, required this.catalogFmt});

  final CatalogFmt catalogFmt;

  @override
  Widget build(BuildContext context) {
    return CommonSettingTile(
        isNavigation: true,
        icon: matchCatFmtToIcon(catalogFmt, false),
        title: 'Specimens',
        label: 'Tissue ID, specimen type, treatments, and more',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SpecimenSelection(),
            ),
          );
        });
  }
}

class CollEventSection extends StatelessWidget {
  const CollEventSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonSettingTile(
      isNavigation: true,
      icon: Icons.calendar_month_outlined,
      title: 'Events',
      label: 'Methods and event personnel roles',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CollEventSelection(),
        ),
      ),
    );
  }
}
