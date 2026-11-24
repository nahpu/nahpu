import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/analytics_charts.dart';
import 'package:nahpu/screens/projects/statistics/analytics_tables.dart';
import 'package:nahpu/screens/projects/statistics/searchable_statistic_filter.dart';
import 'package:nahpu/screens/projects/statistics/statistic_filter_panel.dart';
import 'package:nahpu/screens/projects/statistics/statistic_metric_strip.dart';
import 'package:nahpu/screens/projects/statistics/statistics_table.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/providers/analytics.dart';
import 'package:nahpu/services/providers/statistics.dart';
import 'package:nahpu/services/statistics/pca_export.dart';
import 'package:nahpu/services/statistics/scatter_service.dart';
import 'package:nahpu/services/types/analytics.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/statistics.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Height of the main plot, which also holds its loading and empty states so
/// the card keeps one size across selections.
const double _plotHeight = 440;

/// Body height of the scree and loadings cards, equal so they line up side
/// by side.
const double _detailBodyHeight = 320;

/// The Analytics view of the record statistics page: a principal component
/// analysis of the measurements the user selects, or a scatter plot of one
/// measurement against another.
///
/// It covers one project, or every project when [projectUuid] is null. The
/// layout follows Explore: a tinted option panel above the result cards.
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
  AnalyticsMethod _method = AnalyticsMethod.pca;
  SpecimenRecordType? _taxonGroup;

  /// Variables the user picked, or null while the defaults apply.
  Set<AnalyticsVariable>? _picked;
  AnalyticsColorBy _colorBy = AnalyticsColorBy.species;
  PcaScalingMode _scaling = PcaScalingMode.correlation;
  bool _logTransform = false;
  Set<int> _siteIds = const {};
  AnalyticsTaxonFilterRank _taxonRank = AnalyticsTaxonFilterRank.species;
  Set<int> _taxonIds = const {};
  int _xComponent = 0;
  int _yComponent = 1;

  /// Scatter plot variables the user picked, or null for the defaults.
  AnalyticsVariable? _scatterX;
  AnalyticsVariable? _scatterY;

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
    final usable = [
      for (final option in options.value ?? const <AnalyticsVariableOption>[])
        if (option.count > 0) option.variable,
    ];
    final selected = _selectedVariables(taxonGroup, options.value ?? const []);
    final siteOptions = statisticFilterOptionsProvider((
      projectUuid: projectUuid,
      kind: StatisticFilterKind.site,
    ));
    final taxonOptions = statisticFilterOptionsProvider((
      projectUuid: projectUuid,
      kind: _taxonRank.filterKind,
    ));
    final isPca = _method == AnalyticsMethod.pca;

    // The PCA result labels the component pickers with their variance.
    final pcaRequest = PcaRequest(
      projectUuid: projectUuid,
      taxonGroup: taxonGroup,
      variables: selected,
      scaling: _scaling,
      logTransform: _logTransform,
      siteIds: _siteIds,
      taxonRank: _taxonRank,
      taxonIds: _taxonIds,
    );
    final canRunPca = isPca && selected.length >= pcaMinVariables;
    final pcaResult = canRunPca
        ? ref.watch(pcaResultProvider(pcaRequest))
        : null;
    final componentCount =
        pcaResult?.value?.componentCount ??
        (selected.length < pcaMinVariables ? pcaMinVariables : selected.length);
    final xComponent = _xComponent.clamp(0, componentCount - 1);
    final yComponent = _yComponent.clamp(0, componentCount - 1);

    final scatterX = usable.contains(_scatterX)
        ? _scatterX
        : _defaultScatterVariable(usable, selected, 0);
    final scatterY = usable.contains(_scatterY)
        ? _scatterY
        : _defaultScatterVariable(usable, selected, 1);
    final scatterRequest = scatterX == null || scatterY == null
        ? null
        : ScatterRequest(
            projectUuid: projectUuid,
            taxonGroup: taxonGroup,
            x: scatterX,
            y: scatterY,
            logTransform: _logTransform,
            siteIds: _siteIds,
            taxonRank: _taxonRank,
            taxonIds: _taxonIds,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatisticFilterPanel(
          section: _MethodSwitch(
            selected: _method,
            onSelected: (value) => setState(() => _method = value),
          ),
          selector: Wrap(
            spacing: NahpuSpacing.md,
            runSpacing: NahpuSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Tooltip(
                message: isPca
                    ? l10n.projectAnalyticsVariablesHelp
                    : l10n.projectAnalyticsLogScatterHelp,
                child: FilterChip(
                  key: const ValueKey('analytics-log-transform'),
                  avatar: const Icon(Icons.functions_rounded),
                  label: Text(l10n.projectAnalyticsLogTransform),
                  selected: _logTransform,
                  showCheckmark: false,
                  onSelected: (value) => setState(() => _logTransform = value),
                ),
              ),
              if (isPca)
                Tooltip(
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
            ],
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
            MultiStatisticFilterPicker(
              key: const ValueKey('analytics-site-filter'),
              options: ref.watch(siteOptions),
              selected: _siteIds,
              label: l10n.projectStatsSite,
              placeholder: l10n.projectStatsAllSites,
              onChanged: (value) => setState(() => _siteIds = value),
              onRetry: () => ref.invalidate(siteOptions),
            ),
            StatisticDropdownField<AnalyticsTaxonFilterRank>(
              key: ValueKey('analytics-taxon-rank-${_taxonRank.name}'),
              label: l10n.projectAnalyticsTaxonFilterRank,
              values: AnalyticsTaxonFilterRank.values,
              selected: _taxonRank,
              valueLabel: (value) => value.localizedLabel(l10n),
              onSelected: (value) => setState(() {
                if (value == _taxonRank) return;
                _taxonRank = value;
                // Picks at one rank mean nothing at another.
                _taxonIds = const {};
              }),
            ),
            MultiStatisticFilterPicker(
              key: ValueKey('analytics-taxon-filter-${_taxonRank.name}'),
              options: ref.watch(taxonOptions),
              selected: _taxonIds,
              label: _taxonRank.localizedLabel(l10n),
              placeholder: _taxonRank.localizedAllLabel(l10n),
              onChanged: (value) => setState(() => _taxonIds = value),
              onRetry: () => ref.invalidate(taxonOptions),
            ),
            if (isPca) ...[
              _ComponentDropdown(
                key: ValueKey('analytics-x-axis-$xComponent'),
                label: l10n.projectAnalyticsHorizontalAxis,
                count: componentCount,
                result: pcaResult?.value,
                selected: xComponent,
                onSelected: (value) => setState(() => _xComponent = value),
              ),
              _ComponentDropdown(
                key: ValueKey('analytics-y-axis-$yComponent'),
                label: l10n.projectAnalyticsVerticalAxis,
                count: componentCount,
                result: pcaResult?.value,
                selected: yComponent,
                onSelected: (value) => setState(() => _yComponent = value),
              ),
            ] else if (scatterX != null && scatterY != null) ...[
              StatisticDropdownField<AnalyticsVariable>(
                key: ValueKey('analytics-scatter-x-${scatterX.id}'),
                label: l10n.projectAnalyticsHorizontalAxis,
                values: usable,
                selected: scatterX,
                valueLabel: (value) => value.localizedLabel(l10n),
                onSelected: (value) => setState(() => _scatterX = value),
              ),
              StatisticDropdownField<AnalyticsVariable>(
                key: ValueKey('analytics-scatter-y-${scatterY.id}'),
                label: l10n.projectAnalyticsVerticalAxis,
                values: usable,
                selected: scatterY,
                valueLabel: (value) => value.localizedLabel(l10n),
                onSelected: (value) => setState(() => _scatterY = value),
              ),
            ],
          ],
          footer: !isPca
              ? null
              : options.when(
                  data: (items) => _VariablePicker(
                    options: items,
                    selected: selected.toSet(),
                    onToggle: (variable) => _toggleVariable(variable, selected),
                    onSelectAll: () => setState(() {
                      _picked = {
                        for (final item in items)
                          if (item.count > 0) item.variable,
                      };
                    }),
                    onClear: () => setState(() => _picked = {}),
                  ),
                  loading: () => const _AnalyticsLoading(),
                  error: (error, _) => _AnalyticsMessage(
                    message: l10n.projectStatsLoadError('$error'),
                    onRetry: () => ref.invalidate(optionsProvider),
                  ),
                ),
        ),
        const SizedBox(height: NahpuSpacing.xl),
        if (isPca)
          _PcaResults(
            request: pcaRequest,
            result: pcaResult,
            hasMeasurements: !options.hasValue || usable.length >= 2,
            colorBy: _colorBy,
            xComponent: xComponent,
            yComponent: yComponent,
            projectName: widget.projectName,
          )
        else
          _ScatterResults(
            request: scatterRequest,
            colorBy: _colorBy,
            projectName: widget.projectName,
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

  /// The [position]th PCA variable, so the scatter plot starts on the same
  /// measurements, or the [position]th usable one.
  static AnalyticsVariable? _defaultScatterVariable(
    List<AnalyticsVariable> usable,
    List<AnalyticsVariable> selected,
    int position,
  ) {
    if (usable.isEmpty) return null;
    if (selected.length > position) return selected[position];
    return usable[position.clamp(0, usable.length - 1)];
  }

  void _selectTaxonGroup(SpecimenRecordType value) {
    setState(() {
      _taxonGroup = value;
      // Each group has its own measurements, so the picks start over.
      _picked = null;
      _scatterX = null;
      _scatterY = null;
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

/// Switches Analytics between a PCA and a scatter plot, like the section
/// switch of Explore.
class _MethodSwitch extends StatelessWidget {
  const _MethodSwitch({required this.selected, required this.onSelected});

  final AnalyticsMethod selected;
  final ValueChanged<AnalyticsMethod> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AnalyticsMethod>(
      key: const ValueKey('analytics-method-control'),
      showSelectedIcon: false,
      segments: [
        for (final method in AnalyticsMethod.values)
          ButtonSegment(
            value: method,
            icon: Icon(switch (method) {
              AnalyticsMethod.pca => Icons.bubble_chart_outlined,
              AnalyticsMethod.scatter => Icons.scatter_plot_outlined,
            }),
            label: Text(method.localizedLabel(context.l10n)),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onSelected(selection.single),
    );
  }
}

/// Chips for choosing the variables of an analysis.
class _VariablePicker extends StatelessWidget {
  const _VariablePicker({
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.onSelectAll,
    required this.onClear,
  });

  final List<AnalyticsVariableOption> options;
  final Set<AnalyticsVariable> selected;
  final ValueChanged<AnalyticsVariable> onToggle;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.projectAnalyticsVariables,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: NahpuSpacing.xxs),
                  Text(
                    l10n.projectAnalyticsVariablesHelp,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: NahpuSpacing.lg),
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
      ],
    );
  }
}

/// The score plot card, with the scree, loadings, and summary cards below it
/// once the analysis has run.
class _PcaResults extends StatelessWidget {
  const _PcaResults({
    required this.request,
    required this.result,
    required this.hasMeasurements,
    required this.colorBy,
    required this.xComponent,
    required this.yComponent,
    required this.projectName,
  });

  final PcaRequest request;

  /// The analysis, or null while too few variables are selected.
  final AsyncValue<PcaAnalysisResult>? result;
  final bool hasMeasurements;
  final AnalyticsColorBy colorBy;
  final int xComponent;
  final int yComponent;
  final String projectName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final result = this.result;
    final data = result?.value;
    final export = data == null ? null : PcaExportBuilder(data);
    final scores = _AnalyticsCard(
      title: l10n.projectAnalyticsScores,
      showTotal: true,
      total: data?.records.length,
      action: IconButton(
        key: const ValueKey('analytics-export-scores'),
        tooltip: l10n.projectAnalyticsExportScores,
        icon: const Icon(Icons.file_upload_outlined),
        onPressed: export == null
            ? null
            : () => showTabularExportDialog(
                context: context,
                title: l10n.projectAnalyticsExportScores,
                defaultFileName: '${projectName}_pca-scores',
                headers: export.scores().headers,
                rows: export.scores().rows,
              ),
      ),
      child: switch (result) {
        null => _PlotMessage(
          key: const ValueKey('analytics-select-variables'),
          message: hasMeasurements
              ? l10n.projectAnalyticsSelectVariables
              : l10n.projectAnalyticsNoMeasurements,
        ),
        AsyncValue(value: final data?) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PcaMetricStrip(
              result: data,
              xComponent: xComponent,
              yComponent: yComponent,
            ),
            const SizedBox(height: NahpuSpacing.lg),
            AnalyticsScatterChart(
              records: data.records,
              points: [
                for (final score in data.scores)
                  (x: score[xComponent], y: score[yComponent]),
              ],
              xTitle: _axisTitle(l10n, data, xComponent),
              yTitle: _axisTitle(l10n, data, yComponent),
              colorBy: colorBy,
              semanticLabel: l10n.projectAnalyticsScores,
              height: _plotHeight,
            ),
          ],
        ),
        AsyncValue(error: final error?) => _PlotMessage(
          key: error is PcaFailure ? const ValueKey('analytics-failure') : null,
          message: error is PcaFailure
              ? error.localizedMessage(l10n)
              : l10n.projectAnalyticsError('$error'),
        ),
        _ => const _PlotLoading(),
      },
    );
    if (data == null || export == null) return scores;

    final scree = _PcaScreeCard(result: data);
    final loadings = _LoadingsCard(
      result: data,
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
        scores,
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
          child: PcaSummaryTable(result: data),
        ),
      ],
    );
  }

  static String _axisTitle(
    AppLocalizations l10n,
    PcaAnalysisResult result,
    int component,
  ) => l10n.projectAnalyticsComponentVariance(
    component + 1,
    (result.explainedVariance[component] * 100).toStringAsFixed(1),
  );
}

