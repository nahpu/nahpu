import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/export/coll_event_writer.dart';
import 'package:nahpu/services/export/collecting_records.dart';
import 'package:nahpu/services/export/media_writer.dart';
import 'package:nahpu/services/export/specimen_part_records.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/export/avian_records.dart';
import 'package:nahpu/services/export/mammalian_records.dart';
import 'package:nahpu/services/export/herpetofauna_records.dart';
import 'package:nahpu/src/rust/api/export.dart';
import 'package:nahpu/services/export/dynamic_record_exporter.dart';

class SpecimenRecordWriter {
  SpecimenRecordWriter({
    required this.ref,
    required this.recordType,
    required this.isInaccurateInBrackets,
    this.isAllFields = false,
    this.concatenateMultiEntry = true,
    this.useFieldNamesOnly = false,
    this.selectedColumns,
    this.exportPreset,
  });

  final WidgetRef ref;
  final SpecimenRecordType recordType;
  final bool isInaccurateInBrackets;
  final bool isAllFields;
  final bool concatenateMultiEntry;
  final bool useFieldNamesOnly;
  final List<String>? selectedColumns;
  final ExportPresetModel? exportPreset;

  Future<void> writeRecordDelimited(File filePath, ExportFmt format) async {
    List<SpecimenData> specimenList = await _getSpecimenListByTaxonGroup();

    // If we have a custom preset, use the dynamic exporter
    if (exportPreset != null) {
      return await _writeDynamicRecordDelimited(filePath, format, specimenList);
    }

    List<String> header = [
      ...collectingRecordExportList,
      ...siteExportList,
      ...collEventExportList,
      ..._getMeasurementHeader(),
      partExportSimple,
      'media::media'
    ];

    List<Map<String, dynamic>> jsonList = [];

    for (var element in specimenList) {
      List<List<String>> contents = await _getSpecimenDetails(element);
      for (var content in contents) {
        Map<String, dynamic> row = {};
        for (int i = 0; i < header.length; i++) {
          if (selectedColumns == null || selectedColumns!.contains(header[i])) {
            String key =
                useFieldNamesOnly ? header[i].split('::').last : header[i];
            row[key] = content[i];
          }
        }
        jsonList.add(row);
      }
    }

    String jsonContent = jsonEncode(jsonList);
    List<String> filteredHeader = selectedColumns == null
        ? header
        : header.where((h) => selectedColumns!.contains(h)).toList();

    final writer = RecordWriter(
      jsonContent: jsonContent,
      outputPath: filePath.path,
      columnNames: useFieldNamesOnly
          ? filteredHeader.map((e) => e.split('::').last).toList()
          : filteredHeader,
      exportFormat: format.name,
      concatenateMultiEntries: concatenateMultiEntry,
    );
    await writer.write();
  }

  Future<void> _writeDynamicRecordDelimited(
      File filePath, ExportFmt format, List<SpecimenData> specimenList) async {
    final exporter = DynamicRecordExporter(
      ref: ref,
      concatenateMultiEntry: concatenateMultiEntry,
    );
    List<Map<String, dynamic>> jsonList = [];

    for (var specimen in specimenList) {
      final dynamicRecords = await exporter.getRecord(specimen);
      for (var dynamicRecord in dynamicRecords) {
        Map<String, dynamic> row = {};

        // Add simple fields
        for (var col in exportPreset!.fields.keys) {
          final customName = exportPreset!.fields[col] ?? col;
          row[customName] = dynamicRecord[col] ?? '';
        }

        // Add combined fields
        for (var combined in exportPreset!.combinedFields) {
          String value = '';
          for (var comp in combined.fields) {
            if (comp.startsWith('SEP:')) {
              value += comp.substring(4);
            } else {
              value += dynamicRecord[comp] ?? '';
            }
          }
          row[combined.fieldId] = value;
        }
        jsonList.add(row);
      }
    }

    String jsonContent = jsonEncode(jsonList);
    List<String> columnNames = [
      ...exportPreset!.fields.values,
      ...exportPreset!.combinedFields.map((e) => e.fieldId),
    ];

    final writer = RecordWriter(
      jsonContent: jsonContent,
      outputPath: filePath.path,
      columnNames: columnNames,
      exportFormat: format.name,
      concatenateMultiEntries: concatenateMultiEntry,
    );
    await writer.write();
  }

  Future<List<List<String>>> _getSpecimenDetails(SpecimenData data) async {
    List<String> collectingRecord = await _getCollectingRecord(data);
    List<String> parts = await _getPartListStrings(data.uuid);
    List<String> collSiteDetails = await _getCollEventSiteDetails(
      data.collEventID,
    );
    List<String> measurement = await _getMeasurement(data);
    String media = await _getSpecimenMedia(data.uuid);

    List<String> baseContent = [
      ...collectingRecord,
      ...collSiteDetails,
      ...measurement,
    ];

    if (parts.isEmpty) {
      return [[...baseContent, '', media]];
    }

    if (concatenateMultiEntry) {
      return [[...baseContent, parts.join('|'), media]];
    } else {
      return parts.map((p) => [...baseContent, p, media]).toList();
    }
  }

