import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/associated_data/associated_data_services.dart';
import 'package:nahpu/services/types/associated_data.dart';
import 'package:path/path.dart';

String formatSiteName(SiteData site) {
  return [
        site.country,
        site.islandGroup,
        site.stateProvince,
        site.county,
        site.municipality,
        site.locality,
      ]
      .whereType<String>()
      .map((part) => part.trim())
      .where((part) {
        return part.isNotEmpty;
      })
      .join(', ');
}

class SiteServices extends AppServices {
  const SiteServices({required super.ref});

  Future<int> createNewSite() async {
    final siteID = await dbAccess.transaction(() async {
      final id = await SiteQuery(
        dbAccess,
      ).createSite(SiteCompanion(projectUuid: db.Value(currentProjectUuid)));
      await SiteQuery(
        dbAccess,
      ).createSiteAttribute(SiteAttributeCompanion(siteID: db.Value(id)));
      return id;
    });
    invalidateSite();
    return siteID;
  }

  /// Returns the new site's id, or null when the origin no longer exists.
  Future<int?> duplicateSite(int originID) async {
    SiteData? siteData = await getSite(originID);
    if (siteData == null) {
      return null;
    }
    final attribute = await getSiteAttribute(originID);
    final newSiteId = await dbAccess.transaction(() async {
      final id = await SiteQuery(dbAccess).createSite(
        SiteCompanion(
          projectUuid: db.Value(currentProjectUuid),
          leadStaffId: db.Value(siteData.leadStaffId),
          siteType: db.Value(siteData.siteType),
          country: db.Value(siteData.country),
          islandGroup: db.Value(siteData.islandGroup),
          stateProvince: db.Value(siteData.stateProvince),
          county: db.Value(siteData.county),
          municipality: db.Value(siteData.municipality),
          locality: db.Value(siteData.locality),
          remark: db.Value(siteData.remark),
        ),
      );
      await SiteQuery(dbAccess).createSiteAttribute(
        SiteAttributeCompanion(
          siteID: db.Value(id),
          habitatType: db.Value(attribute?.habitatType),
          habitatCondition: db.Value(attribute?.habitatCondition),
          habitatDescription: db.Value(attribute?.habitatDescription),
          canopyCover: db.Value(attribute?.canopyCover),
        ),
      );
      return id;
    });
    invalidateSite();
    return newSiteId;
  }

  Future<SiteData?> getSite(int? id) async {
    if (id == null) {
      return null;
    } else {
      return await SiteQuery(dbAccess).getSiteById(id);
    }
  }

  Future<List<SiteData>> getAllSites() async {
    return SiteQuery(dbAccess).getAllSites(currentProjectUuid);
  }

  Future<SiteAttributeData?> getSiteAttribute(int siteId) {
    return SiteQuery(dbAccess).getSiteAttribute(siteId);
  }

  Future<void> updateSite(int id, SiteCompanion entries) async {
    await SiteQuery(dbAccess).updateSiteEntry(id, entries);
  }

  Future<void> updateSiteAttribute(
    int siteId,
    SiteAttributeCompanion entries,
  ) async {
    final updated = await SiteQuery(
      dbAccess,
    ).updateSiteAttributeEntry(siteId, entries);
    if (updated == 0) {
      await SiteQuery(
        dbAccess,
      ).createSiteAttribute(entries.copyWith(siteID: db.Value(siteId)));
    }
    ref.invalidate(siteAttributeProvider(siteId));
  }

  Future<void> createSiteMediaFromList(
    int siteId,
    List<String> filePaths,
  ) async {
    for (String filePath in filePaths) {
      await createSiteMedia(siteId, filePath);
    }
  }

  Future<void> createSiteMedia(int siteId, String filePath) async {
    final metadata = await MediaMetadataServices().extract(File(filePath));

    int mediaId = await MediaDbQuery(dbAccess).createMedia(
      MediaCompanion(
        projectUuid: db.Value(currentProjectUuid),
        fileName: db.Value(basename(filePath)),
        category: db.Value(matchMediaCategory(MediaCategory.site)),
        taken: db.Value(metadata.taken),
        camera: db.Value(metadata.camera),
        lenses: db.Value(metadata.lenses),
        additionalExif: db.Value(metadata.additionalExif),
      ),
    );
    SiteMediaCompanion entries = SiteMediaCompanion(
      siteId: db.Value(siteId),
      mediaId: db.Value(mediaId),
    );
    await SiteQuery(dbAccess).createSiteMedia(entries);
    // ref.invalidate(siteMediaProvider);
  }

  Future<List<SiteMediaData>> getSiteMedia(int siteId) async {
    return SiteQuery(dbAccess).getSiteMedia(siteId);
  }

  Future<SiteMediaData> getSiteMediaByMediaId(int siteMediaId) async {
    return await SiteQuery(dbAccess).getSiteMediaById(siteMediaId);
  }

