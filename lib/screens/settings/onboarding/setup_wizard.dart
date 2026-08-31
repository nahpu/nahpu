import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nahpu/screens/exports/export_settings.dart';
import 'package:nahpu/screens/settings/transfer/app_settings_import.dart';
import 'package:nahpu/screens/settings/records/controlled_vocabulary.dart';
import 'package:nahpu/screens/settings/records/specimen_settings.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/screens/shared/layout/wizard.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/parasites.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// A guided pass over the settings a new user would otherwise have to find one
/// screen at a time.
///
/// Every control here is the same widget the matching settings screen uses, so
/// each setting keeps one source of truth and writes as it is changed. Skipping
/// therefore means "stop answering questions", never "undo".
class SetupWizardScreen extends ConsumerStatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  ConsumerState<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends ConsumerState<SetupWizardScreen> {
  int _step = 0;
  int _maxVisitedStep = 0;
  bool _collectsParasites = false;

  @override
  Widget build(BuildContext context) {
    final catalogFmt = ref.watch(catalogFmtNotifierProvider).asData?.value;
    final steps = _stepsFor(catalogFmt);
    // Choosing arthropods drops the parasite step, which can leave the wizard
    // parked past the end of its own step list.
    final step = _step.clamp(0, steps.length - 1);
    final maxVisitedStep = _maxVisitedStep.clamp(0, steps.length - 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Setup NAHPU')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: NahpuWizardScaffold(
                steps: steps.map((e) => e.title).toList(),
                currentStep: step,
                maxVisitedStep: maxVisitedStep,
                onStepSelected: (index) => setState(() => _step = index),
                child: _contentFor(steps[step]),
              ),
            ),
            NahpuWizardActionBar(
              step: step,
              lastStep: steps.length - 1,
              isRunning: false,
              canContinue: true,
              finalActionLabel: 'Review setup',
              finalActionIcon: Icons.checklist_rounded,
              secondaryLabel: step == 0 ? 'Skip setup' : null,
              onSecondary: step == 0 ? _close : null,
              onBack: () => setState(() => _step = step - 1),
              onContinue: () => setState(() {
                _step = step + 1;
                _maxVisitedStep = maxVisitedStep < _step
                    ? _step
                    : maxVisitedStep;
              }),
              onClose: _close,
            ),
          ],
        ),
      ),
    );
  }

  List<_SetupStep> _stepsFor(CatalogFmt? catalogFmt) {
    return [
      _SetupStep.welcome,
      _SetupStep.catalogFormat,
      _SetupStep.identifiers,
      _SetupStep.sites,
      _SetupStep.events,
      _SetupStep.specimens,
      if (catalogFmt != null && supportsParasites(catalogFmt))
        _SetupStep.parasites,
      _SetupStep.finish,
    ];
  }

  Widget _contentFor(_SetupStep step) {
    switch (step) {
      case _SetupStep.welcome:
        return const _WelcomeStep();
      case _SetupStep.catalogFormat:
        return const _CatalogFormatStep();
      case _SetupStep.identifiers:
        return const _IdentifierStep();
      case _SetupStep.sites:
        return const _SitesStep();
      case _SetupStep.events:
        return const _EventsStep();
      case _SetupStep.specimens:
        return const _SpecimensStep();
      case _SetupStep.parasites:
        return _ParasiteStep(
          collectsParasites: _collectsParasites,
          onChanged: (value) => setState(() => _collectsParasites = value),
        );
      case _SetupStep.finish:
        return _FinishStep(collectsParasites: _collectsParasites);
    }
  }

  void _close() => Navigator.pop(context);
}

enum _SetupStep {
  welcome('Welcome'),
  catalogFormat('Catalog format'),
  identifiers('Identifiers'),
  sites('Sites'),
  events('Events'),
  specimens('Specimens'),
  parasites('Parasites'),
  finish('Finish');

  const _SetupStep(this.title);

