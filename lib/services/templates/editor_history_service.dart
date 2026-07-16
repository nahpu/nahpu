import 'package:nahpu/screens/templates/template_model.dart';

/// A restorable state of the template editor.
class TemplateEditorSnapshot {
  /// Captures the template and editor settings required for undo and redo.
  TemplateEditorSnapshot({
    required Template template,
    required this.isDuplex,
    required this.mirrorFront,
    required this.mirrorBack,
    required this.templateWidthMm,
    required this.templateHeightMm,
  }) : template = template.copyWith();

  /// The template content at the time of the snapshot.
  final Template template;

  /// Whether the editor displays two template pages.
  final bool isDuplex;

  /// Whether the front page is mirrored.
  final bool mirrorFront;

  /// Whether the back page is mirrored.
  final bool mirrorBack;

  /// The active template width in millimeters.
  final double templateWidthMm;

  /// The active template height in millimeters.
  final double templateHeightMm;
}

/// Maintains bounded undo and redo stacks for template editor changes.
class TemplateEditorHistoryService {
  /// Creates an editor history with at most [capacity] undo entries.
  ///
  /// A non-positive [capacity] is normalized to one retained entry.
  TemplateEditorHistoryService({int capacity = 50})
      : capacity = capacity < 1 ? 1 : capacity;

  /// The maximum number of undo states retained.
  final int capacity;

  final List<TemplateEditorSnapshot> _undoStack = [];
  final List<TemplateEditorSnapshot> _redoStack = [];

  /// Whether an earlier editor state can be restored.
  bool get canUndo => _undoStack.isNotEmpty;

  /// Whether an undone editor state can be reapplied.
  bool get canRedo => _redoStack.isNotEmpty;

  /// Records [current] before a user-visible mutation and clears redo history.
  void push(TemplateEditorSnapshot current) {
    _appendUndo(current);
    _redoStack.clear();
  }

  /// Returns the prior state and records [current] in the redo stack.
  ///
  /// Returns null when no prior state is available.
  TemplateEditorSnapshot? undo(TemplateEditorSnapshot current) {
    if (!canUndo) return null;
    _redoStack.add(current);
    return _undoStack.removeLast();
  }

  /// Returns the next state and records [current] in the undo stack.
  ///
  /// Returns null when no redone state is available.
  TemplateEditorSnapshot? redo(TemplateEditorSnapshot current) {
    if (!canRedo) return null;
    _appendUndo(current);
    return _redoStack.removeLast();
  }

  void _appendUndo(TemplateEditorSnapshot snapshot) {
    _undoStack.add(snapshot);
    if (_undoStack.length > capacity) {
      _undoStack.removeAt(0);
    }
  }
}
