import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/export/record_writer.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  test('non-bat mammal values line up under the all-mammals header', () {
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
}
