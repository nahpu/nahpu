import 'dart:io';

import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/project_transfer/project_transfer_archive.dart';
import 'package:nahpu/services/project_transfer/project_transfer_models.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/controlled_vocabulary_services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

export 'project_transfer_archive.dart';
export 'project_transfer_models.dart';

/// Exports and imports complete NAHPU projects with related attribute records.
///
/// Archives are normalized while parsing so legacy attribute names and the
/// v1-v3 associated-data URL field remain importable.
class ProjectTransferService extends AppServices {
  ProjectTransferService({required super.ref})
    : _database = ref.read(databaseProvider),
      _projectUuid = ref.read(projectUuidProvider);

  final Database _database;
  final String _projectUuid;

  @override
  Database get dbAccess => _database;

  @override
  String get currentProjectUuid => _projectUuid;

  ProjectTransferArchiveService get archive =>
      ProjectTransferArchiveService(ref: ref);

  Future<ProjectTransferPayload> buildExport() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final projectRows = await _query('SELECT * FROM project WHERE uuid = ?', [
      currentProjectUuid,
    ]);
    if (projectRows.isEmpty) {
      throw StateError('The active project no longer exists.');
    }

    final records = <String, List<Map<String, dynamic>>>{};
    records['site'] = await _projectRows('site');
    final siteIds = _intIds(records['site']!, 'id');
    records['coordinate'] = await _rowsForIds('coordinate', 'siteID', siteIds);
    records['collEvent'] = await _projectRows('collEvent');
    final eventIds = _intIds(records['collEvent']!, 'id');
    records['weather'] = await _rowsForIds('weather', 'eventID', eventIds);
    records['collPersonnel'] = await _rowsForIds(
      'collPersonnel',
      'eventID',
      eventIds,
    );
    records['collEffort'] = await _rowsForIds(
      'collEffort',
      'eventID',
      eventIds,
    );
    records['eventAssociatedData'] = await _rowsForIds(
      'eventAssociatedData',
      'eventID',
      eventIds,
    );
    records['specimen'] = await _projectRows('specimen');
    final specimenUuids = _stringIds(records['specimen']!, 'uuid');
    records['mammalAttribute'] = await _rowsForStrings(
      'mammalAttribute',
      'specimenUuid',
      specimenUuids,
    );
    records['birdAttribute'] = await _rowsForStrings(
      'birdAttribute',
      'specimenUuid',
      specimenUuids,
    );
    records['herpAttribute'] = await _rowsForStrings(
      'herpAttribute',
      'specimenUuid',
      specimenUuids,
    );
    records['specimenPart'] = await _rowsForStrings(
      'specimenPart',
      'specimenUuid',
      specimenUuids,
    );
    records['parasiteDetection'] = await _rowsForStrings(
      'parasiteDetection',
      'specimenUuid',
      specimenUuids,
    );
    records['parasite'] = await _rowsForStrings(
      'parasite',
      'specimenUuid',
      specimenUuids,
    );
    records['associatedData'] = await _projectRows('associatedData');
    records['specimenAssociatedData'] = await _rowsForStrings(
      'specimenAssociatedData',
      'specimenUuid',
      specimenUuids,
    );
    records['siteAssociatedData'] = await _rowsForIds(
      'siteAssociatedData',
      'siteId',
      siteIds,
    );
    records['narrative'] = await _projectRows('narrative');
    final narrativeIds = _intIds(records['narrative']!, 'id');

    final taxonomyIds = {
      ...records['specimen']!.map((row) => row['speciesID']).whereType<int>(),
      ...records['parasite']!.map((row) => row['speciesID']).whereType<int>(),
    }.toList();
    records['taxonomy'] = await _rowsForIds('taxonomy', 'id', taxonomyIds);

    final personnelIds = <String>{};
    final projectPersonnel = await _query(
      'SELECT personnelUuid FROM personnelList WHERE projectUuid = ?',
      [currentProjectUuid],
    );
    personnelIds.addAll(
      projectPersonnel.map((row) => row['personnelUuid']).whereType<String>(),
    );
    _addStringValues(records['site']!, 'leadStaffId', personnelIds);
    _addStringValues(records['collPersonnel']!, 'personnelId', personnelIds);
    _addStringValues(records['specimen']!, 'catalogerID', personnelIds);
    _addStringValues(records['specimen']!, 'identifierID', personnelIds);
    _addStringValues(records['specimen']!, 'preparatorID', personnelIds);
    _addStringValues(records['specimenPart']!, 'personnelId', personnelIds);
    _addStringValues(records['parasite']!, 'identifierID', personnelIds);
    _addStringValues(records['narrative']!, 'writerId', personnelIds);
    records['personnel'] = await _rowsForStrings(
      'personnel',
      'uuid',
      personnelIds.toList(),
    );
    records['personnelList'] = records['personnel']!
        .map(
          (row) => {
            'projectUuid': currentProjectUuid,
            'personnelUuid': row['uuid'],
          },
        )
        .toList(growable: false);

    final linkedMediaIds = <int>{};
    records['siteMedia'] = await _rowsForIds('siteMedia', 'siteId', siteIds);
    records['eventMedia'] = await _rowsForIds(
      'eventMedia',
      'eventID',
      eventIds,
    );
    records['narrativeMedia'] = await _rowsForIds(
      'narrativeMedia',
      'narrativeId',
      narrativeIds,
    );
    records['specimenMedia'] = await _rowsForStrings(
      'specimenMedia',
      'specimenUuid',
      specimenUuids,
    );
    for (final key in [
      'siteMedia',
      'eventMedia',
      'narrativeMedia',
      'specimenMedia',
    ]) {
      linkedMediaIds.addAll(
        records[key]!.map((row) => row['mediaId']).whereType<int>(),
      );
    }
    linkedMediaIds.addAll(
      records['taxonomy']!.map((row) => row['mediaId']).whereType<int>(),
    );
    final projectMedia = await _projectRows('media');
    linkedMediaIds.addAll(_intIds(projectMedia, 'primaryId'));
    records['media'] = await _rowsForIds(
      'media',
      'primaryId',
      linkedMediaIds.toList(),
    );

    final warnings = <String>[];
    final mediaFiles = <ProjectTransferMediaFile>[];
    await _collectMedia(records, mediaFiles, warnings);
    await _collectPersonnelPhotos(records, mediaFiles, warnings);
    _validateReferences(records);

