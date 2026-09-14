import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/exports/export_db.dart';
import 'package:nahpu/screens/projects/personnel/manage_personnel.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_list.dart';
import 'package:nahpu/screens/settings/application/application_settings.dart';
import 'package:nahpu/screens/settings/application/data_usage.dart';
import 'package:nahpu/screens/settings/database/db_settings.dart';
import 'package:nahpu/screens/settings/presets/document_presets.dart';
import 'package:nahpu/screens/settings/presets/export_presets.dart';
import 'package:nahpu/screens/settings/records/catalog_format.dart';
import 'package:nahpu/screens/settings/records/collevent_settings.dart';
import 'package:nahpu/screens/settings/records/custom_fields.dart';
import 'package:nahpu/screens/settings/records/site_settings.dart';
import 'package:nahpu/screens/settings/records/specimen_settings.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/templates/template_editor_screen.dart';
import 'package:nahpu/services/providers/settings.dart';

/// A page reachable from the settings section list.
enum SettingsDestination {
  catalogFormat,
  sites,
  events,
  specimens,
  customFields,
  taxa,
  personnel,
  backupDatabase,
  replaceDatabase,
  tabularPresets,
  documentPresets,
  templateEditor,
  theme,
  dataUsage;

  /// Whether the page can open beside the section list on wide screens.
  ///
  /// Taxa and personnel already split into their own list and details. The
  /// template editor and the database jobs guard leaving with [PopScope],
  /// which switching the pane would bypass, so these open full screen.
  bool get opensInPane => switch (this) {
    SettingsDestination.taxa ||
    SettingsDestination.personnel ||
    SettingsDestination.templateEditor ||
    SettingsDestination.backupDatabase ||
    SettingsDestination.replaceDatabase => false,
    _ => true,
  };
}

/// Opens [destination] as a full-screen page.
void openSettingsDestination(
  BuildContext context,
  SettingsDestination destination, {
  String? projectUuid,
}) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (context) => SettingsDestinationPage(
        destination: destination,
        projectUuid: projectUuid,
      ),
    ),
  );
}

class SettingsDestinationPage extends StatelessWidget {
  const SettingsDestinationPage({
    super.key,
    required this.destination,
    required this.projectUuid,
  });

  final SettingsDestination destination;
  final String? projectUuid;

  @override
  Widget build(BuildContext context) {
    return switch (destination) {
      SettingsDestination.catalogFormat => const CatalogFmtSelection(),
      SettingsDestination.sites => const SiteSelection(),
      SettingsDestination.events => const CollEventSelection(),
      SettingsDestination.specimens => const SpecimenSelection(),
      SettingsDestination.customFields => _CustomFieldsDestination(
        projectUuid: projectUuid,
      ),
      SettingsDestination.taxa => const ManageTaxa(),
      SettingsDestination.personnel => const ManagePersonnel(),
      SettingsDestination.backupDatabase => const ExportDbForm(),
      SettingsDestination.replaceDatabase => const DatabaseSettings(),
      SettingsDestination.tabularPresets => const ExportPresetsScreen(),
      SettingsDestination.documentPresets => const DocumentPresetsScreen(),
      SettingsDestination.templateEditor => const TemplateEditorScreen(),
      SettingsDestination.theme => const ThemeSettings(),
      SettingsDestination.dataUsage => const DataUsageSettings(),
    };
  }
}

/// Custom fields follow the current catalog format, which can change while
/// the page is open beside the catalog format setting.
class _CustomFieldsDestination extends ConsumerWidget {
  const _CustomFieldsDestination({required this.projectUuid});

  final String? projectUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(catalogFmtNotifierProvider)
        .when(
          data: (catalogFmt) => CustomFieldsSettings(
            projectUuid: projectUuid,
            currentCatalog: catalogFmt,
          ),
          loading: () =>
              const Scaffold(body: Center(child: CommonProgressIndicator())),
          error: (error, _) => Scaffold(
            body: Center(child: Text('Unable to load catalog format: $error')),
          ),
        );
  }
}
