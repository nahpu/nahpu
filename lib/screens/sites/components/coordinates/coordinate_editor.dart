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
  }

  @override
  void dispose() {
    widget.coordCtr.nameIdCtr.removeListener(_manualFieldsChanged);
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
                      onCoordinateChanged: _manualFieldsChanged,
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
          canRefresh: widget.coordCtr.hasCoordinateInput,
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

  void _manualFieldsChanged() {
    if (!mounted) return;
    setState(() {
      if (_manualPreview != null) _manualPreviewIsStale = true;
    });
  }

  Future<void> _refreshManualMap() async {
    try {
      final parsed = await _manualFormKey.currentState?._parseInput();
      if (parsed == null || !mounted) return;
      final name = widget.coordCtr.nameIdCtr.text.trim();
      setState(() {
        _manualPreview = CoordinateMapPoint(
          id: 0,
          name: name.isEmpty ? 'New coordinate' : name,
          latitude: parsed.decimalLatitude,
          longitude: parsed.decimalLongitude,
        );
        _manualPreviewIsStale = false;
      });
    } catch (error) {
      if (mounted) _showError(error.toString());
    }
  }

  Widget _buildImportReview() {
    final review = _review;
    if (review == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Supported files: GeoJSON/JSON, KML, zipped Shapefile, and GPX.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Wrap(
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
                      _isLoadingFile
                          ? 'Reading file…'
                          : 'Select coordinate file',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: OutlinedButton.icon(
                  onPressed: _scanQr,
                  icon: const Icon(Icons.qr_code_scanner_outlined),
                  label: const Text('Scan QR', overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: OutlinedButton.icon(
                  onPressed: _pickCoordinateFile,
                  icon: const Icon(Icons.file_open_outlined),
                  label: const Text(
                    'Choose another file',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
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
      final datums = await ref.read(
        userDefinedFieldProvider(datumPrefKey).future,
      );
      final forms = CoordinateExchangeService.companionsForSite(
        records,
        widget.siteId,
        defaultDatum: datums.firstOrNull,
      );
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
          onDetect: (capture) async {
            final rawValue = capture.barcodes.firstOrNull?.rawValue;
            if (rawValue == null) return;
            try {
              final coordinate = CoordinateExchangeService.decodeQr(rawValue);
              await _populateControllers(coordinate);
              if (!mounted || !context.mounted) return;
              Navigator.pop(context);
              setState(() => _mode = _AddCoordinateMode.manual);
            } catch (error) {
              if (!mounted || !context.mounted) return;
              Navigator.pop(context);
              _showError(error.toString());
            }
          },
        ),
      ),
    );
  }

  Future<void> _populateControllers(CoordinateData coordinate) async {
    String? datum = coordinate.datum;
    if (datum == null) {
      final datums = await ref.read(
        userDefinedFieldProvider(datumPrefKey).future,
      );
      datum = datums.firstOrNull;
    }
    if (!mounted) return;
    widget.coordCtr.nameIdCtr.text = coordinate.nameId ?? '';
    widget.coordCtr.setCoordinateInputData(
      decimalLatitude: coordinate.decimalLatitude,
      decimalLongitude: coordinate.decimalLongitude,
      verbatimLatitude: coordinate.verbatimLatitude,
      verbatimLongitude: coordinate.verbatimLongitude,
      verbatimCoordinates: coordinate.verbatimCoordinates,
      verbatimCoordinateSystem: coordinate.verbatimCoordinateSystem,
    );
    widget.coordCtr.elevationCtr.text =
        coordinate.elevationInMeter?.toString() ?? '';
    widget.coordCtr.datumCtr.text = datum ?? '';
    widget.coordCtr.uncertaintyCtr.text =
        coordinate.uncertaintyInMeters?.toString() ?? '';
    widget.coordCtr.gpsUnitCtr.text = coordinate.gpsUnit ?? '';
    widget.coordCtr.noteCtr.text = coordinate.notes ?? '';
    _manualFormKey.currentState?.syncInputFormat();
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
    this.onCoordinateChanged,
  });

  final int? coordinateId;
  final int siteId;
  final CoordinateCtrModel coordCtr;
  final bool isEditing;
  final bool disposeController;
  final bool showActions;
  final VoidCallback? onCoordinateChanged;

  @override
  CoordinateFormsState createState() => CoordinateFormsState();
}

class CoordinateFormsState extends ConsumerState<CoordinateForms> {
  bool _isFetchingLocation = false;
  String? _configuredDatumDefault;
  String _dmsLatitude = '';
  String _dmsLongitude = '';
  late CoordinateInputFormat _inputFormat;
  AngularCoordinateValidation? _latitudeValidation;
  AngularCoordinateValidation? _longitudeValidation;
  int _formatSelectionRevision = 0;

  @override
  void initState() {
    super.initState();
    _inputFormat = CoordinateInputFormat.values.byName(
      widget.coordCtr.inputFormat,
    );
    widget.coordCtr.latitudeCtr.addListener(_updateGPSDescription);
    widget.coordCtr.longitudeCtr.addListener(_updateGPSDescription);
    if (!widget.isEditing) {
      _prefillSiteId();
      _setConfiguredDatumDefault();
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
          CommonPadding(
            child: DropdownButtonFormField<CoordinateInputFormat>(
              key: ValueKey(_formatSelectionRevision),
              initialValue: _inputFormat,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Coordinate format'),
              items: const [
                DropdownMenuItem(
                  value: CoordinateInputFormat.decimalDegrees,
                  child: Text('Decimal degrees'),
                ),
                DropdownMenuItem(
                  value: CoordinateInputFormat.degreesDecimalMinutes,
                  child: Text('Degrees decimal minutes (DDM)'),
                ),
                DropdownMenuItem(
                  value: CoordinateInputFormat.degreesMinutesSeconds,
                  child: Text('Degrees minutes seconds (DMS)'),
                ),
                DropdownMenuItem(
                  value: CoordinateInputFormat.utm,
                  child: Text('UTM (WGS84)'),
                ),
              ],
              onChanged: _changeInputFormat,
            ),
          ),
          const SizedBox(height: 12),
          if (_inputFormat == CoordinateInputFormat.utm)
            CommonPadding(
              child: CommonTextField(
                controller: widget.coordCtr.utmCtr,
                labelText: 'UTM coordinate',
                hintText: '11 N 385153 3768853',
                isLastField: false,
                onChanged: (_) => _coordinateInputChanged(),
              ),
            )
          else if (_inputFormat == CoordinateInputFormat.decimalDegrees)
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
                  onChanged: (_) => _coordinateInputChanged(),
                ),
                CommonNumField(
                  controller: widget.coordCtr.longitudeCtr,
                  labelText: 'Decimal Longitude',
                  hintText: 'Add a longitude',
                  isDouble: true,
                  isSigned: true,
                  isLastField: false,
                  helperText: _dmsLongitude.isEmpty ? null : _dmsLongitude,
                  onChanged: (_) => _coordinateInputChanged(),
                ),
              ],
            )
          else
            Column(
              children: [
                CommonPadding(
                  child: _AngularCoordinateFields(
                    axis: AngularCoordinateAxis.latitude,
                    controller: widget.coordCtr.latitudeAngularCtr,
                    includesSeconds:
                        _inputFormat ==
                        CoordinateInputFormat.degreesMinutesSeconds,
                    validation: _latitudeValidation,
                    onChanged: () =>
                        _angularInputChanged(AngularCoordinateAxis.latitude),
                  ),
                ),
                const SizedBox(height: 12),
                CommonPadding(
                  child: _AngularCoordinateFields(
                    axis: AngularCoordinateAxis.longitude,
                    controller: widget.coordCtr.longitudeAngularCtr,
                    includesSeconds:
                        _inputFormat ==
                        CoordinateInputFormat.degreesMinutesSeconds,
                    validation: _longitudeValidation,
                    onChanged: () =>
                        _angularInputChanged(AngularCoordinateAxis.longitude),
                  ),
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
            child: ref
                .watch(effectiveUserDefinedFieldProvider(datumPrefKey))
                .when(
                  data: (data) {
                    final current = widget.coordCtr.datumCtr.text.trim();
                    final options = includeCurrentVocabularyValue(
                      data,
                      current.isEmpty ? null : current,
                    );
                    final selected = current.isEmpty
                        ? _configuredDatumDefault
                        : current;
                    return DropdownButtonFormField<String>(
                      key: ValueKey(selected),
                      initialValue: selected,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Datum',
                        hintText: 'Specify the datum',
                      ),
                      items: options
                          .map(
                            (datum) => DropdownMenuItem(
                              value: datum,
                              child: CommonDropdownText(text: datum),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        widget.coordCtr.datumCtr.text = value ?? '';
                      },
                    );
                  },
                  loading: () => const CommonProgressIndicator(),
                  error: (error, _) => Text(error.toString()),
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

  Future<void> _changeInputFormat(CoordinateInputFormat? value) async {
    if (value == null || value == _inputFormat) return;
    if (widget.coordCtr.hasCoordinateInput) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Change coordinate format?'),
          content: const Text(
            'Changing the format clears the entered coordinate values. '
            'Name, elevation, datum, uncertainty, GPS unit, and notes are kept.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear and switch'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (confirmed != true) {
        setState(() => _formatSelectionRevision++);
        return;
      }
    }

    setState(() {
      widget.coordCtr.clearCoordinateInput();
      _inputFormat = value;
      widget.coordCtr.inputFormat = value.name;
      _latitudeValidation = null;
      _longitudeValidation = null;
      _dmsLatitude = '';
      _dmsLongitude = '';
      _formatSelectionRevision++;
      if (value == CoordinateInputFormat.utm) {
        widget.coordCtr.datumCtr.text = 'WGS84';
      }
    });
    _coordinateInputChanged();
  }

  void _coordinateInputChanged() {
    widget.onCoordinateChanged?.call();
  }

  void _angularInputChanged(AngularCoordinateAxis axis) {
    setState(() {
      if (axis == AngularCoordinateAxis.latitude) {
        _latitudeValidation = null;
        widget.coordCtr.latitudeAngularCtr.invalidStoredValue = null;
      } else {
        _longitudeValidation = null;
        widget.coordCtr.longitudeAngularCtr.invalidStoredValue = null;
      }
    });
    _coordinateInputChanged();
  }

  void syncInputFormat() {
    setState(() {
      _inputFormat = CoordinateInputFormat.values.byName(
        widget.coordCtr.inputFormat,
      );
      _latitudeValidation = null;
      _longitudeValidation = null;
      _formatSelectionRevision++;
    });
    _coordinateInputChanged();
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
      return await GeoLocationServices().getCurrentCoordinates();
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
      widget.coordCtr.clearCoordinateInput();
      _inputFormat = CoordinateInputFormat.decimalDegrees;
      widget.coordCtr.inputFormat = _inputFormat.name;
      _formatSelectionRevision++;
      widget.coordCtr.latitudeCtr.text = position.latitude.toStringAsFixed(6);
      widget.coordCtr.longitudeCtr.text = position.longitude.toStringAsFixed(6);
      widget.coordCtr.elevationCtr.text = position.altitude.toInt().toString();
      widget.coordCtr.uncertaintyCtr.text = position.accuracy
          .toInt()
          .toString();
    });
    _coordinateInputChanged();
  }

  Future<void> _setConfiguredDatumDefault() async {
    final datums = await ref.read(
      userDefinedFieldProvider(datumPrefKey).future,
    );
    if (!mounted) return;
    final datum = datums.firstOrNull;
    setState(() {
      _configuredDatumDefault = datum;
      if (widget.coordCtr.datumCtr.text.isEmpty && datum != null) {
        widget.coordCtr.datumCtr.text = datum;
      }
    });
  }

  Future<void> _createCoordinate() async {
    final form = await _getform();

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
    final form = await _getform();
    await CoordinateServices(
      ref: ref,
    ).updateCoordinate(widget.coordinateId!, form);
  }

  Future<ParsedCoordinateInput> _parseInput() async {
    String primary;
    String? secondary;
    if (_inputFormat == CoordinateInputFormat.utm) {
      primary = widget.coordCtr.utmCtr.text;
    } else if (_inputFormat == CoordinateInputFormat.decimalDegrees) {
      primary = widget.coordCtr.latitudeCtr.text;
      secondary = widget.coordCtr.longitudeCtr.text;
    } else {
      final includesSeconds =
          _inputFormat == CoordinateInputFormat.degreesMinutesSeconds;
      final latitudeValidation = CoordinateInputPartsCodec.validate(
        widget.coordCtr.latitudeAngularCtr.parts,
        axis: AngularCoordinateAxis.latitude,
        includesSeconds: includesSeconds,
      );
      final longitudeValidation = CoordinateInputPartsCodec.validate(
        widget.coordCtr.longitudeAngularCtr.parts,
        axis: AngularCoordinateAxis.longitude,
        includesSeconds: includesSeconds,
      );
      if (mounted) {
        setState(() {
          _latitudeValidation = latitudeValidation;
          _longitudeValidation = longitudeValidation;
        });
      }
      if (!latitudeValidation.isValid || !longitudeValidation.isValid) {
        final message = !latitudeValidation.isValid
            ? latitudeValidation.firstError
            : longitudeValidation.firstError;
        throw FormatException(message);
      }
      primary = CoordinateInputPartsCodec.compose(
        widget.coordCtr.latitudeAngularCtr.parts,
        axis: AngularCoordinateAxis.latitude,
        includesSeconds: includesSeconds,
      );
      secondary = CoordinateInputPartsCodec.compose(
        widget.coordCtr.longitudeAngularCtr.parts,
        axis: AngularCoordinateAxis.longitude,
        includesSeconds: includesSeconds,
      );
    }
    return parseCoordinateInput(
      format: _inputFormat,
      primary: primary,
      secondary: secondary,
    );
  }

  Future<CoordinateCompanion> _getform() async {
    final parsed = await _parseInput();
    return CoordinateCompanion(
      nameId: db.Value(widget.coordCtr.nameIdCtr.text),
      decimalLatitude: db.Value(parsed.decimalLatitude),
      decimalLongitude: db.Value(parsed.decimalLongitude),
      verbatimLatitude: db.Value(parsed.verbatimLatitude),
      verbatimLongitude: db.Value(parsed.verbatimLongitude),
      verbatimCoordinates: db.Value(parsed.verbatimCoordinates),
      verbatimCoordinateSystem: db.Value(parsed.verbatimCoordinateSystem),
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

class _AngularCoordinateFields extends StatelessWidget {
  static const double _controlWidth = 132;

  const _AngularCoordinateFields({
    required this.axis,
    required this.controller,
    required this.includesSeconds,
    required this.validation,
    required this.onChanged,
  });

  final AngularCoordinateAxis axis;
  final AngularCoordinateCtrModel controller;
  final bool includesSeconds;
  final AngularCoordinateValidation? validation;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final axisLabel = axis == AngularCoordinateAxis.latitude
        ? 'Latitude'
        : 'Longitude';
    final directions = axis == AngularCoordinateAxis.latitude
        ? const [
            AngularCoordinateDirection.north,
            AngularCoordinateDirection.south,
          ]
        : const [
            AngularCoordinateDirection.east,
            AngularCoordinateDirection.west,
          ];
    final invalidStoredValue = controller.invalidStoredValue;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(80),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: NahpuStroke.thin,
        ),
        borderRadius: BorderRadius.circular(NahpuRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            axisLabel,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (invalidStoredValue != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'This verbatim ${axis.name} could not be read and may have been '
                'changed outside NAHPU. Re-enter it before saving.\n'
                'Original: ${invalidStoredValue.isEmpty ? '(missing)' : invalidStoredValue}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: NahpuSpacing.md,
            runSpacing: NahpuSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              SizedBox(
                width: _controlWidth,
                child: CommonNumField(
                  controller: controller.degreesCtr,
                  labelText: 'Degree',
                  hintText: '0',
                  isLastField: false,
                  errorText: validation?.degreesError,
                  onChanged: (_) => onChanged(),
                ),
              ),
              SizedBox(
                width: _controlWidth,
                child: CommonNumField(
                  controller: controller.minutesCtr,
                  labelText: 'Minute',
                  hintText: '0',
                  isDouble: !includesSeconds,
                  isLastField: false,
                  errorText: validation?.minutesError,
                  onChanged: (_) => onChanged(),
                ),
              ),
              if (includesSeconds)
                SizedBox(
                  width: _controlWidth,
                  child: CommonNumField(
                    controller: controller.secondsCtr,
                    labelText: 'Second',
                    hintText: '0',
                    isDouble: true,
                    isLastField: false,
                    errorText: validation?.secondsError,
                    onChanged: (_) => onChanged(),
                  ),
                ),
              SizedBox(
                width: _controlWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Direction'),
                    const SizedBox(height: 4),
                    SegmentedButton<AngularCoordinateDirection>(
                      showSelectedIcon: false,
                      emptySelectionAllowed: true,
                      segments: [
                        for (final direction in directions)
                          ButtonSegment(
                            value: direction,
                            label: Text(direction.label),
                          ),
                      ],
                      selected: controller.direction == null
                          ? const <AngularCoordinateDirection>{}
                          : {controller.direction!},
                      onSelectionChanged: (selection) {
                        controller.direction = selection.firstOrNull;
                        onChanged();
                      },
                    ),
                    if (validation?.directionError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        validation!.directionError!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
              'Manual entry supports decimal degrees (DD), degrees and decimal'
              ' minutes (DDM), degrees-minutes-seconds (DMS), and WGS84 UTM.'
              ' DDM and DMS use separate numeric fields with required N/S and'
              ' E/W direction controls.',
        ),
        InfoContent(
          header: 'Import',
          content:
              'Coordinate file import supports GeoJSON/JSON, KML, zipped'
              ' Shapefile, and GPX files. NAHPU coordinate QR codes can also'
              ' be scanned from the Import tab.',
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
              ' New coordinates use the first datum configured in Site Settings.',
        ),
      ],
    );
  }
}

/// Full-screen coordinate management for the current project.
