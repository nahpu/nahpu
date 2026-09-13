import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/settings/settings_destination.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/settings/application/application_settings.dart';
import 'package:nahpu/styles/design_tokens.dart';

class AppSettings extends ConsumerStatefulWidget {
  const AppSettings({super.key, this.projectUuid});

  final String? projectUuid;

  @override
  ProjectSettingState createState() => ProjectSettingState();
}

class ProjectSettingState extends ConsumerState<AppSettings> {
  SettingsDestination _selected = SettingsDestination.catalogFormat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSplit = constraints.maxWidth >= NahpuBreakpoints.desktop;
            final sectionList = SettingsSectionList(
              selected: isSplit ? _selected : null,
              onOpen: (destination) => _open(destination, isSplit: isSplit),
            );
            if (!isSplit) {
              return sectionList;
            }
            // Wide screens keep the section list beside the open page, so
            // moving between settings does not leave this screen.
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: NahpuContentWidth.settingsList,
                  child: sectionList,
                ),
                const VerticalDivider(
                  width: NahpuStroke.thin,
                  thickness: NahpuStroke.thin,
                ),
                Expanded(
                  child: SettingsDetailPane(
                    destination: _selected,
                    projectUuid: widget.projectUuid,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _open(SettingsDestination destination, {required bool isSplit}) {
    if (isSplit && destination.opensInPane) {
      setState(() => _selected = destination);
      return;
    }
    openSettingsDestination(
      context,
      destination,
      projectUuid: widget.projectUuid,
    );
  }
}

class SettingsSectionList extends ConsumerWidget {
  const SettingsSectionList({
    super.key,
    required this.selected,
    required this.onOpen,
  });

  /// The page open beside the list, or null when pages open full screen.
  final SettingsDestination? selected;
  final ValueChanged<SettingsDestination> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonSettingList(
      sections: [
        ref
            .watch(catalogFmtNotifierProvider)
            .when(
              data: (data) => CatalogSettings(
                catalogFmt: data,
                selected: selected,
                onOpen: onOpen,
              ),
              loading: () => const CommonProgressIndicator(),
              error: (e, s) => const Text('Error'),
            ),
        DatabaseSettingSections(selected: selected, onOpen: onOpen),
        ExportSettingsSection(selected: selected, onOpen: onOpen),
        ApplicationSettings(selected: selected, onOpen: onOpen),
      ],
    );
  }
}

/// Hosts the selected settings page beside the section list.
///
/// Pages open inside their own navigator, so a page's follow-up screens stay
/// in the pane and the first page shows no back button.
class SettingsDetailPane extends StatefulWidget {
  const SettingsDetailPane({
    super.key,
    required this.destination,
    required this.projectUuid,
  });

  final SettingsDestination destination;
  final String? projectUuid;

  @override
  State<SettingsDetailPane> createState() => _SettingsDetailPaneState();
}

