import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/charts.dart';
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

class StatisticViewer extends ConsumerWidget {
  const StatisticViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = ref.watch(recordStatisticTotalsProvider);

    return FormCard(
      title: 'Record Statistics',
      infoTopic: InfoTopic.recordStatistics,
      mainAxisAlignment: MainAxisAlignment.start,
      child: DashboardPanelBody(
        contentAlignment: Alignment.center,
        content: totals.when(
          data: (value) => _RecordStatisticsSummary(totals: value),
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

class _RecordStatisticsSummary extends StatelessWidget {
  const _RecordStatisticsSummary({required this.totals});

  final RecordStatisticTotals totals;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryForeground = colorScheme.onSecondaryContainer;
    final secondaryBackground = colorScheme.secondaryContainer.withValues(
      alpha: 0.16,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: const ValueKey('record-stat-specimens'),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            NahpuSpacing.lg,
            NahpuSpacing.xl,
            NahpuSpacing.lg,
            NahpuSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: secondaryBackground,
            borderRadius: BorderRadius.circular(NahpuRadius.md),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                totals.specimenCount.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(color: secondaryForeground),
              ),
              Text(
                'Specimens',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: secondaryForeground),
              ),
              const SizedBox(height: NahpuSpacing.md),
              Container(
                width: double.infinity,
                height: NahpuStroke.thin,
                color: colorScheme.outlineVariant,
              ),
              const SizedBox(height: NahpuSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _RecordStatisticMetric(
                      key: const ValueKey('record-stat-species'),
                      label: 'Species',
                      count: totals.speciesCount,
                      countStyle: Theme.of(context).textTheme.titleLarge,
                      labelStyle: Theme.of(context).textTheme.bodyMedium,
                      foregroundColor: secondaryForeground,
                    ),
                  ),
                  Container(
                    width: NahpuStroke.thin,
                    height: NahpuControlSize.touchTarget,
                    color: colorScheme.outlineVariant,
                  ),
                  Expanded(
                    child: _RecordStatisticMetric(
                      key: const ValueKey('record-stat-families'),
                      label: 'Families',
                      count: totals.familyCount,
                      countStyle: Theme.of(context).textTheme.titleLarge,
                      labelStyle: Theme.of(context).textTheme.bodyMedium,
                      foregroundColor: secondaryForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        Container(
          key: const ValueKey('record-stat-secondary'),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            0,
            NahpuSpacing.lg,
            0,
            NahpuSpacing.md,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(NahpuRadius.md),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _RecordStatisticMetric(
                  key: const ValueKey('record-stat-sites'),
                  label: 'Sites',
                  count: totals.siteCount,
                  countStyle: Theme.of(context).textTheme.titleMedium,
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                  foregroundColor: colorScheme.onSurface,
                ),
              ),
              Container(
                width: NahpuStroke.thin,
                height: NahpuControlSize.control,
                color: colorScheme.outlineVariant,
              ),
              Expanded(
                child: _RecordStatisticMetric(
                  key: const ValueKey('record-stat-events'),
                  label: 'Events',
                  count: totals.eventCount,
                  countStyle: Theme.of(context).textTheme.titleMedium,
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                  foregroundColor: colorScheme.onSurface,
                ),
              ),
              Container(
                width: NahpuStroke.thin,
                height: NahpuControlSize.control,
                color: colorScheme.outlineVariant,
              ),
              Expanded(
                child: _RecordStatisticMetric(
                  key: const ValueKey('record-stat-narratives'),
                  label: 'Narratives',
                  count: totals.narrativeCount,
                  countStyle: Theme.of(context).textTheme.titleMedium,
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                  foregroundColor: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecordStatisticMetric extends StatelessWidget {
  const _RecordStatisticMetric({
    super.key,
    required this.label,
    required this.count,
    required this.countStyle,
    required this.labelStyle,
    required this.foregroundColor,
  });

  final String label;
  final int count;
  final TextStyle? countStyle;
  final TextStyle? labelStyle;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$label: $count',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.xxs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count.toString(),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: countStyle?.copyWith(color: foregroundColor),
            ),
            const SizedBox(height: NahpuSpacing.xxs),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: labelStyle?.copyWith(color: foregroundColor),
            ),
          ],
        ),
      ),
    );
  }
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
  static const _wideSummaryGroupHeight = 280.0;

  const _FullScreenRecordStatisticsCard({required this.totals});

  final RecordStatisticTotals totals;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('full-screen-record-stat-summary'),
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final records = _SummaryGroup(
              key: const ValueKey('full-screen-record-stat-records'),
              title: 'Records',
              children: [
                _SummaryMetric(
                  key: const ValueKey('full-screen-record-stat-specimens'),
                  label: 'Specimens',
                  value: totals.specimenCount.toString(),
                  emphasis: true,
                ),
                _SummaryMetric(
                  key: const ValueKey('full-screen-record-stat-species'),
                  label: 'Species',
                  value: totals.speciesCount.toString(),
                ),
                _SummaryMetric(
                  key: const ValueKey('full-screen-record-stat-families'),
                  label: 'Families',
                  value: totals.familyCount.toString(),
                ),
                _SummaryMetric(
                  key: const ValueKey('full-screen-record-stat-narratives'),
                  label: 'Narratives',
                  value: totals.narrativeCount.toString(),
                ),
              ],
            );
            final sampling = _SummaryGroup(
              key: const ValueKey('full-screen-record-stat-sampling'),
              title: 'Sampling',
              children: [
                _SummaryMetric(
                  key: const ValueKey('full-screen-record-stat-sites'),
                  label: 'Sites',
                  value: totals.siteCount.toString(),
                ),
                _SummaryMetric(
                  key: const ValueKey('full-screen-record-stat-events'),
                  label: 'Events',
                  value: totals.eventCount.toString(),
                ),
                _SummaryMetric(
                  key: const ValueKey('full-screen-record-stat-capture-days'),
                  label: 'Capture days',
                  value: totals.totalCaptureDays.toString(),
                ),
                if (totals.totalDays != null)
                  _SummaryMetric(
                    key: const ValueKey('full-screen-record-stat-total-days'),
                    label: 'Project days',
                    value: totals.totalDays.toString(),
                  ),
                _SummaryMetric(
                  key: const ValueKey('full-screen-record-stat-elevation'),
                  label: 'Site elevation',
                  value: _formatElevationRange(totals),
                  wide: true,
                ),
              ],
            );
            if (constraints.maxWidth >= 760) {
              return SizedBox(
                height: _wideSummaryGroupHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: records),
                    const SizedBox(width: NahpuSpacing.md),
                    Expanded(child: sampling),
                  ],
                ),
              );
            }
            return Column(
              children: [
                records,
                const SizedBox(height: NahpuSpacing.md),
                sampling,
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatElevationRange(RecordStatisticTotals totals) {
    final minimum = totals.minimumElevationInMeter;
    final maximum = totals.maximumElevationInMeter;
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
              final spacing = NahpuSpacing.xs;
              final standardWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final metric in children)
                    SizedBox(
                      width: metric.wide ? constraints.maxWidth : standardWidth,
                      child: metric,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    super.key,
    required this.label,
    required this.value,
    this.emphasis = false,
    this.wide = false,
  });

  final String label;
  final String value;
  final bool emphasis;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: '$label: $value',
      child: Container(
        constraints: const BoxConstraints(minHeight: 68),
        padding: const EdgeInsets.symmetric(
          horizontal: NahpuSpacing.sm,
          vertical: NahpuSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: emphasis
              ? colorScheme.secondaryContainer.withValues(alpha: 0.35)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(NahpuRadius.sm),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: emphasis
                  ? Theme.of(context).textTheme.headlineSmall
                  : Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: NahpuSpacing.xxs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
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
    final request = StatisticRequest(
      projectUuid: projectUuid,
      measure: definition.selection.measure,
      group: definition.selection.group,
      limit: definition.isPie ? null : topStatisticCount,
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
              builder: (rows) => definition.isPie
                  ? StatisticPieChart(data: rows, height: 280)
                  : StatisticBarChart(
                      data: rows,
                      measure: request.measure,
                      group: request.group,
                      compact: true,
                      height: 280,
                    ),
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
  const _SummaryDefinition({
    required this.title,
    required this.selection,
    this.isPie = false,
  });

  final String title;
  final StatisticSelection selection;
  final bool isPie;
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
  _SummaryDefinition(
    title: 'Specimens by sex',
    selection: StatisticSelection(
      measure: StatisticMeasure.specimens,
      group: StatisticGroup.sex,
    ),
    isPie: true,
  ),
];

enum _DetailMode { chart, table }
