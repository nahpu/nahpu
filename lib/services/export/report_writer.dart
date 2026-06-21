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
import 'package:xml/xml.dart';

class ReportServices extends AppServices {
  const ReportServices({required super.ref});

  Future<void> writeReport(File savePath, ReportType reportType) async {
    switch (reportType) {
      case ReportType.speciesCount:
        await SpeciesListWriter(ref: ref).writeSpeciesListCompact(savePath);
        break;
      case ReportType.mediaData:
        await MediaWriterServices(ref: ref)
            .writeAllMediaDelimited(savePath, true);
        break;
      case ReportType.coordinate:
        await CoordinateWriter(ref: ref).writeCoordinate(savePath);
        break;
    }
  }
}

class CoordinateWriter extends AppServices {
  const CoordinateWriter({required super.ref});

  Future<void> writeCoordinate(File savePath) async {
    final coordinateList = await _getAllCoordinate();
    final kml = _buildKml(coordinateList);
    await savePath.writeAsString(kml.toXmlString(pretty: true));
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

  XmlDocument _buildKml(List<CoordinateData> coordinateList) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('kml', nest: () {
      builder.element('Document', nest: () {
        builder.element('name', nest: 'NAHPU');
        builder.element('description', nest: 'NAHPU');
        builder.element('Style', nest: () {
          builder.element('LineStyle', nest: () {
            builder.element('color', nest: 'ff0000ff');
            builder.element('width', nest: '2');
          });
          builder.element('PolyStyle', nest: () {
            builder.element('color', nest: '7f00ff00');
          });
        });
        for (var coordinate in coordinateList) {
          builder.element('Placemark', nest: () {
            builder.element('name', nest: coordinate.nameId);
            builder.element('description', nest: coordinate.notes);
            builder.element('styleUrl', nest: '#msn_ylw-pushpin');
            builder.element('Point', nest: () {
              builder.element('coordinates',
                  nest: '${coordinate.decimalLongitude ?? ''}'
                      ',${coordinate.decimalLatitude ?? ''}'
                      '${coordinate.elevationInMeter ?? ''}');
            });
          });
        }
      });
    });

    return builder.buildDocument();
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
