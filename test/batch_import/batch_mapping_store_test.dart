import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_mapping_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late BatchMappingStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues(const {});
    store = BatchMappingStore(await SharedPreferences.getInstance());
  });

  const type = DataTableRecordType.specimenRecords;
  const mode = BatchImportMode.create;

  test('keeps user choices for the same headers in any order', () async {
    await store.save(type, mode, const [
      BatchColumnMatch(
        column: 0,
        header: 'Wt',
        fieldKey: 'measurement::weight',
        origin: BatchMatchOrigin.user,
      ),
      BatchColumnMatch(
        column: 1,
        header: 'genus',
        fieldKey: 'specimen::genus',
        origin: BatchMatchOrigin.darwinCore,
      ),
      BatchColumnMatch(
        column: 2,
        header: 'Photo',
        origin: BatchMatchOrigin.user,
      ),
    ]);

    expect(store.load(type, mode, ['Photo', 'genus', 'Wt']), {
      'wt': 'measurement::weight',
      'photo': '',
    });
    expect(store.load(type, mode, ['genus', 'Wt']), isEmpty);
    expect(
      store.load(type, BatchImportMode.update, ['Wt', 'genus', 'Photo']),
      isEmpty,
    );
  });

  test('storage keys are stable across runs', () {
    expect(
      BatchMappingStore.storageKey(type, mode, ['b', 'a']),
      BatchMappingStore.storageKey(type, mode, ['A', 'B']),
    );
    expect(
      BatchMappingStore.storageKey(type, mode, ['a']),
      startsWith('batchImportMapping.specimenRecords.create.'),
    );
  });
}
