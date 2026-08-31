import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';

SpecimenPartProjectRecord specimenPartFixture({
  int id = 1,
  String? type,
  int? fieldNumber,
  int? projectNumber,
  String? tissueId,
  String? barcode,
  String? treatment,
  String? museumId,
}) {
  return SpecimenPartProjectRecord(
    part: SpecimenPartData(
      id: id,
      specimenUuid: 'specimen-$id',
      tissueID: tissueId ?? 'T-$id',
      barcodeID: barcode,
      type: type,
      treatment: treatment,
    ),
    specimen: SpecimenData(
      uuid: 'specimen-$id',
      projectUuid: 'project',
      fieldNumber: fieldNumber,
      projectFieldNumber: projectNumber,
      museumID: museumId,
    ),
  );
}
