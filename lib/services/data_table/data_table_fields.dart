import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/birds.dart';
import 'package:nahpu/services/types/invertebrates.dart';
import 'package:nahpu/services/types/mammals.dart';
import 'package:nahpu/services/types/specimens.dart';

/// How a field's stored value is typed, which decides its editor, the
/// filter operators it offers, and how input is validated.
enum DataTableValueType {
  text,
  integer,
  real,
  date,
  time,

  /// Stored as a number, shown as a label from a fixed list (sex, testis
  /// position, and so on).
  coded,
}

/// Where an edit to a field is written.
enum DataTableWriteTarget {
  specimen,

  /// The specimen's taxon attribute row (mammal, bird, and so on).
  attribute,
  part,
  site,
  siteAttribute,

  /// Shared locality rows: saved by resolving a new or matching row, never
  /// by updating one in place.
  geography,
  event,
  environment,
  narrative,
}

/// Tables a page query can join. Declared in dependency order: a join only
/// reads aliases from joins declared before it.
enum DataTableJoin {
  taxonomy,
  cataloger,
  preparator,
  event,
  site,
  geography,
  siteAttribute,
  environment,
  mammal,
  bird,
  herp,
  invertebrate,
  fossil,
  fish;

  /// Joins this one reads from.
  Set<DataTableJoin> get requires => switch (this) {
    DataTableJoin.site => {DataTableJoin.event},
    DataTableJoin.geography ||
    DataTableJoin.siteAttribute => {DataTableJoin.event, DataTableJoin.site},
    DataTableJoin.environment => {DataTableJoin.event},
    _ => const {},
  };
}

/// A taxon attribute table a `measurement::` field can live in.
class DataTableAttributeTable {
  const DataTableAttributeTable(
    this.join,
    this.table,
    this.alias,
    this.columns,
  );

  final DataTableJoin join;
  final String table;
  final String alias;

  /// Plain columns: stored as shown, so they are safe to edit and filter.
  final Map<String, DataTableValueType> columns;
}

const _real = DataTableValueType.real;
const _int = DataTableValueType.integer;
const _text = DataTableValueType.text;
const _coded = DataTableValueType.coded;

