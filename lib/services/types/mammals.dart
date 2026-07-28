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

const List<String> testisPositionList = ['Scrotal', 'Abdominal'];

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

const List<String> vaginaOpeningList = ['Imperforate', 'Perforate'];

enum PubicSymphysis { close, smallOpen, open }

const List<String> pubicSymphysisList = ['Close', 'Small Open', 'Open'];

enum ReproductiveStage { nulliparous, primiparous, multiparous }

const List<String> reproductiveStageList = [
  'Nulliparous',
  'Primiparous',
  'Multiparous',
];

enum MammaeCondition { small, large, lactating }

const List<String> mammaeConditionList = ['Small', 'Large', 'Lactating'];

enum MammalAccuracyStatus { accurate, inaccurate }

const List<String> accuracyList = ['Accurate', 'Inaccurate'];

const List<String> coreMammalAccuracyFields = [
  'totalLength',
  'tailLength',
  'hindFootLength',
  'earLength',
  'weight',
];

const List<String> batMammalAccuracyFields = ['forearm', 'tibia'];

const List<String> mammalAccuracyFieldOrder = [
  'totalLength',
  'tailLength',
  'hindFootLength',
  'earLength',
  'forearm',
  'tibia',
  'weight',
];

const Map<String, String> mammalAccuracyFieldLabels = {
  'totalLength': 'Total length',
  'tailLength': 'Tail length',
  'hindFootLength': 'Hind foot length',
  'earLength': 'Ear length',
  'forearm': 'Forearm length',
  'tibia': 'Tibia length',
  'weight': 'Weight',
};

class MammalAccuracyDetails {
  MammalAccuracyDetails({
    required this.status,
    Iterable<String> inaccurateFields = const [],
    this.remark = '',
  }) : inaccurateFields = Set.unmodifiable(inaccurateFields);

  final MammalAccuracyStatus status;
  final Set<String> inaccurateFields;
  final String remark;

  bool get isInaccurate => status == MammalAccuracyStatus.inaccurate;

  MammalAccuracyDetails copyWith({
    MammalAccuracyStatus? status,
    Iterable<String>? inaccurateFields,
    String? remark,
  }) {
    return MammalAccuracyDetails(
      status: status ?? this.status,
      inaccurateFields: inaccurateFields ?? this.inaccurateFields,
      remark: remark ?? this.remark,
    );
  }
}

List<String> availableMammalAccuracyFields({required bool includeBatFields}) {
  return [
    ...coreMammalAccuracyFields,
    if (includeBatFields) ...batMammalAccuracyFields,
  ];
}

MammalAccuracyDetails parseMammalAccuracy(
  String? accuracy, {
  String? accuracySpecify,
  required bool includeBatFields,
}) {
  final storedAccuracy = accuracy?.trim() ?? '';
  final storedRemark = accuracySpecify?.trim() ?? '';
  final normalizedAccuracy = storedAccuracy.toLowerCase();
  final availableFields = availableMammalAccuracyFields(
    includeBatFields: includeBatFields,
  );

  if (storedAccuracy.isEmpty || normalizedAccuracy == 'accurate') {
    return MammalAccuracyDetails(
      status: MammalAccuracyStatus.accurate,
      remark: storedRemark,
    );
  }

  if (normalizedAccuracy.startsWith('inaccurate:')) {
    final fieldText = storedAccuracy.substring(storedAccuracy.indexOf(':') + 1);
    final fields = fieldText
        .split(',')
        .map((field) => field.trim())
        .where(mammalAccuracyFieldOrder.contains);
    return MammalAccuracyDetails(
      status: MammalAccuracyStatus.inaccurate,
      inaccurateFields: fields,
      remark: storedRemark,
    );
  }

  final legacyFields = switch (normalizedAccuracy) {
    'tail cropped' => const ['totalLength', 'tailLength', 'weight'],
    'ear damaged' => const ['earLength', 'weight'],
    'ear length inaccurate' => const ['earLength'],
    'hind length inaccurate' => const ['hindFootLength'],
    'partially eaten' ||
    'other' ||
    'other reason' ||
    'all measurements inaccurate' => availableFields,
    _ => availableFields,
  };

  return MammalAccuracyDetails(
    status: MammalAccuracyStatus.inaccurate,
    inaccurateFields: legacyFields,
    remark: storedRemark.isNotEmpty ? storedRemark : storedAccuracy,
  );
}

String serializeMammalAccuracy(MammalAccuracyDetails details) {
  if (!details.isInaccurate) return 'accurate';

  final fields = mammalAccuracyFieldOrder
      .where(details.inaccurateFields.contains)
      .toList();
  if (fields.isEmpty) {
    throw ArgumentError('At least one inaccurate measurement is required.');
  }
  return 'inaccurate:${fields.join(',')}';
}

enum Echolocation { fm, cf, qcf, none }

const List<String> echolocationList = ['FM', 'CF', 'QCF', 'None'];

Echolocation? getEcholocation(int? echolocation) {
  if (echolocation != null) {
    return Echolocation.values[echolocation];
  }
  return null;
}