  Future<List<String>> _getCollectingRecord(SpecimenData data) async {
    final service = CollectingRecordWriterServices(ref: ref);
    return await service.getRecord(data);
  }

  List<String> _getMeasurementHeader() {
    switch (recordType) {
      case SpecimenRecordType.generalMammals:
        return mammalMeasurementExportList;
      case SpecimenRecordType.birds:
        return avianMeasurementExportList;
      case SpecimenRecordType.bats:
        return batMeasurementExportList;
      case SpecimenRecordType.allMammals:
        return batMeasurementExportList;
      case SpecimenRecordType.herpetofauna:
        return herpMeasurementExportList;
      case SpecimenRecordType.allTaxa:
        return <String>{
          ...mammalMeasurementExportList,
          ...avianMeasurementExportList,
          ...batMeasurementExportList,
          ...herpMeasurementExportList,
        }.toList();
    }
  }

  Future<List<SpecimenData>> _getSpecimenListByTaxonGroup() async {
    final service = SpecimenServices(ref: ref);

    if (recordType == SpecimenRecordType.allMammals) {
      return await service.getSpecimenListForAllMammals();
    } else if (recordType == SpecimenRecordType.allTaxa) {
      return await service.getSpecimenList();
    }

    String taxonGroup = matchRecordTypeToTaxonGroup(recordType);
    return await service.getSpecimenListByTaxonGroup(taxonGroup);
  }

  Future<List<String>> _getCollEventSiteDetails(int? collEventId) async {
    return await CollEventRecordWriter(ref: ref)
        .getCOllEventSiteDetails(collEventId);
  }

  Future<List<String>> _getPartListStrings(String specimenUuid) async {
    SpecimenPartWriterServices service =
        SpecimenPartWriterServices(ref: ref, isWithLabel: true);
    List<List<String>> partList =
        await service.getPartList(specimenUuid, isWithEmpty: false);
    return partList.map((e) => e.join(';')).toList();
  }

  Future<List<String>> _getMeasurement(SpecimenData data) async {
    SpecimenRecordType currentType = recordType;
    if (recordType == SpecimenRecordType.allTaxa) {
      currentType = matchTaxonGroupToRecordType(data.taxonGroup ?? '');
    }

    List<String> values;
    List<String> keys;

    switch (currentType) {
      case SpecimenRecordType.generalMammals:
      case SpecimenRecordType.allMammals:
        keys = mammalMeasurementExportList;
        values = await _getMeasurementGeneralMammals(data.uuid, false);
        break;
      case SpecimenRecordType.birds:
        keys = avianMeasurementExportList;
        values = await _getMeasurementBirds(data.uuid);
        break;
      case SpecimenRecordType.bats:
        keys = batMeasurementExportList;
        values = await _getMeasurementGeneralMammals(data.uuid, true);
        break;
      case SpecimenRecordType.herpetofauna:
        keys = herpMeasurementExportList;
        values = await _getMeasurementHerps(data.uuid);
        break;
      case SpecimenRecordType.allTaxa:
        keys = [];
        values = [];
        break;
    }

    if (recordType != SpecimenRecordType.allTaxa) {
      return values;
    }

    List<String> combinedHeader = _getMeasurementHeader();
    Map<String, String> map = {};
    for (int i = 0; i < keys.length; i++) {
      if (i < values.length) {
        map[keys[i]] = values[i];
      }
    }

    return combinedHeader.map((k) => map[k] ?? '').toList();
  }

  Future<List<String>> _getMeasurementGeneralMammals(
      String specimenUuid, bool isBatRecord) async {
    MammalianMeasurements mammals = MammalianMeasurements(
      specimenUuid: specimenUuid,
      ref: ref,
      isBatRecord: isBatRecord,
      isInaccurateInBrackets: isInaccurateInBrackets,
    );
    return await mammals.getMeasurements();
  }

  Future<List<String>> _getMeasurementBirds(String specimenUuid) async {
    AvianMeasurements birds =
        AvianMeasurements(specimenUuid: specimenUuid, ref: ref);
    return await birds.getMeasurements();
  }

  Future<List<String>> _getMeasurementHerps(String specimenUuid) async {
    HerpetofaunaMeasurements herps = HerpetofaunaMeasurements(
      specimenUuid: specimenUuid,
      ref: ref,
    );
    return await herps.getMeasurements();
  }

  Future<String> _getSpecimenMedia(String specimenUuid) async {
    String specimenMedia =
        await MediaWriterServices(ref: ref).getSpecimenMedias(specimenUuid);
    return specimenMedia;
  }
}
