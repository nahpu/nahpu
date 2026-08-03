import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/templates/editor_history_service.dart';

void main() {
  TemplateEditorSnapshot snapshot(String name) {
    return TemplateEditorSnapshot(
      template: DefaultTemplate.defaultTemplate().copyWith(name: name),
      isDuplex: false,
      mirrorFront: false,
      mirrorBack: false,
      templateWidthMm: 85.6,
      templateHeightMm: 54,
    );
  }

  group('TemplateEditorHistoryService', () {
    test('restores undo states and then redoes them', () {
      final history = TemplateEditorHistoryService();
      final first = snapshot('first');
      final second = snapshot('second');

      history.push(first);
      final undone = history.undo(second);

      expect(undone?.template.name, 'first');
      expect(history.canUndo, isFalse);
      expect(history.canRedo, isTrue);

      final redone = history.redo(first);
      expect(redone?.template.name, 'second');
      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);
    });

    test('keeps only the configured number of undo states', () {
      final history = TemplateEditorHistoryService(capacity: 1);
      history
        ..push(snapshot('first'))
        ..push(snapshot('second'));

      expect(history.undo(snapshot('third'))?.template.name, 'second');
      expect(history.undo(snapshot('second')), isNull);
    });
  });
}
