import 'package:nahpu/l10n/app_localizations.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/projects/project_transfer_models.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/services/specimen_curation/specimen_curation_mode.dart';
import 'package:nahpu/services/specimen_curation/tissue_box.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/services/templates/print_specimen_table_columns.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/events.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:nahpu/services/types/network_statistics.dart';
import 'package:nahpu/services/types/project_tools.dart';
import 'package:nahpu/services/types/sites.dart';
import 'package:nahpu/services/types/spatial_statistics.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/types/statistics.dart';

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
    RecordType.parasites => l10n.presetsRecordTypeParasites,
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
    'collMethod' => l10n.labelTableCollMethod,
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

/// Personnel roles stay in English in the database; this is the shown label.
String personnelRoleLabel(AppLocalizations l10n, String role) => switch (role) {
  'Cataloger' => l10n.projectPersonnelRoleCataloger,
  'Determiner only' => l10n.projectPersonnelRoleDeterminer,
  'Preparator only' => l10n.projectPersonnelRolePreparator,
  'None' => l10n.projectPersonnelRoleNone,
  _ => role,
};

extension TaxonRankLocalizedLabel on TaxonRank {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    TaxonRank.taxonClass => l10n.projectTaxonClass,
    TaxonRank.order => l10n.projectTaxonOrder,
    TaxonRank.family => l10n.projectTaxonFamily,
    TaxonRank.genus => l10n.projectTaxonGenus,
    TaxonRank.species => l10n.projectTaxonSpecies,
    TaxonRank.subspecies => l10n.projectTaxonSubspecies,
  };
}

extension TaxonSearchCategoryLocalizedLabel on TaxonSearchCategory {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    TaxonSearchCategory.allFields => l10n.projectTaxonAllFields,
    TaxonSearchCategory.taxonRank => l10n.projectTaxonRankLabel,
    TaxonSearchCategory.kingdom => l10n.projectTaxonKingdom,
    TaxonSearchCategory.phylum => l10n.projectTaxonPhylum,
    TaxonSearchCategory.taxonClass => l10n.projectTaxonClass,
    TaxonSearchCategory.order => l10n.projectTaxonOrder,
    TaxonSearchCategory.family => l10n.projectTaxonFamily,
    TaxonSearchCategory.genus => l10n.projectTaxonGenus,
    TaxonSearchCategory.species => l10n.projectTaxonSpecies,
    TaxonSearchCategory.subspecies => l10n.projectTaxonSubspecies,
    TaxonSearchCategory.authors => l10n.projectTaxonAuthors,
    TaxonSearchCategory.commonName => l10n.projectTaxonCommonName,
    TaxonSearchCategory.redListCategory => l10n.projectTaxonRedListCategory,
    TaxonSearchCategory.citesStatus => l10n.projectTaxonCitesStatus,
    TaxonSearchCategory.countryStatus => l10n.projectTaxonCountryStatus,
    TaxonSearchCategory.sortingOrder => l10n.projectTaxonSortingOrder,
    TaxonSearchCategory.notes => l10n.projectPersonnelNotes,
  };
}

extension ProjectTransferSectionLocalizedLabel on ProjectTransferSection {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ProjectTransferSection.projectInfo => l10n.projectTransferProjectInfo,
    ProjectTransferSection.personnel => l10n.settingsNavPersonnel,
    ProjectTransferSection.taxonomy => l10n.projectTransferTaxonomy,
    ProjectTransferSection.sites => l10n.projectTransferSites,
    ProjectTransferSection.events => l10n.projectTransferEvents,
    ProjectTransferSection.specimens => l10n.projectTransferSpecimens,
    ProjectTransferSection.narratives => l10n.projectTransferNarratives,
  };
}

extension ProjectTransferConflictActionLocalizedLabel
    on ProjectTransferConflictAction {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ProjectTransferConflictAction.keepCurrent =>
      l10n.projectTransferKeepCurrent,
    ProjectTransferConflictAction.useImported =>
      l10n.projectTransferUseImported,
    ProjectTransferConflictAction.importAsNew =>
      l10n.projectTransferImportAsNew,
    ProjectTransferConflictAction.skip => l10n.projectWizardSkip,
  };
}

/// The record counts in a project transfer summary are keyed in English.
String projectTransferSummaryLabel(AppLocalizations l10n, String key) =>
    switch (key) {
      'Personnel' => l10n.settingsNavPersonnel,
      'Taxonomy' => l10n.projectTransferTaxonomy,
      'Sites' => l10n.projectTransferSites,
      'Events' => l10n.projectTransferEvents,
      'Specimens' => l10n.projectTransferSpecimens,
      'Narratives' => l10n.projectTransferNarratives,
      'Custom fields' => l10n.projectTransferCustomFields,
      'Media' => l10n.projectTransferMedia,
      _ => key,
    };

