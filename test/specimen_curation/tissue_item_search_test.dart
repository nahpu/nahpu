import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/specimen_curation/tissue_item.dart';

void main() {
  TissueItemRecord part(int id, String tissueId) {
    return TissueItemRecord.part(
      SpecimenPartProjectRecord(
        part: SpecimenPartData(id: id, tissueID: tissueId),
        specimen: SpecimenData(uuid: 'specimen-$id'),
      ),
    );
  }

  final records = [
    part(1, 'ABC1 Liver'),
    part(2, 'ABC2 Liver'),
    part(3, 'XYZ1'),
  ];
  String textFor(TissueItemRecord record) => record.code ?? '';

  test('an empty query matches nothing', () {
    expect(searchTissueItems(records, '  ', textFor), isEmpty);
  });

  test('matches every word in any order, ignoring case', () {
    expect(searchTissueItems(records, 'liver abc2', textFor), [1]);
    expect(searchTissueItems(records, 'abc', textFor), [0, 1]);
    expect(searchTissueItems(records, 'nope', textFor), isEmpty);
  });
}
