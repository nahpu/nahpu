import 'package:nahpu/screens/projects/components/project_info.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/common/common.dart';

class ProjectOverview extends ConsumerWidget {
  const ProjectOverview({super.key, required this.projectUuid});

  final String projectUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormCard(
      title: 'Project Overview',
      infoContent: const ProjectInfoContent(),
      isPrimary: true,
      mainAxisAlignment: MainAxisAlignment.start,
      child: ref.watch(projectInfoProvider(projectUuid)).when(
            data: (data) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: ProjectInfo(
                  projectData: data,
                ),
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
              'Failed fetching data from the database. Check if the project name exists. $error')
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
          content: 'Basic information about the project.'
              ' You can edit the project information'
              ' by clicking the edit button in the bottom right corner.'
              ' To share the project details with others,'
              ' use the QR code.',
        ),
        InfoContent(
          header: 'UUID',
          content: 'UUID is a universal unique identifier.'
              ' It is automatically generated when you create a new project.'
              ' It standardizes the project identification process,'
              ' making it easy to find, manage, and share project data.',
        ),
        InfoContent(
          header: 'Sharing project details',
          content: 'Current version only supports sharing project details '
              'via QR code and only available to import using mobile devices. Tap the QR code to view it in full. '
              'On other devices, create a new project and use the '
              '"Scan QR" button to scan the QR code from this project. '
              'The QR code contains essential project information, '
              'making it convenient to consolidate data when working '
              'with multiple devices on the same project.',
        ),
        InfoContent(
          header: 'Tips',
          content: 'Keep the description short and concise.'
              ' Provide only general information about the location,'
              ' e.g. Mt. Gede, Java, Indonesia.'
              ' We recommend using the narrative to provide'
              ' more detailed information about the project.',
        ),
      ],
    );
  }
}