/// The scatter plot card of two variables.
class _ScatterResults extends ConsumerWidget {
  const _ScatterResults({
    required this.request,
    required this.colorBy,
    required this.projectName,
  });

  /// The plot, or null while the taxon group has no measurement to plot.
  final ScatterRequest? request;
  final AnalyticsColorBy colorBy;
  final String projectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final request = this.request;
    final result = request == null
        ? null
        : ref.watch(scatterResultProvider(request));
    final data = result?.value;
    return _AnalyticsCard(
      title: request == null
          ? l10n.projectAnalyticsMethodScatter
          : l10n.projectAnalyticsScatterTitle(
              request.x.localizedName(l10n),
              request.y.localizedName(l10n),
            ),
      showTotal: true,
      total: data?.records.length,
      action: IconButton(
        key: const ValueKey('analytics-export-scatter'),
        tooltip: l10n.projectAnalyticsExportScatter,
        icon: const Icon(Icons.file_upload_outlined),
        onPressed: data == null || data.records.isEmpty
            ? null
            : () {
                final table = ScatterExportBuilder(data).points();
                showTabularExportDialog(
                  context: context,
                  title: l10n.projectAnalyticsExportScatter,
                  defaultFileName:
                      '${projectName}_scatter_'
                      '${data.request.x.id}-${data.request.y.id}',
                  headers: table.headers,
                  rows: table.rows,
                );
              },
      ),
      child: switch (result) {
        null => _PlotMessage(
          message: l10n.projectAnalyticsScatterNeedsVariables,
        ),
        AsyncValue(value: final data?) when data.records.isEmpty =>
          _PlotMessage(
            key: const ValueKey('analytics-scatter-empty'),
            message: l10n.projectAnalyticsNoScatterRecords,
          ),
        AsyncValue(value: final data?) => Column(
          key: const ValueKey('analytics-scatter-results'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ScatterMetricStrip(result: data),
            const SizedBox(height: NahpuSpacing.lg),
            AnalyticsScatterChart(
              records: data.records,
              points: data.points,
              xTitle: _axisTitle(l10n, data.request.x, data.request),
              yTitle: _axisTitle(l10n, data.request.y, data.request),
              colorBy: colorBy,
              semanticLabel: l10n.projectAnalyticsMethodScatter,
              height: _plotHeight,
            ),
          ],
        ),
        AsyncValue(error: final error?) => _PlotMessage(
          message: l10n.projectAnalyticsError('$error'),
          onRetry: () => ref.invalidate(scatterResultProvider(request!)),
        ),
        _ => const _PlotLoading(),
      },
    );
  }

  static String _axisTitle(
    AppLocalizations l10n,
    AnalyticsVariable variable,
    ScatterRequest request,
  ) {
    final label = variable.localizedLabel(l10n);
    return request.logTransform ? l10n.projectAnalyticsLogOf(label) : label;
  }
}

