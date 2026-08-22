import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/controlled_vocabulary.dart';
import 'package:nahpu/services/types/events.dart';

class CollEventSelection extends StatefulWidget {
  const CollEventSelection({super.key});

  @override
  State<CollEventSelection> createState() => _CollEventSelectionState();
}

class _CollEventSelectionState extends State<CollEventSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collection Event Settings')),
      body: SafeArea(
        child: CommonSettingList(
          sections: const [
            ControlledVocabularySetting(
              title: 'Primary activities',
              typePrefKey: collActivityPrefKey,
              fmtPrefKey: collActivityFmtPrefKey,
              typeName: 'primary activity',
            ),
            ControlledVocabularySetting(
              title: 'Collection methods',
              typePrefKey: collMethodPrefKey,
              fmtPrefKey: collMethodFmtPrefKey,
              typeName: 'collection method',
            ),
            ControlledVocabularySetting(
              title: 'Personnel roles',
              typePrefKey: collRolePrefKey,
              fmtPrefKey: collRoleFmtPrefKey,
              typeName: 'personnel role',
            ),
            EnvironmentalDataFieldSettings(),
          ],
        ),
      ),
    );
  }
}

class EnvironmentalDataFieldSettings extends ConsumerWidget {
  const EnvironmentalDataFieldSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonSettingSection(
      title: 'Environmental data fields',
      isDivided: true,
      children: [
        ref
            .watch(userDefinedFieldProvider(environmentalDataFieldsPrefKey))
            .when(
              data: (selected) => Column(
                children: [
                  for (final field in environmentalDataFields)
                    CheckboxListTile(
                      value: selected.contains(field),
                      title: Text(environmentalDataFieldLabels[field]!),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (visible) async {
                        final next = selected.toSet();
                        if (visible == true) {
                          next.add(field);
                        } else {
                          next.remove(field);
                        }
                        await ref
                            .read(userConfigSettingsServiceProvider)
                            .replaceOptions(
                              environmentalDataFieldsPrefKey,
                              environmentalDataFields
                                  .where(next.contains)
                                  .toList(growable: false),
                            );
                        ref.invalidate(
                          userDefinedFieldProvider(
                            environmentalDataFieldsPrefKey,
                          ),
                        );
                      },
                    ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (error, _) =>
                  Text('Unable to load environmental data fields: $error'),
            ),
      ],
    );
  }
}
