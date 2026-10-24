import 'package:nahpu/l10n/app_localizations.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/templates/print_specimen_table_columns.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/events.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:nahpu/services/types/project_tools.dart';
import 'package:nahpu/services/types/sites.dart';
import 'package:nahpu/services/types/specimens.dart';

/// Localized display labels for service enums and keyed field names.
///
/// The English labels on the types themselves stay the stable values used in
/// exports, file names, stored preferences, and matching. Use these only for
/// text shown in the UI.

extension CatalogFmtLocalizedLabel on CatalogFmt {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    CatalogFmt.ornithology => l10n.labelCatalogFormatOrnithology,
    CatalogFmt.mammalogy => l10n.labelCatalogFormatMammalogy,
    CatalogFmt.herpetology => l10n.labelCatalogFormatHerpetology,
    CatalogFmt.invertebrateZoology =>
      l10n.labelCatalogFormatInvertebrateZoology,
    CatalogFmt.ichthyology => l10n.labelCatalogFormatIchthyology,
  };
}

extension RecordTypeLocalizedLabel on RecordType {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    RecordType.specimenRecord => l10n.presetsRecordTypeSpecimen,
    RecordType.site => l10n.presetsRecordTypeSite,
    RecordType.collEvent => l10n.presetsRecordTypeCollEvent,
    RecordType.narrative => l10n.presetsRecordTypeNarrative,
    RecordType.specimenParts => l10n.presetsRecordTypeSpecimenParts,
    RecordType.none => l10n.presetsRecordTypeNone,
  };
}

extension SpecimenRecordTypeLocalizedLabel on SpecimenRecordType {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    SpecimenRecordType.allTaxa => l10n.labelSpecimenRecordTypeAllTaxa,
    SpecimenRecordType.birds => l10n.labelSpecimenRecordTypeBirds,
    SpecimenRecordType.mammals => l10n.labelSpecimenRecordTypeMammals,
    SpecimenRecordType.herpetofauna => l10n.labelSpecimenRecordTypeHerpetofauna,
    SpecimenRecordType.invertebrates =>
      l10n.labelSpecimenRecordTypeInvertebrates,
    SpecimenRecordType.fishes => l10n.labelSpecimenRecordTypeFishes,
  };
}

extension ProjectToolCategoryLocalizedLabel on ProjectToolCategory {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ProjectToolCategory.utilities => l10n.labelProjectToolCategoryUtilities,
    ProjectToolCategory.project => l10n.labelProjectToolCategoryProject,
    ProjectToolCategory.records => l10n.labelProjectToolCategoryRecords,
    ProjectToolCategory.database => l10n.labelProjectToolCategoryDatabase,
    ProjectToolCategory.configuration =>
      l10n.labelProjectToolCategoryConfiguration,
  };
}

extension ProjectToolLocalizedLabel on ProjectTool {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ProjectTool.dataTable => l10n.labelProjectToolDataTable,
    ProjectTool.templates => l10n.labelProjectToolTemplates,
    ProjectTool.mergeProject => l10n.labelProjectToolMergeProject,
    ProjectTool.exportProject => l10n.labelProjectToolExportProject,
    ProjectTool.batchImport => l10n.labelProjectToolBatchImport,
    ProjectTool.specimenCuration => l10n.labelProjectToolCuration,
    ProjectTool.bundleRecords => l10n.labelProjectToolBundleRecords,
    ProjectTool.exportRecords => l10n.labelProjectToolExportRecords,
    ProjectTool.exportDocuments => l10n.labelProjectToolExportDocuments,
    ProjectTool.backupDatabase => l10n.drawerBackupDatabase,
    ProjectTool.settings => l10n.drawerSettings,
    ProjectTool.exportUserConfigs => l10n.labelProjectToolExportConfigs,
    ProjectTool.importUserConfigs => l10n.labelProjectToolImportConfigs,
  };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
    ProjectTool.dataTable => l10n.labelProjectToolDataTableDescription,
    ProjectTool.templates => l10n.labelProjectToolTemplatesDescription,
    ProjectTool.mergeProject => l10n.labelProjectToolMergeProjectDescription,
    ProjectTool.exportProject => l10n.labelProjectToolExportProjectDescription,
    ProjectTool.batchImport => l10n.labelProjectToolBatchImportDescription,
    ProjectTool.specimenCuration => l10n.labelProjectToolCurationDescription,
    ProjectTool.bundleRecords => l10n.labelProjectToolBundleRecordsDescription,
    ProjectTool.exportRecords => l10n.labelProjectToolExportRecordsDescription,
    ProjectTool.exportDocuments =>
      l10n.labelProjectToolExportDocumentsDescription,
    ProjectTool.backupDatabase =>
      l10n.labelProjectToolBackupDatabaseDescription,
    ProjectTool.settings => l10n.labelProjectToolSettingsDescription,
    ProjectTool.exportUserConfigs => l10n.drawerExportUserConfigs,
    ProjectTool.importUserConfigs => l10n.drawerImportUserConfigs,
  };
}

