import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_map.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_table.dart';
import 'package:nahpu/screens/projects/statistics/searchable_statistic_filter.dart';
import 'package:nahpu/services/providers/statistics.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/services/types/statistics.dart';

class SpatialStatisticsPanel extends ConsumerStatefulWidget {
  const SpatialStatisticsPanel({super.key, required this.projectUuid});

  final String projectUuid;

  @override
  ConsumerState<SpatialStatisticsPanel> createState() =>
      _SpatialStatisticsPanelState();
}

class _SpatialStatisticsPanelState
    extends ConsumerState<SpatialStatisticsPanel> {
  SpatialStatisticKind _selectedKind = SpatialStatisticKind.coordinate;
  _SpatialStatisticMode _mode = _SpatialStatisticMode.map;
  StatisticFilterOption? _selectedSpecies;

  @override
  void didUpdateWidget(covariant SpatialStatisticsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectUuid != widget.projectUuid) {
      _selectedSpecies = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = SpatialStatisticRequest(
      projectUuid: widget.projectUuid,
      kind: _selectedKind,
      speciesId: _selectedSpecies?.id,
    );
    final data = ref.watch(spatialStatisticDataProvider(request));
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Spatial statistics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _SpatialKindPicker(
              selected: _selectedKind,
              onSelected: (kind) => setState(() => _selectedKind = kind),
            ),
            if (_selectedKind.needsSpecies) ...[
              const SizedBox(height: 12),
              SearchableStatisticFilterPicker(
                options: ref.watch(
                  spatialSpeciesFilterOptionsProvider(widget.projectUuid),
                ),
                selected: _selectedSpecies,
                title: 'Select a species',
                placeholder: 'Select a species',
                onChanged: (value) {
                  setState(() => _selectedSpecies = value);
                },
                onRetry: () => ref.invalidate(
                  spatialSpeciesFilterOptionsProvider(widget.projectUuid),
                ),
              ),
            ],
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final title = Text(
                  _selectedKind.needsSpecies && _selectedSpecies != null
                      ? '${_selectedSpecies!.label} counts by coordinates'
                      : _selectedKind.title,
                  style: Theme.of(context).textTheme.titleLarge,
                );
                final selector = SegmentedButton<_SpatialStatisticMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: _SpatialStatisticMode.map,
                      icon: Icon(Icons.map_outlined),
                      label: Text('Map'),
                    ),
                    ButtonSegment(
                      value: _SpatialStatisticMode.table,
                      icon: Icon(Icons.table_rows_outlined),
                      label: Text('Table'),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) {
                    setState(() => _mode = selection.single);
                  },
                );
                if (constraints.maxWidth >= 620) {
                  return Row(
                    children: [
                      Expanded(child: title),
                      selector,
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 8), selector],
                );
              },
            ),
            const SizedBox(height: 12),
            if (!request.isReady)
              const _SpatialSpeciesPrompt()
            else
              data.when(
                data: (rows) => _buildContent(rows),
                loading: () => const SizedBox(
                  height: 320,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => SizedBox(
                  height: 320,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Unable to load spatial statistics: $error'),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => ref.invalidate(
                            spatialStatisticDataProvider(request),
                          ),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<SpatialStatisticDatum> rows) {
    if (_mode == _SpatialStatisticMode.map) {
      return SpatialStatisticsMap(kind: _selectedKind, rows: rows);
    }
    if (rows.isNotEmpty) {
      return SpatialStatisticsTable(kind: _selectedKind, rows: rows);
    }
    return SizedBox(
      height: 220,
      child: Center(
        child: Text(
          _emptyMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  String get _emptyMessage => switch (_selectedKind) {
    SpatialStatisticKind.coordinate =>
      'No coordinates have been added to this project.',
    SpatialStatisticKind.specimens =>
      'No specimens are assigned to project coordinates.',
    SpatialStatisticKind.species =>
      'No species are associated with project coordinates.',
    SpatialStatisticKind.family =>
      'No families are associated with project coordinates.',
    SpatialStatisticKind.coordinatesBySpecies =>
      'No specimens of ${_selectedSpecies?.label ?? 'the selected species'} '
          'are assigned to project coordinates.',
  };
}

class _SpatialSpeciesPrompt extends StatelessWidget {
  const _SpatialSpeciesPrompt();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 280,
    child: Center(
      child: Text(
        'Select a species to view coordinate abundance.',
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class _SpatialKindPicker extends StatelessWidget {
  const _SpatialKindPicker({required this.selected, required this.onSelected});

  final SpatialStatisticKind selected;
  final ValueChanged<SpatialStatisticKind> onSelected;

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (final kind in SpatialStatisticKind.values)
        ChoiceChip(
          label: Text(kind.label),
          selected: kind == selected,
          onSelected: (_) => onSelected(kind),
        ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 550) {
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

enum _SpatialStatisticMode { map, table }
