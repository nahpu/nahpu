import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/statistics/charts.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics.dart';
import 'package:nahpu/screens/projects/statistics/statistics_table.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/statistics.dart';
import 'package:nahpu/services/types/statistics.dart';

const int topStatisticCount = 5;

class StatisticViewer extends ConsumerWidget {
  const StatisticViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectUuid = ref.watch(projectUuidProvider);
    final request = StatisticRequest(
      projectUuid: projectUuid,
      kind: StatisticKind.species,
      limit: topStatisticCount,
    );
    final data = ref.watch(statisticDataProvider(request));

    return FormCard(
      title: 'Statistics',
      mainAxisAlignment: MainAxisAlignment.start,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360, maxWidth: 460),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Top species',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: _StatisticAsyncContent(
                value: data,
                onRetry: () => ref.invalidate(statisticDataProvider(request)),
                builder: (rows) => StatisticBarChart(
                  data: rows,
                  kind: StatisticKind.species,
                  compact: true,
                  height: 240,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: PrimaryButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatisticFullScreen(
                      startingStatistic: StatisticKind.species,
                    ),
                  ),
                ),
                icon: Icons.analytics_outlined,
                label: 'Open statistics',
              ),
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Top five categories across the current project.',
                    style: Theme.of(context).textTheme.bodyMedium,
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
                            _StatisticFilterPicker(
                              kind: _selectedStatistic,
                              selected: selectedFilter,
                              onChanged: (value) {
                                setState(() {
                                  if (value == null) {
                                    _filters.remove(_selectedStatistic);
                                  } else {
                                    _filters[_selectedStatistic] = value;
                                  }
                                });
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedStatistic.title,
                                  style: Theme.of(context).textTheme.titleLarge,
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
                                      () => _detailMode = selection.single);
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
                  SpatialStatisticsPanel(projectUuid: projectUuid),
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

  String _defaultFileName(
    String projectName,
    StatisticFilterOption? filter,
  ) {
    final now = DateTime.now();
    final date = '${now.year.toString().padLeft(4, '0')}'
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
  const _StatisticSummary({
    required this.projectUuid,
    required this.onExplore,
  });

  final String projectUuid;
  final ValueChanged<StatisticKind> onExplore;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumnBreakpoint = StatisticBarChart.minimumWidth(
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
      elevation: 0,
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

class _StatisticFilterPicker extends ConsumerWidget {
  const _StatisticFilterPicker({
    required this.kind,
    required this.selected,
    required this.onChanged,
  });

  final StatisticKind kind;
  final StatisticFilterOption? selected;
  final ValueChanged<StatisticFilterOption?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(statisticFilterOptionsProvider(kind));
    return options.when(
      data: (items) => Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: items.isEmpty
                  ? null
                  : () async {
                      final result =
                          await showModalBottomSheet<StatisticFilterOption>(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (context) => _StatisticFilterSheet(
                          title: kind.needsSite
                              ? 'Select a site'
                              : 'Select a species',
                          options: items,
                        ),
                      );
                      if (result != null) onChanged(result);
                    },
              icon: const Icon(Icons.search_rounded),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  selected?.label ??
                      (kind.needsSite ? 'Select a site' : 'Select a species'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (selected != null)
            IconButton(
              tooltip: 'Clear selection',
              onPressed: () => onChanged(null),
              icon: const Icon(Icons.clear_rounded),
            ),
        ],
      ),
      loading: () => const LinearProgressIndicator(),
      error: (error, stackTrace) => Row(
        children: [
          Expanded(child: Text('Unable to load choices: $error')),
          IconButton(
            tooltip: 'Retry',
            onPressed: () =>
                ref.invalidate(statisticFilterOptionsProvider(kind)),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _StatisticFilterSheet extends StatefulWidget {
  const _StatisticFilterSheet({
    required this.title,
    required this.options,
  });

  final String title;
  final List<StatisticFilterOption> options;

  @override
  State<_StatisticFilterSheet> createState() => _StatisticFilterSheetState();
}

class _StatisticFilterSheetState extends State<_StatisticFilterSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options
        .where(
          (option) => option.label.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList(growable: false);
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SearchBar(
                controller: _searchController,
                hintText: 'Search',
                leading: const Icon(Icons.search_rounded),
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 8),
                ),
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.45),
                ),
                trailing: [
                  if (_query.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
                ],
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No matching choices'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final option = filtered[index];
                          return ListTile(
                            title: Text(option.label),
                            onTap: () => Navigator.pop(context, option),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
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
