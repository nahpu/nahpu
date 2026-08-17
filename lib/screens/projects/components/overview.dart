import 'package:nahpu/screens/projects/components/project_info.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/common/common.dart';

class ProjectOverview extends ConsumerWidget {
  const ProjectOverview({
    super.key,
    required this.projectUuid,
    required this.useHorizontalLayout,
    this.onEdit,
  });

  final String projectUuid;
  final bool useHorizontalLayout;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormCard(
      title: 'Project Overview',
      infoTopic: InfoTopic.projectOverview,
      isPrimary: true,
      isExpanded: useHorizontalLayout,
      mainAxisAlignment: MainAxisAlignment.start,
      child: ref
          .watch(projectInfoProvider(projectUuid))
          .when(
            data: (data) {
              final actions = ProjectInfoActions(
                projectData: data,
                onEdit: onEdit,
              );
              if (useHorizontalLayout) {
                return Column(
                  children: [
                    Expanded(child: _ProjectInfoSection(data: data)),
                    actions,
                  ],
                );
              }
              return Column(
                children: [
                  SizedBox(height: 360, child: _ProjectInfoSection(data: data)),
                  actions,
                ],
              );
            },
            loading: () => const CommonProgressIndicator(),
            error: (error, stack) => Text(error.toString()),
          ),
    );
  }

  Widget showAlert(BuildContext context, String error) {
    return AlertDialog(
      title: const Text('ERROR!'),
      content: Column(
        children: [
          Text(
            'Failed fetching data from the database. Check if the project name exists. $error',
          ),
        ],
      ),
    );
  }
}

class _ProjectInfoSection extends StatelessWidget {
  const _ProjectInfoSection({required this.data});

  final ProjectData? data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('project-overview-scroll'),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ProjectInfo(
          projectData: data,
          showActions: false,
          useSectionContainers: false,
        ),
      ),
    );
  }
}
