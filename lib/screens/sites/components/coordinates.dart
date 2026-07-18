import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/maps/coordinate_location_map.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/coordinate_exchange_service.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/maps/coordinate_map_point.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/actions/export_share_button.dart';
import 'package:nahpu/screens/exports/components/file_settings.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/types/sites.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:nahpu/src/rust/api/gis.dart';
import 'package:nahpu/src/rust/api/gis.dart' as rust_gis;
import 'package:url_launcher/url_launcher.dart';

enum CoordinatePopUpMenuItems { details, edit, copy, open, qr }

class CoordinateFields extends StatelessWidget {
  const CoordinateFields({super.key, required this.siteId});

  final int siteId;

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Coordinates',
      infoContent: const CoordinateInfoContent(),
      mainAxisAlignment: MainAxisAlignment.start,
      child: SizedBox(height: 484, child: CoordinateList(sideId: siteId)),
    );
  }
}

class AddCoordinateButton extends ConsumerWidget {
  const AddCoordinateButton({super.key, required this.siteId});

  final int siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        SecondaryButton(
          text: 'Manage',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CoordinateManager(),
              ),
            );
          },
        ),
        PrimaryButton(
          icon: Icons.add,
          label: 'Add coordinate',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewCoordinate(
                  siteId: siteId,
                  coordCtr: CoordinateCtrModel.empty(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class CoordinateList extends ConsumerStatefulWidget {
  const CoordinateList({
    super.key,
    required this.sideId,
    this.selectedCoordinateId,
    this.onCoordinateSelected,
  });

  final int sideId;
  final int? selectedCoordinateId;
  final ValueChanged<int>? onCoordinateSelected;

  @override
  CoordinateListState createState() => CoordinateListState();
}

class CoordinateListState extends ConsumerState<CoordinateList> {
  bool _isSelecting = false;
  final List<int> _selectedCoordinates = [];

  @override
  Widget build(BuildContext context) {
    final coordinates = ref.watch(coordinateBySiteProvider(widget.sideId));
    ScrollController scrollController = ScrollController();
    return coordinates.when(
      data: (data) {
        return data.isEmpty
            ? EmptyCoordinateList(siteId: widget.sideId)
            : Column(
                children: [
                  SelectItemsInterface(
                    isSelecting: _isSelecting,
                    onClearPressed: _selectedCoordinates.isEmpty
                        ? null
                        : () {
                            setState(() {
                              _selectedCoordinates.clear();
                            });
                          },
                    onSelectAllPressed: () {
                      setState(() {
                        _selectedCoordinates.clear();
                        _selectedCoordinates.addAll(
                          data
                              .where((e) => e.id != null)
                              .map((e) => e.id!)
                              .toList(),
                        );
                      });
                    },
                    onSelectPressed: () {
                      setState(() {
                        _isSelecting = !_isSelecting;
                        _selectedCoordinates.clear();
                      });
                    },
                  ),
                  Flexible(
                    child: CommonScrollbar(
                      scrollController: scrollController,
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: scrollController,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            dense: true,
                            selected:
                                data[index].id == widget.selectedCoordinateId,
                            onTap:
                                !_isSelecting &&
                                    widget.onCoordinateSelected != null &&
                                    data[index].id != null
                                ? () => widget.onCoordinateSelected?.call(
                                    data[index].id!,
                                  )
                                : null,
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                !_isSelecting
                                    ? CoordinateTileIcon(
                                        name: data[index].nameId ?? 'unknown',
                                      )
                                    : ListCheckBox(
                                        isDisabled: false,
                                        value: _selectedCoordinates.contains(
                                          data[index].id,
                                        ),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (data[index].id != null) {
                                              if (value == true) {
                                                _selectedCoordinates.add(
                                                  data[index].id!,
                                                );
                                              } else {
                                                _selectedCoordinates.remove(
                                                  data[index].id,
                                                );
                                              }
                                            }
                                          });
                                        },
                                      ),
                              ],
                            ),
                            title: CoordinateTitle(
                              coordinateId: data[index].nameId,
                            ),
                            subtitle: CoordinateSubtitle(
                              coordinate: data[index],
                            ),
                            trailing: !_isSelecting
                                ? CoordinateMenu(
                                    coordinateId: data[index].id!,
                                    siteId: data[index].siteID!,
                                    coordinate: data[index],
                                  )
                                : const SizedBox.shrink(),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  !_isSelecting
                      ? AddCoordinateButton(siteId: widget.sideId)
                      : DeleteItemsButton(
                          selectedItems: _selectedCoordinates,
                          itemName: 'coordinates',
                          onPressedFunction: () async {
                            await _deleteCoodinates();
                            setState(() {
                              _selectedCoordinates.clear();
                            });
                          },
                        ),
                ],
              );
      },
      loading: () => const CommonProgressIndicator(),
      error: (error, stack) => Text(error.toString()),
    );
  }

  Future<void> _deleteCoodinates() async {
    try {
      CoordinateServices(
        ref: ref,
      ).deleteCoordinatesFromList(_selectedCoordinates);
      ref.invalidate(coordinateBySiteProvider);
      setState(() {
        _isSelecting = false;
      });
      if (context.mounted) {
        _pop();
      }
    } catch (e) {
      if (context.mounted) {
        _showError(e.toString());
      }
    }
  }

  void _pop() {
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 10)),
    );
  }
}

