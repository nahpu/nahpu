import 'dart:io';
import 'dart:convert';

import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/common.dart';
import 'package:nahpu/services/projects/personnel_services.dart';
import 'package:nahpu/services/export/site_writer.dart';
import 'package:nahpu/src/rust/api/export.dart';
import 'package:nahpu/services/common/utility_services.dart';

class CollEventRecordWriter extends AppServices {
  CollEventRecordWriter({
    required super.ref,
    this.useFieldNamesOnly = false,
    this.selectedColumns,
    this.customColumnNames,
  });

  final bool useFieldNamesOnly;
  final List<String>? selectedColumns;
  final Map<String, String>? customColumnNames;

  Future<void> writeCollEventDelimited(File filePath, ExportFmt format) async {
    List<String> header = [...siteExportList, ...collEventExportList];
    List<CollEventData> collEventList = await CollEventServices(
      ref: ref,
    ).getAllCollEvents();

    List<Map<String, dynamic>> jsonList = [];

    for (var collEvent in collEventList) {
      List<String> eventDetails = await getCOllEventSiteDetails(collEvent.id);
      Map<String, dynamic> row = {};
      for (int i = 0; i < header.length; i++) {
        if (selectedColumns == null || selectedColumns!.contains(header[i])) {
          String key = customColumnNames?.containsKey(header[i]) == true
              ? customColumnNames![header[i]]!
              : useFieldNamesOnly
              ? header[i].split('::').last
              : header[i];
          row[key] = eventDetails[i];
        }
      }
      jsonList.add(row);
    }

    String jsonContent = jsonEncode(jsonList);
    List<String> filteredHeader = selectedColumns == null
        ? header
        : header.where((h) => selectedColumns!.contains(h)).toList();

    final writer = RecordWriter(
      jsonContent: jsonContent,
      outputPath: filePath.path,
      columnNames: customColumnNames != null
          ? filteredHeader.map((e) => customColumnNames![e] ?? e).toList()
          : useFieldNamesOnly
          ? filteredHeader.map((e) => e.split('::').last).toList()
          : filteredHeader,
      exportFormat: format.name,
      concatenateMultiEntries: true,
    );
    await writer.write();
  }

  Future<List<String>> getCOllEventSiteDetails(int? collEventId) async {
    int emptySite = siteExportList.length;
    int emptyEvent = collEventExportList.length;
    int emptyAll = emptySite + emptyEvent;
    if (collEventId == null) {
      return List.filled(emptyAll, '');
    } else {
      CollEventData? collEvent = await CollEventServices(
        ref: ref,
      ).getCollEvent(collEventId);
      if (collEvent == null) {
        return List.filled(emptyAll, '');
      }

      List<String> siteDetails = await _getSite(collEvent.siteID);
      List<String> collEventDetails = await _getEventDetails(collEvent);
      return [...siteDetails, ...collEventDetails];
    }
  }

  Future<List<String>> _getEventDetails(CollEventData data) async {
    String eventID = await CollEventServices(ref: ref).getCollEventID(data);
    String methods = data.primaryCollMethod ?? '';
    String startDate = data.startDate ?? '';
    String endDate = data.endDate ?? '';
    String startTime = data.startTime ?? '';
    String endTime = data.endTime ?? '';
    String effort = await _getEffort(data.id);
    String person = await _getAllPersonnel(data.id);
    final environment = await _getEnvironment(data.id);

    return [
      eventID,
      methods,
      startDate,
      endDate,
      startTime,
      endTime,
      effort,
      person,
      ...environment,
    ];
  }

  Future<List<String>> _getEnvironment(int eventId) async {
    try {
      final data = await CollEventServices(
        ref: ref,
      ).getAllEnvironmentData(eventId);
      return [
        _number(data.lowestDayTempC),
        _number(data.highestDayTempC),
        _number(data.lowestNightTempC),
        _number(data.highestNightTempC),
        _number(data.averageHumidity),
        _number(data.dewPointTemp),
        data.sunriseTime ?? '',
        data.sunsetTime ?? '',
        data.moonPhase ?? '',
        data.cloudCover ?? '',
        _number(data.rainfallInMm),
        _number(data.ambientTemperature),
        _number(data.ambientHumidity),
        _number(data.waterTemperature),
        _number(data.pH),
        _number(data.dissolvedOxygen),
        _number(data.flowVelocity),
        data.notes ?? '',
      ];
    } catch (_) {
      return List.filled(environmentalDataExportList.length, '');
    }
  }

  String _number(double? value) => value?.truncateZero() ?? '';

  Future<List<String>> _getSite(int? siteID) async {
    List<String> siteDetails = await SiteWriterServices(
      ref: ref,
    ).getSiteDetails(siteID);
    return siteDetails;
  }

  Future<String> _getEffort(int id) async {
    List<CollEffortData> effort = await CollEventServices(
      ref: ref,
    ).getAllCollEffort(id);
    return effort.map((e) => '"${e.method}";${e.count}').join(writerSeparator);
  }

  Future<String> _getAllPersonnel(int id) async {
    List<CollPersonnelData> personnel = await CollEventServices(
      ref: ref,
    ).getAllCollPersonnel(id);

    String person = await Future.wait(
      personnel.map((e) async => await _getPersonnel(e)),
    ).then((value) => value.join(writerSeparator));

    return person;
  }

  Future<String> _getPersonnel(CollPersonnelData data) async {
    if (data.personnelId == null) {
      return '';
    } else {
      PersonnelData personnel = await PersonnelServices(
        ref: ref,
      ).getPersonnelByUuid(data.personnelId!);
      return '${personnel.name};${data.role}';
    }
  }
}
