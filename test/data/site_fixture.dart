import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/geography_queries.dart';
import 'package:nahpu/services/types/geography.dart';

/// Inserts a site with its locality resolved into the shared geography table.
///
/// Geography lives in its own table, so tests that used to set the locality
/// columns on `SiteCompanion` build the record here instead. Passing equal
/// values twice reuses one geography row, exactly as the app does.
Future<int> insertSiteWithGeography(
  Database database, {
  String projectUuid = '',
  String? siteID,
  String? siteType,
  String? leadStaffId,
  String? remark,
  String? country,
  String? islandGroup,
  String? stateProvince,
  String? county,
  String? municipality,
  String? locality,
}) async {
  final geographyId = await GeographyQuery(database).resolve(
    GeographyDraft(
      country: country,
      islandGroup: islandGroup,
      stateProvince: stateProvince,
      county: county,
      municipality: municipality,
      locality: locality,
    ),
  );
  return database
      .into(database.site)
      .insert(
        SiteCompanion(
          projectUuid: Value(projectUuid),
          siteID: Value(siteID),
          siteType: Value(siteType),
          leadStaffId: Value(leadStaffId),
          remark: Value(remark),
          geographyId: Value(geographyId),
        ),
      );
}
