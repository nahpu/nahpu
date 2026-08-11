import 'package:nahpu/screens/projects/components/project_info.dart';
import 'package:flutter/material.dart';
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
      infoContent: const ProjectInfoContent(),
      isPrimary: true,
      isExpanded: useHorizontalLayout,
      mainAxisAlignment: MainAxisAlignment.start,
      child: ref
          .watch(projectInfoProvider(projectUuid))
          .when(
            data: (data) {
              final projectInfo = Padding(
                padding: const EdgeInsets.all(8),
                child: ProjectInfo(
                  projectData: data,
                  showActions: false,
                  useSectionContainers: false,
                ),
              );
              final actions = ProjectInfoActions(
                projectData: data,
                onEdit: onEdit,
              );
              if (useHorizontalLayout) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        key: const ValueKey('project-overview-scroll'),
                        child: projectInfo,
                      ),
                    ),
                    actions,
                  ],
                );
              }
              return Column(children: [projectInfo, actions]);
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

class ProjectInfoContent extends StatelessWidget {
  const ProjectInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          header: 'Overview',
          content:
              'Basic information about the project.'
              ' You can edit or export the project information'
              ' using the actions at the bottom of this panel.'
              ' QR sharing is available from the project menu.',
        ),
        InfoContent(
          header: 'UUID',
          content:
              'UUID is a universal unique identifier.'
              ' It is automatically generated when you create a new project.'
              ' It standardizes the project identification process,'
              ' making it easy to find, manage, and share project data.',
        ),
        InfoContent(
          header: 'Sharing project details',
          content:
              'Export project information as JSON to transfer it '
              'between desktop devices. You can also use the "Show QR" '
              'action from the project menu, then scan it when creating a '
              'new project on another device.',
        ),
        InfoContent(
          header: 'Tips',
          content:
              'Keep the description short and concise.'
              ' Provide only general information about the location,'
              ' e.g. Mt. Gede, Java, Indonesia.'
              ' We recommend using the narrative to provide'
              ' more detailed information about the project.',
        ),
      ],
    );
  }
}
