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

  /// No description provided for @settingsMapKindUnavailableOnDesktop.
  ///
  /// In en, this message translates to:
  /// **'{kind} · unavailable on desktop'**
  String settingsMapKindUnavailableOnDesktop(String kind);

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

  /// No description provided for @settingsMapLayerUnavailableOnDesktop.
  ///
  /// In en, this message translates to:
  /// **'This layer is unavailable on desktop'**
  String get settingsMapLayerUnavailableOnDesktop;

  /// No description provided for @settingsMapLayerTypeUnavailableOnDesktop.
  ///
  /// In en, this message translates to:
  /// **'This layer type is unavailable on desktop.'**
  String get settingsMapLayerTypeUnavailableOnDesktop;

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

  /// No description provided for @settingsMapSupportedFormatsDesktop.
  ///
  /// In en, this message translates to:
  /// **'Supports GeoJSON, zipped WGS84 Shapefiles, and raster PMTiles on desktop.'**
  String get settingsMapSupportedFormatsDesktop;

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

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// Hint of a dropdown with no selection.
  ///
  /// In en, this message translates to:
  /// **'Choose one'**
  String get formsChooseOne;

  /// No description provided for @formsErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String formsErrorDetail(String error);

  /// Label of the field that adds a value to a controlled vocabulary. type is a localized lowercase noun such as 'site type'.
  ///
  /// In en, this message translates to:
  /// **'Add {type}'**
  String formsAddValue(String type);

  /// Hint of a field. type is a localized lowercase noun or a custom field name.
  ///
  /// In en, this message translates to:
  /// **'Enter {type}'**
  String formsEnterValue(String type);

  /// Button that updates a controlled vocabulary with values found in the database.
  ///
  /// In en, this message translates to:
  /// **'Match database'**
  String get formsMatchDatabase;

  /// plural is a localized lowercase plural noun such as 'site types'.
  ///
  /// In en, this message translates to:
  /// **'Match database {plural}?'**
  String formsMatchDatabaseTitle(String plural);

  /// No description provided for @formsMatchAppendMissing.
  ///
  /// In en, this message translates to:
  /// **'Append missing'**
  String get formsMatchAppendMissing;

  /// No description provided for @formsMatchOverrideAll.
  ///
  /// In en, this message translates to:
  /// **'Override all'**
  String get formsMatchOverrideAll;

  /// No description provided for @formsMatchHelp.
  ///
  /// In en, this message translates to:
  /// **'Use this when records arrive from someone whose controlled vocabularies you do not have.'**
  String get formsMatchHelp;

  /// No description provided for @formsMatchAppendDescription.
  ///
  /// In en, this message translates to:
  /// **'Add values found in the database without changing your existing {plural}.'**
  String formsMatchAppendDescription(String plural);

  /// No description provided for @formsMatchOverrideDescription.
  ///
  /// In en, this message translates to:
  /// **'Replace all configured {plural} with the values currently found in the database.'**
  String formsMatchOverrideDescription(String plural);

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'site type'**
  String get formsVocabSiteType;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'site types'**
  String get formsVocabSiteTypePlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'habitat type'**
  String get formsVocabHabitatType;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'habitat types'**
  String get formsVocabHabitatTypePlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'datum'**
  String get formsVocabDatum;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'datums'**
  String get formsVocabDatumPlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'primary activity'**
  String get formsVocabPrimaryActivity;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'primary activities'**
  String get formsVocabPrimaryActivityPlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'collection method'**
  String get formsVocabCollectionMethod;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'collection methods'**
  String get formsVocabCollectionMethodPlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'personnel role'**
  String get formsVocabPersonnelRole;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'personnel roles'**
  String get formsVocabPersonnelRolePlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'identification method'**
  String get formsVocabIdentificationMethod;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'identification methods'**
  String get formsVocabIdentificationMethodPlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'life stage'**
  String get formsVocabLifeStage;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'life stages'**
  String get formsVocabLifeStagePlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'specimen type'**
  String get formsVocabSpecimenType;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'specimen types'**
  String get formsVocabSpecimenTypePlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'treatment'**
  String get formsVocabTreatment;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'treatments'**
  String get formsVocabTreatmentPlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'condition'**
  String get formsVocabCondition;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'conditions'**
  String get formsVocabConditionPlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'category'**
  String get formsVocabParasiteCategory;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'categories'**
  String get formsVocabParasiteCategoryPlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'detection method'**
  String get formsVocabDetectionMethod;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'detection methods'**
  String get formsVocabDetectionMethodPlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'preparation method'**
  String get formsVocabPreparationMethod;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'preparation methods'**
  String get formsVocabPreparationMethodPlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'anatomical location'**
  String get formsVocabAnatomicalLocation;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'anatomical locations'**
  String get formsVocabAnatomicalLocationPlural;

  /// Singular controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Add {type}'.
  ///
  /// In en, this message translates to:
  /// **'storage value'**
  String get formsVocabStorageValue;

  /// Plural controlled-vocabulary noun used mid-sentence (lowercase), e.g. in 'Match database {plural}?'.
  ///
  /// In en, this message translates to:
  /// **'storage values'**
  String get formsVocabStorageValuePlural;

  /// No description provided for @formsNextId.
  ///
  /// In en, this message translates to:
  /// **'Next ID'**
  String get formsNextId;

  /// No description provided for @formsNextNumber.
  ///
  /// In en, this message translates to:
  /// **'Next number'**
  String get formsNextNumber;

  /// No description provided for @formsNumberedIdNoPreview.
  ///
  /// In en, this message translates to:
  /// **'Set a next number to auto-number · Leading zeros are kept'**
  String get formsNumberedIdNoPreview;

  /// label names the preview, such as 'Next tissue ID'; preview is the next generated ID.
  ///
  /// In en, this message translates to:
  /// **'{label}: {preview} · Leading zeros are kept'**
  String formsNumberedIdPreview(String label, String preview);

  /// Group of bundled document presets.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get formsBundledDocuments;

  /// Group of bundled tabular export presets.
  ///
  /// In en, this message translates to:
  /// **'Tabular records'**
  String get formsBundledTabularRecords;

  /// Group of bundled templates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get formsBundledTemplates;

  /// Subtitle of a bundled preset that is already installed.
  ///
  /// In en, this message translates to:
  /// **'Added · {description}'**
  String formsBundledAdded(String description);

  /// No description provided for @formsDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get formsDescriptionOptional;

  /// No description provided for @formsDescriptionTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use {max} characters or fewer.'**
  String formsDescriptionTooLong(int max);

  /// No description provided for @formsShowInfo.
  ///
  /// In en, this message translates to:
  /// **'Show information'**
  String get formsShowInfo;

  /// Title of the help dialog opened by the info button.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get formsInfo;

  /// No description provided for @formsDeleteConfirmPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type `{text}` to enable delete'**
  String formsDeleteConfirmPrompt(String text);

  /// No description provided for @formsDeleteConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Enter confirmation text'**
  String get formsDeleteConfirmHint;

  /// Specimen search option chip.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get formsSearchAll;

  /// Specimen search option chip.
  ///
  /// In en, this message translates to:
  /// **'Field number'**
  String get formsSearchFieldNumber;

  /// Specimen search option chip.
  ///
  /// In en, this message translates to:
  /// **'Cataloger'**
  String get formsSearchCataloger;

  /// Specimen search option chip.
  ///
  /// In en, this message translates to:
  /// **'Preparator'**
  String get formsSearchPreparator;

  /// Specimen search option chip.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get formsSearchCollector;

  /// Specimen search option chip.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get formsSearchCondition;

  /// Specimen search option chip: preparation date.
  ///
  /// In en, this message translates to:
  /// **'Prep date'**
  String get formsSearchPrepDate;

  /// Specimen search option chip: preparation time.
  ///
  /// In en, this message translates to:
  /// **'Prep time'**
  String get formsSearchPrepTime;

  /// Specimen search option chip.
  ///
  /// In en, this message translates to:
  /// **'Taxa'**
  String get formsSearchTaxa;

  /// Specimen search option chip: preparation type.
  ///
  /// In en, this message translates to:
  /// **'Prep type'**
  String get formsSearchPrepType;

  /// No description provided for @formsSiteId.
  ///
  /// In en, this message translates to:
  /// **'Site ID'**
  String get formsSiteId;

  /// No description provided for @formsSiteIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a site'**
  String get formsSiteIdHint;

  /// No description provided for @formsSiteName.
  ///
  /// In en, this message translates to:
  /// **'Site name'**
  String get formsSiteName;

  /// Button that copies a preset.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get formsPresetDuplicate;

  /// No description provided for @formsPresetName.
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get formsPresetName;

  /// Refers to the formsPresetUpdate button; keep its label in sync.
  ///
  /// In en, this message translates to:
  /// **'Select Update to save the name and description'**
  String get formsPresetUpdateHelper;

  /// No description provided for @formsPresetUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get formsPresetUpdate;

  /// No description provided for @formsCustomFieldLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load custom fields: {error}'**
  String formsCustomFieldLoadError(String error);

  /// No description provided for @formsCustomFieldManage.
  ///
  /// In en, this message translates to:
  /// **'Manage custom fields'**
  String get formsCustomFieldManage;

  /// No description provided for @formsEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get formsEnterNumber;

  /// Option for a custom field with no value.
  ///
  /// In en, this message translates to:
  /// **'Unset'**
  String get formsCustomFieldUnset;

  /// No description provided for @formsCustomFieldArchivedOption.
  ///
  /// In en, this message translates to:
  /// **'{label} (archived)'**
  String formsCustomFieldArchivedOption(String label);

  /// Tooltip of the add button on preset, template, and custom field screens.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, template{Create new template} customField{Create new custom field} other{Create new preset}}'**
  String sharedPresetCreateTooltip(String kind);

  /// Tooltip of the overflow menu on preset, template, and custom field screens.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, template{Template options} customField{Custom field options} other{Preset options}}'**
  String sharedPresetOptions(String kind);

  /// No description provided for @sharedPresetCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get sharedPresetCreateNew;

  /// No description provided for @sharedPresetScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get sharedPresetScanQr;

  /// No description provided for @sharedPresetExportSelected.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, template{Export this template} customField{Export this custom field} other{Export this preset}}'**
  String sharedPresetExportSelected(String kind);

  /// No description provided for @sharedPresetExportAll.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, template{Export all templates} customField{Export all custom fields} other{Export all presets}}'**
  String sharedPresetExportAll(String kind);

  /// Adds the presets bundled with NAHPU.
  ///
  /// In en, this message translates to:
  /// **'Load defaults'**
  String get sharedLoadDefaults;

  /// No description provided for @sharedShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get sharedShowMore;

  /// No description provided for @sharedShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get sharedShowLess;

  /// No description provided for @sharedShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get sharedShare;

  /// No description provided for @sharedUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get sharedUpdate;

  /// No description provided for @sharedAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get sharedAdd;

  /// No description provided for @sharedExportAs.
  ///
  /// In en, this message translates to:
  /// **'Export as…'**
  String get sharedExportAs;

  /// No description provided for @sharedFind.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get sharedFind;

  /// No description provided for @sharedDeleteSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 item} other{Delete {count} items}}'**
  String sharedDeleteSelectedCount(int count);

  /// No description provided for @sharedDeleteSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete selected items'**
  String get sharedDeleteSelectedTitle;

  /// No description provided for @sharedDeleteSelectedBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the selected items?'**
  String get sharedDeleteSelectedBody;

  /// No description provided for @sharedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get sharedTryAgain;

  /// No description provided for @sharedExportTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'about {duration} left'**
  String sharedExportTimeLeft(String duration);

  /// No description provided for @sharedExportCancelling.
  ///
  /// In en, this message translates to:
  /// **'Cancelling…'**
  String get sharedExportCancelling;

  /// No description provided for @sharedExportFilesOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total, plural, =1{1 file} other{{total} files}}'**
  String sharedExportFilesOfTotal(int completed, int total);

  /// No description provided for @sharedExportFileCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file} other{{count} files}}'**
  String sharedExportFileCount(int count);

  /// No description provided for @sharedExportBytesOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{processed} of {total}'**
  String sharedExportBytesOfTotal(String processed, String total);

  /// No description provided for @sharedExportElapsed.
  ///
  /// In en, this message translates to:
  /// **'{duration} elapsed'**
  String sharedExportElapsed(String duration);

  /// Progress count beside the active export step.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total}'**
  String sharedExportUnitsOfTotal(int completed, int total);

  /// No description provided for @sharedExportCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'No file was saved. Nothing on this device was changed.'**
  String get sharedExportCancelledBody;

  /// No description provided for @sharedExportStoppedAt.
  ///
  /// In en, this message translates to:
  /// **'Stopped while working on: {step}'**
  String sharedExportStoppedAt(String step);

  /// No description provided for @sharedExportDidNotFinish.
  ///
  /// In en, this message translates to:
  /// **'The export did not finish.'**
  String get sharedExportDidNotFinish;

  /// No description provided for @sharedExportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled'**
  String get sharedExportCancelled;

  /// No description provided for @sharedExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get sharedExportFailed;

  /// No description provided for @sharedExportComplete.
  ///
  /// In en, this message translates to:
  /// **'Export complete'**
  String get sharedExportComplete;

  /// The exported file was written to disk.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get sharedSaved;

  /// No description provided for @sharedHideSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Hide save location'**
  String get sharedHideSaveLocation;

  /// No description provided for @sharedExportTemporaryNote.
  ///
  /// In en, this message translates to:
  /// **'Share this file now to keep it. NAHPU removes it when you export again.'**
  String get sharedExportTemporaryNote;

  /// No description provided for @sharedExportAppStorageNote.
  ///
  /// In en, this message translates to:
  /// **'Saved in NAHPU app storage. Choose a folder next time to save straight to it.'**
  String get sharedExportAppStorageNote;

  /// No description provided for @sharedExportFinishedIn.
  ///
  /// In en, this message translates to:
  /// **'Finished in {duration}'**
  String sharedExportFinishedIn(String duration);

  /// No description provided for @sharedExportSizeIn.
  ///
  /// In en, this message translates to:
  /// **'{size} in {duration}'**
  String sharedExportSizeIn(String size, String duration);

  /// No description provided for @sharedOpenDirectory.
  ///
  /// In en, this message translates to:
  /// **'Open directory'**
  String get sharedOpenDirectory;

  /// No description provided for @sharedSaveToDevice.
  ///
  /// In en, this message translates to:
  /// **'Save to device'**
  String get sharedSaveToDevice;

  /// No description provided for @sharedSaveCopyTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Too large to save through the Files app, which is limited to {limit}. Choose a folder before exporting to write files this size straight to your device.'**
  String sharedSaveCopyTooLarge(String limit);

  /// No description provided for @sharedQrExportImage.
  ///
  /// In en, this message translates to:
  /// **'Export QR code as an image'**
  String get sharedQrExportImage;

  /// No description provided for @sharedQrImageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This data is too large for a QR code image.'**
  String get sharedQrImageTooLarge;

  /// No description provided for @sharedLoadDefaultsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the bundled presets to add. Presets you already have are left unchanged.'**
  String get sharedLoadDefaultsDescription;

  /// No description provided for @sharedLoadDefaultsNone.
  ///
  /// In en, this message translates to:
  /// **'No default presets of this type.'**
  String get sharedLoadDefaultsNone;

  /// Heading for bundled presets that suit any catalog format.
  ///
  /// In en, this message translates to:
  /// **'Defaults'**
  String get sharedLoadDefaultsGenericTitle;

  /// No description provided for @sharedLoadDefaultsGenericMessage.
  ///
  /// In en, this message translates to:
  /// **'Presets that suit any catalog format.'**
  String get sharedLoadDefaultsGenericMessage;

  /// Heading for bundled presets written for one catalog format.
  ///
  /// In en, this message translates to:
  /// **'For {format}'**
  String sharedLoadDefaultsForFormat(String format);

  /// No description provided for @sharedLoadDefaultsForFormatMessage.
  ///
  /// In en, this message translates to:
  /// **'Optional presets written for this catalog format.'**
  String get sharedLoadDefaultsForFormatMessage;

  /// No description provided for @sharedLoadDefaultsLayoutsNote.
  ///
  /// In en, this message translates to:
  /// **'Layouts bring the templates they print with.'**
  String get sharedLoadDefaultsLayoutsNote;

  /// No description provided for @sharedLoadSelected.
  ///
  /// In en, this message translates to:
  /// **'Load selected'**
  String get sharedLoadSelected;

  /// No description provided for @sharedLoadDefaultsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load bundled presets: {error}'**
  String sharedLoadDefaultsLoadError(String error);

  /// No description provided for @sharedLoadDefaultsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load default presets: {error}'**
  String sharedLoadDefaultsFailed(String error);

  /// No description provided for @sharedIncludeLinkedTemplates.
  ///
  /// In en, this message translates to:
  /// **'Include linked templates'**
  String get sharedIncludeLinkedTemplates;

  /// No description provided for @sharedLinkedTemplateList.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 template: {names}} other{{count} templates: {names}}}'**
  String sharedLinkedTemplateList(int count, String names);

  /// No description provided for @sharedExportedTo.
  ///
  /// In en, this message translates to:
  /// **'Exported to {path}'**
  String sharedExportedTo(String path);

  /// No description provided for @sharedExportFailedError.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String sharedExportFailedError(String error);

  /// No description provided for @sharedExportProjectInfo.
  ///
  /// In en, this message translates to:
  /// **'Export project info'**
  String get sharedExportProjectInfo;

  /// No description provided for @sharedExportProjectInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Export this project information as JSON.'**
  String get sharedExportProjectInfoDescription;

  /// Sort direction heading in the sort dialog.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get sharedSortOrder;

  /// No description provided for @sharedSortAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get sharedSortAscending;

  /// No description provided for @sharedSortDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get sharedSortDescending;

  /// No description provided for @sharedSortId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get sharedSortId;

  /// No description provided for @sharedSortRecordOrder.
  ///
  /// In en, this message translates to:
  /// **'Record order'**
  String get sharedSortRecordOrder;

  /// No description provided for @sharedSortSiteId.
  ///
  /// In en, this message translates to:
  /// **'Site ID'**
  String get sharedSortSiteId;

  /// No description provided for @sharedSortStateProvince.
  ///
  /// In en, this message translates to:
  /// **'State/province'**
  String get sharedSortStateProvince;

  /// No description provided for @sharedSortPreciseLocality.
  ///
  /// In en, this message translates to:
  /// **'Precise locality'**
  String get sharedSortPreciseLocality;

  /// No description provided for @sharedSortEventId.
  ///
  /// In en, this message translates to:
  /// **'Event ID'**
  String get sharedSortEventId;

  /// No description provided for @sharedSortStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get sharedSortStartDate;

  /// No description provided for @sharedSortFieldId.
  ///
  /// In en, this message translates to:
  /// **'Field ID'**
  String get sharedSortFieldId;

  /// No description provided for @sharedSortCataloger.
  ///
  /// In en, this message translates to:
  /// **'Cataloger'**
  String get sharedSortCataloger;

  /// No description provided for @sharedSortSpecies.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get sharedSortSpecies;

  /// No description provided for @sharedSortDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sharedSortDate;

  /// No description provided for @sharedSortWriter.
  ///
  /// In en, this message translates to:
  /// **'Writer'**
  String get sharedSortWriter;

  /// No description provided for @sharedImportRecordType.
  ///
  /// In en, this message translates to:
  /// **'{type, select, site{Import site} event{Import event} other{Import specimen}}'**
  String sharedImportRecordType(String type);

  /// No description provided for @sharedCreateNewRecordType.
  ///
  /// In en, this message translates to:
  /// **'{type, select, site{Create new site} event{Create new event} other{Create new specimen}}'**
  String sharedCreateNewRecordType(String type);

  /// No description provided for @sharedUpdateExistingRecordType.
  ///
  /// In en, this message translates to:
  /// **'{type, select, site{Update an existing site} event{Update an existing event} other{Update an existing specimen}}'**
  String sharedUpdateExistingRecordType(String type);

  /// No description provided for @sharedExportRecordType.
  ///
  /// In en, this message translates to:
  /// **'{type, select, site{Export site} event{Export event} other{Export specimen}}'**
  String sharedExportRecordType(String type);

  /// No description provided for @sharedExportRecordJson.
  ///
  /// In en, this message translates to:
  /// **'{type, select, site{Export this site record as JSON.} event{Export this event record as JSON.} other{Export this specimen record as JSON.}}'**
  String sharedExportRecordJson(String type);

  /// No description provided for @sharedExportRecordMedia.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This record includes 1 linked media file, which will be included in the archive.} other{This record includes {count} linked media files, which will be included in the archive.}}'**
  String sharedExportRecordMedia(int count);

  /// No description provided for @sharedReusesSavedLocality.
  ///
  /// In en, this message translates to:
  /// **'Reuses a saved locality: {locality}'**
  String sharedReusesSavedLocality(String locality);

  /// No description provided for @sharedContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get sharedContinue;

  /// No description provided for @sharedBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get sharedBack;

  /// No description provided for @sharedChooseEventSite.
  ///
  /// In en, this message translates to:
  /// **'Choose event site'**
  String get sharedChooseEventSite;

  /// No description provided for @sharedChooseEventSiteDescription.
  ///
  /// In en, this message translates to:
  /// **'This event includes a linked site. Choose an existing site or create the embedded site as a new site.'**
  String get sharedChooseEventSiteDescription;

  /// No description provided for @sharedCreateEmbeddedSite.
  ///
  /// In en, this message translates to:
  /// **'Create embedded site'**
  String get sharedCreateEmbeddedSite;

  /// No description provided for @sharedCreateEmbeddedEvent.
  ///
  /// In en, this message translates to:
  /// **'Create embedded event'**
  String get sharedCreateEmbeddedEvent;

  /// No description provided for @sharedCreateEmbeddedTaxonomy.
  ///
  /// In en, this message translates to:
  /// **'Create embedded taxonomy'**
  String get sharedCreateEmbeddedTaxonomy;

  /// No description provided for @sharedChooseSpecimenEvent.
  ///
  /// In en, this message translates to:
  /// **'Choose specimen event'**
  String get sharedChooseSpecimenEvent;

  /// No description provided for @sharedChooseSpecimenTaxonomy.
  ///
  /// In en, this message translates to:
  /// **'Choose specimen taxonomy'**
  String get sharedChooseSpecimenTaxonomy;

  /// No description provided for @sharedCoordinateCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 coordinate} other{{count} coordinates}}'**
  String sharedCoordinateCount(int count);

  /// No description provided for @sharedPersonCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String sharedPersonCount(int count);

  /// Collection method entries of an event.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 collection method} other{{count} collection methods}}'**
  String sharedCollMethodCount(int count);

  /// No description provided for @sharedPersonnelAssignmentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 personnel assignment} other{{count} personnel assignments}}'**
  String sharedPersonnelAssignmentCount(int count);

  /// One item in a list of what an imported record includes.
  ///
  /// In en, this message translates to:
  /// **'environmental data'**
  String get sharedEnvironmentalData;

  /// No description provided for @sharedMediaFileCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 media file} other{{count} media files}}'**
  String sharedMediaFileCount(int count);

  /// No description provided for @sharedNoAssociatedRecords.
  ///
  /// In en, this message translates to:
  /// **'No associated records'**
  String get sharedNoAssociatedRecords;

  /// No description provided for @sharedSiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Site {id}'**
  String sharedSiteLabel(String id);

  /// No description provided for @sharedEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Event {id}'**
  String sharedEventLabel(String id);

  /// No description provided for @sharedSpecimenLabel.
  ///
  /// In en, this message translates to:
  /// **'Specimen {id}'**
  String sharedSpecimenLabel(String id);

  /// No description provided for @sharedTaxonLabel.
  ///
  /// In en, this message translates to:
  /// **'Taxon {id}'**
  String sharedTaxonLabel(String id);

  /// No description provided for @sharedRecordLabel.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get sharedRecordLabel;

  /// No description provided for @sharedSpecimenImportSummary.
  ///
  /// In en, this message translates to:
  /// **'Includes {partCount, plural, =1{1 part} other{{partCount} parts}}, {associatedCount, plural, =1{1 associated record} other{{associatedCount} associated records}}, and {mediaCount, plural, =1{1 media file} other{{mediaCount} media files}}.'**
  String sharedSpecimenImportSummary(
    int partCount,
    int associatedCount,
    int mediaCount,
  );

  /// No description provided for @sharedSiteQrCode.
  ///
  /// In en, this message translates to:
  /// **'Site QR code'**
  String get sharedSiteQrCode;

  /// No description provided for @sharedEventQrCode.
  ///
  /// In en, this message translates to:
  /// **'Event QR code'**
  String get sharedEventQrCode;

  /// No description provided for @sharedSpecimenImported.
  ///
  /// In en, this message translates to:
  /// **'Specimen imported successfully.'**
  String get sharedSpecimenImported;

  /// No description provided for @sharedSiteImported.
  ///
  /// In en, this message translates to:
  /// **'Site imported successfully.'**
  String get sharedSiteImported;

  /// No description provided for @sharedEventImported.
  ///
  /// In en, this message translates to:
  /// **'Event imported successfully.'**
  String get sharedEventImported;

  /// No description provided for @sharedQrNoData.
  ///
  /// In en, this message translates to:
  /// **'The QR code has no data.'**
  String get sharedQrNoData;

  /// No description provided for @sharedRecordQrTooLargeBody.
  ///
  /// In en, this message translates to:
  /// **'This record contains too much data for a QR code. Export it as JSON to transfer the complete record instead.'**
  String get sharedRecordQrTooLargeBody;

  /// No description provided for @sharedRecordQrDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan this code from another NAHPU device to import the record.'**
  String get sharedRecordQrDescription;

  /// No description provided for @sharedRecordExchangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Record import/export failed: {error}'**
  String sharedRecordExchangeFailed(String error);

  /// No description provided for @sharedFileName.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get sharedFileName;

  /// No description provided for @sharedSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String sharedSomethingWentWrong(String error);

  /// No description provided for @sharedSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get sharedSelectFile;

  /// No description provided for @sharedSupportedFormats.
  ///
  /// In en, this message translates to:
  /// **'Supported formats'**
  String get sharedSupportedFormats;

  /// A heading and the list of file formats on the next line.
  ///
  /// In en, this message translates to:
  /// **'{label}:\n{formats}'**
  String sharedSupportedFormatsList(String label, String formats);

  /// No description provided for @sharedAppendDate.
  ///
  /// In en, this message translates to:
  /// **'Append current date'**
  String get sharedAppendDate;

  /// Keep -yyyy-mm-dd as is; it is the literal date pattern.
  ///
  /// In en, this message translates to:
  /// **'Adds -yyyy-mm-dd to the filename'**
  String get sharedAppendDateDescription;

  /// No description provided for @sharedSaveTo.
  ///
  /// In en, this message translates to:
  /// **'Save to'**
  String get sharedSaveTo;

  /// No description provided for @sharedSelectDirectory.
  ///
  /// In en, this message translates to:
  /// **'Select directory'**
  String get sharedSelectDirectory;

  /// Clears the chosen folder; does not delete files.
  ///
  /// In en, this message translates to:
  /// **'Clear directory'**
  String get sharedClearDirectory;

  /// No description provided for @sharedNoFolderChosen.
  ///
  /// In en, this message translates to:
  /// **'No folder chosen. The export goes to NAHPU app storage — browse to a folder to put it somewhere you choose.'**
  String get sharedNoFolderChosen;

  /// No description provided for @sharedShareAfterExport.
  ///
  /// In en, this message translates to:
  /// **'Share after export'**
  String get sharedShareAfterExport;

  /// No description provided for @sharedTemporaryExportNote.
  ///
  /// In en, this message translates to:
  /// **'NAHPU keeps the file only until your next export. Share it to save a copy in Files, send it to another app, or put it in a cloud folder.'**
  String get sharedTemporaryExportNote;

  /// No description provided for @sharedEntireDatabaseContents.
  ///
  /// In en, this message translates to:
  /// **'Entire database contents'**
  String get sharedEntireDatabaseContents;

  /// No description provided for @sharedBackupSizeBeforeCompression.
  ///
  /// In en, this message translates to:
  /// **'Backup size before compression'**
  String get sharedBackupSizeBeforeCompression;

  /// A numbered wizard step.
  ///
  /// In en, this message translates to:
  /// **'{number}. {label}'**
  String sharedWizardStepChip(int number, String label);

  /// No description provided for @sharedNavDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get sharedNavDashboard;

  /// No description provided for @sharedNavSites.
  ///
  /// In en, this message translates to:
  /// **'Sites'**
  String get sharedNavSites;

  /// No description provided for @sharedNavEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get sharedNavEvents;

  /// No description provided for @sharedNavSpecimens.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get sharedNavSpecimens;

  /// No description provided for @sharedNavNarrative.
  ///
  /// In en, this message translates to:
  /// **'Narrative'**
  String get sharedNavNarrative;

  /// No description provided for @sharedNavCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get sharedNavCollapse;

  /// No description provided for @sharedNavExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get sharedNavExpand;

  /// No description provided for @sharedNavCollapseNavigation.
  ///
  /// In en, this message translates to:
  /// **'Collapse navigation'**
  String get sharedNavCollapseNavigation;

  /// No description provided for @sharedNavExpandNavigation.
  ///
  /// In en, this message translates to:
  /// **'Expand navigation'**
  String get sharedNavExpandNavigation;

  /// No description provided for @sharedNavCollapseRail.
  ///
  /// In en, this message translates to:
  /// **'Collapse navigation rail'**
  String get sharedNavCollapseRail;

  /// No description provided for @sharedNavExpandRail.
  ///
  /// In en, this message translates to:
  /// **'Expand navigation rail'**
  String get sharedNavExpandRail;

  /// No description provided for @sharedNavMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get sharedNavMenu;

  /// No description provided for @sharedNavCloseMenu.
  ///
  /// In en, this message translates to:
  /// **'Close menu'**
  String get sharedNavCloseMenu;

  /// No description provided for @sharedNavCloseProjectMenu.
  ///
  /// In en, this message translates to:
  /// **'Close project menu'**
  String get sharedNavCloseProjectMenu;

  /// No description provided for @sharedNavOpenProjectMenu.
  ///
  /// In en, this message translates to:
  /// **'Open project menu'**
  String get sharedNavOpenProjectMenu;

  /// No description provided for @sharedNavCloseProject.
  ///
  /// In en, this message translates to:
  /// **'Close project'**
  String get sharedNavCloseProject;

  /// No description provided for @sharedGoToPage.
  ///
  /// In en, this message translates to:
  /// **'Go to page'**
  String get sharedGoToPage;

  /// No description provided for @sharedGoToPageOrSearch.
  ///
  /// In en, this message translates to:
  /// **'Go to page or search'**
  String get sharedGoToPageOrSearch;

  /// No description provided for @sharedPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String sharedPageOf(int current, int total);

  /// No description provided for @sharedSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get sharedSearch;

  /// No description provided for @sharedPageNumber.
  ///
  /// In en, this message translates to:
  /// **'Page number'**
  String get sharedPageNumber;

  /// No description provided for @sharedGo.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get sharedGo;

  /// No description provided for @sharedOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get sharedOr;

  /// No description provided for @sharedSearchRecords.
  ///
  /// In en, this message translates to:
  /// **'Search records'**
  String get sharedSearchRecords;

  /// No description provided for @sharedPageOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a page from 1 to {total}'**
  String sharedPageOutOfRange(int total);

  /// No description provided for @textReplaceErrorEmptyPattern.
  ///
  /// In en, this message translates to:
  /// **'Find text cannot be empty.'**
  String get textReplaceErrorEmptyPattern;

  /// Shown when a regex replacement pattern does not compile. detail is the raw parser message, left untranslated.
  ///
  /// In en, this message translates to:
  /// **'Invalid regular expression: {detail}'**
  String textReplaceErrorInvalidRegex(String detail);

  /// No description provided for @textReplaceAdd.
  ///
  /// In en, this message translates to:
  /// **'Add replacement'**
  String get textReplaceAdd;

  /// No description provided for @textReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace text'**
  String get textReplaceTitle;

  /// No description provided for @textReplaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Applied in order after value formatting.'**
  String get textReplaceSubtitle;

  /// No description provided for @textReplaceDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Find and replace'**
  String get textReplaceDialogTitle;

  /// Label for choosing how a replacement rule matches text: exact or regex.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get textReplaceMatch;

  /// Match type: literal text.
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get textReplaceMatchExact;

  /// Match type: regular expression.
  ///
  /// In en, this message translates to:
  /// **'Regex'**
  String get textReplaceMatchRegex;

  /// No description provided for @textReplaceFind.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get textReplaceFind;

  /// No description provided for @textReplaceWith.
  ///
  /// In en, this message translates to:
  /// **'Replace with'**
  String get textReplaceWith;

  /// No description provided for @textReplaceIgnoreCase.
  ///
  /// In en, this message translates to:
  /// **'Ignore case'**
  String get textReplaceIgnoreCase;

  /// No description provided for @textReplaceMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move replacement up'**
  String get textReplaceMoveUp;

  /// No description provided for @textReplaceMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move replacement down'**
  String get textReplaceMoveDown;

  /// No description provided for @textReplaceRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove replacement'**
  String get textReplaceRemove;

  /// No description provided for @textReplaceRegexHelp.
  ///
  /// In en, this message translates to:
  /// **'Use \$0 for the full match, \$1…\$n for groups, and \$\$ for \$.'**
  String get textReplaceRegexHelp;

  /// Font preview sample text. Free translation is fine; keep it playful and natural.
  ///
  /// In en, this message translates to:
  /// **'Durians are the king of fruits, and mangosteen is the queen of fruit. Apparently, it is never a good idea to eat them at the same time. I definitely should not have eaten 12 durians and a dozen mangosteens in one sitting out in the fields.'**
  String get documentFontSampleA;

  /// Font preview sample text.
  ///
  /// In en, this message translates to:
  /// **'There is only one place in northern Sumatra where orangutans, rhinos, elephants, and tigers share the same natural habitat. Guess the name of the National Park?'**
  String get documentFontSampleB;

  /// Font preview sample text. Keep the URL github.com/nahpu/nahpu/issues unchanged. The pangram reference may be adapted to a local pangram.
  ///
  /// In en, this message translates to:
  /// **'Feeling creative or inspired? Send the maintainer your thoughts, an interesting biodiversity fact, a field joke, or a short story worth reading, or post it at github.com/nahpu/nahpu/issues, and it may show up right here. A font choice should not be decided by a quick brown fox jumping over a lazy dog.'**
  String get documentFontSampleC;

  /// Label above a font sample shown in bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get documentFontBold;

  /// Label above a font sample shown in italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get documentFontItalic;

  /// Name shown for a custom field.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get fieldEditorLabel;

  /// Data type of a custom field.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get fieldEditorType;

  /// No description provided for @fieldEditorCatalogApplicability.
  ///
  /// In en, this message translates to:
  /// **'Catalog applicability'**
  String get fieldEditorCatalogApplicability;

  /// No description provided for @fieldEditorCurrentCatalogOnly.
  ///
  /// In en, this message translates to:
  /// **'Current catalog only ({catalog})'**
  String fieldEditorCurrentCatalogOnly(String catalog);

  /// Choices of a dropdown custom field.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get fieldEditorOptions;

  /// No description provided for @fieldEditorOptionsHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter one option per line.'**
  String get fieldEditorOptionsHelper;

  /// No description provided for @fieldEditorMapToDwc.
  ///
  /// In en, this message translates to:
  /// **'Map to Darwin Core'**
  String get fieldEditorMapToDwc;

  /// No description provided for @fieldEditorDwcOfficialTerms.
  ///
  /// In en, this message translates to:
  /// **'Official terms {version}'**
  String fieldEditorDwcOfficialTerms(String version);

  /// Darwin Core (DWC) class the custom field maps to.
  ///
  /// In en, this message translates to:
  /// **'DWC target'**
  String get fieldEditorDwcTarget;

  /// No description provided for @fieldEditorDwcMappingMode.
  ///
  /// In en, this message translates to:
  /// **'Mapping mode'**
  String get fieldEditorDwcMappingMode;

  /// No description provided for @fieldEditorDwcDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct field'**
  String get fieldEditorDwcDirect;

  /// No description provided for @fieldEditorDwcAssertion.
  ///
  /// In en, this message translates to:
  /// **'Repeatable measurement / fact'**
  String get fieldEditorDwcAssertion;

  /// Darwin Core (DWC) term the custom field maps to.
  ///
  /// In en, this message translates to:
  /// **'DWC field'**
  String get fieldEditorDwcField;

  /// No description provided for @fieldEditorDwcAllowConflict.
  ///
  /// In en, this message translates to:
  /// **'I understand duplicate values'**
  String get fieldEditorDwcAllowConflict;

  /// No description provided for @fieldEditorDwcAllowConflictNote.
  ///
  /// In en, this message translates to:
  /// **'Conflicting scalar values will be joined with “ | ”.'**
  String get fieldEditorDwcAllowConflictNote;

  /// No description provided for @fieldEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit custom field'**
  String get fieldEditorEditTitle;

  /// No description provided for @fieldEditorAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add custom field to {section}'**
  String fieldEditorAddTitle(String section);

  /// No description provided for @documentFileSettings.
  ///
  /// In en, this message translates to:
  /// **'File Settings'**
  String get documentFileSettings;

  /// No description provided for @documentFileFormat.
  ///
  /// In en, this message translates to:
  /// **'File format'**
  String get documentFileFormat;

  /// No description provided for @documentFileBundleFormat.
  ///
  /// In en, this message translates to:
  /// **'Bundle format'**
  String get documentFileBundleFormat;

  /// No description provided for @documentFileDwcDpZipNote.
  ///
  /// In en, this message translates to:
  /// **'ZIP is provided for compatibility. TAR.GZ is the standards-oriented DwC-DP option.'**
  String get documentFileDwcDpZipNote;

  /// No description provided for @documentFileFormatCsv.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated (.csv)'**
  String get documentFileFormatCsv;

  /// No description provided for @documentFileFormatTsv.
  ///
  /// In en, this message translates to:
  /// **'Tab-separated (.tsv)'**
  String get documentFileFormatTsv;

  /// No description provided for @documentFileFormatExcel.
  ///
  /// In en, this message translates to:
  /// **'Excel (.xlsx)'**
  String get documentFileFormatExcel;

  /// No description provided for @documentFileFormatJson.
  ///
  /// In en, this message translates to:
  /// **'JSON (.json)'**
  String get documentFileFormatJson;

  /// error is the raw exception text.
  ///
  /// In en, this message translates to:
  /// **'Error generating PDF:\n{error}'**
  String documentPreviewPdfError(String error);

  /// No description provided for @documentPreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No preview available.'**
  String get documentPreviewUnavailable;

  /// No description provided for @documentPreviewNotGenerated.
  ///
  /// In en, this message translates to:
  /// **'Preview has not been generated.'**
  String get documentPreviewNotGenerated;

  /// No description provided for @documentPreviewNoLayout.
  ///
  /// In en, this message translates to:
  /// **'No layout loaded.'**
  String get documentPreviewNoLayout;

  /// No description provided for @documentPreviewUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update preview'**
  String get documentPreviewUpdate;

  /// No description provided for @documentPreviewGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate preview'**
  String get documentPreviewGenerate;

  /// No description provided for @documentPreviewOptionsChanged.
  ///
  /// In en, this message translates to:
  /// **'Preview options changed'**
  String get documentPreviewOptionsChanged;

  /// No description provided for @documentPreviewPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String documentPreviewPageOf(int current, int total);

  /// Button that restores the default table columns.
  ///
  /// In en, this message translates to:
  /// **'Defaults'**
  String get documentColumnsDefaults;

  /// No description provided for @documentColumnsSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{Selected {selected} of 1 column} other{Selected {selected} of {total} columns}}'**
  String documentColumnsSelectedCount(int selected, int total);

  /// No description provided for @documentPartFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter specimen parts'**
  String get documentPartFilterTitle;

  /// No description provided for @documentPartFilterNote.
  ///
  /// In en, this message translates to:
  /// **'Filters change the list only. Selected parts remain included in the export until you change the selection.'**
  String get documentPartFilterNote;

  /// No description provided for @documentPartFilterTypes.
  ///
  /// In en, this message translates to:
  /// **'Part types'**
  String get documentPartFilterTypes;

  /// No description provided for @documentPartFilterTypesHint.
  ///
  /// In en, this message translates to:
  /// **'Leave all unchecked to include every type.'**
  String get documentPartFilterTypesHint;

  /// No description provided for @documentPartFilterNumberRange.
  ///
  /// In en, this message translates to:
  /// **'Number range'**
  String get documentPartFilterNumberRange;

  /// Specimen number assigned in the field, not a form field.
  ///
  /// In en, this message translates to:
  /// **'Field number'**
  String get documentPartFilterFieldNumber;

  /// No description provided for @documentPartFilterProjectNumber.
  ///
  /// In en, this message translates to:
  /// **'Project number'**
  String get documentPartFilterProjectNumber;

  /// Lower bound of a number range.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get documentPartFilterFrom;

  /// Upper bound of a number range.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get documentPartFilterTo;

  /// No description provided for @documentPartFilterRangeHint.
  ///
  /// In en, this message translates to:
  /// **'Includes both endpoints. Leave either end blank for no limit.'**
  String get documentPartFilterRangeHint;

  /// No description provided for @documentPartFilterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get documentPartFilterReset;

  /// No description provided for @documentPartFilterInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a non-negative whole number.'**
  String get documentPartFilterInvalidNumber;

  /// No description provided for @documentPartFilterFromAfterTo.
  ///
  /// In en, this message translates to:
  /// **'From must be less than or equal to To.'**
  String get documentPartFilterFromAfterTo;

  /// error is the raw exception text.
  ///
  /// In en, this message translates to:
  /// **'Unable to load parts: {error}'**
  String documentPartsLoadError(String error);

  /// No description provided for @documentPartsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search parts or specimen numbers'**
  String get documentPartsSearch;

  /// No description provided for @documentPartFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Filter specimen parts (active)'**
  String get documentPartFilterActive;

  /// No description provided for @documentPartsSummary.
  ///
  /// In en, this message translates to:
  /// **'Showing {shown} of {total, plural, =1{1 part} other{{total} parts}} · Selected {selected}'**
  String documentPartsSummary(int shown, int total, int selected);

  /// hidden counts selected parts that the current filter hides.
  ///
  /// In en, this message translates to:
  /// **'Showing {shown} of {total, plural, =1{1 part} other{{total} parts}} · Selected {selected} ({hidden} hidden)'**
  String documentPartsSummaryHidden(
    int shown,
    int total,
    int selected,
    int hidden,
  );

  /// No description provided for @documentPartsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No specimen parts found'**
  String get documentPartsEmpty;

  /// Title for a specimen part with no tissue or barcode ID; id is its database ID.
  ///
  /// In en, this message translates to:
  /// **'Part {id}'**
  String documentPartFallbackTitle(String id);

  /// No description provided for @documentPartFieldNumber.
  ///
  /// In en, this message translates to:
  /// **'Field no. {number}'**
  String documentPartFieldNumber(String number);

  /// No description provided for @documentPartProjectNumber.
  ///
  /// In en, this message translates to:
  /// **'Project no. {number}'**
  String documentPartProjectNumber(String number);

  /// Museum catalog number of a specimen.
  ///
  /// In en, this message translates to:
  /// **'Catalog {number}'**
  String documentPartCatalog(String number);

  /// No description provided for @documentPartSpecimenFallback.
  ///
  /// In en, this message translates to:
  /// **'Specimen {uuid}'**
  String documentPartSpecimenFallback(String uuid);

  /// Button that clears the record selection.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get documentSelectionClearAll;

  /// No description provided for @documentSpecimenSearch.
  ///
  /// In en, this message translates to:
  /// **'Search Field No, Collector, Species...'**
  String get documentSpecimenSearch;

  /// Chip label for an active collection date filter. Dates are ISO dates.
  ///
  /// In en, this message translates to:
  /// **'Coll: {start} - {end}'**
  String documentSpecimenCollectedRange(String start, String end);

  /// No description provided for @documentSpecimenCollectionDate.
  ///
  /// In en, this message translates to:
  /// **'Collection Date'**
  String get documentSpecimenCollectionDate;

  /// Chip label for an active preparation date filter. Dates are ISO dates.
  ///
  /// In en, this message translates to:
  /// **'Prep: {start} - {end}'**
  String documentSpecimenPreparedRange(String start, String end);

  /// Specimen preparation date filter.
  ///
  /// In en, this message translates to:
  /// **'Prep Date'**
  String get documentSpecimenPrepDate;

  /// No description provided for @documentSelectionSelectedOf.
  ///
  /// In en, this message translates to:
  /// **'Selected {selected} of {total}'**
  String documentSelectionSelectedOf(int selected, int total);

  /// No description provided for @documentSpecimenSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select specimens'**
  String get documentSpecimenSelectTitle;

  /// No description provided for @documentSelectSitePreview.
  ///
  /// In en, this message translates to:
  /// **'Select Site for Preview'**
  String get documentSelectSitePreview;

  /// No description provided for @documentSelectSitesPreview.
  ///
  /// In en, this message translates to:
  /// **'Select Sites for Preview'**
  String get documentSelectSitesPreview;

  /// No description provided for @documentSelectSites.
  ///
  /// In en, this message translates to:
  /// **'Select sites'**
  String get documentSelectSites;

  /// No description provided for @documentSelectEventPreview.
  ///
  /// In en, this message translates to:
  /// **'Select Event for Preview'**
  String get documentSelectEventPreview;

  /// No description provided for @documentSelectEventsPreview.
  ///
  /// In en, this message translates to:
  /// **'Select Events for Preview'**
  String get documentSelectEventsPreview;

  /// No description provided for @documentSelectEvents.
  ///
  /// In en, this message translates to:
  /// **'Select events'**
  String get documentSelectEvents;

  /// No description provided for @documentSelectNarrativePreview.
  ///
  /// In en, this message translates to:
  /// **'Select Narrative for Preview'**
  String get documentSelectNarrativePreview;

  /// No description provided for @documentSelectNarrativesPreview.
  ///
  /// In en, this message translates to:
  /// **'Select Narratives for Preview'**
  String get documentSelectNarrativesPreview;

  /// No description provided for @documentSelectNarratives.
  ///
  /// In en, this message translates to:
  /// **'Select narratives'**
  String get documentSelectNarratives;

  /// No description provided for @documentSiteSearch.
  ///
  /// In en, this message translates to:
  /// **'Search site ID, locality...'**
  String get documentSiteSearch;

  /// No description provided for @documentSelectionClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get documentSelectionClearSearch;

  /// No description provided for @documentSitesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sites found'**
  String get documentSitesEmpty;

  /// No description provided for @documentSiteUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Site'**
  String get documentSiteUnnamed;

  /// No description provided for @documentSiteNoLocality.
  ///
  /// In en, this message translates to:
  /// **'No locality details'**
  String get documentSiteNoLocality;

  /// error is the raw exception text.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String documentSelectionLoadError(String error);

  /// No description provided for @documentEventSearch.
  ///
  /// In en, this message translates to:
  /// **'Search event ID, method...'**
  String get documentEventSearch;

  /// No description provided for @documentEventsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get documentEventsEmpty;

  /// No description provided for @documentEventFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Event ID: {id}'**
  String documentEventFallbackTitle(String id);

  /// No description provided for @documentEventNoMethod.
  ///
  /// In en, this message translates to:
  /// **'No method'**
  String get documentEventNoMethod;

  /// No description provided for @documentSelectionNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get documentSelectionNoDate;

  /// No description provided for @documentNarrativeSearch.
  ///
  /// In en, this message translates to:
  /// **'Search date, content...'**
  String get documentNarrativeSearch;

  /// No description provided for @documentNarrativesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No narratives found'**
  String get documentNarrativesEmpty;

  /// No description provided for @documentNarrativeNoText.
  ///
  /// In en, this message translates to:
  /// **'No text'**
  String get documentNarrativeNoText;

  /// No description provided for @documentRecordsSpecimens.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get documentRecordsSpecimens;

  /// No description provided for @documentRecordsSites.
  ///
  /// In en, this message translates to:
  /// **'Sites'**
  String get documentRecordsSites;

  /// No description provided for @documentRecordsEvents.
  ///
  /// In en, this message translates to:
  /// **'Collecting Events'**
  String get documentRecordsEvents;

  /// No description provided for @documentRecordsNarratives.
  ///
  /// In en, this message translates to:
  /// **'Narratives'**
  String get documentRecordsNarratives;

  /// No description provided for @documentRecordsGeneric.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get documentRecordsGeneric;

  /// No description provided for @documentSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} selected'**
  String documentSelectedCount(int selected, int total);

  /// No description provided for @documentPageSizeLetter.
  ///
  /// In en, this message translates to:
  /// **'US Letter (8.5 x 11 in)'**
  String get documentPageSizeLetter;

  /// No description provided for @documentPageSizeLegal.
  ///
  /// In en, this message translates to:
  /// **'US Legal'**
  String get documentPageSizeLegal;

  /// Custom page size.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get documentPageSizeCustom;

  /// No description provided for @documentOrientationPortrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get documentOrientationPortrait;

  /// No description provided for @documentOrientationLandscape.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get documentOrientationLandscape;

  /// No description provided for @documentOverrideBlocks.
  ///
  /// In en, this message translates to:
  /// **'Override template blocks'**
  String get documentOverrideBlocks;

  /// No description provided for @documentTemplateBlocks.
  ///
  /// In en, this message translates to:
  /// **'Template blocks'**
  String get documentTemplateBlocks;

  /// No description provided for @documentAddBlock.
  ///
  /// In en, this message translates to:
  /// **'Add Block'**
  String get documentAddBlock;

  /// No description provided for @documentMultiBlockMode.
  ///
  /// In en, this message translates to:
  /// **'Multiple blocks mode'**
  String get documentMultiBlockMode;

  /// No description provided for @documentMultiBlockContinuous.
  ///
  /// In en, this message translates to:
  /// **'Continuous (Block-by-block)'**
  String get documentMultiBlockContinuous;

  /// No description provided for @documentMultiBlockAlternate.
  ///
  /// In en, this message translates to:
  /// **'Alternate (Record-by-record)'**
  String get documentMultiBlockAlternate;

  /// No description provided for @documentBlockNumber.
  ///
  /// In en, this message translates to:
  /// **'Block #{number}'**
  String documentBlockNumber(int number);

  /// No description provided for @documentShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get documentShowLess;

  /// No description provided for @documentShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get documentShowMore;

  /// No description provided for @documentDeleteBlock.
  ///
  /// In en, this message translates to:
  /// **'Delete Block'**
  String get documentDeleteBlock;

  /// No description provided for @documentBlockTemplate.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get documentBlockTemplate;

  /// No description provided for @documentTemplateMissing.
  ///
  /// In en, this message translates to:
  /// **'This template no longer exists'**
  String get documentTemplateMissing;

  /// Shown for a template or field that no longer exists.
  ///
  /// In en, this message translates to:
  /// **'Missing: {name}'**
  String documentMissingItem(String name);

  /// No description provided for @documentEditTemplate.
  ///
  /// In en, this message translates to:
  /// **'Edit template'**
  String get documentEditTemplate;

  /// No description provided for @documentBlockCopies.
  ///
  /// In en, this message translates to:
  /// **'Copies'**
  String get documentBlockCopies;

  /// No description provided for @documentBlockRows.
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get documentBlockRows;

  /// Short for columns, a narrow number field label.
  ///
  /// In en, this message translates to:
  /// **'Cols'**
  String get documentBlockCols;

  /// No description provided for @documentAutoFillPage.
  ///
  /// In en, this message translates to:
  /// **'Auto-fill page'**
  String get documentAutoFillPage;

  /// No description provided for @documentTemplatePadding.
  ///
  /// In en, this message translates to:
  /// **'Template padding (mm)'**
  String get documentTemplatePadding;

  /// No description provided for @documentPaddingTop.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get documentPaddingTop;

  /// No description provided for @documentPaddingLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get documentPaddingLeft;

  /// No description provided for @documentPaddingRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get documentPaddingRight;

  /// No description provided for @documentPaddingBottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get documentPaddingBottom;

  /// No description provided for @documentPageBreakAfter.
  ///
  /// In en, this message translates to:
  /// **'Page break after'**
  String get documentPageBreakAfter;

  /// No description provided for @documentPageBreakAfterHint.
  ///
  /// In en, this message translates to:
  /// **'Insert page break after this block'**
  String get documentPageBreakAfterHint;

  /// No description provided for @documentCurrentProjectSelection.
  ///
  /// In en, this message translates to:
  /// **'Current Project Selection'**
  String get documentCurrentProjectSelection;

  /// No description provided for @documentActiveProjectDocument.
  ///
  /// In en, this message translates to:
  /// **'1 document (active project)'**
  String get documentActiveProjectDocument;

  /// No description provided for @documentSelectionSpecimens.
  ///
  /// In en, this message translates to:
  /// **'Specimens Selection'**
  String get documentSelectionSpecimens;

  /// No description provided for @documentSelectionSpecimenParts.
  ///
  /// In en, this message translates to:
  /// **'Specimen Parts Selection'**
  String get documentSelectionSpecimenParts;

  /// No description provided for @documentSelectionSites.
  ///
  /// In en, this message translates to:
  /// **'Sites Selection'**
  String get documentSelectionSites;

  /// No description provided for @documentSelectionEvents.
  ///
  /// In en, this message translates to:
  /// **'Collecting Events Selection'**
  String get documentSelectionEvents;

  /// No description provided for @documentSelectionNarratives.
  ///
  /// In en, this message translates to:
  /// **'Narratives Selection'**
  String get documentSelectionNarratives;

  /// Sort direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get documentSortDirection;

  /// No description provided for @documentSortAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get documentSortAscending;

  /// No description provided for @documentSortDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get documentSortDescending;

  /// No description provided for @documentSortFieldsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load ordering fields'**
  String get documentSortFieldsLoadError;

  /// No description provided for @documentSortOriginalOrder.
  ///
  /// In en, this message translates to:
  /// **'Original order'**
  String get documentSortOriginalOrder;

  /// No description provided for @documentSortOrderBy.
  ///
  /// In en, this message translates to:
  /// **'Order by'**
  String get documentSortOrderBy;

  /// No description provided for @documentSortOrderRecordsBy.
  ///
  /// In en, this message translates to:
  /// **'Order records by'**
  String get documentSortOrderRecordsBy;

  /// No description provided for @documentSortClosePicker.
  ///
  /// In en, this message translates to:
  /// **'Close order field picker'**
  String get documentSortClosePicker;

  /// No description provided for @documentSortFieldUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{table} · Not available for this template'**
  String documentSortFieldUnavailable(String table);

  /// No description provided for @documentFieldCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 field} other{{count} fields}}'**
  String documentFieldCount(int count);

  /// No description provided for @documentLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Layout'**
  String get documentLayoutTitle;

  /// No description provided for @documentLayoutProfile.
  ///
  /// In en, this message translates to:
  /// **'Layout profile'**
  String get documentLayoutProfile;

  /// No description provided for @documentLayoutProfileHelper.
  ///
  /// In en, this message translates to:
  /// **'Page settings and template blocks are set by the profile.'**
  String get documentLayoutProfileHelper;

  /// No description provided for @documentManagePresets.
  ///
  /// In en, this message translates to:
  /// **'Manage presets'**
  String get documentManagePresets;

  /// No description provided for @documentPageSetup.
  ///
  /// In en, this message translates to:
  /// **'Page Setup'**
  String get documentPageSetup;

  /// No description provided for @documentPageSize.
  ///
  /// In en, this message translates to:
  /// **'Page size'**
  String get documentPageSize;

  /// No description provided for @documentPageWidthMm.
  ///
  /// In en, this message translates to:
  /// **'Width mm'**
  String get documentPageWidthMm;

  /// No description provided for @documentPageHeightMm.
  ///
  /// In en, this message translates to:
  /// **'Height mm'**
  String get documentPageHeightMm;

  /// No description provided for @documentOrientation.
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get documentOrientation;

  /// No description provided for @documentPagePadding.
  ///
  /// In en, this message translates to:
  /// **'Page padding (mm)'**
  String get documentPagePadding;

  /// No description provided for @documentSelectSpecimenParts.
  ///
  /// In en, this message translates to:
  /// **'Select specimen parts'**
  String get documentSelectSpecimenParts;

  /// Catalog format (taxon discipline).
  ///
  /// In en, this message translates to:
  /// **'Ornithology'**
  String get labelCatalogFormatOrnithology;

  /// Catalog format (taxon discipline).
  ///
  /// In en, this message translates to:
  /// **'Mammalogy'**
  String get labelCatalogFormatMammalogy;

  /// Catalog format (taxon discipline).
  ///
  /// In en, this message translates to:
  /// **'Herpetology'**
  String get labelCatalogFormatHerpetology;

  /// Catalog format (taxon discipline).
  ///
  /// In en, this message translates to:
  /// **'Invertebrate zoology'**
  String get labelCatalogFormatInvertebrateZoology;

  /// Catalog format (taxon discipline).
  ///
  /// In en, this message translates to:
  /// **'Ichthyology'**
  String get labelCatalogFormatIchthyology;

  /// Taxon group filter for specimen records.
  ///
  /// In en, this message translates to:
  /// **'All taxa'**
  String get labelSpecimenRecordTypeAllTaxa;

  /// Taxon group filter for specimen records.
  ///
  /// In en, this message translates to:
  /// **'Birds'**
  String get labelSpecimenRecordTypeBirds;

  /// Taxon group filter for specimen records.
  ///
  /// In en, this message translates to:
  /// **'Mammals'**
  String get labelSpecimenRecordTypeMammals;

  /// Taxon group filter for specimen records.
  ///
  /// In en, this message translates to:
  /// **'Herpetofauna'**
  String get labelSpecimenRecordTypeHerpetofauna;

  /// Taxon group filter for specimen records.
  ///
  /// In en, this message translates to:
  /// **'Invertebrates'**
  String get labelSpecimenRecordTypeInvertebrates;

  /// Taxon group filter for specimen records.
  ///
  /// In en, this message translates to:
  /// **'Fishes'**
  String get labelSpecimenRecordTypeFishes;

  /// Group of project dashboard tools.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get labelProjectToolCategoryUtilities;

  /// Group of project dashboard tools.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get labelProjectToolCategoryProject;

  /// Group of project dashboard tools.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get labelProjectToolCategoryRecords;

  /// Group of project dashboard tools.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get labelProjectToolCategoryDatabase;

  /// Group of project dashboard tools.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get labelProjectToolCategoryConfiguration;

  /// Project dashboard tool.
  ///
  /// In en, this message translates to:
  /// **'Data table'**
  String get labelProjectToolDataTable;

  /// No description provided for @labelProjectToolDataTableDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse, sort, and search project records'**
  String get labelProjectToolDataTableDescription;

  /// Project dashboard tool.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get labelProjectToolTemplates;

  /// No description provided for @labelProjectToolTemplatesDescription.
  ///
  /// In en, this message translates to:
  /// **'Create and edit document templates'**
  String get labelProjectToolTemplatesDescription;

  /// Project dashboard tool.
  ///
  /// In en, this message translates to:
  /// **'Merge project'**
  String get labelProjectToolMergeProject;

  /// No description provided for @labelProjectToolMergeProjectDescription.
  ///
  /// In en, this message translates to:
  /// **'Merge another project into this one'**
  String get labelProjectToolMergeProjectDescription;

  /// Project dashboard tool.
  ///
  /// In en, this message translates to:
  /// **'Export project'**
  String get labelProjectToolExportProject;

  /// No description provided for @labelProjectToolExportProjectDescription.
  ///
  /// In en, this message translates to:
  /// **'Export this project for transfer'**
  String get labelProjectToolExportProjectDescription;

  /// Project dashboard tool.
  ///
  /// In en, this message translates to:
  /// **'Batch import'**
  String get labelProjectToolBatchImport;

  /// No description provided for @labelProjectToolBatchImportDescription.
  ///
  /// In en, this message translates to:
  /// **'Import or update records from a spreadsheet'**
  String get labelProjectToolBatchImportDescription;

  /// Project dashboard tool.
  ///
  /// In en, this message translates to:
  /// **'Curation'**
  String get labelProjectToolCuration;

  /// No description provided for @labelProjectToolCurationDescription.
  ///
  /// In en, this message translates to:
  /// **'Specimen curation: scan tissues into storage boxes'**
  String get labelProjectToolCurationDescription;

  /// Project dashboard tool.
  ///
  /// In en, this message translates to:
  /// **'Bundle records'**
  String get labelProjectToolBundleRecords;

  /// No description provided for @labelProjectToolBundleRecordsDescription.
  ///
  /// In en, this message translates to:
  /// **'Bundle records with their media'**
  String get labelProjectToolBundleRecordsDescription;

  /// Project dashboard tool.
  ///
  /// In en, this message translates to:
  /// **'Export records'**
  String get labelProjectToolExportRecords;

  /// No description provided for @labelProjectToolExportRecordsDescription.
  ///
  /// In en, this message translates to:
  /// **'Export records as tabular data'**
  String get labelProjectToolExportRecordsDescription;

  /// Project dashboard tool.
  ///
  /// In en, this message translates to:
  /// **'Export documents'**
  String get labelProjectToolExportDocuments;

  /// No description provided for @labelProjectToolExportDocumentsDescription.
  ///
  /// In en, this message translates to:
  /// **'Export records as documents'**
  String get labelProjectToolExportDocumentsDescription;

  /// No description provided for @labelProjectToolBackupDatabaseDescription.
  ///
  /// In en, this message translates to:
  /// **'Back up the application database'**
  String get labelProjectToolBackupDatabaseDescription;

  /// No description provided for @labelProjectToolSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Open application settings'**
  String get labelProjectToolSettingsDescription;

  /// Project dashboard tool.
  ///
  /// In en, this message translates to:
  /// **'Export configs'**
  String get labelProjectToolExportConfigs;

  /// Project dashboard tool.
  ///
  /// In en, this message translates to:
  /// **'Import configs'**
  String get labelProjectToolImportConfigs;

  /// Map base layer option: no base layer.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get labelBasemapNone;

  /// No description provided for @labelBasemapNoneDescription.
  ///
  /// In en, this message translates to:
  /// **'No geographic base layer'**
  String get labelBasemapNoneDescription;

  /// Map base layer option.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get labelBasemapAutomatic;

  /// Positron is a map style name; Dark must match labelBasemapDark.
  ///
  /// In en, this message translates to:
  /// **'Positron in light mode and Dark in dark mode'**
  String get labelBasemapAutomaticDescription;

  /// Natural Earth is a dataset name.
  ///
  /// In en, this message translates to:
  /// **'Natural Earth (Offline)'**
  String get labelBasemapNaturalEarthOffline;

  /// No description provided for @labelBasemapNaturalEarthOfflineDescription.
  ///
  /// In en, this message translates to:
  /// **'Bundled country boundaries that work without internet access'**
  String get labelBasemapNaturalEarthOfflineDescription;

  /// No description provided for @labelBasemapPositronDescription.
  ///
  /// In en, this message translates to:
  /// **'Minimal, low-contrast light map'**
  String get labelBasemapPositronDescription;

  /// No description provided for @labelBasemapBrightDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed map with bright colors'**
  String get labelBasemapBrightDescription;

  /// No description provided for @labelBasemapLibertyDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed map with balanced colors'**
  String get labelBasemapLibertyDescription;

  /// Map base layer style for low light.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get labelBasemapDark;

  /// No description provided for @labelBasemapDarkDescription.
  ///
  /// In en, this message translates to:
  /// **'Dark map for low-light use'**
  String get labelBasemapDarkDescription;

  /// Custom map layer type.
  ///
  /// In en, this message translates to:
  /// **'Raster tiles'**
  String get labelMapLayerKindRasterTiles;

  /// Custom map layer type.
  ///
  /// In en, this message translates to:
  /// **'Vector tiles'**
  String get labelMapLayerKindVectorTiles;

  /// Custom map layer type.
  ///
  /// In en, this message translates to:
  /// **'Elevation model'**
  String get labelMapLayerKindElevationModel;

  /// Form section a custom field is shown in.
  ///
  /// In en, this message translates to:
  /// **'Specimen Attributes'**
  String get labelFieldSectionSpecimenAttributes;

  /// Form section a custom field is shown in.
  ///
  /// In en, this message translates to:
  /// **'Site Attributes'**
  String get labelFieldSectionSiteAttributes;

  /// Form section a custom field is shown in.
  ///
  /// In en, this message translates to:
  /// **'Environmental Data'**
  String get labelFieldSectionEnvironmentalData;

  /// Form section a custom field is shown in.
  ///
  /// In en, this message translates to:
  /// **'Specimen Part'**
  String get labelFieldSectionSpecimenPart;

  /// Form section a custom field is shown in.
  ///
  /// In en, this message translates to:
  /// **'Parasite'**
  String get labelFieldSectionParasite;

  /// Site geography field.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get labelSiteGeographyCountry;

  /// Site geography field.
  ///
  /// In en, this message translates to:
  /// **'Island group'**
  String get labelSiteGeographyIslandGroup;

  /// Site geography field.
  ///
  /// In en, this message translates to:
  /// **'State/Province'**
  String get labelSiteGeographyStateProvince;

  /// Site geography field (second-level administrative area).
  ///
  /// In en, this message translates to:
  /// **'County/Parish/District'**
  String get labelSiteGeographyCounty;

  /// Site geography field.
  ///
  /// In en, this message translates to:
  /// **'Municipality/City/Town'**
  String get labelSiteGeographyMunicipality;

  /// No description provided for @labelEnvironmentalLowestDayTemp.
  ///
  /// In en, this message translates to:
  /// **'Day lowest temperature'**
  String get labelEnvironmentalLowestDayTemp;

  /// No description provided for @labelEnvironmentalHighestDayTemp.
  ///
  /// In en, this message translates to:
  /// **'Day highest temperature'**
  String get labelEnvironmentalHighestDayTemp;

  /// No description provided for @labelEnvironmentalLowestNightTemp.
  ///
  /// In en, this message translates to:
  /// **'Night lowest temperature'**
  String get labelEnvironmentalLowestNightTemp;

  /// No description provided for @labelEnvironmentalHighestNightTemp.
  ///
  /// In en, this message translates to:
  /// **'Night highest temperature'**
  String get labelEnvironmentalHighestNightTemp;

  /// No description provided for @labelEnvironmentalAverageHumidity.
  ///
  /// In en, this message translates to:
  /// **'Average humidity'**
  String get labelEnvironmentalAverageHumidity;

  /// No description provided for @labelEnvironmentalDewPoint.
  ///
  /// In en, this message translates to:
  /// **'Dew point'**
  String get labelEnvironmentalDewPoint;

  /// No description provided for @labelEnvironmentalCloudCover.
  ///
  /// In en, this message translates to:
  /// **'Cloud cover'**
  String get labelEnvironmentalCloudCover;

  /// No description provided for @labelEnvironmentalRainfall.
  ///
  /// In en, this message translates to:
  /// **'Rainfall'**
  String get labelEnvironmentalRainfall;

  /// No description provided for @labelEnvironmentalAmbientTemperature.
  ///
  /// In en, this message translates to:
  /// **'Ambient temperature'**
  String get labelEnvironmentalAmbientTemperature;

  /// No description provided for @labelEnvironmentalAmbientHumidity.
  ///
  /// In en, this message translates to:
  /// **'Ambient humidity'**
  String get labelEnvironmentalAmbientHumidity;

  /// No description provided for @labelEnvironmentalWaterTemperature.
  ///
  /// In en, this message translates to:
  /// **'Water temperature'**
  String get labelEnvironmentalWaterTemperature;

  /// No description provided for @labelEnvironmentalDissolvedOxygen.
  ///
  /// In en, this message translates to:
  /// **'Dissolved oxygen'**
  String get labelEnvironmentalDissolvedOxygen;

  /// No description provided for @labelEnvironmentalDissolvedOxygenSaturation.
  ///
  /// In en, this message translates to:
  /// **'Dissolved oxygen saturation'**
  String get labelEnvironmentalDissolvedOxygenSaturation;

  /// No description provided for @labelEnvironmentalConductivity.
  ///
  /// In en, this message translates to:
  /// **'Conductivity'**
  String get labelEnvironmentalConductivity;

  /// No description provided for @labelEnvironmentalFlowVelocity.
  ///
  /// In en, this message translates to:
  /// **'Flow velocity'**
  String get labelEnvironmentalFlowVelocity;

  /// No description provided for @labelEnvironmentalSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get labelEnvironmentalSunrise;

  /// No description provided for @labelEnvironmentalSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get labelEnvironmentalSunset;

  /// No description provided for @labelEnvironmentalMoonPhase.
  ///
  /// In en, this message translates to:
  /// **'Moon phase'**
  String get labelEnvironmentalMoonPhase;

  /// Free-text notes field of environmental data.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get labelEnvironmentalNotes;

  /// Environmental field label followed by its measurement unit.
  ///
  /// In en, this message translates to:
  /// **'{label} ({unit})'**
  String labelEnvironmentalWithUnit(String label, String unit);

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get labelTableProject;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get labelTableGeography;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get labelTableSite;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Site Attribute'**
  String get labelTableSiteAttribute;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Fossil Site'**
  String get labelTableFossilSite;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Coordinate'**
  String get labelTableCoordinate;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Coll Event'**
  String get labelTableCollEvent;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get labelTableEnvironment;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Coll Personnel'**
  String get labelTableCollPersonnel;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Coll Method'**
  String get labelTableCollMethod;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Narrative'**
  String get labelTableNarrative;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get labelTableMedia;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Narrative Media'**
  String get labelTableNarrativeMedia;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Site Media'**
  String get labelTableSiteMedia;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Event Media'**
  String get labelTableEventMedia;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Specimen Media'**
  String get labelTableSpecimenMedia;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Associated Data'**
  String get labelTableAssociatedData;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Specimen Associated Data'**
  String get labelTableSpecimenAssociatedData;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Site Associated Data'**
  String get labelTableSiteAssociatedData;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Event Associated Data'**
  String get labelTableEventAssociatedData;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Personnel List'**
  String get labelTablePersonnelList;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Personnel'**
  String get labelTablePersonnel;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Taxonomy'**
  String get labelTableTaxonomy;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Specimen'**
  String get labelTableSpecimen;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Mammal Attribute'**
  String get labelTableMammalAttribute;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Bird Attribute'**
  String get labelTableBirdAttribute;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Herp Attribute'**
  String get labelTableHerpAttribute;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Invertebrate Attribute'**
  String get labelTableInvertebrateAttribute;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Fish Attribute'**
  String get labelTableFishAttribute;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Fossil Attribute'**
  String get labelTableFossilAttribute;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Parasite Detection'**
  String get labelTableParasiteDetection;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Parasite'**
  String get labelTableParasite;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Specimen Part'**
  String get labelTableSpecimenPart;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Specimen Individual'**
  String get labelTableSpecimenIndividual;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Specimen Part Individual'**
  String get labelTableSpecimenPartIndividual;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Parasite Individual'**
  String get labelTableParasiteIndividual;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Custom Field Definition'**
  String get labelTableCustomFieldDefinition;

  /// Database table name shown in field pickers.
  ///
  /// In en, this message translates to:
  /// **'Custom Field Value'**
  String get labelTableCustomFieldValue;

  /// Number of files in a folder of the application-folder explorer.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file} other{{count} files}}'**
  String fileExplorerFileCount(int count);

  /// No description provided for @fileExplorerImageCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 image} other{{count} images}}'**
  String fileExplorerImageCount(int count);

  /// No description provided for @fileExplorerAudioCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 audio file} other{{count} audio files}}'**
  String fileExplorerAudioCount(int count);

  /// No description provided for @fileExplorerVideoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 video} other{{count} videos}}'**
  String fileExplorerVideoCount(int count);

  /// No description provided for @fileExplorerOtherCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 other file} other{{count} other files}}'**
  String fileExplorerOtherCount(int count);

  /// Tooltip naming why a file in the application folder cannot be removed.
  ///
  /// In en, this message translates to:
  /// **'Application database'**
  String get fileExplorerLockDatabase;

  /// Tooltip naming why a file in the application folder cannot be removed.
  ///
  /// In en, this message translates to:
  /// **'Database working file'**
  String get fileExplorerLockDatabaseSidecar;

  /// Tooltip naming why a file in the application folder cannot be removed.
  ///
  /// In en, this message translates to:
  /// **'Database backup'**
  String get fileExplorerLockBackup;

  /// Tooltip naming why a file in the application folder cannot be removed.
  ///
  /// In en, this message translates to:
  /// **'Custom fonts and map layers'**
  String get fileExplorerLockUserConfig;

  /// Tooltip naming why a file in the application folder cannot be removed.
  ///
  /// In en, this message translates to:
  /// **'Global template media'**
  String get fileExplorerLockTemplateMedia;

  /// Tooltip naming why a file in the application folder cannot be removed.
  ///
  /// In en, this message translates to:
  /// **'Linked to a media record'**
  String get fileExplorerLockMediaRecord;

  /// Tooltip naming why a file in the application folder cannot be removed.
  ///
  /// In en, this message translates to:
  /// **'Linked to a personnel photo'**
  String get fileExplorerLockPersonnelPhoto;

  /// Tooltip naming why a file in the application folder cannot be removed.
  ///
  /// In en, this message translates to:
  /// **'Linked to associated data'**
  String get fileExplorerLockAssociatedData;

  /// Tooltip naming why a file in the application folder cannot be removed.
  ///
  /// In en, this message translates to:
  /// **'A record points here but could not be read'**
  String get fileExplorerLockUnresolvedReference;

  /// Tooltip naming why a file in the application folder cannot be removed.
  ///
  /// In en, this message translates to:
  /// **'Changed just now, may still be copying'**
  String get fileExplorerLockRecentlyModified;

  /// Tooltip naming why a file in the application folder cannot be removed.
  ///
  /// In en, this message translates to:
  /// **'Not in a folder NAHPU manages'**
  String get fileExplorerLockUnmanagedLocation;

  /// Tooltip naming why a file in the application folder cannot be removed.
  ///
  /// In en, this message translates to:
  /// **'Folder of a project not in the database'**
  String get fileExplorerLockUnknownProject;

  /// Shown when removing unlinked files is disabled because some references could not be read.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 associated data record could not be read, so some files cannot be checked. Removing files is disabled until that is resolved.} other{{count} associated data records could not be read, so some files cannot be checked. Removing files is disabled until that is resolved.}}'**
  String fileExplorerPruneBlockedUnresolved(int count);

  /// No description provided for @fileExplorerPruneBlockedEmptyIndex.
  ///
  /// In en, this message translates to:
  /// **'The database reports no linked files at all, which usually means it is still opening. Reopen this screen before removing anything.'**
  String get fileExplorerPruneBlockedEmptyIndex;

  /// Stage name in the export, backup, or restore progress stepper.
  ///
  /// In en, this message translates to:
  /// **'Prepare backup'**
  String get progressPrepareBackup;

  /// Stage name in the export, backup, or restore progress stepper.
  ///
  /// In en, this message translates to:
  /// **'Copy media and files'**
  String get progressCopyMediaAndFiles;

  /// Stage name in the export, backup, or restore progress stepper.
  ///
  /// In en, this message translates to:
  /// **'Compress archive'**
  String get progressCompressArchive;

  /// Stage name in the export, backup, or restore progress stepper.
  ///
  /// In en, this message translates to:
  /// **'Extract archive'**
  String get progressExtractArchive;

  /// Stage name in the export, backup, or restore progress stepper.
  ///
  /// In en, this message translates to:
  /// **'Restore media and files'**
  String get progressRestoreMediaAndFiles;

  /// Stage name in the export, backup, or restore progress stepper.
  ///
  /// In en, this message translates to:
  /// **'Back up current data'**
  String get progressBackUpCurrentData;

  /// Stage name in the export, backup, or restore progress stepper.
  ///
  /// In en, this message translates to:
  /// **'Replace database'**
  String get progressReplaceDatabase;

  /// Stage name in the export, backup, or restore progress stepper.
  ///
  /// In en, this message translates to:
  /// **'Write records'**
  String get progressWriteRecords;

  /// Stage name in the export, backup, or restore progress stepper.
  ///
  /// In en, this message translates to:
  /// **'Copy media'**
  String get progressCopyMedia;

  /// Stage name in the export, backup, or restore progress stepper.
  ///
  /// In en, this message translates to:
  /// **'Check contents'**
  String get progressCheckContents;

  /// Stage name in the export, backup, or restore progress stepper.
  ///
  /// In en, this message translates to:
  /// **'Collect records'**
  String get progressCollectRecords;

  /// Stage name in the export, backup, or restore progress stepper.
  ///
  /// In en, this message translates to:
  /// **'Check records'**
  String get progressCheckRecords;

  /// Stage name in the export, backup, or restore progress stepper.
  ///
  /// In en, this message translates to:
  /// **'Write and compress package'**
  String get progressWriteAndCompressPackage;

  /// Stage name in the export, backup, or restore progress stepper.
  ///
  /// In en, this message translates to:
  /// **'Process media'**
  String get progressProcessMedia;

  /// No description provided for @serviceMessagePresetsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Added 1 preset} other{Added {count} presets}}'**
  String serviceMessagePresetsAdded(int count);

  /// No description provided for @serviceMessageNoDefaultPresets.
  ///
  /// In en, this message translates to:
  /// **'No default presets of this type'**
  String get serviceMessageNoDefaultPresets;

  /// No description provided for @serviceMessageDefaultPresetsLoaded.
  ///
  /// In en, this message translates to:
  /// **'Default presets are already loaded'**
  String get serviceMessageDefaultPresetsLoaded;

  /// Snackbar after importing a print layout file that also added templates.
  ///
  /// In en, this message translates to:
  /// **'Imported {count, plural, =1{1 preset} other{{count} presets}} and {templateCount, plural, =1{1 template} other{{templateCount} templates}}'**
  String serviceMessagePresetsAndTemplatesImported(
    int count,
    int templateCount,
  );

  /// Note in the preset export dialog.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 template uses images, which are referenced by name rather than stored in the file. On another installation those images have to be added again.} other{{count} templates use images, which are referenced by name rather than stored in the file. On another installation those images have to be added again.}}'**
  String serviceMessagePresetImageNote(int count);

  /// No description provided for @deletePersonnelCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 personnel} other{Delete {count} personnel}}'**
  String deletePersonnelCount(int count);

  /// No description provided for @deletePersonnelTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete personnel} other{Delete personnel}}'**
  String deletePersonnelTitle(int count);

  /// No description provided for @deletePersonnelBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Are you sure you want to delete the selected personnel?} other{Are you sure you want to delete the selected personnel?}}'**
  String deletePersonnelBody(int count);

  /// No description provided for @deleteTaxaCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 taxon} other{Delete {count} taxa}}'**
  String deleteTaxaCount(int count);

  /// No description provided for @deleteTaxaTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete taxon} other{Delete taxa}}'**
  String deleteTaxaTitle(int count);

  /// No description provided for @deleteTaxaBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Are you sure you want to delete the selected taxon?} other{Are you sure you want to delete the selected taxa?}}'**
  String deleteTaxaBody(int count);

  /// No description provided for @deleteCoordinatesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 coordinate} other{Delete {count} coordinates}}'**
  String deleteCoordinatesCount(int count);

  /// No description provided for @deleteCoordinatesTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete coordinate} other{Delete coordinates}}'**
  String deleteCoordinatesTitle(int count);

  /// No description provided for @deleteCoordinatesBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Are you sure you want to delete the selected coordinate?} other{Are you sure you want to delete the selected coordinates?}}'**
  String deleteCoordinatesBody(int count);

  /// No description provided for @deleteCollMethodsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 collection method} other{Delete {count} collection methods}}'**
  String deleteCollMethodsCount(int count);

  /// No description provided for @deleteCollMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete collection method} other{Delete collection methods}}'**
  String deleteCollMethodsTitle(int count);

  /// No description provided for @deleteCollMethodsBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Are you sure you want to delete the selected collection method?} other{Are you sure you want to delete the selected collection methods?}}'**
  String deleteCollMethodsBody(int count);

  /// No description provided for @deleteParasitesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 parasite} other{Delete {count} parasites}}'**
  String deleteParasitesCount(int count);

  /// No description provided for @deleteParasitesTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete parasite} other{Delete parasites}}'**
  String deleteParasitesTitle(int count);

  /// No description provided for @deleteParasitesBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Are you sure you want to delete the selected parasite?} other{Are you sure you want to delete the selected parasites?}}'**
  String deleteParasitesBody(int count);

  /// No description provided for @deleteSpecimenPartsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 specimen part} other{Delete {count} specimen parts}}'**
  String deleteSpecimenPartsCount(int count);

  /// No description provided for @deleteSpecimenPartsTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete specimen part} other{Delete specimen parts}}'**
  String deleteSpecimenPartsTitle(int count);

  /// No description provided for @deleteSpecimenPartsBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Are you sure you want to delete the selected specimen part?} other{Are you sure you want to delete the selected specimen parts?}}'**
  String deleteSpecimenPartsBody(int count);

  /// No description provided for @deleteAssociatedDataCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Remove 1 associated data entry} other{Remove {count} associated data entries}}'**
  String deleteAssociatedDataCount(int count);

  /// No description provided for @deleteAssociatedDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove associated data'**
  String get deleteAssociatedDataTitle;

  /// No description provided for @deleteAssociatedDataBody.
  ///
  /// In en, this message translates to:
  /// **'Remove the selected associated data from this record? Data shared with other records will be preserved.'**
  String get deleteAssociatedDataBody;

  /// No description provided for @removeProjectPersonnelCount.
  ///
  /// In en, this message translates to:
  /// **'Remove {count} personnel from project'**
  String removeProjectPersonnelCount(int count);

  /// No description provided for @removeProjectPersonnelTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove personnel'**
  String get removeProjectPersonnelTitle;

  /// No description provided for @removeProjectPersonnelBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the selected personnel from the project?'**
  String get removeProjectPersonnelBody;

  /// No description provided for @removeEventPersonnelCount.
  ///
  /// In en, this message translates to:
  /// **'Remove {count} personnel from event'**
  String removeEventPersonnelCount(int count);

  /// No description provided for @removeEventPersonnelTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove event personnel'**
  String get removeEventPersonnelTitle;

  /// No description provided for @removeEventPersonnelBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the selected personnel from this event?'**
  String get removeEventPersonnelBody;

  /// No description provided for @projectDeleteProject.
  ///
  /// In en, this message translates to:
  /// **'Delete project'**
  String get projectDeleteProject;

  /// No description provided for @projectDeleteProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete project?'**
  String get projectDeleteProjectTitle;

  /// No description provided for @projectDeleteProjectPrompt.
  ///
  /// In en, this message translates to:
  /// **'You will delete this project and its related data. This cannot be undone.'**
  String get projectDeleteProjectPrompt;

  /// No description provided for @projectNoProject.
  ///
  /// In en, this message translates to:
  /// **'No project'**
  String get projectNoProject;

  /// No description provided for @projectOverview.
  ///
  /// In en, this message translates to:
  /// **'Project overview'**
  String get projectOverview;

  /// No description provided for @projectOverviewLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed fetching data from the database. Check if the project name exists. {error}'**
  String projectOverviewLoadError(Object error);

  /// No description provided for @projectSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save project: {error}'**
  String projectSaveFailed(String error);

  /// No description provided for @projectDetails.
  ///
  /// In en, this message translates to:
  /// **'Project details'**
  String get projectDetails;

  /// The asterisk marks a required field.
  ///
  /// In en, this message translates to:
  /// **'Project name*'**
  String get projectNameLabel;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the project name (required)'**
  String get projectNameHint;

  /// No description provided for @projectDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Project description'**
  String get projectDescriptionLabel;

  /// No description provided for @projectDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a short project description'**
  String get projectDescriptionHint;

  /// No description provided for @projectPrincipalInvestigator.
  ///
  /// In en, this message translates to:
  /// **'Principal investigator'**
  String get projectPrincipalInvestigator;

  /// No description provided for @projectPrincipalInvestigatorHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the principal investigator'**
  String get projectPrincipalInvestigatorHint;

  /// Institutional accession number for the project's material.
  ///
  /// In en, this message translates to:
  /// **'Accession'**
  String get projectAccession;

  /// No description provided for @projectAccessionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter an institutional accession'**
  String get projectAccessionHint;

  /// No description provided for @projectPlaceAndTime.
  ///
  /// In en, this message translates to:
  /// **'Place and time'**
  String get projectPlaceAndTime;

  /// No description provided for @projectLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get projectLocation;

  /// No description provided for @projectLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the general project location'**
  String get projectLocationHint;

  /// No description provided for @projectTimeZoneNote.
  ///
  /// In en, this message translates to:
  /// **'NAHPU stores collection dates and times as entered in local field time. The project time zone records that context so exchanged data can be interpreted consistently by third-party collection management systems and other tools.'**
  String get projectTimeZoneNote;

  /// No description provided for @projectDates.
  ///
  /// In en, this message translates to:
  /// **'Project dates'**
  String get projectDates;

  /// No description provided for @projectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get projectStartDate;

  /// No description provided for @projectEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get projectEndDate;

  /// No description provided for @projectChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get projectChooseDate;

  /// No description provided for @projectClearField.
  ///
  /// In en, this message translates to:
  /// **'Clear {label}'**
  String projectClearField(String label);

  /// No description provided for @projectTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get projectTimeZone;

  /// No description provided for @projectChooseTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Choose a time zone'**
  String get projectChooseTimeZone;

  /// No description provided for @projectTimeZoneUtc.
  ///
  /// In en, this message translates to:
  /// **'(UTC) Coordinated Universal Time'**
  String get projectTimeZoneUtc;

  /// No description provided for @projectMainTaxonGroup.
  ///
  /// In en, this message translates to:
  /// **'Main taxon group'**
  String get projectMainTaxonGroup;

  /// No description provided for @projectChooseTaxonGroup.
  ///
  /// In en, this message translates to:
  /// **'Choose a taxon group'**
  String get projectChooseTaxonGroup;

  /// No description provided for @projectTaxonSettingLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load taxon setting: {error}'**
  String projectTaxonSettingLoadError(String error);

  /// No description provided for @projectIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get projectIdentity;

  /// No description provided for @projectDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get projectDescription;

  /// No description provided for @projectSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get projectSchedule;

  /// No description provided for @projectRecordMetadata.
  ///
  /// In en, this message translates to:
  /// **'Record metadata'**
  String get projectRecordMetadata;

  /// No description provided for @projectCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get projectCreated;

  /// No description provided for @projectLastAccessed.
  ///
  /// In en, this message translates to:
  /// **'Last accessed'**
  String get projectLastAccessed;

  /// No description provided for @projectNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get projectNotProvided;

  /// No description provided for @projectUuid.
  ///
  /// In en, this message translates to:
  /// **'UUID'**
  String get projectUuid;

  /// No description provided for @projectQrTooltip.
  ///
  /// In en, this message translates to:
  /// **'Project QR code. Tap to view full.'**
  String get projectQrTooltip;

  /// No description provided for @projectEditTools.
  ///
  /// In en, this message translates to:
  /// **'Edit tools'**
  String get projectEditTools;

  /// No description provided for @projectEditToolsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose the tools shown here'**
  String get projectEditToolsTooltip;

  /// No description provided for @projectUtilities.
  ///
  /// In en, this message translates to:
  /// **'Project utilities'**
  String get projectUtilities;

  /// No description provided for @projectDashboard.
  ///
  /// In en, this message translates to:
  /// **'Project dashboard'**
  String get projectDashboard;

  /// No description provided for @projectEditProject.
  ///
  /// In en, this message translates to:
  /// **'Edit project'**
  String get projectEditProject;

  /// No description provided for @projectPersonnelRoleCataloger.
  ///
  /// In en, this message translates to:
  /// **'Cataloger'**
  String get projectPersonnelRoleCataloger;

  /// No description provided for @projectPersonnelRoleDeterminer.
  ///
  /// In en, this message translates to:
  /// **'Determiner only'**
  String get projectPersonnelRoleDeterminer;

  /// No description provided for @projectPersonnelRolePreparator.
  ///
  /// In en, this message translates to:
  /// **'Preparator only'**
  String get projectPersonnelRolePreparator;

  /// No description provided for @projectPersonnelRoleNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get projectPersonnelRoleNone;

  /// No description provided for @projectPersonnelSelectExisting.
  ///
  /// In en, this message translates to:
  /// **'Select existing'**
  String get projectPersonnelSelectExisting;

  /// No description provided for @projectPersonnelSelectFromDatabase.
  ///
  /// In en, this message translates to:
  /// **'Select from database'**
  String get projectPersonnelSelectFromDatabase;

  /// No description provided for @projectPersonnelAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add new'**
  String get projectPersonnelAddNew;

  /// No description provided for @projectPersonnelAddNewPersonnel.
  ///
  /// In en, this message translates to:
  /// **'Add new personnel'**
  String get projectPersonnelAddNewPersonnel;

  /// No description provided for @projectPersonnelImageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Image not found'**
  String get projectPersonnelImageNotFound;

  /// No description provided for @projectPersonnelTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get projectPersonnelTakePhoto;

  /// No description provided for @projectPersonnelSelectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select photo'**
  String get projectPersonnelSelectPhoto;

  /// No description provided for @projectPersonnelEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit personnel'**
  String get projectPersonnelEdit;

  /// No description provided for @projectPersonnelManage.
  ///
  /// In en, this message translates to:
  /// **'Manage personnel'**
  String get projectPersonnelManage;

  /// No description provided for @projectPersonnelManageButton.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get projectPersonnelManageButton;

  /// No description provided for @projectPersonnelNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No personnel found.'**
  String get projectPersonnelNoneFound;

  /// No description provided for @projectPersonnelSelectToView.
  ///
  /// In en, this message translates to:
  /// **'Select personnel to view details'**
  String get projectPersonnelSelectToView;

  /// No description provided for @projectPersonnelSearch.
  ///
  /// In en, this message translates to:
  /// **'Search personnel'**
  String get projectPersonnelSearch;

  /// No description provided for @projectPersonnelUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed personnel'**
  String get projectPersonnelUnnamed;

  /// No description provided for @projectPersonnelAssigned.
  ///
  /// In en, this message translates to:
  /// **'Personnel is currently assigned to a project'**
  String get projectPersonnelAssigned;

  /// No description provided for @projectPersonnelDeleted.
  ///
  /// In en, this message translates to:
  /// **'{deleted, plural, =1{1 personnel deleted.} other{{deleted} personnel deleted.}}'**
  String projectPersonnelDeleted(int deleted);

  /// No description provided for @projectPersonnelDeletedPartly.
  ///
  /// In en, this message translates to:
  /// **'{deleted} personnel deleted. {protected} personnel could not be deleted because they are assigned to a project.'**
  String projectPersonnelDeletedPartly(int deleted, int protected);

  /// No description provided for @projectPersonnelNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No personnel match “{query}”.'**
  String projectPersonnelNoMatch(String query);

  /// No description provided for @projectSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String projectSelectedCount(int count);

  /// Chip on personnel already in the project.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get projectPersonnelAdded;

  /// No description provided for @projectPersonnelAddCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 personnel} other{Add {count} personnel}}'**
  String projectPersonnelAddCount(int count);

  /// No description provided for @projectPersonnelRemoveBlocked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 personnel could not be removed because they are used by project records.} other{{count} personnel could not be removed because they are used by project records.}}'**
  String projectPersonnelRemoveBlocked(int count);

  /// No description provided for @projectPersonnelRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get projectPersonnelRole;

  /// No description provided for @projectPersonnelRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter role'**
  String get projectPersonnelRoleHint;

  /// No description provided for @projectPersonnelAffiliation.
  ///
  /// In en, this message translates to:
  /// **'Affiliation'**
  String get projectPersonnelAffiliation;

  /// No description provided for @projectPersonnelAffiliationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter affiliation'**
  String get projectPersonnelAffiliationHint;

  /// No description provided for @projectPersonnelOrcid.
  ///
  /// In en, this message translates to:
  /// **'ORCID iD'**
  String get projectPersonnelOrcid;

  /// No description provided for @projectPersonnelOrcidInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid hyphenated ORCID iD'**
  String get projectPersonnelOrcidInvalid;

  /// No description provided for @projectPersonnelCurrentFieldNumber.
  ///
  /// In en, this message translates to:
  /// **'Current field number'**
  String get projectPersonnelCurrentFieldNumber;

  /// No description provided for @projectPersonnelInitials.
  ///
  /// In en, this message translates to:
  /// **'Initials'**
  String get projectPersonnelInitials;

  /// No description provided for @projectPersonnelInitialsLabel.
  ///
  /// In en, this message translates to:
  /// **'Initials*'**
  String get projectPersonnelInitialsLabel;

  /// No description provided for @projectPersonnelInitialsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. HH or H-H'**
  String get projectPersonnelInitialsHint;

  /// No description provided for @projectPersonnelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get projectPersonnelEmail;

  /// No description provided for @projectPersonnelEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get projectPersonnelEmailHint;

  /// No description provided for @projectPersonnelPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get projectPersonnelPhone;

  /// No description provided for @projectPersonnelPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone'**
  String get projectPersonnelPhoneHint;

  /// No description provided for @projectPersonnelSpecimenCare.
  ///
  /// In en, this message translates to:
  /// **'Specimen care'**
  String get projectPersonnelSpecimenCare;

  /// No description provided for @projectPersonnelSpecimenCareRole.
  ///
  /// In en, this message translates to:
  /// **'Specimen care role'**
  String get projectPersonnelSpecimenCareRole;

  /// No description provided for @projectPersonnelRegisterFieldNumber.
  ///
  /// In en, this message translates to:
  /// **'Register field number'**
  String get projectPersonnelRegisterFieldNumber;

  /// No description provided for @projectPersonnelRegisterPersonalFieldNumber.
  ///
  /// In en, this message translates to:
  /// **'Register personal field number'**
  String get projectPersonnelRegisterPersonalFieldNumber;

  /// No description provided for @projectPersonnelRegisterFieldNumberNote.
  ///
  /// In en, this message translates to:
  /// **'Initials and cataloger number will be used to generate specimen field ID.'**
  String get projectPersonnelRegisterFieldNumberNote;

  /// No description provided for @projectEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get projectEnabled;

  /// No description provided for @projectDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get projectDisabled;

  /// No description provided for @projectPersonnelProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get projectPersonnelProfile;

  /// No description provided for @projectPersonnelContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get projectPersonnelContact;

  /// No description provided for @projectPersonnelNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get projectPersonnelNotes;

  /// No description provided for @projectPersonnelNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Write notes'**
  String get projectPersonnelNotesHint;

  /// No description provided for @projectPersonnelNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name*'**
  String get projectPersonnelNameLabel;

  /// No description provided for @projectPersonnelNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a name (required)'**
  String get projectPersonnelNameHint;

  /// No description provided for @projectPersonnelCatalogerNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Cataloger number*'**
  String get projectPersonnelCatalogerNumberLabel;

  /// No description provided for @projectErrorDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String projectErrorDetail(String error);

  /// No description provided for @projectLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get projectLoading;

  /// No description provided for @projectTaxonNew.
  ///
  /// In en, this message translates to:
  /// **'New taxon'**
  String get projectTaxonNew;

  /// No description provided for @projectTaxonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit taxon'**
  String get projectTaxonEdit;

  /// No description provided for @projectTaxonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add taxon'**
  String get projectTaxonAdd;

  /// No description provided for @projectTaxonClassification.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get projectTaxonClassification;

  /// No description provided for @projectTaxonRank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get projectTaxonRank;

  /// No description provided for @projectTaxonRankLabel.
  ///
  /// In en, this message translates to:
  /// **'Taxon rank'**
  String get projectTaxonRankLabel;

  /// No description provided for @projectTaxonRankHint.
  ///
  /// In en, this message translates to:
  /// **'Select the rank represented by this record'**
  String get projectTaxonRankHint;

  /// No description provided for @projectTaxonRankRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a rank and enter its name.'**
  String get projectTaxonRankRequired;

  /// Hint for a classification field; the field name is lowercase.
  ///
  /// In en, this message translates to:
  /// **'Enter {field}'**
  String projectTaxonEnterValue(String field);

  /// No description provided for @projectTaxonKingdom.
  ///
  /// In en, this message translates to:
  /// **'Kingdom'**
  String get projectTaxonKingdom;

  /// No description provided for @projectTaxonPhylum.
  ///
  /// In en, this message translates to:
  /// **'Phylum'**
  String get projectTaxonPhylum;

  /// No description provided for @projectTaxonClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get projectTaxonClass;

  /// No description provided for @projectTaxonOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get projectTaxonOrder;

  /// No description provided for @projectTaxonFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get projectTaxonFamily;

  /// No description provided for @projectTaxonGenus.
  ///
  /// In en, this message translates to:
  /// **'Genus'**
  String get projectTaxonGenus;

  /// No description provided for @projectTaxonSpecies.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get projectTaxonSpecies;

  /// No description provided for @projectTaxonSubspecies.
  ///
  /// In en, this message translates to:
  /// **'Subspecies'**
  String get projectTaxonSubspecies;

  /// No description provided for @projectTaxonSpecificEpithet.
  ///
  /// In en, this message translates to:
  /// **'Specific epithet'**
  String get projectTaxonSpecificEpithet;

  /// No description provided for @projectTaxonSubspecificEpithet.
  ///
  /// In en, this message translates to:
  /// **'Subspecific epithet'**
  String get projectTaxonSubspecificEpithet;

  /// No description provided for @projectTaxonAdditionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional details'**
  String get projectTaxonAdditionalDetails;

  /// No description provided for @projectTaxonAuthors.
  ///
  /// In en, this message translates to:
  /// **'Authors'**
  String get projectTaxonAuthors;

  /// No description provided for @projectTaxonAuthorsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter authors'**
  String get projectTaxonAuthorsHint;

  /// No description provided for @projectTaxonCommonName.
  ///
  /// In en, this message translates to:
  /// **'Common name'**
  String get projectTaxonCommonName;

  /// No description provided for @projectTaxonCommonNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a common name'**
  String get projectTaxonCommonNameHint;

  /// No description provided for @projectTaxonRedListLabel.
  ///
  /// In en, this message translates to:
  /// **'IUCN Red List category'**
  String get projectTaxonRedListLabel;

  /// No description provided for @projectTaxonRedListHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Endangered, Vulnerable, etc.'**
  String get projectTaxonRedListHint;

  /// No description provided for @projectTaxonRedListCategory.
  ///
  /// In en, this message translates to:
  /// **'Red List category'**
  String get projectTaxonRedListCategory;

  /// No description provided for @projectTaxonCitesStatus.
  ///
  /// In en, this message translates to:
  /// **'CITES status'**
  String get projectTaxonCitesStatus;

  /// No description provided for @projectTaxonCitesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Appendix I, Appendix II, Non-CITES, etc.'**
  String get projectTaxonCitesHint;

  /// No description provided for @projectTaxonCountryStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Country conservation status'**
  String get projectTaxonCountryStatusLabel;

  /// No description provided for @projectTaxonCountryStatusHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Protected, common, etc.'**
  String get projectTaxonCountryStatusHint;

  /// No description provided for @projectTaxonCountryStatus.
  ///
  /// In en, this message translates to:
  /// **'Country status'**
  String get projectTaxonCountryStatus;

  /// No description provided for @projectTaxonSortingOrder.
  ///
  /// In en, this message translates to:
  /// **'Sorting order'**
  String get projectTaxonSortingOrder;

  /// No description provided for @projectTaxonSortingOrderHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1, 2, 3'**
  String get projectTaxonSortingOrderHint;

  /// No description provided for @projectTaxonNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter notes'**
  String get projectTaxonNotesHint;

  /// No description provided for @projectTaxonAllFields.
  ///
  /// In en, this message translates to:
  /// **'All fields'**
  String get projectTaxonAllFields;

  /// No description provided for @projectTaxonConservation.
  ///
  /// In en, this message translates to:
  /// **'Conservation'**
  String get projectTaxonConservation;

  /// No description provided for @projectTaxonTotalRecords.
  ///
  /// In en, this message translates to:
  /// **'Total records'**
  String get projectTaxonTotalRecords;

  /// No description provided for @projectTaxonCurrentProject.
  ///
  /// In en, this message translates to:
  /// **'Current project'**
  String get projectTaxonCurrentProject;

  /// No description provided for @projectTaxonAllProjects.
  ///
  /// In en, this message translates to:
  /// **'All projects'**
  String get projectTaxonAllProjects;

  /// No description provided for @projectTaxonRecordTotalsError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load record totals: {error}'**
  String projectTaxonRecordTotalsError(String error);

  /// No description provided for @projectTaxonQrTooltip.
  ///
  /// In en, this message translates to:
  /// **'Taxon QR code. Tap to view full.'**
  String get projectTaxonQrTooltip;

  /// No description provided for @projectTaxonQrCode.
  ///
  /// In en, this message translates to:
  /// **'Taxon QR code'**
  String get projectTaxonQrCode;

  /// No description provided for @projectTaxonQrDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan this code in NAHPU to import this taxon.'**
  String get projectTaxonQrDescription;

  /// No description provided for @projectTaxonRegistry.
  ///
  /// In en, this message translates to:
  /// **'Taxon registry'**
  String get projectTaxonRegistry;

  /// No description provided for @projectTaxonImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {taxa} taxa across {families} families.'**
  String projectTaxonImported(int taxa, int families);

  /// No description provided for @projectTaxonEmpty.
  ///
  /// In en, this message translates to:
  /// **'No taxon found.\nAdd or import taxa to start recording captures.'**
  String get projectTaxonEmpty;

  /// No description provided for @projectTaxonMetricOrders.
  ///
  /// In en, this message translates to:
  /// **'orders'**
  String get projectTaxonMetricOrders;

  /// No description provided for @projectTaxonMetricFamilies.
  ///
  /// In en, this message translates to:
  /// **'families'**
  String get projectTaxonMetricFamilies;

  /// No description provided for @projectTaxonMetricSpecies.
  ///
  /// In en, this message translates to:
  /// **'species registered'**
  String get projectTaxonMetricSpecies;

  /// No description provided for @projectTaxonMetricTaxa.
  ///
  /// In en, this message translates to:
  /// **'taxa'**
  String get projectTaxonMetricTaxa;

  /// No description provided for @projectTaxonSpecimenRecords.
  ///
  /// In en, this message translates to:
  /// **'Specimen records'**
  String get projectTaxonSpecimenRecords;

  /// No description provided for @projectTaxonSearchSpecimens.
  ///
  /// In en, this message translates to:
  /// **'Search specimens'**
  String get projectTaxonSearchSpecimens;

  /// No description provided for @projectTaxonNoSpecimens.
  ///
  /// In en, this message translates to:
  /// **'No specimens found'**
  String get projectTaxonNoSpecimens;

  /// No description provided for @projectTaxonSpecimensFound.
  ///
  /// In en, this message translates to:
  /// **'{found, plural, =1{Found: 1 of {total, plural, =1{1 specimen} other{{total} specimens}}} other{Found: {found} of {total, plural, =1{1 specimen} other{{total} specimens}}}}'**
  String projectTaxonSpecimensFound(int found, int total);

  /// No description provided for @projectTaxonSpecimenCount.
  ///
  /// In en, this message translates to:
  /// **'Specimen count: {count}'**
  String projectTaxonSpecimenCount(int count);

  /// No description provided for @projectTaxonImportFromQr.
  ///
  /// In en, this message translates to:
  /// **'Import from QR'**
  String get projectTaxonImportFromQr;

  /// No description provided for @projectTaxonSingle.
  ///
  /// In en, this message translates to:
  /// **'Single taxon'**
  String get projectTaxonSingle;

  /// No description provided for @projectTaxonMultiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple taxa'**
  String get projectTaxonMultiple;

  /// No description provided for @projectTaxonScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan taxon QR'**
  String get projectTaxonScanQr;

  /// No description provided for @projectTaxonScanMultiple.
  ///
  /// In en, this message translates to:
  /// **'Scan multiple taxa'**
  String get projectTaxonScanMultiple;

  /// No description provided for @projectCameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access is denied. Allow camera access in device settings, then retry.'**
  String get projectCameraDenied;

  /// No description provided for @projectTaxonCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera scanning is unavailable. Retry or use file import.'**
  String get projectTaxonCameraUnavailable;

  /// No description provided for @projectTaxonCameraError.
  ///
  /// In en, this message translates to:
  /// **'Unable to use the camera. Retry or use file import.'**
  String get projectTaxonCameraError;

  /// No description provided for @projectTaxonReadyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 taxon ready} other{{count} taxa ready}}'**
  String projectTaxonReadyCount(int count);

  /// No description provided for @projectTaxonScanPrompt.
  ///
  /// In en, this message translates to:
  /// **'Scan a NAHPU taxon QR code.'**
  String get projectTaxonScanPrompt;

  /// No description provided for @projectRetryCamera.
  ///
  /// In en, this message translates to:
  /// **'Retry camera'**
  String get projectRetryCamera;

  /// No description provided for @projectTaxonManage.
  ///
  /// In en, this message translates to:
  /// **'Manage taxa'**
  String get projectTaxonManage;

  /// No description provided for @projectTaxonNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No taxa found'**
  String get projectTaxonNoneFound;

  /// No description provided for @projectTaxonSelectToView.
  ///
  /// In en, this message translates to:
  /// **'Select a taxon to view details'**
  String get projectTaxonSelectToView;

  /// Search hint; the category is lowercase.
  ///
  /// In en, this message translates to:
  /// **'Search {category}'**
  String projectTaxonSearchIn(String category);

  /// No description provided for @projectTaxonSearchCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search category: {category}'**
  String projectTaxonSearchCategoryTooltip(String category);

  /// No description provided for @projectTaxonSearchCategory.
  ///
  /// In en, this message translates to:
  /// **'Search category'**
  String get projectTaxonSearchCategory;

  /// No description provided for @projectTaxonInUse.
  ///
  /// In en, this message translates to:
  /// **'Taxon is currently used by a specimen'**
  String get projectTaxonInUse;

  /// No description provided for @projectTaxonDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 taxon deleted.} other{{count} taxa deleted.}}'**
  String projectTaxonDeleted(int count);

  /// No description provided for @projectTaxonDeletedPartly.
  ///
  /// In en, this message translates to:
  /// **'{deleted} taxa deleted. {protected} taxa could not be deleted because they are used by specimens.'**
  String projectTaxonDeletedPartly(int deleted, int protected);

  /// No description provided for @projectTaxonNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No taxa match “{query}”.'**
  String projectTaxonNoMatch(String query);

  /// No description provided for @projectTaxonNoMatchIn.
  ///
  /// In en, this message translates to:
  /// **'No taxa match “{query}” in {category}.'**
  String projectTaxonNoMatchIn(String query, String category);

  /// No description provided for @projectTaxonManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get projectTaxonManual;

  /// No description provided for @projectImportSetupTab.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get projectImportSetupTab;

  /// No description provided for @projectTaxonQrSource.
  ///
  /// In en, this message translates to:
  /// **'NAHPU taxon QR'**
  String get projectTaxonQrSource;

  /// No description provided for @projectMapColumns.
  ///
  /// In en, this message translates to:
  /// **'Map columns'**
  String get projectMapColumns;

  /// No description provided for @projectParsingError.
  ///
  /// In en, this message translates to:
  /// **'Parsing error'**
  String get projectParsingError;

  /// No description provided for @projectCheckColumns.
  ///
  /// In en, this message translates to:
  /// **'Check columns'**
  String get projectCheckColumns;

  /// No description provided for @projectHideAdvancedOptions.
  ///
  /// In en, this message translates to:
  /// **'Hide advanced options'**
  String get projectHideAdvancedOptions;

  /// No description provided for @projectAdvancedOptions.
  ///
  /// In en, this message translates to:
  /// **'Advanced options'**
  String get projectAdvancedOptions;

  /// No description provided for @projectTaxonReview.
  ///
  /// In en, this message translates to:
  /// **'Review taxa'**
  String get projectTaxonReview;

  /// No description provided for @projectTaxonPreviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Select a file or scan a taxon QR to preview imports.'**
  String get projectTaxonPreviewEmpty;

  /// No description provided for @projectTaxonReviewSummary.
  ///
  /// In en, this message translates to:
  /// **'{registered} already registered · {duplicates} duplicate'**
  String projectTaxonReviewSummary(int registered, int duplicates);

  /// No description provided for @projectTaxonAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Already registered'**
  String get projectTaxonAlreadyRegistered;

  /// No description provided for @projectTaxonDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get projectTaxonDuplicate;

  /// No description provided for @projectImportSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'Import {count} selected'**
  String projectImportSelectedCount(int count);

  /// No description provided for @projectTaxonSelectSharedClass.
  ///
  /// In en, this message translates to:
  /// **'Select the class shared by all rows'**
  String get projectTaxonSelectSharedClass;

  /// No description provided for @projectTaxonClassForAllRows.
  ///
  /// In en, this message translates to:
  /// **'Class for all rows'**
  String get projectTaxonClassForAllRows;

  /// No description provided for @projectTaxonKingdomPhylum.
  ///
  /// In en, this message translates to:
  /// **'Kingdom: {kingdom} · Phylum: {phylum}'**
  String projectTaxonKingdomPhylum(String kingdom, String phylum);

  /// No description provided for @projectParserExcel.
  ///
  /// In en, this message translates to:
  /// **'Excel parser'**
  String get projectParserExcel;

  /// No description provided for @projectParserDelimited.
  ///
  /// In en, this message translates to:
  /// **'Delimited text parser'**
  String get projectParserDelimited;

  /// No description provided for @projectDelimiterNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'Not applicable (Excel file)'**
  String get projectDelimiterNotApplicable;

  /// No description provided for @projectDelimiterTab.
  ///
  /// In en, this message translates to:
  /// **'Tab (\"\\t\")'**
  String get projectDelimiterTab;

  /// No description provided for @projectDelimiterComma.
  ///
  /// In en, this message translates to:
  /// **'Comma (\",\")'**
  String get projectDelimiterComma;

  /// No description provided for @projectDelimiterSemicolon.
  ///
  /// In en, this message translates to:
  /// **'Semicolon (\";\")'**
  String get projectDelimiterSemicolon;

  /// No description provided for @projectDelimiterCustomRaw.
  ///
  /// In en, this message translates to:
  /// **'Custom (raw text)'**
  String get projectDelimiterCustomRaw;

  /// No description provided for @projectParsingDetails.
  ///
  /// In en, this message translates to:
  /// **'Parsing details'**
  String get projectParsingDetails;

  /// No description provided for @projectParserValue.
  ///
  /// In en, this message translates to:
  /// **'Parser: {parser}'**
  String projectParserValue(String parser);

  /// No description provided for @projectDelimiterValue.
  ///
  /// In en, this message translates to:
  /// **'Delimiter: {delimiter}'**
  String projectDelimiterValue(String delimiter);

  /// No description provided for @projectCustomDelimiterRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a custom delimiter to continue.'**
  String get projectCustomDelimiterRequired;

  /// No description provided for @projectParser.
  ///
  /// In en, this message translates to:
  /// **'Parser'**
  String get projectParser;

  /// No description provided for @projectParserAutoDetect.
  ///
  /// In en, this message translates to:
  /// **'Auto detect'**
  String get projectParserAutoDetect;

  /// No description provided for @projectCustomDelimiter.
  ///
  /// In en, this message translates to:
  /// **'Custom delimiter'**
  String get projectCustomDelimiter;

  /// No description provided for @projectCustomDelimiterHint.
  ///
  /// In en, this message translates to:
  /// **'Enter raw text (example: | or \\t)'**
  String get projectCustomDelimiterHint;

  /// No description provided for @projectRetryParse.
  ///
  /// In en, this message translates to:
  /// **'Retry parse'**
  String get projectRetryParse;

  /// No description provided for @projectTaxonSupportedInputs.
  ///
  /// In en, this message translates to:
  /// **'Supported inputs:'**
  String get projectTaxonSupportedInputs;

  /// No description provided for @projectTaxonSupportedFormats.
  ///
  /// In en, this message translates to:
  /// **'CSV (.csv), TSV (.tsv), Excel (.xlsx), NAHPU taxon QR'**
  String get projectTaxonSupportedFormats;

  /// No description provided for @projectReadingFile.
  ///
  /// In en, this message translates to:
  /// **'Reading file…'**
  String get projectReadingFile;

  /// No description provided for @projectQrUnavailable.
  ///
  /// In en, this message translates to:
  /// **'QR scanning is unavailable on this platform.'**
  String get projectQrUnavailable;

  /// No description provided for @projectClearImport.
  ///
  /// In en, this message translates to:
  /// **'Clear import'**
  String get projectClearImport;

  /// No description provided for @projectWizardWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get projectWizardWelcome;

  /// No description provided for @projectWizardMainTaxon.
  ///
  /// In en, this message translates to:
  /// **'Main taxon'**
  String get projectWizardMainTaxon;

  /// No description provided for @projectWizardReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get projectWizardReview;

  /// No description provided for @projectWizardCreateOnce.
  ///
  /// In en, this message translates to:
  /// **'Create once for all devices'**
  String get projectWizardCreateOnce;

  /// No description provided for @projectWizardCreateOnceBody.
  ///
  /// In en, this message translates to:
  /// **'Create a new project only for the first device. Use QR/Import JSON to transfer project info and its identity.'**
  String get projectWizardCreateOnceBody;

  /// No description provided for @projectWizardCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new project'**
  String get projectWizardCreateNew;

  /// No description provided for @projectScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan project QR'**
  String get projectScanQr;

  /// No description provided for @projectWizardMainTaxonBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the main taxon to tailor NAHPU’s specimen forms and defaults on this device. A project can contain multiple taxon groups, and you can change the main taxon later in Settings.'**
  String get projectWizardMainTaxonBody;

  /// No description provided for @projectWizardFieldIdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up field IDs'**
  String get projectWizardFieldIdsTitle;

  /// No description provided for @projectWizardFieldIdsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load field ID settings: {error}'**
  String projectWizardFieldIdsLoadError(String error);

  /// No description provided for @projectWizardFieldIdsBody.
  ///
  /// In en, this message translates to:
  /// **'Choose how specimen field IDs are generated. You can change this later in Settings > Catalogs > Specimens.'**
  String get projectWizardFieldIdsBody;

  /// No description provided for @projectWizardCatalogerRequired.
  ///
  /// In en, this message translates to:
  /// **'A registered cataloger is required'**
  String get projectWizardCatalogerRequired;

  /// No description provided for @projectWizardCatalogerRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Next, choose an eligible cataloger or create one with initials and a current personal field number.'**
  String get projectWizardCatalogerRequiredBody;

  /// No description provided for @projectWizardPrefixHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. {example}'**
  String projectWizardPrefixHint(String example);

  /// No description provided for @projectCurrentCatalogNumber.
  ///
  /// In en, this message translates to:
  /// **'Current catalog number'**
  String get projectCurrentCatalogNumber;

  /// No description provided for @projectWizardNextNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the next number'**
  String get projectWizardNextNumberHint;

  /// No description provided for @projectWizardCurrentNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a current number'**
  String get projectWizardCurrentNumberRequired;

  /// No description provided for @projectWizardAutoIncrementCatalog.
  ///
  /// In en, this message translates to:
  /// **'Auto-increment catalog number'**
  String get projectWizardAutoIncrementCatalog;

  /// No description provided for @projectWizardPersonnelLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load personnel: {error}'**
  String projectWizardPersonnelLoadError(String error);

  /// No description provided for @projectWizardCreateCataloger.
  ///
  /// In en, this message translates to:
  /// **'Create a cataloger'**
  String get projectWizardCreateCataloger;

  /// No description provided for @projectWizardChooseCataloger.
  ///
  /// In en, this message translates to:
  /// **'Choose a cataloger'**
  String get projectWizardChooseCataloger;

  /// No description provided for @projectWizardNoCatalogerBody.
  ///
  /// In en, this message translates to:
  /// **'No registered cataloger is available. Create one now; the role and personal field-number registration are filled automatically.'**
  String get projectWizardNoCatalogerBody;

  /// No description provided for @projectWizardCreateAnotherCatalogerBody.
  ///
  /// In en, this message translates to:
  /// **'Create another cataloger. The role and personal field-number registration are filled automatically.'**
  String get projectWizardCreateAnotherCatalogerBody;

  /// No description provided for @projectWizardChooseCatalogerBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the cataloger whose initials and current field number will be used for personnel field IDs.'**
  String get projectWizardChooseCatalogerBody;

  /// No description provided for @projectWizardCatalogerLabel.
  ///
  /// In en, this message translates to:
  /// **'Cataloger*'**
  String get projectWizardCatalogerLabel;

  /// No description provided for @projectWizardCatalogerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the cataloger name'**
  String get projectWizardCatalogerNameHint;

  /// No description provided for @projectWizardCurrentFieldNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Current field number*'**
  String get projectWizardCurrentFieldNumberLabel;

  /// No description provided for @projectWizardCurrentFieldNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the next personal field number'**
  String get projectWizardCurrentFieldNumberHint;

  /// No description provided for @projectWizardCatalogerRoleSet.
  ///
  /// In en, this message translates to:
  /// **'Specimen care role: Cataloger'**
  String get projectWizardCatalogerRoleSet;

  /// No description provided for @projectWizardFieldNumberEnabled.
  ///
  /// In en, this message translates to:
  /// **'Personal field-number registration enabled'**
  String get projectWizardFieldNumberEnabled;

  /// No description provided for @projectWizardReviewImported.
  ///
  /// In en, this message translates to:
  /// **'Review imported project'**
  String get projectWizardReviewImported;

  /// No description provided for @projectWizardReviewProject.
  ///
  /// In en, this message translates to:
  /// **'Review project'**
  String get projectWizardReviewProject;

  /// No description provided for @projectWizardImportNote.
  ///
  /// In en, this message translates to:
  /// **'This project-info transfer preserves the source UUID. Records, personnel, taxa, and device settings are not included.'**
  String get projectWizardImportNote;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectName;

  /// No description provided for @projectFieldIdPrefix.
  ///
  /// In en, this message translates to:
  /// **'Field ID prefix'**
  String get projectFieldIdPrefix;

  /// No description provided for @projectFieldIdSuffix.
  ///
  /// In en, this message translates to:
  /// **'Field ID suffix'**
  String get projectFieldIdSuffix;

  /// No description provided for @projectWizardExistingCataloger.
  ///
  /// In en, this message translates to:
  /// **'Existing cataloger selected'**
  String get projectWizardExistingCataloger;

  /// No description provided for @projectWizardNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get projectWizardNotConfigured;

  /// No description provided for @projectWizardDeviceSetup.
  ///
  /// In en, this message translates to:
  /// **'Device setup'**
  String get projectWizardDeviceSetup;

  /// No description provided for @projectWizardKeepCurrent.
  ///
  /// In en, this message translates to:
  /// **'Keep current setting'**
  String get projectWizardKeepCurrent;

  /// No description provided for @projectWizardFieldIdMode.
  ///
  /// In en, this message translates to:
  /// **'Field ID mode'**
  String get projectWizardFieldIdMode;

  /// No description provided for @projectWizardAutoIncrement.
  ///
  /// In en, this message translates to:
  /// **'Auto-increment'**
  String get projectWizardAutoIncrement;

  /// No description provided for @projectOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get projectOn;

  /// No description provided for @projectOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get projectOff;

  /// No description provided for @projectWizardTaxonomyReadiness.
  ///
  /// In en, this message translates to:
  /// **'Taxonomy readiness'**
  String get projectWizardTaxonomyReadiness;

  /// No description provided for @projectWizardTaxaCountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Available taxa count is unavailable.'**
  String get projectWizardTaxaCountUnavailable;

  /// No description provided for @projectWizardAvailableTaxa.
  ///
  /// In en, this message translates to:
  /// **'Available taxa: {count}'**
  String projectWizardAvailableTaxa(int count);

  /// No description provided for @projectWizardNoTaxa.
  ///
  /// In en, this message translates to:
  /// **'No taxa are available'**
  String get projectWizardNoTaxa;

  /// No description provided for @projectWizardNoTaxaBody.
  ///
  /// In en, this message translates to:
  /// **'Add or import taxa in the Taxon Registry before creating a new specimen record.'**
  String get projectWizardNoTaxaBody;

  /// No description provided for @projectWizardSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get projectWizardSkip;

  /// No description provided for @projectWizardCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get projectWizardCreating;

  /// No description provided for @projectWizardCatalogerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Cataloger name is required'**
  String get projectWizardCatalogerNameRequired;

  /// No description provided for @projectWizardNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name is too short'**
  String get projectWizardNameTooShort;

  /// No description provided for @projectWizardInvalidCharacters.
  ///
  /// In en, this message translates to:
  /// **'Invalid characters'**
  String get projectWizardInvalidCharacters;

  /// No description provided for @projectWizardInitialsRequired.
  ///
  /// In en, this message translates to:
  /// **'Initials are required'**
  String get projectWizardInitialsRequired;

  /// No description provided for @projectWizardInitialsTooShort.
  ///
  /// In en, this message translates to:
  /// **'Initials are too short'**
  String get projectWizardInitialsTooShort;

  /// No description provided for @projectWizardFieldNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Current field number is required'**
  String get projectWizardFieldNumberRequired;

  /// No description provided for @projectWizardInvalidFieldNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid field number'**
  String get projectWizardInvalidFieldNumber;

  /// No description provided for @projectInvalidQr.
  ///
  /// In en, this message translates to:
  /// **'Invalid project QR code.'**
  String get projectInvalidQr;

  /// No description provided for @projectNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Project name is required'**
  String get projectNameRequired;

  /// No description provided for @projectNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Project name is too short'**
  String get projectNameTooShort;

  /// No description provided for @projectNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Project name is too long'**
  String get projectNameTooLong;

  /// No description provided for @projectNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Project name is invalid'**
  String get projectNameInvalid;

  /// No description provided for @projectNameExists.
  ///
  /// In en, this message translates to:
  /// **'Project name already exists'**
  String get projectNameExists;

  /// No description provided for @projectUuidExists.
  ///
  /// In en, this message translates to:
  /// **'A project with this UUID already exists on this device.'**
  String get projectUuidExists;

  /// No description provided for @projectCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create project: {error}'**
  String projectCreateFailed(String error);

  /// No description provided for @projectWizardChooseExisting.
  ///
  /// In en, this message translates to:
  /// **'Choose existing'**
  String get projectWizardChooseExisting;

  /// No description provided for @projectWizardCreateNewCataloger.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get projectWizardCreateNewCataloger;

  /// No description provided for @projectUuidValue.
  ///
  /// In en, this message translates to:
  /// **'Project UUID: {uuid}'**
  String projectUuidValue(String uuid);

  /// No description provided for @projectImportInfoJson.
  ///
  /// In en, this message translates to:
  /// **'Import project-info JSON'**
  String get projectImportInfoJson;

  /// No description provided for @projectTransferProjectInfo.
  ///
  /// In en, this message translates to:
  /// **'Project info'**
  String get projectTransferProjectInfo;

  /// No description provided for @projectTransferTaxonomy.
  ///
  /// In en, this message translates to:
  /// **'Taxonomy'**
  String get projectTransferTaxonomy;

  /// No description provided for @projectTransferSites.
  ///
  /// In en, this message translates to:
  /// **'Sites'**
  String get projectTransferSites;

  /// No description provided for @projectTransferEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get projectTransferEvents;

  /// No description provided for @projectTransferSpecimens.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get projectTransferSpecimens;

  /// No description provided for @projectTransferNarratives.
  ///
  /// In en, this message translates to:
  /// **'Narratives'**
  String get projectTransferNarratives;

  /// No description provided for @projectTransferCustomFields.
  ///
  /// In en, this message translates to:
  /// **'Custom fields'**
  String get projectTransferCustomFields;

  /// No description provided for @projectTransferMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get projectTransferMedia;

  /// No description provided for @projectTransferKeepCurrent.
  ///
  /// In en, this message translates to:
  /// **'Keep current'**
  String get projectTransferKeepCurrent;

  /// No description provided for @projectTransferUseImported.
  ///
  /// In en, this message translates to:
  /// **'Use imported'**
  String get projectTransferUseImported;

  /// No description provided for @projectTransferImportAsNew.
  ///
  /// In en, this message translates to:
  /// **'Import as new'**
  String get projectTransferImportAsNew;

  /// No description provided for @projectExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting project'**
  String get projectExporting;

  /// No description provided for @projectExportingHint.
  ///
  /// In en, this message translates to:
  /// **'Projects with many photos can take several minutes. Keep NAHPU open until this finishes.'**
  String get projectExportingHint;

  /// No description provided for @projectExportAnother.
  ///
  /// In en, this message translates to:
  /// **'Export another'**
  String get projectExportAnother;

  /// No description provided for @projectExportCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel the export?'**
  String get projectExportCancelTitle;

  /// No description provided for @projectExportCancelBody.
  ///
  /// In en, this message translates to:
  /// **'The export is still running. Leaving now cancels it and no file will be saved.'**
  String get projectExportCancelBody;

  /// No description provided for @projectExportKeepExporting.
  ///
  /// In en, this message translates to:
  /// **'Keep exporting'**
  String get projectExportKeepExporting;

  /// No description provided for @projectExportCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel export'**
  String get projectExportCancel;

  /// No description provided for @projectOpenFolderFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the folder: {error}'**
  String projectOpenFolderFailed(String error);

  /// No description provided for @projectSaveCopyFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save a copy: {error}'**
  String projectSaveCopyFailed(String error);

  /// No description provided for @projectExportArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup and transfer archive'**
  String get projectExportArchiveTitle;

  /// No description provided for @projectExportArchiveBody.
  ///
  /// In en, this message translates to:
  /// **'Use this archive as a project backup, or to transfer this project to another device and merge it there.'**
  String get projectExportArchiveBody;

  /// No description provided for @projectExportLight.
  ///
  /// In en, this message translates to:
  /// **'Light export'**
  String get projectExportLight;

  /// No description provided for @projectExportLightBody.
  ///
  /// In en, this message translates to:
  /// **'Export the project without media files for limited-internet uploads. Use TAR.GZ or ZIP for a full project backup.'**
  String get projectExportLightBody;

  /// No description provided for @projectExportArchiveContents.
  ///
  /// In en, this message translates to:
  /// **'Archive contents'**
  String get projectExportArchiveContents;

  /// No description provided for @projectExportExcluded.
  ///
  /// In en, this message translates to:
  /// **'Excluded'**
  String get projectExportExcluded;

  /// No description provided for @projectExportMediaSize.
  ///
  /// In en, this message translates to:
  /// **'Media size'**
  String get projectExportMediaSize;

  /// No description provided for @projectWarningCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 warning} other{{count} warnings}}'**
  String projectWarningCount(int count);

  /// No description provided for @projectTransferFileAndSafety.
  ///
  /// In en, this message translates to:
  /// **'File and safety'**
  String get projectTransferFileAndSafety;

  /// No description provided for @projectTransferReviewImport.
  ///
  /// In en, this message translates to:
  /// **'Review and import'**
  String get projectTransferReviewImport;

  /// No description provided for @projectTransferReviewMerge.
  ///
  /// In en, this message translates to:
  /// **'Review and merge'**
  String get projectTransferReviewMerge;

  /// No description provided for @projectTransferResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get projectTransferResult;

  /// No description provided for @projectTransferChooseFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a project transfer first'**
  String get projectTransferChooseFirst;

  /// No description provided for @projectTransferChooseFirstBody.
  ///
  /// In en, this message translates to:
  /// **'Return to File and safety to select an archive.'**
  String get projectTransferChooseFirstBody;

  /// No description provided for @projectTransferChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a NAHPU project transfer'**
  String get projectTransferChooseTitle;

  /// No description provided for @projectTransferChooseBody.
  ///
  /// In en, this message translates to:
  /// **'Project transfers can be JSON.GZ, ZIP, or TAR.GZ. JSON.GZ contains records only. ZIP and TAR.GZ include media.'**
  String get projectTransferChooseBody;

  /// No description provided for @projectTransferReadingArchive.
  ///
  /// In en, this message translates to:
  /// **'Reading archive'**
  String get projectTransferReadingArchive;

  /// No description provided for @projectTransferReadingArchiveHint.
  ///
  /// In en, this message translates to:
  /// **'Transfers that include media can take several minutes to unpack. Keep NAHPU open.'**
  String get projectTransferReadingArchiveHint;

  /// No description provided for @projectTransferChooseArchive.
  ///
  /// In en, this message translates to:
  /// **'Choose archive'**
  String get projectTransferChooseArchive;

  /// No description provided for @projectTransferChooseAnotherArchive.
  ///
  /// In en, this message translates to:
  /// **'Choose another archive'**
  String get projectTransferChooseAnotherArchive;

  /// No description provided for @projectTransferBackupBeforeImport.
  ///
  /// In en, this message translates to:
  /// **'Back up before importing'**
  String get projectTransferBackupBeforeImport;

  /// No description provided for @projectTransferBackupBeforeMerge.
  ///
  /// In en, this message translates to:
  /// **'Back up before merging'**
  String get projectTransferBackupBeforeMerge;

  /// No description provided for @projectTransferBackupBody.
  ///
  /// In en, this message translates to:
  /// **'A database backup gives you a recovery point if imported changes are not what you expected.'**
  String get projectTransferBackupBody;

  /// No description provided for @projectTransferBackupNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get projectTransferBackupNow;

  /// No description provided for @projectTransferBackupAckImport.
  ///
  /// In en, this message translates to:
  /// **'I understand that I should keep a backup before importing.'**
  String get projectTransferBackupAckImport;

  /// No description provided for @projectTransferBackupAckMerge.
  ///
  /// In en, this message translates to:
  /// **'I understand that I should keep a backup before merging.'**
  String get projectTransferBackupAckMerge;

  /// No description provided for @projectTransferNewIdentity.
  ///
  /// In en, this message translates to:
  /// **'New project identity'**
  String get projectTransferNewIdentity;

  /// No description provided for @projectTransferArchiveUuid.
  ///
  /// In en, this message translates to:
  /// **'Archive UUID: {uuid}'**
  String projectTransferArchiveUuid(String uuid);

  /// No description provided for @projectTransferDestinationName.
  ///
  /// In en, this message translates to:
  /// **'Destination project name'**
  String get projectTransferDestinationName;

  /// No description provided for @projectTransferDestinationNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Names the new project on this device. The archive is not changed.'**
  String get projectTransferDestinationNameHelper;

  /// No description provided for @projectTransferNameConflict.
  ///
  /// In en, this message translates to:
  /// **'A project named “{name}” already exists. Choose another name. If these are copies of the same project, cancel and use Merge project instead.'**
  String projectTransferNameConflict(String name);

  /// No description provided for @projectTransferAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This project already exists'**
  String get projectTransferAlreadyExists;

  /// No description provided for @projectTransferAlreadyExistsBody.
  ///
  /// In en, this message translates to:
  /// **'Matching UUIDs identify the same project. Import is blocked. Merge this archive into the existing project instead.'**
  String get projectTransferAlreadyExistsBody;

  /// No description provided for @projectTransferOpenMerge.
  ///
  /// In en, this message translates to:
  /// **'Open Merge project'**
  String get projectTransferOpenMerge;

  /// No description provided for @projectTransferUuidMismatch.
  ///
  /// In en, this message translates to:
  /// **'Project UUID does not match'**
  String get projectTransferUuidMismatch;

  /// No description provided for @projectTransferUuidMismatchBody.
  ///
  /// In en, this message translates to:
  /// **'Archive: {archive}\nActive project: {active}'**
  String projectTransferUuidMismatchBody(String archive, String active);

  /// No description provided for @projectTransferForceMerge.
  ///
  /// In en, this message translates to:
  /// **'Force merge into the active project'**
  String get projectTransferForceMerge;

  /// No description provided for @projectTransferForceMergeBody.
  ///
  /// In en, this message translates to:
  /// **'Imported project-scoped records will use the active project UUID. Conflicts still require the choices shown later.'**
  String get projectTransferForceMergeBody;

  /// No description provided for @projectTransferTypeToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type “{name}” to confirm'**
  String projectTransferTypeToConfirm(String name);

  /// No description provided for @projectCatalogNumberPrefix.
  ///
  /// In en, this message translates to:
  /// **'Catalog number prefix'**
  String get projectCatalogNumberPrefix;

  /// No description provided for @projectCatalogNumberSuffix.
  ///
  /// In en, this message translates to:
  /// **'Catalog number suffix'**
  String get projectCatalogNumberSuffix;

  /// No description provided for @projectTransferProjectInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Current values are kept by default. Select individual imported values when you want to replace them.'**
  String get projectTransferProjectInfoBody;

  /// No description provided for @projectTransferKeepAllCurrent.
  ///
  /// In en, this message translates to:
  /// **'Keep all current'**
  String get projectTransferKeepAllCurrent;

  /// No description provided for @projectTransferUseAllImported.
  ///
  /// In en, this message translates to:
  /// **'Use all imported'**
  String get projectTransferUseAllImported;

  /// No description provided for @projectTransferReviewMatches.
  ///
  /// In en, this message translates to:
  /// **'Review matches before continuing. “Keep current” maps imported dependencies to the existing record without replacing it.'**
  String get projectTransferReviewMatches;

  /// No description provided for @projectTransferBulkTooltip.
  ///
  /// In en, this message translates to:
  /// **'Apply one choice to all matched records'**
  String get projectTransferBulkTooltip;

  /// No description provided for @projectTransferActionForAll.
  ///
  /// In en, this message translates to:
  /// **'{action} for all'**
  String projectTransferActionForAll(String action);

  /// No description provided for @projectTransferBulkAction.
  ///
  /// In en, this message translates to:
  /// **'Bulk action'**
  String get projectTransferBulkAction;

  /// No description provided for @projectTransferStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get projectTransferStatusNew;

  /// No description provided for @projectTransferStatusMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get projectTransferStatusMatched;

  /// No description provided for @projectTransferNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get projectTransferNeedsAttention;

  /// No description provided for @projectTransferSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get projectTransferSkipped;

  /// No description provided for @projectTransferNoConflicts.
  ///
  /// In en, this message translates to:
  /// **'No conflicts'**
  String get projectTransferNoConflicts;

  /// No description provided for @projectTransferNoConflictsBody.
  ///
  /// In en, this message translates to:
  /// **'All records in this section can be imported as new.'**
  String get projectTransferNoConflictsBody;

  /// No description provided for @projectTransferReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been written yet. The database changes will be committed together; a failure rolls them all back.'**
  String get projectTransferReviewBody;

  /// No description provided for @projectTransferSourceProject.
  ///
  /// In en, this message translates to:
  /// **'Source project'**
  String get projectTransferSourceProject;

  /// No description provided for @projectTransferDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get projectTransferDestination;

  /// No description provided for @projectTransferUuidHandling.
  ///
  /// In en, this message translates to:
  /// **'UUID handling'**
  String get projectTransferUuidHandling;

  /// No description provided for @projectTransferNewUuid.
  ///
  /// In en, this message translates to:
  /// **'New project UUID: {uuid}'**
  String projectTransferNewUuid(String uuid);

  /// No description provided for @projectTransferForceMergeUuid.
  ///
  /// In en, this message translates to:
  /// **'Force merge into active UUID'**
  String get projectTransferForceMergeUuid;

  /// No description provided for @projectTransferMatchingUuid.
  ///
  /// In en, this message translates to:
  /// **'Matching project UUID'**
  String get projectTransferMatchingUuid;

  /// No description provided for @projectTransferConflicts.
  ///
  /// In en, this message translates to:
  /// **'Conflicts'**
  String get projectTransferConflicts;

  /// No description provided for @projectTransferMediaFiles.
  ///
  /// In en, this message translates to:
  /// **'Media files'**
  String get projectTransferMediaFiles;

  /// No description provided for @projectTransferResolveConflicts.
  ///
  /// In en, this message translates to:
  /// **'Resolve conflicts before merging'**
  String get projectTransferResolveConflicts;

  /// No description provided for @projectTransferDuplicateIdentifiers.
  ///
  /// In en, this message translates to:
  /// **'Duplicate identifiers still need an action in {sections}.'**
  String projectTransferDuplicateIdentifiers(String sections);

  /// No description provided for @projectTransferArchiveWarnings.
  ///
  /// In en, this message translates to:
  /// **'Archive warnings'**
  String get projectTransferArchiveWarnings;

  /// No description provided for @projectTransferImportUnfinished.
  ///
  /// In en, this message translates to:
  /// **'Import did not finish'**
  String get projectTransferImportUnfinished;

  /// No description provided for @projectTransferMergeUnfinished.
  ///
  /// In en, this message translates to:
  /// **'Merge did not finish'**
  String get projectTransferMergeUnfinished;

  /// No description provided for @projectTransferImportRetry.
  ///
  /// In en, this message translates to:
  /// **'Return to Review and import and try again.'**
  String get projectTransferImportRetry;

  /// No description provided for @projectTransferMergeRetry.
  ///
  /// In en, this message translates to:
  /// **'Return to Review and merge and try again.'**
  String get projectTransferMergeRetry;

  /// No description provided for @projectTransferImported.
  ///
  /// In en, this message translates to:
  /// **'Project imported'**
  String get projectTransferImported;

  /// No description provided for @projectTransferMerged.
  ///
  /// In en, this message translates to:
  /// **'Project data merged'**
  String get projectTransferMerged;

  /// No description provided for @projectTransferCountImported.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get projectTransferCountImported;

  /// No description provided for @projectTransferCountMerged.
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get projectTransferCountMerged;

  /// No description provided for @projectTransferCountUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get projectTransferCountUpdated;

  /// No description provided for @projectTransferSkippedOnConflict.
  ///
  /// In en, this message translates to:
  /// **'Skipped on conflict'**
  String get projectTransferSkippedOnConflict;

  /// No description provided for @projectTransferMediaCopied.
  ///
  /// In en, this message translates to:
  /// **'Media copied'**
  String get projectTransferMediaCopied;

  /// No description provided for @projectTransferWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get projectTransferWarnings;

  /// No description provided for @projectTransferConflict.
  ///
  /// In en, this message translates to:
  /// **'Conflict'**
  String get projectTransferConflict;

  /// No description provided for @projectTransferCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get projectTransferCurrent;

  /// No description provided for @projectTransferConflictAction.
  ///
  /// In en, this message translates to:
  /// **'Conflict action'**
  String get projectTransferConflictAction;

  /// No description provided for @projectTransferChooseAction.
  ///
  /// In en, this message translates to:
  /// **'Choose an action'**
  String get projectTransferChooseAction;

  /// No description provided for @projectTransferChooseActionToContinue.
  ///
  /// In en, this message translates to:
  /// **'Choose an action to continue'**
  String get projectTransferChooseActionToContinue;

  /// No description provided for @projectTransferNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get projectTransferNotSet;

  /// No description provided for @projectTransferNoDetails.
  ///
  /// In en, this message translates to:
  /// **'No details'**
  String get projectTransferNoDetails;

  /// No description provided for @projectBatchSpecimenParts.
  ///
  /// In en, this message translates to:
  /// **'Specimen parts'**
  String get projectBatchSpecimenParts;

  /// No description provided for @projectBatchNarrative.
  ///
  /// In en, this message translates to:
  /// **'Narrative'**
  String get projectBatchNarrative;

  /// No description provided for @projectBatchModeUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update existing records'**
  String get projectBatchModeUpdate;

  /// No description provided for @projectBatchModeCreate.
  ///
  /// In en, this message translates to:
  /// **'Import new records'**
  String get projectBatchModeCreate;

  /// No description provided for @projectBatchHeaderAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get projectBatchHeaderAuto;

  /// No description provided for @projectBatchDarwinCore.
  ///
  /// In en, this message translates to:
  /// **'Darwin Core'**
  String get projectBatchDarwinCore;

  /// No description provided for @projectBatchHeaderNames.
  ///
  /// In en, this message translates to:
  /// **'Column names'**
  String get projectBatchHeaderNames;

  /// No description provided for @projectBatchKeySpecimenUuid.
  ///
  /// In en, this message translates to:
  /// **'Specimen UUID'**
  String get projectBatchKeySpecimenUuid;

  /// No description provided for @projectBatchKeyCatalogNumber.
  ///
  /// In en, this message translates to:
  /// **'Catalog number'**
  String get projectBatchKeyCatalogNumber;

  /// No description provided for @projectBatchKeyCatalogerFieldNumber.
  ///
  /// In en, this message translates to:
  /// **'Cataloger and field number'**
  String get projectBatchKeyCatalogerFieldNumber;

  /// No description provided for @projectBatchKeyTissueId.
  ///
  /// In en, this message translates to:
  /// **'Tissue ID'**
  String get projectBatchKeyTissueId;

  /// No description provided for @projectBatchKeyBarcodeId.
  ///
  /// In en, this message translates to:
  /// **'Barcode ID'**
  String get projectBatchKeyBarcodeId;

  /// No description provided for @projectBatchKeySiteId.
  ///
  /// In en, this message translates to:
  /// **'Site ID'**
  String get projectBatchKeySiteId;

  /// No description provided for @projectBatchKeyEventId.
  ///
  /// In en, this message translates to:
  /// **'Event ID'**
  String get projectBatchKeyEventId;

  /// No description provided for @projectBatchKeyNarrativeDate.
  ///
  /// In en, this message translates to:
  /// **'Narrative date'**
  String get projectBatchKeyNarrativeDate;

  /// No description provided for @projectBatchStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get projectBatchStatusReady;

  /// No description provided for @projectBatchStatusMissingLink.
  ///
  /// In en, this message translates to:
  /// **'Missing link'**
  String get projectBatchStatusMissingLink;

  /// No description provided for @projectBatchStatusNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No match'**
  String get projectBatchStatusNoMatch;

  /// No description provided for @projectBatchStatusAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'Several matches'**
  String get projectBatchStatusAmbiguous;

  /// No description provided for @projectBatchStatusExists.
  ///
  /// In en, this message translates to:
  /// **'Already in project'**
  String get projectBatchStatusExists;

  /// No description provided for @projectBatchStatusDuplicateInFile.
  ///
  /// In en, this message translates to:
  /// **'Repeated in file'**
  String get projectBatchStatusDuplicateInFile;

  /// No description provided for @projectBatchStatusInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid values'**
  String get projectBatchStatusInvalid;

  /// No description provided for @projectBatchUpdateRecords.
  ///
  /// In en, this message translates to:
  /// **'Update records'**
  String get projectBatchUpdateRecords;

  /// No description provided for @projectBatchImportRecords.
  ///
  /// In en, this message translates to:
  /// **'Import records'**
  String get projectBatchImportRecords;

  /// No description provided for @projectBatchStepMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get projectBatchStepMode;

  /// No description provided for @projectBatchStepFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get projectBatchStepFile;

  /// No description provided for @projectBatchStepColumns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get projectBatchStepColumns;

  /// No description provided for @projectBatchStepGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get projectBatchStepGroups;

  /// No description provided for @projectBatchUnsupportedFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a CSV, TSV, or Excel file.'**
  String get projectBatchUnsupportedFile;

  /// No description provided for @projectBatchModeTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do?'**
  String get projectBatchModeTitle;

  /// No description provided for @projectBatchModeBody.
  ///
  /// In en, this message translates to:
  /// **'Bring records in from a CSV, TSV, or Excel file. Columns can use Darwin Core terms or your own names.'**
  String get projectBatchModeBody;

  /// No description provided for @projectBatchModeCreateBody.
  ///
  /// In en, this message translates to:
  /// **'Add one record per row. Taxa, personnel, sites, and events are linked when they are already in the project.'**
  String get projectBatchModeCreateBody;

  /// No description provided for @projectBatchModeUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'Match each row to a record by a key column, such as a catalog number, and write the other columns. Blank cells are left unchanged.'**
  String get projectBatchModeUpdateBody;

  /// No description provided for @projectBatchRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get projectBatchRecords;

  /// No description provided for @projectBatchLinkedRecords.
  ///
  /// In en, this message translates to:
  /// **'Linked records'**
  String get projectBatchLinkedRecords;

  /// No description provided for @projectBatchLinkedRecordsBody.
  ///
  /// In en, this message translates to:
  /// **'Each row can describe a site, its collecting event, a specimen, and a part. Rows are grouped into sites and events, which you can check before importing.'**
  String get projectBatchLinkedRecordsBody;

  /// No description provided for @projectBatchChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get projectBatchChooseFile;

  /// No description provided for @projectBatchChooseFileBody.
  ///
  /// In en, this message translates to:
  /// **'The first row must hold the column names. Each row after it is one record.'**
  String get projectBatchChooseFileBody;

  /// No description provided for @projectBatchSheet.
  ///
  /// In en, this message translates to:
  /// **'Sheet'**
  String get projectBatchSheet;

  /// No description provided for @projectBatchTableSize.
  ///
  /// In en, this message translates to:
  /// **'{rows, plural, =1{1 row} other{{rows} rows}} · {columns, plural, =1{1 column} other{{columns} columns}}'**
  String projectBatchTableSize(int rows, int columns);

  /// No description provided for @projectBatchMatchColumns.
  ///
  /// In en, this message translates to:
  /// **'Match columns'**
  String get projectBatchMatchColumns;

  /// No description provided for @projectBatchMatchColumnsBody.
  ///
  /// In en, this message translates to:
  /// **'{mapped} of {total} columns match a field. Change any match, or skip a column. Your changes are remembered for files with the same columns.'**
  String projectBatchMatchColumnsBody(int mapped, int total);

  /// No description provided for @projectBatchKeyColumn.
  ///
  /// In en, this message translates to:
  /// **'Key column'**
  String get projectBatchKeyColumn;

  /// No description provided for @projectBatchKeyColumnMissing.
  ///
  /// In en, this message translates to:
  /// **'Map a column to one of: {keys}.'**
  String projectBatchKeyColumnMissing(String keys);

  /// No description provided for @projectBatchKeyColumnBody.
  ///
  /// In en, this message translates to:
  /// **'Rows update the record with the same value.'**
  String get projectBatchKeyColumnBody;

  /// No description provided for @projectBatchMatchRecordsBy.
  ///
  /// In en, this message translates to:
  /// **'Match records by'**
  String get projectBatchMatchRecordsBy;

  /// No description provided for @projectBatchNoValues.
  ///
  /// In en, this message translates to:
  /// **'No values'**
  String get projectBatchNoValues;

  /// No description provided for @projectBatchNahpuField.
  ///
  /// In en, this message translates to:
  /// **'NAHPU field'**
  String get projectBatchNahpuField;

  /// No description provided for @projectBatchSkipColumn.
  ///
  /// In en, this message translates to:
  /// **'Skip column'**
  String get projectBatchSkipColumn;

  /// No description provided for @projectBatchFieldInUse.
  ///
  /// In en, this message translates to:
  /// **'{field} (in use)'**
  String projectBatchFieldInUse(String field);

  /// No description provided for @projectBatchNameMatch.
  ///
  /// In en, this message translates to:
  /// **'Name match'**
  String get projectBatchNameMatch;

  /// No description provided for @projectBatchCloseMatch.
  ///
  /// In en, this message translates to:
  /// **'Close match {percent}%'**
  String projectBatchCloseMatch(int percent);

  /// No description provided for @projectBatchSkippedByYou.
  ///
  /// In en, this message translates to:
  /// **'Skipped by you'**
  String get projectBatchSkippedByYou;

  /// No description provided for @projectBatchYourChoice.
  ///
  /// In en, this message translates to:
  /// **'Your choice'**
  String get projectBatchYourChoice;

  /// No description provided for @projectBatchSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get projectBatchSearch;

  /// No description provided for @projectBatchLoadRecordsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load records: {error}'**
  String projectBatchLoadRecordsFailed(String error);

  /// No description provided for @projectBatchNoMatchingRecords.
  ///
  /// In en, this message translates to:
  /// **'No matching records.'**
  String get projectBatchNoMatchingRecords;

  /// No description provided for @projectBatchNoOtherGroup.
  ///
  /// In en, this message translates to:
  /// **'There is no other group to merge with.'**
  String get projectBatchNoOtherGroup;

  /// No description provided for @projectBatchMoveToNewGroup.
  ///
  /// In en, this message translates to:
  /// **'Move to new group'**
  String get projectBatchMoveToNewGroup;

  /// No description provided for @projectBatchCheckGroups.
  ///
  /// In en, this message translates to:
  /// **'Check groups'**
  String get projectBatchCheckGroups;

  /// No description provided for @projectBatchCheckGroupsBody.
  ///
  /// In en, this message translates to:
  /// **'Rows that describe the same site or event are grouped. Link a group to a record the project has, merge groups that are the same place or visit, or split rows out.'**
  String get projectBatchCheckGroupsBody;

  /// No description provided for @projectBatchSitesCount.
  ///
  /// In en, this message translates to:
  /// **'Sites ({count})'**
  String projectBatchSitesCount(int count);

  /// No description provided for @projectBatchEventsCount.
  ///
  /// In en, this message translates to:
  /// **'Events ({count})'**
  String projectBatchEventsCount(int count);

  /// No description provided for @projectBatchSpecimensCount.
  ///
  /// In en, this message translates to:
  /// **'Specimens ({count})'**
  String projectBatchSpecimensCount(int count);

  /// No description provided for @projectBatchNoSiteColumns.
  ///
  /// In en, this message translates to:
  /// **'No columns describe a site.'**
  String get projectBatchNoSiteColumns;

  /// No description provided for @projectBatchNoEventColumns.
  ///
  /// In en, this message translates to:
  /// **'No columns describe an event.'**
  String get projectBatchNoEventColumns;

  /// No description provided for @projectBatchNoSpecimenColumns.
  ///
  /// In en, this message translates to:
  /// **'No columns describe a specimen.'**
  String get projectBatchNoSpecimenColumns;

  /// No description provided for @projectBatchNewSite.
  ///
  /// In en, this message translates to:
  /// **'New site'**
  String get projectBatchNewSite;

  /// No description provided for @projectBatchEventCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event} other{{count} events}}'**
  String projectBatchEventCount(int count);

  /// No description provided for @projectBatchSpecimenCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 specimen} other{{count} specimens}}'**
  String projectBatchSpecimenCount(int count);

  /// No description provided for @projectBatchPartCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 part} other{{count} parts}}'**
  String projectBatchPartCount(int count);

  /// No description provided for @projectBatchSetSiteId.
  ///
  /// In en, this message translates to:
  /// **'Set site ID'**
  String get projectBatchSetSiteId;

  /// No description provided for @projectBatchLinkSite.
  ///
  /// In en, this message translates to:
  /// **'Link to an existing site'**
  String get projectBatchLinkSite;

  /// No description provided for @projectBatchMergeIntoSite.
  ///
  /// In en, this message translates to:
  /// **'Merge into site'**
  String get projectBatchMergeIntoSite;

  /// No description provided for @projectBatchMoveRowsToSite.
  ///
  /// In en, this message translates to:
  /// **'Move rows to a new site'**
  String get projectBatchMoveRowsToSite;

  /// No description provided for @projectBatchRow.
  ///
  /// In en, this message translates to:
  /// **'Row {row}'**
  String projectBatchRow(String row);

  /// No description provided for @projectBatchRows.
  ///
  /// In en, this message translates to:
  /// **'Rows {rows}'**
  String projectBatchRows(String rows);

  /// No description provided for @projectBatchRowsMore.
  ///
  /// In en, this message translates to:
  /// **'Rows {rows} and {count} more'**
  String projectBatchRowsMore(int count, String rows);

  /// No description provided for @projectBatchNoSite.
  ///
  /// In en, this message translates to:
  /// **'No site'**
  String get projectBatchNoSite;

  /// No description provided for @projectBatchNoEvent.
  ///
  /// In en, this message translates to:
  /// **'No event'**
  String get projectBatchNoEvent;

  /// No description provided for @projectBatchEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Event: {event}'**
  String projectBatchEventLabel(String event);

  /// No description provided for @projectBatchSetIdSuffix.
  ///
  /// In en, this message translates to:
  /// **'Set ID suffix'**
  String get projectBatchSetIdSuffix;

  /// No description provided for @projectBatchLinkEvent.
  ///
  /// In en, this message translates to:
  /// **'Link to an existing event'**
  String get projectBatchLinkEvent;

  /// No description provided for @projectBatchSetEventIdSuffix.
  ///
  /// In en, this message translates to:
  /// **'Set event ID suffix'**
  String get projectBatchSetEventIdSuffix;

  /// No description provided for @projectBatchMergeIntoEvent.
  ///
  /// In en, this message translates to:
  /// **'Merge into event'**
  String get projectBatchMergeIntoEvent;

  /// No description provided for @projectBatchMoveRowsToEvent.
  ///
  /// In en, this message translates to:
  /// **'Move rows to a new event'**
  String get projectBatchMoveRowsToEvent;

  /// No description provided for @projectBatchExcluded.
  ///
  /// In en, this message translates to:
  /// **'Excluded'**
  String get projectBatchExcluded;

  /// No description provided for @projectBatchCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get projectBatchCheck;

  /// No description provided for @projectBatchLinksToExisting.
  ///
  /// In en, this message translates to:
  /// **'Links to existing'**
  String get projectBatchLinksToExisting;

  /// No description provided for @projectBatchChangeGroup.
  ///
  /// In en, this message translates to:
  /// **'Change group'**
  String get projectBatchChangeGroup;

  /// No description provided for @projectBatchLinkExisting.
  ///
  /// In en, this message translates to:
  /// **'Link to existing…'**
  String get projectBatchLinkExisting;

  /// No description provided for @projectBatchCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new instead'**
  String get projectBatchCreateNew;

  /// No description provided for @projectBatchMergeInto.
  ///
  /// In en, this message translates to:
  /// **'Merge into…'**
  String get projectBatchMergeInto;

  /// No description provided for @projectBatchSplitRows.
  ///
  /// In en, this message translates to:
  /// **'Split rows…'**
  String get projectBatchSplitRows;

  /// No description provided for @projectBatchLinkedReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Sites are written first, then events at them, then specimens and their parts.'**
  String get projectBatchLinkedReviewBody;

  /// No description provided for @projectBatchSitesSummary.
  ///
  /// In en, this message translates to:
  /// **'Sites: {created} new, {linked} linked'**
  String projectBatchSitesSummary(int created, int linked);

  /// No description provided for @projectBatchEventsSummary.
  ///
  /// In en, this message translates to:
  /// **'Events: {created} new, {linked} linked'**
  String projectBatchEventsSummary(int created, int linked);

  /// No description provided for @projectBatchSpecimensSummary.
  ///
  /// In en, this message translates to:
  /// **'Specimens: {count}'**
  String projectBatchSpecimensSummary(int count);

  /// No description provided for @projectBatchPartsSummary.
  ///
  /// In en, this message translates to:
  /// **'Parts: {count}'**
  String projectBatchPartsSummary(int count);

  /// No description provided for @projectBatchRowsSkipped.
  ///
  /// In en, this message translates to:
  /// **'Rows skipped: {count}'**
  String projectBatchRowsSkipped(int count);

  /// No description provided for @projectBatchImportSpecimensMissingLinks.
  ///
  /// In en, this message translates to:
  /// **'Import specimens with missing links'**
  String get projectBatchImportSpecimensMissingLinks;

  /// No description provided for @projectBatchImportSpecimensMissingLinksBody.
  ///
  /// In en, this message translates to:
  /// **'The taxon or person stays empty. Add it to the project first to link it.'**
  String get projectBatchImportSpecimensMissingLinksBody;

  /// No description provided for @projectBatchWritingRecords.
  ///
  /// In en, this message translates to:
  /// **'Writing {done} of {total} records'**
  String projectBatchWritingRecords(int done, int total);

  /// No description provided for @projectBatchWritingRows.
  ///
  /// In en, this message translates to:
  /// **'Writing {done} of {total} rows'**
  String projectBatchWritingRows(int done, int total);

  /// No description provided for @projectBatchNoProblems.
  ///
  /// In en, this message translates to:
  /// **'No problems found.'**
  String get projectBatchNoProblems;

  /// No description provided for @projectBatchMoreRows.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{And 1 more row.} other{And {count} more rows.}}'**
  String projectBatchMoreRows(int count);

  /// No description provided for @projectBatchSiteProblem.
  ///
  /// In en, this message translates to:
  /// **'Site {site}: {message}'**
  String projectBatchSiteProblem(String site, String message);

  /// No description provided for @projectBatchSpecimenSkipped.
  ///
  /// In en, this message translates to:
  /// **'Specimen skipped: {status}.'**
  String projectBatchSpecimenSkipped(String status);

  /// No description provided for @projectBatchExcludedRow.
  ///
  /// In en, this message translates to:
  /// **'Excluded.'**
  String get projectBatchExcludedRow;

  /// No description provided for @projectBatchDoneWithErrors.
  ///
  /// In en, this message translates to:
  /// **'Done, with errors'**
  String get projectBatchDoneWithErrors;

  /// No description provided for @projectBatchAddedSpecimensParts.
  ///
  /// In en, this message translates to:
  /// **'Added {specimens, plural, =1{1 specimen} other{{specimens} specimens}} and {parts, plural, =1{1 part} other{{parts} parts}}.'**
  String projectBatchAddedSpecimensParts(int specimens, int parts);

  /// No description provided for @projectBatchRowsWithErrors.
  ///
  /// In en, this message translates to:
  /// **'Rows with errors: {count}'**
  String projectBatchRowsWithErrors(int count);

  /// No description provided for @projectBatchOpenSpecimenTable.
  ///
  /// In en, this message translates to:
  /// **'Open specimen records table'**
  String get projectBatchOpenSpecimenTable;

  /// No description provided for @projectBatchUpdatedRecords.
  ///
  /// In en, this message translates to:
  /// **'Updated {count} {records}.'**
  String projectBatchUpdatedRecords(int count, String records);

  /// No description provided for @projectBatchAddedRecords.
  ///
  /// In en, this message translates to:
  /// **'Added {count} {records}.'**
  String projectBatchAddedRecords(int count, String records);

  /// No description provided for @projectBatchUpdatedCount.
  ///
  /// In en, this message translates to:
  /// **'Updated: {count}'**
  String projectBatchUpdatedCount(int count);

  /// No description provided for @projectBatchAddedCount.
  ///
  /// In en, this message translates to:
  /// **'Added: {count}'**
  String projectBatchAddedCount(int count);

  /// No description provided for @projectBatchSkippedInReview.
  ///
  /// In en, this message translates to:
  /// **'Skipped in review: {count}'**
  String projectBatchSkippedInReview(int count);

  /// No description provided for @projectBatchFailedCount.
  ///
  /// In en, this message translates to:
  /// **'Failed: {count}'**
  String projectBatchFailedCount(int count);

  /// No description provided for @projectBatchOpenTable.
  ///
  /// In en, this message translates to:
  /// **'Open {records} table'**
  String projectBatchOpenTable(String records);

  /// No description provided for @projectBatchReviewUpdate.
  ///
  /// In en, this message translates to:
  /// **'This will update {count} of {total} {records}. Rows with problems are skipped.'**
  String projectBatchReviewUpdate(int count, int total, String records);

  /// No description provided for @projectBatchReviewAdd.
  ///
  /// In en, this message translates to:
  /// **'This will add {count} of {total} {records}. Rows with problems are skipped.'**
  String projectBatchReviewAdd(int count, int total, String records);

  /// No description provided for @projectBatchImportRowsMissingLinks.
  ///
  /// In en, this message translates to:
  /// **'Import rows with missing links'**
  String get projectBatchImportRowsMissingLinks;

  /// No description provided for @projectBatchImportRowsMissingLinksBody.
  ///
  /// In en, this message translates to:
  /// **'The taxon, person, site, or event stays empty. Add it to the project first to link it.'**
  String get projectBatchImportRowsMissingLinksBody;

  /// No description provided for @projectStatsPartQuantity.
  ///
  /// In en, this message translates to:
  /// **'Part quantity'**
  String get projectStatsPartQuantity;

  /// No description provided for @projectStatsQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get projectStatsQuantity;

  /// No description provided for @projectStatsSite.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get projectStatsSite;

  /// No description provided for @projectStatsDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get projectStatsDate;

  /// No description provided for @projectStatsMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get projectStatsMethod;

  /// No description provided for @projectStatsSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get projectStatsSex;

  /// No description provided for @projectStatsLifeStage.
  ///
  /// In en, this message translates to:
  /// **'Life stage'**
  String get projectStatsLifeStage;

  /// No description provided for @projectStatsPartType.
  ///
  /// In en, this message translates to:
  /// **'Part type'**
  String get projectStatsPartType;

  /// No description provided for @projectStatsTreatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get projectStatsTreatment;

  /// Chart title. The category is lowercase.
  ///
  /// In en, this message translates to:
  /// **'{measure} by {category}'**
  String projectStatsTitle(String measure, String category);

  /// No description provided for @projectStatsTitleWithBreakdown.
  ///
  /// In en, this message translates to:
  /// **'{measure} by {category} and {breakdown}'**
  String projectStatsTitleWithBreakdown(
    String measure,
    String category,
    String breakdown,
  );

  /// No description provided for @projectStatsTitleAtSite.
  ///
  /// In en, this message translates to:
  /// **'{title} at {site}'**
  String projectStatsTitleAtSite(String title, String site);

  /// No description provided for @projectStatsTitleForSpecies.
  ///
  /// In en, this message translates to:
  /// **'{title} for {species}'**
  String projectStatsTitleForSpecies(String title, String species);

  /// No description provided for @projectStatsCoordinatesBySpecies.
  ///
  /// In en, this message translates to:
  /// **'Coordinates by species'**
  String get projectStatsCoordinatesBySpecies;

  /// No description provided for @projectStatsSpatialSpecimensTitle.
  ///
  /// In en, this message translates to:
  /// **'Specimen counts by site coordinates'**
  String get projectStatsSpatialSpecimensTitle;

  /// No description provided for @projectStatsSpatialSpeciesTitle.
  ///
  /// In en, this message translates to:
  /// **'Species counts by site coordinates'**
  String get projectStatsSpatialSpeciesTitle;

  /// No description provided for @projectStatsSpatialFamiliesTitle.
  ///
  /// In en, this message translates to:
  /// **'Family counts by site coordinates'**
  String get projectStatsSpatialFamiliesTitle;

  /// No description provided for @projectStatsSpatialSelectedSpeciesTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected species counts by coordinates'**
  String get projectStatsSpatialSelectedSpeciesTitle;

  /// No description provided for @projectStatsCountSpecimens.
  ///
  /// In en, this message translates to:
  /// **'specimens'**
  String get projectStatsCountSpecimens;

  /// No description provided for @projectStatsCountSpecies.
  ///
  /// In en, this message translates to:
  /// **'species'**
  String get projectStatsCountSpecies;

  /// No description provided for @projectStatsCountFamilies.
  ///
  /// In en, this message translates to:
  /// **'families'**
  String get projectStatsCountFamilies;

  /// No description provided for @projectStatsClasses.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get projectStatsClasses;

  /// No description provided for @projectStatsOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get projectStatsOrders;

  /// No description provided for @projectStatsFamilies.
  ///
  /// In en, this message translates to:
  /// **'Families'**
  String get projectStatsFamilies;

  /// No description provided for @projectStatsGenera.
  ///
  /// In en, this message translates to:
  /// **'Genera'**
  String get projectStatsGenera;

  /// No description provided for @projectStatsSpecimenMedia.
  ///
  /// In en, this message translates to:
  /// **'Specimen media'**
  String get projectStatsSpecimenMedia;

  /// No description provided for @projectStatsSiteMedia.
  ///
  /// In en, this message translates to:
  /// **'Site media'**
  String get projectStatsSiteMedia;

  /// No description provided for @projectStatsEventMedia.
  ///
  /// In en, this message translates to:
  /// **'Event media'**
  String get projectStatsEventMedia;

  /// No description provided for @projectStatsNarrativeMedia.
  ///
  /// In en, this message translates to:
  /// **'Narrative media'**
  String get projectStatsNarrativeMedia;

  /// No description provided for @projectStatsRecordedSites.
  ///
  /// In en, this message translates to:
  /// **'Recorded sites'**
  String get projectStatsRecordedSites;

  /// No description provided for @projectStatsSampledSites.
  ///
  /// In en, this message translates to:
  /// **'Sampled sites'**
  String get projectStatsSampledSites;

  /// No description provided for @projectStatsCaptureDays.
  ///
  /// In en, this message translates to:
  /// **'Capture days'**
  String get projectStatsCaptureDays;

  /// No description provided for @projectStatsProjectDays.
  ///
  /// In en, this message translates to:
  /// **'Project days'**
  String get projectStatsProjectDays;

  /// No description provided for @projectStatsRecordedElevation.
  ///
  /// In en, this message translates to:
  /// **'Recorded elevation'**
  String get projectStatsRecordedElevation;

  /// No description provided for @projectStatsSampledElevation.
  ///
  /// In en, this message translates to:
  /// **'Sampled elevation'**
  String get projectStatsSampledElevation;

  /// No description provided for @projectStatsNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get projectStatsNotRecorded;

  /// No description provided for @projectStatsRecordStatistics.
  ///
  /// In en, this message translates to:
  /// **'Record statistics'**
  String get projectStatsRecordStatistics;

  /// No description provided for @projectStatsTopSpecies.
  ///
  /// In en, this message translates to:
  /// **'Top recorded species'**
  String get projectStatsTopSpecies;

  /// No description provided for @projectStatsRecordCounts.
  ///
  /// In en, this message translates to:
  /// **'Record counts'**
  String get projectStatsRecordCounts;

  /// No description provided for @projectStatsShowRecordCounts.
  ///
  /// In en, this message translates to:
  /// **'Show record counts'**
  String get projectStatsShowRecordCounts;

  /// No description provided for @projectStatsShowTopSpecies.
  ///
  /// In en, this message translates to:
  /// **'Show top recorded species'**
  String get projectStatsShowTopSpecies;

  /// No description provided for @projectStatsExploreMore.
  ///
  /// In en, this message translates to:
  /// **'Explore more stats'**
  String get projectStatsExploreMore;

  /// No description provided for @projectStatsRecordLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load record statistics: {error}'**
  String projectStatsRecordLoadError(String error);

  /// No description provided for @projectStatsSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get projectStatsSummary;

  /// No description provided for @projectStatsExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get projectStatsExplore;

  /// No description provided for @projectStatsTotalAllProjects.
  ///
  /// In en, this message translates to:
  /// **'Total across all projects'**
  String get projectStatsTotalAllProjects;

  /// No description provided for @projectStatsGroupBy.
  ///
  /// In en, this message translates to:
  /// **'Group by'**
  String get projectStatsGroupBy;

  /// No description provided for @projectStatsSelectSite.
  ///
  /// In en, this message translates to:
  /// **'Select a site'**
  String get projectStatsSelectSite;

  /// No description provided for @projectStatsAllSites.
  ///
  /// In en, this message translates to:
  /// **'All sites'**
  String get projectStatsAllSites;

  /// No description provided for @projectStatsSelectSpecies.
  ///
  /// In en, this message translates to:
  /// **'Select a species'**
  String get projectStatsSelectSpecies;

  /// No description provided for @projectStatsAllSpecies.
  ///
  /// In en, this message translates to:
  /// **'All species'**
  String get projectStatsAllSpecies;

  /// No description provided for @projectStatsChart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get projectStatsChart;

  /// No description provided for @projectStatsTable.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get projectStatsTable;

  /// No description provided for @projectStatsRecordSummary.
  ///
  /// In en, this message translates to:
  /// **'Record summary'**
  String get projectStatsRecordSummary;

  /// No description provided for @projectStatsTaxonomicBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Taxonomic breakdown'**
  String get projectStatsTaxonomicBreakdown;

  /// No description provided for @projectStatsMediaBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Media breakdown'**
  String get projectStatsMediaBreakdown;

  /// No description provided for @projectStatsPerProject.
  ///
  /// In en, this message translates to:
  /// **'Per project'**
  String get projectStatsPerProject;

  /// No description provided for @projectStatsNoProjects.
  ///
  /// In en, this message translates to:
  /// **'No projects yet.'**
  String get projectStatsNoProjects;

  /// No description provided for @projectStatsProjectLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load project statistics: {error}'**
  String projectStatsProjectLoadError(String error);

  /// No description provided for @projectStatsViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get projectStatsViewDetails;

  /// No description provided for @projectStatsBreakDownBy.
  ///
  /// In en, this message translates to:
  /// **'Break down by'**
  String get projectStatsBreakDownBy;

  /// No description provided for @projectStatsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load statistics: {error}'**
  String projectStatsLoadError(String error);

  /// No description provided for @projectStatsSpecimensBySpecies.
  ///
  /// In en, this message translates to:
  /// **'Specimens by species'**
  String get projectStatsSpecimensBySpecies;

  /// No description provided for @projectStatsSpecimensByFamily.
  ///
  /// In en, this message translates to:
  /// **'Specimens by family'**
  String get projectStatsSpecimensByFamily;

  /// No description provided for @projectStatsSpecimensBySite.
  ///
  /// In en, this message translates to:
  /// **'Specimens by site'**
  String get projectStatsSpecimensBySite;

  /// No description provided for @projectStatsSpecimensByDate.
  ///
  /// In en, this message translates to:
  /// **'Specimens by date'**
  String get projectStatsSpecimensByDate;

  /// No description provided for @projectStatsSpecimensByMethod.
  ///
  /// In en, this message translates to:
  /// **'Specimens by method'**
  String get projectStatsSpecimensByMethod;

  /// No description provided for @projectStatsSpecimensBySex.
  ///
  /// In en, this message translates to:
  /// **'Specimens by sex'**
  String get projectStatsSpecimensBySex;

  /// No description provided for @projectStatsPartQuantityByType.
  ///
  /// In en, this message translates to:
  /// **'Part quantity by type'**
  String get projectStatsPartQuantityByType;

  /// No description provided for @projectStatsPartQuantityByTreatment.
  ///
  /// In en, this message translates to:
  /// **'Part quantity by treatment'**
  String get projectStatsPartQuantityByTreatment;

  /// No description provided for @projectStatsCounts.
  ///
  /// In en, this message translates to:
  /// **'Counts'**
  String get projectStatsCounts;

  /// No description provided for @projectStatsSpatial.
  ///
  /// In en, this message translates to:
  /// **'Spatial'**
  String get projectStatsSpatial;

  /// No description provided for @projectStatsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data to display'**
  String get projectStatsNoData;

  /// No description provided for @projectStatsTapToView.
  ///
  /// In en, this message translates to:
  /// **'{label}\nTap to view records'**
  String projectStatsTapToView(String label);

  /// No description provided for @projectStatsShowBarChart.
  ///
  /// In en, this message translates to:
  /// **'Show bar chart'**
  String get projectStatsShowBarChart;

  /// No description provided for @projectStatsShowPieChart.
  ///
  /// In en, this message translates to:
  /// **'Show pie chart'**
  String get projectStatsShowPieChart;

  /// No description provided for @projectStatsClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get projectStatsClearSelection;

  /// No description provided for @projectStatsChoicesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load choices: {error}'**
  String projectStatsChoicesLoadError(String error);

  /// No description provided for @projectStatsNoMatchingChoices.
  ///
  /// In en, this message translates to:
  /// **'No matching choices'**
  String get projectStatsNoMatchingChoices;

  /// No description provided for @projectStatsNoRecordsInGroup.
  ///
  /// In en, this message translates to:
  /// **'No records in this group.'**
  String get projectStatsNoRecordsInGroup;

  /// No description provided for @projectStatsShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get projectStatsShow;

  /// No description provided for @projectStatsSpeciesCountsByCoordinates.
  ///
  /// In en, this message translates to:
  /// **'{species} counts by coordinates'**
  String projectStatsSpeciesCountsByCoordinates(String species);

  /// No description provided for @projectStatsMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get projectStatsMap;

  /// No description provided for @projectStatsSpatialLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load spatial statistics: {error}'**
  String projectStatsSpatialLoadError(String error);

  /// No description provided for @projectStatsNoSpecimenCoords.
  ///
  /// In en, this message translates to:
  /// **'No specimens are assigned to project coordinates.'**
  String get projectStatsNoSpecimenCoords;

  /// No description provided for @projectStatsNoSpeciesCoords.
  ///
  /// In en, this message translates to:
  /// **'No species are associated with project coordinates.'**
  String get projectStatsNoSpeciesCoords;

  /// No description provided for @projectStatsNoFamilyCoords.
  ///
  /// In en, this message translates to:
  /// **'No families are associated with project coordinates.'**
  String get projectStatsNoFamilyCoords;

  /// No description provided for @projectStatsNoSelectedSpeciesCoords.
  ///
  /// In en, this message translates to:
  /// **'No specimens of the selected species are assigned to project coordinates.'**
  String get projectStatsNoSelectedSpeciesCoords;

  /// No description provided for @projectStatsNoSpeciesCoordsFor.
  ///
  /// In en, this message translates to:
  /// **'No specimens of {species} are assigned to project coordinates.'**
  String projectStatsNoSpeciesCoordsFor(String species);

  /// No description provided for @projectStatsCoordinateLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Coordinate} other{Coordinates}}'**
  String projectStatsCoordinateLabel(int count);

  /// No description provided for @projectStatsMeanPerCoordinate.
  ///
  /// In en, this message translates to:
  /// **'Mean {counted} per coordinate'**
  String projectStatsMeanPerCoordinate(String counted);

  /// No description provided for @projectStatsTopCoordinate.
  ///
  /// In en, this message translates to:
  /// **'Top coordinate'**
  String get projectStatsTopCoordinate;

  /// No description provided for @projectStatsTopValue.
  ///
  /// In en, this message translates to:
  /// **'Top: {name}'**
  String projectStatsTopValue(String name);

  /// No description provided for @projectStatsCategoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Category ({category})} other{Categories ({category})}}'**
  String projectStatsCategoryCount(int count, String category);

  /// No description provided for @projectStatsMeanPerCategory.
  ///
  /// In en, this message translates to:
  /// **'Mean {counted} per category'**
  String projectStatsMeanPerCategory(String counted);

  /// No description provided for @projectStatsTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get projectStatsTopCategory;

  /// No description provided for @projectStatsTopCategoryShare.
  ///
  /// In en, this message translates to:
  /// **'Top category share'**
  String get projectStatsTopCategoryShare;

  /// No description provided for @projectStatsTotalCount.
  ///
  /// In en, this message translates to:
  /// **'Total count: {value}'**
  String projectStatsTotalCount(String value);

  /// No description provided for @projectStatsElevation.
  ///
  /// In en, this message translates to:
  /// **'Elevation'**
  String get projectStatsElevation;

  /// No description provided for @projectStatsSelectSpeciesPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a species to view coordinate abundance.'**
  String get projectStatsSelectSpeciesPrompt;

  /// No description provided for @projectStatsCollapseLegend.
  ///
  /// In en, this message translates to:
  /// **'Collapse map legend'**
  String get projectStatsCollapseLegend;

  /// No description provided for @projectStatsExpandLegend.
  ///
  /// In en, this message translates to:
  /// **'Expand map legend'**
  String get projectStatsExpandLegend;

  /// No description provided for @projectStatsLegend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get projectStatsLegend;

  /// No description provided for @projectStatsLegendCircle.
  ///
  /// In en, this message translates to:
  /// **'Each circle represents\none coordinate'**
  String get projectStatsLegendCircle;

  /// No description provided for @projectStatsLegendGrouped.
  ///
  /// In en, this message translates to:
  /// **'Grouped sites,\nzoom in to split'**
  String get projectStatsLegendGrouped;

  /// No description provided for @projectStatsUnmappedRecords.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 record is listed in the table but cannot be mapped because latitude or longitude is missing or invalid.} other{{count} records are listed in the table but cannot be mapped because latitude or longitude is missing or invalid.}}'**
  String projectStatsUnmappedRecords(int count);

  /// No description provided for @projectStatsSpatialMap.
  ///
  /// In en, this message translates to:
  /// **'Spatial statistics map'**
  String get projectStatsSpatialMap;

  /// No description provided for @projectStatsMapLayers.
  ///
  /// In en, this message translates to:
  /// **'Map layers'**
  String get projectStatsMapLayers;

  /// No description provided for @projectStatsViewFullScreen.
  ///
  /// In en, this message translates to:
  /// **'View map full screen'**
  String get projectStatsViewFullScreen;

  /// No description provided for @projectStatsNaturalEarthError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the offline Natural Earth map.'**
  String get projectStatsNaturalEarthError;

  /// No description provided for @projectStatsNoValidCoordinates.
  ///
  /// In en, this message translates to:
  /// **'No valid coordinates are available to map.'**
  String get projectStatsNoValidCoordinates;

  /// No description provided for @projectStatsMapPrepareError.
  ///
  /// In en, this message translates to:
  /// **'Unable to prepare the map: {error}'**
  String projectStatsMapPrepareError(String error);

  /// No description provided for @projectStatsZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get projectStatsZoomIn;

  /// No description provided for @projectStatsZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get projectStatsZoomOut;

  /// No description provided for @projectStatsCenterMap.
  ///
  /// In en, this message translates to:
  /// **'Center map on statistics'**
  String get projectStatsCenterMap;

  /// No description provided for @projectStatsSiteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 site} other{{count} sites}}'**
  String projectStatsSiteCount(int count);

  /// No description provided for @projectStatsExportTable.
  ///
  /// In en, this message translates to:
  /// **'Export table'**
  String get projectStatsExportTable;

  /// No description provided for @projectStatsColumnName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get projectStatsColumnName;

  /// No description provided for @projectStatsColumnLocality.
  ///
  /// In en, this message translates to:
  /// **'Locality'**
  String get projectStatsColumnLocality;

  /// No description provided for @projectStatsColumnDecimalLatitude.
  ///
  /// In en, this message translates to:
  /// **'Decimal latitude'**
  String get projectStatsColumnDecimalLatitude;

  /// No description provided for @projectStatsColumnDecimalLongitude.
  ///
  /// In en, this message translates to:
  /// **'Decimal longitude'**
  String get projectStatsColumnDecimalLongitude;

  /// No description provided for @projectStatsColumnElevation.
  ///
  /// In en, this message translates to:
  /// **'Elevation (m)'**
  String get projectStatsColumnElevation;

  /// No description provided for @projectStatsColumnDatum.
  ///
  /// In en, this message translates to:
  /// **'Datum'**
  String get projectStatsColumnDatum;

  /// No description provided for @projectStatsColumnUncertainty.
  ///
  /// In en, this message translates to:
  /// **'Uncertainty (m)'**
  String get projectStatsColumnUncertainty;

  /// No description provided for @projectStatsColumnGpsUnit.
  ///
  /// In en, this message translates to:
  /// **'GPS unit'**
  String get projectStatsColumnGpsUnit;

  /// No description provided for @projectStatsColumnLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get projectStatsColumnLatitude;

  /// No description provided for @projectStatsColumnLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get projectStatsColumnLongitude;

  /// No description provided for @projectStatsColumnCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get projectStatsColumnCount;

  /// No description provided for @projectStatsColumnPercent.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get projectStatsColumnPercent;

  /// No description provided for @projectStatsColumnCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get projectStatsColumnCategory;

  /// No description provided for @projectStatsViewRecords.
  ///
  /// In en, this message translates to:
  /// **'View records'**
  String get projectStatsViewRecords;

  /// No description provided for @projectStatsExportStatisticsTable.
  ///
  /// In en, this message translates to:
  /// **'Export statistics table'**
  String get projectStatsExportStatisticsTable;

  /// No description provided for @projectStatsExportSpatialTable.
  ///
  /// In en, this message translates to:
  /// **'Export spatial statistics table'**
  String get projectStatsExportSpatialTable;

  /// No description provided for @projectStatsExportError.
  ///
  /// In en, this message translates to:
  /// **'Unable to export statistics: {error}'**
  String projectStatsExportError(String error);

  /// No description provided for @projectStatsExportComplete.
  ///
  /// In en, this message translates to:
  /// **'Export complete'**
  String get projectStatsExportComplete;

  /// No description provided for @projectStatsShareError.
  ///
  /// In en, this message translates to:
  /// **'Unable to share statistics: {error}'**
  String projectStatsShareError(String error);

  /// Specimen part field for the museum's permanent tissue number.
  ///
  /// In en, this message translates to:
  /// **'Museum permanent'**
  String get projectTissueMuseumPermanent;

  /// No description provided for @projectTissueMuseumLoan.
  ///
  /// In en, this message translates to:
  /// **'Museum loan'**
  String get projectTissueMuseumLoan;

  /// No description provided for @projectTissueIdOrBarcode.
  ///
  /// In en, this message translates to:
  /// **'Tissue ID or barcode'**
  String get projectTissueIdOrBarcode;

  /// No description provided for @projectTissueFillRows.
  ///
  /// In en, this message translates to:
  /// **'Rows, left to right'**
  String get projectTissueFillRows;

  /// No description provided for @projectTissueFillColumns.
  ///
  /// In en, this message translates to:
  /// **'Columns, top to bottom'**
  String get projectTissueFillColumns;

  /// No description provided for @projectTissueFillSerpentine.
  ///
  /// In en, this message translates to:
  /// **'Serpentine rows'**
  String get projectTissueFillSerpentine;

  /// No description provided for @projectTissueEntryScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get projectTissueEntryScan;

  /// No description provided for @projectTissueEntryWorkList.
  ///
  /// In en, this message translates to:
  /// **'Work list'**
  String get projectTissueEntryWorkList;

  /// No description provided for @projectTissueTitle.
  ///
  /// In en, this message translates to:
  /// **'Specimen curation'**
  String get projectTissueTitle;

  /// No description provided for @projectTissueFilledCount.
  ///
  /// In en, this message translates to:
  /// **'{filled} / {capacity} filled'**
  String projectTissueFilledCount(int filled, int capacity);

  /// No description provided for @projectTissueNextCell.
  ///
  /// In en, this message translates to:
  /// **'Next cell'**
  String get projectTissueNextCell;

  /// No description provided for @projectTissueFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get projectTissueFull;

  /// No description provided for @projectTissueNextBox.
  ///
  /// In en, this message translates to:
  /// **'Next box'**
  String get projectTissueNextBox;

  /// No description provided for @projectTissueCellFilled.
  ///
  /// In en, this message translates to:
  /// **'{cell} · filled'**
  String projectTissueCellFilled(String cell);

  /// No description provided for @projectTissueFilled.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get projectTissueFilled;

  /// No description provided for @projectTissueNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get projectTissueNext;

  /// No description provided for @projectTissueTapEmptyCell.
  ///
  /// In en, this message translates to:
  /// **'Tap an empty cell to jump'**
  String get projectTissueTapEmptyCell;

  /// No description provided for @projectTissueScanTubes.
  ///
  /// In en, this message translates to:
  /// **'Scan tubes'**
  String get projectTissueScanTubes;

  /// No description provided for @projectTissueCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera scanning is unavailable. Use the scan field instead.'**
  String get projectTissueCameraUnavailable;

  /// No description provided for @projectTissueCameraError.
  ///
  /// In en, this message translates to:
  /// **'Unable to use the camera. Retry or use the scan field.'**
  String get projectTissueCameraError;

  /// No description provided for @projectTissueSessionLog.
  ///
  /// In en, this message translates to:
  /// **'Session log'**
  String get projectTissueSessionLog;

  /// No description provided for @projectTissueSessionLogCount.
  ///
  /// In en, this message translates to:
  /// **'Session log ({count})'**
  String projectTissueSessionLogCount(int count);

  /// No description provided for @projectTissueSessionLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'Checked tubes appear here.'**
  String get projectTissueSessionLogEmpty;

  /// No description provided for @projectTissueSeveralMatches.
  ///
  /// In en, this message translates to:
  /// **'Several parts match {code}'**
  String projectTissueSeveralMatches(String code);

  /// No description provided for @projectTissueCount.
  ///
  /// In en, this message translates to:
  /// **'Count {count}'**
  String projectTissueCount(String count);

  /// No description provided for @projectTissueAt.
  ///
  /// In en, this message translates to:
  /// **'At {location}'**
  String projectTissueAt(String location);

  /// No description provided for @projectTissueFindTubes.
  ///
  /// In en, this message translates to:
  /// **'Find tubes'**
  String get projectTissueFindTubes;

  /// No description provided for @projectTissueType.
  ///
  /// In en, this message translates to:
  /// **'Tissue type'**
  String get projectTissueType;

  /// No description provided for @projectTissuePreservation.
  ///
  /// In en, this message translates to:
  /// **'Preservation'**
  String get projectTissuePreservation;

  /// No description provided for @projectTissueUpdateField.
  ///
  /// In en, this message translates to:
  /// **'Update field'**
  String get projectTissueUpdateField;

  /// No description provided for @projectTissueField.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get projectTissueField;

  /// No description provided for @projectTissueValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get projectTissueValue;

  /// No description provided for @projectTissueMuseumCode.
  ///
  /// In en, this message translates to:
  /// **'Museum code'**
  String get projectTissueMuseumCode;

  /// No description provided for @projectTissueBoxSize.
  ///
  /// In en, this message translates to:
  /// **'Box size'**
  String get projectTissueBoxSize;

  /// No description provided for @projectTissueNumbering.
  ///
  /// In en, this message translates to:
  /// **'Numbering'**
  String get projectTissueNumbering;

  /// No description provided for @projectTissueFillOrder.
  ///
  /// In en, this message translates to:
  /// **'Fill order'**
  String get projectTissueFillOrder;

  /// No description provided for @projectTissueBoxLabel.
  ///
  /// In en, this message translates to:
  /// **'Box label'**
  String get projectTissueBoxLabel;

  /// No description provided for @projectTissueBoxHint.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get projectTissueBoxHint;

  /// No description provided for @projectTissueBoxNumber.
  ///
  /// In en, this message translates to:
  /// **'Box number'**
  String get projectTissueBoxNumber;

  /// No description provided for @projectTissueOverwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite existing values'**
  String get projectTissueOverwrite;

  /// No description provided for @projectTissueOverwriteBody.
  ///
  /// In en, this message translates to:
  /// **'Replace a stored location or a different field value'**
  String get projectTissueOverwriteBody;

  /// No description provided for @projectTissueAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get projectTissueAny;

  /// No description provided for @projectTissueScanTube.
  ///
  /// In en, this message translates to:
  /// **'Scan tube'**
  String get projectTissueScanTube;

  /// No description provided for @projectTissueScanHint.
  ///
  /// In en, this message translates to:
  /// **'Scan or type, then press Enter'**
  String get projectTissueScanHint;

  /// No description provided for @projectTissueScanWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan with camera'**
  String get projectTissueScanWithCamera;

  /// No description provided for @projectTissueUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get projectTissueUndo;

  /// No description provided for @projectTissueReady.
  ///
  /// In en, this message translates to:
  /// **'Ready. Scan the first tube.'**
  String get projectTissueReady;

  /// No description provided for @projectTissueWorkListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No unplaced parts match the tissue type and preservation filters.'**
  String get projectTissueWorkListEmpty;

  /// No description provided for @projectTissueRemaining.
  ///
  /// In en, this message translates to:
  /// **'Next · {count} remaining'**
  String projectTissueRemaining(int count);

  /// No description provided for @projectTissuePlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get projectTissuePlace;
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
