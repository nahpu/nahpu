import 'package:flutter/material.dart';
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
import 'package:nahpu/screens/settings/app_settings_import.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/utility_services.dart';
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
    final projectUuid = ref.watch(projectUuidProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.md),
      child: NavigationDrawer(
        elevation: NahpuElevation.medium,
        footer: SafeArea(
          top: false,
          child: _DeleteProjectTile(projectUuid: projectUuid),
        ),
        children: [
          MenuAvatar(projectUuid: projectUuid),
          if (widget.showCloseProject) ...[
            ListTile(
              leading: const Icon(Icons.exit_to_app_outlined),
              title: const Text('Close project'),
              onTap: () => closeProject(context, ref, projectUuid),
            ),
            const Divider(color: Colors.grey),
          ],
          ListTile(
            leading: const Icon(Icons.move_to_inbox_outlined),
            title: const Text('Merge project'),
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
            title: const Text('Export project'),
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
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Bundle records'),
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
            title: const Text('Export records'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportForm()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: const Text('Export documents'),
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
            title: const Text('Backup database'),
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
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppSettings()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.adaptive.share_outlined),
            title: const Text('Export user configs'),
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
            leading: const Icon(Icons.input_outlined),
            title: const Text('Import user configs'),
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
    final errorColor = Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.only(bottom: NahpuSpacing.lg),
      child: ListTile(
        leading: Icon(Icons.delete_outline, color: errorColor),
        title: Text('Delete project', style: TextStyle(color: errorColor)),
        onTap: () async {
          final confirmationCode = projectUuid.length >= 5
              ? projectUuid.substring(0, 5)
              : projectUuid;
          return showDeleteAlertOnMenu(
            context: context,
            title: 'Delete project?',
            deletePrompt:
                'You will delete this project and its related data. This cannot be undone.',
            requiredConfirmationText: confirmationCode,
            onDelete: () async {
              try {
                final message = await ProjectServices(
                  ref: ref,
                ).deleteProjectAndData(projectUuid);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                  );
                  if (message != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  final errorMessage = e is ProjectDeletionFailure
                      ? e.toUserMessage()
                      : e.toString();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: Text(errorMessage),
                    ),
                  );
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
                data?.name ?? 'No Project',
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
