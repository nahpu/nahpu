part of '../coordinates.dart';

enum _AddCoordinateMode { manual, import }

class NewCoordinate extends ConsumerStatefulWidget {
  const NewCoordinate({
    super.key,
    required this.siteId,
    required this.coordCtr,
  });

  final int siteId;
  final CoordinateCtrModel coordCtr;

  @override
  ConsumerState<NewCoordinate> createState() => _NewCoordinateState();
}

class _NewCoordinateState extends ConsumerState<NewCoordinate> {
  final _manualFormKey = GlobalKey<CoordinateFormsState>();
  _AddCoordinateMode _mode = _AddCoordinateMode.manual;
  CoordinateImportReview? _review;
  Set<int> _selectedImports = {};
  int? _focusedImport;
  bool _isLoadingFile = false;
  CoordinateMapPoint? _manualPreview;
  bool _manualPreviewIsStale = false;

  @override
  void initState() {
    super.initState();
    widget.coordCtr.nameIdCtr.addListener(_manualFieldsChanged);
    widget.coordCtr.latitudeCtr.addListener(_manualFieldsChanged);
    widget.coordCtr.longitudeCtr.addListener(_manualFieldsChanged);
  }

  @override
  void dispose() {
    widget.coordCtr.nameIdCtr.removeListener(_manualFieldsChanged);
    widget.coordCtr.latitudeCtr.removeListener(_manualFieldsChanged);
    widget.coordCtr.longitudeCtr.removeListener(_manualFieldsChanged);
    widget.coordCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FalseWillPop(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add coordinates'),
          automaticallyImplyLeading: false,
          actions: [
            if (MediaQuery.sizeOf(context).width < 600)
              IconButton(
                tooltip: 'View map',
                onPressed: () => _showMapSheet(_buildMap()),
                icon: const Icon(Icons.map_outlined),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            child: _buildActions(),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final content = _mode == _AddCoordinateMode.import
                  ? _buildImportReview()
                  : CoordinateForms(
                      key: _manualFormKey,
                      coordinateId: null,
                      siteId: widget.siteId,
                      coordCtr: widget.coordCtr,
                      disposeController: false,
                      showActions: false,
                    );
              final map = _buildMap();
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: SegmentedButton<_AddCoordinateMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: _AddCoordinateMode.manual,
                          icon: Icon(Icons.edit_location_alt_outlined),
                          label: Text('Manual'),
                        ),
                        ButtonSegment(
                          value: _AddCoordinateMode.import,
                          icon: Icon(Icons.move_to_inbox_outlined),
                          label: Text('Import'),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (selection) =>
                          setState(() => _mode = selection.first),
                    ),
                  ),
                  Expanded(
                    child: isWide
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 600,
                                  ),
                                  child: _CoordinateSurfacePanel(
                                    child: content,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _CoordinateSurfacePanel(child: map),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    12,
                                    12,
                                    0,
                                  ),
                                  child: _CoordinateSurfacePanel(
                                    child: content,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMap() => _mode == _AddCoordinateMode.import
      ? _ImportCoordinateMap(
          records: _review?.coordinates ?? const [],
          focusedIndex: _focusedImport,
          onFocused: (index) => setState(() => _focusedImport = index),
        )
      : _ManualCoordinateMap(
          point: _manualPreview,
          isStale: _manualPreviewIsStale,
          canRefresh: _validManualPoint != null,
          onRefresh: _refreshManualMap,
        );

  Widget _buildActions() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SecondaryButton(
        text: 'Cancel',
        onPressed: () => Navigator.of(context).pop(),
      ),
      const SizedBox(width: 24),
      PrimaryButton(
        label: _mode == _AddCoordinateMode.import
            ? 'Add ${_selectedImports.length} selected'
            : 'Add',
        icon: Icons.add,
        onPressed:
            _mode == _AddCoordinateMode.import && _selectedImports.isEmpty
            ? null
            : _submit,
      ),
    ],
  );

  Future<void> _submit() async {
    if (_mode == _AddCoordinateMode.import) {
      await _importSelected();
      return;
    }
    await _manualFormKey.currentState?.submit();
  }

  CoordinateMapPoint? get _validManualPoint {
    final latitude = double.tryParse(widget.coordCtr.latitudeCtr.text.trim());
    final longitude = double.tryParse(widget.coordCtr.longitudeCtr.text.trim());
    if (latitude == null ||
        longitude == null ||
        !latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return null;
    }
    final name = widget.coordCtr.nameIdCtr.text.trim();
    return CoordinateMapPoint(
      id: 0,
      name: name.isEmpty ? 'New coordinate' : name,
      latitude: latitude,
      longitude: longitude,
    );
  }

  void _manualFieldsChanged() {
    if (!mounted) return;
    setState(() {
      if (_manualPreview != null) _manualPreviewIsStale = true;
    });
  }

  void _refreshManualMap() {
    final point = _validManualPoint;
    if (point == null) return;
    setState(() {
      _manualPreview = point;
      _manualPreviewIsStale = false;
    });
  }

  Widget _buildImportReview() {
    final review = _review;
    if (review == null) {
      return Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: _scanQr,
              icon: const Icon(Icons.qr_code_scanner_outlined),
              label: const Text('Scan QR'),
            ),
            FilledButton.icon(
              onPressed: _isLoadingFile ? null : _pickCoordinateFile,
              icon: _isLoadingFile
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_open_outlined),
              label: Text(
                _isLoadingFile ? 'Reading file…' : 'Select coordinate file',
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              OutlinedButton.icon(
                onPressed: _pickCoordinateFile,
                icon: const Icon(Icons.file_open_outlined),
                label: const Text('Choose another file'),
              ),
              OutlinedButton.icon(
                onPressed: _scanQr,
                icon: const Icon(Icons.qr_code_scanner_outlined),
                label: const Text('Scan QR'),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _selectedImports = {
                    for (
                      var index = 0;
                      index < review.coordinates.length;
                      index++
                    )
                      index,
                  };
                }),
                child: const Text('Select all'),
              ),
              TextButton(
                onPressed: () => setState(_selectedImports.clear),
                child: const Text('Clear all'),
              ),
            ],
          ),
        ),
        if (review.warnings.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              review.warnings.join('\n'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: review.coordinates.length,
            itemBuilder: (context, index) {
              final coordinate = review.coordinates[index];
              return CheckboxListTile(
                value: _selectedImports.contains(index),
                selected: _focusedImport == index,
                title: Text(coordinate.nameId),
                subtitle: Text(
                  '${coordinate.decimalLatitude}, ${coordinate.decimalLongitude}',
                ),
                onChanged: (selected) => setState(() {
                  _focusedImport = index;
                  selected == true
                      ? _selectedImports.add(index)
                      : _selectedImports.remove(index);
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickCoordinateFile() async {
    setState(() => _isLoadingFile = true);
    try {
      final file = await openFile(
        acceptedTypeGroups: [coordinateFileTypeGroup],
      );
      if (file == null) return;
      final review = await CoordinateExchangeService(
        ref: ref,
      ).importFile(file.path);
      if (!mounted) return;
      setState(() {
        _review = review;
        _selectedImports = {
          for (var index = 0; index < review.coordinates.length; index++) index,
        };
        _focusedImport = review.coordinates.isEmpty ? null : 0;
      });
    } catch (error) {
      if (mounted) _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingFile = false);
    }
  }

  Future<void> _importSelected() async {
    final review = _review;
    if (review == null) return;
    try {
      final selected = _selectedImports.toList()..sort();
      final records = selected.map((index) => review.coordinates[index]);
      final forms = CoordinateExchangeService(
        ref: ref,
      ).companionsForSite(records, widget.siteId);
      await CoordinateServices(ref: ref).createCoordinates(forms);
      ref.invalidate(coordinateBySiteProvider);
      ref.invalidate(coordinateByProjectProvider);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) _showError(error.toString());
    }
  }

  Future<void> _scanQr() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(
          onDetect: (capture) {
            final rawValue = capture.barcodes.firstOrNull?.rawValue;
            if (rawValue == null) return;
            try {
              final coordinate = CoordinateExchangeService.decodeQr(rawValue);
              _populateControllers(coordinate);
              Navigator.pop(context);
              if (mounted) setState(() => _mode = _AddCoordinateMode.manual);
            } catch (error) {
              Navigator.pop(context);
              if (mounted) _showError(error.toString());
            }
          },
        ),
      ),
    );
  }

  void _populateControllers(CoordinateData coordinate) {
    widget.coordCtr.nameIdCtr.text = coordinate.nameId ?? '';
    widget.coordCtr.latitudeCtr.text =
        coordinate.decimalLatitude?.toString() ?? '';
    widget.coordCtr.longitudeCtr.text =
        coordinate.decimalLongitude?.toString() ?? '';
    widget.coordCtr.elevationCtr.text =
        coordinate.elevationInMeter?.toString() ?? '';
    widget.coordCtr.datumCtr.text = coordinate.datum ?? 'WGS84';
    widget.coordCtr.uncertaintyCtr.text =
        coordinate.uncertaintyInMeters?.toString() ?? '';
    widget.coordCtr.gpsUnitCtr.text = coordinate.gpsUnit ?? '';
    widget.coordCtr.noteCtr.text = coordinate.notes ?? '';
  }

  Future<void> _showMapSheet(Widget map) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Padding(padding: const EdgeInsets.all(12), child: map),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ManualCoordinateMap extends StatelessWidget {
  const _ManualCoordinateMap({
    required this.point,
    required this.isStale,
    required this.canRefresh,
    required this.onRefresh,
  });

  final CoordinateMapPoint? point;
  final bool isStale;
  final bool canRefresh;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (point == null || isStale) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isStale
                    ? 'The coordinate changed. Refresh the map to update the preview.'
                    : 'Enter a valid WGS84 latitude and longitude, then refresh the map.',
                textAlign: TextAlign.center,
              ),
              if (canRefresh) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh map'),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return CoordinateLocationMap(
      points: [point!],
      selectedPointId: 0,
      onPointSelected: (_) {},
    );
  }
}

