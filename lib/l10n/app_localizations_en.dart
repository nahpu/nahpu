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
}
