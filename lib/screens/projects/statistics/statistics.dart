import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/charts.dart';
import 'package:nahpu/screens/projects/statistics/record_statistic_metrics.dart';
import 'package:nahpu/screens/projects/statistics/searchable_statistic_filter.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics.dart';
import 'package:nahpu/screens/projects/statistics/statistic_records.dart';
import 'package:nahpu/screens/projects/statistics/statistic_filter_panel.dart';
import 'package:nahpu/screens/projects/statistics/statistic_metric_strip.dart';
import 'package:nahpu/screens/projects/statistics/statistics_table.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/statistics.dart';
import 'package:nahpu/services/sites/coordinate_format.dart';
import 'package:nahpu/services/types/statistics.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';

const int topStatisticCount = 5;
const int _pieChartCategoryThreshold = 5;

/// Height of the chart area in every summary card, so bar and pie cards end
/// at the same line no matter which chart they show.
const double _summaryChartHeight = 360;

String _formatProjectDays(AppLocalizations l10n, int? totalDays) =>
    totalDays?.toString() ?? l10n.projectStatsNotRecorded;

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
      title: context.l10n.projectStatsRecordStatistics,
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
                    isTopSpecies
                        ? context.l10n.projectStatsTopSpecies
                        : context.l10n.projectStatsRecordCounts,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Semantics(
                  label: isTopSpecies
                      ? context.l10n.projectStatsShowRecordCounts
                      : context.l10n.projectStatsShowTopSpecies,
                  child: IconButton(
                    key: const ValueKey('record-statistics-view-toggle'),
                    visualDensity: VisualDensity.compact,
                    tooltip: isTopSpecies
                        ? context.l10n.projectStatsShowRecordCounts
                        : context.l10n.projectStatsShowTopSpecies,
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
          child: Text(context.l10n.projectStatsExploreMore),
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
    );
    return _StatisticAsyncContent(
      value: ref.watch(statisticDataProvider(request)),
      onRetry: () => ref.invalidate(statisticDataProvider(request)),
      // Every species is loaded so N counts all specimens, not the top five.
      builder: (rows) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatisticTotalLabel(total: statisticTotal(rows)),
          const SizedBox(height: NahpuSpacing.xs),
          Expanded(
            child: StatisticRankedBarList(
              data: rows.take(topStatisticCount).toList(growable: false),
              isSpecies: true,
              onSelect: (label, series) => openStatisticRecords(
                context,
                ref,
                request,
                label: label,
                seriesLabel: series,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordCountMetrics extends ConsumerWidget {
  const _RecordCountMetrics();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = recordStatisticTotalsProvider(
      ref.watch(projectUuidProvider),
    );
    return ref
        .watch(provider)
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
                Text(context.l10n.projectStatsRecordLoadError('$error')),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(provider),
                  child: Text(context.l10n.commonRetry),
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
                      _formatProjectDays(context.l10n, totals.totalDays),
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
      label: '${kind.localizedLabel(context.l10n)}: $value',
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
                    kind.icon!,
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
              kind.localizedLabel(context.l10n),
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
    this.allProjects = false,
  });

  final StatisticSelection startingSelection;

  /// Covers every project in the database instead of the open project, and
  /// lists each project's totals under the overall summary.
  final bool allProjects;

  @override
  ConsumerState<StatisticFullScreen> createState() =>
      _StatisticFullScreenState();
}

class _StatisticFullScreenState extends ConsumerState<StatisticFullScreen> {
  static const _exploreStatisticsCardHeight = 960.0;

  _StatisticView _view = _StatisticView.summary;
  _DetailSection _detailSection = _DetailSection.counts;
  StatisticFilterOption? _siteFilter;
  StatisticFilterOption? _speciesFilter;
  late StatisticMeasure _measure;
  late StatisticGroup _group;
  late StatisticTaxonRank _rank;
  StatisticBreakdown? _breakdown;
  _DetailMode _detailMode = _DetailMode.chart;

  @override
  void initState() {
    super.initState();
    _measure = widget.startingSelection.measure;
    _group = widget.startingSelection.group;
    _rank =
        widget.startingSelection.rank ?? StatisticTaxonRank.defaultGroupable;
    _breakdown = widget.startingSelection.breakdown;
  }

  @override
  Widget build(BuildContext context) {
    final String? projectUuid = widget.allProjects
        ? null
        : ref.watch(projectUuidProvider);
    final totals = ref.watch(recordStatisticTotalsProvider(projectUuid));
    final projectName = widget.allProjects
        ? 'NAHPU_all-projects'
        : ref.watch(currProjInfoProvider).value?.name ?? 'NAHPU';
    final availability = ref.watch(statisticAvailabilityProvider(projectUuid));
    final siteOptions = statisticFilterOptionsProvider((
      projectUuid: projectUuid,
      kind: StatisticFilterKind.site,
    ));
    final speciesOptions = statisticFilterOptionsProvider((
      projectUuid: projectUuid,
      kind: StatisticFilterKind.species,
    ));
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
      rank: _usesTaxonRank ? _rank : null,
      breakdown: _breakdown,
      siteId: _usesSiteFilter ? _siteFilter?.id : null,
      speciesId: _usesSpeciesFilter ? _speciesFilter?.id : null,
    );
    final details = ref.watch(statisticDataProvider(request));
    final detailRows = details.value;
    void select(String label, String? series) => openStatisticRecords(
      context,
      ref,
      request,
      label: label,
      seriesLabel: series,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.allProjects
              ? context.l10n.drawerDatabaseStatistics
              : context.l10n.projectStatsRecordStatistics,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NahpuPageMargin.horizontal,
                NahpuPageMargin.top,
                NahpuPageMargin.horizontal,
                0,
              ),
              child: Center(
                child: SegmentedButton<_StatisticView>(
                  key: const ValueKey('statistics-view-selector'),
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: _StatisticView.summary,
                      icon: const Icon(Icons.dashboard_outlined),
                      label: Text(context.l10n.projectStatsSummary),
                    ),
                    ButtonSegment(
                      value: _StatisticView.explore,
                      icon: const Icon(Icons.analytics_outlined),
                      label: Text(context.l10n.projectStatsExplore),
                    ),
                  ],
                  selected: {_view},
                  onSelectionChanged: (selection) {
                    setState(() => _view = selection.single);
                  },
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                // A fresh key per view opens each view scrolled to the top.
                key: ValueKey(_view),
                padding: const EdgeInsets.fromLTRB(
                  NahpuPageMargin.horizontal,
                  NahpuPageMargin.top,
                  NahpuPageMargin.horizontal,
                  NahpuPageMargin.bottom,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_view == _StatisticView.summary) ...[
                          CommonPadding(
                            child: _FullScreenRecordStatisticsSummary(
                              value: totals,
                              title: widget.allProjects
                                  ? context.l10n.projectStatsTotalAllProjects
                                  : null,
                              onRetry: () => ref.invalidate(
                                recordStatisticTotalsProvider(projectUuid),
                              ),
                            ),
                          ),
                          if (widget.allProjects) ...[
                            const SizedBox(height: NahpuSpacing.md),
                            const CommonPadding(
                              child: _ProjectBreakdownTable(),
                            ),
                          ],
                          const SizedBox(height: NahpuSpacing.xl),
                          _StatisticSummary(
                            projectUuid: projectUuid,
                            onExplore: _exploreSelection,
                          ),
                        ] else ...[
                          if (_detailSection == _DetailSection.spatial)
                            SpatialStatisticsPanel(
                              projectUuid: projectUuid,
                              projectName: projectName,
                              height: _exploreStatisticsCardHeight,
                              sectionSwitch: _DetailSectionSwitch(
                                selected: _detailSection,
                                onSelected: _selectDetailSection,
                              ),
                            )
                          else ...[
                            StatisticFilterPanel(
                              section: _DetailSectionSwitch(
                                selected: _detailSection,
                                onSelected: _selectDetailSection,
                              ),
                              selector: SegmentedButton<StatisticMeasure>(
                                key: const ValueKey(
                                  'statistics-measure-control',
                                ),
                                showSelectedIcon: false,
                                segments: [
                                  for (final measure in StatisticMeasure.values)
                                    ButtonSegment(
                                      value: measure,
                                      label: Text(
                                        measure.localizedLabel(context.l10n),
                                      ),
                                    ),
                                ],
                                selected: {_measure},
                                onSelectionChanged: (selection) =>
                                    _selectMeasure(
                                      selection.single,
                                      hasLifeStage,
                                    ),
                              ),
                              fields: [
                                StatisticDropdownField<StatisticGroup>(
                                  key: const ValueKey(
                                    'statistics-group-control',
                                  ),
                                  label: context.l10n.projectStatsGroupBy,
                                  values: _measure.groups(
                                    hasLifeStage: hasLifeStage,
                                  ),
                                  selected: _group,
                                  valueLabel: (value) =>
                                      value.localizedLabel(context.l10n),
                                  onSelected: (value) {
                                    setState(() {
                                      _group = value;
                                      _breakdown = null;
                                    });
                                  },
                                ),
                                if (_usesTaxonRank)
                                  StatisticDropdownField<StatisticTaxonRank>(
                                    key: const ValueKey(
                                      'statistics-taxon-rank-control',
                                    ),
                                    label: context.l10n.projectTaxonRankLabel,
                                    values: StatisticTaxonRank.groupable,
                                    selected: _rank,
                                    valueLabel: (value) =>
                                        value.localizedLabel(context.l10n),
                                    onSelected: (value) {
                                      setState(() => _rank = value);
                                    },
                                  ),
                                if (_canBreakDown)
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
                                if (_usesSiteFilter)
                                  SearchableStatisticFilterPicker(
                                    options: ref.watch(siteOptions),
                                    selected: _siteFilter,
                                    label: context.l10n.projectStatsSite,
                                    title: context.l10n.projectStatsSelectSite,
                                    placeholder:
                                        context.l10n.projectStatsAllSites,
                                    onChanged: (value) {
                                      setState(() => _siteFilter = value);
                                    },
                                    onRetry: () => ref.invalidate(siteOptions),
                                  ),
                                if (_usesSpeciesFilter)
                                  SearchableStatisticFilterPicker(
                                    options: ref.watch(speciesOptions),
                                    selected: _speciesFilter,
                                    label: context.l10n.projectTaxonSpecies,
                                    title:
                                        context.l10n.projectStatsSelectSpecies,
                                    placeholder:
                                        context.l10n.projectStatsAllSpecies,
                                    onChanged: (value) {
                                      setState(() => _speciesFilter = value);
                                    },
                                    onRetry: () =>
                                        ref.invalidate(speciesOptions),
                                  ),
                              ],
                            ),
                            const SizedBox(height: NahpuSpacing.xl),
                            Card(
                              clipBehavior: Clip.antiAlias,
                              shape: _plotCardShape,
                              child: SizedBox(
                                key: const ValueKey(
                                  'explore-statistics-content',
                                ),
                                height: _exploreStatisticsCardHeight,
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    NahpuSpacing.xl,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  request.localizedTitle(
                                                    context.l10n,
                                                    siteLabel: _usesSiteFilter
                                                        ? _siteFilter?.label
                                                        : null,
                                                    speciesLabel:
                                                        _usesSpeciesFilter
                                                        ? _speciesFilter?.label
                                                        : null,
                                                  ),
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,
                                                ),
                                                StatisticTotalLabel(
                                                  total: detailRows == null
                                                      ? null
                                                      : statisticTotal(
                                                          detailRows,
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SegmentedButton<_DetailMode>(
                                            showSelectedIcon: false,
                                            segments: [
                                              ButtonSegment(
                                                value: _DetailMode.chart,
                                                icon: const Icon(
                                                  Icons.bar_chart_rounded,
                                                ),
                                                label: Text(
                                                  context
                                                      .l10n
                                                      .projectStatsChart,
                                                ),
                                              ),
                                              ButtonSegment(
                                                value: _DetailMode.table,
                                                icon: const Icon(
                                                  Icons.table_rows_outlined,
                                                ),
                                                label: Text(
                                                  context
                                                      .l10n
                                                      .projectStatsTable,
                                                ),
                                              ),
                                            ],
                                            selected: {_detailMode},
                                            onSelectionChanged: (selection) {
                                              setState(
                                                () => _detailMode =
                                                    selection.single,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Expanded(
                                        child: _StatisticAsyncContent(
                                          value: details,
                                          onRetry: () => ref.invalidate(
                                            statisticDataProvider(request),
                                          ),
                                          builder: (rows) => Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              // Shown even when empty so the chart keeps
                                              // one height across selections.
                                              _ExploreMetricStrip(
                                                request: request,
                                                rows: rows,
                                              ),
                                              const SizedBox(
                                                height: NahpuSpacing.lg,
                                              ),
                                              Expanded(
                                                child: LayoutBuilder(
                                                  builder: (context, constraints) {
                                                    if (_detailMode ==
                                                        _DetailMode.chart) {
                                                      if (_isPieChartGroup(
                                                            request.group,
                                                          ) &&
                                                          request.breakdown ==
                                                              null) {
                                                        return StatisticChartSwitcher(
                                                          data: rows,
                                                          measure:
                                                              request.measure,
                                                          group: request.group,
                                                          rank: request.rank,
                                                          usePieByDefault:
                                                              _shouldUseStandalonePieChart(
                                                                request,
                                                                rows,
                                                              ),
                                                          height: constraints
                                                              .maxHeight,
                                                          fitHeight: true,
                                                          toggleKey: const ValueKey(
                                                            'statistics-detail-chart-toggle',
                                                          ),
                                                          onSelect: select,
                                                        );
                                                      }
                                                      return StatisticBarChart(
                                                        data: rows,
                                                        measure:
                                                            request.measure,
                                                        group: request.group,
                                                        rank: request.rank,
                                                        breakdown:
                                                            request.breakdown,
                                                        height: constraints
                                                            .maxHeight,
                                                        fitHeight: true,
                                                        onSelect: select,
                                                      );
                                                    }
                                                    final tableRows =
                                                        buildStatisticTableRows(
                                                          rows,
                                                        );
                                                    return StatisticDataTable(
                                                      rows: tableRows,
                                                      onSelect: select,
                                                      categoryLabel: request
                                                          .localizedCategoryLabel(
                                                            context.l10n,
                                                          ),
                                                      seriesLabel: request
                                                          .breakdown
                                                          ?.localizedLabel(
                                                            context.l10n,
                                                          ),
                                                      countLabel: request
                                                          .measure
                                                          .localizedCountLabel(
                                                            context.l10n,
                                                          ),
                                                      onExport:
                                                          tableRows.isEmpty
                                                          ? null
                                                          : () => showStatisticExportDialog(
                                                              context: context,
                                                              defaultFileName:
                                                                  _defaultFileName(
                                                                    projectName,
                                                                    request,
                                                                  ),
                                                              rows: tableRows,
                                                              categoryLabel: request
                                                                  .localizedCategoryLabel(
                                                                    context
                                                                        .l10n,
                                                                  ),
                                                              seriesLabel: request
                                                                  .breakdown
                                                                  ?.localizedLabel(
                                                                    context
                                                                        .l10n,
                                                                  ),
                                                              countLabel: request
                                                                  .measure
                                                                  .localizedCountLabel(
                                                                    context
                                                                        .l10n,
                                                                  ),
                                                            ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _usesTaxonRank => _group == StatisticGroup.taxonRank;

  bool get _usesSiteFilter =>
      _measure == StatisticMeasure.specimens &&
      _group == StatisticGroup.species;

  bool get _usesSpeciesFilter => _measure == StatisticMeasure.partQuantity;

  bool get _canBreakDown =>
      _measure == StatisticMeasure.specimens &&
      _group == StatisticGroup.species;

  void _selectDetailSection(_DetailSection section) {
    setState(() => _detailSection = section);
  }

  void _selectMeasure(StatisticMeasure measure, bool hasLifeStage) {
    setState(() {
      _measure = measure;
      _group = measure.groups(hasLifeStage: hasLifeStage).first;
      _breakdown = null;
    });
  }

  /// Opens the Explore counts on [selection], as picked from a summary card.
  void _exploreSelection(StatisticSelection selection) {
    setState(() {
      _measure = selection.measure;
      _group = selection.group;
      _rank = selection.rank ?? _rank;
      _breakdown = selection.breakdown;
      _view = _StatisticView.explore;
      _detailSection = _DetailSection.counts;
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
    this.title,
  });

  final AsyncValue<RecordStatisticTotals> value;
  final VoidCallback onRetry;

  /// Heading above the summary groups, or none.
  final String? title;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (totals) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(title!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: NahpuSpacing.sm),
          ],
          _FullScreenRecordStatisticsCard(totals: totals),
        ],
      ),
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
              Text(context.l10n.projectStatsRecordLoadError('$error')),
              const SizedBox(height: NahpuSpacing.md),
              TextButton(
                onPressed: onRetry,
                child: Text(context.l10n.commonRetry),
              ),
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
          key: const ValueKey('full-screen-record-stat-record-summary'),
          title: context.l10n.projectStatsRecordSummary,
          children: [
            _SummaryMetric(
              key: RecordMetricKind.specimens.fullScreenKey,
              kind: RecordMetricKind.specimens,
              value: totals.specimenCount.toString(),
              emphasis: true,
            ),
            _SummaryMetric(
              key: RecordMetricKind.specimenParts.fullScreenKey,
              kind: RecordMetricKind.specimenParts,
              value: totals.specimenPartCount.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.narratives.fullScreenKey,
              kind: RecordMetricKind.narratives,
              value: totals.narrativeCount.toString(),
            ),
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
              value: _formatProjectDays(context.l10n, totals.totalDays),
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
        const SizedBox(height: NahpuSpacing.md),
        _SummaryGroup(
          key: const ValueKey('full-screen-record-stat-taxonomy'),
          title: context.l10n.projectStatsTaxonomicBreakdown,
          children: [
            _SummaryMetric(
              key: RecordMetricKind.classes.fullScreenKey,
              kind: RecordMetricKind.classes,
              value: totals.classCount.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.orders.fullScreenKey,
              kind: RecordMetricKind.orders,
              value: totals.orderCount.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.families.fullScreenKey,
              kind: RecordMetricKind.families,
              value: totals.familyCount.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.genera.fullScreenKey,
              kind: RecordMetricKind.genera,
              value: totals.genusCount.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.species.fullScreenKey,
              kind: RecordMetricKind.species,
              value: totals.speciesCount.toString(),
            ),
          ],
        ),
        const SizedBox(height: NahpuSpacing.md),
        _SummaryGroup(
          key: const ValueKey('full-screen-record-stat-media-breakdown'),
          title: context.l10n.projectStatsMediaBreakdown,
          children: [
            _SummaryMetric(
              key: RecordMetricKind.media.fullScreenKey,
              kind: RecordMetricKind.media,
              value: totals.mediaCount.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.specimenMedia.fullScreenKey,
              kind: RecordMetricKind.specimenMedia,
              value: totals.specimenMediaCount.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.siteMedia.fullScreenKey,
              kind: RecordMetricKind.siteMedia,
              value: totals.siteMediaCount.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.eventMedia.fullScreenKey,
              kind: RecordMetricKind.eventMedia,
              value: totals.eventMediaCount.toString(),
            ),
            _SummaryMetric(
              key: RecordMetricKind.narrativeMedia.fullScreenKey,
              kind: RecordMetricKind.narrativeMedia,
              value: totals.narrativeMediaCount.toString(),
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
      label: '${kind.localizedLabel(context.l10n)}: $value',
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
                kind.icon!,
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
                    kind.localizedLabel(context.l10n),
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

/// Each project's record totals, listed under the database-wide summary.
class _ProjectBreakdownTable extends ConsumerWidget {
  const _ProjectBreakdownTable();

  static const _rowsPerPage = 4;

  static const _metrics = [
    RecordMetricKind.specimens,
    RecordMetricKind.specimenParts,
    RecordMetricKind.species,
    RecordMetricKind.families,
    RecordMetricKind.recordedSites,
    RecordMetricKind.events,
    RecordMetricKind.narratives,
    RecordMetricKind.media,
    RecordMetricKind.captureDays,
    RecordMetricKind.projectDays,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      key: const ValueKey('full-screen-record-stat-per-project'),
      padding: const EdgeInsets.all(NahpuSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(NahpuRadius.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.projectStatsPerProject,
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: NahpuSpacing.sm),
          ref
              .watch(projectRecordTotalsProvider)
              .when(
                data: (projects) => projects.isEmpty
                    ? Text(context.l10n.projectStatsNoProjects)
                    : PaginatedDataTable(
                        rowsPerPage: _rowsPerPage,
                        showEmptyRows: false,
                        columns: [
                          DataColumn(
                            label: Text(context.l10n.labelTableProject),
                          ),
                          for (final metric in _metrics)
                            DataColumn(
                              label: Text(metric.localizedLabel(context.l10n)),
                              numeric: true,
                            ),
                        ],
                        source: _ProjectBreakdownDataSource(
                          l10n: context.l10n,
                          projects: projects,
                          metrics: _metrics,
                        ),
                      ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(NahpuSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.l10n.projectStatsProjectLoadError('$error')),
                    const SizedBox(height: NahpuSpacing.md),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(projectRecordTotalsProvider),
                      child: Text(context.l10n.commonRetry),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

/// One row per project for [_ProjectBreakdownTable].
class _ProjectBreakdownDataSource extends DataTableSource {
  _ProjectBreakdownDataSource({
    required this.l10n,
    required this.projects,
    required this.metrics,
  });

  final AppLocalizations l10n;
  final List<ProjectRecordTotals> projects;
  final List<RecordMetricKind> metrics;

  @override
  DataRow? getRow(int index) {
    if (index >= projects.length) return null;
    final project = projects[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(project.projectName)),
        for (final metric in metrics)
          DataCell(Text(_value(l10n, metric, project.totals))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => projects.length;

  @override
  int get selectedRowCount => 0;

  String _value(
    AppLocalizations l10n,
    RecordMetricKind metric,
    RecordStatisticTotals totals,
  ) => switch (metric) {
    RecordMetricKind.specimens => totals.specimenCount.toString(),
    RecordMetricKind.specimenParts => totals.specimenPartCount.toString(),
    RecordMetricKind.species => totals.speciesCount.toString(),
    RecordMetricKind.families => totals.familyCount.toString(),
    RecordMetricKind.recordedSites => totals.recordedSiteCount.toString(),
    RecordMetricKind.events => totals.eventCount.toString(),
    RecordMetricKind.narratives => totals.narrativeCount.toString(),
    RecordMetricKind.media => totals.mediaCount.toString(),
    RecordMetricKind.captureDays => totals.totalCaptureDays.toString(),
    RecordMetricKind.projectDays => _formatProjectDays(l10n, totals.totalDays),
    _ => '',
  };
}

class _StatisticSummary extends StatelessWidget {
  const _StatisticSummary({required this.projectUuid, required this.onExplore});

  final String? projectUuid;
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
            for (final definition in _summaryDefinitions(context.l10n))
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

  final String? projectUuid;
  final _SummaryDefinition definition;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Every category is loaded so N counts the whole project; the charts
    // show only the top ones.
    final request = StatisticRequest(
      projectUuid: projectUuid,
      measure: definition.selection.measure,
      group: definition.selection.group,
      rank: definition.selection.rank,
    );
    final value = ref.watch(statisticDataProvider(request));
    final rows = value.value;
    void select(String label, String? series) => openStatisticRecords(
      context,
      ref,
      request,
      label: label,
      seriesLabel: series,
    );
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: _plotCardShape,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        definition.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      StatisticTotalLabel(
                        total: rows == null ? null : statisticTotal(rows),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onExplore,
                  child: Text(context.l10n.projectStatsViewDetails),
                ),
              ],
            ),
            SizedBox(
              height: _summaryChartHeight,
              child: _StatisticAsyncContent(
                value: value,
                onRetry: () => ref.invalidate(statisticDataProvider(request)),
                builder: (rows) {
                  if (_isPieChartGroup(request.group)) {
                    return StatisticChartSwitcher(
                      data: rows
                          .take(topStatisticCount)
                          .toList(growable: false),
                      measure: request.measure,
                      group: request.group,
                      rank: request.rank,
                      usePieByDefault: _shouldUseStandalonePieChart(
                        request,
                        rows,
                      ),
                      compact: true,
                      height: _summaryChartHeight,
                      fitHeight: true,
                      toggleKey: ValueKey(
                        'statistics-summary-chart-toggle-${request.group.name}',
                      ),
                      onSelect: select,
                    );
                  }
                  return StatisticBarChart(
                    data: rows.take(topStatisticCount).toList(growable: false),
                    measure: request.measure,
                    group: request.group,
                    rank: request.rank,
                    compact: true,
                    height: _summaryChartHeight,
                    onSelect: select,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Headline numbers shown above the Explore count chart and table, matching
/// the strip above the spatial map.
class _ExploreMetricStrip extends StatelessWidget {
  const _ExploreMetricStrip({required this.request, required this.rows});

  final StatisticRequest request;
  final List<StatisticDatum> rows;

  @override
  Widget build(BuildContext context) {
    final summary = StatisticDataSummary.fromData(rows);
    final l10n = context.l10n;
    final categoryLabel = request.localizedCategoryLabel(l10n).toLowerCase();
    final top = summary.topLabel;
    return StatisticMetricStrip(
      key: const ValueKey('explore-statistics-metrics'),
      tiles: [
        StatisticMetricTile(
          value: '${summary.categoryCount}',
          label: l10n.projectStatsCategoryCount(
            summary.categoryCount,
            categoryLabel,
          ),
        ),
        StatisticMetricTile(
          value: summary.average.toStringAsFixed(1),
          label: l10n.projectStatsMeanPerCategory(
            request.measure.localizedCountLabel(l10n).toLowerCase(),
          ),
        ),
        StatisticMetricTile(
          value: top == null ? '—' : '${summary.topCount}',
          label: top == null
              ? l10n.projectStatsTopCategory
              : l10n.projectStatsTopValue(top),
        ),
        StatisticMetricTile(
          value: top == null ? '—' : '${summary.topShare.toStringAsFixed(1)}%',
          label: l10n.projectStatsTopCategoryShare,
        ),
      ],
    );
  }
}

/// Switches Explore between count and spatial statistics.
class _DetailSectionSwitch extends StatelessWidget {
  const _DetailSectionSwitch({
    required this.selected,
    required this.onSelected,
  });

  final _DetailSection selected;
  final ValueChanged<_DetailSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_DetailSection>(
      key: const ValueKey('statistics-detail-section-control'),
      showSelectedIcon: false,
      segments: [
        for (final section in _DetailSection.values)
          ButtonSegment(
            value: section,
            icon: Icon(section.icon),
            label: Text(section.localizedLabel(context.l10n)),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (selection) => onSelected(selection.single),
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
    return StatisticDropdownField<_BreakdownChoice>(
      label: context.l10n.projectStatsBreakDownBy,
      values: [
        _BreakdownChoice.none,
        if (hasSex) _BreakdownChoice.sex,
        if (hasLifeStage) _BreakdownChoice.lifeStage,
      ],
      selected: _BreakdownChoice.of(selected),
      valueLabel: (value) => value.localizedLabel(context.l10n),
      onSelected: (value) => onSelected(value.breakdown),
    );
  }
}

/// [StatisticBreakdown] choices plus None, so the dropdown never holds null.
enum _BreakdownChoice {
  none(null),
  sex(StatisticBreakdown.sex),
  lifeStage(StatisticBreakdown.lifeStage);

  const _BreakdownChoice(this.breakdown);

  final StatisticBreakdown? breakdown;

  String localizedLabel(AppLocalizations l10n) =>
      breakdown?.localizedLabel(l10n) ?? l10n.projectPersonnelRoleNone;

  static _BreakdownChoice of(StatisticBreakdown? breakdown) =>
      values.firstWhere((choice) => choice.breakdown == breakdown);
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
            Text(context.l10n.projectStatsLoadError('$error')),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.commonRetry),
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

List<_SummaryDefinition> _summaryDefinitions(AppLocalizations l10n) => [
  _SummaryDefinition(
    title: l10n.projectStatsSpecimensBySpecies,
    selection: StatisticSelection(
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.species,
    ),
  ),
  _SummaryDefinition(
    title: l10n.projectStatsSpecimensByFamily,
    selection: StatisticSelection(
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.taxonRank,
      rank: StatisticTaxonRank.family,
    ),
  ),
  _SummaryDefinition(
    title: l10n.projectStatsSpecimensBySite,
    selection: StatisticSelection(
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.site,
    ),
  ),
  _SummaryDefinition(
    title: l10n.projectStatsSpecimensByDate,
    selection: StatisticSelection(
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.date,
    ),
  ),
  _SummaryDefinition(
    title: l10n.projectStatsSpecimensByMethod,
    selection: StatisticSelection(
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.method,
    ),
  ),
  _SummaryDefinition(
    title: l10n.projectStatsSpecimensBySex,
    selection: StatisticSelection(
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.sex,
    ),
  ),
  _SummaryDefinition(
    title: l10n.projectStatsPartQuantityByType,
    selection: StatisticSelection(
      measure: StatisticMeasure.partQuantity,
      group: StatisticGroup.partType,
    ),
  ),
  _SummaryDefinition(
    title: l10n.projectStatsPartQuantityByTreatment,
    selection: StatisticSelection(
      measure: StatisticMeasure.partQuantity,
      group: StatisticGroup.partTreatment,
    ),
  ),
];

/// Top-level view of the full-screen record statistics page.
/// Borderless shape for statistics plot cards.
const _plotCardShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(NahpuRadius.md)),
);

enum _StatisticView { summary, explore }

/// Which statistics the Explore view is showing.
enum _DetailSection {
  counts(Icons.format_list_numbered_rounded),
  spatial(Icons.public_outlined);

  const _DetailSection(this.icon);

  final IconData icon;

  String localizedLabel(AppLocalizations l10n) => switch (this) {
    counts => l10n.projectStatsCounts,
    spatial => l10n.projectStatsSpatial,
  };
}

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
