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
import 'package:nahpu/services/export/bird_attributes.dart';
import 'package:nahpu/services/export/mammal_attributes.dart';
import 'package:nahpu/services/export/herp_attributes.dart';
import 'package:nahpu/services/export/dynamic_record_exporter.dart';
import 'package:nahpu/src/rust/api/export.dart';

class SpecimenRecordWriter {
  SpecimenRecordWriter({
    required this.ref,
    required this.recordType,
    this.isAllFields = false,
    this.concatenateMultiEntry = true,
    this.useFieldNamesOnly = false,
    this.selectedColumns,
  });

  final WidgetRef ref;
  final SpecimenRecordType recordType;
  final bool isAllFields;
  final bool concatenateMultiEntry;
  final bool useFieldNamesOnly;
  final List<String>? selectedColumns;

  Future<void> writeRecordDelimited(File filePath, ExportFmt format) async {
    List<SpecimenData> specimenList = await _getSpecimenListByTaxonGroup();

    List<String> header = [
      ...collectingRecordExportList,
      ...siteExportList,
      ...collEventExportList,
      ..._getAttributeHeader(),
      ...parasiteDetectionExportList,
      ...parasiteExportList,
      partExportSimple,
      'media::media',
    ];

    List<Map<String, dynamic>> jsonList = [];

    for (var element in specimenList) {
      List<List<String>> contents = await _getSpecimenDetails(element);
      for (var content in contents) {
        Map<String, dynamic> row = {};
        for (int i = 0; i < header.length; i++) {
          if (selectedColumns == null || selectedColumns!.contains(header[i])) {
            String key = useFieldNamesOnly
                ? header[i].split('::').last
                : header[i];
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

  Future<List<List<String>>> _getSpecimenDetails(SpecimenData data) async {
    List<String> collectingRecord = await _getCollectingRecord(data);
    List<String> parts = await _getPartListStrings(data.uuid);
    List<String> collSiteDetails = await _getCollEventSiteDetails(
      data.collEventID,
    );
    List<String> attributes = await _getAttributes(data);
    String media = await _getSpecimenMedia(data.uuid);
    final dynamicRecords = await DynamicRecordExporter(
      ref: ref,
      expansion: concatenateMultiEntry
          ? MultiEntryExpansion.concatenate
          : MultiEntryExpansion.parasites,
    ).getRecord(data);

    List<String> baseContent = [
      ...collectingRecord,
      ...collSiteDetails,
      ...attributes,
    ];
    final partValue = parts.join('|');
    return dynamicRecords
        .map(
          (record) => [
            ...baseContent,
            ...parasiteDetectionExportList.map((field) => record[field] ?? ''),
            ...parasiteExportList.map((field) => record[field] ?? ''),
            partValue,
            media,
          ],
        )
        .toList(growable: false);
  }

  Future<List<String>> _getCollectingRecord(SpecimenData data) async {
    final service = CollectingRecordWriterServices(ref: ref);
    return await service.getRecord(data);
  }

  List<String> _getAttributeHeader() {
    switch (recordType) {
      case SpecimenRecordType.generalMammals:
        return mammalAttributeExportList;
      case SpecimenRecordType.birds:
        return birdAttributeExportList;
      case SpecimenRecordType.bats:
        return batAttributeExportList;
      case SpecimenRecordType.allMammals:
        return batAttributeExportList;
      case SpecimenRecordType.herpetofauna:
        return herpAttributeExportList;
      case SpecimenRecordType.allTaxa:
        return <String>{
          ...mammalAttributeExportList,
          ...birdAttributeExportList,
          ...batAttributeExportList,
          ...herpAttributeExportList,
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
    return await CollEventRecordWriter(
      ref: ref,
    ).getCOllEventSiteDetails(collEventId);
  }

  Future<List<String>> _getPartListStrings(String specimenUuid) async {
    SpecimenPartWriterServices service = SpecimenPartWriterServices(
      ref: ref,
      isWithLabel: true,
    );
    List<List<String>> partList = await service.getPartList(
      specimenUuid,
      isWithEmpty: false,
    );
    return partList.map((e) => e.join(';')).toList();
  }

  Future<List<String>> _getAttributes(SpecimenData data) async {
    SpecimenRecordType currentType = recordType;
    if (recordType == SpecimenRecordType.allTaxa) {
      currentType = matchTaxonGroupToRecordType(data.taxonGroup ?? '');
    }

    List<String> values;
    List<String> keys;

    switch (currentType) {
      case SpecimenRecordType.generalMammals:
      case SpecimenRecordType.allMammals:
        keys = mammalAttributeExportList;
        values = await _getMammalAttributes(data.uuid, false);
        break;
      case SpecimenRecordType.birds:
        keys = birdAttributeExportList;
        values = await _getBirdAttributes(data.uuid);
        break;
      case SpecimenRecordType.bats:
        keys = batAttributeExportList;
        values = await _getMammalAttributes(data.uuid, true);
        break;
      case SpecimenRecordType.herpetofauna:
        keys = herpAttributeExportList;
        values = await _getHerpAttributes(data.uuid);
        break;
      case SpecimenRecordType.allTaxa:
        keys = [];
        values = [];
        break;
    }

    if (recordType != SpecimenRecordType.allTaxa) {
      return values;
    }

    List<String> combinedHeader = _getAttributeHeader();
    Map<String, String> map = {};
    for (int i = 0; i < keys.length; i++) {
      if (i < values.length) {
        map[keys[i]] = values[i];
      }
    }

    return combinedHeader.map((k) => map[k] ?? '').toList();
  }

  Future<List<String>> _getMammalAttributes(
    String specimenUuid,
    bool isBatRecord,
  ) async {
    MammalAttributes mammals = MammalAttributes(
      specimenUuid: specimenUuid,
      ref: ref,
      isBatRecord: isBatRecord,
    );
    return await mammals.getAttributes();
  }

  Future<List<String>> _getBirdAttributes(String specimenUuid) async {
    BirdAttributes birds = BirdAttributes(specimenUuid: specimenUuid, ref: ref);
    return await birds.getAttributes();
  }

  Future<List<String>> _getHerpAttributes(String specimenUuid) async {
    HerpAttributes herps = HerpAttributes(specimenUuid: specimenUuid, ref: ref);
    return await herps.getAttributes();
  }

  Future<String> _getSpecimenMedia(String specimenUuid) async {
    String specimenMedia = await MediaWriterServices(
      ref: ref,
    ).getSpecimenMedias(specimenUuid);
    return specimenMedia;
  }
}