/// Fish measurements are left out on purpose: lot and individual records
/// gate which measurements apply, and lot ranges can follow the
/// individuals. Only a fish's sex and record type are editable here.
const dataTableAttributeTables = [
  DataTableAttributeTable(DataTableJoin.mammal, 'mammalAttribute', 'ma', {
    'sex': _coded,
    'testisPosition': _coded,
    'epididymisAppearance': _coded,
    'reproductiveStage': _coded,
    'mammaeCondition': _coded,
    'vaginaOpening': _coded,
    'pubicSymphysis': _coded,
    'echolocation': _coded,
    'totalLength': _real,
    'tailLength': _real,
    'hindFootLength': _real,
    'earLength': _real,
    'forearm': _real,
    'tibia': _real,
    'frequencyMax': _real,
    'frequencyMin': _real,
    'frequencyAtMaxEnergy': _real,
    'duration': _real,
    'weight': _real,
    'accuracy': _text,
    'accuracySpecify': _text,
    'lifeStage': _text,
    'testisLength': _real,
    'testisWidth': _real,
    'leftPlacentalScars': _int,
    'rightPlacentalScars': _int,
    'mammaeInguinalCount': _int,
    'mammaeAxillaryCount': _int,
    'mammaeAbdominalCount': _int,
    'embryoLeftCount': _int,
    'embryoRightCount': _int,
    'embryoCR': _int,
    'remark': _text,
  }),
  DataTableAttributeTable(DataTableJoin.bird, 'birdAttribute', 'ba', {
    'sex': _coded,
    'broodPatch': _coded,
    'skullOssification': _coded,
    'hasBursa': _coded,
    'fat': _coded,
    'ovaryAppearance': _coded,
    'oviductAppearance': _coded,
    'wingIsMolt': _coded,
    'tailIsMolt': _coded,
    'bodyMolt': _coded,
    'weight': _real,
    'wingspan': _real,
    'irisColor': _text,
    'irisHex': _text,
    'billColor': _text,
    'billHex': _text,
    'maxillaColor': _text,
    'maxillaHex': _text,
    'mandibleColor': _text,
    'mandibleHex': _text,
    'toeColor': _text,
    'toeHex': _text,
    'tarsusColor': _text,
    'tarsusHex': _text,
    'lifeStage': _text,
    'bursaWidth': _real,
    'bursaLength': _real,
    'stomachContent': _text,
    'testisLength': _real,
    'testisWidth': _real,
    'testisRemark': _text,
    'ovaryLength': _real,
    'ovaryWidth': _real,
    'oviductWidth': _real,
    'firstOvaSize': _real,
    'secondOvaSize': _real,
    'thirdOvaSize': _real,
    'ovaryRemark': _text,
    'wingMolt': _text,
    'tailMolt': _text,
    'moltRemark': _text,
    'specimenRemark': _text,
    'habitatRemark': _text,
  }),
  DataTableAttributeTable(DataTableJoin.herp, 'herpAttribute', 'ha', {
    'sex': _coded,
    'lifeStage': _text,
    'weight': _real,
    'svl': _real,
    'remark': _text,
  }),
  DataTableAttributeTable(
    DataTableJoin.invertebrate,
    'invertebrateAttribute',
    'ia',
    {
      'sex': _coded,
      'caste': _coded,
      'headWidth': _real,
      'bodyLength': _real,
      'wingspanUpper': _real,
      'wingspanLower': _real,
      'lifeStage': _text,
      'hostOrganism': _text,
      'hostPart': _text,
      'remark': _text,
    },
  ),
  DataTableAttributeTable(DataTableJoin.fossil, 'fossilAttribute', 'fa', {
    'sex': _coded,
    'fossilType': _text,
    'specimenDescription': _text,
    'ontogeneticStage': _text,
    'weight': _real,
    'weightUnit': _text,
    'remark': _text,
  }),
  DataTableAttributeTable(DataTableJoin.fish, 'fishAttribute', 'fsa', {
    'sex': _coded,
    'specimenType': _coded,
  }),
];

/// One choice of a coded field: the stored number and the label shown.
typedef DataTableCode = (int code, String label);

List<DataTableCode> _indexed(List<String> labels) => [
  for (final (index, label) in labels.indexed) (index, label),
];

const List<DataTableCode> _yesNo = [(1, 'Yes'), (0, 'No')];

/// Labels for coded columns, matching what the exports write.
final Map<String, List<DataTableCode>> dataTableCodes = {
  'sex': [
    for (final sex in allowedSpecimenSexes)
      (specimenSexCode[sex]!, specimenSexLabel[sex]!),
  ],
  'testisPosition': _indexed(testisPositionList),
  'epididymisAppearance': _indexed(epididymisAppearanceList),
  'reproductiveStage': _indexed(reproductiveStageList),
  'mammaeCondition': _indexed(mammaeConditionList),
  'vaginaOpening': _indexed(vaginaOpeningList),
  'pubicSymphysis': _indexed(pubicSymphysisList),
  'echolocation': _indexed(echolocationList),
  'broodPatch': _yesNo,
  'hasBursa': _yesNo,
  'wingIsMolt': _yesNo,
  'tailIsMolt': _yesNo,
  'skullOssification': [
    for (final value in skullOssificationList) (value, '$value'),
  ],
  'fat': _indexed(fatCategoryList),
  'ovaryAppearance': _indexed(ovaryAppearanceList),
  'oviductAppearance': _indexed(oviductAppearanceList),
  'bodyMolt': _indexed(bodyMoltList),
  'caste': _indexed(invertebrateCasteList),
  'specimenType': [
    for (final type in FishSpecimenType.values) (type.index, type.name),
  ],
};

