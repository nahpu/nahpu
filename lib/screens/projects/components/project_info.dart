import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProjectInfo extends ConsumerWidget {
  const ProjectInfo({super.key, required this.projectData});

  final ProjectData? projectData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ProjectQrIcon(data: _getProjectJson(projectData)),
        const SizedBox(height: 4),
        ProjectInfoText(
          title: 'Project name: ',
          text: projectData?.name,
        ),
        ProjectInfoText(title: 'UUID: ', text: projectData?.uuid),
        ProjectInfoText(
            title: 'Project description: ', text: projectData?.description),
        ProjectInfoText(
          title: 'Principal investigator: ',
          text: projectData?.principalInvestigator,
        ),
        ProjectInfoText(
          title: 'Location: ',
          text: projectData?.location,
        ),
        ProjectInfoText(
          title: 'Time zone: ',
          text: projectData?.timeZone,
        ),        
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
      ],
    );
  }

  String _parseDate(String? date) {
    final value = parseDate(date);
    return '${value.date} ${value.time}';
  }

  String _getProjectJson(ProjectData? projectData) {
    final data = projectData?.toJson();
    return data != null ? jsonEncode(data) : '';
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
          )
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
          child: ProjectQrCodeViewer(
            data: data,
            isFullScreen: false,
          ),
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: ProjectQrCodeViewer(
                  data: data,
                  isFullScreen: true,
                ),
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
    return Container(
      width: isFullScreen ? 400 : 80,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ProjectQrCode(
        data: data,
        color: Colors.black,
        backgroundColor: Colors.transparent,
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
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      backgroundColor: backgroundColor ?? Colors.transparent,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.circle,
        color: color,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.circle,
        color: color,
      ),
    );
  }
}
