import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;
import 'package:nahpu/l10n/app_localizations.dart';
import 'package:nahpu/services/localization/app_language.dart';

export 'package:nahpu/l10n/app_localizations.dart';

/// Every delegate the app needs: NAHPU's strings plus the Material, Cupertino,
/// and widget strings from `material_ui`, whose Material widgets look up its
/// own localizations type.
const List<LocalizationsDelegate<dynamic>> nahpuLocalizationsDelegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

extension AppLocalizationsContext on BuildContext {
  /// NAHPU's strings in the UI language.
  ///
  /// Falls back to English where no [AppLocalizations] is in scope, such as a
  /// widget test that builds a bare app, so a screen never fails to render
  /// for want of a delegate.
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? localizationsFor(AppLanguage.english);

  /// The shipped language of the locale in scope, which documentation opens
  /// in. English where no locale is in scope.
  AppLanguage get appLanguage =>
      AppLanguage.resolve([?Localizations.maybeLocaleOf(this)]);
}

/// NAHPU's strings in [language], apart from the UI language. Documentation
/// uses it so a document's own labels match the language it is written in.
AppLocalizations localizationsFor(AppLanguage language) {
  return lookupAppLocalizations(language.locale);
}
