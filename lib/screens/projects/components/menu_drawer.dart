import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/screens/exports/bundle_records.dart';
import 'package:nahpu/screens/exports/export_db.dart';
import 'package:nahpu/screens/exports/export_settings.dart';
import 'package:nahpu/screens/exports/export_documents.dart';
import 'package:nahpu/screens/exports/export_records.dart';
import 'package:nahpu/screens/projects/project_transfer/export_project.dart';
import 'package:nahpu/screens/projects/project_transfer/import_project.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/screens/home/home.dart';
import 'package:nahpu/screens/settings/settings.dart';
import 'package:nahpu/screens/settings/transfer/app_settings_import.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/projects/batch_import/batch_import.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/projects/project_services.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/styles/design_tokens.dart';

class ProjectMenuDrawer extends ConsumerStatefulWidget {
  const ProjectMenuDrawer({super.key, this.showCloseProject = true});

  final bool showCloseProject;

  @override
  ProjectMenuDrawerState createState() => ProjectMenuDrawerState();
}

class ProjectMenuDrawerState extends ConsumerState<ProjectMenuDrawer> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final projectUuid = ref.watch(projectUuidProvider);
    return Padding(
      padding: widget.showCloseProject
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(vertical: NahpuSpacing.md),
      child: NavigationDrawer(
        elevation: NahpuElevation.medium,
        footer: widget.showCloseProject
            ? null
            : SafeArea(
                top: false,
                child: _DeleteProjectTile(projectUuid: projectUuid),
              ),
        children: [
          MenuAvatar(projectUuid: projectUuid),
          if (widget.showCloseProject) ...[
            ListTile(
              leading: const Icon(Icons.exit_to_app_outlined),
              title: Text(l10n.sharedNavCloseProject),
              onTap: () => closeProject(context, ref, projectUuid),
            ),
            const Divider(color: Colors.grey),
          ],
          ListTile(
            leading: const Icon(Icons.move_to_inbox_outlined),
            title: Text(l10n.labelProjectToolMergeProject),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImportProjectScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.outbox_outlined),
            title: Text(l10n.labelProjectToolExportProject),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExportProjectScreen(),
                ),
              );
            },
          ),
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          ListTile(
            leading: const Icon(Icons.post_add_outlined),
            title: Text(l10n.labelProjectToolBatchImport),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BatchImportPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: Text(l10n.labelProjectToolBundleRecords),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BundleRecordsForm(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.adaptive.share_outlined),
            title: Text(l10n.labelProjectToolExportRecords),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportForm()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l10n.labelProjectToolExportDocuments),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExportDocumentsView(),
                ),
              );
            },
          ),
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: Text(l10n.drawerBackupDatabase),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportDbForm()),
              );
            },
          ),
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.drawerSettings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppSettings(projectUuid: projectUuid),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.adaptive.share_outlined),
            title: Text(l10n.drawerExportUserConfigs),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExportSettingsForm(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(l10n.drawerImportUserConfigs),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppSettingsImport(),
                ),
              );
            },
          ),
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          if (widget.showCloseProject) ...[
            const SizedBox(height: NahpuSpacing.xl),
            _DeleteProjectTile(projectUuid: projectUuid),
          ],
        ],
      ),
    );
  }
}

class _DeleteProjectTile extends ConsumerWidget {
  const _DeleteProjectTile({required this.projectUuid});

  final String projectUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final errorColor = Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.only(bottom: NahpuSpacing.lg),
      child: ListTile(
        leading: Icon(Icons.delete_outline, color: errorColor),
        title: Text(
          l10n.projectDeleteProject,
          style: TextStyle(color: errorColor),
        ),
        onTap: () async {
          final confirmationCode = projectUuid.length >= 5
              ? projectUuid.substring(0, 5)
              : projectUuid;
          // Held so the outcome is still reported if this tile is gone by the
          // time the deletion finishes: both outlive the menu panel.
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          return showDeleteAlertOnMenu(
            context: context,
            title: l10n.projectDeleteProjectTitle,
            deletePrompt: l10n.projectDeleteProjectPrompt,
            requiredConfirmationText: confirmationCode,
            onDelete: () async {
              try {
                final message = await ProjectServices(
                  ref: ref,
                ).deleteProjectAndData(projectUuid);
                navigator.pop();
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (context) => const Home()),
                );
                if (message != null) {
                  messenger.showSnackBar(SnackBar(content: Text(message)));
                }
              } catch (e) {
                navigator.pop();
                final errorMessage = e is ProjectDeletionFailure
                    ? e.toUserMessage()
                    : e.toString();
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.commonError),
                      content: Text(errorMessage),
                    ),
                  );
                } else {
                  messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
                }
              }
            },
          );
        },
      ),
    );
  }
}

void closeProject(BuildContext context, WidgetRef ref, String projectUuid) {
  ProjectServices(ref: ref).updateProject(
    projectUuid,
    ProjectCompanion(lastAccessed: db.Value(getSystemDateTime())),
  );
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const Home()),
  );
}

class MenuAvatar extends ConsumerWidget {
  const MenuAvatar({super.key, required this.projectUuid});

  final String projectUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectInfo = ref.watch(projectInfoProvider(projectUuid));
    return projectInfo.when(
      data: (data) {
        return DrawerHeader(
          decoration: BoxDecoration(
            color: Color.lerp(
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.surface,
              0.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data?.name ?? context.l10n.projectNoProject,
                style: TextStyle(
                  fontFamily: 'Merriweather',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                data?.uuid ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
      loading: () => const CommonProgressIndicator(),
      error: (error, stack) => Text(error.toString()),
    );
  }
}
