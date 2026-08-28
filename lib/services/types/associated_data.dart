enum AssociatedDataOrigin { sites, events, specimens }

sealed class AssociatedDataTarget {
  const AssociatedDataTarget();

  const factory AssociatedDataTarget.site(int siteId) =
      SiteAssociatedDataTarget;

  const factory AssociatedDataTarget.event(int eventId) =
      EventAssociatedDataTarget;

  const factory AssociatedDataTarget.specimen(String specimenUuid) =
      SpecimenAssociatedDataTarget;

  AssociatedDataOrigin get origin;
}

final class SiteAssociatedDataTarget extends AssociatedDataTarget {
  const SiteAssociatedDataTarget(this.siteId);

  final int siteId;

  @override
  AssociatedDataOrigin get origin => AssociatedDataOrigin.sites;

  @override
  bool operator ==(Object other) =>
      other is SiteAssociatedDataTarget && other.siteId == siteId;

  @override
  int get hashCode => Object.hash(origin, siteId);
}

final class EventAssociatedDataTarget extends AssociatedDataTarget {
  const EventAssociatedDataTarget(this.eventId);

  final int eventId;

  @override
  AssociatedDataOrigin get origin => AssociatedDataOrigin.events;

  @override
  bool operator ==(Object other) =>
      other is EventAssociatedDataTarget && other.eventId == eventId;

  @override
  int get hashCode => Object.hash(origin, eventId);
}

final class SpecimenAssociatedDataTarget extends AssociatedDataTarget {
  const SpecimenAssociatedDataTarget(this.specimenUuid);

  final String specimenUuid;

  @override
  AssociatedDataOrigin get origin => AssociatedDataOrigin.specimens;

  @override
  bool operator ==(Object other) =>
      other is SpecimenAssociatedDataTarget &&
      other.specimenUuid == specimenUuid;

  @override
  int get hashCode => Object.hash(origin, specimenUuid);
}

enum AssociatedDataFileStorageMode { copyToProject, linkOriginal }
