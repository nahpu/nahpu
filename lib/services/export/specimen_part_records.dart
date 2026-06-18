import 'dart:io';
import 'dart:convert';

import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/collecting_records.dart';
import 'package:nahpu/services/export/common.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/src/rust/api/export.dart';

class SpecimenPartWriter extends AppServices {
  const SpecimenPartWriter({
    required super.ref,
  });

  Future<void> writeDelimited(File filePath, ExportFmt format) async {
    List<String> header = [
      ...partExportListDelimited,
      ...collectingRecordExportList,
    ];

    List<String> specimenList = await _getSpecimenList();
    List<Map<String, dynamic>> jsonList = [];

    for (var uuid in specimenList) {
      List<List<String>> parts = await SpecimenPartWriterServices(
        ref: ref,
        isWithLabel: false,
      ).getPartList(uuid, isWithEmpty: true);
      SpecimenData specimenData =
          await SpecimenServices(ref: ref).getSpecimen(uuid);
      for (var part in parts) {
        List<String> collectingRecords = await CollectingRecordWriterServices(
          ref: ref,
        ).getRecord(specimenData);
        List<String> content = [
          ...part,
          ...collectingRecords,
        ];

        Map<String, dynamic> row = {};
        for (int i = 0; i < header.length; i++) {
          row[header[i]] = content[i];
        }
        jsonList.add(row);
      }
    }

    String jsonContent = jsonEncode(jsonList);

    final writer = RecordWriter(
      jsonContent: jsonContent,
      outputPath: filePath.path,
      columnNames: header,
      exportFormat: format.name,
    );
    await writer.write();
  }

  Future<List<String>> _getSpecimenList() async {
    return await SpecimenServices(ref: ref).getAllSpecimenUuids();
  }
}

class SpecimenPartWriterServices extends AppServices {
  const SpecimenPartWriterServices({
    required super.ref,
    required this.isWithLabel,
  });

  final bool isWithLabel;

  Future<String> getPartListStr(String specimenUuid) async {
    List<List<String>> partList =
        await getPartList(specimenUuid, isWithEmpty: false);

    String partListStr = partList.map((e) => e.join(';')).join(writerSeparator);

    return partListStr;
  }

  Future<List<List<String>>> getPartList(String specimenUuid,
      {required bool isWithEmpty}) async {
    List<SpecimenPartData> data =
        await SpecimenPartServices(ref: ref).getSpecimenParts(specimenUuid);

    List<List<String>> partList = [];
    for (SpecimenPartData part in data) {
      List<String> parts = await getPart(part, isWithEmpty);
      partList.add(parts);
    }

    return partList;
  }

  Future<List<String>> getPart(SpecimenPartData data, bool isWithEmpty) async {
    String tissueID = _getTissueID(data.tissueID);
    String barcode = _getBarcode(data.barcodeID);
    String type = _getType(data.type);
    String count = _getCount(data.count);
    String treatment = _getTreatment(data.treatment);
    String additionalTreatment =
        _getAdditionalTreatment(data.additionalTreatment);
    String dateTaken = _getDateTaken(data.dateTaken);
    String timeTaken = _getTimeTaken(data.timeTaken);
    String museumPermanent = _getMuseumPermanent(data.museumPermanent);
    String museumLoan = _getMuseumLoan(data.museumLoan);
    String remarks = _getRemarks(data.remark);
    List<String> content = [
      tissueID,
      barcode,
      type,
      count,
      treatment,
      additionalTreatment,
      dateTaken,
      timeTaken,
      museumPermanent,
      museumLoan,
      remarks
    ];

    if (isWithEmpty) {
      return content;
    }

    return content.where((element) => element.isNotEmpty).toList();
  }

  String _getTissueID(String? tissueID) {
    if (tissueID == null || tissueID.isEmpty) return '';

    if (isWithLabel) {
      return 'tissueID: $tissueID';
    }
    return tissueID;
  }

  String _getBarcode(String? barcode) {
    if (barcode == null || barcode.isEmpty) {
      return '';
    }
    if (isWithLabel) {
      return 'barcode: $barcode';
    }
    return barcode;
  }

  String _getType(String? type) {
    if (type == null || type.isEmpty) {
      return 'Unknown';
    }

    if (isWithLabel) {
      return 'partType: $type';
    }
    return type;
  }

  String _getCount(String? count) {
    if (count == null || count.isEmpty) {
      return 'Unknown';
    }

    if (isWithLabel) {
      return 'count: $count';
    }

    return count;
  }

  String _getTreatment(String? treatment) {
    if (treatment == null || treatment.isEmpty) {
      return 'Unknown';
    }

    if (isWithLabel) {
      return 'treatment: $treatment';
    }

    return treatment;
  }

  String _getAdditionalTreatment(String? additionalTreatment) {
    if (additionalTreatment == null || additionalTreatment.isEmpty) {
      return '';
    }

    if (isWithLabel) {
      return 'additionalTreatment: $additionalTreatment';
    }

    return additionalTreatment;
  }

  String _getDateTaken(String? dateTaken) {
    if (dateTaken == null || dateTaken.isEmpty) {
      return '';
    }

    if (isWithLabel) {
      return 'dateTaken: $dateTaken';
    }

    return dateTaken;
  }

  String _getTimeTaken(String? timeTaken) {
    if (timeTaken == null || timeTaken.isEmpty) {
      return '';
    }

    if (isWithLabel) {
      return 'timeTaken: $timeTaken';
    }

    return timeTaken;
  }

  String _getMuseumPermanent(String? museumPermanent) {
    if (museumPermanent == null || museumPermanent.isEmpty) {
      return '';
    }

    if (isWithLabel) {
      return 'museumPermanent: $museumPermanent';
    }

    return museumPermanent;
  }

  String _getMuseumLoan(String? museumLoan) {
    if (museumLoan == null || museumLoan.isEmpty) {
      return '';
    }

    if (isWithLabel) {
      return 'museumLoan: $museumLoan';
    }

    return museumLoan;
  }

  String _getRemarks(String? remarks) {
    if (remarks == null || remarks.isEmpty) {
      return '';
    }

    if (isWithLabel) {
      return 'remarks: $remarks';
    }

    return remarks;
  }
}