extension SpatialBasemapStyleLocalizedLabel on SpatialBasemapStyle {
  /// Positron, Bright, and Liberty are OpenFreeMap style names and stay as is.
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    SpatialBasemapStyle.none => l10n.labelBasemapNone,
    SpatialBasemapStyle.automatic => l10n.labelBasemapAutomatic,
    SpatialBasemapStyle.naturalEarthOffline =>
      l10n.labelBasemapNaturalEarthOffline,
    SpatialBasemapStyle.positron ||
    SpatialBasemapStyle.bright ||
    SpatialBasemapStyle.liberty => label,
    SpatialBasemapStyle.dark => l10n.labelBasemapDark,
  };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
    SpatialBasemapStyle.none => l10n.labelBasemapNoneDescription,
    SpatialBasemapStyle.automatic => l10n.labelBasemapAutomaticDescription,
    SpatialBasemapStyle.naturalEarthOffline =>
      l10n.labelBasemapNaturalEarthOfflineDescription,
    SpatialBasemapStyle.positron => l10n.labelBasemapPositronDescription,
    SpatialBasemapStyle.bright => l10n.labelBasemapBrightDescription,
    SpatialBasemapStyle.liberty => l10n.labelBasemapLibertyDescription,
    SpatialBasemapStyle.dark => l10n.labelBasemapDarkDescription,
  };
}

extension UserMapLayerKindLocalizedLabel on UserMapLayerKind {
  /// GeoJSON is a format name and stays as is.
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    UserMapLayerKind.geoJson => label,
    UserMapLayerKind.rasterPmtiles => l10n.labelMapLayerKindRasterTiles,
    UserMapLayerKind.vectorPmtiles => l10n.labelMapLayerKindVectorTiles,
    UserMapLayerKind.demPmtiles => l10n.labelMapLayerKindElevationModel,
  };
}

extension FieldUISectionLocalizedLabel on FieldUISection {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    FieldUISection.specimenAttribute =>
      l10n.labelFieldSectionSpecimenAttributes,
    FieldUISection.siteAttribute => l10n.labelFieldSectionSiteAttributes,
    FieldUISection.environmentalData => l10n.labelFieldSectionEnvironmentalData,
    FieldUISection.specimenPart => l10n.labelFieldSectionSpecimenPart,
    FieldUISection.parasite => l10n.labelFieldSectionParasite,
  };
}

extension TextCaseFmtLocalizedLabel on TextCaseFmt {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    TextCaseFmt.anyCase => l10n.recordsVocabularyCaseAny,
    TextCaseFmt.sentenceCase => l10n.recordsVocabularyCaseSentence,
    TextCaseFmt.titleCase => l10n.recordsVocabularyCaseTitle,
    TextCaseFmt.upperCase => l10n.recordsVocabularyCaseUpper,
    TextCaseFmt.lowerCase => l10n.recordsVocabularyCaseLower,
  };
}

/// Localized label for a site geography field key such as `stateProvince`.
/// Unknown keys fall back to [siteGeographyFieldLabels], then the key.
String siteGeographyFieldLocalizedLabel(AppLocalizations l10n, String field) {
  return switch (field) {
    'country' => l10n.labelSiteGeographyCountry,
    'islandGroup' => l10n.labelSiteGeographyIslandGroup,
    'stateProvince' => l10n.labelSiteGeographyStateProvince,
    'county' => l10n.labelSiteGeographyCounty,
    'municipality' => l10n.labelSiteGeographyMunicipality,
    _ => siteGeographyFieldLabels[field] ?? field,
  };
}

