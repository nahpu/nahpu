import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/screens/projects/statistics/charts.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/project_shell.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/statistics/captures.dart';
import 'package:nahpu/services/statistics/common.dart';
import 'package:nahpu/services/taxonomy_services.dart';
import 'package:nahpu/services/types/statistics.dart';

const double chartWidth = 32;
const int maxCount = 5;

class StatisticViewer extends ConsumerStatefulWidget {
  const StatisticViewer({
    super.key,
  });

  @override
  StatisticViewerState createState() => StatisticViewerState();
}

class StatisticViewerState extends ConsumerState<StatisticViewer> {
  GraphType _selectedGraph = GraphType.speciesCount;
  final bool _isLarge = false;

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Statistics',
      mainAxisAlignment: MainAxisAlignment.start,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 360, maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StatisticDropdown(
              selectedGraph: _selectedGraph,
              isLarge: _isLarge,
              onChanged: (GraphType? newValue) {
                setState(() {
                  _selectedGraph = newValue!;
                });
              },
              graphOptions: dashboardGraphOptions,
            ),
            Expanded(
                child: FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CountBarChart(
                    graphType: _selectedGraph,
                    dataPoints: snapshot.data!,
                    isFullScreen: false,
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
              future: _getData(ref),
            )),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: () {
                // Pushed on top of the shell; Close pops back to it.
                Navigator.push(
                  context,
                  _openFullscreen(),
                );
              },
              label: 'View all',
              icon: Icons.fullscreen,
            ),
          ],
        ),
      ),
    );
  }

  Future<DataPoints> _getData(WidgetRef ref) async {
    CaptureRecordStats data = CaptureRecordStats(ref: ref);
    GraphType graph = _selectedGraph;
    switch (graph) {
      case GraphType.speciesCount:
        return data.getSpeciesDataPoint();
      case GraphType.familyCount:
        return data.getFamilyDataPoint();
      default:
        return data.getSpeciesDataPoint();
    }
  }

  /// We use custom transitions to make the fullscreen graph slide up from the
  /// bottom of the screen.
  Route _openFullscreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          StatisticFullScreen(
        startingGraph: _selectedGraph,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}

class StatisticFullScreen extends ConsumerStatefulWidget {
  const StatisticFullScreen({
    super.key,
    required this.startingGraph,
  });
  final GraphType startingGraph;
  @override
  StatisticFullScreenState createState() => StatisticFullScreenState();
}