extension DataTableRecordTypeLocalizedLabel on DataTableRecordType {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    DataTableRecordType.specimenRecords => l10n.projectTaxonSpecimenRecords,
    DataTableRecordType.specimenParts => l10n.projectBatchSpecimenParts,
    DataTableRecordType.parasites => l10n.projectBatchParasites,
    DataTableRecordType.sites => l10n.projectTransferSites,
    DataTableRecordType.events => l10n.projectTransferEvents,
    DataTableRecordType.narrative => l10n.projectBatchNarrative,
  };
}

extension BatchImportModeLocalizedLabel on BatchImportMode {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    BatchImportMode.update => l10n.projectBatchModeUpdate,
    BatchImportMode.create => l10n.projectBatchModeCreate,
  };
}

extension BatchImportHeaderModeLocalizedLabel on BatchImportHeaderMode {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    BatchImportHeaderMode.auto => l10n.projectBatchHeaderAuto,
    BatchImportHeaderMode.darwinCore => l10n.projectBatchDarwinCore,
    BatchImportHeaderMode.names => l10n.projectBatchHeaderNames,
  };
}

extension BatchImportKeyLocalizedLabel on BatchImportKey {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    BatchImportKey.specimenUuid => l10n.projectBatchKeySpecimenUuid,
    BatchImportKey.catalogNumber => l10n.projectBatchKeyCatalogNumber,
    BatchImportKey.catalogerFieldNumber =>
      l10n.projectBatchKeyCatalogerFieldNumber,
    BatchImportKey.tissueId => l10n.projectBatchKeyTissueId,
    BatchImportKey.barcodeId => l10n.projectBatchKeyBarcodeId,
    BatchImportKey.parasiteId => l10n.projectBatchKeyParasiteId,
    BatchImportKey.parasiteUuid => l10n.projectBatchKeyParasiteUuid,
    BatchImportKey.siteId => l10n.projectBatchKeySiteId,
    BatchImportKey.eventId => l10n.projectBatchKeyEventId,
    BatchImportKey.narrativeDate => l10n.projectBatchKeyNarrativeDate,
  };
}

extension BatchRowStatusLocalizedLabel on BatchRowStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    BatchRowStatus.ready => l10n.projectBatchStatusReady,
    BatchRowStatus.missingLink => l10n.projectBatchStatusMissingLink,
    BatchRowStatus.noMatch => l10n.projectBatchStatusNoMatch,
    BatchRowStatus.ambiguous => l10n.projectBatchStatusAmbiguous,
    BatchRowStatus.exists => l10n.projectBatchStatusExists,
    BatchRowStatus.duplicateInFile => l10n.projectBatchStatusDuplicateInFile,
    BatchRowStatus.invalid => l10n.projectBatchStatusInvalid,
  };
}

extension StatisticMeasureLocalizedLabel on StatisticMeasure {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    StatisticMeasure.specimens => l10n.projectTransferSpecimens,
    StatisticMeasure.species => l10n.projectTaxonSpecies,
    StatisticMeasure.partQuantity => l10n.projectStatsPartQuantity,
    StatisticMeasure.parasites => l10n.projectBatchParasites,
  };

  String localizedCountLabel(AppLocalizations l10n) => switch (this) {
    StatisticMeasure.specimens => l10n.projectTransferSpecimens,
    StatisticMeasure.species => l10n.projectTaxonSpecies,
    StatisticMeasure.partQuantity => l10n.projectStatsQuantity,
    StatisticMeasure.parasites => l10n.projectBatchParasites,
  };
}

extension StatisticGroupLocalizedLabel on StatisticGroup {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    StatisticGroup.species => l10n.projectTaxonSpecies,
    StatisticGroup.taxonRank => l10n.projectTaxonRankLabel,
    StatisticGroup.site => l10n.projectStatsSite,
    StatisticGroup.date => l10n.projectStatsDate,
    StatisticGroup.method => l10n.projectStatsMethod,
    StatisticGroup.sex => l10n.projectStatsSex,
    StatisticGroup.lifeStage => l10n.projectStatsLifeStage,
    StatisticGroup.partType => l10n.projectStatsPartType,
    StatisticGroup.partTreatment => l10n.projectStatsTreatment,
    StatisticGroup.parasiteTaxon => l10n.projectStatsParasiteTaxon,
    StatisticGroup.parasiteCategory => l10n.projectStatsParasiteCategory,
    StatisticGroup.anatomicalLocation => l10n.projectStatsAnatomicalLocation,
    StatisticGroup.hostSpecies => l10n.projectStatsHostSpecies,
  };
}

extension StatisticTaxonRankLocalizedLabel on StatisticTaxonRank {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    StatisticTaxonRank.taxonClass => l10n.projectTaxonClass,
    StatisticTaxonRank.order => l10n.projectTaxonOrder,
    StatisticTaxonRank.family => l10n.projectTaxonFamily,
    StatisticTaxonRank.genus => l10n.projectTaxonGenus,
    StatisticTaxonRank.species => l10n.projectTaxonSpecies,
  };
}

