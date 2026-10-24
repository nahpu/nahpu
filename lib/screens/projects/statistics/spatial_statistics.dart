import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_map.dart';
import 'package:nahpu/screens/projects/statistics/spatial_statistics_table.dart';
import 'package:nahpu/screens/projects/statistics/searchable_statistic_filter.dart';
import 'package:nahpu/screens/projects/statistics/statistic_filter_panel.dart';
import 'package:nahpu/screens/projects/statistics/statistic_metric_strip.dart';
import 'package:nahpu/screens/projects/statistics/statistics_table.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/providers/statistics.dart';
import 'package:nahpu/services/sites/coordinate_format.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/services/types/statistics.dart';
import 'package:nahpu/styles/design_tokens.dart';

class SpatialStatisticsPanel extends ConsumerStatefulWidget {
  const SpatialStatisticsPanel({
    super.key,
    required this.projectUuid,
    required this.projectName,
    required this.height,
    required this.sectionSwitch,
  });

  /// Project the map covers, or null for every project.
  final String? projectUuid;
  final String projectName;

  /// Counts/Spatial switch shown at the top of the filter panel.
  final Widget sectionSwitch;

  /// Fixed card height, shared with the Explore counts card so switching
  /// between them keeps the page steady.
  final double height;

  @override
  ConsumerState<SpatialStatisticsPanel> createState() =>
      _SpatialStatisticsPanelState();
}

class _SpatialStatisticsPanelState
    extends ConsumerState<SpatialStatisticsPanel> {
  SpatialStatisticKind _selectedKind = SpatialStatisticKind.specimens;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatisticFilterPanel(
          section: widget.sectionSwitch,
          fields: [
            StatisticDropdownField<SpatialStatisticKind>(
              key: const ValueKey('spatial-statistics-kind-control'),
              label: 'Show',
              values: SpatialStatisticKind.values,
              selected: _selectedKind,
              valueLabel: (kind) => kind.label,
              onSelected: (kind) => setState(() => _selectedKind = kind),
            ),
            if (_selectedKind.needsSpecies)
              SearchableStatisticFilterPicker(
                options: ref.watch(
                  spatialSpeciesFilterOptionsProvider(widget.projectUuid),
                ),
                selected: _selectedSpecies,
                label: 'Species',
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
        ),
        const SizedBox(height: NahpuSpacing.xl),
        Card(
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(NahpuRadius.md)),
          ),
          child: SizedBox(
            key: const ValueKey('spatial-statistics-content'),
            height: widget.height,
            child: Padding(
              padding: const EdgeInsets.all(NahpuSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final title = Text(
                        _selectedKind.needsSpecies && _selectedSpecies != null
                            ? '${_selectedSpecies!.label} counts by coordinates'
                            : _selectedKind.title,
                        style: Theme.of(context).textTheme.titleMedium,
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
                  Expanded(
                    child: !request.isReady
                        ? const _SpatialSpeciesPrompt()
                        : data.when(
                            data: (rows) => Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (rows.isNotEmpty) ...[
                                  SpatialMetricStrip(
                                    kind: _selectedKind,
                                    summary: SpatialStatisticSummary.fromRows(
                                      rows,
                                    ),
                                  ),
                                  const SizedBox(height: NahpuSpacing.lg),
                                ],
                                Expanded(child: _buildContent(rows)),
                              ],
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stackTrace) => Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Unable to load spatial statistics: $error',
                                  ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildContent(List<SpatialStatisticDatum> rows) {
    if (_mode == _SpatialStatisticMode.map) {
      return SpatialStatisticsMap(kind: _selectedKind, rows: rows);
    }
    if (rows.isNotEmpty) {
      return SpatialStatisticsTable(
        kind: _selectedKind,
        rows: rows,
        onExport: () => showSpatialStatisticExportDialog(
          context: context,
          defaultFileName: _defaultFileName,
          kind: _selectedKind,
          rows: rows,
        ),
      );
    }
    return Center(
      child: Text(
        _emptyMessage,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  String get _emptyMessage => switch (_selectedKind) {
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

  String get _defaultFileName {
    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final components = [
      widget.projectName,
      _selectedKind.fileSlug,
      if (_selectedSpecies != null) _selectedSpecies!.label,
      date,
    ];
    return components
        .join('_')
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}

/// Headline numbers shown above the spatial map and table.
class SpatialMetricStrip extends StatelessWidget {
  const SpatialMetricStrip({
    super.key,
    required this.kind,
    required this.summary,
  });

  final SpatialStatisticKind kind;
  final SpatialStatisticSummary summary;

  @override
  Widget build(BuildContext context) {
    final top = summary.top;
    return StatisticMetricStrip(
      key: const ValueKey('spatial-statistics-metrics'),
      tiles: [
        StatisticMetricTile(
          value: '${summary.coordinateCount}',
          label: summary.coordinateCount == 1 ? 'Coordinate' : 'Coordinates',
        ),
        // Species and families repeat across coordinates, so their sum is not
        // a project total; show the mean per coordinate instead.
        if (kind.countsSpecimens)
          StatisticMetricTile(
            value: '${summary.total}',
            label: kind.countLabel.toSentenceCase(),
          )
        else
          StatisticMetricTile(
            value: summary.average.toStringAsFixed(1),
            label: 'Mean ${kind.countLabel} per coordinate',
          ),
        StatisticMetricTile(
          value: top == null ? '—' : '${top.count}',
          label: top == null ? 'Top coordinate' : 'Top: ${top.displayName}',
        ),
        StatisticMetricTile(value: _elevationText, label: 'Elevation'),
      ],
    );
  }

  String get _elevationText {
    final minimum = summary.minimumElevation;
    final maximum = summary.maximumElevation;
    if (minimum == null || maximum == null) return '—';
    // One decimal: with none, the formatter's trailing-zero trim would turn
    // 1450 into 145.
    final minimumText = formatCoordinate(minimum, decimals: 1);
    if (minimum == maximum) return '$minimumText m';
    return '$minimumText–${formatCoordinate(maximum, decimals: 1)} m';
  }
}

class _SpatialSpeciesPrompt extends StatelessWidget {
  const _SpatialSpeciesPrompt();

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      'Select a species to view coordinate abundance.',
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.center,
    ),
  );
}

enum _SpatialStatisticMode { map, table }
