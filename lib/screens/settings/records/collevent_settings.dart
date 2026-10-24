import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/records/controlled_vocabulary.dart';
import 'package:nahpu/services/types/events.dart';
import 'package:nahpu/services/localization/l10n.dart';

enum _EnvironmentalDataCategory {
  temperature,
  humidity,
  measurements,
  aquatic,
  astronomy;

  String label(AppLocalizations l10n) => switch (this) {
    _EnvironmentalDataCategory.temperature => l10n.recordsCollEventTemperature,
    _EnvironmentalDataCategory.humidity => l10n.recordsCollEventHumidity,
    _EnvironmentalDataCategory.measurements =>
      l10n.recordsCollEventEnvironmentalMeasurements,
    _EnvironmentalDataCategory.aquatic => l10n.recordsCollEventAquaticData,
    _EnvironmentalDataCategory.astronomy => l10n.recordsCollEventAstronomy,
  };
}

class _EnvironmentalDataFieldCategory {
  const _EnvironmentalDataFieldCategory({
    required this.category,
    required this.fields,
  });

  final _EnvironmentalDataCategory category;
  final List<String> fields;
}

const _environmentalDataFieldCategories = [
  _EnvironmentalDataFieldCategory(
    category: _EnvironmentalDataCategory.temperature,
    fields: [
      'lowestDayTempC',
      'highestDayTempC',
      'lowestNightTempC',
      'highestNightTempC',
    ],
  ),
  _EnvironmentalDataFieldCategory(
    category: _EnvironmentalDataCategory.humidity,
    fields: ['averageHumidity', 'dewPointTemp'],
  ),
  _EnvironmentalDataFieldCategory(
    category: _EnvironmentalDataCategory.measurements,
    fields: [
      'cloudCover',
      'rainfallInMm',
      'ambientTemperature',
      'ambientHumidity',
    ],
  ),
  _EnvironmentalDataFieldCategory(
    category: _EnvironmentalDataCategory.aquatic,
    fields: [
      'waterTemperature',
      'pH',
      'dissolvedOxygen',
      'dissolvedOxygenPercent',
      'conductivity',
      'flowVelocity',
    ],
  ),
  _EnvironmentalDataFieldCategory(
    category: _EnvironmentalDataCategory.astronomy,
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
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordsCollEventSettings)),
      body: SafeArea(
        child: CommonSettingList(
          sections: [
            ControlledVocabularySetting(
              title: l10n.recordsCollEventPrimaryActivities,
              typePrefKey: collActivityPrefKey,
              fmtPrefKey: collActivityFmtPrefKey,
              typeName: 'primary activity',
            ),
            ControlledVocabularySetting(
              title: l10n.recordsCollEventCollectionMethods,
              typePrefKey: collMethodPrefKey,
              fmtPrefKey: collMethodFmtPrefKey,
              typeName: 'collection method',
            ),
            ControlledVocabularySetting(
              title: l10n.recordsCollEventPersonnelRoles,
              typePrefKey: collRolePrefKey,
              fmtPrefKey: collRoleFmtPrefKey,
              typeName: 'personnel role',
            ),
            const EnvironmentalDataFieldSettings(),
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
    final l10n = context.l10n;
    return CommonSettingSection(
      title: l10n.recordsCollEventEnvironmentalDataFields,
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
                          category.category.label(l10n),
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
              error: (error, _) => Text(
                l10n.recordsCollEventEnvironmentalDataFieldsLoadError(
                  error.toString(),
                ),
              ),
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
      title: Text(environmentalDataFieldLabelWithUnit(field)),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: onChanged,
    );
  }
}
