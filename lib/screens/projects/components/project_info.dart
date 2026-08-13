import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/dialogs/project_exchange_dialogs.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/screens/shared/media/qr.dart';

class ProjectInfo extends StatelessWidget {
  const ProjectInfo({
    super.key,
    required this.projectData,
    this.onEdit,
    this.showExport = true,
    this.showActions = true,
    this.useSectionContainers = true,
  });

  final ProjectData? projectData;
  final VoidCallback? onEdit;
  final bool showExport;
  final bool showActions;
  final bool useSectionContainers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProjectInfoSection(
          title: 'Identity',
          useContainer: useSectionContainers,
          children: [
            Text(
              _displayValue(projectData?.name),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _ProjectInfoField(
              label: 'UUID',
              value: _displayValue(projectData?.uuid),
              isSelectable: true,
            ),
          ],
        ),
        _ProjectInfoSection(
          title: 'Description',
          useContainer: useSectionContainers,
          children: [
            Text(
              _displayValue(projectData?.description),
              softWrap: true,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        const SizedBox(height: 4),
        _ProjectInfoSection(
          title: 'Project details',
          useContainer: useSectionContainers,
          children: [
            _ProjectInfoField(
              label: 'Principal investigator',
              value: _displayValue(projectData?.principalInvestigator),
            ),
            _ProjectInfoField(
              label: 'Accession',
              value: _displayValue(projectData?.accession),
            ),
            _ProjectInfoField(
              label: 'Location',
              value: _displayValue(projectData?.location),
            ),
            _ProjectInfoField(
              label: 'Time zone',
              value: _displayValue(projectData?.timeZone),
            ),
          ],
        ),
        _ProjectInfoSection(
          title: 'Schedule',
          useContainer: useSectionContainers,
          children: [
            _ProjectInfoField(
              label: 'Start date',
              value: _displayValue(
                dateStdToDateDisplay(projectData?.startDate),
              ),
            ),
            _ProjectInfoField(
              label: 'End date',
              value: _displayValue(dateStdToDateDisplay(projectData?.endDate)),
            ),
          ],
        ),
        _ProjectInfoSection(
          title: 'Record metadata',
          useContainer: useSectionContainers,
          children: [
            _ProjectInfoField(
              label: 'Created',
              value: _parseDate(projectData?.created),
              isSmall: true,
            ),
            _ProjectInfoField(
              label: 'Last accessed',
              value: _parseDate(projectData?.lastAccessed),
              isSmall: true,
            ),
            if (showActions)
              ProjectInfoActions(
                projectData: projectData,
                onEdit: onEdit,
                showExport: showExport,
              ),
          ],
        ),
      ],
    );
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Not provided';
    }
    return value;
  }

  String _parseDate(String? date) {
    if (date == null || date.trim().isEmpty) {
      return 'Not provided';
    }
    final value = parseDate(date);
    return '${value.date} ${value.time}';
  }
}

class ProjectInfoActions extends StatelessWidget {
  const ProjectInfoActions({
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
    if (projectData == null || (onEdit == null && !showExport)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        children: [
          if (onEdit != null)
            TextButton(onPressed: onEdit, child: const Text('Edit')),
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
    );
  }
}

class _ProjectInfoSection extends StatelessWidget {
  const _ProjectInfoSection({
    required this.title,
    required this.children,
    required this.useContainer,
  });

  final String title;
  final List<Widget> children;
  final bool useContainer;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        ...children,
      ],
    );
    if (!useContainer) {
      return Padding(padding: const EdgeInsets.all(8), child: content);
    }

    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withAlpha(80),
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: content,
    );
  }
}

class _ProjectInfoField extends StatelessWidget {
  const _ProjectInfoField({
    required this.label,
    required this.value,
    this.isSelectable = false,
    this.isSmall = false,
  });

  final String label;
  final String value;
  final bool isSelectable;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final valueStyle = isSmall
        ? Theme.of(context).textTheme.bodySmall
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          if (isSelectable)
            SelectableText(value, style: valueStyle)
          else
            Text(value, softWrap: true, style: valueStyle),
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