extension StatisticBreakdownLocalizedLabel on StatisticBreakdown {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    StatisticBreakdown.sex => l10n.projectStatsSex,
    StatisticBreakdown.lifeStage => l10n.projectStatsLifeStage,
  };
}

extension StatisticRequestLocalizedLabel on StatisticRequest {
  /// The shown name of the grouped column, such as Family or Site.
  String localizedCategoryLabel(AppLocalizations l10n) =>
      group == StatisticGroup.taxonRank
      ? resolvedRank.localizedLabel(l10n)
      : group.localizedLabel(l10n);

  String localizedTitle(
    AppLocalizations l10n, {
    String? siteLabel,
    String? speciesLabel,
  }) {
    final category = localizedCategoryLabel(l10n).toLowerCase();
    if (measure.usesSpeciesFilter) {
      final title = l10n.projectStatsTitle(
        measure.localizedLabel(l10n),
        category,
      );
      return speciesLabel == null
          ? title
          : l10n.projectStatsTitleForSpecies(title, speciesLabel);
    }
    final title = breakdown == null
        ? l10n.projectStatsTitle(measure.localizedLabel(l10n), category)
        : l10n.projectStatsTitleWithBreakdown(
            measure.localizedLabel(l10n),
            category,
            breakdown!.localizedLabel(l10n).toLowerCase(),
          );
    return siteLabel == null
        ? title
        : l10n.projectStatsTitleAtSite(title, siteLabel);
  }
}

extension NetworkNodeTypeLocalizedLabel on NetworkNodeType {
  /// Plural name of the record type, as on a network column or hub.
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    NetworkNodeType.site => l10n.projectStatsNetworkSites,
    NetworkNodeType.event => l10n.projectStatsNetworkEvents,
    NetworkNodeType.specimen => l10n.projectStatsNetworkSpecimenType,
    NetworkNodeType.taxon => l10n.projectStatsNetworkTaxa,
    NetworkNodeType.collector => l10n.projectStatsNetworkCollectors,
    NetworkNodeType.media => l10n.projectStatsNetworkMedia,
  };
}

extension NetworkLayoutLocalizedLabel on NetworkLayout {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    NetworkLayout.radial => l10n.projectStatsNetworkRadial,
    NetworkLayout.layered => l10n.projectStatsNetworkLayered,
  };
}

extension SpatialStatisticKindLocalizedLabel on SpatialStatisticKind {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    SpatialStatisticKind.specimens => l10n.projectTransferSpecimens,
    SpatialStatisticKind.species => l10n.projectTaxonSpecies,
    SpatialStatisticKind.family => l10n.projectTaxonFamily,
    SpatialStatisticKind.coordinatesBySpecies =>
      l10n.projectStatsCoordinatesBySpecies,
  };

  String localizedTitle(AppLocalizations l10n) => switch (this) {
    SpatialStatisticKind.specimens => l10n.projectStatsSpatialSpecimensTitle,
    SpatialStatisticKind.species => l10n.projectStatsSpatialSpeciesTitle,
    SpatialStatisticKind.family => l10n.projectStatsSpatialFamiliesTitle,
    SpatialStatisticKind.coordinatesBySpecies =>
      l10n.projectStatsSpatialSelectedSpeciesTitle,
  };

  /// Lowercase name of what each count is, as in "12 specimens".
  String localizedCountLabel(AppLocalizations l10n) => switch (this) {
    SpatialStatisticKind.specimens ||
    SpatialStatisticKind.coordinatesBySpecies =>
      l10n.projectStatsCountSpecimens,
    SpatialStatisticKind.species => l10n.projectStatsCountSpecies,
    SpatialStatisticKind.family => l10n.projectStatsCountFamilies,
  };
}

extension TissueCheckFieldLocalizedLabel on TissueCheckField {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    TissueCheckField.museumPermanent => l10n.projectTissueMuseumPermanent,
    TissueCheckField.museumLoan => l10n.projectTissueMuseumLoan,
  };
}

extension TissueIdentifyByLocalizedLabel on TissueIdentifyBy {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    TissueIdentifyBy.tissueId => l10n.projectTissueIdOrBarcode,
    TissueIdentifyBy.fieldId => l10n.recordsSpecimenFieldId,
  };
}

extension TissueFillOrderLocalizedLabel on TissueFillOrder {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    TissueFillOrder.rowMajor => l10n.projectTissueFillRows,
    TissueFillOrder.columnMajor => l10n.projectTissueFillColumns,
    TissueFillOrder.serpentine => l10n.projectTissueFillSerpentine,
  };
}

extension TissueEntryModeLocalizedLabel on TissueEntryMode {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    TissueEntryMode.scan => l10n.projectTissueEntryScan,
    TissueEntryMode.workList => l10n.projectTissueEntryWorkList,
  };
}
