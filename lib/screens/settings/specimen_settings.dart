import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/personnel/add_personnel.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/settings/controlled_vocabulary.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/specimens/parasite_services.dart';
import 'package:nahpu/services/types/parasites.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/styles/design_tokens.dart';

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
            bool isMobile = constraints.maxWidth < NahpuBreakpoints.compact;
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
                const SpecimenSexSetting(),
                const ControlledVocabularySetting(
                  title: 'IdMethod',
                  typePrefKey: idMethodPrefKey,
                  fmtPrefKey: idMethodFmtPrefKey,
                  typeName: 'IdMethod',
                  pluralName: 'IdMethods',
                ),
                const ControlledVocabularySetting(
                  title: 'Life stages',
                  typePrefKey: lifeStagePrefKey,
                  fmtPrefKey: lifeStageFmtPrefKey,
                  typeName: 'life stage',
                ),
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

class SpecimenSexSetting extends ConsumerWidget {
  const SpecimenSexSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonSettingSection(
      title: 'Sex',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Male, Female, and Unknown are always available. Add optional '
            'terms with +. A question mark records examiner uncertainty.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ref
                .watch(specimenSexVocabularyProvider)
                .when(
                  data: (enabled) => _SpecimenSexOptions(enabled: enabled),
                  loading: () => const Center(child: CommonProgressIndicator()),
                  error: (error, _) =>
                      Text('Unable to load sex options: $error'),
                ),
          ),
        ),
      ],
    );
  }
}

/// Sex options split into the terms currently in use and the ones that can
/// still be added.
class _SpecimenSexOptions extends ConsumerWidget {
  const _SpecimenSexOptions({required this.enabled});

  final List<SpecimenSex> enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final additional = optionalSpecimenSexes
        .where((sex) => !enabled.contains(sex))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SpecimenSexGroup(
          title: 'Selected',
          children: [
            for (final sex in defaultSpecimenSexes)
              Chip(label: Text(specimenSexLabel[sex]!)),
            for (final sex in optionalSpecimenSexes)
              if (enabled.contains(sex))
                InputChip(
                  label: Text(specimenSexLabel[sex]!),
                  onDeleted: () => _remove(context, ref, sex),
                ),
          ],
        ),
        if (additional.isNotEmpty) ...[
          const SizedBox(height: NahpuSpacing.lg),
          _SpecimenSexGroup(
            title: 'Additional options',
            children: [
              for (final sex in additional)
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(specimenSexLabel[sex]!),
                  onPressed: () => _add(ref, sex),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _add(WidgetRef ref, SpecimenSex sex) async {
    await ref
        .read(userConfigSettingsServiceProvider)
        .addOption(specimenSexPrefKey, specimenSexLabel[sex]!);
    ref.invalidate(specimenSexVocabularyProvider);
    ref.invalidate(userDefinedFieldProvider(specimenSexPrefKey));
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    SpecimenSex sex,
  ) async {
    final usedCodes = await SpecimenServices(ref: ref).getDistinctSexCodes();
    if (!context.mounted) return;
    if (usedCodes.contains(getSpecimenSexCode(sex))) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot remove sex'),
          content: Text(
            '${specimenSexLabel[sex]} is used by one or more specimen records. '
            'Change those records before removing this option.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    await ref
        .read(userConfigSettingsServiceProvider)
        .removeOption(specimenSexPrefKey, specimenSexLabel[sex]!);
    ref.invalidate(specimenSexVocabularyProvider);
    ref.invalidate(userDefinedFieldProvider(specimenSexPrefKey));
  }
}

/// One labeled row of sex chips that fills the section width.
class _SpecimenSexGroup extends StatelessWidget {
  const _SpecimenSexGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: NahpuSpacing.md),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
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
              const UseProjectIdToggle(),
              const SizedBox(height: 8),
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

class UseProjectIdToggle extends ConsumerWidget {
  const UseProjectIdToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(fieldIdModeNotifierProvider)
        .when(
          data: (mode) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SwitchListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              title: const Text('Use project ID'),
              value: mode == FieldIdMode.project,
              onChanged: (value) {
                ref
                    .read(fieldIdModeNotifierProvider.notifier)
                    .set(value ? FieldIdMode.project : FieldIdMode.personnel);
              },
            ),
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
    return Column(
      children: [
        CommonPadding(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: const Text('Personnel field IDs require a cataloger'),
            subtitle: const Text(
              'Add a personnel with at least one Cataloger role in the project '
              'and assign a current field number to that role.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          onPressed: () => _addPersonnel(context),
          icon: Icons.add,
          label: 'Add personnel',
        ),
      ],
    );
  }

  Future<void> _addPersonnel(BuildContext context) async {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (context) => const AddPersonnel()));
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
        CommonPadding(
          child: Text(
            'Preview: ${_prefixController.text}${_numberController.text}'
            '${_suffixController.text}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 8),
        autoIncrement.when(
          data: (enabled) => CommonPadding(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-increment catalog number'),
              value: enabled,
              onChanged: (value) => ref
                  .read(projectFieldIdAutoIncrementProvider.notifier)
                  .set(value),
            ),
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, stack) => Text(error.toString()),
        ),
        const SizedBox(height: 16),
        Center(
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
