import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/charts.dart';
import 'package:nahpu/screens/projects/statistics/record_statistic_metrics.dart';
import 'package:nahpu/screens/projects/statistics/searchable_statistic_filter.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics.dart';
import 'package:nahpu/screens/projects/statistics/statistics_table.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/statistics.dart';
import 'package:nahpu/services/sites/coordinate_format.dart';
import 'package:nahpu/services/types/statistics.dart';
import 'package:nahpu/styles/design_tokens.dart';

const int topStatisticCount = 5;
const int _pieChartCategoryThreshold = 5;

String _formatProjectDays(int? totalDays) =>
    totalDays?.toString() ?? 'Not recorded';

class StatisticViewer extends ConsumerStatefulWidget {
  const StatisticViewer({super.key});

  @override
  ConsumerState<StatisticViewer> createState() => _StatisticViewerState();
}

/// Which face of the dashboard record statistics panel is showing.
enum _RecordPanelView { topSpecies, metrics }

class _StatisticViewerState extends ConsumerState<StatisticViewer> {
  _RecordPanelView _view = _RecordPanelView.topSpecies;

  @override
  Widget build(BuildContext context) {
    final isTopSpecies = _view == _RecordPanelView.topSpecies;

    return FormCard(
      title: 'Record Statistics',
      infoTopic: InfoTopic.recordStatistics,
      mainAxisAlignment: MainAxisAlignment.start,
      child: DashboardPanelBody(
        contentAlignment: Alignment.topCenter,
        content: Column(
          key: const ValueKey('record-statistics-content'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isTopSpecies ? 'Top recorded species' : 'Record counts',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Semantics(
                  label: isTopSpecies
                      ? 'Show record counts'
                      : 'Show top recorded species',
                  child: IconButton(
                    key: const ValueKey('record-statistics-view-toggle'),
                    visualDensity: VisualDensity.compact,
                    tooltip: isTopSpecies
                        ? 'Show record counts'
                        : 'Show top recorded species',
                    icon: Icon(
                      isTopSpecies
                          ? Icons.grid_view_rounded
                          : Icons.leaderboard_outlined,
                    ),
                    onPressed: () => setState(
                      () => _view = isTopSpecies
                          ? _RecordPanelView.metrics
                          : _RecordPanelView.topSpecies,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: NahpuSpacing.sm),
            Expanded(
              child: isTopSpecies
                  ? const _TopSpeciesChart()
                  : const _RecordCountMetrics(),
            ),
          ],
        ),
        actions: FilledButton(
          key: const ValueKey('record-statistics-actions'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StatisticFullScreen(
                startingSelection: StatisticSelection(
                  measure: StatisticMeasure.specimens,
                  group: StatisticGroup.species,
                ),
              ),
            ),
          ),
          child: const Text('Explore more stats'),
        ),
      ),
    );
  }
}

class _TopSpeciesChart extends ConsumerWidget {
  const _TopSpeciesChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = StatisticRequest(
      projectUuid: ref.watch(projectUuidProvider),
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.species,
      limit: topStatisticCount,
    );
    return _StatisticAsyncContent(
      value: ref.watch(statisticDataProvider(request)),
      onRetry: () => ref.invalidate(statisticDataProvider(request)),
      builder: (rows) => StatisticRankedBarList(data: rows, isSpecies: true),
    );
  }
}

class _RecordCountMetrics extends ConsumerWidget {
  const _RecordCountMetrics();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(recordStatisticTotalsProvider)
        .when(
          data: (value) => LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: _RecordStatisticsSummary(totals: value),
                ),
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Unable to load record statistics: $error'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(recordStatisticTotalsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
  }
}

class _RecordStatisticsSummary extends StatelessWidget {
  const _RecordStatisticsSummary({required this.totals});

