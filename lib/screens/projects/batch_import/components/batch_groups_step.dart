import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/batch_import/components/batch_group_dialogs.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/screens/shared/layout/wizard.dart';
import 'package:nahpu/services/data_table/data_table_link_service.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/import/batch/batch_linked_models.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';

typedef BatchLinkOptions =
    Future<List<DataTableLinkOption>> Function(DataTableLink link);

enum BatchGroupsView { sites, events, specimens }

/// A linked import's groups step: the sites, events, and specimens the
/// rows make, with ways to link, rename, merge, split, or leave them out.
class BatchGroupsStep extends StatefulWidget {
  const BatchGroupsStep({
    super.key,
    required this.plan,
    required this.onChanged,
    required this.linkOptions,
  });

  final BatchLinkedPlan plan;
  final ValueChanged<BatchLinkedPlan> onChanged;
  final BatchLinkOptions linkOptions;

  @override
  State<BatchGroupsStep> createState() => _BatchGroupsStepState();
}

class _BatchGroupsStepState extends State<BatchGroupsStep> {
  BatchGroupsView _view = BatchGroupsView.sites;

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuStepHeading(
          title: context.l10n.projectBatchCheckGroups,
          message: context.l10n.projectBatchCheckGroupsBody,
        ),
        const SizedBox(height: NahpuSpacing.xl),
        SegmentedButton<BatchGroupsView>(
          segments: [
            ButtonSegment(
              value: BatchGroupsView.sites,
              label: Text(
                context.l10n.projectBatchSitesCount(plan.sites.length),
              ),
            ),
            ButtonSegment(
              value: BatchGroupsView.events,
              label: Text(
                context.l10n.projectBatchEventsCount(plan.events.length),
              ),
            ),
            ButtonSegment(
              value: BatchGroupsView.specimens,
              label: Text(
                context.l10n.projectBatchSpecimensCount(plan.specimens.length),
              ),
            ),
          ],
          selected: {_view},
          onSelectionChanged: (selection) =>
              setState(() => _view = selection.single),
        ),
        const SizedBox(height: NahpuSpacing.xl),
        switch (_view) {
          BatchGroupsView.sites => BatchGroupList(
            empty: context.l10n.projectBatchNoSiteColumns,
            children: [
              for (final site in plan.sites)
                BatchSiteGroupCard(
                  plan: plan,
                  site: site,
                  onChanged: widget.onChanged,
                  linkOptions: widget.linkOptions,
                ),
            ],
          ),
          BatchGroupsView.events => BatchGroupList(
            empty: context.l10n.projectBatchNoEventColumns,
            children: [
              for (final event in plan.events)
                BatchEventGroupCard(
                  plan: plan,
                  event: event,
                  onChanged: widget.onChanged,
                  linkOptions: widget.linkOptions,
                ),
            ],
          ),
          BatchGroupsView.specimens => BatchGroupList(
            empty: context.l10n.projectBatchNoSpecimenColumns,
            children: [
              for (final specimen in plan.specimens)
                BatchSpecimenCard(
                  plan: plan,
                  specimen: specimen,
                  onChanged: widget.onChanged,
                ),
            ],
          ),
        },
      ],
    );
  }
}

class BatchGroupList extends StatelessWidget {
  const BatchGroupList({
    super.key,
    required this.empty,
    required this.children,
  });

  final String empty;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return NahpuPanel(child: Text(empty));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final child in children) ...[
          child,
          const SizedBox(height: NahpuSpacing.md),
        ],
      ],
    );
  }
}

/// Actions a group card's menu offers.
enum BatchGroupMenuAction { link, create, rename, merge, split }

class BatchSiteGroupCard extends StatelessWidget {
  const BatchSiteGroupCard({
    super.key,
    required this.plan,
    required this.site,
    required this.onChanged,
    required this.linkOptions,
  });

  final BatchLinkedPlan plan;
  final BatchSiteGroup site;
  final ValueChanged<BatchLinkedPlan> onChanged;
  final BatchLinkOptions linkOptions;

  @override
  Widget build(BuildContext context) {
    final linked = site.action == BatchGroupAction.linkExisting;
    final lat = site.coordinate['coordinate::decimalLatitude'];
    final lon = site.coordinate['coordinate::decimalLongitude'];
    return BatchGroupCard(
      title: linked
          ? site.existingLabel!
          : site.siteName ?? context.l10n.projectBatchNewSite,
      linked: linked,
      inactive: !plan.isActive(site.rows),
      details: [
        [
          site.values['geography::specificLocality'],
          site.values['geography::stateProvince'],
          site.values['geography::country'],
        ].whereType<String>().join(', '),
        if (lat != null && lon != null) '$lat, $lon',
        '${_rowsLabel(context.l10n, plan, site.rows)} · '
            '${context.l10n.projectBatchEventCount(plan.eventsAt(site.id).length)}',
      ],
      warnings: [...site.problems, ...site.conflicts],
      actions: [
        BatchGroupMenuAction.link,
        if (linked)
          BatchGroupMenuAction.create
        else
          BatchGroupMenuAction.rename,
        BatchGroupMenuAction.merge,
        if (site.rows.length > 1) BatchGroupMenuAction.split,
      ],
      renameLabel: context.l10n.projectBatchSetSiteId,
      onAction: (action) => _act(context, action),
    );
  }

