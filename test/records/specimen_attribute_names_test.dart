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

  test('rewrites v21 site geography keys to the geography namespace', () {
    for (final field in const [
      'country',
      'islandGroup',
      'stateProvince',
      'county',
      'municipality',
      'locality',
      'specificLocality',
      'verbatimLocality',
    ]) {
      expect(
        canonicalizeSpecimenAttributeSourceKey('site::$field'),
        'geography::$field',
        reason: 'site::$field should move to the geography namespace',
      );
    }

    // Fields that stayed on the site row must not be rewritten.
    for (final key in const [
      'site::siteID',
      'site::siteType',
      'site::remark',
      'site::mediaID',
    ]) {
      expect(canonicalizeSpecimenAttributeSourceKey(key), key);
    }

    // Habitat fields still resolve to siteAttribute, not geography.
    expect(
      canonicalizeSpecimenAttributeSourceKey('site::habitatType'),
      'siteAttribute::habitatType',
    );
  });

  test('migrates saved preset expressions to the geography namespace', () {
    expect(
      canonicalizeSpecimenAttributeExpression(
        '[site::siteID]: [site::country]; [site::stateProvince]; '
        '[site::county], [site::locality]',
      ),
      '[site::siteID]: [geography::country]; [geography::stateProvince]; '
      '[geography::county], [geography::locality]',
    );
    // A longer key must not be clipped by a shorter one that shares a prefix.
    expect(
      canonicalizeSpecimenAttributeExpression('[site::verbatimLocality]'),
      '[geography::verbatimLocality]',
    );
    expect(
      canonicalizeSpecimenAttributeExpression('[site::specificLocality]'),
      '[geography::specificLocality]',
    );
  });
}
