import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/numbered_id_fields.dart';
import 'package:nahpu/screens/exports/export_settings.dart';
import 'package:nahpu/screens/settings/transfer/app_settings_import.dart';
import 'package:nahpu/screens/settings/records/controlled_vocabulary.dart';
import 'package:nahpu/screens/settings/records/specimen_settings.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/bundled_preset_checklist.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/screens/shared/layout/wizard.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/bundled_preset_service.dart';
import 'package:nahpu/services/localization/l10n.dart';
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
    final l10n = context.l10n;
    final catalogFmt = ref.watch(catalogFmtNotifierProvider).asData?.value;
    final steps = _stepsFor(catalogFmt);
    // Choosing invertebrate zoology drops the parasite step, which can leave
    // the wizard
    // parked past the end of its own step list.
    final step = _step.clamp(0, steps.length - 1);
    final maxVisitedStep = _maxVisitedStep.clamp(0, steps.length - 1);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeSetupNahpu)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: NahpuWizardScaffold(
                steps: steps.map((e) => e.title(l10n)).toList(),
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
              finalActionLabel: l10n.setupReviewSetup,
              finalActionIcon: Icons.checklist_rounded,
              secondaryLabel: step == 0 ? l10n.setupSkipSetup : null,
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
      _SetupStep.exportPresets,
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
      case _SetupStep.exportPresets:
        return const _ExportPresetsStep();
      case _SetupStep.finish:
        return _FinishStep(collectsParasites: _collectsParasites);
    }
  }

  void _close() => Navigator.pop(context);
}

enum _SetupStep {
  welcome,
  catalogFormat,
  identifiers,
  sites,
  events,
  specimens,
  parasites,
  exportPresets,
  finish;

