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
      List<String> measurementList = [];
      if (specimenRecordType != null) {
        switch (specimenRecordType) {
          case SpecimenRecordType.generalMammals:
            measurementList = mammalMeasurementExportList;
            break;
          case SpecimenRecordType.birds:
            measurementList = avianMeasurementExportList;
            break;
          case SpecimenRecordType.bats:
          case SpecimenRecordType.allMammals:
            measurementList = batMeasurementExportList;
            break;
          case SpecimenRecordType.herpetofauna:
            measurementList = herpMeasurementExportList;
            break;
          case SpecimenRecordType.allTaxa:
            measurementList = <String>{
              ...mammalMeasurementExportList,
              ...avianMeasurementExportList,
              ...batMeasurementExportList,
              ...herpMeasurementExportList,
            }.toSet().toList();
            break;
        }
      }
      return [
        ...collectingRecordExportList,
        ...siteExportList,
        ...collEventExportList,
        ...measurementList,
        partExportSimple,
        'media::media',
      ];
  }
}
