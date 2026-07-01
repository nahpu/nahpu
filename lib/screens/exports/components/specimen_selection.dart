import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/export/label_writer.dart'
    show fieldValuesForSpecimen;
import 'package:nahpu/services/print_specimen_table_columns.dart';

class SpecimenSelectionView extends ConsumerStatefulWidget {
  const SpecimenSelectionView({
    super.key,
    required this.selectedUuidList,
    required this.onSelectionChanged,
    required this.visibleColumnIds,
    required this.onColumnsChanged,
    this.isSingleSelection = false,
  });

  final Set<String> selectedUuidList;
  final ValueChanged<Set<String>> onSelectionChanged;
  final List<String> visibleColumnIds;
  final VoidCallback onColumnsChanged;
  final bool isSingleSelection;

  @override
  ConsumerState<SpecimenSelectionView> createState() =>
      _SpecimenSelectionViewState();
}

class _SpecimenSelectionViewState extends ConsumerState<SpecimenSelectionView> {
  final TextEditingController _searchController = TextEditingController();

  List<SpecimenData> _currentPageData = [];
  Map<String, Map<String, String>> _rowValues = {};

  final ScrollController _hScrollController = ScrollController();
  final ScrollController _vScrollController = ScrollController();

  int _totalCount = 0;
  int _currentPage = 0;
  final int _pageSize = 50;
  bool _isLoading = true;

  String _searchQuery = '';
  bool _hasCollectionDate = false;
  String _collectionStartDate = '';
  String _collectionEndDate = '';

  bool _hasPrepDate = false;
  String _prepStartDate = '';
  String _prepEndDate = '';

