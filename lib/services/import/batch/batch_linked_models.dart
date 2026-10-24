import 'package:nahpu/services/import/batch/batch_import_models.dart';

/// Whether a group of rows becomes a new record or joins one the project
/// already has.
enum BatchGroupAction { create, linkExisting }

/// The rows of a linked import that describe one site.
class BatchSiteGroup {
  const BatchSiteGroup({
    required this.id,
    required this.rows,
    this.values = const {},
    this.coordinate = const {},
    this.siteName,
    this.action = BatchGroupAction.create,
    this.existingId,
    this.existingLabel,
    this.conflicts = const [],
    this.problems = const [],
  });

  /// Stable within the import, such as `site-1`.
  final String id;

  /// Indexes into the table's rows.
  final List<int> rows;

  /// Text to store by site, habitat, and locality field key.
  final Map<String, String> values;

  /// Text to store by coordinate field key.
  final Map<String, String> coordinate;

  /// The site ID a new site gets.
  final String? siteName;
  final BatchGroupAction action;

  /// The existing site's row id, when linked.
  final int? existingId;
  final String? existingLabel;

  /// Fields the rows disagree on, as messages.
  final List<String> conflicts;

  /// Values that don't fit their field, as messages. They are left out.
  final List<String> problems;

  /// What the review calls this site.
  String get label =>
      siteName ??
      values['geography::specificLocality'] ??
      values['geography::country'] ??
      'Site without ID';

  BatchSiteGroup copyWith({
    String? id,
    List<int>? rows,
    String? Function()? siteName,
    BatchGroupAction? action,
    int? Function()? existingId,
    String? Function()? existingLabel,
    List<String>? conflicts,
  }) => BatchSiteGroup(
    id: id ?? this.id,
    rows: rows ?? this.rows,
    values: values,
    coordinate: coordinate,
    siteName: siteName == null ? this.siteName : siteName(),
    action: action ?? this.action,
    existingId: existingId == null ? this.existingId : existingId(),
    existingLabel: existingLabel == null ? this.existingLabel : existingLabel(),
    conflicts: conflicts ?? this.conflicts,
    problems: problems,
  );
}

/// The rows of a linked import that describe one collecting event.
class BatchEventGroup {
  const BatchEventGroup({
    required this.id,
    required this.rows,
    this.siteGroupId,
    this.values = const {},
    this.idSuffix,
    this.action = BatchGroupAction.create,
    this.existingId,
    this.existingLabel,
    this.conflicts = const [],
    this.problems = const [],
  });

  final String id;
  final List<int> rows;

  /// The site group the event happened at, if the rows name one.
  final String? siteGroupId;

  /// Text to store by event and environment field key.
  final Map<String, String> values;

  /// The suffix a new event's ID gets.
  final String? idSuffix;
  final BatchGroupAction action;
  final int? existingId;
  final String? existingLabel;
  final List<String> conflicts;
  final List<String> problems;

  String get startDate => values['event::startDate'] ?? '';
  String get method => values['event::Activity'] ?? '';

  BatchEventGroup copyWith({
    String? id,
    List<int>? rows,
    String? Function()? siteGroupId,
    String? Function()? idSuffix,
    BatchGroupAction? action,
    int? Function()? existingId,
    String? Function()? existingLabel,
    List<String>? conflicts,
  }) => BatchEventGroup(
    id: id ?? this.id,
    rows: rows ?? this.rows,
    siteGroupId: siteGroupId == null ? this.siteGroupId : siteGroupId(),
    values: values,
    idSuffix: idSuffix == null ? this.idSuffix : idSuffix(),
    action: action ?? this.action,
    existingId: existingId == null ? this.existingId : existingId(),
    existingLabel: existingLabel == null ? this.existingLabel : existingLabel(),
    conflicts: conflicts ?? this.conflicts,
    problems: problems,
  );
}

/// A specimen of a linked import: one row, or several rows that share its
/// catalog number, UUID, or cataloger and field number.
class BatchLinkedSpecimen {
  const BatchLinkedSpecimen({
    required this.id,
    required this.rows,
    required this.plan,
    this.eventGroupId,
    this.parts = const [],
    this.parasites = const [],
  });

  final String id;
  final List<int> rows;

  /// What the specimen's own columns write, checked as a specimen import
  /// checks them.
  final BatchRowPlan plan;
  final String? eventGroupId;
  final List<BatchLinkedPart> parts;
  final List<BatchLinkedParasite> parasites;