/// Localized label for an environmental data field key. Unknown keys fall
/// back to [environmentalDataFieldLabels], then the key.
String environmentalDataFieldLocalizedLabel(
  AppLocalizations l10n,
  String field,
) {
  return switch (field) {
    'lowestDayTempC' => l10n.labelEnvironmentalLowestDayTemp,
    'highestDayTempC' => l10n.labelEnvironmentalHighestDayTemp,
    'lowestNightTempC' => l10n.labelEnvironmentalLowestNightTemp,
    'highestNightTempC' => l10n.labelEnvironmentalHighestNightTemp,
    'averageHumidity' => l10n.labelEnvironmentalAverageHumidity,
    'dewPointTemp' => l10n.labelEnvironmentalDewPoint,
    'cloudCover' => l10n.labelEnvironmentalCloudCover,
    'rainfallInMm' => l10n.labelEnvironmentalRainfall,
    'ambientTemperature' => l10n.labelEnvironmentalAmbientTemperature,
    'ambientHumidity' => l10n.labelEnvironmentalAmbientHumidity,
    'waterTemperature' => l10n.labelEnvironmentalWaterTemperature,
    'dissolvedOxygen' => l10n.labelEnvironmentalDissolvedOxygen,
    'dissolvedOxygenPercent' =>
      l10n.labelEnvironmentalDissolvedOxygenSaturation,
    'conductivity' => l10n.labelEnvironmentalConductivity,
    'flowVelocity' => l10n.labelEnvironmentalFlowVelocity,
    'sunriseTime' => l10n.labelEnvironmentalSunrise,
    'sunsetTime' => l10n.labelEnvironmentalSunset,
    'moonPhase' => l10n.labelEnvironmentalMoonPhase,
    'notes' => l10n.labelEnvironmentalNotes,
    _ => environmentalDataFieldLabels[field] ?? field,
  };
}

/// Localized environmental field label followed by its unit, such as
/// `Conductivity (µS/cm)`. The unit itself is never translated.
String environmentalDataFieldLocalizedLabelWithUnit(
  AppLocalizations l10n,
  String field,
) {
  final label = environmentalDataFieldLocalizedLabel(l10n, field);
  final unit = environmentalDataFieldUnits[field];
  return unit == null ? label : l10n.labelEnvironmentalWithUnit(label, unit);
}

/// Localized title for a database table name in field pickers. Unknown
/// tables fall back to [databaseTableDisplayTitle].
String databaseTableLocalizedTitle(AppLocalizations l10n, String tableName) {
  return switch (tableName) {
    'project' => l10n.labelTableProject,
    'geography' => l10n.labelTableGeography,
    'site' => l10n.labelTableSite,
    'siteAttribute' => l10n.labelTableSiteAttribute,
    'fossilSite' => l10n.labelTableFossilSite,
    'coordinate' => l10n.labelTableCoordinate,
    'collEvent' => l10n.labelTableCollEvent,
    'environment' => l10n.labelTableEnvironment,
    'collPersonnel' => l10n.labelTableCollPersonnel,
    'collEffort' => l10n.labelTableCollEffort,
    'narrative' => l10n.labelTableNarrative,
    'media' => l10n.labelTableMedia,
    'narrativeMedia' => l10n.labelTableNarrativeMedia,
    'siteMedia' => l10n.labelTableSiteMedia,
    'eventMedia' => l10n.labelTableEventMedia,
    'specimenMedia' => l10n.labelTableSpecimenMedia,
    'associatedData' => l10n.labelTableAssociatedData,
    'specimenAssociatedData' => l10n.labelTableSpecimenAssociatedData,
    'siteAssociatedData' => l10n.labelTableSiteAssociatedData,
    'eventAssociatedData' => l10n.labelTableEventAssociatedData,
    'personnelList' => l10n.labelTablePersonnelList,
    'personnel' => l10n.labelTablePersonnel,
    'taxonomy' => l10n.labelTableTaxonomy,
    'specimen' => l10n.labelTableSpecimen,
    'mammalAttribute' => l10n.labelTableMammalAttribute,
    'birdAttribute' => l10n.labelTableBirdAttribute,
    'herpAttribute' => l10n.labelTableHerpAttribute,
    'invertebrateAttribute' => l10n.labelTableInvertebrateAttribute,
    'fishAttribute' => l10n.labelTableFishAttribute,
    'fossilAttribute' => l10n.labelTableFossilAttribute,
    'parasiteDetection' => l10n.labelTableParasiteDetection,
    'parasite' => l10n.labelTableParasite,
    'specimenPart' => l10n.labelTableSpecimenPart,
    'specimenIndividual' => l10n.labelTableSpecimenIndividual,
    'specimenPartIndividual' => l10n.labelTableSpecimenPartIndividual,
    'parasiteIndividual' => l10n.labelTableParasiteIndividual,
    'customFieldDefinition' => l10n.labelTableCustomFieldDefinition,
    'customFieldValue' => l10n.labelTableCustomFieldValue,
    _ => databaseTableDisplayTitle(tableName),
  };
}