  @override
  void initState() {
    super.initState();
    _fetchPage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _hScrollController.dispose();
    _vScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage() async {
    setState(() => _isLoading = true);
    final db = ref.read(databaseProvider);
    final projectUuid = ref.read(projectUuidProvider);

    try {
      final totalResult = await db
          .countSpecimens(
            projectUuid,
            _searchQuery.isEmpty ? '' : '%$_searchQuery%',
            _hasCollectionDate,
            _collectionStartDate,
            _collectionEndDate,
            _hasPrepDate,
            _prepStartDate,
            _prepEndDate,
          )
          .getSingleOrNull();

      final data = await db
          .searchSpecimens(
            projectUuid,
            _searchQuery.isEmpty ? '' : '%$_searchQuery%',
            _hasCollectionDate,
            _collectionStartDate,
            _collectionEndDate,
            _hasPrepDate,
            _prepStartDate,
            _prepEndDate,
            _pageSize,
            _currentPage * _pageSize,
          )
          .get();

      final rowVals = <String, Map<String, String>>{};
      for (final s in data) {
        rowVals[s.uuid] = await fieldValuesForSpecimen(db, s, ref);
      }

      if (!mounted) return;
      setState(() {
        _totalCount = totalResult ?? 0;
        _currentPageData = data;
        _rowValues = rowVals;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _cellText(Map<String, String> row, String columnId) {
    if (row.containsKey(columnId)) return row[columnId]!;
    final lower = columnId.toLowerCase();
    for (final e in row.entries) {
      if (e.key.toLowerCase() == lower) return e.value;
    }
    return '';
  }

  void _onHeaderCheckbox(bool? v) {
    final newSelected = Set<String>.from(widget.selectedUuidList);
    if (v == true) {
      newSelected.addAll(_currentPageData.map((e) => e.uuid));
    } else {
      newSelected.removeAll(_currentPageData.map((e) => e.uuid));
    }
    widget.onSelectionChanged(newSelected);
  }

  bool? get _headerCheckboxValue {
    if (_currentPageData.isEmpty) return false;
    final n = _currentPageData
        .where((s) => widget.selectedUuidList.contains(s.uuid))
        .length;
    if (n == 0) return false;
    if (n == _currentPageData.length) return true;
    return null;
  }

  Future<void> _pickDateRange(bool isCollection) async {
    DateTimeRange? initialRange;
    if (isCollection) {
      if (_hasCollectionDate &&
          _collectionStartDate.isNotEmpty &&
          _collectionEndDate.isNotEmpty) {
        try {
          initialRange = DateTimeRange(
            start: DateTime.parse(_collectionStartDate),
            end: DateTime.parse(_collectionEndDate),
          );
        } catch (_) {}
      }
    } else {
      if (_hasPrepDate &&
          _prepStartDate.isNotEmpty &&
          _prepEndDate.isNotEmpty) {
        try {
          initialRange = DateTimeRange(
            start: DateTime.parse(_prepStartDate),
            end: DateTime.parse(_prepEndDate),
          );
        } catch (_) {}
      }
    }

    if (initialRange == null) {
      String? dateStr;
      if (widget.selectedUuidList.isNotEmpty) {
        for (final uuid in widget.selectedUuidList) {
          try {
            final specimen = _currentPageData.firstWhere((s) => s.uuid == uuid);
            dateStr = isCollection
                ? (specimen.collectionDate ?? specimen.captureDate)
                : specimen.prepDate;
            if (dateStr != null && dateStr.isNotEmpty) {
              break;
            }
          } catch (_) {}
        }
      }

      if (dateStr == null || dateStr.isEmpty) {
        for (final specimen in _currentPageData) {
          final sDate = isCollection
              ? (specimen.collectionDate ?? specimen.captureDate)
              : specimen.prepDate;
          if (sDate != null && sDate.isNotEmpty) {
            dateStr = sDate;
            break;
          }
        }
      }

      if (dateStr != null && dateStr.isNotEmpty) {
        try {
          final date = DateTime.parse(dateStr);
          initialRange = DateTimeRange(start: date, end: date);
        } catch (_) {}
      }
    }

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDateRange: initialRange,
    );
    if (range != null) {
      setState(() {
        if (isCollection) {
          _hasCollectionDate = true;
          _collectionStartDate = range.start.toIso8601String().split('T').first;
          _collectionEndDate = range.end.toIso8601String().split('T').first;
        } else {
          _hasPrepDate = true;
          _prepStartDate = range.start.toIso8601String().split('T').first;
          _prepEndDate = range.end.toIso8601String().split('T').first;
        }
        _currentPage = 0;
      });
      _fetchPage();
    }
  }

  void _clearDateFilter(bool isCollection) {
    setState(() {
      if (isCollection) {
        _hasCollectionDate = false;
        _collectionStartDate = '';
        _collectionEndDate = '';
      } else {
        _hasPrepDate = false;
        _prepStartDate = '';
        _prepEndDate = '';
      }
      _currentPage = 0;
    });
    _fetchPage();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                'Selected ${widget.selectedUuidList.length} of $_totalCount',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Table columns',
                icon: const Icon(Icons.view_column_outlined),
                onPressed: widget.onColumnsChanged,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Field No, Collector, Species...',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          _searchQuery = _searchController.text.trim();
                          _currentPage = 0;
                        });
                        _fetchPage();
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                      _currentPage = 0;
                    });
                    _fetchPage();
                  },
                ),
              ),
              InputChip(
                label: Text(_hasCollectionDate
                    ? 'Coll: $_collectionStartDate - $_collectionEndDate'
                    : 'Collection Date'),
                onPressed: () => _pickDateRange(true),
                onDeleted:
                    _hasCollectionDate ? () => _clearDateFilter(true) : null,
                showCheckmark: false,
                avatar: const Icon(Icons.calendar_today_outlined, size: 16),
              ),
              InputChip(
                label: Text(_hasPrepDate
                    ? 'Prep: $_prepStartDate - $_prepEndDate'
                    : 'Prep Date'),
                onPressed: () => _pickDateRange(false),
                onDeleted: _hasPrepDate ? () => _clearDateFilter(false) : null,
                showCheckmark: false,
                avatar: const Icon(Icons.calendar_month_outlined, size: 16),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return Scrollbar(
                      controller: _vScrollController,
                      child: SingleChildScrollView(
                        controller: _vScrollController,
                        scrollDirection: Axis.vertical,
                        child: Scrollbar(
                          controller: _hScrollController,
                          child: SingleChildScrollView(
                            controller: _hScrollController,
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: DataTable(
                                columnSpacing: 16,
                                horizontalMargin: 12,
                                dataRowMinHeight: 40,
                                columns: [
                                  DataColumn(
                                    label: widget.isSingleSelection
                                        ? const SizedBox.shrink()
                                        : Checkbox(
                                            tristate: true,
                                            value: _headerCheckboxValue,
                                            onChanged: _onHeaderCheckbox,
                                          ),
                                  ),
                                  for (final col in widget.visibleColumnIds)
                                    DataColumn(
                                      label: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minWidth: 72,
                                          maxWidth: 160,
                                        ),
                                        child: Text(
                                          specimenColumnDisplayTitle(col),
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                ],
                                rows: [
                                  for (final s in _currentPageData)
                                    DataRow(
                                      selected: widget.selectedUuidList
                                          .contains(s.uuid),
                                      cells: [
                                        DataCell(
                                          Checkbox(
                                            value: widget.selectedUuidList
                                                .contains(s.uuid),
                                            onChanged: (v) {
                                              final newSelected =
                                                  Set<String>.from(
                                                      widget.selectedUuidList);
                                              if (v == true) {
                                                if (widget.isSingleSelection) {
                                                  newSelected.clear();
                                                }
                                                newSelected.add(s.uuid);
                                              } else {
                                                newSelected.remove(s.uuid);
                                              }
                                              widget.onSelectionChanged(
                                                  newSelected);
                                            },
                                          ),
                                        ),
                                        for (final col
                                            in widget.visibleColumnIds)
                                          DataCell(
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                  maxWidth: 200),
                                              child: Text(
                                                _cellText(
                                                    _rowValues[s.uuid] ?? {},
                                                    col),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (!_isLoading)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0
                    ? () {
                        setState(() => _currentPage--);
                        _fetchPage();
                      }
                    : null,
              ),
              Text(
                  'Page ${_currentPage + 1} of ${(_totalCount > 0 ? (_totalCount / _pageSize).ceil() : 1)}'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: (_currentPage + 1) * _pageSize < _totalCount
                    ? () {
                        setState(() => _currentPage++);
                        _fetchPage();
                      }
                    : null,
              ),
            ],
          ),
      ],
    );
  }
}
