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
  NarrativeRecordWriter({
    required super.ref,
    this.useFieldNamesOnly = false,
    this.selectedColumns,
    this.customColumnNames,
  });

  final bool useFieldNamesOnly;
  final List<String>? selectedColumns;
  final Map<String, String>? customColumnNames;

  Future<void> writeNarrativeDelimited(File filePath, ExportFmt format) async {
    List<NarrativeData> narrativeList =
        await NarrativeServices(ref: ref).getAllNarrative();

    List<Map<String, dynamic>> jsonList = [];

    for (var narrative in narrativeList) {
      List<String> rowDetails = await getNarrative(narrative);
      Map<String, dynamic> row = {};
      for (int i = 0; i < narrativeExportList.length; i++) {
        if (selectedColumns == null || selectedColumns!.contains(narrativeExportList[i])) {
          String key = customColumnNames?.containsKey(narrativeExportList[i]) == true
            ? customColumnNames![narrativeExportList[i]]!
            : useFieldNamesOnly ? narrativeExportList[i].split('::').last : narrativeExportList[i];
          row[key] = rowDetails[i];
        }
      }
      jsonList.add(row);
    }

    String jsonContent = jsonEncode(jsonList);
    List<String> filteredHeader = selectedColumns == null
        ? narrativeExportList
        : narrativeExportList.where((h) => selectedColumns!.contains(h)).toList();

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
