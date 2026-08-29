import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/database/coordinate_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/personnel_queries.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/database/geography_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/types/geography.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/types/sites.dart';

class SiteCopyException implements Exception {
  const SiteCopyException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SiteCopySource {
  const SiteCopySource({
    required this.project,
    required this.site,
    required this.attribute,
    required this.coordinates,
    this.leaderName,
  });

  final ProjectSummary project;
  final SiteRecord site;
  final SiteAttributeData? attribute;
  final List<CoordinateData> coordinates;
  final String? leaderName;

  String get siteLabel {
    final value = site.siteID?.trim();
    return value == null || value.isEmpty ? 'Unnamed site #${site.id}' : value;
  }
}

class SiteCopyRequest {
  const SiteCopyRequest({
    required this.targetSiteId,
    required this.sourceProjectUuid,
    required this.sourceSiteId,
    required this.fields,
  });

  final int targetSiteId;
  final String sourceProjectUuid;
  final int sourceSiteId;
  final Set<SiteCopyField> fields;
}

class SiteCopyResult {
  const SiteCopyResult({
    required this.fieldCount,
    required this.coordinateCount,
    required this.sourceSiteLabel,
    required this.sourceProjectName,
  });

  final int fieldCount;
  final int coordinateCount;
  final String sourceSiteLabel;
  final String sourceProjectName;
}

class SiteCopyServices extends AppServices {
  const SiteCopyServices({required super.ref});

  Future<List<ProjectSummary>> getSourceProjects() async {
    final projects = (await ProjectQuery(dbAccess).getProjectList()).toList();
    final currentUuid = currentProjectUuid;
    projects.removeWhere((project) => project.uuid == currentUuid);
    projects.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return projects;
  }

  Future<List<SiteRecord>> getSourceSites(String projectUuid) async {
    final sites = await SiteQuery(dbAccess).getAllSites(projectUuid);
    sites.sort((a, b) {
      final aName = a.siteID?.trim() ?? '';
      final bName = b.siteID?.trim() ?? '';
      if (aName.isEmpty && bName.isNotEmpty) return 1;
      if (aName.isNotEmpty && bName.isEmpty) return -1;
      return aName.toLowerCase().compareTo(bName.toLowerCase());
    });
    return sites;
  }

  Future<SiteCopySource> loadSource({
    required String projectUuid,
    required int siteId,
  }) async {
    final project = (await ProjectQuery(
      dbAccess,
    ).getProjectList()).where((value) => value.uuid == projectUuid).firstOrNull;
    if (project == null) {
      throw const SiteCopyException('The source project could not be found.');
    }
    final site =
        await (dbAccess.select(dbAccess.site)
              ..where((row) => row.id.equals(siteId))
              ..where((row) => row.projectUuid.equals(projectUuid)))
            .getSingleOrNull();
    if (site == null) {
      throw const SiteCopyException('The source site could not be found.');
    }
    final coordinates = await CoordinateQuery(
      dbAccess,
    ).getCoordinatesBySiteID(siteId);
    final attribute = await SiteQuery(dbAccess).getSiteAttribute(siteId);
    String? leaderName;
    if (site.leadStaffId != null) {
      try {
        leaderName = (await PersonnelQuery(
          dbAccess,
        ).getPersonnelByUuid(site.leadStaffId!)).name;
      } catch (_) {
        leaderName = null;
      }
    }
    return SiteCopySource(
      project: project,
      site: SiteRecord(
        site: site,
        geography: await GeographyQuery(dbAccess).getById(site.geographyId),
      ),
      attribute: attribute,
      coordinates: coordinates,
      leaderName: leaderName,
    );
  }

  Future<bool> isTargetEmpty(int targetSiteId) async {
    final site = await SiteQuery(dbAccess).getSiteById(targetSiteId);
    final attribute = await SiteQuery(dbAccess).getSiteAttribute(targetSiteId);
    return _isEmpty(site, attribute);
  }

