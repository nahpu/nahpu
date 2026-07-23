import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as db;
import 'package:file_selector/file_selector.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/database.dart' as nahpu_db;
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';

enum RecordExchangeType { site, event }

class RecordExchangePayload {
  const RecordExchangePayload({
    required this.type,
    required this.data,
    this.version = 1,
  });

  final RecordExchangeType type;
  final int version;
  final Map<String, dynamic> data;

  String get typeName => type == RecordExchangeType.site ? 'site' : 'event';

  String get encoded => const JsonEncoder.withIndent('  ').convert(toJson());

  String get compactEncoded => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
    'nahpu_record': typeName,
    'version': version,
    'data': data,
  };

  String get displayName {
    final record = data[typeName];
    if (record is Map && type == RecordExchangeType.site) {
      final siteId = record['siteID'];
      if (siteId is String && siteId.trim().isNotEmpty) return siteId;
    }
    if (record is Map && type == RecordExchangeType.event) {
      final suffix = record['idSuffix'];
      if (suffix is String && suffix.trim().isNotEmpty) {
        return 'Event $suffix';
      }
    }
    return type == RecordExchangeType.site ? 'Site record' : 'Event record';
  }

  int get coordinateCount => _maps(data['coordinates']).length;

  int get effortCount => _maps(data['effort']).length;

  int get assignmentCount => _maps(data['personnelAssignments']).length;

  int get personnelCount => _maps(data['personnel']).length;

  bool get hasLinkedSite =>
      type == RecordExchangeType.event && data['site'] is Map;

  static RecordExchangePayload parse(String content, {String? expectedType}) {
    final decoded = jsonDecode(content);
    if (decoded is! Map) {
      throw const FormatException('NAHPU record JSON must be an object.');
    }
    final envelope = Map<String, dynamic>.from(decoded);
    final name = envelope['nahpu_record'];
    final version = envelope['version'];
    final rawData = envelope['data'];
    if (name is! String || version is! num || rawData is! Map) {
      throw const FormatException('Invalid NAHPU record JSON envelope.');
    }
    if (version.toInt() != 1) {
      throw const FormatException('Unsupported NAHPU record JSON version.');
    }
    if (name != 'site' && name != 'event') {
      throw const FormatException('Unsupported NAHPU record type.');
    }
    if (expectedType != null && name != expectedType) {
      throw FormatException('This JSON contains a $name, not a $expectedType.');
    }
    final type = name == 'site'
        ? RecordExchangeType.site
        : RecordExchangeType.event;
    return RecordExchangePayload(
      type: type,
      version: version.toInt(),
      data: Map<String, dynamic>.from(rawData),
    )..validate();
  }

  void validate() {
    final record = data[typeName];
    if (record is! Map) {
      throw FormatException('NAHPU $typeName data is missing.');
    }
    _maps(data['personnel']);
    _maps(data['coordinates']);
    if (type == RecordExchangeType.event) {
      _maps(data['effort']);
      _maps(data['personnelAssignments']);
      final weather = data['weather'];
      if (weather != null && weather is! Map) {
        throw const FormatException('Event weather data is invalid.');
      }
      final site = data['site'];
      if (site != null && site is! Map) {
        throw const FormatException('Event linked site data is invalid.');
      }
      if (site is Map) {
        final linked = Map<String, dynamic>.from(site);
        if (linked['site'] is! Map) {
          throw const FormatException('Event linked site data is missing.');
        }
        _maps(linked['coordinates']);
      }
    }
  }

  static List<Map<String, dynamic>> _maps(dynamic value) {
    if (value == null) return const [];
    if (value is! List) {
      throw const FormatException('NAHPU associated data must be a list.');
    }
    return value.map((entry) {
      if (entry is! Map) {
        throw const FormatException('NAHPU associated data is invalid.');
      }
      return Map<String, dynamic>.from(entry);
    }).toList();
  }
}