/// Headline numbers of a scatter plot: its records and how closely the two
/// variables follow a line.
class _ScatterMetricStrip extends StatelessWidget {
  const _ScatterMetricStrip({required this.result});

  final ScatterResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final correlation = result.correlation;
    return StatisticMetricStrip(
      key: const ValueKey('analytics-scatter-metrics'),
      tiles: [
        StatisticMetricTile(
          value: '${result.records.length}',
          label: l10n.projectAnalyticsRecordsPlotted,
        ),
        StatisticMetricTile(
          value: '${result.excludedCount}',
          label: l10n.projectAnalyticsRecordsExcluded,
        ),
        StatisticMetricTile(
          value: correlation?.toStringAsFixed(3) ?? '—',
          label: l10n.projectAnalyticsPearson,
        ),
        StatisticMetricTile(
          value: correlation == null
              ? '—'
              : (correlation * correlation).toStringAsFixed(3),
          label: l10n.projectAnalyticsRSquared,
        ),
      ],
    );
  }
}

/// Variance explained by each component, as a chart or a table.
class _PcaScreeCard extends StatefulWidget {
  const _PcaScreeCard({required this.result});

  final PcaAnalysisResult result;

  @override
  State<_PcaScreeCard> createState() => _PcaScreeCardState();
}