  BatchLinkedSpecimen copyWith({String? Function()? eventGroupId}) =>
      BatchLinkedSpecimen(
        id: id,
        rows: rows,
        plan: plan,
        eventGroupId: eventGroupId == null ? this.eventGroupId : eventGroupId(),
        parts: parts,
        parasites: parasites,
      );
}

/// A part one row adds to its specimen.
class BatchLinkedPart {
  const BatchLinkedPart({required this.row, required this.plan});

  /// Index into the table's rows.
  final int row;
  final BatchRowPlan plan;
}

/// A parasite one row adds to its specimen.
class BatchLinkedParasite {
  const BatchLinkedParasite({required this.row, required this.plan});

  /// Index into the table's rows.
  final int row;
  final BatchRowPlan plan;
}

/// What a linked import will write.
class BatchLinkedCounts {
  const BatchLinkedCounts({
    required this.newSites,
    required this.linkedSites,
    required this.newEvents,
    required this.linkedEvents,
    required this.specimens,
    required this.parts,
    this.parasites = 0,
    required this.skippedRows,
  });

  final int newSites;
  final int linkedSites;
  final int newEvents;
  final int linkedEvents;
  final int specimens;
  final int parts;
  final int parasites;

  /// Rows excluded by the user or with nothing that can be written.
  final int skippedRows;
}

/// How a linked import's rows become sites, events, specimens, parts, and
/// parasites,
/// with the user's changes. Every change returns a new plan.
class BatchLinkedPlan {
  const BatchLinkedPlan({
    required this.rowNumbers,
    required this.sites,
    required this.events,
    required this.specimens,
    this.excluded = const {},
  });

  /// The file row number of each table row, for messages.
  final List<int> rowNumbers;
  final List<BatchSiteGroup> sites;
  final List<BatchEventGroup> events;
  final List<BatchLinkedSpecimen> specimens;

  /// Table rows the user left out.
  final Set<int> excluded;

  BatchSiteGroup? site(String? id) =>
      sites.where((site) => site.id == id).firstOrNull;
  BatchEventGroup? event(String? id) =>
      events.where((event) => event.id == id).firstOrNull;

  /// Events at [siteId], in file order.
  List<BatchEventGroup> eventsAt(String siteId) => [
    for (final event in events)
      if (event.siteGroupId == siteId) event,
  ];

  bool isRowIncluded(int row) => !excluded.contains(row);

  /// Whether any of [rows] is still in the import.
  bool isActive(List<int> rows) => rows.any(isRowIncluded);

  /// Specimens to write: active, and importable as [includeMissingLinks]
  /// decides.
  List<BatchLinkedSpecimen> writableSpecimens({
    bool includeMissingLinks = true,
  }) => [
    for (final specimen in specimens)
      if (isActive(specimen.rows) &&
          (specimen.plan.status == BatchRowStatus.ready ||
              (includeMissingLinks &&
                  specimen.plan.status == BatchRowStatus.missingLink)))
        specimen,
  ];

  /// Parts of [specimen] to write.
  List<BatchLinkedPart> writableParts(BatchLinkedSpecimen specimen) => [
    for (final part in specimen.parts)
      if (isRowIncluded(part.row) && part.plan.status.isImportable) part,
  ];

  /// Parasites of [specimen] to write.
  List<BatchLinkedParasite> writableParasites(BatchLinkedSpecimen specimen) => [
    for (final parasite in specimen.parasites)
      if (isRowIncluded(parasite.row) && parasite.plan.status.isImportable)
        parasite,
  ];

  /// Events to write or link: those of a writable specimen, or of active
  /// rows that hold no specimen.
  Set<String> usedEvents({bool includeMissingLinks = true}) {
    final specimenRows = {for (final specimen in specimens) ...specimen.rows};
    return {
      for (final specimen in writableSpecimens(
        includeMissingLinks: includeMissingLinks,
      ))
        ?specimen.eventGroupId,
      for (final event in events)
        if (event.rows.any(
          (row) => isRowIncluded(row) && !specimenRows.contains(row),
        ))
          event.id,
    };
  }

  /// Sites to write or link: those of a used event, or of active rows that
  /// hold no event.
  Set<String> usedSites({bool includeMissingLinks = true}) {
    final eventRows = {for (final event in events) ...event.rows};
    return {
      for (final id in usedEvents(includeMissingLinks: includeMissingLinks))
        ?event(id)?.siteGroupId,
      for (final site in sites)
        if (site.rows.any(
          (row) => isRowIncluded(row) && !eventRows.contains(row),
        ))
          site.id,
    };
  }

