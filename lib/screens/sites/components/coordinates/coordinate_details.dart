part of '../coordinates.dart';

class CoordinateMenu extends ConsumerStatefulWidget {
  const CoordinateMenu({
    super.key,
    required this.coordinateId,
    required this.siteId,
    required this.coordinate,
  });

  final int coordinateId;
  final int siteId;
  final CoordinateData coordinate;

  @override
  CoordinateMenuState createState() => CoordinateMenuState();
}

class CoordinateMenuState extends ConsumerState<CoordinateMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      onSelected: _onSelected,
      itemBuilder: (context) => <PopupMenuEntry<CoordinatePopUpMenuItems>>[
        const PopupMenuItem<CoordinatePopUpMenuItems>(
          value: CoordinatePopUpMenuItems.edit,
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<CoordinatePopUpMenuItems>(
          value: CoordinatePopUpMenuItems.qr,
          child: ListTile(
            leading: Icon(Icons.qr_code_outlined),
            title: Text('Show QR'),
          ),
        ),
        const PopupMenuItem<CoordinatePopUpMenuItems>(
          value: CoordinatePopUpMenuItems.copy,
          child: ListTile(
            leading: Icon(Icons.copy_outlined),
            title: Text('Copy'),
          ),
        ),
        const PopupMenuItem<CoordinatePopUpMenuItems>(
          value: CoordinatePopUpMenuItems.open,
          child: ListTile(
            leading: Icon(Icons.open_in_browser_outlined),
            title: Text('Open in map'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<CoordinatePopUpMenuItems>(
          value: CoordinatePopUpMenuItems.details,
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Details'),
          ),
        ),
      ],
    );
  }

  Future<void> _onSelected(CoordinatePopUpMenuItems item) async {
    switch (item) {
      case CoordinatePopUpMenuItems.details:
        _showDetails();
        break;
      case CoordinatePopUpMenuItems.edit:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCoordinate(
              coordinateId: widget.coordinateId,
              siteId: widget.siteId,
              coordCtr: CoordinateCtrModel.fromData(widget.coordinate),
            ),
          ),
        );
        break;
      case CoordinatePopUpMenuItems.copy:
        await Clipboard.setData(ClipboardData(text: _latLong));
        if (context.mounted) {
          _showCopiedSnackBar();
        }
        break;
      case CoordinatePopUpMenuItems.open:
        await _launchGoogleMap();
        break;
      case CoordinatePopUpMenuItems.qr:
        showCoordinateQrDialog(context, widget.coordinate);
        break;
    }
  }

  void _showDetails() {
    final useHorizontalLayout = MediaQuery.sizeOf(context).width > 600.0;
    if (useHorizontalLayout) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Coordinate Details',
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: 880,
              height: 460,
              child: CoordinateDetails(coordinate: widget.coordinate),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) {
          return Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Coordinate Details',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 2),
                Expanded(
                  child: CoordinateDetails(coordinate: widget.coordinate),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _showCopiedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Latitude and Longitude copied to clipboard'),
      ),
    );
  }

  Future<void> _launchGoogleMap() async {
    const host = 'www.google.com';
    const path = 'maps/search/';
    final queryParameters = {'api': '1', 'query': _latLong};
    Uri url = Uri.https(host, path, queryParameters);
    if (kDebugMode) print(url.toString());
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  String get _latLong {
    return '${widget.coordinate.decimalLatitude},'
        '${widget.coordinate.decimalLongitude}';
  }
}

class CoordinateDetails extends ConsumerStatefulWidget {
  const CoordinateDetails({super.key, required this.coordinate});

  final CoordinateData coordinate;

  @override
  CoordinateDetailsState createState() => CoordinateDetailsState();
}