  Future<void> deleteSite(int id) async {
    try {
      await CoordinateServices(ref: ref).deleteCoordinateBySiteID(id);
      await SiteQuery(dbAccess).deleteAllSiteMedias(id);
      await AssociatedDataServices(
        ref: ref,
      ).detachAllFromTarget(AssociatedDataTarget.site(id));
      await SiteQuery(dbAccess).deleteSiteAttribute(id);
      await SiteQuery(dbAccess).deleteSite(id);
    } catch (e) {
      rethrow;
    }

    invalidateSite();
  }

  Future<void> deleteAllSites(String projectUuid) async {
    try {
      List<SiteData> sites = await SiteQuery(dbAccess).getAllSites(projectUuid);

      for (SiteData site in sites) {
        await CoordinateServices(ref: ref).deleteCoordinateBySiteID(site.id);
        await SiteQuery(dbAccess).deleteAllSiteMedias(site.id);
        await AssociatedDataServices(
          ref: ref,
        ).detachAllFromTarget(AssociatedDataTarget.site(site.id));
        await SiteQuery(dbAccess).deleteSiteAttribute(site.id);
      }
      await SiteQuery(dbAccess).deleteAllSites(projectUuid);
      invalidateSite();
    } catch (e) {
      rethrow;
    }
  }

  void invalidateSite() {
    ref.invalidate(siteEntryProvider);
  }
}

class SiteSearchServices {
  const SiteSearchServices({
    required this.siteEntries,
    this.attributesBySite = const {},
  });
  final List<SiteData> siteEntries;
  final Map<int, SiteAttributeData> attributesBySite;

  List<SiteData> search(String query) {
    final filteredSites = siteEntries.where((site) {
      final attribute = attributesBySite[site.id];
      return _isMatch(site.siteID, query) ||
          _isMatch(site.siteType, query) ||
          _isMatch(site.country, query) ||
          _isMatch(site.islandGroup, query) ||
          _isMatch(site.stateProvince, query) ||
          _isMatch(site.county, query) ||
          _isMatch(site.municipality, query) ||
          _isMatch(site.locality, query) ||
          _isMatch(site.remark, query) ||
          _isMatch(attribute?.habitatType, query) ||
          _isMatch(attribute?.habitatCondition, query) ||
          _isMatch(attribute?.habitatDescription, query) ||
          _isMatch(attribute?.canopyCover, query);
    }).toList();
    return filteredSites;
  }

  bool _isMatch(String? value, String query) {
    return value.isContain(query);
  }
}

class CoordinateServices extends AppServices {
  const CoordinateServices({required super.ref});

  Future<List<CoordinateData>> getCoordinatesBySiteID(int siteID) async {
    return CoordinateQuery(dbAccess).getCoordinatesBySiteID(siteID);
  }

  Future<CoordinateData?> getCoordinateById(int coordinateId) async {
    return CoordinateQuery(dbAccess).getCoordinateById(coordinateId);
  }

  Future<int> createCoordinate(CoordinateCompanion form) async {
    return await CoordinateQuery(dbAccess).createCoordinate(form);
  }

  Future<void> createCoordinates(List<CoordinateCompanion> forms) async {
    await dbAccess.transaction(() async {
      for (final form in forms) {
        await CoordinateQuery(dbAccess).createCoordinate(form);
      }
    });
  }

  Future<void> updateCoordinate(
    int coordinateId,
    CoordinateCompanion form,
  ) async {
    await CoordinateQuery(dbAccess).updateCoordinate(coordinateId, form);
  }

  Future<void> deleteCoordinateBySiteID(int siteID) async {
    await CoordinateQuery(dbAccess).deleteCoordinateBySiteID(siteID);
  }

  Future<void> deleteCoordinate(int coordinateId) async {
    await CoordinateQuery(dbAccess).deleteCoordinate(coordinateId);
  }

  Future<void> deleteCoordinatesFromList(List<int> coordinatesList) async {
    await CoordinateQuery(dbAccess).deleteCoordinates(coordinatesList);
  }
}

class GeoLocationServices {
  Future<Position> getCurrentCoordinates() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied,'
        ' we cannot request permissions.',
      );
    }

    if (!await Geolocator.isLocationServiceEnabled() ||
        permission == LocationPermission.denied) {
      LocationPermission permission = await Geolocator.requestPermission();
      return await _getCoordinates(permission);
    }

    return await _getCoordinates(permission);
  }

  Future<Position> _getCoordinates(LocationPermission permission) async {
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        timeLimit: const Duration(seconds: 10),
      );
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      return position;
    }
    throw Exception('Location permissions are denied');
  }

  CoordinateCtrModel getControllerModel(Position position) {
    CoordinateCtrModel ctr = CoordinateCtrModel.empty();
    ctr.latitudeCtr.text = position.latitude.toStringAsFixed(6);
    ctr.longitudeCtr.text = position.longitude.toStringAsFixed(6);
    ctr.elevationCtr.text = position.altitude.toInt().toString();
    ctr.uncertaintyCtr.text = position.accuracy.toInt().toString();
    return ctr;
  }
}
