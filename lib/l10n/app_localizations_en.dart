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
  String get homeMoreActions => 'More';

  @override
  String get homeGallery => 'Gallery';

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
  String get drawerMediaGallery => 'Media gallery';

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
  String get settingsLanguageHelpTranslate => 'Help translate NAHPU';

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
  String settingsMapKindUnavailableOnDesktop(String kind) {
    return '$kind · unavailable on desktop';
  }

  @override
  String get settingsMapConfigureLayer => 'Configure layer';

  @override
  String get settingsMapShowLayer => 'Show layer';

  @override
  String get settingsMapLayerUnavailableOnDesktop =>
      'This layer is unavailable on desktop';

  @override
  String get settingsMapLayerTypeUnavailableOnDesktop =>
      'This layer type is unavailable on desktop.';

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
  String get settingsMapSupportedFormatsDesktop =>
      'Supports GeoJSON, zipped WGS84 Shapefiles, and raster PMTiles on desktop.';

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
  String get presetsRecordTypeParasites => 'Parasites';

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
  String presetsPreviewParasites(int count) {
    return 'Preview Parasites ($count selected)';
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
  String get presetsPreviewSelectParasites => 'Select parasites for preview';

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
  String documentParasitesLoadError(String error) {
    return 'Unable to load parasites: $error';
  }

  @override
  String get documentParasitesSearch => 'Search parasites or specimen numbers';

  @override
  String documentParasitesSummary(int shown, int total, int selected) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total parasites',
      one: '1 parasite',
    );
    return 'Showing $shown of $_temp0 · Selected $selected';
  }

  @override
  String documentParasitesSummaryHidden(
    int shown,
    int total,
    int selected,
    int hidden,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total parasites',
      one: '1 parasite',
    );
    return 'Showing $shown of $_temp0 · Selected $selected ($hidden hidden)';
  }

  @override
  String get documentParasitesEmpty => 'No parasites found';

  @override
  String documentParasiteFallbackTitle(String id) {
    return 'Parasite $id';
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
  String get documentSelectionParasites => 'Parasites Selection';

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
  String get documentSelectParasites => 'Select parasites';

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

  @override
  String get projectDeleteProject => 'Delete project';

  @override
  String get projectDeleteProjectTitle => 'Delete project?';

  @override
  String get projectDeleteProjectPrompt =>
      'You will delete this project and its related data. This cannot be undone.';

  @override
  String get projectNoProject => 'No project';

  @override
  String get projectOverview => 'Project overview';

  @override
  String projectOverviewLoadError(Object error) {
    return 'Failed fetching data from the database. Check if the project name exists. $error';
  }

  @override
  String projectSaveFailed(String error) {
    return 'Could not save project: $error';
  }

  @override
  String get projectDetails => 'Project details';

  @override
  String get projectNameLabel => 'Project name*';

  @override
  String get projectNameHint => 'Enter the project name (required)';

  @override
  String get projectDescriptionLabel => 'Project description';

  @override
  String get projectDescriptionHint => 'Enter a short project description';

  @override
  String get projectPrincipalInvestigator => 'Principal investigator';

  @override
  String get projectPrincipalInvestigatorHint =>
      'Enter the principal investigator';

  @override
  String get projectAccession => 'Accession';

  @override
  String get projectAccessionHint => 'Enter an institutional accession';

  @override
  String get projectPlaceAndTime => 'Place and time';

  @override
  String get projectLocation => 'Location';

  @override
  String get projectLocationHint => 'Enter the general project location';

  @override
  String get projectTimeZoneNote =>
      'NAHPU stores collection dates and times as entered in local field time. The project time zone records that context so exchanged data can be interpreted consistently by third-party collection management systems and other tools.';

  @override
  String get projectDates => 'Project dates';

  @override
  String get projectStartDate => 'Start date';

  @override
  String get projectEndDate => 'End date';

  @override
  String get projectChooseDate => 'Choose a date';

  @override
  String projectClearField(String label) {
    return 'Clear $label';
  }

  @override
  String get projectTimeZone => 'Time zone';

  @override
  String get projectChooseTimeZone => 'Choose a time zone';

  @override
  String get projectTimeZoneUtc => '(UTC) Coordinated Universal Time';

  @override
  String get projectMainTaxonGroup => 'Main taxon group';

  @override
  String get projectChooseTaxonGroup => 'Choose a taxon group';

  @override
  String projectTaxonSettingLoadError(String error) {
    return 'Could not load taxon setting: $error';
  }

  @override
  String get projectIdentity => 'Identity';

  @override
  String get projectDescription => 'Description';

  @override
  String get projectSchedule => 'Schedule';

  @override
  String get projectRecordMetadata => 'Record metadata';

  @override
  String get projectCreated => 'Created';

  @override
  String get projectLastAccessed => 'Last accessed';

  @override
  String get projectNotProvided => 'Not provided';

  @override
  String get projectUuid => 'UUID';

  @override
  String get projectQrTooltip => 'Project QR code. Tap to view full.';

  @override
  String get projectEditTools => 'Edit list';

  @override
  String get projectEditToolsTooltip => 'Choose the tools shown here';

  @override
  String get projectUtilities => 'Project utilities';

  @override
  String get projectDashboard => 'Project dashboard';

  @override
  String get projectEditProject => 'Edit project';

  @override
  String get projectPersonnelRoleCataloger => 'Cataloger';

  @override
  String get projectPersonnelRoleDeterminer => 'Determiner only';

  @override
  String get projectPersonnelRolePreparator => 'Preparator only';

  @override
  String get projectPersonnelRoleNone => 'None';

  @override
  String get projectPersonnelSelectExisting => 'Select existing';

  @override
  String get projectPersonnelSelectFromDatabase => 'Select from database';

  @override
  String get projectPersonnelAddNew => 'Add new';

  @override
  String get projectPersonnelAddNewPersonnel => 'Add new personnel';

  @override
  String get projectPersonnelImageNotFound => 'Image not found';

  @override
  String get projectPersonnelTakePhoto => 'Take photo';

  @override
  String get projectPersonnelSelectPhoto => 'Select photo';

  @override
  String get projectPersonnelEdit => 'Edit personnel';

  @override
  String get projectPersonnelManage => 'Manage personnel';

  @override
  String get projectPersonnelManageButton => 'Manage';

  @override
  String get projectPersonnelNoneFound => 'No personnel found.';

  @override
  String get projectPersonnelSelectToView => 'Select personnel to view details';

  @override
  String get projectPersonnelSearch => 'Search personnel';

  @override
  String get projectPersonnelUnnamed => 'Unnamed personnel';

  @override
  String get projectPersonnelAssigned =>
      'Personnel is currently assigned to a project';

  @override
  String projectPersonnelDeleted(int deleted) {
    String _temp0 = intl.Intl.pluralLogic(
      deleted,
      locale: localeName,
      other: '$deleted personnel deleted.',
      one: '1 personnel deleted.',
    );
    return '$_temp0';
  }

  @override
  String projectPersonnelDeletedPartly(int deleted, int protected) {
    return '$deleted personnel deleted. $protected personnel could not be deleted because they are assigned to a project.';
  }

  @override
  String projectPersonnelNoMatch(String query) {
    return 'No personnel match “$query”.';
  }

  @override
  String projectSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get projectPersonnelAdded => 'Added';

  @override
  String projectPersonnelAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count personnel',
      one: 'Add 1 personnel',
    );
    return '$_temp0';
  }

  @override
  String projectPersonnelRemoveBlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count personnel could not be removed because they are used by project records.',
      one:
          '1 personnel could not be removed because they are used by project records.',
    );
    return '$_temp0';
  }

  @override
  String get projectPersonnelRole => 'Role';

  @override
  String get projectPersonnelRoleHint => 'Enter role';

  @override
  String get projectPersonnelAffiliation => 'Affiliation';

  @override
  String get projectPersonnelAffiliationHint => 'Enter affiliation';

  @override
  String get projectPersonnelOrcid => 'ORCID iD';

  @override
  String get projectPersonnelOrcidInvalid =>
      'Enter a valid hyphenated ORCID iD';

  @override
  String get projectPersonnelCurrentFieldNumber => 'Current field number';

  @override
  String get projectPersonnelInitials => 'Initials';

  @override
  String get projectPersonnelInitialsLabel => 'Initials*';

  @override
  String get projectPersonnelInitialsHint => 'e.g. HH or H-H';

  @override
  String get projectPersonnelEmail => 'Email';

  @override
  String get projectPersonnelEmailHint => 'Enter email';

  @override
  String get projectPersonnelPhone => 'Phone';

  @override
  String get projectPersonnelPhoneHint => 'Enter phone';

  @override
  String get projectPersonnelSpecimenCare => 'Specimen care';

  @override
  String get projectPersonnelSpecimenCareRole => 'Specimen care role';

  @override
  String get projectPersonnelRegisterFieldNumber => 'Register field number';

  @override
  String get projectPersonnelRegisterPersonalFieldNumber =>
      'Register personal field number';

  @override
  String get projectPersonnelRegisterFieldNumberNote =>
      'Initials and cataloger number will be used to generate specimen field ID.';

  @override
  String get projectEnabled => 'Enabled';

  @override
  String get projectDisabled => 'Disabled';

  @override
  String get projectPersonnelProfile => 'Profile';

  @override
  String get projectPersonnelContact => 'Contact';

  @override
  String get projectPersonnelNotes => 'Notes';

  @override
  String get projectPersonnelNotesHint => 'Write notes';

  @override
  String get projectPersonnelNameLabel => 'Name*';

  @override
  String get projectPersonnelNameHint => 'Enter a name (required)';

  @override
  String get projectPersonnelCatalogerNumberLabel => 'Cataloger number*';

  @override
  String projectErrorDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get projectLoading => 'Loading…';

  @override
  String get projectTaxonNew => 'New taxon';

  @override
  String get projectTaxonEdit => 'Edit taxon';

  @override
  String get projectTaxonAdd => 'Add taxon';

  @override
  String get projectTaxonClassification => 'Classification';

  @override
  String get projectTaxonRank => 'Rank';

  @override
  String get projectTaxonRankLabel => 'Taxon rank';

  @override
  String get projectTaxonRankHint =>
      'Select the rank represented by this record';

  @override
  String get projectTaxonRankRequired => 'Select a rank and enter its name.';

  @override
  String projectTaxonEnterValue(String field) {
    return 'Enter $field';
  }

  @override
  String get projectTaxonKingdom => 'Kingdom';

  @override
  String get projectTaxonPhylum => 'Phylum';

  @override
  String get projectTaxonClass => 'Class';

  @override
  String get projectTaxonOrder => 'Order';

  @override
  String get projectTaxonFamily => 'Family';

  @override
  String get projectTaxonGenus => 'Genus';

  @override
  String get projectTaxonSpecies => 'Species';

  @override
  String get projectTaxonSubspecies => 'Subspecies';

  @override
  String get projectTaxonSpecificEpithet => 'Specific epithet';

  @override
  String get projectTaxonSubspecificEpithet => 'Subspecific epithet';

  @override
  String get projectTaxonAdditionalDetails => 'Additional details';

  @override
  String get projectTaxonAuthors => 'Authors';

  @override
  String get projectTaxonAuthorsHint => 'Enter authors';

  @override
  String get projectTaxonCommonName => 'Common name';

  @override
  String get projectTaxonCommonNameHint => 'Enter a common name';

  @override
  String get projectTaxonRedListLabel => 'IUCN Red List category';

  @override
  String get projectTaxonRedListHint => 'e.g. Endangered, Vulnerable, etc.';

  @override
  String get projectTaxonRedListCategory => 'Red List category';

  @override
  String get projectTaxonCitesStatus => 'CITES status';

  @override
  String get projectTaxonCitesHint =>
      'e.g. Appendix I, Appendix II, Non-CITES, etc.';

  @override
  String get projectTaxonCountryStatusLabel => 'Country conservation status';

  @override
  String get projectTaxonCountryStatusHint => 'e.g. Protected, common, etc.';

  @override
  String get projectTaxonCountryStatus => 'Country status';

  @override
  String get projectTaxonSortingOrder => 'Sorting order';

  @override
  String get projectTaxonSortingOrderHint => 'e.g. 1, 2, 3';

  @override
  String get projectTaxonNotesHint => 'Enter notes';

  @override
  String get projectTaxonAllFields => 'All fields';

  @override
  String get projectTaxonConservation => 'Conservation';

  @override
  String get projectTaxonTotalRecords => 'Total records';

  @override
  String get projectTaxonCurrentProject => 'Current project';

  @override
  String get projectTaxonAllProjects => 'All projects';

  @override
  String projectTaxonRecordTotalsError(String error) {
    return 'Unable to load record totals: $error';
  }

  @override
  String get projectTaxonQrTooltip => 'Taxon QR code. Tap to view full.';

  @override
  String get projectTaxonQrCode => 'Taxon QR code';

  @override
  String get projectTaxonQrDescription =>
      'Scan this code in NAHPU to import this taxon.';

  @override
  String get projectTaxonRegistry => 'Taxon registry';

  @override
  String projectTaxonImported(int taxa, int families) {
    return 'Imported $taxa taxa across $families families.';
  }

  @override
  String get projectTaxonEmpty =>
      'No taxon found.\nAdd or import taxa to start recording captures.';

  @override
  String get projectTaxonMetricOrders => 'orders';

  @override
  String get projectTaxonMetricFamilies => 'families';

  @override
  String get projectTaxonMetricSpecies => 'species registered';

  @override
  String get projectTaxonMetricTaxa => 'taxa';

  @override
  String get projectTaxonSpecimenRecords => 'Specimen records';

  @override
  String get projectTaxonSearchSpecimens => 'Search specimens';

  @override
  String get projectTaxonNoSpecimens => 'No specimens found';

  @override
  String projectTaxonSpecimensFound(int found, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total specimens',
      one: '1 specimen',
    );
    String _temp1 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total specimens',
      one: '1 specimen',
    );
    String _temp2 = intl.Intl.pluralLogic(
      found,
      locale: localeName,
      other: 'Found: $found of $_temp0',
      one: 'Found: 1 of $_temp1',
    );
    return '$_temp2';
  }

  @override
  String projectTaxonSpecimenCount(int count) {
    return 'Specimen count: $count';
  }

  @override
  String get projectTaxonImportFromQr => 'Import from QR';

  @override
  String get projectTaxonSingle => 'Single taxon';

  @override
  String get projectTaxonMultiple => 'Multiple taxa';

  @override
  String get projectTaxonScanQr => 'Scan taxon QR';

  @override
  String get projectTaxonScanMultiple => 'Scan multiple taxa';

  @override
  String get projectCameraDenied =>
      'Camera access is denied. Allow camera access in device settings, then retry.';

  @override
  String get projectTaxonCameraUnavailable =>
      'Camera scanning is unavailable. Retry or use file import.';

  @override
  String get projectTaxonCameraError =>
      'Unable to use the camera. Retry or use file import.';

  @override
  String projectTaxonReadyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count taxa ready',
      one: '1 taxon ready',
    );
    return '$_temp0';
  }

  @override
  String get projectTaxonScanPrompt => 'Scan a NAHPU taxon QR code.';

  @override
  String get projectRetryCamera => 'Retry camera';

  @override
  String get projectTaxonManage => 'Manage taxa';

  @override
  String get projectTaxonNoneFound => 'No taxa found';

  @override
  String get projectTaxonSelectToView => 'Select a taxon to view details';

  @override
  String projectTaxonSearchIn(String category) {
    return 'Search $category';
  }

  @override
  String projectTaxonSearchCategoryTooltip(String category) {
    return 'Search category: $category';
  }

  @override
  String get projectTaxonSearchCategory => 'Search category';

  @override
  String get projectTaxonInUse => 'Taxon is currently used by a specimen';

  @override
  String projectTaxonDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count taxa deleted.',
      one: '1 taxon deleted.',
    );
    return '$_temp0';
  }

  @override
  String projectTaxonDeletedPartly(int deleted, int protected) {
    return '$deleted taxa deleted. $protected taxa could not be deleted because they are used by specimens.';
  }

  @override
  String projectTaxonNoMatch(String query) {
    return 'No taxa match “$query”.';
  }

  @override
  String projectTaxonNoMatchIn(String query, String category) {
    return 'No taxa match “$query” in $category.';
  }

  @override
  String get projectTaxonManual => 'Manual';

  @override
  String get projectImportSetupTab => 'Setup';

  @override
  String get projectTaxonQrSource => 'NAHPU taxon QR';

  @override
  String get projectMapColumns => 'Map columns';

  @override
  String get projectParsingError => 'Parsing error';

  @override
  String get projectCheckColumns => 'Check columns';

  @override
  String get projectHideAdvancedOptions => 'Hide advanced options';

  @override
  String get projectAdvancedOptions => 'Advanced options';

  @override
  String get projectTaxonReview => 'Review taxa';

  @override
  String get projectTaxonPreviewEmpty =>
      'Select a file or scan a taxon QR to preview imports.';

  @override
  String projectTaxonReviewSummary(int registered, int duplicates) {
    return '$registered already registered · $duplicates duplicate';
  }

  @override
  String get projectTaxonAlreadyRegistered => 'Already registered';

  @override
  String get projectTaxonDuplicate => 'Duplicate';

  @override
  String projectImportSelectedCount(int count) {
    return 'Import $count selected';
  }

  @override
  String get projectTaxonSelectSharedClass =>
      'Select the class shared by all rows';

  @override
  String get projectTaxonClassForAllRows => 'Class for all rows';

  @override
  String projectTaxonKingdomPhylum(String kingdom, String phylum) {
    return 'Kingdom: $kingdom · Phylum: $phylum';
  }

  @override
  String get projectParserExcel => 'Excel parser';

  @override
  String get projectParserDelimited => 'Delimited text parser';

  @override
  String get projectDelimiterNotApplicable => 'Not applicable (Excel file)';

  @override
  String get projectDelimiterTab => 'Tab (\"\\t\")';

  @override
  String get projectDelimiterComma => 'Comma (\",\")';

  @override
  String get projectDelimiterSemicolon => 'Semicolon (\";\")';

  @override
  String get projectDelimiterCustomRaw => 'Custom (raw text)';

  @override
  String get projectParsingDetails => 'Parsing details';

  @override
  String projectParserValue(String parser) {
    return 'Parser: $parser';
  }

  @override
  String projectDelimiterValue(String delimiter) {
    return 'Delimiter: $delimiter';
  }

  @override
  String get projectCustomDelimiterRequired =>
      'Enter a custom delimiter to continue.';

  @override
  String get projectParser => 'Parser';

  @override
  String get projectParserAutoDetect => 'Auto detect';

  @override
  String get projectCustomDelimiter => 'Custom delimiter';

  @override
  String get projectCustomDelimiterHint => 'Enter raw text (example: | or \\t)';

  @override
  String get projectRetryParse => 'Retry parse';

  @override
  String get projectTaxonSupportedInputs => 'Supported inputs:';

  @override
  String get projectTaxonSupportedFormats =>
      'CSV (.csv), TSV (.tsv), Excel (.xlsx), NAHPU taxon QR';

  @override
  String get projectReadingFile => 'Reading file…';

  @override
  String get projectQrUnavailable =>
      'QR scanning is unavailable on this platform.';

  @override
  String get projectClearImport => 'Clear import';

  @override
  String get projectWizardWelcome => 'Welcome';

  @override
  String get projectWizardMainTaxon => 'Main taxon';

  @override
  String get projectWizardReview => 'Review';

  @override
  String get projectWizardCreateOnce => 'Create once for all devices';

  @override
  String get projectWizardCreateOnceBody =>
      'Create a new project only for the first device. Use QR/Import JSON to transfer project info and its identity.';

  @override
  String get projectWizardCreateNew => 'Create new project';

  @override
  String get projectScanQr => 'Scan project QR';

  @override
  String get projectWizardMainTaxonBody =>
      'Choose the main taxon to tailor NAHPU’s specimen forms and defaults on this device. A project can contain multiple taxon groups, and you can change the main taxon later in Settings.';

  @override
  String get projectWizardFieldIdsTitle => 'Set up field IDs';

  @override
  String projectWizardFieldIdsLoadError(String error) {
    return 'Could not load field ID settings: $error';
  }

  @override
  String get projectWizardFieldIdsBody =>
      'Choose how specimen field IDs are generated. You can change this later in Settings > Catalogs > Specimens.';

  @override
  String get projectWizardCatalogerRequired =>
      'A registered cataloger is required';

  @override
  String get projectWizardCatalogerRequiredBody =>
      'Next, choose an eligible cataloger or create one with initials and a current personal field number.';

  @override
  String projectWizardPrefixHint(String example) {
    return 'e.g. $example';
  }

  @override
  String get projectCurrentCatalogNumber => 'Current catalog number';

  @override
  String get projectWizardNextNumberHint => 'Enter the next number';

  @override
  String get projectWizardCurrentNumberRequired => 'Enter a current number';

  @override
  String get projectWizardAutoIncrementCatalog =>
      'Auto-increment catalog number';

  @override
  String projectWizardPersonnelLoadError(String error) {
    return 'Could not load personnel: $error';
  }

  @override
  String get projectWizardCreateCataloger => 'Create a cataloger';

  @override
  String get projectWizardChooseCataloger => 'Choose a cataloger';

  @override
  String get projectWizardNoCatalogerBody =>
      'No registered cataloger is available. Create one now; the role and personal field-number registration are filled automatically.';

  @override
  String get projectWizardCreateAnotherCatalogerBody =>
      'Create another cataloger. The role and personal field-number registration are filled automatically.';

  @override
  String get projectWizardChooseCatalogerBody =>
      'Choose the cataloger whose initials and current field number will be used for personnel field IDs.';

  @override
  String get projectWizardCatalogerLabel => 'Cataloger*';

  @override
  String get projectWizardCatalogerNameHint => 'Enter the cataloger name';

  @override
  String get projectWizardCurrentFieldNumberLabel => 'Current field number*';

  @override
  String get projectWizardCurrentFieldNumberHint =>
      'Enter the next personal field number';

  @override
  String get projectWizardCatalogerRoleSet => 'Specimen care role: Cataloger';

  @override
  String get projectWizardFieldNumberEnabled =>
      'Personal field-number registration enabled';

  @override
  String get projectWizardReviewImported => 'Review imported project';

  @override
  String get projectWizardReviewProject => 'Review project';

  @override
  String get projectWizardImportNote =>
      'This project-info transfer preserves the source UUID. Records, personnel, taxa, and device settings are not included.';

  @override
  String get projectName => 'Project name';

  @override
  String get projectFieldIdPrefix => 'Field ID prefix';

  @override
  String get projectFieldIdSuffix => 'Field ID suffix';

  @override
  String get projectWizardExistingCataloger => 'Existing cataloger selected';

  @override
  String get projectWizardNotConfigured => 'Not configured';

  @override
  String get projectWizardDeviceSetup => 'Device setup';

  @override
  String get projectWizardKeepCurrent => 'Keep current setting';

  @override
  String get projectWizardFieldIdMode => 'Field ID mode';

  @override
  String get projectWizardAutoIncrement => 'Auto-increment';

  @override
  String get projectOn => 'On';

  @override
  String get projectOff => 'Off';

  @override
  String get projectWizardTaxonomyReadiness => 'Taxonomy readiness';

  @override
  String get projectWizardTaxaCountUnavailable =>
      'Available taxa count is unavailable.';

  @override
  String projectWizardAvailableTaxa(int count) {
    return 'Available taxa: $count';
  }

  @override
  String get projectWizardNoTaxa => 'No taxa are available';

  @override
  String get projectWizardNoTaxaBody =>
      'Add or import taxa in the Taxon Registry before creating a new specimen record.';

  @override
  String get projectWizardSkip => 'Skip';

  @override
  String get projectWizardCreating => 'Creating…';

  @override
  String get projectWizardCatalogerNameRequired => 'Cataloger name is required';

  @override
  String get projectWizardNameTooShort => 'Name is too short';

  @override
  String get projectWizardInvalidCharacters => 'Invalid characters';

  @override
  String get projectWizardInitialsRequired => 'Initials are required';

  @override
  String get projectWizardInitialsTooShort => 'Initials are too short';

  @override
  String get projectWizardFieldNumberRequired =>
      'Current field number is required';

  @override
  String get projectWizardInvalidFieldNumber => 'Invalid field number';

  @override
  String get projectInvalidQr => 'Invalid project QR code.';

  @override
  String get projectNameRequired => 'Project name is required';

  @override
  String get projectNameTooShort => 'Project name is too short';

  @override
  String get projectNameTooLong => 'Project name is too long';

  @override
  String get projectNameInvalid => 'Project name is invalid';

  @override
  String get projectNameExists => 'Project name already exists';

  @override
  String get projectUuidExists =>
      'A project with this UUID already exists on this device.';

  @override
  String projectCreateFailed(String error) {
    return 'Could not create project: $error';
  }

  @override
  String get projectWizardChooseExisting => 'Choose existing';

  @override
  String get projectWizardCreateNewCataloger => 'Create new';

  @override
  String projectUuidValue(String uuid) {
    return 'Project UUID: $uuid';
  }

  @override
  String get projectImportInfoJson => 'Import project-info JSON';

  @override
  String get projectTransferProjectInfo => 'Project info';

  @override
  String get projectTransferTaxonomy => 'Taxonomy';

  @override
  String get projectTransferSites => 'Sites';

  @override
  String get projectTransferEvents => 'Events';

  @override
  String get projectTransferSpecimens => 'Specimens';

  @override
  String get projectTransferNarratives => 'Narratives';

  @override
  String get projectTransferCustomFields => 'Custom fields';

  @override
  String get projectTransferMedia => 'Media';

  @override
  String get projectTransferKeepCurrent => 'Keep current';

  @override
  String get projectTransferUseImported => 'Use imported';

  @override
  String get projectTransferImportAsNew => 'Import as new';

  @override
  String get projectExporting => 'Exporting project';

  @override
  String get projectExportingHint =>
      'Projects with many photos can take several minutes. Keep NAHPU open until this finishes.';

  @override
  String get projectExportAnother => 'Export another';

  @override
  String get projectExportCancelTitle => 'Cancel the export?';

  @override
  String get projectExportCancelBody =>
      'The export is still running. Leaving now cancels it and no file will be saved.';

  @override
  String get projectExportKeepExporting => 'Keep exporting';

  @override
  String get projectExportCancel => 'Cancel export';

  @override
  String projectOpenFolderFailed(String error) {
    return 'Unable to open the folder: $error';
  }

  @override
  String projectSaveCopyFailed(String error) {
    return 'Unable to save a copy: $error';
  }

  @override
  String get projectExportArchiveTitle => 'Backup and transfer archive';

  @override
  String get projectExportArchiveBody =>
      'Use this archive as a project backup, or to transfer this project to another device and merge it there.';

  @override
  String get projectExportLight => 'Light export';

  @override
  String get projectExportLightBody =>
      'Export the project without media files for limited-internet uploads. Use TAR.GZ or ZIP for a full project backup.';

  @override
  String get projectExportArchiveContents => 'Archive contents';

  @override
  String get projectExportExcluded => 'Excluded';

  @override
  String get projectExportMediaSize => 'Media size';

  @override
  String projectWarningCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count warnings',
      one: '1 warning',
    );
    return '$_temp0';
  }

  @override
  String get projectTransferFileAndSafety => 'File and safety';

  @override
  String get projectTransferReviewImport => 'Review and import';

  @override
  String get projectTransferReviewMerge => 'Review and merge';

  @override
  String get projectTransferResult => 'Result';

  @override
  String get projectTransferChooseFirst => 'Choose a project transfer first';

  @override
  String get projectTransferChooseFirstBody =>
      'Return to File and safety to select an archive.';

  @override
  String get projectTransferChooseTitle => 'Choose a NAHPU project transfer';

  @override
  String get projectTransferChooseBody =>
      'Project transfers can be JSON.GZ, ZIP, or TAR.GZ. JSON.GZ contains records only. ZIP and TAR.GZ include media.';

  @override
  String get projectTransferReadingArchive => 'Reading archive';

  @override
  String get projectTransferReadingArchiveHint =>
      'Transfers that include media can take several minutes to unpack. Keep NAHPU open.';

  @override
  String get projectTransferChooseArchive => 'Choose archive';

  @override
  String get projectTransferChooseAnotherArchive => 'Choose another archive';

  @override
  String get projectTransferBackupBeforeImport => 'Back up before importing';

  @override
  String get projectTransferBackupBeforeMerge => 'Back up before merging';

  @override
  String get projectTransferBackupBody =>
      'A database backup gives you a recovery point if imported changes are not what you expected.';

  @override
  String get projectTransferBackupNow => 'Back up now';

  @override
  String get projectTransferBackupAckImport =>
      'I understand that I should keep a backup before importing.';

  @override
  String get projectTransferBackupAckMerge =>
      'I understand that I should keep a backup before merging.';

  @override
  String get projectTransferNewIdentity => 'New project identity';

  @override
  String projectTransferArchiveUuid(String uuid) {
    return 'Archive UUID: $uuid';
  }

  @override
  String get projectTransferDestinationName => 'Destination project name';

  @override
  String get projectTransferDestinationNameHelper =>
      'Names the new project on this device. The archive is not changed.';

  @override
  String projectTransferNameConflict(String name) {
    return 'A project named “$name” already exists. Choose another name. If these are copies of the same project, cancel and use Merge project instead.';
  }

  @override
  String get projectTransferAlreadyExists => 'This project already exists';

  @override
  String get projectTransferAlreadyExistsBody =>
      'Matching UUIDs identify the same project. Import is blocked. Merge this archive into the existing project instead.';

  @override
  String get projectTransferOpenMerge => 'Open Merge project';

  @override
  String get projectTransferUuidMismatch => 'Project UUID does not match';

  @override
  String projectTransferUuidMismatchBody(String archive, String active) {
    return 'Archive: $archive\nActive project: $active';
  }

  @override
  String get projectTransferForceMerge => 'Force merge into the active project';

  @override
  String get projectTransferForceMergeBody =>
      'Imported project-scoped records will use the active project UUID. Conflicts still require the choices shown later.';

  @override
  String projectTransferTypeToConfirm(String name) {
    return 'Type “$name” to confirm';
  }

  @override
  String get projectCatalogNumberPrefix => 'Catalog number prefix';

  @override
  String get projectCatalogNumberSuffix => 'Catalog number suffix';

  @override
  String get projectTransferProjectInfoBody =>
      'Current values are kept by default. Select individual imported values when you want to replace them.';

  @override
  String get projectTransferKeepAllCurrent => 'Keep all current';

  @override
  String get projectTransferUseAllImported => 'Use all imported';

  @override
  String get projectTransferReviewMatches =>
      'Review matches before continuing. “Keep current” maps imported dependencies to the existing record without replacing it.';

  @override
  String get projectTransferBulkTooltip =>
      'Apply one choice to all matched records';

  @override
  String projectTransferActionForAll(String action) {
    return '$action for all';
  }

  @override
  String get projectTransferBulkAction => 'Bulk action';

  @override
  String get projectTransferStatusNew => 'New';

  @override
  String get projectTransferStatusMatched => 'Matched';

  @override
  String get projectTransferNeedsAttention => 'Needs attention';

  @override
  String get projectTransferSkipped => 'Skipped';

  @override
  String get projectTransferNoConflicts => 'No conflicts';

  @override
  String get projectTransferNoConflictsBody =>
      'All records in this section can be imported as new.';

  @override
  String get projectTransferReviewBody =>
      'Nothing has been written yet. The database changes will be committed together; a failure rolls them all back.';

  @override
  String get projectTransferSourceProject => 'Source project';

  @override
  String get projectTransferDestination => 'Destination';

  @override
  String get projectTransferUuidHandling => 'UUID handling';

  @override
  String projectTransferNewUuid(String uuid) {
    return 'New project UUID: $uuid';
  }

  @override
  String get projectTransferForceMergeUuid => 'Force merge into active UUID';

  @override
  String get projectTransferMatchingUuid => 'Matching project UUID';

  @override
  String get projectTransferConflicts => 'Conflicts';

  @override
  String get projectTransferMediaFiles => 'Media files';

  @override
  String get projectTransferResolveConflicts =>
      'Resolve conflicts before merging';

  @override
  String projectTransferDuplicateIdentifiers(String sections) {
    return 'Duplicate identifiers still need an action in $sections.';
  }

  @override
  String get projectTransferArchiveWarnings => 'Archive warnings';

  @override
  String get projectTransferImportUnfinished => 'Import did not finish';

  @override
  String get projectTransferMergeUnfinished => 'Merge did not finish';

  @override
  String get projectTransferImportRetry =>
      'Return to Review and import and try again.';

  @override
  String get projectTransferMergeRetry =>
      'Return to Review and merge and try again.';

  @override
  String get projectTransferImported => 'Project imported';

  @override
  String get projectTransferMerged => 'Project data merged';

  @override
  String get projectTransferCountImported => 'Imported';

  @override
  String get projectTransferCountMerged => 'Merged';

  @override
  String get projectTransferCountUpdated => 'Updated';

  @override
  String get projectTransferSkippedOnConflict => 'Skipped on conflict';

  @override
  String get projectTransferMediaCopied => 'Media copied';

  @override
  String get projectTransferWarnings => 'Warnings';

  @override
  String get projectTransferConflict => 'Conflict';

  @override
  String get projectTransferCurrent => 'Current';

  @override
  String get projectTransferConflictAction => 'Conflict action';

  @override
  String get projectTransferChooseAction => 'Choose an action';

  @override
  String get projectTransferChooseActionToContinue =>
      'Choose an action to continue';

  @override
  String get projectTransferNotSet => 'Not set';

  @override
  String get projectTransferNoDetails => 'No details';

  @override
  String get projectBatchSpecimenParts => 'Specimen parts';

  @override
  String get projectBatchParasites => 'Parasites';

  @override
  String get projectBatchNarrative => 'Narrative';

  @override
  String get projectBatchModeUpdate => 'Update existing records';

  @override
  String get projectBatchModeCreate => 'Import new records';

  @override
  String get projectBatchHeaderAuto => 'Auto';

  @override
  String get projectBatchDarwinCore => 'Darwin Core';

  @override
  String get projectBatchHeaderNames => 'Column names';

  @override
  String get projectBatchKeySpecimenUuid => 'Specimen UUID';

  @override
  String get projectBatchKeyCatalogNumber => 'Catalog number';

  @override
  String get projectBatchKeyCatalogerFieldNumber =>
      'Cataloger and field number';

  @override
  String get projectBatchKeyTissueId => 'Tissue ID';

  @override
  String get projectBatchKeyBarcodeId => 'Barcode ID';

  @override
  String get projectBatchKeyParasiteId => 'Parasite ID';

  @override
  String get projectBatchKeyParasiteUuid => 'Parasite UUID';

  @override
  String get projectBatchKeySiteId => 'Site ID';

  @override
  String get projectBatchKeyEventId => 'Event ID';

  @override
  String get projectBatchKeyNarrativeDate => 'Narrative date';

  @override
  String get projectBatchStatusReady => 'Ready';

  @override
  String get projectBatchStatusMissingLink => 'Missing link';

  @override
  String get projectBatchStatusNoMatch => 'No match';

  @override
  String get projectBatchStatusAmbiguous => 'Several matches';

  @override
  String get projectBatchStatusExists => 'Already in project';

  @override
  String get projectBatchStatusDuplicateInFile => 'Repeated in file';

  @override
  String get projectBatchStatusInvalid => 'Invalid values';

  @override
  String get projectBatchUpdateRecords => 'Update records';

  @override
  String get projectBatchImportRecords => 'Import records';

  @override
  String get projectBatchStepMode => 'Mode';

  @override
  String get projectBatchStepFile => 'File';

  @override
  String get projectBatchStepColumns => 'Columns';

  @override
  String get projectBatchStepGroups => 'Groups';

  @override
  String get projectBatchUnsupportedFile => 'Choose a CSV, TSV, or Excel file.';

  @override
  String get projectBatchModeTitle => 'What do you want to do?';

  @override
  String get projectBatchModeBody =>
      'Bring records in from a CSV, TSV, or Excel file. Columns can use Darwin Core terms or your own names.';

  @override
  String get projectBatchModeCreateBody =>
      'Add one record per row. Taxa, personnel, sites, and events are linked when they are already in the project.';

  @override
  String get projectBatchModeUpdateBody =>
      'Match each row to a record by a key column, such as a catalog number, and write the other columns. Blank cells are left unchanged.';

  @override
  String get projectBatchRecords => 'Records';

  @override
  String get projectBatchLinkedRecords => 'Linked records';

  @override
  String get projectBatchLinkedRecordsBody =>
      'Each row can describe a site, its collecting event, a specimen, and a part. Rows are grouped into sites and events, which you can check before importing.';

  @override
  String get projectBatchChooseFile => 'Choose a file';

  @override
  String get projectBatchChooseFileBody =>
      'The first row must hold the column names. Each row after it is one record.';

  @override
  String get projectBatchSheet => 'Sheet';

  @override
  String projectBatchTableSize(int rows, int columns) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: '$rows rows',
      one: '1 row',
    );
    String _temp1 = intl.Intl.pluralLogic(
      columns,
      locale: localeName,
      other: '$columns columns',
      one: '1 column',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get projectBatchMatchColumns => 'Match columns';

  @override
  String projectBatchMatchColumnsBody(int mapped, int total) {
    return '$mapped of $total columns match a field. Change any match, or skip a column. Your changes are remembered for files with the same columns.';
  }

  @override
  String get projectBatchKeyColumn => 'Key column';

  @override
  String projectBatchKeyColumnMissing(String keys) {
    return 'Map a column to one of: $keys.';
  }

  @override
  String get projectBatchKeyColumnBody =>
      'Rows update the record with the same value.';

  @override
  String get projectBatchMatchRecordsBy => 'Match records by';

  @override
  String get projectBatchNoValues => 'No values';

  @override
  String get projectBatchNahpuField => 'NAHPU field';

  @override
  String get projectBatchSkipColumn => 'Skip column';

  @override
  String projectBatchFieldInUse(String field) {
    return '$field (in use)';
  }

  @override
  String get projectBatchNameMatch => 'Name match';

  @override
  String projectBatchCloseMatch(int percent) {
    return 'Close match $percent%';
  }

  @override
  String get projectBatchSkippedByYou => 'Skipped by you';

  @override
  String get projectBatchYourChoice => 'Your choice';

  @override
  String get projectBatchSearch => 'Search';

  @override
  String projectBatchLoadRecordsFailed(String error) {
    return 'Couldn\'t load records: $error';
  }

  @override
  String get projectBatchNoMatchingRecords => 'No matching records.';

  @override
  String get projectBatchNoOtherGroup =>
      'There is no other group to merge with.';

  @override
  String get projectBatchMoveToNewGroup => 'Move to new group';

  @override
  String get projectBatchCheckGroups => 'Check groups';

  @override
  String get projectBatchCheckGroupsBody =>
      'Rows that describe the same site or event are grouped. Link a group to a record the project has, merge groups that are the same place or visit, or split rows out.';

  @override
  String projectBatchSitesCount(int count) {
    return 'Sites ($count)';
  }

  @override
  String projectBatchEventsCount(int count) {
    return 'Events ($count)';
  }

  @override
  String projectBatchSpecimensCount(int count) {
    return 'Specimens ($count)';
  }

  @override
  String get projectBatchNoSiteColumns => 'No columns describe a site.';

  @override
  String get projectBatchNoEventColumns => 'No columns describe an event.';

  @override
  String get projectBatchNoSpecimenColumns => 'No columns describe a specimen.';

  @override
  String get projectBatchNewSite => 'New site';

  @override
  String projectBatchEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String projectBatchSpecimenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count specimens',
      one: '1 specimen',
    );
    return '$_temp0';
  }

  @override
  String projectBatchPartCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parts',
      one: '1 part',
    );
    return '$_temp0';
  }

  @override
  String projectBatchParasiteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parasites',
      one: '1 parasite',
    );
    return '$_temp0';
  }

  @override
  String get projectBatchSetSiteId => 'Set site ID';

  @override
  String get projectBatchLinkSite => 'Link to an existing site';

  @override
  String get projectBatchMergeIntoSite => 'Merge into site';

  @override
  String get projectBatchMoveRowsToSite => 'Move rows to a new site';

  @override
  String projectBatchRow(String row) {
    return 'Row $row';
  }

  @override
  String projectBatchRows(String rows) {
    return 'Rows $rows';
  }

  @override
  String projectBatchRowsMore(int count, String rows) {
    return 'Rows $rows and $count more';
  }

  @override
  String get projectBatchNoSite => 'No site';

  @override
  String get projectBatchNoEvent => 'No event';

  @override
  String projectBatchEventLabel(String event) {
    return 'Event: $event';
  }

  @override
  String get projectBatchSetIdSuffix => 'Set ID suffix';

  @override
  String get projectBatchLinkEvent => 'Link to an existing event';

  @override
  String get projectBatchSetEventIdSuffix => 'Set event ID suffix';

  @override
  String get projectBatchMergeIntoEvent => 'Merge into event';

  @override
  String get projectBatchMoveRowsToEvent => 'Move rows to a new event';

  @override
  String get projectBatchExcluded => 'Excluded';

  @override
  String get projectBatchCheck => 'Check';

  @override
  String get projectBatchLinksToExisting => 'Links to existing';

  @override
  String get projectBatchChangeGroup => 'Change group';

  @override
  String get projectBatchLinkExisting => 'Link to existing…';

  @override
  String get projectBatchCreateNew => 'Create new instead';

  @override
  String get projectBatchMergeInto => 'Merge into…';

  @override
  String get projectBatchSplitRows => 'Split rows…';

  @override
  String get projectBatchLinkedReviewBody =>
      'Sites are written first, then events at them, then specimens and their parts.';

  @override
  String projectBatchSitesSummary(int created, int linked) {
    return 'Sites: $created new, $linked linked';
  }

  @override
  String projectBatchEventsSummary(int created, int linked) {
    return 'Events: $created new, $linked linked';
  }

  @override
  String projectBatchSpecimensSummary(int count) {
    return 'Specimens: $count';
  }

  @override
  String projectBatchPartsSummary(int count) {
    return 'Parts: $count';
  }

  @override
  String projectBatchParasitesSummary(int count) {
    return 'Parasites: $count';
  }

  @override
  String projectBatchRowsSkipped(int count) {
    return 'Rows skipped: $count';
  }

  @override
  String get projectBatchImportSpecimensMissingLinks =>
      'Import specimens with missing links';

  @override
  String get projectBatchImportSpecimensMissingLinksBody =>
      'The taxon or person stays empty. Add it to the project first to link it.';

  @override
  String projectBatchWritingRecords(int done, int total) {
    return 'Writing $done of $total records';
  }

  @override
  String projectBatchWritingRows(int done, int total) {
    return 'Writing $done of $total rows';
  }

  @override
  String get projectBatchNoProblems => 'No problems found.';

  @override
  String projectBatchMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'And $count more rows.',
      one: 'And 1 more row.',
    );
    return '$_temp0';
  }

  @override
  String projectBatchSiteProblem(String site, String message) {
    return 'Site $site: $message';
  }

  @override
  String projectBatchSpecimenSkipped(String status) {
    return 'Specimen skipped: $status.';
  }

  @override
  String get projectBatchExcludedRow => 'Excluded.';

  @override
  String get projectBatchDoneWithErrors => 'Done, with errors';

  @override
  String projectBatchAddedSpecimensParts(int specimens, int parts) {
    String _temp0 = intl.Intl.pluralLogic(
      specimens,
      locale: localeName,
      other: '$specimens specimens',
      one: '1 specimen',
    );
    String _temp1 = intl.Intl.pluralLogic(
      parts,
      locale: localeName,
      other: '$parts parts',
      one: '1 part',
    );
    return 'Added $_temp0 and $_temp1.';
  }

  @override
  String projectBatchRowsWithErrors(int count) {
    return 'Rows with errors: $count';
  }

  @override
  String get projectBatchOpenSpecimenTable => 'Open specimen records table';

  @override
  String projectBatchUpdatedRecords(int count, String records) {
    return 'Updated $count $records.';
  }

  @override
  String projectBatchAddedRecords(int count, String records) {
    return 'Added $count $records.';
  }

  @override
  String projectBatchUpdatedCount(int count) {
    return 'Updated: $count';
  }

  @override
  String projectBatchAddedCount(int count) {
    return 'Added: $count';
  }

  @override
  String projectBatchSkippedInReview(int count) {
    return 'Skipped in review: $count';
  }

  @override
  String projectBatchFailedCount(int count) {
    return 'Failed: $count';
  }

  @override
  String projectBatchOpenTable(String records) {
    return 'Open $records table';
  }

  @override
  String projectBatchReviewUpdate(int count, int total, String records) {
    return 'This will update $count of $total $records. Rows with problems are skipped.';
  }

  @override
  String projectBatchReviewAdd(int count, int total, String records) {
    return 'This will add $count of $total $records. Rows with problems are skipped.';
  }

  @override
  String get projectBatchImportRowsMissingLinks =>
      'Import rows with missing links';

  @override
  String get projectBatchImportRowsMissingLinksBody =>
      'The taxon, person, site, or event stays empty. Add it to the project first to link it.';

  @override
  String get projectStatsPartQuantity => 'Part quantity';

  @override
  String get projectStatsQuantity => 'Quantity';

  @override
  String get projectStatsSite => 'Site';

  @override
  String get projectStatsDate => 'Date';

  @override
  String get projectStatsMethod => 'Method';

  @override
  String get projectStatsSex => 'Sex';

  @override
  String get projectStatsLifeStage => 'Life stage';

  @override
  String get projectStatsPartType => 'Part type';

  @override
  String get projectStatsTreatment => 'Treatment';

  @override
  String get projectStatsParasiteTaxon => 'Parasite taxon';

  @override
  String get projectStatsParasiteCategory => 'Category';

  @override
  String get projectStatsAnatomicalLocation => 'Anatomical location';

  @override
  String get projectStatsHostSpecies => 'Host species';

  @override
  String projectStatsTitle(String measure, String category) {
    return '$measure by $category';
  }

  @override
  String projectStatsTitleWithBreakdown(
    String measure,
    String category,
    String breakdown,
  ) {
    return '$measure by $category and $breakdown';
  }

  @override
  String projectStatsTitleAtSite(String title, String site) {
    return '$title at $site';
  }

  @override
  String projectStatsTitleForSpecies(String title, String species) {
    return '$title for $species';
  }

  @override
  String get projectStatsCoordinatesBySpecies => 'Coordinates by species';

  @override
  String get projectStatsSpatialSpecimensTitle =>
      'Specimen counts by site coordinates';

  @override
  String get projectStatsSpatialSpeciesTitle =>
      'Species counts by site coordinates';

  @override
  String get projectStatsSpatialFamiliesTitle =>
      'Family counts by site coordinates';

  @override
  String get projectStatsSpatialSelectedSpeciesTitle =>
      'Selected species counts by coordinates';

  @override
  String get projectStatsCountSpecimens => 'specimens';

  @override
  String get projectStatsCountSpecies => 'species';

  @override
  String get projectStatsCountFamilies => 'families';

  @override
  String get projectStatsClasses => 'Classes';

  @override
  String get projectStatsOrders => 'Orders';

  @override
  String get projectStatsFamilies => 'Families';

  @override
  String get projectStatsGenera => 'Genera';

  @override
  String get projectStatsSpecimenMedia => 'Specimen media';

  @override
  String get projectStatsSiteMedia => 'Site media';

  @override
  String get projectStatsEventMedia => 'Event media';

  @override
  String get projectStatsNarrativeMedia => 'Narrative media';

  @override
  String get projectStatsRecordedSites => 'Recorded sites';

  @override
  String get projectStatsSampledSites => 'Sampled sites';

  @override
  String get projectStatsCaptureDays => 'Capture days';

  @override
  String get projectStatsProjectDays => 'Project days';

  @override
  String get projectStatsRecordedElevation => 'Recorded elevation';

  @override
  String get projectStatsSampledElevation => 'Sampled elevation';

  @override
  String get projectStatsNotRecorded => 'Not recorded';

  @override
  String get projectStatsRecordStatistics => 'Record statistics';

  @override
  String get projectStatsTopSpecies => 'Top recorded species';

  @override
  String get projectStatsRecordCounts => 'Record counts';

  @override
  String get projectStatsShowRecordCounts => 'Show record counts';

  @override
  String get projectStatsShowTopSpecies => 'Show top recorded species';

  @override
  String get projectStatsExploreMore => 'Explore more stats';

  @override
  String projectStatsRecordLoadError(String error) {
    return 'Unable to load record statistics: $error';
  }

  @override
  String get projectStatsSummary => 'Summary';

  @override
  String get projectStatsExplore => 'Explore';

  @override
  String get projectStatsTotalAllProjects => 'Total across all projects';

  @override
  String get projectStatsGroupBy => 'Group by';

  @override
  String get projectStatsSelectSite => 'Select a site';

  @override
  String get projectStatsAllSites => 'All sites';

  @override
  String get projectStatsSelectSpecies => 'Select a species';

  @override
  String get projectStatsAllSpecies => 'All species';

  @override
  String get projectStatsChart => 'Chart';

  @override
  String get projectStatsTable => 'Table';

  @override
  String get projectStatsRecordSummary => 'Record summary';

  @override
  String get projectStatsTaxonomicBreakdown => 'Taxonomic breakdown';

  @override
  String get projectStatsMediaBreakdown => 'Media breakdown';

  @override
  String get projectStatsPerProject => 'Per project';

  @override
  String get projectStatsNoProjects => 'No projects yet.';

  @override
  String projectStatsProjectLoadError(String error) {
    return 'Unable to load project statistics: $error';
  }

  @override
  String get projectStatsViewDetails => 'View details';

  @override
  String get projectStatsBreakDownBy => 'Break down by';

  @override
  String projectStatsLoadError(String error) {
    return 'Unable to load statistics: $error';
  }

  @override
  String get projectStatsSpecimensBySpecies => 'Specimens by species';

  @override
  String get projectStatsSpecimensByFamily => 'Specimens by family';

  @override
  String get projectStatsSpecimensBySite => 'Specimens by site';

  @override
  String get projectStatsSpecimensByDate => 'Specimens by date';

  @override
  String get projectStatsSpecimensByMethod => 'Specimens by method';

  @override
  String get projectStatsSpecimensBySex => 'Specimens by sex';

  @override
  String get projectStatsPartQuantityByType => 'Part quantity by type';

  @override
  String get projectStatsPartQuantityByTreatment =>
      'Part quantity by treatment';

  @override
  String get projectStatsCounts => 'Counts';

  @override
  String get projectStatsSpatial => 'Spatial';

  @override
  String get projectStatsNetwork => 'Network';

  @override
  String get projectStatsNetworkTitle => 'Records linked through specimens';

  @override
  String get projectStatsNetworkHint =>
      'Tap a record to show what links to it.';

  @override
  String get projectStatsNetworkRadial => 'Radial';

  @override
  String get projectStatsNetworkLayered => 'Layered';

  @override
  String get projectStatsNetworkStartFrom => 'Start from';

  @override
  String get projectStatsNetworkColumns => 'Columns';

  @override
  String get projectStatsNetworkFit => 'Fit to view';

  @override
  String get projectStatsNetworkReset => 'Reset';

  @override
  String get projectStatsNetworkFullScreen => 'View network full screen';

  @override
  String projectStatsNetworkLoadError(String error) {
    return 'Unable to load the network: $error';
  }

  @override
  String get projectStatsNetworkEmpty => 'No specimens to link yet.';

  @override
  String projectStatsNetworkMore(int count) {
    return '+$count more';
  }

  @override
  String projectStatsNetworkSpecimens(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count specimens',
      one: '1 specimen',
    );
    return '$_temp0';
  }

  @override
  String projectStatsNetworkShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shared specimens',
      one: '1 shared specimen',
    );
    return '$_temp0';
  }

  @override
  String projectStatsNetworkRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
    );
    return '$_temp0';
  }

  @override
  String get projectStatsNetworkShowLinks => 'Show links';

  @override
  String get projectStatsNetworkHideLinks => 'Hide links';

  @override
  String get projectStatsNetworkShowMore => 'Show more';

  @override
  String get projectStatsNetworkSites => 'Sites';

  @override
  String get projectStatsNetworkEvents => 'Events';

  @override
  String get projectStatsNetworkSpecimenType => 'Specimens';

  @override
  String get projectStatsNetworkTaxa => 'Species';

  @override
  String get projectStatsNetworkCollectors => 'Collectors';

  @override
  String get projectStatsNetworkMedia => 'Media';

  @override
  String get projectStatsNetworkLegend => 'Record types';

  @override
  String get projectStatsNoData => 'No data to display';

  @override
  String projectStatsTapToView(String label) {
    return '$label\nTap to view records';
  }

  @override
  String get projectStatsShowBarChart => 'Show bar chart';

  @override
  String get projectStatsShowPieChart => 'Show pie chart';

  @override
  String get projectStatsClearSelection => 'Clear selection';

  @override
  String projectStatsChoicesLoadError(String error) {
    return 'Unable to load choices: $error';
  }

  @override
  String get projectStatsNoMatchingChoices => 'No matching choices';

  @override
  String get projectStatsNoRecordsInGroup => 'No records in this group.';

  @override
  String get projectStatsShow => 'Show';

  @override
  String projectStatsSpeciesCountsByCoordinates(String species) {
    return '$species counts by coordinates';
  }

  @override
  String get projectStatsMap => 'Map';

  @override
  String projectStatsSpatialLoadError(String error) {
    return 'Unable to load spatial statistics: $error';
  }

  @override
  String get projectStatsNoSpecimenCoords =>
      'No specimens are assigned to project coordinates.';

  @override
  String get projectStatsNoSpeciesCoords =>
      'No species are associated with project coordinates.';

  @override
  String get projectStatsNoFamilyCoords =>
      'No families are associated with project coordinates.';

  @override
  String get projectStatsNoSelectedSpeciesCoords =>
      'No specimens of the selected species are assigned to project coordinates.';

  @override
  String projectStatsNoSpeciesCoordsFor(String species) {
    return 'No specimens of $species are assigned to project coordinates.';
  }

  @override
  String projectStatsCoordinateLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Coordinates',
      one: 'Coordinate',
    );
    return '$_temp0';
  }

  @override
  String projectStatsMeanPerCoordinate(String counted) {
    return 'Mean $counted per coordinate';
  }

  @override
  String get projectStatsTopCoordinate => 'Top coordinate';

  @override
  String projectStatsTopValue(String name) {
    return 'Top: $name';
  }

  @override
  String projectStatsCategoryCount(int count, String category) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Categories ($category)',
      one: 'Category ($category)',
    );
    return '$_temp0';
  }

  @override
  String projectStatsMeanPerCategory(String counted) {
    return 'Mean $counted per category';
  }

  @override
  String get projectStatsTopCategory => 'Top category';

  @override
  String get projectStatsTopCategoryShare => 'Top category share';

  @override
  String projectStatsTotalCount(String value) {
    return 'Total count: $value';
  }

  @override
  String get projectStatsElevation => 'Elevation';

  @override
  String get projectStatsSelectSpeciesPrompt =>
      'Select a species to view coordinate abundance.';

  @override
  String get projectStatsCollapseLegend => 'Collapse map legend';

  @override
  String get projectStatsExpandLegend => 'Expand map legend';

  @override
  String get projectStatsLegend => 'Legend';

  @override
  String get projectStatsLegendCircle =>
      'Each circle represents\none coordinate';

  @override
  String get projectStatsLegendGrouped => 'Grouped sites,\nzoom in to split';

  @override
  String projectStatsUnmappedRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count records are listed in the table but cannot be mapped because latitude or longitude is missing or invalid.',
      one:
          '1 record is listed in the table but cannot be mapped because latitude or longitude is missing or invalid.',
    );
    return '$_temp0';
  }

  @override
  String get projectStatsSpatialMap => 'Spatial statistics map';

  @override
  String get projectStatsMapLayers => 'Map layers';

  @override
  String get projectStatsViewFullScreen => 'View map full screen';

  @override
  String get projectStatsNaturalEarthError =>
      'Unable to load the offline Natural Earth map.';

  @override
  String get projectStatsNoValidCoordinates =>
      'No valid coordinates are available to map.';

  @override
  String projectStatsMapPrepareError(String error) {
    return 'Unable to prepare the map: $error';
  }

  @override
  String get projectStatsZoomIn => 'Zoom in';

  @override
  String get projectStatsZoomOut => 'Zoom out';

  @override
  String get projectStatsCenterMap => 'Center map on statistics';

  @override
  String projectStatsSiteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sites',
      one: '1 site',
    );
    return '$_temp0';
  }

  @override
  String get projectStatsExportTable => 'Export table';

  @override
  String get projectStatsColumnName => 'Name';

  @override
  String get projectStatsColumnLocality => 'Locality';

  @override
  String get projectStatsColumnDecimalLatitude => 'Decimal latitude';

  @override
  String get projectStatsColumnDecimalLongitude => 'Decimal longitude';

  @override
  String get projectStatsColumnElevation => 'Elevation (m)';

  @override
  String get projectStatsColumnDatum => 'Datum';

  @override
  String get projectStatsColumnUncertainty => 'Uncertainty (m)';

  @override
  String get projectStatsColumnGpsUnit => 'GPS unit';

  @override
  String get projectStatsColumnLatitude => 'Latitude';

  @override
  String get projectStatsColumnLongitude => 'Longitude';

  @override
  String get projectStatsColumnCount => 'Count';

  @override
  String get projectStatsColumnPercent => 'Percent';

  @override
  String get projectStatsColumnCategory => 'Category';

  @override
  String get projectStatsViewRecords => 'View records';

  @override
  String get projectStatsExportStatisticsTable => 'Export statistics table';

  @override
  String get projectStatsExportSpatialTable =>
      'Export spatial statistics table';

  @override
  String projectStatsExportError(String error) {
    return 'Unable to export statistics: $error';
  }

  @override
  String get projectStatsExportComplete => 'Export complete';

  @override
  String projectStatsShareError(String error) {
    return 'Unable to share statistics: $error';
  }

  @override
  String get projectTissueMuseumPermanent => 'Museum permanent';

  @override
  String get projectTissueMuseumLoan => 'Museum loan';

  @override
  String get projectTissueIdOrBarcode => 'Tissue ID or barcode';

  @override
  String get projectTissueFillRows => 'Rows, left to right';

  @override
  String get projectTissueFillColumns => 'Columns, top to bottom';

  @override
  String get projectTissueFillSerpentine => 'Serpentine rows';

  @override
  String get projectTissueEntryScan => 'Scan';

  @override
  String get projectTissueEntryWorkList => 'Work list';

  @override
  String get projectTissueTitle => 'Specimen curation';

  @override
  String projectTissueFilledCount(int filled, int capacity) {
    return '$filled / $capacity filled';
  }

  @override
  String get projectTissueNextCell => 'Next cell';

  @override
  String get projectTissueFull => 'Full';

  @override
  String get projectTissueNextBox => 'Next box';

  @override
  String get projectTissueFilled => 'Filled';

  @override
  String get projectTissueNext => 'Next';

  @override
  String get projectTissueScanTubes => 'Scan tubes';

  @override
  String get projectTissueCameraUnavailable =>
      'Camera scanning is unavailable. Use the scan field instead.';

  @override
  String get projectTissueCameraError =>
      'Unable to use the camera. Retry or use the scan field.';

  @override
  String get projectTissueSessionLog => 'Session log';

  @override
  String projectTissueSessionLogCount(int count) {
    return 'Session log ($count)';
  }

  @override
  String get projectTissueSessionLogEmpty => 'Checked tubes appear here.';

  @override
  String projectTissueSeveralMatches(String code) {
    return 'Several parts match $code';
  }

  @override
  String projectTissueCount(String count) {
    return 'Count $count';
  }

  @override
  String projectTissueAt(String location) {
    return 'At $location';
  }

  @override
  String get projectTissueFindTubes => 'Find tubes';

  @override
  String get projectTissueType => 'Tissue type';

  @override
  String get projectTissuePreservation => 'Preservation';

  @override
  String get projectTissueUpdateField => 'Update field';

  @override
  String get projectTissueField => 'Field';

  @override
  String get projectTissueValue => 'Value';

  @override
  String get projectTissueMuseumCode => 'Museum code';

  @override
  String get projectTissueBoxSize => 'Box size';

  @override
  String get projectTissueNumbering => 'Numbering';

  @override
  String get projectTissueFillOrder => 'Fill order';

  @override
  String get projectTissueBoxLabel => 'Box label';

  @override
  String get projectTissueBoxHint => 'Box';

  @override
  String get projectTissueBoxNumber => 'Box number';

  @override
  String get projectTissueOverwrite => 'Overwrite existing values';

  @override
  String get projectTissueOverwriteBody =>
      'Replace a stored location or a different field value';

  @override
  String get projectTissueTabBox => 'Box';

  @override
  String get projectTissueTabSetup => 'Setup';

  @override
  String projectTissueTabLog(int count) {
    return 'Log ($count)';
  }

  @override
  String get projectTissueFindTubesBody =>
      'Which tubes the scan and work list match.';

  @override
  String get projectTissueUpdateFieldBody => 'Written to each tube you place.';

  @override
  String get projectTissueBoxSectionBody =>
      'Size, fill order, and the box being filled.';

  @override
  String get projectTissueAdvanced => 'Labels and overwrite';

  @override
  String get projectTissueAdvancedBody =>
      'Cell label format and how stored values are handled.';

  @override
  String get projectTissueExportLog => 'Export log';

  @override
  String get projectTissueExportLogTitle => 'Export session log';

  @override
  String projectTissueExportSummary(int checked, int skipped) {
    return '$checked checked, $skipped skipped';
  }

  @override
  String get projectTissueLogStatusChecked => 'Checked';

  @override
  String get projectTissueLogStatusSkipped => 'Skipped';

  @override
  String get projectTissuePart => 'Part';

  @override
  String get projectTissueColStatus => 'Status';

  @override
  String get projectTissueColOrder => 'Order';

  @override
  String get projectTissueColFieldId => 'Field ID';

  @override
  String get projectTissueColTubeId => 'Tube ID';

  @override
  String get projectTissueColKind => 'Kind';

  @override
  String get projectTissueColType => 'Type';

  @override
  String get projectTissueColTreatment => 'Treatment';

  @override
  String get projectTissueColField => 'Updated field';

  @override
  String get projectTissueColValue => 'Value';

  @override
  String get projectTissueColLocation => 'Location';

  @override
  String get projectTissueColBox => 'Box';

  @override
  String get projectTissueColCell => 'Cell';

  @override
  String get projectTissueColPreviousValue => 'Previous value';

  @override
  String get projectTissueColPreviousLocation => 'Previous location';

  @override
  String get projectTissueLogColumns => 'Columns';

  @override
  String get projectTissueLogColumnsBody =>
      'Curation columns always come first. Add part, specimen, and linked record fields after them.';

  @override
  String get projectTissueLogAddColumns => 'Add columns';

  @override
  String get projectTissueLogAddedColumns => 'Added columns';

  @override
  String get projectTissueLogNoAddedColumns =>
      'No added columns. The export has the curation columns only.';

  @override
  String get projectTissueLogHeaderStyle => 'Added column headers';

  @override
  String get projectTissueLogHeaderFieldName => 'Field names';

  @override
  String get projectTissueLogHeaderKey => 'NAHPU keys';

  @override
  String get projectTissueLogChooseColumns => 'Choose columns';

  @override
  String projectTissueLogRemoveColumn(String name) {
    return 'Remove $name';
  }

  @override
  String projectTissueLogSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get projectTissueReplace => 'Replace';

  @override
  String projectTissueReplaceTitle(String cell) {
    return 'Replace $cell?';
  }

  @override
  String projectTissueReplaceMessage(int count, String cell, String labels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The next tube you scan or place goes into $cell. $labels lose their location and return to the work list. Undo puts them back.',
      one:
          'The next tube you scan or place goes into $cell. $labels loses its location and returns to the work list. Undo puts it back.',
    );
    return '$_temp0';
  }

  @override
  String projectTissueReplacing(String labels) {
    return 'Replaces $labels';
  }

  @override
  String projectTissueReplacedLog(String labels) {
    return 'Replaced $labels';
  }

  @override
  String get projectTissueColReplaced => 'Replaced';

  @override
  String get projectTissueAny => 'Any';

  @override
  String get projectTissueScanTube => 'Scan tube';

  @override
  String get projectTissueScanHint => 'Scan or type, then press Enter';

  @override
  String get projectTissueScanWithCamera => 'Scan with camera';

  @override
  String get projectTissueUndo => 'Undo';

  @override
  String get projectTissueReady => 'Ready. Scan the first tube.';

  @override
  String get projectTissueWorkListEmpty =>
      'No unplaced parts match the tissue type and preservation filters.';

  @override
  String projectTissueRemaining(int count) {
    return 'Next · $count remaining';
  }

  @override
  String get projectTissuePlace => 'Place';

  @override
  String get projectTissueIncludeParasites => 'Include parasites';

  @override
  String get projectTissueWorkListSearch => 'Search work list';

  @override
  String get projectTissueNoMatches => 'No matching tubes';

  @override
  String get projectTissueParasite => 'Parasite';

  @override
  String get projectTissueParasiteCategory => 'Parasite category';

  @override
  String get projectTissueIdParasiteIdOrBarcode =>
      'Tissue ID, parasite ID, or barcode';

  @override
  String get projectTissueFieldIdOrParasiteId => 'Field ID or parasite ID';

  @override
  String get projectTissueSearchByFieldId => 'Search by field ID';

  @override
  String projectTissueLogChecked(int count) {
    return 'Checked ($count)';
  }

  @override
  String projectTissueLogSkipped(int count) {
    return 'Skipped ($count)';
  }

  @override
  String get projectTissueLogSkippedEmpty =>
      'Skipped tubes appear here until they are placed.';

  @override
  String get projectTissuePreviousBox => 'Previous box';

  @override
  String get projectTissueDetails => 'Details';

  @override
  String get projectTissueOpenRecord => 'Open record';

  @override
  String projectTissueSharedCell(int count) {
    return '$count tubes share this cell';
  }

  @override
  String get projectTissueBarcode => 'Barcode';

  @override
  String get projectTissueStorageLocation => 'Storage location';

  @override
  String get projectTissueCountLabel => 'Count';

  @override
  String get projectTissueTapCellHint =>
      'Tap an empty cell to jump, or a filled cell to see its tube';

  @override
  String get parasiteRecords => 'Parasite records';

  @override
  String get parasiteUnidentified => 'Unidentified parasite';

  @override
  String parasiteIndividuals(String ids) {
    return 'Ind: $ids';
  }

  @override
  String parasiteCount(String count) {
    return 'Count: $count';
  }

  @override
  String get parasiteNoneAdded => 'No parasites added';

  @override
  String get parasiteAdd => 'Add parasite';

  @override
  String get parasiteEdit => 'Edit parasite';

  @override
  String get parasiteDetails => 'Parasite details';

  @override
  String get parasiteCountLabel => 'Count';

  @override
  String get parasiteCountHint => 'Enter parasite count';

  @override
  String get parasiteCategory => 'Category';

  @override
  String get parasiteAnatomicalLocation => 'Anatomical location';

  @override
  String get parasiteCollectionIdentification => 'Collection & identification';

  @override
  String get parasiteCollector => 'Collector';

  @override
  String get parasiteCollectorHint => 'Select who collected the parasite';

  @override
  String get parasiteDetectionMethod => 'Detection method';

  @override
  String get parasiteDateCollected => 'Date collected';

  @override
  String get parasiteDateCollectedHint => 'Enter collection date';

  @override
  String get parasiteTimeCollected => 'Time collected';

  @override
  String get parasiteTimeCollectedHint => 'Enter collection time';

  @override
  String get parasiteDeterminer => 'Determiner';

  @override
  String get parasiteDeterminerHint => 'Select who identified the parasite';

  @override
  String get parasiteDateDetermined => 'Date determined';

  @override
  String get parasiteDateDeterminedHint => 'Enter identification date';

  @override
  String get parasiteDeterminationMethod => 'Determination method';

  @override
  String parasiteSaveError(String error) {
    return 'Unable to save parasite: $error';
  }

  @override
  String get parasiteTaxon => 'Parasite taxon';

  @override
  String get parasiteTaxonHint => 'Select a registered taxon';

  @override
  String get parasiteNotIdentified => 'Not identified';

  @override
  String parasiteTaxaLoadError(String error) {
    return 'Unable to load taxa: $error';
  }

  @override
  String get parasiteAddTaxon => 'Add taxon';

  @override
  String get parasiteNotAssigned => 'Not assigned';

  @override
  String get parasitePreparationPreservation => 'Preparation & preservation';

  @override
  String get parasitePreparationMethod => 'Preparation method';

  @override
  String get parasiteTreatment => 'Treatment';

  @override
  String get parasiteDatePreserved => 'Date preserved';

  @override
  String get parasiteDatePreservedHint => 'Enter preservation date';

  @override
  String get parasiteTimePreserved => 'Time preserved';

  @override
  String get parasiteTimePreservedHint => 'Enter preservation time';

  @override
  String get parasiteCuration => 'Curation';

  @override
  String get parasiteStorage => 'Storage';

  @override
  String get parasiteStorageLocation => 'Storage location';

  @override
  String get parasiteStorageLocationHint =>
      'Enter freezer, cabinet, shelf, or container';

  @override
  String get parasiteMuseumPermanent => 'Museum permanent';

  @override
  String get parasiteMuseumHint => 'Enter museum name or abbreviation';

  @override
  String get parasiteMuseumLoan => 'Museum loan';

  @override
  String get parasiteRemarks => 'Remarks';

  @override
  String get parasiteRemarksHint => 'Enter parasite remarks';

  @override
  String get parasiteLifeStage => 'Life stage';

  @override
  String get parasiteLifeStageHint => 'Select parasite life stage';

  @override
  String get parasiteAssociationStatus => 'Association status';

  @override
  String get parasiteAssociationStatusHint => 'Select association status';

  @override
  String parasiteFieldLoadError(String field, String error) {
    return 'Unable to load $field: $error';
  }

  @override
  String get parasiteSetOptionsInSettings => 'Set options in Specimen settings';

  @override
  String parasiteSelectField(String field) {
    return 'Select $field';
  }

  @override
  String get parasiteIds => 'IDs';

  @override
  String parasiteUuid(String uuid) {
    return 'UUID: $uuid';
  }

  @override
  String get parasiteId => 'Parasite ID';

  @override
  String get parasiteIdHint => 'Enter a user-defined parasite ID';

  @override
  String get parasiteIdOptions => 'Parasite ID options';

  @override
  String get parasiteScanCode => 'Scan QR/Barcode';

  @override
  String get parasiteNewNumber => 'New number';

  @override
  String get parasiteSettings => 'Settings';

  @override
  String get parasiteIdSettings => 'Parasite ID settings';

  @override
  String get parasitePrefix => 'Prefix';

  @override
  String get parasitePrefixHint => 'Enter parasite ID prefix';

  @override
  String get parasiteNumber => 'Number';

  @override
  String get parasiteNumberHint => 'Enter the next parasite ID number';

  @override
  String get specimenShowOutlierWarnings => 'Show outlier warnings';

  @override
  String get mammalTotalLength => 'Total length (mm)';

  @override
  String get mammalTotalLengthHint => 'Enter TTL';

  @override
  String get mammalTailLength => 'Tail length (mm)';

  @override
  String get mammalTailLengthHint => 'Enter TL';

  @override
  String get specimenAutoCalculated => 'Automatically calculated';

  @override
  String get mammalHeadBodyLength => 'Head and body length (mm)';

  @override
  String get mammalHeadBodyLengthHint => 'Enter HBL';

  @override
  String get mammalTailHeadBodyRatio => 'Tail/HB length';

  @override
  String get mammalTailHeadBodyRatioHint => 'Enter TL/HBL';

  @override
  String get mammalHindFootLength => 'Hind foot length (mm)';

  @override
  String get mammalHindFootLengthHint => 'Enter HF length';

  @override
  String get mammalEarLength => 'Ear length (mm)';

  @override
  String get mammalEarLengthHint => 'Enter ER length';

  @override
  String get mammalShowBatFields => 'Show bat fields';

  @override
  String get specimenRemarks => 'Remarks';

  @override
  String get specimenMeasurementRemarksHint =>
      'Write notes about the measurements (optional)';

  @override
  String get specimenUnusualMeasurement => 'Unusual measurement';

  @override
  String get mammalChangeSexTitle => 'Change sex?';

  @override
  String get mammalChangeSexBody =>
      'Changing the sex will clear reproductive data that does not apply to the new selection.';

  @override
  String get specimenAccuracy => 'Accuracy';

  @override
  String get specimenAccuracyHint => 'Select measurement accuracy';

  @override
  String get specimenNoInaccurateSelected =>
      'No inaccurate measurements selected';

  @override
  String specimenInaccurateList(String labels) {
    return '*Inaccurate: $labels';
  }

  @override
  String specimenAccuracyRemarkValue(String remark) {
    return 'Remark:\n$remark';
  }

  @override
  String get specimenSelectInaccurate => 'Select inaccurate measurements';

  @override
  String get specimenInaccurateMeasurements => 'Inaccurate measurements';

  @override
  String get specimenSelectEveryInaccurate =>
      'Select every measurement that is inaccurate.';

  @override
  String get specimenSelectAtLeastOneInaccurate =>
      'Select at least one inaccurate measurement.';

  @override
  String get specimenAccuracyRemark => 'Accuracy remark';

  @override
  String get specimenAccuracyRemarkHint =>
      'Describe why the measurements are inaccurate';

  @override
  String get mammalTestes => 'Testes';

  @override
  String get mammalTestisPosition => 'Position';

  @override
  String get mammalTestisPositionHint => 'Select testis position';

  @override
  String get specimenLengthMm => 'Length (mm)';

  @override
  String get mammalTestisLengthHint => 'Enter the length of the right testes';

  @override
  String get specimenWidthMm => 'Width (mm)';

  @override
  String get mammalTestisWidthHint => 'Enter the width of the right testes';

  @override
  String get mammalEpididymis => 'Epididymis';

  @override
  String get mammalEpididymisHint => 'Select epididymis appearance';

  @override
  String get mammalVaginaOpening => 'Vagina opening';

  @override
  String get mammalVaginaOpeningHint => 'Select vagina opening';

  @override
  String get mammalPubicSymphysis => 'Pubic symphysis';

  @override
  String get mammalPubicSymphysisHint => 'Select pubic symphysis condition';

  @override
  String get mammalFemaleReproductive => 'Female reproductive attributes';

  @override
  String get mammalReproductiveStage => 'Reproductive stage';

  @override
  String get mammalReproductiveStageHint => 'Select reproductive stage';

  @override
  String get mammalMammaeCounts => 'Mammae counts (pairs)';

  @override
  String get mammalMammaeCondition => 'Mammae condition';

  @override
  String get mammalMammaeConditionHint => 'Select mammae condition';

  @override
  String get mammalEmbryo => 'Embryo';

  @override
  String get mammalCrownRumpLength => 'CR length (mm)';

  @override
  String get mammalCrownRumpLengthHint => 'Enter crown-rump length';

  @override
  String get mammalPlacentalScars => 'Placental scars';

  @override
  String get mammalAxillary => 'Axillary';

  @override
  String get mammalAxillaryHint => 'Enter the axillary pair number';

  @override
  String get mammalAbdominal => 'Abdominal';

  @override
  String get mammalAbdominalHint => 'Enter the abdominal pair number';

  @override
  String get mammalInguinal => 'Inguinal';

  @override
  String get mammalInguinalHint => 'Enter the inguinal pair number';

  @override
  String get specimenLeft => 'Left';

  @override
  String get specimenRight => 'Right';

  @override
  String get mammalForearmLength => 'Forearm Length (mm)';

  @override
  String get mammalForearmLengthHint => 'Enter FL length';

  @override
  String get mammalTibiaLength => 'Tibia Length (mm)';

  @override
  String get mammalTibiaLengthHint => 'Enter tibia length';

  @override
  String get mammalEcholocate => 'Echolocate?';

  @override
  String get mammalEcholocation => 'Echolocation';

  @override
  String get mammalEcholocationHint => 'Select echolocation type';

  @override
  String get mammalFrequencyMax => 'Frequency Max (kHz)';

  @override
  String get mammalFrequencyMaxHint => 'Enter maximum echolocate frequency';

  @override
  String get mammalFrequencyMin => 'Frequency Min (kHz)';

  @override
  String get mammalFrequencyMinHint => 'Enter minimum echolocate frequency';

  @override
  String get mammalFrequencyMaxEnergy => 'Frequency At Max Energy (kHz)';

  @override
  String get mammalFrequencyMaxEnergyHint =>
      'Enter echolocate frequency at max energy';

  @override
  String get mammalEcholocationDuration => 'Duration (seconds)';

  @override
  String get mammalEcholocationDurationHint => 'Enter echolocation duration';

  @override
  String get birdWingspan => 'Wingspan (mm)';

  @override
  String get birdWingspanHint => 'Enter wingspan length';

  @override
  String get birdBillColor => 'Bill color';

  @override
  String get birdBillColorHint => 'Enter bill color';

  @override
  String get birdMaxillaColor => 'Maxilla color';

  @override
  String get birdMaxillaColorHint => 'Enter maxilla color';

  @override
  String get birdMandibleColor => 'Mandible color';

  @override
  String get birdMandibleColorHint => 'Enter mandible color';

  @override
  String get birdIrisColor => 'Iris color';

  @override
  String get birdIrisColorHint => 'Enter iris color';

  @override
  String get birdTarsusColor => 'Tarsus color';

  @override
  String get birdTarsusColorHint => 'Enter tarsus color';

  @override
  String get birdToeColor => 'Toe color';

  @override
  String get birdToeColorHint => 'Enter toe color';

  @override
  String get birdBroodPatch => 'Brood patch';

  @override
  String get birdBursaPresent => 'Bursa present';

  @override
  String get birdStomachContents => 'Stomach contents';

  @override
  String get birdStomachContentsHint => 'Enter stomach contents';

  @override
  String get birdBursaLength => 'Bursa length (mm)';

  @override
  String get birdBursaLengthHint => 'Enter bursa length';

  @override
  String get birdBursaWidth => 'Bursa width (mm)';

  @override
  String get birdBursaWidthHint => 'Enter bursa width';

  @override
  String get birdMaleGonads => 'Male gonads';

  @override
  String get birdLeftTestisSize => 'Left testis size (mm)';

  @override
  String get birdSize => 'Size';

  @override
  String get birdMinute => 'minute';

  @override
  String get birdOneMmOrGreater => '1 mm or greater';

  @override
  String get birdLength => 'Length';

  @override
  String get specimenEnterLength => 'Enter length';

  @override
  String get birdWidth => 'Width';

  @override
  String get specimenEnterWidth => 'Enter width';

  @override
  String get birdTestisRemarksHint => 'Enter remarks, e.g. right testis size';

  @override
  String get birdFemaleGonads => 'Female gonads';

  @override
  String get birdOvarySize => 'Ovary size';

  @override
  String get birdAppearance => 'Appearance';

  @override
  String get birdOviduct => 'Oviduct';

  @override
  String get birdGonadRemarksHint =>
      'Add additional information about the gonads';

  @override
  String get birdSkullOssification => 'Skull ossification (%)';

  @override
  String get birdSkullOssificationHint => 'Enter percentage';

  @override
  String get birdFat => 'Fat';

  @override
  String get birdLargestOva => 'Diameter of three largest ova (mm)';

  @override
  String get birdFirst => 'First';

  @override
  String get birdEnterSize => 'Enter size';

  @override
  String get birdSecond => 'Second';

  @override
  String get birdThird => 'Third';

  @override
  String get birdMolt => 'Molt';

  @override
  String get birdWingMolt => 'Wing molt';

  @override
  String get birdTailMolt => 'Tail molt';

  @override
  String get birdMoltRemarksHint => 'Add additional molt information';

  @override
  String get birdWingMoltHint => 'Enter wing molt';

  @override
  String get birdTailMoltHint => 'Enter tail molt';

  @override
  String get birdBodyMolt => 'Body molt';

  @override
  String get specimenNotes => 'Notes';

  @override
  String get birdHabitat => 'Habitat';

  @override
  String get birdHabitatHint => 'Add additional information about the habitat';

  @override
  String get specimenSpecimen => 'Specimen';

  @override
  String get specimenRemarksHint =>
      'Add additional information about the specimen';

  @override
  String get fishStandardLength => 'Standard length (mm)';

  @override
  String get fishStandardLengthHint => 'Enter standard length';

  @override
  String get fishTotalLengthHint => 'Enter total length';

  @override
  String get fishTotalIndividuals => 'Total individuals';

  @override
  String get fishTotalIndividualsHint =>
      'Enter the number of individuals in the lot';

  @override
  String get fishAutoUpdateRanges => 'Auto-update min and max';

  @override
  String get fishAutoUpdateRangesBody =>
      'Fill the ranges from the individuals measured below';

  @override
  String get fishMinStandardLength => 'Min. standard length (mm)';

  @override
  String get fishMinStandardLengthHint => 'Enter minimum standard length';

  @override
  String get fishMaxStandardLength => 'Max. standard length (mm)';

  @override
  String get fishMaxStandardLengthHint => 'Enter maximum standard length';

  @override
  String get fishMinTotalLength => 'Min. total length (mm)';

  @override
  String get fishMinTotalLengthHint => 'Enter minimum total length';

  @override
  String get fishMaxTotalLength => 'Max. total length (mm)';

  @override
  String get fishMaxTotalLengthHint => 'Enter maximum total length';

  @override
  String get fishMinWeight => 'Min. weight';

  @override
  String get fishMinWeightHint => 'Enter minimum weight';

  @override
  String get fishMaxWeight => 'Max. weight';

  @override
  String get fishMaxWeightHint => 'Enter maximum weight';

  @override
  String get fishSpecimenType => 'Specimen type';

  @override
  String get fishTypeIndividual => 'Individual';

  @override
  String get fishTypeLot => 'Lot';

  @override
  String get fishTypeIndividualDescription =>
      'One fish with its own measurements';

  @override
  String get fishTypeLotDescription => 'Many individuals stored together';

  @override
  String get invertCaste => 'Caste';

  @override
  String get invertCasteHint => 'Select caste';

  @override
  String get invertEcologicalInteractions => 'Ecological interactions';

  @override
  String get invertShowMorphometrics => 'Show specimen morphometrics';

  @override
  String get invertMorphometrics => 'Specimen morphometrics';

  @override
  String get invertHostOrganism => 'Host organism';

  @override
  String get invertHostOrganismHint => 'Enter the associated host taxon';

  @override
  String get invertHostPart => 'Host part';

  @override
  String get invertHostPartHint => 'Enter the occupied host part';

  @override
  String get invertHeadWidth => 'Head width (mm)';

  @override
  String get invertHeadWidthHint => 'Enter head width';

  @override
  String get invertBodyLength => 'Body length (mm)';

  @override
  String get invertBodyLengthHint => 'Enter body length';

  @override
  String get invertUpperWingspan => 'Upper wingspan (mm)';

  @override
  String get invertUpperWingspanHint => 'Enter upper wingspan';

  @override
  String get invertLowerWingspan => 'Lower wingspan (mm)';

  @override
  String get invertLowerWingspanHint => 'Enter lower wingspan';

  @override
  String get herpSnoutVentLength => 'SVL (cm)';

  @override
  String get herpSnoutVentLengthHint => 'Enter snout-vent length';

  @override
  String get partSpecimenParts => 'Specimen Parts';

  @override
  String get partAdd => 'Add specimen part';

  @override
  String get partNoneAdded => 'No parts added';

  @override
  String get partUnknown => 'Unknown part';

  @override
  String get partNoCount => 'No count';

  @override
  String get partNoTreatment => 'None';

  @override
  String get partHasRemark => 'has remark';

  @override
  String partPmi(String pmi) {
    return 'PMI $pmi';
  }

  @override
  String get partAddParts => 'Add specimen parts';

  @override
  String get partEditParts => 'Edit specimen parts';

  @override
  String get partPreparation => 'Preparation';

  @override
  String get partSampling => 'Sampling';

  @override
  String partSaveError(String error) {
    return 'Unable to save specimen part: $error';
  }

  @override
  String get partCounts => 'Counts';

  @override
  String get partCountsHint => 'Enter part counts';

  @override
  String get partPreparationType => 'Preparation type';

  @override
  String get partPreparationTypeHint => 'Enter preparation type';

  @override
  String get partTreatmentHint => 'Enter treatment';

  @override
  String get partAdditionalTreatment => 'Additional treatment';

  @override
  String get partAdditionalTreatmentHint => 'Enter additional treatment';

  @override
  String get partPreparatorHint => 'If different from voucher preparator';

  @override
  String get partDateTaken => 'Date taken';

  @override
  String get partTimeTaken => 'Time taken';

  @override
  String get partRecommendedFresh => 'Recommended for fresh tissues';

  @override
  String get partStorageType => 'Storage type';

  @override
  String get partStorageTypeHint => 'Enter storage type';

  @override
  String get partStorageLocationHint =>
      'It can be cell or jar ID, following your museum convention';

  @override
  String get partMuseumHint => 'Enter a museum name or abbreviation';

  @override
  String get partRemarksHint => 'Enter a remark specific to this part';

  @override
  String get partBarcodeId => 'QR/barcode ID';

  @override
  String get partBarcodeIdHint => 'Enter barcode ID (if applicable)';

  @override
  String get partBarcodeIdOptions => 'QR/barcode ID options';

  @override
  String get partGenerateUuid => 'Generate UUID';

  @override
  String get partInvalidBarcode => 'Invalid QR/barcode';

  @override
  String get partBarcodeIdExists =>
      'QR/barcode ID already exists. Clear the field to generate a new UUID';

  @override
  String get partTissueIdHint => 'Enter tissue ID';

  @override
  String get partRepeatTissueFailed => 'Failed to repeat tissue number';

  @override
  String get partTissueIdOptions => 'Tissue ID options';

  @override
  String get partTissueIdSettings => 'Tissue ID settings';

  @override
  String get specimenCollectionIdentification => 'Collection & Identification';

  @override
  String get specimenTaxaLoadError => 'Error loading taxa';

  @override
  String get specimenIdConfidence => 'ID Confidence';

  @override
  String get specimenIdConfidenceHint => 'Choose a confidence level';

  @override
  String get specimenDeterminerHint =>
      'Choose a determiner (default is cataloger)';

  @override
  String get specimenIdMethod => 'Identification Method';

  @override
  String get specimenIdMethodHint => 'Choose an identification method';

  @override
  String get specimenCollectionDate => 'Collection date';

  @override
  String get specimenCollectionTime => 'Collection time';

  @override
  String get specimenConditionHint => 'Choose a condition';

  @override
  String get specimenPrepDate => 'Prep. date';

  @override
  String get specimenPrepTime => 'Prep. time';

  @override
  String get specimenPreparatorHint =>
      'Choose a preparator (default is cataloger)';

  @override
  String specimenUuid(String uuid) {
    return 'Specimen UUID: $uuid';
  }

  @override
  String get specimenMuseumId => 'Museum ID';

  @override
  String get specimenMuseumIdHint => 'Enter museum ID (if applicable)';

  @override
  String specimenFieldIdValue(String id) {
    return 'Field ID: $id';
  }

  @override
  String get specimenFieldIdLoading => 'Field ID: Loading…';

  @override
  String get specimenFieldIdUnavailable => 'Field ID: unavailable';

  @override
  String get specimenFieldIdSelectCataloger => 'Field ID: select a cataloger';

  @override
  String get specimenFieldIdCatalogerNotSetUp =>
      'Field ID: cataloger is not set up for field numbers';

  @override
  String get specimenEditFieldId => 'Edit field ID';

  @override
  String get specimenFieldIdPersonnel => 'Personnel';

  @override
  String get specimenFieldIdProject => 'Project';

  @override
  String get specimenFieldIdPersonnelUnavailable =>
      'Select a Cataloger with personal field-number registration enabled before assigning a personnel field ID.';

  @override
  String get specimenPersonnelFieldNumber => 'Personnel field number';

  @override
  String get specimenProjectCatalogNumber => 'Project catalog number';

  @override
  String get specimenFieldIdTypeChangeAck =>
      'I understand that changing identifier type removes the specimen’s previous field ID and that it may already appear in exports or on specimen labels.';

  @override
  String get specimenSaving => 'Saving…';

  @override
  String get fishStandardLengthShort => 'Standard length';

  @override
  String get fishTotalLengthShort => 'Total length';

  @override
  String get fishWeight => 'Weight';

  @override
  String get fishLotSummary => 'Lot summary';

  @override
  String fishMeasuredCount(int count) {
    return '$count measured';
  }

  @override
  String fishMeasuredOfTotal(int count, int total) {
    return '$count of $total individuals measured';
  }

  @override
  String get fishNotMeasured => 'Not measured';

  @override
  String fishStandardDeviation(String value) {
    return '± $value SD';
  }

  @override
  String fishRange(String min, String max, String unit) {
    return 'Range $min–$max $unit';
  }

  @override
  String get fishIndividuals => 'Individuals';

  @override
  String fishIndividualsLoadError(String error) {
    return 'Unable to load individuals: $error';
  }

  @override
  String get fishAddIndividual => 'Add individual';

  @override
  String get fishDeleteIndividual => 'Delete individual';

  @override
  String fishStandardLengthValue(String value) {
    return 'SL $value mm';
  }

  @override
  String fishTotalLengthValue(String value) {
    return 'TL $value mm';
  }

  @override
  String get fishNoMeasurements => 'No measurements';

  @override
  String fishDeleteIndividualTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get fishDeleteIndividualBody =>
      'This deletes the individual and unlinks it from any specimen parts and parasites.';

  @override
  String get fishStandardLengthMm => 'SL (mm)';

  @override
  String get fishTotalLengthMm => 'TL (mm)';

  @override
  String fishWeightWithUnit(String unit) {
    return 'Weight ($unit)';
  }

  @override
  String get fishEnterWeight => 'Enter weight';

  @override
  String get fishIndividualRemarksHint => 'Add notes about this individual';

  @override
  String get fishEditIndividual => 'Edit individual';

  @override
  String fishEnteredCount(int count) {
    return '$count entered';
  }

  @override
  String fishEnteredOfTotal(int count, int total) {
    return '$count of $total entered';
  }

  @override
  String get fishSaveAndAddAnother => 'Save and add another';

  @override
  String get fishMeasurements => 'Measurements';

  @override
  String get fishTagId => 'Tag ID';

  @override
  String get fishTagIdHint => 'Enter individual or tag ID';

  @override
  String get fishAutoNumbered => 'Auto-numbered. Edit to override.';

  @override
  String get fishTagIdOptions => 'Tag ID options';

  @override
  String get fishTagIdSettings => 'Tag ID settings';

  @override
  String get specimenCaptureRecords => 'Capture Records';

  @override
  String get specimenChooseSite => 'Choose a site';

  @override
  String get specimenChangeSiteTitle => 'Change site?';

  @override
  String get specimenChangeSiteBody =>
      'Except for capture date and time, all fields in the collecting record section will be empty again.';

  @override
  String get specimenChooseEvent => 'Choose a collecting event ID';

  @override
  String get specimenChangeEventTitle => 'Change collecting event ID?';

  @override
  String get specimenChangeEventBody =>
      'Except for capture date and time, all fields in the collecting record section will be empty again. The coordinate is kept when it belongs to the same site.';

  @override
  String get specimenChooseMethod => 'Choose a method type';

  @override
  String get specimenRelativeTime => 'Relative time';

  @override
  String get specimenMethodId => 'Method ID';

  @override
  String get specimenMethodIdHint => 'Enter ID, e.g. trap/net number, etc.';

  @override
  String get specimenCaptureDate => 'Capture date';

  @override
  String get specimenCoordinateId => 'Coordinate ID';

  @override
  String get specimenChooseCoordinate => 'Choose a coordinate';

  @override
  String get specimenCoordinateExtent => 'Coordinate extent (m)';

  @override
  String get specimenCoordinateExtentHint => 'Add the coordinate extent';

  @override
  String get specimenExtentInvalid =>
      'Extent must be a number greater than zero';

  @override
  String get specimenCaptureTime => 'Capture time';

  @override
  String get specimenChoosePerson => 'Choose a person';

  @override
  String get specimenSexHint => 'Select specimen sex';

  @override
  String get specimenLifeStageHint => 'Select life stage';

  @override
  String specimenLifeStagesLoadError(String error) {
    return 'Unable to load life stages: $error';
  }

  @override
  String specimenParasiteDetectionLoadError(String error) {
    return 'Unable to load parasite detection: $error';
  }

  @override
  String get specimenParasitesExamined => 'Parasites examined';

  @override
  String get specimenParasitesDetected => 'Parasites detected';

  @override
  String get specimenDetectionRemarks => 'Detection remarks';

  @override
  String get specimenDetectionRemarksHint =>
      'Enter parasite examination or detection remarks';

  @override
  String get specimenCreate => 'Create specimen';

  @override
  String get specimenActions => 'Specimen actions';

  @override
  String get specimenDuplicatePart => 'Duplicate part';

  @override
  String get specimenExport => 'Export specimen';

  @override
  String get specimenImport => 'Import specimen';

  @override
  String specimenDuplicatePartError(String error) {
    return 'Error duplicating part: $error';
  }

  @override
  String get specimenDeleteTitle => 'Delete specimen?';

  @override
  String get specimenDeleteBody =>
      'You will delete this specimen record, all measurements, and specimen parts.\nYou will need to manually update the field number.';

  @override
  String specimenDeleteError(String error) {
    return 'Error deleting specimen: $error';
  }

  @override
  String get specimenDeleteAllTitle => 'Delete all specimens?';

  @override
  String get specimenDeleteAllBody =>
      'It will remove all specimens records, measurements, and specimen parts';

  @override
  String specimenDeleteAllError(String error) {
    return 'Error deleting all specimens: $error';
  }

  @override
  String get specimenTaxonInfo => 'Taxon Info';

  @override
  String get specimenNoSpeciesSelected => 'No species selected';

  @override
  String get specimenTaxonTooltip => 'Type taxon name and select from list';

  @override
  String get specimenTaxon => 'Taxon';

  @override
  String get specimenTaxonHint => 'Type taxon name';

  @override
  String get specimenEnterTaxon => 'Enter taxon';

  @override
  String get specimenNoneSelected => 'None selected';

  @override
  String specimenRemoveIndividualTooltip(String name) {
    return 'Remove $name';
  }

  @override
  String get specimenAllIndividualsAdded => 'All individuals added';

  @override
  String get specimenSelectIndividual => 'Select an individual';

  @override
  String specimenRemoveIndividualTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String specimenRemoveIndividualBody(String name) {
    return 'This record will no longer be linked to individual $name. The individual itself is kept.';
  }

  @override
  String get specimenRecordsTitle => 'Specimen Records';

  @override
  String get specimenSearchOptions => 'Search Options';

  @override
  String get specimenRecordTitle => 'Specimen Record';

  @override
  String get specimenNoneFound => 'No specimen found';

  @override
  String get specimenWeightHint => 'Enter specimen weight';

  @override
  String get specimenChangeWeightUnit => 'Change weight unit';

  @override
  String get templateDeleteTextBox => 'Delete text box';

  @override
  String get templateHeightMm => 'Height (mm)';

  @override
  String get templatePictureTypeOptions => 'Picture type options';

  @override
  String get templateRotation => 'Rotation';

  @override
  String get templateQrCode => 'QR Code';

  @override
  String get templateQrSize => 'QR Size (mm)';

  @override
  String get templateContentFormattingOptions => 'Content formatting options';

  @override
  String get templateShape => 'Shape';

  @override
  String get templateSquare => 'Square';

  @override
  String get templateCircle => 'Circle';

  @override
  String get templateDynamic => 'Dynamic';

  @override
  String get templateSizePt => 'Size (pt)';

  @override
  String get templateDecreaseFontSize => 'Decrease font size';

  @override
  String get templateIncreaseFontSize => 'Increase font size';

  @override
  String get templateTextFormattingOptions => 'Text formatting options';

  @override
  String get templateTextStylingOptions => 'Text styling options';

  @override
  String get templateMaxWidth => 'Max Width (mm)';

  @override
  String get templateMaxHeight => 'Max Height (mm)';

  @override
  String get templateFont => 'Font';

  @override
  String templateFontNotInstalled(String font) {
    return '$font (not installed)';
  }

  @override
  String get templateUnderline => 'Underline';

  @override
  String get templateStrikethrough => 'Strikethrough';

  @override
  String get templateForeground => 'Foreground';

  @override
  String get templateQrForegroundColor => 'Select QR foreground color';

  @override
  String get templateBackground => 'Background';

  @override
  String get templateQrBackgroundColor => 'Select QR background color';

  @override
  String get templateConditionalOutput => 'Conditional output';

  @override
  String get templateFormat => 'Format';

  @override
  String get templateMapEncodedValues => 'Map encoded values';

  @override
  String get templateHeaderCase => 'Header Case';

  @override
  String get templateUppercase => 'Uppercase';

  @override
  String get templateLowercase => 'Lowercase';

  @override
  String get templateMissing => 'Missing';

  @override
  String get templateTextColor => 'Select text color';

  @override
  String get templateTextBackgroundColor => 'Select text background color';

  @override
  String get templateStroke => 'Stroke';

  @override
  String get templateTextStrokeColor => 'Select text stroke color';

  @override
  String get templateStyle => 'Style';

  @override
  String get templateRadius => 'Radius';

  @override
  String get templatePadding => 'Padding';

  @override
  String get templateAlignLeft => 'Align left';

  @override
  String get templateAlignCenter => 'Align center';

  @override
  String get templateAlignRight => 'Align right';

  @override
  String templateClearColor(String label) {
    return 'Clear $label';
  }

  @override
  String get templateNoContentPlaceholder => 'No Content Placeholder';

  @override
  String get templateCustomText => 'Custom Text';

  @override
  String get templateCustomTextHint => 'Enter custom fallback text';

  @override
  String get templateConditionalType => 'Conditional type';

  @override
  String get templateTargetField => 'Target field';

  @override
  String get templateConditionalTextHelper =>
      'Fields such as [mammalAttribute::testisWidth] are filled in.';

  @override
  String get templateReplacementHelper =>
      'Written when matched; otherwise the original target value is kept. Leave it empty to hide the value.';

  @override
  String get templateTypeNormalText => 'Normal Text';

  @override
  String get templateTypePicture => 'Picture';

  @override
  String get templateTypeMarkdown => 'Markdown';

  @override
  String get templateTypeCoordinates => 'Coordinates';

  @override
  String get templateTypeList => 'List Values';

  @override
  String get templateTypeNestedList => 'Nested List';

  @override
  String get templateTypeDates => 'Dates';

  @override
  String get templateTypeDateTime => 'Date and Time';

  @override
  String get templateTypeTime => 'Time';

  @override
  String get templateTypeSex => 'Sex';

  @override
  String get templateTypeNumber => 'Number';

  @override
  String get templateTypeEncoded => 'Encoded Text';

  @override
  String get templateFormatDefaultMapping => 'Default mapping';

  @override
  String get templateFormatCustomMapping => 'Custom mapping...';

  @override
  String get templateFormatDecimal => 'Decimal (45.123, -122.543)';

  @override
  String get templateFormatCardinalDecimal =>
      'Cardinal Dec (45.123° N, 122.543° W)';

  @override
  String get templateFormatPipe => 'Pipe separated (A | B | C)';

  @override
  String get templateFormatComma => 'Comma separated (A, B, C)';

  @override
  String get templateFormatSemicolon => 'Semicolon separated (A; B; C)';

  @override
  String get templateFormatSlash => 'Slash separated (A / B / C)';

  @override
  String get templateFormatNewline => 'New line (A\nB\nC)';

  @override
  String get templateFormatBullet => 'Bulleted (• A\n• B)';

  @override
  String get templateFormatCustomSeparator => 'Custom separator...';

  @override
  String get templateFormatTable => 'Table';

  @override
  String get templateFormatCardList => 'Card list';

  @override
  String get templateFormatMonthDdYyyy => 'Month DD, YYYY (June 28, 2026)';

  @override
  String get templateFormatDdMonthYyyy => 'DD Month YYYY (28 June 2026)';

  @override
  String get templateFormatDdMonthAbbr => 'DD Month (Abbr) (28 Jun 2026)';

  @override
  String get templateFormatYmdSeconds =>
      'YYYY-MM-DD seconds (2026-06-28 14:05:09)';

  @override
  String get templateFormatIsoMinutes => 'ISO minutes (2026-06-28T14:05)';

  @override
  String get templateFormatIsoSeconds => 'ISO seconds (2026-06-28T14:05:09)';

  @override
  String get templateFormatDdMonthYyyyTime =>
      'DD Month YYYY 24h (28 June 2026 14:05)';

  @override
  String get templateFormatMonthDdYyyyTime =>
      'Month DD, YYYY 12h (June 28, 2026 2:05 PM)';

  @override
  String get templateFormatDdMonYyyyTime =>
      'DD Mon YYYY 24h (28 Jun 2026 14:05)';

  @override
  String get templateFormatMonDdYyyyTime =>
      'Mon DD, YYYY 12h (Jun 28, 2026 2:05 PM)';

  @override
  String get templateFormatTime24 => 'Time 24h (14:05)';

  @override
  String get templateFormatTime24Seconds => 'Time 24h seconds (14:05:09)';

  @override
  String get templateFormatTime12 => 'Time 12h (2:05 PM)';

  @override
  String get templateFormatTime12Padded => 'Time 12h padded (02:05 PM)';

  @override
  String get templateFormatOriginal => 'Original';

  @override
  String get templateFormatDecimals0 => '0 decimal places (e.g. 12)';

  @override
  String get templateFormatDecimals1 => '1 decimal place (e.g. 12.3)';

  @override
  String get templateFormatDecimals2 => '2 decimal places (e.g. 12.34)';

  @override
  String get templateFormatDecimals3 => '3 decimal places (e.g. 12.345)';

  @override
  String get templateFormatNormal => 'Normal';

  @override
  String get templateFormatCapitalize => 'Capitalize';

  @override
  String get templateSexSymbol => 'Symbol (♂/♀)';

  @override
  String get templateSexLetter => 'Letter (M/F)';

  @override
  String get templateSexText => 'Text (Male/Female)';

  @override
  String get templateSexUnknown => 'Unknown';

  @override
  String get templateSexNa => 'N/A';

  @override
  String get templateSexNone => 'None';

  @override
  String get templateSizeLabel => 'Template size:';

  @override
  String get templateAddImage => 'Add image';

  @override
  String get templateAddLine => 'Add line';

  @override
  String get templateAddShape => 'Add shape';

  @override
  String get templateFront => 'Front';

  @override
  String get templateBack => 'Back';

  @override
  String get templateSave => 'Save template';

  @override
  String get templateRedo => 'Redo';

  @override
  String get templateBorder => 'Template border';

  @override
  String get templateElements => 'Elements';

  @override
  String get templateHideGrid => 'Hide grid';

  @override
  String get templateShowGrid => 'Show grid';

  @override
  String get templateDisableSnap => 'Disable snap';

  @override
  String get templateEnableSnap => 'Enable snap';

  @override
  String get templateUnlockCanvas => 'Unlock canvas movement';

  @override
  String get templateLockCanvas => 'Lock canvas movement';

  @override
  String get templateSelectPreviewRecord => 'Select specimen for text preview';

  @override
  String get templateSettings => 'Template settings';

  @override
  String get templateToolPage => 'Page';

  @override
  String get templateToolView => 'View';

  @override
  String get templatePresetTemplate => 'Preset template';

  @override
  String templateMirrorOn(String side) {
    return '$side: rotated 180° for print (tap to turn off)';
  }

  @override
  String templateMirrorOff(String side) {
    return '$side: tap to rotate template 180° for print';
  }

  @override
  String get templateOneSided => '1 sided';

  @override
  String templateEditSide(String side) {
    return 'Edit $side side';
  }

  @override
  String templateElementsForSide(String side) {
    return 'Elements · $side';
  }

  @override
  String get templateNoElements =>
      'No elements on this side yet. Add one from the Add tools.';

  @override
  String get templateHidden => 'Hidden';

  @override
  String get templateLocked => 'Locked';

  @override
  String get templateNoSaved => 'No saved templates yet.';

  @override
  String get templateFitToScreen => 'Fit to screen';

  @override
  String get templateRemoveImage => 'Remove image';

  @override
  String get templateDragToRotate => 'Drag to rotate';

  @override
  String get templateRemoveLine => 'Remove line';

  @override
  String get templateDragToMove => 'Drag to move';

  @override
  String get templateRemoveShape => 'Remove shape';

  @override
  String get templateDeleteImage => 'Delete image';

  @override
  String get templateLineStrokeOptions => 'Line stroke options';

  @override
  String get templateThickness => 'Thickness';

  @override
  String get templateColor => 'Color';

  @override
  String get templateSelectColor => 'Select color';

  @override
  String get templateDeleteLine => 'Delete line';

  @override
  String get templateDismissToolbar => 'Dismiss toolbar';

  @override
  String get templateBorderFillOptions => 'Border and fill options';

  @override
  String get templateSelectStrokeColor => 'Select stroke color';

  @override
  String get templateFill => 'Fill';

  @override
  String get templateClearFill => 'Clear fill';

  @override
  String get templateDeleteShape => 'Delete shape';

  @override
  String get templateRectangle => 'Rectangle';

  @override
  String get templateEllipse => 'Ellipse';

  @override
  String get templateTriangle => 'Triangle';

  @override
  String get templatePolygon => 'Polygon';

  @override
  String get templateCorners => 'Corners';

  @override
  String get templateSelectFillColor => 'Select fill color';

  @override
  String get templateBorderTitle => 'Border';

  @override
  String get templateSelectBorderColor => 'Select border color';

  @override
  String get templateSelectColorShade => 'Select color shade';

  @override
  String get templateSelectedColorShades => 'Selected color and its shades';

  @override
  String get templateSendToBack => 'Send to back';

  @override
  String get templateSendBackward => 'Send backward';

  @override
  String get templateBringForward => 'Bring forward';

  @override
  String get templateBringToFront => 'Bring to front';

  @override
  String get templateUnlockPosition => 'Unlock position';

  @override
  String get templateLockPosition => 'Lock position';

  @override
  String get templateHideElement => 'Hide element';

  @override
  String get templateShowElement => 'Show element';

  @override
  String get templateDuplicateElement => 'Duplicate element';

  @override
  String get templateCopyElement => 'Copy element';

  @override
  String get templatePasteElement => 'Paste element';

  @override
  String templateMapEncodedValuesBody(String field) {
    return 'Define custom labels for [$field] values:';
  }

  @override
  String get templateFontsNotInstalled => 'Fonts not installed';

  @override
  String templateMissingFontOne(int templates) {
    String _temp0 = intl.Intl.pluralLogic(
      templates,
      locale: localeName,
      other:
          'This installation does not have 1 font used by the imported templates. Choose a replacement.',
      one:
          'This installation does not have 1 font used by the imported template. Choose a replacement.',
    );
    return '$_temp0';
  }

  @override
  String templateMissingFontMany(int templates, int fonts) {
    String _temp0 = intl.Intl.pluralLogic(
      templates,
      locale: localeName,
      other:
          'This installation does not have $fonts fonts used by the imported templates. Choose a replacement for each.',
      one:
          'This installation does not have $fonts fonts used by the imported template. Choose a replacement for each.',
    );
    return '$_temp0';
  }

  @override
  String get templateInstallOriginalFonts =>
      'Install the original fonts under Documents > Fonts if you need an exact match.';

  @override
  String templateFontPreview(String font) {
    return 'Preview: $font';
  }

  @override
  String get templateCancelImport => 'Cancel import';

  @override
  String get templateReplaceAndImport => 'Replace and import';

  @override
  String get templateExistsTitle => 'Template exists';

  @override
  String templateExistsBody(String name) {
    return 'A template named \"$name\" already exists. Replace the saved copy?';
  }

  @override
  String get templateNewName => 'New name';

  @override
  String get templateUploadFromDevice => 'Upload from device';

  @override
  String get templateUploadFromDeviceBody =>
      'Copies the file into your template images folder';

  @override
  String get templateSavedImages => 'Saved images';

  @override
  String get templateNoSavedImages => 'No saved images yet - upload one first.';

  @override
  String get templateName => 'Template name';

  @override
  String get templateEnterName => 'Enter a name';

  @override
  String get templateSaveImportedAs => 'Save imported template as';

  @override
  String templateMustDiffer(String name) {
    return 'Must differ from \"$name\"';
  }

  @override
  String get templateNameExists => 'A template with this name already exists';

  @override
  String templateRecordTypeValue(String type) {
    return 'Record type: $type';
  }

  @override
  String get templateSides => 'Sides';

  @override
  String get templateOneSidedBody =>
      'Create a template with a Front side only.';

  @override
  String get templateTwoSided => '2 sided';

  @override
  String get templateTwoSidedBody => 'Create separate Front and Back designs.';

  @override
  String get templateCreateNew => 'Create new template';

  @override
  String get templateOptions => 'Template Options';

  @override
  String get templateSaveAs => 'Save as...';

  @override
  String get templateChoose => 'Choose template';

  @override
  String get templateUntitled => 'Untitled template';

  @override
  String get templateInsertField => 'Insert Field';

  @override
  String get templateAllTaxa => 'All Taxa';

  @override
  String get templateEditCustomText => 'Edit Custom Text';

  @override
  String get templateTextInput => 'Text Input';

  @override
  String get templateTextInputHint => 'Enter text or insert fields...';

  @override
  String get templateAvailableSymbols => 'Available Symbols';

  @override
  String get templateEnterText => 'Enter text...';

  @override
  String templateRenamedTo(String name) {
    return 'Renamed to $name';
  }

  @override
  String templateRenameFailed(String error) {
    return 'Rename failed: $error';
  }

  @override
  String templateSavedName(String name) {
    return 'Saved template \"$name\"';
  }

  @override
  String templateSavedFile(String file) {
    return 'Saved $file';
  }

  @override
  String templateReplacementInvalid(int index, String text, String message) {
    return 'Text replacement $index in \"$text\" is invalid: $message';
  }

  @override
  String templateImportedAndSaved(String name) {
    return 'Imported and saved \"$name\"';
  }

  @override
  String get templateImportFailed => 'Import failed or file invalid';

  @override
  String get templateUnsavedChanges => 'Unsaved Changes';

  @override
  String get templateUnsavedChangesBody =>
      'Do you want to save the changes to the template before leaving?';

  @override
  String get templateDiscard => 'Discard';

  @override
  String get templatePreviewPartSelection =>
      'Specimen Part Selection for Preview';

  @override
  String get templatePreviewParasiteSelection =>
      'Parasite Selection for Preview';

  @override
  String get templatePreviewSpecimenSelection =>
      'Specimen Selection for Preview';

  @override
  String get templateSizePreset => 'Template Size Preset';

  @override
  String get templateSizePaper => 'Paper';

  @override
  String get templateSizeCryotubes => 'Cryotubes';

  @override
  String get templateSizeRangeHelper => 'Enter value between 10 and 500 mm';

  @override
  String get templateSizeEnterWidth => 'Please enter a width';

  @override
  String get templateSizeInvalidNumber => 'Please enter a valid number';

  @override
  String get templateSizeOutOfRange => 'Must be between 10 and 500';

  @override
  String get templateSizeEnterHeight => 'Please enter a height';

  @override
  String get templateSizeApplyCustom => 'Apply Custom Size';

  @override
  String get templatePresetLetter => 'Letter';

  @override
  String get templatePresetLegal => 'Legal';

  @override
  String get templatePresetVialSideLarge => '1.5 - 2.0 mL Vial Side';

  @override
  String get templatePresetVialSideSmall => '0.5 - 1.0 mL Vial Side';

  @override
  String get templatePresetCapDotSmall => 'Small Vial Cap Dot';

  @override
  String get templatePresetCapDotLarge => 'Large Vial Cap Dot';

  @override
  String get templatePresetSelfLaminating => 'Self-Laminating Wrap';

  @override
  String get templatePresetPinnedLocality => 'Invertebrate Pinned (Locality)';

  @override
  String get templatePresetPinnedTaxon => 'Invertebrate Pinned (Taxon ID)';

  @override
  String get templatePresetJarInsert => 'Fluid Collection (Jar Insert)';

  @override
  String get templatePresetVertebrateTag => 'Vertebrate Specimen Tag (Medium)';

  @override
  String get templatePresetSkullBox => 'Skull Box / Micro-Vial';

  @override
  String get templatePresetA4Description =>
      'International standard default for catalogs, reports, and label sheets.';

  @override
  String get templatePresetLetterDescription =>
      'North American standard default for documentation and matrix printing.';

  @override
  String get templatePresetLegalDescription =>
      'Extended canvas for long field logs, history sheets, or oversized tables.';

  @override
  String get templatePresetA5Description =>
      'Compact size ideal for pocket field books and small log inserts.';

  @override
  String get templatePresetA3Description =>
      'Oversized sheet for map generation, collection drawer layouts, and system grids.';

  @override
  String get templatePresetVialSideLargeDescription =>
      'Standard side-wall label. Fits 3-4 lines of text plus a barcode.';

  @override
  String get templatePresetVialSideSmallDescription =>
      'Compact side-wall profile for smaller tissue or DNA aliquots.';

  @override
  String get templatePresetCapDotSmallDescription =>
      'Circular top dot fitting 0.5–1.5 mL tube caps for top-down scanning.';

  @override
  String get templatePresetCapDotLargeDescription =>
      'Circular top dot fitting 2.0 mL or larger cryovial screw caps.';

  @override
  String get templatePresetSelfLaminatingDescription =>
      'Text prints on a 25.4x12.7mm zone; clear tail wraps over to protect against liquid nitrogen.';

  @override
  String get templatePresetPinnedLocalityDescription =>
      'Rigid boundary for pinned insects; fits 5-6 lines of ultra-compact metadata.';

  @override
  String get templatePresetPinnedTaxonDescription =>
      'Smallest footprint; contains Genus species, author, and determiner info.';

  @override
  String get templatePresetJarInsertDescription =>
      'Placed inside wet jars (alcohol/formalin). High legibility through curved glass.';

  @override
  String get templatePresetVertebrateTagDescription =>
      'Standard medium-sized vertebrate curation and hang tag.';

  @override
  String get templatePresetSkullBoxDescription =>
      'Optimized for 1-to-2 dram glass vials or small cardboard osteological boxes.';

  @override
  String get templateElementImage => 'Image';

  @override
  String templateElementImageDetail(String width, String height) {
    return 'Image · $width × $height mm';
  }

  @override
  String get templateElementLine => 'Line';

  @override
  String get templateElementEmptyText => 'Empty text';

  @override
  String get mediaGallery => 'Gallery';

  @override
  String get mediaActions => 'Actions';

  @override
  String get mediaDeleteSelectedTitle => 'Delete selected media?';

  @override
  String get mediaDeleteSelectedBody =>
      'Delete the selected media from all NAHPU records and from disk? This cannot be undone.';

  @override
  String mediaSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get mediaNoneAdded => 'No media added';

  @override
  String get mediaAdd => 'Add media';

  @override
  String get mediaTakePhotosVideos => 'Take photos/videos';

  @override
  String get mediaRecordAudio => 'Record audio';

  @override
  String get mediaAddFromGallery => 'Add from gallery';

  @override
  String get mediaAddFromFile => 'Add from file';

  @override
  String get mediaUnavailable => 'Media unavailable';

  @override
  String get mediaFileMissing => 'File missing';

  @override
  String get mediaImageUnavailable => 'Image unavailable';

  @override
  String get mediaNone => 'No media';

  @override
  String get mediaMenuActions => 'Media actions';

  @override
  String get mediaShowInfo => 'Show info';

  @override
  String get mediaEdit => 'Edit media';

  @override
  String get mediaInfo => 'Media info';

  @override
  String get mediaDeleteFileTitle => 'Delete media file?';

  @override
  String mediaDeleteFileBody(String name) {
    return 'Delete $name from all NAHPU records and from disk? This cannot be undone.';
  }

  @override
  String get mediaDeleteThisFileBody =>
      'Delete this media file from all NAHPU records and from disk? This cannot be undone.';

  @override
  String get mediaFileAlreadyExists => 'File already exists';

  @override
  String get mediaFileName => 'File name';

  @override
  String get mediaFileNameHint => 'Enter a file name';

  @override
  String get mediaCaption => 'Caption';

  @override
  String get mediaCaptionHint => 'Enter a caption';

  @override
  String get mediaTag => 'Tag';

  @override
  String get mediaTagHint => 'Enter a tag';

  @override
  String get mediaPhotographer => 'Photographer';

  @override
  String get mediaSelectPersonnel => 'Select personnel';

  @override
  String get mediaClearPhotographer => 'Clear photographer';

  @override
  String get mediaExportSelected => 'Export selected media';

  @override
  String get mediaExporting => 'Exporting media';

  @override
  String get mediaExportingHint =>
      'Large media selections can take several minutes. Keep NAHPU open until this finishes.';

  @override
  String get mediaExport => 'Export media';

  @override
  String get mediaExportLeaveBody =>
      'The export is still running. Leaving now cancels it and no file will be saved.';

  @override
  String get mediaArchive => 'Media archive';

  @override
  String get mediaImageFormat => 'Image format';

  @override
  String get mediaLimitDimensions => 'Limit image dimensions';

  @override
  String get mediaLimitDimensionsBody =>
      'Constrain the longer side without upscaling';

  @override
  String get mediaMaxDimension => 'Maximum width or height (px)';

  @override
  String get mediaMaxDimensionHelper => 'Applies to whichever side is longer.';

  @override
  String get mediaJpegQuality => 'JPEG quality';

  @override
  String get mediaImages => 'Images';

  @override
  String get mediaAudio => 'Audio';

  @override
  String get mediaVideo => 'Video';

  @override
  String get mediaOther => 'Other';

  @override
  String get mediaSourceSize => 'Source size';

  @override
  String get mediaExported => 'Exported';

  @override
  String mediaWarningCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count warnings',
      one: '1 warning',
    );
    return '$_temp0';
  }

  @override
  String mediaCannotConvert(String format) {
    return '$format cannot be converted and will remain in its original format.';
  }

  @override
  String get mediaPause => 'Pause';

  @override
  String get mediaPlay => 'Play';

  @override
  String mediaPlaybackUnavailable(String error) {
    return 'Playback preview is unavailable: $error';
  }

  @override
  String get mediaCameraAccessRequired =>
      'Camera access is required to take photos and videos.';

  @override
  String get mediaMicrophoneAccessRequired =>
      'Microphone access is required to record video.';

  @override
  String get mediaCameraError => 'Unable to use the camera.';

  @override
  String get mediaPhoto => 'Photo';

  @override
  String get mediaSwitchCamera => 'Switch camera';

  @override
  String get mediaStopRecording => 'Stop recording';

  @override
  String get mediaRecordVideo => 'Record video';

  @override
  String get mediaRetake => 'Retake';

  @override
  String get mediaUse => 'Use';

  @override
  String get mediaDetailFile => 'File';

  @override
  String get mediaCategory => 'Category';

  @override
  String get mediaCaptureEquipment => 'Capture and equipment';

  @override
  String get mediaTaken => 'Taken';

  @override
  String get mediaCamera => 'Camera';

  @override
  String get mediaLenses => 'Lenses';

  @override
  String get mediaAdditionalExif => 'Additional EXIF';

  @override
  String get mediaId => 'Media ID';

  @override
  String get mediaSecondaryId => 'Secondary ID';

  @override
  String get mediaPhotographerId => 'Photographer ID';

  @override
  String get mediaLinkedInformation => 'Linked information';

  @override
  String mediaLinkedInformationError(String error) {
    return 'Linked information is unavailable: $error';
  }

  @override
  String get mediaResume => 'Resume';

  @override
  String get mediaPausePlayback => 'Pause playback';

  @override
  String get mediaPlayRecording => 'Play recording';

  @override
  String get mediaRecordingNotSaved => 'The audio recording was not saved.';

  @override
  String get mediaImageSettings => 'Image Settings';

  @override
  String mediaOriginalSize(int width, int height) {
    return 'Original: $width × $height px';
  }

  @override
  String get mediaResizeImage => 'Resize image';

  @override
  String get mediaAspectLocked => 'Aspect ratio is locked';

  @override
  String get mediaWidthPx => 'Width (px)';

  @override
  String mediaMaxValue(int value) {
    return 'Max $value';
  }

  @override
  String get mediaHeightPx => 'Height (px)';

  @override
  String get mediaSearchMetadata => 'Search media metadata';

  @override
  String get mediaGalleryTitle => 'Media gallery';

  @override
  String get mediaGalleryAllProjectsTitle => 'All media';

  @override
  String get mediaFilterProject => 'Filter by project';

  @override
  String get mediaAllProjects => 'All projects';

  @override
  String get mediaSearch => 'Search media';

  @override
  String get mediaDeleteSelected => 'Delete selected media';

  @override
  String get mediaCategoryEvent => 'Event';

  @override
  String get mediaSort => 'Sort media';

  @override
  String get mediaNoMatching => 'No matching media';

  @override
  String get mediaSortAddedNewest => 'Newest added';

  @override
  String get mediaSortAddedOldest => 'Oldest added';

  @override
  String get mediaSortFileNameAsc => 'File name A–Z';

  @override
  String get mediaSortFileNameDesc => 'File name Z–A';

  @override
  String get mediaSortTakenNewest => 'Date taken, newest';

  @override
  String get mediaSortTakenOldest => 'Date taken, oldest';

  @override
  String get mediaHideDetails => 'Hide details';

  @override
  String get mediaShowDetails => 'Show details';

  @override
  String get mediaPrevious => 'Previous';

  @override
  String get mediaMute => 'Mute';

  @override
  String get mediaUnmute => 'Unmute';

  @override
  String get mediaPlaybackSpeed => 'Playback speed';

  @override
  String get mediaExitFullscreen => 'Exit fullscreen';

  @override
  String get mediaFullscreen => 'Fullscreen';

  @override
  String mediaCannotDisplay(String kind) {
    return 'Cannot display this $kind file';
  }

  @override
  String get mediaBarcode => 'Barcode';

  @override
  String get mediaScanQrCode => 'Scan QR code';

  @override
  String get mediaScanBarcode => 'Scan barcode';

  @override
  String get mediaAlignQrCode => 'Align the QR code within the frame';

  @override
  String get mediaAlignBarcode => 'Align the barcode within the frame';

  @override
  String get mediaQrTooLarge =>
      'Data is too large for a QR code.\nExport it as a file instead.';

  @override
  String get associatedUnnamed => 'Unnamed associated data';

  @override
  String get associatedFileUnavailable => 'File unavailable';

  @override
  String get associatedTypeLink => 'Link';

  @override
  String get associatedUnknownType => 'Unknown type';

  @override
  String get associatedNoResource => 'No resource';

  @override
  String get associatedActions => 'Associated data actions';

  @override
  String get associatedOpenInDefaultApp => 'Open in default app';

  @override
  String get associatedOpenLink => 'Open link';

  @override
  String get associatedNoUriToShare => 'No URI to share.';

  @override
  String get associatedFileNotFound => 'File not found';

  @override
  String get associatedInvalidUri => 'Invalid URI.';

  @override
  String associatedCouldNotOpen(String uri) {
    return 'Could not open $uri';
  }

  @override
  String get associatedAdd => 'Add associated data';

  @override
  String get associatedNoneAdded => 'No associated data added';

  @override
  String get associatedEdit => 'Edit associated data';

  @override
  String get associatedDataType => 'Data type';

  @override
  String get associatedDataTypeHint => 'Select data type';

  @override
  String get associatedNameHint => 'e.g., GenBank or MorphoSource';

  @override
  String get associatedDescriptionHint => 'Describe the associated data';

  @override
  String get associatedResource => 'Resource';

  @override
  String get associatedNonMediaFiles => 'Non-media files';

  @override
  String get associatedCopyToProject => 'Copy to project';

  @override
  String get associatedLinkOriginal => 'Link original';

  @override
  String get associatedLinkOriginalWarning =>
      'The link will stop working if the original file is moved or deleted.';

  @override
  String get associatedSelectDataType => 'Select a data type.';

  @override
  String get associatedEnterValidUri => 'Enter a valid URI.';

  @override
  String get associatedSelectFile => 'Select a file.';

  @override
  String get associatedNoIdentifier => 'Associated data has no identifier.';

  @override
  String get associatedInfo => 'Associated data info';

  @override
  String get associatedOriginStoragePath => 'Origin storage path';

  @override
  String get associatedLinkedOriginal => 'Linked original';

  @override
  String get associatedProjectCopy => 'Project copy';

  @override
  String get associatedAvailability => 'Availability';

  @override
  String get associatedChecking => 'Checking…';

  @override
  String get legalReadThe => 'Please read the ';

  @override
  String get legalTermsAndConditions => 'Terms and Conditions';

  @override
  String get legalAndThe => ' and the ';

  @override
  String get legalPrivacyPolicy => 'Privacy Policy';

  @override
  String get legalBeforeYouStart =>
      ' before you start. Using NAHPU accepts them.';

  @override
  String get legalTermsTile => 'Terms and conditions';

  @override
  String get legalPrivacyTile => 'Privacy policy';

  @override
  String get mapCenterOnCoordinates => 'Center map on coordinates';

  @override
  String mapMoreCount(int count) {
    return '+$count more';
  }

  @override
  String get mapTapToZoomIn => 'Tap to zoom in';

  @override
  String get mapNaturalEarthOffline => 'Natural Earth · offline';

  @override
  String get mapRetryDetailed => 'Try the detailed map again';

  @override
  String get siteAddCoordinates => 'Add coordinates';

  @override
  String get siteViewMap => 'View map';

  @override
  String siteAddSelected(int count) {
    return 'Add $count selected';
  }

  @override
  String get siteNewCoordinate => 'New coordinate';

  @override
  String get siteSupportedFiles => 'Supported files:';

  @override
  String get siteSupportedFileTypes =>
      'CSV, TSV, Excel, GeoJSON/JSON, KML, zipped Shapefile, and GPX.';

  @override
  String get siteSelectCoordinateFile => 'Select coordinate file';

  @override
  String siteRowsSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows skipped',
      one: '1 row skipped',
    );
    return '$_temp0';
  }

  @override
  String get siteEditColumnMapping => 'Edit column mapping';

  @override
  String get siteChooseAnotherFile => 'Choose another file';

  @override
  String get siteCoordinateChanged =>
      'The coordinate changed. Refresh the map to update the preview.';

  @override
  String get siteEnterValidCoordinate =>
      'Enter a valid WGS84 latitude and longitude, then refresh the map.';

  @override
  String get siteRefreshMap => 'Refresh map';

  @override
  String get siteEditCoordinates => 'Edit Coordinates';

  @override
  String get siteAddName => 'Add a name';

  @override
  String get siteDeviceGps => 'Device GPS';

  @override
  String get siteDeviceGpsBody => 'Use device sensor to autofill coordinates';

  @override
  String get siteGetLocation => 'Get location';

  @override
  String get siteCoordinateFormat => 'Coordinate format';

  @override
  String get siteDecimalDegrees => 'Decimal degrees';

  @override
  String get siteDdm => 'Degrees decimal minutes (DDM)';

  @override
  String get siteDms => 'Degrees minutes seconds (DMS)';

  @override
  String get siteUtm => 'UTM (WGS84)';

  @override
  String get siteUtmCoordinate => 'UTM coordinate';

  @override
  String get siteDecimalLatitude => 'Decimal Latitude';

  @override
  String get siteAddLatitude => 'Add a latitude';

  @override
  String get siteDecimalLongitude => 'Decimal Longitude';

  @override
  String get siteAddLongitude => 'Add a longitude';

  @override
  String get siteAddElevation => 'Add an elevation';

  @override
  String get siteSpecifyDatum => 'Specify the datum';

  @override
  String get siteAddUncertainty => 'Add an uncertainty';

  @override
  String get siteGpsUnit => 'GPS Unit';

  @override
  String get siteSpecifyGpsUnit => 'Specify the GPS unit';

  @override
  String get siteAddNotes => 'Add notes (optional)';

  @override
  String get siteChangeFormatTitle => 'Change coordinate format?';

  @override
  String get siteChangeFormatBody =>
      'Changing the format clears the entered coordinate values. Name, elevation, datum, uncertainty, GPS unit, and notes are kept.';

  @override
  String get siteClearAndSwitch => 'Clear and switch';

  @override
  String siteInvalidVerbatim(String axis, String value) {
    return 'This verbatim $axis could not be read and may have been changed outside NAHPU. Re-enter it before saving.\nOriginal: $value';
  }

  @override
  String get siteMissingValue => '(missing)';

  @override
  String get siteDegree => 'Degree';

  @override
  String get siteMinute => 'Minute';

  @override
  String get siteSecond => 'Second';

  @override
  String get siteManageCoordinates => 'Manage coordinates';

  @override
  String get siteCoordinateMap => 'Coordinate map';

  @override
  String siteExportCoordinatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Export $count coordinates',
      one: 'Export 1 coordinate',
    );
    return '$_temp0';
  }

  @override
  String get siteFormatGeoJson => 'GeoJSON (.geojson)';

  @override
  String get siteFormatShapefile => 'Shapefile bundle (.zip)';

  @override
  String get siteShowCoordinates => 'Show coordinates';

  @override
  String get siteAllCoordinates => 'All coordinates';

  @override
  String siteLoadSitesError(String error) {
    return 'Unable to load sites: $error';
  }

  @override
  String siteLoadCoordinatesError(String error) {
    return 'Unable to load coordinates: $error';
  }

  @override
  String siteExportSelectedCoordinates(int count) {
    return 'Export coordinates ($count)';
  }

  @override
  String get siteNoCoordinates => 'No coordinates added';

  @override
  String siteSelectedOfCoordinates(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total coordinates',
      one: '1 coordinate',
    );
    return '$count of $_temp0';
  }

  @override
  String siteUnnamedCoordinateId(String id) {
    return 'Unnamed coordinate ($id)';
  }

  @override
  String siteCoordinatesNotShown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count coordinates are not shown because latitude or longitude is missing or invalid.',
      one:
          '1 coordinate is not shown because latitude or longitude is missing or invalid.',
    );
    return '$_temp0';
  }

  @override
  String get siteCoordinateActions => 'Coordinate actions';

  @override
  String get siteCopy => 'Copy';

  @override
  String get siteOpenInMap => 'Open in map';

  @override
  String get siteCoordinateDetails => 'Coordinate Details';

  @override
  String get siteCopiedToClipboard =>
      'Latitude and Longitude copied to clipboard';

  @override
  String get siteNoName => 'No Name';

  @override
  String get siteOriginalCoordinate => 'Original coordinate';

  @override
  String get siteOriginalFormat => 'Original format';

  @override
  String get siteUncertainty => 'Uncertainty';

  @override
  String get siteUnnamedCoordinate => 'Unnamed coordinate';

  @override
  String get siteAddCoordinate => 'Add coordinate';

  @override
  String get siteNoId => 'No ID';

  @override
  String siteColumnsDetected(int columns, int rows) {
    return '$columns columns and $rows data rows detected. NAHPU inferred the matches below. Latitude and longitude are required; all other fields are optional.';
  }

  @override
  String siteColumnsDetectedInWorksheet(
    int columns,
    int rows,
    String worksheet,
  ) {
    return '$columns columns and $rows data rows detected in worksheet \"$worksheet\". NAHPU inferred the matches below. Latitude and longitude are required; all other fields are optional.';
  }

  @override
  String get siteNotIncluded => 'Not included';

  @override
  String siteHeaderColumn(String header, int index) {
    return '$header (column $index)';
  }

  @override
  String get siteReviewCoordinates => 'Review coordinates';

  @override
  String get siteImportFieldNameId => 'Name / ID';

  @override
  String get siteCopyFromProject => 'Copy from project';

  @override
  String get siteChooseDataToCopy => 'Choose data to copy';

  @override
  String get siteSelectSourceProject =>
      'Select the project that contains the site to copy.';

  @override
  String siteSelectFromProject(String project) {
    return 'Select a site from $project.';
  }

  @override
  String get siteNoSitesInProject => 'No sites found in this project.';

  @override
  String get siteSelectDataToCopy =>
      'Select the data to copy into the empty site.';

  @override
  String get siteNoCopyableData => 'The selected site has no copyable data.';

  @override
  String get siteNoDataInSource => 'No data in source';

  @override
  String get siteMustBeEmptyBody =>
      'The current site must be empty before copying data. Clear its site information, coordinates, media, and linked data first.';

  @override
  String get siteMustBeEmpty => 'Site must be empty';

  @override
  String get siteNeedAnotherProject =>
      'Create or import another project before copying site data.';

  @override
  String get siteMultipleProjectsRequired => 'Multiple projects required';

  @override
  String siteUnnamedSite(String id) {
    return 'Unnamed site #$id';
  }

  @override
  String siteGeographySettingsError(String error) {
    return 'Unable to load geography settings: $error';
  }

  @override
  String get siteFindLocalityTooltip =>
      'Type a locality and select a saved one to fill every geography field';

  @override
  String get siteFindLocality => 'Find existing locality';

  @override
  String get siteFindLocalityHint => 'Type to reuse a saved locality';

  @override
  String get siteEnterCountry => 'Enter a country';

  @override
  String get siteEnterIslandGroup => 'Enter an island group';

  @override
  String get siteEnterStateProvince => 'Enter a state/province';

  @override
  String get siteEnterCounty => 'Enter a county/parish/district';

  @override
  String get siteEnterMunicipality => 'Enter a municipality/city/town';

  @override
  String get sitePreciseLocality => 'Precise Locality';

  @override
  String get sitePreciseLocalityHint =>
      'Enter a precise locality lower than municipality';

  @override
  String get siteRemarksHint => 'Enter more info about the site (optional)';

  @override
  String get siteHabitatType => 'Habitat Type';

  @override
  String get siteHabitatTypeHint => 'Select a habitat type';

  @override
  String get siteHabitatCondition => 'Habitat Condition';

  @override
  String get siteHabitatConditionHint =>
      'E.g. \"Pristine\", \"Disturbed\", \"etc.\"';

  @override
  String get siteHabitatDescription => 'Habitat Description';

  @override
  String get siteHabitatDescriptionHint =>
      'Describe the site, e.g. \"A camp site in the middle of the forest.\"';

  @override
  String get siteCanopyCover => 'Canopy Cover';

  @override
  String get siteCanopyCoverHint => 'Enter canopy cover';

  @override
  String get siteCreate => 'Create site';

  @override
  String get siteActions => 'Site actions';

  @override
  String get siteDuplicate => 'Duplicate site';

  @override
  String get siteCopyFromProjectMenu => 'Copy from project ...';

  @override
  String get siteExport => 'Export site';

  @override
  String get siteImport => 'Import site';

  @override
  String siteCopiedSummary(
    String fields,
    String coordinates,
    String site,
    String project,
  ) {
    return 'Copied $fields and $coordinates from $site in $project.';
  }

  @override
  String siteFieldCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fields',
      one: '1 field',
    );
    return '$_temp0';
  }

  @override
  String get siteDeleteTitle => 'Delete site?';

  @override
  String get siteDeleteBody => 'You will delete all records in this site form';

  @override
  String get siteDeleteAllTitle => 'Delete all sites?';

  @override
  String get siteDeleteAllBody => 'You will delete all site records';

  @override
  String get siteDeleteInUse =>
      'Cannot delete sites. Being used by other records.';

  @override
  String get siteIdentity => 'Site Identity';

  @override
  String get siteIdHint =>
      'Enter a site ID (max. 40 chars), e.g. \"CAMP-01\", \"LINE-1\"';

  @override
  String get siteLeader => 'Site Leader';

  @override
  String get siteType => 'Site Type';

  @override
  String get siteTypeHint => 'Choose a site type';

  @override
  String get siteSearch => 'Search sites';

  @override
  String get siteRecordTitle => 'Site Record';

  @override
  String get siteNoneFound => 'No site found';

  @override
  String get siteCopyFieldSiteLeader => 'Site leader';

  @override
  String get siteCopyFieldSiteType => 'Site type';

  @override
  String get siteCopyFieldPreciseLocality => 'Precise locality';

  @override
  String get siteCopyFieldHabitatType => 'Habitat type';

  @override
  String get siteCopyFieldHabitatCondition => 'Habitat condition';

  @override
  String get siteCopyFieldHabitatDescription => 'Habitat description';

  @override
  String get siteCopyFieldCanopyCover => 'Canopy cover';

  @override
  String eventEnvironmentLoadError(String error) {
    return 'Unable to load environmental data: $error';
  }

  @override
  String get eventDayLowest => 'Day Lowest';

  @override
  String get eventDayHighest => 'Day Highest';

  @override
  String get eventNightLowest => 'Night Lowest';

  @override
  String get eventNightHighest => 'Night Highest';

  @override
  String get eventAverage => 'Average';

  @override
  String get eventDewPoint => 'Dew Point';

  @override
  String get eventEnterLowestTemp => 'Enter lowest temperature';

  @override
  String get eventEnterHighestTemp => 'Enter highest temperature';

  @override
  String get eventEnterAverageHumidity => 'Enter average humidity';

  @override
  String get eventEnterDewPoint => 'Enter dew point';

  @override
  String get eventCloudCover => 'Cloud cover (oktas)';

  @override
  String get eventCloudCoverHint => 'Select cloud cover';

  @override
  String get eventCloudCoverHelper =>
      'One okta represents one eighth of the visible sky.';

  @override
  String eventInvalidStoredValue(String value) {
    return '$value — Invalid stored value';
  }

  @override
  String get eventEnterRainfall => 'Enter rainfall';

  @override
  String get eventEnterAmbientTemp => 'Enter ambient temperature';

  @override
  String get eventEnterRelativeHumidity => 'Enter relative humidity';

  @override
  String get eventEnterWaterTemp => 'Enter water temperature';

  @override
  String get eventEnterPh => 'Enter pH';

  @override
  String get eventEnterDissolvedOxygen => 'Enter dissolved oxygen';

  @override
  String get eventEnterOxygenSaturation => 'Enter dissolved oxygen saturation';

  @override
  String get eventEnterConductivity => 'Enter conductivity';

  @override
  String get eventEnterFlowVelocity => 'Enter flow velocity';

  @override
  String get eventEnterSunrise => 'Enter sunrise time';

  @override
  String get eventEnterSunset => 'Enter sunset time';

  @override
  String get eventMoonPhaseHint => 'Select moon phase';

  @override
  String eventRecoveryTitle(int count) {
    return 'Some stored environmental values need attention ($count)';
  }

  @override
  String get eventRecoveryBody =>
      'Correct or clear the highlighted fields. Other values will not be changed.';

  @override
  String eventSaveValueError(String error) {
    return 'Could not save this value: $error';
  }

  @override
  String get eventEnterValidNumber => 'Enter a valid number.';

  @override
  String eventValueRange(String minimum, String maximum) {
    return 'Enter a value from $minimum to $maximum';
  }

  @override
  String eventValueMinimum(String minimum) {
    return 'Enter a value of $minimum or more';
  }

  @override
  String get eventOkta0 => '0 — Clear sky';

  @override
  String get eventOkta1 => '1 — Up to 1/8 covered';

  @override
  String get eventOkta2 => '2 — 2/8 covered';

  @override
  String get eventOkta3 => '3 — 3/8 covered';

  @override
  String get eventOkta4 => '4 — Half covered';

  @override
  String get eventOkta5 => '5 — 5/8 covered';

  @override
  String get eventOkta6 => '6 — 6/8 covered';

  @override
  String get eventOkta7 => '7 — At least 7/8, not overcast';

  @override
  String get eventOkta8 => '8 — Fully overcast';

  @override
  String get eventOkta9 => '9 — Sky obscured';

  @override
  String get eventMoonNew => 'New Moon';

  @override
  String get eventMoonWaxingCrescent => 'Waxing Crescent';

  @override
  String get eventMoonFirstQuarter => 'First Quarter';

  @override
  String get eventMoonWaxingGibbous => 'Waxing Gibbous';

  @override
  String get eventMoonFull => 'Full Moon';

  @override
  String get eventMoonWaningGibbous => 'Waning Gibbous';

  @override
  String get eventMoonLastQuarter => 'Last Quarter';

  @override
  String get eventMoonWaningCrescent => 'Waning Crescent';

  @override
  String get eventActivity => 'Activity';

  @override
  String get eventPrimaryActivity => 'Primary activity';

  @override
  String get eventSelectActivity => 'Select an activity';

  @override
  String eventActivitiesLoadError(String error) {
    return 'Unable to load primary activities: $error';
  }

  @override
  String get eventActivityNotesHint => 'Enter notes about the activity';

  @override
  String get eventAddCollMethod => 'Add collection method';

  @override
  String get eventNoCollMethods => 'No collection methods added';

  @override
  String get eventAddCollMethodTitle => 'Add Collection Method';

  @override
  String get eventEditCollMethod => 'Edit Collection Method';

  @override
  String get eventCollMethod => 'Collection method';

  @override
  String get eventCountHint =>
      'How many of this tool were used (if applicable)?';

  @override
  String get eventMethodDetails => 'Method details';

  @override
  String get eventBrandModel => 'Brand and Model';

  @override
  String get eventBrandModelHint =>
      'Enter brand and model of the tool (if applicable)';

  @override
  String get eventSizeHint => 'Enter size of the tool (if applicable)';

  @override
  String get eventToolNotesHint =>
      'Enter any notes about the tool (if applicable)';

  @override
  String get eventSelectMethod => 'Select a method';

  @override
  String get eventIdentity => 'Event Identity';

  @override
  String get eventStartDate => 'Start Date';

  @override
  String get eventEndDate => 'End Date';

  @override
  String get eventEditId => 'Edit Event ID';

  @override
  String get eventIdSuffix => 'ID suffix';

  @override
  String get eventIdSuffixHint => 'Enter ID suffix';

  @override
  String get eventIdLabel => 'Event ID: ';

  @override
  String get eventStartTime => 'Start Time';

  @override
  String get eventEndTime => 'End Time';

  @override
  String get eventCreate => 'Create event';

  @override
  String get eventDeleteInUse =>
      'Failed to delete the events. The events are currently in use by other records.';

  @override
  String get eventActions => 'Event actions';

  @override
  String get eventDuplicate => 'Duplicate event';

  @override
  String get eventExport => 'Export event';

  @override
  String get eventImport => 'Import event';

  @override
  String get eventDeleteTitle => 'Delete collecting event?';

  @override
  String get eventDeleteBody =>
      'You will also delete collection methods, collecting personnel, environmental data, and media in this event.';

  @override
  String get eventDeleteAllTitle => 'Delete all collecting events?';

  @override
  String get eventDeleteAllBody =>
      'Deleting all collecting events will also delete all associated collection methods, collecting personnel, environmental data, and media from the database.';

  @override
  String get eventPersonnel => 'Event Personnel';

  @override
  String get eventNoPersonnel => 'No personnel added';

  @override
  String get eventUnknownPersonnel => 'Unknown personnel';

  @override
  String get eventEnterRole => 'Enter a role';

  @override
  String get eventSearch => 'Search events';

  @override
  String get eventRecordTitle => 'Collecting Event Record';

  @override
  String get eventNoneFound => 'No collecting event found';

  @override
  String exportPresetsLoadError(String error) {
    return 'Unable to load export presets: $error';
  }

  @override
  String get exportPreset => 'Export preset';

  @override
  String get exportNoPresets =>
      'No export presets found. Manage presets in settings to create one.';

  @override
  String get exportManagePresetsButton => 'Manage Presets';

  @override
  String get exportPresetHelper =>
      'Record type, headers, and field mappings are set by the preset.';

  @override
  String get exportPresetDetails => 'Preset details';

  @override
  String get exportSelectPresetPrompt =>
      'Select an export preset to see details and preview.';

  @override
  String exportPresetName(String name) {
    return 'Preset: $name';
  }

  @override
  String exportPresetRecord(String type) {
    return 'Record: $type';
  }

  @override
  String exportPresetTaxon(String taxon) {
    return 'Taxon: $taxon';
  }

  @override
  String exportPresetHeader(String format) {
    return 'Header: $format';
  }

  @override
  String exportSelectedColumns(int count) {
    return 'Selected Columns ($count):';
  }

  @override
  String get exportPreviewTable => 'Preview Table';

  @override
  String get exportNoFieldsMapped => 'No fields mapped in this preset.';

  @override
  String exportNestedFields(String namespace, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fields',
      one: '1 field',
    );
    return '$namespace ($_temp0)';
  }

  @override
  String get exportTablePreview => 'Table preview';

  @override
  String get exportNoRecordsForPreset => 'No records found for this preset.';

  @override
  String exportShowingRecords(int start, int end, int total) {
    return 'Showing $start-$end of $total records';
  }

  @override
  String exportPageOf(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get exportBundling => 'Bundling records';

  @override
  String get exportBundlingHint =>
      'Packaging writes the records, copies media, compresses the bundle, and then checks it. Keep NAHPU open.';

  @override
  String get exportCreateBundle => 'Create bundle';

  @override
  String get exportBundleAnother => 'Bundle another';

  @override
  String get exportCancelBundleTitle => 'Cancel the bundle?';

  @override
  String get exportCancelBundleBody =>
      'The bundle is still being written. Leaving now cancels it and no package will be saved.';

  @override
  String get exportKeepBundling => 'Keep bundling';

  @override
  String get exportCancelBundle => 'Cancel bundle';

  @override
  String exportCreatedFile(String file) {
    return 'Created $file';
  }

  @override
  String get exportBundleComplete => 'Bundle complete!';

  @override
  String get exportCompleteData => 'Complete NAHPU data';

  @override
  String get exportCompleteDataBody =>
      'This bundle includes all NAHPU database tables, a restorable project snapshot, user configurations, available media, and custom fonts.';

  @override
  String get exportFrictionless => 'Export is in Frictionless Data Format.';

  @override
  String get exportRecordedTaxa => 'Recorded Taxa';

  @override
  String get exportSelectedTaxa => 'Selected taxa';

  @override
  String get exportNoTaxaRecorded => 'No specimen taxa have been recorded yet.';

  @override
  String exportTaxonGroupsIncluded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recorded taxon groups will be included.',
      one: '1 recorded taxon group will be included.',
    );
    return '$_temp0';
  }

  @override
  String get exportPackageContents => 'Package contents';

  @override
  String get exportSelectTaxonPrompt =>
      'Select at least one recorded taxon to list the package contents.';

  @override
  String get exportPackageContentsBody =>
      'The list reflects exactly what will be bundled. Empty optional fields and tables are omitted.';

  @override
  String exportRecordsAndFields(int records, int fields) {
    String _temp0 = intl.Intl.pluralLogic(
      records,
      locale: localeName,
      other: '$records records',
      one: '1 record',
    );
    String _temp1 = intl.Intl.pluralLogic(
      fields,
      locale: localeName,
      other: '$fields fields',
      one: '1 field',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get exportBackingUp => 'Backing up database';

  @override
  String get exportBackingUpHint =>
      'Large media libraries can take several minutes. Keep NAHPU open until this finishes.';

  @override
  String get exportSaveBackup => 'Save backup';

  @override
  String get exportSaveAnother => 'Save another';

  @override
  String get exportCancelBackupTitle => 'Cancel the backup?';

  @override
  String get exportCancelBackupBody =>
      'The backup is still running. Leaving now cancels it and no file will be saved.';

  @override
  String get exportKeepBackingUp => 'Keep backing up';

  @override
  String get exportCancelBackup => 'Cancel backup';

  @override
  String get exportBackupArchive => 'Backup archive';

  @override
  String get exportBackupBody =>
      'This creates a full NAHPU database backup. For a project-only backup, use Export project.';

  @override
  String get exportBackupDetail =>
      'It copies all projects and every file in NAHPU app data, whether or not a project links to it. Run it occasionally in the field, when battery use is not a concern.';

  @override
  String get exportWillExport => 'Will export';

  @override
  String exportUserConfigsExportedTo(String path) {
    return 'User configs exported to $path';
  }

  @override
  String get exportCustomFieldTemplates => 'Custom field templates';

  @override
  String get exportNoCustomFields => 'No custom fields available';

  @override
  String get exportNoPrintLayouts =>
      'No print layouts yet. Load the default layouts, or create one in Document Presets.';

  @override
  String get exportEnterFileNameFirst => 'Enter a file name first.';

  @override
  String exportShareFailed(String error) {
    return 'Unable to share export: $error';
  }

  @override
  String get exportFormatOptionsTitle => 'Format Options';

  @override
  String get exportFormatOptions => 'Format options';

  @override
  String get exportConcatenateMultiEntry => 'Concatenate multi-entry records';

  @override
  String get exportFieldNamesOnly => 'Field names only for headers';

  @override
  String get exportSelectFieldsTitle => 'Select Fields';

  @override
  String get exportClearAll => 'Clear All';

  @override
  String get exportRequired => 'Required';

  @override
  String get dataTableMoreActions => 'More actions';

  @override
  String dataTableNoMatches(String records) {
    return 'No $records match your search and filters.';
  }

  @override
  String dataTableNoRecordsYet(String records) {
    return 'No $records yet.';
  }

  @override
  String dataTableNoRecordsForTaxaYet(String records, String taxa) {
    return 'No $records for $taxa yet.';
  }

  @override
  String dataTableProjectNoRecordsForTaxa(String records, String taxa) {
    return 'This project has no $records for $taxa.';
  }

  @override
  String dataTableProjectNoRecordsYet(String records) {
    return 'This project has no $records yet.';
  }

  @override
  String get dataTableSaved => 'Saved.';

  @override
  String dataTableLoadError(String records) {
    return 'Couldn\'t load $records.';
  }

  @override
  String get dataTableSomeChangesFailed =>
      'Some changes couldn\'t be saved. Check the marked cells.';

  @override
  String get dataTableNoMoreMatches => 'No more matches.';

  @override
  String get dataTableNoEarlierMatches => 'No earlier matches.';

  @override
  String get dataTableCellCannotBeReplaced => 'This cell can\'t be replaced.';

  @override
  String dataTableReadForReplaceError(String error) {
    return 'Couldn\'t read records to replace: $error';
  }

  @override
  String get dataTableNothingToReplace => 'Nothing to replace.';

  @override
  String get dataTableReplaceAllTitle => 'Replace all?';

  @override
  String dataTableReplaceAllBody(String values, String records) {
    return 'Replace $values in $records?';
  }

  @override
  String dataTableValueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count values',
      one: '1 value',
    );
    return '$_temp0';
  }

  @override
  String dataTableRecordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
    );
    return '$_temp0';
  }

  @override
  String get dataTableAutoSaveWrites => 'Auto-save writes them right away.';

  @override
  String get dataTableWaitForSave => 'They wait for Save.';

  @override
  String dataTableReplaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Replaced $count values.',
      one: 'Replaced 1 value.',
    );
    return '$_temp0';
  }

  @override
  String dataTableSkippedChoices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dropdown values skipped; pick those from their list.',
      one: '1 dropdown value skipped; pick it from its list.',
    );
    return '$_temp0';
  }

  @override
  String dataTableInvalidValues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count values wouldn\'t fit their fields.',
      one: '1 value wouldn\'t fit its field.',
    );
    return '$_temp0';
  }

  @override
  String get dataTablePickDate => 'Pick a date';

  @override
  String get dataTablePickTime => 'Pick a time';

  @override
  String get dataTableSaveChangesTitle => 'Save your changes?';

  @override
  String dataTableUnsavedChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count unsaved changes in this table.',
      one: 'You have 1 unsaved change in this table.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableFindField => 'Find a field';

  @override
  String dataTableFieldsShown(int count, int total) {
    return '$count of $total fields shown';
  }

  @override
  String get dataTableComputedNotSearchable =>
      'Calculated during export: not searchable or sortable';

  @override
  String get dataTableShowAll => 'Show all';

  @override
  String get dataTableAutoSaveTooltip =>
      'Save each change as you commit it. Undo with Ctrl+Z or ⌘Z while this table is open.';

  @override
  String get dataTableAutoSave => 'Auto-save';

  @override
  String get dataTableDiscardChanges => 'Discard changes';

  @override
  String get dataTableRetrySave => 'Retry save';

  @override
  String get dataTableEditModeOn => 'Edit mode is on (Ctrl+E or ⌘E)';

  @override
  String get dataTableEditModeOff => 'Edit mode is off (Ctrl+E or ⌘E)';

  @override
  String dataTableCellsNeedAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cells need attention',
      one: '1 cell needs attention',
    );
    return '$_temp0';
  }

  @override
  String dataTableUnsavedChangeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unsaved changes',
      one: '1 unsaved change',
    );
    return '$_temp0';
  }

  @override
  String get dataTableAllChangesSaved => 'All changes saved';

  @override
  String dataTableColumnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count columns',
      one: '1 column',
    );
    return '$_temp0';
  }

  @override
  String dataTableExportSummary(String records, String columns) {
    return '$records × $columns, with the current search, filters, sort, and visible columns.';
  }

  @override
  String get dataTableColumnHeaders => 'Column headers';

  @override
  String get dataTableDwcOnly => 'Darwin Core-mapped columns only';

  @override
  String get dataTableDwcOnlyBody =>
      'Leave out columns without a Darwin Core term. Otherwise they keep their NAHPU key.';

  @override
  String dataTableReadProgress(int count, int total) {
    return 'Read $count of $total records';
  }

  @override
  String dataTableScopeChip(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get dataTableClearFilters => 'Clear filters';

  @override
  String dataTableBetweenValues(String low, String high) {
    return '$low and $high';
  }

  @override
  String get dataTableFilterRules => 'Filter rules';

  @override
  String get dataTableFilterRulesBody => 'Show records that match every rule.';

  @override
  String get dataTableAddRule => 'Add rule';

  @override
  String get dataTableEnterValueEveryRule => 'Enter a value for every rule.';

  @override
  String get dataTableEnterDates => 'Enter dates as YYYY-MM-DD.';

  @override
  String get dataTableEnterTimes => 'Enter times as HH:MM.';

  @override
  String get dataTableChooseListed => 'Choose one of the listed values.';

  @override
  String get dataTableEnterNumber => 'Enter a number.';

  @override
  String get dataTableComputedNotFilterable =>
      'Calculated during export; not filterable';

  @override
  String get dataTableRemoveRule => 'Remove rule';

  @override
  String get dataTableReplacingNeedsEditMode => 'Replacing needs edit mode.';

  @override
  String get dataTableMatchCase => 'Match case';

  @override
  String get dataTableWholeCell => 'Whole cell';

  @override
  String get dataTablePreviousMatch => 'Previous match';

  @override
  String get dataTableNextMatch => 'Next match';

  @override
  String get dataTableTurnOnEditMode => 'Turn on edit mode';

  @override
  String get dataTableReplaceAll => 'Replace all';

  @override
  String get dataTableNoMatchesShort => 'No matches';

  @override
  String dataTableFoundCount(int count) {
    return '$count found';
  }

  @override
  String dataTableMatchOf(int current, int total) {
    return '$current of $total';
  }

  @override
  String get dataTableAllVisibleColumns => 'All visible columns';

  @override
  String dataTableColumnReadOnly(String column) {
    return '$column is read-only here.';
  }

  @override
  String dataTableSkippedOffList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Skipped $count values that aren\'t in their lists.',
      one: 'Skipped 1 value that isn\'t in its list.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableChangeFishTypeTitle => 'Change fish record type?';

  @override
  String dataTableSexClears(String fields) {
    return 'This clears $fields that no longer apply to the new sex.';
  }

  @override
  String get dataTableFishTypeChangeBody =>
      'Switching between an individual and a lot changes which measurements apply.';

  @override
  String dataTableSkippedReadOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Skipped $count read-only or linked cells.',
      one: 'Skipped 1 read-only or linked cell.',
    );
    return '$_temp0';
  }

  @override
  String dataTableCopiedCells(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copied $count cells.',
      one: 'Copied 1 cell.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableSwitchToEditToPaste => 'Switch to edit mode to paste.';

  @override
  String dataTablePastedSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pasted; skipped $count read-only or linked cells.',
      one: 'Pasted; skipped 1 read-only or linked cell.',
    );
    return '$_temp0';
  }

  @override
  String get dataTablePastedCutOff =>
      'Pasted; cut off at the edge of the page.';

  @override
  String dataTablePastedSkippedAndCutOff(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Pasted; skipped $count read-only or linked cells and cut off at the edge of the page.',
      one:
          'Pasted; skipped 1 read-only or linked cell and cut off at the edge of the page.',
    );
    return '$_temp0';
  }

  @override
  String get dataTableComputedField =>
      'Calculated during export: not searchable, sortable, or filterable.';

  @override
  String get dataTableLinkedDataHint =>
      'Linked data: double-click or press F2 to edit.';

  @override
  String get dataTableReadOnlyHere => 'Read-only here.';

  @override
  String get dataTableOpenForm => 'Open form';

  @override
  String dataTableLinkCurrent(String value) {
    return 'Now: $value.';
  }

  @override
  String get dataTableLoadChoicesError => 'Couldn\'t load the choices.';

  @override
  String get dataTableLinkCatalogerNote =>
      'The field number follows the new cataloger. The determiner and preparator change too when they were the previous cataloger.';

  @override
  String get dataTableLinkEventNote =>
      'The collecting method and personnel are cleared, and the coordinate follows the new event\'s site.';

  @override
  String get dataTableLinkTaxonNote =>
      'Order, family, genus, and epithet all come from the chosen taxon.';

  @override
  String dataTableSaveError(String error) {
    return 'Couldn\'t save: $error';
  }

  @override
  String get dataTableNothingMatches => 'Nothing matches.';

  @override
  String dataTableNotLinked(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'site': 'This record isn\'t linked to a site yet.',
      'other': 'This record isn\'t linked to an event yet.',
    });
    return '$_temp0';
  }

  @override
  String dataTableLinkedLoadError(String noun) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'site': 'Couldn\'t load the site.',
      'other': 'Couldn\'t load the event.',
    });
    return '$_temp0';
  }

  @override
  String dataTableLinkShared(String noun, int count) {
    String _temp0 = intl.Intl.selectLogic(noun, {
      'site': 'Changes apply to every record linked to this site ($count).',
      'other': 'Changes apply to every record linked to this event ($count).',
    });
    return '$_temp0';
  }

  @override
  String get dataTableSomeChangesNotSaved => 'Some changes couldn\'t be saved.';

  @override
  String get dataTablePageRangeEmpty => '0 of 0';

  @override
  String dataTablePageRange(String first, String last, String total) {
    return '$first–$last of $total';
  }

  @override
  String get dataTableRowsPerPage => 'Rows per page';

  @override
  String get dataTableFirstPage => 'First page';

  @override
  String get dataTablePreviousPage => 'Previous page';

  @override
  String get dataTableNextPage => 'Next page';

  @override
  String get dataTableLastPage => 'Last page';

  @override
  String dataTableSearchIn(String target) {
    return 'Search $target';
  }

  @override
  String get dataTableRefresh => 'Refresh';

  @override
  String get dataTableAddFieldRules => 'Add field rules';

  @override
  String get dataTableEditFieldRules => 'Edit field rules';

  @override
  String get dataTableFilters => 'Filters';

  @override
  String get dataTableAllVisibleFields => 'All visible fields';

  @override
  String get dataTableSearchingAllFields => 'Searching all visible fields';

  @override
  String dataTableSearchingField(String field) {
    return 'Searching $field';
  }

  @override
  String get dataTableFilterOpIs => 'is';

  @override
  String get dataTableFilterOpContains => 'contains';

  @override
  String get dataTableFilterOpStartsWith => 'starts with';

  @override
  String get dataTableFilterOpGreaterThan => 'greater than';

  @override
  String get dataTableFilterOpLessThan => 'less than';

  @override
  String get dataTableFilterOpBetween => 'between';

  @override
  String get dataTableFilterOpIsEmpty => 'is empty';

  @override
  String get dataTableFilterOpIsNotEmpty => 'is not empty';

  @override
  String get dataTableQuickMissingTaxon => 'Missing taxon';

  @override
  String get dataTableQuickNoFieldNumber => 'No field number';

  @override
  String get dataTableQuickNoEvent => 'No event';

  @override
  String get dataTableQuickHasParts => 'Has parts';

  @override
  String get dataTableQuickHasMedia => 'Has media';

  @override
  String get dataTableQuickNoTissueId => 'No tissue ID';

  @override
  String get dataTableQuickNoParasiteId => 'No parasite ID';

  @override
  String get dataTableQuickNoCoordinates => 'No coordinates';

  @override
  String get dataTableQuickNoLocality => 'No locality';

  @override
  String get dataTableQuickNoSpecimens => 'No specimens';

  @override
  String get dataTableQuickNoEndDate => 'No end date';

  @override
  String get dataTableQuickNoSite => 'No site';

  @override
  String dataTableProjectScopeOne(String name) {
    return 'Project: $name';
  }

  @override
  String dataTableProjectScopeTwo(String first, String second) {
    return 'Projects: $first, $second';
  }

  @override
  String dataTableProjectScopeMany(int count) {
    return '$count projects';
  }

  @override
  String get siteImportFieldGpsUnit => 'GPS unit';

  @override
  String get projectTissueCustomLabels => 'Customize cell labels';

  @override
  String get projectTissueBoxSeparator => 'Box separator';

  @override
  String get projectTissueRowColumnSeparator => 'Row–column separator';

  @override
  String get projectTissueZeroPad => 'Pad numbers with zeros';

  @override
  String projectTissueLabelExample(String example) {
    return 'Example: $example';
  }
}
