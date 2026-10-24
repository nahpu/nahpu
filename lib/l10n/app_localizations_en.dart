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
}
