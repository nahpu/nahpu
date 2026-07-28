import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/personnel_services.dart';
import 'package:nahpu/services/taxonomy_services.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/export/common.dart';

/// Builds template source maps using canonical database `table::field` keys.
class DynamicRecordExporter {
  DynamicRecordExporter({
    required this.ref,
    required this.concatenateMultiEntry,
  });
  final WidgetRef ref;
  final bool concatenateMultiEntry;

  Future<List<Map<String, String>>> getRecord(SpecimenData data) async {
    final Map<String, String> baseRecord = {};

    // Pre-populate specimenPart keys to avoid unresolved placeholders
    final partColumns = [
      'id',
      'specimenUuid',
      'personnelId',
      'tissueID',
      'barcodeID',
      'type',
      'count',
      'treatment',
      'additionalTreatment',
      'dateTaken',
      'timeTaken',
      'pmi',
      'museumPermanent',
      'museumLoan',
      'remark'
    ];
    for (var col in partColumns) {
      baseRecord['specimenPart::$col'] = '';
    }

    await _getSpecimenData(data, baseRecord);
    await _getProjectData(data.projectUuid, baseRecord);
    await _getCollEventData(data.collEventID, baseRecord);
    await _getCoordinateData(data.coordinateID, baseRecord);
    await _getAttributeData(data.uuid, baseRecord);

    final List<Map<String, dynamic>> parts = await _getPartData(data.uuid);

    if (parts.isEmpty) {
      return [baseRecord];
    }

    if (concatenateMultiEntry) {
      final Set<String> allKeys = {};
      for (var part in parts) {
        allKeys.addAll(part.keys);
      }
      for (var key in allKeys) {
        String combinedValue =
            parts.map((part) => part[key]?.toString() ?? '').join(' | ');
        baseRecord['specimenPart::$key'] = combinedValue;
      }
      return [baseRecord];
    } else {
      List<Map<String, String>> records = [];
      for (var part in parts) {
        var row = Map<String, String>.from(baseRecord);
        _addData(row, 'specimenPart', part);
        records.add(row);
      }
      return records;
    }
  }

  Future<void> _getSpecimenData(
    SpecimenData data,
    Map<String, String> record,
  ) async {
    _addData(record, 'specimen', data.toJson());
    if (data.catalogerID != null) {
      final p = await PersonnelServices(
        ref: ref,
      ).getPersonnelByUuid(data.catalogerID!);
      record['specimen::catalogerID'] = p.name ?? '';
      _addData(record, 'personnel', p.toJson());
    }
    if (data.preparatorID != null) {
      final p = await PersonnelServices(
        ref: ref,
      ).getPersonnelByUuid(data.preparatorID!);
      record['specimen::preparatorID'] = p.name ?? '';
    }
    if (data.speciesID != null) {
      final tax = await TaxonomyServices(
        ref: ref,
      ).getTaxonById(data.speciesID!);
      record['specimen::speciesID'] = tax.id.toString();
      record['specimen::scientificName'] =
          '${tax.genus ?? ''} ${tax.specificEpithet ?? ''}'.trim();
      _addData(record, 'taxonomy', tax.toJson());
    }
  }

  Future<void> _getProjectData(
    String? projectUuid,
    Map<String, String> record,
  ) async {
    if (projectUuid != null) {
      final proj = await ProjectServices(
        ref: ref,
      ).getProjectByUuid(projectUuid);
      _addData(record, 'project', proj.toJson());
    }
  }

