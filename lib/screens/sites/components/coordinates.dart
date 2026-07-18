import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/types/sites.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:nahpu/src/rust/api/gis.dart';
import 'package:url_launcher/url_launcher.dart';

enum CoordinatePopUpMenuItems { edit, copy, open }

class CoordinateFields extends StatelessWidget {
  const CoordinateFields({super.key, required this.siteId});

  final int siteId;

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Coordinates',
      infoContent: const CoordinateInfoContent(),
      mainAxisAlignment: MainAxisAlignment.start,
      child: SizedBox(
          height: 484,
          child: CoordinateList(
            sideId: siteId,
          )),
    );
  }
}

class AddCoordinateButton extends ConsumerWidget {
  const AddCoordinateButton({super.key, required this.siteId});

  final int siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PrimaryButton(
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
    );
  }
}

class CoordinateList extends ConsumerStatefulWidget {
  const CoordinateList({
    super.key,
    required this.sideId,
  });

  final int sideId;

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
                        _selectedCoordinates.addAll(data
                            .where((e) => e.id != null)
                            .map((e) => e.id!)
                            .toList());
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
                              leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    !_isSelecting
                                        ? CoordinateTileIcon(
                                            name:
                                                data[index].nameId ?? 'unknown')
                                        : ListCheckBox(
                                            isDisabled: false,
                                            value: _selectedCoordinates
                                                .contains(data[index].id),
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (data[index].id != null) {
                                                  if (value == true) {
                                                    _selectedCoordinates
                                                        .add(data[index].id!);
                                                  } else {
                                                    _selectedCoordinates
                                                        .remove(data[index].id);
                                                  }
                                                }
                                              });
                                            },
                                          ),
                                  ]),
                              title: CoordinateTitle(
                                  coordinateId: data[index].nameId),
                              subtitle:
                                  CoordinateSubtitle(coordinate: data[index]),
                              trailing: !_isSelecting
                                  ? CoordinateMenu(
                                      coordinateId: data[index].id!,
                                      siteId: data[index].siteID!,
                                      coordinate: data[index],
                                    )
                                  : const SizedBox.shrink(),
                            );
                          },
                        )),
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
                          }),
                ],
              );
      },
      loading: () => const CommonProgressIndicator(),
      error: (error, stack) => Text(error.toString()),
    );
  }

  Future<void> _deleteCoodinates() async {
    try {
      CoordinateServices(ref: ref)
          .deleteCoordinatesFromList(_selectedCoordinates);
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 10),
    ));
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
  const CoordinateTitle({
    super.key,
    required this.coordinateId,
  });

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
  const CoordinateSubtitle({
    super.key,
    required this.coordinate,
  });

  final CoordinateData coordinate;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          const WidgetSpan(
              child: TileIcon(icon: Icons.pin_drop_outlined),
              alignment: PlaceholderAlignment.middle),
          TextSpan(
              style: Theme.of(context).textTheme.labelLarge,
              text:
                  '${coordinate.decimalLatitude}, ${coordinate.decimalLongitude}'),
          const TextSpan(text: '  '),
          const WidgetSpan(
              child: TileIcon(icon: Icons.landscape_outlined),
              alignment: PlaceholderAlignment.middle),
          TextSpan(
            style: Theme.of(context).textTheme.labelLarge,
            text: _getCoordinateElevation(),
          ),
          const TextSpan(text: '  '),
          const WidgetSpan(
              child: TileIcon(icon: Icons.circle_outlined),
              alignment: PlaceholderAlignment.middle),
          TextSpan(
            style: Theme.of(context).textTheme.labelLarge,
            text: _getCoordinateUncertainty(),
          ),
          const TextSpan(text: '  '),
          const WidgetSpan(
              child: TileIcon(icon: Icons.map_outlined),
              alignment: PlaceholderAlignment.middle),
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
            title: Text('Open'),
          ),
        ),
      ],
    );
  }

  Future<void> _onSelected(CoordinatePopUpMenuItems item) async {
    switch (item) {
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
    final queryParameters = {
      'api': '1',
      'query': _latLong,
    };
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

class NewCoordinate extends ConsumerWidget {
  const NewCoordinate({
    super.key,
    required this.siteId,
    required this.coordCtr,
  });

  final int siteId;
  final CoordinateCtrModel coordCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FalseWillPop(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Add coordinates'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: CoordinateForms(
          coordinateId: null,
          siteId: siteId,
          coordCtr: coordCtr,
        ),
      ),
    ));
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
  });

  final int? coordinateId;
  final int siteId;
  final CoordinateCtrModel coordCtr;
  final bool isEditing;

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
    widget.coordCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool useHorizontalLayout = MediaQuery.sizeOf(context).width > 600.0;
    return ScrollableConstrainedLayout(
        child: Column(
      children: [
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Use device sensor to autofill coordinates',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
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
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: CommonDropdownText(text: e),
                    ))
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
        const SizedBox(
          height: 16,
        ),
        CommonPadding(
          child: FormButton(
              isEditing: widget.isEditing,
              onSubmitted: () {
                widget.isEditing ? _updateCoordinate() : _createCoordinate();
                ref.invalidate(coordinateBySiteProvider);
                Navigator.pop(context);
              }),
        ),
      ],
    ));
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
      widget.coordCtr.uncertaintyCtr.text =
          position.accuracy.toInt().toString();
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

    try {
      await CoordinateServices(ref: ref)
          .updateCoordinate(widget.coordinateId!, form);
    } catch (e) {
      // Error dialog box

      if (context.mounted) {
        _showAlertDialog();
      }
    }
  }

  void _showAlertDialog() {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('There was an error updating the coordinate'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  CoordinateCompanion _getform() {
    return CoordinateCompanion(
      nameId: db.Value(widget.coordCtr.nameIdCtr.text),
      decimalLatitude:
          db.Value(double.tryParse(widget.coordCtr.latitudeCtr.text)),
      decimalLongitude:
          db.Value(double.tryParse(widget.coordCtr.longitudeCtr.text)),
      elevationInMeter:
          db.Value(double.tryParse(widget.coordCtr.elevationCtr.text)),
      datum: db.Value(widget.coordCtr.datumCtr.text),
      uncertaintyInMeters:
          db.Value(int.tryParse(widget.coordCtr.uncertaintyCtr.text)),
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
          content: 'Coordinates of the site.'
              ' Use the add coordinate button to add a coordinate.'
              ' There is no limit to the number of coordinates that can be added.',
        ),
        InfoContent(
          content: 'Current version only supports decimal format.'
              ' The West and South directions are negative'
              ' and the East and North directions are positive.',
        ),
        InfoContent(
          header: 'List information',
          content: 'Top: Coordinate name\n'
              'Bottom (left to right): Latitude and Longitude,'
              ' Elevation, Uncertainty, and Datum',
        ),
        InfoContent(
          header: 'Datum',
          content: 'The datum is the reference frame for the coordinates.'
              ' The default is WGS84, which is the standard datum for GPS.',
        )
      ],
    );
  }
}
