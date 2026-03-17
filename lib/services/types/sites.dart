import 'package:flutter/foundation.dart';

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
  'Montane Forest'
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
    return 'assets/icons/placeholder.svg';
  }
}
