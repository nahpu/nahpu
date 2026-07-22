part of '../coordinates.dart';

class CoordinateManager extends ConsumerStatefulWidget {
  const CoordinateManager({super.key});

  @override
  ConsumerState<CoordinateManager> createState() => _CoordinateManagerState();
}

class _CoordinateManagerState extends ConsumerState<CoordinateManager> {
  int? _siteFilterId;
  Set<int>? _selectedCoordinateIds;
  int? _focusedCoordinateId;
  int _focusRequest = 0;

  @override
  Widget build(BuildContext context) {
    final coordinates = ref.watch(coordinateByProjectProvider);
    final sites = ref.watch(siteEntryProvider);
    final visibleCoordinateIds = _visibleCoordinateIds(coordinates.value ?? []);
    final selectedCoordinateIds =
        _selectedCoordinateIds ?? visibleCoordinateIds;
    Future<void> openFullScreenMap() => _openFullScreenMap(
      coordinates: coordinates,
      siteFilterId: _siteFilterId,
      selectedCoordinateIds: selectedCoordinateIds,
      focusedCoordinateId: _focusedCoordinateId,
      focusRequest: _focusRequest,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage coordinates'),
        actions: [
          if (MediaQuery.sizeOf(context).width < 600)
            IconButton(
              tooltip: 'View map',
              onPressed: openFullScreenMap,
              icon: const Icon(Icons.map_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final map = _CoordinateMapPane(
              coordinates: coordinates,
              siteFilterId: _siteFilterId,
              selectedCoordinateIds: selectedCoordinateIds,
              focusedCoordinateId: _focusedCoordinateId,
              focusRequest: _focusRequest,
              onCoordinateSelected: _focusCoordinate,
            );

            if (isWide) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 380,
                      child: _CoordinateSurfacePanel(
                        child: _CoordinateManagerListPane(
                          coordinates: coordinates,
                          sites: sites,
                          siteFilterId: _siteFilterId,
                          selectedCoordinateIds: selectedCoordinateIds,
                          focusedCoordinateId: _focusedCoordinateId,
                          onSiteFilterChanged: _changeSiteFilter,
                          onCoordinateSelected: _focusCoordinate,
                          onCoordinateSelectionChanged:
                              _changeCoordinateSelection,
                          onSelectAll: () => _selectAll(visibleCoordinateIds),
                          onClearAll: _clearAll,
                          onExportCoordinates: _exportCoordinates,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: _CoordinateSurfacePanel(child: map),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _FullScreenMapButton(
                              onPressed: openFullScreenMap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            final list = _CoordinateSurfacePanel(
              child: _CoordinateManagerListPane(
                coordinates: coordinates,
                sites: sites,
                siteFilterId: _siteFilterId,
                selectedCoordinateIds: selectedCoordinateIds,
                focusedCoordinateId: _focusedCoordinateId,
                onSiteFilterChanged: _changeSiteFilter,
                onCoordinateSelected: _focusCoordinate,
                onCoordinateSelectionChanged: _changeCoordinateSelection,
                onSelectAll: () => _selectAll(visibleCoordinateIds),
                onClearAll: _clearAll,
                onExportCoordinates: _exportCoordinates,
              ),
            );
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: list,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _changeSiteFilter(int? siteId) {
    setState(() {
      _siteFilterId = siteId;
      _selectedCoordinateIds = null;
      _focusedCoordinateId = null;
      _focusRequest++;
    });
  }

  void _focusCoordinate(int coordinateId) {
    setState(() {
      _focusedCoordinateId = coordinateId;
      _focusRequest++;
    });
  }

  void _changeCoordinateSelection(int coordinateId, bool selected) {
    final visibleIds = _visibleCoordinateIds(
      ref.read(coordinateByProjectProvider).value ?? [],
    );
    setState(() {
      final selection = {...(_selectedCoordinateIds ?? visibleIds)};
      selected ? selection.add(coordinateId) : selection.remove(coordinateId);
      _selectedCoordinateIds = selection;
      if (!selected && _focusedCoordinateId == coordinateId) {
        _focusedCoordinateId = null;
        _focusRequest++;
      }
    });
  }

  void _selectAll(Set<int> visibleCoordinateIds) {
    setState(() => _selectedCoordinateIds = {...visibleCoordinateIds});
  }

  void _clearAll() {
    setState(() {
      _selectedCoordinateIds = {};
      _focusedCoordinateId = null;
      _focusRequest++;
    });
  }

  Future<void> _openFullScreenMap({
    required AsyncValue<List<CoordinateData>> coordinates,
    required int? siteFilterId,
    required Set<int> selectedCoordinateIds,
    required int? focusedCoordinateId,
    required int focusRequest,
  }) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => _CoordinateManagerFullScreenMap(
          coordinates: coordinates,
          siteFilterId: siteFilterId,
          selectedCoordinateIds: selectedCoordinateIds,
          focusedCoordinateId: focusedCoordinateId,
          focusRequest: focusRequest,
          onCoordinateFocused: _focusCoordinate,
        ),
      ),
    );
  }

  Set<int> _visibleCoordinateIds(List<CoordinateData> coordinates) {
    return {
      for (final coordinate in coordinates)
        if (coordinate.id != null &&
            (_siteFilterId == null || coordinate.siteID == _siteFilterId))
          coordinate.id!,
    };
  }

  Future<void> _exportCoordinates(List<CoordinateData> coordinates) async {
    final content = _CoordinateExportOverlay(coordinates: coordinates);
    if (MediaQuery.sizeOf(context).width > 600) {
      await showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: content,
          ),
        ),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: content,
        ),
      ),
    );
  }
}

class _CoordinateManagerFullScreenMap extends StatefulWidget {
  const _CoordinateManagerFullScreenMap({
    required this.coordinates,
    required this.siteFilterId,
    required this.selectedCoordinateIds,
    required this.focusedCoordinateId,
    required this.focusRequest,
    required this.onCoordinateFocused,
  });

