import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/specimen_services.dart';

class CaptureRecordFields extends ConsumerStatefulWidget {
  const CaptureRecordFields({
    super.key,
    required this.specimenUuid,
    required this.useHorizontalLayout,
    required this.specimenCtr,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  CaptureRecordFieldsState createState() => CaptureRecordFieldsState();
}

class CaptureRecordFieldsState extends ConsumerState<CaptureRecordFields> {
  bool _showMore = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Capture Records',
      infoContent: const CaptureRecordInfoContent(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          EventIdField(
            specimenUuid: widget.specimenUuid,
            useHorizontalLayout: widget.useHorizontalLayout,
            specimenCtr: widget.specimenCtr,
          ),
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              CaptureDate(
                specimenUuid: widget.specimenUuid,
                specimenCtr: widget.specimenCtr,
              ),
              CaptureTime(
                specimenUuid: widget.specimenUuid,
                specimenCtr: widget.specimenCtr,
              ),
            ],
          ),
          _showMore || widget.specimenCtr.relativeTimeCtr != null
              ? RelativeTimeSwitch(
                  specimenUuid: widget.specimenUuid,
                  specimenCtr: widget.specimenCtr,
                )
              : const SizedBox.shrink(),
          _showMore || widget.specimenCtr.methodIDCtr.text.isNotEmpty
              ? AdaptiveLayout(
                  useHorizontalLayout: widget.useHorizontalLayout,
                  children: [
                    MethodField(
                      specimenUuid: widget.specimenUuid,
                      specimenCtr: widget.specimenCtr,
                    ),
                    MethodIdField(
                      specimenUuid: widget.specimenUuid,
                      specimenCtr: widget.specimenCtr,
                    ),
                  ],
                )
              : CommonPadding(
                  child: MethodField(
                    specimenUuid: widget.specimenUuid,
                    specimenCtr: widget.specimenCtr,
                  ),
                ),
          CoordinateField(
            specimenUuid: widget.specimenUuid,
            specimenCtr: widget.specimenCtr,
          ),
          Visibility(
              visible: _isCollectorFieldVisible,
              child: CollPersonnelField(
                specimenUuid: widget.specimenUuid,
                specimenCtr: widget.specimenCtr,
              )),
          Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TextButton(
                  onPressed: () {
                    setState(
                      () {
                        _showMore = !_showMore;
                      },
                    );
                  },
                  child: Text(_showMore ? 'Show less' : 'Show more'))),
        ],
      ),
    );
  }

  bool get _isCollectorFieldVisible {
    bool isCollectorFieldAlwaysShown =
        SpecimenSettingServices(ref: ref).isCollectorFieldAlwaysShown();
    return widget.specimenCtr.collPersonnelCtr != null ||
        _showMore ||
        isCollectorFieldAlwaysShown;
  }
}

class EventIdField extends ConsumerStatefulWidget {
  const EventIdField({
    super.key,
    required this.specimenUuid,
    required this.useHorizontalLayout,
    required this.specimenCtr,
  });

  final String specimenUuid;
  final bool useHorizontalLayout;
  final SpecimenFormCtrModel specimenCtr;

  @override
  EventIdFieldState createState() => EventIdFieldState();
}

