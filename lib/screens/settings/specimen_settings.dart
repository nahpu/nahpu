import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/specimen_services.dart';

class SpecimenSelection extends ConsumerStatefulWidget {
  const SpecimenSelection({super.key});

  @override
  SpecimenSelectionState createState() => SpecimenSelectionState();
}

class SpecimenSelectionState extends ConsumerState<SpecimenSelection> {
  bool _isAlwaysShownCollectorField = false;

  @override
  void initState() {
    _isAlwaysShownCollectorField =
        SpecimenSettingServices(ref: ref).isCollectorFieldAlwaysShown();
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
                        await services.setCollectorFieldAlwaysShown(value);
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
              TissueIDFields(
                isMobile: isMobile,
              ),
              const SpecimenTypeSettings(),
              const TreatmentOptionSettings(),
            ],
          );
        },
      )),
    );
  }
}

class SpecimenTypeSettings extends ConsumerWidget {
  const SpecimenTypeSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController partController = TextEditingController();
    return SettingChips(
      title: 'Specimen part types',
      controller: partController,
      chipList: ref.watch(specimenTypesProvider).when(
            data: (data) {
              return data
                  .map((e) => CommonSettingChip(
                        text: e,
                        primaryColor: Theme.of(context).colorScheme.primary,
                        onDeleted: () {
                          SpecimenPartServices(ref: ref).removeType(e);
                        },
                      ))
                  .toList();
            },
            loading: () => const [CommonProgressIndicator()],
            error: (error, stackTrace) {
              return const [Text('Error loading data')];
            },
          ),
      labelText: 'Add Type',
      hintText: 'Enter part type',
      onPressed: () {
        if (partController.text.isNotEmpty) {
          SpecimenPartServices(ref: ref).addType(
            partController.text.trim(),
          );
          partController.clear();
        }
      },
      resetLabel: 'Match database types',
      onReset: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CommonAlertDialog(
              titleText: 'Match database types?',
              descText: 'Matching database types will'
                ' delete all unused specimen part types',
              confirmFunction: SpecimenPartServices(ref: ref).getSpecimenTypes,
            );
          },
        );
      },
    );
  }
}

class TreatmentOptionSettings extends ConsumerWidget {
  const TreatmentOptionSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController treatmentController = TextEditingController();
    return SettingChips(
      title: 'Treatments',
      controller: treatmentController,
      chipList: ref.watch(treatmentOptionsProvider).when(
            data: (data) {
              return data
                  .map((e) => CommonSettingChip(
                        text: e,
                        primaryColor: Theme.of(context).colorScheme.secondary,
                        onDeleted: () {
                          SpecimenPartServices(ref: ref).removeTreatment(e);
                        },
                      ))
                  .toList();
            },
            loading: () => const [CommonProgressIndicator()],
            error: (error, stackTrace) {
              return const [Text('Error loading data')];
            },
          ),
      labelText: 'Add Treatment',
      hintText: 'Enter treatment',
      onPressed: () {
        if (treatmentController.text.isNotEmpty) {
          SpecimenPartServices(ref: ref).addTreatment(
            treatmentController.text.trim(),
          );
          treatmentController.clear();
        }
      },
      resetLabel: 'Match database treatments',
      onReset: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CommonAlertDialog(
              titleText: 'Match database treatments?',
              descText: 'Matching database types will'
                ' delete all unused treatments',
              confirmFunction: SpecimenPartServices(ref: ref).getTreatmentOptions,
            );
          }
        );
      }
    );
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
            padding: const EdgeInsets.all(16),
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
      constraints: const BoxConstraints(maxWidth: 320),
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
      constraints: const BoxConstraints(maxWidth: 320),
      child: TextField(
        controller: tissueNumCtr,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Tissue no.',
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
