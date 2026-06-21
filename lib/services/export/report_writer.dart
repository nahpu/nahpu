import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/media_writer.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/src/rust/api/export.dart';


class ReportServices extends AppServices {
  const ReportServices({required super.ref});

  Future<void> writeReport(File savePath, ReportType reportType, ReportFmt reportFmt) async {
    switch (reportType) {
      case ReportType.speciesCount:
        await SpeciesListWriter(ref: ref).writeSpeciesListCompact(savePath);
        break;
      case ReportType.mediaData:
        await MediaWriterServices(ref: ref)
            .writeAllMediaDelimited(savePath, true);
        break;
      case ReportType.coordinate:
        await CoordinateWriter(ref: ref).writeCoordinate(savePath, reportFmt);
        break;
    }
  }
}

class CoordinateWriter extends AppServices {
  const CoordinateWriter({required super.ref});

  Future<void> writeCoordinate(File savePath, ReportFmt reportFmt) async {
    final coordinateList = await _getAllCoordinate();
    
    List<Map<String, dynamic>> coordinateDataList = coordinateList.map((c) => {
      'nameId': c.nameId,
      'notes': c.notes,
      'decimalLongitude': c.decimalLongitude,
      'decimalLatitude': c.decimalLatitude,
      'elevationInMeter': c.elevationInMeter,
    }).toList();

    String formatStr = 'kml';
    switch (reportFmt) {
      case ReportFmt.geojson:
        formatStr = 'geojson';
        break;
      case ReportFmt.topojson:
        formatStr = 'topojson';
        break;
      case ReportFmt.shp:
        formatStr = 'shp';
        break;
      case ReportFmt.csv:
      case ReportFmt.kml:
        formatStr = 'kml';
        break;
    }

    await exportCoordinates(
      jsonContent: jsonEncode(coordinateDataList),
      outputPath: savePath.path,
      exportFormat: formatStr,
    );
  }

  Future<List<CoordinateData>> _getAllCoordinate() async {
    final allSites = await SiteServices(ref: ref).getAllSites();
    List<CoordinateData> coordinateList = [];
    for (var site in allSites) {
      List<CoordinateData> data =
          await CoordinateServices(ref: ref).getCoordinatesBySiteID(site.id);
      coordinateList.addAll(data);
    }
    return coordinateList;
  }
}

class SpeciesListWriter extends AppServices {
  const SpeciesListWriter({required super.ref});

  Future<void> writeSpeciesListCompact(File filePath) async {
    final speciesListMap = await countSpeciesList();

    List<Map<String, dynamic>> speciesDataList = [];
    for (var element in speciesListMap.entries) {
      speciesDataList.add({
        'Species': element.key,
        'Count': element.value,
      });
    }

    await RecordWriter(
      jsonContent: jsonEncode(speciesDataList),
      outputPath: filePath.path,
      columnNames: ['Species', 'Count'],
      exportFormat: 'csv',
    ).write();
  }

  Future<Map<String, int>> countSpeciesList() async {
    final speciesList = await getSpeciesList();
    SplayTreeMap<String, int> speciesListMap = SplayTreeMap();
    for (var speciesID in speciesList) {
      if (speciesID != null) {
        String species = await getSpeciesName(speciesID);
        speciesListMap[species] = (speciesListMap[species] ?? 0) + 1;
      }
    }
    return speciesListMap;
  }

  Future<List<int?>> getSpeciesList() async {
    final speciesList = await SpecimenServices(ref: ref).getAllSpecies();
    return speciesList;
  }

  Future<String> getSpeciesName(int speciesID) async {
    TaxonomyData taxonData =
        await SpecimenServices(ref: ref).getTaxonById(speciesID);
    return '${taxonData.genus} ${taxonData.specificEpithet}';
  }
}
