import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/records/controlled_vocabulary.dart';
import 'package:nahpu/services/types/events.dart';

class _EnvironmentalDataFieldCategory {
  const _EnvironmentalDataFieldCategory({
    required this.title,
    required this.fields,
  });

  final String title;
  final List<String> fields;
}

const _environmentalDataFieldCategories = [
  _EnvironmentalDataFieldCategory(
    title: 'Temperature (°C)',
    fields: [
      'lowestDayTempC',
      'highestDayTempC',
      'lowestNightTempC',
      'highestNightTempC',
    ],
  ),
  _EnvironmentalDataFieldCategory(
    title: 'Humidity (%)',
    fields: ['averageHumidity', 'dewPointTemp'],
  ),
  _EnvironmentalDataFieldCategory(
    title: 'Environmental measurements',
    fields: [
      'cloudCover',
      'rainfallInMm',
      'ambientTemperature',
      'ambientHumidity',
    ],
  ),
  _EnvironmentalDataFieldCategory(
    title: 'Aquatic Data',
    fields: ['waterTemperature', 'pH', 'dissolvedOxygen', 'flowVelocity'],
  ),
  _EnvironmentalDataFieldCategory(
    title: 'Astronomy',
    fields: ['sunriseTime', 'sunsetTime', 'moonPhase'],
  ),
];

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
      children: [
        ref
            .watch(userDefinedFieldProvider(environmentalDataFieldsPrefKey))
            .when(
              data: (selected) => Column(
                children: [
                  for (final (categoryIndex, category)
                      in _environmentalDataFieldCategories.indexed) ...[
                    if (categoryIndex > 0) const SettingDivider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          category.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    for (final (fieldIndex, field)
                        in category.fields.indexed) ...[
                      _EnvironmentalDataFieldTile(
                        field: field,
                        selected: selected.contains(field),
                        onChanged: (visible) =>
                            _updateField(ref, selected, field, visible),
                      ),
                      if (fieldIndex != category.fields.length - 1)
                        const SettingDivider(),
                    ],
                  ],
                  const SettingDivider(),
                  _EnvironmentalDataFieldTile(
                    field: 'notes',
                    selected: selected.contains('notes'),
                    onChanged: (visible) =>
                        _updateField(ref, selected, 'notes', visible),
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

  Future<void> _updateField(
    WidgetRef ref,
    List<String> selected,
    String field,
    bool? visible,
  ) async {
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
          environmentalDataFields.where(next.contains).toList(growable: false),
        );
    ref.invalidate(userDefinedFieldProvider(environmentalDataFieldsPrefKey));
  }
}

class _EnvironmentalDataFieldTile extends StatelessWidget {
  const _EnvironmentalDataFieldTile({
    required this.field,
    required this.selected,
    required this.onChanged,
  });

  final String field;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: selected,
      title: Text(environmentalDataFieldLabels[field]!),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: onChanged,
    );
  }
}
