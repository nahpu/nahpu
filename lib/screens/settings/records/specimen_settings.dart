import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nahpu/screens/projects/personnel/add_personnel.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/forms/numbered_id_fields.dart';
import 'package:nahpu/services/specimens/fish_lot_services.dart';
import 'package:nahpu/screens/settings/records/controlled_vocabulary.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/specimens/parasite_services.dart';
import 'package:nahpu/services/types/parasites.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';

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
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordsSpecimenSettings)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bool isMobile = constraints.maxWidth < NahpuBreakpoints.compact;
            final catalogFmt = ref.watch(catalogFmtNotifierProvider);
            return CommonSettingList(
              sections: [
                CommonSettingSection(
                  title: l10n.recordsSpecimenCaptureRecords,
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
                      label: l10n.recordsSpecimenAlwaysShowCollector,
                    ),
                  ],
                ),
                FieldIDFields(isMobile: isMobile),
                TissueIDFields(isMobile: isMobile),
                if (catalogFmt.asData?.value == CatalogFmt.ichthyology)
                  IndividualTagIdSetting(isMobile: isMobile),
                const SpecimenSexSetting(),
                ControlledVocabularySetting(
                  title: l10n.recordsSpecimenIdentificationMethods,
                  typePrefKey: idMethodPrefKey,
                  fmtPrefKey: idMethodFmtPrefKey,
                  typeName: 'identification method',
                ),
                ControlledVocabularySetting(
                  title: l10n.recordsSpecimenLifeStages,
                  typePrefKey: lifeStagePrefKey,
                  fmtPrefKey: lifeStageFmtPrefKey,
                  typeName: 'life stage',
                ),
                ControlledVocabularySetting(
                  title: l10n.recordsSpecimenTypes,
                  typePrefKey: specimenTypePrefKey,
                  fmtPrefKey: specimenTypeFmtPrefKey,
                  typeName: 'specimen type',
                ),
                ControlledVocabularySetting(
                  title: l10n.recordsSpecimenTreatments,
                  typePrefKey: treatmentPrefKey,
                  fmtPrefKey: treatmentFmtPrefKey,
                  typeName: 'treatment',
                ),
                ControlledVocabularySetting(
                  title: l10n.recordsSpecimenConditions,
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
    final l10n = context.l10n;
    return CommonSettingSection(
      title: l10n.recordsSpecimenSex,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            l10n.recordsSpecimenSexNote(
              specimenSexLabel[SpecimenSex.male]!,
              specimenSexLabel[SpecimenSex.female]!,
              specimenSexLabel[SpecimenSex.unknown]!,
            ),
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
                      Text(l10n.recordsSpecimenSexLoadError(error.toString())),
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
          title: context.l10n.recordsSpecimenSexSelected,
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
            title: context.l10n.recordsSpecimenSexAdditional,
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
          title: Text(context.l10n.recordsSpecimenSexRemoveBlockedTitle),
          content: Text(
            context.l10n.recordsSpecimenSexRemoveBlockedBody(
              specimenSexLabel[sex]!,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.commonOk),
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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Center(
            child: Text(
              l10n.recordsSpecimenParasites,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        CommonSettingSection(
          title: l10n.recordsSpecimenParasiteIdentification,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
              child: _ParasiteIdSettingsFields(isMobile: isMobile),
            ),
          ],
        ),
        ControlledVocabularySetting(
          title: l10n.recordsSpecimenParasiteCategories,
          typePrefKey: parasiteCategoryPrefKey,
          fmtPrefKey: parasiteCategoryFmtPrefKey,
          typeName: 'category',
        ),
        ControlledVocabularySetting(
          title: l10n.recordsSpecimenParasiteDetectionMethods,
          typePrefKey: parasiteDetectionMethodPrefKey,
          fmtPrefKey: parasiteDetectionMethodFmtPrefKey,
          typeName: 'detection method',
        ),
        ControlledVocabularySetting(
          title: l10n.recordsSpecimenParasitePreparationMethods,
          typePrefKey: parasitePreparationMethodPrefKey,
          fmtPrefKey: parasitePreparationMethodFmtPrefKey,
          typeName: 'preparation method',
        ),
        ControlledVocabularySetting(
          title: l10n.recordsSpecimenParasiteAnatomicalLocations,
          typePrefKey: parasiteAnatomicalLocationPrefKey,
          fmtPrefKey: parasiteAnatomicalLocationFmtPrefKey,
          typeName: 'anatomical location',
        ),
        ControlledVocabularySetting(
          title: l10n.recordsSpecimenParasiteStorage,
          typePrefKey: parasiteStoragePrefKey,
          fmtPrefKey: parasiteStorageFmtPrefKey,
          typeName: 'storage value',
        ),
        ControlledVocabularySetting(
          title: l10n.recordsSpecimenTreatments,
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
    final l10n = context.l10n;
    return AdaptiveLayout(
      useHorizontalLayout: !widget.isMobile,
      children: [
        TextField(
          controller: _prefixController,
          decoration: InputDecoration(
            labelText: l10n.recordsSpecimenParasiteIdPrefix,
            hintText: l10n.recordsSpecimenParasiteIdPrefixHint('P'),
          ),
          onChanged: services.setPrefix,
        ),
        TextField(
          controller: _numberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.recordsSpecimenParasiteIdNumber,
            hintText: l10n.recordsSpecimenNextNumberHint,
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
      title: context.l10n.recordsSpecimenFieldId,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FieldIdModeChoice(showDescriptions: false),
              const SizedBox(height: NahpuSpacing.lg),
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

/// Field ID mode picker shown as two selectable cards.
///
/// Shared by the setup wizard and Settings > Catalogs > Specimens. Settings
/// hides the descriptions to keep the section compact.
class FieldIdModeChoice extends ConsumerWidget {
  const FieldIdModeChoice({super.key, this.showDescriptions = true});

  final bool showDescriptions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(fieldIdModeNotifierProvider)
        .when(
          data: (mode) => RadioGroup<FieldIdMode>(
            groupValue: mode,
            onChanged: (value) {
              if (value == null) return;
              ref.read(fieldIdModeNotifierProvider.notifier).set(value);
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final l10n = context.l10n;
                final personnel = _FieldIdModeCard(
                  mode: FieldIdMode.personnel,
                  iconPath: 'assets/icons/personnel_id.svg',
                  title: l10n.recordsSpecimenPersonnelId,
                  message: showDescriptions
                      ? l10n.recordsSpecimenPersonnelIdDescription
                      : null,
                );
                final project = _FieldIdModeCard(
                  mode: FieldIdMode.project,
                  iconPath: 'assets/icons/project_id.svg',
                  title: l10n.recordsSpecimenProjectId,
                  message: showDescriptions
                      ? l10n.recordsSpecimenProjectIdDescription
                      : null,
                );
                return constraints.maxWidth >= NahpuBreakpoints.compact
                    // The cards sit in a scroll view, so the row has no height
                    // to stretch into until the tallest card is measured.
                    ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: personnel),
                            const SizedBox(width: NahpuSpacing.lg),
                            Expanded(child: project),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          personnel,
                          const SizedBox(height: NahpuSpacing.lg),
                          project,
                        ],
                      );
              },
            ),
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, _) => Text(
            context.l10n.recordsSpecimenFieldIdModeLoadError(error.toString()),
          ),
        );
  }
}

class _FieldIdModeCard extends StatelessWidget {
  const _FieldIdModeCard({
    required this.mode,
    required this.iconPath,
    required this.title,
    this.message,
  });

  final FieldIdMode mode;
  final String iconPath;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected =
        RadioGroup.maybeOf<FieldIdMode>(context)?.groupValue == mode;
    final foreground = selected ? colors.onPrimaryContainer : colors.onSurface;
    return Material(
      color: selected ? colors.primaryContainer : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NahpuRadius.lg),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? NahpuStroke.regular : NahpuStroke.thin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => RadioGroup.maybeOf<FieldIdMode>(context)?.onChanged(mode),
        child: Padding(
          padding: const EdgeInsets.all(NahpuSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    iconPath,
                    height: NahpuControlSize.iconLarge,
                    width: NahpuControlSize.iconLarge,
                    colorFilter: ColorFilter.mode(
                      selected ? colors.primary : colors.outline,
                      BlendMode.srcIn,
                    ),
                  ),
                  const Spacer(),
                  Radio<FieldIdMode>(value: mode),
                ],
              ),
              const SizedBox(height: NahpuSpacing.lg),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: foreground),
              ),
              if (message != null) ...[
                const SizedBox(height: NahpuSpacing.xs),
                Text(
                  message!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: foreground),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonnelFieldIdNote extends StatelessWidget {
  const _PersonnelFieldIdNote();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        CommonPadding(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.recordsSpecimenPersonnelFieldIdNoteTitle),
            subtitle: Text(l10n.recordsSpecimenPersonnelFieldIdNoteBody),
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          onPressed: () => _addPersonnel(context),
          icon: Icons.add,
          label: l10n.recordsSpecimenAddPersonnel,
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
  bool _hasProject = true;

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
    final l10n = context.l10n;
    final autoIncrement = ref.watch(projectFieldIdAutoIncrementProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_hasProject)
          const _NoProjectFieldIdNote()
        else ...[
          AdaptiveLayout(
            useHorizontalLayout: !widget.isMobile,
            children: [
              TextField(
                controller: _prefixController,
                decoration: InputDecoration(
                  labelText: l10n.recordsSpecimenPrefix,
                  hintText: l10n.recordsSpecimenExampleHint('NAHPU-'),
                ),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.recordsSpecimenCurrentCatalogNumber,
                  hintText: l10n.recordsSpecimenNextNumberHint,
                ),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: _suffixController,
                decoration: InputDecoration(
                  labelText: l10n.recordsSpecimenSuffix,
                  hintText: l10n.recordsSpecimenExampleHint('-M'),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CommonPadding(
            child: Text(
              l10n.recordsSpecimenFieldIdPreview(
                '${_prefixController.text}${_numberController.text}'
                '${_suffixController.text}',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
        const SizedBox(height: 8),
        autoIncrement.when(
          data: (enabled) => CommonPadding(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.recordsSpecimenAutoIncrement),
              value: enabled,
              onChanged: (value) => ref
                  .read(projectFieldIdAutoIncrementProvider.notifier)
                  .set(value),
            ),
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, stack) => Text(error.toString()),
        ),
        if (_hasProject) ...[
          const SizedBox(height: 16),
          Center(
            child: FilledButton(
              onPressed: _save,
              child: Text(l10n.recordsSpecimenSaveFieldIdSettings),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _load() async {
    final project = await ProjectFieldIdServices(ref: ref).findProject();
    if (!mounted) return;
    if (project == null) {
      setState(() {
        _hasProject = false;
        _loading = false;
      });
      return;
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.recordsSpecimenFieldIdSettingsSaved),
        ),
      );
    }
  }
}

class _NoProjectFieldIdNote extends StatelessWidget {
  const _NoProjectFieldIdNote();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CommonPadding(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.info_outline),
        title: Text(l10n.recordsSpecimenNoProjectFieldIdTitle),
        subtitle: Text(l10n.recordsSpecimenNoProjectFieldIdBody),
      ),
    );
  }
}

Future<bool> _confirmIdentifierChange(BuildContext context) async {
  final l10n = context.l10n;
  final message = l10n.recordsSpecimenFieldIdChangeBody;
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
                    l10n.recordsSpecimenFieldIdChangeTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(message),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.commonCancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(l10n.recordsSpecimenIUnderstand),
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
          title: Text(l10n.recordsSpecimenFieldIdChangeTitle),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.recordsSpecimenIUnderstand),
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
      title: context.l10n.recordsSpecimenTissueId,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            NahpuSpacing.md,
            NahpuSpacing.xs,
            NahpuSpacing.md,
            NahpuSpacing.xl,
          ),
          child: NumberedIdFields(
            store: TissueIdServices(ref: ref),
            useHorizontalLayout: !isMobile,
            previewLabel: context.l10n.recordsSpecimenNextTissueId,
          ),
        ),
      ],
    );
  }
}

/// Auto-numbering for lot individual tags. Shown only for catalog formats
/// that record lot individuals.
class IndividualTagIdSetting extends ConsumerWidget {
  const IndividualTagIdSetting({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonSettingSection(
      title: context.l10n.recordsSpecimenIndividualTagId,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            NahpuSpacing.md,
            NahpuSpacing.xs,
            NahpuSpacing.md,
            NahpuSpacing.xl,
          ),
          child: NumberedIdFields(
            store: IndividualTagIdServices(ref: ref),
            useHorizontalLayout: !isMobile,
            previewLabel: context.l10n.recordsSpecimenNextTag,
            prefixHint: 'FT-',
            suffixHint: '-A',
          ),
        ),
      ],
    );
  }
}