class StatisticFullScreenState extends ConsumerState<StatisticFullScreen> {
  final TextEditingController _controller = TextEditingController();
  GraphType? _graphType;
  final bool _isisFullScreen = true;
  final bool _isLarge = true;
  int? _selectedID;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Statistics'),
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            ProjectShell.returnToTab(context, ref, 0);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 18, 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: StatisticDropdown(
                    selectedGraph: _getGraphType,
                    graphOptions: fullScreenGraphOptions,
                    isLarge: _isLarge,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _graphType = value;
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 0, 0),
                  child: Visibility(
                    visible: _graphType == GraphType.speciesPerSiteCount ||
                        _graphType == GraphType.partPerSpeciesCount,
                    child: FutureBuilder(
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            bool enabledFeature =
                                snapshot.data!.length > 5 ? true : false;
                            return DropdownMenu(
                              initialSelection: _selectedID,
                              controller: _controller,
                              enableSearch: enabledFeature,
                              enabled: snapshot.data!.entries.isNotEmpty,
                              hintText: 'Select',
                              textStyle:
                                  Theme.of(context).textTheme.titleMedium,
                              inputDecorationTheme: const InputDecorationTheme(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              trailingIcon:
                                  _controller.text.isEmpty || !enabledFeature
                                      ? null
                                      : IconButton(
                                          icon: const Icon(Icons.clear_rounded),
                                          onPressed: () {
                                            setState(() {
                                              _selectedID = null;
                                              _controller.clear();
                                            });
                                          }),
                              leadingIcon:
                                  _graphType == GraphType.speciesPerSiteCount ||
                                          _graphType ==
                                              GraphType.partPerSpeciesCount
                                      ? const Icon(Icons.search_rounded)
                                      : null,
                              dropdownMenuEntries: snapshot.data!.entries
                                  .map((e) => DropdownMenuEntry(
                                        value: e.key,
                                        label: e.value,
                                      ))
                                  .toList(),
                              onSelected: (value) {
                                setState(() {
                                  _selectedID = value;
                                });
                              },
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                        future: _getDropdownEntry()),
                  ),
                ),
                Expanded(
                    child: FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CountBarChart(
                        graphType: _getGraphType,
                        dataPoints: snapshot.data!,
                        isFullScreen: _isisFullScreen,
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                  future: _getData(ref),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  GraphType get _getGraphType {
    if (_graphType == null) {
      return widget.startingGraph;
    } else {
      return _graphType!;
    }
  }

  Future<DataPoints> _getData(WidgetRef ref) async {
    CaptureRecordStats data = CaptureRecordStats(ref: ref);
    GraphType graph = _getGraphType;
    switch (graph) {
      case GraphType.speciesCount:
        return data.getSpeciesDataPoint();
      case GraphType.familyCount:
        return data.getFamilyDataPoint();
      case GraphType.speciesPerSiteCount:
        return data.getSpeciesPerSiteDataPoint(_selectedID);
      case GraphType.specimenPartCount:
        return data.getSpecimenPartDataPoint();
      case GraphType.partPerSpeciesCount:
        return data.getPartPerSpeciesDataPoint(_selectedID);
      case GraphType.partTreatmentCount:
        return data.getPartTreatmentDataPoint();
    }
  }

  Future<Map<int, String>> _getDropdownEntry() async {
    switch (_getGraphType) {
      case GraphType.speciesPerSiteCount:
        return await CollEventServices(ref: ref).getSitesForAllEvents();
      case GraphType.partPerSpeciesCount:
        List<int> speciesList =
            await SpecimenServices(ref: ref).getAllDistinctSpecies();

        Map<int, String> speciesMap = {};
        for (int speciesID in speciesList) {
          TaxonomyData data =
              await TaxonomyServices(ref: ref).getTaxonById(speciesID);
          speciesMap[speciesID] =
              '${data.genus ?? ''} ${data.specificEpithet ?? ''}';
        }
        return Map.fromEntries(speciesMap.entries.toList()
          ..sort((e1, e2) => e1.value.compareTo(e2.value)));
      default:
        return {};
    }
  }
}

class StatisticDropdown extends StatelessWidget {
  const StatisticDropdown({
    super.key,
    required this.selectedGraph,
    required this.onChanged,
    required this.graphOptions,
    required this.isLarge,
  });

  final GraphType selectedGraph;
  final void Function(GraphType?) onChanged;
  final List<String> graphOptions;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<GraphType>(
      value: selectedGraph,
      underline: const SizedBox.shrink(),
      items: graphOptions
          .map((String value) => DropdownMenuItem<GraphType>(
                value: GraphType.values[graphOptions.indexOf(value)],
                child: Text(
                  value,
                  style: isLarge
                      ? Theme.of(context).textTheme.titleLarge
                      : Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.fade,
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class CountBarChart extends ConsumerWidget {
  const CountBarChart({
    super.key,
    required this.graphType,
    required this.dataPoints,
    required this.isFullScreen,
  });

  final GraphType graphType;
  final DataPoints dataPoints;
  final bool isFullScreen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        dataPoints.data.isEmpty
            ? Text(
                _emptyText,
                style: Theme.of(context).textTheme.labelLarge,
              )
            : Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                        width: getChartWidth(dataPoints.data.length),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: BarChartViewer(
                            labels: dataPoints.labels,
                            data: isFullScreen
                                ? dataPoints.data
                                : DataPoints(
                                        data: dataPoints.data,
                                        labels: dataPoints.labels)
                                    .getMaxCount(maxCount),
                          ),
                        )),
                  ),
                ),
              ),
        !isFullScreen || dataPoints.data.isEmpty
            ? const SizedBox.shrink()
            : StatBottomText(
                dataLength: dataPoints.data.length,
                graphType: graphType,
              ),
      ],
    );
  }

  double getChartWidth(int dataLength) {
    if (isFullScreen) {
      return dataLength * (chartWidth + 24);
    } else {
      return maxCount * (chartWidth + 28);
    }
  }

  String get _emptyText {
    return 'No data to display';
  }
}

class StatBottomText extends StatelessWidget {
  const StatBottomText({
    super.key,
    required this.dataLength,
    required this.graphType,
  });

  final int dataLength;
  final GraphType graphType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
      child: Text(
        _bottomText,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }

  String get _bottomText {
    switch (graphType) {
      case GraphType.speciesCount:
        return 'Species counts: $dataLength';
      case GraphType.familyCount:
        return 'Family counts: $dataLength';
      case GraphType.speciesPerSiteCount:
        return 'Species counts: $dataLength';
      case GraphType.specimenPartCount:
        return 'Part-treatment type counts: $dataLength';
      case GraphType.partPerSpeciesCount:
        return 'Part-treatment type counts: $dataLength';
      case GraphType.partTreatmentCount:
        return 'Treatment type counts: $dataLength';
    }
  }
}