class _ImportCoordinateMap extends StatelessWidget {
  const _ImportCoordinateMap({
    required this.records,
    required this.focusedIndex,
    required this.onFocused,
  });

  final List<rust_gis.CoordinateTransferRecord> records;
  final int? focusedIndex;
  final ValueChanged<int> onFocused;

  @override
  Widget build(BuildContext context) {
    return CoordinateLocationMap(
      points: [
        for (var index = 0; index < records.length; index++)
          CoordinateMapPoint(
            id: index,
            name: records[index].nameId,
            latitude: records[index].decimalLatitude,
            longitude: records[index].decimalLongitude,
          ),
      ],
      selectedPointId: focusedIndex,
      onPointSelected: onFocused,
    );
  }
}

class EditCoordinate extends ConsumerWidget {
  const EditCoordinate({
    super.key,
    required this.coordinateId,
    required this.siteId,
    required this.coordCtr,
  });

  final int coordinateId;
  final int siteId;
  final CoordinateCtrModel coordCtr;
  final bool isEditing = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FalseWillPop(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Coordinates'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: CoordinateForms(
            coordinateId: coordinateId,
            siteId: siteId,
            coordCtr: coordCtr,
            isEditing: isEditing,
          ),
        ),
      ),
    );
  }
}

class CoordinateForms extends ConsumerStatefulWidget {
  const CoordinateForms({
    super.key,
    required this.coordinateId,
    required this.siteId,
    required this.coordCtr,
    this.isEditing = false,
    this.disposeController = true,
    this.showActions = true,
  });