class EmptyCoordinateList extends StatelessWidget {
  const EmptyCoordinateList({super.key, required this.siteId});

  final int siteId;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('No coordinates added'),
        const SizedBox(height: 8),
        AddCoordinateButton(siteId: siteId),
      ],
    );
  }
}

class CoordinateTileIcon extends StatelessWidget {
  const CoordinateTileIcon({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return TileSvgIcon(iconPath: _iconPath);
  }

  String get _iconPath {
    return CoordinateIcon(coordinateName: name).matchCoordinateToIconPath();
  }
}

class CoordinateTitle extends StatelessWidget {
  const CoordinateTitle({super.key, required this.coordinateId});

  final String? coordinateId;

  @override
  Widget build(BuildContext context) {
    return Text(
      coordinateId ?? 'No ID',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class CoordinateSubtitle extends StatelessWidget {
  const CoordinateSubtitle({super.key, required this.coordinate});

  final CoordinateData coordinate;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          const WidgetSpan(
            child: TileIcon(icon: Icons.pin_drop_outlined),
            alignment: PlaceholderAlignment.middle,
          ),
          TextSpan(
            style: Theme.of(context).textTheme.labelLarge,
            text:
                '${coordinate.decimalLatitude}, ${coordinate.decimalLongitude}',
          ),
          const TextSpan(text: '  '),
          const WidgetSpan(
            child: TileIcon(icon: Icons.landscape_outlined),
            alignment: PlaceholderAlignment.middle,
          ),
          TextSpan(
            style: Theme.of(context).textTheme.labelLarge,
            text: _getCoordinateElevation(),
          ),
          const TextSpan(text: '  '),
          const WidgetSpan(
            child: TileIcon(icon: Icons.circle_outlined),
            alignment: PlaceholderAlignment.middle,
          ),
          TextSpan(
            style: Theme.of(context).textTheme.labelLarge,
            text: _getCoordinateUncertainty(),
          ),
          const TextSpan(text: '  '),
          const WidgetSpan(
            child: TileIcon(icon: Icons.map_outlined),
            alignment: PlaceholderAlignment.middle,
          ),
          TextSpan(
            style: Theme.of(context).textTheme.labelLarge,
            text: '${coordinate.datum}',
          ),
        ],
      ),
    );
  }

  String _getCoordinateUncertainty() {
    if (coordinate.uncertaintyInMeters == null ||
        coordinate.uncertaintyInMeters == 0) {
      return '± ? m';
    } else {
      return '±${coordinate.uncertaintyInMeters} m';
    }
  }

  String _getCoordinateElevation() {
    if (coordinate.elevationInMeter == null) {
      return '? m';
    } else {
      return '${coordinate.elevationInMeter?.truncateZero()} m';
    }
  }
}

