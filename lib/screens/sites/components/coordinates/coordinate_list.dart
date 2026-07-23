part of '../coordinates.dart';

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
