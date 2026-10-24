import 'package:nahpu/services/export/text_replacements.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// Localized messages for [TextReplacementRuleError].
extension TextReplacementRuleErrorLabel on TextReplacementRuleError {
  /// The error in the UI language. A regex parser detail stays as reported.
  String label(AppLocalizations l10n) => switch (this) {
    TextReplacementEmptyPattern() => l10n.textReplaceErrorEmptyPattern,
    TextReplacementInvalidRegex(:final detail) =>
      l10n.textReplaceErrorInvalidRegex(detail),
  };
}
