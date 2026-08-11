import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/settings/export_preset_edit.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  const firstPreset = ExportPresetModel(
    recordType: RecordType.site,
    specimenRecordType: SpecimenRecordType.allTaxa,
    headerFormat: ExportHeaderFormat.fieldName,
    mappings: [ExportFieldMapping(expression: '[site::siteID]')],
  );
  const secondPreset = ExportPresetModel(
    recordType: RecordType.narrative,
    specimenRecordType: SpecimenRecordType.allTaxa,
    headerFormat: ExportHeaderFormat.fieldName,
    mappings: [ExportFieldMapping(expression: '[narrative::narrativeID]')],
  );

  testWidgets('switching presets flushes the previous pending snapshot',
      (tester) async {
    final notifier = _FakeExportPresetNotifier({
      'first': firstPreset,
      'second': secondPreset,
    });
    late void Function(String name, ExportPresetModel preset) selectPreset;
    var selectedName = 'first';
    var selectedPreset = firstPreset;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exportPresetNotifierProvider.overrideWith(() => notifier),
        ],
        child: MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              selectPreset = (name, preset) => setState(() {
                    selectedName = name;
                    selectedPreset = preset;
                  });
              return Scaffold(
                body: ExportPresetEditForm(
                  presetName: selectedName,
                  initialPreset: selectedPreset,
                  onPresetRenamed: (_, _) {},
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preset name'),
      'renamed-first',
    );
    selectPreset('second', secondPreset);
    await tester.pump();
    await tester.pump();

    expect(notifier.renames, [('first', 'renamed-first')]);
    expect(notifier.savedPresets.single, firstPreset);
  });

  testWidgets('provider-driven deletion does not flush a pending edit',
      (tester) async {
    final notifier = _FakeExportPresetNotifier({'first': firstPreset});
    var showEditor = true;
    late StateSetter updateHarness;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exportPresetNotifierProvider.overrideWith(() => notifier),
        ],
        child: MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              updateHarness = setState;
              return Scaffold(
                body: showEditor
                    ? const ExportPresetEditForm(
                        presetName: 'first',
                        initialPreset: firstPreset,
                        onPresetRenamed: _ignoreRename,
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preset name'),
      'should-not-return',
    );
    notifier.beginDelete();
    updateHarness(() => showEditor = false);
    await tester.pump();

    expect(notifier.renames, isEmpty);
    expect(notifier.savedPresets, isEmpty);
  });
}

void _ignoreRename(String oldName, String newName) {}

class _FakeExportPresetNotifier extends ExportPresetNotifier {
  _FakeExportPresetNotifier(this.presets);

  final Map<String, ExportPresetModel> presets;
  final List<(String, String)> renames = [];
  final List<ExportPresetModel> savedPresets = [];

  @override
  Future<Map<String, ExportPresetModel>> build() async => presets;

  @override
  Future<void> savePreset(String name, ExportPresetModel preset) async {
    savedPresets.add(preset);
  }

  @override
  Future<void> renamePreset(
    String previousName,
    String nextName,
    ExportPresetModel preset,
  ) async {
    renames.add((previousName, nextName));
    savedPresets.add(preset);
  }

  void beginDelete() => state = const AsyncValue.loading();
}