/// Columns cleared when a sex change drops male or female attributes,
/// matching what the record forms clear.
const dataTableSexClearedColumns = {
  'mammalAttribute': (
    male: [
      'testisPosition',
      'testisLength',
      'testisWidth',
      'epididymisAppearance',
    ],
    female: [
      'vaginaOpening',
      'pubicSymphysis',
      'reproductiveStage',
      'mammaeAxillaryCount',
      'mammaeAbdominalCount',
      'mammaeInguinalCount',
      'mammaeCondition',
      'embryoLeftCount',
      'embryoRightCount',
      'embryoCR',
      'leftPlacentalScars',
      'rightPlacentalScars',
    ],
  ),
  'birdAttribute': (
    male: ['testisLength', 'testisWidth', 'testisRemark'],
    female: [
      'ovaryLength',
      'ovaryWidth',
      'ovaryAppearance',
      'firstOvaSize',
      'secondOvaSize',
      'thirdOvaSize',
      'oviductWidth',
      'oviductAppearance',
      'ovaryRemark',
    ],
  ),
};

/// One export header key, as the data table understands it.
///
/// [sqlExpr] and [sortExprs] are fixed fragments over the page query's table
/// aliases. They are never built from user input; values always travel as
/// bound variables.
class DataTableField {
  const DataTableField({
    required this.key,
    this.sqlExpr,
    this.sortExprs = const [],
    this.joins = const {},
    this.valueType = DataTableValueType.text,
    this.writeTarget,
    this.column,
    this.optionKey,
    this.attributeTables = const [],
  });

  final String key;
  final String? sqlExpr;

  /// Ordering terms for a field that sorts but can't be searched, such as an
  /// event ID built from its parts.
  final List<String> sortExprs;
  final Set<DataTableJoin> joins;
  final DataTableValueType valueType;
  final DataTableWriteTarget? writeTarget;

  /// Database column an edit writes.
  final String? column;

  /// Controlled vocabulary offered while editing, by preference key.
  final String? optionKey;

  /// For `measurement::` fields: every attribute table that has [column].
  final List<DataTableAttributeTable> attributeTables;

  /// Choices of a coded field.
  List<DataTableCode> get codes => valueType == DataTableValueType.coded
      ? dataTableCodes[column] ?? const []
      : const [];

  /// The label for a stored code, or the text unchanged when it isn't one.
  String labelFor(String raw) {
    final code = int.tryParse(raw.trim());
    for (final (value, label) in codes) {
      if (value == code) return label;
    }
    return raw;
  }

  /// The code for typed or pasted text: a label (or the start of exactly
  /// one), or the code itself. Null when nothing matches.
  int? codeForInput(String text) {
    final input = text.trim().toLowerCase();
    if (input.isEmpty) return null;
    for (final (code, label) in codes) {
      if (label.toLowerCase() == input || '$code' == input) return code;
    }
    final starts = [
      for (final (code, label) in codes)
        if (label.toLowerCase().startsWith(input)) code,
    ];
    return starts.length == 1 ? starts.single : null;
  }

  /// What search and sort compare: labels for coded fields, so "male"
  /// finds males rather than the digit 0.
  String? get displayExpr {
    if (sqlExpr == null || valueType != DataTableValueType.coded) {
      return sqlExpr;
    }
    final cases = [
      for (final (code, label) in codes)
        "WHEN $code THEN '${label.replaceAll("'", "''")}'",
    ];
    return '(CASE $sqlExpr ${cases.join(' ')} END)';
  }

  /// Searchable and filterable in SQL.
  bool get isFilterable => sqlExpr != null;
  bool get isSortable => sqlExpr != null || sortExprs.isNotEmpty;

  /// Derived during export, such as coordinates or media lists.
  bool get isComputed => !isSortable;

  List<String> get orderTerms => sortExprs.isEmpty ? [displayExpr!] : sortExprs;
}

/// The catalog entry for [key]. Keys the catalog doesn't know are computed:
/// shown, but never filtered, sorted, or edited.
DataTableField dataTableField(String key) =>
    _catalog[key] ?? DataTableField(key: key);

final Map<String, DataTableField> _catalog = {
  for (final field in [
    ..._specimenFields,
    ..._partFields,
    ..._siteFields,
    ..._eventFields,
    ..._environmentFields,
    ..._narrativeFields,
    ..._measurementFields(),
  ])
    field.key: field,
};