class RecordExchangeResult {
  const RecordExchangeResult({required this.recordId, this.createdSiteId});

  final int recordId;
  final int? createdSiteId;
}

class RecordExchangeService extends AppServices {
  const RecordExchangeService({required super.ref});

  Future<RecordExchangePayload> exportSite(int siteId) async {
    final site =
        await (dbAccess.select(dbAccess.site)
              ..where((row) => row.id.equals(siteId))
              ..where((row) => row.projectUuid.equals(currentProjectUuid)))
            .getSingleOrNull();
    if (site == null) throw const FormatException('Site could not be found.');

    final coordinates = await CoordinateQuery(
      dbAccess,
    ).getCoordinatesBySiteID(site.id);
    final personnel = <Map<String, dynamic>>[];
    if (site.leadStaffId != null) {
      final leadStaff = await _getPersonnel(site.leadStaffId!);
      if (leadStaff != null) personnel.add(_portablePersonnel(leadStaff));
    }

    return RecordExchangePayload(
      type: RecordExchangeType.site,
      data: {
        'site': _portableSite(site),
        'coordinates': coordinates.map(_portableCoordinate).toList(),
        'personnel': personnel,
      },
    );
  }

  Future<RecordExchangePayload> exportEvent(int eventId) async {
    final event =
        await (dbAccess.select(dbAccess.collEvent)
              ..where((row) => row.id.equals(eventId))
              ..where((row) => row.projectUuid.equals(currentProjectUuid)))
            .getSingleOrNull();
    if (event == null) {
      throw const FormatException('Event could not be found.');
    }

    final effort = await CollEffortQuery(
      dbAccess,
    ).getCollEffortByEventId(event.id);
    final assignments = await CollPersonnelQuery(
      dbAccess,
    ).getCollPersonnelByEventId(event.id);
    final personnel = <String, Map<String, dynamic>>{};
    for (final assignment in assignments) {
      final id = assignment.personnelId;
      if (id != null) {
        final person = await _getPersonnel(id);
        if (person != null) personnel[id] = _portablePersonnel(person);
      }
    }

    Map<String, dynamic>? linkedSite;
    if (event.siteID != null) {
      final site =
          await (dbAccess.select(dbAccess.site)
                ..where((row) => row.id.equals(event.siteID!))
                ..where((row) => row.projectUuid.equals(currentProjectUuid)))
              .getSingleOrNull();
      if (site != null) {
        final coordinates = await CoordinateQuery(
          dbAccess,
        ).getCoordinatesBySiteID(site.id);
        linkedSite = {
          'site': _portableSite(site),
          'coordinates': coordinates.map(_portableCoordinate).toList(),
        };
        if (site.leadStaffId != null) {
          final leadStaff = await _getPersonnel(site.leadStaffId!);
          if (leadStaff != null) {
            personnel[leadStaff.uuid] = _portablePersonnel(leadStaff);
          }
        }
      }
    }

    WeatherData? weather;
    try {
      weather = await (dbAccess.select(
        dbAccess.weather,
      )..where((row) => row.eventID.equals(event.id))).getSingleOrNull();
    } catch (_) {
      weather = null;
    }

    return RecordExchangePayload(
      type: RecordExchangeType.event,
      data: {
        'event': _portableEvent(event),
        'effort': effort.map(_portableEffort).toList(),
        'personnelAssignments': assignments.map(_portableAssignment).toList(),
        'personnel': personnel.values.toList(),
        'weather': weather == null ? null : _portableWeather(weather),
        'site': ?linkedSite,
      },
    );
  }

  Future<File> saveJson(
    RecordExchangePayload payload, {
    required String fileStem,
    Directory? destinationDirectory,
  }) async {
    final output = await AppIOServices(
      dir: destinationDirectory,
      fileStem: _safeFileStem(fileStem),
      ext: 'json',
    ).getSavePath();
    await output.writeAsString(payload.encoded);
    return output;
  }