  final int? coordinateId;
  final int siteId;
  final CoordinateCtrModel coordCtr;
  final bool isEditing;
  final bool disposeController;
  final bool showActions;

  @override
  CoordinateFormsState createState() => CoordinateFormsState();
}

class CoordinateFormsState extends ConsumerState<CoordinateForms> {
  final List<String> _datum = ['WGS84', 'NAD83', 'NAD27', 'Other'];
  bool _isFetchingLocation = false;
  String _dmsLatitude = '';
  String _dmsLongitude = '';

  @override
  void initState() {
    super.initState();
    widget.coordCtr.latitudeCtr.addListener(_updateGPSDescription);
    widget.coordCtr.longitudeCtr.addListener(_updateGPSDescription);
    if (!widget.isEditing) {
      _prefillSiteId();
    } else {
      _updateGPSDescription();
    }
  }

  @override
  void dispose() {
    widget.coordCtr.latitudeCtr.removeListener(_updateGPSDescription);
    widget.coordCtr.longitudeCtr.removeListener(_updateGPSDescription);
    if (widget.disposeController) widget.coordCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool useHorizontalLayout = MediaQuery.sizeOf(context).width > 600.0;
    return ScrollableConstrainedLayout(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 4),
          CommonPadding(
            child: CommonTextField(
              controller: widget.coordCtr.nameIdCtr,
              labelText: 'Name',
              hintText: 'Add a name',
              isLastField: false,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.my_location_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Device GPS',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Use device sensor to autofill coordinates',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _isFetchingLocation
                        ? null
                        : () async {
                            setState(() {
                              _isFetchingLocation = true;
                            });
                            try {
                              Position? position = await _getLocation();
                              if (position != null) {
                                _populateLocation(position);
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isFetchingLocation = false;
                                });
                              }
                            }
                          },
                    icon: _isFetchingLocation
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.gps_fixed),
                    tooltip: 'Get location',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          AdaptiveLayout(
            useHorizontalLayout: useHorizontalLayout,
            children: [
              CommonNumField(
                controller: widget.coordCtr.latitudeCtr,
                labelText: 'Decimal Latitude',
                hintText: 'Add a latitude',
                isDouble: true,
                isSigned: true,
                isLastField: false,
                helperText: _dmsLatitude.isEmpty ? null : _dmsLatitude,
              ),
              CommonNumField(
                controller: widget.coordCtr.longitudeCtr,
                labelText: 'Decimal Longitude',
                hintText: 'Add a longitude',
                isDouble: true,
                isSigned: true,
                isLastField: false,
                helperText: _dmsLongitude.isEmpty ? null : _dmsLongitude,
              ),
            ],
          ),
          const SizedBox(height: 12),
          CommonPadding(
            child: CommonNumField(
              controller: widget.coordCtr.elevationCtr,
              labelText: 'Elevation (m)',
              hintText: 'Add an elevation',
              isDouble: false,
              isLastField: false,
            ),
          ),
          CommonPadding(
            child: DropdownButtonFormField(
              initialValue: _getDatum(),
              decoration: const InputDecoration(
                labelText: 'Datum',
                hintText: 'Specify the datum',
              ),
              items: _datum
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: CommonDropdownText(text: e),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                widget.coordCtr.datumCtr.text = value.toString();
              },
            ),
          ),
          CommonPadding(
            child: CommonNumField(
              controller: widget.coordCtr.uncertaintyCtr,
              labelText: 'Uncertainty (m)',
              hintText: 'Add an uncertainty',
              isDouble: false,
              isLastField: false,
            ),
          ),
          CommonPadding(
            child: CommonTextField(
              controller: widget.coordCtr.gpsUnitCtr,
              labelText: 'GPS Unit',
              hintText: 'Specify the GPS unit',
              isLastField: false,
            ),
          ),
          CommonPadding(
            child: CommonTextField(
              maxLines: 3,
              controller: widget.coordCtr.noteCtr,
              labelText: 'Notes',
              hintText: 'Add notes (optional)',
              isLastField: true,
            ),
          ),
          if (widget.showActions) ...[
            const SizedBox(height: 16),
            CommonPadding(
              child: FormButton(
                isEditing: widget.isEditing,
                onSubmitted: submit,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _updateGPSDescription() async {
    final latText = widget.coordCtr.latitudeCtr.text;
    final lonText = widget.coordCtr.longitudeCtr.text;

    if (latText.isNotEmpty) {
      final lat = double.tryParse(latText);
      if (lat != null) {
        try {
          final dmsLat = await ddToDms(dd: lat, axis: CoordinateAxis.latitude);
          if (mounted) {
            setState(() {
              _dmsLatitude = _formatDms(dmsLat);
            });
          }
        } catch (_) {
          if (mounted) {
            setState(() {
              _dmsLatitude = '';
            });
          }
        }
      } else {
        setState(() {
          _dmsLatitude = '';
        });
      }
    } else {
      setState(() {
        _dmsLatitude = '';
      });
    }

    if (lonText.isNotEmpty) {
      final lon = double.tryParse(lonText);
      if (lon != null) {
        try {
          final dmsLon = await ddToDms(dd: lon, axis: CoordinateAxis.longitude);
          if (mounted) {
            setState(() {
              _dmsLongitude = _formatDms(dmsLon);
            });
          }
        } catch (_) {
          if (mounted) {
            setState(() {
              _dmsLongitude = '';
            });
          }
        }
      } else {
        setState(() {
          _dmsLongitude = '';
        });
      }
    } else {
      setState(() {
        _dmsLongitude = '';
      });
    }
  }

  String _formatDms(DmsCoordinateFfi dms) {
    String dir = _formatDirection(dms.direction);
    return '${dms.degrees}°${dms.minutes}\'${dms.seconds.toStringAsFixed(1)}" $dir';
  }

  String _formatDirection(CardinalDirection direction) {
    switch (direction) {
      case CardinalDirection.north:
        return 'N';
      case CardinalDirection.south:
        return 'S';
      case CardinalDirection.east:
        return 'E';
      case CardinalDirection.west:
        return 'W';
    }
  }

  Future<void> _prefillSiteId() async {
    final siteData = await SiteServices(ref: ref).getSite(widget.siteId);
    if (siteData != null && siteData.siteID != null) {
      if (mounted && widget.coordCtr.nameIdCtr.text.isEmpty) {
        setState(() {
          widget.coordCtr.nameIdCtr.text = siteData.siteID!;
        });
      }
    }
  }

  Future<Position?> _getLocation() async {
    try {
      return GeoLocationServices().getCurrentCoordinates();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () async {
                await Geolocator.openLocationSettings();
              },
            ),
          ),
        );
      }
    }
    return null;
  }

  void _populateLocation(Position position) {
    setState(() {
      widget.coordCtr.latitudeCtr.text = position.latitude.toStringAsFixed(6);
      widget.coordCtr.longitudeCtr.text = position.longitude.toStringAsFixed(6);
      widget.coordCtr.elevationCtr.text = position.altitude.toInt().toString();
      widget.coordCtr.uncertaintyCtr.text = position.accuracy
          .toInt()
          .toString();
    });
  }

  String _getDatum() {
    if (widget.coordCtr.datumCtr.text.isEmpty) {
      setState(() {
        widget.coordCtr.datumCtr.text = _datum[0];
      });
      return widget.coordCtr.datumCtr.text;
    } else {
      return widget.coordCtr.datumCtr.text;
    }
  }

  Future<void> _createCoordinate() async {
    CoordinateCompanion form = _getform();

    await CoordinateServices(ref: ref).createCoordinate(form);
  }

  Future<void> submit() async {
    try {
      if (widget.isEditing) {
        await _updateCoordinate();
      } else {
        await _createCoordinate();
      }
      ref.invalidate(coordinateBySiteProvider);
      ref.invalidate(coordinateByProjectProvider);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _updateCoordinate() async {
    CoordinateCompanion form = _getform();
    await CoordinateServices(
      ref: ref,
    ).updateCoordinate(widget.coordinateId!, form);
  }

  CoordinateCompanion _getform() {
    return CoordinateCompanion(
      nameId: db.Value(widget.coordCtr.nameIdCtr.text),
      decimalLatitude: db.Value(
        double.tryParse(widget.coordCtr.latitudeCtr.text),
      ),
      decimalLongitude: db.Value(
        double.tryParse(widget.coordCtr.longitudeCtr.text),
      ),
      elevationInMeter: db.Value(
        double.tryParse(widget.coordCtr.elevationCtr.text),
      ),
      datum: db.Value(widget.coordCtr.datumCtr.text),
      uncertaintyInMeters: db.Value(
        int.tryParse(widget.coordCtr.uncertaintyCtr.text),
      ),
      gpsUnit: db.Value(widget.coordCtr.gpsUnitCtr.text),
      siteID: db.Value(widget.siteId),
      notes: db.Value(widget.coordCtr.noteCtr.text),
    );
  }
}

class CoordinateInfoContent extends StatelessWidget {
  const CoordinateInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          header: 'Overview',
          content:
              'Coordinates of the site.'
              ' Use the add coordinate button to add a coordinate.'
              ' There is no limit to the number of coordinates that can be added.',
        ),
        InfoContent(
          content:
              'Current version only supports decimal format.'
              ' The West and South directions are negative'
              ' and the East and North directions are positive.',
        ),
        InfoContent(
          header: 'List information',
          content:
              'Top: Coordinate name\n'
              'Bottom (left to right): Latitude and Longitude,'
              ' Elevation, Uncertainty, and Datum',
        ),
        InfoContent(
          header: 'Datum',
          content:
              'The datum is the reference frame for the coordinates.'
              ' The default is WGS84, which is the standard datum for GPS.',
        ),
      ],
    );
  }
}

/// Full-screen coordinate management for the current project.
