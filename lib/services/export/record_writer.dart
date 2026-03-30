import 'dart:io';
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
import 'package:nahpu/services/export/common.dart';
import 'package:nahpu/services/export/mammalian_records.dart';
import 'package:nahpu/services/export/herpetofauna_records.dart';

class SpecimenRecordWriter {
  SpecimenRecordWriter({
    required this.ref,
    required this.recordType,
    required this.isInaccurateInBrackets,
  });

  final WidgetRef ref;
  final SpecimenRecordType recordType;
  final bool isInaccurateInBrackets;

  Future<void> writeRecordDelimited(File filePath, bool isCsv) async {
    String delimiter = isCsv ? csvDelimiter : tsvDelimiter;

    List<SpecimenData> specimenList = await _getSpecimenListByTaxonGroup();
    final file = await filePath.create(recursive: true);
    final writer = file.openWrite();
    List<String> header = [
      ...collectingRecordExportList,
      ...siteExportList,
      ...collEventExportList,
      ..._getMeasurementHeader(),
      partExportSimple,
      'media'
    ];
    writer.writeln(header.toDelimitedText(delimiter));

    for (var element in specimenList) {
      List<String> content = await _getSpecimenDetails(element);
      writer.writeln(content.toDelimitedText(delimiter));
    }

    writer.close();
  }

  Future<List<String>> _getSpecimenDetails(SpecimenData data) async {
    List<String> collectingRecord = await _getCollectingRecord(data);
    String parts = await _getPartList(data.uuid);
    List<String> collSiteDetails = await _getCollEventSiteDetails(
      data.collEventID,
    );
    List<String> measurement = await _getMeasurement(data.uuid);
    String media = await _getSpecimenMedia(data.uuid);

    List<String> content = [
      ...collectingRecord,
      ...collSiteDetails,
      ...measurement,
      parts,
      media
    ];

    return content;
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
    }
  }

  Future<List<SpecimenData>> _getSpecimenListByTaxonGroup() async {
    final service = SpecimenServices(ref: ref);

    if (recordType == SpecimenRecordType.allMammals) {
      return await service.getSpecimenListForAllMammals();
    }

    String taxonGroup = matchRecordTypeToTaxonGroup(recordType);
    return await service.getSpecimenListByTaxonGroup(taxonGroup);
  }

  Future<List<String>> _getCollEventSiteDetails(int? collEventId) async {
    return await CollEventRecordWriter(ref: ref)
        .getCOllEventSiteDetails(collEventId);
  }

  Future<String> _getPartList(String specimenUuid) async {
    SpecimenPartWriterServices service =
        SpecimenPartWriterServices(ref: ref, isWithLabel: true);
    return await service.getPartListStr(specimenUuid);
  }

  Future<List<String>> _getMeasurement(String specimenUuid) async {
    bool isBat = recordType == SpecimenRecordType.bats ||
        recordType == SpecimenRecordType.allMammals;
    switch (recordType) {
      case SpecimenRecordType.generalMammals:
        return await _getMeasurementGeneralMammals(specimenUuid, isBat);
      case SpecimenRecordType.birds:
        return await _getMeasurementBirds(specimenUuid);
      case SpecimenRecordType.bats:
        return await _getMeasurementGeneralMammals(specimenUuid, isBat);
      case SpecimenRecordType.allMammals:
        return await _getMeasurementGeneralMammals(specimenUuid, isBat);
      case SpecimenRecordType.herpetofauna:
        return await _getMeasurementHerps(specimenUuid);
    }
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