  final RecordStatisticTotals totals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            key: const ValueKey('record-stat-taxa'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: _RecordStatisticTile(
                  kind: RecordMetricKind.specimens,
                  value: totals.specimenCount.toString(),
                  tier: _RecordTileTier.hero,
                ),
              ),
              const SizedBox(height: NahpuSpacing.xs),
              Expanded(
                flex: 2,
                child: _RecordMetricRow(
                  tier: _RecordTileTier.primary,
                  spacing: NahpuSpacing.xs,
                  metrics: [
                    (RecordMetricKind.species, totals.speciesCount.toString()),
                    (RecordMetricKind.families, totals.familyCount.toString()),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: NahpuSpacing.md),
        Expanded(
          flex: 4,
          child: Column(
            key: const ValueKey('record-stat-secondary'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _RecordMetricRow(
                  tier: _RecordTileTier.secondary,
                  metrics: [
                    (
                      RecordMetricKind.recordedSites,
                      totals.recordedSiteCount.toString(),
                    ),
                    (RecordMetricKind.events, totals.eventCount.toString()),
                  ],
                ),
              ),
              const SizedBox(height: NahpuSpacing.xs),
              Expanded(
                child: _RecordMetricRow(
                  tier: _RecordTileTier.secondary,
                  metrics: [
                    (
                      RecordMetricKind.narratives,
                      totals.narrativeCount.toString(),
                    ),
                    (
                      RecordMetricKind.projectDays,
                      _formatProjectDays(totals.totalDays),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A row of equally sized record tiles that fill the height they are given.
class _RecordMetricRow extends StatelessWidget {
  const _RecordMetricRow({
    required this.metrics,
    required this.tier,
    this.spacing = NahpuSpacing.sm,
  });

  final List<(RecordMetricKind, String)> metrics;
  final _RecordTileTier tier;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < metrics.length; index++) ...[
          if (index > 0) SizedBox(width: spacing),
          Expanded(
            child: _RecordStatisticTile(
              kind: metrics[index].$1,
              value: metrics[index].$2,
              tier: tier,
            ),
          ),
        ],
      ],
    );
  }
}

/// Visual weight of a dashboard record statistic tile.
enum _RecordTileTier { hero, primary, secondary }

class _RecordStatisticTile extends StatelessWidget {
  const _RecordStatisticTile({
    required this.kind,
    required this.value,
    required this.tier,
  });

  final RecordMetricKind kind;
  final String value;
  final _RecordTileTier tier;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSecondary = tier == _RecordTileTier.secondary;
    final countColor = isSecondary
        ? colorScheme.onSurface
        : colorScheme.onSecondaryContainer;
    final labelColor = isSecondary
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSecondaryContainer;
    final countText = Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: _countStyle(textTheme)?.copyWith(color: countColor),
    );

    return Semantics(
      container: true,
      label: '${kind.label}: $value',
      child: Container(
        key: kind.dashboardKey,
        width: double.infinity,
        alignment: Alignment.center,
        padding: _padding,
        decoration: BoxDecoration(
          color: _fill(colorScheme),
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (kind.hasIcon)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    kind.icon,
                    size: NahpuControlSize.iconSmall,
                    color: labelColor,
                  ),
                  const SizedBox(width: NahpuSpacing.xs),
                  Flexible(child: countText),
                ],
              )
            else
              countText,
            const SizedBox(height: NahpuSpacing.xxs),
            Text(
              kind.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: _labelStyle(textTheme)?.copyWith(color: labelColor),
            ),
          ],
        ),
      ),
    );
  }

  /// Corner radius grows with the tier so the tiles read as one bento grid.
  double get _radius => switch (tier) {
    _RecordTileTier.hero => NahpuRadius.lg,
    _RecordTileTier.primary => NahpuRadius.md,
    _RecordTileTier.secondary => NahpuRadius.sm,
  };

  Color _fill(ColorScheme colorScheme) => switch (tier) {
    _RecordTileTier.hero => colorScheme.secondaryContainer.withValues(
      alpha: 0.28,
    ),
    _RecordTileTier.primary => colorScheme.secondaryContainer.withValues(
      alpha: 0.16,
    ),
    _RecordTileTier.secondary => colorScheme.surfaceContainerLow,
  };

  EdgeInsets get _padding => switch (tier) {
    _RecordTileTier.hero => const EdgeInsets.symmetric(
      vertical: NahpuSpacing.xs,
      horizontal: NahpuSpacing.lg,
    ),
    _RecordTileTier.primary => const EdgeInsets.symmetric(
      vertical: NahpuSpacing.xs,
      horizontal: NahpuSpacing.sm,
    ),
    _RecordTileTier.secondary => const EdgeInsets.symmetric(
      vertical: NahpuSpacing.xs,
      horizontal: NahpuSpacing.xs,
    ),
  };

  TextStyle? _countStyle(TextTheme textTheme) => switch (tier) {
    _RecordTileTier.hero => textTheme.headlineMedium,
    _RecordTileTier.primary => textTheme.titleMedium,
    _RecordTileTier.secondary => textTheme.titleSmall,
  };

  TextStyle? _labelStyle(TextTheme textTheme) => switch (tier) {
    _RecordTileTier.hero => textTheme.titleSmall,
    _RecordTileTier.primary => textTheme.bodySmall,
    _RecordTileTier.secondary => textTheme.labelSmall,
  };
}

