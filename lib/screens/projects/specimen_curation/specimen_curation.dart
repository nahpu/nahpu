import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_box_card.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_camera_scanner.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_check_log.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_check_setup.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_scan_card.dart';
import 'package:nahpu/screens/projects/specimen_curation/components/tissue_work_list.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
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
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// Curates specimens by scanning. Tissue mode fills a box: each scanned tube
/// gets the chosen field value and the next cell as its storage location.
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
  List<SpecimenPartProjectRecord>? _workList;
  int _workIndex = 0;

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
  }

  @override
  Widget build(BuildContext context) {
    final settings = _session.settings;
    final partTypes = _vocabulary(specimenTypePrefKey);
    final treatments = _vocabulary(treatmentPrefKey);
    final boxCard = TissueBoxCard(
      boxName: settings.boxName,
      layout: _session.layout,
      occupied: _session.occupied,
      next: _session.next,
      onCellSelected: _selectCell,
      onNextBox: () => _run(_session.nextBox),
    );
    final setupCard = TissueCheckSetupCard(
      settings: settings,
      onChanged: _updateSettings,
      partTypes: partTypes,
      treatments: treatments,
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
      entryMode: _entryMode,
      onEntryModeChanged: _setEntryMode,
      workList: TissueWorkListPanel(
        records: _workList,
        index: _workIndex,
        labelFor: _session.labelFor,
        nextLocation: _session.nextLocation,
        isBusy: _busyCount > 0,
        onPlace: _placeCurrent,
        onSkip: _skipCurrent,
        onSelect: (index) => setState(() => _workIndex = index),
      ),
    );
    final logCard = TissueCheckLogCard(entries: _session.entries);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.projectTissueTitle)),
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
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 23, child: boxCard),
                            const SizedBox(width: NahpuSpacing.xl),
                            Expanded(
                              flex: 20,
                              child: SpecimenCurationColumn(
                                children: [setupCard, scanCard, logCard],
                              ),
                            ),
                          ],
                        )
                      else
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

  void _selectCell(TissueCell cell) {
    setState(() => _session.selectCell(cell));
  }

  void _updateSettings(TissueCheckSettings settings) {
    final previous = _session.settings;
    final update = _session.updateSettings(settings);
    setState(() {});
    _run(() => update);
    final filtersChanged =
        previous.partType != settings.partType ||
        previous.preservation != settings.preservation;
    if (filtersChanged && _entryMode == TissueEntryMode.workList) {
      _reloadWorkList();
    }
  }

  /// The configured values plus those already used in the database.
  List<String> _vocabulary(String prefKey) {
    return ref.watch(effectiveUserDefinedFieldProvider(prefKey)).value ??
        const [];
  }

  void _setEntryMode(TissueEntryMode mode) {
    setState(() => _entryMode = mode);
    if (mode == TissueEntryMode.workList) _reloadWorkList();
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
    setState(() => _workIndex = (_workIndex + 1) % count);
  }

  Future<void> _scan(String code) async {
    _session
      ..partTypes = _vocabularyNow(specimenTypePrefKey)
      ..treatments = _vocabularyNow(treatmentPrefKey);
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

  Future<SpecimenPartProjectRecord?> _pickPart(
    String code,
    List<SpecimenPartProjectRecord> records,
  ) async {
    if (!mounted) return null;
    return showDialog<SpecimenPartProjectRecord>(
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
