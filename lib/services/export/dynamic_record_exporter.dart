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
    final db = ref.read(databaseProvider);
    Map<String, String> record = {};

    // Helper to add data to record
    void addData(String table, Map<String, dynamic> json) {
      for (var entry in json.entries) {
        record['$table::${entry.key}'] = entry.value?.toString() ?? '';
      }
    }

    // 1. Specimen
    addData('specimen', data.toJson());
    // Resolve encoded specimen fields
    if (data.catalogerID != null) {
      final p = await PersonnelServices(ref: ref)
          .getPersonnelByUuid(data.catalogerID!);
      record['specimen::catalogerID'] = p.name ?? '';
      addData('personnel', p.toJson());
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
      addData('taxonomy', tax.toJson());
    }

    // 2. Project
    final projectUuid = data.projectUuid;
    if (projectUuid != null) {
      final proj =
          await ProjectServices(ref: ref).getProjectByUuid(projectUuid);
      addData('project', proj.toJson());
    }

    // 3. CollEvent & Site
    if (data.collEventID != null) {
      final event =
          await CollEventServices(ref: ref).getCollEvent(data.collEventID!);
      if (event != null) {
        addData('collEvent', event.toJson());

        if (event.siteID != null) {
          final site = await SiteServices(ref: ref).getSite(event.siteID!);
          if (site != null) {
            addData('site', site.toJson());
          }
        }

        // Weather
        try {
          final weather = await CollEventServices(ref: ref).getAllWeatherData(data.collEventID!);
          addData('weather', weather.toJson());
        } catch (_) {
          // No weather data found
        }
      }
    }

    // 4. Coordinates
    if (data.coordinateID != null) {
      final coord = await CoordinateServices(ref: ref).getCoordinateById(data.coordinateID!);
      if (coord != null) {
        addData('coordinate', coord.toJson());
      }
    }

    // 5. Measurements
    final mammal = await (db.select(db.mammalMeasurement)
        ..where((t) => t.specimenUuid.equals(data.uuid)))
        .getSingleOrNull();
    if (mammal != null) addData('mammalMeasurement', mammal.toJson());

    final avian = await (db.select(db.avianMeasurement)
        ..where((t) => t.specimenUuid.equals(data.uuid)))
        .getSingleOrNull();
    if (avian != null) addData('avianMeasurement', avian.toJson());

    final herp = await (db.select(db.herpMeasurement)
        ..where((t) => t.specimenUuid.equals(data.uuid)))
        .getSingleOrNull();
    if (herp != null) addData('herpMeasurement', herp.toJson());

    // 6. Parts (Concatenated)
    final parts = await (db.select(db.specimenPart)
        ..where((t) => t.specimenUuid.equals(data.uuid)))
        .get();
    if (parts.isNotEmpty) {
      // Just taking the first part's raw fields for the flat structure, or concatenate?
      // For proper dynamic export, maybe we add the first one.
      addData('specimenPart', parts.first.toJson());
    }

    return record;
  }
}
