import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/types/sites.dart';
import 'package:nahpu/services/utility_services.dart';
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
          height: 324,
          child: CoordinateList(
            sideId: siteId,
          )),
    );
  }
}

class AddCoordinateButton extends ConsumerStatefulWidget {
  const AddCoordinateButton({super.key, required this.siteId});

  final int siteId;

  @override
  AddCoordinateButtonState createState() => AddCoordinateButtonState();
}

class AddCoordinateButtonState extends ConsumerState<AddCoordinateButton> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        SecondaryButton(
          text: 'Add coordinate',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewCoordinate(
                  siteId: widget.siteId,
                  coordCtr: CoordinateCtrModel.empty(),
                ),
              ),
            );
          },
        ),
        PrimaryIconButton(
          onPressed: () async {
            Position? position = await _getLocation();
            if (position != null) {
              _addCoordinate(position);
            }
          },
          icon: Icons.my_location_outlined,
        ),
      ],
    );
  }

  Future<Position?> _getLocation() async {
    try {
      return GeoLocationServices().getCurrentCoordinates();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () async {
              await Geolocator.openLocationSettings();
              // openAppSettings();
            },
          ),
        ),
      );
    }
    return null;
  }

  Future<void> _addCoordinate(Position position) async {
    final locator = GeoLocationServices();
    final coordinateCtr = locator.getControllerModel(position);
    if (context.mounted) {
      _navigateToAddCoordinate(coordinateCtr);
    }
  }

  void _navigateToAddCoordinate(CoordinateCtrModel coordinateCtr) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewCoordinate(
          siteId: widget.siteId,
          coordCtr: coordinateCtr,
        ),
      ),
    );
  }
}

class CoordinateList extends ConsumerWidget {
  const CoordinateList({
    super.key,
    required this.sideId,
  });

  final int sideId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinates = ref.watch(coordinateBySiteProvider(sideId));
    ScrollController scrollController = ScrollController();
    return coordinates.when(
      data: (data) {
        return data.isEmpty
            ? EmptyCoordinateList(siteId: sideId)
            : Column(
                children: [
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
                              leading: CoordinateTileIcon(
                                  name: data[index].nameId ?? 'unknown'),
                              title: CoordinateTitle(
                                  coordinateId: data[index].nameId),
                              subtitle:
                                  CoordinateSubtitle(coordinate: data[index]),
                              trailing: CoordinateMenu(
                                coordinateId: data[index].id!,
                                siteId: data[index].siteID!,
                                coordCtr:
                                    CoordinateCtrModel.fromData(data[index]),
                              ),
                            );
                          },
                        )),
                  ),
                  const SizedBox(height: 8),
                  AddCoordinateButton(siteId: sideId),
                ],
              );
      },
      loading: () => const CommonProgressIndicator(),
      error: (error, stack) => Text(error.toString()),
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
    required this.coordCtr,
  });

  final int coordinateId;
  final int siteId;
  final CoordinateCtrModel coordCtr;

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
              coordCtr: widget.coordCtr,
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
    return '${widget.coordCtr.latitudeCtr.text},'
        '${widget.coordCtr.longitudeCtr.text}';
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

  @override
  void dispose() {
    widget.coordCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableConstrainedLayout(
        child: Column(
      children: [
        CommonTextField(
          controller: widget.coordCtr.nameIdCtr,
          labelText: 'Name',
          hintText: 'Add a name',
          isLastField: false,
        ),
        CommonNumField(
          controller: widget.coordCtr.latitudeCtr,
          labelText: 'Decimal Latitude',
          hintText: 'Add a latitude',
          isDouble: true,
          isSigned: true,
          isLastField: false,
        ),
        CommonNumField(
          controller: widget.coordCtr.longitudeCtr,
          labelText: 'Decimal Longitude',
          hintText: 'Add a longitude',
          isDouble: true,
          isSigned: true,
          isLastField: false,
        ),
        CommonNumField(
          controller: widget.coordCtr.elevationCtr,
          labelText: 'Elevation (m)',
          hintText: 'Add an elevation',
          isDouble: false,
          isLastField: false,
        ),
        DropdownButtonFormField(
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
        CommonNumField(
          controller: widget.coordCtr.uncertaintyCtr,
          labelText: 'Uncertainty (m)',
          hintText: 'Add an uncertainty',
          isDouble: false,
          isLastField: false,
        ),
        CommonTextField(
          controller: widget.coordCtr.gpsUnitCtr,
          labelText: 'GPS Unit',
          hintText: 'Specify the GPS unit',
          isLastField: false,
        ),
        CommonTextField(
          maxLines: 3,
          controller: widget.coordCtr.noteCtr,
          labelText: 'Notes',
          hintText: 'Add notes (optional)',
          isLastField: true,
        ),
        const SizedBox(
          height: 10,
        ),
        FormButtonWithDelete(
            isEditing: widget.isEditing,
            onDeleted: () {
              CoordinateServices(ref: ref)
                  .deleteCoordinate(widget.coordinateId!);
              ref.invalidate(coordinateBySiteProvider);
              Navigator.pop(context);
            },
            onSubmitted: () {
              widget.isEditing ? _updateCoordinate() : _createCoordinate();
              ref.invalidate(coordinateBySiteProvider);
              Navigator.pop(context);
            }),
      ],
    ));
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
