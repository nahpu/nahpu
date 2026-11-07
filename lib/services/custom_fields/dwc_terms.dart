import 'package:nahpu/services/types/custom_field.dart';

const dwcTermsVersion = '2026-05-26';

/// Terms a custom field may be mapped onto directly.
///
/// Every entry must be a registered bundle column for at least one target in
/// [builtInDwcFieldsByTarget]; `nahpu_dwc` withholds anything else from a Darwin Core
/// bundle rather than publishing it under an invented term.
const officialDwcFields = <String>[
  'dwc:associatedTaxa',
  'dwc:basisOfRecord',
  'dwc:behavior',
  'dwc:catalogNumber',
  'dwc:class',
  'dwc:country',
  'dwc:county',
  'dwc:decimalLatitude',
  'dwc:decimalLongitude',
  'dwc:eventDate',
  'dwc:eventRemarks',
  'dwc:family',
  'dwc:genus',
  'dwc:habitat',
  'dwc:individualCount',
  'dwc:lifeStage',
  'dwc:locality',
  'dwc:materialEntityRemarks',
  'dwc:materialEntityType',
  'dwc:materialSampleID',
  'dwc:measurementValue',
  'dwc:municipality',
  'dwc:occurrenceRemarks',
  'dwc:organismInteractionDescription',
  'dwc:organismInteractionType',
  'dwc:preparations',
  'dwc:recordNumber',
  'dwc:reproductiveCondition',
  'dwc:samplingEffort',
  'dwc:samplingProtocol',
  'dwc:scientificName',
  'dwc:sex',
  'dwc:stateProvince',
  'dwc:verbatimLocality',
];

const builtInDwcFieldsByTarget = <String, Set<String>>{
  'event': {
    'dwc:country',
    'dwc:county',
    'dwc:decimalLatitude',
    'dwc:decimalLongitude',
    'dwc:eventDate',
    'dwc:eventRemarks',
    'dwc:habitat',
    'dwc:locality',
    'dwc:municipality',
    'dwc:samplingEffort',
    'dwc:samplingProtocol',
    'dwc:stateProvince',
  },
  'occurrence': {
    'dwc:basisOfRecord',
    'dwc:catalogNumber',
    'dwc:class',
    'dwc:family',
    'dwc:genus',
    'dwc:lifeStage',
    'dwc:occurrenceRemarks',
    'dwc:recordNumber',
    'dwc:scientificName',
    'dwc:sex',
  },
  'material': {
    'dwc:materialEntityRemarks',
    'dwc:materialEntityType',
    'dwc:materialSampleID',
    'dwc:preparations',
  },
  'organismInteraction': {
    'dwc:organismInteractionDescription',
    'dwc:organismInteractionType',
  },
};

List<String> dwcTargetsForPlacement(FieldUISection placement) =>
    switch (placement) {
      FieldUISection.siteAttribute => const ['event'],
      FieldUISection.environmentalData => const ['event'],
      FieldUISection.specimenAttribute => const ['occurrence'],
      FieldUISection.specimenPart => const ['material'],
      FieldUISection.symbiont => const ['occurrence', 'organismInteraction'],
    };
