import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/dialogs/project_exchange_dialogs.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:nahpu/screens/shared/media/qr.dart';

class ProjectInfo extends StatelessWidget {
  const ProjectInfo({
    super.key,
    required this.projectData,
    this.onEdit,
    this.showExport = true,
  });

  final ProjectData? projectData;
  final VoidCallback? onEdit;
  final bool showExport;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProjectInfoText(title: 'Project name: ', text: projectData?.name),
        ProjectInfoText(title: 'UUID: ', text: projectData?.uuid),
        ProjectInfoText(
          title: 'Project description: ',
          text: projectData?.description,
        ),
        ProjectInfoText(
          title: 'Principal investigator: ',
          text: projectData?.principalInvestigator,
        ),
        Consumer(
          builder: (context, ref, child) {
            final fieldIdMode = ref.watch(fieldIdModeNotifierProvider).value;
            if (fieldIdMode != FieldIdMode.project) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                ProjectInfoText(
                  title: 'Catalog number prefix: ',
                  text: projectData?.catalogNumberPrefix,
                ),
                ProjectInfoText(
                  title: 'Current catalog number: ',
                  text: projectData?.currentCatalogNumber?.toString(),
                ),
                ProjectInfoText(
                  title: 'Catalog number suffix: ',
                  text: projectData?.catalogNumberSuffix,
                ),
              ],
            );
          },
        ),
        ProjectInfoText(title: 'Location: ', text: projectData?.location),
        ProjectInfoText(title: 'Time zone: ', text: projectData?.timeZone),
        ProjectInfoText(
          title: 'Start date: ',
          text: dateStdToDateDisplay(projectData?.startDate),
        ),
        ProjectInfoText(
          title: 'End date: ',
          text: dateStdToDateDisplay(projectData?.endDate),
        ),
        const SizedBox(height: 24),
        ProjectInfoText(
          title: 'Created: ',
          text: _parseDate(projectData?.created),
          isSmall: true,
        ),
        ProjectInfoText(
          title: 'Last accessed: ',
          text: _parseDate(projectData?.lastAccessed),
          isSmall: true,
        ),
        if (projectData != null && (onEdit != null || showExport)) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onEdit != null) ...[
                TextButton(onPressed: onEdit, child: const Text('Edit')),
                const SizedBox(width: 16),
              ],
              if (showExport)
                TextButton(
                  onPressed: () => showProjectExportDialog(
                    context: context,
                    projectData: projectData!,
                  ),
                  child: const Text('Export info'),
                ),
            ],
          ),
        ],
      ],
    );
  }

  String _parseDate(String? date) {
    final value = parseDate(date);
    return '${value.date} ${value.time}';
  }
}

class ProjectInfoText extends StatelessWidget {
  const ProjectInfoText({
    super.key,
    required this.title,
    required this.text,
    this.isSmall = false,
  });

  final String title;
  final String? text;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      text: TextSpan(
        text: title,
        style: isSmall
            ? Theme.of(context).textTheme.labelMedium
            : Theme.of(context).textTheme.titleSmall,
        children: [
          TextSpan(
            text: text ?? '',
            style: isSmall
                ? Theme.of(context).textTheme.labelMedium
                : Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class ProjectQrIcon extends StatelessWidget {
  const ProjectQrIcon({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Project QR code. Tap to view full.',
      child: GestureDetector(
        child: SizedBox(
          width: 96,
          height: 96,
          child: ProjectQrCodeViewer(data: data, isFullScreen: false),
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: ProjectQrCodeViewer(data: data, isFullScreen: true),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class ProjectQrCodeViewer extends StatelessWidget {
  const ProjectQrCodeViewer({
    super.key,
    required this.data,
    required this.isFullScreen,
  });

  final String data;
  final bool isFullScreen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullScreen ? 400 : 80,
      height: isFullScreen ? 400 : 80,
      child: ProjectQrCode(
        data: data,
        color: Colors.black,
        backgroundColor: Colors.white,
      ),
    );
  }
}

class ProjectQrCode extends StatelessWidget {
  const ProjectQrCode({
    super.key,
    required this.data,
    required this.color,
    required this.backgroundColor,
  });

  final Color? color;
  final Color? backgroundColor;
  final String data;

  @override
  Widget build(BuildContext context) {
    final background = backgroundColor ?? Colors.transparent;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: QrImageView(data: data, backgroundColor: background, color: color),
    );
  }
}