  BatchLinkedCounts counts({bool includeMissingLinks = true}) {
    final usedSites = this.usedSites(includeMissingLinks: includeMissingLinks);
    final usedEvents = this.usedEvents(
      includeMissingLinks: includeMissingLinks,
    );
    final writable = writableSpecimens(
      includeMissingLinks: includeMissingLinks,
    );
    final writtenRows = {
      for (final specimen in writable) ...specimen.rows,
      for (final event in events)
        if (usedEvents.contains(event.id)) ...event.rows,
      for (final site in sites)
        if (usedSites.contains(site.id)) ...site.rows,
    }.where(isRowIncluded).toSet();
    int count(Iterable<BatchGroupAction> actions, BatchGroupAction action) =>
        actions.where((a) => a == action).length;
    final siteActions = [
      for (final site in sites)
        if (usedSites.contains(site.id)) site.action,
    ];
    final eventActions = [
      for (final event in events)
        if (usedEvents.contains(event.id)) event.action,
    ];
    return BatchLinkedCounts(
      newSites: count(siteActions, BatchGroupAction.create),
      linkedSites: count(siteActions, BatchGroupAction.linkExisting),
      newEvents: count(eventActions, BatchGroupAction.create),
      linkedEvents: count(eventActions, BatchGroupAction.linkExisting),
      specimens: writable.length,
      parts: writable.fold<int>(0, (n, s) => n + writableParts(s).length),
      parasites: writable.fold<int>(
        0,
        (n, s) => n + writableParasites(s).length,
      ),
      skippedRows: rowNumbers.length - writtenRows.length,
    );
  }

  BatchLinkedPlan _copy({
    List<BatchSiteGroup>? sites,
    List<BatchEventGroup>? events,
    List<BatchLinkedSpecimen>? specimens,
    Set<int>? excluded,
  }) => BatchLinkedPlan(
    rowNumbers: rowNumbers,
    sites: sites ?? this.sites,
    events: events ?? this.events,
    specimens: specimens ?? this.specimens,
    excluded: excluded ?? this.excluded,
  );

  BatchLinkedPlan _updateSite(
    String id,
    BatchSiteGroup Function(BatchSiteGroup site) update,
  ) => _copy(
    sites: [for (final site in sites) site.id == id ? update(site) : site],
  );

  BatchLinkedPlan _updateEvent(
    String id,
    BatchEventGroup Function(BatchEventGroup event) update,
  ) => _copy(
    events: [
      for (final event in events) event.id == id ? update(event) : event,
    ],
  );

  /// Points the site group at an existing site instead of a new one.
  BatchLinkedPlan linkSite(String id, int siteId, String label) => _updateSite(
    id,
    (site) => site.copyWith(
      action: BatchGroupAction.linkExisting,
      existingId: () => siteId,
      existingLabel: () => label,
    ),
  );

  BatchLinkedPlan createSite(String id) => _updateSite(
    id,
    (site) => site.copyWith(
      action: BatchGroupAction.create,
      existingId: () => null,
      existingLabel: () => null,
    ),
  );

  /// Sets the site ID a new site gets; blank leaves it without one.
  BatchLinkedPlan renameSite(String id, String name) => _updateSite(
    id,
    (site) =>
        site.copyWith(siteName: () => name.trim().isEmpty ? null : name.trim()),
  );

  /// Moves [from]'s rows and events into [into]. Events that end up alike,
  /// on the same date with the same method, become one.
  BatchLinkedPlan mergeSites(String from, String into) {
    if (from == into) return this;
    final source = site(from);
    final target = site(into);
    if (source == null || target == null) return this;
    final merged = _copy(
      sites: [
        for (final site in sites)
          if (site.id == into)
            site.copyWith(
              rows: [...site.rows, ...source.rows]..sort(),
              conflicts: [...site.conflicts, ...source.conflicts],
            )
          else if (site.id != from)
            site,
      ],
      events: [
        for (final event in events)
          event.siteGroupId == from
              ? event.copyWith(siteGroupId: () => into)
              : event,
      ],
    );
    return merged._mergeAlikeEvents(into);
  }

