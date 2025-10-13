import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/outliers/outlier_results_view.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/database/taxonomy_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/statistics/outlier_detection_services.dart';
import 'package:nahpu/services/taxonomy_services.dart';

final speciesListProvider =
    FutureProvider.autoDispose<List<TaxonomyData>>((ref) async {
  final projectUuid = ref.read(projectUuidProvider);
  final taxa =
      TaxonomyQuery(ref.read(databaseProvider)).getTaxaWithSpecimenData(projectUuid);
  return taxa;
});

class OutlierSelectionView extends ConsumerStatefulWidget {
  const OutlierSelectionView({super.key});

  @override
  OutlierSelectionViewState createState() => OutlierSelectionViewState();
}

class OutlierSelectionViewState extends ConsumerState<OutlierSelectionView> {
  final List<int> _selectedTaxa = [];
  bool _selectAll = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outlier Analysis'),
      ),
      body: ref.watch(speciesListProvider).when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(
                  child: Text(
                      'No species with enough data for analysis (min. 3 specimens).'),
                );
              }
              if (data.isNotEmpty && _selectedTaxa.length == data.length) {
                _selectAll = true;
              } else {
                _selectAll = false;
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select species',
                            style: Theme.of(context).textTheme.titleMedium),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectAll = !_selectAll;
                              _selectedTaxa.clear();
                              if (_selectAll) {
                                _selectedTaxa.addAll(data.map((e) => e.id));
                              }
                            });
                          },
                          child: Text(_selectAll ? 'Deselect All' : 'Select All'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          title: Text(getSpeciesName(data[index])),
                          value: _selectedTaxa.contains(data[index].id),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedTaxa.add(data[index].id);
                              } else {
                                _selectedTaxa.remove(data[index].id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ProgressButton(
                      label: 'Run Analysis',
                      icon: Icons.analytics_outlined,
                      isRunning: _isLoading,
                      onPressed: _selectedTaxa.isEmpty
                          ? null
                          : () async {
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                final outliers = await OutlierDetectionServices(
                                        ref: ref)
                                    .findOutliers(_selectedTaxa);
                                if (context.mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => OutlierResultsView(
                                          outlierSpecimens: outliers),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                    ),
                  ),
                ],
              );
            },
            loading: () => const CommonProgressIndicator(),
            error: (err, stack) => Text('Error: $err'),
          ),
    );
  }
}