import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nahpu/services/data_table/data_table_save_service.dart';

export 'package:nahpu/services/data_table/data_table_save_service.dart'
    show DataTableCellId, DataTableEdit, DataTableSaveResult;

typedef DataTableSaver =
    Future<DataTableSaveResult> Function(List<DataTableEdit> edits);

/// Pending data table edits, their save state, and undo.
///
/// Edits wait for [save] unless [autoSave] is on, in which case committed
/// edits save after a short pause so a paste or a run of quick edits goes
/// out together. Saves never overlap: a save requested while one is running
/// waits for it.
class DataTableEditController extends ChangeNotifier {
  DataTableEditController({
    required this.saver,
    bool initialAutoSave = false,
    this.autoSaveDelay = const Duration(milliseconds: 400),
  }) : _autoSave = initialAutoSave;

  final DataTableSaver saver;
  final Duration autoSaveDelay;

  final Map<DataTableCellId, DataTableEdit> _pending = {};
  final Map<DataTableCellId, String> _errors = {};
  final Set<DataTableCellId> _saving = {};

  /// Stored value of each edited cell before its first edit, or as of its
  /// last save. Undo and "edited back to the original" compare against it.
  final Map<DataTableCellId, String> _stored = {};
  final List<(DataTableEdit, String)> _undo = [];
  bool _autoSave;
  Timer? _timer;
  Future<void> _saveChain = Future.value();
  int _revision = 0;

  bool get autoSave => _autoSave;
  bool get hasPending => _pending.isNotEmpty;
  bool get isSaving => _saving.isNotEmpty;
  bool get canUndo => _undo.isNotEmpty;
  int get pendingCount => _pending.length;
  int get failedCount => _errors.length;

  DataTableEdit? pendingFor(DataTableCellId cell) => _pending[cell];
  String? errorFor(DataTableCellId cell) => _errors[cell];
  bool isSavingCell(DataTableCellId cell) => _saving.contains(cell);

  /// Records committed edits. [stored] gives each cell's stored value, so
  /// an edit back to it drops the pending change instead of saving it.
  ///
  /// Input that doesn't fit its field is kept as a cell error and not
  /// queued. Returns how many edits were accepted.
  int commit(List<(DataTableEdit, String)> edits, {bool recordUndo = true}) {
    var accepted = 0;
    for (final (edit, stored) in edits) {
      final cell = edit.cell;
      final original = _stored.putIfAbsent(cell, () => stored);
      final previous = _pending[cell]?.value ?? original;
      if (edit.value.trim() == previous.trim() && _errors[cell] == null) {
        continue;
      }
      try {
        dataTableStoredValue(edit.field, edit.value);
      } on FormatException catch (e) {
        _errors[cell] = e.message;
        continue;
      }
      _errors.remove(cell);
      if (recordUndo) _undo.add((edit, previous));
      if (edit.value.trim() == original.trim()) {
        _pending.remove(cell);
      } else {
        _pending[cell] = edit.copyWith(revision: ++_revision);
      }
      accepted++;
    }
    notifyListeners();
    if (_autoSave && accepted > 0) _scheduleSave();
    return accepted;
  }

  /// Reverts the last change. If it was already saved, the revert becomes a
  /// pending edit of its own, which auto-save then writes back.
  void undoLast() {
    if (_undo.isEmpty) return;
    final (edit, previous) = _undo.removeLast();
    final stored = _stored[edit.cell] ?? previous;
    commit([(edit.copyWith(value: previous), stored)], recordUndo: false);
  }

  /// Drops every unsaved edit and cell error.
  void discard() {
    _timer?.cancel();
    _pending.clear();
    _errors.clear();
    _undo.clear();
    _stored.clear();
    notifyListeners();
  }

  /// Saves every pending edit, retrying failed ones.
  Future<void> save() {
    _timer?.cancel();
    _timer = null;
    _saveChain = _saveChain.then((_) => _saveNow());
    return _saveChain;
  }

  /// Saves edits queued by auto-save without waiting for the pause.
  Future<void> flush() {
    if (_timer == null) return _saveChain;
    return save();
  }

  /// Turns auto-save on or off. Turning it on saves what is pending.
  Future<void> setAutoSave(bool value) async {
    if (_autoSave == value) return;
    _autoSave = value;
    notifyListeners();
    if (value) {
      await save();
    } else {
      await flush();
    }
  }

  /// Forgets stored values after the page reloads with fresh data.
  void resetStored() {
    _stored.removeWhere((cell, _) => !_pending.containsKey(cell));
    _undo.clear();
  }

  void _scheduleSave() {
    _timer?.cancel();
    _timer = Timer(autoSaveDelay, () {
      _timer = null;
      save();
    });
  }

  Future<void> _saveNow() async {
    final batch = _pending.values.toList();
    if (batch.isEmpty) return;
    _saving.addAll(batch.map((edit) => edit.cell));
    notifyListeners();
    DataTableSaveResult result;
    try {
      result = await saver(batch);
    } catch (e) {
      result = DataTableSaveResult(
        saved: const {},
        errors: {for (final edit in batch) edit.cell: 'Couldn\'t save: $e'},
      );
    }
    for (final edit in batch) {
      final cell = edit.cell;
      _saving.remove(cell);
      final error = result.errors[cell];
      if (error != null) {
        _errors[cell] = error;
        continue;
      }
      if (!result.saved.contains(cell)) continue;
      _errors.remove(cell);
      _stored[cell] = edit.value;
      // A newer edit made during the save stays pending.
      if (_pending[cell]?.revision == edit.revision) _pending.remove(cell);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
