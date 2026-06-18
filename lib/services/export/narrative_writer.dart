import 'dart:io';
import 'dart:convert';

import 'package:nahpu/services/export/media_writer.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/narrative_services.dart';
import 'package:nahpu/services/export/site_writer.dart';
import 'package:nahpu/src/rust/api/export.dart';

class NarrativeRecordWriter extends AppServices {
  NarrativeRecordWriter({required super.ref});

  Future<void> writeNarrativeDelimited(File filePath, bool isCsv) async {
    List<NarrativeData> narrativeList =
        await NarrativeServices(ref: ref).getAllNarrative();

    List<Map<String, dynamic>> jsonList = [];

    for (var narrative in narrativeList) {
      List<String> rowDetails = await getNarrative(narrative);
      Map<String, dynamic> row = {};
      for (int i = 0; i < narrativeExportList.length; i++) {
        row[narrativeExportList[i]] = rowDetails[i];
      }
      jsonList.add(row);
    }

    String jsonContent = jsonEncode(jsonList);
    String format = isCsv ? 'csv' : 'tsv';

    final writer = RecordWriter(
      jsonContent: jsonContent,
      outputPath: filePath.path,
      columnNames: narrativeExportList,
      exportFormat: format,
    );
    await writer.write();
  }

  Future<List<String>> getNarrative(NarrativeData narrative) async {
    String verbatimLocality = await SiteWriterServices(ref: ref)
        .getVerbatimLocality(narrative.siteID);
    String mediaDetails = await getNarrativeMedia(narrative.id);
    String narrativeDate = narrative.date ?? '';
    String fieldNote = narrative.narrative ?? '';
    List<String> narrativeList = [
      narrativeDate,
      verbatimLocality,
      fieldNote,
      mediaDetails
    ];
    return narrativeList;
  }

  Future<String> getNarrativeMedia(int? narrativeID) async {
    String mediaDetails =
        await MediaWriterServices(ref: ref).getNarrativeMedias(narrativeID);

    return mediaDetails;
  }
}
