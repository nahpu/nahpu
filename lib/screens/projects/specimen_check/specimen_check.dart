import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/specimen_check/components/tissue_box_card.dart';
import 'package:nahpu/screens/projects/specimen_check/components/tissue_camera_scanner.dart';
import 'package:nahpu/screens/projects/specimen_check/components/tissue_check_log.dart';
import 'package:nahpu/screens/projects/specimen_check/components/tissue_check_setup.dart';
import 'package:nahpu/screens/projects/specimen_check/components/tissue_scan_card.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/specimen_check.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/specimen_check/specimen_check_mode.dart';
import 'package:nahpu/services/specimen_check/tissue_box.dart';
import 'package:nahpu/services/specimen_check/tissue_check_service.dart';
import 'package:nahpu/services/specimen_check/tissue_check_session.dart';
import 'package:nahpu/services/specimen_check/tissue_check_settings.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Checks specimens against the project by scanning. Tissue check fills a
/// box: each scanned tube gets the chosen field value and the next cell as
/// its storage location.
class SpecimenCheckScreen extends ConsumerStatefulWidget {
  const SpecimenCheckScreen({super.key, this.cameraAvailable});

  /// Overrides the platform check for the camera button. Used by tests.
  final bool? cameraAvailable;

  @override
  ConsumerState<SpecimenCheckScreen> createState() =>
      _SpecimenCheckScreenState();
}

class _SpecimenCheckScreenState extends ConsumerState<SpecimenCheckScreen> {
  late final TissueCheckSession _session;
  SpecimenCheckMode _mode = SpecimenCheckMode.tissue;
  TissueScanOutcome? _outcome;
  int _busyCount = 0;

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
    );
    final logCard = TissueCheckLogCard(entries: _session.entries);

    return Scaffold(
      appBar: AppBar(title: const Text('Specimen check')),
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
                        child: SegmentedButton<SpecimenCheckMode>(
                          segments: [
                            for (final mode in SpecimenCheckMode.values)
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
                              child: SpecimenCheckColumn(
                                children: [setupCard, scanCard, logCard],
                              ),
                            ),
                          ],
                        )
                      else
                        SpecimenCheckColumn(
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
    final update = _session.updateSettings(settings);
    setState(() {});
    _run(() => update);
  }

  Future<void> _scan(String code) async {
    await _run(() async {
      final outcome = await _session.scan(
        code,
        pickPart: (records) => _pickPart(code.trim(), records),
      );
      if (mounted) setState(() => _outcome = outcome);
    });
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
  }

  Future<SpecimenPartProjectRecord?> _pickPart(
    String code,
    List<SpecimenPartProjectRecord> records,
  ) async {
    if (!mounted) return null;
    return showDialog<SpecimenPartProjectRecord>(
      context: context,
      builder: (context) => TissueMatchDialog(code: code, records: records),
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
class SpecimenCheckColumn extends StatelessWidget {
  const SpecimenCheckColumn({super.key, required this.children});

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
