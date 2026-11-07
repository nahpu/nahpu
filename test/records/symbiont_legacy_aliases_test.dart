import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/import/batch/batch_column_matcher.dart';
import 'package:nahpu/services/record_exchange/record_exchange_models.dart';
import 'package:nahpu/services/specimens/specimen_attribute_names.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  test('pre-v26 parasite source keys resolve to symbionts', () {
    expect(
      canonicalizeSpecimenAttributeSourceKey('parasite::parasiteID'),
      'symbiont::symbiontID',
    );
    expect(
      canonicalizeSpecimenAttributeSourceKey('parasite::parasiteUuid'),
      'symbiont::symbiontUuid',
    );
    expect(
      canonicalizeSpecimenAttributeSourceKey('parasite::identifierID'),
      'symbiont::determinerID',
    );
    expect(
      canonicalizeSpecimenAttributeSourceKey(
        'parasiteDetection::parasiteExamined',
      ),
      'symbiontDetection::symbiontExamined',
    );
    expect(
      canonicalizeSpecimenAttributeSourceKey('parasite::category'),
      'symbiont::category',
    );
    expect(
      canonicalizeSpecimenAttributeExpression(
        '{parasite::parasiteID} {parasiteDetection::parasiteDetected}',
      ),
      '{symbiont::symbiontID} {symbiontDetection::symbiontDetected}',
    );
    expect(
      canonicalizeSpecimenAttributeTableName('customParasite'),
      'customSymbiont',
    );
  });

  test('pre-v26 record types and custom-field sections parse', () {
    expect(parseRecordType('parasites'), RecordType.symbionts);
    expect(parseFieldUISection('parasite'), FieldUISection.symbiont);
    expect(parseFieldUISection('symbiont'), FieldUISection.symbiont);
  });

  test('pre-v26 parasite headers are batch import aliases', () {
    expect(batchHeaderAliases['symbiont::symbiontID'], contains('parasite id'));
  });

  test('record JSON written before v26 reads parasite keys', () {
    final payload = RecordExchangePayload.parse(
      jsonEncode({
        'nahpu_record': 'specimen',
        'version': 7,
        'data': {
          'specimen': {'uuid': 'host'},
          'parasites': [
            {'sourceParasiteId': 1, 'parasiteID': 'P-1'},
          ],
          'parasiteDetection': {'parasiteExamined': 1},
          'parasiteIndividuals': [
            {'sourceParasiteId': 1, 'sourceIndividualId': 2},
          ],
          'customFields': {
            'definitions': [
              {'sourceDefinitionId': 4, 'uiSection': 'parasite'},
            ],
            'values': [
              {'sourceDefinitionId': 4, 'parasiteId': 1},
            ],
          },
        },
      }),
    );

    final data = payload.data;
    expect(data['symbionts'], [
      {'sourceSymbiontId': 1, 'symbiontID': 'P-1'},
    ]);
    expect(data['symbiontDetection'], {'symbiontExamined': 1});
    expect(data['symbiontIndividuals'], [
      {'sourceSymbiontId': 1, 'sourceIndividualId': 2},
    ]);
    final customFields = data['customFields'] as Map;
    expect(customFields['definitions'], [
      {'sourceDefinitionId': 4, 'uiSection': 'symbiont'},
    ]);
    expect(customFields['values'], [
      {'sourceDefinitionId': 4, 'symbiontId': 1},
    ]);
  });
}
