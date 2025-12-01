// Centralized definition of mandatory fields for data validation.
class MandatoryFieldService {
  // Maps internal field names to human-readable labels
  static const Map<String, String> fieldLabels = {
    'sex': 'Sex',
    'age': 'Age',
    'totalLength': 'Total Length',
    'tailLength': 'Tail Length',
    'hindFootLength': 'Hind Foot Length',
    'earLength': 'Ear Length',
    'weight': 'Weight',
    'forearm': 'Forearm Length',
    'testisLength': 'Testis Length',
    'testisWidth': 'Testis Width',
    'wingspan': 'Wingspan',
    'bursaLength': 'Bursa Length',
    'bursaWidth': 'Bursa Width',
    'ovaryLength': 'Ovary Length',
    'ovaryWidth': 'Ovary Width',
    'catalogerID': 'Cataloger',
    'fieldNumber': 'Field Number',
    'speciesID': 'Species',
    'prepDate': 'Prep Date',
    'prepTime': 'Prep Time',
    'collEventID': 'Event ID',
    'siteID': 'Site ID',
    'country': 'Country',
    'stateProvince': 'State/Province',
    'locality': 'Precise Locality',
  };

  // Mammal Specific Fields that are dropdowns
  static const List<String> mammalDropdowns = ['sex', 'age'];

  // Mammal Specific Fields for outlier detection and null/empty checks
  static const List<String> mammalMeasurements = [
    'totalLength',
    'tailLength',
    'hindFootLength',
    'earLength',
    'weight',
  ];

  // Bird Specific Fields for outlier detection and null/empty checks
  static const List<String> avianMeasurements = [
    'sex',
    'weight',
    'wingspan',
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

  // Helper to get all relevant specimen fields for UI selection
  static List<String> get allSpecimenFields => <String>{
        ...specimenGeneral,
        ...specimenCapture,
        ...mammalDropdowns,
        ...mammalMeasurements,
        ...avianMeasurements,
      }.toList(); // Remove duplicates if any

  static Map<String, List<String>> get groupedFields => {
        'General': [...specimenGeneral, ...specimenCapture],
        'Mammals': [...mammalDropdowns, ...mammalMeasurements],
        'Birds': [...avianMeasurements],
      };
}