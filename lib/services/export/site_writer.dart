import 'dart:io';
import 'dart:convert';

import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/common.dart';
import 'package:nahpu/services/export/media_writer.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/src/rust/api/export.dart';

class SiteWriterServices extends AppServices {
  const SiteWriterServices({
    required super.ref,
  });

  Future<void> writeSiteDelimited(File filePath, bool isCsv) async {
    List<String> header = [...siteExportList, 'media'];

    List<SiteData> siteList = await SiteServices(ref: ref).getAllSites();
    List<Map<String, dynamic>> jsonList = [];

    for (var site in siteList) {
      List<String> siteDetails = await getSiteDetails(site.id);
      String mediaDetails = await _getSiteMedia(site.id);
      List<String> content = [...siteDetails, mediaDetails];

      Map<String, dynamic> row = {};
      for (int i = 0; i < header.length; i++) {
        row[header[i]] = content[i];
      }
      jsonList.add(row);
    }

    String jsonContent = jsonEncode(jsonList);
    String format = isCsv ? 'csv' : 'tsv';

    final writer = RecordWriter(
      jsonContent: jsonContent,
      outputPath: filePath.path,
      columnNames: header,
      exportFormat: format,
    );
    await writer.write();
  }

  Future<String> _getSiteMedia(int? siteID) async {
    String mediaDetails =
        await MediaWriterServices(ref: ref).getSiteMedias(siteID);

    return mediaDetails;
  }

  Future<List<String>> getSiteDetails(int? siteID) async {
    int emptySite = siteExportList.length;
    if (siteID == null) {
      return List.filled(emptySite, '');
    } else {
      SiteData? data = await _getSiteData(siteID);
      if (data == null) {
        return List.filled(emptySite, '');
      } else {
        String verbatimLocality = _createVerbatimLocality(data);

        List<String> siteDelimited = _getSiteDelimited(data);
        String coordinates = await getCoordinates(siteID);
        List<String> siteDetails = [
          data.siteID.toString(),
          data.habitatType ?? '',
          ...siteDelimited,
          verbatimLocality,
          coordinates
        ];
        return siteDetails;
      }
    }
  }

  Future<String> getVerbatimLocality(int? siteID) async {
    if (siteID == null) {
      return '';
    } else {
      SiteData? data = await _getSiteData(siteID);
      if (data == null) {
        return '';
      } else {
        String verbatimLocality = _createVerbatimLocality(data);
        return verbatimLocality;
      }
    }
  }

  Future<SiteData?> _getSiteData(int? siteID) async {
    return await SiteServices(ref: ref).getSite(siteID);
  }

  Future<String> getCoordinates(int? siteID) async {
    if (siteID == null) {
      return '';
    }
    List<CoordinateData> coordinateList =
        await CoordinateServices(ref: ref).getCoordinatesBySiteID(siteID);
    String coordinateDetails = coordinateList
        .map((e) => _getCoordinateData(e).join())
        .join(writerSeparator);

    return coordinateDetails;
  }

  Future<List<String>> getCoordinateById(int? coordinateId) async {
    if (coordinateId == null) {
      return [''];
    }
    CoordinateData? data =
        await CoordinateServices(ref: ref).getCoordinateById(coordinateId);
    if (data == null) {
      return [''];
    } else {
      List<String> coordinates = _getCoordinateData(data);
      return coordinates;
    }
  }

  List<String> _getCoordinateData(CoordinateData data) {
    String nameId = data.nameId != null ? '${data.nameId};' : 'No name';
    String latLong =
        data.decimalLatitude != null && data.decimalLongitude != null
            ? '${data.decimalLatitude},${data.decimalLongitude};'
            : 'Unknown Lat/Long;';
    String elevation =
        data.elevationInMeter != null || data.elevationInMeter == 0
            ? '${data.elevationInMeter}m;'
            : 'Unknown elevation;';
    String uncertainty =
        data.uncertaintyInMeters != null || data.uncertaintyInMeters == 0
            ? '${data.uncertaintyInMeters}m;'
            : 'Unknown uncertainty;';
    String datum = data.datum != null ? '${data.datum};' : 'Unknown datum;';
    String gpsUnit =
        data.gpsUnit != null ? '${data.gpsUnit}' : 'Unknown GPS unit';
    String notes =
        data.notes != null || data.notes!.isNotEmpty ? '${data.notes}' : '';
    return [nameId, latLong, elevation, uncertainty, datum, gpsUnit, notes];
  }

  List<String> _getSiteDelimited(SiteData data) {
    String country = data.country != null ? '${data.country}' : '';
    String stateProvince =
        data.stateProvince != null ? '${data.stateProvince}' : '';
    String county = data.county != null ? '${data.county}' : '';
    String municipality =
        data.municipality != null ? '${data.municipality}' : '';
    String specificLocality =
        data.locality != null ? data.locality!.trim() : '';
    String siteRemark = data.remark != null ? '${data.remark}' : '';
    return [
      country,
      stateProvince,
      county,
      municipality,
      specificLocality,
      siteRemark
    ];
  }

  String _createVerbatimLocality(SiteData data) {
    String country = data.country != null ? '${data.country}: ' : '';
    String stateProvince =
        data.stateProvince != null ? '${data.stateProvince}; ' : '';
    String county = data.county != null ? '${data.county}; ' : '';
    String municipality =
        data.municipality != null ? '${data.municipality}; ' : '';
    String specificLocality =
        data.locality != null ? data.locality!.trim() : '';
    return '$country$stateProvince$county$municipality$specificLocality';
  }
}
