// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonBeta => 'Beta';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonUnavailable => 'Unavailable';

  @override
  String get commonError => 'Error';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonPreview => 'Preview';

  @override
  String get commonSortRecords => 'Sort records';

  @override
  String get commonDeleteRecord => 'Delete record';

  @override
  String get commonDeleteAllRecords => 'Delete all records';

  @override
  String get homeDatabaseErrorTitle => 'Unable to open the NAHPU database.';

  @override
  String get homeDatabaseErrorBody =>
      'Your data was not deleted. Retry the database migration or restart NAHPU.';

  @override
  String get homeExistingProjects => 'Existing projects';

  @override
  String get homeNoProjectsTitle => 'No projects found.';

  @override
  String get homeNoProjectsBody => 'Create or import a project to get started.';

  @override
  String get homeSetupHint =>
      'New to NAHPU? Run Setup NAHPU to choose your catalog format, identifiers, vocabularies, and export presets.';

  @override
  String get homeSetupNahpu => 'Setup NAHPU';

  @override
  String get homeStatistics => 'Statistics';

  @override
  String get homeSearchRecords => 'Search records';

  @override
  String get homeSearchReset => 'Reset';

  @override
  String get homeSearchShowResults => 'Show results';

  @override
  String get homeSearchHint => 'Field number, taxon, site, or any value';

  @override
  String get homeSearchRecordType => 'Record type';

  @override
  String get homeSearchIn => 'Search in';

  @override
  String get homeSearchAllFields => 'All fields';

  @override
  String get homeSearchProjects => 'Projects';

  @override
  String get homeSearchAllProjects => 'All projects';

  @override
  String get homeSearchTaxa => 'Taxa';

  @override
  String get homeSearchQuickFilters => 'Quick filters';

  @override
  String homeProjectAccessed(String date) {
    return 'Accessed: $date';
  }

  @override
  String homeProjectCreated(String date) {
    return 'Created: $date';
  }

  @override
  String get homeProjectActions => 'Project actions';

  @override
  String get homeProjectEditInfo => 'Edit info';

  @override
  String get homeProjectShowQr => 'Show QR';

  @override
  String get homeProjectExportInfo => 'Export info';

  @override
  String get homeProjectDetails => 'Details';

  @override
  String get homeProjectInformation => 'Project information';

  @override
  String get homeProjectQrCode => 'Project QR code';

  @override
  String get homeProjectQrDescription =>
      'Scan this code when creating a new project to transfer project information.';

  @override
  String aboutTitle(String appName) {
    return 'About $appName';
  }

  @override
  String get aboutTagline =>
      'Rethinking biodiversity inventories in the digital age';

  @override
  String get aboutLicenses => 'Licenses';

  @override
  String get aboutAppVersion => 'App version';

  @override
  String aboutVersionBuild(String version, String build) {
    return 'v$version (build $build)';
  }

  @override
  String get aboutCodename => 'Codename';

  @override
  String get aboutCodenameNote =>
      'From NAHPU’s first real-world field test on Mt. Gede, West Java, Indonesia.';

  @override
  String get aboutDatabaseSchema => 'Database schema';

  @override
  String aboutSchemaSupported(String version) {
    return 'App supports v$version';
  }

  @override
  String aboutDescription(String appName) {
    return '$appName is a cross-platform digital catalog app designed for natural history specimen data collection and management, providing insights at the point of collection.';
  }

  @override
  String get drawerCreateProject => 'Create project';

  @override
  String get drawerImportProject => 'Import project';

  @override
  String get drawerDatabaseStatistics => 'Database statistics';

  @override
  String get drawerBackupDatabase => 'Backup database';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerExportUserConfigs => 'Export user configs';

  @override
  String get drawerImportUserConfigs => 'Import user configs';

  @override
  String get drawerAbout => 'About';

  @override
  String get drawerWebsite => 'NAHPU website';

  @override
  String get drawerCookbook => 'Cookbook';

  @override
  String get settingsApplications => 'Applications';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLabel => 'Set light or dark appearance';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsTools => 'Tools';

  @override
  String get settingsToolsLabel =>
      'Choose the tools shown on the project dashboard';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String settingsLanguageSystemLabel(String language) {
    return 'Follows the device language ($language)';
  }

  @override
  String get settingsLanguageBetaNote =>
      'Language support is in beta. Some screens are still in English, and translations may be machine drafts.';

  @override
  String get settingsRegionalFormat => 'Regional format';

  @override
  String get settingsRegionalFormatMatchLanguage => 'Match language';

  @override
  String get settingsRegionalFormatNote =>
      'Changes only how dates and numbers are shown. Saved records and exports keep standard formats.';

  @override
  String settingsRegionalFormatPreview(String date, String number) {
    return 'Example: $date · $number';
  }

  @override
  String get docsContents => 'Contents';

  @override
  String docsCollapse(String title) {
    return 'Collapse $title';
  }

  @override
  String docsExpand(String title) {
    return 'Expand $title';
  }

  @override
  String get docsLoadError => 'Unable to load this documentation.';

  @override
  String get docsOnlineLinks =>
      'These links open the NAHPU documentation and need an internet connection.';

  @override
  String get docsAsideNote => 'Note';

  @override
  String get docsAsideCaution => 'Caution';

  @override
  String get docsAsideTip => 'Tip';

  @override
  String get docsAiTranslation => 'AI-assisted translation.';

  @override
  String get docsAiCheck => 'Check for accuracy';

  @override
  String docsReviewedBy(String reviewers) {
    return 'Human-checked and revised by $reviewers.';
  }

  @override
  String docsReviewerPair(String first, String second) {
    return '$first and $second';
  }

  @override
  String docsReviewerList(String leading, String last) {
    return '$leading, and $last';
  }

  @override
  String get narrativeTitle => 'Narrative';

  @override
  String get narrativeRecordTitle => 'Narrative Record';

  @override
  String get narrativeSearchHint => 'Search narrative';

  @override
  String get narrativeEmpty => 'No narrative found';

  @override
  String get narrativeCreate => 'Create narrative';

  @override
  String get narrativeActions => 'Narrative actions';

  @override
  String get narrativeDeleteTitle => 'Delete narrative?';

  @override
  String get narrativeDeletePrompt => 'You will delete this narrative';

  @override
  String get narrativeDeleteAllTitle => 'Delete all narrative?';

  @override
  String get narrativeDeleteAllPrompt =>
      'You will delete all narrative in this project';

  @override
  String narrativeDeleteError(String error) {
    return 'Error deleting narrative: $error';
  }

  @override
  String get narrativeDeleted => 'Narrative deleted';

  @override
  String get narrativeTextLabel => 'Narrative';

  @override
  String get narrativeTextHint => 'Enter narrative (Markdown supported)';

  @override
  String get narrativeTextEmpty =>
      'No narrative. Use the Edit button above to start writing.';

  @override
  String get narrativeDate => 'Date';

  @override
  String get narrativeDateHint => 'Enter date';

  @override
  String get narrativeTime => 'Time';

  @override
  String get narrativeTimeHint => 'Enter time';

  @override
  String get narrativeWriter => 'Writer';

  @override
  String get narrativeWriterHint => 'Choose a person name';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDone => 'Done';

  @override
  String get commonExport => 'Export';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonReset => 'Reset';

  @override
  String get settingsNavCatalogs => 'Catalogs';

  @override
  String get settingsNavCatalogFormat => 'Format';

  @override
  String get settingsNavCatalogFormatLabel => 'Set catalog format';

  @override
  String settingsNavCatalogFormatLoadError(String error) {
    return 'Unable to load catalog format: $error';
  }

  @override
  String get settingsNavSites => 'Sites';

  @override
  String get settingsNavSitesLabel =>
      'Manage site types, habitat types, and coordinate datums';

  @override
  String get settingsNavEvents => 'Events';

  @override
  String get settingsNavEventsLabel =>
      'Manage activities, collection methods, personnel roles, and environmental fields';

  @override
  String get settingsNavSpecimens => 'Specimens';

  @override
  String get settingsNavSpecimensLabel =>
      'Manage field, tissue ID settings, and controlled vocabularies for specimen forms';

  @override
  String get settingsNavCustomFields => 'Custom fields';

  @override
  String get settingsNavCustomFieldsLabel =>
      'Manage fields for sites, environmental data, specimens, parts, and parasites';

  @override
  String get settingsNavDatabase => 'Database';

  @override
  String get settingsNavTaxa => 'Taxa';

  @override
  String get settingsNavTaxaLabel => 'Manage taxonomy records';

  @override
  String get settingsNavPersonnel => 'Personnel';

  @override
  String get settingsNavPersonnelLabel => 'Manage personnel records';

  @override
  String get settingsNavBackupDatabaseLabel =>
      'Full database backup of all records and settings';

  @override
  String get settingsNavReplaceDatabase => 'Replace database';

  @override
  String get settingsNavReplaceDatabaseLabel =>
      'Replace current database with another database file';

  @override
  String get settingsNavExports => 'Exports';

  @override
  String get settingsNavTabularData => 'Tabular Data';

  @override
  String get settingsNavTabularDataLabel =>
      'Manage presets for exporting in tabular formats';

  @override
  String get settingsNavDocuments => 'Documents';

  @override
  String get settingsNavDocumentsLabel =>
      'Manage presets for exporting documents';

  @override
  String get settingsNavTemplateEditor => 'Template Editor';

  @override
  String get settingsNavTemplateEditorLabel =>
      'Create and edit document templates';

  @override
  String get settingsCommonSetCaseFormat => 'Set case format';

  @override
  String get settingsFileTreeEmpty => 'The application folder is empty.';

  @override
  String settingsFileTreeUnlinkedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unlinked',
    );
    return '$_temp0';
  }

  @override
  String get settingsFileTreeRemoveEmptyFolder => 'Remove this empty folder';

  @override
  String get settingsFileTreeSelectFolder => 'Select this folder';

  @override
  String settingsFileTreeSelectRemovable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Select the $count removable files here',
      one: 'Select the 1 removable file here',
    );
    return '$_temp0';
  }

  @override
  String get settingsFileTreeSaveCopy => 'Save a copy';

  @override
  String get settingsFileTreeRemoveFile => 'Remove this file';

  @override
  String get settingsFileTreeKept => 'Kept';

  @override
  String get settingsSelectionApplicationFolder => 'Application folder';

  @override
  String settingsSelectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected files',
      one: '1 selected file',
    );
    return '$_temp0';
  }

  @override
  String get settingsSelectionArchiveFormat => 'Archive format';

  @override
  String get settingsSelectionNoFolder =>
      'Exporting a selection needs a folder to write to, which this device cannot offer. You can still delete the selected files after reviewing them.';

  @override
  String get settingsSelectionExportNote =>
      'Exporting writes these files to one compressed archive, then offers to remove the originals. Deleting removes them straight away and cannot be undone.';

  @override
  String get settingsSelectionDeleteNote =>
      'Deleting removes the selected files straight away and cannot be undone.';

  @override
  String get settingsSelectionDeletePermanently => 'Delete permanently';

  @override
  String get settingsMapLayers => 'Map layers';

  @override
  String get settingsMapPmtilesType => 'PMTiles layer type';

  @override
  String settingsMapImportError(String error) {
    return 'Unable to import map layer: $error';
  }

  @override
  String get settingsMapBaseLayer => 'Base layer';

  @override
  String get settingsMapCustomLayers => 'Custom layers';

  @override
  String settingsMapLoadError(String error) {
    return 'Unable to load custom map layers: $error';
  }

  @override
  String get settingsMapNoCustomLayers =>
      'No custom layers have been imported.';

  @override
  String get settingsMapImportCustomLayer => 'Import custom layer';

  @override
  String settingsMapKindUnavailableOnLinux(String kind) {
    return '$kind · unavailable on Linux';
  }

  @override
  String get settingsMapConfigureLayer => 'Configure layer';

  @override
  String get settingsMapShowLayer => 'Show layer';

  @override
  String get settingsMapLayerUnavailableOnLinux =>
      'This layer is unavailable on Linux';

  @override
  String get settingsMapLayerTypeUnavailableOnLinux =>
      'This layer type is unavailable on Linux.';

  @override
  String get settingsMapOpacity => 'Opacity';

  @override
  String get settingsMapUseTerrain => 'Use for 3D terrain';

  @override
  String get settingsMapHillshadeNote =>
      'Hillshade remains visible when terrain is off.';

  @override
  String get settingsMapLayerOrder => 'Layer order';

  @override
  String get settingsMapMoveEarlier => 'Move earlier';

  @override
  String get settingsMapMoveLater => 'Move later';

  @override
  String get settingsMapDeleteLayer => 'Delete layer';

  @override
  String get settingsMapDeleteLayerTitle => 'Delete map layer?';

  @override
  String settingsMapDeleteLayerBody(String name) {
    return 'Delete $name and its stored map data?';
  }

  @override
  String get settingsMapSupportedFormatsLinux =>
      'Supports GeoJSON, zipped WGS84 Shapefiles, and raster PMTiles on Linux.';

  @override
  String get settingsMapSupportedFormats =>
      'Supports GeoJSON, zipped WGS84 Shapefiles, and PMTiles.';

  @override
  String get settingsDataUsage => 'Data usage';

  @override
  String get settingsDataUsageLabel =>
      'Browse and clean up the application folder';

  @override
  String get settingsDataUsageRescan => 'Rescan';

  @override
  String get settingsDataUsageFiles => 'Files';

  @override
  String get settingsDataUsageFilesLabel => 'Include images and other files';

  @override
  String get settingsDataUsageMediaFiles => 'Media files';

  @override
  String get settingsDataUsageMediaFilesLabel => 'Images, audio, video';

  @override
  String get settingsDataUsageTotal => 'Total usage';

  @override
  String get settingsDataUsageReclaimable => 'Reclaimable';

  @override
  String get settingsDataUsageReclaimableLabel =>
      'Unlinked files that can be removed';

  @override
  String get settingsDataUsageNone => 'None';

  @override
  String get settingsDataUsageRemoveOriginalsTitle => 'Remove the originals?';

  @override
  String settingsDataUsageArchiveWritten(
    int count,
    String archive,
    String size,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files were written to $archive ($size).',
      one: '1 file was written to $archive ($size).',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataUsageRemoveOriginalsBody =>
      'Removing them from NAHPU frees the space. The archive keeps your copy, and this cannot be undone.';

  @override
  String settingsDataUsageExportedTo(String path) {
    return 'Exported to $path';
  }

  @override
  String settingsDataUsageExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String settingsDataUsageSaveCopyFailed(String name, String error) {
    return 'Could not save $name: $error';
  }

  @override
  String get settingsDataUsageRemoveFileTitle => 'Remove this file?';

  @override
  String settingsDataUsageRemoveFileBody(String name, String size) {
    return '$name ($size) is not linked to any record. This cannot be undone.';
  }

  @override
  String get settingsDataUsageRemoveFolderTitle => 'Remove this empty folder?';

  @override
  String settingsDataUsageRemoveFolderBody(String name) {
    return '$name holds no files. Removing it does not affect any record.';
  }

  @override
  String settingsDataUsageRemovedFolder(String name) {
    return 'Removed $name.';
  }

  @override
  String settingsDataUsageRemoveFolderFailed(String name) {
    return 'Could not remove $name.';
  }

  @override
  String settingsDataUsageDeleteSelectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count selected files?',
      one: 'Delete 1 selected file?',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataUsageDeleteSelectionBody =>
      'These files are not linked to any record. This cannot be undone.';

  @override
  String get settingsDataUsageCollapseAll => 'Collapse all';

  @override
  String get settingsDataUsageExpandAll => 'Expand all';

  @override
  String get settingsDataUsageSelectAll => 'Select all';

  @override
  String get settingsDataUsageSelect => 'Select';

  @override
  String get settingsDataUsageClear => 'Clear';

  @override
  String settingsDataUsageReview(int count) {
    return 'Review $count';
  }

  @override
  String get settingsDataUsageScanError =>
      'Could not read the application folder';

  @override
  String get settingsDataUsagePruneTitle => 'Remove unlinked files';

  @override
  String get settingsDataUsagePruneDescription =>
      'Files no longer used by any record, such as leftovers from deleted media or cancelled imports. Linked files, databases and backups, custom fonts, map layers, and files outside NAHPU-managed folders are not affected.';

  @override
  String get settingsDataUsageNothingToReclaim => 'Nothing to reclaim.';

  @override
  String settingsDataUsagePruneButton(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remove $count unlinked files ($size)',
      one: 'Remove 1 unlinked file ($size)',
    );
    return '$_temp0';
  }

  @override
  String settingsDataUsagePruneConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remove $count unlinked files?',
      one: 'Remove 1 unlinked file?',
    );
    return '$_temp0';
  }

  @override
  String settingsDataUsagePruneConfirmBody(String size) {
    return 'This frees $size. Files still linked to your records, your database and its backups, and your custom fonts and map layers are not affected.\n\nThis cannot be undone.';
  }

  @override
  String settingsDataUsageRemovedSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Removed $count files ($size).',
      one: 'Removed 1 file ($size).',
    );
    return '$_temp0';
  }

  @override
  String settingsDataUsageKeptChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files were kept because they changed during the scan.',
      one: '1 file was kept because it changed during the scan.',
    );
    return '$_temp0';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get recordsCatalogFormat => 'Catalog format';

  @override
  String get recordsCatalogMeasurementRecords => 'Measurement records';

  @override
  String get recordsCatalogAlwaysShowBatFields => 'Always show bat fields';

  @override
  String get recordsCatalogBatFieldsNote =>
      'If enabled, fields specific to bats are always shown in the mammal measurement fields. You can also choose to toggle the visibility of bat-specific fields for each specimen record in the specimen record screen.';

  @override
  String get recordsVocabularyCaseFormat => 'Case format';

  @override
  String recordsVocabularyCaseFormatLoadError(String error) {
    return 'Unable to load case format: $error';
  }

  @override
  String get recordsVocabularyCaseAny => 'Any Case';

  @override
  String get recordsVocabularyCaseSentence => 'Sentence Case';

  @override
  String get recordsVocabularyCaseTitle => 'Title Case';

  @override
  String get recordsVocabularyCaseUpper => 'Upper Case';

  @override
  String get recordsVocabularyCaseLower => 'Lower Case';

  @override
  String get recordsSiteSettings => 'Site settings';

  @override
  String get recordsSiteTypes => 'Site Types';

  @override
  String get recordsSiteHabitatTypes => 'Habitat Types';

  @override
  String get recordsSiteDatums => 'Datums';

  @override
  String get recordsSiteGeographyFields => 'Geography fields';

  @override
  String recordsSiteGeographyFieldsLoadError(String error) {
    return 'Unable to load geography fields: $error';
  }

  @override
  String get recordsSiteMaps => 'Maps';

  @override
  String get recordsSiteMapLayers => 'Map layers';

  @override
  String get recordsSiteMapLayersLabel =>
      'Choose a base layer or import and manage custom layers';

  @override
  String get recordsCollEventSettings => 'Collection event settings';

  @override
  String get recordsCollEventPrimaryActivities => 'Primary Activities';

  @override
  String get recordsCollEventCollectionMethods => 'Collection Methods';

  @override
  String get recordsCollEventPersonnelRoles => 'Personnel Roles';

  @override
  String get recordsCollEventEnvironmentalDataFields =>
      'Environmental data fields';

  @override
  String recordsCollEventEnvironmentalDataFieldsLoadError(String error) {
    return 'Unable to load environmental data fields: $error';
  }

  @override
  String get recordsCollEventTemperature => 'Temperature';

  @override
  String get recordsCollEventHumidity => 'Humidity';

  @override
  String get recordsCollEventEnvironmentalMeasurements =>
      'Environmental measurements';

  @override
  String get recordsCollEventAquaticData => 'Aquatic Data';

  @override
  String get recordsCollEventAstronomy => 'Astronomy';

  @override
  String get recordsSpecimenSettings => 'Specimen settings';

  @override
  String get recordsSpecimenCaptureRecords => 'Capture records';

  @override
  String get recordsSpecimenAlwaysShowCollector =>
      'Always show collector field';

  @override
  String get recordsSpecimenIdentificationMethods => 'Identification Methods';

  @override
  String get recordsSpecimenLifeStages => 'Life Stages';

  @override
  String get recordsSpecimenTypes => 'Specimen Types';

  @override
  String get recordsSpecimenTreatments => 'Treatments';

  @override
  String get recordsSpecimenConditions => 'Conditions';

  @override
  String get recordsSpecimenSex => 'Sex';

  @override
  String recordsSpecimenSexNote(String male, String female, String unknown) {
    return '$male, $female, and $unknown are always available. Add optional terms with +. A question mark records examiner uncertainty.';
  }

  @override
  String recordsSpecimenSexLoadError(String error) {
    return 'Unable to load sex options: $error';
  }

  @override
  String get recordsSpecimenSexSelected => 'Selected';

  @override
  String get recordsSpecimenSexAdditional => 'Additional options';

  @override
  String get recordsSpecimenSexRemoveBlockedTitle => 'Cannot remove sex';

  @override
  String recordsSpecimenSexRemoveBlockedBody(String sex) {
    return '$sex is used by one or more specimen records. Change those records before removing this option.';
  }

  @override
  String get recordsSpecimenParasites => 'Parasites';

  @override
  String get recordsSpecimenParasiteIdentification => 'Identification';

  @override
  String get recordsSpecimenParasiteCategories => 'Categories';

  @override
  String get recordsSpecimenParasiteDetectionMethods => 'Detection Methods';

  @override
  String get recordsSpecimenParasitePreparationMethods => 'Preparation Methods';

  @override
  String get recordsSpecimenParasiteAnatomicalLocations =>
      'Anatomical Locations';

  @override
  String get recordsSpecimenParasiteStorage => 'Storage';

  @override
  String get recordsSpecimenParasiteIdPrefix => 'Parasite ID prefix';

  @override
  String recordsSpecimenParasiteIdPrefixHint(String example) {
    return 'Enter a prefix, e.g. $example';
  }

  @override
  String get recordsSpecimenParasiteIdNumber => 'Parasite ID number';

  @override
  String get recordsSpecimenNextNumberHint => 'Enter the next number';

  @override
  String get recordsSpecimenFieldId => 'Field ID';

  @override
  String recordsSpecimenFieldIdModeLoadError(String error) {
    return 'Unable to load field ID mode: $error';
  }

  @override
  String get recordsSpecimenPersonnelId => 'Personnel ID';

  @override
  String get recordsSpecimenPersonnelIdDescription =>
      'The ID is a person\'s initials and running number. You will set it when creating personnel with a cataloger role.';

  @override
  String get recordsSpecimenProjectId => 'Project ID';

  @override
  String get recordsSpecimenProjectIdDescription =>
      'The project keeps one running number with a shared prefix and suffix.';

  @override
  String get recordsSpecimenPersonnelFieldIdNoteTitle =>
      'Personnel field IDs require a cataloger';

  @override
  String get recordsSpecimenPersonnelFieldIdNoteBody =>
      'Add a person with the Cataloger role in the project and assign a current field number to that role.';

  @override
  String get recordsSpecimenAddPersonnel => 'Add personnel';

  @override
  String get recordsSpecimenPrefix => 'Prefix';

  @override
  String get recordsSpecimenSuffix => 'Suffix';

  @override
  String recordsSpecimenExampleHint(String example) {
    return 'e.g. $example';
  }

  @override
  String get recordsSpecimenCurrentCatalogNumber => 'Current catalog number';

  @override
  String recordsSpecimenFieldIdPreview(String id) {
    return 'Preview: $id';
  }

  @override
  String get recordsSpecimenAutoIncrement => 'Auto-increment catalog number';

  @override
  String get recordsSpecimenSaveFieldIdSettings => 'Save field ID settings';

  @override
  String get recordsSpecimenFieldIdSettingsSaved => 'Field ID settings saved.';

  @override
  String get recordsSpecimenNoProjectFieldIdTitle =>
      'Open a project to set project field IDs';

  @override
  String get recordsSpecimenNoProjectFieldIdBody =>
      'The prefix, current number, and suffix are saved per project.';

  @override
  String get recordsSpecimenFieldIdChangeTitle =>
      'Change project field ID format?';

  @override
  String get recordsSpecimenFieldIdChangeBody =>
      'Changing the project field ID prefix or suffix changes existing project IDs. These identifiers may already have been used in exports or written on specimen labels. Double-check the new values before changing them.';

  @override
  String get recordsSpecimenIUnderstand => 'I understand';

  @override
  String get recordsSpecimenTissueId => 'Tissue ID';

  @override
  String get recordsSpecimenNextTissueId => 'Next tissue ID';

  @override
  String get recordsSpecimenIndividualTagId => 'Individual tag ID';

  @override
  String get recordsSpecimenNextTag => 'Next tag';

  @override
  String get recordsCustomFieldTitle => 'Custom fields';

  @override
  String get recordsCustomFieldFieldsTab => 'Fields';

  @override
  String get recordsCustomFieldEditField => 'Edit field';

  @override
  String recordsCustomFieldLoadError(String error) {
    return 'Unable to load fields: $error';
  }

  @override
  String recordsCustomFieldSaved(String name) {
    return 'Saved “$name”.';
  }

  @override
  String recordsCustomFieldImportQrError(String error) {
    return 'Unable to import QR code: $error';
  }

  @override
  String recordsCustomFieldImportError(String error) {
    return 'Unable to import custom fields: $error';
  }

  @override
  String get recordsCustomFieldImportEmpty =>
      'This user-config payload has no custom field templates.';

  @override
  String recordsCustomFieldImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count custom field definitions.',
      one: 'Imported 1 custom field definition.',
    );
    return '$_temp0';
  }

  @override
  String recordsCustomFieldExportError(String error) {
    return 'Unable to export custom fields: $error';
  }

  @override
  String recordsCustomFieldExportedTo(String path) {
    return 'Custom fields exported to $path';
  }

  @override
  String get recordsCustomFieldExported => 'Custom fields exported';

  @override
  String get recordsCustomFieldQrTooLargeTitle => 'QR code is too large';

  @override
  String get recordsCustomFieldQrTooLargeBody =>
      'The selected custom fields contain too much data for one QR code. Export them as a file instead.';

  @override
  String get recordsCustomFieldExportFile => 'Export file';

  @override
  String get recordsCustomFieldDiscardLegacyTitle => 'Discard legacy values?';

  @override
  String recordsCustomFieldDiscardLegacyBody(String name) {
    return 'Legacy values for “$name” cannot be recovered after they are discarded.';
  }

  @override
  String get recordsCustomFieldDiscardValues => 'Discard values';

  @override
  String get recordsCustomFieldDeleteTitle => 'Delete custom field?';

  @override
  String recordsCustomFieldDeleteBody(String name) {
    return 'Delete “$name” permanently? This action cannot be undone.';
  }

  @override
  String get recordsCustomFieldSelectFields => 'Select fields';

  @override
  String get recordsCustomFieldShowArchived => 'Show archived fields';

  @override
  String recordsCustomFieldAllArchived(String location) {
    return 'All custom fields in $location are archived.';
  }

  @override
  String recordsCustomFieldEmpty(String location) {
    return 'No custom fields in $location yet.';
  }

  @override
  String get recordsCustomFieldAdd => 'Add custom field';

  @override
  String get recordsCustomFieldArchived => 'Archived';

  @override
  String get recordsCustomFieldActive => 'Active';

  @override
  String get recordsCustomFieldDefinitionActions => 'Definition actions';

  @override
  String get recordsCustomFieldMoveUp => 'Move up';

  @override
  String get recordsCustomFieldMoveDown => 'Move down';

  @override
  String get recordsCustomFieldRestore => 'Restore';

  @override
  String get recordsCustomFieldArchive => 'Archive';

  @override
  String get recordsCustomFieldDiscardLegacy => 'Discard legacy values';

  @override
  String get recordsCustomFieldDeleteInUse => 'Delete (values in use)';

  @override
  String get recordsCustomFieldSelectPrompt =>
      'Select a custom field to edit, or add a new one.';

  @override
  String get recordsCustomFieldNew => 'New custom field';

  @override
  String recordsCustomFieldEditName(String name) {
    return 'Edit $name';
  }

  @override
  String recordsCustomFieldShownIn(String location) {
    return 'Shown in $location';
  }

  @override
  String get recordsCustomFieldDetails => 'Details';

  @override
  String get recordsCustomFieldStatus => 'Status';

  @override
  String get recordsCustomFieldScope => 'Scope';

  @override
  String get recordsCustomFieldStoredValues => 'Stored values';

  @override
  String get recordsCustomFieldLegacyValues => 'Legacy values';

  @override
  String get recordsCustomFieldDeletion => 'Deletion';

  @override
  String get recordsCustomFieldDeletionAvailable => 'Available';

  @override
  String get recordsCustomFieldDeletionUnavailable =>
      'Unavailable until all stored values are cleared';

  @override
  String recordsCustomFieldUsageLoadError(String error) {
    return 'Unable to load usage: $error';
  }

  @override
  String get recordsCustomFieldProjectUuid => 'Project UUID';

  @override
  String get recordsCustomFieldDefinitionUuid => 'Definition UUID';

  @override
  String get recordsCustomFieldSourceTemplateUuid => 'Source template UUID';

  @override
  String get recordsCustomFieldNotFromTemplate =>
      'Not imported from a template';

  @override
  String get recordsCustomFieldTypeText => 'Text';

  @override
  String get recordsCustomFieldTypeNumber => 'Number';

  @override
  String get recordsCustomFieldTypeBoolean => 'Yes / No';

  @override
  String get recordsCustomFieldTypeDropdown => 'Dropdown';

  @override
  String get recordsCustomFieldScopeGlobal => 'Global';

  @override
  String get recordsCustomFieldScopeProject => 'Current project';

  @override
  String get recordsCustomFieldAllCatalogs => 'All catalog formats';

  @override
  String recordsCustomFieldCatalogOnly(String catalog) {
    return '$catalog only';
  }

  @override
  String get commonSelectAll => 'Select all';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonImport => 'Import';

  @override
  String get databaseSelectFileFailed => 'Failed to select file!';

  @override
  String get databaseReplaceConfirmTitle => 'Replace database?';

  @override
  String get databaseReplace => 'Replace';

  @override
  String get databaseRestoreCancelled =>
      'Restore cancelled. The database was not replaced.';

  @override
  String get databaseRestoreCannotStop =>
      'The restore is replacing your data and cannot be stopped now.';

  @override
  String get databaseCancelRestoreTitle => 'Cancel the restore?';

  @override
  String get databaseCancelRestoreBody =>
      'The archive is still being read. Leaving now cancels the restore and your current data is left untouched.';

  @override
  String get databaseKeepRestoring => 'Keep restoring';

  @override
  String get databaseCancelRestore => 'Cancel restore';

  @override
  String databaseReplaceFailed(String error) {
    return 'Failed to replace database: $error';
  }

  @override
  String get databaseReplaceDatabase => 'Replace database';

  @override
  String get databaseReplaceWith => 'Replace with';

  @override
  String get databaseSourceDescription =>
      'A NAHPU backup archive or a SQLite database file.';

  @override
  String get databaseNoFileSelected => 'No file selected';

  @override
  String get databaseBrowse => 'Browse';

  @override
  String get databaseChangeFile => 'Change';

  @override
  String get databaseClearFile => 'Clear file';

  @override
  String get databaseSupportedFormats => 'ZIP, TAR.GZ, or SQLITE3';

  @override
  String get databaseCannotRestore => 'Can’t be restored';

  @override
  String get databaseSqliteDatabase => 'SQLite database';

  @override
  String get databaseBackupArchive => 'NAHPU backup archive';

  @override
  String databaseBackupArchiveRestores(String database) {
    return 'NAHPU backup archive · restores $database';
  }

  @override
  String get databaseBeforeReplacing => 'Before replacing';

  @override
  String get databaseReplaceWarning =>
      'This action will replace every record in NAHPU. Media or config files that match the archive will be overwritten. This cannot be undone.';

  @override
  String get databaseBackupFirst => 'Back up current data first';

  @override
  String get databaseBackupFirstSubtitle =>
      'Saves a full archive, including media, to the NAHPU backup folder';

  @override
  String get databaseNoSafetyBackup =>
      'No safety backup. Your current records and media are not saved before they are replaced.';

  @override
  String get databaseComparisonTitle => 'Current and replacement';

  @override
  String get databaseChooseFileToCompare => 'Choose a file to compare.';

  @override
  String get databaseArchiveIncludesConfigs =>
      'This archive also includes user configs, which the restore imports.';

  @override
  String get databaseSchemaVersion => 'Schema version';

  @override
  String get databaseAssociatedFiles => 'Associated files';

  @override
  String get databaseSize => 'Size';

  @override
  String databaseSchemaUpgraded(int version, int current) {
    return 'The replacement schema v$version is upgraded to v$current after restore.';
  }

  @override
  String databaseSchemaNewer(int version) {
    return 'The replacement schema v$version is newer than this app.';
  }

  @override
  String get databaseTableProjects => 'Projects';

  @override
  String get databaseTablePersonnel => 'Personnel';

  @override
  String get databaseTableTaxa => 'Taxa';

  @override
  String get databaseTableSites => 'Sites';

  @override
  String get databaseTableCollectionEvents => 'Collection events';

  @override
  String get databaseTableSpecimens => 'Specimens';

  @override
  String get databaseTableNarratives => 'Narratives';

  @override
  String get databaseTableMediaRecords => 'Media records';

  @override
  String get databaseIssueNotNahpu =>
      'This file is not a NAHPU database. Choose a NAHPU backup archive or database file.';

  @override
  String get databaseIssueNewerSchema =>
      'This database was made by a newer version of NAHPU. Update NAHPU, then restore it.';

  @override
  String get databaseIssueUnreadable =>
      'This database could not be read. The file may be damaged.';

  @override
  String get databaseColumnCurrent => 'Current';

  @override
  String get databaseColumnReplacement => 'Replacement';

  @override
  String get databaseColumnChange => 'Change';

  @override
  String get databaseRestoring => 'Restoring database';

  @override
  String get databaseRestoreHint =>
      'Restoring a backup with many photos can take several minutes. Keep NAHPU open until this finishes.';

  @override
  String get databaseChooseDatabase => 'Choose database';

  @override
  String get databaseChooseDatabaseBody =>
      'This archive contains multiple database files at its root. Choose the database to restore.';

  @override
  String get databaseConfirmWithBackup =>
      'A full backup of your current data is saved first. Continue?';

  @override
  String get databaseConfirmWithoutBackup =>
      'No backup will be made, so your current data cannot be recovered. Continue?';

  @override
  String get databaseReplaceSuccess => 'Success 🎉';

  @override
  String get databaseReplaced => 'Database has been replaced!';

  @override
  String get databaseBackupFilePath => 'Backup file path:';

  @override
  String get databaseBackToHome => 'Back to Home';

  @override
  String databaseIosBackupPath(
    String appDir,
    String backupDir,
    String fileName,
  ) {
    return 'Files app/On my Devices/$appDir/$backupDir/$fileName';
  }

  @override
  String get transferCustomFieldsQrTitle => 'Custom fields QR code';

  @override
  String transferCustomFieldsQrDescription(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Scan this code from another NAHPU device to import $count custom field definitions.',
      one:
          'Scan this code from another NAHPU device to import 1 custom field definition.',
    );
    return '$_temp0';
  }

  @override
  String get transferExportCustomFields => 'Export custom fields';

  @override
  String get transferShowQr => 'Show QR';

  @override
  String get transferExportFile => 'Export file';

  @override
  String get transferNoCustomFields =>
      'No custom fields are available to export.';

  @override
  String transferSelectedCount(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String get transferScopeGlobal => 'Global';

  @override
  String get transferScopeCurrentProject => 'Current project';

  @override
  String get transferArchived => 'Archived';

  @override
  String get transferImportCustomFields => 'Import custom fields';

  @override
  String transferReusableDefinitions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reusable definitions',
      one: '1 reusable definition',
    );
    return '$_temp0';
  }

  @override
  String get transferDestination => 'Destination';

  @override
  String get transferCustomFieldImportNote =>
      'Definitions are preflighted before import. Matching template IDs are updated safely; unrelated fields remain unchanged.';

  @override
  String get transferImportSelectedConfigs => 'Import selected configs';

  @override
  String get transferWillImport => 'Will import';

  @override
  String get transferImportSelectedConfigsConfirm => 'Import selected configs?';

  @override
  String get transferConfigsImported => 'Selected user configs were imported.';

  @override
  String get transferImportConfirmationBody =>
      'The selected groups will be replaced. Custom fields are matched by template ID and merged, so existing definitions are kept. Unselected groups remain unchanged.';

  @override
  String get transferCustomFieldDestination => 'Custom field destination';

  @override
  String get transferSectionUserConfigs =>
      'Controlled vocabularies and settings';

  @override
  String get transferSectionRecordExportPresets => 'Tabular export presets';

  @override
  String get transferSectionTemplatePresets => 'Document templates';

  @override
  String get transferSectionDocumentLayouts => 'Document layout presets';

  @override
  String get transferSectionTemplateTablePreview =>
      'Template table preview columns';

  @override
  String get transferSectionCustomFields => 'Custom fields';

  @override
  String get transferConfigSections => 'Config sections';

  @override
  String get transferChooseFileToPreview =>
      'Choose a user-config file to preview its contents.';

  @override
  String get transferSelectAtLeastOneSection =>
      'Select at least one config section.';

  @override
  String transferEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String get transferNoSavedEntries => 'No saved entries';

  @override
  String get transferOtherSettings => 'Other settings';

  @override
  String get transferNoItems => 'No items';

  @override
  String transferMappingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mappings',
      one: '1 mapping',
    );
    return '$_temp0';
  }

  @override
  String get transferIncompatiblePreset => 'Incompatible preset';

  @override
  String transferBlockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blocks',
      one: '1 block',
    );
    return '$_temp0';
  }

  @override
  String get setupReviewSetup => 'Review setup';

  @override
  String get setupSkipSetup => 'Skip setup';

  @override
  String get setupStepWelcome => 'Welcome';

  @override
  String get setupCatalogFormat => 'Catalog format';

  @override
  String get setupIdentifiers => 'Identifiers';

  @override
  String get setupStepSites => 'Sites';

  @override
  String get setupStepEvents => 'Events';

  @override
  String get setupStepSpecimens => 'Specimens';

  @override
  String get setupParasites => 'Parasites';

  @override
  String get setupExportPresets => 'Export presets';

  @override
  String get setupStepFinish => 'Finish';

  @override
  String get setupWelcomeTitle => 'Set up NAHPU';

  @override
  String get setupWelcomeMessage =>
      'NAHPU records specimens using your own conventions. This sets the catalog number format, and the controlled vocabularies for sites, events, and specimens.';

  @override
  String get setupWelcomeCatalogFormat => 'The taxon group you catalog.';

  @override
  String get setupWelcomeIdentifiers =>
      'How field numbers and tissue numbers are formed.';

  @override
  String get setupControlledVocabularies => 'Controlled vocabularies';

  @override
  String get setupWelcomeVocabularies =>
      'The vocabularies for sites, events, and specimens.';

  @override
  String get setupWelcomeExportPresets =>
      'Bundled print layouts and tabular presets for exports.';

  @override
  String get setupWelcomeNotPermanent =>
      'This takes a few minutes and nothing here is permanent. Every answer can be changed later in Settings, or by running this wizard again.';

  @override
  String get setupImportTitle => 'Already have settings from your team?';

  @override
  String get setupImportMessage =>
      'A team only needs to set this up once. If your team has already configured NAHPU, import their user configs file and you can skip the rest of this wizard. You can export yours for everyone else at the end.';

  @override
  String get setupCatalogFormatMessage =>
      'The format decides which measurement fields appear on specimen records.';

  @override
  String get setupCatalogFormatNote =>
      'You can change the catalog format at any time, and a single project can hold records in more than one format. Pick the format you will use most often.';

  @override
  String setupCatalogFormatLoadError(String error) {
    return 'Unable to load catalog format: $error';
  }

  @override
  String get setupFieldIdsTitle => 'Specimen field IDs';

  @override
  String get setupFieldIdsMessage =>
      'Choose your field ID strategy. You will complete ID setup when creating a new project.';

  @override
  String get setupIdentifiersNote =>
      'These identifier settings can be changed for a different project. You can set them under Settings > Catalogs.';

  @override
  String get setupTissueIdsTitle => 'Tissue IDs';

  @override
  String get setupTissueIdsMessage =>
      'Some collections number tissues separately from the specimen. Set here if your collection uses it. NAHPU automatically uses the specimen field id as default if you don\'t set tissue id.';

  @override
  String get setupUseSeparateTissueId => 'Use a separate tissue ID';

  @override
  String get setupNextTissueId => 'Next tissue ID';

  @override
  String get setupSitesTitle => 'Site vocabularies';

  @override
  String get setupSitesMessage =>
      'The controlled vocabularies for site and coordinate forms. Add your own terms, remove any you will not use, or leave the defaults alone. You can update these lists later in the Settings > Sites.';

  @override
  String get setupSiteTypes => 'Site types';

  @override
  String get setupHabitatTypes => 'Habitat types';

  @override
  String get setupDatums => 'Datums';

  @override
  String get setupEventsTitle => 'Collecting event vocabularies';

  @override
  String get setupEventsMessage =>
      'The controlled vocabularies for collecting events. You can update these lists later in the Settings > Events.';

  @override
  String get setupPrimaryActivities => 'Primary activities';

  @override
  String get setupCollectionMethods => 'Collection methods';

  @override
  String get setupPersonnelRoles => 'Personnel roles';

  @override
  String get setupSpecimensTitle => 'Specimen vocabularies';

  @override
  String get setupSpecimensMessage =>
      'The controlled vocabularies for specimen records. You can update these lists later in the Settings > Specimens.';

  @override
  String get setupIdentificationMethods => 'Identification methods';

  @override
  String get setupLifeStages => 'Life stages';

  @override
  String get setupSpecimenTypes => 'Specimen types';

  @override
  String get setupTreatments => 'Treatments';

  @override
  String get setupConditions => 'Conditions';

  @override
  String get setupParasitesMessage =>
      'NAHPU features a separate parasite form to associate parasite records with specimens. The toggle below allows you to setup controlled vocabularies for parasite records.';

  @override
  String get setupCollectsParasites => 'I will collect parasites';

  @override
  String get setupParasiteCategories => 'Categories';

  @override
  String get setupDetectionMethods => 'Detection methods';

  @override
  String get setupPreparationMethods => 'Preparation methods';

  @override
  String get setupAnatomicalLocations => 'Anatomical locations';

  @override
  String get setupStorage => 'Storage';

  @override
  String get setupFinishTitle => 'You are set up';

  @override
  String get setupFinishMessage =>
      'NAHPU will use these conventions for new records.';

  @override
  String get setupNotSet => 'Not set';

  @override
  String get setupFieldId => 'Field ID';

  @override
  String get setupProjectId => 'Project ID';

  @override
  String get setupPersonnelId => 'Personnel ID';

  @override
  String get setupTissueId => 'Tissue ID';

  @override
  String get setupTissueNumberedSeparately => 'Numbered separately';

  @override
  String get setupTissueFollowsSpecimen => 'Follows the specimen';

  @override
  String get setupParasitesCollected => 'Collected';

  @override
  String get setupParasitesNotCollected => 'Not collected';

  @override
  String get setupShareTitle => 'Share this setup with your team';

  @override
  String get setupShareMessage =>
      'Your team only needs to do this once. Export these user configs and share with your team members/collaborators to ensure everyone works with the same vocabularies and settings.';

  @override
  String get setupFinishNote =>
      'Nothing here is locked in. Change any individual setting under Settings, or run Setup NAHPU again from the menu.';

  @override
  String get setupExportPresetsMessage =>
      'These are default presets for exporting records. Print layouts will be used for labels, tags, and field booklets. Tabular presets will be used for spreadsheets. You can manage or create your own presets in the Settings menu.';

  @override
  String get setupPresetDefaults => 'Defaults';

  @override
  String get setupPresetDefaultsMessage =>
      'Presets that suit any catalog format.';

  @override
  String setupPresetsForFormat(String catalogFormat) {
    return 'For $catalogFormat';
  }

  @override
  String get setupPresetsForFormatMessage =>
      'Optional presets written for this catalog format.';

  @override
  String get setupAddSelectedPresets => 'Add selected presets';

  @override
  String setupBundledPresetsLoadError(String error) {
    return 'Unable to load bundled presets: $error';
  }

  @override
  String setupAddPresetsError(String error) {
    return 'Failed to add presets: $error';
  }

  @override
  String setupExportPresetCounts(int documentCount, int tabularCount) {
    return '$documentCount document, $tabularCount tabular';
  }

  @override
  String get commonClose => 'Close';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonSelect => 'Select';

  @override
  String get presetsTemplateDeleteTitle => 'Delete template';

  @override
  String presetsDeleteNamePrompt(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get presetsTemplateUnusedDelete =>
      'This template is unused and will be permanently removed.';

  @override
  String presetsTemplateInUse(int blockCount, int layoutCount) {
    String _temp0 = intl.Intl.pluralLogic(
      blockCount,
      locale: localeName,
      other: '$blockCount blocks',
      one: '1 block',
    );
    String _temp1 = intl.Intl.pluralLogic(
      layoutCount,
      locale: localeName,
      other: '$layoutCount print layouts',
      one: '1 print layout',
    );
    return 'This template is used by $_temp0 in $_temp1. Choose a replacement before deleting it.';
  }

  @override
  String presetsTemplateUsageBlocks(
    String layoutName,
    int count,
    String blocks,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'blocks',
      one: 'block',
    );
    return '$layoutName: $_temp0 $blocks';
  }

  @override
  String get presetsTemplateNoReplacement =>
      'Create another template with the same record type, or change the affected layout blocks before deleting this one.';

  @override
  String get presetsTemplateReplacement => 'Replacement template';

  @override
  String get presetsTemplateReplacementNote =>
      'Page size, margins, grid, and padding will stay unchanged. Review the affected print layouts after replacement.';

  @override
  String get presetsTemplateEmpty =>
      'No templates yet. Templates define the content placed in print-layout blocks.';

  @override
  String get presetsTemplateNoMatch => 'No templates match your search.';

  @override
  String get presetsTemplateNoneToExport => 'No templates to export';

  @override
  String get presetsTemplateExportTitle => 'Export templates';

  @override
  String presetsTemplateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count templates',
      one: '1 template',
    );
    return '$_temp0';
  }

  @override
  String presetsTemplateInvalidFile(String error) {
    return 'Invalid template file: $error';
  }

  @override
  String presetsTemplateImportFailed(String error) {
    return 'Failed to import templates: $error';
  }

  @override
  String presetsTemplateImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count templates',
      one: 'Imported 1 template',
    );
    return '$_temp0';
  }

  @override
  String presetsTemplateImportedPartial(int imported, int offered, int limit) {
    return 'Imported $imported of $offered templates (limit $limit)';
  }

  @override
  String presetsTemplateLoadError(String error) {
    return 'Unable to load templates: $error';
  }

  @override
  String presetsTemplateDeleted(String name) {
    return 'Deleted \"$name\"';
  }

  @override
  String presetsTemplateDeletedUpdated(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blocks',
      one: '1 block',
    );
    return 'Deleted \"$name\" and updated $_temp0';
  }

  @override
  String presetsTemplateDeleteError(String error) {
    return 'Could not delete template: $error';
  }

  @override
  String get presetsTemplateSearchHint => 'Search templates';

  @override
  String get presetsUnused => 'Unused';

  @override
  String presetsTemplateLayoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count layouts',
      one: '1 layout',
    );
    return '$_temp0';
  }

  @override
  String get presetsTemplateOptions => 'Template options';

  @override
  String get presetsRecordTypeSpecimen => 'Specimen';

  @override
  String get presetsRecordTypeSite => 'Site';

  @override
  String get presetsRecordTypeCollEvent => 'Collecting event';

  @override
  String get presetsRecordTypeNarrative => 'Narrative';

  @override
  String get presetsRecordTypeSpecimenParts => 'Specimen parts';

  @override
  String get presetsRecordTypeNone => 'No records';

  @override
  String presetsFontReadError(String error) {
    return 'Unable to read fonts: $error';
  }

  @override
  String get presetsFonts => 'Fonts';

  @override
  String presetsFontInstalled(String family) {
    return 'Installed $family';
  }

  @override
  String presetsFontInstallError(String error) {
    return 'Unable to install font: $error';
  }

  @override
  String presetsFontInUseTitle(String family) {
    return '$family is in use';
  }

  @override
  String presetsFontInUseBody(int count, String templates) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'these templates',
      one: 'this template',
    );
    return 'Remove or change this font in $_temp0 before deleting it:\n\n$templates';
  }

  @override
  String presetsFontDeleteTitle(String family) {
    return 'Delete $family?';
  }

  @override
  String get presetsFontDeleteBody =>
      'The font files are removed from this installation. Templates that use it elsewhere are not changed.';

  @override
  String get presetsFontSearch => 'Search fonts';

  @override
  String get presetsFontInstall => 'Install font';

  @override
  String get presetsFontFind => 'Find fonts';

  @override
  String get presetsFontLicenseNote =>
      'Download a font in your browser, then install the .ttf or .otf file here. You are responsible for the license of any font you install.';

  @override
  String get presetsFontNoMatch => 'No fonts match your search';

  @override
  String get presetsFontInstalledByYou => 'Installed by you';

  @override
  String get presetsFontBundledWithNahpu => 'Bundled with NAHPU';

  @override
  String presetsFontFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '1 file',
    );
    return '$_temp0';
  }

  @override
  String presetsFontUsedByCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Used by $count templates',
      one: 'Used by 1 template',
    );
    return '$_temp0';
  }

  @override
  String get presetsFontDelete => 'Delete font';

  @override
  String get presetsFontSelectToPreview => 'Select a font to preview it';

  @override
  String get presetsFontBundled => 'Bundled';

  @override
  String get presetsFontInstalledLabel => 'Installed';

  @override
  String presetsFontUsedBy(String templates) {
    return 'Used by $templates';
  }

  @override
  String get presetsFontSize => 'Size';

  @override
  String presetsMaxReached(int max) {
    return 'Maximum of $max presets reached.';
  }

  @override
  String presetsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count presets',
      one: 'Imported 1 preset',
    );
    return '$_temp0';
  }

  @override
  String presetsImportFailed(String error) {
    return 'Failed to import presets: $error';
  }

  @override
  String get presetsNoneToExport => 'No presets to export';

  @override
  String get presetsExportTabularTitle => 'Export tabular presets';

  @override
  String presetsTabularCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tabular presets',
      one: '1 tabular preset',
    );
    return '$_temp0';
  }

  @override
  String presetsExportFailed(String error) {
    return 'Failed to export presets: $error';
  }

  @override
  String get presetsTabularTitle => 'Tabular Export Presets';

  @override
  String get presetsTabPresets => 'Presets';

  @override
  String get presetsTabEditPreset => 'Edit Preset';

  @override
  String get presetsSelectPresets => 'Select Presets';

  @override
  String get presetsTabularEmpty =>
      'No tabular presets yet. Create or import one, or add the presets for your catalog format in Setup NAHPU.';

  @override
  String presetsMappingSummary(int count, String recordType) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mappings',
      one: '1 mapping',
    );
    return '$_temp0 · $recordType';
  }

  @override
  String get presetsExportThisPreset => 'Export this preset';

  @override
  String presetsErrorDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get presetsDeletePresetTitle => 'Delete Preset';

  @override
  String presetsDeletePresetConfirm(String name) {
    return 'Are you sure you want to delete the preset \"$name\"?';
  }

  @override
  String get presetsSelectToEdit => 'Select a preset to edit';

  @override
  String get presetsNotFound => 'Preset not found';

  @override
  String get presetsLoadError => 'Error loading preset';

  @override
  String get presetsNewPreset => 'New Preset';

  @override
  String get presetsName => 'Preset Name';

  @override
  String get presetsNameExists => 'A preset with this name already exists';

  @override
  String get presetsNameEmpty => 'Name cannot be empty';

  @override
  String get presetsNameInvalidChars =>
      'Only alphanumeric, underscores, and dashes allowed';

  @override
  String get presetsPreviewEmptyTitle => 'No Preview Data';

  @override
  String get presetsPreviewEmptyBody =>
      'No records matched the selected filters, or mappings are empty.';

  @override
  String presetsPreviewFailed(String error) {
    return 'Failed to generate preview: $error';
  }

  @override
  String presetsSaveError(String error) {
    return 'Couldn\'t save: $error';
  }

  @override
  String get presetsNameRequired => 'Preset name cannot be empty.';

  @override
  String presetsNameTaken(String name) {
    return 'A preset named \"$name\" already exists.';
  }

  @override
  String presetsUpdateError(String error) {
    return 'Couldn\'t update: $error';
  }

  @override
  String get presetsDuplicateTitle => 'Duplicate preset';

  @override
  String presetsDuplicateError(String error) {
    return 'Couldn\'t duplicate: $error';
  }

  @override
  String presetsEditTitle(String name) {
    return 'Edit $name';
  }

  @override
  String get presetsEditFields => 'Edit Fields';

  @override
  String get presetsPreviewExportTable => 'Preview Export Table';

  @override
  String get presetsSaving => 'Saving…';

  @override
  String get presetsSavedAutomatically => 'Saved automatically';

  @override
  String get presetsRecordType => 'Record type';

  @override
  String get presetsSpecimenTaxonGroup => 'Specimen taxon group';

  @override
  String get presetsHeaderFormat => 'Generated header format';

  @override
  String get presetsHeaderNahpuNamespace =>
      'NAHPU namespace (nahpu:table.field)';

  @override
  String presetsPreviewSites(int count) {
    return 'Preview Sites ($count selected)';
  }

  @override
  String presetsPreviewEvents(int count) {
    return 'Preview Events ($count selected)';
  }

  @override
  String presetsPreviewNarratives(int count) {
    return 'Preview Narratives ($count selected)';
  }

  @override
  String presetsPreviewSpecimenParts(int count) {
    return 'Preview Specimen Parts ($count selected)';
  }

  @override
  String presetsPreviewSpecimens(int count) {
    return 'Preview Specimens ($count selected)';
  }

  @override
  String get presetsPreviewCurrentProject => 'Current Project (None)';

  @override
  String get presetsDocumentTitle => 'Document Presets';

  @override
  String get presetsPrintLayouts => 'Print layouts';

  @override
  String get presetsTemplates => 'Templates';

  @override
  String get presetsDocumentNew => 'New document preset';

  @override
  String presetsRenamed(String name) {
    return 'Renamed to $name';
  }

  @override
  String presetsRenameFailed(String error) {
    return 'Rename failed: $error';
  }

  @override
  String get presetsExportPrintLayoutsTitle => 'Export print layouts';

  @override
  String presetsPrintLayoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count print layouts',
      one: '1 print layout',
    );
    return '$_temp0';
  }

  @override
  String presetsDocumentInvalidFile(String error) {
    return 'Invalid document layout file: $error';
  }

  @override
  String get presetsDocumentEmpty =>
      'No print layouts yet. Create or import one, or load the default layouts.';

  @override
  String get presetsIncompatible => 'Incompatible preset';

  @override
  String get presetsIncompatibleBody =>
      'This preset is not compatible with the current version.';

  @override
  String get presetsPreviewNoRecords => 'No preview records for this type';

  @override
  String get presetsPreviewSelectSpecimenParts =>
      'Select specimen parts for preview';

  @override
  String get presetsPreviewSelectSpecimens => 'Select specimens for preview';

  @override
  String get presetsTableColumns => 'Table columns';

  @override
  String get commonApply => 'Apply';

  @override
  String get exportFieldsTitle => 'Edit Preset Mappings';

  @override
  String get exportFieldsAvailableFields => 'Available Fields';

  @override
  String get exportFieldsSelectedMappings => 'Selected Mappings';

  @override
  String get exportFieldsNoPreviewTitle => 'No Preview Data';

  @override
  String get exportFieldsNoPreviewBody =>
      'No records matched the selected filters, or mappings are empty.';

  @override
  String exportFieldsPreviewFailed(String error) {
    return 'Failed to generate preview: $error';
  }

  @override
  String get exportFieldsInsertSourceField => 'Insert Source Field';

  @override
  String get exportFieldsDisplayTableField => 'Table::Field';

  @override
  String get exportFieldsDisplayFieldOnly => 'Field Only';

  @override
  String get exportFieldsOtherFields => 'Other fields';

  @override
  String get exportFieldsSelectField => 'Select field';

  @override
  String get exportFieldsChooseField => 'Choose a field';

  @override
  String get exportFieldsCloseFieldPicker => 'Close field picker';

  @override
  String get exportFieldsSearchFields => 'Search fields or tables';

  @override
  String get exportFieldsNoMatchingFields => 'No matching fields.';

  @override
  String get exportFieldsAddCustomField => 'Add custom field';

  @override
  String get exportFieldsAddNested => 'Add nested';

  @override
  String get exportFieldsUnnamed => 'Unnamed';

  @override
  String exportFieldsCardNested(String name) {
    return 'Nested: $name';
  }

  @override
  String exportFieldsCardList(String name) {
    return 'List: $name';
  }

  @override
  String exportFieldsCardField(String name) {
    return 'Field: $name';
  }

  @override
  String exportFieldsCardCustom(String name) {
    return 'Custom: $name';
  }

  @override
  String exportFieldsCardIndexedColumns(String style) {
    return 'Indexed columns · $style';
  }

  @override
  String get exportFieldsCardDarwinCoreSeparator =>
      'One column · Darwin Core \" | \" separator';

  @override
  String exportFieldsCardSeparator(String separator) {
    return 'One column · $separator separator';
  }

  @override
  String exportFieldsCardFormat(String format, String options) {
    return 'Format: $format · Options: $options';
  }

  @override
  String get exportFieldsCustomize => 'Customize';

  @override
  String get exportFieldsOneColumn => 'One column';

  @override
  String get exportFieldsIndexedColumns => 'Indexed columns';

  @override
  String get exportFieldsRepeatedRows => 'Repeated rows';

  @override
  String get exportFieldsFormatConditionalBrackets => 'conditional brackets';

  @override
  String get exportFieldsFormatConditionalField => 'conditional field';

  @override
  String get exportFieldsFormatConditionalValue => 'conditional value';

  @override
  String get exportFieldsMappingType => 'Mapping type';

  @override
  String get exportFieldsKindSingle => 'Single field';

  @override
  String get exportFieldsKindCustom => 'Custom field';

  @override
  String get exportFieldsKindList => 'List field';

  @override
  String get exportFieldsKindNested => 'Nested records';

  @override
  String get exportFieldsSourceField => 'Source field';

  @override
  String get exportFieldsSourceFieldHelper =>
      'Choose the NAHPU field that supplies this column.';

  @override
  String get exportFieldsColumnNameOptional => 'Column name (optional)';

  @override
  String get exportFieldsColumnNameOptionalHelper =>
      'Leave blank to use the source field name.';

  @override
  String get exportFieldsListOutput => 'List output';

  @override
  String exportFieldsExample(String example) {
    return 'Example: $example';
  }

  @override
  String get exportFieldsDarwinCoreListSeparator =>
      'Darwin Core list values are separated with \" | \".';

  @override
  String get exportFieldsSeparator => 'Separator';

  @override
  String get exportFieldsSeparatorPipe => 'Pipe (A | B)';

  @override
  String get exportFieldsSeparatorComma => 'Comma (A, B)';

  @override
  String get exportFieldsSeparatorSemicolon => 'Semicolon (A; B)';

  @override
  String get exportFieldsSeparatorSlash => 'Slash (A / B)';

  @override
  String get exportFieldsSeparatorNewLine => 'New line';

  @override
  String get exportFieldsSeparatorBulleted => 'Bulleted';

  @override
  String get exportFieldsSeparatorCustom => 'Custom';

  @override
  String get exportFieldsCustomSeparator => 'Custom separator';

  @override
  String get exportFieldsValueFormat => 'Value format';

  @override
  String get exportFieldsValueNormal => 'Normal text';

  @override
  String get exportFieldsValueEncoded => 'Encoded text';

  @override
  String get exportFieldsValueCoordinates => 'Coordinates';

  @override
  String get exportFieldsValueConditionalBrackets => 'Conditional brackets';

  @override
  String get exportFieldsValueConditionalField => 'Conditional field';

  @override
  String get exportFieldsValueConditionalValue => 'Conditional value';

  @override
  String get exportFieldsReplacementText => 'Replacement text';

  @override
  String get exportFieldsReplacementTextHelper =>
      'Written when the condition matches; otherwise the original value is kept.';

  @override
  String get exportFieldsColumnName => 'Column name';

  @override
  String get exportFieldsColumnNameHelper =>
      'Name the output column containing the custom value.';

  @override
  String get exportFieldsRelatedRecords => 'Related records';

  @override
  String get exportFieldsRelatedRecordsHelper =>
      'Select the repeated record group to export.';

  @override
  String get exportFieldsSelectedChildFields => 'Selected child fields';

  @override
  String get exportFieldsSelectChildFieldHint =>
      'Select at least one child field below.';

  @override
  String get exportFieldsMoveUp => 'Move up';

  @override
  String get exportFieldsMoveDown => 'Move down';

  @override
  String get exportFieldsRemoveField => 'Remove field';

  @override
  String get exportFieldsChooseChildFields => 'Choose child fields';

  @override
  String get exportFieldsColumnPrefixOptional => 'Column prefix (optional)';

  @override
  String get exportFieldsNestedOutput => 'Nested output';

  @override
  String get exportFieldsNestedOneColumnHint =>
      'Combine all child records into one cell.';

  @override
  String get exportFieldsNestedIndexedHint =>
      'Create a group of columns for each record.';

  @override
  String get exportFieldsNestedRepeatedHint =>
      'Create one export row per child record.';

  @override
  String get exportFieldsNestedRepeatedTaken =>
      'Another mapping already expands export rows.';

  @override
  String get exportFieldsFieldSeparator => 'Field separator';

  @override
  String get exportFieldsRecordSeparator => 'Record separator';

  @override
  String get exportFieldsAdvanced => 'Advanced';

  @override
  String get exportFieldsRawExpression => 'Raw source expression';

  @override
  String get exportFieldsRawFormatOption => 'Raw format option';

  @override
  String get exportFieldsRawFormatOptionHelper =>
      'For example: enum, dms, or custom_map:0=No.';

  @override
  String get exportFieldsEmptyValue => 'Empty value';

  @override
  String get exportFieldsEmptyBlank => 'Blank';

  @override
  String get exportFieldsEmptyCustomText => 'Custom text';

  @override
  String get exportFieldsCustomEmptyText => 'Custom empty text';

  @override
  String get exportFieldsRawNamespace => 'Raw related-record namespace';

  @override
  String exportFieldsErrorReplacement(int number, String error) {
    return 'Replacement $number: $error';
  }

  @override
  String get exportFieldsErrorChooseGroup => 'Choose a related-record group.';

  @override
  String get exportFieldsErrorChooseChild => 'Choose at least one child field.';

  @override
  String get exportFieldsErrorSeparatorsEmpty =>
      'Field and record separators cannot be empty.';

  @override
  String get exportFieldsErrorMultiFieldHeader =>
      'Set a custom header for a multi-field concatenated mapping.';

  @override
  String get exportFieldsErrorAddSegment =>
      'Add at least one field or text segment.';

  @override
  String get exportFieldsErrorChooseSource => 'Choose a source field.';

  @override
  String get exportFieldsErrorCompositeHeader =>
      'Set a custom header for a composite mapping.';

  @override
  String get exportFieldsErrorIndexedSingleSource =>
      'Indexed lists require exactly one source field.';

  @override
  String get exportFieldsErrorConditionalSingleSource =>
      'Conditional output requires exactly one source field.';

  @override
  String get exportFieldsErrorAddCondition => 'Add at least one condition.';

  @override
  String get exportFieldsErrorReplacementText => 'Enter replacement text.';

  @override
  String get exportFieldsErrorControllingField =>
      'Choose a controlling field for every bracket condition.';

  @override
  String get exportFieldsErrorComparisonValue =>
      'Enter a comparison value for every bracket condition.';

  @override
  String get exportFieldsErrorSelfDependency =>
      'A conditional field cannot depend on itself.';

  @override
  String get exportFieldsCustomValue => 'Custom value';

  @override
  String get exportFieldsCustomValueHelp =>
      'Fields and text are emitted left to right. Add as many segments as needed.';

  @override
  String get exportFieldsCustomValueEmpty => 'Add a field or text to begin.';

  @override
  String get exportFieldsTextOrSeparator => 'Text or separator';

  @override
  String get exportFieldsShowLabel => 'Show label';

  @override
  String get exportFieldsEditConditionalText => 'Edit conditional text';

  @override
  String get exportFieldsMoveSegmentUp => 'Move segment up';

  @override
  String get exportFieldsMoveSegmentDown => 'Move segment down';

  @override
  String get exportFieldsRemoveSegment => 'Remove segment';

  @override
  String get exportFieldsAddField => 'Add field';

  @override
  String get exportFieldsAddText => 'Add text';

  @override
  String get exportFieldsAddConditionalText => 'Add conditional text';

  @override
  String exportFieldsExpression(String expression) {
    return 'Expression: $expression';
  }

  @override
  String get exportFieldsAddSourceField => 'Add source field';

  @override
  String get exportFieldsConditionalText => 'Conditional text';

  @override
  String get exportFieldsTextWhenMatched => 'Text when matched';

  @override
  String exportFieldsTextWhenMatchedHelper(String example) {
    return 'Fields such as $example are filled in.';
  }

  @override
  String get exportFieldsTextOtherwise => 'Text otherwise (optional)';

  @override
  String get exportFieldsTextOtherwiseHelper =>
      'Leave it empty to write nothing.';

  @override
  String get exportFieldsSummaryOr => 'or';

  @override
  String get exportFieldsSummaryAnd => 'and';

  @override
  String exportFieldsSummaryIf(String conditions, String text) {
    return 'If $conditions → \"$text\"';
  }

  @override
  String exportFieldsSummaryIfOtherwise(
    String conditions,
    String text,
    String otherwise,
  ) {
    return 'If $conditions → \"$text\", otherwise \"$otherwise\"';
  }

  @override
  String exportFieldsSummaryEquals(String field, String value) {
    return '$field equals \"$value\"';
  }

  @override
  String exportFieldsSummaryNotEquals(String field, String value) {
    return '$field does not equal \"$value\"';
  }

  @override
  String exportFieldsSummaryContains(String field, String value) {
    return '$field contains \"$value\"';
  }

  @override
  String exportFieldsSummaryIsNotEmpty(String field) {
    return '$field is not empty';
  }

  @override
  String exportFieldsSummaryIsEmpty(String field) {
    return '$field is empty';
  }

  @override
  String get exportFieldsValueConditions => 'Value conditions';

  @override
  String get exportFieldsFieldConditions => 'Field conditions';

  @override
  String get exportFieldsConditionsHelp =>
      'Compare raw stored values. Blank controlling values never match.';

  @override
  String get exportFieldsMatchLogic => 'Match logic';

  @override
  String get exportFieldsMatchAny => 'Any condition (OR)';

  @override
  String get exportFieldsMatchAll => 'All conditions (AND)';

  @override
  String get exportFieldsAddCondition => 'Add condition';

  @override
  String get exportFieldsControllingField => 'Controlling field';

  @override
  String get exportFieldsOperatorEquals => 'Equals';

  @override
  String get exportFieldsOperatorNotEquals => 'Does not equal';

  @override
  String get exportFieldsOperatorContains => 'Contains';

  @override
  String get exportFieldsOperatorIsNotEmpty => 'Is not empty';

  @override
  String get exportFieldsOperatorIsEmpty => 'Is empty';

  @override
  String get exportFieldsValue => 'Value';

  @override
  String get exportFieldsRemoveCondition => 'Remove condition';

  @override
  String get exportFieldsIndexedColumnNames => 'Indexed column names';

  @override
  String exportFieldsIndexedUnderscore(String example) {
    return 'Underscore: $example';
  }

  @override
  String exportFieldsIndexedCompact(String example) {
    return 'Compact: $example';
  }

  @override
  String exportFieldsIndexedBrackets(String example) {
    return 'Brackets: $example';
  }

  @override
  String get exportFieldsOutputExample => 'Output example';

  @override
  String get exportFieldsOutputExampleEmpty =>
      'Complete the mapping to see its output shape.';

  @override
  String get exportFieldsOutputExampleRows =>
      'Each child record creates another export row.';

  @override
  String get exportFieldsCustomizeNested => 'Customize Nested Mapping';

  @override
  String get exportFieldsCustomizeField => 'Customize Field Mapping';

  @override
  String get exportFieldsPreviewTitle => 'Export Preview';

  @override
  String exportFieldsPreviewShowing(int shown, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Showing $shown of $total records',
      one: 'Showing $shown of 1 record',
    );
    return '$_temp0';
  }

  @override
  String get commonSave => 'Save';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get formsChooseOne => 'Choose one';

  @override
  String formsErrorDetail(String error) {
    return 'Error: $error';
  }

  @override
  String formsAddValue(String type) {
    return 'Add $type';
  }

  @override
  String formsEnterValue(String type) {
    return 'Enter $type';
  }

  @override
  String get formsMatchDatabase => 'Match database';

  @override
  String formsMatchDatabaseTitle(String plural) {
    return 'Match database $plural?';
  }

  @override
  String get formsMatchAppendMissing => 'Append missing';

  @override
  String get formsMatchOverrideAll => 'Override all';

  @override
  String get formsMatchHelp =>
      'Use this when records arrive from someone whose controlled vocabularies you do not have.';

  @override
  String formsMatchAppendDescription(String plural) {
    return 'Add values found in the database without changing your existing $plural.';
  }

  @override
  String formsMatchOverrideDescription(String plural) {
    return 'Replace all configured $plural with the values currently found in the database.';
  }

  @override
  String get formsVocabSiteType => 'site type';

  @override
  String get formsVocabSiteTypePlural => 'site types';

  @override
  String get formsVocabHabitatType => 'habitat type';

  @override
  String get formsVocabHabitatTypePlural => 'habitat types';

  @override
  String get formsVocabDatum => 'datum';

  @override
  String get formsVocabDatumPlural => 'datums';

  @override
  String get formsVocabPrimaryActivity => 'primary activity';

  @override
  String get formsVocabPrimaryActivityPlural => 'primary activities';

  @override
  String get formsVocabCollectionMethod => 'collection method';

  @override
  String get formsVocabCollectionMethodPlural => 'collection methods';

  @override
  String get formsVocabPersonnelRole => 'personnel role';

  @override
  String get formsVocabPersonnelRolePlural => 'personnel roles';

  @override
  String get formsVocabIdentificationMethod => 'identification method';

  @override
  String get formsVocabIdentificationMethodPlural => 'identification methods';

  @override
  String get formsVocabLifeStage => 'life stage';

  @override
  String get formsVocabLifeStagePlural => 'life stages';

  @override
  String get formsVocabSpecimenType => 'specimen type';

  @override
  String get formsVocabSpecimenTypePlural => 'specimen types';

  @override
  String get formsVocabTreatment => 'treatment';

  @override
  String get formsVocabTreatmentPlural => 'treatments';

  @override
  String get formsVocabCondition => 'condition';

  @override
  String get formsVocabConditionPlural => 'conditions';

  @override
  String get formsVocabParasiteCategory => 'category';

  @override
  String get formsVocabParasiteCategoryPlural => 'categories';

  @override
  String get formsVocabDetectionMethod => 'detection method';

  @override
  String get formsVocabDetectionMethodPlural => 'detection methods';

  @override
  String get formsVocabPreparationMethod => 'preparation method';

  @override
  String get formsVocabPreparationMethodPlural => 'preparation methods';

  @override
  String get formsVocabAnatomicalLocation => 'anatomical location';

  @override
  String get formsVocabAnatomicalLocationPlural => 'anatomical locations';

  @override
  String get formsVocabStorageValue => 'storage value';

  @override
  String get formsVocabStorageValuePlural => 'storage values';

  @override
  String get formsNextId => 'Next ID';

  @override
  String get formsNextNumber => 'Next number';

  @override
  String get formsNumberedIdNoPreview =>
      'Set a next number to auto-number · Leading zeros are kept';

  @override
  String formsNumberedIdPreview(String label, String preview) {
    return '$label: $preview · Leading zeros are kept';
  }

  @override
  String get formsBundledDocuments => 'Documents';

  @override
  String get formsBundledTabularRecords => 'Tabular records';

  @override
  String get formsBundledTemplates => 'Templates';

  @override
  String formsBundledAdded(String description) {
    return 'Added · $description';
  }

  @override
  String get formsDescriptionOptional => 'Description (optional)';

  @override
  String formsDescriptionTooLong(int max) {
    return 'Use $max characters or fewer.';
  }

  @override
  String get formsShowInfo => 'Show information';

  @override
  String get formsInfo => 'Info';

  @override
  String formsDeleteConfirmPrompt(String text) {
    return 'Type `$text` to enable delete';
  }

  @override
  String get formsDeleteConfirmHint => 'Enter confirmation text';

  @override
  String get formsSearchAll => 'All';

  @override
  String get formsSearchFieldNumber => 'Field number';

  @override
  String get formsSearchCataloger => 'Cataloger';

  @override
  String get formsSearchPreparator => 'Preparator';

  @override
  String get formsSearchCollector => 'Collector';

  @override
  String get formsSearchCondition => 'Condition';

  @override
  String get formsSearchPrepDate => 'Prep date';

  @override
  String get formsSearchPrepTime => 'Prep time';

  @override
  String get formsSearchTaxa => 'Taxa';

  @override
  String get formsSearchPrepType => 'Prep type';

  @override
  String get formsSiteId => 'Site ID';

  @override
  String get formsSiteIdHint => 'Enter a site';

  @override
  String get formsSiteName => 'Site name';

  @override
  String get formsPresetDuplicate => 'Duplicate';

  @override
  String get formsPresetName => 'Preset name';

  @override
  String get formsPresetUpdateHelper =>
      'Select Update to save the name and description';

  @override
  String get formsPresetUpdate => 'Update';

  @override
  String formsCustomFieldLoadError(String error) {
    return 'Unable to load custom fields: $error';
  }

  @override
  String get formsCustomFieldManage => 'Manage custom fields';

  @override
  String get formsEnterNumber => 'Enter a number';

  @override
  String get formsCustomFieldUnset => 'Unset';

  @override
  String formsCustomFieldArchivedOption(String label) {
    return '$label (archived)';
  }

  @override
  String sharedPresetCreateTooltip(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Create new template',
      'customField': 'Create new custom field',
      'other': 'Create new preset',
    });
    return '$_temp0';
  }

  @override
  String sharedPresetOptions(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Template options',
      'customField': 'Custom field options',
      'other': 'Preset options',
    });
    return '$_temp0';
  }

  @override
  String get sharedPresetCreateNew => 'Create new';

  @override
  String get sharedPresetScanQr => 'Scan QR';

  @override
  String sharedPresetExportSelected(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Export this template',
      'customField': 'Export this custom field',
      'other': 'Export this preset',
    });
    return '$_temp0';
  }

  @override
  String sharedPresetExportAll(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'template': 'Export all templates',
      'customField': 'Export all custom fields',
      'other': 'Export all presets',
    });
    return '$_temp0';
  }

  @override
  String get sharedLoadDefaults => 'Load defaults';

  @override
  String get sharedShowMore => 'Show more';

  @override
  String get sharedShowLess => 'Show less';

  @override
  String get sharedShare => 'Share';

  @override
  String get sharedUpdate => 'Update';

  @override
  String get sharedAdd => 'Add';

  @override
  String get sharedExportAs => 'Export as…';

  @override
  String get sharedFind => 'Find';

  @override
  String sharedDeleteSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count items',
      one: 'Delete 1 item',
    );
    return '$_temp0';
  }

  @override
  String get sharedDeleteSelectedTitle => 'Delete selected items';

  @override
  String get sharedDeleteSelectedBody =>
      'Are you sure you want to delete the selected items?';

  @override
  String get sharedTryAgain => 'Try again';

  @override
  String sharedExportTimeLeft(String duration) {
    return 'about $duration left';
  }

  @override
  String get sharedExportCancelling => 'Cancelling…';

  @override
  String sharedExportFilesOfTotal(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total files',
      one: '1 file',
    );
    return '$completed of $_temp0';
  }

  @override
  String sharedExportFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '1 file',
    );
    return '$_temp0';
  }

  @override
  String sharedExportBytesOfTotal(String processed, String total) {
    return '$processed of $total';
  }

  @override
  String sharedExportElapsed(String duration) {
    return '$duration elapsed';
  }

  @override
  String sharedExportUnitsOfTotal(int completed, int total) {
    return '$completed of $total';
  }

  @override
  String get sharedExportCancelledBody =>
      'No file was saved. Nothing on this device was changed.';

  @override
  String sharedExportStoppedAt(String step) {
    return 'Stopped while working on: $step';
  }

  @override
  String get sharedExportDidNotFinish => 'The export did not finish.';

  @override
  String get sharedExportCancelled => 'Export cancelled';

  @override
  String get sharedExportFailed => 'Export failed';

  @override
  String get sharedExportComplete => 'Export complete';

  @override
  String get sharedSaved => 'Saved';

  @override
  String get sharedHideSaveLocation => 'Hide save location';

  @override
  String get sharedExportTemporaryNote =>
      'Share this file now to keep it. NAHPU removes it when you export again.';

  @override
  String get sharedExportAppStorageNote =>
      'Saved in NAHPU app storage. Choose a folder next time to save straight to it.';

  @override
  String sharedExportFinishedIn(String duration) {
    return 'Finished in $duration';
  }

  @override
  String sharedExportSizeIn(String size, String duration) {
    return '$size in $duration';
  }

  @override
  String get sharedOpenDirectory => 'Open directory';

  @override
  String get sharedSaveToDevice => 'Save to device';

  @override
  String sharedSaveCopyTooLarge(String limit) {
    return 'Too large to save through the Files app, which is limited to $limit. Choose a folder before exporting to write files this size straight to your device.';
  }

  @override
  String get sharedQrExportImage => 'Export QR code as an image';

  @override
  String get sharedQrImageTooLarge =>
      'This data is too large for a QR code image.';

  @override
  String get sharedLoadDefaultsDescription =>
      'Choose the bundled presets to add. Presets you already have are left unchanged.';

  @override
  String get sharedLoadDefaultsNone => 'No default presets of this type.';

  @override
  String get sharedLoadDefaultsGenericTitle => 'Defaults';

  @override
  String get sharedLoadDefaultsGenericMessage =>
      'Presets that suit any catalog format.';

  @override
  String sharedLoadDefaultsForFormat(String format) {
    return 'For $format';
  }

  @override
  String get sharedLoadDefaultsForFormatMessage =>
      'Optional presets written for this catalog format.';

  @override
  String get sharedLoadDefaultsLayoutsNote =>
      'Layouts bring the templates they print with.';

  @override
  String get sharedLoadSelected => 'Load selected';

  @override
  String sharedLoadDefaultsLoadError(String error) {
    return 'Unable to load bundled presets: $error';
  }

  @override
  String sharedLoadDefaultsFailed(String error) {
    return 'Failed to load default presets: $error';
  }

  @override
  String get sharedIncludeLinkedTemplates => 'Include linked templates';

  @override
  String sharedLinkedTemplateList(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count templates: $names',
      one: '1 template: $names',
    );
    return '$_temp0';
  }

  @override
  String sharedExportedTo(String path) {
    return 'Exported to $path';
  }

  @override
  String sharedExportFailedError(String error) {
    return 'Export failed: $error';
  }

  @override
  String get sharedExportProjectInfo => 'Export project info';

  @override
  String get sharedExportProjectInfoDescription =>
      'Export this project information as JSON.';

  @override
  String get sharedSortOrder => 'Order';

  @override
  String get sharedSortAscending => 'Ascending';

  @override
  String get sharedSortDescending => 'Descending';

  @override
  String get sharedSortId => 'ID';

  @override
  String get sharedSortRecordOrder => 'Record order';

  @override
  String get sharedSortSiteId => 'Site ID';

  @override
  String get sharedSortStateProvince => 'State/province';

  @override
  String get sharedSortPreciseLocality => 'Precise locality';

  @override
  String get sharedSortEventId => 'Event ID';

  @override
  String get sharedSortStartDate => 'Start date';

  @override
  String get sharedSortFieldId => 'Field ID';

  @override
  String get sharedSortCataloger => 'Cataloger';

  @override
  String get sharedSortSpecies => 'Species';

  @override
  String get sharedSortDate => 'Date';

  @override
  String get sharedSortWriter => 'Writer';

  @override
  String sharedImportRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Import site',
      'event': 'Import event',
      'other': 'Import specimen',
    });
    return '$_temp0';
  }

  @override
  String sharedCreateNewRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Create new site',
      'event': 'Create new event',
      'other': 'Create new specimen',
    });
    return '$_temp0';
  }

  @override
  String sharedUpdateExistingRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Update an existing site',
      'event': 'Update an existing event',
      'other': 'Update an existing specimen',
    });
    return '$_temp0';
  }

  @override
  String sharedExportRecordType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Export site',
      'event': 'Export event',
      'other': 'Export specimen',
    });
    return '$_temp0';
  }

  @override
  String sharedExportRecordJson(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'site': 'Export this site record as JSON.',
      'event': 'Export this event record as JSON.',
      'other': 'Export this specimen record as JSON.',
    });
    return '$_temp0';
  }

  @override
  String sharedExportRecordMedia(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'This record includes $count linked media files, which will be included in the archive.',
      one:
          'This record includes 1 linked media file, which will be included in the archive.',
    );
    return '$_temp0';
  }

  @override
  String sharedReusesSavedLocality(String locality) {
    return 'Reuses a saved locality: $locality';
  }

  @override
  String get sharedContinue => 'Continue';

  @override
  String get sharedBack => 'Back';

  @override
  String get sharedChooseEventSite => 'Choose event site';

  @override
  String get sharedChooseEventSiteDescription =>
      'This event includes a linked site. Choose an existing site or create the embedded site as a new site.';

  @override
  String get sharedCreateEmbeddedSite => 'Create embedded site';

  @override
  String get sharedCreateEmbeddedEvent => 'Create embedded event';

  @override
  String get sharedCreateEmbeddedTaxonomy => 'Create embedded taxonomy';

  @override
  String get sharedChooseSpecimenEvent => 'Choose specimen event';

  @override
  String get sharedChooseSpecimenTaxonomy => 'Choose specimen taxonomy';

  @override
  String sharedCoordinateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coordinates',
      one: '1 coordinate',
    );
    return '$_temp0';
  }

  @override
  String sharedPersonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String sharedCollMethodCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count collection methods',
      one: '1 collection method',
    );
    return '$_temp0';
  }

  @override
  String sharedPersonnelAssignmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnel assignments',
      one: '1 personnel assignment',
    );
    return '$_temp0';
  }

  @override
  String get sharedEnvironmentalData => 'environmental data';

  @override
  String sharedMediaFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count media files',
      one: '1 media file',
    );
    return '$_temp0';
  }

  @override
  String get sharedNoAssociatedRecords => 'No associated records';

  @override
  String sharedSiteLabel(String id) {
    return 'Site $id';
  }

  @override
  String sharedEventLabel(String id) {
    return 'Event $id';
  }

  @override
  String sharedSpecimenLabel(String id) {
    return 'Specimen $id';
  }

  @override
  String sharedTaxonLabel(String id) {
    return 'Taxon $id';
  }

  @override
  String get sharedRecordLabel => 'Record';

  @override
  String sharedSpecimenImportSummary(
    int partCount,
    int associatedCount,
    int mediaCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      partCount,
      locale: localeName,
      other: '$partCount parts',
      one: '1 part',
    );
    String _temp1 = intl.Intl.pluralLogic(
      associatedCount,
      locale: localeName,
      other: '$associatedCount associated records',
      one: '1 associated record',
    );
    String _temp2 = intl.Intl.pluralLogic(
      mediaCount,
      locale: localeName,
      other: '$mediaCount media files',
      one: '1 media file',
    );
    return 'Includes $_temp0, $_temp1, and $_temp2.';
  }

  @override
  String get sharedSiteQrCode => 'Site QR code';

  @override
  String get sharedEventQrCode => 'Event QR code';

  @override
  String get sharedSpecimenImported => 'Specimen imported successfully.';

  @override
  String get sharedSiteImported => 'Site imported successfully.';

  @override
  String get sharedEventImported => 'Event imported successfully.';

  @override
  String get sharedQrNoData => 'The QR code has no data.';

  @override
  String get sharedRecordQrTooLargeBody =>
      'This record contains too much data for a QR code. Export it as JSON to transfer the complete record instead.';

  @override
  String get sharedRecordQrDescription =>
      'Scan this code from another NAHPU device to import the record.';

  @override
  String sharedRecordExchangeFailed(String error) {
    return 'Record import/export failed: $error';
  }

  @override
  String get sharedFileName => 'File name';

  @override
  String sharedSomethingWentWrong(String error) {
    return 'Something went wrong: $error';
  }

  @override
  String get sharedSelectFile => 'Select file';

  @override
  String get sharedSupportedFormats => 'Supported formats';

  @override
  String sharedSupportedFormatsList(String label, String formats) {
    return '$label:\n$formats';
  }

  @override
  String get sharedAppendDate => 'Append current date';

  @override
  String get sharedAppendDateDescription => 'Adds -yyyy-mm-dd to the filename';

  @override
  String get sharedSaveTo => 'Save to';

  @override
  String get sharedSelectDirectory => 'Select directory';

  @override
  String get sharedClearDirectory => 'Clear directory';

  @override
  String get sharedNoFolderChosen =>
      'No folder chosen. The export goes to NAHPU app storage — browse to a folder to put it somewhere you choose.';

  @override
  String get sharedShareAfterExport => 'Share after export';

  @override
  String get sharedTemporaryExportNote =>
      'NAHPU keeps the file only until your next export. Share it to save a copy in Files, send it to another app, or put it in a cloud folder.';

  @override
  String get sharedEntireDatabaseContents => 'Entire database contents';

  @override
  String get sharedBackupSizeBeforeCompression =>
      'Backup size before compression';

  @override
  String sharedWizardStepChip(int number, String label) {
    return '$number. $label';
  }

  @override
  String get sharedNavDashboard => 'Dashboard';

  @override
  String get sharedNavSites => 'Sites';

  @override
  String get sharedNavEvents => 'Events';

  @override
  String get sharedNavSpecimens => 'Specimens';

  @override
  String get sharedNavNarrative => 'Narrative';

  @override
  String get sharedNavCollapse => 'Collapse';

  @override
  String get sharedNavExpand => 'Expand';

  @override
  String get sharedNavCollapseNavigation => 'Collapse navigation';

  @override
  String get sharedNavExpandNavigation => 'Expand navigation';

  @override
  String get sharedNavCollapseRail => 'Collapse navigation rail';

  @override
  String get sharedNavExpandRail => 'Expand navigation rail';

  @override
  String get sharedNavMenu => 'Menu';

  @override
  String get sharedNavCloseMenu => 'Close menu';

  @override
  String get sharedNavCloseProjectMenu => 'Close project menu';

  @override
  String get sharedNavOpenProjectMenu => 'Open project menu';

  @override
  String get sharedNavCloseProject => 'Close project';

  @override
  String get sharedGoToPage => 'Go to page';

  @override
  String get sharedGoToPageOrSearch => 'Go to page or search';

  @override
  String sharedPageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get sharedSearch => 'Search';

  @override
  String get sharedPageNumber => 'Page number';

  @override
  String get sharedGo => 'Go';

  @override
  String get sharedOr => 'or';

  @override
  String get sharedSearchRecords => 'Search records';

  @override
  String sharedPageOutOfRange(int total) {
    return 'Enter a page from 1 to $total';
  }

  @override
  String get textReplaceErrorEmptyPattern => 'Find text cannot be empty.';

  @override
  String textReplaceErrorInvalidRegex(String detail) {
    return 'Invalid regular expression: $detail';
  }

  @override
  String get textReplaceAdd => 'Add replacement';

  @override
  String get textReplaceTitle => 'Replace text';

  @override
  String get textReplaceSubtitle => 'Applied in order after value formatting.';

  @override
  String get textReplaceDialogTitle => 'Find and replace';

  @override
  String get textReplaceMatch => 'Match';

  @override
  String get textReplaceMatchExact => 'Exact';

  @override
  String get textReplaceMatchRegex => 'Regex';

  @override
  String get textReplaceFind => 'Find';

  @override
  String get textReplaceWith => 'Replace with';

  @override
  String get textReplaceIgnoreCase => 'Ignore case';

  @override
  String get textReplaceMoveUp => 'Move replacement up';

  @override
  String get textReplaceMoveDown => 'Move replacement down';

  @override
  String get textReplaceRemove => 'Remove replacement';

  @override
  String get textReplaceRegexHelp =>
      'Use \$0 for the full match, \$1…\$n for groups, and \$\$ for \$.';

  @override
  String get documentFontSampleA =>
      'Durians are the king of fruits, and mangosteen is the queen of fruit. Apparently, it is never a good idea to eat them at the same time. I definitely should not have eaten 12 durians and a dozen mangosteens in one sitting out in the fields.';

  @override
  String get documentFontSampleB =>
      'There is only one place in northern Sumatra where orangutans, rhinos, elephants, and tigers share the same natural habitat. Guess the name of the National Park?';

  @override
  String get documentFontSampleC =>
      'Feeling creative or inspired? Send the maintainer your thoughts, an interesting biodiversity fact, a field joke, or a short story worth reading, or post it at github.com/nahpu/nahpu/issues, and it may show up right here. A font choice should not be decided by a quick brown fox jumping over a lazy dog.';

  @override
  String get documentFontBold => 'Bold';

  @override
  String get documentFontItalic => 'Italic';

  @override
  String get fieldEditorLabel => 'Label';

  @override
  String get fieldEditorType => 'Type';

  @override
  String get fieldEditorCatalogApplicability => 'Catalog applicability';

  @override
  String fieldEditorCurrentCatalogOnly(String catalog) {
    return 'Current catalog only ($catalog)';
  }

  @override
  String get fieldEditorOptions => 'Options';

  @override
  String get fieldEditorOptionsHelper => 'Enter one option per line.';

  @override
  String get fieldEditorMapToDwc => 'Map to Darwin Core';

  @override
  String fieldEditorDwcOfficialTerms(String version) {
    return 'Official terms $version';
  }

  @override
  String get fieldEditorDwcTarget => 'DWC target';

  @override
  String get fieldEditorDwcMappingMode => 'Mapping mode';

  @override
  String get fieldEditorDwcDirect => 'Direct field';

  @override
  String get fieldEditorDwcAssertion => 'Repeatable measurement / fact';

  @override
  String get fieldEditorDwcField => 'DWC field';

  @override
  String get fieldEditorDwcAllowConflict => 'I understand duplicate values';

  @override
  String get fieldEditorDwcAllowConflictNote =>
      'Conflicting scalar values will be joined with “ | ”.';

  @override
  String get fieldEditorEditTitle => 'Edit custom field';

  @override
  String fieldEditorAddTitle(String section) {
    return 'Add custom field to $section';
  }

  @override
  String get documentFileSettings => 'File Settings';

  @override
  String get documentFileFormat => 'File format';

  @override
  String get documentFileBundleFormat => 'Bundle format';

  @override
  String get documentFileDwcDpZipNote =>
      'ZIP is provided for compatibility. TAR.GZ is the standards-oriented DwC-DP option.';

  @override
  String get documentFileFormatCsv => 'Comma-separated (.csv)';

  @override
  String get documentFileFormatTsv => 'Tab-separated (.tsv)';

  @override
  String get documentFileFormatExcel => 'Excel (.xlsx)';

  @override
  String get documentFileFormatJson => 'JSON (.json)';

  @override
  String documentPreviewPdfError(String error) {
    return 'Error generating PDF:\n$error';
  }

  @override
  String get documentPreviewUnavailable => 'No preview available.';

  @override
  String get documentPreviewNotGenerated => 'Preview has not been generated.';

  @override
  String get documentPreviewNoLayout => 'No layout loaded.';

  @override
  String get documentPreviewUpdate => 'Update preview';

  @override
  String get documentPreviewGenerate => 'Generate preview';

  @override
  String get documentPreviewOptionsChanged => 'Preview options changed';

  @override
  String documentPreviewPageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get documentColumnsDefaults => 'Defaults';

  @override
  String documentColumnsSelectedCount(int selected, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Selected $selected of $total columns',
      one: 'Selected $selected of 1 column',
    );
    return '$_temp0';
  }

  @override
  String get documentPartFilterTitle => 'Filter specimen parts';

  @override
  String get documentPartFilterNote =>
      'Filters change the list only. Selected parts remain included in the export until you change the selection.';

  @override
  String get documentPartFilterTypes => 'Part types';

  @override
  String get documentPartFilterTypesHint =>
      'Leave all unchecked to include every type.';

  @override
  String get documentPartFilterNumberRange => 'Number range';

  @override
  String get documentPartFilterFieldNumber => 'Field number';

  @override
  String get documentPartFilterProjectNumber => 'Project number';

  @override
  String get documentPartFilterFrom => 'From';

  @override
  String get documentPartFilterTo => 'To';

  @override
  String get documentPartFilterRangeHint =>
      'Includes both endpoints. Leave either end blank for no limit.';

  @override
  String get documentPartFilterReset => 'Reset filters';

  @override
  String get documentPartFilterInvalidNumber =>
      'Enter a non-negative whole number.';

  @override
  String get documentPartFilterFromAfterTo =>
      'From must be less than or equal to To.';

  @override
  String documentPartsLoadError(String error) {
    return 'Unable to load parts: $error';
  }

  @override
  String get documentPartsSearch => 'Search parts or specimen numbers';

  @override
  String get documentPartFilterActive => 'Filter specimen parts (active)';

  @override
  String documentPartsSummary(int shown, int total, int selected) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total parts',
      one: '1 part',
    );
    return 'Showing $shown of $_temp0 · Selected $selected';
  }

  @override
  String documentPartsSummaryHidden(
    int shown,
    int total,
    int selected,
    int hidden,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total parts',
      one: '1 part',
    );
    return 'Showing $shown of $_temp0 · Selected $selected ($hidden hidden)';
  }

  @override
  String get documentPartsEmpty => 'No specimen parts found';

  @override
  String documentPartFallbackTitle(String id) {
    return 'Part $id';
  }

  @override
  String documentPartFieldNumber(String number) {
    return 'Field no. $number';
  }

  @override
  String documentPartProjectNumber(String number) {
    return 'Project no. $number';
  }

  @override
  String documentPartCatalog(String number) {
    return 'Catalog $number';
  }

  @override
  String documentPartSpecimenFallback(String uuid) {
    return 'Specimen $uuid';
  }

  @override
  String get documentSelectionClearAll => 'Clear all';

  @override
  String get documentSpecimenSearch => 'Search Field No, Collector, Species...';

  @override
  String documentSpecimenCollectedRange(String start, String end) {
    return 'Coll: $start - $end';
  }

  @override
  String get documentSpecimenCollectionDate => 'Collection Date';

  @override
  String documentSpecimenPreparedRange(String start, String end) {
    return 'Prep: $start - $end';
  }

  @override
  String get documentSpecimenPrepDate => 'Prep Date';

  @override
  String documentSelectionSelectedOf(int selected, int total) {
    return 'Selected $selected of $total';
  }

  @override
  String get documentSpecimenSelectTitle => 'Select specimens';

  @override
  String get documentSelectSitePreview => 'Select Site for Preview';

  @override
  String get documentSelectSitesPreview => 'Select Sites for Preview';

  @override
  String get documentSelectSites => 'Select sites';

  @override
  String get documentSelectEventPreview => 'Select Event for Preview';

  @override
  String get documentSelectEventsPreview => 'Select Events for Preview';

  @override
  String get documentSelectEvents => 'Select events';

  @override
  String get documentSelectNarrativePreview => 'Select Narrative for Preview';

  @override
  String get documentSelectNarrativesPreview => 'Select Narratives for Preview';

  @override
  String get documentSelectNarratives => 'Select narratives';

  @override
  String get documentSiteSearch => 'Search site ID, locality...';

  @override
  String get documentSelectionClearSearch => 'Clear search';

  @override
  String get documentSitesEmpty => 'No sites found';

  @override
  String get documentSiteUnnamed => 'Unnamed Site';

  @override
  String get documentSiteNoLocality => 'No locality details';

  @override
  String documentSelectionLoadError(String error) {
    return 'Error: $error';
  }

  @override
  String get documentEventSearch => 'Search event ID, method...';

  @override
  String get documentEventsEmpty => 'No events found';

  @override
  String documentEventFallbackTitle(String id) {
    return 'Event ID: $id';
  }

  @override
  String get documentEventNoMethod => 'No method';

  @override
  String get documentSelectionNoDate => 'No date';

  @override
  String get documentNarrativeSearch => 'Search date, content...';

  @override
  String get documentNarrativesEmpty => 'No narratives found';

  @override
  String get documentNarrativeNoText => 'No text';

  @override
  String get documentRecordsSpecimens => 'Specimens';

  @override
  String get documentRecordsSites => 'Sites';

  @override
  String get documentRecordsEvents => 'Collecting Events';

  @override
  String get documentRecordsNarratives => 'Narratives';

  @override
  String get documentRecordsGeneric => 'Records';

  @override
  String documentSelectedCount(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String get documentPageSizeLetter => 'US Letter (8.5 x 11 in)';

  @override
  String get documentPageSizeLegal => 'US Legal';

  @override
  String get documentPageSizeCustom => 'Custom';

  @override
  String get documentOrientationPortrait => 'Portrait';

  @override
  String get documentOrientationLandscape => 'Landscape';

  @override
  String get documentOverrideBlocks => 'Override template blocks';

  @override
  String get documentTemplateBlocks => 'Template blocks';

  @override
  String get documentAddBlock => 'Add Block';

  @override
  String get documentMultiBlockMode => 'Multiple blocks mode';

  @override
  String get documentMultiBlockContinuous => 'Continuous (Block-by-block)';

  @override
  String get documentMultiBlockAlternate => 'Alternate (Record-by-record)';

  @override
  String documentBlockNumber(int number) {
    return 'Block #$number';
  }

  @override
  String get documentShowLess => 'Show less';

  @override
  String get documentShowMore => 'Show more';

  @override
  String get documentDeleteBlock => 'Delete Block';

  @override
  String get documentBlockTemplate => 'Template';

  @override
  String get documentTemplateMissing => 'This template no longer exists';

  @override
  String documentMissingItem(String name) {
    return 'Missing: $name';
  }

  @override
  String get documentEditTemplate => 'Edit template';

  @override
  String get documentBlockCopies => 'Copies';

  @override
  String get documentBlockRows => 'Rows';

  @override
  String get documentBlockCols => 'Cols';

  @override
  String get documentAutoFillPage => 'Auto-fill page';

  @override
  String get documentTemplatePadding => 'Template padding (mm)';

  @override
  String get documentPaddingTop => 'Top';

  @override
  String get documentPaddingLeft => 'Left';

  @override
  String get documentPaddingRight => 'Right';

  @override
  String get documentPaddingBottom => 'Bottom';

  @override
  String get documentPageBreakAfter => 'Page break after';

  @override
  String get documentPageBreakAfterHint => 'Insert page break after this block';

  @override
  String get documentCurrentProjectSelection => 'Current Project Selection';

  @override
  String get documentActiveProjectDocument => '1 document (active project)';

  @override
  String get documentSelectionSpecimens => 'Specimens Selection';

  @override
  String get documentSelectionSpecimenParts => 'Specimen Parts Selection';

  @override
  String get documentSelectionSites => 'Sites Selection';

  @override
  String get documentSelectionEvents => 'Collecting Events Selection';

  @override
  String get documentSelectionNarratives => 'Narratives Selection';

  @override
  String get documentSortDirection => 'Direction';

  @override
  String get documentSortAscending => 'Ascending';

  @override
  String get documentSortDescending => 'Descending';

  @override
  String get documentSortFieldsLoadError => 'Unable to load ordering fields';

  @override
  String get documentSortOriginalOrder => 'Original order';

  @override
  String get documentSortOrderBy => 'Order by';

  @override
  String get documentSortOrderRecordsBy => 'Order records by';

  @override
  String get documentSortClosePicker => 'Close order field picker';

  @override
  String documentSortFieldUnavailable(String table) {
    return '$table · Not available for this template';
  }

  @override
  String documentFieldCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fields',
      one: '1 field',
    );
    return '$_temp0';
  }

  @override
  String get documentLayoutTitle => 'Document Layout';

  @override
  String get documentLayoutProfile => 'Layout profile';

  @override
  String get documentLayoutProfileHelper =>
      'Page settings and template blocks are set by the profile.';

  @override
  String get documentManagePresets => 'Manage presets';

  @override
  String get documentPageSetup => 'Page Setup';

  @override
  String get documentPageSize => 'Page size';

  @override
  String get documentPageWidthMm => 'Width mm';

  @override
  String get documentPageHeightMm => 'Height mm';

  @override
  String get documentOrientation => 'Orientation';

  @override
  String get documentPagePadding => 'Page padding (mm)';

  @override
  String get documentSelectSpecimenParts => 'Select specimen parts';

  @override
  String get labelCatalogFormatOrnithology => 'Ornithology';

  @override
  String get labelCatalogFormatMammalogy => 'Mammalogy';

  @override
  String get labelCatalogFormatHerpetology => 'Herpetology';

  @override
  String get labelCatalogFormatInvertebrateZoology => 'Invertebrate zoology';

  @override
  String get labelCatalogFormatIchthyology => 'Ichthyology';

  @override
  String get labelSpecimenRecordTypeAllTaxa => 'All taxa';

  @override
  String get labelSpecimenRecordTypeBirds => 'Birds';

  @override
  String get labelSpecimenRecordTypeMammals => 'Mammals';

  @override
  String get labelSpecimenRecordTypeHerpetofauna => 'Herpetofauna';

  @override
  String get labelSpecimenRecordTypeInvertebrates => 'Invertebrates';

  @override
  String get labelSpecimenRecordTypeFishes => 'Fishes';

  @override
  String get labelProjectToolCategoryUtilities => 'Utilities';

  @override
  String get labelProjectToolCategoryProject => 'Project';

  @override
  String get labelProjectToolCategoryRecords => 'Records';

  @override
  String get labelProjectToolCategoryDatabase => 'Database';

  @override
  String get labelProjectToolCategoryConfiguration => 'Configuration';

  @override
  String get labelProjectToolDataTable => 'Data table';

  @override
  String get labelProjectToolDataTableDescription =>
      'Browse, sort, and search project records';

  @override
  String get labelProjectToolTemplates => 'Templates';

  @override
  String get labelProjectToolTemplatesDescription =>
      'Create and edit document templates';

  @override
  String get labelProjectToolMergeProject => 'Merge project';

  @override
  String get labelProjectToolMergeProjectDescription =>
      'Merge another project into this one';

  @override
  String get labelProjectToolExportProject => 'Export project';

  @override
  String get labelProjectToolExportProjectDescription =>
      'Export this project for transfer';

  @override
  String get labelProjectToolBatchImport => 'Batch import';

  @override
  String get labelProjectToolBatchImportDescription =>
      'Import or update records from a spreadsheet';

  @override
  String get labelProjectToolCuration => 'Curation';

  @override
  String get labelProjectToolCurationDescription =>
      'Specimen curation: scan tissues into storage boxes';

  @override
  String get labelProjectToolBundleRecords => 'Bundle records';

  @override
  String get labelProjectToolBundleRecordsDescription =>
      'Bundle records with their media';

  @override
  String get labelProjectToolExportRecords => 'Export records';

  @override
  String get labelProjectToolExportRecordsDescription =>
      'Export records as tabular data';

  @override
  String get labelProjectToolExportDocuments => 'Export documents';

  @override
  String get labelProjectToolExportDocumentsDescription =>
      'Export records as documents';

  @override
  String get labelProjectToolBackupDatabaseDescription =>
      'Back up the application database';

  @override
  String get labelProjectToolSettingsDescription => 'Open application settings';

  @override
  String get labelProjectToolExportConfigs => 'Export configs';

  @override
  String get labelProjectToolImportConfigs => 'Import configs';

  @override
  String get labelBasemapNone => 'None';

  @override
  String get labelBasemapNoneDescription => 'No geographic base layer';

  @override
  String get labelBasemapAutomatic => 'Automatic';

  @override
  String get labelBasemapAutomaticDescription =>
      'Positron in light mode and Dark in dark mode';

  @override
  String get labelBasemapNaturalEarthOffline => 'Natural Earth (Offline)';

  @override
  String get labelBasemapNaturalEarthOfflineDescription =>
      'Bundled country boundaries that work without internet access';

  @override
  String get labelBasemapPositronDescription =>
      'Minimal, low-contrast light map';

  @override
  String get labelBasemapBrightDescription => 'Detailed map with bright colors';

  @override
  String get labelBasemapLibertyDescription =>
      'Detailed map with balanced colors';

  @override
  String get labelBasemapDark => 'Dark';

  @override
  String get labelBasemapDarkDescription => 'Dark map for low-light use';

  @override
  String get labelMapLayerKindRasterTiles => 'Raster tiles';

  @override
  String get labelMapLayerKindVectorTiles => 'Vector tiles';

  @override
  String get labelMapLayerKindElevationModel => 'Elevation model';

  @override
  String get labelFieldSectionSpecimenAttributes => 'Specimen Attributes';

  @override
  String get labelFieldSectionSiteAttributes => 'Site Attributes';

  @override
  String get labelFieldSectionEnvironmentalData => 'Environmental Data';

  @override
  String get labelFieldSectionSpecimenPart => 'Specimen Part';

  @override
  String get labelFieldSectionParasite => 'Parasite';

  @override
  String get labelSiteGeographyCountry => 'Country';

  @override
  String get labelSiteGeographyIslandGroup => 'Island group';

  @override
  String get labelSiteGeographyStateProvince => 'State/Province';

  @override
  String get labelSiteGeographyCounty => 'County/Parish/District';

  @override
  String get labelSiteGeographyMunicipality => 'Municipality/City/Town';

  @override
  String get labelEnvironmentalLowestDayTemp => 'Day lowest temperature';

  @override
  String get labelEnvironmentalHighestDayTemp => 'Day highest temperature';

  @override
  String get labelEnvironmentalLowestNightTemp => 'Night lowest temperature';

  @override
  String get labelEnvironmentalHighestNightTemp => 'Night highest temperature';

  @override
  String get labelEnvironmentalAverageHumidity => 'Average humidity';

  @override
  String get labelEnvironmentalDewPoint => 'Dew point';

  @override
  String get labelEnvironmentalCloudCover => 'Cloud cover';

  @override
  String get labelEnvironmentalRainfall => 'Rainfall';

  @override
  String get labelEnvironmentalAmbientTemperature => 'Ambient temperature';

  @override
  String get labelEnvironmentalAmbientHumidity => 'Ambient humidity';

  @override
  String get labelEnvironmentalWaterTemperature => 'Water temperature';

  @override
  String get labelEnvironmentalDissolvedOxygen => 'Dissolved oxygen';

  @override
  String get labelEnvironmentalDissolvedOxygenSaturation =>
      'Dissolved oxygen saturation';

  @override
  String get labelEnvironmentalConductivity => 'Conductivity';

  @override
  String get labelEnvironmentalFlowVelocity => 'Flow velocity';

  @override
  String get labelEnvironmentalSunrise => 'Sunrise';

  @override
  String get labelEnvironmentalSunset => 'Sunset';

  @override
  String get labelEnvironmentalMoonPhase => 'Moon phase';

  @override
  String get labelEnvironmentalNotes => 'Notes';

  @override
  String labelEnvironmentalWithUnit(String label, String unit) {
    return '$label ($unit)';
  }

  @override
  String get labelTableProject => 'Project';

  @override
  String get labelTableGeography => 'Geography';

  @override
  String get labelTableSite => 'Site';

  @override
  String get labelTableSiteAttribute => 'Site Attribute';

  @override
  String get labelTableFossilSite => 'Fossil Site';

  @override
  String get labelTableCoordinate => 'Coordinate';

  @override
  String get labelTableCollEvent => 'Coll Event';

  @override
  String get labelTableEnvironment => 'Environment';

  @override
  String get labelTableCollPersonnel => 'Coll Personnel';

  @override
  String get labelTableCollMethod => 'Coll Method';

  @override
  String get labelTableNarrative => 'Narrative';

  @override
  String get labelTableMedia => 'Media';

  @override
  String get labelTableNarrativeMedia => 'Narrative Media';

  @override
  String get labelTableSiteMedia => 'Site Media';

  @override
  String get labelTableEventMedia => 'Event Media';

  @override
  String get labelTableSpecimenMedia => 'Specimen Media';

  @override
  String get labelTableAssociatedData => 'Associated Data';

  @override
  String get labelTableSpecimenAssociatedData => 'Specimen Associated Data';

  @override
  String get labelTableSiteAssociatedData => 'Site Associated Data';

  @override
  String get labelTableEventAssociatedData => 'Event Associated Data';

  @override
  String get labelTablePersonnelList => 'Personnel List';

  @override
  String get labelTablePersonnel => 'Personnel';

  @override
  String get labelTableTaxonomy => 'Taxonomy';

  @override
  String get labelTableSpecimen => 'Specimen';

  @override
  String get labelTableMammalAttribute => 'Mammal Attribute';

  @override
  String get labelTableBirdAttribute => 'Bird Attribute';

  @override
  String get labelTableHerpAttribute => 'Herp Attribute';

  @override
  String get labelTableInvertebrateAttribute => 'Invertebrate Attribute';

  @override
  String get labelTableFishAttribute => 'Fish Attribute';

  @override
  String get labelTableFossilAttribute => 'Fossil Attribute';

  @override
  String get labelTableParasiteDetection => 'Parasite Detection';

  @override
  String get labelTableParasite => 'Parasite';

  @override
  String get labelTableSpecimenPart => 'Specimen Part';

  @override
  String get labelTableSpecimenIndividual => 'Specimen Individual';

  @override
  String get labelTableSpecimenPartIndividual => 'Specimen Part Individual';

  @override
  String get labelTableParasiteIndividual => 'Parasite Individual';

  @override
  String get labelTableCustomFieldDefinition => 'Custom Field Definition';

  @override
  String get labelTableCustomFieldValue => 'Custom Field Value';

  @override
  String fileExplorerFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '1 file',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerImageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count images',
      one: '1 image',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerAudioCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count audio files',
      one: '1 audio file',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerVideoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos',
      one: '1 video',
    );
    return '$_temp0';
  }

  @override
  String fileExplorerOtherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count other files',
      one: '1 other file',
    );
    return '$_temp0';
  }

  @override
  String get fileExplorerLockDatabase => 'Application database';

  @override
  String get fileExplorerLockDatabaseSidecar => 'Database working file';

  @override
  String get fileExplorerLockBackup => 'Database backup';

  @override
  String get fileExplorerLockUserConfig => 'Custom fonts and map layers';

  @override
  String get fileExplorerLockTemplateMedia => 'Global template media';

  @override
  String get fileExplorerLockMediaRecord => 'Linked to a media record';

  @override
  String get fileExplorerLockPersonnelPhoto => 'Linked to a personnel photo';

  @override
  String get fileExplorerLockAssociatedData => 'Linked to associated data';

  @override
  String get fileExplorerLockUnresolvedReference =>
      'A record points here but could not be read';

  @override
  String get fileExplorerLockRecentlyModified =>
      'Changed just now, may still be copying';

  @override
  String get fileExplorerLockUnmanagedLocation =>
      'Not in a folder NAHPU manages';

  @override
  String get fileExplorerLockUnknownProject =>
      'Folder of a project not in the database';

  @override
  String fileExplorerPruneBlockedUnresolved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count associated data records could not be read, so some files cannot be checked. Removing files is disabled until that is resolved.',
      one:
          '1 associated data record could not be read, so some files cannot be checked. Removing files is disabled until that is resolved.',
    );
    return '$_temp0';
  }

  @override
  String get fileExplorerPruneBlockedEmptyIndex =>
      'The database reports no linked files at all, which usually means it is still opening. Reopen this screen before removing anything.';

  @override
  String get progressPrepareBackup => 'Prepare backup';

  @override
  String get progressCopyMediaAndFiles => 'Copy media and files';

  @override
  String get progressCompressArchive => 'Compress archive';

  @override
  String get progressExtractArchive => 'Extract archive';

  @override
  String get progressRestoreMediaAndFiles => 'Restore media and files';

  @override
  String get progressBackUpCurrentData => 'Back up current data';

  @override
  String get progressReplaceDatabase => 'Replace database';

  @override
  String get progressWriteRecords => 'Write records';

  @override
  String get progressCopyMedia => 'Copy media';

  @override
  String get progressCheckContents => 'Check contents';

  @override
  String get progressCollectRecords => 'Collect records';

  @override
  String get progressCheckRecords => 'Check records';

  @override
  String get progressWriteAndCompressPackage => 'Write and compress package';

  @override
  String get progressProcessMedia => 'Process media';

  @override
  String serviceMessagePresetsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count presets',
      one: 'Added 1 preset',
    );
    return '$_temp0';
  }

  @override
  String get serviceMessageNoDefaultPresets =>
      'No default presets of this type';

  @override
  String get serviceMessageDefaultPresetsLoaded =>
      'Default presets are already loaded';

  @override
  String serviceMessagePresetsAndTemplatesImported(
    int count,
    int templateCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count presets',
      one: '1 preset',
    );
    String _temp1 = intl.Intl.pluralLogic(
      templateCount,
      locale: localeName,
      other: '$templateCount templates',
      one: '1 template',
    );
    return 'Imported $_temp0 and $_temp1';
  }

  @override
  String serviceMessagePresetImageNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count templates use images, which are referenced by name rather than stored in the file. On another installation those images have to be added again.',
      one:
          '1 template uses images, which are referenced by name rather than stored in the file. On another installation those images have to be added again.',
    );
    return '$_temp0';
  }

  @override
  String deletePersonnelCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count personnel',
      one: 'Delete 1 personnel',
    );
    return '$_temp0';
  }

  @override
  String deletePersonnelTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete personnel',
      one: 'Delete personnel',
    );
    return '$_temp0';
  }

  @override
  String deletePersonnelBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Are you sure you want to delete the selected personnel?',
      one: 'Are you sure you want to delete the selected personnel?',
    );
    return '$_temp0';
  }

  @override
  String deleteTaxaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count taxa',
      one: 'Delete 1 taxon',
    );
    return '$_temp0';
  }

  @override
  String deleteTaxaTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete taxa',
      one: 'Delete taxon',
    );
    return '$_temp0';
  }

  @override
  String deleteTaxaBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Are you sure you want to delete the selected taxa?',
      one: 'Are you sure you want to delete the selected taxon?',
    );
    return '$_temp0';
  }

  @override
  String deleteCoordinatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count coordinates',
      one: 'Delete 1 coordinate',
    );
    return '$_temp0';
  }

  @override
  String deleteCoordinatesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete coordinates',
      one: 'Delete coordinate',
    );
    return '$_temp0';
  }

  @override
  String deleteCoordinatesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Are you sure you want to delete the selected coordinates?',
      one: 'Are you sure you want to delete the selected coordinate?',
    );
    return '$_temp0';
  }

  @override
  String deleteCollMethodsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count collection methods',
      one: 'Delete 1 collection method',
    );
    return '$_temp0';
  }

  @override
  String deleteCollMethodsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete collection methods',
      one: 'Delete collection method',
    );
    return '$_temp0';
  }

  @override
  String deleteCollMethodsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Are you sure you want to delete the selected collection methods?',
      one: 'Are you sure you want to delete the selected collection method?',
    );
    return '$_temp0';
  }

  @override
  String deleteParasitesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count parasites',
      one: 'Delete 1 parasite',
    );
    return '$_temp0';
  }

  @override
  String deleteParasitesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete parasites',
      one: 'Delete parasite',
    );
    return '$_temp0';
  }

  @override
  String deleteParasitesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Are you sure you want to delete the selected parasites?',
      one: 'Are you sure you want to delete the selected parasite?',
    );
    return '$_temp0';
  }

  @override
  String deleteSpecimenPartsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count specimen parts',
      one: 'Delete 1 specimen part',
    );
    return '$_temp0';
  }

  @override
  String deleteSpecimenPartsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete specimen parts',
      one: 'Delete specimen part',
    );
    return '$_temp0';
  }

  @override
  String deleteSpecimenPartsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Are you sure you want to delete the selected specimen parts?',
      one: 'Are you sure you want to delete the selected specimen part?',
    );
    return '$_temp0';
  }

  @override
  String deleteAssociatedDataCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remove $count associated data entries',
      one: 'Remove 1 associated data entry',
    );
    return '$_temp0';
  }

  @override
  String get deleteAssociatedDataTitle => 'Remove associated data';

  @override
  String get deleteAssociatedDataBody =>
      'Remove the selected associated data from this record? Data shared with other records will be preserved.';

  @override
  String removeProjectPersonnelCount(int count) {
    return 'Remove $count personnel from project';
  }

  @override
  String get removeProjectPersonnelTitle => 'Remove personnel';

  @override
  String get removeProjectPersonnelBody =>
      'Are you sure you want to remove the selected personnel from the project?';

  @override
  String removeEventPersonnelCount(int count) {
    return 'Remove $count personnel from event';
  }

  @override
  String get removeEventPersonnelTitle => 'Remove event personnel';

  @override
  String get removeEventPersonnelBody =>
      'Are you sure you want to remove the selected personnel from this event?';
}
