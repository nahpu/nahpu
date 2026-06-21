import 'package:nahpu/services/types/export.dart';

List<String> getAvailableExportColumns({
  required ExportRecordType recordType,
  SpecimenRecordType? specimenRecordType,
  SpecimenExportFmt? specimenExportFmt,
}) {
  switch (recordType) {
    case ExportRecordType.narrative:
      return narrativeExportList;
    case ExportRecordType.site:
      return siteExportList;
    case ExportRecordType.collEvent:
      return collEventExportList;
    case ExportRecordType.specimenParts:
      return [
        ...collectingRecordExportList,
        ...siteExportList,
        ...collEventExportList,
        ...partExportListDelimited,
      ];
    case ExportRecordType.specimenRecord:
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
            measurementList = [
              ...mammalMeasurementExportList,
              ...avianMeasurementExportList,
              ...batMeasurementExportList,
              ...herpMeasurementExportList,
            ].toSet().toList();
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
