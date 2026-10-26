import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/dialogs/project_exchange_dialogs.dart';
import 'package:nahpu/screens/shared/dialogs/qr_code_dialog.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/styles/design_tokens.dart';

class ProjectInfo extends StatelessWidget {
  const ProjectInfo({
    super.key,
    required this.projectData,
    this.onEdit,
    this.showExport = true,
    this.showActions = true,
    this.useSectionContainers = true,
    this.qrData,
    this.useHorizontalQrLayout = false,
  });

  final ProjectData? projectData;
  final VoidCallback? onEdit;
  final bool showExport;
  final bool showActions;
  final bool useSectionContainers;
  final String? qrData;
  final bool useHorizontalQrLayout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final projectQrData = qrData;
    final showQrBesideIdentity = projectQrData != null && useHorizontalQrLayout;
    final identitySection = _ProjectInfoSection(
      title: l10n.projectIdentity,
      useContainer: useSectionContainers,
      children: [_ProjectIdentityDetails(projectData: projectData)],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (projectQrData != null && !useHorizontalQrLayout)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Center(child: ProjectQrIcon(data: projectQrData)),
          ),
        if (showQrBesideIdentity)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: identitySection),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: NahpuSpacing.md),
                child: ProjectQrIcon(data: projectQrData),
              ),
            ],
          )
        else
          identitySection,
        _ProjectInfoSection(
          title: l10n.projectDescription,
          useContainer: useSectionContainers,
          children: [
            Text(
              _displayValue(l10n, projectData?.description),
              softWrap: true,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        const SizedBox(height: 4),
        _ProjectInfoSection(
          title: l10n.projectDetails,
          useContainer: useSectionContainers,
          children: [
            _ProjectInfoField(
              label: l10n.projectPrincipalInvestigator,
              value: _displayValue(l10n, projectData?.principalInvestigator),
            ),
            _ProjectInfoField(
              label: l10n.projectAccession,
              value: _displayValue(l10n, projectData?.accession),
            ),
            _ProjectInfoField(
              label: l10n.projectLocation,
              value: _displayValue(l10n, projectData?.location),
            ),
            _ProjectInfoField(
              label: l10n.projectTimeZone,
              value: _displayValue(l10n, projectData?.timeZone),
            ),
          ],
        ),
        _ProjectInfoSection(
          title: l10n.projectSchedule,
          useContainer: useSectionContainers,
          children: [
            _ProjectInfoField(
              label: l10n.projectStartDate,
              value: _displayValue(
                l10n,
                dateStdToDateDisplay(projectData?.startDate),
              ),
            ),
            _ProjectInfoField(
              label: l10n.projectEndDate,
              value: _displayValue(
                l10n,
                dateStdToDateDisplay(projectData?.endDate),
              ),
            ),
          ],
        ),
        _ProjectInfoSection(
          title: l10n.projectRecordMetadata,
          useContainer: useSectionContainers,
          children: [
            _ProjectInfoField(
              label: l10n.projectCreated,
              value: _parseDate(l10n, projectData?.created),
              isSmall: true,
            ),
            _ProjectInfoField(
              label: l10n.projectLastAccessed,
              value: _parseDate(l10n, projectData?.lastAccessed),
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

  String _displayValue(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.projectNotProvided;
    }
    return value;
  }

  String _parseDate(AppLocalizations l10n, String? date) {
    if (date == null || date.trim().isEmpty) {
      return l10n.projectNotProvided;
    }
    final value = parseDate(date);
    return '${value.date} ${value.time}';
  }
}

class _ProjectIdentityDetails extends StatelessWidget {
  const _ProjectIdentityDetails({required this.projectData});

  final ProjectData? projectData;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _displayValue(l10n, projectData?.name),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _ProjectInfoField(
          label: l10n.projectUuid,
          value: _displayValue(l10n, projectData?.uuid),
          isSelectable: true,
        ),
      ],
    );
  }

  String _displayValue(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.projectNotProvided;
    }
    return value;
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
            TextButton(onPressed: onEdit, child: Text(context.l10n.commonEdit)),
          if (showExport)
            TextButton(
              onPressed: () => showProjectExportDialog(
                context: context,
                projectData: projectData!,
              ),
              child: Text(context.l10n.homeProjectExportInfo),
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
      message: context.l10n.projectQrTooltip,
      child: GestureDetector(
        child: SizedBox(
          width: 112,
          height: 112,
          child: RepaintBoundary(child: QrCodeViewer(data: data, maxSize: 112)),
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => QrCodeDialog(
              title: context.l10n.homeProjectQrCode,
              data: data,
              description: context.l10n.homeProjectQrDescription,
            ),
          );
        },
      ),
    );
  }
}
