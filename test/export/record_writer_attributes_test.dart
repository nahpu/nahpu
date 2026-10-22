import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/export/record_writer.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  test('values line up under a header with more fields', () {
    final values = [
      for (final key in mammalAttributeExportList) 'value of $key',
    ];

    final row = alignAttributeValues(
      batAttributeExportList,
      mammalAttributeExportList,
      values,
    );

    expect(row, hasLength(batAttributeExportList.length));
    String at(String key) => row[batAttributeExportList.indexOf(key)];
    expect(at('measurement::sex'), 'value of measurement::sex');
    expect(at('measurement::remark'), 'value of measurement::remark');
    expect(at('measurement::forearm'), isEmpty);
  });

  test('a matching header keeps the values in read order', () {
    final values = [for (final key in batAttributeExportList) key];
    expect(
      alignAttributeValues(
        batAttributeExportList,
        batAttributeExportList,
        values,
      ),
      values,
    );
  });

  testWidgets('mammal columns add bat fields only when asked', (tester) async {
    late WidgetRef ref;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, widgetRef, _) {
            ref = widgetRef;
            return const SizedBox();
          },
        ),
      ),
    );

    List<String> header({
      required SpecimenRecordType type,
      required bool bats,
    }) => SpecimenRecordWriter(
      ref: ref,
      recordType: type,
      includeBatFields: bats,
    ).header;

    for (final type in [
      SpecimenRecordType.mammals,
      SpecimenRecordType.allTaxa,
    ]) {
      expect(
        header(type: type, bats: false),
        isNot(contains('measurement::forearm')),
      );
      expect(header(type: type, bats: false), contains('measurement::sex'));
      expect(header(type: type, bats: true), contains('measurement::forearm'));
    }
  });
}