class _SettingsDetailPaneState extends State<SettingsDetailPane> {
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void didUpdateWidget(covariant SettingsDetailPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destination != widget.destination) {
      // A new navigator drops the pages opened from the previous setting.
      _navigatorKey = GlobalKey<NavigatorState>();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler<Object?>(
      onPopWithResult: (_) => _navigatorKey.currentState?.maybePop(),
      child: LayoutBuilder(
        builder: (context, constraints) => MediaQuery(
          // Several settings pages choose their layout from the screen width.
          // Reporting the pane size lets them fit the pane instead.
          data: MediaQuery.of(context).copyWith(size: constraints.biggest),
          child: HeroControllerScope.none(
            child: Navigator(
              key: _navigatorKey,
              onGenerateRoute: (settings) => MaterialPageRoute<void>(
                settings: settings,
                builder: (context) => SettingsDestinationPage(
                  destination: widget.destination,
                  projectUuid: widget.projectUuid,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CatalogSettings extends StatelessWidget {
  const CatalogSettings({
    super.key,
    required this.catalogFmt,
    required this.selected,
    required this.onOpen,
  });

  final CatalogFmt catalogFmt;
  final SettingsDestination? selected;
  final ValueChanged<SettingsDestination> onOpen;

  @override
  Widget build(BuildContext context) {
    return CommonSettingSection(
      title: 'Catalogs',
      isDivided: true,
      children: [
        CatalogFmtSection(
          selectedFmt: catalogFmt,
          isSelected: selected == SettingsDestination.catalogFormat,
          onTap: () => onOpen(SettingsDestination.catalogFormat),
        ),
        // Sites precede events: a collecting event happens at a site, so the
        // settings follow the order the records are created in.
        CommonSettingTile(
          title: 'Sites',
          icon: Icons.place_outlined,
          label: 'Manage site types, habitat types, and coordinate datums',
          isNavigation: true,
          isSelected: selected == SettingsDestination.sites,
          onTap: () => onOpen(SettingsDestination.sites),
        ),
        CollEventSection(
          isSelected: selected == SettingsDestination.events,
          onTap: () => onOpen(SettingsDestination.events),
        ),
        SpecimenSection(
          catalogFmt: catalogFmt,
          isSelected: selected == SettingsDestination.specimens,
          onTap: () => onOpen(SettingsDestination.specimens),
        ),
        CommonSettingTile(
          title: 'Custom fields',
          icon: Icons.dynamic_form_outlined,
          label:
              'Manage fields for sites, environmental data, specimens, parts, and parasites',
          isNavigation: true,
          isSelected: selected == SettingsDestination.customFields,
          onTap: () => onOpen(SettingsDestination.customFields),
        ),
      ],
    );
  }
}

class DatabaseSettingSections extends StatelessWidget {
  const DatabaseSettingSections({super.key, this.selected, this.onOpen});

  final SettingsDestination? selected;

  /// Opens a page; when null, the page is pushed full screen.
  final ValueChanged<SettingsDestination>? onOpen;

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
          isSelected: selected == SettingsDestination.taxa,
          onTap: () => _open(context, SettingsDestination.taxa),
        ),
        CommonSettingTile(
          title: 'Personnel',
          icon: Icons.group_outlined,
          label: 'Manage personnel records',
          isNavigation: true,
          isSelected: selected == SettingsDestination.personnel,
          onTap: () => _open(context, SettingsDestination.personnel),
        ),
        CommonSettingTile(
          isNavigation: true,
          icon: Icons.backup_outlined,
          title: 'Backup database',
          label: 'Full database backup of all records and settings',
          isSelected: selected == SettingsDestination.backupDatabase,
          onTap: () => _open(context, SettingsDestination.backupDatabase),
        ),
        CommonSettingTile(
          isNavigation: true,
          icon: Icons.storage_outlined,
          title: 'Replace database',
          label: 'Replace current database with another database file',
          isSelected: selected == SettingsDestination.replaceDatabase,
          onTap: () => _open(context, SettingsDestination.replaceDatabase),
        ),
      ],
    );
  }

  void _open(BuildContext context, SettingsDestination destination) {
    final onOpen = this.onOpen;
    if (onOpen != null) {
      onOpen(destination);
    } else {
      openSettingsDestination(context, destination);
    }
  }
}

class CatalogFmtSection extends StatelessWidget {
  const CatalogFmtSection({
    super.key,
    required this.selectedFmt,
    required this.onTap,
    this.isSelected = false,
  });

  final CatalogFmt selectedFmt;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return CommonSettingTile(
      isNavigation: true,
      icon: Icons.archive_outlined,
      title: 'Format',
      label: 'Set catalog format',
      value: catalogFmtDisplayName(selectedFmt),
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}

class SpecimenSection extends StatelessWidget {
  const SpecimenSection({
    super.key,
    required this.catalogFmt,
    required this.onTap,
    this.isSelected = false,
  });

  final CatalogFmt catalogFmt;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return CommonSettingTile(
      isNavigation: true,
      icon: matchCatFmtToIcon(catalogFmt, isFilledIcon: false),
      title: 'Specimens',
      label:
          'Manage field, tissue ID settings, and controlled vocabularies for specimen forms',
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}

class CollEventSection extends StatelessWidget {
  const CollEventSection({
    super.key,
    required this.onTap,
    this.isSelected = false,
  });

  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return CommonSettingTile(
      isNavigation: true,
      icon: Icons.calendar_month_outlined,
      title: 'Events',
      label:
          'Manage activities, collection methods, personnel roles, and environmental fields',
      isSelected: isSelected,
      onTap: onTap,
    );
  }
}

class ExportSettingsSection extends StatelessWidget {
  const ExportSettingsSection({
    super.key,
    required this.selected,
    required this.onOpen,
  });

  final SettingsDestination? selected;
  final ValueChanged<SettingsDestination> onOpen;

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
          isSelected: selected == SettingsDestination.tabularPresets,
          onTap: () => onOpen(SettingsDestination.tabularPresets),
        ),
        CommonSettingTile(
          title: 'Documents',
          label: 'Manage presets for exporting documents',
          isNavigation: true,
          icon: Icons.picture_as_pdf_outlined,
          isSelected: selected == SettingsDestination.documentPresets,
          onTap: () => onOpen(SettingsDestination.documentPresets),
        ),
        CommonSettingTile(
          isNavigation: true,
          icon: Icons.edit_note_outlined,
          title: 'Template Editor',
          label: 'Create and edit document templates',
          isSelected: selected == SettingsDestination.templateEditor,
          onTap: () => onOpen(SettingsDestination.templateEditor),
        ),
      ],
    );
  }
}
