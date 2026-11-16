import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/analytics_charts.dart';
import 'package:nahpu/screens/projects/statistics/analytics_tables.dart';
import 'package:nahpu/screens/projects/statistics/searchable_statistic_filter.dart';
import 'package:nahpu/screens/projects/statistics/statistic_filter_panel.dart';
import 'package:nahpu/screens/projects/statistics/statistics_table.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/providers/analytics.dart';
import 'package:nahpu/services/providers/statistics.dart';
import 'package:nahpu/services/statistics/pca_export.dart';
import 'package:nahpu/services/types/analytics.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/statistics.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// The Analytics view of the record statistics page: a principal component
/// analysis of the measurements the user selects.
///
/// It covers one project, or every project when [projectUuid] is null.
class AnalyticsPanel extends ConsumerStatefulWidget {
  const AnalyticsPanel({
    super.key,
    required this.projectUuid,
    required this.projectName,
  });

  final String? projectUuid;

  /// Stem of the export file names.
  final String projectName;

  @override
  ConsumerState<AnalyticsPanel> createState() => _AnalyticsPanelState();
}

class _AnalyticsPanelState extends ConsumerState<AnalyticsPanel> {
  SpecimenRecordType? _taxonGroup;

  /// Variables the user picked, or null while the defaults apply.
  Set<AnalyticsVariable>? _picked;
  AnalyticsColorBy _colorBy = AnalyticsColorBy.species;
  PcaScalingMode _scaling = PcaScalingMode.correlation;
  bool _logTransform = false;
  StatisticFilterOption? _siteFilter;
  StatisticFilterOption? _speciesFilter;
  int _xComponent = 0;
  int _yComponent = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final projectUuid = widget.projectUuid;
    final groupsProvider = analyticsTaxonGroupsProvider(projectUuid);
    final groups = ref.watch(groupsProvider);
    final available = groups.value;
    if (available == null) {
      return groups.hasError
          ? _AnalyticsMessage(
              message: l10n.projectStatsLoadError('${groups.error}'),
              onRetry: () => ref.invalidate(groupsProvider),
            )
          : const _AnalyticsLoading();
    }
    if (available.isEmpty) {
      return _AnalyticsMessage(message: l10n.projectAnalyticsNoSpecimens);
    }

