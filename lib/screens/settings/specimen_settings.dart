import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/settings/controlled_vocabulary.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:nahpu/services/parasite_services.dart';
import 'package:nahpu/services/types/parasites.dart';

class SpecimenSelection extends ConsumerStatefulWidget {
  const SpecimenSelection({super.key});

  @override
  SpecimenSelectionState createState() => SpecimenSelectionState();
}

class SpecimenSelectionState extends ConsumerState<SpecimenSelection> {
  bool _isAlwaysShownCollectorField = false;

  @override
  void initState() {
    _isAlwaysShownCollectorField = SpecimenSettingServices(
      ref: ref,
    ).getSpecimenSettingField(collectorFieldKey);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final services = SpecimenSettingServices(ref: ref);

    return Scaffold(
      appBar: AppBar(title: const Text('Specimen Settings')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bool isMobile = constraints.maxWidth < 600;
            final catalogFmt = ref.watch(catalogFmtNotifierProvider);
            return CommonSettingList(
              sections: [
                CommonSettingSection(
                  title: 'Capture records',
                  children: [
                    SwitchSettings(
                      value: _isAlwaysShownCollectorField,
                      onChanged: (bool value) async {
                        try {
                          await services.setSpecimenSettingField(
                            collectorFieldKey,
                            value,
                          );
                          setState(() {
                            _isAlwaysShownCollectorField = value;
                          });
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                      label: 'Always show collector field',
                    ),
                  ],
                ),
                FieldIDFields(isMobile: isMobile),
                TissueIDFields(isMobile: isMobile),
                const ControlledVocabularySetting(
                  title: 'Specimen types',
                  typePrefKey: specimenTypePrefKey,
                  fmtPrefKey: specimenTypeFmtPrefKey,
                  typeName: 'specimen type',
                ),
                const ControlledVocabularySetting(
                  title: 'Treatments',
                  typePrefKey: treatmentPrefKey,
                  fmtPrefKey: treatmentFmtPrefKey,
                  typeName: 'treatment',
                ),
                const ControlledVocabularySetting(
                  title: 'Conditions',
                  typePrefKey: conditionPrefKey,
                  fmtPrefKey: conditionFmtPrefKey,
                  typeName: 'condition',
                ),
                ...catalogFmt.when(
                  data: (format) => supportsParasites(format)
                      ? [ParasiteSettings(isMobile: isMobile)]
                      : const <Widget>[],
                  loading: () => const <Widget>[],
                  error: (_, _) => const <Widget>[],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ParasiteSettings extends StatelessWidget {
  const ParasiteSettings({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Parasite', style: Theme.of(context).textTheme.titleMedium),
        CommonSettingSection(
          title: 'Identification',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
              child: _ParasiteIdSettingsFields(isMobile: isMobile),
            ),
          ],
        ),
        const ControlledVocabularySetting(
          title: 'Categories',
          typePrefKey: parasiteCategoryPrefKey,
          fmtPrefKey: parasiteCategoryFmtPrefKey,
          typeName: 'category',
        ),
        const ControlledVocabularySetting(
          title: 'Detection methods',
          typePrefKey: parasiteDetectionMethodPrefKey,
          fmtPrefKey: parasiteDetectionMethodFmtPrefKey,
          typeName: 'detection method',
        ),
        const ControlledVocabularySetting(
          title: 'Preparation methods',
          typePrefKey: parasitePreparationMethodPrefKey,
          fmtPrefKey: parasitePreparationMethodFmtPrefKey,
          typeName: 'preparation method',
        ),
        const ControlledVocabularySetting(
          title: 'Anatomical locations',
          typePrefKey: parasiteAnatomicalLocationPrefKey,
          fmtPrefKey: parasiteAnatomicalLocationFmtPrefKey,
          typeName: 'anatomical location',
        ),
        const ControlledVocabularySetting(
          title: 'Storage',
          typePrefKey: parasiteStoragePrefKey,
          fmtPrefKey: parasiteStorageFmtPrefKey,
          typeName: 'storage value',
        ),
        const ControlledVocabularySetting(
          title: 'Treatments',
          typePrefKey: parasiteTreatmentPrefKey,
          fmtPrefKey: parasiteTreatmentFmtPrefKey,
          typeName: 'treatment',
        ),
      ],
    );
  }
}

class _ParasiteIdSettingsFields extends StatefulWidget {
  const _ParasiteIdSettingsFields({required this.isMobile});

  final bool isMobile;

  @override
  State<_ParasiteIdSettingsFields> createState() =>
      _ParasiteIdSettingsFieldsState();
}

class _ParasiteIdSettingsFieldsState extends State<_ParasiteIdSettingsFields> {
  final _prefixController = TextEditingController();
  final _numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const services = ParasiteIdServices();
    return AdaptiveLayout(
      useHorizontalLayout: !widget.isMobile,
      children: [
        TextField(
          controller: _prefixController,
          decoration: const InputDecoration(
            labelText: 'Parasite ID prefix',
            hintText: 'Enter a prefix, e.g. P',
          ),
          onChanged: services.setPrefix,
        ),
        TextField(
          controller: _numberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Parasite ID number',
            hintText: 'Enter the next number',
          ),
          onChanged: services.setNumber,
        ),
      ],
    );
  }

  Future<void> _load() async {
    const services = ParasiteIdServices();
    final values = await Future.wait([
      services.getPrefix(),
      services.getNumberString(),
    ]);
    if (!mounted) return;
    _prefixController.text = values[0];
    _numberController.text = values[1];
  }
}

class FieldIDFields extends ConsumerWidget {
  const FieldIDFields({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fieldIdModeNotifier = ref.watch(fieldIdModeNotifierProvider);

    return CommonSettingSection(
      title: 'Field ID',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
          child: AdaptiveLayout(
            useHorizontalLayout: !isMobile,
            children: [
              FieldIdModeDropDown(ref: ref),
              fieldIdModeNotifier.when(
                data: (mode) => Visibility(
                  visible: mode == FieldIdMode.project,
                  child: ProjectFieldId(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const Text('Error'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FieldIdModeDropDown extends StatelessWidget {
  const FieldIdModeDropDown({super.key, required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(fieldIdModeNotifierProvider)
        .when(
          data: (mode) => DropdownButtonFormField<FieldIdMode>(
            isExpanded: true,
            initialValue: mode,
            decoration: InputDecoration(labelText: 'ID mode'),
            items: FieldIdMode.values
                .map(
                  (e) => DropdownMenuItem<FieldIdMode>(
                    value: e,
                    child: CommonDropdownText(text: e.name.toTitleCase()),
                  ),
                )
                .toList(),
            onChanged: (FieldIdMode? selectedMode) {
              if (selectedMode != null) {
                ref
                    .read(fieldIdModeNotifierProvider.notifier)
                    .set(selectedMode);
              }
            },
          ),
          loading: () => const CommonProgressIndicator(),
          error: (e, s) => const Text('Error'),
        );
  }
}

class ProjectFieldId extends ConsumerStatefulWidget {
  const ProjectFieldId({super.key});

  @override
  ProjectFieldIdState createState() => ProjectFieldIdState();
}

class ProjectFieldIdState extends ConsumerState<ProjectFieldId> {
  late TextEditingController projectFieldIdCtr;

  @override
  void initState() {
    projectFieldIdCtr = TextEditingController(text: _getNumber());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: TextField(
        controller: projectFieldIdCtr,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Project number',
          hintText: 'Enter the initial starting number',
        ),
        textInputAction: TextInputAction.done,
        onChanged: (String? value) async {
          await ProjectFieldIdServices(ref: ref).setNumber(value ?? '1');
        },
      ),
    );
  }

  String _getNumber() {
    return ProjectFieldIdServices(ref: ref).getNumberString();
  }
}

class TissueIDFields extends ConsumerWidget {
  const TissueIDFields({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonSettingSection(
      title: 'Tissue ID',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
          child: AdaptiveLayout(
            useHorizontalLayout: !isMobile,
            children: const [TissuePrefixField(), TissueNumField()],
          ),
        ),
      ],
    );
  }
}

class TissuePrefixField extends ConsumerStatefulWidget {
  const TissuePrefixField({super.key});

  @override
  TissuePrefixFieldState createState() => TissuePrefixFieldState();
}

class TissuePrefixFieldState extends ConsumerState<TissuePrefixField> {
  late TextEditingController prefixCtr;

  @override
  void initState() {
    prefixCtr = TextEditingController(text: _getPrefix());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: TextField(
        controller: prefixCtr,
        decoration: const InputDecoration(
          labelText: 'Prefix',
          hintText: 'Enter tissue ID prefix, e.g. M',
        ),
        onChanged: (String? value) async {
          if (value != null && value.trim().isNotEmpty) {
            await TissueIdServices(ref: ref).setPrefix(value.trim());
          }
        },
      ),
    );
  }

  String _getPrefix() {
    return TissueIdServices(ref: ref).getPrefix();
  }
}

class TissueNumField extends ConsumerStatefulWidget {
  const TissueNumField({super.key});

  @override
  TissueNumFieldState createState() => TissueNumFieldState();
}

class TissueNumFieldState extends ConsumerState<TissueNumField> {
  late TextEditingController tissueNumCtr;

  @override
  void initState() {
    tissueNumCtr = TextEditingController(text: _getNumber());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: TextField(
        controller: tissueNumCtr,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Tissue number',
          hintText: 'Enter the initial starting number',
        ),
        textInputAction: TextInputAction.done,
        onChanged: (String? value) async {
          if (value != null && value.trim().isNotEmpty) {
            await TissueIdServices(ref: ref).setNumber(value);
          }
        },
      ),
    );
  }

  String _getNumber() {
    return TissueIdServices(ref: ref).getNumberString();
  }
}