class EventIdFieldState extends ConsumerState<EventIdField> {
  int? siteIDctr;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getSiteFromEventID();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      useHorizontalLayout: widget.useHorizontalLayout,
      children: [
        DropdownButtonFormField<int?>(
            isExpanded: true,
            initialValue: siteIDctr,
            decoration: const InputDecoration(
              labelText: 'Site ID',
              hintText: 'Choose a site',
            ),
            items: ref.watch(siteInEventProvider).when(
                data: (data) {
                  return data.isEmpty
                      ? const []
                      : data
                          .map((site) => DropdownMenuItem(
                                value: site.id,
                                child:
                                    CommonDropdownText(text: site.siteID ?? ''),
                              ))
                          .toList();
                },
                loading: () => const [],
                error: (error, stack) => const []),
            onChanged: (int? newValue) async {
              if (siteIDctr != null) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Change site?'),
                        content: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 350),
                            child:
                                const Text('Except for capture date and time,'
                                    ' all fields in the collecting record'
                                    ' section will be empty again.')),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () async {
                                await _updateSite(newValue);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text('OK')),
                        ],
                      );
                    });
              } else {
                await _updateSite(newValue);
              }
            }),
        DropdownButtonFormField<int?>(
            isExpanded: true,
            initialValue: widget.specimenCtr.collEventIDCtr,
            decoration: const InputDecoration(
              labelText: 'Event ID',
              hintText: 'Choose a collecting event ID',
            ),
            items: ref.watch(collEventEntryProvider).when(
                data: (data) {
                  return data.isEmpty
                      ? const []
                      : data.reversed
                          .where((collEvent) => collEvent.siteID == siteIDctr)
                          .map((event) => DropdownMenuItem(
                                value: event.id,
                                child: CollEventIDText(collEventData: event),
                              ))
                          .toList();
                },
                loading: () => const [],
                error: (error, stack) => const []),
            onChanged: (int? newValue) async {
              if (widget.specimenCtr.collEventIDCtr != null) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Change collecting event ID?'),
                        content: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 350),
                            child: const Text(
                                'Except for capture date and time,'
                                ' all fields in the collecting record section'
                                ' will be empty again.')),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () async {
                                await _updateSpecimen(newValue);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text('OK')),
                        ],
                      );
                    });
              } else {
                await _updateSpecimen(newValue);
              }
            }),
      ],
    );
  }

  Future<void> _updateSite(int? newValue) async {
    int? eventID;
    await _updateSpecimen(eventID);
    setState(() {
      ref.invalidate(collEventEntryProvider);
      siteIDctr = newValue;
    });
  }

  Future<void> _getSiteFromEventID() async {
    if (widget.specimenCtr.collEventIDCtr != null) {
      CollEventData? data = await CollEventServices(ref: ref)
          .getCollEvent(widget.specimenCtr.collEventIDCtr);
      if (data != null) {
        setState(() {
          siteIDctr = data.siteID;
        });
      }
    }
  }

  Future<void> _updateSpecimen(int? newValue) async {
    try {
      await SpecimenServices(ref: ref).updateSpecimen(
        widget.specimenUuid,
        SpecimenCompanion(
          collEventID: db.Value(newValue),
          collMethodID: const db.Value(null),
          collPersonnelID: const db.Value(null),
          coordinateID: const db.Value(null),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String errors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errors),
      ),
    );
  }
}

class MethodField extends ConsumerWidget {
  const MethodField({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButtonFormField<int?>(
        initialValue: specimenCtr.collMethodCtr,
        decoration: const InputDecoration(
          labelText: 'Method',
          hintText: 'Choose a method type',
        ),
        items: specimenCtr.collEventIDCtr != null
            ? ref
                .watch(collEffortByEventProvider(specimenCtr.collEventIDCtr!))
                .when(
                    data: (data) {
                      return data.map((effort) {
                        return DropdownMenuItem(
                          value: effort.id,
                          child: CommonDropdownText(text: effort.method ?? ''),
                        );
                      }).toList();
                    },
                    loading: () => const [],
                    error: (error, stack) => const [])
            : const [],
        onChanged: (int? newValue) {
          specimenCtr.collMethodCtr = newValue;
          SpecimenServices(ref: ref).updateSpecimen(
            specimenUuid,
            SpecimenCompanion(
              collMethodID: db.Value(specimenCtr.collMethodCtr),
            ),
          );
        });
  }
}

class CollEventIDText extends ConsumerStatefulWidget {
  const CollEventIDText({
    super.key,
    required this.collEventData,
  });

  final CollEventData collEventData;