void showCoordinateQrDialog(BuildContext context, CoordinateData coordinate) {
  final name = coordinate.nameId?.trim();
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(name == null || name.isEmpty ? 'Coordinate' : name),
      content: SizedBox.square(
        dimension: 300,
        child: QrImageView(
          data: CoordinateExchangeService.encodeQr(coordinate),
          backgroundColor: Colors.white,
          color: Colors.black,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

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
              width: 480,
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
                const Divider(height: 1),
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
        final dmsLat = await ddToDms(dd: lat, isLatitude: true);
        final dmsLon = await ddToDms(dd: lon, isLatitude: false);
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
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              final content = _mode == _AddCoordinateMode.import
                  ? _buildImportReview()
                  : CoordinateForms(
                      coordinateId: null,
                      siteId: widget.siteId,
                      coordCtr: widget.coordCtr,
                      disposeController: false,
                    );
              final map = _mode == _AddCoordinateMode.import
                  ? _ImportCoordinateMap(
                      records: _review?.coordinates ?? const [],
                      focusedIndex: _focusedImport,
                      onFocused: (index) =>
                          setState(() => _focusedImport = index),
                    )
                  : _ManualCoordinateMap(
                      point: _manualPreview,
                      isStale: _manualPreviewIsStale,
                      canRefresh: _validManualPoint != null,
                      onRefresh: _refreshManualMap,
                    );
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
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (_mode == _AddCoordinateMode.manual &&
                                        _validManualPoint != null)
                                      FilledButton.icon(
                                        onPressed: _refreshManualMap,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Refresh map'),
                                      ),
                                    OutlinedButton.icon(
                                      onPressed:
                                          _mode == _AddCoordinateMode.manual &&
                                              (_manualPreview == null ||
                                                  _manualPreviewIsStale)
                                          ? null
                                          : () => _showMapSheet(map),
                                      icon: const Icon(Icons.map_outlined),
                                      label: const Text('Show on map'),
                                    ),
                                  ],
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
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _selectedImports.isEmpty ? null : _importSelected,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text('Add ${_selectedImports.length} selected'),
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
  });

  final int? coordinateId;
  final int siteId;
  final CoordinateCtrModel coordCtr;
  final bool isEditing;
  final bool disposeController;

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
          const SizedBox(height: 16),
          CommonPadding(
            child: FormButton(
              isEditing: widget.isEditing,
              onSubmitted: () async {
                try {
                  if (widget.isEditing) {
                    await _updateCoordinate();
                  } else {
                    await _createCoordinate();
                  }
                  ref.invalidate(coordinateBySiteProvider);
                  ref.invalidate(coordinateByProjectProvider);
                  if (context.mounted) Navigator.pop(context);
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error.toString())));
                  }
                }
              },
            ),
          ),
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
          final dmsLat = await ddToDms(dd: lat, isLatitude: true);
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
          final dmsLon = await ddToDms(dd: lon, isLatitude: false);
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
class CoordinateManager extends ConsumerStatefulWidget {
  const CoordinateManager({super.key});

  @override
  ConsumerState<CoordinateManager> createState() => _CoordinateManagerState();
}

class _CoordinateManagerState extends ConsumerState<CoordinateManager> {
  int? _siteFilterId;
  int? _selectedCoordinateId;

