import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/settings/presets/export_preset_edit.dart';
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

  Finder nameField() => find.widgetWithText(TextFormField, 'Preset name');
  Finder renameButton() => find.widgetWithText(FilledButton, 'Rename');

  /// Changes the record type, which is one of the auto-saved settings.
  Future<void> changeRecordType(WidgetTester tester, String label) async {
    await tester.tap(find.byType(DropdownButtonFormField<RecordType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  testWidgets('typing a name does not persist anything', (tester) async {
    final notifier = _FakeExportPresetNotifier({'first': firstPreset});

    await tester.pumpWidget(
      _harness(notifier, presetName: 'first', preset: firstPreset),
    );
    await tester.pump();

    await tester.enterText(nameField(), 'renamed-first');
    await tester.pump(const Duration(seconds: 1));

    expect(notifier.renames, isEmpty);
    expect(notifier.savedPresets, isEmpty);
  });

  testWidgets('the Rename button commits the typed name', (tester) async {
    final notifier = _FakeExportPresetNotifier({'first': firstPreset});
    final renamed = <(String, String)>[];

    await tester.pumpWidget(
      _harness(
        notifier,
        presetName: 'first',
        preset: firstPreset,
        onRenamed: (from, to) => renamed.add((from, to)),
      ),
    );
    await tester.pump();

    await tester.enterText(nameField(), '  renamed-first  ');
    await tester.pump();
    await tester.tap(renameButton());
    await tester.pumpAndSettle();

    expect(notifier.renames, [('first', 'renamed-first')]);
    expect(renamed, [('first', 'renamed-first')]);
  });

  testWidgets('Rename is disabled until the name changes and is valid', (
    tester,
  ) async {
    final notifier = _FakeExportPresetNotifier({
      'first': firstPreset,
      'second': secondPreset,
    });

    await tester.pumpWidget(
      _harness(notifier, presetName: 'first', preset: firstPreset),
    );
    await tester.pump();

    FilledButton button() => tester.widget<FilledButton>(renameButton());
    expect(button().onPressed, isNull, reason: 'unchanged name');

    await tester.enterText(nameField(), '   ');
    await tester.pump();
    expect(button().onPressed, isNull, reason: 'empty name');
    expect(find.text('Preset name cannot be empty.'), findsOneWidget);

    await tester.enterText(nameField(), 'second');
    await tester.pump();
    expect(button().onPressed, isNull, reason: 'name already taken');
    expect(
      find.text('A preset named "second" already exists.'),
      findsOneWidget,
    );

    await tester.enterText(nameField(), 'third');
    await tester.pump();
    expect(button().onPressed, isNotNull);
  });

  testWidgets('a settings change saves under the persisted name while a new '
      'name is half-typed', (tester) async {
    final notifier = _FakeExportPresetNotifier({'first': firstPreset});

    await tester.pumpWidget(
      _harness(notifier, presetName: 'first', preset: firstPreset),
    );
    await tester.pump();

    await tester.enterText(nameField(), 'half-typed-nam');
    await tester.pump();
    await changeRecordType(tester, 'narrative');
    await tester.pump(const Duration(seconds: 1));

    expect(notifier.renames, isEmpty);
    expect(notifier.savedNames, ['first']);
    expect(notifier.savedPresets.single.recordType, RecordType.narrative);
  });

  testWidgets('an auto-save does not disturb the name being typed', (
    tester,
  ) async {
    final notifier = _FakeExportPresetNotifier({'first': firstPreset});

    await tester.pumpWidget(
      _harness(notifier, presetName: 'first', preset: firstPreset),
    );
    await tester.pump();

    await tester.enterText(nameField(), 'Site');
    await tester.pump();
    await changeRecordType(tester, 'narrative');
    await tester.pump(const Duration(seconds: 1));

    final controller = tester.widget<TextFormField>(nameField()).controller!;
    expect(controller.text, 'Site');
    expect(controller.selection.baseOffset, 'Site'.length);
  });

  testWidgets('switching presets flushes the pending settings edit', (
    tester,
  ) async {
    final notifier = _FakeExportPresetNotifier({
      'first': firstPreset,
      'second': secondPreset,
    });
    late void Function(String name, ExportPresetModel preset) selectPreset;
    var selectedName = 'first';
    var selectedPreset = firstPreset;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [exportPresetNotifierProvider.overrideWith(() => notifier)],
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
                  onPresetRenamed: _ignoreRename,
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await changeRecordType(tester, 'narrative');
    selectPreset('second', secondPreset);
    await tester.pump();
    await tester.pump();

    expect(notifier.renames, isEmpty);
    expect(notifier.savedNames, ['first']);
    expect(notifier.savedPresets.single.recordType, RecordType.narrative);
  });

  testWidgets('switching presets adopts the new name in the field', (
    tester,
  ) async {
    final notifier = _FakeExportPresetNotifier({
      'first': firstPreset,
      'second': secondPreset,
    });
    late void Function(String name, ExportPresetModel preset) selectPreset;
    var selectedName = 'first';
    var selectedPreset = firstPreset;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [exportPresetNotifierProvider.overrideWith(() => notifier)],
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
                  onPresetRenamed: _ignoreRename,
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    selectPreset('second', secondPreset);
    await tester.pump();

    expect(
      tester.widget<TextFormField>(nameField()).controller!.text,
      'second',
    );
  });

  testWidgets('provider-driven deletion does not flush a pending edit', (
    tester,
  ) async {
    final notifier = _FakeExportPresetNotifier({'first': firstPreset});
    var showEditor = true;
    late StateSetter updateHarness;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [exportPresetNotifierProvider.overrideWith(() => notifier)],
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

    await tester.enterText(nameField(), 'should-not-return');
    notifier.beginDelete();
    updateHarness(() => showEditor = false);
    await tester.pump();

    expect(notifier.renames, isEmpty);
    expect(notifier.savedPresets, isEmpty);
  });
}

Widget _harness(
  _FakeExportPresetNotifier notifier, {
  required String presetName,
  required ExportPresetModel preset,
  void Function(String, String)? onRenamed,
}) => ProviderScope(
  overrides: [exportPresetNotifierProvider.overrideWith(() => notifier)],
  child: MaterialApp(
    home: Scaffold(
      body: ExportPresetEditForm(
        presetName: presetName,
        initialPreset: preset,
        onPresetRenamed: onRenamed ?? _ignoreRename,
      ),
    ),
  ),
);

void _ignoreRename(String oldName, String newName) {}

class _FakeExportPresetNotifier extends ExportPresetNotifier {
  _FakeExportPresetNotifier(this.presets);

  final Map<String, ExportPresetModel> presets;
  final List<(String, String)> renames = [];
  final List<ExportPresetModel> savedPresets = [];
  final List<String> savedNames = [];

  @override
  Future<Map<String, ExportPresetModel>> build() async => presets;

  @override
  Future<void> savePreset(String name, ExportPresetModel preset) async {
    savedNames.add(name);
    savedPresets.add(preset);
  }

  @override
  Future<void> renamePreset(
    String previousName,
    String nextName,
    ExportPresetModel preset,
  ) async {
    renames.add((previousName, nextName));
  }

  void beginDelete() => state = const AsyncValue.loading();
}
