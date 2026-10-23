import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_id.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('id'),
    Locale('pt'),
  ];

  /// Badge on features that are still in beta.
  ///
  /// In en, this message translates to:
  /// **'Beta'**
  String get commonBeta;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Shown when a value, such as the app version, cannot be read.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get commonUnavailable;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @homeDatabaseErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the NAHPU database.'**
  String get homeDatabaseErrorTitle;

  /// No description provided for @homeDatabaseErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Your data was not deleted. Retry the database migration or restart NAHPU.'**
  String get homeDatabaseErrorBody;

  /// No description provided for @homeExistingProjects.
  ///
  /// In en, this message translates to:
  /// **'Existing projects'**
  String get homeExistingProjects;

  /// No description provided for @homeNoProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'No projects found.'**
  String get homeNoProjectsTitle;

  /// No description provided for @homeNoProjectsBody.
  ///
  /// In en, this message translates to:
  /// **'Create or import a project to get started.'**
  String get homeNoProjectsBody;

  /// Uses the homeSetupNahpu label as the name of the setup wizard.
  ///
  /// In en, this message translates to:
  /// **'New to NAHPU? Run Setup NAHPU to choose your catalog format, identifiers, vocabularies, and export presets.'**
  String get homeSetupHint;

  /// Name of the setup wizard, used as a button and menu label.
  ///
  /// In en, this message translates to:
  /// **'Setup NAHPU'**
  String get homeSetupNahpu;

  /// No description provided for @homeStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get homeStatistics;

  /// No description provided for @homeSearchRecords.
  ///
  /// In en, this message translates to:
  /// **'Search records'**
  String get homeSearchRecords;

  /// No description provided for @homeSearchReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get homeSearchReset;

  /// No description provided for @homeSearchShowResults.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get homeSearchShowResults;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Field number, taxon, site, or any value'**
  String get homeSearchHint;

  /// No description provided for @homeSearchRecordType.
  ///
  /// In en, this message translates to:
  /// **'Record type'**
  String get homeSearchRecordType;

  /// No description provided for @homeSearchIn.
  ///
  /// In en, this message translates to:
  /// **'Search in'**
  String get homeSearchIn;

  /// No description provided for @homeSearchAllFields.
  ///
  /// In en, this message translates to:
  /// **'All fields'**
  String get homeSearchAllFields;

  /// No description provided for @homeSearchProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get homeSearchProjects;

  /// No description provided for @homeSearchAllProjects.
  ///
  /// In en, this message translates to:
  /// **'All projects'**
  String get homeSearchAllProjects;

  /// No description provided for @homeSearchTaxa.
  ///
  /// In en, this message translates to:
  /// **'Taxa'**
  String get homeSearchTaxa;

  /// No description provided for @homeSearchQuickFilters.
  ///
  /// In en, this message translates to:
  /// **'Quick filters'**
  String get homeSearchQuickFilters;

  /// No description provided for @homeProjectAccessed.
  ///
  /// In en, this message translates to:
  /// **'Accessed: {date}'**
  String homeProjectAccessed(String date);

  /// No description provided for @homeProjectCreated.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String homeProjectCreated(String date);

  /// No description provided for @homeProjectActions.
  ///
  /// In en, this message translates to:
  /// **'Project actions'**
  String get homeProjectActions;

  /// No description provided for @homeProjectEditInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit info'**
  String get homeProjectEditInfo;

  /// No description provided for @homeProjectShowQr.
  ///
  /// In en, this message translates to:
  /// **'Show QR'**
  String get homeProjectShowQr;

  /// No description provided for @homeProjectExportInfo.
  ///
  /// In en, this message translates to:
  /// **'Export info'**
  String get homeProjectExportInfo;

  /// No description provided for @homeProjectDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get homeProjectDetails;

  /// No description provided for @homeProjectInformation.
  ///
  /// In en, this message translates to:
  /// **'Project information'**
  String get homeProjectInformation;

  /// No description provided for @homeProjectQrCode.
  ///
  /// In en, this message translates to:
  /// **'Project QR code'**
  String get homeProjectQrCode;

  /// No description provided for @homeProjectQrDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan this code when creating a new project to transfer project information.'**
  String get homeProjectQrDescription;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About {appName}'**
  String aboutTitle(String appName);

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Rethinking biodiversity inventories in the digital age'**
  String get aboutTagline;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get aboutAppVersion;

  /// No description provided for @aboutVersionBuild.
  ///
  /// In en, this message translates to:
  /// **'v{version} (build {build})'**
  String aboutVersionBuild(String version, String build);

  /// No description provided for @aboutCodename.
  ///
  /// In en, this message translates to:
  /// **'Codename'**
  String get aboutCodename;

  /// No description provided for @aboutCodenameNote.
  ///
  /// In en, this message translates to:
  /// **'From NAHPU’s first real-world field test on Mt. Gede, West Java, Indonesia.'**
  String get aboutCodenameNote;

  /// No description provided for @aboutDatabaseSchema.
  ///
  /// In en, this message translates to:
  /// **'Database schema'**
  String get aboutDatabaseSchema;

  /// No description provided for @aboutSchemaSupported.
  ///
  /// In en, this message translates to:
  /// **'App supports v{version}'**
  String aboutSchemaSupported(String version);

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'{appName} is a cross-platform digital catalog app designed for natural history specimen data collection and management, providing insights at the point of collection.'**
  String aboutDescription(String appName);

  /// No description provided for @drawerCreateProject.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get drawerCreateProject;

  /// No description provided for @drawerImportProject.
  ///
  /// In en, this message translates to:
  /// **'Import project'**
  String get drawerImportProject;

  /// No description provided for @drawerDatabaseStatistics.
  ///
  /// In en, this message translates to:
  /// **'Database statistics'**
  String get drawerDatabaseStatistics;

  /// No description provided for @drawerBackupDatabase.
  ///
  /// In en, this message translates to:
  /// **'Backup database'**
  String get drawerBackupDatabase;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @drawerExportUserConfigs.
  ///
  /// In en, this message translates to:
  /// **'Export user configs'**
  String get drawerExportUserConfigs;

  /// No description provided for @drawerImportUserConfigs.
  ///
  /// In en, this message translates to:
  /// **'Import user configs'**
  String get drawerImportUserConfigs;

  /// No description provided for @drawerAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get drawerAbout;

  /// No description provided for @drawerWebsite.
  ///
  /// In en, this message translates to:
  /// **'NAHPU website'**
  String get drawerWebsite;

  /// Name of the bundled how-to guide. Match the documentation website.
  ///
  /// In en, this message translates to:
  /// **'Cookbook'**
  String get drawerCookbook;

  /// Heading of the app-wide settings section.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get settingsApplications;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Set light or dark appearance'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get settingsTools;

  /// No description provided for @settingsToolsLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose the tools shown on the project dashboard'**
  String get settingsToolsLabel;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageSystemLabel.
  ///
  /// In en, this message translates to:
  /// **'Follows the device language ({language})'**
  String settingsLanguageSystemLabel(String language);

  /// No description provided for @settingsLanguageBetaNote.
  ///
  /// In en, this message translates to:
  /// **'Language support is in beta. Some screens are still in English, and translations may be machine drafts.'**
  String get settingsLanguageBetaNote;

  /// No description provided for @settingsRegionalFormat.
  ///
  /// In en, this message translates to:
  /// **'Regional format'**
  String get settingsRegionalFormat;

  /// No description provided for @settingsRegionalFormatMatchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Match language'**
  String get settingsRegionalFormatMatchLanguage;

  /// No description provided for @settingsRegionalFormatNote.
  ///
  /// In en, this message translates to:
  /// **'Changes only how dates and numbers are shown. Saved records and exports keep standard formats.'**
  String get settingsRegionalFormatNote;

  /// No description provided for @settingsRegionalFormatPreview.
  ///
  /// In en, this message translates to:
  /// **'Example: {date} · {number}'**
  String settingsRegionalFormatPreview(String date, String number);

  /// No description provided for @docsContents.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get docsContents;

  /// No description provided for @docsCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse {title}'**
  String docsCollapse(String title);

  /// No description provided for @docsExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand {title}'**
  String docsExpand(String title);

  /// No description provided for @docsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this documentation.'**
  String get docsLoadError;

  /// No description provided for @docsOnlineLinks.
  ///
  /// In en, this message translates to:
  /// **'These links open the NAHPU documentation and need an internet connection.'**
  String get docsOnlineLinks;

  /// No description provided for @docsAsideNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get docsAsideNote;

  /// No description provided for @docsAsideCaution.
  ///
  /// In en, this message translates to:
  /// **'Caution'**
  String get docsAsideCaution;

  /// No description provided for @docsAsideTip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get docsAsideTip;

  /// No description provided for @docsAiTranslation.
  ///
  /// In en, this message translates to:
  /// **'AI-assisted translation.'**
  String get docsAiTranslation;

  /// No description provided for @docsAiCheck.
  ///
  /// In en, this message translates to:
  /// **'Check for accuracy'**
  String get docsAiCheck;

  /// No description provided for @docsReviewedBy.
  ///
  /// In en, this message translates to:
  /// **'Human-checked and revised by {reviewers}.'**
  String docsReviewedBy(String reviewers);

  /// No description provided for @docsReviewerPair.
  ///
  /// In en, this message translates to:
  /// **'{first} and {second}'**
  String docsReviewerPair(String first, String second);

  /// Joins three or more reviewers. leading is already comma-separated.
  ///
  /// In en, this message translates to:
  /// **'{leading}, and {last}'**
  String docsReviewerList(String leading, String last);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'id', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'id':
      return AppLocalizationsId();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