  final String title;
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NahpuStepHeading(
                title: 'Set up NAHPU',
                message:
                    'NAHPU records specimens using conventions you choose: how '
                    'catalog numbers are formed, and the controlled '
                    'vocabularies offered for sites, events, and specimens. '
                    'This sets them once so the rest of your work stays '
                    'consistent.',
              ),
              const SizedBox(height: NahpuSpacing.xl),
              const _WelcomeItem(
                icon: Icons.archive_outlined,
                title: 'Catalog format',
                message: 'The taxon group you catalog.',
              ),
              const _WelcomeItem(
                icon: Icons.tag_rounded,
                title: 'Identifiers',
                message: 'How field numbers and tissue numbers are formed.',
              ),
              const _WelcomeItem(
                icon: Icons.list_alt_rounded,
                title: 'Controlled vocabularies',
                message:
                    'The vocabularies offered for sites, events, and '
                    'specimens. Every one ships with sensible defaults.',
              ),
              const SizedBox(height: NahpuSpacing.xl),
              Text(
                'This takes a few minutes and nothing here is permanent. Skip '
                'it and NAHPU uses its defaults. Every answer can be changed '
                'later in Settings, or by running this wizard again from the '
                'menu.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        _SetupActionPanel(
          title: 'Already have settings from your team?',
          message:
              'A team only needs to set this up once. If a colleague has '
              'already configured NAHPU, import their user configs file and '
              'you can skip the rest of this wizard. You can export yours '
              'for everyone else at the end.',
          icon: Icons.download_outlined,
          label: 'Import user configs',
          onPressed: (context) => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const AppSettingsImport(),
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeItem extends StatelessWidget {
  const _WelcomeItem({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: NahpuSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary, size: NahpuControlSize.icon),
          const SizedBox(width: NahpuSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: NahpuSpacing.xxs),
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogFormatStep extends ConsumerWidget {
  const _CatalogFormatStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(catalogFmtNotifierProvider)
        .when(
          data: (selected) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NahpuPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NahpuStepHeading(
                      title: 'Catalog format',
                      message:
                          'The taxon group you catalog. It decides which '
                          'measurement fields appear on specimen records and '
                          'whether parasites are offered.',
                    ),
                    const SizedBox(height: NahpuSpacing.xl),
                    for (final fmt in CatalogFmt.values)
                      Padding(
                        padding: const EdgeInsets.only(bottom: NahpuSpacing.md),
                        child: _CatalogFormatTile(
                          catalogFmt: fmt,
                          selected: selected == fmt,
                          onTap: () => ref
                              .read(catalogFmtNotifierProvider.notifier)
                              .set(fmt),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: NahpuSpacing.lg),
              const _SetupNote(
                'You can change the catalog format at any time, and a single '
                'project can hold records in more than one format. Pick the '
                'one you will use most often.',
              ),
            ],
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, _) => Text('Unable to load catalog format: $error'),
        );
  }
}

class _CatalogFormatTile extends StatelessWidget {
  const _CatalogFormatTile({
    required this.catalogFmt,
    required this.selected,
    required this.onTap,
  });

  final CatalogFmt catalogFmt;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primaryContainer : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NahpuRadius.md),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: NahpuStroke.thin,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(
          matchCatFmtToIcon(catalogFmt, isFilledIcon: selected),
          color: selected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
        ),
        title: Text(matchCatFmtToTaxonGroup(catalogFmt)),
        textColor: selected ? colors.onPrimaryContainer : null,
        trailing: selected ? const Icon(Icons.check_rounded) : null,
        iconColor: selected ? colors.onPrimaryContainer : null,
        onTap: onTap,
      ),
    );
  }
}

class _IdentifierStep extends ConsumerWidget {
  const _IdentifierStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NahpuStepHeading(
                title: 'Specimen field IDs',
                message:
                    'Choose where a specimen field number comes from. Both '
                    'schemes produce a unique ID for every specimen.',
              ),
              const SizedBox(height: NahpuSpacing.xl),
              const _FieldIdModeChoice(),
              const SizedBox(height: NahpuSpacing.xl),
              const _CatalogerNote(),
            ],
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        const _TissueIdQuestion(),
        const SizedBox(height: NahpuSpacing.lg),
        const _SetupNote(
          'These identifier settings can be changed for a different project. '
          'The prefix and starting number for a project, and the field number '
          'held by a cataloger, are set per project under Settings > Catalogs '
          '> Specimens once the project exists.',
        ),
      ],
    );
  }
}

class _FieldIdModeChoice extends ConsumerWidget {
  const _FieldIdModeChoice();

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
                const personnel = _FieldIdModeCard(
                  mode: FieldIdMode.personnel,
                  iconPath: 'assets/icons/personnel_id.svg',
                  title: 'Personnel ID',
                  message:
                      'Each cataloger keeps their own running field number. '
                      'The ID is their initials plus that number.',
                );
                const project = _FieldIdModeCard(
                  mode: FieldIdMode.project,
                  iconPath: 'assets/icons/project_id.svg',
                  title: 'Project ID',
                  message:
                      'The project keeps one running number that every '
                      'cataloger draws from, with a shared prefix and suffix.',
                );
                return constraints.maxWidth >= NahpuBreakpoints.compact
                    // The cards sit in a scroll view, so the row has no height
                    // to stretch into until the tallest card is measured.
                    ? const IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: personnel),
                            SizedBox(width: NahpuSpacing.lg),
                            Expanded(child: project),
                          ],
                        ),
                      )
                    : const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          personnel,
                          SizedBox(height: NahpuSpacing.lg),
                          project,
                        ],
                      );
              },
            ),
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, _) => Text('Unable to load field ID mode: $error'),
        );
  }
}