class StatisticFullScreen extends ConsumerStatefulWidget {
  const StatisticFullScreen({
    super.key,
    this.startingSelection = const StatisticSelection(
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.species,
    ),
  });

  final StatisticSelection startingSelection;

  @override
  ConsumerState<StatisticFullScreen> createState() =>
      _StatisticFullScreenState();
}

class _StatisticFullScreenState extends ConsumerState<StatisticFullScreen> {
  static const _detailedStatisticsCardHeight = 960.0;

  final _detailKey = GlobalKey();
  StatisticFilterOption? _siteFilter;
  StatisticFilterOption? _speciesFilter;
  late StatisticMeasure _measure;
  late StatisticGroup _group;
  StatisticBreakdown? _breakdown;
  _DetailMode _detailMode = _DetailMode.chart;

  @override
  void initState() {
    super.initState();
    _measure = widget.startingSelection.measure;
    _group = widget.startingSelection.group;
    _breakdown = widget.startingSelection.breakdown;
  }

  @override
  Widget build(BuildContext context) {
    final projectUuid = ref.watch(projectUuidProvider);
    final totals = ref.watch(recordStatisticTotalsProvider);
    final projectName = ref.watch(currProjInfoProvider).value?.name ?? 'NAHPU';
    final availability = ref.watch(statisticAvailabilityProvider);
    final hasSex = availability.when(
      data: (value) => value.hasSex,
      loading: () => false,
      error: (error, stackTrace) => false,
    );
    final hasLifeStage = availability.when(
      data: (value) => value.hasLifeStage,
      loading: () => false,
      error: (error, stackTrace) => false,
    );
    final request = StatisticRequest(
      projectUuid: projectUuid,
      measure: _measure,
      group: _group,
      breakdown: _breakdown,
      siteId: _usesSiteFilter ? _siteFilter?.id : null,
      speciesId: _usesSpeciesFilter ? _speciesFilter?.id : null,
    );
    final details = ref.watch(statisticDataProvider(request));

    return Scaffold(
      appBar: AppBar(title: const Text('Record Statistics')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CommonPadding(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Summary',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Record totals and top five counts by category.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CommonPadding(
                    child: _FullScreenRecordStatisticsSummary(
                      value: totals,
                      onRetry: () =>
                          ref.invalidate(recordStatisticTotalsProvider),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StatisticSummary(
                    projectUuid: projectUuid,
                    onExplore: _selectAndReveal,
                  ),
                  const SizedBox(height: 32),
                  Card(
                    key: _detailKey,
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      key: const ValueKey('detailed-statistics-content'),
                      height: _detailedStatisticsCardHeight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Detailed statistics',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            _StatisticControl<StatisticMeasure>(
                              key: const ValueKey('statistics-measure-control'),
                              label: 'Measure',
                              values: StatisticMeasure.values,
                              selected: _measure,
                              valueLabel: (value) => value.label,
                              onSelected: (value) =>
                                  _selectMeasure(value, hasLifeStage),
                            ),
                            const SizedBox(height: 12),
                            _StatisticControl<StatisticGroup>(
                              key: const ValueKey('statistics-group-control'),
                              label: 'Group by',
                              values: _measure.groups(
                                hasLifeStage: hasLifeStage,
                              ),
                              selected: _group,
                              valueLabel: (value) => value.label,
                              onSelected: (value) {
                                setState(() {
                                  _group = value;
                                  _breakdown = null;
                                });
                              },
                            ),
                            if (_canBreakDown) ...[
                              const SizedBox(height: 12),
                              _BreakdownControl(
                                key: const ValueKey(
                                  'statistics-breakdown-control',
                                ),
                                selected: _breakdown,
                                hasSex: hasSex,
                                hasLifeStage: hasLifeStage,
                                onSelected: (value) {
                                  setState(() => _breakdown = value);
                                },
                              ),
                            ],
                            if (_usesSiteFilter) ...[
                              const SizedBox(height: 12),
                              SearchableStatisticFilterPicker(
                                options: ref.watch(
                                  statisticFilterOptionsProvider(
                                    StatisticFilterKind.site,
                                  ),
                                ),
                                selected: _siteFilter,
                                title: 'Select a site',
                                placeholder: 'All sites',
                                onChanged: (value) {
                                  setState(() => _siteFilter = value);
                                },
                                onRetry: () => ref.invalidate(
                                  statisticFilterOptionsProvider(
                                    StatisticFilterKind.site,
                                  ),
                                ),
                              ),
                            ],
                            if (_usesSpeciesFilter) ...[
                              const SizedBox(height: 12),
                              SearchableStatisticFilterPicker(
                                options: ref.watch(
                                  statisticFilterOptionsProvider(
                                    StatisticFilterKind.species,
                                  ),
                                ),
                                selected: _speciesFilter,
                                title: 'Select a species',
                                placeholder: 'All species',
                                onChanged: (value) {
                                  setState(() => _speciesFilter = value);
                                },
                                onRetry: () => ref.invalidate(
                                  statisticFilterOptionsProvider(
                                    StatisticFilterKind.species,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    request.title(
                                      siteLabel: _usesSiteFilter
                                          ? _siteFilter?.label
                                          : null,
                                      speciesLabel: _usesSpeciesFilter
                                          ? _speciesFilter?.label
                                          : null,
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                                SegmentedButton<_DetailMode>(
                                  showSelectedIcon: false,
                                  segments: const [
                                    ButtonSegment(
                                      value: _DetailMode.chart,
                                      icon: Icon(Icons.bar_chart_rounded),
                                      label: Text('Chart'),
                                    ),
                                    ButtonSegment(
                                      value: _DetailMode.table,
                                      icon: Icon(Icons.table_rows_outlined),
                                      label: Text('Table'),
                                    ),
                                  ],
                                  selected: {_detailMode},
                                  onSelectionChanged: (selection) {
                                    setState(
                                      () => _detailMode = selection.single,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return _StatisticAsyncContent(
                                    value: details,
                                    onRetry: () => ref.invalidate(
                                      statisticDataProvider(request),
                                    ),
                                    builder: (rows) {
                                      if (_detailMode == _DetailMode.chart) {
                                        if (_isPieChartGroup(request.group) &&
                                            request.breakdown == null) {
                                          return StatisticChartSwitcher(
                                            data: rows,
                                            measure: request.measure,
                                            group: request.group,
                                            usePieByDefault:
                                                _shouldUseStandalonePieChart(
                                                  request,
                                                  rows,
                                                ),
                                            height: constraints.maxHeight,
                                            fitHeight: true,
                                            toggleKey: const ValueKey(
                                              'statistics-detail-chart-toggle',
                                            ),
                                          );
                                        }
                                        return StatisticBarChart(
                                          data: rows,
                                          measure: request.measure,
                                          group: request.group,
                                          breakdown: request.breakdown,
                                          height: constraints.maxHeight,
                                          fitHeight: true,
                                        );
                                      }
                                      final tableRows = buildStatisticTableRows(
                                        rows,
                                      );
                                      return StatisticDataTable(
                                        rows: tableRows,
                                        categoryLabel: request.group.label,
                                        seriesLabel: request.seriesLabel,
                                        countLabel: request.measure.countLabel,
                                        onExport: tableRows.isEmpty
                                            ? null
                                            : () => showStatisticExportDialog(
                                                context: context,
                                                defaultFileName:
                                                    _defaultFileName(
                                                      projectName,
                                                      request,
                                                    ),
                                                rows: tableRows,
                                                categoryLabel:
                                                    request.group.label,
                                                seriesLabel:
                                                    request.seriesLabel,
                                                countLabel:
                                                    request.measure.countLabel,
                                              ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SpatialStatisticsPanel(
                    projectUuid: projectUuid,
                    projectName: projectName,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _usesSiteFilter =>
      _measure == StatisticMeasure.specimens &&
      _group == StatisticGroup.species;

  bool get _usesSpeciesFilter => _measure == StatisticMeasure.partQuantity;

  bool get _canBreakDown =>
      _measure == StatisticMeasure.specimens &&
      _group == StatisticGroup.species;

  void _selectMeasure(StatisticMeasure measure, bool hasLifeStage) {
    setState(() {
      _measure = measure;
      _group = measure.groups(hasLifeStage: hasLifeStage).first;
      _breakdown = null;
    });
  }

  void _selectAndReveal(StatisticSelection selection) {
    setState(() {
      _measure = selection.measure;
      _group = selection.group;
      _breakdown = selection.breakdown;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final detailContext = _detailKey.currentContext;
      if (detailContext != null) {
        Scrollable.ensureVisible(
          detailContext,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  String _defaultFileName(String projectName, StatisticRequest request) {
    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final activeFilter = _usesSiteFilter ? _siteFilter : _speciesFilter;
    final components = [
      projectName,
      request.fileSlug,
      if (activeFilter != null) activeFilter.label,
      date,
    ];
    return components
        .join('_')
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}

class _FullScreenRecordStatisticsSummary extends StatelessWidget {
  const _FullScreenRecordStatisticsSummary({
    required this.value,
    required this.onRetry,
  });

  final AsyncValue<RecordStatisticTotals> value;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (totals) => _FullScreenRecordStatisticsCard(totals: totals),
      loading: () => const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Card(
        child: Padding(
          padding: const EdgeInsets.all(NahpuSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Unable to load record statistics: $error'),
              const SizedBox(height: NahpuSpacing.md),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullScreenRecordStatisticsCard extends StatelessWidget {
  const _FullScreenRecordStatisticsCard({required this.totals});

  final RecordStatisticTotals totals;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('full-screen-record-stat-summary'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SummaryGroup(
          key: const ValueKey('full-screen-record-stat-records'),
          title: 'Records',
          children: [
            _SummaryMetric(
              key: RecordMetricKind.specimens.fullScreenKey,
              kind: RecordMetricKind.specimens,
              value: totals.specimenCount.toString(),
              emphasis: true,
            ),
            _SummaryMetric(
              key: RecordMetricKind.species.fullScreenKey,
              kind: RecordMetricKind.species,
              value: totals.speciesCount.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.families.fullScreenKey,
              kind: RecordMetricKind.families,
              value: totals.familyCount.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.narratives.fullScreenKey,
              kind: RecordMetricKind.narratives,
              value: totals.narrativeCount.toString(),
            ),
          ],
        ),
        const SizedBox(height: NahpuSpacing.md),
        _SummaryGroup(
          key: const ValueKey('full-screen-record-stat-sampling'),
          title: 'Sampling',
          children: [
            _SummaryMetric(
              key: RecordMetricKind.recordedSites.fullScreenKey,
              kind: RecordMetricKind.recordedSites,
              value: totals.recordedSiteCount.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.sampledSites.fullScreenKey,
              kind: RecordMetricKind.sampledSites,
              value: totals.sampledSiteCount.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.events.fullScreenKey,
              kind: RecordMetricKind.events,
              value: totals.eventCount.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.captureDays.fullScreenKey,
              kind: RecordMetricKind.captureDays,
              value: totals.totalCaptureDays.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.projectDays.fullScreenKey,
              kind: RecordMetricKind.projectDays,
              value: _formatProjectDays(totals.totalDays),
            ),
            _SummaryMetric(
              key: RecordMetricKind.recordedElevation.fullScreenKey,
              kind: RecordMetricKind.recordedElevation,
              value: _formatElevationRange(
                totals.minimumRecordedElevationInMeter,
                totals.maximumRecordedElevationInMeter,
              ),
              span: 2,
            ),
            _SummaryMetric(
              key: RecordMetricKind.sampledElevation.fullScreenKey,
              kind: RecordMetricKind.sampledElevation,
              value: _formatElevationRange(
                totals.minimumSampledElevationInMeter,
                totals.maximumSampledElevationInMeter,
              ),
              span: 2,
            ),
          ],
        ),
      ],
    );
  }

  String _formatElevationRange(double? minimum, double? maximum) {
    if (minimum == null || maximum == null) return '—';
    final minimumText = formatCoordinate(minimum, decimals: 2);
    final maximumText = formatCoordinate(maximum, decimals: 2);
    if (minimum == maximum) return '$minimumText m';
    return '$minimumText–$maximumText m';
  }
}

class _SummaryGroup extends StatelessWidget {
  const _SummaryGroup({super.key, required this.title, required this.children});

  final String title;
  final List<_SummaryMetric> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(NahpuSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(NahpuRadius.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: NahpuSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = NahpuSpacing.xs;
              final rows = _packRows(_columnCount(constraints.maxWidth));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var row = 0; row < rows.length; row++) ...[
                    if (row > 0) const SizedBox(height: spacing),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (
                            var index = 0;
                            index < rows[row].length;
                            index++
                          ) ...[
                            if (index > 0) const SizedBox(width: spacing),
                            Expanded(
                              flex: rows[row][index].span,
                              child: rows[row][index],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Columns for the metric grid, capped so a group with few metrics never
  /// leaves a dead trailing column.
  int _columnCount(double maxWidth) {
    final limit = maxWidth >= 1000
        ? 5
        : maxWidth >= 720
        ? 4
        : maxWidth >= 480
        ? 3
        : 2;
    final spanCount = children.fold<int>(
      0,
      (total, metric) => total + metric.span,
    );
    if (spanCount < 1) return 1;
    return spanCount < limit ? spanCount : limit;
  }

  /// Packs the metrics into rows of at most [columns] spans.
  ///
  /// Every row is stretched to the full group width, so a run that cannot
  /// fill its columns widens its metrics instead of leaving dead space.
  List<List<_SummaryMetric>> _packRows(int columns) {
    final rows = <List<_SummaryMetric>>[];
    var row = <_SummaryMetric>[];
    var used = 0;
    for (final metric in children) {
      final span = metric.span > columns ? columns : metric.span;
      if (row.isNotEmpty && used + span > columns) {
        rows.add(row);
        row = <_SummaryMetric>[];
        used = 0;
      }
      row.add(metric);
      used += span;
    }
    if (row.isNotEmpty) rows.add(row);
    return rows;
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    super.key,
    required this.kind,
    required this.value,
    this.emphasis = false,
    this.span = 1,
  });

  final RecordMetricKind kind;
  final String value;
  final bool emphasis;

  /// Number of grid columns this metric occupies.
  final int span;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = emphasis
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;
    return Semantics(
      container: true,
      label: '${kind.label}: $value',
      child: Container(
        constraints: const BoxConstraints(minHeight: 68),
        padding: const EdgeInsets.symmetric(
          horizontal: NahpuSpacing.md,
          vertical: NahpuSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: emphasis
              ? colorScheme.secondaryContainer.withValues(alpha: 0.35)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(NahpuRadius.sm),
        ),
        child: Row(
          children: [
            if (kind.hasIcon) ...[
              Icon(
                kind.icon,
                size: NahpuControlSize.iconMedium,
                color: foregroundColor,
              ),
              const SizedBox(width: NahpuSpacing.sm),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: emphasis
                        ? Theme.of(context).textTheme.headlineSmall
                        : Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: NahpuSpacing.xxs),
                  Text(
                    kind.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticSummary extends StatelessWidget {
  const _StatisticSummary({required this.projectUuid, required this.onExplore});

  final String projectUuid;
  final ValueChanged<StatisticSelection> onExplore;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumnBreakpoint =
            StatisticBarChart.minimumWidth(
                  categoryCount: topStatisticCount,
                  compact: true,
                ) *
                2 +
            16;
        final cardWidth = constraints.maxWidth >= twoColumnBreakpoint
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final definition in _summaryDefinitions)
              SizedBox(
                width: cardWidth,
                child: _StatisticSummaryCard(
                  projectUuid: projectUuid,
                  definition: definition,
                  onExplore: () => onExplore(definition.selection),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatisticSummaryCard extends ConsumerWidget {
  const _StatisticSummaryCard({
    required this.projectUuid,
    required this.definition,
    required this.onExplore,
  });

  final String projectUuid;
  final _SummaryDefinition definition;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdaptiveChart = _isPieChartGroup(definition.selection.group);
    final request = StatisticRequest(
      projectUuid: projectUuid,
      measure: definition.selection.measure,
      group: definition.selection.group,
      limit: isAdaptiveChart ? null : topStatisticCount,
    );
    final value = ref.watch(statisticDataProvider(request));
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    definition.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(onPressed: onExplore, child: const Text('Explore')),
              ],
            ),
            _StatisticAsyncContent(
              value: value,
              onRetry: () => ref.invalidate(statisticDataProvider(request)),
              builder: (rows) {
                if (_isPieChartGroup(request.group)) {
                  return StatisticChartSwitcher(
                    data: rows.take(topStatisticCount).toList(growable: false),
                    measure: request.measure,
                    group: request.group,
                    usePieByDefault: _shouldUseStandalonePieChart(
                      request,
                      rows,
                    ),
                    compact: true,
                    height: 280,
                    toggleKey: ValueKey(
                      'statistics-summary-chart-toggle-${request.group.name}',
                    ),
                  );
                }
                return StatisticBarChart(
                  data: rows.take(topStatisticCount).toList(growable: false),
                  measure: request.measure,
                  group: request.group,
                  compact: true,
                  height: 280,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticControl<T> extends StatelessWidget {
  const _StatisticControl({
    super.key,
    required this.label,
    required this.values,
    required this.selected,
    required this.valueLabel,
    required this.onSelected,
  });

  final String label;
  final List<T> values;
  final T selected;
  final String Function(T value) valueLabel;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in values)
              ChoiceChip(
                label: Text(valueLabel(value)),
                selected: selected == value,
                onSelected: (_) => onSelected(value),
              ),
          ],
        ),
      ],
    );
  }
}

class _BreakdownControl extends StatelessWidget {
  const _BreakdownControl({
    super.key,
    required this.selected,
    required this.hasSex,
    required this.hasLifeStage,
    required this.onSelected,
  });

  final StatisticBreakdown? selected;
  final bool hasSex;
  final bool hasLifeStage;
  final ValueChanged<StatisticBreakdown?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Break down by', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('None'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
            if (hasSex)
              ChoiceChip(
                label: const Text('Sex'),
                selected: selected == StatisticBreakdown.sex,
                onSelected: (_) => onSelected(StatisticBreakdown.sex),
              ),
            if (hasLifeStage)
              ChoiceChip(
                label: const Text('Life stage'),
                selected: selected == StatisticBreakdown.lifeStage,
                onSelected: (_) => onSelected(StatisticBreakdown.lifeStage),
              ),
          ],
        ),
      ],
    );
  }
}

class _StatisticAsyncContent extends StatelessWidget {
  const _StatisticAsyncContent({
    required this.value,
    required this.builder,
    required this.onRetry,
  });

  final AsyncValue<List<StatisticDatum>> value;
  final Widget Function(List<StatisticDatum>) builder;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Unable to load statistics: $error'),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryDefinition {
  const _SummaryDefinition({required this.title, required this.selection});

  final String title;
  final StatisticSelection selection;
}

const _summaryDefinitions = [
  _SummaryDefinition(
    title: 'Specimens by species',
    selection: StatisticSelection(
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.species,
    ),
  ),
  _SummaryDefinition(
    title: 'Specimens by family',
    selection: StatisticSelection(
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.family,
    ),
  ),
  _SummaryDefinition(
    title: 'Specimens by site',
    selection: StatisticSelection(
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.site,
    ),
  ),
  _SummaryDefinition(
    title: 'Specimens by date',
    selection: StatisticSelection(
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.date,
    ),
  ),
  _SummaryDefinition(
    title: 'Specimens by method',
    selection: StatisticSelection(
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.method,
    ),
  ),
  _SummaryDefinition(
    title: 'Specimens by sex',
    selection: StatisticSelection(
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.sex,
    ),
  ),
  _SummaryDefinition(
    title: 'Part quantity by type',
    selection: StatisticSelection(
      measure: StatisticMeasure.partQuantity,
      group: StatisticGroup.partType,
    ),
  ),
  _SummaryDefinition(
    title: 'Part quantity by treatment',
    selection: StatisticSelection(
      measure: StatisticMeasure.partQuantity,
      group: StatisticGroup.partTreatment,
    ),
  ),
];

enum _DetailMode { chart, table }

bool _isPieChartGroup(StatisticGroup group) => switch (group) {
  StatisticGroup.method ||
  StatisticGroup.sex ||
  StatisticGroup.lifeStage => true,
  _ => false,
};

bool _shouldUseStandalonePieChart(
  StatisticRequest request,
  List<StatisticDatum> rows,
) {
  if (request.breakdown != null || !_isPieChartGroup(request.group)) {
    return false;
  }
  final categoryCount = rows.map((datum) => datum.label).toSet().length;
  return categoryCount < _pieChartCategoryThreshold;
}
