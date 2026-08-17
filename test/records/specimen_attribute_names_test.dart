import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/specimens/specimen_attribute_names.dart';

void main() {
  test('canonicalizes legacy specimen attribute identifiers', () {
    expect(
      canonicalizeSpecimenAttributeSourceKey('mammalMeasurement::totalLength'),
      'mammalAttribute::totalLength',
    );
    expect(
      canonicalizeSpecimenAttributeSourceKey('avianMeasurement::wingspan'),
      'birdAttribute::wingspan',
    );
    expect(
      canonicalizeSpecimenAttributeSourceKey('herpMeasurement::svl'),
      'herpAttribute::svl',
    );
  });

  test('canonicalizes placeholders when loading a legacy template', () {
    final text = CustomTextElement.fromJson({
      'id': 'legacy',
      'text':
          'TL [mammalMeasurement::totalLength] '
          'Wing [avianMeasurement::wingspan] '
          'SVL [herpMeasurement::svl]',
    });

    expect(
      text.text,
      'TL [mammalAttribute::totalLength] '
      'Wing [birdAttribute::wingspan] '
      'SVL [herpAttribute::svl]',
    );
  });

  test('canonicalizes legacy foot color fields to toe color fields', () {
    expect(
      canonicalizeSpecimenAttributeSourceKey('avianMeasurement::footColor'),
      'birdAttribute::toeColor',
    );
    expect(
      canonicalizeSpecimenAttributeSourceKey('measurement::footHex'),
      'measurement::toeHex',
    );
  });

  test('moves legacy arthropod environment and canopy sources', () {
    expect(
      canonicalizeSpecimenAttributeSourceKey(
        'arthropodAttribute::ambientHumidity',
      ),
      'environment::ambientHumidity',
    );
    expect(
      canonicalizeSpecimenAttributeSourceKey('arthropodAttribute::canopyCover'),
      'siteAttribute::canopyCover',
    );
    expect(
      canonicalizeSpecimenAttributeExpression(
        r'${arthropodAttribute::flowVelocity}',
      ),
      r'${environment::flowVelocity}',
    );
  });
}
