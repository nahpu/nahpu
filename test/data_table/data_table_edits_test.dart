import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/data_table/data_table_edits.dart';
import 'package:nahpu/services/data_table/data_table_fields.dart';

void main() {
  const delay = Duration(milliseconds: 20);
  late List<List<DataTableEdit>> calls;
  late Set<String> failing;
  Completer<void>? gate;

  Future<DataTableSaveResult> saver(List<DataTableEdit> edits) async {
    calls.add(edits);
    await gate?.future;
    return DataTableSaveResult(
      saved: {
        for (final edit in edits)
          if (!failing.contains(edit.value)) edit.cell,
      },
      errors: {
        for (final edit in edits)
          if (failing.contains(edit.value)) edit.cell: 'Nope',
      },
    );
  }

  setUp(() {
    calls = [];
    failing = {};
    gate = null;
  });

  (DataTableEdit, String) edit(
    String record,
    String value, {
    String stored = '',
  }) => (
    DataTableEdit(
      cell: DataTableCellId(record, 'specimen::condition'),
      field: dataTableField('specimen::condition'),
      value: value,
    ),
    stored,
  );

  DataTableEditController controller({bool autoSave = false}) {
    final edits = DataTableEditController(
      saver: saver,
      initialAutoSave: autoSave,
      autoSaveDelay: delay,
    );
    addTearDown(edits.dispose);
    return edits;
  }

  test('edits wait for save while auto-save is off', () async {
    final edits = controller()..commit([edit('a', 'Good')]);
    await Future<void>.delayed(delay * 3);
    expect(calls, isEmpty);
    expect(edits.hasPending, isTrue);

    await edits.save();
    expect(calls.single, hasLength(1));
    expect(edits.hasPending, isFalse);
  });

  test('editing back to the stored value drops the change', () {
    final edits = controller()
      ..commit([edit('a', 'Good', stored: 'Fine')])
      ..commit([edit('a', 'Fine', stored: 'Fine')]);
    expect(edits.hasPending, isFalse);
  });

  test('invalid input becomes a cell error, not a pending edit', () {
    final edits = controller();
    final accepted = edits.commit([
      (
        DataTableEdit(
          cell: const DataTableCellId('a', 'specimen::preparationDate'),
          field: dataTableField('specimen::preparationDate'),
          value: 'soon',
        ),
        '',
      ),
    ]);
    expect(accepted, 0);
    expect(edits.hasPending, isFalse);
    expect(
      edits.errorFor(const DataTableCellId('a', 'specimen::preparationDate')),
      isNotNull,
    );
  });

  test('auto-save sends a burst of commits as one save', () async {
    final edits = controller(autoSave: true)
      ..commit([edit('a', 'Good')])
      ..commit([edit('b', 'Fair'), edit('c', 'Poor')]);
    expect(calls, isEmpty);
    await Future<void>.delayed(delay * 3);
    expect(calls, hasLength(1));
    expect(calls.single, hasLength(3));
    expect(edits.hasPending, isFalse);
  });

  test('failed saves stay pending with their error until retried', () async {
    failing = {'Bad'};
    final edits = controller(autoSave: true)
      ..commit([edit('a', 'Bad'), edit('b', 'Good')]);
    await Future<void>.delayed(delay * 3);
    expect(edits.pendingCount, 1);
    expect(
      edits.errorFor(const DataTableCellId('a', 'specimen::condition')),
      'Nope',
    );
    expect(calls, hasLength(1), reason: 'no automatic retry');

    failing = {};
    await edits.save();
    expect(edits.hasPending, isFalse);
    expect(edits.failedCount, 0);
  });

  test('an edit made during a save stays pending', () async {
    gate = Completer<void>();
    final edits = controller()..commit([edit('a', 'Good')]);
    final saving = edits.save();
    await pumpEventQueue();
    expect(calls, hasLength(1));
    edits.commit([edit('a', 'Better')]);
    gate!.complete();
    await saving;
    expect(
      edits
          .pendingFor(const DataTableCellId('a', 'specimen::condition'))
          ?.value,
      'Better',
    );
  });

  test('turning auto-save on saves what is pending', () async {
    final edits = controller()..commit([edit('a', 'Good')]);
    await edits.setAutoSave(true);
    expect(calls, hasLength(1));
    expect(edits.hasPending, isFalse);
  });

  test('turning auto-save off flushes a queued save', () async {
    final edits = controller(autoSave: true)..commit([edit('a', 'Good')]);
    await edits.setAutoSave(false);
    expect(calls, hasLength(1));
    expect(edits.hasPending, isFalse);
  });

  test('saves never overlap', () async {
    gate = Completer<void>();
    final edits = controller()..commit([edit('a', 'Good')]);
    final first = edits.save();
    await pumpEventQueue();
    edits.commit([edit('b', 'Fair')]);
    final second = edits.save();
    await Future<void>.delayed(delay);
    expect(calls, hasLength(1));
    gate!.complete();
    await Future.wait([first, second]);
    expect(calls, hasLength(2));
  });

  test('undo after an auto-save writes the old value back', () async {
    final edits = controller(autoSave: true)
      ..commit([edit('a', 'Good', stored: 'Fine')]);
    await Future<void>.delayed(delay * 3);
    expect(calls.single.single.value, 'Good');

    edits.undoLast();
    await Future<void>.delayed(delay * 3);
    expect(calls, hasLength(2));
    expect(calls.last.single.value, 'Fine');
  });

  test('undo before saving just drops the change', () {
    final edits = controller()..commit([edit('a', 'Good', stored: 'Fine')]);
    edits.undoLast();
    expect(edits.hasPending, isFalse);
  });
}