  Future<void> _act(BuildContext context, BatchGroupMenuAction action) async {
    switch (action) {
      case BatchGroupMenuAction.link:
        final option = await showDialog<DataTableLinkOption>(
          context: context,
          builder: (_) => BatchLinkExistingDialog(
            title: context.l10n.projectBatchLinkSite,
            options: linkOptions(DataTableLink.site),
          ),
        );
        if (option != null) {
          onChanged(plan.linkSite(site.id, option.id! as int, option.label));
        }
      case BatchGroupMenuAction.create:
        onChanged(plan.createSite(site.id));
      case BatchGroupMenuAction.rename:
        final name = await showDialog<String>(
          context: context,
          builder: (_) => BatchRenameGroupDialog(
            title: context.l10n.projectBatchSetSiteId,
            label: context.l10n.projectBatchKeySiteId,
            initialValue: site.siteName ?? '',
          ),
        );
        if (name != null) onChanged(plan.renameSite(site.id, name));
      case BatchGroupMenuAction.merge:
        final into = await showDialog<String>(
          context: context,
          builder: (_) => BatchMergeGroupDialog(
            title: context.l10n.projectBatchMergeIntoSite,
            groups: [
              for (final other in plan.sites)
                if (other.id != site.id)
                  (
                    other.id,
                    other.label,
                    _rowsLabel(context.l10n, plan, other.rows),
                  ),
            ],
          ),
        );
        if (into != null) onChanged(plan.mergeSites(site.id, into));
      case BatchGroupMenuAction.split:
        final rows = await showDialog<Set<int>>(
          context: context,
          builder: (_) => BatchSplitGroupDialog(
            title: context.l10n.projectBatchMoveRowsToSite,
            rows: [
              for (final row in site.rows)
                (row, context.l10n.projectBatchRow('${plan.rowNumbers[row]}')),
            ],
          ),
        );
        if (rows != null) onChanged(plan.splitSite(site.id, rows));
    }
  }
}

class BatchEventGroupCard extends StatelessWidget {
  const BatchEventGroupCard({
    super.key,
    required this.plan,
    required this.event,
    required this.onChanged,
    required this.linkOptions,
  });

  final BatchLinkedPlan plan;
  final BatchEventGroup event;
  final ValueChanged<BatchLinkedPlan> onChanged;
  final BatchLinkOptions linkOptions;

  @override
  Widget build(BuildContext context) {
    final linked = event.action == BatchGroupAction.linkExisting;
    final site = plan.site(event.siteGroupId);
    final specimens = plan.specimens
        .where((s) => s.eventGroupId == event.id)
        .length;
    final suffix = event.idSuffix;
    return BatchGroupCard(
      title: linked
          ? event.existingLabel!
          : [
              site?.label ?? context.l10n.projectBatchNoSite,
              if (event.startDate.isNotEmpty) event.startDate,
              ?suffix,
            ].join(' · '),
      linked: linked,
      inactive: !plan.isActive(event.rows),
      details: [
        if (event.method.isNotEmpty) event.method,
        '${_rowsLabel(context.l10n, plan, event.rows)} · '
            '${context.l10n.projectBatchSpecimenCount(specimens)}',
      ],
      warnings: [...event.problems, ...event.conflicts],
      actions: [
        BatchGroupMenuAction.link,
        if (linked)
          BatchGroupMenuAction.create
        else
          BatchGroupMenuAction.rename,
        BatchGroupMenuAction.merge,
        if (event.rows.length > 1) BatchGroupMenuAction.split,
      ],
      renameLabel: context.l10n.projectBatchSetIdSuffix,
      onAction: (action) => _act(context, action),
    );
  }

  Future<void> _act(BuildContext context, BatchGroupMenuAction action) async {
    switch (action) {
      case BatchGroupMenuAction.link:
        final option = await showDialog<DataTableLinkOption>(
          context: context,
          builder: (_) => BatchLinkExistingDialog(
            title: context.l10n.projectBatchLinkEvent,
            options: linkOptions(DataTableLink.event),
          ),
        );
        if (option != null) {
          onChanged(plan.linkEvent(event.id, option.id! as int, option.label));
        }
      case BatchGroupMenuAction.create:
        onChanged(plan.createEvent(event.id));
      case BatchGroupMenuAction.rename:
        final suffix = await showDialog<String>(
          context: context,
          builder: (_) => BatchRenameGroupDialog(
            title: context.l10n.projectBatchSetEventIdSuffix,
            label: context.l10n.recordsSpecimenSuffix,
            initialValue: event.idSuffix ?? '',
          ),
        );
        if (suffix != null) onChanged(plan.renameEvent(event.id, suffix));
      case BatchGroupMenuAction.merge:
        final into = await showDialog<String>(
          context: context,
          builder: (_) => BatchMergeGroupDialog(
            title: context.l10n.projectBatchMergeIntoEvent,
            groups: [
              for (final other in plan.events)
                if (other.id != event.id)
                  (
                    other.id,
                    [
                      plan.site(other.siteGroupId)?.label ??
                          context.l10n.projectBatchNoSite,
                      if (other.startDate.isNotEmpty) other.startDate,
                    ].join(' · '),
                    _rowsLabel(context.l10n, plan, other.rows),
                  ),
            ],
          ),
        );
        if (into != null) onChanged(plan.mergeEvents(event.id, into));
      case BatchGroupMenuAction.split:
        final rows = await showDialog<Set<int>>(
          context: context,
          builder: (_) => BatchSplitGroupDialog(
            title: context.l10n.projectBatchMoveRowsToEvent,
            rows: [
              for (final row in event.rows)
                (row, context.l10n.projectBatchRow('${plan.rowNumbers[row]}')),
            ],
          ),
        );
        if (rows != null) onChanged(plan.splitEvent(event.id, rows));
    }
  }
}