  @override
  CollEventIDTextState createState() => CollEventIDTextState();
}

class CollEventIDTextState extends ConsumerState<CollEventIDText> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CommonDropdownText(text: snapshot.data as String);
        } else {
          return const SizedBox.shrink();
        }
      },
      future: _getCollEventID(),
    );
  }

  Future<String> _getCollEventID() async {
    return CollEventServices(ref: ref).getCollEventID(widget.collEventData);
  }
}

class RelativeTimeSwitch extends ConsumerStatefulWidget {
  const RelativeTimeSwitch({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  RelativeTimeSwitchState createState() => RelativeTimeSwitchState();
}

class RelativeTimeSwitchState extends ConsumerState<RelativeTimeSwitch> {
  @override
  Widget build(BuildContext context) {
    return CommonPadding(
      child: SwitchField(
        label: 'Relative time',
        value: _isSwitched(widget.specimenCtr.relativeTimeCtr),
        onPressed: (bool value) {
          setState(() {
            int newValue = value ? 1 : 0;
            widget.specimenCtr.relativeTimeCtr = newValue;
            SpecimenServices(ref: ref).updateSpecimen(
              widget.specimenUuid,
              SpecimenCompanion(isRelativeTime: db.Value(newValue)),
            );
          });
        },
      ),
    );
  }

  bool _isSwitched(int? value) {
    if (value == null) {
      return false;
    } else {
      return value == 0 ? false : true;
    }
  }
}

class MethodIdField extends ConsumerWidget {
  const MethodIdField({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: specimenCtr.methodIDCtr,
      decoration: const InputDecoration(
        labelText: 'Method ID',
        hintText: 'Enter ID, e.g. trap/net number, etc.',
      ),
      textInputAction: TextInputAction.next,
      onChanged: (String? value) {
        if (value != null && value.isNotEmpty) {
          SpecimenServices(ref: ref).updateSpecimenSkipInvalidation(
            specimenUuid,
            SpecimenCompanion(methodID: db.Value(value)),
          );
        }
      },
      onSubmitted: (_) {
        SpecimenServices(ref: ref).invalidateSpecimenList();
      },
    );
  }
}

class CaptureDate extends ConsumerWidget {
  const CaptureDate({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonDateField(
        labelText: 'Capture date',
        hintText: 'Enter date',
        controller: specimenCtr.captureDateCtr,
        initialDate: DateTime.now(),
        lastDate: DateTime.now(),
        onTap: () {
          SpecimenServices(ref: ref).updateSpecimen(
            specimenUuid,
            SpecimenCompanion(
              captureDate: db.Value(specimenCtr.captureDateCtr.text),
            ),
          );
        });
  }
}

class CoordinateField extends ConsumerStatefulWidget {
  const CoordinateField({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  CoordinateFieldState createState() => CoordinateFieldState();
}

class CoordinateFieldState extends ConsumerState<CoordinateField> {
  @override
  Widget build(BuildContext context) {
    return CommonPadding(
      child: DropdownButtonFormField<int?>(
        initialValue: widget.specimenCtr.coordinateCtr,
        decoration: const InputDecoration(
          labelText: 'Coordinate ID',
          hintText: 'Choose a method type',
        ),
        items: widget.specimenCtr.collEventIDCtr != null
            ? ref
                .watch(coordinateByEventProvider(
                    widget.specimenCtr.collEventIDCtr!))
                .when(
                  data: (data) {
                    return data.map((coordinate) {
                      return DropdownMenuItem(
                        value: coordinate.id,
                        child:
                            CommonDropdownText(text: coordinate.nameId ?? ''),
                      );
                    }).toList();
                  },
                  loading: () => const [],
                  error: (error, stack) => const [],
                )
            : [],
        onChanged: (int? newValue) {
          setState(() {
            widget.specimenCtr.coordinateCtr = newValue;
            SpecimenServices(ref: ref).updateSpecimen(widget.specimenUuid,
                SpecimenCompanion(coordinateID: db.Value(newValue)));
          });
        },
      ),
    );
  }
}

class CaptureTime extends ConsumerStatefulWidget {
  const CaptureTime({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  CaptureTimeState createState() => CaptureTimeState();
}

class CaptureTimeState extends ConsumerState<CaptureTime> {
  @override
  Widget build(BuildContext context) {
    return widget.specimenCtr.relativeTimeCtr == 1
        ? DropdownButtonFormField(
            decoration: const InputDecoration(
              labelText: 'Capture time',
              hintText: 'Enter time',
            ),
            items: relativeTimeList
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: CommonDropdownText(text: e),
                  ),
                )
                .toList(),
            onChanged: (String? newValue) {
              setState(() {
                widget.specimenCtr.captureTimeCtr.text = newValue ?? '';
                SpecimenServices(ref: ref).updateSpecimen(
                  widget.specimenUuid,
                  SpecimenCompanion(
                    captureTime:
                        db.Value(widget.specimenCtr.captureTimeCtr.text),
                  ),
                );
              });
            },
          )
        : CommonTimeField(
            labelText: 'Capture time',
            hintText: 'Enter time',
            controller: widget.specimenCtr.captureTimeCtr,
            initialTime: TimeOfDay.now(),
            onTap: () {
              SpecimenServices(ref: ref).updateSpecimen(
                widget.specimenUuid,
                SpecimenCompanion(
                  captureTime: db.Value(widget.specimenCtr.captureTimeCtr.text),
                ),
              );
            },
          );
  }
}

class CollPersonnelField extends ConsumerWidget {
  const CollPersonnelField({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonPadding(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: specimenCtr.collPersonnelCtr,
              decoration: const InputDecoration(
                labelText: 'Collector',
                hintText: 'Choose a person',
              ),
              items: specimenCtr.collEventIDCtr != null
                  ? ref
                      .watch(collPersonnelProvider(specimenCtr.collEventIDCtr!))
                      .when(
                        data: (data) {
                          return data.map((person) {
                            return DropdownMenuItem(
                                value: person.id,
                                child: PersonnelName(
                                  personnelUuid: person.personnelId,
                                ));
                          }).toList();
                        },
                        loading: () => const [],
                        error: (e, s) => const [],
                      )
                  : [],
              onChanged: (int? newValue) {
                specimenCtr.collPersonnelCtr = newValue;
                SpecimenServices(ref: ref).updateSpecimen(
                  specimenUuid,
                  SpecimenCompanion(
                    collPersonnelID: db.Value(newValue),
                  ),
                );
              },
            ),
          ),
          specimenCtr.collPersonnelCtr != null
              ? IconButton(
                  onPressed: () {
                    specimenCtr.collPersonnelCtr = null;
                    SpecimenServices(ref: ref).updateSpecimen(
                      specimenUuid,
                      const SpecimenCompanion(
                        collPersonnelID: db.Value(null),
                      ),
                    );
                  },
                  icon: const Icon(Icons.clear_rounded),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class PersonnelName extends ConsumerWidget {
  const PersonnelName({
    super.key,
    required this.personnelUuid,
  });

  final String? personnelUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      return ref.watch(personnelNameProvider(personnelUuid!)).when(
            data: (data) {
              return CommonDropdownText(text: data.name ?? '');
            },
            loading: () => const CommonDropdownText(text: 'Loading...'),
            error: (error, stack) => const CommonDropdownText(text: 'Error'),
          );
    } catch (e) {
      return const CommonDropdownText(text: 'Error');
    }
  }
}

class CaptureRecordInfoContent extends StatelessWidget {
  const CaptureRecordInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(content: [
      InfoContent(
        content:
            'Capture records are used to record the date, time, and location of a specimen'
            ' for each capture event. They also record the method used to capture the '
            'specimen, and the personnel who collected it.',
      ),
      InfoContent(
        content:
            'If you choose to change a collecting event ID, all fields in this section '
            'will be empty again, except for the capture date and time. ',
      )
    ]);
  }
}