  Future<void> _getCollEventData(
    int? collEventID,
    Map<String, String> record,
  ) async {
    // Pre-populate collEffort keys to avoid unresolved placeholders
    final effortColumns = [
      'id',
      'eventID',
      'method',
      'brand',
      'count',
      'size',
      'notes'
    ];
    for (var col in effortColumns) {
      record['collEffort::$col'] = '';
    }

    if (collEventID != null) {
      final event = await CollEventServices(ref: ref).getCollEvent(collEventID);
      if (event != null) {
        _addData(record, 'collEvent', event.toJson());
        _addData(record, 'event', event.toJson());

        final formattedEventID =
            await CollEventServices(ref: ref).getCollEventID(event);
        record['collEvent::collEventID'] = formattedEventID;
        record['collEvent::collEventId'] = formattedEventID;
        record['event::collEventID'] = formattedEventID;
        record['event::collEventId'] = formattedEventID;

        final methods = await _getEventEffort(event.id);
        final personnel = await _getEventPersonnel(event.id);
        record['collEvent::methods'] = methods;
        record['event::methods'] = methods;
        record['collEvent::personnel'] = personnel;
        record['event::personnel'] = personnel;
        record['collEvent::Activity'] = event.primaryCollMethod ?? '';
        record['event::Activity'] = event.primaryCollMethod ?? '';

        final efforts =
            await CollEventServices(ref: ref).getAllCollEffort(event.id);
        if (efforts.isNotEmpty) {
          final Set<String> effortKeys = {};
          final List<Map<String, dynamic>> effortJsons =
              efforts.map((e) => e.toJson()).toList();
          for (var effortJson in effortJsons) {
            effortKeys.addAll(effortJson.keys);
          }
          for (var key in effortKeys) {
            final combined =
                effortJsons.map((e) => e[key]?.toString() ?? '').join(' | ');
            record['collEffort::$key'] = combined;
          }
        }

        if (event.siteID != null) {
          final site = await SiteServices(ref: ref).getSite(event.siteID!);
          if (site != null) {
            _addData(record, 'site', site.toJson());
          }
        }

        try {
          final weather = await CollEventServices(
            ref: ref,
          ).getAllWeatherData(collEventID);
          _addData(record, 'weather', weather.toJson());
        } catch (_) {
          // No weather data found
        }
      }
    }
  }

  Future<String> _getEventEffort(int id) async {
    List<CollEffortData> effort =
        await CollEventServices(ref: ref).getAllCollEffort(id);
    return effort.map((e) => '"${e.method}";${e.count}').join(writerSeparator);
  }

  Future<String> _getEventPersonnel(int id) async {
    List<CollPersonnelData> personnel =
        await CollEventServices(ref: ref).getAllCollPersonnel(id);

    String person = await Future.wait(personnel.map((e) async {
      if (e.personnelId == null) return '';
      final p =
          await PersonnelServices(ref: ref).getPersonnelByUuid(e.personnelId!);
      return '${p.name};${e.role}';
    })).then((value) => value.where((v) => v.isNotEmpty).join(writerSeparator));

    return person;
  }

  Future<void> _getCoordinateData(
    int? coordinateID,
    Map<String, String> record,
  ) async {
    if (coordinateID != null) {
      final coord = await CoordinateServices(
        ref: ref,
      ).getCoordinateById(coordinateID);
      if (coord != null) {
        _addData(record, 'coordinate', coord.toJson());
      }
    }
  }

  Future<void> _getAttributeData(
    String specimenUuid,
    Map<String, String> record,
  ) async {
    final db = ref.read(databaseProvider);
    final mammal = await (db.select(
      db.mammalAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid)))
        .getSingleOrNull();
    if (mammal != null) {
      _addData(record, 'mammalAttribute', mammal.toJson());
    }

    final bird = await (db.select(
      db.birdAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid)))
        .getSingleOrNull();
    if (bird != null) {
      _addData(record, 'birdAttribute', bird.toJson());
    }

    final herp = await (db.select(
      db.herpAttribute,
    )..where((t) => t.specimenUuid.equals(specimenUuid)))
        .getSingleOrNull();
    if (herp != null) {
      _addData(record, 'herpAttribute', herp.toJson());
    }
  }

  Future<List<Map<String, dynamic>>> _getPartData(String specimenUuid) async {
    final db = ref.read(databaseProvider);
    final parts = await (db.select(
      db.specimenPart,
    )..where((t) => t.specimenUuid.equals(specimenUuid)))
        .get();
    return parts.map((e) => e.toJson()).toList();
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
