import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/statistics/charts.dart';
import 'package:nahpu/screens/projects/statistics/searchable_statistic_filter.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics.dart';
import 'package:nahpu/screens/projects/statistics/statistics_table.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/statistics.dart';
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
                startingStatistic: StatisticKind.species,
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
    final primaryForeground = colorScheme.onPrimaryContainer;
    final primaryBackground = colorScheme.primaryContainer.withValues(
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
            color: primaryBackground,
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
                ).textTheme.headlineLarge?.copyWith(color: primaryForeground),
              ),
              Text(
                'Specimens',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: primaryForeground),
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
                      foregroundColor: primaryForeground,
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
                      foregroundColor: primaryForeground,
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
    this.startingStatistic = StatisticKind.species,
  });

  final StatisticKind startingStatistic;

  @override
  ConsumerState<StatisticFullScreen> createState() =>
      _StatisticFullScreenState();
}

class _StatisticFullScreenState extends ConsumerState<StatisticFullScreen> {
  final _detailKey = GlobalKey();
  final _filters = <StatisticKind, StatisticFilterOption>{};
  StatisticKind _selectedStatistic = StatisticKind.species;
  _DetailMode _detailMode = _DetailMode.chart;

  @override
  void initState() {
    super.initState();
    _selectedStatistic = widget.startingStatistic;
  }

  @override
  Widget build(BuildContext context) {
    final projectUuid = ref.watch(projectUuidProvider);
    final selectedFilter = _filters[_selectedStatistic];
    final request = StatisticRequest(
      projectUuid: projectUuid,
      kind: _selectedStatistic,
      filterId: selectedFilter?.id,
    );
    final details = ref.watch(statisticDataProvider(request));
    final projectName = ref.watch(currProjInfoProvider).value?.name ?? 'NAHPU';

    return Scaffold(
      appBar: AppBar(title: const Text('Project Statistics')),
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
                    child: Text(
                      'Summary',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CommonPadding(
                    child: Text(
                      'Top five categories across the current project.',
                      style: Theme.of(context).textTheme.bodyMedium,
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Detailed statistics',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          _StatisticKindPicker(
                            selected: _selectedStatistic,
                            onSelected: (kind) {
                              setState(() => _selectedStatistic = kind);
                            },
                          ),
                          if (_selectedStatistic.needsSite ||
                              _selectedStatistic.needsTaxon) ...[
                            const SizedBox(height: 12),
                            SearchableStatisticFilterPicker(
                              options: ref.watch(
                                statisticFilterOptionsProvider(
                                  _selectedStatistic,
                                ),
                              ),
                              selected: selectedFilter,
                              title: _selectedStatistic.needsSite
                                  ? 'Select a site'
                                  : 'Select a species',
                              placeholder: _selectedStatistic.needsSite
                                  ? 'Select a site'
                                  : 'Select a species',
                              onChanged: (value) {
                                setState(() {
                                  if (value == null) {
                                    _filters.remove(_selectedStatistic);
                                  } else {
                                    _filters[_selectedStatistic] = value;
                                  }
                                });
                              },
                              onRetry: () => ref.invalidate(
                                statisticFilterOptionsProvider(
                                  _selectedStatistic,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedStatistic.title,
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
                          if (!request.isReady)
                            _FilterPrompt(kind: _selectedStatistic)
                          else
                            _StatisticAsyncContent(
                              value: details,
                              onRetry: () => ref.invalidate(
                                statisticDataProvider(request),
                              ),
                              builder: (rows) {
                                if (_detailMode == _DetailMode.chart) {
                                  return StatisticBarChart(
                                    data: rows,
                                    kind: _selectedStatistic,
                                    height: 420,
                                  );
                                }
                                final tableRows = buildStatisticTableRows(rows);
                                return StatisticDataTable(
                                  rows: tableRows,
                                  onExport: tableRows.isEmpty
                                      ? null
                                      : () => showStatisticExportDialog(
                                          context: context,
                                          defaultFileName: _defaultFileName(
                                            projectName,
                                            selectedFilter,
                                          ),
                                          rows: tableRows,
                                        ),
                                );
                              },
                            ),
                        ],
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

  void _selectAndReveal(StatisticKind kind) {
    setState(() => _selectedStatistic = kind);
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

  String _defaultFileName(String projectName, StatisticFilterOption? filter) {
    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final components = [
      projectName,
      _selectedStatistic.fileSlug,
      if (filter != null) filter.label,
      date,
    ];
    return components
        .join('_')
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}

class _StatisticSummary extends StatelessWidget {
  const _StatisticSummary({required this.projectUuid, required this.onExplore});

  final String projectUuid;
  final ValueChanged<StatisticKind> onExplore;

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
            for (final kind in summaryStatisticKinds)
              SizedBox(
                width: cardWidth,
                child: _StatisticSummaryCard(
                  projectUuid: projectUuid,
                  kind: kind,
                  onExplore: () => onExplore(kind),
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
    required this.kind,
    required this.onExplore,
  });

  final String projectUuid;
  final StatisticKind kind;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = StatisticRequest(
      projectUuid: projectUuid,
      kind: kind,
      limit: topStatisticCount,
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
                    'Top ${kind.label.toLowerCase()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton(onPressed: onExplore, child: const Text('Explore')),
              ],
            ),
            _StatisticAsyncContent(
              value: value,
              onRetry: () => ref.invalidate(statisticDataProvider(request)),
              builder: (rows) => StatisticBarChart(
                data: rows,
                kind: kind,
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

class _StatisticKindPicker extends StatelessWidget {
  const _StatisticKindPicker({
    required this.selected,
    required this.onSelected,
  });

  final StatisticKind selected;
  final ValueChanged<StatisticKind> onSelected;

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (final kind in StatisticKind.values)
        ChoiceChip(
          label: Text(kind.label),
          selected: selected == kind,
          onSelected: (_) => onSelected(kind),
        ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          return Wrap(spacing: 8, runSpacing: 8, children: chips);
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(spacing: 8, children: chips),
        );
      },
    );
  }
}

class _FilterPrompt extends StatelessWidget {
  const _FilterPrompt({required this.kind});

  final StatisticKind kind;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Text(
          kind.needsSite
              ? 'Select a site to view species counts.'
              : 'Select a species to view part quantities.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
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

enum _DetailMode { chart, table }
