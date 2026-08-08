import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/coordinate_input.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/controllers.dart';

void main() {
  test('DDM composition preserves entered precision', () {
    const latitude = AngularCoordinateParts(
      degrees: '41',
      minutes: '24.2028',
      direction: AngularCoordinateDirection.north,
    );
    const longitude = AngularCoordinateParts(
      degrees: '123',
      minutes: '15.500',
      direction: AngularCoordinateDirection.west,
    );

    expect(
      CoordinateInputPartsCodec.compose(
        latitude,
        axis: AngularCoordinateAxis.latitude,
        includesSeconds: false,
      ),
      "41° 24.2028' N",
    );
    expect(
      CoordinateInputPartsCodec.compose(
        longitude,
        axis: AngularCoordinateAxis.longitude,
        includesSeconds: false,
      ),
      "123° 15.500' W",
    );
  });

  test('DMS composition and parsing preserve component tokens', () {
    const parts = AngularCoordinateParts(
      degrees: '12',
      minutes: '03',
      seconds: '04.250',
      direction: AngularCoordinateDirection.south,
    );
    final verbatim = CoordinateInputPartsCodec.compose(
      parts,
      axis: AngularCoordinateAxis.latitude,
      includesSeconds: true,
    );
    final parsed = CoordinateInputPartsCodec.tryParseVerbatim(
      verbatim,
      axis: AngularCoordinateAxis.latitude,
      includesSeconds: true,
    );

    expect(verbatim, '12° 03\' 04.250" S');
    expect(parsed?.degrees, '12');
    expect(parsed?.minutes, '03');
    expect(parsed?.seconds, '04.250');
    expect(parsed?.direction, AngularCoordinateDirection.south);
  });

  test('validation enforces directions, component ranges, and axis limits', () {
    const missingDirection = AngularCoordinateParts(
      degrees: '41',
      minutes: '24.2',
      direction: null,
    );
    const invalidLimit = AngularCoordinateParts(
      degrees: '90',
      minutes: '1',
      seconds: '0',
      direction: AngularCoordinateDirection.north,
    );
    const wrongAxis = AngularCoordinateParts(
      degrees: '12',
      minutes: '60',
      direction: AngularCoordinateDirection.east,
    );

    expect(
      CoordinateInputPartsCodec.validate(
        missingDirection,
        axis: AngularCoordinateAxis.latitude,
        includesSeconds: false,
      ).directionError,
      isNotNull,
    );
    expect(
      CoordinateInputPartsCodec.validate(
        invalidLimit,
        axis: AngularCoordinateAxis.latitude,
        includesSeconds: true,
      ).minutesError,
      contains('zero minutes'),
    );
    final wrongAxisValidation = CoordinateInputPartsCodec.validate(
      wrongAxis,
      axis: AngularCoordinateAxis.latitude,
      includesSeconds: false,
    );
    expect(wrongAxisValidation.minutesError, isNotNull);
    expect(wrongAxisValidation.directionError, isNotNull);
  });

  test(
    'coordinate controller restores DDM and flags altered verbatim data',
    () {
      final valid = CoordinateCtrModel.fromData(
        const CoordinateData(
          decimalLatitude: 41.40338,
          decimalLongitude: -123.25833,
          verbatimLatitude: "41° 24.2028' N",
          verbatimLongitude: "123° 15.5' W",
          verbatimCoordinateSystem: 'degrees decimal minutes',
        ),
      );
      final altered = CoordinateCtrModel.fromData(
        const CoordinateData(
          decimalLatitude: 41.4,
          decimalLongitude: -123.2,
          verbatimLatitude: 'changed externally',
          verbatimLongitude: "123° 15.5' W",
          verbatimCoordinateSystem: 'degrees decimal minutes',
        ),
      );
      addTearDown(valid.dispose);
      addTearDown(altered.dispose);

      expect(valid.inputFormat, 'degreesDecimalMinutes');
      expect(valid.latitudeAngularCtr.degreesCtr.text, '41');
      expect(
        valid.longitudeAngularCtr.direction,
        AngularCoordinateDirection.west,
      );
      expect(
        altered.latitudeAngularCtr.invalidStoredValue,
        'changed externally',
      );
      expect(altered.latitudeAngularCtr.degreesCtr.text, isEmpty);
    },
  );
}