  /// Moves [rows] of site [id] into a new site, with the parts of its
  /// events those rows hold.
  BatchLinkedPlan splitSite(String id, Set<int> rows) {
    final source = site(id);
    if (source == null) return this;
    final moving = source.rows.where(rows.contains).toList();
    if (moving.isEmpty || moving.length == source.rows.length) return this;
    final newId = _nextId('site', sites.map((s) => s.id));
    var plan = _copy(
      sites: [
        for (final site in sites)
          site.id == id
              ? site.copyWith(
                  rows: [
                    for (final row in site.rows)
                      if (!rows.contains(row)) row,
                  ],
                )
              : site,
      ],
    );
    plan = plan._copy(
      sites: [
        ...plan.sites,
        source.copyWith(
          id: newId,
          rows: moving,
          siteName: () => null,
          action: BatchGroupAction.create,
          existingId: () => null,
          existingLabel: () => null,
          conflicts: const [],
        ),
      ],
    );
    for (final event in eventsAt(id)) {
      final eventRows = event.rows.where(rows.contains).toSet();
      if (eventRows.isEmpty) continue;
      if (eventRows.length == event.rows.length) {
        plan = plan._updateEvent(
          event.id,
          (e) => e.copyWith(siteGroupId: () => newId),
        );
      } else {
        plan = plan.splitEvent(event.id, eventRows);
        final created = plan.events.last;
        plan = plan._updateEvent(
          created.id,
          (e) => e.copyWith(siteGroupId: () => newId),
        );
      }
    }
    return plan;
  }

  BatchLinkedPlan linkEvent(String id, int eventId, String label) =>
      _updateEvent(
        id,
        (event) => event.copyWith(
          action: BatchGroupAction.linkExisting,
          existingId: () => eventId,
          existingLabel: () => label,
        ),
      );

  BatchLinkedPlan createEvent(String id) => _updateEvent(
    id,
    (event) => event.copyWith(
      action: BatchGroupAction.create,
      existingId: () => null,
      existingLabel: () => null,
    ),
  );

  /// Sets the suffix a new event's ID gets; blank leaves it without one.
  BatchLinkedPlan renameEvent(String id, String suffix) => _updateEvent(
    id,
    (event) => event.copyWith(
      idSuffix: () => suffix.trim().isEmpty ? null : suffix.trim(),
    ),
  );

  /// Moves [from]'s rows and specimens into [into], at [into]'s site.
  BatchLinkedPlan mergeEvents(String from, String into) {
    if (from == into) return this;
    final source = event(from);
    final target = event(into);
    if (source == null || target == null) return this;
    return _copy(
      events: [
        for (final event in events)
          if (event.id == into)
            event.copyWith(
              rows: [...event.rows, ...source.rows]..sort(),
              conflicts: [...event.conflicts, ...source.conflicts],
            )
          else if (event.id != from)
            event,
      ],
      specimens: [
        for (final specimen in specimens)
          specimen.eventGroupId == from
              ? specimen.copyWith(eventGroupId: () => into)
              : specimen,
      ],
    );
  }

  /// Moves [rows] of event [id] into a new event at the same site, with
  /// the specimens those rows start.
  BatchLinkedPlan splitEvent(String id, Set<int> rows) {
    final source = event(id);
    if (source == null) return this;
    final moving = source.rows.where(rows.contains).toList();
    if (moving.isEmpty || moving.length == source.rows.length) return this;
    final newId = _nextId('event', events.map((e) => e.id));
    return _copy(
      events: [
        for (final event in events)
          if (event.id == id)
            event.copyWith(
              rows: [
                for (final row in event.rows)
                  if (!rows.contains(row)) row,
              ],
            )
          else
            event,
        source.copyWith(
          id: newId,
          rows: moving,
          idSuffix: () => null,
          action: BatchGroupAction.create,
          existingId: () => null,
          existingLabel: () => null,
          conflicts: const [],
        ),
      ],
      specimens: [
        for (final specimen in specimens)
          specimen.eventGroupId == id && rows.contains(specimen.rows.first)
              ? specimen.copyWith(eventGroupId: () => newId)
              : specimen,
      ],
    );
  }

  BatchLinkedPlan excludeRow(int row) => _copy(excluded: {...excluded, row});

  BatchLinkedPlan includeRow(int row) =>
      _copy(excluded: {...excluded}..remove(row));

  BatchLinkedPlan _mergeAlikeEvents(String siteId) {
    var plan = this;
    final kept = <String, String>{};
    for (final event in eventsAt(siteId)) {
      final key =
          '${event.startDate}|${event.values['event::endDate']}|'
                  '${event.method}'
              .toLowerCase();
      final into = kept[key];
      if (into == null) {
        kept[key] = event.id;
      } else {
        plan = plan.mergeEvents(event.id, into);
      }
    }
    return plan;
  }

  static String _nextId(String prefix, Iterable<String> taken) {
    final used = taken.toSet();
    var n = used.length + 1;
    while (used.contains('$prefix-$n')) {
      n++;
    }
    return '$prefix-$n';
  }
}
