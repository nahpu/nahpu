import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/localization/l10n.dart';

class ControlledVocabularySetting extends ConsumerWidget {
  const ControlledVocabularySetting({
    super.key,
    required this.title,
    required this.typePrefKey,
    required this.fmtPrefKey,
    required this.typeName,
    required this.pluralName,
    this.showCard = true,
  });

  final String title;
  final String typePrefKey;
  final String fmtPrefKey;

  /// Localized singular noun for one value, as it reads mid-sentence.
  final String typeName;

  /// Localized plural noun for the values, as it reads mid-sentence.
  final String pluralName;

  /// Set false where the caller already supplies the card and the heading, so
  /// the field does not draw a second card inside the first.
  final bool showCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserDefinedSettingField(
          typePrefKey: typePrefKey,
          fmtPrefKey: fmtPrefKey,
          typeName: typeName,
          onCaseFormatPressed: () {
            _showCaseFormatPicker(context, ref, fmtPrefKey);
          },
          sectionTitle: showCard ? title : null,
          pluralName: pluralName,
        ),
      ],
    );
  }
}

Future<void> _showCaseFormatPicker(
  BuildContext context,
  WidgetRef ref,
  String prefKey,
) async {
  final isNarrow = MediaQuery.sizeOf(context).width < 600;
  final selected = isNarrow
      ? await showModalBottomSheet<TextCaseFmt>(
          context: context,
          isScrollControlled: true,
          builder: (context) => _CaseFormatPicker(prefKey: prefKey),
        )
      : await showDialog<TextCaseFmt>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.recordsVocabularyCaseFormat),
            content: SizedBox(
              width: 420,
              height: 300,
              child: _CaseFormatPicker(prefKey: prefKey),
            ),
          ),
        );

  if (!context.mounted || selected == null) return;
  await ref
      .read(userConfigSettingsServiceProvider)
      .setTextCaseFormat(prefKey, selected.name);
  ref.invalidate(textCaseFmtProvider(prefKey));
}

class _CaseFormatPicker extends ConsumerWidget {
  const _CaseFormatPicker({required this.prefKey});

  final String prefKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: ref
          .watch(textCaseFmtProvider(prefKey))
          .when(
            data: (current) => RadioGroup<TextCaseFmt>(
              groupValue: current,
              onChanged: (value) {
                if (value != null) Navigator.pop(context, value);
              },
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final format in TextCaseFmt.values)
                    RadioListTile<TextCaseFmt>(
                      value: format,
                      title: Text(_caseFormatLabel(context.l10n, format)),
                    ),
                ],
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: CommonProgressIndicator(),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                context.l10n.recordsVocabularyCaseFormatLoadError(
                  error.toString(),
                ),
              ),
            ),
          ),
    );
  }
}

String _caseFormatLabel(AppLocalizations l10n, TextCaseFmt format) {
  return switch (format) {
    TextCaseFmt.anyCase => l10n.recordsVocabularyCaseAny,
    TextCaseFmt.sentenceCase => l10n.recordsVocabularyCaseSentence,
    TextCaseFmt.titleCase => l10n.recordsVocabularyCaseTitle,
    TextCaseFmt.upperCase => l10n.recordsVocabularyCaseUpper,
    TextCaseFmt.lowerCase => l10n.recordsVocabularyCaseLower,
  };
}