    final taxonGroup = available.contains(_taxonGroup)
        ? _taxonGroup!
        : available.first;
    final optionsProvider = analyticsVariableOptionsProvider((
      projectUuid: projectUuid,
      taxonGroup: taxonGroup,
    ));
    final options = ref.watch(optionsProvider);
    final selected = _selectedVariables(taxonGroup, options.value ?? const []);
    final siteOptions = statisticFilterOptionsProvider((
      projectUuid: projectUuid,
      kind: StatisticFilterKind.site,
    ));
    final speciesOptions = statisticFilterOptionsProvider((
      projectUuid: projectUuid,
      kind: StatisticFilterKind.species,
    ));
    final request = PcaRequest(
      projectUuid: projectUuid,
      taxonGroup: taxonGroup,
      variables: selected,
      scaling: _scaling,
      logTransform: _logTransform,
      siteId: _siteFilter?.id,
      speciesId: _speciesFilter?.id,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatisticFilterPanel(
          section: Text(
            l10n.projectAnalyticsPcaTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          selector: Tooltip(
            message: l10n.projectAnalyticsScalingHelp,
            child: SegmentedButton<PcaScalingMode>(
              key: const ValueKey('analytics-scaling-control'),
              showSelectedIcon: false,
              segments: [
                for (final mode in PcaScalingMode.values)
                  ButtonSegment(
                    value: mode,
                    label: Text(mode.localizedLabel(l10n)),
                  ),
              ],
              selected: {_scaling},
              onSelectionChanged: (selection) {
                setState(() => _scaling = selection.single);
              },
            ),
          ),
          fields: [
            StatisticDropdownField<SpecimenRecordType>(
              key: ValueKey('analytics-taxon-group-control-$taxonGroup'),
              label: l10n.projectAnalyticsTaxonGroup,
              values: available,
              selected: taxonGroup,
              valueLabel: (value) => value.localizedLabel(l10n),
              onSelected: _selectTaxonGroup,
            ),
            StatisticDropdownField<AnalyticsColorBy>(
              key: const ValueKey('analytics-color-control'),
              label: l10n.projectAnalyticsColorBy,
              values: [
                for (final value in AnalyticsColorBy.values)
                  if (value != AnalyticsColorBy.project || projectUuid == null)
                    value,
              ],
              selected: _colorBy,
              valueLabel: (value) => value.localizedLabel(l10n),
              onSelected: (value) => setState(() => _colorBy = value),
            ),
            SearchableStatisticFilterPicker(
              options: ref.watch(siteOptions),
              selected: _siteFilter,
              label: l10n.projectStatsSite,
              title: l10n.projectStatsSelectSite,
              placeholder: l10n.projectStatsAllSites,
              onChanged: (value) => setState(() => _siteFilter = value),
              onRetry: () => ref.invalidate(siteOptions),
            ),
            SearchableStatisticFilterPicker(
              options: ref.watch(speciesOptions),
              selected: _speciesFilter,
              label: l10n.projectTaxonSpecies,
              title: l10n.projectStatsSelectSpecies,
              placeholder: l10n.projectStatsAllSpecies,
              onChanged: (value) => setState(() => _speciesFilter = value),
              onRetry: () => ref.invalidate(speciesOptions),
            ),
          ],
          footer: options.when(
            data: (items) => _VariablePicker(
              options: items,
              selected: selected.toSet(),
              logTransform: _logTransform,
              onToggle: (variable) => _toggleVariable(variable, selected),
              onSelectAll: () => setState(() {
                _picked = {
                  for (final item in items)
                    if (item.count > 0) item.variable,
                };
              }),
              onClear: () => setState(() => _picked = {}),
              onLogTransformChanged: (value) {
                setState(() => _logTransform = value);
              },
            ),
            loading: () => const _AnalyticsLoading(),
            error: (error, _) => _AnalyticsMessage(
              message: l10n.projectStatsLoadError('$error'),
              onRetry: () => ref.invalidate(optionsProvider),
            ),
          ),
        ),
        const SizedBox(height: NahpuSpacing.xl),
        if (selected.length < pcaMinVariables)
          _AnalyticsMessage(
            key: const ValueKey('analytics-select-variables'),
            message: options.hasValue && !_hasMeasurements(options.value!)
                ? l10n.projectAnalyticsNoMeasurements
                : l10n.projectAnalyticsSelectVariables,
          )
        else
          ref
              .watch(pcaResultProvider(request))
              .when(
                data: (result) => _PcaResultView(
                  result: result,
                  colorBy: _colorBy,
                  xComponent: _xComponent.clamp(0, result.componentCount - 1),
                  yComponent: _yComponent.clamp(0, result.componentCount - 1),
                  projectName: widget.projectName,
                  onXChanged: (value) => setState(() => _xComponent = value),
                  onYChanged: (value) => setState(() => _yComponent = value),
                ),
                loading: () => const _AnalyticsLoading(),
                error: (error, _) => error is PcaFailure
                    ? _AnalyticsMessage(
                        key: const ValueKey('analytics-failure'),
                        message: error.localizedMessage(l10n),
                      )
                    : _AnalyticsMessage(
                        message: l10n.projectAnalyticsError('$error'),
                        onRetry: () =>
                            ref.invalidate(pcaResultProvider(request)),
                      ),
              ),
      ],
    );
  }

  /// The variables to analyze, in picker order: the user's picks that still
  /// have data, or the group's default body measurements before any pick.
  List<AnalyticsVariable> _selectedVariables(
    SpecimenRecordType taxonGroup,
    List<AnalyticsVariableOption> options,
  ) {
    final picked = _picked;
    final defaults = MeasurementTable.of(taxonGroup)?.defaults ?? const {};
    return [
      for (final option in options)
        if (option.count > 0 &&
            (picked?.contains(option.variable) ??
                defaults.contains(option.variable.column)))
          option.variable,
    ];
  }

  bool _hasMeasurements(List<AnalyticsVariableOption> options) =>
      options.where((option) => option.count > 0).length >= pcaMinVariables;

  void _selectTaxonGroup(SpecimenRecordType value) {
    setState(() {
      _taxonGroup = value;
      // Each group has its own measurements, so the picks start over.
      _picked = null;
      _xComponent = 0;
      _yComponent = 1;
    });
  }

  void _toggleVariable(
    AnalyticsVariable variable,
    List<AnalyticsVariable> selected,
  ) {
    setState(() {
      final next = selected.toSet();
      if (!next.remove(variable)) next.add(variable);
      _picked = next;
    });
  }
}