  String title(AppLocalizations l10n) {
    return switch (this) {
      _SetupStep.welcome => l10n.setupStepWelcome,
      _SetupStep.catalogFormat => l10n.setupCatalogFormat,
      _SetupStep.identifiers => l10n.setupIdentifiers,
      _SetupStep.sites => l10n.setupStepSites,
      _SetupStep.events => l10n.setupStepEvents,
      _SetupStep.specimens => l10n.setupStepSpecimens,
      _SetupStep.parasites => l10n.setupParasites,
      _SetupStep.exportPresets => l10n.setupExportPresets,
      _SetupStep.finish => l10n.setupStepFinish,
    };
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NahpuStepHeading(
                title: l10n.setupWelcomeTitle,
                message: l10n.setupWelcomeMessage,
              ),
              const SizedBox(height: NahpuSpacing.xl),
              _WelcomeItem(
                icon: Icons.archive_outlined,
                title: l10n.setupCatalogFormat,
                message: l10n.setupWelcomeCatalogFormat,
              ),
              _WelcomeItem(
                icon: Icons.tag_rounded,
                title: l10n.setupIdentifiers,
                message: l10n.setupWelcomeIdentifiers,
              ),
              _WelcomeItem(
                icon: Icons.list_alt_rounded,
                title: l10n.setupControlledVocabularies,
                message: l10n.setupWelcomeVocabularies,
              ),
              _WelcomeItem(
                icon: Icons.print_outlined,
                title: l10n.setupExportPresets,
                message: l10n.setupWelcomeExportPresets,
              ),
              const SizedBox(height: NahpuSpacing.xl),
              Text(
                l10n.setupWelcomeNotPermanent,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        _SetupActionPanel(
          title: l10n.setupImportTitle,
          message: l10n.setupImportMessage,
          icon: Icons.download_outlined,
          label: l10n.drawerImportUserConfigs,
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
    final l10n = context.l10n;
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
                    NahpuStepHeading(
                      title: l10n.setupCatalogFormat,
                      message: l10n.setupCatalogFormatMessage,
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
              _SetupNote(l10n.setupCatalogFormatNote),
            ],
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, _) =>
              Text(l10n.setupCatalogFormatLoadError(error.toString())),
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(catalogFmtDisplayName(catalogFmt))),
            if (isCatalogFmtBeta(catalogFmt)) ...[
              const SizedBox(width: NahpuSpacing.md),
              const BetaBadge(),
            ],
          ],
        ),
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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NahpuStepHeading(
                title: l10n.setupFieldIdsTitle,
                message: l10n.setupFieldIdsMessage,
              ),
              const SizedBox(height: NahpuSpacing.xl),
              const FieldIdModeChoice(),
              const SizedBox(height: NahpuSpacing.xl),
            ],
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        const _TissueIdQuestion(),
        const SizedBox(height: NahpuSpacing.lg),
        _SetupNote(l10n.setupIdentifiersNote),
      ],
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
    final l10n = context.l10n;
    final isMobile =
        MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact;
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NahpuStepHeading(
            title: l10n.setupTissueIdsTitle,
            message: l10n.setupTissueIdsMessage,
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
            title: Text(l10n.setupUseSeparateTissueId),
            value: _separate,
            onChanged: _setSeparate,
          ),
          if (_separate) ...[
            const SizedBox(height: NahpuSpacing.lg),
            NumberedIdFields(
              store: TissueIdServices(ref: ref),
              useHorizontalLayout: !isMobile,
              previewLabel: l10n.setupNextTissueId,
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
    final l10n = context.l10n;
    return _VocabularyStep(
      title: l10n.setupSitesTitle,
      message: l10n.setupSitesMessage,
      vocabularies: [
        _Vocabulary(
          title: l10n.setupSiteTypes,
          typePrefKey: siteTypePrefKey,
          fmtPrefKey: siteTypeFmtPrefKey,
          typeName: 'site type',
        ),
        _Vocabulary(
          title: l10n.setupHabitatTypes,
          typePrefKey: habitatTypePrefKey,
          fmtPrefKey: habitatTypeFmtPrefKey,
          typeName: 'habitat type',
        ),
        _Vocabulary(
          title: l10n.setupDatums,
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
    final l10n = context.l10n;
    return _VocabularyStep(
      title: l10n.setupEventsTitle,
      message: l10n.setupEventsMessage,
      vocabularies: [
        _Vocabulary(
          title: l10n.setupPrimaryActivities,
          typePrefKey: collActivityPrefKey,
          fmtPrefKey: collActivityFmtPrefKey,
          typeName: 'primary activity',
        ),
        _Vocabulary(
          title: l10n.setupCollectionMethods,
          typePrefKey: collMethodPrefKey,
          fmtPrefKey: collMethodFmtPrefKey,
          typeName: 'collection method',
        ),
        _Vocabulary(
          title: l10n.setupPersonnelRoles,
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
    final l10n = context.l10n;
    return _VocabularyStep(
      title: l10n.setupSpecimensTitle,
      message: l10n.setupSpecimensMessage,
      vocabularies: [
        _Vocabulary(
          title: l10n.setupIdentificationMethods,
          typePrefKey: idMethodPrefKey,
          fmtPrefKey: idMethodFmtPrefKey,
          typeName: 'identification method',
        ),
        _Vocabulary(
          title: l10n.setupLifeStages,
          typePrefKey: lifeStagePrefKey,
          fmtPrefKey: lifeStageFmtPrefKey,
          typeName: 'life stage',
        ),
        _Vocabulary(
          title: l10n.setupSpecimenTypes,
          typePrefKey: specimenTypePrefKey,
          fmtPrefKey: specimenTypeFmtPrefKey,
          typeName: 'specimen type',
        ),
        _Vocabulary(
          title: l10n.setupTreatments,
          typePrefKey: treatmentPrefKey,
          fmtPrefKey: treatmentFmtPrefKey,
          typeName: 'treatment',
        ),
        _Vocabulary(
          title: l10n.setupConditions,
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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NahpuStepHeading(
                title: l10n.setupParasites,
                message: l10n.setupParasitesMessage,
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
                title: Text(l10n.setupCollectsParasites),
                value: collectsParasites,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (collectsParasites) ...[
          const SizedBox(height: NahpuSpacing.lg),
          _VocabularyPanels(
            vocabularies: [
              _Vocabulary(
                title: l10n.setupParasiteCategories,
                typePrefKey: parasiteCategoryPrefKey,
                fmtPrefKey: parasiteCategoryFmtPrefKey,
                typeName: 'category',
                pluralName: 'categories',
              ),
              _Vocabulary(
                title: l10n.setupDetectionMethods,
                typePrefKey: parasiteDetectionMethodPrefKey,
                fmtPrefKey: parasiteDetectionMethodFmtPrefKey,
                typeName: 'detection method',
              ),
              _Vocabulary(
                title: l10n.setupPreparationMethods,
                typePrefKey: parasitePreparationMethodPrefKey,
                fmtPrefKey: parasitePreparationMethodFmtPrefKey,
                typeName: 'preparation method',
              ),
              _Vocabulary(
                title: l10n.setupAnatomicalLocations,
                typePrefKey: parasiteAnatomicalLocationPrefKey,
                fmtPrefKey: parasiteAnatomicalLocationFmtPrefKey,
                typeName: 'anatomical location',
              ),
              _Vocabulary(
                title: l10n.setupStorage,
                typePrefKey: parasiteStoragePrefKey,
                fmtPrefKey: parasiteStorageFmtPrefKey,
                typeName: 'storage value',
                pluralName: 'storage values',
              ),
              _Vocabulary(
                title: l10n.setupTreatments,
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
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NahpuStepHeading(
                title: l10n.setupFinishTitle,
                message: l10n.setupFinishMessage,
              ),
              const SizedBox(height: NahpuSpacing.lg),
              _SummaryRow(
                label: l10n.setupCatalogFormat,
                value: catalogFmt == null
                    ? l10n.setupNotSet
                    : catalogFmtDisplayName(catalogFmt),
              ),
              _SummaryRow(
                label: l10n.setupFieldId,
                value: switch (fieldIdMode) {
                  FieldIdMode.project => l10n.setupProjectId,
                  FieldIdMode.personnel => l10n.setupPersonnelId,
                  null => l10n.setupNotSet,
                },
              ),
              _SummaryRow(
                label: l10n.setupTissueId,
                value: separateTissueId
                    ? l10n.setupTissueNumberedSeparately
                    : l10n.setupTissueFollowsSpecimen,
              ),
              if (catalogFmt != null && supportsParasites(catalogFmt))
                _SummaryRow(
                  label: l10n.setupParasites,
                  value: collectsParasites
                      ? l10n.setupParasitesCollected
                      : l10n.setupParasitesNotCollected,
                ),
              _ExportPresetSummaryRow(catalogFmt: catalogFmt),
            ],
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        NahpuPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.setupControlledVocabularies,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: NahpuSpacing.md),
              for (final entry in _summaryVocabularies(l10n))
                _VocabularyCountRow(label: entry.$1, prefKey: entry.$2),
            ],
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        _SetupActionPanel(
          title: l10n.setupShareTitle,
          message: l10n.setupShareMessage,
          icon: Icons.ios_share_outlined,
          label: l10n.drawerExportUserConfigs,
          onPressed: (context) => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const ExportSettingsForm(),
            ),
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        _SetupNote(l10n.setupFinishNote),
      ],
    );
  }

  List<(String, String)> _summaryVocabularies(AppLocalizations l10n) {
    return [
      (l10n.setupSiteTypes, siteTypePrefKey),
      (l10n.setupHabitatTypes, habitatTypePrefKey),
      (l10n.setupDatums, datumPrefKey),
      (l10n.setupPrimaryActivities, collActivityPrefKey),
      (l10n.setupCollectionMethods, collMethodPrefKey),
      (l10n.setupPersonnelRoles, collRolePrefKey),
      (l10n.setupIdentificationMethods, idMethodPrefKey),
      (l10n.setupLifeStages, lifeStagePrefKey),
      (l10n.setupSpecimenTypes, specimenTypePrefKey),
      (l10n.setupTreatments, treatmentPrefKey),
      (l10n.setupConditions, conditionPrefKey),
    ];
  }
}

/// Offers the presets NAHPU ships with.
///
/// Presets that suit any catalog format are usually added at first launch
/// already. Presets written for one catalog format are optional, so they start
/// unchecked.
class _ExportPresetsStep extends ConsumerStatefulWidget {
  const _ExportPresetsStep();

  @override
  ConsumerState<_ExportPresetsStep> createState() => _ExportPresetsStepState();
}

class _ExportPresetsStepState extends ConsumerState<_ExportPresetsStep> {
  /// Checkbox choices keyed by asset path, overriding each preset's default.
  final Map<String, bool> _choices = {};
  bool _adding = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final catalogFmt = ref.watch(catalogFmtNotifierProvider).asData?.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuPanel(
          child: NahpuStepHeading(
            title: l10n.setupExportPresets,
            message: l10n.setupExportPresetsMessage,
          ),
        ),
        const SizedBox(height: NahpuSpacing.lg),
        ref
            .watch(bundledPresetStatusProvider(catalogFmt))
            .when(
              data: (statuses) {
                // Templates arrive with the layouts that print them.
                final offered = statuses
                    .where((s) => s.preset.kind != BundledPresetKind.template)
                    .toList();
                final generic = offered
                    .where((s) => s.preset.isGeneric)
                    .toList();
                final specific = offered
                    .where((s) => !s.preset.isGeneric)
                    .toList();
                final selected = [
                  for (final status in offered)
                    if (!status.isInstalled && _isChecked(status))
                      status.preset,
                ];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (generic.isNotEmpty)
                      BundledPresetChecklist(
                        title: l10n.setupPresetDefaults,
                        message: l10n.setupPresetDefaultsMessage,
                        statuses: generic,
                        isChecked: _isChecked,
                        onChanged: _setChoice,
                      ),
                    if (catalogFmt != null && specific.isNotEmpty) ...[
                      const SizedBox(height: NahpuSpacing.lg),
                      BundledPresetChecklist(
                        title: l10n.setupPresetsForFormat(
                          catalogFmtDisplayName(catalogFmt),
                        ),
                        message: l10n.setupPresetsForFormatMessage,
                        statuses: specific,
                        isChecked: _isChecked,
                        onChanged: _setChoice,
                      ),
                    ],
                    const SizedBox(height: NahpuSpacing.lg),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.tonalIcon(
                        onPressed: selected.isEmpty || _adding
                            ? null
                            : () => _add(selected),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.setupAddSelectedPresets),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const CommonProgressIndicator(),
              error: (error, _) =>
                  Text(l10n.setupBundledPresetsLoadError(error.toString())),
            ),
      ],
    );
  }

  bool _isChecked(BundledPresetStatus status) {
    return status.isInstalled ||
        (_choices[status.preset.assetPath] ?? status.preset.isGeneric);
  }

  void _setChoice(BundledPreset preset, bool value) {
    setState(() => _choices[preset.assetPath] = value);
  }

  Future<void> _add(List<BundledPreset> presets) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _adding = true);
    try {
      final result = await ref
          .read(bundledPresetServiceProvider)
          .loadSelected(presets);
      ref.invalidate(bundledPresetStatusProvider);
      ref.invalidate(allBundledPresetStatusProvider);
      messenger.showSnackBar(SnackBar(content: Text(result.message)));
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.setupAddPresetsError(error.toString()))),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }
}

class _ExportPresetSummaryRow extends ConsumerWidget {
  const _ExportPresetSummaryRow({required this.catalogFmt});

  final CatalogFmt? catalogFmt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statuses = ref
        .watch(bundledPresetStatusProvider(catalogFmt))
        .asData
        ?.value;
    int installed(BundledPresetKind kind) =>
        statuses
            ?.where(
              (status) => status.isInstalled && status.preset.kind == kind,
            )
            .length ??
        0;
    final l10n = context.l10n;
    return _SummaryRow(
      label: l10n.setupExportPresets,
      value: statuses == null
          ? '--'
          : l10n.setupExportPresetCounts(
              installed(BundledPresetKind.document),
              installed(BundledPresetKind.record),
            ),
    );
  }
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
