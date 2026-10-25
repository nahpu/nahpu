import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_box_card.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_camera_scanner.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_cell_inspector.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_check_log.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_check_setup.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_scan_card.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_work_list.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/screens/specimens/specimen_view.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/specimen_curation.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/services/specimen_curation/specimen_curation_mode.dart';
import 'package:nahpu/services/specimen_curation/tissue_box.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_service.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_session.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_item.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// Curates specimens by scanning. Tissue mode fills a box: each scanned tube,
/// a specimen part or optionally a parasite, gets the chosen field value and
/// the next cell as its storage location. Still in beta.
class SpecimenCurationScreen extends ConsumerStatefulWidget {
  const SpecimenCurationScreen({super.key, this.cameraAvailable});

  /// Overrides the platform check for the camera button. Used by tests.
  final bool? cameraAvailable;

  @override
  ConsumerState<SpecimenCurationScreen> createState() =>
      _SpecimenCurationScreenState();
}

class _SpecimenCurationScreenState
    extends ConsumerState<SpecimenCurationScreen> {
  late final TissueCheckSession _session;
  SpecimenCurationMode _mode = SpecimenCurationMode.tissue;
  TissueEntryMode _entryMode = TissueEntryMode.scan;
  TissueScanOutcome? _outcome;
  int _busyCount = 0;

  /// The work list, or null while it loads.
  List<TissueItemRecord>? _workList;
  int _workIndex = 0;

  /// The filled cell shown in the inspector, with the box it belongs to so
  /// it never shows over another box.
  ({String box, TissueCell cell})? _inspected;

  /// Codes suggested while typing in the scan field.
  List<String> _scanCodes = const [];

  @override
  void initState() {
    super.initState();
    _session = TissueCheckSession(
      service: TissueCheckService(
        database: ref.read(databaseProvider),
        projectUuid: ref.read(projectUuidProvider),
      ),
      settings: ref.read(tissueCheckSettingsProvider),
      saveSettings: ref.read(tissueCheckSettingsProvider.notifier).set,
      onWrite: _refreshParts,
    );
    _busyCount++;
    _session.load().whenComplete(() {
      if (mounted) setState(() => _busyCount--);
    });
    _reloadScanCodes();
  }

  @override
  Widget build(BuildContext context) {
    final settings = _session.settings;
    final partTypes = _vocabulary(specimenTypePrefKey);
    final treatments = _treatments(settings.includeParasites, _vocabulary);
    final inspected = _inspected?.box == settings.boxName
        ? _inspected!.cell
        : null;
    final inspectedItems = inspected == null
        ? const <TissueItemRecord>[]
        : _session.itemsAt(inspected);
    final boxCard = TissueBoxCard(
      boxName: settings.boxName,
      layout: _session.layout,
      occupied: _session.occupied,
      next: _session.next,
      shortLabelFor: _session.shortLabelFor,
      labelFor: _session.labelFor,
      inspected: inspectedItems.isEmpty ? null : inspected,
      onInspect: (cell) => setState(
        () => _inspected = _inspected?.cell == cell
            ? null
            : (box: settings.boxName, cell: cell),
      ),
      inspector: inspectedItems.isEmpty
          ? null
          : TissueCellInspector(
              cellLabel: _session.layout.cellLabel(inspected!),
              items: inspectedItems,
              labelFor: _session.labelFor,
              detailFor: _session.detailFor,
              onDetails: _showDetails,
              onClose: () => setState(() => _inspected = null),
            ),
      onCellSelected: _selectCell,
      onNextBox: () => _changeBox(_session.nextBox),
      onPreviousBox: settings.boxNumber > 1
          ? () => _changeBox(_session.previousBox)
          : null,
    );
    final setupCard = TissueCheckSetupCard(
      settings: settings,
      onChanged: _updateSettings,
      partTypes: partTypes,
      treatments: treatments,
      parasiteCategories: settings.includeParasites
          ? _vocabulary(parasiteCategoryPrefKey)
          : const [],
    );
    final scanCard = TissueScanCard(
      outcome: _outcome,
      isBusy: _busyCount > 0,
      canUndo: _session.entries.isNotEmpty,
      onScan: _scan,
      onUndo: _undo,
      autofocus: _shouldAutofocus(context),
      onOpenCamera: widget.cameraAvailable ?? supportsCameraScanning
          ? _openCamera
          : null,
      identifyBy: settings.identifyBy,
      suggestions: _scanCodes,
      onIdentifyByChanged: (identifyBy) =>
          _updateSettings(settings.copyWith(identifyBy: identifyBy)),
      includeParasites: settings.includeParasites,
      entryMode: _entryMode,
      onEntryModeChanged: _setEntryMode,
      workList: TissueWorkListPanel(
        records: _workList,
        index: _workIndex,
        labelFor: _session.labelFor,
        searchTextFor: _session.searchTextFor,
        nextLocation: _session.nextLocation,
        isBusy: _busyCount > 0,
        onPlace: _placeCurrent,
        onSkip: _skipCurrent,
        onSelect: (index) => setState(() => _workIndex = index),
      ),
    );
    final logCard = TissueCheckLogCard(
      entries: _session.entries,
      skipped: _session.skipped,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                context.l10n.projectTissueTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: NahpuSpacing.sm),
            const BetaBadge(),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= NahpuBreakpoints.desktop;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                NahpuSpacing.xl,
                NahpuPageMargin.top,
                NahpuSpacing.xl,
                NahpuPageMargin.bottom,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: NahpuContentWidth.settings,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SegmentedButton<SpecimenCurationMode>(
                          segments: [
                            for (final mode in SpecimenCurationMode.values)
                              ButtonSegment(
                                value: mode,
                                label: Text(mode.label),
                                icon: const Icon(Icons.science_outlined),
                              ),
                          ],
                          selected: {_mode},
                          showSelectedIcon: false,
                          onSelectionChanged: (selection) =>
                              setState(() => _mode = selection.first),
                        ),
                      ),
                      const SizedBox(height: NahpuSpacing.xl),
                      if (isWide) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 23, child: boxCard),
                            const SizedBox(width: NahpuSpacing.xl),
                            Expanded(
                              flex: 20,
                              child: SpecimenCurationColumn(
                                children: [setupCard, scanCard],
                              ),
                            ),
                          ],
                        ),
                        // The log spans both columns, so long labels and
                        // the skipped list have room side by side.
                        const SizedBox(height: NahpuSpacing.xl),
                        logCard,
                      ] else
                        SpecimenCurationColumn(
                          children: [boxCard, setupCard, scanCard, logCard],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Wide layouts and desktops scan without a soft keyboard covering the
  /// box, so the field can take focus at once.
  bool _shouldAutofocus(BuildContext context) {
    final isDesktop = switch (defaultTargetPlatform) {
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux => true,
      _ => false,
    };
    return isDesktop ||
        MediaQuery.sizeOf(context).width >= NahpuBreakpoints.desktop;
  }

  /// Steps to another box and closes the inspector, which belongs to the
  /// box being left.
  Future<void> _changeBox(Future<void> Function() step) {
    setState(() => _inspected = null);
    return _run(step);
  }

  Future<void> _showDetails(TissueItemRecord record) async {
    final open = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => TissueItemDetailsSheet(
        record: record,
        label: _session.labelFor(record),
        fieldId: _session.service.fieldIdOf(record.specimen.uuid),
        onOpenRecord: () => Navigator.pop(context, true),
      ),
    );
    if (open == true && mounted) await _openRecord(record);
  }

  /// Opens the tube's specimen, then reads the box back, since the form
  /// may have moved or relabeled the tube.
  Future<void> _openRecord(TissueItemRecord record) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SpecimenFormView(specimenUuid: record.specimen.uuid),
      ),
    );
    if (!mounted) return;
    await _run(_session.load);
    if (_entryMode == TissueEntryMode.workList) await _reloadWorkList();
  }

  void _selectCell(TissueCell cell) {
    setState(() => _session.selectCell(cell));
  }

  void _updateSettings(TissueCheckSettings settings) {
    final previous = _session.settings;
    final update = _session.updateSettings(settings);
    setState(() {});
    _run(() => update);
    final filtersChanged =
        !setEquals(previous.partTypes, settings.partTypes) ||
        !setEquals(previous.preservations, settings.preservations) ||
        previous.includeParasites != settings.includeParasites ||
        !setEquals(previous.parasiteCategories, settings.parasiteCategories);
    if (filtersChanged && _entryMode == TissueEntryMode.workList) {
      _reloadWorkList();
    }
    if (previous.identifyBy != settings.identifyBy ||
        previous.includeParasites != settings.includeParasites) {
      _reloadScanCodes();
    }
  }

  /// The configured values plus those already used in the database.
  List<String> _vocabulary(String prefKey) {
    return ref.watch(effectiveUserDefinedFieldProvider(prefKey)).value ??
        const [];
  }

  /// Part treatments, plus parasite treatments when parasites are included.
  List<String> _treatments(
    bool includeParasites,
    List<String> Function(String prefKey) vocabulary,
  ) {
    final parts = vocabulary(treatmentPrefKey);
    if (!includeParasites) return parts;
    return mergeVocabularyOptions(parts, vocabulary(parasiteTreatmentPrefKey));
  }

  void _setEntryMode(TissueEntryMode mode) {
    setState(() => _entryMode = mode);
    if (mode == TissueEntryMode.workList) _reloadWorkList();
  }

  Future<void> _reloadScanCodes() async {
    final codes = await _session.scanCodes();
    if (mounted) setState(() => _scanCodes = codes);
  }

  Future<void> _reloadWorkList() async {
    setState(() => _workList = null);
    final records = await _session.workList();
    if (!mounted) return;
    setState(() {
      _workList = records;
      _workIndex = records.isEmpty
          ? 0
          : _workIndex.clamp(0, records.length - 1);
    });
  }

  Future<void> _placeCurrent() async {
    final records = _workList;
    if (records == null || records.isEmpty) return;
    final record = records[_workIndex];
    await _run(() async {
      final outcome = await _session.place(record);
      if (!mounted) return;
      setState(() {
        _outcome = outcome;
        if (outcome.status == TissueScanStatus.checked) {
          records.removeAt(_workIndex);
          if (_workIndex >= records.length) _workIndex = 0;
        }
      });
    });
  }

  void _skipCurrent() {
    final count = _workList?.length ?? 0;
    if (count < 2) return;
    setState(() {
      _session.skip(_workList![_workIndex]);
      _workIndex = (_workIndex + 1) % count;
    });
  }

  Future<void> _scan(String code) async {
    _session
      ..partTypes = _vocabularyNow(specimenTypePrefKey)
      ..treatments = _treatments(
        _session.settings.includeParasites,
        _vocabularyNow,
      )
      ..parasiteLabel = context.l10n.projectTissueParasite;
    await _run(() async {
      final outcome = await _session.scan(
        code,
        pickPart: (records) => _pickPart(code.trim(), records),
      );
      if (mounted) setState(() => _outcome = outcome);
    });
  }

  List<String> _vocabularyNow(String prefKey) {
    return ref.read(effectiveUserDefinedFieldProvider(prefKey)).value ??
        const [];
  }

  Future<TissueScanOutcome> _scanFromCamera(String code) async {
    final outcome = await _session.scan(
      code,
      pickPart: (records) => _pickPart(code, records),
    );
    if (mounted) setState(() => _outcome = outcome);
    return outcome;
  }

  Future<void> _undo() async {
    await _run(() async {
      final outcome = await _session.undoLast();
      if (mounted && outcome != null) setState(() => _outcome = outcome);
    });
    if (mounted && _entryMode == TissueEntryMode.workList) {
      await _reloadWorkList();
    }
  }

  Future<TissueItemRecord?> _pickPart(
    String code,
    List<TissueItemRecord> records,
  ) async {
    if (!mounted) return null;
    return showDialog<TissueItemRecord>(
      context: context,
      builder: (context) => TissueMatchDialog(
        code: code,
        records: records,
        labelFor: _session.labelFor,
      ),
    );
  }

  Future<void> _openCamera() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TissueCameraScanner(onCode: _scanFromCamera),
      ),
    );
  }

  void _refreshParts() {
    ref.invalidate(partBySpecimenProvider);
    ref.invalidate(specimenPartEntryProvider);
    ref.invalidate(parasiteBySpecimenProvider);
    ref.invalidate(parasiteEntryProvider);
  }

  Future<void> _run(Future<void> Function() operation) async {
    setState(() => _busyCount++);
    try {
      await operation();
    } finally {
      if (mounted) setState(() => _busyCount--);
    }
  }
}

/// Stacks the tissue check cards with even spacing.
class SpecimenCurationColumn extends StatelessWidget {
  const SpecimenCurationColumn({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, child) in children.indexed) ...[
          if (index > 0) const SizedBox(height: NahpuSpacing.xl),
          child,
        ],
      ],
    );
  }
}
