import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/templates/template_editor_screen.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/projects/personnel/manage_personnel.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_list.dart';
import 'package:nahpu/screens/settings/records/catalog_format.dart';
import 'package:nahpu/screens/settings/records/collevent_settings.dart';
import 'package:nahpu/screens/settings/records/site_settings.dart';
import 'package:nahpu/screens/exports/export_db.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/settings/database/db_settings.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/settings/application/application_settings.dart';
import 'package:nahpu/screens/settings/records/specimen_settings.dart';
import 'package:nahpu/screens/settings/presets/document_presets.dart';
import 'package:nahpu/screens/settings/presets/export_presets.dart';
import 'package:nahpu/screens/settings/records/custom_fields.dart';

class AppSettings extends ConsumerStatefulWidget {
  const AppSettings({super.key, this.projectUuid});

  final String? projectUuid;

  @override
  ProjectSettingState createState() => ProjectSettingState();
}

class ProjectSettingState extends ConsumerState<AppSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: CommonSettingList(
          sections: [
            ref
                .watch(catalogFmtNotifierProvider)
                .when(
                  data: (data) => CatalogSettings(
                    ref: ref,
                    catalogFmt: data,
                    projectUuid: widget.projectUuid,
                  ),
                  loading: () => const CommonProgressIndicator(),
                  error: (e, s) => const Text('Error'),
                ),
            const DatabaseSettingSections(),
            const ExportSettingsSection(),
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
    required this.projectUuid,
  });

  final WidgetRef ref;
  final CatalogFmt catalogFmt;
  final String? projectUuid;

  @override
  Widget build(BuildContext context) {
    return CommonSettingSection(
      title: 'Catalogs',
      isDivided: true,
      children: [
        CatalogFmtSection(selectedFmt: catalogFmt),
        // Sites precede events: a collecting event happens at a site, so the
        // settings follow the order the records are created in.
        CommonSettingTile(
          title: 'Sites',
          icon: Icons.place_outlined,
          label: 'Manage site types, habitat types, and coordinate datums',
          isNavigation: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SiteSelection()),
          ),
        ),
        const CollEventSection(),
        SpecimenSection(catalogFmt: catalogFmt),
        CommonSettingTile(
          title: 'Custom fields',
          icon: Icons.dynamic_form_outlined,
          label:
              'Manage fields for sites, environmental data, specimens, parts, and parasites',
          isNavigation: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomFieldsSettings(
                projectUuid: projectUuid,
                currentCatalog: catalogFmt,
              ),
            ),
          ),
        ),
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
          label: 'Manage taxonomy records',
          isNavigation: true,
          icon: Icons.emoji_nature_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManageTaxa()),
            );
          },
        ),
        CommonSettingTile(
          title: 'Personnel',
          icon: Icons.group_outlined,
          label: 'Manage personnel records',
          isNavigation: true,
          onTap: (() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManagePersonnel()),
            );
          }),
        ),
        CommonSettingTile(
          isNavigation: true,
          icon: Icons.backup_outlined,
          title: 'Back up database',
          label: 'Full archive with all media (.zip or .tar.gz)',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExportDbForm()),
          ),
        ),
        CommonSettingTile(
          isNavigation: true,
          icon: Icons.storage_outlined,
          title: 'Replace database',
          label: 'Overwrites everything. Back up first.',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DatabaseSettings()),
          ),
        ),
      ],
    );
  }
}

class CatalogFmtSection extends StatelessWidget {
  const CatalogFmtSection({super.key, required this.selectedFmt});

  final CatalogFmt selectedFmt;

  @override
  Widget build(BuildContext context) {
    return CommonSettingTile(
      isNavigation: true,
      icon: Icons.archive_outlined,
      title: 'Format',
      label: 'Set catalog format',
      value: matchCatFmtToTaxonGroup(selectedFmt),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CatalogFmtSelection()),
        );
      },
    );
  }
}

class SpecimenSection extends StatelessWidget {
  const SpecimenSection({super.key, required this.catalogFmt});

  final CatalogFmt catalogFmt;

  @override
  Widget build(BuildContext context) {
    return CommonSettingTile(
      isNavigation: true,
      icon: matchCatFmtToIcon(catalogFmt, isFilledIcon: false),
      title: 'Specimens',
      label:
          'Manage field, tissue ID settings, and controlled vocabularies for specimen forms',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SpecimenSelection()),
        );
      },
    );
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
      label:
          'Manage activities, collection methods, personnel roles, and environmental fields',
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CollEventSelection()),
      ),
    );
  }
}

class ExportSettingsSection extends StatelessWidget {
  const ExportSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonSettingSection(
      title: 'Exports',
      isDivided: true,
      children: [
        CommonSettingTile(
          title: 'Tabular Data',
          label: 'Manage presets for exporting in tabular formats',
          isNavigation: true,
          icon: Icons.table_view_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExportPresetsScreen(),
              ),
            );
          },
        ),
        CommonSettingTile(
          title: 'Documents',
          label: 'Manage presets for exporting documents',
          isNavigation: true,
          icon: Icons.picture_as_pdf_outlined,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DocumentPresetsScreen(),
              ),
            );
          },
        ),
        CommonSettingTile(
          isNavigation: true,
          icon: Icons.edit_note_outlined,
          title: 'Template Editor',
          label: 'Create and edit document templates',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const TemplateEditorScreen(),
            ),
          ),
        ),
      ],
    );
  }
}
