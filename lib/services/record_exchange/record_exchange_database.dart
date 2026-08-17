import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/database.dart' as nahpu_db;
import 'package:nahpu/services/common/io_services.dart';

class RecordExchangeDatabase extends AppServices {
  const RecordExchangeDatabase({required super.ref});

  Future<PersonnelData?> getPersonnel(String uuid) {
    return (dbAccess.select(
      dbAccess.personnel,
    )..where((row) => row.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<Map<String, String>> importPersonnel(
    List<Map<String, dynamic>> entries,
  ) async {
    final imported = <String, String>{};
    for (final json in entries) {
      final person = PersonnelData.fromJson(json);
      final existing = await getPersonnel(person.uuid);
      if (existing == null) {
        await dbAccess
            .into(dbAccess.personnel)
            .insert(personnelCompanion(person));
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

  void validatePersonnelReference(
    String? personnelId,
    Map<String, String> importedPersonnel,
  ) {
    if (personnelId != null && !importedPersonnel.containsKey(personnelId)) {
      throw FormatException(
        'Personnel $personnelId is missing from the import package.',
      );
    }
  }

  Future<int> insertPortableSite(
    Map<String, dynamic> siteJson,
    Map<String, dynamic>? siteAttributeJson,
    List<Map<String, dynamic>> coordinateJson,
    Map<String, String> personnelIds,
  ) async {
    final leadStaffId = optionalString(siteJson['leadStaffId']);
    validatePersonnelReference(leadStaffId, personnelIds);
    final siteId = await dbAccess
        .into(dbAccess.site)
        .insert(
          siteCompanion(
            siteJson,
          ).copyWith(projectUuid: db.Value(currentProjectUuid)),
        );
    await dbAccess
        .into(dbAccess.siteAttribute)
        .insert(siteAttributeCompanion(siteAttributeJson ?? siteJson, siteId));
    for (final coordinate in coordinateJson) {
      await dbAccess
          .into(dbAccess.coordinate)
          .insert(coordinateCompanion(coordinate, siteId));
    }
    return siteId;
  }

  Map<String, dynamic> portableSite(SiteData value) =>
      without(value.toJson(), {'id', 'projectUuid', 'mediaID'});

  Map<String, dynamic> portableSiteAttribute(SiteAttributeData value) =>
      without(value.toJson(), {'siteID'});

  Map<String, dynamic> portableCoordinate(CoordinateData value) =>
      without(value.toJson(), {'id', 'siteID'});

  Map<String, dynamic> portableEvent(CollEventData value) =>
      without(value.toJson(), {'id', 'projectUuid', 'siteID'});

  Map<String, dynamic> portableEffort(CollEffortData value) =>
      without(value.toJson(), {'id', 'eventID'});

  Map<String, dynamic> portableAssignment(CollPersonnelData value) =>
      without(value.toJson(), {'id', 'eventID'});

  Map<String, dynamic> portableEnvironment(EnvironmentData value) =>
      without(value.toJson(), {'eventID'});

  Map<String, dynamic> portableAssociatedData(AssociatedDataData value) {
    final json = without(value.toJson(), {'primaryId', 'projectUuid'});
    json['url'] = json.remove('uri');
    return json;
  }

  Map<String, dynamic> associatedDataJson(Map<String, dynamic> source) {
    final json = Map<String, dynamic>.from(source);
    json['primaryId'] = null;
    json['projectUuid'] = currentProjectUuid;
    json['uri'] ??= json['url'];
    json.remove('url');
    json.remove('specimenUuid');
    return json;
  }

  Map<String, dynamic> portablePersonnel(PersonnelData value) {
    final json = without(value.toJson(), {'photoPath'});
    json['photoPath'] = null;
    return json;
  }

  nahpu_db.SiteCompanion siteCompanion(Map<String, dynamic> json) =>
      nahpu_db.SiteCompanion(
        siteID: db.Value(optionalString(json['siteID'])),
        leadStaffId: db.Value(optionalString(json['leadStaffId'])),
        siteType: db.Value(optionalString(json['siteType'])),
        country: db.Value(optionalString(json['country'])),
        islandGroup: db.Value(optionalString(json['islandGroup'])),
        stateProvince: db.Value(optionalString(json['stateProvince'])),
        county: db.Value(optionalString(json['county'])),
        municipality: db.Value(optionalString(json['municipality'])),
        locality: db.Value(optionalString(json['locality'])),
        remark: db.Value(optionalString(json['remark'])),
      );

  nahpu_db.SiteAttributeCompanion siteAttributeCompanion(
    Map<String, dynamic> json,
    int siteId,
  ) => nahpu_db.SiteAttributeCompanion(
    siteID: db.Value(siteId),
    habitatType: db.Value(optionalString(json['habitatType'])),
    habitatCondition: db.Value(optionalString(json['habitatCondition'])),
    habitatDescription: db.Value(optionalString(json['habitatDescription'])),
    canopyCover: db.Value(optionalString(json['canopyCover'])),
  );

  nahpu_db.CoordinateCompanion coordinateCompanion(
    Map<String, dynamic> json,
    int? siteId,
  ) => nahpu_db.CoordinateCompanion(
    nameId: db.Value(optionalString(json['nameId'])),
    decimalLatitude: db.Value(optionalDouble(json['decimalLatitude'])),
    decimalLongitude: db.Value(optionalDouble(json['decimalLongitude'])),
    verbatimLatitude: db.Value(optionalString(json['verbatimLatitude'])),
    verbatimLongitude: db.Value(optionalString(json['verbatimLongitude'])),
    verbatimCoordinates: db.Value(optionalString(json['verbatimCoordinates'])),
    verbatimCoordinateSystem: db.Value(
      optionalString(json['verbatimCoordinateSystem']),
    ),
    elevationInMeter: db.Value(optionalDouble(json['elevationInMeter'])),
    datum: db.Value(optionalString(json['datum'])),
    uncertaintyInMeters: db.Value(optionalInt(json['uncertaintyInMeters'])),
    gpsUnit: db.Value(optionalString(json['gpsUnit'])),
    notes: db.Value(optionalString(json['notes'])),
    siteID: db.Value(siteId),
  );

  nahpu_db.CollEventCompanion eventCompanion(
    Map<String, dynamic> json,
    int? siteId,
  ) => nahpu_db.CollEventCompanion(
    idSuffix: db.Value(optionalString(json['idSuffix'])),
    startDate: db.Value(optionalString(json['startDate'])),
    startTime: db.Value(optionalString(json['startTime'])),
    endDate: db.Value(optionalString(json['endDate'])),
    endTime: db.Value(optionalString(json['endTime'])),
    primaryCollMethod: db.Value(optionalString(json['primaryCollMethod'])),
    collMethodNotes: db.Value(optionalString(json['collMethodNotes'])),
    siteID: db.Value(siteId),
  );

  nahpu_db.CollEffortCompanion effortCompanion(
    Map<String, dynamic> json,
    int eventId,
  ) => nahpu_db.CollEffortCompanion(
    eventID: db.Value(eventId),
    method: db.Value(optionalString(json['method'])),
    brand: db.Value(optionalString(json['brand'])),
    count: db.Value(optionalInt(json['count'])),
    size: db.Value(optionalString(json['size'])),
    notes: db.Value(optionalString(json['notes'])),
  );

  nahpu_db.CollPersonnelCompanion assignmentCompanion(
    Map<String, dynamic> json,
    int eventId,
  ) => nahpu_db.CollPersonnelCompanion(
    eventID: db.Value(eventId),
    personnelId: db.Value(optionalString(json['personnelId'])),
    name: db.Value(optionalString(json['name'])),
    role: db.Value(optionalString(json['role'])),
  );

  nahpu_db.EnvironmentCompanion environmentCompanion(
    Map<String, dynamic> json,
    int eventId,
  ) => nahpu_db.EnvironmentCompanion(
    eventID: db.Value(eventId),
    lowestDayTempC: db.Value(optionalDouble(json['lowestDayTempC'])),
    highestDayTempC: db.Value(optionalDouble(json['highestDayTempC'])),
    lowestNightTempC: db.Value(optionalDouble(json['lowestNightTempC'])),
    highestNightTempC: db.Value(optionalDouble(json['highestNightTempC'])),
    averageHumidity: db.Value(optionalDouble(json['averageHumidity'])),
    dewPointTemp: db.Value(optionalDouble(json['dewPointTemp'])),
    sunriseTime: db.Value(optionalString(json['sunriseTime'])),
    sunsetTime: db.Value(optionalString(json['sunsetTime'])),
    moonPhase: db.Value(optionalString(json['moonPhase'])),
    cloudCover: db.Value(optionalString(json['cloudCover'])),
    rainfallInMm: db.Value(optionalDouble(json['rainfallInMm'])),
    ambientTemperature: db.Value(optionalDouble(json['ambientTemperature'])),
    ambientHumidity: db.Value(optionalDouble(json['ambientHumidity'])),
    waterTemperature: db.Value(optionalDouble(json['waterTemperature'])),
    pH: db.Value(optionalDouble(json['pH'])),
    dissolvedOxygen: db.Value(optionalDouble(json['dissolvedOxygen'])),
    flowVelocity: db.Value(optionalDouble(json['flowVelocity'])),
    notes: db.Value(optionalString(json['notes'])),
  );

  nahpu_db.PersonnelCompanion personnelCompanion(PersonnelData value) =>
      nahpu_db.PersonnelCompanion(
        uuid: db.Value(value.uuid),
        name: db.Value(value.name),
        initial: db.Value(value.initial),
        email: db.Value(value.email),
        phone: db.Value(value.phone),
        affiliation: db.Value(value.affiliation),
        orcid: db.Value(value.orcid),
        role: db.Value(value.role),
        currentFieldNumber: db.Value(value.currentFieldNumber),
        notes: db.Value(value.notes),
        photoPath: const db.Value(null),
        isRegisterField: db.Value(value.isRegisterField),
      );

  static Map<String, dynamic> without(
    Map<String, dynamic> source,
    Set<String> omitted,
  ) => Map<String, dynamic>.fromEntries(
    source.entries.where((entry) => !omitted.contains(entry.key)),
  );

  static String? optionalString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    throw const FormatException('NAHPU record contains an invalid text value.');
  }

  static int? optionalInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    throw const FormatException('NAHPU record contains an invalid number.');
  }

  static double? optionalDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    throw const FormatException('NAHPU record contains an invalid number.');
  }
}
