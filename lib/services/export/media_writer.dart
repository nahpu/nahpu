import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/common.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/media/media_services.dart';
import 'package:nahpu/services/narrative/narrative_services.dart';
import 'package:nahpu/services/projects/personnel_services.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';

class MediaWriterServices {
  MediaWriterServices({required this.ref});

  final WidgetRef ref;

  Future<String> getSpecimenMedias(String specimenUuid) async {
    List<SpecimenMediaData> mediaList = await SpecimenServices(
      ref: ref,
    ).getSpecimenMedia(specimenUuid);
    List<MediaData> mediaDataList = [];
    for (var media in mediaList) {
      if (media.mediaId != null) {
        MediaData mediaData = await MediaServices(
          ref: ref,
        ).getMediaById(media.mediaId!);
        mediaDataList.add(mediaData);
      }
    }
    return await _getConcatenateMediaData(mediaDataList);
  }

  Future<String> getSiteMedias(int? siteID) async {
    if (siteID == null) {
      return '';
    }
    List<SiteMediaData> mediaList = await SiteServices(
      ref: ref,
    ).getSiteMedia(siteID);
    List<MediaData> mediaDataList = [];
    for (var media in mediaList) {
      if (media.mediaId != null) {
        MediaData mediaData = await MediaServices(
          ref: ref,
        ).getMediaById(media.mediaId!);
        mediaDataList.add(mediaData);
      }
    }
    return await _getConcatenateMediaData(mediaDataList);
  }

  Future<String> getNarrativeMedias(int? narrativeId) async {
    if (narrativeId == null) {
      return '';
    }
    List<NarrativeMediaData> mediaList = await NarrativeServices(
      ref: ref,
    ).getNarrativeMedia(narrativeId);
    List<MediaData> mediaDataList = [];
    for (var media in mediaList) {
      if (media.mediaId != null) {
        MediaData mediaData = await MediaServices(
          ref: ref,
        ).getMediaById(media.mediaId!);
        mediaDataList.add(mediaData);
      }
    }

    return await _getConcatenateMediaData(mediaDataList);
  }

  Future<String> _getConcatenateMediaData(List<MediaData> data) async {
    List<String> mediaDetails = await Future.wait(
      data.map((e) async {
        List<String> mediaList = await _getMedia(e);
        mediaList.removeWhere((e) => e.isEmpty);
        return mediaList.join(';');
      }),
    );
    String mediaDetailsString = mediaDetails.join(writerSeparator);
    return mediaDetailsString;
  }

  Future<List<String>> _getMedia(MediaData data) async {
    String category = data.category != null ? '${data.category}' : '';
    String tag = data.tag != null ? '${data.tag}' : '';
    String camera = data.camera != null ? '${data.camera}' : 'unknown camera';
    String dateTaken = data.taken != null ? '${data.taken}' : 'unknown date';
    String lenseModel = data.lenses != null
        ? '${data.lenses}'
        : 'unknown lenses';
    String photographer = await _getPhotographer(data.personnelId);
    String additionalExif = _cleanAdditionalExif(data.additionalExif);
    String fileName = data.fileName != null ? '${data.fileName}' : '';
    String caption = data.caption != null ? '${data.caption}' : '';

    return [
      category,
      caption,
      photographer,
      tag,
      dateTaken,
      camera,
      lenseModel,
      additionalExif,
      fileName,
    ];
  }

  Future<String> _getPhotographer(String? photographerUuid) async {
    if (photographerUuid == null || photographerUuid.isEmpty) {
      return '';
    }
    PersonnelData photographer = await PersonnelServices(
      ref: ref,
    ).getPersonnelByUuid(photographerUuid);
    return '${photographer.name}';
  }

  String _cleanAdditionalExif(String? addExif) {
    return MediaMetadataServices().formatAdditionalMetadataForExport(addExif);
  }
}

class MediaCategoryServices extends AppServices {
  const MediaCategoryServices({required super.ref});

  Future<String> getLinkedData(int? mediaId, String? category) async {
    if (mediaId == null || category == null) {
      return '';
    }
    String linkedData = '';
    switch (category) {
      case 'specimen':
        linkedData = await _getSpecimenLinkedData(mediaId);
        break;
      case 'site':
        linkedData = await _getSiteLinkedData(mediaId);
        break;
      case 'narrative':
        linkedData = await _getNarrativeLinkedData(mediaId);
        break;
      default:
        break;
    }
    return linkedData;
  }

  Future<String> _getNarrativeLinkedData(int mediaId) async {
    NarrativeMediaData narrativeMediaData = await NarrativeServices(
      ref: ref,
    ).getNarrativeMediaByMediaId(mediaId);
    NarrativeData narrative = await NarrativeServices(
      ref: ref,
    ).getNarrative(narrativeMediaData.narrativeId);
    return narrative.date != null ? 'Date: ${narrative.date}' : '';
  }

  Future<String> _getSiteLinkedData(int mediaId) async {
    SiteMediaData siteMediaData = await SiteServices(
      ref: ref,
    ).getSiteMediaByMediaId(mediaId);
    SiteData? site = await SiteServices(ref: ref).getSite(siteMediaData.siteId);
    if (site == null) {
      return '';
    }
    String siteId = site.siteID ?? '';
    String locality = site.locality ?? '';
    return '$siteId: $locality';
  }

  Future<String> _getSpecimenLinkedData(int mediaId) async {
    SpecimenMediaData specimenMediaData = await SpecimenServices(
      ref: ref,
    ).getSpecimenMediaByMediaId(mediaId);
    SpecimenData specimen = await SpecimenServices(
      ref: ref,
    ).getSpecimen(specimenMediaData.specimenUuid);
    TaxonomyData? taxonomy = specimen.speciesID == null
        ? null
        : await TaxonomyServices(ref: ref).getTaxonById(specimen.speciesID!);
    String specimenFieldId = await _getSpecimenFieldId(specimen);
    String species = taxonomy == null
        ? ''
        : '${taxonomy.genus ?? ''} ${taxonomy.specificEpithet ?? ''}';
    return '$specimenFieldId $species';
  }

  Future<String> _getSpecimenFieldId(SpecimenData specimen) async {
    PersonnelData? catalogerName = specimen.catalogerID == null
        ? null
        : await PersonnelServices(
            ref: ref,
          ).getPersonnelByUuid(specimen.catalogerID!);
    if (catalogerName == null) {
      return '';
    }
    return '${catalogerName.name ?? ''} ${specimen.fieldNumber ?? ''}:';
  }
}