const _specimenFields = [
  DataTableField(key: 'specimen::specimenUUID', sqlExpr: 's.uuid'),
  DataTableField(
    key: 'specimen::cataloger',
    sqlExpr: 'cat.name',
    joins: {DataTableJoin.cataloger},
  ),
  DataTableField(
    key: 'specimen::fieldNumber',
    sqlExpr: 's.fieldNumber',
    valueType: DataTableValueType.integer,
  ),
  DataTableField(
    key: 'specimen::preparator',
    sqlExpr: 'prep.name',
    joins: {DataTableJoin.preparator},
  ),
  DataTableField(
    key: 'specimen::order',
    sqlExpr: 'tx.taxonOrder',
    joins: {DataTableJoin.taxonomy},
  ),
  DataTableField(
    key: 'specimen::family',
    sqlExpr: 'tx.taxonFamily',
    joins: {DataTableJoin.taxonomy},
  ),
  DataTableField(
    key: 'specimen::genus',
    sqlExpr: 'tx.genus',
    joins: {DataTableJoin.taxonomy},
  ),
  DataTableField(
    key: 'specimen::specificEpithet',
    sqlExpr: 'tx.specificEpithet',
    joins: {DataTableJoin.taxonomy},
  ),
  DataTableField(
    key: 'specimen::condition',
    sqlExpr: 's.condition',
    writeTarget: DataTableWriteTarget.specimen,
    column: 'condition',
    optionKey: conditionPrefKey,
  ),
  DataTableField(
    key: 'specimen::iDConfidence',
    sqlExpr: 's.iDConfidence',
    valueType: DataTableValueType.integer,
    writeTarget: DataTableWriteTarget.specimen,
    column: 'iDConfidence',
  ),
  DataTableField(
    key: 'specimen::iDMethod',
    sqlExpr: 's.iDMethod',
    writeTarget: DataTableWriteTarget.specimen,
    column: 'iDMethod',
    optionKey: idMethodPrefKey,
  ),
  DataTableField(
    key: 'specimen::collectionTime',
    sqlExpr: 's.collectionTime',
    valueType: DataTableValueType.time,
    writeTarget: DataTableWriteTarget.specimen,
    column: 'collectionTime',
  ),
  DataTableField(
    key: 'specimen::preparationDate',
    sqlExpr: 's.prepDate',
    valueType: DataTableValueType.date,
    writeTarget: DataTableWriteTarget.specimen,
    column: 'prepDate',
  ),
  DataTableField(
    key: 'specimen::preparationTime',
    sqlExpr: 's.prepTime',
    valueType: DataTableValueType.time,
    writeTarget: DataTableWriteTarget.specimen,
    column: 'prepTime',
  ),
];

DataTableField _part(
  String name, {
  DataTableValueType type = DataTableValueType.text,
  String? optionKey,
}) => DataTableField(
  key: 'part::$name',
  sqlExpr: 'p.$name',
  valueType: type,
  writeTarget: DataTableWriteTarget.part,
  column: name,
  optionKey: optionKey,
);

final _partFields = [
  _part('tissueID'),
  _part('barcodeID'),
  _part('type', optionKey: specimenTypePrefKey),
  _part('count'),
  _part('treatment', optionKey: treatmentPrefKey),
  _part('additionalTreatment'),
  _part('dateTaken', type: DataTableValueType.date),
  _part('timeTaken', type: DataTableValueType.time),
  _part('museumPermanent'),
  _part('museumLoan'),
  _part('remark'),
];

DataTableField _geography(String key, String column) => DataTableField(
  key: 'geography::$key',
  sqlExpr: 'g.$column',
  joins: {DataTableJoin.geography},
  writeTarget: DataTableWriteTarget.geography,
  column: column,
);

DataTableField _habitat(String name, {String? optionKey}) => DataTableField(
  key: 'siteAttribute::$name',
  sqlExpr: 'sa.$name',
  joins: {DataTableJoin.siteAttribute},
  writeTarget: DataTableWriteTarget.siteAttribute,
  column: name,
  optionKey: optionKey,
);