  Future<SiteCopyResult> copy(SiteCopyRequest request) async {
    if (request.fields.isEmpty) {
      throw const SiteCopyException('Select at least one field to copy.');
    }
    final result = await dbAccess.transaction(() async {
      final target = await SiteQuery(
        dbAccess,
      ).getSiteById(request.targetSiteId);
      if (target.projectUuid != currentProjectUuid) {
        throw const SiteCopyException(
          'The selected target site is not in the active project.',
        );
      }
      final targetAttribute = await SiteQuery(
        dbAccess,
      ).getSiteAttribute(target.id);
      if (!await _isEmpty(target, targetAttribute)) {
        throw const SiteCopyException(
          'The current site must be empty before copying data.',
        );
      }
      if (request.sourceProjectUuid == currentProjectUuid) {
        throw const SiteCopyException(
          'Choose a site from a different project.',
        );
      }
      final sourceSite =
          await (dbAccess.select(dbAccess.site)
                ..where((row) => row.id.equals(request.sourceSiteId))
                ..where(
                  (row) => row.projectUuid.equals(request.sourceProjectUuid),
                ))
              .getSingleOrNull();
      if (sourceSite == null) {
        throw const SiteCopyException('The source site could not be found.');
      }
      final source = SiteRecord(
        site: sourceSite,
        geography: await GeographyQuery(
          dbAccess,
        ).getById(sourceSite.geographyId),
      );
      final sourceAttribute = await SiteQuery(
        dbAccess,
      ).getSiteAttribute(source.id);
      final coordinates = await CoordinateQuery(
        dbAccess,
      ).getCoordinatesBySiteID(source.id);

      final companion = _siteCompanion(source, request.fields).copyWith(
        geographyId: await _copiedGeographyId(source, target, request.fields),
      );
      await SiteQuery(dbAccess).updateSiteEntry(target.id, companion);
      final attributeCompanion = _siteAttributeCompanion(
        sourceAttribute,
        request.fields,
      );
      final updated = await SiteQuery(
        dbAccess,
      ).updateSiteAttributeEntry(target.id, attributeCompanion);
      if (updated == 0) {
        await SiteQuery(dbAccess).createSiteAttribute(
          attributeCompanion.copyWith(siteID: db.Value(target.id)),
        );
      }

      if (request.fields.contains(SiteCopyField.leadStaff) &&
          source.leadStaffId != null) {
        final links = await PersonnelQuery(
          dbAccess,
        ).getProjectPersonnelLinks(target.projectUuid!);
        if (!links.any((link) => link.personnelUuid == source.leadStaffId)) {
          await PersonnelQuery(dbAccess).createProjectPersonnelEntry(
            PersonnelListCompanion(
              projectUuid: db.Value(target.projectUuid),
              personnelUuid: db.Value(source.leadStaffId),
            ),
          );
        }
      }

      if (request.fields.contains(SiteCopyField.coordinates)) {
        for (final coordinate in coordinates) {
          await CoordinateQuery(dbAccess).createCoordinate(
            CoordinateCompanion(
              nameId: db.Value(coordinate.nameId),
              decimalLatitude: db.Value(coordinate.decimalLatitude),
              decimalLongitude: db.Value(coordinate.decimalLongitude),
              verbatimLatitude: db.Value(coordinate.verbatimLatitude),
              verbatimLongitude: db.Value(coordinate.verbatimLongitude),
              verbatimCoordinates: db.Value(coordinate.verbatimCoordinates),
              verbatimCoordinateSystem: db.Value(
                coordinate.verbatimCoordinateSystem,
              ),
              elevationInMeter: db.Value(coordinate.elevationInMeter),
              datum: db.Value(coordinate.datum),
              uncertaintyInMeters: db.Value(coordinate.uncertaintyInMeters),
              gpsUnit: db.Value(coordinate.gpsUnit),
              notes: db.Value(coordinate.notes),
              siteID: db.Value(target.id),
            ),
          );
        }
      }

      final project = (await ProjectQuery(dbAccess).getProjectList())
          .where((value) => value.uuid == request.sourceProjectUuid)
          .firstOrNull;
      return SiteCopyResult(
        fieldCount: request.fields
            .where((field) => field != SiteCopyField.coordinates)
            .length,
        coordinateCount: request.fields.contains(SiteCopyField.coordinates)
            ? coordinates.length
            : 0,
        sourceSiteLabel: _siteLabel(source),
        sourceProjectName: project?.name ?? request.sourceProjectUuid,
      );
    });
    ref.invalidate(projectPersonnelProvider);
    return result;
  }

