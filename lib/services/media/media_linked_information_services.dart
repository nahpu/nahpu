import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/database/taxonomy_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/services/types/import.dart';

class MediaLinkedField {
  const MediaLinkedField(this.label, this.value);

  final String label;
  final String? value;
}

class MediaLinkedInformation {
  const MediaLinkedInformation({required this.fields});

  final List<MediaLinkedField> fields;
}

class MediaLinkRequest {
  const MediaLinkRequest({required this.mediaId, required this.category});

  final int mediaId;
  final String category;

  @override
  bool operator ==(Object other) {
    return other is MediaLinkRequest &&
        other.mediaId == mediaId &&
        other.category == category;
  }

  @override
  int get hashCode => Object.hash(mediaId, category);
}

final mediaLinkedInformationProvider = FutureProvider.family
    .autoDispose<MediaLinkedInformation?, MediaLinkRequest>((ref, request) {
      return MediaLinkedInformationServices(
        dbAccess: ref.read(databaseProvider),
      ).resolve(
        mediaId: request.mediaId,
        category: matchMediaCategoryString(request.category),
      );
    });

class MediaLinkedInformationServices {
  const MediaLinkedInformationServices({required this.dbAccess});

  final Database dbAccess;

  Future<MediaLinkedInformation?> resolve({
    required int mediaId,
    required MediaCategory category,
  }) {
    return switch (category) {
      MediaCategory.specimen => _specimenInformation(mediaId),
      MediaCategory.site => _siteInformation(mediaId),
      MediaCategory.event => _eventInformation(mediaId),
      MediaCategory.narrative => _narrativeInformation(mediaId),
      MediaCategory.personnel || MediaCategory.all => Future.value(),
    };
  }

  Future<MediaLinkedInformation?> _specimenInformation(int mediaId) async {
    final link =
        await (dbAccess.select(dbAccess.specimenMedia)
              ..where((row) => row.mediaId.equals(mediaId))
              ..limit(1))
            .getSingleOrNull();
    if (link == null) return null;

    final specimen = await SpecimenQuery(
      dbAccess,
    ).getSpecimenByUuid(link.specimenUuid);
    final event = specimen.collEventID == null
        ? null
        : await CollEventQuery(
            dbAccess,
          ).getCollEventById(specimen.collEventID!);
    final site = event?.siteID == null
        ? null
        : await SiteQuery(dbAccess).getSiteById(event!.siteID!);
    final taxon = specimen.speciesID == null
        ? null
        : await TaxonomyQuery(dbAccess).getTaxonById(specimen.speciesID!);
    final fields = <MediaLinkedField>[
      MediaLinkedField('Field ID', await _fieldId(specimen)),
      if (specimen.museumID?.trim().isNotEmpty ?? false)
        MediaLinkedField('Museum ID', specimen.museumID),
      MediaLinkedField(
        'Species',
        taxon == null ? null : getTaxonDisplayName(taxon),
      ),
      MediaLinkedField(
        'Event ID',
        event == null ? null : formatCollEventId(event, site),
      ),
      MediaLinkedField('Site name', site == null ? null : formatSiteName(site)),
    ];
    return MediaLinkedInformation(fields: fields);
  }

  Future<MediaLinkedInformation?> _siteInformation(int mediaId) async {
    final link =
        await (dbAccess.select(dbAccess.siteMedia)
              ..where((row) => row.mediaId.equals(mediaId))
              ..limit(1))
            .getSingleOrNull();
    if (link == null) return null;
    final site = await SiteQuery(dbAccess).getSiteById(link.siteId);
    return MediaLinkedInformation(
      fields: [
        MediaLinkedField('Site ID', site.siteID),
        MediaLinkedField('Site name', formatSiteName(site)),
      ],
    );
  }

  Future<MediaLinkedInformation?> _eventInformation(int mediaId) async {
    final link =
        await (dbAccess.select(dbAccess.eventMedia)
              ..where((row) => row.mediaId.equals(mediaId))
              ..limit(1))
            .getSingleOrNull();
    if (link == null) return null;
    final event = await CollEventQuery(dbAccess).getCollEventById(link.eventID);
    final site = event.siteID == null
        ? null
        : await SiteQuery(dbAccess).getSiteById(event.siteID!);
    return MediaLinkedInformation(
      fields: [
        MediaLinkedField('Event ID', formatCollEventId(event, site)),
        MediaLinkedField(
          'Site name',
          site == null ? null : formatSiteName(site),
        ),
      ],
    );
  }

  Future<MediaLinkedInformation?> _narrativeInformation(int mediaId) async {
    final link =
        await (dbAccess.select(dbAccess.narrativeMedia)
              ..where((row) => row.mediaId.equals(mediaId))
              ..limit(1))
            .getSingleOrNull();
    if (link == null) return null;
    final narrative =
        await (dbAccess.select(dbAccess.narrative)
              ..where((row) => row.id.equals(link.narrativeId))
              ..limit(1))
            .getSingleOrNull();
    if (narrative == null) return null;
    final site = narrative.siteID == null
        ? null
        : await SiteQuery(dbAccess).getSiteById(narrative.siteID!);
    final writer = narrative.writerId == null
        ? null
        : await _personnel(narrative.writerId!);
    final writerName = writer?.name?.trim();
    return MediaLinkedInformation(
      fields: [
        MediaLinkedField(
          'Site name',
          site == null ? null : formatSiteName(site),
        ),
        MediaLinkedField(
          'Writer',
          writerName?.isNotEmpty ?? false ? writerName : narrative.writerId,
        ),
      ],
    );
  }

  Future<String?> _fieldId(SpecimenData specimen) async {
    if (specimen.projectFieldNumber != null) {
      if (specimen.projectUuid == null) {
        return specimen.projectFieldNumber.toString();
      }
      final project = await ProjectQuery(
        dbAccess,
      ).getProjectByUuid(specimen.projectUuid!);
      return formatProjectFieldId(project, specimen.projectFieldNumber);
    }
    if (specimen.fieldNumber == null) return null;
    final cataloger = specimen.catalogerID == null
        ? null
        : await _personnel(specimen.catalogerID!);
    return '${cataloger?.initial ?? ''}${specimen.fieldNumber}';
  }

  Future<PersonnelData?> _personnel(String uuid) async {
    return (dbAccess.select(dbAccess.personnel)
          ..where((row) => row.uuid.equals(uuid))
          ..limit(1))
        .getSingleOrNull();
  }
}