/// Chips for choosing the variables of an analysis, with the log option.
class _VariablePicker extends StatelessWidget {
  const _VariablePicker({
    required this.options,
    required this.selected,
    required this.logTransform,
    required this.onToggle,
    required this.onSelectAll,
    required this.onClear,
    required this.onLogTransformChanged,
  });

  final List<AnalyticsVariableOption> options;
  final Set<AnalyticsVariable> selected;
  final bool logTransform;
  final ValueChanged<AnalyticsVariable> onToggle;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final ValueChanged<bool> onLogTransformChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: NahpuSpacing.lg,
          children: [
            Text(
              l10n.projectAnalyticsVariables,
              style: theme.textTheme.titleSmall,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  key: const ValueKey('analytics-select-all'),
                  onPressed: onSelectAll,
                  child: Text(l10n.commonSelectAll),
                ),
                TextButton(
                  key: const ValueKey('analytics-clear'),
                  onPressed: selected.isEmpty ? null : onClear,
                  child: Text(l10n.commonClear),
                ),
              ],
            ),
          ],
        ),
        Text(
          l10n.projectAnalyticsVariablesHelp,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        Wrap(
          spacing: NahpuSpacing.md,
          runSpacing: NahpuSpacing.md,
          children: [
            for (final option in options)
              FilterChip(
                key: ValueKey('analytics-variable-${option.variable.id}'),
                label: Text(
                  l10n.projectAnalyticsVariableCount(
                    option.variable.localizedLabel(l10n),
                    option.count,
                  ),
                ),
                selected: selected.contains(option.variable),
                // A variable no record has a value for cannot be analyzed.
                onSelected: option.count > 0
                    ? (_) => onToggle(option.variable)
                    : null,
              ),
          ],
        ),
        const SizedBox(height: NahpuSpacing.md),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilterChip(
            key: const ValueKey('analytics-log-transform'),
            avatar: const Icon(Icons.functions_rounded),
            label: Text(l10n.projectAnalyticsLogTransform),
            selected: logTransform,
            showCheckmark: false,
            onSelected: onLogTransformChanged,
          ),
        ),
      ],
    );
  }
}

/// Plots and tables of a finished analysis.
class _PcaResultView extends StatelessWidget {
  const _PcaResultView({
    required this.result,
    required this.colorBy,
    required this.xComponent,
    required this.yComponent,
    required this.projectName,
    required this.onXChanged,
    required this.onYChanged,
  });