  final AsyncValue<List<CoordinateData>> coordinates;
  final int? siteFilterId;
  final Set<int> selectedCoordinateIds;
  final int? focusedCoordinateId;
  final int focusRequest;
  final ValueChanged<int> onCoordinateFocused;

  @override
  State<_CoordinateManagerFullScreenMap> createState() =>
      _CoordinateManagerFullScreenMapState();
}

class _CoordinateManagerFullScreenMapState
    extends State<_CoordinateManagerFullScreenMap> {
  late int? _focusedCoordinateId;
  late int _focusRequest;

  @override
  void initState() {
    super.initState();
    _focusedCoordinateId = widget.focusedCoordinateId;
    _focusRequest = widget.focusRequest;
  }

  @override
  Widget build(BuildContext context) => FullScreenMapPage(
    title: 'Coordinate map',
    child: _CoordinateMapPane(
      coordinates: widget.coordinates,
      siteFilterId: widget.siteFilterId,
      selectedCoordinateIds: widget.selectedCoordinateIds,
      focusedCoordinateId: _focusedCoordinateId,
      focusRequest: _focusRequest,
      onCoordinateSelected: _focusCoordinate,
    ),
  );

  void _focusCoordinate(int coordinateId) {
    setState(() {
      _focusedCoordinateId = coordinateId;
      _focusRequest++;
    });
    widget.onCoordinateFocused(coordinateId);
  }
}

class _FullScreenMapButton extends StatelessWidget {
  const _FullScreenMapButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(8),
    child: IconButton(
      tooltip: 'View map full screen',
      onPressed: onPressed,
      icon: const Icon(Icons.fullscreen),
    ),
  );
}

class _CoordinateExportOverlay extends ConsumerStatefulWidget {
  const _CoordinateExportOverlay({required this.coordinates});

  final List<CoordinateData> coordinates;

  @override
  ConsumerState<_CoordinateExportOverlay> createState() =>
      _CoordinateExportOverlayState();
}