  @override
  Widget build(BuildContext context) {
    final coordinates = ref.watch(coordinateByProjectProvider);
    final sites = ref.watch(siteEntryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage coordinates')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final map = _CoordinateMapPane(
              coordinates: coordinates,
              siteFilterId: _siteFilterId,
              selectedCoordinateId: _selectedCoordinateId,
              onCoordinateSelected: _selectCoordinate,
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
                          selectedCoordinateId: _selectedCoordinateId,
                          onSiteFilterChanged: _changeSiteFilter,
                          onCoordinateSelected: _selectCoordinate,
                          onShareCoordinate: _shareCoordinate,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _CoordinateSurfacePanel(child: map)),
                  ],
                ),
              );
            }
            final list = _CoordinateSurfacePanel(
              child: _CoordinateManagerListPane(
                coordinates: coordinates,
                sites: sites,
                siteFilterId: _siteFilterId,
                selectedCoordinateId: _selectedCoordinateId,
                onSiteFilterChanged: _changeSiteFilter,
                onCoordinateSelected: _selectCoordinate,
                onShareCoordinate: _shareCoordinate,
              ),
            );
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.list_outlined), text: 'Coordinates'),
                      Tab(icon: Icon(Icons.map_outlined), text: 'Map'),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TabBarView(
                        children: [
                          list,
                          _CoordinateSurfacePanel(child: map),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _changeSiteFilter(int? siteId) {
    setState(() {
      _siteFilterId = siteId;
      _selectedCoordinateId = null;
    });
  }

  void _selectCoordinate(int coordinateId) {
    setState(() => _selectedCoordinateId = coordinateId);
  }

  Future<void> _shareCoordinate(CoordinateData coordinate) async {
    final content = _CoordinateExportOverlay(coordinate: coordinate);
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

class _CoordinateExportOverlay extends ConsumerStatefulWidget {
  const _CoordinateExportOverlay({required this.coordinate});

  final CoordinateData coordinate;

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
    _exportCtr.fileNameCtr.text = CoordinateExchangeService.defaultFileName(
      widget.coordinate,
    );
  }

  @override
  void didUpdateWidget(covariant _CoordinateExportOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coordinate.id != widget.coordinate.id) {
      _exportCtr.fileNameCtr.text = CoordinateExchangeService.defaultFileName(
        widget.coordinate,
      );
      _resetExport();
    }
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
            'Export coordinate',
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
      final file = await CoordinateExchangeService(ref: ref).exportCoordinate(
        widget.coordinate,
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
    required this.selectedCoordinateId,
    required this.onSiteFilterChanged,
    required this.onCoordinateSelected,
    required this.onShareCoordinate,
  });

  final AsyncValue<List<CoordinateData>> coordinates;
  final AsyncValue<List<SiteData>> sites;
  final int? siteFilterId;
  final int? selectedCoordinateId;
  final ValueChanged<int?> onSiteFilterChanged;
  final ValueChanged<int> onCoordinateSelected;
  final ValueChanged<CoordinateData> onShareCoordinate;

  @override
  Widget build(BuildContext context) {
    final entries = _filteredCoordinates(coordinates.value ?? const []);
    final selected = entries
        .where((coordinate) => coordinate.id == selectedCoordinateId)
        .firstOrNull;
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
                selectedCoordinateId: selectedCoordinateId,
                onCoordinateSelected: onCoordinateSelected,
              ),
              loading: () => const CommonProgressIndicator(),
              error: (error, stackTrace) =>
                  Center(child: Text('Unable to load coordinates: $error')),
            ),
          ),
          if (selected != null) ...[
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => onShareCoordinate(selected),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share coordinate'),
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
    required this.selectedCoordinateId,
    required this.onCoordinateSelected,
  });

  final List<CoordinateData> coordinates;
  final Map<int, String> siteLabels;
  final int? selectedCoordinateId;
  final ValueChanged<int> onCoordinateSelected;

  @override
  Widget build(BuildContext context) {
    if (coordinates.isEmpty) {
      return const Center(child: Text('No coordinates added'));
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Text(
            '${coordinates.length} ${coordinates.length == 1 ? 'coordinate' : 'coordinates'}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        for (final coordinate in coordinates)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Builder(
              builder: (context) {
                final colorScheme = Theme.of(context).colorScheme;
                final selected = coordinate.id == selectedCoordinateId;
                final background = selected
                    ? Color.alphaBlend(
                        colorScheme.primaryContainer.withValues(alpha: 0.22),
                        colorScheme.surfaceContainerHighest,
                      )
                    : colorScheme.surfaceContainerHighest;
                return Material(
                  color: background,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: Ink(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selected
                            ? colorScheme.outline.withValues(alpha: 0.5)
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
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
    required this.selectedCoordinateId,
    required this.onCoordinateSelected,
  });

  final AsyncValue<List<CoordinateData>> coordinates;
  final int? siteFilterId;
  final int? selectedCoordinateId;
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
              selectedPointId: selectedCoordinateId,
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
