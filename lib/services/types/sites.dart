import 'package:flutter/foundation.dart';

enum SiteCopyField {
  siteId,
  leadStaff,
  siteType,
  country,
  stateProvince,
  county,
  municipality,
  locality,
  remark,
  habitatType,
  habitatCondition,
  habitatDescription,
  coordinates,
}

extension SiteCopyFieldLabel on SiteCopyField {
  String get label => switch (this) {
    SiteCopyField.siteId => 'Site ID',
    SiteCopyField.leadStaff => 'Site leader',
    SiteCopyField.siteType => 'Site type',
    SiteCopyField.country => 'Country',
    SiteCopyField.stateProvince => 'State/Province',
    SiteCopyField.county => 'County/Parish/District',
    SiteCopyField.municipality => 'Municipality/City/Town',
    SiteCopyField.locality => 'Precise locality',
    SiteCopyField.remark => 'Remarks',
    SiteCopyField.habitatType => 'Habitat type',
    SiteCopyField.habitatCondition => 'Habitat condition',
    SiteCopyField.habitatDescription => 'Habitat description',
    SiteCopyField.coordinates => 'Coordinates',
  };
}

const List<String> defaultSiteTypes = [
  'City',
  'Town',
  'Hotel',
  'Village',
  'Camp',
  'Trail',
  'Trapline',
  'Netline',
  'Cave',
  'Other',
];

const List<String> defaultHabitatTypes = [
  'Urban',
  'Riverbank',
  'Desert',
  'Grassland',
  'Montane Forest',
];

class CoordinateIcon {
  const CoordinateIcon({required this.coordinateName});

  final String coordinateName;

  String matchCoordinateToIconPath() {
    final lowercased = _cleanName();
    if (kDebugMode) {
      print('Coordinate: $coordinateName, Lowercased: $lowercased');
    }
    return _matchNameToIconPath(lowercased);
  }

  String _cleanName() {
    final lowercased = coordinateName.toLowerCase().trim();
    if (lowercased.endsWith('s') || lowercased.endsWith('es')) {
      return lowercased.substring(0, coordinateName.length - 1);
    }
    return lowercased.replaceAll(' ', '-');
  }

  String _matchNameToIconPath(String lowercased) {
    if (lowercased.contains('hotel') || lowercased.contains('hostel')) {
      return 'assets/icons/hotel.svg';
    } else if (lowercased.contains('house') || lowercased.contains('home')) {
      return 'assets/icons/home.svg';
    } else if (lowercased.contains('camp') || lowercased.contains('tent')) {
      return 'assets/icons/tent.svg';
    }
    return 'assets/icons/coordinate.svg';
  }
}
