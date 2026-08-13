import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/common/utility_services.dart';

class ControlledVocabularySetting extends ConsumerWidget {
  const ControlledVocabularySetting({
    super.key,
    required this.title,
    required this.typePrefKey,
    required this.fmtPrefKey,
    required this.typeName,
    this.pluralName,
  });

  final String title;
  final String typePrefKey;
  final String fmtPrefKey;
  final String typeName;
  final String? pluralName;

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
          sectionTitle: title.toTitleCase(),
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
            title: const Text('Case format'),
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
                  for (final entry in textCaseFmtMap.entries)
                    RadioListTile<TextCaseFmt>(
                      value: entry.key,
                      title: Text(entry.value),
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
              child: Text('Unable to load case format: $error'),
            ),
          ),
    );
  }
}
