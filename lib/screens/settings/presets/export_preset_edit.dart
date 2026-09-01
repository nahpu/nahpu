import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/presets/export_preset_fields.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/export/preset_record_exporter.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/export.dart';

class ExportPresetEditForm extends ConsumerStatefulWidget {
  const ExportPresetEditForm({
    super.key,
    required this.presetName,
    required this.initialPreset,
    required this.onPresetRenamed,
  });

  final String presetName;
  final ExportPresetModel initialPreset;
  final void Function(String, String) onPresetRenamed;

  @override
  ConsumerState<ExportPresetEditForm> createState() =>
      _ExportPresetEditFormState();
}

class _ExportPresetEditFormState extends ConsumerState<ExportPresetEditForm> {
  late TextEditingController _nameController;
  late ExportPresetModel _preset;
  final Map<int, String> _expectedPersistedNames = {};
  int _editSession = 0;
  Timer? _saveTimer;
  _PendingPresetSave? _pendingSave;
  Future<void> _saveChain = Future.value();
  late ExportPresetNotifier _presetNotifier;
  AsyncValue<Map<String, ExportPresetModel>> _presetProviderState =
      const AsyncValue.loading();
  bool _isSaving = false;
  String? _saveError;
  bool _isRenaming = false;
  String? _renameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.presetName);
    _preset = widget.initialPreset;
    _expectedPersistedNames[_editSession] = widget.presetName;
    _presetNotifier = ref.read(exportPresetNotifierProvider.notifier);
    ref.listenManual(
      exportPresetNotifierProvider,
      (_, next) => _presetProviderState = next,
      fireImmediately: true,
    );
  }

  @override
  void didUpdateWidget(covariant ExportPresetEditForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.presetName == widget.presetName) return;
    _flushPendingSave();
    _editSession++;
    // Only take the incoming name when the user had no unsaved edit against
    // the preset they were on. Assigning to `text` resets the caret, so doing
    // it while the user is typing would drop characters and jump the cursor.
    final hadUnsavedName = _nameController.text.trim() != oldWidget.presetName;
    if (!hadUnsavedName) _nameController.text = widget.presetName;
    _expectedPersistedNames[_editSession] = widget.presetName;
    _preset = widget.initialPreset;
    _renameError = null;
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    final pending = _pendingSave;
    final presets = _presetProviderState.asData?.value;
    if (pending != null &&
        presets?.containsKey(_expectedPersistedNames[pending.editSession]) ==
            true) {
      _flushPendingSave(updateUi: false);
    } else {
      _pendingSave = null;
    }
    _nameController.dispose();
    super.dispose();
  }

  void _showPreview() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final exporter = PresetRecordExporter(ref: ref, preset: _preset);
      final previewData = await exporter.getPreviewData();
      if (mounted) {
        Navigator.pop(context);
      }

      if (previewData.headers.isEmpty || previewData.rows.isEmpty) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Preview Data'),
              content: const Text(
                'No records matched the selected filters, or mappings are empty.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
        return;
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => PreviewTableDialog(
            headers: previewData.headers,
            rows: previewData.rows,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to generate preview: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _update({
    RecordType? recordType,
    SpecimenRecordType? specimenRecordType,
    ExportHeaderFormat? headerFormat,
    List<ExportFieldMapping>? mappings,
  }) {
    setState(() {
      _preset = ExportPresetModel(
        recordType: recordType ?? _preset.recordType,
        specimenRecordType: specimenRecordType ?? _preset.specimenRecordType,
        headerFormat: headerFormat ?? _preset.headerFormat,
        mappings: mappings ?? _preset.mappings,
      );
    });
    _schedulePersist();
  }

  /// Queues an auto-save of the preset body.
  ///
  /// The target is always the persisted name, never the text field, so a
  /// settings change made while a new name is half-typed saves under the name
  /// the preset actually has.
  void _schedulePersist() {
    _saveTimer?.cancel();
    _pendingSave = _PendingPresetSave(
      editSession: _editSession,
      targetName: widget.presetName,
      preset: _preset,
    );
    _saveTimer = Timer(const Duration(milliseconds: 400), _flushPendingSave);
  }

  Future<void> _flushPendingSave({bool updateUi = true}) {
    _saveTimer?.cancel();
    _saveTimer = null;
    final pending = _pendingSave;
    if (pending == null) return _saveChain;
    _pendingSave = null;

    _saveChain = _saveChain.then((_) async {
      final isCurrentSession = pending.editSession == _editSession;
      if (mounted && updateUi && isCurrentSession) {
        setState(() {
          _isSaving = true;
          _saveError = null;
        });
      }
      try {
        await _presetNotifier.savePreset(pending.targetName, pending.preset);
        if (mounted && updateUi && isCurrentSession) {
          setState(() => _isSaving = false);
        }
      } on Object catch (error) {
        if (mounted && updateUi && isCurrentSession) {
          setState(() {
            _isSaving = false;
            _saveError = 'Couldn\'t save: $error';
          });
        }
      }
    });
    return _saveChain;
  }

  bool get _isNameDirty => _nameController.text.trim() != widget.presetName;

  bool get _canRename =>
      _isNameDirty && _nameValidationError == null && !_isRenaming;

  /// Validates the typed name, or null when it can be committed.
  String? get _nameValidationError {
    final trimmed = _nameController.text.trim();
    if (trimmed.isEmpty) return 'Preset name cannot be empty.';
    final presets = _presetProviderState.asData?.value;
    if (presets != null &&
        trimmed != widget.presetName &&
        presets.containsKey(trimmed)) {
      return 'A preset named "$trimmed" already exists.';
    }
    return null;
  }

  /// Commits a rename on demand.
  ///
  /// Renaming is deliberately separate from the body auto-save: committing on
  /// every keystroke renamed the preset to each prefix of what the user was
  /// typing, and the name pushed back down then reset the field mid-word.
  Future<void> _renamePreset() async {
    final target = _nameController.text.trim();
    final error = _nameValidationError;
    if (error != null) {
      setState(() => _renameError = error);
      return;
    }
    final sourceName = widget.presetName;
    if (target == sourceName) return;

    setState(() {
      _isRenaming = true;
      _renameError = null;
    });
    // Land any queued body edit under the old name first, so the rename
    // carries the current settings rather than racing them.
    await _flushPendingSave();
    try {
      await _presetNotifier.renamePreset(sourceName, target, _preset);
      _expectedPersistedNames[_editSession] = target;
      if (!mounted) return;
      setState(() => _isRenaming = false);
      widget.onPresetRenamed(sourceName, target);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isRenaming = false;
        _renameError = 'Couldn\'t rename: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Edit ${widget.presetName}',
      isExpanded: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Preset name',
                      errorText: _isNameDirty
                          ? (_renameError ?? _nameValidationError)
                          : _renameError,
                      helperText: _isNameDirty && _nameValidationError == null
                          ? 'Select Rename to save this name'
                          : null,
                    ),
                    onChanged: (_) => setState(() => _renameError = null),
                    onFieldSubmitted: (_) {
                      if (_canRename) _renamePreset();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: FilledButton.tonal(
                    onPressed: _canRename ? _renamePreset : null,
                    child: _isRenaming
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Rename'),
                  ),
                ),
              ],
            ),
          ),
          _PresetSettingsCard(
            preset: _preset,
            onRecordTypeChanged: (value) => _update(recordType: value),
            onSpecimenRecordTypeChanged: (value) =>
                _update(specimenRecordType: value),
            onHeaderFormatChanged: (value) => _update(headerFormat: value),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Edit Fields',
                    icon: Icons.list_alt_outlined,
                    onPressed: () async {
                      final updated = await Navigator.push<ExportPresetModel>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExportPresetFieldsScreen(
                            preset: _preset,
                            onPresetChanged: (updated) =>
                                _update(mappings: updated.mappings),
                          ),
                        ),
                      );
                      if (updated != null) _update(mappings: updated.mappings);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'Preview Export Table',
                  onPressed: _showPreview,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _saveError ?? (_isSaving ? 'Saving…' : 'Saved automatically'),
                style: TextStyle(
                  color: _saveError == null
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingPresetSave {
  const _PendingPresetSave({
    required this.editSession,
    required this.targetName,
    required this.preset,
  });

  final int editSession;
  final String targetName;
  final ExportPresetModel preset;
}

class _PresetSettingsCard extends StatelessWidget {
  const _PresetSettingsCard({
    required this.preset,
    required this.onRecordTypeChanged,
    required this.onSpecimenRecordTypeChanged,
    required this.onHeaderFormatChanged,
  });

  final ExportPresetModel preset;
  final ValueChanged<RecordType> onRecordTypeChanged;
  final ValueChanged<SpecimenRecordType> onSpecimenRecordTypeChanged;
  final ValueChanged<ExportHeaderFormat> onHeaderFormatChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              DropdownButtonFormField<RecordType>(
                isExpanded: true,
                initialValue: preset.recordType,
                decoration: const InputDecoration(labelText: 'Record type'),
                items: RecordType.values
                    .where((type) => type != RecordType.none)
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(recordTypeToString(type)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) onRecordTypeChanged(value);
                },
              ),
              if (preset.recordType == RecordType.specimenRecord) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<SpecimenRecordType>(
                  isExpanded: true,
                  initialValue: preset.specimenRecordType,
                  decoration: const InputDecoration(
                    labelText: 'Specimen taxon group',
                  ),
                  items: SpecimenRecordType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) onSpecimenRecordTypeChanged(value);
                  },
                ),
              ],
              const SizedBox(height: 8),
              DropdownButtonFormField<ExportHeaderFormat>(
                isExpanded: true,
                initialValue: preset.headerFormat,
                decoration: const InputDecoration(
                  labelText: 'Generated header format',
                ),
                items: const [
                  DropdownMenuItem(
                    value: ExportHeaderFormat.tableFieldName,
                    child: Text('table::fieldName'),
                  ),
                  DropdownMenuItem(
                    value: ExportHeaderFormat.fieldName,
                    child: Text('fieldName'),
                  ),
                  DropdownMenuItem(
                    value: ExportHeaderFormat.darwinCore,
                    child: Text('Darwin Core (dwc:/dcterms:)'),
                  ),
                  DropdownMenuItem(
                    value: ExportHeaderFormat.nahpuNamespace,
                    child: Text('NAHPU namespace (nahpu:table.field)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) onHeaderFormatChanged(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