  Future<bool> _isEmpty(SiteRecord site, SiteAttributeData? attribute) async {
    final scalarValues = [
      site.siteID,
      site.leadStaffId,
      site.siteType,
      site.country,
      site.islandGroup,
      site.stateProvince,
      site.county,
      site.municipality,
      site.mediaID,
      site.locality,
      site.remark,
      attribute?.habitatType,
      attribute?.habitatCondition,
      attribute?.habitatDescription,
      attribute?.canopyCover,
    ];
    if (scalarValues.any((value) => value?.trim().isNotEmpty == true)) {
      return false;
    }
    return _hasNoChildren(site.id);
  }

  Future<bool> _hasNoChildren(int siteId) async {
    final coordinates = await CoordinateQuery(
      dbAccess,
    ).getCoordinatesBySiteID(siteId);
    if (coordinates.isNotEmpty) return false;
    final media = await SiteQuery(dbAccess).getSiteMedia(siteId);
    if (media.isNotEmpty) return false;
    final associated = await (dbAccess.select(
      dbAccess.siteAssociatedData,
    )..where((row) => row.siteId.equals(siteId))).get();
    if (associated.isNotEmpty) return false;
    final fossil = await (dbAccess.select(
      dbAccess.fossilSite,
    )..where((row) => row.siteID.equals(siteId))).get();
    return fossil.isEmpty;
  }

  SiteCompanion _siteCompanion(SiteRecord source, Set<SiteCopyField> fields) {
    return SiteCompanion(
      siteID: fields.contains(SiteCopyField.siteId)
          ? db.Value(source.siteID)
          : const db.Value.absent(),
      leadStaffId: fields.contains(SiteCopyField.leadStaff)
          ? db.Value(source.leadStaffId)
          : const db.Value.absent(),
      siteType: fields.contains(SiteCopyField.siteType)
          ? db.Value(source.siteType)
          : const db.Value.absent(),
      remark: fields.contains(SiteCopyField.remark)
          ? db.Value(source.remark)
          : const db.Value.absent(),
    );
  }

  /// Resolves the locality the target should point at after the copy.
  ///
  /// A geography record is atomic, so copying a subset of its fields means
  /// combining the chosen source values with the target's existing ones and
  /// resolving that combination, which may match an existing record or create a
  /// new one.
  Future<db.Value<int?>> _copiedGeographyId(
    SiteRecord source,
    SiteRecord target,
    Set<SiteCopyField> fields,
  ) async {
    const geographyFields = {
      SiteCopyField.country,
      SiteCopyField.islandGroup,
      SiteCopyField.stateProvince,
      SiteCopyField.county,
      SiteCopyField.municipality,
      SiteCopyField.locality,
    };
    if (fields.intersection(geographyFields).isEmpty) {
      return const db.Value.absent();
    }
    String? pick(SiteCopyField field, String? from, String? current) =>
        fields.contains(field) ? from : current;
    final draft = GeographyDraft(
      country: pick(SiteCopyField.country, source.country, target.country),
      islandGroup: pick(
        SiteCopyField.islandGroup,
        source.islandGroup,
        target.islandGroup,
      ),
      stateProvince: pick(
        SiteCopyField.stateProvince,
        source.stateProvince,
        target.stateProvince,
      ),
      county: pick(SiteCopyField.county, source.county, target.county),
      municipality: pick(
        SiteCopyField.municipality,
        source.municipality,
        target.municipality,
      ),
      locality: pick(SiteCopyField.locality, source.locality, target.locality),
    );
    return db.Value(await GeographyQuery(dbAccess).resolve(draft));
  }

  SiteAttributeCompanion _siteAttributeCompanion(
    SiteAttributeData? source,
    Set<SiteCopyField> fields,
  ) {
    return SiteAttributeCompanion(
      habitatType: fields.contains(SiteCopyField.habitatType)
          ? db.Value(source?.habitatType)
          : const db.Value.absent(),
      habitatCondition: fields.contains(SiteCopyField.habitatCondition)
          ? db.Value(source?.habitatCondition)
          : const db.Value.absent(),
      habitatDescription: fields.contains(SiteCopyField.habitatDescription)
          ? db.Value(source?.habitatDescription)
          : const db.Value.absent(),
      canopyCover: fields.contains(SiteCopyField.canopyCover)
          ? db.Value(source?.canopyCover)
          : const db.Value.absent(),
    );
  }

  String _siteLabel(SiteRecord site) {
    final value = site.siteID?.trim();
    return value == null || value.isEmpty ? 'Unnamed site #${site.id}' : value;
  }
}
