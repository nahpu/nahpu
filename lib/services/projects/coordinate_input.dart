enum AngularCoordinateAxis { latitude, longitude }

enum AngularCoordinateDirection {
  north('N'),
  south('S'),
  east('E'),
  west('W');

  const AngularCoordinateDirection(this.label);

  final String label;

  bool supports(AngularCoordinateAxis axis) => switch (axis) {
    AngularCoordinateAxis.latitude =>
      this == AngularCoordinateDirection.north ||
          this == AngularCoordinateDirection.south,
    AngularCoordinateAxis.longitude =>
      this == AngularCoordinateDirection.east ||
          this == AngularCoordinateDirection.west,
  };

  static AngularCoordinateDirection? fromLabel(String? value) {
    final normalized = value?.trim().toUpperCase();
    for (final direction in values) {
      if (direction.label == normalized) return direction;
    }
    return null;
  }
}

class AngularCoordinateParts {
  const AngularCoordinateParts({
    required this.degrees,
    required this.minutes,
    this.seconds = '',
    required this.direction,
  });

  final String degrees;
  final String minutes;
  final String seconds;
  final AngularCoordinateDirection? direction;
}

class AngularCoordinateValidation {
  const AngularCoordinateValidation({
    this.degreesError,
    this.minutesError,
    this.secondsError,
    this.directionError,
  });

  final String? degreesError;
  final String? minutesError;
  final String? secondsError;
  final String? directionError;

  bool get isValid =>
      degreesError == null &&
      minutesError == null &&
      secondsError == null &&
      directionError == null;

  String get firstError =>
      degreesError ??
      minutesError ??
      secondsError ??
      directionError ??
      'Invalid coordinate';
}

class CoordinateInputPartsCodec {
  const CoordinateInputPartsCodec._();

  static final RegExp _numberPattern = RegExp(r'\d+(?:\.\d+)?');
  static final RegExp _directionPattern = RegExp(r'\b([NSEW])\b');

  static AngularCoordinateParts? tryParseVerbatim(
    String? value, {
    required AngularCoordinateAxis axis,
    required bool includesSeconds,
  }) {
    if (value == null || value.trim().isEmpty || value.contains('-')) {
      return null;
    }
    final tokens = _numberPattern
        .allMatches(value)
        .map((match) => match.group(0)!)
        .toList(growable: false);
    final expectedCount = includesSeconds ? 3 : 2;
    if (tokens.length != expectedCount) return null;

    final directionMatch = _directionPattern.firstMatch(value.toUpperCase());
    final direction = AngularCoordinateDirection.fromLabel(
      directionMatch?.group(1),
    );
    final parts = AngularCoordinateParts(
      degrees: tokens[0],
      minutes: tokens[1],
      seconds: includesSeconds ? tokens[2] : '',
      direction: direction,
    );
    return validate(parts, axis: axis, includesSeconds: includesSeconds).isValid
        ? parts
        : null;
  }

  static AngularCoordinateValidation validate(
    AngularCoordinateParts parts, {
    required AngularCoordinateAxis axis,
    required bool includesSeconds,
  }) {
    final axisLabel = axis.name;
    final maxDegrees = axis == AngularCoordinateAxis.latitude ? 90 : 180;
    String? degreesError;
    String? minutesError;
    String? secondsError;
    String? directionError;

    final degrees = int.tryParse(parts.degrees);
    if (parts.degrees.isEmpty) {
      degreesError = 'Enter $axisLabel degrees';
    } else if (degrees == null || degrees < 0 || degrees > maxDegrees) {
      degreesError = '$axisLabel degrees must be 0–$maxDegrees';
    }

    final minutes = includesSeconds
        ? int.tryParse(parts.minutes)?.toDouble()
        : double.tryParse(parts.minutes);
    if (parts.minutes.isEmpty) {
      minutesError = 'Enter $axisLabel minutes';
    } else if (minutes == null ||
        !minutes.isFinite ||
        minutes < 0 ||
        minutes >= 60) {
      minutesError = '$axisLabel minutes must be at least 0 and less than 60';
    }

    double? seconds;
    if (includesSeconds) {
      seconds = double.tryParse(parts.seconds);
      if (parts.seconds.isEmpty) {
        secondsError = 'Enter $axisLabel seconds';
      } else if (seconds == null ||
          !seconds.isFinite ||
          seconds < 0 ||
          seconds >= 60) {
        secondsError = '$axisLabel seconds must be at least 0 and less than 60';
      }
    }

    if (degrees == maxDegrees && ((minutes ?? 0) != 0 || (seconds ?? 0) != 0)) {
      final limit = '$maxDegrees° $axisLabel requires zero minutes and seconds';
      minutesError ??= limit;
      if (includesSeconds) secondsError ??= limit;
    }

    final direction = parts.direction;
    if (direction == null || !direction.supports(axis)) {
      directionError = axis == AngularCoordinateAxis.latitude
          ? 'Select N or S for latitude'
          : 'Select E or W for longitude';
    }

    return AngularCoordinateValidation(
      degreesError: degreesError,
      minutesError: minutesError,
      secondsError: secondsError,
      directionError: directionError,
    );
  }

  static String compose(
    AngularCoordinateParts parts, {
    required AngularCoordinateAxis axis,
    required bool includesSeconds,
  }) {
    final validation = validate(
      parts,
      axis: axis,
      includesSeconds: includesSeconds,
    );
    if (!validation.isValid) throw FormatException(validation.firstError);
    final direction = parts.direction!.label;
    if (includesSeconds) {
      return '${parts.degrees}° ${parts.minutes}\' ${parts.seconds}" $direction';
    }
    return '${parts.degrees}° ${parts.minutes}\' $direction';
  }
}
