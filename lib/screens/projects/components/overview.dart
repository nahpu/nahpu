import 'package:nahpu/screens/projects/components/project_info.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/screens/projects/edit_project.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/localization/l10n.dart';

class ProjectOverview extends ConsumerWidget {
  const ProjectOverview({
    super.key,
    required this.projectUuid,
    required this.useHorizontalLayout,
  });

  final String projectUuid;
  final bool useHorizontalLayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormCard(
      title: context.l10n.projectOverview,
      infoTopic: InfoTopic.projectOverview,
      isPrimary: true,
      isExpanded: useHorizontalLayout,
      mainAxisAlignment: MainAxisAlignment.start,
      child: ref
          .watch(projectInfoProvider(projectUuid))
          .when(
            data: (data) {
              final qrData = ref.watch(projectQrPayloadProvider(projectUuid));
              final actions = ProjectInfoActions(
                projectData: data,
                onEdit: () => _openEditProject(context),
              );
              if (useHorizontalLayout) {
                return Column(
                  children: [
                    Expanded(
                      child: _ProjectInfoSection(
                        data: data,
                        qrData: qrData,
                        useHorizontalQrLayout: true,
                      ),
                    ),
                    actions,
                  ],
                );
              }
              return Column(
                children: [
                  SizedBox(
                    height: 360,
                    child: _ProjectInfoSection(
                      data: data,
                      qrData: qrData,
                      useHorizontalQrLayout: false,
                    ),
                  ),
                  actions,
                ],
              );
            },
            loading: () => const CommonProgressIndicator(),
            error: (error, stack) => Text(error.toString()),
          ),
    );
  }

  void _openEditProject(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProject(projectUuid: projectUuid),
      ),
    );
  }

  Widget showAlert(BuildContext context, String error) {
    return AlertDialog(
      title: Text(context.l10n.commonError),
      content: Column(
        children: [Text(context.l10n.projectOverviewLoadError(error))],
      ),
    );
  }
}

class _ProjectInfoSection extends StatelessWidget {
  const _ProjectInfoSection({
    required this.data,
    required this.qrData,
    required this.useHorizontalQrLayout,
  });

  final ProjectData? data;
  final String? qrData;
  final bool useHorizontalQrLayout;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('project-overview-scroll'),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ProjectInfo(
          projectData: data,
          qrData: qrData,
          useHorizontalQrLayout: useHorizontalQrLayout,
          showActions: false,
          useSectionContainers: false,
        ),
      ),
    );
  }
}
