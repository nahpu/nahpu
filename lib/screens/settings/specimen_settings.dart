import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/utility_services.dart';

class SpecimenSelection extends ConsumerStatefulWidget {
  const SpecimenSelection({super.key});

  @override
  SpecimenSelectionState createState() => SpecimenSelectionState();
}

class SpecimenSelectionState extends ConsumerState<SpecimenSelection> {
  bool _isAlwaysShownCollectorField = false;

  @override
  void initState() {
    _isAlwaysShownCollectorField = SpecimenSettingServices(ref: ref)
        .getSpecimenSettingField(collectorFieldKey);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final services = SpecimenSettingServices(ref: ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Specimen Settings'),
      ),
      body: SafeArea(child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          bool isMobile = constraints.maxWidth < 600;
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
                            collectorFieldKey, value);
                        setState(() {
                          _isAlwaysShownCollectorField = value;
                        });
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                            ),
                          );
                        }
                      }
                    },
                    label: 'Always show collector field',
                  )
                ],
              ),
              FieldIDFields(
                isMobile: isMobile,
              ),
              TissueIDFields(
                isMobile: isMobile,
              ),
              SpecimenFormats(
                isMobile: isMobile,
              ),
              UserDefinedSettingField(
                typePrefKey: specimenTypePrefKey,
                fmtPrefKey: specimenTypeFmtPrefKey,
                typeName: 'Specimen Type',
              ),
              UserDefinedSettingField(
                typePrefKey: treatmentPrefKey,
                fmtPrefKey: treatmentFmtPrefKey,
                typeName: 'Treatment',
              ),
            ],
          );
        },
      )),
    );
  }
}

class SpecimenFormats extends ConsumerWidget {
  const SpecimenFormats({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonSettingSection(title: 'Formats', children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
          child: AdaptiveLayout(
            useHorizontalLayout: !isMobile,
            children: [
              TextCaseFmtDropDown(
                  ref: ref,
                  label: 'Specimen part types',
                  textCasePrefString: specimenTypeFmtPrefKey),
              TextCaseFmtDropDown(
                  ref: ref,
                  label: 'Treatment types',
                  textCasePrefString: treatmentFmtPrefKey),
            ],
          ))
    ]);
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
                      child: ProjectFieldId()),
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const Text('Error'),
                )
              ],
            )),
      ],
    );
  }
}

class FieldIdModeDropDown extends StatelessWidget {
  const FieldIdModeDropDown({
    super.key,
    required this.ref,
  });

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ref.watch(fieldIdModeNotifierProvider).when(
          data: (mode) => DropdownButtonFormField<FieldIdMode>(
              initialValue: mode,
              decoration: InputDecoration(
                labelText: 'ID mode',
              ),
              items: FieldIdMode.values
                  .map((e) => DropdownMenuItem<FieldIdMode>(
                      value: e,
                      child: CommonDropdownText(text: e.name.toTitleCase())))
                  .toList(),
              onChanged: (FieldIdMode? selectedMode) {
                if (selectedMode != null) {
                  ref
                      .read(fieldIdModeNotifierProvider.notifier)
                      .set(selectedMode);
                }
              }),
          loading: () => const CommonProgressIndicator(),
          error: (e, s) => const Text('Error'),
        );
  }
}

class ProjectFieldId extends ConsumerStatefulWidget {
  const ProjectFieldId({
    super.key,
  });

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
              children: const [
                TissuePrefixField(),
                TissueNumField(),
              ],
            )),
      ],
    );
  }
}

class TissuePrefixField extends ConsumerStatefulWidget {
  const TissuePrefixField({
    super.key,
  });

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
          }),
    );
  }

  String _getPrefix() {
    return TissueIdServices(ref: ref).getPrefix();
  }
}

class TissueNumField extends ConsumerStatefulWidget {
  const TissueNumField({
    super.key,
  });

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
