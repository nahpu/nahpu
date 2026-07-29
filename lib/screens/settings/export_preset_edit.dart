import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/export_preset_fields.dart';
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
  String? _ownRenameTarget;
  late ExportPresetNotifier _presetNotifier;
  AsyncValue<Map<String, ExportPresetModel>> _presetProviderState =
      const AsyncValue.loading();
  bool _isSaving = false;
  String? _saveError;

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
    if (oldWidget.presetName != widget.presetName) {
      final isOwnRename = _ownRenameTarget == widget.presetName;
      _ownRenameTarget = null;
      if (!isOwnRename) {
        _flushPendingSave();
        _editSession++;
      }
      _nameController.text = widget.presetName;
      _expectedPersistedNames[_editSession] = widget.presetName;
      if (!isOwnRename) _preset = widget.initialPreset;
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    final pending = _pendingSave;
    final presets = _presetProviderState.asData?.value;
    if (pending != null &&
        presets?.containsKey(
              _expectedPersistedNames[pending.editSession],
            ) ==
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

  void _schedulePersist() {
    _saveTimer?.cancel();
    _pendingSave = _PendingPresetSave(
      editSession: _editSession,
      targetName: _nameController.text.trim(),
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

    if (pending.targetName.isEmpty) {
      if (mounted && updateUi && pending.editSession == _editSession) {
        setState(() => _saveError = 'Preset name cannot be empty.');
      }
      return _saveChain;
    }

    final sourceName =
        _expectedPersistedNames[pending.editSession] ?? pending.targetName;
    _expectedPersistedNames[pending.editSession] = pending.targetName;
    _saveChain = _saveChain.then((_) async {
      final isCurrentSession = pending.editSession == _editSession;
      if (mounted && updateUi && isCurrentSession) {
        setState(() {
          _isSaving = true;
          _saveError = null;
        });
      }
      try {
        if (pending.targetName == sourceName) {
          await _presetNotifier.savePreset(pending.targetName, pending.preset);
        } else {
          await _presetNotifier.renamePreset(
            sourceName,
            pending.targetName,
            pending.preset,
          );
          if (mounted &&
              updateUi &&
              isCurrentSession &&
              widget.presetName == sourceName) {
            _ownRenameTarget = pending.targetName;
            widget.onPresetRenamed(sourceName, pending.targetName);
          }
        }
        if (mounted && updateUi && isCurrentSession) {
          setState(() => _isSaving = false);
        }
      } on Object catch (error) {
        if (_expectedPersistedNames[pending.editSession] ==
            pending.targetName) {
          _expectedPersistedNames[pending.editSession] = sourceName;
        }
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

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Edit ${widget.presetName}',
      isExpanded: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Preset name'),
              onChanged: (_) => _schedulePersist(),
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
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
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
                  decoration:
                      const InputDecoration(labelText: 'Specimen taxon group'),
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
                decoration:
                    const InputDecoration(labelText: 'Generated header format'),
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