class _FieldIdModeCard extends ConsumerWidget {
  const _FieldIdModeCard({
    required this.mode,
    required this.iconPath,
    required this.title,
    required this.message,
  });

  final FieldIdMode mode;
  final String iconPath;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const SizedBox(height: NahpuSpacing.xs),
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogerNote extends StatelessWidget {
  const _CatalogerNote();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return NahpuPanel(
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      color: colors.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: NahpuControlSize.iconMedium,
                color: colors.onSecondaryContainer,
              ),
              const SizedBox(width: NahpuSpacing.md),
              Text(
                'Cataloger, not collector',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colors.onSecondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: NahpuSpacing.md),
          Text(
            'A cataloger is often called a collector. NAHPU keeps the two '
            'apart: the collector role is restricted to people who collect '
            'specimens but are not responsible for entering data. Cataloger is '
            'the highest-level role in NAHPU, and a cataloger name is what '
            'appears in any field that asks for a personnel name.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _TissueIdQuestion extends ConsumerStatefulWidget {
  const _TissueIdQuestion();

  @override
  ConsumerState<_TissueIdQuestion> createState() => _TissueIdQuestionState();
}

class _TissueIdQuestionState extends ConsumerState<_TissueIdQuestion> {
  late bool _separate;

  @override
  void initState() {
    _separate = SpecimenSettingServices(
      ref: ref,
    ).getSpecimenSettingField(separateTissueIdKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact;
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NahpuStepHeading(
            title: 'Tissue IDs',
            message:
                'Some collections number tissues separately from the specimen, '
                'so a tissue carries its own prefix and running number. Others '
                'reuse the specimen field ID.',
          ),
          const SizedBox(height: NahpuSpacing.lg),
          SwitchListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NahpuRadius.lg),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: NahpuSpacing.lg,
              vertical: NahpuSpacing.xxs,
            ),
            title: const Text('Use a separate tissue ID'),
            value: _separate,
            onChanged: _setSeparate,
          ),
          if (_separate) ...[
            const SizedBox(height: NahpuSpacing.lg),
            AdaptiveLayout(
              useHorizontalLayout: !isMobile,
              children: const [TissuePrefixField(), TissueNumField()],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _setSeparate(bool value) async {
    await SpecimenSettingServices(
      ref: ref,
    ).setSpecimenSettingField(separateTissueIdKey, value);
    if (!mounted) return;
    setState(() => _separate = value);
  }
}

class _SitesStep extends StatelessWidget {
  const _SitesStep();

  @override
  Widget build(BuildContext context) {
    return const _VocabularyStep(
      title: 'Site vocabularies',
      message:
          'The controlled vocabularies offered when you record a site. Add '
          'your own terms, remove any you will not use, or leave the defaults '
          'alone.',
      vocabularies: [
        _Vocabulary(
          title: 'Site types',
          typePrefKey: siteTypePrefKey,
          fmtPrefKey: siteTypeFmtPrefKey,
          typeName: 'site type',
        ),
        _Vocabulary(
          title: 'Habitat types',
          typePrefKey: habitatTypePrefKey,
          fmtPrefKey: habitatTypeFmtPrefKey,
          typeName: 'habitat type',
        ),
        _Vocabulary(
          title: 'Datums',
          typePrefKey: datumPrefKey,
          fmtPrefKey: datumFmtPrefKey,
          typeName: 'datum',
          pluralName: 'datums',
        ),
      ],
    );
  }
}

class _EventsStep extends StatelessWidget {
  const _EventsStep();

  @override
  Widget build(BuildContext context) {
    return const _VocabularyStep(
      title: 'Collecting event vocabularies',
      message:
          'The controlled vocabularies offered when you record a collecting '
          'event and the people who took part in it.',
      vocabularies: [
        _Vocabulary(
          title: 'Primary activities',
          typePrefKey: collActivityPrefKey,
          fmtPrefKey: collActivityFmtPrefKey,
          typeName: 'primary activity',
        ),
        _Vocabulary(
          title: 'Collection methods',
          typePrefKey: collMethodPrefKey,
          fmtPrefKey: collMethodFmtPrefKey,
          typeName: 'collection method',
        ),
        _Vocabulary(
          title: 'Personnel roles',
          typePrefKey: collRolePrefKey,
          fmtPrefKey: collRoleFmtPrefKey,
          typeName: 'personnel role',
        ),
      ],
    );
  }
}

class _SpecimensStep extends StatelessWidget {
  const _SpecimensStep();

  @override
  Widget build(BuildContext context) {
    return const _VocabularyStep(
      title: 'Specimen vocabularies',
      message:
          'The controlled vocabularies offered on a specimen record. '
          'Identifier settings were covered earlier and are not repeated '
          'here.',
      vocabularies: [
        _Vocabulary(
          title: 'Identification methods',
          typePrefKey: idMethodPrefKey,
          fmtPrefKey: idMethodFmtPrefKey,
          typeName: 'identification method',
        ),
        _Vocabulary(
          title: 'Life stages',
          typePrefKey: lifeStagePrefKey,
          fmtPrefKey: lifeStageFmtPrefKey,
          typeName: 'life stage',
        ),
        _Vocabulary(
          title: 'Specimen types',
          typePrefKey: specimenTypePrefKey,
          fmtPrefKey: specimenTypeFmtPrefKey,
          typeName: 'specimen type',
        ),
        _Vocabulary(
          title: 'Treatments',
          typePrefKey: treatmentPrefKey,
          fmtPrefKey: treatmentFmtPrefKey,
          typeName: 'treatment',
        ),
        _Vocabulary(
          title: 'Conditions',
          typePrefKey: conditionPrefKey,
          fmtPrefKey: conditionFmtPrefKey,
          typeName: 'condition',
        ),
      ],
    );
  }
}

class _ParasiteStep extends StatelessWidget {
  const _ParasiteStep({
    required this.collectsParasites,
    required this.onChanged,
  });

  final bool collectsParasites;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NahpuStepHeading(
                title: 'Parasites',
                message:
                    'NAHPU can record parasites found on or in a specimen. '
                    'Answer no and this step stays out of your way; the '
                    'parasite vocabularies are still there in Settings if '
                    'you need them later.',
              ),
              const SizedBox(height: NahpuSpacing.lg),
              SwitchListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NahpuRadius.lg),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: NahpuSpacing.lg,
                  vertical: NahpuSpacing.xxs,
                ),
                title: const Text('I will collect parasites'),
                value: collectsParasites,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (collectsParasites) ...[
          const SizedBox(height: NahpuSpacing.lg),
          const _VocabularyPanels(
            vocabularies: [
              _Vocabulary(
                title: 'Categories',
                typePrefKey: parasiteCategoryPrefKey,
                fmtPrefKey: parasiteCategoryFmtPrefKey,
                typeName: 'category',
                pluralName: 'categories',
              ),
              _Vocabulary(
                title: 'Detection methods',
                typePrefKey: parasiteDetectionMethodPrefKey,
                fmtPrefKey: parasiteDetectionMethodFmtPrefKey,
                typeName: 'detection method',
              ),
              _Vocabulary(
                title: 'Preparation methods',
                typePrefKey: parasitePreparationMethodPrefKey,
                fmtPrefKey: parasitePreparationMethodFmtPrefKey,
                typeName: 'preparation method',
              ),
              _Vocabulary(
                title: 'Anatomical locations',
                typePrefKey: parasiteAnatomicalLocationPrefKey,
                fmtPrefKey: parasiteAnatomicalLocationFmtPrefKey,
                typeName: 'anatomical location',
              ),
              _Vocabulary(
                title: 'Storage',
                typePrefKey: parasiteStoragePrefKey,
                fmtPrefKey: parasiteStorageFmtPrefKey,
                typeName: 'storage value',
                pluralName: 'storage values',
              ),
              _Vocabulary(
                title: 'Treatments',
                typePrefKey: parasiteTreatmentPrefKey,
                fmtPrefKey: parasiteTreatmentFmtPrefKey,
                typeName: 'treatment',
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _FinishStep extends ConsumerWidget {
  const _FinishStep({required this.collectsParasites});

  final bool collectsParasites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogFmt = ref.watch(catalogFmtNotifierProvider).asData?.value;
    final fieldIdMode = ref.watch(fieldIdModeNotifierProvider).asData?.value;
    final separateTissueId = SpecimenSettingServices(
      ref: ref,
    ).getSpecimenSettingField(separateTissueIdKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NahpuStepHeading(
                title: 'You are set up',
                message: 'NAHPU will use these conventions for new records.',
              ),
              const SizedBox(height: NahpuSpacing.lg),
              _SummaryRow(
                label: 'Catalog format',
                value: catalogFmt == null
                    ? 'Not set'
                    : matchCatFmtToTaxonGroup(catalogFmt),
              ),
              _SummaryRow(
                label: 'Field ID',
                value: switch (fieldIdMode) {
                  FieldIdMode.project => 'Project ID',
                  FieldIdMode.personnel => 'Personnel ID',
                  null => 'Not set',
                },
              ),
              _SummaryRow(
                label: 'Tissue ID',
                value: separateTissueId
                    ? 'Numbered separately'
                    : 'Follows the specimen',
              ),
              if (catalogFmt != null && supportsParasites(catalogFmt))
                _SummaryRow(
                  label: 'Parasites',
                  value: collectsParasites ? 'Collected' : 'Not collected',
                ),
            ],
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        NahpuPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Controlled vocabularies',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: NahpuSpacing.md),
              for (final entry in _summaryVocabularies)
                _VocabularyCountRow(label: entry.$1, prefKey: entry.$2),
            ],
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        _SetupActionPanel(
          title: 'Share this setup with your team',
          message:
              'Your team only needs to do this once. Export these user '
              'configs and colleagues can import them to work from the same '
              'controlled vocabularies and identifier scheme.',
          icon: Icons.ios_share_outlined,
          label: 'Export user configs',
          onPressed: (context) => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const ExportSettingsForm(),
            ),
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        const _SetupNote(
          'Nothing here is locked in. Change any individual setting under '
          'Settings, or run Setup NAHPU again from the menu to walk through '
          'all of it once more.',
        ),
      ],
    );
  }

  static const _summaryVocabularies = <(String, String)>[
    ('Site types', siteTypePrefKey),
    ('Habitat types', habitatTypePrefKey),
    ('Datums', datumPrefKey),
    ('Primary activities', collActivityPrefKey),
    ('Collection methods', collMethodPrefKey),
    ('Personnel roles', collRolePrefKey),
    ('Identification methods', idMethodPrefKey),
    ('Life stages', lifeStagePrefKey),
    ('Specimen types', specimenTypePrefKey),
    ('Treatments', treatmentPrefKey),
    ('Conditions', conditionPrefKey),
  ];
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 132, child: Text(label)),
          const SizedBox(width: NahpuSpacing.xl),
          Expanded(
            child: Text(
              ': $value',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabularyCountRow extends ConsumerWidget {
  const _VocabularyCountRow({required this.label, required this.prefKey});

  final String label;
  final String prefKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref
        .watch(effectiveUserDefinedFieldProvider(prefKey))
        .asData
        ?.value
        .length;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            count == null ? '--' : '$count',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

/// One controlled vocabulary rendered in the wizard's own panel.
///
/// The settings screens let [ControlledVocabularySetting] draw its own card.
/// Here the wizard supplies the card so every panel in a step matches.
class _Vocabulary {
  const _Vocabulary({
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
}

class _VocabularyStep extends StatelessWidget {
  const _VocabularyStep({
    required this.title,
    required this.message,
    required this.vocabularies,
  });

  final String title;
  final String message;
  final List<_Vocabulary> vocabularies;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuPanel(
          child: NahpuStepHeading(title: title, message: message),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        _VocabularyPanels(vocabularies: vocabularies),
      ],
    );
  }
}

class _VocabularyPanels extends StatelessWidget {
  const _VocabularyPanels({required this.vocabularies});

  final List<_Vocabulary> vocabularies;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final vocabulary in vocabularies)
          Padding(
            padding: const EdgeInsets.only(bottom: NahpuSpacing.lg),
            child: NahpuPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vocabulary.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ControlledVocabularySetting(
                    title: vocabulary.title,
                    typePrefKey: vocabulary.typePrefKey,
                    fmtPrefKey: vocabulary.fmtPrefKey,
                    typeName: vocabulary.typeName,
                    pluralName: vocabulary.pluralName,
                    showCard: false,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A panel that pairs a short explanation with one action, used for the
/// settings hand-off between colleagues at either end of the wizard.
class _SetupActionPanel extends StatelessWidget {
  const _SetupActionPanel({
    required this.title,
    required this.message,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final String title;
  final String message;
  final IconData icon;
  final String label;
  final void Function(BuildContext context) onPressed;

  @override
  Widget build(BuildContext context) {
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: NahpuSpacing.md),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: NahpuSpacing.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => onPressed(context),
              icon: Icon(icon),
              label: Text(label),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupNote extends StatelessWidget {
  const _SetupNote(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return NahpuPanel(
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      color: colors.tertiaryContainer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: NahpuControlSize.iconMedium,
            color: colors.onTertiaryContainer,
          ),
          const SizedBox(width: NahpuSpacing.md),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