class _CoordinateExportOverlayState
    extends ConsumerState<_CoordinateExportOverlay> {
  late final FileOpCtrModel _exportCtr;
  CoordinateFileFormat _format = CoordinateFileFormat.geoJson;
  Directory? _selectedDir;
  File? _outputFile;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _exportCtr = FileOpCtrModel.empty();
    _exportCtr.fileNameCtr.text =
        CoordinateExchangeService.defaultCoordinatesFileName();
  }

  @override
  void dispose() {
    _exportCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Export ${widget.coordinates.length} '
            '${widget.coordinates.length == 1 ? 'coordinate' : 'coordinates'}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          GenericFileSettingsCard<CoordinateFileFormat>(
            exportCtr: _exportCtr,
            selectedDir: _selectedDir,
            format: _format,
            formats: CoordinateFileFormat.values,
            formatLabel: _formatLabel,
            onFormatChanged: (value) => setState(() {
              _format = value;
              _outputFile = null;
            }),
            onFileNameChanged: (_) => _resetExport(),
            onSelectDir: _selectDirectory,
            onClearDir: () => setState(() {
              _selectedDir = null;
              _outputFile = null;
            }),
          ),
          const SizedBox(height: 20),
          ExportShareButton(
            hasExported: _outputFile != null,
            isRunning: _isRunning,
            onExport: _exportCtr.isValid ? _export : null,
            onShare: _share,
          ),
        ],
      ),
    );
  }

  String _formatLabel(CoordinateFileFormat value) => switch (value) {
    CoordinateFileFormat.geoJson => 'GeoJSON (.geojson)',
    CoordinateFileFormat.kml => 'KML (.kml)',
    CoordinateFileFormat.shapefile => 'Shapefile bundle (.zip)',
  };

  void _resetExport() {
    if (mounted) setState(() => _outputFile = null);
  }

  Future<void> _selectDirectory() async {
    final directory = await FilePickerServices().selectDir();
    if (directory != null && mounted) {
      setState(() {
        _selectedDir = directory;
        _outputFile = null;
      });
    }
  }

  Future<void> _export() async {
    setState(() => _isRunning = true);
    try {
      final file = await CoordinateExchangeService(ref: ref).exportCoordinates(
        widget.coordinates,
        _format,
        fileName: _exportCtr.fileNameCtr.text,
        destinationDirectory: _selectedDir,
      );
      if (!mounted) return;
      setState(() => _outputFile = file);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exported to ${file.path}')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  Future<void> _share() async {
    final file = _outputFile;
    if (file == null) return;
    try {
      await FilePickerServices().shareFile(context, file);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _CoordinateManagerListPane extends StatelessWidget {
  const _CoordinateManagerListPane({
    required this.coordinates,
    required this.sites,
    required this.siteFilterId,
    required this.selectedCoordinateIds,
    required this.focusedCoordinateId,
    required this.onSiteFilterChanged,
    required this.onCoordinateSelected,
    required this.onCoordinateSelectionChanged,
    required this.onSelectAll,
    required this.onClearAll,
    required this.onExportCoordinates,
  });

  final AsyncValue<List<CoordinateData>> coordinates;
  final AsyncValue<List<SiteData>> sites;
  final int? siteFilterId;
  final Set<int> selectedCoordinateIds;
  final int? focusedCoordinateId;
  final ValueChanged<int?> onSiteFilterChanged;
  final ValueChanged<int> onCoordinateSelected;
  final void Function(int coordinateId, bool selected)
  onCoordinateSelectionChanged;
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;
  final ValueChanged<List<CoordinateData>> onExportCoordinates;

  @override
  Widget build(BuildContext context) {
    final entries = _filteredCoordinates(coordinates.value ?? const []);
    final selectedCoordinates = entries
        .where((coordinate) => selectedCoordinateIds.contains(coordinate.id))
        .toList(growable: false);
    final siteLabels = {
      for (final site in sites.value ?? const <SiteData>[])
        site.id: _siteLabel(site),
    };
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Show coordinates',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          sites.when(
            data: (siteEntries) => DropdownButtonFormField<int>(
              initialValue: siteFilterId ?? -1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(
                  value: -1,
                  child: Text('All coordinates'),
                ),
                for (final site in siteEntries)
                  DropdownMenuItem(
                    value: site.id,
                    child: Text(_siteLabel(site)),
                  ),
              ],
              onChanged: (value) {
                onSiteFilterChanged(value == -1 ? null : value);
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (error, stackTrace) => Text('Unable to load sites: $error'),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: coordinates.when(
              data: (_) => _CoordinateManagerCoordinateList(
                coordinates: entries,
                siteLabels: siteLabels,
                selectedCoordinateIds: selectedCoordinateIds,
                focusedCoordinateId: focusedCoordinateId,
                onCoordinateSelected: onCoordinateSelected,
                onCoordinateSelectionChanged: onCoordinateSelectionChanged,
                onSelectAll: onSelectAll,
                onClearAll: onClearAll,
              ),
              loading: () => const CommonProgressIndicator(),
              error: (error, stackTrace) =>
                  Center(child: Text('Unable to load coordinates: $error')),
            ),
          ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const ValueKey('coordinate-manager-export'),
              onPressed: selectedCoordinates.isEmpty
                  ? null
                  : () => onExportCoordinates(selectedCoordinates),
              icon: const Icon(Icons.file_upload_outlined),
              label: Text('Export coordinates (${selectedCoordinates.length})'),
            ),
          ],
        ],
      ),
    );
  }

  List<CoordinateData> _filteredCoordinates(List<CoordinateData> values) {
    if (siteFilterId == null) return values;
    return values
        .where((coordinate) => coordinate.siteID == siteFilterId)
        .toList();
  }

  String _siteLabel(SiteData site) {
    final name = site.siteID?.trim();
    if (name != null && name.isNotEmpty) return name;
    final locality = site.locality?.trim();
    if (locality != null && locality.isNotEmpty) return locality;
    return 'Site ${site.id}';
  }
}

class _CoordinateManagerCoordinateList extends StatelessWidget {
  const _CoordinateManagerCoordinateList({
    required this.coordinates,
    required this.siteLabels,
    required this.selectedCoordinateIds,
    required this.focusedCoordinateId,
    required this.onCoordinateSelected,
    required this.onCoordinateSelectionChanged,
    required this.onSelectAll,
    required this.onClearAll,
  });

