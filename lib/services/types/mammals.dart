// Database read through index.
// and stored as integer.
// DON'T CHANGE ORDER!
enum SpecimenAge { adult, subadult, juvenile, unknown }

const List<String> specimenAgeList = [
  'Adult',
  'Subadult',
  'Juvenile',
  'Unknown',
];

SpecimenAge? getSpecimenAge(int? age) {
  if (age != null) {
    return SpecimenAge.values[age];
  }
  return null;
}

enum TestisPosition { scrotal, abdominal }

const List<String> testisPositionList = [
  'Scrotal',
  'Abdominal',
];

TestisPosition? getTestisPosition(int? pos) {
  if (pos != null) {
    return TestisPosition.values[pos];
  }
  return null;
}

enum EpididymisAppearance { tubular, partial, notTubular }

const List<String> epididymisAppearanceList = [
  'Tubular',
  'Partial',
  'Not Tubular',
];

enum VaginaOpening { imperforate, perforate }

const List<String> vaginaOpeningList = [
  'Imperforate',
  'Perforate',
];

enum PubicSymphysis { close, smallOpen, open }

const List<String> pubicSymphysisList = [
  'Close',
  'Small Open',
  'Open',
];

enum ReproductiveStage { nulliparous, primiparous, multiparous }

const List<String> reproductiveStageList = [
  'Nulliparous',
  'Primiparous',
  'Multiparous',
];

enum MammaeCondition { small, large, lactating }

const List<String> mammaeConditionList = [
  'Small',
  'Large',
  'Lactating',
];

const List<String> accuracyList = [
  'Accurate',
  'Tail cropped',
  'Ear damaged',
  'Partially eaten',
  'Other reason',
];

const List<String> accuracyOtherReason = [
  'Ear length inaccurate',
  'Hind length inaccurate',
  'All measurements inaccurate',
];

enum MeasurementAccuracy {
  accurate,
  tailCropped,
  partiallyEaten,
  earLengthInaccurate,
  hindLengthInaccurate,
  allMeasurementsInaccurate,
  other,
}

MeasurementAccuracy matchAccuracy(String? accuracy) {
  if (accuracy == null || accuracy.isEmpty) {
    return MeasurementAccuracy.accurate;
  }

  switch (accuracy) {
    case 'Tail cropped':
      return MeasurementAccuracy.tailCropped;
    case 'Partially eaten':
      return MeasurementAccuracy.partiallyEaten;
    case 'Ear length inaccurate':
      return MeasurementAccuracy.earLengthInaccurate;
    case 'Hind length inaccurate':
      return MeasurementAccuracy.hindLengthInaccurate;
    case 'All measurements inaccurate':
      return MeasurementAccuracy.allMeasurementsInaccurate;
    case 'Other reason':
      return MeasurementAccuracy.other;
    default:
      return MeasurementAccuracy.accurate;
  }
}

enum Echolocation { fm, cf, qcf, none }

const List<String> echolocationList = [
  'FM',
  'CF',
  'QCF',
  'None',
];

Echolocation? getEcholocation(int? echolocation) {
  if (echolocation != null) {
    return Echolocation.values[echolocation];
  }
  return null;
}
