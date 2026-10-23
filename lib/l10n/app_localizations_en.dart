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
}
