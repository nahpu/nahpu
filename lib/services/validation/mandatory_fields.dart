// Centralized definition of mandatory fields for data validation.
class MandatoryFieldService {
  // Mammal Specific Fields that are dropdowns
  static const List<String> mammalDropdowns = ['sex', 'age'];

  // Mammal Specific Fields for outlier detection and null/empty checks
  static const List<String> mammalMeasurements = [
    'totalLength',
    'tailLength',
    'hindFootLength',
    'earLength',
    'weight'
  ];

  // Shared Specimen Fields for null/empty checks
  static const List<String> specimenGeneral = [
    'catalogerID',
    'fieldNumber',
    'speciesID',
    'prepDate',
    'prepTime'
  ];

  // Shared Capture Record Fields for null/empty checks
  static const List<String> specimenCapture = ['collEventID'];
  // Note: siteID is implicitly checked via collEventID

  // Site Record Fields for null/empty checks
  static const List<String> siteFields = [
    'siteID',
    'country',
    'stateProvince',
    'locality'
  ];
}