class CoordinateDetailsState extends ConsumerState<CoordinateDetails> {
  String _dmsLatitude = 'Loading...';
  String _dmsLongitude = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadDms();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final map = _CoordinateDetailMap(coordinate: widget.coordinate);
        final details = _buildDetails(context);
        if (constraints.maxWidth >= NahpuBreakpoints.compact) {
          final columns = Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: details),
              const SizedBox(width: NahpuSpacing.xl),
              Expanded(child: map),
            ],
          );
          return Padding(
            padding: const EdgeInsets.all(NahpuSpacing.md),
            child: constraints.hasBoundedHeight
                ? columns
                : SizedBox(height: _wideMapHeight, child: columns),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                NahpuSpacing.xl,
                NahpuSpacing.md,
                NahpuSpacing.xl,
                0,
              ),
              child: SizedBox(height: _mapHeight, child: map),
            ),
            if (constraints.hasBoundedHeight)
              Expanded(child: details)
            else
              details,
          ],
        );
      },
    );
  }

  Widget _buildDetails(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDetailRow(
            context,
            Icons.tag_outlined,
            'Name',
            widget.coordinate.nameId ?? 'No Name',
          ),
          const Divider(height: 16),
          _buildDetailRow(
            context,
            Icons.pin_drop_outlined,
            'Latitude',
            widget.coordinate.decimalLatitude != null
                ? '${widget.coordinate.decimalLatitude} ($_dmsLatitude)'
                : 'N/A',
          ),
          const Divider(height: 16),
          _buildDetailRow(
            context,
            Icons.pin_drop_outlined,
            'Longitude',
            widget.coordinate.decimalLongitude != null
                ? '${widget.coordinate.decimalLongitude} ($_dmsLongitude)'
                : 'N/A',
          ),
          if (widget.coordinate.verbatimCoordinateSystem != null) ...[
            const Divider(height: 16),
            _buildDetailRow(
              context,
              Icons.text_fields_outlined,
              'Original coordinate',
              [
                    widget.coordinate.verbatimLatitude,
                    widget.coordinate.verbatimLongitude,
                    widget.coordinate.verbatimCoordinates,
                  ]
                  .whereType<String>()
                  .where((value) => value.isNotEmpty)
                  .join(', '),
            ),
            const Divider(height: 16),
            _buildDetailRow(
              context,
              Icons.grid_on_outlined,
              'Original format',
              widget.coordinate.verbatimCoordinateSystem!,
            ),
          ],
          const Divider(height: 16),
          _buildDetailRow(
            context,
            Icons.landscape_outlined,
            'Elevation',
            widget.coordinate.elevationInMeter != null
                ? '${widget.coordinate.elevationInMeter?.truncateZero()} m'
                : 'N/A',
          ),
          const Divider(height: 16),
          _buildDetailRow(
            context,
            Icons.map_outlined,
            'Datum',
            widget.coordinate.datum ?? 'N/A',
          ),
          const Divider(height: 16),
          _buildDetailRow(
            context,
            Icons.circle_outlined,
            'Uncertainty',
            widget.coordinate.uncertaintyInMeters != null &&
                    widget.coordinate.uncertaintyInMeters != 0
                ? '±${widget.coordinate.uncertaintyInMeters} m'
                : 'N/A',
          ),
          const Divider(height: 16),
          _buildDetailRow(
            context,
            Icons.settings_input_antenna_outlined,
            'GPS Unit',
            widget.coordinate.gpsUnit != null &&
                    widget.coordinate.gpsUnit!.isNotEmpty
                ? widget.coordinate.gpsUnit!
                : 'N/A',
          ),
          const Divider(height: 16),
          _buildDetailRow(
            context,
            Icons.notes_outlined,
            'Notes',
            widget.coordinate.notes != null &&
                    widget.coordinate.notes!.isNotEmpty
                ? widget.coordinate.notes!
                : '',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDms() async {
    final lat = widget.coordinate.decimalLatitude;
    final lon = widget.coordinate.decimalLongitude;
    if (lat != null && lon != null) {
      try {
        final dmsLat = await ddToDms(dd: lat, axis: CoordinateAxis.latitude);
        final dmsLon = await ddToDms(dd: lon, axis: CoordinateAxis.longitude);
        if (mounted) {
          setState(() {
            _dmsLatitude = _formatDms(dmsLat);
            _dmsLongitude = _formatDms(dmsLon);
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _dmsLatitude = 'N/A';
            _dmsLongitude = 'N/A';
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _dmsLatitude = 'N/A';
          _dmsLongitude = 'N/A';
        });
      }
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
}

/// Height of the detail map when the layout stacks it above the details.
const double _mapHeight = 220;

/// Height of the two-column layout when its parent leaves the height unbounded.
const double _wideMapHeight = 320;

class _CoordinateDetailMap extends StatelessWidget {
  const _CoordinateDetailMap({required this.coordinate});

  final CoordinateData coordinate;

  @override
  Widget build(BuildContext context) {
    final name = coordinate.nameId?.trim() ?? '';
    final point = CoordinateMapPoint(
      id: coordinate.id ?? 0,
      name: name.isNotEmpty ? name : 'Unnamed coordinate',
      latitude: coordinate.decimalLatitude,
      longitude: coordinate.decimalLongitude,
    );
    return CoordinateLocationMap(
      points: [point],
      selectedPointId: point.id,
      onPointSelected: (_) {},
    );
  }
}