class BatchSpecimenCard extends StatelessWidget {
  const BatchSpecimenCard({
    super.key,
    required this.plan,
    required this.specimen,
    required this.onChanged,
  });

  final BatchLinkedPlan plan;
  final BatchLinkedSpecimen specimen;
  final ValueChanged<BatchLinkedPlan> onChanged;

  @override
  Widget build(BuildContext context) {
    final included = plan.isActive(specimen.rows);
    final event = plan.event(specimen.eventGroupId);
    final status = specimen.plan.status;
    final colors = Theme.of(context).colorScheme;
    return NahpuPanel(
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_rowsLabel(context.l10n, plan, specimen.rows)} · '
                  '${status.localizedLabel(context.l10n)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: status.isImportable ? null : colors.error,
                  ),
                ),
                const SizedBox(height: NahpuSpacing.xs),
                Text(
                  [
                    event == null
                        ? context.l10n.projectBatchNoEvent
                        : context.l10n.projectBatchEventLabel(
                            event.existingLabel ?? event.startDate,
                          ),
                    context.l10n.projectBatchPartCount(specimen.parts.length),
                    if (specimen.parasites.isNotEmpty)
                      context.l10n.projectBatchParasiteCount(
                        specimen.parasites.length,
                      ),
                  ].join(' · '),
                ),
                for (final message in [
                  ...specimen.plan.messages,
                  for (final part in specimen.parts) ...part.plan.messages,
                  for (final parasite in specimen.parasites)
                    ...parasite.plan.messages,
                ])
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: included,
            onChanged: (value) {
              var next = plan;
              for (final row in specimen.rows) {
                next = value ? next.includeRow(row) : next.excludeRow(row);
              }
              onChanged(next);
            },
          ),
        ],
      ),
    );
  }
}

/// The frame of a site or event card: title, status, details, warnings,
/// and its menu.
class BatchGroupCard extends StatelessWidget {
  const BatchGroupCard({
    super.key,
    required this.title,
    required this.linked,
    required this.inactive,
    required this.details,
    required this.warnings,
    required this.actions,
    required this.renameLabel,
    required this.onAction,
  });

  final String title;
  final bool linked;

  /// Every row of the group is excluded.
  final bool inactive;
  final List<String> details;
  final List<String> warnings;
  final List<BatchGroupMenuAction> actions;
  final String renameLabel;
  final ValueChanged<BatchGroupMenuAction> onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final (chip, chipColor) = inactive
        ? (l10n.projectBatchExcluded, colors.outline)
        : warnings.isNotEmpty
        ? (l10n.projectBatchCheck, colors.error)
        : linked
        ? (l10n.projectBatchLinksToExisting, colors.primary)
        : (l10n.projectTransferStatusNew, colors.tertiary);
    return NahpuPanel(
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: NahpuSpacing.md,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    Text(
                      chip,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: chipColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NahpuSpacing.xs),
                for (final detail in details)
                  if (detail.isNotEmpty) Text(detail),
                for (final warning in warnings)
                  Text(
                    warning,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.error,
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<BatchGroupMenuAction>(
            tooltip: l10n.projectBatchChangeGroup,
            onSelected: onAction,
            itemBuilder: (context) => [
              for (final action in actions)
                PopupMenuItem(
                  value: action,
                  child: Text(switch (action) {
                    BatchGroupMenuAction.link => l10n.projectBatchLinkExisting,
                    BatchGroupMenuAction.create => l10n.projectBatchCreateNew,
                    BatchGroupMenuAction.rename => '$renameLabel…',
                    BatchGroupMenuAction.merge => l10n.projectBatchMergeInto,
                    BatchGroupMenuAction.split => l10n.projectBatchSplitRows,
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Rows 2, 3, 7" in file row numbers, shortened past a few.
String _rowsLabel(AppLocalizations l10n, BatchLinkedPlan plan, List<int> rows) {
  final numbers = [for (final row in rows) plan.rowNumbers[row]];
  if (numbers.length == 1) return l10n.projectBatchRow('${numbers.single}');
  final shown = numbers.take(4).join(', ');
  return numbers.length > 4
      ? l10n.projectBatchRowsMore(numbers.length - 4, shown)
      : l10n.projectBatchRows(shown);
}