  Future<RecordExchangeResult> importPayload(
    RecordExchangePayload payload, {
    int? targetId,
    int? linkedSiteId,
    bool createEmbeddedSite = false,
  }) async {
    payload.validate();
    return dbAccess.transaction(() async {
      final personnelIds = await _importPersonnel(payload);
      if (payload.type == RecordExchangeType.site) {
        return _importSite(
          payload,
          targetId: targetId,
          personnelIds: personnelIds,
        );
      }
      return _importEvent(
        payload,
        targetId: targetId,
        linkedSiteId: linkedSiteId,
        createEmbeddedSite: createEmbeddedSite,
        personnelIds: personnelIds,
      );
    });
  }

  Future<List<SiteData>> getCurrentProjectSites() async {
    return SiteQuery(dbAccess).getAllSites(currentProjectUuid);
  }

  Future<List<CollEventData>> getCurrentProjectEvents() async {
    return CollEventQuery(dbAccess).getAllCollEvents(currentProjectUuid);
  }

  Future<XFile?> selectJsonFile() {
    return FilePickerServices().selectJsonFile();
  }

  Future<PersonnelData?> _getPersonnel(String uuid) {
    return (dbAccess.select(
      dbAccess.personnel,
    )..where((row) => row.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<Map<String, String>> _importPersonnel(
    RecordExchangePayload payload,
  ) async {
    final imported = <String, String>{};
    for (final json in RecordExchangePayload._maps(payload.data['personnel'])) {
      final person = PersonnelData.fromJson(json);
      final existing = await _getPersonnel(person.uuid);
      if (existing == null) {
        await dbAccess
            .into(dbAccess.personnel)
            .insert(_personnelCompanion(person));
      }
      final link =
          await (dbAccess.select(dbAccess.personnelList)
                ..where((row) => row.projectUuid.equals(currentProjectUuid))
                ..where((row) => row.personnelUuid.equals(person.uuid)))
              .getSingleOrNull();
      if (link == null) {
        await dbAccess
            .into(dbAccess.personnelList)
            .insert(
              PersonnelListCompanion(
                projectUuid: db.Value(currentProjectUuid),
                personnelUuid: db.Value(person.uuid),
              ),
            );
      }
      imported[person.uuid] = person.uuid;
    }
    return imported;
  }

  Future<RecordExchangeResult> _importSite(
    RecordExchangePayload payload, {
    required int? targetId,
    required Map<String, String> personnelIds,
  }) async {
    final siteJson = _requiredMap(payload.data['site'], 'site');
    final leadStaffId = _optionalString(siteJson['leadStaffId']);
    _validatePersonnelReference(leadStaffId, personnelIds);
    final companion = _siteCompanion(siteJson);
    if (targetId != null) {
      final target =
          await (dbAccess.select(dbAccess.site)
                ..where((row) => row.id.equals(targetId))
                ..where((row) => row.projectUuid.equals(currentProjectUuid)))
              .getSingleOrNull();
      if (target == null) {
        throw const FormatException('The selected site no longer exists.');
      }
    }
    final siteId =
        targetId ??
        await dbAccess
            .into(dbAccess.site)
            .insert(
              companion.copyWith(projectUuid: db.Value(currentProjectUuid)),
            );
    if (targetId != null) {
      await (dbAccess.update(dbAccess.site)
            ..where((row) => row.id.equals(targetId)))
          .write(companion.copyWith(projectUuid: db.Value(currentProjectUuid)));
      await (dbAccess.delete(
        dbAccess.coordinate,
      )..where((row) => row.siteID.equals(targetId))).go();
    }
    for (final coordinateJson in RecordExchangePayload._maps(
      payload.data['coordinates'],
    )) {
      await dbAccess
          .into(dbAccess.coordinate)
          .insert(_coordinateCompanion(coordinateJson, siteId));
    }
    return RecordExchangeResult(recordId: siteId);
  }

  Future<RecordExchangeResult> _importEvent(
    RecordExchangePayload payload, {
    required int? targetId,
    required int? linkedSiteId,
    required bool createEmbeddedSite,
    required Map<String, String> personnelIds,
  }) async {
    final eventJson = _requiredMap(payload.data['event'], 'event');
    final siteData = payload.data['site'];
    var resolvedSiteId = linkedSiteId;
    int? createdSiteId;
    if (siteData != null && createEmbeddedSite) {
      final linked = _requiredMap(siteData, 'linked site');
      createdSiteId = await _insertPortableSite(
        _requiredMap(linked['site'], 'linked site'),
        RecordExchangePayload._maps(linked['coordinates']),
        personnelIds,
      );
      resolvedSiteId = createdSiteId;
    }
    if (siteData != null && resolvedSiteId == null) {
      throw const FormatException('Select a site for the imported event.');
    }
    if (resolvedSiteId != null) {
      final linkedSite =
          await (dbAccess.select(dbAccess.site)
                ..where((row) => row.id.equals(resolvedSiteId!))
                ..where((row) => row.projectUuid.equals(currentProjectUuid)))
              .getSingleOrNull();
      if (linkedSite == null && !createEmbeddedSite) {
        throw const FormatException(
          'The selected event site no longer exists.',
        );
      }
    }

    final companion = _eventCompanion(eventJson, resolvedSiteId);
    if (targetId != null) {
      final target =
          await (dbAccess.select(dbAccess.collEvent)
                ..where((row) => row.id.equals(targetId))
                ..where((row) => row.projectUuid.equals(currentProjectUuid)))
              .getSingleOrNull();
      if (target == null) {
        throw const FormatException('The selected event no longer exists.');
      }
    }
    final eventId =
        targetId ??
        await dbAccess
            .into(dbAccess.collEvent)
            .insert(
              companion.copyWith(projectUuid: db.Value(currentProjectUuid)),
            );
    if (targetId != null) {
      await (dbAccess.update(dbAccess.collEvent)
            ..where((row) => row.id.equals(targetId)))
          .write(companion.copyWith(projectUuid: db.Value(currentProjectUuid)));
      await (dbAccess.delete(
        dbAccess.collEffort,
      )..where((row) => row.eventID.equals(targetId))).go();
      await (dbAccess.delete(
        dbAccess.collPersonnel,
      )..where((row) => row.eventID.equals(targetId))).go();
      await (dbAccess.delete(
        dbAccess.weather,
      )..where((row) => row.eventID.equals(targetId))).go();
    }

    for (final effortJson in RecordExchangePayload._maps(
      payload.data['effort'],
    )) {
      await dbAccess
          .into(dbAccess.collEffort)
          .insert(_effortCompanion(effortJson, eventId));
    }
    for (final assignmentJson in RecordExchangePayload._maps(
      payload.data['personnelAssignments'],
    )) {
      final personnelId = _optionalString(assignmentJson['personnelId']);
      _validatePersonnelReference(personnelId, personnelIds);
      await dbAccess
          .into(dbAccess.collPersonnel)
          .insert(_assignmentCompanion(assignmentJson, eventId));
    }
    final weather = payload.data['weather'];
    if (weather is Map) {
      await dbAccess
          .into(dbAccess.weather)
          .insert(
            _weatherCompanion(Map<String, dynamic>.from(weather), eventId),
          );
    }
    return RecordExchangeResult(
      recordId: eventId,
      createdSiteId: createdSiteId,
    );
  }

  Future<int> _insertPortableSite(
    Map<String, dynamic> siteJson,
    List<Map<String, dynamic>> coordinateJson,
    Map<String, String> personnelIds,
  ) async {
    final leadStaffId = _optionalString(siteJson['leadStaffId']);
    _validatePersonnelReference(leadStaffId, personnelIds);
    final siteId = await dbAccess
        .into(dbAccess.site)
        .insert(
          _siteCompanion(
            siteJson,
          ).copyWith(projectUuid: db.Value(currentProjectUuid)),
        );
    for (final coordinate in coordinateJson) {
      await dbAccess
          .into(dbAccess.coordinate)
          .insert(_coordinateCompanion(coordinate, siteId));
    }
    return siteId;
  }

  void _validatePersonnelReference(
    String? personnelId,
    Map<String, String> importedPersonnel,
  ) {
    if (personnelId != null && !importedPersonnel.containsKey(personnelId)) {
      throw FormatException(
        'Personnel $personnelId is missing from the import package.',
      );
    }
  }

  Map<String, dynamic> _portableSite(SiteData value) =>
      _without(value.toJson(), {'id', 'projectUuid', 'mediaID'});

  Map<String, dynamic> _portableCoordinate(CoordinateData value) =>
      _without(value.toJson(), {'id', 'siteID'});

  Map<String, dynamic> _portableEvent(CollEventData value) =>
      _without(value.toJson(), {'id', 'projectUuid', 'siteID'});

  Map<String, dynamic> _portableEffort(CollEffortData value) =>
      _without(value.toJson(), {'id', 'eventID'});

  Map<String, dynamic> _portableAssignment(CollPersonnelData value) =>
      _without(value.toJson(), {'id', 'eventID'});

  Map<String, dynamic> _portableWeather(WeatherData value) =>
      _without(value.toJson(), {'eventID'});

  Map<String, dynamic> _portablePersonnel(PersonnelData value) {
    final json = _without(value.toJson(), {'photoPath'});
    json['photoPath'] = null;
    return json;
  }

  nahpu_db.SiteCompanion _siteCompanion(Map<String, dynamic> json) =>
      nahpu_db.SiteCompanion(
        siteID: db.Value(_optionalString(json['siteID'])),
        leadStaffId: db.Value(_optionalString(json['leadStaffId'])),
        siteType: db.Value(_optionalString(json['siteType'])),
        country: db.Value(_optionalString(json['country'])),
        stateProvince: db.Value(_optionalString(json['stateProvince'])),
        county: db.Value(_optionalString(json['county'])),
        municipality: db.Value(_optionalString(json['municipality'])),
        locality: db.Value(_optionalString(json['locality'])),
        remark: db.Value(_optionalString(json['remark'])),
        habitatType: db.Value(_optionalString(json['habitatType'])),
        habitatCondition: db.Value(_optionalString(json['habitatCondition'])),
        habitatDescription: db.Value(
          _optionalString(json['habitatDescription']),
        ),
      );

  nahpu_db.CoordinateCompanion _coordinateCompanion(
    Map<String, dynamic> json,
    int siteId,
  ) => nahpu_db.CoordinateCompanion(
    nameId: db.Value(_optionalString(json['nameId'])),
    decimalLatitude: db.Value(_optionalDouble(json['decimalLatitude'])),
    decimalLongitude: db.Value(_optionalDouble(json['decimalLongitude'])),
    elevationInMeter: db.Value(_optionalDouble(json['elevationInMeter'])),
    datum: db.Value(_optionalString(json['datum'])),
    uncertaintyInMeters: db.Value(_optionalInt(json['uncertaintyInMeters'])),
    gpsUnit: db.Value(_optionalString(json['gpsUnit'])),
    notes: db.Value(_optionalString(json['notes'])),
    siteID: db.Value(siteId),
  );

  nahpu_db.CollEventCompanion _eventCompanion(
    Map<String, dynamic> json,
    int? siteId,
  ) => nahpu_db.CollEventCompanion(
    idSuffix: db.Value(_optionalString(json['idSuffix'])),
    startDate: db.Value(_optionalString(json['startDate'])),
    startTime: db.Value(_optionalString(json['startTime'])),
    endDate: db.Value(_optionalString(json['endDate'])),
    endTime: db.Value(_optionalString(json['endTime'])),
    primaryCollMethod: db.Value(_optionalString(json['primaryCollMethod'])),
    collMethodNotes: db.Value(_optionalString(json['collMethodNotes'])),
    siteID: db.Value(siteId),
  );

  nahpu_db.CollEffortCompanion _effortCompanion(
    Map<String, dynamic> json,
    int eventId,
  ) => nahpu_db.CollEffortCompanion(
    eventID: db.Value(eventId),
    method: db.Value(_optionalString(json['method'])),
    brand: db.Value(_optionalString(json['brand'])),
    count: db.Value(_optionalInt(json['count'])),
    size: db.Value(_optionalString(json['size'])),
    notes: db.Value(_optionalString(json['notes'])),
  );

  nahpu_db.CollPersonnelCompanion _assignmentCompanion(
    Map<String, dynamic> json,
    int eventId,
  ) {
    final personnelId = _optionalString(json['personnelId']);
    return nahpu_db.CollPersonnelCompanion(
      eventID: db.Value(eventId),
      personnelId: db.Value(personnelId),
      name: db.Value(_optionalString(json['name'])),
      role: db.Value(_optionalString(json['role'])),
    );
  }

  nahpu_db.WeatherCompanion _weatherCompanion(
    Map<String, dynamic> json,
    int eventId,
  ) => nahpu_db.WeatherCompanion(
    eventID: db.Value(eventId),
    lowestDayTempC: db.Value(_optionalDouble(json['lowestDayTempC'])),
    highestDayTempC: db.Value(_optionalDouble(json['highestDayTempC'])),
    lowestNightTempC: db.Value(_optionalDouble(json['lowestNightTempC'])),
    highestNightTempC: db.Value(_optionalDouble(json['highestNightTempC'])),
    averageHumidity: db.Value(_optionalDouble(json['averageHumidity'])),
    dewPointTemp: db.Value(_optionalDouble(json['dewPointTemp'])),
    sunriseTime: db.Value(_optionalString(json['sunriseTime'])),
    sunsetTime: db.Value(_optionalString(json['sunsetTime'])),
    moonPhase: db.Value(_optionalString(json['moonPhase'])),
    notes: db.Value(_optionalString(json['notes'])),
  );

  nahpu_db.PersonnelCompanion _personnelCompanion(PersonnelData value) =>
      nahpu_db.PersonnelCompanion(
        uuid: db.Value(value.uuid),
        name: db.Value(value.name),
        initial: db.Value(value.initial),
        email: db.Value(value.email),
        phone: db.Value(value.phone),
        affiliation: db.Value(value.affiliation),
        role: db.Value(value.role),
        currentFieldNumber: db.Value(value.currentFieldNumber),
        notes: db.Value(value.notes),
        photoPath: const db.Value(null),
        isRegisterField: db.Value(value.isRegisterField),
      );

  static Map<String, dynamic> _without(
    Map<String, dynamic> source,
    Set<String> omitted,
  ) {
    return Map<String, dynamic>.fromEntries(
      source.entries.where((entry) => !omitted.contains(entry.key)),
    );
  }

  static Map<String, dynamic> _requiredMap(dynamic value, String name) {
    if (value is! Map) throw FormatException('NAHPU $name data is invalid.');
    return Map<String, dynamic>.from(value);
  }

  static String? _optionalString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    throw const FormatException('NAHPU record contains an invalid text value.');
  }

  static int? _optionalInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    throw const FormatException('NAHPU record contains an invalid number.');
  }

  static double? _optionalDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    throw const FormatException('NAHPU record contains an invalid number.');
  }

  static String _safeFileStem(String value) {
    final cleaned = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? 'nahpu-record' : 'nahpu-$cleaned';
  }
}
