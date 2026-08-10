import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/site_writer.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/projects/personnel_services.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';

class CollectingRecordWriterServices extends AppServices {
  const CollectingRecordWriterServices({required super.ref});

  Future<List<String>> getRecord(SpecimenData data) async {
    String specimenUuid = data.uuid;
    ({String name, String initial}) cataloger = await _getCatalogerIdentity(
      data.catalogerID,
    );
    String fieldNumber = '${data.fieldNumber ?? ''}';
    String preparator = await _getPreparatorName(data.preparatorID);
    List<String> taxonomy = await _getSpeciesName(data.speciesID);
    String condition = data.condition ?? '';
    String collectionTime = data.collectionTime ?? '';
    String prepDate = data.prepDate ?? '';
    String prepTime = data.prepTime ?? '';
    String specimenCoordinate = await _getSiteCoordinate(data.coordinateID);
    return [
      specimenUuid,
      cataloger.name,
      fieldNumber,
      preparator,
      ...taxonomy,
      condition,
      collectionTime,
      prepDate,
      prepTime,
      specimenCoordinate,
    ];
  }

  Future<List<String>> _getSpeciesName(int? speciesId) async {
    if (speciesId == null) {
      return [''];
    } else {
      TaxonomyData taxon = await TaxonomyServices(
        ref: ref,
      ).getTaxonById(speciesId);

      return [
        taxon.taxonOrder ?? '',
        taxon.taxonFamily ?? '',
        taxon.genus ?? '',
        taxon.specificEpithet ?? '',
      ];
    }
  }

  Future<({String name, String initial})> _getCatalogerIdentity(
    String? catalogerUuid,
  ) async {
    if (catalogerUuid == null) {
      return (name: '', initial: '');
    } else {
      PersonnelData person = await PersonnelServices(
        ref: ref,
      ).getPersonnelByUuid(catalogerUuid);
      return (name: person.name ?? '', initial: person.initial ?? '');
    }
  }

  Future<String> _getPreparatorName(String? preparatorUuid) async {
    if (preparatorUuid == null) {
      return '';
    } else {
      PersonnelData person = await PersonnelServices(
        ref: ref,
      ).getPersonnelByUuid(preparatorUuid);
      return person.name ?? '';
    }
  }

  Future<String> _getSiteCoordinate(int? coordinateId) async {
    if (coordinateId == null) {
      return '';
    } else {
      List<String> coordinate = await SiteWriterServices(
        ref: ref,
      ).getCoordinateById(coordinateId);
      return coordinate.join();
    }
  }
}