    return ProjectTransferPayload(
      exportedAt: DateTime.now().toUtc().toIso8601String(),
      appVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
      databaseVersion: kSchemaVersion,
      project: projectRows.single,
      records: records,
      mediaFiles: mediaFiles,
      warnings: warnings,
    );
  }

  Future<ProjectTransferImportPlan> planImport(
    ProjectTransferPayload payload, {
    ProjectTransferImportMode mode = ProjectTransferImportMode.merge,
    String? destinationName,
  }) async {
    _validateReferences(payload.records);
    late final String destinationProjectUuid;
    late final String destinationProjectName;
    ProjectTransferProjectMatch? nameConflict;
    if (mode == ProjectTransferImportMode.merge) {
      final activeRows = await _query('SELECT * FROM project WHERE uuid = ?', [
        currentProjectUuid,
      ]);
      if (activeRows.isEmpty) {
        throw StateError('The active project no longer exists.');
      }
      destinationProjectUuid = currentProjectUuid;
      destinationProjectName = activeRows.single['name'] as String;
    } else {
      final uuidMatch = await findProjectUuidMatch(payload.sourceProjectUuid);
      if (uuidMatch != null) {
        throw ProjectTransferProjectExistsException(uuidMatch);
      }
      destinationProjectUuid = payload.sourceProjectUuid;
      destinationProjectName = (destinationName ?? payload.projectName).trim();
      nameConflict = await findProjectNameMatch(destinationProjectName);
    }
    final conflicts = <ProjectTransferConflict>[];
    final matched = {
      for (final section in ProjectTransferSection.values) section: 0,
    };
    final fresh = {
      for (final section in ProjectTransferSection.values) section: 0,
    };

    final localPersonnel = {
      for (final row in await _query('SELECT * FROM personnel'))
        row['uuid'] as String: row,
    };
    for (final imported in payload.rows('personnel')) {
      final uuid = imported['uuid'] as String?;
      final current = uuid == null ? null : localPersonnel[uuid];
      if (current == null) {
        fresh[ProjectTransferSection.personnel] =
            fresh[ProjectTransferSection.personnel]! + 1;
      } else {
        matched[ProjectTransferSection.personnel] =
            matched[ProjectTransferSection.personnel]! + 1;
        conflicts.add(
          ProjectTransferConflict(
            id: _conflictId('personnel', uuid!),
            section: ProjectTransferSection.personnel,
            label: imported['name'] as String? ?? uuid,
            currentSummary: _personSummary(current),
            importedSummary: _personSummary(imported),
            warning:
                'Personnel are shared across projects. Replacing this person '
                'can affect other projects.',
          ),
        );
      }
    }

    final localTaxonomy = await _query('SELECT * FROM taxonomy');
    for (final imported in payload.rows('taxonomy')) {
      final current = _findTaxonomy(localTaxonomy, imported);
      if (current == null) {
        fresh[ProjectTransferSection.taxonomy] =
            fresh[ProjectTransferSection.taxonomy]! + 1;
      } else {
        matched[ProjectTransferSection.taxonomy] =
            matched[ProjectTransferSection.taxonomy]! + 1;
        conflicts.add(
          ProjectTransferConflict(
            id: _conflictId('taxonomy', imported['id']),
            section: ProjectTransferSection.taxonomy,
            label: _taxonName(imported),
            currentSummary: _taxonName(current),
            importedSummary: _taxonName(imported),
            warning:
                'Taxonomy is shared across projects. Replacing this taxon can '
                'affect specimens in other projects.',
          ),
        );
      }
    }

    final localSites = mode == ProjectTransferImportMode.merge
        ? await _projectRows('site', projectUuid: destinationProjectUuid)
        : <Map<String, dynamic>>[];
    final sourceSiteMatches = <int, int>{};
    for (final imported in payload.rows('site')) {
      final current = _findSite(localSites, imported);
      if (current == null) {
        fresh[ProjectTransferSection.sites] =
            fresh[ProjectTransferSection.sites]! + 1;
      } else {
        final sourceId = imported['id'] as int;
        sourceSiteMatches[sourceId] = current['id'] as int;
        matched[ProjectTransferSection.sites] =
            matched[ProjectTransferSection.sites]! + 1;
        conflicts.add(
          ProjectTransferConflict(
            id: _conflictId('site', sourceId),
            section: ProjectTransferSection.sites,
            label: _siteName(imported),
            currentSummary: _siteSummary(current),
            importedSummary: _siteSummary(imported),
          ),
        );
      }
    }

    final localEvents = mode == ProjectTransferImportMode.merge
        ? await _projectRows('collEvent', projectUuid: destinationProjectUuid)
        : <Map<String, dynamic>>[];
    for (final imported in payload.rows('collEvent')) {
      final current = _findEvent(localEvents, imported, sourceSiteMatches);
      if (current == null) {
        fresh[ProjectTransferSection.events] =
            fresh[ProjectTransferSection.events]! + 1;
      } else {
        matched[ProjectTransferSection.events] =
            matched[ProjectTransferSection.events]! + 1;
        conflicts.add(
          ProjectTransferConflict(
            id: _conflictId('event', imported['id']),
            section: ProjectTransferSection.events,
            label: _eventName(imported),
            currentSummary: _eventName(current),
            importedSummary: _eventName(imported),
          ),
        );
      }
    }

    final localSpecimens = {
      for (final row in await _query('SELECT * FROM specimen'))
        row['uuid'] as String: row,
    };
    for (final imported in payload.rows('specimen')) {
      final uuid = imported['uuid'] as String;
      final current = localSpecimens[uuid];
      if (current == null) {
        fresh[ProjectTransferSection.specimens] =
            fresh[ProjectTransferSection.specimens]! + 1;
      } else {
        matched[ProjectTransferSection.specimens] =
            matched[ProjectTransferSection.specimens]! + 1;
        final belongsToDestination =
            current['projectUuid'] == destinationProjectUuid;
        conflicts.add(
          ProjectTransferConflict(
            id: _conflictId('specimen', uuid),
            section: ProjectTransferSection.specimens,
            label: uuid,
            currentSummary: 'Project ${current['projectUuid'] ?? 'unknown'}',
            importedSummary: 'Source project ${payload.sourceProjectUuid}',
            allowedActions:
                mode == ProjectTransferImportMode.merge && belongsToDestination
                ? ProjectTransferConflictAction.values
                : const [
                    ProjectTransferConflictAction.importAsNew,
                    ProjectTransferConflictAction.skip,
                  ],
            warning:
                mode == ProjectTransferImportMode.merge && belongsToDestination
                ? null
                : 'This UUID belongs to another project and cannot be '
                      'replaced.',
          ),
        );
      }
    }

    final localNarratives = mode == ProjectTransferImportMode.merge
        ? await _projectRows('narrative', projectUuid: destinationProjectUuid)
        : <Map<String, dynamic>>[];
    for (final imported in payload.rows('narrative')) {
      final current = _findNarrative(
        localNarratives,
        imported,
        sourceSiteMatches,
      );
      if (current == null) {
        fresh[ProjectTransferSection.narratives] =
            fresh[ProjectTransferSection.narratives]! + 1;
      } else {
        matched[ProjectTransferSection.narratives] =
            matched[ProjectTransferSection.narratives]! + 1;
        conflicts.add(
          ProjectTransferConflict(
            id: _conflictId('narrative', imported['id']),
            section: ProjectTransferSection.narratives,
            label: _narrativeName(imported),
            currentSummary: _narrativeSummary(current),
            importedSummary: _narrativeSummary(imported),
          ),
        );
      }
    }

    return ProjectTransferImportPlan(
      payload: payload,
      mode: mode,
      destinationProjectUuid: destinationProjectUuid,
      destinationProjectName: destinationProjectName,
      conflicts: conflicts,
      matchedBySection: matched,
      newBySection: fresh,
      warnings: [...payload.warnings],
      nameConflict: nameConflict,
    );
  }

  Future<ProjectTransferProjectMatch?> findProjectUuidMatch(String uuid) async {
    final rows = await _query(
      'SELECT uuid, name FROM project WHERE uuid = ? LIMIT 1',
      [uuid],
    );
    if (rows.isEmpty) return null;
    return ProjectTransferProjectMatch(
      uuid: rows.single['uuid'] as String,
      name: rows.single['name'] as String,
    );
  }

  Future<ProjectTransferProjectMatch?> findProjectNameMatch(String name) async {
    final normalized = name.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    final rows = await _query('SELECT uuid, name FROM project');
    for (final row in rows) {
      final currentName = row['name'] as String;
      if (currentName.trim().toLowerCase() == normalized) {
        return ProjectTransferProjectMatch(
          uuid: row['uuid'] as String,
          name: currentName,
        );
      }
    }
    return null;
  }

  Future<ProjectTransferImportResult> importProject(
    ProjectTransferImportPlan plan, {
    required bool forceMerge,
    required Map<String, ProjectTransferConflictAction> conflictActions,
    required Map<String, bool> importedProjectFields,
    required Directory extractedDirectory,
    String? destinationProjectName,
  }) async {
    if (plan.hasUuidMismatch && !forceMerge) {
      throw const FormatException(
        'The project UUID does not match the active project.',
      );
    }
    final copiedFiles = <File>[];
    var imported = 0;
    var updated = 0;
    var skipped = 0;
    final targetProjectUuid = plan.destinationProjectUuid;
    final targetProjectName =
        (destinationProjectName ?? plan.destinationProjectName).trim();
    try {
      await dbAccess.transaction(() async {
        if (plan.isNewProject) {
          await _createImportedProject(plan, targetProjectName);
        } else {
          await _importProjectFields(
            plan,
            importedProjectFields,
            targetProjectUuid,
          );
        }
        final personnelMap = <String, String?>{};
        for (final row in plan.payload.rows('personnel')) {
          final sourceUuid = row['uuid'] as String;
          final conflict = _findConflict(plan, 'personnel', sourceUuid);
          final action = _actionFor(conflict, conflictActions);
          final exists = conflict != null;
          if (exists && action == ProjectTransferConflictAction.skip) {
            personnelMap[sourceUuid] = null;
            skipped++;
            continue;
          }
          var targetUuid = sourceUuid;
          if (exists && action == ProjectTransferConflictAction.importAsNew) {
            targetUuid = const Uuid().v4();
          }
          personnelMap[sourceUuid] = targetUuid;
          final targetRow = {...row, 'uuid': targetUuid};
          if (exists && action == ProjectTransferConflictAction.keepCurrent) {
            updated++;
          } else if (exists &&
              action == ProjectTransferConflictAction.useImported) {
            await _update('personnel', targetRow, 'uuid', targetUuid);
            updated++;
          } else {
            await _insert('personnel', targetRow);
            imported++;
          }
          final linked = await _query(
            'SELECT 1 FROM personnelList '
            'WHERE projectUuid = ? AND personnelUuid = ? LIMIT 1',
            [targetProjectUuid, targetUuid],
          );
          if (linked.isEmpty) {
            await _insert('personnelList', {
              'projectUuid': targetProjectUuid,
              'personnelUuid': targetUuid,
            });
          }
        }

        final taxonomyMap = <int, int?>{};
        final localTaxonomy = await _query('SELECT * FROM taxonomy');
        for (final row in plan.payload.rows('taxonomy')) {
          final sourceId = row['id'] as int;
          final current = _findTaxonomy(localTaxonomy, row);
          final conflict = _findConflict(plan, 'taxonomy', sourceId);
          final action = _actionFor(conflict, conflictActions);
          if (current != null && action == ProjectTransferConflictAction.skip) {
            taxonomyMap[sourceId] = null;
            skipped++;
          } else if (current != null &&
              action == ProjectTransferConflictAction.keepCurrent) {
            taxonomyMap[sourceId] = current['id'] as int;
            updated++;
          } else if (current != null &&
              action == ProjectTransferConflictAction.useImported) {
            final targetId = current['id'] as int;
            await _update(
              'taxonomy',
              {...row, 'id': targetId, 'mediaId': null},
              'id',
              targetId,
            );
            taxonomyMap[sourceId] = targetId;
            updated++;
          } else {
            taxonomyMap[sourceId] = await _insert(
              'taxonomy',
              {...row, 'mediaId': null},
              omit: {'id'},
            );
            imported++;
          }
        }

        final siteMap = <int, int?>{};
        final coordinateMap = <int, int?>{};
        final sitesUsingImportedChildren = <int>{};
        var localSites = await _projectRows(
          'site',
          projectUuid: targetProjectUuid,
        );
        for (final row in plan.payload.rows('site')) {
          final sourceId = row['id'] as int;
          final current = _findSite(localSites, row);
          final conflict = _findConflict(plan, 'site', sourceId);
          final action = _actionFor(conflict, conflictActions);
          if (current != null && action == ProjectTransferConflictAction.skip) {
            siteMap[sourceId] = null;
            skipped++;
          } else if (current != null &&
              action == ProjectTransferConflictAction.keepCurrent) {
            siteMap[sourceId] = current['id'] as int;
            updated++;
          } else if (current != null &&
              action == ProjectTransferConflictAction.useImported) {
            final targetId = current['id'] as int;
            await _update(
              'site',
              _remapPersonnel(
                {...row, 'id': targetId, 'projectUuid': targetProjectUuid},
                'leadStaffId',
                personnelMap,
              ),
              'id',
              targetId,
            );
            siteMap[sourceId] = targetId;
            sitesUsingImportedChildren.add(sourceId);
            updated++;
          } else {
            final newRow = _remapPersonnel(
              {
                ...row,
                'projectUuid': targetProjectUuid,
                if (current != null)
                  'siteID': await _uniqueSiteId(
                    row['siteID'] as String?,
                    targetProjectUuid,
                  ),
              },
              'leadStaffId',
              personnelMap,
            );
            siteMap[sourceId] = await _insert(
              'site',
              newRow,
              omit: {'id', 'mediaID'},
            );
            sitesUsingImportedChildren.add(sourceId);
            imported++;
            localSites = await _projectRows(
              'site',
              projectUuid: targetProjectUuid,
            );
          }
        }
        for (final row in plan.payload.rows('coordinate')) {
          final sourceSiteId = row['siteID'] as int?;
          final targetSiteId = siteMap[sourceSiteId];
          if (targetSiteId == null) {
            coordinateMap[row['id'] as int] = null;
            skipped++;
            continue;
          }
          if (!sitesUsingImportedChildren.contains(sourceSiteId)) {
            final currentCoordinates = await _query(
              'SELECT id FROM coordinate WHERE siteID = ? ORDER BY id',
              [targetSiteId],
            );
            coordinateMap[row['id'] as int] = currentCoordinates.isEmpty
                ? null
                : currentCoordinates.first['id'] as int;
            continue;
          }
          coordinateMap[row['id'] as int] = await _insert(
            'coordinate',
            {...row, 'siteID': targetSiteId},
            omit: {'id'},
          );
        }

        final eventMap = <int, int?>{};
        final effortMap = <int, int?>{};
        final collPersonnelMap = <int, int?>{};
        final eventsUsingImportedChildren = <int>{};
        var localEvents = await _projectRows(
          'collEvent',
          projectUuid: targetProjectUuid,
        );
        for (final row in plan.payload.rows('collEvent')) {
          final sourceId = row['id'] as int;
          final current = _findEvent(localEvents, row, siteMap);
          final conflict = _findConflict(plan, 'event', sourceId);
          final action = _actionFor(conflict, conflictActions);
          final targetSite = siteMap[row['siteID'] as int?];
          if (row['siteID'] != null && targetSite == null) {
            eventMap[sourceId] = null;
            skipped++;
          } else if (current != null &&
              action == ProjectTransferConflictAction.skip) {
            eventMap[sourceId] = null;
            skipped++;
          } else if (current != null &&
              action == ProjectTransferConflictAction.keepCurrent) {
            eventMap[sourceId] = current['id'] as int;
            updated++;
          } else if (current != null &&
              action == ProjectTransferConflictAction.useImported) {
            final targetId = current['id'] as int;
            await _update(
              'collEvent',
              {
                ...row,
                'id': targetId,
                'projectUuid': targetProjectUuid,
                'siteID': targetSite,
              },
              'id',
              targetId,
            );
            await _deleteWhere('weather', 'eventID', targetId);
            await _deleteWhere('collPersonnel', 'eventID', targetId);
            await _deleteWhere('collEffort', 'eventID', targetId);
            await _deleteWhere('eventMedia', 'eventID', targetId);
            await _deleteWhere('eventAssociatedData', 'eventID', targetId);
            eventMap[sourceId] = targetId;
            eventsUsingImportedChildren.add(sourceId);
            updated++;
          } else {
            eventMap[sourceId] = await _insert(
              'collEvent',
              {...row, 'projectUuid': targetProjectUuid, 'siteID': targetSite},
              omit: {'id'},
            );
            eventsUsingImportedChildren.add(sourceId);
            imported++;
            localEvents = await _projectRows(
              'collEvent',
              projectUuid: targetProjectUuid,
            );
          }
        }
        for (final row in plan.payload.rows('weather')) {
          final sourceEventId = row['eventID'] as int?;
          final eventId = eventMap[sourceEventId];
          if (eventId != null &&
              eventsUsingImportedChildren.contains(sourceEventId)) {
            await _insert('weather', {...row, 'eventID': eventId});
          }
        }
        for (final row in plan.payload.rows('collPersonnel')) {
          final sourceEventId = row['eventID'] as int?;
          final eventId = eventMap[sourceEventId];
          final personId = personnelMap[row['personnelId'] as String?];
          if (eventId != null &&
              !eventsUsingImportedChildren.contains(sourceEventId)) {
            final currentRows = await _query(
              'SELECT id FROM collPersonnel '
              'WHERE eventID = ? AND personnelId IS ? ORDER BY id LIMIT 1',
              [eventId, personId],
            );
            collPersonnelMap[row['id'] as int] =
                currentRows.firstOrNull?['id'] as int?;
          } else if (eventId != null &&
              (row['personnelId'] == null || personId != null)) {
            collPersonnelMap[row['id'] as int] = await _insert(
              'collPersonnel',
              {...row, 'eventID': eventId, 'personnelId': personId},
              omit: {'id'},
            );
          }
        }
        for (final row in plan.payload.rows('collEffort')) {
          final sourceEventId = row['eventID'] as int?;
          final eventId = eventMap[sourceEventId];
          if (eventId != null &&
              !eventsUsingImportedChildren.contains(sourceEventId)) {
            final currentRows = await _query(
              'SELECT id FROM collEffort '
              'WHERE eventID = ? AND method IS ? ORDER BY id LIMIT 1',
              [eventId, row['method']],
            );
            effortMap[row['id'] as int] =
                currentRows.firstOrNull?['id'] as int?;
          } else if (eventId != null) {
            effortMap[row['id'] as int] = await _insert(
              'collEffort',
              {...row, 'eventID': eventId},
              omit: {'id'},
            );
          }
        }

        final specimenMap = <String, String?>{};
        final specimensUsingImportedChildren = <String>{};
        for (final row in plan.payload.rows('specimen')) {
          final sourceUuid = row['uuid'] as String;
          final existingRows = await _query(
            'SELECT * FROM specimen WHERE uuid = ?',
            [sourceUuid],
          );
          final current = existingRows.firstOrNull;
          final conflict = _findConflict(plan, 'specimen', sourceUuid);
          final action = _actionFor(conflict, conflictActions);
          if (current != null && action == ProjectTransferConflictAction.skip) {
            specimenMap[sourceUuid] = null;
            skipped++;
            continue;
          }
          if (row['speciesID'] != null &&
              taxonomyMap[row['speciesID'] as int?] == null) {
            specimenMap[sourceUuid] = null;
            skipped++;
            continue;
          }
          if (row['collEventID'] != null &&
              eventMap[row['collEventID'] as int?] == null) {
            specimenMap[sourceUuid] = null;
            skipped++;
            continue;
          }
          var targetUuid = sourceUuid;
          if (current != null &&
              action == ProjectTransferConflictAction.importAsNew) {
            targetUuid = const Uuid().v4();
          }
          final targetRow = {
            ...row,
            'uuid': targetUuid,
            'projectUuid': targetProjectUuid,
            'speciesID': taxonomyMap[row['speciesID'] as int?],
            'collEventID': eventMap[row['collEventID'] as int?],
            'coordinateID': coordinateMap[row['coordinateID'] as int?],
            'catalogerID': personnelMap[row['catalogerID'] as String?],
            'identifierID': personnelMap[row['identifierID'] as String?],
            'preparatorID': personnelMap[row['preparatorID'] as String?],
            'collPersonnelID': collPersonnelMap[row['collPersonnelID'] as int?],
            'collMethodID': effortMap[row['collMethodID'] as int?],
            'condition': canonicalizeCondition(row['condition'] as String?),
          };
          if (current != null &&
              action == ProjectTransferConflictAction.keepCurrent) {
            specimenMap[sourceUuid] = sourceUuid;
            updated++;
          } else if (current != null &&
              action == ProjectTransferConflictAction.useImported &&
              current['projectUuid'] == targetProjectUuid) {
            await _deleteSpecimenChildren(sourceUuid);
            await _update('specimen', targetRow, 'uuid', sourceUuid);
            specimenMap[sourceUuid] = sourceUuid;
            specimensUsingImportedChildren.add(sourceUuid);
            updated++;
          } else {
            await _insert('specimen', targetRow);
            specimenMap[sourceUuid] = targetUuid;
            specimensUsingImportedChildren.add(sourceUuid);
            imported++;
          }
        }
        await _importSpecimenChildren(
          plan.payload,
          specimenMap,
          personnelMap,
          taxonomyMap,
          specimensUsingImportedChildren,
        );
        await _importAssociatedData(
          plan.payload,
          specimenMap,
          siteMap,
          eventMap,
          specimensUsingImportedChildren,
          sitesUsingImportedChildren,
          eventsUsingImportedChildren,
          targetProjectUuid,
        );

        final narrativeMap = <int, int?>{};
        final narrativesUsingImportedChildren = <int>{};
        var localNarratives = await _projectRows(
          'narrative',
          projectUuid: targetProjectUuid,
        );
        for (final row in plan.payload.rows('narrative')) {
          final sourceId = row['id'] as int;
          final current = _findNarrative(localNarratives, row, siteMap);
          final conflict = _findConflict(plan, 'narrative', sourceId);
          final action = _actionFor(conflict, conflictActions);
          final siteId = siteMap[row['siteID'] as int?];
          if (row['siteID'] != null && siteId == null) {
            narrativeMap[sourceId] = null;
            skipped++;
          } else if (current != null &&
              action == ProjectTransferConflictAction.skip) {
            narrativeMap[sourceId] = null;
            skipped++;
          } else if (current != null &&
              action == ProjectTransferConflictAction.keepCurrent) {
            narrativeMap[sourceId] = current['id'] as int;
            updated++;
          } else if (current != null &&
              action == ProjectTransferConflictAction.useImported) {
            final targetId = current['id'] as int;
            await _update(
              'narrative',
              {
                ...row,
                'id': targetId,
                'projectUuid': targetProjectUuid,
                'siteID': siteId,
                'writerId': personnelMap[row['writerId'] as String?],
                'mediaID': null,
              },
              'id',
              targetId,
            );
            await _deleteWhere('narrativeMedia', 'narrativeId', targetId);
            narrativeMap[sourceId] = targetId;
            narrativesUsingImportedChildren.add(sourceId);
            updated++;
          } else {
            narrativeMap[sourceId] = await _insert(
              'narrative',
              {
                ...row,
                'projectUuid': targetProjectUuid,
                'siteID': siteId,
                'writerId': personnelMap[row['writerId'] as String?],
                'mediaID': null,
              },
              omit: {'id'},
            );
            narrativesUsingImportedChildren.add(sourceId);
            imported++;
            localNarratives = await _projectRows(
              'narrative',
              projectUuid: targetProjectUuid,
            );
          }
        }
        final mediaMap = await _importMedia(
          plan.payload,
          extractedDirectory,
          personnelMap,
          copiedFiles,
          targetProjectUuid,
        );
        await _importMediaLinks(
          plan.payload,
          siteMap,
          eventMap,
          specimenMap,
          narrativeMap,
          mediaMap,
          sitesUsingImportedChildren,
          eventsUsingImportedChildren,
          specimensUsingImportedChildren,
          narrativesUsingImportedChildren,
        );
      });
    } catch (_) {
      for (final file in copiedFiles.reversed) {
        if (file.existsSync()) await file.delete();
      }
      rethrow;
    }
    _invalidateProjectProviders(targetProjectUuid);
    return ProjectTransferImportResult(
      imported: imported,
      updated: updated,
      skipped: skipped,
      mediaCopied: copiedFiles.length,
      warnings: plan.warnings,
    );
  }

  Future<void> _collectMedia(
    Map<String, List<Map<String, dynamic>>> records,
    List<ProjectTransferMediaFile> mediaFiles,
    List<String> warnings,
  ) async {
    final missingIds = <int>{};
    final documentRoot = await nahpuDocumentDir;
    for (final row in records['media']!) {
      final mediaId = row['primaryId'] as int;
      final fileName = row['fileName'] as String?;
      final category = row['category'] as String?;
      final projectUuid = row['projectUuid'] as String? ?? currentProjectUuid;
      if (fileName == null || category == null) {
        missingIds.add(mediaId);
        warnings.add('Media $mediaId has incomplete file information.');
        continue;
      }
      final source = File(
        path.join(documentRoot.path, projectUuid, mediaDir, category, fileName),
      );
      if (!source.existsSync()) {
        missingIds.add(mediaId);
        warnings.add('Missing media omitted: $fileName');
        continue;
      }
      final archivePath = path.posix.join(
        'media',
        '$mediaId-${_safeFileName(fileName)}',
      );
      mediaFiles.add(
        ProjectTransferMediaFile(
          sourceId: 'media:$mediaId',
          kind: category,
          archivePath: archivePath,
          originalFileName: fileName,
          sourcePath: source.path,
        ),
      );
    }
    if (missingIds.isEmpty) return;
    records['media']!.removeWhere(
      (row) => missingIds.contains(row['primaryId']),
    );
    for (final key in [
      'siteMedia',
      'eventMedia',
      'narrativeMedia',
      'specimenMedia',
    ]) {
      records[key]!.removeWhere((row) => missingIds.contains(row['mediaId']));
    }
    for (final taxon in records['taxonomy']!) {
      if (missingIds.contains(taxon['mediaId'])) taxon['mediaId'] = null;
    }
  }

  Future<void> _collectPersonnelPhotos(
    Map<String, List<Map<String, dynamic>>> records,
    List<ProjectTransferMediaFile> mediaFiles,
    List<String> warnings,
  ) async {
    records['personnelPhoto'] = <Map<String, dynamic>>[];
    final root = await nahpuDocumentDir;
    for (final person in records['personnel']!) {
      final photoPath = person['photoPath'] as String?;
      if (photoPath == null || photoPath.startsWith('assets/')) continue;
      final source = File(
        path.join(root.path, 'appMedia', 'personnel', photoPath),
      );
      if (!source.existsSync()) {
        warnings.add('Missing personnel photo omitted: $photoPath');
        person['photoPath'] = null;
        continue;
      }
      final uuid = person['uuid'] as String;
      final archivePath = path.posix.join(
        'media',
        'personnel-$uuid-${_safeFileName(photoPath)}',
      );
      records['personnelPhoto']!.add({
        'personnelUuid': uuid,
        'archivePath': archivePath,
      });
      mediaFiles.add(
        ProjectTransferMediaFile(
          sourceId: 'personnel:$uuid',
          kind: 'personnel',
          archivePath: archivePath,
          originalFileName: photoPath,
          sourcePath: source.path,
        ),
      );
    }
  }

  Future<void> _createImportedProject(
    ProjectTransferImportPlan plan,
    String destinationProjectName,
  ) async {
    if (destinationProjectName.length < 3 ||
        destinationProjectName.length > 25 ||
        !destinationProjectName.isValidProjectName) {
      throw const FormatException('Choose a valid project name.');
    }
    final uuidMatch = await findProjectUuidMatch(plan.destinationProjectUuid);
    if (uuidMatch != null) {
      throw ProjectTransferProjectExistsException(uuidMatch);
    }
    final nameMatch = await findProjectNameMatch(destinationProjectName);
    if (nameMatch != null) {
      throw FormatException(
        'A project named ${nameMatch.name} already exists. '
        'Choose a different project name.',
      );
    }
    await _insert('project', {
      ...plan.payload.project,
      'uuid': plan.destinationProjectUuid,
      'name': destinationProjectName,
    });
  }

  Future<void> _importProjectFields(
    ProjectTransferImportPlan plan,
    Map<String, bool> importedFields,
    String targetProjectUuid,
  ) async {
    const fields = [
      'name',
      'description',
      'principalInvestigator',
      'location',
      'timeZone',
      'startDate',
      'endDate',
      'accession',
      'catalogNumberPrefix',
      'currentCatalogNumber',
      'catalogNumberSuffix',
    ];
    final selected = {
      for (final field in fields)
        if (importedFields[field] == true) field: plan.payload.project[field],
    };
    if (selected.isNotEmpty) {
      await _update(
        'project',
        {...selected, 'uuid': targetProjectUuid},
        'uuid',
        targetProjectUuid,
      );
    }
  }

  Future<void> _importSpecimenChildren(
    ProjectTransferPayload payload,
    Map<String, String?> specimenMap,
    Map<String, String?> personnelMap,
    Map<int, int?> taxonomyMap,
    Set<String> specimensUsingImportedChildren,
  ) async {
    for (final table in ['mammalAttribute', 'birdAttribute', 'herpAttribute']) {
      for (final row in payload.rows(table)) {
        final sourceUuid = row['specimenUuid'] as String?;
        if (!specimensUsingImportedChildren.contains(sourceUuid)) continue;
        final uuid = specimenMap[sourceUuid];
        if (uuid != null) {
          await _insert(table, {...row, 'specimenUuid': uuid});
        }
      }
    }
    for (final row in payload.rows('specimenPart')) {
      final sourceUuid = row['specimenUuid'] as String?;
      if (!specimensUsingImportedChildren.contains(sourceUuid)) continue;
      final uuid = specimenMap[sourceUuid];
      final personnelId = personnelMap[row['personnelId'] as String?];
      if (uuid != null && (row['personnelId'] == null || personnelId != null)) {
        await _insert(
          'specimenPart',
          {...row, 'specimenUuid': uuid, 'personnelId': personnelId},
          omit: {'id'},
        );
      }
    }
    for (final row in payload.rows('parasiteDetection')) {
      final sourceUuid = row['specimenUuid'] as String?;
      if (!specimensUsingImportedChildren.contains(sourceUuid)) continue;
      final uuid = specimenMap[sourceUuid];
      if (uuid != null) {
        await _insert('parasiteDetection', {...row, 'specimenUuid': uuid});
      }
    }
    for (final row in payload.rows('parasite')) {
      final sourceUuid = row['specimenUuid'] as String?;
      if (!specimensUsingImportedChildren.contains(sourceUuid)) continue;
      final uuid = specimenMap[sourceUuid];
      final taxonId = taxonomyMap[row['speciesID'] as int?];
      final identifierId = personnelMap[row['identifierID'] as String?];
      if (uuid == null ||
          (row['speciesID'] != null && taxonId == null) ||
          (row['identifierID'] != null && identifierId == null)) {
        continue;
      }
      var parasiteUuid = row['parasiteUuid'] as String?;
      final duplicate = parasiteUuid == null
          ? const <Map<String, dynamic>>[]
          : await _query('SELECT id FROM parasite WHERE parasiteUuid = ?', [
              parasiteUuid,
            ]);
      if (parasiteUuid == null || duplicate.isNotEmpty) {
        parasiteUuid = const Uuid().v4();
      }
      await _insert(
        'parasite',
        {
          ...row,
          'specimenUuid': uuid,
          'speciesID': taxonId,
          'identifierID': identifierId,
          'parasiteUuid': parasiteUuid,
        },
        omit: {'id'},
      );
    }
  }

  Future<void> _importAssociatedData(
    ProjectTransferPayload payload,
    Map<String, String?> specimenMap,
    Map<int, int?> siteMap,
    Map<int, int?> eventMap,
    Set<String> specimensUsingImportedChildren,
    Set<int> sitesUsingImportedChildren,
    Set<int> eventsUsingImportedChildren,
    String targetProjectUuid,
  ) async {
    final specimenLinks = payload.rows('specimenAssociatedData').isEmpty
        ? payload
              .rows('associatedData')
              .where((row) => row['specimenUuid'] is String)
              .map(
                (row) => {
                  'specimenUuid': row['specimenUuid'],
                  'associatedDataId': row['primaryId'],
                },
              )
              .toList(growable: false)
        : payload.rows('specimenAssociatedData');
    final siteLinks = payload.rows('siteAssociatedData');
    final eventLinks = payload.rows('eventAssociatedData');
    final sourceDataIds = <int>{};
    for (final row in specimenLinks) {
      final sourceUuid = row['specimenUuid'] as String?;
      final sourceId = row['associatedDataId'] as int?;
      if (sourceId != null &&
          specimensUsingImportedChildren.contains(sourceUuid) &&
          specimenMap[sourceUuid] != null) {
        sourceDataIds.add(sourceId);
      }
    }
    for (final row in siteLinks) {
      final sourceSiteId = row['siteId'] as int?;
      final sourceId = row['associatedDataId'] as int?;
      if (sourceId != null &&
          sitesUsingImportedChildren.contains(sourceSiteId) &&
          siteMap[sourceSiteId] != null) {
        sourceDataIds.add(sourceId);
      }
    }
    for (final row in eventLinks) {
      final sourceEventId = row['eventID'] as int?;
      final sourceId = row['associatedDataId'] as int?;
      if (sourceId != null &&
          eventsUsingImportedChildren.contains(sourceEventId) &&
          eventMap[sourceEventId] != null) {
        sourceDataIds.add(sourceId);
      }
    }

    final dataMap = <int, int>{};
    for (final row in payload.rows('associatedData')) {
      final sourceId = row['primaryId'] as int?;
      if (sourceId == null || !sourceDataIds.contains(sourceId)) continue;
      final data = Map<String, dynamic>.from(row)
        ..remove('specimenUuid')
        ..['projectUuid'] = targetProjectUuid;
      dataMap[sourceId] = await _insert(
        'associatedData',
        data,
        omit: {'primaryId'},
      );
    }
    for (final row in specimenLinks) {
      final sourceUuid = row['specimenUuid'] as String?;
      final targetUuid = specimenMap[sourceUuid];
      final dataId = dataMap[row['associatedDataId'] as int?];
      if (targetUuid != null &&
          dataId != null &&
          specimensUsingImportedChildren.contains(sourceUuid)) {
        await _insert('specimenAssociatedData', {
          'specimenUuid': targetUuid,
          'associatedDataId': dataId,
        });
      }
    }
    for (final row in siteLinks) {
      final sourceSiteId = row['siteId'] as int?;
      final targetSiteId = siteMap[sourceSiteId];
      final dataId = dataMap[row['associatedDataId'] as int?];
      if (targetSiteId != null &&
          dataId != null &&
          sitesUsingImportedChildren.contains(sourceSiteId)) {
        await _insert('siteAssociatedData', {
          'siteId': targetSiteId,
          'associatedDataId': dataId,
        });
      }
    }
    for (final row in eventLinks) {
      final sourceEventId = row['eventID'] as int?;
      final targetEventId = eventMap[sourceEventId];
      final dataId = dataMap[row['associatedDataId'] as int?];
      if (targetEventId != null &&
          dataId != null &&
          eventsUsingImportedChildren.contains(sourceEventId)) {
        await _insert('eventAssociatedData', {
          'eventID': targetEventId,
          'associatedDataId': dataId,
        });
      }
    }
  }

  Future<Map<int, int>> _importMedia(
    ProjectTransferPayload payload,
    Directory extractedDirectory,
    Map<String, String?> personnelMap,
    List<File> copiedFiles,
    String targetProjectUuid,
  ) async {
    final mediaMap = <int, int>{};
    final manifestById = {
      for (final entry in payload.mediaFiles) entry.sourceId: entry,
    };
    final projectDir = await FileServices(
      ref: ref,
    ).getProjectDirByUUID(targetProjectUuid);
    for (final row in payload.rows('media')) {
      final sourceId = row['primaryId'] as int;
      final manifest = manifestById['media:$sourceId'];
      if (manifest == null) continue;
      final source = File(
        path.join(extractedDirectory.path, manifest.archivePath),
      );
      final category = row['category'] as String?;
      if (category == null) continue;
      final targetDir = Directory(
        path.join(projectDir.path, mediaDir, category),
      );
      await targetDir.create(recursive: true);
      final destination = File(
        _uniquePath(targetDir.path, manifest.originalFileName),
      );
      await source.copy(destination.path);
      copiedFiles.add(destination);
      final newId = await _insert(
        'media',
        {
          ...row,
          'projectUuid': targetProjectUuid,
          'personnelId': personnelMap[row['personnelId'] as String?],
          'fileName': path.basename(destination.path),
        },
        omit: {'primaryId'},
      );
      mediaMap[sourceId] = newId;
    }
    for (final photo in payload.rows('personnelPhoto')) {
      final sourceUuid = photo['personnelUuid'] as String;
      final targetUuid = personnelMap[sourceUuid];
      final manifest = manifestById['personnel:$sourceUuid'];
      if (targetUuid == null || manifest == null) continue;
      final targetDir = Directory(
        path.join((await nahpuDocumentDir).path, 'appMedia', 'personnel'),
      );
      await targetDir.create(recursive: true);
      final source = File(
        path.join(extractedDirectory.path, manifest.archivePath),
      );
      final destination = File(
        _uniquePath(targetDir.path, manifest.originalFileName),
      );
      await source.copy(destination.path);
      copiedFiles.add(destination);
      await dbAccess.customStatement(
        'UPDATE personnel SET photoPath = ? WHERE uuid = ?',
        [path.basename(destination.path), targetUuid],
      );
    }
    return mediaMap;
  }

  Future<void> _importMediaLinks(
    ProjectTransferPayload payload,
    Map<int, int?> siteMap,
    Map<int, int?> eventMap,
    Map<String, String?> specimenMap,
    Map<int, int?> narrativeMap,
    Map<int, int> mediaMap,
    Set<int> sitesUsingImportedChildren,
    Set<int> eventsUsingImportedChildren,
    Set<String> specimensUsingImportedChildren,
    Set<int> narrativesUsingImportedChildren,
  ) async {
    for (final row in payload.rows('siteMedia')) {
      final sourceSiteId = row['siteId'] as int?;
      if (!sitesUsingImportedChildren.contains(sourceSiteId)) continue;
      final siteId = siteMap[sourceSiteId];
      final mediaId = mediaMap[row['mediaId'] as int?];
      if (siteId != null && mediaId != null) {
        await _insert('siteMedia', {'siteId': siteId, 'mediaId': mediaId});
      }
    }
    for (final row in payload.rows('eventMedia')) {
      final sourceEventId = row['eventID'] as int?;
      if (!eventsUsingImportedChildren.contains(sourceEventId)) continue;
      final eventId = eventMap[sourceEventId];
      final mediaId = mediaMap[row['mediaId'] as int?];
      if (eventId != null && mediaId != null) {
        await _insert('eventMedia', {'eventID': eventId, 'mediaId': mediaId});
      }
    }
    for (final row in payload.rows('specimenMedia')) {
      final sourceSpecimenUuid = row['specimenUuid'] as String?;
      if (!specimensUsingImportedChildren.contains(sourceSpecimenUuid)) {
        continue;
      }
      final specimenUuid = specimenMap[sourceSpecimenUuid];
      final mediaId = mediaMap[row['mediaId'] as int?];
      if (specimenUuid != null && mediaId != null) {
        await _insert('specimenMedia', {
          'specimenUuid': specimenUuid,
          'mediaId': mediaId,
        });
      }
    }
    for (final row in payload.rows('narrativeMedia')) {
      final sourceNarrativeId = row['narrativeId'] as int?;
      if (!narrativesUsingImportedChildren.contains(sourceNarrativeId)) {
        continue;
      }
      final narrativeId = narrativeMap[sourceNarrativeId];
      final mediaId = mediaMap[row['mediaId'] as int?];
      if (narrativeId != null && mediaId != null) {
        await _insert('narrativeMedia', {
          'narrativeId': narrativeId,
          'mediaId': mediaId,
        });
      }
    }
  }

  Future<void> _deleteSpecimenChildren(String uuid) async {
    for (final table in [
      'mammalAttribute',
      'birdAttribute',
      'herpAttribute',
      'specimenPart',
      'parasiteDetection',
      'parasite',
      'specimenMedia',
    ]) {
      await _deleteWhere(table, 'specimenUuid', uuid);
    }
    await _deleteWhere('specimenAssociatedData', 'specimenUuid', uuid);
  }

  void _validateReferences(Map<String, List<Map<String, dynamic>>> records) {
    final siteIds = _intIds(records['site'] ?? const [], 'id').toSet();
    final eventIds = _intIds(records['collEvent'] ?? const [], 'id').toSet();
    final taxonIds = _intIds(records['taxonomy'] ?? const [], 'id').toSet();
    final specimenIds = _stringIds(
      records['specimen'] ?? const [],
      'uuid',
    ).toSet();
    for (final row in records['coordinate'] ?? const []) {
      if (!siteIds.contains(row['siteID'])) {
        throw const FormatException('A coordinate has an unresolved site.');
      }
    }
    for (final row in records['collEvent'] ?? const []) {
      if (row['siteID'] != null && !siteIds.contains(row['siteID'])) {
        throw const FormatException('An event has an unresolved site.');
      }
    }
    for (final row in records['specimen'] ?? const []) {
      if (row['fieldNumber'] != null && row['projectFieldNumber'] != null) {
        throw const FormatException(
          'A specimen cannot have both a personnel field number and a '
          'project field number.',
        );
      }
      if (row['speciesID'] != null && !taxonIds.contains(row['speciesID'])) {
        throw const FormatException('A specimen has unresolved taxonomy.');
      }
      if (row['collEventID'] != null &&
          !eventIds.contains(row['collEventID'])) {
        throw const FormatException('A specimen has an unresolved event.');
      }
    }
    for (final table in [
      'mammalAttribute',
      'birdAttribute',
      'herpAttribute',
      'specimenPart',
      'parasiteDetection',
      'parasite',
      'specimenMedia',
    ]) {
      for (final row in records[table] ?? const []) {
        if (!specimenIds.contains(row['specimenUuid'])) {
          throw FormatException('$table has an unresolved specimen.');
        }
      }
    }
    for (final row in records['parasite'] ?? const []) {
      if (row['speciesID'] != null && !taxonIds.contains(row['speciesID'])) {
        throw const FormatException('A parasite has unresolved taxonomy.');
      }
    }
    final associatedDataIds = _intIds(
      records['associatedData'] ?? const [],
      'primaryId',
    ).toSet();
    final specimenLinks = records['specimenAssociatedData'] ?? const [];
    if (specimenLinks.isEmpty) {
      for (final row in records['associatedData'] ?? const []) {
        if (row['specimenUuid'] != null &&
            !specimenIds.contains(row['specimenUuid'])) {
          throw const FormatException(
            'Associated data has an unresolved specimen.',
          );
        }
      }
    } else {
      for (final row in specimenLinks) {
        if (!specimenIds.contains(row['specimenUuid']) ||
            !associatedDataIds.contains(row['associatedDataId'])) {
          throw const FormatException(
            'Specimen associated data has an unresolved reference.',
          );
        }
      }
    }
    for (final row in records['siteAssociatedData'] ?? const []) {
      if (!siteIds.contains(row['siteId']) ||
          !associatedDataIds.contains(row['associatedDataId'])) {
        throw const FormatException(
          'Site associated data has an unresolved reference.',
        );
      }
    }
    for (final row in records['eventAssociatedData'] ?? const []) {
      if (!eventIds.contains(row['eventID']) ||
          !associatedDataIds.contains(row['associatedDataId'])) {
        throw const FormatException(
          'Event associated data has an unresolved reference.',
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _projectRows(
    String table, {
    String? projectUuid,
  }) => _query('SELECT * FROM $table WHERE projectUuid = ?', [
    projectUuid ?? currentProjectUuid,
  ]);

  Future<List<Map<String, dynamic>>> _rowsForIds(
    String table,
    String column,
    List<int> ids,
  ) {
    if (ids.isEmpty) return Future.value([]);
    return _query(
      'SELECT * FROM $table WHERE $column IN '
      '(${List.filled(ids.length, '?').join(',')})',
      ids,
    );
  }

  Future<List<Map<String, dynamic>>> _rowsForStrings(
    String table,
    String column,
    List<String> ids,
  ) {
    if (ids.isEmpty) return Future.value([]);
    return _query(
      'SELECT * FROM $table WHERE $column IN '
      '(${List.filled(ids.length, '?').join(',')})',
      ids,
    );
  }

  Future<List<Map<String, dynamic>>> _query(
    String sql, [
    List<Object?> values = const [],
  ]) async {
    final variables = values.map(_variable).toList(growable: false);
    final rows = await dbAccess.customSelect(sql, variables: variables).get();
    return rows
        .map((row) => Map<String, dynamic>.from(row.data))
        .toList(growable: false);
  }

  Variable _variable(Object? value) => switch (value) {
    int value => Variable.withInt(value),
    double value => Variable.withReal(value),
    String value => Variable.withString(value),
    bool value => Variable.withBool(value),
    _ => Variable<Object>(value),
  };

  Future<int> _insert(
    String table,
    Map<String, dynamic> row, {
    Set<String> omit = const {},
  }) async {
    final values = Map<String, dynamic>.from(row)
      ..removeWhere((key, _) => omit.contains(key));
    final columns = values.keys.toList(growable: false);
    final sql =
        'INSERT INTO $table (${columns.join(',')}) VALUES '
        '(${List.filled(columns.length, '?').join(',')})';
    await dbAccess.customStatement(
      sql,
      columns.map((column) => values[column]).toList(growable: false),
    );
    final result = await _query('SELECT last_insert_rowid() AS id');
    return result.single['id'] as int;
  }

  Future<void> _update(
    String table,
    Map<String, dynamic> row,
    String key,
    Object keyValue,
  ) async {
    final values = Map<String, dynamic>.from(row)..remove(key);
    final columns = values.keys.toList(growable: false);
    if (columns.isEmpty) return;
    await dbAccess.customStatement(
      'UPDATE $table SET '
      '${columns.map((column) => '$column = ?').join(',')} '
      'WHERE $key = ?',
      [...columns.map((column) => values[column]), keyValue],
    );
  }

  Future<void> _deleteWhere(String table, String column, Object value) =>
      dbAccess.customStatement('DELETE FROM $table WHERE $column = ?', [value]);

  Map<String, dynamic> _remapPersonnel(
    Map<String, dynamic> row,
    String column,
    Map<String, String?> personnelMap,
  ) {
    final source = row[column] as String?;
    return {...row, column: source == null ? null : personnelMap[source]};
  }

  ProjectTransferConflict? _findConflict(
    ProjectTransferImportPlan plan,
    String kind,
    Object sourceId,
  ) {
    final id = _conflictId(kind, sourceId);
    return plan.conflicts.where((item) => item.id == id).firstOrNull;
  }

  ProjectTransferConflictAction _actionFor(
    ProjectTransferConflict? conflict,
    Map<String, ProjectTransferConflictAction> actions,
  ) {
    if (conflict == null) return ProjectTransferConflictAction.importAsNew;
    final action =
        actions[conflict.id] ?? ProjectTransferConflictAction.keepCurrent;
    if (!conflict.allowedActions.contains(action)) {
      return conflict.allowedActions.first;
    }
    return action;
  }

  Map<String, dynamic>? _findTaxonomy(
    List<Map<String, dynamic>> rows,
    Map<String, dynamic> imported,
  ) {
    final key = _taxonKey(imported);
    if (key == '|') return null;
    final matches = rows.where((row) => _taxonKey(row) == key).toList();
    return matches.length == 1 ? matches.single : null;
  }

  Map<String, dynamic>? _findSite(
    List<Map<String, dynamic>> rows,
    Map<String, dynamic> imported,
  ) {
    final key = _normalize(imported['siteID']);
    if (key.isEmpty) return null;
    final matches = rows
        .where((row) => _normalize(row['siteID']) == key)
        .toList();
    return matches.length == 1 ? matches.single : null;
  }

  Map<String, dynamic>? _findEvent(
    List<Map<String, dynamic>> rows,
    Map<String, dynamic> imported,
    Map<int, int?> siteMap,
  ) {
    final sourceSite = imported['siteID'] as int?;
    final targetSite = sourceSite == null ? null : siteMap[sourceSite];
    if (sourceSite != null && targetSite == null) return null;
    final matches = rows.where((row) {
      return row['siteID'] == targetSite &&
          _normalize(row['startDate']) == _normalize(imported['startDate']) &&
          _normalize(row['startTime']) == _normalize(imported['startTime']) &&
          _normalize(row['idSuffix']) == _normalize(imported['idSuffix']);
    }).toList();
    return matches.length == 1 ? matches.single : null;
  }

  Map<String, dynamic>? _findNarrative(
    List<Map<String, dynamic>> rows,
    Map<String, dynamic> imported,
    Map<int, int?> siteMap,
  ) {
    final sourceSite = imported['siteID'] as int?;
    final targetSite = sourceSite == null ? null : siteMap[sourceSite];
    if (sourceSite != null && targetSite == null) return null;
    final matches = rows.where((row) {
      return row['siteID'] == targetSite &&
          _normalize(row['date']) == _normalize(imported['date']) &&
          _normalize(row['time']) == _normalize(imported['time']) &&
          _normalize(row['writerId']) == _normalize(imported['writerId']);
    }).toList();
    return matches.length == 1 ? matches.single : null;
  }

  Future<String> _uniqueSiteId(
    String? original,
    String targetProjectUuid,
  ) async {
    final base = (original == null || original.trim().isEmpty)
        ? 'Imported site'
        : '${original.trim()} imported';
    var candidate = base;
    var suffix = 2;
    while ((await _query(
      'SELECT 1 FROM site WHERE projectUuid = ? AND lower(siteID) = lower(?)',
      [targetProjectUuid, candidate],
    )).isNotEmpty) {
      candidate = '$base $suffix';
      suffix++;
    }
    return candidate;
  }

  String _uniquePath(String directory, String originalName) {
    final safeName = _safeFileName(originalName);
    final stem = path.basenameWithoutExtension(safeName);
    final extension = path.extension(safeName);
    var candidate = path.join(directory, safeName);
    var index = 1;
    while (File(candidate).existsSync()) {
      candidate = path.join(directory, '${stem}_$index$extension');
      index++;
    }
    return candidate;
  }

  void _invalidateProjectProviders(String targetProjectUuid) {
    ref.invalidate(projectListProvider);
    ref.invalidate(currProjInfoProvider);
    ref.invalidate(projectInfoProvider(targetProjectUuid));
    ref.invalidate(projectPersonnelProvider);
    ref.invalidate(allPersonnelProvider);
    ref.invalidate(taxonRegistryProvider);
    ref.invalidate(taxonProvider);
    ref.invalidate(siteEntryProvider);
    ref.invalidate(coordinateByProjectProvider);
    ref.invalidate(collEventEntryProvider);
    ref.invalidate(specimenEntryProvider);
    ref.invalidate(narrativeEntryProvider);
    invalidateEffectiveControlledVocabularies(ref);
  }

  static List<int> _intIds(List<Map<String, dynamic>> rows, String column) =>
      rows.map((row) => row[column]).whereType<int>().toList(growable: false);

  static List<String> _stringIds(
    List<Map<String, dynamic>> rows,
    String column,
  ) => rows
      .map((row) => row[column])
      .whereType<String>()
      .toList(growable: false);

  static void _addStringValues(
    List<Map<String, dynamic>> rows,
    String column,
    Set<String> target,
  ) {
    target.addAll(rows.map((row) => row[column]).whereType<String>());
  }

  static String _normalize(Object? value) =>
      value?.toString().trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ') ??
      '';

  static String _taxonKey(Map<String, dynamic> row) =>
      '${_normalize(row['genus'])}|${_normalize(row['specificEpithet'])}';

  static String _taxonName(Map<String, dynamic> row) =>
      '${row['genus'] ?? ''} ${row['specificEpithet'] ?? ''}'.trim();

  static String _siteName(Map<String, dynamic> row) =>
      row['siteID'] as String? ?? row['locality'] as String? ?? 'Unnamed site';

  static String _siteSummary(Map<String, dynamic> row) => [
    row['locality'],
    row['stateProvince'],
    row['country'],
  ].whereType<String>().where((value) => value.isNotEmpty).join(', ');

  static String _eventName(Map<String, dynamic> row) => [
    row['startDate'],
    row['startTime'],
    row['idSuffix'],
  ].whereType<String>().where((value) => value.isNotEmpty).join(' · ');

  static String _personSummary(Map<String, dynamic> row) => [
    row['name'],
    row['email'],
    row['affiliation'],
  ].whereType<String>().where((value) => value.isNotEmpty).join(' · ');

  static String _narrativeName(Map<String, dynamic> row) => [
    row['date'],
    row['time'],
  ].whereType<String>().where((value) => value.isNotEmpty).join(' · ');

  static String _narrativeSummary(Map<String, dynamic> row) {
    final text = row['narrative'] as String? ?? '';
    return text.length <= 100 ? text : '${text.substring(0, 100)}…';
  }

  static String _conflictId(String kind, Object sourceId) => '$kind:$sourceId';

  static String _safeFileName(String value) {
    final name = path
        .basename(value)
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
    return name.isEmpty ? 'media' : name;
  }
}