class _PcaScreeCardState extends State<_PcaScreeCard> {
  bool _showTable = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _AnalyticsCard(
      title: l10n.projectAnalyticsScree,
      action: SegmentedButton<bool>(
        key: const ValueKey('analytics-scree-mode'),
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: false,
            icon: const Icon(Icons.show_chart_rounded),
            tooltip: l10n.projectStatsChart,
          ),
          ButtonSegment(
            value: true,
            icon: const Icon(Icons.table_rows_outlined),
            tooltip: l10n.projectStatsTable,
          ),
        ],
        selected: {_showTable},
        onSelectionChanged: (selection) {
          setState(() => _showTable = selection.single);
        },
      ),
      child: SizedBox(
        height: _detailBodyHeight,
        child: _showTable
            ? SingleChildScrollView(
                child: PcaVarianceTable(result: widget.result),
              )
            : PcaScreeChart(result: widget.result),
      ),
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
      child: SizedBox(
        height: _detailBodyHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ComponentDropdown(
              key: ValueKey('analytics-loadings-component-$component'),
              label: l10n.projectAnalyticsLoadingsOf,
              count: widget.result.componentCount,
              result: widget.result,
              selected: component,
              onSelected: (value) => setState(() => _component = value),
            ),
            const SizedBox(height: NahpuSpacing.lg),
            Expanded(
              child: SingleChildScrollView(
                child: PcaLoadingsChart(
                  result: widget.result,
                  component: component,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Picker of one principal component, labelled with its share of variance
/// once the analysis has run.
class _ComponentDropdown extends StatelessWidget {
  const _ComponentDropdown({
    super.key,
    required this.label,
    required this.count,
    required this.result,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final int count;
  final PcaAnalysisResult? result;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final result = this.result;
    return StatisticDropdownField<int>(
      // The labels gain their variance when the analysis finishes.
      key: ValueKey(result),
      label: label,
      values: [for (var index = 0; index < count; index++) index],
      selected: selected,
      valueLabel: (value) => result == null || value >= result.componentCount
          ? l10n.projectAnalyticsComponent(value + 1)
          : l10n.projectAnalyticsComponentVariance(
              value + 1,
              (result.explainedVariance[value] * 100).toStringAsFixed(1),
            ),
      onSelected: onSelected,
    );
  }
}

/// A result card laid out like the Explore result card: the title with an
/// optional `N = total` line, an action beside it, and the content below.
class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.title,
    required this.child,
    this.showTotal = false,
    this.total,
    this.action,
  });

  final String title;
  final Widget child;

  /// Whether the title has an `N = total` line. It shows while the result
  /// loads too, so the header keeps one height.
  final bool showTotal;

  /// Records the card covers, or null while they load.
  final int? total;
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
            ConstrainedBox(
              // One header height whether the action is a button or a
              // segmented control, so side-by-side cards line up.
              constraints: const BoxConstraints(
                minHeight: NahpuControlSize.touchTarget,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (showTotal) StatisticTotalLabel(total: total),
                      ],
                    ),
                  ),
                  if (action != null) ...[
                    const SizedBox(width: NahpuSpacing.md),
                    action!,
                  ],
                ],
              ),
            ),
            const SizedBox(height: NahpuSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

/// A centered note in place of a plot, as tall as the plot.
class _PlotMessage extends StatelessWidget {
  const _PlotMessage({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _plotHeight,
      child: Center(
        child: _AnalyticsMessage(message: message, onRetry: onRetry),
      ),
    );
  }
}

class _PlotLoading extends StatelessWidget {
  const _PlotLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: _plotHeight,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

/// A centered note for an empty, failed, or not-yet-configured analysis.
class _AnalyticsMessage extends StatelessWidget {
  const _AnalyticsMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NahpuSpacing.xl,
        vertical: NahpuSpacing.xxl,
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
      padding: EdgeInsets.all(NahpuSpacing.xxl),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