  final List<CoordinateData> coordinates;
  final Map<int, String> siteLabels;
  final Set<int> selectedCoordinateIds;
  final int? focusedCoordinateId;
  final ValueChanged<int> onCoordinateSelected;
  final void Function(int coordinateId, bool selected)
  onCoordinateSelectionChanged;
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    if (coordinates.isEmpty) {
      return const Center(child: Text('No coordinates added'));
    }
    final visibleIds = {
      for (final coordinate in coordinates)
        if (coordinate.id != null) coordinate.id!,
    };
    final allSelected = visibleIds.every(selectedCoordinateIds.contains);
    final hasSelection = visibleIds.any(selectedCoordinateIds.contains);
    final selectedCount = selectedCoordinateIds.intersection(visibleIds).length;
    final coordinateWord = coordinates.length == 1
        ? 'coordinate'
        : 'coordinates';
    final countLabel = selectedCount < coordinates.length
        ? '$selectedCount of ${coordinates.length} $coordinateWord selected'
        : '${coordinates.length} $coordinateWord';
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  countLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: allSelected ? null : onSelectAll,
                child: const Text('Select all'),
              ),
              TextButton(
                onPressed: hasSelection ? onClearAll : null,
                child: const Text('Clear all'),
              ),
            ],
          ),
        ),
        for (final coordinate in coordinates)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Builder(
              builder: (context) {
                final colorScheme = Theme.of(context).colorScheme;
                final selected = selectedCoordinateIds.contains(coordinate.id);
                final focused = coordinate.id == focusedCoordinateId;
                final background = focused
                    ? Color.alphaBlend(
                        colorScheme.primaryContainer.withValues(alpha: 0.22),
                        colorScheme.surfaceContainerHighest,
                      )
                    : colorScheme.surfaceContainerHighest;
                return Material(
                  key: ValueKey('coordinate-manager-tile-${coordinate.id}'),
                  color: background,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: Ink(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: focused
                            ? colorScheme.outline.withValues(alpha: 0.5)
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Opacity(
                      opacity: selected ? 1 : 0.55,
                      child: ListTile(
                        leading: Checkbox(
                          value: selected,
                          onChanged: coordinate.id == null
                              ? null
                              : (value) => onCoordinateSelectionChanged(
                                  coordinate.id!,
                                  value ?? false,
                                ),
                        ),
                        title: CoordinateTitle(coordinateId: coordinate.nameId),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (coordinate.siteID != null)
                              Text(
                                siteLabels[coordinate.siteID] ??
                                    'Site ${coordinate.siteID}',
                              ),
                            CoordinateSubtitle(coordinate: coordinate),
                          ],
                        ),
                        trailing: IconButton(
                          tooltip: 'Show QR code',
                          onPressed: () =>
                              showCoordinateQrDialog(context, coordinate),
                          icon: const Icon(Icons.qr_code_outlined),
                        ),
                        onTap: coordinate.id == null
                            ? null
                            : () => onCoordinateSelected(coordinate.id!),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CoordinateMapPane extends StatelessWidget {
  const _CoordinateMapPane({
    required this.coordinates,
    required this.siteFilterId,
    required this.selectedCoordinateIds,
    required this.focusedCoordinateId,
    required this.focusRequest,
    required this.onCoordinateSelected,
  });

  final AsyncValue<List<CoordinateData>> coordinates;
  final int? siteFilterId;
  final Set<int> selectedCoordinateIds;
  final int? focusedCoordinateId;
  final int focusRequest;
  final ValueChanged<int> onCoordinateSelected;

  @override
  Widget build(BuildContext context) => coordinates.when(
    data: (allEntries) {
      final entries = siteFilterId == null
          ? allEntries
          : allEntries.where((entry) => entry.siteID == siteFilterId).toList();
      final points = [
        for (final coordinate in entries)
          if (coordinate.id != null)
            CoordinateMapPoint(
              id: coordinate.id!,
              name: coordinate.nameId?.trim().isNotEmpty == true
                  ? coordinate.nameId!
                  : 'Unnamed coordinate (${coordinate.id})',
              latitude: coordinate.decimalLatitude,
              longitude: coordinate.decimalLongitude,
            ),
      ];
      final omitted = points.where((point) => !point.isMappable).length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (omitted > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '$omitted ${omitted == 1 ? 'coordinate is' : 'coordinates are'} '
                'not shown because latitude or longitude is missing or invalid.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Expanded(
            child: CoordinateLocationMap(
              points: points,
              selectedPointIds: selectedCoordinateIds,
              selectedPointId: focusedCoordinateId,
              focusRequest: focusRequest,
              onPointSelected: onCoordinateSelected,
            ),
          ),
        ],
      );
    },
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (error, stackTrace) =>
        Center(child: Text('Unable to load coordinates: $error')),
  );
}

class _CoordinateSurfacePanel extends StatelessWidget {
  const _CoordinateSurfacePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
}
