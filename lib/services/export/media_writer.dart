import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/export/common.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/media_services.dart';
import 'package:nahpu/services/narrative_services.dart';
import 'package:nahpu/services/personnel_services.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/taxonomy_services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/utility_services.dart';

class MediaWriterServices {
  MediaWriterServices({
    required this.ref,
  });

  final WidgetRef ref;

  Future<void> writeAllMediaDelimited(File filePath, bool isCsv) async {
    String delimiter = isCsv ? csvDelimiter : tsvDelimiter;

    final file = await filePath.create(recursive: true);
    final writer = file.openWrite();

    String header = allMediaExportList.toDelimitedText(delimiter);
    writer.writeln(header);

    List<MediaData> mediaList =
        await MediaServices(ref: ref).getAllMediaByProject();

    for (var media in mediaList) {
      List<String> mediaDetails = await _getMedia(media);
      String linkedData = await MediaCategoryServices(ref: ref)
          .getLinkedData(media.primaryId, media.category);
      mediaDetails.insert(1, linkedData);
      writer.writeln(mediaDetails.toDelimitedText(delimiter));
    }

    writer.close();
  }

  Future<String> getSpecimenMedias(String specimenUuid) async {
    List<SpecimenMediaData> mediaList =
        await SpecimenServices(ref: ref).getSpecimenMedia(specimenUuid);
    List<MediaData> mediaDataList = [];
    for (var media in mediaList) {
      if (media.mediaId != null) {
        MediaData mediaData =
            await MediaServices(ref: ref).getMediaById(media.mediaId!);
        mediaDataList.add(mediaData);
      }
    }
    return await _getConcatenateMediaData(mediaDataList);
  }

  Future<String> getSiteMedias(int? siteID) async {
    if (siteID == null) {
      return '';
    }
    List<SiteMediaData> mediaList =
        await SiteServices(ref: ref).getSiteMedia(siteID);
    List<MediaData> mediaDataList = [];
    for (var media in mediaList) {
      if (media.mediaId != null) {
        MediaData mediaData =
            await MediaServices(ref: ref).getMediaById(media.mediaId!);
        mediaDataList.add(mediaData);
      }
    }
    return await _getConcatenateMediaData(mediaDataList);
  }

  Future<String> getNarrativeMedias(int? narrativeId) async {
    if (narrativeId == null) {
      return '';
    }
    List<NarrativeMediaData> mediaList =
        await NarrativeServices(ref: ref).getNarrativeMedia(narrativeId);
    List<MediaData> mediaDataList = [];
    for (var media in mediaList) {
      if (media.mediaId != null) {
        MediaData mediaData =
            await MediaServices(ref: ref).getMediaById(media.mediaId!);
        mediaDataList.add(mediaData);
      }
    }

    return await _getConcatenateMediaData(mediaDataList);
  }

  Future<String> _getConcatenateMediaData(List<MediaData> data) async {
    List<String> mediaDetails = await Future.wait(data.map((e) async {
      List<String> mediaList = await _getMedia(e);
      mediaList.removeWhere((e) => e.isEmpty);
      return mediaList.join(';');
    }));
    String mediaDetailsString = mediaDetails.join(writerSeparator);
    return mediaDetailsString;
  }

  Future<List<String>> _getMedia(MediaData data) async {
    String category = data.category != null ? '${data.category}' : '';
    String tag = data.tag != null ? '${data.tag}' : '';
    String camera = data.camera != null ? '${data.camera}' : 'unknown camera';
    String dateTaken = data.taken != null ? '${data.taken}' : 'unknown date';
    String lenseModel =
        data.lenses != null ? '${data.lenses}' : 'unknown lenses';
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
    PersonnelData photographer =
        await PersonnelServices(ref: ref).getPersonnelByUuid(photographerUuid);
    return '${photographer.name}';
  }

  String _cleanAdditionalExif(String? addExif) {
    if (addExif == null) {
      return '';
    }
    String addExifClean = addExif.replaceAll(listTileSeparator, ' ');
    return addExifClean;
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
    NarrativeMediaData narrativeMediaData =
        await NarrativeServices(ref: ref).getNarrativeMediaByMediaId(mediaId);
    NarrativeData narrative = await NarrativeServices(ref: ref)
        .getNarrative(narrativeMediaData.narrativeId);
    return narrative.date != null ? 'Date: ${narrative.date}' : '';
  }

  Future<String> _getSiteLinkedData(int mediaId) async {
    SiteMediaData siteMediaData =
        await SiteServices(ref: ref).getSiteMediaByMediaId(mediaId);
    SiteData? site = await SiteServices(ref: ref).getSite(siteMediaData.siteId);
    if (site == null) {
      return '';
    }
    String siteId = site.siteID ?? '';
    String locality = site.locality ?? '';
    return '$siteId: $locality';
  }

  Future<String> _getSpecimenLinkedData(int mediaId) async {
    SpecimenMediaData specimenMediaData =
        await SpecimenServices(ref: ref).getSpecimenMediaByMediaId(mediaId);
    SpecimenData specimen = await SpecimenServices(ref: ref)
        .getSpecimen(specimenMediaData.specimenUuid);
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
        : await PersonnelServices(ref: ref)
            .getPersonnelByUuid(specimen.catalogerID!);
    if (catalogerName == null) {
      return '';
    }
    return '${catalogerName.name ?? ''} ${specimen.fieldNumber ?? ''}:';
  }
}
