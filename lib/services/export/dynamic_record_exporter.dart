import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/personnel_services.dart';
import 'package:nahpu/services/taxonomy_services.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/providers/database.dart';

class DynamicRecordExporter {
  DynamicRecordExporter({required this.ref});
  final WidgetRef ref;

  Future<Map<String, String>> getRecord(SpecimenData data) async {
    final Map<String, String> record = {};

    await _getSpecimenData(data, record);
    await _getProjectData(data.projectUuid, record);
    await _getCollEventData(data.collEventID, record);
    await _getCoordinateData(data.coordinateID, record);
    await _getMeasurementData(data.uuid, record);
    await _getPartData(data.uuid, record);

    return record;
  }

  Future<void> _getSpecimenData(
    SpecimenData data,
    Map<String, String> record,
  ) async {
    _addData(record, 'specimen', data.toJson());
    if (data.catalogerID != null) {
      final p = await PersonnelServices(ref: ref)
          .getPersonnelByUuid(data.catalogerID!);
      record['specimen::catalogerID'] = p.name ?? '';
      _addData(record, 'personnel', p.toJson());
    }
    if (data.preparatorID != null) {
      final p = await PersonnelServices(ref: ref)
          .getPersonnelByUuid(data.preparatorID!);
      record['specimen::preparatorID'] = p.name ?? '';
    }
    if (data.speciesID != null) {
      final tax =
          await TaxonomyServices(ref: ref).getTaxonById(data.speciesID!);
      record['specimen::speciesID'] =
          '${tax.genus ?? ''} ${tax.specificEpithet ?? ''}'.trim();
      _addData(record, 'taxonomy', tax.toJson());
    }
  }

  Future<void> _getProjectData(
    String? projectUuid,
    Map<String, String> record,
  ) async {
    if (projectUuid != null) {
      final proj =
          await ProjectServices(ref: ref).getProjectByUuid(projectUuid);
      _addData(record, 'project', proj.toJson());
    }
  }

  Future<void> _getCollEventData(
    int? collEventID,
    Map<String, String> record,
  ) async {
    if (collEventID != null) {
      final event = await CollEventServices(ref: ref).getCollEvent(collEventID);
      if (event != null) {
        _addData(record, 'collEvent', event.toJson());

        if (event.siteID != null) {
          final site = await SiteServices(ref: ref).getSite(event.siteID!);
          if (site != null) {
            _addData(record, 'site', site.toJson());
          }
        }

        try {
          final weather =
              await CollEventServices(ref: ref).getAllWeatherData(collEventID);
          _addData(record, 'weather', weather.toJson());
        } catch (_) {
          // No weather data found
        }
      }
    }
  }

  Future<void> _getCoordinateData(
    int? coordinateID,
    Map<String, String> record,
  ) async {
    if (coordinateID != null) {
      final coord =
          await CoordinateServices(ref: ref).getCoordinateById(coordinateID);
      if (coord != null) {
        _addData(record, 'coordinate', coord.toJson());
      }
    }
  }

  Future<void> _getMeasurementData(
    String specimenUuid,
    Map<String, String> record,
  ) async {
    final db = ref.read(databaseProvider);
    final mammal = await (db.select(db.mammalMeasurement)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .getSingleOrNull();
    if (mammal != null) {
      _addData(record, 'mammalMeasurement', mammal.toJson());
    }

    final avian = await (db.select(db.avianMeasurement)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .getSingleOrNull();
    if (avian != null) {
      _addData(record, 'avianMeasurement', avian.toJson());
    }

    final herp = await (db.select(db.herpMeasurement)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .getSingleOrNull();
    if (herp != null) {
      _addData(record, 'herpMeasurement', herp.toJson());
    }
  }

  Future<void> _getPartData(
    String specimenUuid,
    Map<String, String> record,
  ) async {
    final db = ref.read(databaseProvider);
    final parts = await (db.select(db.specimenPart)
          ..where((t) => t.specimenUuid.equals(specimenUuid)))
        .get();
    if (parts.isNotEmpty) {
      _addData(record, 'specimenPart', parts.first.toJson());
    }
  }

  void _addData(
    Map<String, String> record,
    String table,
    Map<String, dynamic> json,
  ) {
    for (var entry in json.entries) {
      record['$table::${entry.key}'] = entry.value?.toString() ?? '';
    }
  }
}
