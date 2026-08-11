import 'package:nahpu/services/types/export.dart';

List<String> getAvailableExportColumns({
  required RecordType recordType,
  SpecimenRecordType? specimenRecordType,
  SpecimenExportFmt? specimenExportFmt,
}) {
  switch (recordType) {
    case RecordType.none:
      return [];
    case RecordType.narrative:
      return narrativeExportList;
    case RecordType.site:
      return siteExportList;
    case RecordType.collEvent:
      return collEventExportList;
    case RecordType.specimenParts:
      return [
        ...collectingRecordExportList,
        ...siteExportList,
        ...collEventExportList,
        ...partExportListDelimited,
      ];
    case RecordType.specimenRecord:
      List<String> attributeList = [];
      if (specimenRecordType != null) {
        switch (specimenRecordType) {
          case SpecimenRecordType.generalMammals:
            attributeList = mammalAttributeExportList;
            break;
          case SpecimenRecordType.birds:
            attributeList = birdAttributeExportList;
            break;
          case SpecimenRecordType.bats:
          case SpecimenRecordType.allMammals:
            attributeList = batAttributeExportList;
            break;
          case SpecimenRecordType.herpetofauna:
            attributeList = herpAttributeExportList;
            break;
          case SpecimenRecordType.arthropods:
            attributeList = arthropodAttributeExportList;
            break;
          case SpecimenRecordType.allTaxa:
            attributeList = <String>{
              ...mammalAttributeExportList,
              ...birdAttributeExportList,
              ...batAttributeExportList,
              ...herpAttributeExportList,
              ...arthropodAttributeExportList,
            }.toSet().toList();
            break;
        }
      }
      return [
        ...collectingRecordExportList,
        ...siteExportList,
        ...collEventExportList,
        ...attributeList,
        if (specimenRecordType != SpecimenRecordType.arthropods)
          ...parasiteDetectionExportList,
        if (specimenRecordType != SpecimenRecordType.arthropods)
          ...parasiteExportList,
        partExportSimple,
        'media::media',
      ];
  }
}
