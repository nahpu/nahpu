import 'package:flutter/foundation.dart';

enum SiteCopyField {
  siteId,
  leadStaff,
  siteType,
  country,
  islandGroup,
  stateProvince,
  county,
  municipality,
  locality,
  remark,
  habitatType,
  habitatCondition,
  habitatDescription,
  canopyCover,
  coordinates,
}

extension SiteCopyFieldLabel on SiteCopyField {
  String get label => switch (this) {
    SiteCopyField.siteId => 'Site ID',
    SiteCopyField.leadStaff => 'Site leader',
    SiteCopyField.siteType => 'Site type',
    SiteCopyField.country => 'Country',
    SiteCopyField.islandGroup => 'Island group',
    SiteCopyField.stateProvince => 'State/Province',
    SiteCopyField.county => 'County/Parish/District',
    SiteCopyField.municipality => 'Municipality/City/Town',
    SiteCopyField.locality => 'Precise locality',
    SiteCopyField.remark => 'Remarks',
    SiteCopyField.habitatType => 'Habitat type',
    SiteCopyField.habitatCondition => 'Habitat condition',
    SiteCopyField.habitatDescription => 'Habitat description',
    SiteCopyField.canopyCover => 'Canopy cover',
    SiteCopyField.coordinates => 'Coordinates',
  };
}

const List<String> siteGeographyFields = [
  'country',
  'islandGroup',
  'stateProvince',
  'county',
  'municipality',
];

const List<String> defaultVisibleSiteGeographyFields = [
  'country',
  'stateProvince',
  'county',
  'municipality',
];

const Map<String, String> siteGeographyFieldLabels = {
  'country': 'Country',
  'islandGroup': 'Island group',
  'stateProvince': 'State/Province',
  'county': 'County/Parish/District',
  'municipality': 'Municipality/City/Town',
};

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

const List<String> defaultDatums = ['WGS84', 'NAD83', 'NAD27'];

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