  final PcaAnalysisResult result;
  final AnalyticsColorBy colorBy;
  final int xComponent;
  final int yComponent;
  final String projectName;
  final ValueChanged<int> onXChanged;
  final ValueChanged<int> onYChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final export = PcaExportBuilder(result);
    final scree = _AnalyticsCard(
      title: l10n.projectAnalyticsScree,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PcaScreeChart(result: result),
          const SizedBox(height: NahpuSpacing.md),
          PcaVarianceTable(result: result),
        ],
      ),
    );
    final loadings = _LoadingsCard(
      result: result,
      initialComponent: xComponent,
      onExport: () => showTabularExportDialog(
        context: context,
        title: l10n.projectAnalyticsExportLoadings,
        defaultFileName: '${projectName}_pca-loadings',
        headers: export.loadings().headers,
        rows: export.loadings().rows,
      ),
    );
    return Column(
      key: const ValueKey('analytics-results'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.xs),
          child: PcaMetricStrip(
            result: result,
            xComponent: xComponent,
            yComponent: yComponent,
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        _AnalyticsCard(
          title: l10n.projectAnalyticsScores,
          action: IconButton(
            key: const ValueKey('analytics-export-scores'),
            tooltip: l10n.projectAnalyticsExportScores,
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: () => showTabularExportDialog(
              context: context,
              title: l10n.projectAnalyticsExportScores,
              defaultFileName: '${projectName}_pca-scores',
              headers: export.scores().headers,
              rows: export.scores().rows,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: NahpuSpacing.lg,
                runSpacing: NahpuSpacing.lg,
                children: [
                  _ComponentDropdown(
                    key: ValueKey('analytics-x-axis-$xComponent'),
                    label: l10n.projectAnalyticsHorizontalAxis,
                    result: result,
                    selected: xComponent,
                    onSelected: onXChanged,
                  ),
                  _ComponentDropdown(
                    key: ValueKey('analytics-y-axis-$yComponent'),
                    label: l10n.projectAnalyticsVerticalAxis,
                    result: result,
                    selected: yComponent,
                    onSelected: onYChanged,
                  ),
                ],
              ),
              const SizedBox(height: NahpuSpacing.lg),
              PcaScoreScatterChart(
                result: result,
                xComponent: xComponent,
                yComponent: yComponent,
                colorBy: colorBy,
              ),
            ],
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < NahpuBreakpoints.desktop) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  scree,
                  const SizedBox(height: NahpuSpacing.lg),
                  loadings,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: scree),
                const SizedBox(width: NahpuSpacing.lg),
                Expanded(child: loadings),
              ],
            );
          },
        ),
        const SizedBox(height: NahpuSpacing.lg),
        _AnalyticsCard(
          title: l10n.projectAnalyticsSummary,
          action: IconButton(
            key: const ValueKey('analytics-export-summary'),
            tooltip: l10n.projectAnalyticsExportSummary,
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: () => showTabularExportDialog(
              context: context,
              title: l10n.projectAnalyticsExportSummary,
              defaultFileName: '${projectName}_measurement-summary',
              headers: export.summary().headers,
              rows: export.summary().rows,
            ),
          ),
          child: PcaSummaryTable(result: result),
        ),
      ],
    );
  }
}

/// Loadings of one component, which the user picks.
class _LoadingsCard extends StatefulWidget {
  const _LoadingsCard({
    required this.result,
    required this.initialComponent,
    required this.onExport,
  });

  final PcaAnalysisResult result;
  final int initialComponent;
  final VoidCallback onExport;

  @override
  State<_LoadingsCard> createState() => _LoadingsCardState();
}

class _LoadingsCardState extends State<_LoadingsCard> {
  late int _component = widget.initialComponent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final component = _component.clamp(0, widget.result.componentCount - 1);
    return _AnalyticsCard(
      title: l10n.projectAnalyticsLoadings,
      action: IconButton(
        key: const ValueKey('analytics-export-loadings'),
        tooltip: l10n.projectAnalyticsExportLoadings,
        icon: const Icon(Icons.file_upload_outlined),
        onPressed: widget.onExport,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _ComponentDropdown(
              key: ValueKey('analytics-loadings-component-$component'),
              label: l10n.projectAnalyticsLoadingsOf,
              result: widget.result,
              selected: component,
              onSelected: (value) => setState(() => _component = value),
            ),
          ),
          const SizedBox(height: NahpuSpacing.lg),
          PcaLoadingsChart(result: widget.result, component: component),
        ],
      ),
    );
  }
}

/// Picker of one principal component, labelled with its share of variance.
class _ComponentDropdown extends StatelessWidget {
  const _ComponentDropdown({
    super.key,
    required this.label,
    required this.result,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final PcaAnalysisResult result;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: NahpuContentWidth.statisticsOptions,
      child: StatisticDropdownField<int>(
        label: label,
        values: [
          for (var index = 0; index < result.componentCount; index++) index,
        ],
        selected: selected,
        valueLabel: (value) => context.l10n.projectAnalyticsComponentVariance(
          value + 1,
          (result.explainedVariance[value] * 100).toStringAsFixed(1),
        ),
        onSelected: onSelected,
      ),
    );
  }
}

/// A titled result card with an optional action beside the title.
class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ?action,
              ],
            ),
            const SizedBox(height: NahpuSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

/// A centered note for an empty, failed, or not-yet-configured analysis.
class _AnalyticsMessage extends StatelessWidget {
  const _AnalyticsMessage({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NahpuSpacing.xl,
        vertical: NahpuSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.scatter_plot_outlined,
            size: NahpuControlSize.iconLarge,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: NahpuSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: NahpuSpacing.md),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.commonRetry),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnalyticsLoading extends StatelessWidget {
  const _AnalyticsLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(NahpuSpacing.xxxl),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