final _siteFields = [
  // The site ID is the identity events are named after, so it is only
  // renamed from the site form.
  const DataTableField(
    key: 'site::site',
    sqlExpr: 'st.siteID',
    joins: {DataTableJoin.site},
  ),
  _habitat('habitatType', optionKey: habitatTypePrefKey),
  _habitat('habitatCondition'),
  _habitat('habitatDescription'),
  _habitat('canopyCover'),
  _geography('country', 'country'),
  _geography('islandGroup', 'islandGroup'),
  _geography('stateProvince', 'stateProvince'),
  _geography('county', 'county'),
  _geography('municipality', 'municipality'),
  _geography('specificLocality', 'locality'),
  const DataTableField(
    key: 'site::siteNotes',
    sqlExpr: 'st.remark',
    joins: {DataTableJoin.site},
    writeTarget: DataTableWriteTarget.site,
    column: 'remark',
  ),
];

DataTableField _event(
  String key,
  String column, {
  DataTableValueType type = DataTableValueType.text,
  String? optionKey,
}) => DataTableField(
  key: 'event::$key',
  sqlExpr: 'ce.$column',
  joins: {DataTableJoin.event},
  valueType: type,
  writeTarget: DataTableWriteTarget.event,
  column: column,
  optionKey: optionKey,
);

final _eventFields = [
  const DataTableField(
    key: 'event::collEventID',
    sortExprs: ['st.siteID', 'ce.startDate', 'ce.idSuffix'],
    joins: {DataTableJoin.event, DataTableJoin.site},
  ),
  _event('Activity', 'primaryCollMethod', optionKey: collActivityPrefKey),
  _event('startDate', 'startDate', type: DataTableValueType.date),
  _event('endDate', 'endDate', type: DataTableValueType.date),
  _event('startTime', 'startTime', type: DataTableValueType.time),
  _event('endTime', 'endTime', type: DataTableValueType.time),
];

const _environmentTypes = {
  'lowestDayTempC': _real,
  'highestDayTempC': _real,
  'lowestNightTempC': _real,
  'highestNightTempC': _real,
  'averageHumidity': _real,
  'dewPointTemp': _real,
  'sunriseTime': DataTableValueType.time,
  'sunsetTime': DataTableValueType.time,
  'moonPhase': _text,
  'cloudCover': _text,
  'rainfallInMm': _real,
  'ambientTemperature': _real,
  'ambientHumidity': _real,
  'waterTemperature': _real,
  'pH': _real,
  'dissolvedOxygen': _real,
  'flowVelocity': _real,
  'notes': _text,
  'conductivity': _real,
  'dissolvedOxygenPercent': _real,
};

final _environmentFields = [
  for (final entry in _environmentTypes.entries)
    DataTableField(
      key: 'environment::${entry.key}',
      sqlExpr: 'env.${entry.key}',
      joins: {DataTableJoin.environment},
      valueType: entry.value,
      writeTarget: DataTableWriteTarget.environment,
      column: entry.key,
    ),
];

const _narrativeFields = [
  DataTableField(
    key: 'narrative::date',
    sqlExpr: 'n.date',
    valueType: DataTableValueType.date,
    writeTarget: DataTableWriteTarget.narrative,
    column: 'date',
  ),
  DataTableField(
    key: 'narrative::narrative',
    sqlExpr: 'n.narrative',
    writeTarget: DataTableWriteTarget.narrative,
    column: 'narrative',
  ),
];

/// `measurement::` keys are shared by every taxon's attribute table. A
/// specimen has one attribute row, so the first non-null value is its own.
List<DataTableField> _measurementFields() {
  final columns = <String, List<DataTableAttributeTable>>{};
  for (final table in dataTableAttributeTables) {
    for (final column in table.columns.keys) {
      columns.putIfAbsent(column, () => []).add(table);
    }
  }
  return [
    for (final entry in columns.entries)
      DataTableField(
        key: 'measurement::${entry.key}',
        sqlExpr: entry.value.length == 1
            ? '${entry.value.single.alias}.${entry.key}'
            : 'COALESCE(${entry.value.map((t) => '${t.alias}.${entry.key}').join(', ')})',
        joins: {for (final table in entry.value) table.join},
        valueType: entry.value.first.columns[entry.key]!,
        writeTarget: DataTableWriteTarget.attribute,
        column: entry.key,
        optionKey: entry.key == 'lifeStage' ? lifeStagePrefKey : null,
        attributeTables: entry.value,
      ),
  ];
}
