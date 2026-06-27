import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nahpu/services/export/coll_event_writer.dart';
import 'package:nahpu/services/export/narrative_writer.dart';
import 'package:nahpu/services/export/record_writer.dart';
import 'package:nahpu/services/export/report_writer.dart';
import 'package:nahpu/services/export/site_writer.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/media_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/src/rust/api/archive.dart';
import 'package:path/path.dart' as path;

class BundleWriter extends AppServices {
  const BundleWriter({
    required super.ref,
    required this.outputFile,
    required this.isInaccurateInBrackets,
  });

  final File outputFile;
  final ExportFmt format = ExportFmt.csv;
  final bool isInaccurateInBrackets;

  /// Compressed every file in the project directory
  /// into a single archive
  Future<void> create() async {
    final projectDir = await FileServices(ref: ref).currentProjectDir;
    final appDir = await nahpuDocumentDir;
    projectDir.createSync(recursive: true);
    try {
      final recordPaths = await _getAllRecords();

      if (kDebugMode) print(recordPaths);

      await ZipWriter(
        parentDir: projectDir.path,
        altParentDir: appDir.path,
        files: recordPaths,
        outputPath: outputFile.path,
      ).write();
    } catch (e) {
      throw Exception('Error creating archive: $e');
    }
  }

  Future<List<String>> _getAllRecords() async {
    final List<String> recordPaths = [];
    recordPaths.add(await _writeReport());
    recordPaths.add(await _writeNarrativeRecord());
    recordPaths.add(await _writeSiteRecord());
    recordPaths.add(await _writeCollEventRecord());
    recordPaths.addAll(await _writeSpecimenRecords());
    recordPaths.addAll(await _getAllMediaPaths());
    return recordPaths;
  }

  Future<List<String>> _getAllMediaPaths() async {
    final mediaPaths = await MediaFinder(ref: ref).getAllMediaFileByProject();

    return mediaPaths.map((e) => e.path).toList();
  }

  Future<String> _writeReport() async {
    final filePath = await _getSpeciesReportSavePath();
    if (filePath.existsSync()) {
      await filePath.delete();
    }

    await ReportServices(ref: ref)
        .writeReport(filePath, ReportType.speciesCount, ReportFmt.csv);
    return filePath.path;
  }

  Future<String> _writeNarrativeRecord() async {
    final filePath = await _getNarrativeSavePath();
    if (filePath.existsSync()) {
      await filePath.delete();
    }
    await NarrativeRecordWriter(ref: ref).writeNarrativeDelimited(
      filePath,
      format,
    );

    return filePath.path;
  }

  Future<String> _writeSiteRecord() async {
    final filePath = await _getSiteSavePath();
    if (filePath.existsSync()) {
      await filePath.delete();
    }
    await SiteWriterServices(ref: ref).writeSiteDelimited(
      filePath,
      format,
    );

    return filePath.path;
  }

  Future<String> _writeCollEventRecord() async {
    final filePath = await _getCollEventSavePath();
    if (filePath.existsSync()) {
      await filePath.delete();
    }
    await CollEventRecordWriter(ref: ref)
        .writeCollEventDelimited(filePath, format);

    return filePath.path;
  }

  Future<List<String>> _writeSpecimenRecords() async {
    final recordType = await _getSpecimenRecordType();
    List<String> specimenFiles = [];
    if (recordType.contains(SpecimenRecordType.birds)) {
      final File birdDir = await _getBirdSpecimenSavePath();
      await SpecimenRecordWriter(
        ref: ref,
        recordType: SpecimenRecordType.birds,
        isInaccurateInBrackets: isInaccurateInBrackets,
      ).writeRecordDelimited(birdDir, format);
      specimenFiles.add(birdDir.path);
    }
    SpecimenRecordType? mammalRecord = _getMammalRecordType(recordType);
    if (mammalRecord != null) {
      final mammalFile = await _writeMammalSpecimenRecord(mammalRecord);
      specimenFiles.add(mammalFile);
    }
    if (kDebugMode) print(recordType);

    return specimenFiles;
  }

  Future<String> _writeMammalSpecimenRecord(
      SpecimenRecordType mammalRecordType) async {
    final File mammalFile = await _getMammalSpecimenSavePath();

    await SpecimenRecordWriter(
      ref: ref,
      recordType: mammalRecordType,
      isInaccurateInBrackets: isInaccurateInBrackets,
    ).writeRecordDelimited(mammalFile, format);
    return mammalFile.path;
  }

  SpecimenRecordType? _getMammalRecordType(
      List<SpecimenRecordType> recordType) {
    if (recordType.contains(SpecimenRecordType.generalMammals) &&
        recordType.contains(SpecimenRecordType.bats)) {
      return SpecimenRecordType.allMammals;
    } else if (recordType.contains(SpecimenRecordType.generalMammals)) {
      return SpecimenRecordType.generalMammals;
    } else if (recordType.contains(SpecimenRecordType.bats)) {
      return SpecimenRecordType.bats;
    } else {
      return null;
    }
  }

  Future<List<SpecimenRecordType>> _getSpecimenRecordType() async {
    List<String> taxonList =
        await SpecimenServices(ref: ref).getRecordedGroupList();
    List<SpecimenRecordType> specimenRecordTypeList = [];
    for (String taxon in taxonList) {
      final specimenRecordType = matchTaxonGroupToRecordType(taxon);
      specimenRecordTypeList.add(specimenRecordType);
    }
    return specimenRecordTypeList;
  }

  Future<File> _getMammalSpecimenSavePath() async {
    final dir = await _recordDir;
    final specimenFile =
        File(path.join(dir.path, 'mammal_specimen_records.csv'));
    return specimenFile;
  }

  Future<File> _getBirdSpecimenSavePath() async {
    final dir = await _recordDir;
    final specimenFile = File(path.join(dir.path, 'bird_specimen_records.csv'));
    return specimenFile;
  }

  Future<File> _getCollEventSavePath() async {
    final dir = await _recordDir;
    final collEventFile = File(path.join(dir.path, 'coll_event_records.csv'));
    return collEventFile;
  }

  Future<File> _getSiteSavePath() async {
    final dir = await _recordDir;
    final siteFile = File(path.join(dir.path, 'site_records.csv'));
    return siteFile;
  }

  Future<File> _getNarrativeSavePath() async {
    final dir = await _recordDir;
    final narrativeFile = File(path.join(dir.path, 'narrative_records.csv'));
    return narrativeFile;
  }

  Future<File> _getSpeciesReportSavePath() async {
    final dir = await _reportDir;
    final speciesFile = File(path.join(dir.path, 'species_records.csv'));
    return speciesFile;
  }

  Future<Directory> get _recordDir async {
    final projectDir = await FileServices(ref: ref).currentProjectDir;
    final recordDir = Directory(path.join(projectDir.path, 'records'));
    await recordDir.create(recursive: true);
    return recordDir;
  }

  Future<Directory> get _reportDir async {
    final projectDir = await FileServices(ref: ref).currentProjectDir;
    final reportDir = Directory(path.join(projectDir.path, 'reports'));
    await reportDir.create(recursive: true);
    return reportDir;
  }
}
