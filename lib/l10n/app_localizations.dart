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

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get commonPreview;

  /// No description provided for @commonSortRecords.
  ///
  /// In en, this message translates to:
  /// **'Sort records'**
  String get commonSortRecords;

  /// No description provided for @commonDeleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get commonDeleteRecord;

  /// No description provided for @commonDeleteAllRecords.
  ///
  /// In en, this message translates to:
  /// **'Delete all records'**
  String get commonDeleteAllRecords;

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

  /// No description provided for @narrativeTitle.
  ///
  /// In en, this message translates to:
  /// **'Narrative'**
  String get narrativeTitle;

  /// Title of a single narrative opened outside the narrative viewer.
  ///
  /// In en, this message translates to:
  /// **'Narrative Record'**
  String get narrativeRecordTitle;

  /// No description provided for @narrativeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search narrative'**
  String get narrativeSearchHint;

  /// No description provided for @narrativeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No narrative found'**
  String get narrativeEmpty;

  /// No description provided for @narrativeCreate.
  ///
  /// In en, this message translates to:
  /// **'Create narrative'**
  String get narrativeCreate;

  /// No description provided for @narrativeActions.
  ///
  /// In en, this message translates to:
  /// **'Narrative actions'**
  String get narrativeActions;

  /// No description provided for @narrativeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete narrative?'**
  String get narrativeDeleteTitle;

  /// No description provided for @narrativeDeletePrompt.
  ///
  /// In en, this message translates to:
  /// **'You will delete this narrative'**
  String get narrativeDeletePrompt;

  /// No description provided for @narrativeDeleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all narrative?'**
  String get narrativeDeleteAllTitle;

  /// No description provided for @narrativeDeleteAllPrompt.
  ///
  /// In en, this message translates to:
  /// **'You will delete all narrative in this project'**
  String get narrativeDeleteAllPrompt;

  /// No description provided for @narrativeDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting narrative: {error}'**
  String narrativeDeleteError(String error);

  /// No description provided for @narrativeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Narrative deleted'**
  String get narrativeDeleted;

  /// Heading above the narrative text field.
  ///
  /// In en, this message translates to:
  /// **'Narrative'**
  String get narrativeTextLabel;

  /// No description provided for @narrativeTextHint.
  ///
  /// In en, this message translates to:
  /// **'Enter narrative (Markdown supported)'**
  String get narrativeTextHint;

  /// Shown in the preview when the narrative is empty. Refers to the commonEdit button.
  ///
  /// In en, this message translates to:
  /// **'No narrative. Use the Edit button above to start writing.'**
  String get narrativeTextEmpty;

  /// No description provided for @narrativeDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get narrativeDate;

  /// No description provided for @narrativeDateHint.
  ///
  /// In en, this message translates to:
  /// **'Enter date'**
  String get narrativeDateHint;

  /// No description provided for @narrativeTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get narrativeTime;

  /// No description provided for @narrativeTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter time'**
  String get narrativeTimeHint;

  /// No description provided for @narrativeWriter.
  ///
  /// In en, this message translates to:
  /// **'Writer'**
  String get narrativeWriter;

  /// No description provided for @narrativeWriterHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a person name'**
  String get narrativeWriterHint;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get commonExport;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// Heading of the catalog settings section.
  ///
  /// In en, this message translates to:
  /// **'Catalogs'**
  String get settingsNavCatalogs;

  /// Settings tile that opens the catalog format choice.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get settingsNavCatalogFormat;

  /// No description provided for @settingsNavCatalogFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Set catalog format'**
  String get settingsNavCatalogFormatLabel;

  /// No description provided for @settingsNavCatalogFormatLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load catalog format: {error}'**
  String settingsNavCatalogFormatLoadError(String error);

  /// No description provided for @settingsNavSites.
  ///
  /// In en, this message translates to:
  /// **'Sites'**
  String get settingsNavSites;

  /// No description provided for @settingsNavSitesLabel.
  ///
  /// In en, this message translates to:
  /// **'Manage site types, habitat types, and coordinate datums'**
  String get settingsNavSitesLabel;

  /// Collecting events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get settingsNavEvents;

  /// No description provided for @settingsNavEventsLabel.
  ///
  /// In en, this message translates to:
  /// **'Manage activities, collection methods, personnel roles, and environmental fields'**
  String get settingsNavEventsLabel;

  /// No description provided for @settingsNavSpecimens.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get settingsNavSpecimens;

  /// No description provided for @settingsNavSpecimensLabel.
  ///
  /// In en, this message translates to:
  /// **'Manage field, tissue ID settings, and controlled vocabularies for specimen forms'**
  String get settingsNavSpecimensLabel;

  /// No description provided for @settingsNavCustomFields.
  ///
  /// In en, this message translates to:
  /// **'Custom fields'**
  String get settingsNavCustomFields;

  /// No description provided for @settingsNavCustomFieldsLabel.
  ///
  /// In en, this message translates to:
  /// **'Manage fields for sites, environmental data, specimens, parts, and parasites'**
  String get settingsNavCustomFieldsLabel;

  /// No description provided for @settingsNavDatabase.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get settingsNavDatabase;

  /// No description provided for @settingsNavTaxa.
  ///
  /// In en, this message translates to:
  /// **'Taxa'**
  String get settingsNavTaxa;

  /// No description provided for @settingsNavTaxaLabel.
  ///
  /// In en, this message translates to:
  /// **'Manage taxonomy records'**
  String get settingsNavTaxaLabel;

  /// No description provided for @settingsNavPersonnel.
  ///
  /// In en, this message translates to:
  /// **'Personnel'**
  String get settingsNavPersonnel;

  /// No description provided for @settingsNavPersonnelLabel.
  ///
  /// In en, this message translates to:
  /// **'Manage personnel records'**
  String get settingsNavPersonnelLabel;

  /// No description provided for @settingsNavBackupDatabaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Full database backup of all records and settings'**
  String get settingsNavBackupDatabaseLabel;

  /// No description provided for @settingsNavReplaceDatabase.
  ///
  /// In en, this message translates to:
  /// **'Replace database'**
  String get settingsNavReplaceDatabase;

  /// No description provided for @settingsNavReplaceDatabaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Replace current database with another database file'**
  String get settingsNavReplaceDatabaseLabel;

  /// No description provided for @settingsNavExports.
  ///
  /// In en, this message translates to:
  /// **'Exports'**
  String get settingsNavExports;

  /// No description provided for @settingsNavTabularData.
  ///
  /// In en, this message translates to:
  /// **'Tabular Data'**
  String get settingsNavTabularData;

  /// No description provided for @settingsNavTabularDataLabel.
  ///
  /// In en, this message translates to:
  /// **'Manage presets for exporting in tabular formats'**
  String get settingsNavTabularDataLabel;

  /// No description provided for @settingsNavDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get settingsNavDocuments;

  /// No description provided for @settingsNavDocumentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Manage presets for exporting documents'**
  String get settingsNavDocumentsLabel;

  /// No description provided for @settingsNavTemplateEditor.
  ///
  /// In en, this message translates to:
  /// **'Template Editor'**
  String get settingsNavTemplateEditor;

  /// No description provided for @settingsNavTemplateEditorLabel.
  ///
  /// In en, this message translates to:
  /// **'Create and edit document templates'**
  String get settingsNavTemplateEditorLabel;

  /// Tooltip of the button that sets the letter case of new vocabulary entries.
  ///
  /// In en, this message translates to:
  /// **'Set case format'**
  String get settingsCommonSetCaseFormat;

  /// No description provided for @settingsFileTreeEmpty.
  ///
  /// In en, this message translates to:
  /// **'The application folder is empty.'**
  String get settingsFileTreeEmpty;

  /// Number of files in a folder not linked to any record.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} unlinked}}'**
  String settingsFileTreeUnlinkedCount(int count);

  /// No description provided for @settingsFileTreeRemoveEmptyFolder.
  ///
  /// In en, this message translates to:
  /// **'Remove this empty folder'**
  String get settingsFileTreeRemoveEmptyFolder;

  /// No description provided for @settingsFileTreeSelectFolder.
  ///
  /// In en, this message translates to:
  /// **'Select this folder'**
  String get settingsFileTreeSelectFolder;

  /// No description provided for @settingsFileTreeSelectRemovable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Select the 1 removable file here} other{Select the {count} removable files here}}'**
  String settingsFileTreeSelectRemovable(int count);

  /// No description provided for @settingsFileTreeSaveCopy.
  ///
  /// In en, this message translates to:
  /// **'Save a copy'**
  String get settingsFileTreeSaveCopy;

  /// No description provided for @settingsFileTreeRemoveFile.
  ///
  /// In en, this message translates to:
  /// **'Remove this file'**
  String get settingsFileTreeRemoveFile;

  /// Tooltip on a file that cannot be removed when no specific reason is known.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get settingsFileTreeKept;

  /// Group label for selected files that sit directly in the app folder.
  ///
  /// In en, this message translates to:
  /// **'Application folder'**
  String get settingsSelectionApplicationFolder;

  /// No description provided for @settingsSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected file} other{{count} selected files}}'**
  String settingsSelectionTitle(int count);

  /// No description provided for @settingsSelectionArchiveFormat.
  ///
  /// In en, this message translates to:
  /// **'Archive format'**
  String get settingsSelectionArchiveFormat;

  /// No description provided for @settingsSelectionNoFolder.
  ///
  /// In en, this message translates to:
  /// **'Exporting a selection needs a folder to write to, which this device cannot offer. You can still delete the selected files after reviewing them.'**
  String get settingsSelectionNoFolder;

  /// No description provided for @settingsSelectionExportNote.
  ///
  /// In en, this message translates to:
  /// **'Exporting writes these files to one compressed archive, then offers to remove the originals. Deleting removes them straight away and cannot be undone.'**
  String get settingsSelectionExportNote;

  /// No description provided for @settingsSelectionDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Deleting removes the selected files straight away and cannot be undone.'**
  String get settingsSelectionDeleteNote;

  /// No description provided for @settingsSelectionDeletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get settingsSelectionDeletePermanently;

  /// No description provided for @settingsMapLayers.
  ///
  /// In en, this message translates to:
  /// **'Map layers'**
  String get settingsMapLayers;

  /// No description provided for @settingsMapPmtilesType.
  ///
  /// In en, this message translates to:
  /// **'PMTiles layer type'**
  String get settingsMapPmtilesType;

  /// No description provided for @settingsMapImportError.
  ///
  /// In en, this message translates to:
  /// **'Unable to import map layer: {error}'**
  String settingsMapImportError(String error);

  /// No description provided for @settingsMapBaseLayer.
  ///
  /// In en, this message translates to:
  /// **'Base layer'**
  String get settingsMapBaseLayer;

  /// No description provided for @settingsMapCustomLayers.
  ///
  /// In en, this message translates to:
  /// **'Custom layers'**
  String get settingsMapCustomLayers;

  /// No description provided for @settingsMapLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load custom map layers: {error}'**
  String settingsMapLoadError(String error);

  /// No description provided for @settingsMapNoCustomLayers.
  ///
  /// In en, this message translates to:
  /// **'No custom layers have been imported.'**
  String get settingsMapNoCustomLayers;

  /// No description provided for @settingsMapImportCustomLayer.
  ///
  /// In en, this message translates to:
  /// **'Import custom layer'**
  String get settingsMapImportCustomLayer;

  /// No description provided for @settingsMapKindUnavailableOnLinux.
  ///
  /// In en, this message translates to:
  /// **'{kind} · unavailable on Linux'**
  String settingsMapKindUnavailableOnLinux(String kind);

  /// No description provided for @settingsMapConfigureLayer.
  ///
  /// In en, this message translates to:
  /// **'Configure layer'**
  String get settingsMapConfigureLayer;

  /// No description provided for @settingsMapShowLayer.
  ///
  /// In en, this message translates to:
  /// **'Show layer'**
  String get settingsMapShowLayer;

  /// No description provided for @settingsMapLayerUnavailableOnLinux.
  ///
  /// In en, this message translates to:
  /// **'This layer is unavailable on Linux'**
  String get settingsMapLayerUnavailableOnLinux;

  /// No description provided for @settingsMapLayerTypeUnavailableOnLinux.
  ///
  /// In en, this message translates to:
  /// **'This layer type is unavailable on Linux.'**
  String get settingsMapLayerTypeUnavailableOnLinux;

  /// No description provided for @settingsMapOpacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get settingsMapOpacity;

  /// No description provided for @settingsMapUseTerrain.
  ///
  /// In en, this message translates to:
  /// **'Use for 3D terrain'**
  String get settingsMapUseTerrain;

  /// No description provided for @settingsMapHillshadeNote.
  ///
  /// In en, this message translates to:
  /// **'Hillshade remains visible when terrain is off.'**
  String get settingsMapHillshadeNote;

  /// No description provided for @settingsMapLayerOrder.
  ///
  /// In en, this message translates to:
  /// **'Layer order'**
  String get settingsMapLayerOrder;

  /// Moves the layer one step earlier in the drawing order.
  ///
  /// In en, this message translates to:
  /// **'Move earlier'**
  String get settingsMapMoveEarlier;

  /// Moves the layer one step later in the drawing order.
  ///
  /// In en, this message translates to:
  /// **'Move later'**
  String get settingsMapMoveLater;

  /// No description provided for @settingsMapDeleteLayer.
  ///
  /// In en, this message translates to:
  /// **'Delete layer'**
  String get settingsMapDeleteLayer;

  /// No description provided for @settingsMapDeleteLayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete map layer?'**
  String get settingsMapDeleteLayerTitle;

  /// No description provided for @settingsMapDeleteLayerBody.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} and its stored map data?'**
  String settingsMapDeleteLayerBody(String name);

  /// No description provided for @settingsMapSupportedFormatsLinux.
  ///
  /// In en, this message translates to:
  /// **'Supports GeoJSON, zipped WGS84 Shapefiles, and raster PMTiles on Linux.'**
  String get settingsMapSupportedFormatsLinux;

  /// No description provided for @settingsMapSupportedFormats.
  ///
  /// In en, this message translates to:
  /// **'Supports GeoJSON, zipped WGS84 Shapefiles, and PMTiles.'**
  String get settingsMapSupportedFormats;

  /// No description provided for @settingsDataUsage.
  ///
  /// In en, this message translates to:
  /// **'Data usage'**
  String get settingsDataUsage;

  /// No description provided for @settingsDataUsageLabel.
  ///
  /// In en, this message translates to:
  /// **'Browse and clean up the application folder'**
  String get settingsDataUsageLabel;

  /// No description provided for @settingsDataUsageRescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get settingsDataUsageRescan;

  /// No description provided for @settingsDataUsageFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get settingsDataUsageFiles;

  /// No description provided for @settingsDataUsageFilesLabel.
  ///
  /// In en, this message translates to:
  /// **'Include images and other files'**
  String get settingsDataUsageFilesLabel;

  /// No description provided for @settingsDataUsageMediaFiles.
  ///
  /// In en, this message translates to:
  /// **'Media files'**
  String get settingsDataUsageMediaFiles;

  /// No description provided for @settingsDataUsageMediaFilesLabel.
  ///
  /// In en, this message translates to:
  /// **'Images, audio, video'**
  String get settingsDataUsageMediaFilesLabel;

  /// No description provided for @settingsDataUsageTotal.
  ///
  /// In en, this message translates to:
  /// **'Total usage'**
  String get settingsDataUsageTotal;

  /// Disk space that can be freed.
  ///
  /// In en, this message translates to:
  /// **'Reclaimable'**
  String get settingsDataUsageReclaimable;

  /// No description provided for @settingsDataUsageReclaimableLabel.
  ///
  /// In en, this message translates to:
  /// **'Unlinked files that can be removed'**
  String get settingsDataUsageReclaimableLabel;

  /// No description provided for @settingsDataUsageNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get settingsDataUsageNone;

  /// No description provided for @settingsDataUsageRemoveOriginalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove the originals?'**
  String get settingsDataUsageRemoveOriginalsTitle;

  /// No description provided for @settingsDataUsageArchiveWritten.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file was written to {archive} ({size}).} other{{count} files were written to {archive} ({size}).}}'**
  String settingsDataUsageArchiveWritten(
    int count,
    String archive,
    String size,
  );

  /// No description provided for @settingsDataUsageRemoveOriginalsBody.
  ///
  /// In en, this message translates to:
  /// **'Removing them from NAHPU frees the space. The archive keeps your copy, and this cannot be undone.'**
  String get settingsDataUsageRemoveOriginalsBody;

  /// No description provided for @settingsDataUsageExportedTo.
  ///
  /// In en, this message translates to:
  /// **'Exported to {path}'**
  String settingsDataUsageExportedTo(String path);

  /// No description provided for @settingsDataUsageExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String settingsDataUsageExportFailed(String error);

  /// No description provided for @settingsDataUsageSaveCopyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save {name}: {error}'**
  String settingsDataUsageSaveCopyFailed(String name, String error);

  /// No description provided for @settingsDataUsageRemoveFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this file?'**
  String get settingsDataUsageRemoveFileTitle;

  /// No description provided for @settingsDataUsageRemoveFileBody.
  ///
  /// In en, this message translates to:
  /// **'{name} ({size}) is not linked to any record. This cannot be undone.'**
  String settingsDataUsageRemoveFileBody(String name, String size);

  /// No description provided for @settingsDataUsageRemoveFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this empty folder?'**
  String get settingsDataUsageRemoveFolderTitle;

  /// No description provided for @settingsDataUsageRemoveFolderBody.
  ///
  /// In en, this message translates to:
  /// **'{name} holds no files. Removing it does not affect any record.'**
  String settingsDataUsageRemoveFolderBody(String name);

  /// Snackbar after an empty folder is removed.
  ///
  /// In en, this message translates to:
  /// **'Removed {name}.'**
  String settingsDataUsageRemovedFolder(String name);

  /// No description provided for @settingsDataUsageRemoveFolderFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not remove {name}.'**
  String settingsDataUsageRemoveFolderFailed(String name);

  /// No description provided for @settingsDataUsageDeleteSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 selected file?} other{Delete {count} selected files?}}'**
  String settingsDataUsageDeleteSelectionTitle(int count);

  /// No description provided for @settingsDataUsageDeleteSelectionBody.
  ///
  /// In en, this message translates to:
  /// **'These files are not linked to any record. This cannot be undone.'**
  String get settingsDataUsageDeleteSelectionBody;

  /// No description provided for @settingsDataUsageCollapseAll.
  ///
  /// In en, this message translates to:
  /// **'Collapse all'**
  String get settingsDataUsageCollapseAll;

  /// No description provided for @settingsDataUsageExpandAll.
  ///
  /// In en, this message translates to:
  /// **'Expand all'**
  String get settingsDataUsageExpandAll;

  /// No description provided for @settingsDataUsageSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get settingsDataUsageSelectAll;

  /// Turns on file selection mode.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get settingsDataUsageSelect;

  /// Clears the file selection.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get settingsDataUsageClear;

  /// Button that reviews the selected files; count is the number selected.
  ///
  /// In en, this message translates to:
  /// **'Review {count}'**
  String settingsDataUsageReview(int count);

  /// No description provided for @settingsDataUsageScanError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the application folder'**
  String get settingsDataUsageScanError;

  /// No description provided for @settingsDataUsagePruneTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove unlinked files'**
  String get settingsDataUsagePruneTitle;

  /// No description provided for @settingsDataUsagePruneDescription.
  ///
  /// In en, this message translates to:
  /// **'Files no longer used by any record, such as leftovers from deleted media or cancelled imports. Linked files, databases and backups, custom fonts, map layers, and files outside NAHPU-managed folders are not affected.'**
  String get settingsDataUsagePruneDescription;

  /// No description provided for @settingsDataUsageNothingToReclaim.
  ///
  /// In en, this message translates to:
  /// **'Nothing to reclaim.'**
  String get settingsDataUsageNothingToReclaim;

  /// No description provided for @settingsDataUsagePruneButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Remove 1 unlinked file ({size})} other{Remove {count} unlinked files ({size})}}'**
  String settingsDataUsagePruneButton(int count, String size);

  /// No description provided for @settingsDataUsagePruneConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Remove 1 unlinked file?} other{Remove {count} unlinked files?}}'**
  String settingsDataUsagePruneConfirmTitle(int count);

  /// No description provided for @settingsDataUsagePruneConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This frees {size}. Files still linked to your records, your database and its backups, and your custom fonts and map layers are not affected.\n\nThis cannot be undone.'**
  String settingsDataUsagePruneConfirmBody(String size);

  /// No description provided for @settingsDataUsageRemovedSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Removed 1 file ({size}).} other{Removed {count} files ({size}).}}'**
  String settingsDataUsageRemovedSummary(int count, String size);

  /// No description provided for @settingsDataUsageKeptChanged.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file was kept because it changed during the scan.} other{{count} files were kept because they changed during the scan.}}'**
  String settingsDataUsageKeptChanged(int count);

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @recordsCatalogFormat.
  ///
  /// In en, this message translates to:
  /// **'Catalog format'**
  String get recordsCatalogFormat;

  /// No description provided for @recordsCatalogMeasurementRecords.
  ///
  /// In en, this message translates to:
  /// **'Measurement records'**
  String get recordsCatalogMeasurementRecords;

  /// No description provided for @recordsCatalogAlwaysShowBatFields.
  ///
  /// In en, this message translates to:
  /// **'Always show bat fields'**
  String get recordsCatalogAlwaysShowBatFields;

  /// No description provided for @recordsCatalogBatFieldsNote.
  ///
  /// In en, this message translates to:
  /// **'If enabled, fields specific to bats are always shown in the mammal measurement fields. You can also choose to toggle the visibility of bat-specific fields for each specimen record in the specimen record screen.'**
  String get recordsCatalogBatFieldsNote;

  /// Title of the picker that sets the letter case applied to vocabulary values.
  ///
  /// In en, this message translates to:
  /// **'Case format'**
  String get recordsVocabularyCaseFormat;

  /// No description provided for @recordsVocabularyCaseFormatLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load case format: {error}'**
  String recordsVocabularyCaseFormatLoadError(String error);

  /// Letter-case option that leaves values as typed.
  ///
  /// In en, this message translates to:
  /// **'Any Case'**
  String get recordsVocabularyCaseAny;

  /// Letter-case option: only the first letter is capitalized.
  ///
  /// In en, this message translates to:
  /// **'Sentence Case'**
  String get recordsVocabularyCaseSentence;

  /// Letter-case option: every word is capitalized.
  ///
  /// In en, this message translates to:
  /// **'Title Case'**
  String get recordsVocabularyCaseTitle;

  /// No description provided for @recordsVocabularyCaseUpper.
  ///
  /// In en, this message translates to:
  /// **'Upper Case'**
  String get recordsVocabularyCaseUpper;

  /// No description provided for @recordsVocabularyCaseLower.
  ///
  /// In en, this message translates to:
  /// **'Lower Case'**
  String get recordsVocabularyCaseLower;

  /// No description provided for @recordsSiteSettings.
  ///
  /// In en, this message translates to:
  /// **'Site settings'**
  String get recordsSiteSettings;

  /// No description provided for @recordsSiteTypes.
  ///
  /// In en, this message translates to:
  /// **'Site Types'**
  String get recordsSiteTypes;

  /// No description provided for @recordsSiteHabitatTypes.
  ///
  /// In en, this message translates to:
  /// **'Habitat Types'**
  String get recordsSiteHabitatTypes;

  /// Geodetic datums, such as WGS84.
  ///
  /// In en, this message translates to:
  /// **'Datums'**
  String get recordsSiteDatums;

  /// No description provided for @recordsSiteGeographyFields.
  ///
  /// In en, this message translates to:
  /// **'Geography fields'**
  String get recordsSiteGeographyFields;

  /// No description provided for @recordsSiteGeographyFieldsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load geography fields: {error}'**
  String recordsSiteGeographyFieldsLoadError(String error);

  /// No description provided for @recordsSiteMaps.
  ///
  /// In en, this message translates to:
  /// **'Maps'**
  String get recordsSiteMaps;

  /// No description provided for @recordsSiteMapLayers.
  ///
  /// In en, this message translates to:
  /// **'Map layers'**
  String get recordsSiteMapLayers;

  /// No description provided for @recordsSiteMapLayersLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose a base layer or import and manage custom layers'**
  String get recordsSiteMapLayersLabel;

  /// No description provided for @recordsCollEventSettings.
  ///
  /// In en, this message translates to:
  /// **'Collection event settings'**
  String get recordsCollEventSettings;

  /// No description provided for @recordsCollEventPrimaryActivities.
  ///
  /// In en, this message translates to:
  /// **'Primary Activities'**
  String get recordsCollEventPrimaryActivities;

  /// No description provided for @recordsCollEventCollectionMethods.
  ///
  /// In en, this message translates to:
  /// **'Collection Methods'**
  String get recordsCollEventCollectionMethods;

  /// No description provided for @recordsCollEventPersonnelRoles.
  ///
  /// In en, this message translates to:
  /// **'Personnel Roles'**
  String get recordsCollEventPersonnelRoles;

  /// No description provided for @recordsCollEventEnvironmentalDataFields.
  ///
  /// In en, this message translates to:
  /// **'Environmental data fields'**
  String get recordsCollEventEnvironmentalDataFields;

  /// No description provided for @recordsCollEventEnvironmentalDataFieldsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load environmental data fields: {error}'**
  String recordsCollEventEnvironmentalDataFieldsLoadError(String error);

  /// No description provided for @recordsCollEventTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get recordsCollEventTemperature;

  /// No description provided for @recordsCollEventHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get recordsCollEventHumidity;

  /// No description provided for @recordsCollEventEnvironmentalMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Environmental measurements'**
  String get recordsCollEventEnvironmentalMeasurements;

  /// No description provided for @recordsCollEventAquaticData.
  ///
  /// In en, this message translates to:
  /// **'Aquatic Data'**
  String get recordsCollEventAquaticData;

  /// Group of sunrise, sunset, and moon phase fields.
  ///
  /// In en, this message translates to:
  /// **'Astronomy'**
  String get recordsCollEventAstronomy;

  /// No description provided for @recordsSpecimenSettings.
  ///
  /// In en, this message translates to:
  /// **'Specimen settings'**
  String get recordsSpecimenSettings;

  /// No description provided for @recordsSpecimenCaptureRecords.
  ///
  /// In en, this message translates to:
  /// **'Capture records'**
  String get recordsSpecimenCaptureRecords;

  /// No description provided for @recordsSpecimenAlwaysShowCollector.
  ///
  /// In en, this message translates to:
  /// **'Always show collector field'**
  String get recordsSpecimenAlwaysShowCollector;

  /// No description provided for @recordsSpecimenIdentificationMethods.
  ///
  /// In en, this message translates to:
  /// **'Identification Methods'**
  String get recordsSpecimenIdentificationMethods;

  /// No description provided for @recordsSpecimenLifeStages.
  ///
  /// In en, this message translates to:
  /// **'Life Stages'**
  String get recordsSpecimenLifeStages;

  /// No description provided for @recordsSpecimenTypes.
  ///
  /// In en, this message translates to:
  /// **'Specimen Types'**
  String get recordsSpecimenTypes;

  /// Vocabulary of specimen or parasite preparation treatments.
  ///
  /// In en, this message translates to:
  /// **'Treatments'**
  String get recordsSpecimenTreatments;

  /// Vocabulary of specimen conditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get recordsSpecimenConditions;

  /// No description provided for @recordsSpecimenSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get recordsSpecimenSex;

  /// The placeholders are the stored sex terms, shown as they appear on the chips.
  ///
  /// In en, this message translates to:
  /// **'{male}, {female}, and {unknown} are always available. Add optional terms with +. A question mark records examiner uncertainty.'**
  String recordsSpecimenSexNote(String male, String female, String unknown);

  /// No description provided for @recordsSpecimenSexLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load sex options: {error}'**
  String recordsSpecimenSexLoadError(String error);

  /// Heading above the sex terms currently in use.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get recordsSpecimenSexSelected;

  /// No description provided for @recordsSpecimenSexAdditional.
  ///
  /// In en, this message translates to:
  /// **'Additional options'**
  String get recordsSpecimenSexAdditional;

  /// No description provided for @recordsSpecimenSexRemoveBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot remove sex'**
  String get recordsSpecimenSexRemoveBlockedTitle;

  /// No description provided for @recordsSpecimenSexRemoveBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'{sex} is used by one or more specimen records. Change those records before removing this option.'**
  String recordsSpecimenSexRemoveBlockedBody(String sex);

  /// No description provided for @recordsSpecimenParasites.
  ///
  /// In en, this message translates to:
  /// **'Parasites'**
  String get recordsSpecimenParasites;

  /// Section for parasite ID numbering.
  ///
  /// In en, this message translates to:
  /// **'Identification'**
  String get recordsSpecimenParasiteIdentification;

  /// No description provided for @recordsSpecimenParasiteCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get recordsSpecimenParasiteCategories;

  /// No description provided for @recordsSpecimenParasiteDetectionMethods.
  ///
  /// In en, this message translates to:
  /// **'Detection Methods'**
  String get recordsSpecimenParasiteDetectionMethods;

  /// No description provided for @recordsSpecimenParasitePreparationMethods.
  ///
  /// In en, this message translates to:
  /// **'Preparation Methods'**
  String get recordsSpecimenParasitePreparationMethods;

  /// No description provided for @recordsSpecimenParasiteAnatomicalLocations.
  ///
  /// In en, this message translates to:
  /// **'Anatomical Locations'**
  String get recordsSpecimenParasiteAnatomicalLocations;

  /// No description provided for @recordsSpecimenParasiteStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get recordsSpecimenParasiteStorage;

  /// No description provided for @recordsSpecimenParasiteIdPrefix.
  ///
  /// In en, this message translates to:
  /// **'Parasite ID prefix'**
  String get recordsSpecimenParasiteIdPrefix;

  /// No description provided for @recordsSpecimenParasiteIdPrefixHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a prefix, e.g. {example}'**
  String recordsSpecimenParasiteIdPrefixHint(String example);

  /// No description provided for @recordsSpecimenParasiteIdNumber.
  ///
  /// In en, this message translates to:
  /// **'Parasite ID number'**
  String get recordsSpecimenParasiteIdNumber;

  /// No description provided for @recordsSpecimenNextNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the next number'**
  String get recordsSpecimenNextNumberHint;

  /// The field number assigned to a specimen at collection.
  ///
  /// In en, this message translates to:
  /// **'Field ID'**
  String get recordsSpecimenFieldId;

  /// No description provided for @recordsSpecimenFieldIdModeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load field ID mode: {error}'**
  String recordsSpecimenFieldIdModeLoadError(String error);

  /// Field ID mode based on a person's initials and running number.
  ///
  /// In en, this message translates to:
  /// **'Personnel ID'**
  String get recordsSpecimenPersonnelId;

  /// No description provided for @recordsSpecimenPersonnelIdDescription.
  ///
  /// In en, this message translates to:
  /// **'The ID is a person\'s initials and running number. You will set it when creating personnel with a cataloger role.'**
  String get recordsSpecimenPersonnelIdDescription;

  /// Field ID mode based on one running number per project.
  ///
  /// In en, this message translates to:
  /// **'Project ID'**
  String get recordsSpecimenProjectId;

  /// No description provided for @recordsSpecimenProjectIdDescription.
  ///
  /// In en, this message translates to:
  /// **'The project keeps one running number with a shared prefix and suffix.'**
  String get recordsSpecimenProjectIdDescription;

  /// No description provided for @recordsSpecimenPersonnelFieldIdNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Personnel field IDs require a cataloger'**
  String get recordsSpecimenPersonnelFieldIdNoteTitle;

  /// No description provided for @recordsSpecimenPersonnelFieldIdNoteBody.
  ///
  /// In en, this message translates to:
  /// **'Add a person with the Cataloger role in the project and assign a current field number to that role.'**
  String get recordsSpecimenPersonnelFieldIdNoteBody;

  /// No description provided for @recordsSpecimenAddPersonnel.
  ///
  /// In en, this message translates to:
  /// **'Add personnel'**
  String get recordsSpecimenAddPersonnel;

  /// No description provided for @recordsSpecimenPrefix.
  ///
  /// In en, this message translates to:
  /// **'Prefix'**
  String get recordsSpecimenPrefix;

  /// No description provided for @recordsSpecimenSuffix.
  ///
  /// In en, this message translates to:
  /// **'Suffix'**
  String get recordsSpecimenSuffix;

  /// No description provided for @recordsSpecimenExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. {example}'**
  String recordsSpecimenExampleHint(String example);

  /// No description provided for @recordsSpecimenCurrentCatalogNumber.
  ///
  /// In en, this message translates to:
  /// **'Current catalog number'**
  String get recordsSpecimenCurrentCatalogNumber;

  /// No description provided for @recordsSpecimenFieldIdPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview: {id}'**
  String recordsSpecimenFieldIdPreview(String id);

  /// No description provided for @recordsSpecimenAutoIncrement.
  ///
  /// In en, this message translates to:
  /// **'Auto-increment catalog number'**
  String get recordsSpecimenAutoIncrement;

  /// No description provided for @recordsSpecimenSaveFieldIdSettings.
  ///
  /// In en, this message translates to:
  /// **'Save field ID settings'**
  String get recordsSpecimenSaveFieldIdSettings;

  /// No description provided for @recordsSpecimenFieldIdSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Field ID settings saved.'**
  String get recordsSpecimenFieldIdSettingsSaved;

  /// No description provided for @recordsSpecimenNoProjectFieldIdTitle.
  ///
  /// In en, this message translates to:
  /// **'Open a project to set project field IDs'**
  String get recordsSpecimenNoProjectFieldIdTitle;

  /// No description provided for @recordsSpecimenNoProjectFieldIdBody.
  ///
  /// In en, this message translates to:
  /// **'The prefix, current number, and suffix are saved per project.'**
  String get recordsSpecimenNoProjectFieldIdBody;

  /// No description provided for @recordsSpecimenFieldIdChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change project field ID format?'**
  String get recordsSpecimenFieldIdChangeTitle;

  /// No description provided for @recordsSpecimenFieldIdChangeBody.
  ///
  /// In en, this message translates to:
  /// **'Changing the project field ID prefix or suffix changes existing project IDs. These identifiers may already have been used in exports or written on specimen labels. Double-check the new values before changing them.'**
  String get recordsSpecimenFieldIdChangeBody;

  /// No description provided for @recordsSpecimenIUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get recordsSpecimenIUnderstand;

  /// No description provided for @recordsSpecimenTissueId.
  ///
  /// In en, this message translates to:
  /// **'Tissue ID'**
  String get recordsSpecimenTissueId;

  /// No description provided for @recordsSpecimenNextTissueId.
  ///
  /// In en, this message translates to:
  /// **'Next tissue ID'**
  String get recordsSpecimenNextTissueId;

  /// Auto-numbered tag for an individual within a fish lot.
  ///
  /// In en, this message translates to:
  /// **'Individual tag ID'**
  String get recordsSpecimenIndividualTagId;

  /// No description provided for @recordsSpecimenNextTag.
  ///
  /// In en, this message translates to:
  /// **'Next tag'**
  String get recordsSpecimenNextTag;

  /// No description provided for @recordsCustomFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom fields'**
  String get recordsCustomFieldTitle;

  /// Tab listing the custom fields.
  ///
  /// In en, this message translates to:
  /// **'Fields'**
  String get recordsCustomFieldFieldsTab;

  /// No description provided for @recordsCustomFieldEditField.
  ///
  /// In en, this message translates to:
  /// **'Edit field'**
  String get recordsCustomFieldEditField;

  /// No description provided for @recordsCustomFieldLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load fields: {error}'**
  String recordsCustomFieldLoadError(String error);

  /// No description provided for @recordsCustomFieldSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved “{name}”.'**
  String recordsCustomFieldSaved(String name);

  /// No description provided for @recordsCustomFieldImportQrError.
  ///
  /// In en, this message translates to:
  /// **'Unable to import QR code: {error}'**
  String recordsCustomFieldImportQrError(String error);

  /// No description provided for @recordsCustomFieldImportError.
  ///
  /// In en, this message translates to:
  /// **'Unable to import custom fields: {error}'**
  String recordsCustomFieldImportError(String error);

  /// No description provided for @recordsCustomFieldImportEmpty.
  ///
  /// In en, this message translates to:
  /// **'This user-config payload has no custom field templates.'**
  String get recordsCustomFieldImportEmpty;

  /// No description provided for @recordsCustomFieldImported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 custom field definition.} other{Imported {count} custom field definitions.}}'**
  String recordsCustomFieldImported(int count);

  /// No description provided for @recordsCustomFieldExportError.
  ///
  /// In en, this message translates to:
  /// **'Unable to export custom fields: {error}'**
  String recordsCustomFieldExportError(String error);

  /// No description provided for @recordsCustomFieldExportedTo.
  ///
  /// In en, this message translates to:
  /// **'Custom fields exported to {path}'**
  String recordsCustomFieldExportedTo(String path);

  /// No description provided for @recordsCustomFieldExported.
  ///
  /// In en, this message translates to:
  /// **'Custom fields exported'**
  String get recordsCustomFieldExported;

  /// No description provided for @recordsCustomFieldQrTooLargeTitle.
  ///
  /// In en, this message translates to:
  /// **'QR code is too large'**
  String get recordsCustomFieldQrTooLargeTitle;

  /// No description provided for @recordsCustomFieldQrTooLargeBody.
  ///
  /// In en, this message translates to:
  /// **'The selected custom fields contain too much data for one QR code. Export them as a file instead.'**
  String get recordsCustomFieldQrTooLargeBody;

  /// No description provided for @recordsCustomFieldExportFile.
  ///
  /// In en, this message translates to:
  /// **'Export file'**
  String get recordsCustomFieldExportFile;

  /// Legacy values are custom field values stored by an older version of NAHPU.
  ///
  /// In en, this message translates to:
  /// **'Discard legacy values?'**
  String get recordsCustomFieldDiscardLegacyTitle;

  /// No description provided for @recordsCustomFieldDiscardLegacyBody.
  ///
  /// In en, this message translates to:
  /// **'Legacy values for “{name}” cannot be recovered after they are discarded.'**
  String recordsCustomFieldDiscardLegacyBody(String name);

  /// No description provided for @recordsCustomFieldDiscardValues.
  ///
  /// In en, this message translates to:
  /// **'Discard values'**
  String get recordsCustomFieldDiscardValues;

  /// No description provided for @recordsCustomFieldDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete custom field?'**
  String get recordsCustomFieldDeleteTitle;

  /// No description provided for @recordsCustomFieldDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}” permanently? This action cannot be undone.'**
  String recordsCustomFieldDeleteBody(String name);

  /// No description provided for @recordsCustomFieldSelectFields.
  ///
  /// In en, this message translates to:
  /// **'Select fields'**
  String get recordsCustomFieldSelectFields;

  /// No description provided for @recordsCustomFieldShowArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived fields'**
  String get recordsCustomFieldShowArchived;

  /// location is the screen section where the fields appear.
  ///
  /// In en, this message translates to:
  /// **'All custom fields in {location} are archived.'**
  String recordsCustomFieldAllArchived(String location);

  /// location is the screen section where the fields appear.
  ///
  /// In en, this message translates to:
  /// **'No custom fields in {location} yet.'**
  String recordsCustomFieldEmpty(String location);

  /// No description provided for @recordsCustomFieldAdd.
  ///
  /// In en, this message translates to:
  /// **'Add custom field'**
  String get recordsCustomFieldAdd;

  /// Status badge of a custom field.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get recordsCustomFieldArchived;

  /// Status of a custom field.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get recordsCustomFieldActive;

  /// No description provided for @recordsCustomFieldDefinitionActions.
  ///
  /// In en, this message translates to:
  /// **'Definition actions'**
  String get recordsCustomFieldDefinitionActions;

  /// No description provided for @recordsCustomFieldMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get recordsCustomFieldMoveUp;

  /// No description provided for @recordsCustomFieldMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get recordsCustomFieldMoveDown;

  /// Unarchives a custom field.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get recordsCustomFieldRestore;

  /// Verb: archives a custom field.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get recordsCustomFieldArchive;

  /// No description provided for @recordsCustomFieldDiscardLegacy.
  ///
  /// In en, this message translates to:
  /// **'Discard legacy values'**
  String get recordsCustomFieldDiscardLegacy;

  /// Disabled delete action shown while the field still stores values.
  ///
  /// In en, this message translates to:
  /// **'Delete (values in use)'**
  String get recordsCustomFieldDeleteInUse;

  /// No description provided for @recordsCustomFieldSelectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a custom field to edit, or add a new one.'**
  String get recordsCustomFieldSelectPrompt;

  /// No description provided for @recordsCustomFieldNew.
  ///
  /// In en, this message translates to:
  /// **'New custom field'**
  String get recordsCustomFieldNew;

  /// No description provided for @recordsCustomFieldEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String recordsCustomFieldEditName(String name);

  /// location is the screen section where the field appears.
  ///
  /// In en, this message translates to:
  /// **'Shown in {location}'**
  String recordsCustomFieldShownIn(String location);

  /// No description provided for @recordsCustomFieldDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get recordsCustomFieldDetails;

  /// No description provided for @recordsCustomFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get recordsCustomFieldStatus;

  /// No description provided for @recordsCustomFieldScope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get recordsCustomFieldScope;

  /// No description provided for @recordsCustomFieldStoredValues.
  ///
  /// In en, this message translates to:
  /// **'Stored values'**
  String get recordsCustomFieldStoredValues;

  /// No description provided for @recordsCustomFieldLegacyValues.
  ///
  /// In en, this message translates to:
  /// **'Legacy values'**
  String get recordsCustomFieldLegacyValues;

  /// No description provided for @recordsCustomFieldDeletion.
  ///
  /// In en, this message translates to:
  /// **'Deletion'**
  String get recordsCustomFieldDeletion;

  /// No description provided for @recordsCustomFieldDeletionAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get recordsCustomFieldDeletionAvailable;

  /// No description provided for @recordsCustomFieldDeletionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable until all stored values are cleared'**
  String get recordsCustomFieldDeletionUnavailable;

  /// No description provided for @recordsCustomFieldUsageLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load usage: {error}'**
  String recordsCustomFieldUsageLoadError(String error);

  /// No description provided for @recordsCustomFieldProjectUuid.
  ///
  /// In en, this message translates to:
  /// **'Project UUID'**
  String get recordsCustomFieldProjectUuid;

  /// No description provided for @recordsCustomFieldDefinitionUuid.
  ///
  /// In en, this message translates to:
  /// **'Definition UUID'**
  String get recordsCustomFieldDefinitionUuid;

  /// No description provided for @recordsCustomFieldSourceTemplateUuid.
  ///
  /// In en, this message translates to:
  /// **'Source template UUID'**
  String get recordsCustomFieldSourceTemplateUuid;

  /// No description provided for @recordsCustomFieldNotFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Not imported from a template'**
  String get recordsCustomFieldNotFromTemplate;

  /// Custom field data type.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get recordsCustomFieldTypeText;

  /// Custom field data type.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get recordsCustomFieldTypeNumber;

  /// Custom field data type.
  ///
  /// In en, this message translates to:
  /// **'Yes / No'**
  String get recordsCustomFieldTypeBoolean;

  /// Custom field data type.
  ///
  /// In en, this message translates to:
  /// **'Dropdown'**
  String get recordsCustomFieldTypeDropdown;

  /// Custom field available in every project.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get recordsCustomFieldScopeGlobal;

  /// No description provided for @recordsCustomFieldScopeProject.
  ///
  /// In en, this message translates to:
  /// **'Current project'**
  String get recordsCustomFieldScopeProject;

  /// No description provided for @recordsCustomFieldAllCatalogs.
  ///
  /// In en, this message translates to:
  /// **'All catalog formats'**
  String get recordsCustomFieldAllCatalogs;

  /// No description provided for @recordsCustomFieldCatalogOnly.
  ///
  /// In en, this message translates to:
  /// **'{catalog} only'**
  String recordsCustomFieldCatalogOnly(String catalog);

  /// No description provided for @commonSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get commonSelectAll;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get commonImport;

  /// No description provided for @databaseSelectFileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to select file!'**
  String get databaseSelectFileFailed;

  /// No description provided for @databaseReplaceConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace database?'**
  String get databaseReplaceConfirmTitle;

  /// Confirms replacing the current database.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get databaseReplace;

  /// No description provided for @databaseRestoreCancelled.
  ///
  /// In en, this message translates to:
  /// **'Restore cancelled. The database was not replaced.'**
  String get databaseRestoreCancelled;

  /// No description provided for @databaseRestoreCannotStop.
  ///
  /// In en, this message translates to:
  /// **'The restore is replacing your data and cannot be stopped now.'**
  String get databaseRestoreCannotStop;

  /// No description provided for @databaseCancelRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel the restore?'**
  String get databaseCancelRestoreTitle;

  /// No description provided for @databaseCancelRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'The archive is still being read. Leaving now cancels the restore and your current data is left untouched.'**
  String get databaseCancelRestoreBody;

  /// No description provided for @databaseKeepRestoring.
  ///
  /// In en, this message translates to:
  /// **'Keep restoring'**
  String get databaseKeepRestoring;

  /// No description provided for @databaseCancelRestore.
  ///
  /// In en, this message translates to:
  /// **'Cancel restore'**
  String get databaseCancelRestore;

  /// No description provided for @databaseReplaceFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to replace database: {error}'**
  String databaseReplaceFailed(String error);

  /// Title of the restore screen and its main action.
  ///
  /// In en, this message translates to:
  /// **'Replace database'**
  String get databaseReplaceDatabase;

  /// Heading above the file chosen to replace the current database.
  ///
  /// In en, this message translates to:
  /// **'Replace with'**
  String get databaseReplaceWith;

  /// No description provided for @databaseSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'A NAHPU backup archive or a SQLite database file.'**
  String get databaseSourceDescription;

  /// No description provided for @databaseNoFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get databaseNoFileSelected;

  /// Button that opens the file picker.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get databaseBrowse;

  /// Button (verb) that picks a different file.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get databaseChangeFile;

  /// No description provided for @databaseClearFile.
  ///
  /// In en, this message translates to:
  /// **'Clear file'**
  String get databaseClearFile;

  /// Supported file formats. Keep the format names as they are.
  ///
  /// In en, this message translates to:
  /// **'ZIP, TAR.GZ, or SQLITE3'**
  String get databaseSupportedFormats;

  /// No description provided for @databaseCannotRestore.
  ///
  /// In en, this message translates to:
  /// **'Can’t be restored'**
  String get databaseCannotRestore;

  /// No description provided for @databaseSqliteDatabase.
  ///
  /// In en, this message translates to:
  /// **'SQLite database'**
  String get databaseSqliteDatabase;

  /// No description provided for @databaseBackupArchive.
  ///
  /// In en, this message translates to:
  /// **'NAHPU backup archive'**
  String get databaseBackupArchive;

  /// No description provided for @databaseBackupArchiveRestores.
  ///
  /// In en, this message translates to:
  /// **'NAHPU backup archive · restores {database}'**
  String databaseBackupArchiveRestores(String database);

  /// No description provided for @databaseBeforeReplacing.
  ///
  /// In en, this message translates to:
  /// **'Before replacing'**
  String get databaseBeforeReplacing;

  /// No description provided for @databaseReplaceWarning.
  ///
  /// In en, this message translates to:
  /// **'This action will replace every record in NAHPU. Media or config files that match the archive will be overwritten. This cannot be undone.'**
  String get databaseReplaceWarning;

  /// No description provided for @databaseBackupFirst.
  ///
  /// In en, this message translates to:
  /// **'Back up current data first'**
  String get databaseBackupFirst;

  /// No description provided for @databaseBackupFirstSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saves a full archive, including media, to the NAHPU backup folder'**
  String get databaseBackupFirstSubtitle;

  /// No description provided for @databaseNoSafetyBackup.
  ///
  /// In en, this message translates to:
  /// **'No safety backup. Your current records and media are not saved before they are replaced.'**
  String get databaseNoSafetyBackup;

  /// No description provided for @databaseComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Current and replacement'**
  String get databaseComparisonTitle;

  /// No description provided for @databaseChooseFileToCompare.
  ///
  /// In en, this message translates to:
  /// **'Choose a file to compare.'**
  String get databaseChooseFileToCompare;

  /// No description provided for @databaseArchiveIncludesConfigs.
  ///
  /// In en, this message translates to:
  /// **'This archive also includes user configs, which the restore imports.'**
  String get databaseArchiveIncludesConfigs;

  /// No description provided for @databaseSchemaVersion.
  ///
  /// In en, this message translates to:
  /// **'Schema version'**
  String get databaseSchemaVersion;

  /// No description provided for @databaseAssociatedFiles.
  ///
  /// In en, this message translates to:
  /// **'Associated files'**
  String get databaseAssociatedFiles;

  /// No description provided for @databaseSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get databaseSize;

  /// No description provided for @databaseSchemaUpgraded.
  ///
  /// In en, this message translates to:
  /// **'The replacement schema v{version} is upgraded to v{current} after restore.'**
  String databaseSchemaUpgraded(int version, int current);

  /// No description provided for @databaseSchemaNewer.
  ///
  /// In en, this message translates to:
  /// **'The replacement schema v{version} is newer than this app.'**
  String databaseSchemaNewer(int version);

  /// No description provided for @databaseTableProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get databaseTableProjects;

  /// No description provided for @databaseTablePersonnel.
  ///
  /// In en, this message translates to:
  /// **'Personnel'**
  String get databaseTablePersonnel;

  /// No description provided for @databaseTableTaxa.
  ///
  /// In en, this message translates to:
  /// **'Taxa'**
  String get databaseTableTaxa;

  /// No description provided for @databaseTableSites.
  ///
  /// In en, this message translates to:
  /// **'Sites'**
  String get databaseTableSites;

  /// No description provided for @databaseTableCollectionEvents.
  ///
  /// In en, this message translates to:
  /// **'Collection events'**
  String get databaseTableCollectionEvents;

  /// No description provided for @databaseTableSpecimens.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get databaseTableSpecimens;

  /// No description provided for @databaseTableNarratives.
  ///
  /// In en, this message translates to:
  /// **'Narratives'**
  String get databaseTableNarratives;

  /// No description provided for @databaseTableMediaRecords.
  ///
  /// In en, this message translates to:
  /// **'Media records'**
  String get databaseTableMediaRecords;

  /// No description provided for @databaseIssueNotNahpu.
  ///
  /// In en, this message translates to:
  /// **'This file is not a NAHPU database. Choose a NAHPU backup archive or database file.'**
  String get databaseIssueNotNahpu;

  /// No description provided for @databaseIssueNewerSchema.
  ///
  /// In en, this message translates to:
  /// **'This database was made by a newer version of NAHPU. Update NAHPU, then restore it.'**
  String get databaseIssueNewerSchema;

  /// No description provided for @databaseIssueUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This database could not be read. The file may be damaged.'**
  String get databaseIssueUnreadable;

  /// Comparison table header for the database in use now.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get databaseColumnCurrent;

  /// Comparison table header for the file that will replace the database.
  ///
  /// In en, this message translates to:
  /// **'Replacement'**
  String get databaseColumnReplacement;

  /// Comparison table header (noun): the difference in record counts.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get databaseColumnChange;

  /// No description provided for @databaseRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring database'**
  String get databaseRestoring;

  /// No description provided for @databaseRestoreHint.
  ///
  /// In en, this message translates to:
  /// **'Restoring a backup with many photos can take several minutes. Keep NAHPU open until this finishes.'**
  String get databaseRestoreHint;

  /// No description provided for @databaseChooseDatabase.
  ///
  /// In en, this message translates to:
  /// **'Choose database'**
  String get databaseChooseDatabase;

  /// No description provided for @databaseChooseDatabaseBody.
  ///
  /// In en, this message translates to:
  /// **'This archive contains multiple database files at its root. Choose the database to restore.'**
  String get databaseChooseDatabaseBody;

  /// No description provided for @databaseConfirmWithBackup.
  ///
  /// In en, this message translates to:
  /// **'A full backup of your current data is saved first. Continue?'**
  String get databaseConfirmWithBackup;

  /// No description provided for @databaseConfirmWithoutBackup.
  ///
  /// In en, this message translates to:
  /// **'No backup will be made, so your current data cannot be recovered. Continue?'**
  String get databaseConfirmWithoutBackup;

  /// No description provided for @databaseReplaceSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success 🎉'**
  String get databaseReplaceSuccess;

  /// No description provided for @databaseReplaced.
  ///
  /// In en, this message translates to:
  /// **'Database has been replaced!'**
  String get databaseReplaced;

  /// No description provided for @databaseBackupFilePath.
  ///
  /// In en, this message translates to:
  /// **'Backup file path:'**
  String get databaseBackupFilePath;

  /// No description provided for @databaseBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get databaseBackToHome;

  /// Where the backup is found in the iOS Files app. Translate the folder names as the Files app shows them; keep the placeholders.
  ///
  /// In en, this message translates to:
  /// **'Files app/On my Devices/{appDir}/{backupDir}/{fileName}'**
  String databaseIosBackupPath(
    String appDir,
    String backupDir,
    String fileName,
  );

  /// No description provided for @transferCustomFieldsQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom fields QR code'**
  String get transferCustomFieldsQrTitle;

  /// No description provided for @transferCustomFieldsQrDescription.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Scan this code from another NAHPU device to import 1 custom field definition.} other{Scan this code from another NAHPU device to import {count} custom field definitions.}}'**
  String transferCustomFieldsQrDescription(int count);

  /// No description provided for @transferExportCustomFields.
  ///
  /// In en, this message translates to:
  /// **'Export custom fields'**
  String get transferExportCustomFields;

  /// No description provided for @transferShowQr.
  ///
  /// In en, this message translates to:
  /// **'Show QR'**
  String get transferShowQr;

  /// No description provided for @transferExportFile.
  ///
  /// In en, this message translates to:
  /// **'Export file'**
  String get transferExportFile;

  /// No description provided for @transferNoCustomFields.
  ///
  /// In en, this message translates to:
  /// **'No custom fields are available to export.'**
  String get transferNoCustomFields;

  /// No description provided for @transferSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} selected'**
  String transferSelectedCount(int selected, int total);

  /// Custom field scope: available in every project.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get transferScopeGlobal;

  /// Custom field scope: available only in the open project.
  ///
  /// In en, this message translates to:
  /// **'Current project'**
  String get transferScopeCurrentProject;

  /// No description provided for @transferArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get transferArchived;

  /// No description provided for @transferImportCustomFields.
  ///
  /// In en, this message translates to:
  /// **'Import custom fields'**
  String get transferImportCustomFields;

  /// No description provided for @transferReusableDefinitions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reusable definition} other{{count} reusable definitions}}'**
  String transferReusableDefinitions(int count);

  /// No description provided for @transferDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get transferDestination;

  /// No description provided for @transferCustomFieldImportNote.
  ///
  /// In en, this message translates to:
  /// **'Definitions are preflighted before import. Matching template IDs are updated safely; unrelated fields remain unchanged.'**
  String get transferCustomFieldImportNote;

  /// No description provided for @transferImportSelectedConfigs.
  ///
  /// In en, this message translates to:
  /// **'Import selected configs'**
  String get transferImportSelectedConfigs;

  /// Heading of the preview of what an import will add.
  ///
  /// In en, this message translates to:
  /// **'Will import'**
  String get transferWillImport;

  /// No description provided for @transferImportSelectedConfigsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import selected configs?'**
  String get transferImportSelectedConfigsConfirm;

  /// No description provided for @transferConfigsImported.
  ///
  /// In en, this message translates to:
  /// **'Selected user configs were imported.'**
  String get transferConfigsImported;

  /// No description provided for @transferImportConfirmationBody.
  ///
  /// In en, this message translates to:
  /// **'The selected groups will be replaced. Custom fields are matched by template ID and merged, so existing definitions are kept. Unselected groups remain unchanged.'**
  String get transferImportConfirmationBody;

  /// No description provided for @transferCustomFieldDestination.
  ///
  /// In en, this message translates to:
  /// **'Custom field destination'**
  String get transferCustomFieldDestination;

  /// No description provided for @transferSectionUserConfigs.
  ///
  /// In en, this message translates to:
  /// **'Controlled vocabularies and settings'**
  String get transferSectionUserConfigs;

  /// No description provided for @transferSectionRecordExportPresets.
  ///
  /// In en, this message translates to:
  /// **'Tabular export presets'**
  String get transferSectionRecordExportPresets;

  /// No description provided for @transferSectionTemplatePresets.
  ///
  /// In en, this message translates to:
  /// **'Document templates'**
  String get transferSectionTemplatePresets;

  /// No description provided for @transferSectionDocumentLayouts.
  ///
  /// In en, this message translates to:
  /// **'Document layout presets'**
  String get transferSectionDocumentLayouts;

  /// No description provided for @transferSectionTemplateTablePreview.
  ///
  /// In en, this message translates to:
  /// **'Template table preview columns'**
  String get transferSectionTemplateTablePreview;

  /// No description provided for @transferSectionCustomFields.
  ///
  /// In en, this message translates to:
  /// **'Custom fields'**
  String get transferSectionCustomFields;

  /// No description provided for @transferConfigSections.
  ///
  /// In en, this message translates to:
  /// **'Config sections'**
  String get transferConfigSections;

  /// No description provided for @transferChooseFileToPreview.
  ///
  /// In en, this message translates to:
  /// **'Choose a user-config file to preview its contents.'**
  String get transferChooseFileToPreview;

  /// No description provided for @transferSelectAtLeastOneSection.
  ///
  /// In en, this message translates to:
  /// **'Select at least one config section.'**
  String get transferSelectAtLeastOneSection;

  /// No description provided for @transferEntryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry} other{{count} entries}}'**
  String transferEntryCount(int count);

  /// No description provided for @transferNoSavedEntries.
  ///
  /// In en, this message translates to:
  /// **'No saved entries'**
  String get transferNoSavedEntries;

  /// No description provided for @transferOtherSettings.
  ///
  /// In en, this message translates to:
  /// **'Other settings'**
  String get transferOtherSettings;

  /// No description provided for @transferNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get transferNoItems;

  /// No description provided for @transferMappingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mapping} other{{count} mappings}}'**
  String transferMappingCount(int count);

  /// No description provided for @transferIncompatiblePreset.
  ///
  /// In en, this message translates to:
  /// **'Incompatible preset'**
  String get transferIncompatiblePreset;

  /// No description provided for @transferBlockCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 block} other{{count} blocks}}'**
  String transferBlockCount(int count);

  /// Button that moves to the final summary step of the setup wizard.
  ///
  /// In en, this message translates to:
  /// **'Review setup'**
  String get setupReviewSetup;

  /// No description provided for @setupSkipSetup.
  ///
  /// In en, this message translates to:
  /// **'Skip setup'**
  String get setupSkipSetup;

  /// Name of the first setup wizard step.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get setupStepWelcome;

  /// No description provided for @setupCatalogFormat.
  ///
  /// In en, this message translates to:
  /// **'Catalog format'**
  String get setupCatalogFormat;

  /// No description provided for @setupIdentifiers.
  ///
  /// In en, this message translates to:
  /// **'Identifiers'**
  String get setupIdentifiers;

  /// Name of the setup wizard step for site vocabularies.
  ///
  /// In en, this message translates to:
  /// **'Sites'**
  String get setupStepSites;

  /// Name of the setup wizard step for collecting event vocabularies.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get setupStepEvents;

  /// Name of the setup wizard step for specimen vocabularies.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get setupStepSpecimens;

  /// No description provided for @setupParasites.
  ///
  /// In en, this message translates to:
  /// **'Parasites'**
  String get setupParasites;

  /// No description provided for @setupExportPresets.
  ///
  /// In en, this message translates to:
  /// **'Export presets'**
  String get setupExportPresets;

  /// Name of the last setup wizard step.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get setupStepFinish;

  /// No description provided for @setupWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up NAHPU'**
  String get setupWelcomeTitle;

  /// No description provided for @setupWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'NAHPU records specimens using your own conventions. This sets the catalog number format, and the controlled vocabularies for sites, events, and specimens.'**
  String get setupWelcomeMessage;

  /// No description provided for @setupWelcomeCatalogFormat.
  ///
  /// In en, this message translates to:
  /// **'The taxon group you catalog.'**
  String get setupWelcomeCatalogFormat;

  /// No description provided for @setupWelcomeIdentifiers.
  ///
  /// In en, this message translates to:
  /// **'How field numbers and tissue numbers are formed.'**
  String get setupWelcomeIdentifiers;

  /// No description provided for @setupControlledVocabularies.
  ///
  /// In en, this message translates to:
  /// **'Controlled vocabularies'**
  String get setupControlledVocabularies;

  /// No description provided for @setupWelcomeVocabularies.
  ///
  /// In en, this message translates to:
  /// **'The vocabularies for sites, events, and specimens.'**
  String get setupWelcomeVocabularies;

  /// No description provided for @setupWelcomeExportPresets.
  ///
  /// In en, this message translates to:
  /// **'Bundled print layouts and tabular presets for exports.'**
  String get setupWelcomeExportPresets;

  /// No description provided for @setupWelcomeNotPermanent.
  ///
  /// In en, this message translates to:
  /// **'This takes a few minutes and nothing here is permanent. Every answer can be changed later in Settings, or by running this wizard again.'**
  String get setupWelcomeNotPermanent;

  /// No description provided for @setupImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Already have settings from your team?'**
  String get setupImportTitle;

  /// No description provided for @setupImportMessage.
  ///
  /// In en, this message translates to:
  /// **'A team only needs to set this up once. If your team has already configured NAHPU, import their user configs file and you can skip the rest of this wizard. You can export yours for everyone else at the end.'**
  String get setupImportMessage;

  /// No description provided for @setupCatalogFormatMessage.
  ///
  /// In en, this message translates to:
  /// **'The format decides which measurement fields appear on specimen records.'**
  String get setupCatalogFormatMessage;

  /// No description provided for @setupCatalogFormatNote.
  ///
  /// In en, this message translates to:
  /// **'You can change the catalog format at any time, and a single project can hold records in more than one format. Pick the format you will use most often.'**
  String get setupCatalogFormatNote;

  /// No description provided for @setupCatalogFormatLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load catalog format: {error}'**
  String setupCatalogFormatLoadError(String error);

  /// No description provided for @setupFieldIdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Specimen field IDs'**
  String get setupFieldIdsTitle;

  /// No description provided for @setupFieldIdsMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose your field ID strategy. You will complete ID setup when creating a new project.'**
  String get setupFieldIdsMessage;

  /// Settings > Catalogs is a menu path; match the settings screen names.
  ///
  /// In en, this message translates to:
  /// **'These identifier settings can be changed for a different project. You can set them under Settings > Catalogs.'**
  String get setupIdentifiersNote;

  /// No description provided for @setupTissueIdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tissue IDs'**
  String get setupTissueIdsTitle;

  /// No description provided for @setupTissueIdsMessage.
  ///
  /// In en, this message translates to:
  /// **'Some collections number tissues separately from the specimen. Set here if your collection uses it. NAHPU automatically uses the specimen field id as default if you don\'t set tissue id.'**
  String get setupTissueIdsMessage;

  /// No description provided for @setupUseSeparateTissueId.
  ///
  /// In en, this message translates to:
  /// **'Use a separate tissue ID'**
  String get setupUseSeparateTissueId;

  /// No description provided for @setupNextTissueId.
  ///
  /// In en, this message translates to:
  /// **'Next tissue ID'**
  String get setupNextTissueId;

  /// No description provided for @setupSitesTitle.
  ///
  /// In en, this message translates to:
  /// **'Site vocabularies'**
  String get setupSitesTitle;

  /// No description provided for @setupSitesMessage.
  ///
  /// In en, this message translates to:
  /// **'The controlled vocabularies for site and coordinate forms. Add your own terms, remove any you will not use, or leave the defaults alone. You can update these lists later in the Settings > Sites.'**
  String get setupSitesMessage;

  /// No description provided for @setupSiteTypes.
  ///
  /// In en, this message translates to:
  /// **'Site types'**
  String get setupSiteTypes;

  /// No description provided for @setupHabitatTypes.
  ///
  /// In en, this message translates to:
  /// **'Habitat types'**
  String get setupHabitatTypes;

  /// Geodetic datums, such as WGS84, as a controlled vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Datums'**
  String get setupDatums;

  /// No description provided for @setupEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collecting event vocabularies'**
  String get setupEventsTitle;

  /// No description provided for @setupEventsMessage.
  ///
  /// In en, this message translates to:
  /// **'The controlled vocabularies for collecting events. You can update these lists later in the Settings > Events.'**
  String get setupEventsMessage;

  /// No description provided for @setupPrimaryActivities.
  ///
  /// In en, this message translates to:
  /// **'Primary activities'**
  String get setupPrimaryActivities;

  /// No description provided for @setupCollectionMethods.
  ///
  /// In en, this message translates to:
  /// **'Collection methods'**
  String get setupCollectionMethods;

  /// No description provided for @setupPersonnelRoles.
  ///
  /// In en, this message translates to:
  /// **'Personnel roles'**
  String get setupPersonnelRoles;

  /// No description provided for @setupSpecimensTitle.
  ///
  /// In en, this message translates to:
  /// **'Specimen vocabularies'**
  String get setupSpecimensTitle;

  /// No description provided for @setupSpecimensMessage.
  ///
  /// In en, this message translates to:
  /// **'The controlled vocabularies for specimen records. You can update these lists later in the Settings > Specimens.'**
  String get setupSpecimensMessage;

  /// No description provided for @setupIdentificationMethods.
  ///
  /// In en, this message translates to:
  /// **'Identification methods'**
  String get setupIdentificationMethods;

  /// No description provided for @setupLifeStages.
  ///
  /// In en, this message translates to:
  /// **'Life stages'**
  String get setupLifeStages;

  /// No description provided for @setupSpecimenTypes.
  ///
  /// In en, this message translates to:
  /// **'Specimen types'**
  String get setupSpecimenTypes;

  /// Controlled vocabulary of specimen or parasite treatments (preservation or handling).
  ///
  /// In en, this message translates to:
  /// **'Treatments'**
  String get setupTreatments;

  /// Controlled vocabulary of specimen conditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get setupConditions;

  /// No description provided for @setupParasitesMessage.
  ///
  /// In en, this message translates to:
  /// **'NAHPU features a separate parasite form to associate parasite records with specimens. The toggle below allows you to setup controlled vocabularies for parasite records.'**
  String get setupParasitesMessage;

  /// No description provided for @setupCollectsParasites.
  ///
  /// In en, this message translates to:
  /// **'I will collect parasites'**
  String get setupCollectsParasites;

  /// Controlled vocabulary of parasite categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get setupParasiteCategories;

  /// No description provided for @setupDetectionMethods.
  ///
  /// In en, this message translates to:
  /// **'Detection methods'**
  String get setupDetectionMethods;

  /// No description provided for @setupPreparationMethods.
  ///
  /// In en, this message translates to:
  /// **'Preparation methods'**
  String get setupPreparationMethods;

  /// No description provided for @setupAnatomicalLocations.
  ///
  /// In en, this message translates to:
  /// **'Anatomical locations'**
  String get setupAnatomicalLocations;

  /// Controlled vocabulary of parasite storage values.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get setupStorage;

  /// No description provided for @setupFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'You are set up'**
  String get setupFinishTitle;

  /// No description provided for @setupFinishMessage.
  ///
  /// In en, this message translates to:
  /// **'NAHPU will use these conventions for new records.'**
  String get setupFinishMessage;

  /// Summary value when a setting has no value yet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get setupNotSet;

  /// No description provided for @setupFieldId.
  ///
  /// In en, this message translates to:
  /// **'Field ID'**
  String get setupFieldId;

  /// No description provided for @setupProjectId.
  ///
  /// In en, this message translates to:
  /// **'Project ID'**
  String get setupProjectId;

  /// No description provided for @setupPersonnelId.
  ///
  /// In en, this message translates to:
  /// **'Personnel ID'**
  String get setupPersonnelId;

  /// No description provided for @setupTissueId.
  ///
  /// In en, this message translates to:
  /// **'Tissue ID'**
  String get setupTissueId;

  /// No description provided for @setupTissueNumberedSeparately.
  ///
  /// In en, this message translates to:
  /// **'Numbered separately'**
  String get setupTissueNumberedSeparately;

  /// No description provided for @setupTissueFollowsSpecimen.
  ///
  /// In en, this message translates to:
  /// **'Follows the specimen'**
  String get setupTissueFollowsSpecimen;

  /// Summary value: the user collects parasites.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get setupParasitesCollected;

  /// Summary value: the user does not collect parasites.
  ///
  /// In en, this message translates to:
  /// **'Not collected'**
  String get setupParasitesNotCollected;

  /// No description provided for @setupShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share this setup with your team'**
  String get setupShareTitle;

  /// No description provided for @setupShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Your team only needs to do this once. Export these user configs and share with your team members/collaborators to ensure everyone works with the same vocabularies and settings.'**
  String get setupShareMessage;

  /// No description provided for @setupFinishNote.
  ///
  /// In en, this message translates to:
  /// **'Nothing here is locked in. Change any individual setting under Settings, or run Setup NAHPU again from the menu.'**
  String get setupFinishNote;

  /// No description provided for @setupExportPresetsMessage.
  ///
  /// In en, this message translates to:
  /// **'These are default presets for exporting records. Print layouts will be used for labels, tags, and field booklets. Tabular presets will be used for spreadsheets. You can manage or create your own presets in the Settings menu.'**
  String get setupExportPresetsMessage;

  /// Heading of the export presets that suit any catalog format.
  ///
  /// In en, this message translates to:
  /// **'Defaults'**
  String get setupPresetDefaults;

  /// No description provided for @setupPresetDefaultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Presets that suit any catalog format.'**
  String get setupPresetDefaultsMessage;

  /// Heading of export presets written for one catalog format.
  ///
  /// In en, this message translates to:
  /// **'For {catalogFormat}'**
  String setupPresetsForFormat(String catalogFormat);

  /// No description provided for @setupPresetsForFormatMessage.
  ///
  /// In en, this message translates to:
  /// **'Optional presets written for this catalog format.'**
  String get setupPresetsForFormatMessage;

  /// No description provided for @setupAddSelectedPresets.
  ///
  /// In en, this message translates to:
  /// **'Add selected presets'**
  String get setupAddSelectedPresets;

  /// No description provided for @setupBundledPresetsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load bundled presets: {error}'**
  String setupBundledPresetsLoadError(String error);

  /// No description provided for @setupAddPresetsError.
  ///
  /// In en, this message translates to:
  /// **'Failed to add presets: {error}'**
  String setupAddPresetsError(String error);

  /// Summary of installed export presets: document (print layout) presets and tabular (spreadsheet) presets.
  ///
  /// In en, this message translates to:
  /// **'{documentCount} document, {tabularCount} tabular'**
  String setupExportPresetCounts(int documentCount, int tabularCount);

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get commonSelect;

  /// No description provided for @presetsTemplateDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete template'**
  String get presetsTemplateDeleteTitle;

  /// No description provided for @presetsDeleteNamePrompt.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String presetsDeleteNamePrompt(String name);

  /// No description provided for @presetsTemplateUnusedDelete.
  ///
  /// In en, this message translates to:
  /// **'This template is unused and will be permanently removed.'**
  String get presetsTemplateUnusedDelete;

  /// No description provided for @presetsTemplateInUse.
  ///
  /// In en, this message translates to:
  /// **'This template is used by {blockCount, plural, =1{1 block} other{{blockCount} blocks}} in {layoutCount, plural, =1{1 print layout} other{{layoutCount} print layouts}}. Choose a replacement before deleting it.'**
  String presetsTemplateInUse(int blockCount, int layoutCount);

  /// One line in the list of print layouts that use a template. {blocks} is a comma-separated list of block numbers.
  ///
  /// In en, this message translates to:
  /// **'{layoutName}: {count, plural, =1{block} other{blocks}} {blocks}'**
  String presetsTemplateUsageBlocks(
    String layoutName,
    int count,
    String blocks,
  );

  /// No description provided for @presetsTemplateNoReplacement.
  ///
  /// In en, this message translates to:
  /// **'Create another template with the same record type, or change the affected layout blocks before deleting this one.'**
  String get presetsTemplateNoReplacement;

  /// No description provided for @presetsTemplateReplacement.
  ///
  /// In en, this message translates to:
  /// **'Replacement template'**
  String get presetsTemplateReplacement;

  /// No description provided for @presetsTemplateReplacementNote.
  ///
  /// In en, this message translates to:
  /// **'Page size, margins, grid, and padding will stay unchanged. Review the affected print layouts after replacement.'**
  String get presetsTemplateReplacementNote;

  /// No description provided for @presetsTemplateEmpty.
  ///
  /// In en, this message translates to:
  /// **'No templates yet. Templates define the content placed in print-layout blocks.'**
  String get presetsTemplateEmpty;

  /// No description provided for @presetsTemplateNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No templates match your search.'**
  String get presetsTemplateNoMatch;

  /// No description provided for @presetsTemplateNoneToExport.
  ///
  /// In en, this message translates to:
  /// **'No templates to export'**
  String get presetsTemplateNoneToExport;

  /// No description provided for @presetsTemplateExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export templates'**
  String get presetsTemplateExportTitle;

  /// No description provided for @presetsTemplateCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 template} other{{count} templates}}'**
  String presetsTemplateCount(int count);

  /// No description provided for @presetsTemplateInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid template file: {error}'**
  String presetsTemplateInvalidFile(String error);

  /// No description provided for @presetsTemplateImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to import templates: {error}'**
  String presetsTemplateImportFailed(String error);

  /// No description provided for @presetsTemplateImported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 template} other{Imported {count} templates}}'**
  String presetsTemplateImported(int count);

  /// No description provided for @presetsTemplateImportedPartial.
  ///
  /// In en, this message translates to:
  /// **'Imported {imported} of {offered} templates (limit {limit})'**
  String presetsTemplateImportedPartial(int imported, int offered, int limit);

  /// No description provided for @presetsTemplateLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load templates: {error}'**
  String presetsTemplateLoadError(String error);

  /// No description provided for @presetsTemplateDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{name}\"'**
  String presetsTemplateDeleted(String name);

  /// No description provided for @presetsTemplateDeletedUpdated.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{name}\" and updated {count, plural, =1{1 block} other{{count} blocks}}'**
  String presetsTemplateDeletedUpdated(String name, int count);

  /// No description provided for @presetsTemplateDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete template: {error}'**
  String presetsTemplateDeleteError(String error);

  /// No description provided for @presetsTemplateSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search templates'**
  String get presetsTemplateSearchHint;

  /// Shown for a template or font that nothing uses.
  ///
  /// In en, this message translates to:
  /// **'Unused'**
  String get presetsUnused;

  /// Number of print layouts that use a template.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 layout} other{{count} layouts}}'**
  String presetsTemplateLayoutCount(int count);

  /// No description provided for @presetsTemplateOptions.
  ///
  /// In en, this message translates to:
  /// **'Template options'**
  String get presetsTemplateOptions;

  /// Record type a template is for.
  ///
  /// In en, this message translates to:
  /// **'Specimen'**
  String get presetsRecordTypeSpecimen;

  /// Record type a template is for.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get presetsRecordTypeSite;

  /// Record type a template is for.
  ///
  /// In en, this message translates to:
  /// **'Collecting event'**
  String get presetsRecordTypeCollEvent;

  /// Record type a template is for.
  ///
  /// In en, this message translates to:
  /// **'Narrative'**
  String get presetsRecordTypeNarrative;

  /// Record type a template is for.
  ///
  /// In en, this message translates to:
  /// **'Specimen parts'**
  String get presetsRecordTypeSpecimenParts;

  /// Record type for a template that prints no records.
  ///
  /// In en, this message translates to:
  /// **'No records'**
  String get presetsRecordTypeNone;

  /// No description provided for @presetsFontReadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to read fonts: {error}'**
  String presetsFontReadError(String error);

  /// No description provided for @presetsFonts.
  ///
  /// In en, this message translates to:
  /// **'Fonts'**
  String get presetsFonts;

  /// No description provided for @presetsFontInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed {family}'**
  String presetsFontInstalled(String family);

  /// No description provided for @presetsFontInstallError.
  ///
  /// In en, this message translates to:
  /// **'Unable to install font: {error}'**
  String presetsFontInstallError(String error);

  /// No description provided for @presetsFontInUseTitle.
  ///
  /// In en, this message translates to:
  /// **'{family} is in use'**
  String presetsFontInUseTitle(String family);

  /// {templates} is a newline-separated list of template names.
  ///
  /// In en, this message translates to:
  /// **'Remove or change this font in {count, plural, =1{this template} other{these templates}} before deleting it:\n\n{templates}'**
  String presetsFontInUseBody(int count, String templates);

  /// No description provided for @presetsFontDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {family}?'**
  String presetsFontDeleteTitle(String family);

  /// No description provided for @presetsFontDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The font files are removed from this installation. Templates that use it elsewhere are not changed.'**
  String get presetsFontDeleteBody;

  /// No description provided for @presetsFontSearch.
  ///
  /// In en, this message translates to:
  /// **'Search fonts'**
  String get presetsFontSearch;

  /// No description provided for @presetsFontInstall.
  ///
  /// In en, this message translates to:
  /// **'Install font'**
  String get presetsFontInstall;

  /// Opens Google Fonts in the browser.
  ///
  /// In en, this message translates to:
  /// **'Find fonts'**
  String get presetsFontFind;

  /// No description provided for @presetsFontLicenseNote.
  ///
  /// In en, this message translates to:
  /// **'Download a font in your browser, then install the .ttf or .otf file here. You are responsible for the license of any font you install.'**
  String get presetsFontLicenseNote;

  /// No description provided for @presetsFontNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No fonts match your search'**
  String get presetsFontNoMatch;

  /// Section heading for fonts the user installed.
  ///
  /// In en, this message translates to:
  /// **'Installed by you'**
  String get presetsFontInstalledByYou;

  /// Section heading for fonts that ship with the app.
  ///
  /// In en, this message translates to:
  /// **'Bundled with NAHPU'**
  String get presetsFontBundledWithNahpu;

  /// No description provided for @presetsFontFileCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file} other{{count} files}}'**
  String presetsFontFileCount(int count);

  /// No description provided for @presetsFontUsedByCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Used by 1 template} other{Used by {count} templates}}'**
  String presetsFontUsedByCount(int count);

  /// No description provided for @presetsFontDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete font'**
  String get presetsFontDelete;

  /// No description provided for @presetsFontSelectToPreview.
  ///
  /// In en, this message translates to:
  /// **'Select a font to preview it'**
  String get presetsFontSelectToPreview;

  /// Chip for a font that ships with the app.
  ///
  /// In en, this message translates to:
  /// **'Bundled'**
  String get presetsFontBundled;

  /// Chip for a font the user installed.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get presetsFontInstalledLabel;

  /// {templates} is a comma-separated list of template names.
  ///
  /// In en, this message translates to:
  /// **'Used by {templates}'**
  String presetsFontUsedBy(String templates);

  /// Label for the font preview size slider.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get presetsFontSize;

  /// No description provided for @presetsMaxReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum of {max} presets reached.'**
  String presetsMaxReached(int max);

  /// No description provided for @presetsImported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 preset} other{Imported {count} presets}}'**
  String presetsImported(int count);

  /// No description provided for @presetsImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to import presets: {error}'**
  String presetsImportFailed(String error);

  /// No description provided for @presetsNoneToExport.
  ///
  /// In en, this message translates to:
  /// **'No presets to export'**
  String get presetsNoneToExport;

  /// No description provided for @presetsExportTabularTitle.
  ///
  /// In en, this message translates to:
  /// **'Export tabular presets'**
  String get presetsExportTabularTitle;

  /// No description provided for @presetsTabularCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tabular preset} other{{count} tabular presets}}'**
  String presetsTabularCount(int count);

  /// No description provided for @presetsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export presets: {error}'**
  String presetsExportFailed(String error);

  /// No description provided for @presetsTabularTitle.
  ///
  /// In en, this message translates to:
  /// **'Tabular Export Presets'**
  String get presetsTabularTitle;

  /// Tab listing the saved presets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presetsTabPresets;

  /// No description provided for @presetsTabEditPreset.
  ///
  /// In en, this message translates to:
  /// **'Edit Preset'**
  String get presetsTabEditPreset;

  /// No description provided for @presetsSelectPresets.
  ///
  /// In en, this message translates to:
  /// **'Select Presets'**
  String get presetsSelectPresets;

  /// Refers to the homeSetupNahpu action.
  ///
  /// In en, this message translates to:
  /// **'No tabular presets yet. Create or import one, or add the presets for your catalog format in Setup NAHPU.'**
  String get presetsTabularEmpty;

  /// Summary under a tabular export preset: number of field mappings and the record type.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mapping} other{{count} mappings}} · {recordType}'**
  String presetsMappingSummary(int count, String recordType);

  /// No description provided for @presetsExportThisPreset.
  ///
  /// In en, this message translates to:
  /// **'Export this preset'**
  String get presetsExportThisPreset;

  /// No description provided for @presetsErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String presetsErrorDetail(String error);

  /// No description provided for @presetsDeletePresetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Preset'**
  String get presetsDeletePresetTitle;

  /// No description provided for @presetsDeletePresetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the preset \"{name}\"?'**
  String presetsDeletePresetConfirm(String name);

  /// No description provided for @presetsSelectToEdit.
  ///
  /// In en, this message translates to:
  /// **'Select a preset to edit'**
  String get presetsSelectToEdit;

  /// No description provided for @presetsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Preset not found'**
  String get presetsNotFound;

  /// No description provided for @presetsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading preset'**
  String get presetsLoadError;

  /// No description provided for @presetsNewPreset.
  ///
  /// In en, this message translates to:
  /// **'New Preset'**
  String get presetsNewPreset;

  /// No description provided for @presetsName.
  ///
  /// In en, this message translates to:
  /// **'Preset Name'**
  String get presetsName;

  /// No description provided for @presetsNameExists.
  ///
  /// In en, this message translates to:
  /// **'A preset with this name already exists'**
  String get presetsNameExists;

  /// No description provided for @presetsNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get presetsNameEmpty;

  /// No description provided for @presetsNameInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Only alphanumeric, underscores, and dashes allowed'**
  String get presetsNameInvalidChars;

  /// No description provided for @presetsPreviewEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Preview Data'**
  String get presetsPreviewEmptyTitle;

  /// No description provided for @presetsPreviewEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No records matched the selected filters, or mappings are empty.'**
  String get presetsPreviewEmptyBody;

  /// No description provided for @presetsPreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate preview: {error}'**
  String presetsPreviewFailed(String error);

  /// No description provided for @presetsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save: {error}'**
  String presetsSaveError(String error);

  /// No description provided for @presetsNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Preset name cannot be empty.'**
  String get presetsNameRequired;

  /// No description provided for @presetsNameTaken.
  ///
  /// In en, this message translates to:
  /// **'A preset named \"{name}\" already exists.'**
  String presetsNameTaken(String name);

  /// No description provided for @presetsUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update: {error}'**
  String presetsUpdateError(String error);

  /// No description provided for @presetsDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate preset'**
  String get presetsDuplicateTitle;

  /// No description provided for @presetsDuplicateError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t duplicate: {error}'**
  String presetsDuplicateError(String error);

  /// No description provided for @presetsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String presetsEditTitle(String name);

  /// No description provided for @presetsEditFields.
  ///
  /// In en, this message translates to:
  /// **'Edit Fields'**
  String get presetsEditFields;

  /// No description provided for @presetsPreviewExportTable.
  ///
  /// In en, this message translates to:
  /// **'Preview Export Table'**
  String get presetsPreviewExportTable;

  /// No description provided for @presetsSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get presetsSaving;

  /// No description provided for @presetsSavedAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Saved automatically'**
  String get presetsSavedAutomatically;

  /// No description provided for @presetsRecordType.
  ///
  /// In en, this message translates to:
  /// **'Record type'**
  String get presetsRecordType;

  /// No description provided for @presetsSpecimenTaxonGroup.
  ///
  /// In en, this message translates to:
  /// **'Specimen taxon group'**
  String get presetsSpecimenTaxonGroup;

  /// Label for the column-header style of a tabular export.
  ///
  /// In en, this message translates to:
  /// **'Generated header format'**
  String get presetsHeaderFormat;

  /// Keep nahpu:table.field unchanged; it is the literal header pattern.
  ///
  /// In en, this message translates to:
  /// **'NAHPU namespace (nahpu:table.field)'**
  String get presetsHeaderNahpuNamespace;

  /// No description provided for @presetsPreviewSites.
  ///
  /// In en, this message translates to:
  /// **'Preview Sites ({count} selected)'**
  String presetsPreviewSites(int count);

  /// No description provided for @presetsPreviewEvents.
  ///
  /// In en, this message translates to:
  /// **'Preview Events ({count} selected)'**
  String presetsPreviewEvents(int count);

  /// No description provided for @presetsPreviewNarratives.
  ///
  /// In en, this message translates to:
  /// **'Preview Narratives ({count} selected)'**
  String presetsPreviewNarratives(int count);

  /// No description provided for @presetsPreviewSpecimenParts.
  ///
  /// In en, this message translates to:
  /// **'Preview Specimen Parts ({count} selected)'**
  String presetsPreviewSpecimenParts(int count);

  /// No description provided for @presetsPreviewSpecimens.
  ///
  /// In en, this message translates to:
  /// **'Preview Specimens ({count} selected)'**
  String presetsPreviewSpecimens(int count);

  /// Preview header when the layout prints no records.
  ///
  /// In en, this message translates to:
  /// **'Current Project (None)'**
  String get presetsPreviewCurrentProject;

  /// No description provided for @presetsDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Presets'**
  String get presetsDocumentTitle;

  /// No description provided for @presetsPrintLayouts.
  ///
  /// In en, this message translates to:
  /// **'Print layouts'**
  String get presetsPrintLayouts;

  /// No description provided for @presetsTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get presetsTemplates;

  /// No description provided for @presetsDocumentNew.
  ///
  /// In en, this message translates to:
  /// **'New document preset'**
  String get presetsDocumentNew;

  /// No description provided for @presetsRenamed.
  ///
  /// In en, this message translates to:
  /// **'Renamed to {name}'**
  String presetsRenamed(String name);

  /// No description provided for @presetsRenameFailed.
  ///
  /// In en, this message translates to:
  /// **'Rename failed: {error}'**
  String presetsRenameFailed(String error);

  /// No description provided for @presetsExportPrintLayoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Export print layouts'**
  String get presetsExportPrintLayoutsTitle;

  /// No description provided for @presetsPrintLayoutCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 print layout} other{{count} print layouts}}'**
  String presetsPrintLayoutCount(int count);

  /// No description provided for @presetsDocumentInvalidFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid document layout file: {error}'**
  String presetsDocumentInvalidFile(String error);

  /// No description provided for @presetsDocumentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No print layouts yet. Create or import one, or load the default layouts.'**
  String get presetsDocumentEmpty;

  /// No description provided for @presetsIncompatible.
  ///
  /// In en, this message translates to:
  /// **'Incompatible preset'**
  String get presetsIncompatible;

  /// No description provided for @presetsIncompatibleBody.
  ///
  /// In en, this message translates to:
  /// **'This preset is not compatible with the current version.'**
  String get presetsIncompatibleBody;

  /// No description provided for @presetsPreviewNoRecords.
  ///
  /// In en, this message translates to:
  /// **'No preview records for this type'**
  String get presetsPreviewNoRecords;

  /// No description provided for @presetsPreviewSelectSpecimenParts.
  ///
  /// In en, this message translates to:
  /// **'Select specimen parts for preview'**
  String get presetsPreviewSelectSpecimenParts;

  /// No description provided for @presetsPreviewSelectSpecimens.
  ///
  /// In en, this message translates to:
  /// **'Select specimens for preview'**
  String get presetsPreviewSelectSpecimens;

  /// No description provided for @presetsTableColumns.
  ///
  /// In en, this message translates to:
  /// **'Table columns'**
  String get presetsTableColumns;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// Title of the screen that maps NAHPU fields to export columns for an export preset.
  ///
  /// In en, this message translates to:
  /// **'Edit Preset Mappings'**
  String get exportFieldsTitle;

  /// No description provided for @exportFieldsAvailableFields.
  ///
  /// In en, this message translates to:
  /// **'Available Fields'**
  String get exportFieldsAvailableFields;

  /// No description provided for @exportFieldsSelectedMappings.
  ///
  /// In en, this message translates to:
  /// **'Selected Mappings'**
  String get exportFieldsSelectedMappings;

  /// No description provided for @exportFieldsNoPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'No Preview Data'**
  String get exportFieldsNoPreviewTitle;

  /// No description provided for @exportFieldsNoPreviewBody.
  ///
  /// In en, this message translates to:
  /// **'No records matched the selected filters, or mappings are empty.'**
  String get exportFieldsNoPreviewBody;

  /// No description provided for @exportFieldsPreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate preview: {error}'**
  String exportFieldsPreviewFailed(String error);

  /// No description provided for @exportFieldsInsertSourceField.
  ///
  /// In en, this message translates to:
  /// **'Insert Source Field'**
  String get exportFieldsInsertSourceField;

  /// Display option that lists source fields with their table name, as in site::siteID.
  ///
  /// In en, this message translates to:
  /// **'Table::Field'**
  String get exportFieldsDisplayTableField;

  /// Display option that lists source fields without their table name.
  ///
  /// In en, this message translates to:
  /// **'Field Only'**
  String get exportFieldsDisplayFieldOnly;

  /// Group heading for fields that do not belong to a database table.
  ///
  /// In en, this message translates to:
  /// **'Other fields'**
  String get exportFieldsOtherFields;

  /// No description provided for @exportFieldsSelectField.
  ///
  /// In en, this message translates to:
  /// **'Select field'**
  String get exportFieldsSelectField;

  /// No description provided for @exportFieldsChooseField.
  ///
  /// In en, this message translates to:
  /// **'Choose a field'**
  String get exportFieldsChooseField;

  /// No description provided for @exportFieldsCloseFieldPicker.
  ///
  /// In en, this message translates to:
  /// **'Close field picker'**
  String get exportFieldsCloseFieldPicker;

  /// No description provided for @exportFieldsSearchFields.
  ///
  /// In en, this message translates to:
  /// **'Search fields or tables'**
  String get exportFieldsSearchFields;

  /// No description provided for @exportFieldsNoMatchingFields.
  ///
  /// In en, this message translates to:
  /// **'No matching fields.'**
  String get exportFieldsNoMatchingFields;

  /// No description provided for @exportFieldsAddCustomField.
  ///
  /// In en, this message translates to:
  /// **'Add custom field'**
  String get exportFieldsAddCustomField;

  /// Adds a mapping that exports nested, repeated child records such as collectors or specimen parts.
  ///
  /// In en, this message translates to:
  /// **'Add nested'**
  String get exportFieldsAddNested;

  /// No description provided for @exportFieldsUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get exportFieldsUnnamed;

  /// No description provided for @exportFieldsCardNested.
  ///
  /// In en, this message translates to:
  /// **'Nested: {name}'**
  String exportFieldsCardNested(String name);

  /// No description provided for @exportFieldsCardList.
  ///
  /// In en, this message translates to:
  /// **'List: {name}'**
  String exportFieldsCardList(String name);

  /// No description provided for @exportFieldsCardField.
  ///
  /// In en, this message translates to:
  /// **'Field: {name}'**
  String exportFieldsCardField(String name);

  /// No description provided for @exportFieldsCardCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom: {name}'**
  String exportFieldsCardCustom(String name);

  /// No description provided for @exportFieldsCardIndexedColumns.
  ///
  /// In en, this message translates to:
  /// **'Indexed columns · {style}'**
  String exportFieldsCardIndexedColumns(String style);

  /// No description provided for @exportFieldsCardDarwinCoreSeparator.
  ///
  /// In en, this message translates to:
  /// **'One column · Darwin Core \" | \" separator'**
  String get exportFieldsCardDarwinCoreSeparator;

  /// No description provided for @exportFieldsCardSeparator.
  ///
  /// In en, this message translates to:
  /// **'One column · {separator} separator'**
  String exportFieldsCardSeparator(String separator);

  /// No description provided for @exportFieldsCardFormat.
  ///
  /// In en, this message translates to:
  /// **'Format: {format} · Options: {options}'**
  String exportFieldsCardFormat(String format, String options);

  /// No description provided for @exportFieldsCustomize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get exportFieldsCustomize;

  /// No description provided for @exportFieldsOneColumn.
  ///
  /// In en, this message translates to:
  /// **'One column'**
  String get exportFieldsOneColumn;

  /// No description provided for @exportFieldsIndexedColumns.
  ///
  /// In en, this message translates to:
  /// **'Indexed columns'**
  String get exportFieldsIndexedColumns;

  /// No description provided for @exportFieldsRepeatedRows.
  ///
  /// In en, this message translates to:
  /// **'Repeated rows'**
  String get exportFieldsRepeatedRows;

  /// Lowercase value format name shown after "Format:" in a mapping summary.
  ///
  /// In en, this message translates to:
  /// **'conditional brackets'**
  String get exportFieldsFormatConditionalBrackets;

  /// Lowercase value format name shown after "Format:" in a mapping summary.
  ///
  /// In en, this message translates to:
  /// **'conditional field'**
  String get exportFieldsFormatConditionalField;

  /// Lowercase value format name shown after "Format:" in a mapping summary.
  ///
  /// In en, this message translates to:
  /// **'conditional value'**
  String get exportFieldsFormatConditionalValue;

  /// No description provided for @exportFieldsMappingType.
  ///
  /// In en, this message translates to:
  /// **'Mapping type'**
  String get exportFieldsMappingType;

  /// No description provided for @exportFieldsKindSingle.
  ///
  /// In en, this message translates to:
  /// **'Single field'**
  String get exportFieldsKindSingle;

  /// No description provided for @exportFieldsKindCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom field'**
  String get exportFieldsKindCustom;

  /// No description provided for @exportFieldsKindList.
  ///
  /// In en, this message translates to:
  /// **'List field'**
  String get exportFieldsKindList;

  /// No description provided for @exportFieldsKindNested.
  ///
  /// In en, this message translates to:
  /// **'Nested records'**
  String get exportFieldsKindNested;

  /// No description provided for @exportFieldsSourceField.
  ///
  /// In en, this message translates to:
  /// **'Source field'**
  String get exportFieldsSourceField;

  /// No description provided for @exportFieldsSourceFieldHelper.
  ///
  /// In en, this message translates to:
  /// **'Choose the NAHPU field that supplies this column.'**
  String get exportFieldsSourceFieldHelper;

  /// No description provided for @exportFieldsColumnNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Column name (optional)'**
  String get exportFieldsColumnNameOptional;

  /// No description provided for @exportFieldsColumnNameOptionalHelper.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to use the source field name.'**
  String get exportFieldsColumnNameOptionalHelper;

  /// No description provided for @exportFieldsListOutput.
  ///
  /// In en, this message translates to:
  /// **'List output'**
  String get exportFieldsListOutput;

  /// No description provided for @exportFieldsExample.
  ///
  /// In en, this message translates to:
  /// **'Example: {example}'**
  String exportFieldsExample(String example);

  /// No description provided for @exportFieldsDarwinCoreListSeparator.
  ///
  /// In en, this message translates to:
  /// **'Darwin Core list values are separated with \" | \".'**
  String get exportFieldsDarwinCoreListSeparator;

  /// No description provided for @exportFieldsSeparator.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get exportFieldsSeparator;

  /// No description provided for @exportFieldsSeparatorPipe.
  ///
  /// In en, this message translates to:
  /// **'Pipe (A | B)'**
  String get exportFieldsSeparatorPipe;

  /// No description provided for @exportFieldsSeparatorComma.
  ///
  /// In en, this message translates to:
  /// **'Comma (A, B)'**
  String get exportFieldsSeparatorComma;

  /// No description provided for @exportFieldsSeparatorSemicolon.
  ///
  /// In en, this message translates to:
  /// **'Semicolon (A; B)'**
  String get exportFieldsSeparatorSemicolon;

  /// No description provided for @exportFieldsSeparatorSlash.
  ///
  /// In en, this message translates to:
  /// **'Slash (A / B)'**
  String get exportFieldsSeparatorSlash;

  /// No description provided for @exportFieldsSeparatorNewLine.
  ///
  /// In en, this message translates to:
  /// **'New line'**
  String get exportFieldsSeparatorNewLine;

  /// No description provided for @exportFieldsSeparatorBulleted.
  ///
  /// In en, this message translates to:
  /// **'Bulleted'**
  String get exportFieldsSeparatorBulleted;

  /// Separator option that lets the user type their own separator.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get exportFieldsSeparatorCustom;

  /// No description provided for @exportFieldsCustomSeparator.
  ///
  /// In en, this message translates to:
  /// **'Custom separator'**
  String get exportFieldsCustomSeparator;

  /// No description provided for @exportFieldsValueFormat.
  ///
  /// In en, this message translates to:
  /// **'Value format'**
  String get exportFieldsValueFormat;

  /// No description provided for @exportFieldsValueNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal text'**
  String get exportFieldsValueNormal;

  /// Value format that exports the stored code of a coded field instead of its label.
  ///
  /// In en, this message translates to:
  /// **'Encoded text'**
  String get exportFieldsValueEncoded;

  /// No description provided for @exportFieldsValueCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get exportFieldsValueCoordinates;

  /// Value format that wraps the value in brackets when conditions match.
  ///
  /// In en, this message translates to:
  /// **'Conditional brackets'**
  String get exportFieldsValueConditionalBrackets;

  /// No description provided for @exportFieldsValueConditionalField.
  ///
  /// In en, this message translates to:
  /// **'Conditional field'**
  String get exportFieldsValueConditionalField;

  /// No description provided for @exportFieldsValueConditionalValue.
  ///
  /// In en, this message translates to:
  /// **'Conditional value'**
  String get exportFieldsValueConditionalValue;

  /// No description provided for @exportFieldsReplacementText.
  ///
  /// In en, this message translates to:
  /// **'Replacement text'**
  String get exportFieldsReplacementText;

  /// No description provided for @exportFieldsReplacementTextHelper.
  ///
  /// In en, this message translates to:
  /// **'Written when the condition matches; otherwise the original value is kept.'**
  String get exportFieldsReplacementTextHelper;

  /// No description provided for @exportFieldsColumnName.
  ///
  /// In en, this message translates to:
  /// **'Column name'**
  String get exportFieldsColumnName;

  /// No description provided for @exportFieldsColumnNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Name the output column containing the custom value.'**
  String get exportFieldsColumnNameHelper;

  /// No description provided for @exportFieldsRelatedRecords.
  ///
  /// In en, this message translates to:
  /// **'Related records'**
  String get exportFieldsRelatedRecords;

  /// No description provided for @exportFieldsRelatedRecordsHelper.
  ///
  /// In en, this message translates to:
  /// **'Select the repeated record group to export.'**
  String get exportFieldsRelatedRecordsHelper;

  /// Fields of the nested child records, such as each collector or specimen part.
  ///
  /// In en, this message translates to:
  /// **'Selected child fields'**
  String get exportFieldsSelectedChildFields;

  /// No description provided for @exportFieldsSelectChildFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Select at least one child field below.'**
  String get exportFieldsSelectChildFieldHint;

  /// No description provided for @exportFieldsMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get exportFieldsMoveUp;

  /// No description provided for @exportFieldsMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get exportFieldsMoveDown;

  /// No description provided for @exportFieldsRemoveField.
  ///
  /// In en, this message translates to:
  /// **'Remove field'**
  String get exportFieldsRemoveField;

  /// No description provided for @exportFieldsChooseChildFields.
  ///
  /// In en, this message translates to:
  /// **'Choose child fields'**
  String get exportFieldsChooseChildFields;

  /// No description provided for @exportFieldsColumnPrefixOptional.
  ///
  /// In en, this message translates to:
  /// **'Column prefix (optional)'**
  String get exportFieldsColumnPrefixOptional;

  /// No description provided for @exportFieldsNestedOutput.
  ///
  /// In en, this message translates to:
  /// **'Nested output'**
  String get exportFieldsNestedOutput;

  /// No description provided for @exportFieldsNestedOneColumnHint.
  ///
  /// In en, this message translates to:
  /// **'Combine all child records into one cell.'**
  String get exportFieldsNestedOneColumnHint;

  /// No description provided for @exportFieldsNestedIndexedHint.
  ///
  /// In en, this message translates to:
  /// **'Create a group of columns for each record.'**
  String get exportFieldsNestedIndexedHint;

  /// No description provided for @exportFieldsNestedRepeatedHint.
  ///
  /// In en, this message translates to:
  /// **'Create one export row per child record.'**
  String get exportFieldsNestedRepeatedHint;

  /// No description provided for @exportFieldsNestedRepeatedTaken.
  ///
  /// In en, this message translates to:
  /// **'Another mapping already expands export rows.'**
  String get exportFieldsNestedRepeatedTaken;

  /// No description provided for @exportFieldsFieldSeparator.
  ///
  /// In en, this message translates to:
  /// **'Field separator'**
  String get exportFieldsFieldSeparator;

  /// No description provided for @exportFieldsRecordSeparator.
  ///
  /// In en, this message translates to:
  /// **'Record separator'**
  String get exportFieldsRecordSeparator;

  /// No description provided for @exportFieldsAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get exportFieldsAdvanced;

  /// No description provided for @exportFieldsRawExpression.
  ///
  /// In en, this message translates to:
  /// **'Raw source expression'**
  String get exportFieldsRawExpression;

  /// No description provided for @exportFieldsRawFormatOption.
  ///
  /// In en, this message translates to:
  /// **'Raw format option'**
  String get exportFieldsRawFormatOption;

  /// enum, dms, and custom_map:0=No are literal option codes; do not translate them.
  ///
  /// In en, this message translates to:
  /// **'For example: enum, dms, or custom_map:0=No.'**
  String get exportFieldsRawFormatOptionHelper;

  /// No description provided for @exportFieldsEmptyValue.
  ///
  /// In en, this message translates to:
  /// **'Empty value'**
  String get exportFieldsEmptyValue;

  /// No description provided for @exportFieldsEmptyBlank.
  ///
  /// In en, this message translates to:
  /// **'Blank'**
  String get exportFieldsEmptyBlank;

  /// No description provided for @exportFieldsEmptyCustomText.
  ///
  /// In en, this message translates to:
  /// **'Custom text'**
  String get exportFieldsEmptyCustomText;

  /// No description provided for @exportFieldsCustomEmptyText.
  ///
  /// In en, this message translates to:
  /// **'Custom empty text'**
  String get exportFieldsCustomEmptyText;

  /// No description provided for @exportFieldsRawNamespace.
  ///
  /// In en, this message translates to:
  /// **'Raw related-record namespace'**
  String get exportFieldsRawNamespace;

  /// No description provided for @exportFieldsErrorReplacement.
  ///
  /// In en, this message translates to:
  /// **'Replacement {number}: {error}'**
  String exportFieldsErrorReplacement(int number, String error);

  /// No description provided for @exportFieldsErrorChooseGroup.
  ///
  /// In en, this message translates to:
  /// **'Choose a related-record group.'**
  String get exportFieldsErrorChooseGroup;

  /// No description provided for @exportFieldsErrorChooseChild.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one child field.'**
  String get exportFieldsErrorChooseChild;

  /// No description provided for @exportFieldsErrorSeparatorsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Field and record separators cannot be empty.'**
  String get exportFieldsErrorSeparatorsEmpty;

  /// No description provided for @exportFieldsErrorMultiFieldHeader.
  ///
  /// In en, this message translates to:
  /// **'Set a custom header for a multi-field concatenated mapping.'**
  String get exportFieldsErrorMultiFieldHeader;

  /// No description provided for @exportFieldsErrorAddSegment.
  ///
  /// In en, this message translates to:
  /// **'Add at least one field or text segment.'**
  String get exportFieldsErrorAddSegment;

  /// No description provided for @exportFieldsErrorChooseSource.
  ///
  /// In en, this message translates to:
  /// **'Choose a source field.'**
  String get exportFieldsErrorChooseSource;

  /// No description provided for @exportFieldsErrorCompositeHeader.
  ///
  /// In en, this message translates to:
  /// **'Set a custom header for a composite mapping.'**
  String get exportFieldsErrorCompositeHeader;

  /// No description provided for @exportFieldsErrorIndexedSingleSource.
  ///
  /// In en, this message translates to:
  /// **'Indexed lists require exactly one source field.'**
  String get exportFieldsErrorIndexedSingleSource;

  /// No description provided for @exportFieldsErrorConditionalSingleSource.
  ///
  /// In en, this message translates to:
  /// **'Conditional output requires exactly one source field.'**
  String get exportFieldsErrorConditionalSingleSource;

  /// No description provided for @exportFieldsErrorAddCondition.
  ///
  /// In en, this message translates to:
  /// **'Add at least one condition.'**
  String get exportFieldsErrorAddCondition;

  /// No description provided for @exportFieldsErrorReplacementText.
  ///
  /// In en, this message translates to:
  /// **'Enter replacement text.'**
  String get exportFieldsErrorReplacementText;

  /// No description provided for @exportFieldsErrorControllingField.
  ///
  /// In en, this message translates to:
  /// **'Choose a controlling field for every bracket condition.'**
  String get exportFieldsErrorControllingField;

  /// No description provided for @exportFieldsErrorComparisonValue.
  ///
  /// In en, this message translates to:
  /// **'Enter a comparison value for every bracket condition.'**
  String get exportFieldsErrorComparisonValue;

  /// No description provided for @exportFieldsErrorSelfDependency.
  ///
  /// In en, this message translates to:
  /// **'A conditional field cannot depend on itself.'**
  String get exportFieldsErrorSelfDependency;

  /// No description provided for @exportFieldsCustomValue.
  ///
  /// In en, this message translates to:
  /// **'Custom value'**
  String get exportFieldsCustomValue;

  /// No description provided for @exportFieldsCustomValueHelp.
  ///
  /// In en, this message translates to:
  /// **'Fields and text are emitted left to right. Add as many segments as needed.'**
  String get exportFieldsCustomValueHelp;

  /// No description provided for @exportFieldsCustomValueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add a field or text to begin.'**
  String get exportFieldsCustomValueEmpty;

  /// No description provided for @exportFieldsTextOrSeparator.
  ///
  /// In en, this message translates to:
  /// **'Text or separator'**
  String get exportFieldsTextOrSeparator;

  /// Toggles exporting the readable label of a coded field instead of its stored code.
  ///
  /// In en, this message translates to:
  /// **'Show label'**
  String get exportFieldsShowLabel;

  /// No description provided for @exportFieldsEditConditionalText.
  ///
  /// In en, this message translates to:
  /// **'Edit conditional text'**
  String get exportFieldsEditConditionalText;

  /// No description provided for @exportFieldsMoveSegmentUp.
  ///
  /// In en, this message translates to:
  /// **'Move segment up'**
  String get exportFieldsMoveSegmentUp;

  /// No description provided for @exportFieldsMoveSegmentDown.
  ///
  /// In en, this message translates to:
  /// **'Move segment down'**
  String get exportFieldsMoveSegmentDown;

  /// No description provided for @exportFieldsRemoveSegment.
  ///
  /// In en, this message translates to:
  /// **'Remove segment'**
  String get exportFieldsRemoveSegment;

  /// No description provided for @exportFieldsAddField.
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get exportFieldsAddField;

  /// No description provided for @exportFieldsAddText.
  ///
  /// In en, this message translates to:
  /// **'Add text'**
  String get exportFieldsAddText;

  /// No description provided for @exportFieldsAddConditionalText.
  ///
  /// In en, this message translates to:
  /// **'Add conditional text'**
  String get exportFieldsAddConditionalText;

  /// No description provided for @exportFieldsExpression.
  ///
  /// In en, this message translates to:
  /// **'Expression: {expression}'**
  String exportFieldsExpression(String expression);

  /// No description provided for @exportFieldsAddSourceField.
  ///
  /// In en, this message translates to:
  /// **'Add source field'**
  String get exportFieldsAddSourceField;

  /// No description provided for @exportFieldsConditionalText.
  ///
  /// In en, this message translates to:
  /// **'Conditional text'**
  String get exportFieldsConditionalText;

  /// No description provided for @exportFieldsTextWhenMatched.
  ///
  /// In en, this message translates to:
  /// **'Text when matched'**
  String get exportFieldsTextWhenMatched;

  /// No description provided for @exportFieldsTextWhenMatchedHelper.
  ///
  /// In en, this message translates to:
  /// **'Fields such as {example} are filled in.'**
  String exportFieldsTextWhenMatchedHelper(String example);

  /// No description provided for @exportFieldsTextOtherwise.
  ///
  /// In en, this message translates to:
  /// **'Text otherwise (optional)'**
  String get exportFieldsTextOtherwise;

  /// No description provided for @exportFieldsTextOtherwiseHelper.
  ///
  /// In en, this message translates to:
  /// **'Leave it empty to write nothing.'**
  String get exportFieldsTextOtherwiseHelper;

  /// Joins conditions in a summary when any condition may match.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get exportFieldsSummaryOr;

  /// Joins conditions in a summary when all conditions must match.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get exportFieldsSummaryAnd;

  /// No description provided for @exportFieldsSummaryIf.
  ///
  /// In en, this message translates to:
  /// **'If {conditions} → \"{text}\"'**
  String exportFieldsSummaryIf(String conditions, String text);

  /// No description provided for @exportFieldsSummaryIfOtherwise.
  ///
  /// In en, this message translates to:
  /// **'If {conditions} → \"{text}\", otherwise \"{otherwise}\"'**
  String exportFieldsSummaryIfOtherwise(
    String conditions,
    String text,
    String otherwise,
  );

  /// No description provided for @exportFieldsSummaryEquals.
  ///
  /// In en, this message translates to:
  /// **'{field} equals \"{value}\"'**
  String exportFieldsSummaryEquals(String field, String value);

  /// No description provided for @exportFieldsSummaryNotEquals.
  ///
  /// In en, this message translates to:
  /// **'{field} does not equal \"{value}\"'**
  String exportFieldsSummaryNotEquals(String field, String value);

  /// No description provided for @exportFieldsSummaryContains.
  ///
  /// In en, this message translates to:
  /// **'{field} contains \"{value}\"'**
  String exportFieldsSummaryContains(String field, String value);

  /// No description provided for @exportFieldsSummaryIsNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'{field} is not empty'**
  String exportFieldsSummaryIsNotEmpty(String field);

  /// No description provided for @exportFieldsSummaryIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'{field} is empty'**
  String exportFieldsSummaryIsEmpty(String field);

  /// No description provided for @exportFieldsValueConditions.
  ///
  /// In en, this message translates to:
  /// **'Value conditions'**
  String get exportFieldsValueConditions;

  /// No description provided for @exportFieldsFieldConditions.
  ///
  /// In en, this message translates to:
  /// **'Field conditions'**
  String get exportFieldsFieldConditions;

  /// No description provided for @exportFieldsConditionsHelp.
  ///
  /// In en, this message translates to:
  /// **'Compare raw stored values. Blank controlling values never match.'**
  String get exportFieldsConditionsHelp;

  /// No description provided for @exportFieldsMatchLogic.
  ///
  /// In en, this message translates to:
  /// **'Match logic'**
  String get exportFieldsMatchLogic;

  /// No description provided for @exportFieldsMatchAny.
  ///
  /// In en, this message translates to:
  /// **'Any condition (OR)'**
  String get exportFieldsMatchAny;

  /// No description provided for @exportFieldsMatchAll.
  ///
  /// In en, this message translates to:
  /// **'All conditions (AND)'**
  String get exportFieldsMatchAll;

  /// No description provided for @exportFieldsAddCondition.
  ///
  /// In en, this message translates to:
  /// **'Add condition'**
  String get exportFieldsAddCondition;

  /// No description provided for @exportFieldsControllingField.
  ///
  /// In en, this message translates to:
  /// **'Controlling field'**
  String get exportFieldsControllingField;

  /// No description provided for @exportFieldsOperatorEquals.
  ///
  /// In en, this message translates to:
  /// **'Equals'**
  String get exportFieldsOperatorEquals;

  /// No description provided for @exportFieldsOperatorNotEquals.
  ///
  /// In en, this message translates to:
  /// **'Does not equal'**
  String get exportFieldsOperatorNotEquals;

  /// No description provided for @exportFieldsOperatorContains.
  ///
  /// In en, this message translates to:
  /// **'Contains'**
  String get exportFieldsOperatorContains;

  /// No description provided for @exportFieldsOperatorIsNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Is not empty'**
  String get exportFieldsOperatorIsNotEmpty;

  /// No description provided for @exportFieldsOperatorIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Is empty'**
  String get exportFieldsOperatorIsEmpty;

  /// Comparison value of a condition.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get exportFieldsValue;

  /// No description provided for @exportFieldsRemoveCondition.
  ///
  /// In en, this message translates to:
  /// **'Remove condition'**
  String get exportFieldsRemoveCondition;

  /// No description provided for @exportFieldsIndexedColumnNames.
  ///
  /// In en, this message translates to:
  /// **'Indexed column names'**
  String get exportFieldsIndexedColumnNames;

  /// No description provided for @exportFieldsIndexedUnderscore.
  ///
  /// In en, this message translates to:
  /// **'Underscore: {example}'**
  String exportFieldsIndexedUnderscore(String example);

  /// No description provided for @exportFieldsIndexedCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact: {example}'**
  String exportFieldsIndexedCompact(String example);

  /// No description provided for @exportFieldsIndexedBrackets.
  ///
  /// In en, this message translates to:
  /// **'Brackets: {example}'**
  String exportFieldsIndexedBrackets(String example);

  /// No description provided for @exportFieldsOutputExample.
  ///
  /// In en, this message translates to:
  /// **'Output example'**
  String get exportFieldsOutputExample;

  /// No description provided for @exportFieldsOutputExampleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete the mapping to see its output shape.'**
  String get exportFieldsOutputExampleEmpty;

  /// No description provided for @exportFieldsOutputExampleRows.
  ///
  /// In en, this message translates to:
  /// **'Each child record creates another export row.'**
  String get exportFieldsOutputExampleRows;

  /// No description provided for @exportFieldsCustomizeNested.
  ///
  /// In en, this message translates to:
  /// **'Customize Nested Mapping'**
  String get exportFieldsCustomizeNested;

  /// No description provided for @exportFieldsCustomizeField.
  ///
  /// In en, this message translates to:
  /// **'Customize Field Mapping'**
  String get exportFieldsCustomizeField;

  /// No description provided for @exportFieldsPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Preview'**
  String get exportFieldsPreviewTitle;

  /// No description provided for @exportFieldsPreviewShowing.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{Showing {shown} of 1 record} other{Showing {shown} of {total} records}}'**
  String exportFieldsPreviewShowing(int shown, int total);
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
