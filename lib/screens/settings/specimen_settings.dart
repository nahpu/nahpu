import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/settings/controlled_vocabulary.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/parasite_services.dart';
import 'package:nahpu/services/types/parasites.dart';
import 'package:nahpu/services/providers/projects.dart';

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
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Center(
            child: Text(
              'Parasites',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FieldIdModeSelector(),
              const SizedBox(height: 12),
              fieldIdModeNotifier.when(
                data: (mode) => mode == FieldIdMode.personnel
                    ? const _PersonnelFieldIdNote()
                    : ProjectFieldIdSettings(isMobile: isMobile),
                loading: () => const CommonProgressIndicator(),
                error: (error, stack) => Text(error.toString()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FieldIdModeSelector extends ConsumerWidget {
  const FieldIdModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(fieldIdModeNotifierProvider)
        .when(
          data: (mode) => SegmentedButton<FieldIdMode>(
            segments: const [
              ButtonSegment(
                value: FieldIdMode.personnel,
                icon: Icon(Icons.person_outline),
                label: Text('Personnel'),
              ),
              ButtonSegment(
                value: FieldIdMode.project,
                icon: Icon(Icons.folder_outlined),
                label: Text('Project'),
              ),
            ],
            selected: {mode},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              ref
                  .read(fieldIdModeNotifierProvider.notifier)
                  .set(selection.single);
            },
          ),
          loading: () => const CommonProgressIndicator(),
          error: (e, s) => const Text('Error'),
        );
  }
}

class _PersonnelFieldIdNote extends StatelessWidget {
  const _PersonnelFieldIdNote();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.info_outline),
      title: const Text('Personnel field IDs require a cataloger'),
      subtitle: const Text(
        'Add at least one Cataloger with personal field-number registration '
        'enabled and a current field number.',
      ),
    );
  }
}

class ProjectFieldIdSettings extends ConsumerStatefulWidget {
  const ProjectFieldIdSettings({super.key, required this.isMobile});

  final bool isMobile;

  @override
  ConsumerState<ProjectFieldIdSettings> createState() =>
      _ProjectFieldIdSettingsState();
}

class _ProjectFieldIdSettingsState
    extends ConsumerState<ProjectFieldIdSettings> {
  final _prefixController = TextEditingController();
  final _numberController = TextEditingController();
  final _suffixController = TextEditingController();
  String _savedPrefix = '';
  String _savedSuffix = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _numberController.dispose();
    _suffixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const CommonProgressIndicator();
    final autoIncrement = ref.watch(projectFieldIdAutoIncrementProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdaptiveLayout(
          useHorizontalLayout: !widget.isMobile,
          children: [
            TextField(
              controller: _prefixController,
              decoration: const InputDecoration(
                labelText: 'Prefix',
                hintText: 'e.g. NAHPU-',
              ),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Current catalog number',
                hintText: 'Enter the next number',
              ),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: _suffixController,
              decoration: const InputDecoration(
                labelText: 'Suffix',
                hintText: 'e.g. -M',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Preview: ${_prefixController.text}${_numberController.text}'
          '${_suffixController.text}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        autoIncrement.when(
          data: (enabled) => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto-increment project catalog number'),
            subtitle: const Text(
              'Assign the current number to a new project-ID specimen and '
              'advance to the next number.',
            ),
            value: enabled,
            onChanged: (value) => ref
                .read(projectFieldIdAutoIncrementProvider.notifier)
                .set(value),
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, stack) => Text(error.toString()),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _save,
            child: const Text('Save field ID settings'),
          ),
        ),
      ],
    );
  }

  Future<void> _load() async {
    final project = await ProjectFieldIdServices(ref: ref).getProject();
    if (!mounted) return;
    _savedPrefix = project.catalogNumberPrefix ?? '';
    _savedSuffix = project.catalogNumberSuffix ?? '';
    _prefixController.text = _savedPrefix;
    _numberController.text = project.currentCatalogNumber?.toString() ?? '';
    _suffixController.text = _savedSuffix;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final service = ProjectFieldIdServices(ref: ref);
    final identifiersChanged =
        _prefixController.text != _savedPrefix ||
        _suffixController.text != _savedSuffix;
    if (identifiersChanged &&
        await service.hasAssignedProjectNumbers() &&
        mounted &&
        !await _confirmIdentifierChange(context)) {
      return;
    }

    await service.updateSettings(
      prefix: _prefixController.text,
      suffix: _suffixController.text,
      currentNumber: int.tryParse(_numberController.text),
    );
    _savedPrefix = _prefixController.text;
    _savedSuffix = _suffixController.text;
    ref.invalidate(currProjInfoProvider);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Field ID settings saved.')));
    }
  }
}

Future<bool> _confirmIdentifierChange(BuildContext context) async {
  const message =
      'Changing the project field ID prefix or suffix changes existing '
      'project IDs. These identifiers may already have been used in exports '
      'or written on specimen labels. Double-check the new values before '
      'changing them.';
  if (MediaQuery.sizeOf(context).width < 600) {
    return await showModalBottomSheet<bool>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Change project field ID format?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(message),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('I understand'),
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Change project field ID format?'),
          content: const Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('I understand'),
            ),
          ],
        ),
      ) ??
      false;
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
