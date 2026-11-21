part of 'database.dart';

/// Schema changes a release step leaves behind, written as `table.column`, or
/// `table.` for the table itself.
class _StepFootprint {
  const _StepFootprint({
    this.added = const [],
    this.removed = const [],
    this.rerunnable = false,
  });

  /// Entities the step creates. None exist in any earlier schema, and all of
  /// them survive to the current one.
  final List<String> added;

  /// Entities the step removes for good.
  final List<String> removed;

  /// Whether the step can run again over its own finished work.
  ///
  /// For these, any one `added` entity shows that the step started, and it is
  /// run again. The others are only skipped once every `added` entity is in
  /// place and every `removed` one is gone.
  final bool rerunnable;
}

/// Finds where to resume an upgrade that an earlier release left unfinished.
///
/// Releases up to v1.3.0 ran the steps without a transaction, so an attempt
/// that failed partway kept the changes of the steps it finished while
/// `user_version` stayed at the starting version. Rerunning from there fails,
/// because most steps cannot run over the schema later steps produce.
class _PartialAttemptDetector {
  const _PartialAttemptDetector(this.db);

  final Database db;

  /// Footprints of the steps from v12, keyed by the version each produces.
  ///
  /// Derived from the generated schemas; the migration tests check every
  /// version against them. Steps up to v11 are left out: the v11 schema adds
  /// nothing that survives unchanged, and the v12 footprint already marks any
  /// attempt that got past it.
  static const Map<int, _StepFootprint> _footprints = {
    12: _StepFootprint(
      added: [
        'associatedData.projectUuid',
        'customFieldDefinition.',
        'customFieldValue.',
        'fossilAttribute.',
        'siteAssociatedData.',
        'specimenAssociatedData.',
        'specimenPart.storage',
        'taxonomy.subspecificEpithet',
        'taxonomy.taxonRank',
      ],
    ),
    13: _StepFootprint(
      added: [
        'associatedData.uri',
        'customFieldValue.unit',
        'fossilSite.',
        'media.uri',
      ],
      removed: [
        'associatedData.specimenUuid',
        'associatedData.url',
        'paleontologySite.',
      ],
    ),
    14: _StepFootprint(
      added: [
        'birdAttribute.mandibleColor',
        'birdAttribute.mandibleHex',
        'birdAttribute.maxillaColor',
        'birdAttribute.maxillaHex',
        'birdAttribute.toeColor',
        'birdAttribute.toeHex',
      ],
      removed: ['birdAttribute.footColor', 'birdAttribute.footHex'],
    ),
    15: _StepFootprint(
      added: [
        'eventAssociatedData.',
        'eventMedia.',
        'project.accession',
        'project.catalogNumberPrefix',
        'project.catalogNumberSuffix',
        'taxonomy.kingdom',
        'taxonomy.phylum',
      ],
      removed: ['parasiteDetection.parasiteRemark'],
    ),
    16: _StepFootprint(
      added: ['project.currentCatalogNumber', 'specimenPart.storageLocation'],
      rerunnable: true,
    ),
    17: _StepFootprint(
      added: [
        'coordinate.verbatimCoordinates',
        'coordinate.verbatimCoordinateSystem',
        'birdAttribute.weightUnit',
      ],
      rerunnable: true,
    ),
    18: _StepFootprint(
      added: [
        'customFieldDefinition.catalogFormat',
        'customFieldDefinition.dwcField',
      ],
      rerunnable: true,
    ),
    19: _StepFootprint(
      added: [
        'birdAttribute.lifeStage',
        'environment.',
        'fossilAttribute.ontogeneticStage',
        'fossilAttribute.remark',
        'fossilAttribute.sex',
        'fossilAttribute.weight',
        'fossilAttribute.weightUnit',
        'herpAttribute.lifeStage',
        'mammalAttribute.lifeStage',
        'siteAttribute.',
      ],
      removed: [
        'arthropodAttribute.ambientHumidity',
        'arthropodAttribute.ambientTemperature',
        'arthropodAttribute.canopyAffinity',
        'arthropodAttribute.canopyCover',
        'arthropodAttribute.dissolvedOxygen',
        'arthropodAttribute.flowVelocity',
        'arthropodAttribute.pH',
        'arthropodAttribute.waterTemperature',
        'herpAttribute.age',
        'mammalAttribute.age',
        'site.habitatCondition',
        'site.habitatDescription',
        'site.habitatType',
        'weather.',
      ],
    ),
    20: _StepFootprint(added: ['customFieldValue.eventId'], rerunnable: true),
    21: _StepFootprint(
      added: ['geography.', 'site.geographyId'],
      removed: [
        'site.country',
        'site.county',
        'site.islandGroup',
        'site.locality',
        'site.municipality',
        'site.stateProvince',
      ],
    ),
    22: _StepFootprint(added: ['invertebrateAttribute.'], rerunnable: true),
    23: _StepFootprint(
      added: ['environment.conductivity', 'fishAttribute.'],
      rerunnable: true,
    ),
    24: _StepFootprint(added: ['collMethod.'], rerunnable: true),
    // v26 renames `parasite`, so either name marks the v25 columns.
    25: _StepFootprint(
      added: ['parasite.collectorID', 'symbiont.collectorID'],
      rerunnable: true,
    ),
    26: _StepFootprint(
      added: ['symbiont.', 'customFieldValue.symbiontId'],
      rerunnable: true,
    ),
  };

  /// Returns the version to run the steps from: [from] for a file no attempt
  /// has touched, or a later one when an earlier attempt got further.
  Future<int> resumeVersion(int from, int to) async {
    final schema = await _schema();
    for (var version = to; version > from; version--) {
      final footprint = _footprints[version];
      if (footprint == null) continue;
      if (footprint.rerunnable) {
        if (footprint.added.any(schema.contains)) return version - 1;
      } else if (footprint.added.every(schema.contains) &&
          !footprint.removed.any(schema.contains)) {
        return version;
      }
    }
    return from;
  }

  /// Every table as `table.` and every column as `table.column`.
  Future<Set<String>> _schema() async {
    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%'",
          readsFrom: const {},
        )
        .get();
    final schema = <String>{};
    for (final table in tables) {
      final name = table.read<String>('name');
      schema.add('$name.');
      final columns = await db
          .customSelect('PRAGMA table_info("$name")', readsFrom: const {})
          .get();
      for (final column in columns) {
        schema.add('$name.${column.read<String>('name')}');
      }
    }
    return schema;
  }
}
