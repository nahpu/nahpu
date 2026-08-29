import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/database/database.dart';

/// Separator for [GeographyDraft.matchKey] parts.
///
/// The ASCII unit separator cannot occur in typed locality text, so joined
/// fields can never collide across boundaries.
const String _kMatchKeySeparator = '\u001F';

final RegExp _whitespace = RegExp(r'\s+');

/// Normalizes one geography value for deduplication.
///
/// Trims, collapses internal whitespace, and lowercases. Dart's
/// [String.toLowerCase] folds Unicode, unlike SQLite's `lower()` and
/// `COLLATE NOCASE`, which only fold ASCII. Locality names carry diacritics, so
/// the folding has to happen here rather than in SQL.
String normalizeGeographyValue(String? value) {
  if (value == null) return '';
  return value.trim().replaceAll(_whitespace, ' ').toLowerCase();
}

/// Trims a geography value for storage without altering its casing.
String? cleanGeographyValue(String? value) {
  if (value == null) return null;
  final cleaned = value.trim().replaceAll(_whitespace, ' ');
  return cleaned.isEmpty ? null : cleaned;
}

/// The six locality fields that make up one shared geography record.
///
/// Use this to look up or create a `geography` row. [matchKey] is the
/// deduplication key stored on the row.
class GeographyDraft {
  const GeographyDraft({
    this.country,
    this.islandGroup,
    this.stateProvince,
    this.county,
    this.municipality,
    this.locality,
  });

  factory GeographyDraft.fromData(GeographyData data) => GeographyDraft(
    country: data.country,
    islandGroup: data.islandGroup,
    stateProvince: data.stateProvince,
    county: data.county,
    municipality: data.municipality,
    locality: data.locality,
  );

  /// Reads a draft from a record-exchange or project-transfer row.
  ///
  /// Accepts the flat site payload written before geography moved into its own
  /// table, so older QR codes and exported records still import.
  factory GeographyDraft.fromJson(Map<String, dynamic> json) {
    String? read(String key) {
      final value = json[key];
      if (value == null) return null;
      return value is String ? value : value.toString();
    }

    return GeographyDraft(
      country: read('country'),
      islandGroup: read('islandGroup'),
      stateProvince: read('stateProvince'),
      county: read('county'),
      municipality: read('municipality'),
      locality: read('locality') ?? read('specificLocality'),
    );
  }

  final String? country;
  final String? islandGroup;
  final String? stateProvince;
  final String? county;
  final String? municipality;
  final String? locality;

  /// The fields in hierarchy order, broadest first.
  List<String?> get values => [
    country,
    islandGroup,
    stateProvince,
    county,
    municipality,
    locality,
  ];

  /// True when no field carries text, so the site needs no geography row.
  bool get isEmpty =>
      values.every((value) => normalizeGeographyValue(value).isEmpty);

  bool get isNotEmpty => !isEmpty;

  /// The deduplication key: every field normalized and joined in a fixed order.
  String get matchKey =>
      values.map(normalizeGeographyValue).join(_kMatchKeySeparator);

  /// A human-readable summary, broadest field first.
  String get displayName =>
      values.map(cleanGeographyValue).whereType<String>().join(', ');

  GeographyDraft copyWith({
    String? country,
    String? islandGroup,
    String? stateProvince,
    String? county,
    String? municipality,
    String? locality,
  }) => GeographyDraft(
    country: country ?? this.country,
    islandGroup: islandGroup ?? this.islandGroup,
    stateProvince: stateProvince ?? this.stateProvince,
    county: county ?? this.county,
    municipality: municipality ?? this.municipality,
    locality: locality ?? this.locality,
  );

  GeographyCompanion toCompanion() => GeographyCompanion(
    country: db.Value(cleanGeographyValue(country)),
    islandGroup: db.Value(cleanGeographyValue(islandGroup)),
    stateProvince: db.Value(cleanGeographyValue(stateProvince)),
    county: db.Value(cleanGeographyValue(county)),
    municipality: db.Value(cleanGeographyValue(municipality)),
    locality: db.Value(cleanGeographyValue(locality)),
    matchKey: db.Value(matchKey),
  );

  /// The flat form used by record exchange and document field values.
  Map<String, dynamic> toJson() => {
    'country': country,
    'islandGroup': islandGroup,
    'stateProvince': stateProvince,
    'county': county,
    'municipality': municipality,
    'locality': locality,
  };

  @override
  bool operator ==(Object other) =>
      other is GeographyDraft && other.matchKey == matchKey;

  @override
  int get hashCode => matchKey.hashCode;
}

/// A site joined with its shared geography row.
///
/// Geography getters read through to [geography] so callers that used to read
/// the columns off `SiteData` keep the same shape.
class SiteRecord {
  const SiteRecord({required this.site, this.geography});

  final SiteData site;
  final GeographyData? geography;

  int get id => site.id;
  String? get siteID => site.siteID;
  String? get projectUuid => site.projectUuid;
  String? get leadStaffId => site.leadStaffId;
  String? get siteType => site.siteType;
  String? get mediaID => site.mediaID;
  String? get remark => site.remark;
  int? get geographyId => site.geographyId;

  String? get country => geography?.country;
  String? get islandGroup => geography?.islandGroup;
  String? get stateProvince => geography?.stateProvince;
  String? get county => geography?.county;
  String? get municipality => geography?.municipality;
  String? get locality => geography?.locality;

  GeographyDraft get draft => geography == null
      ? const GeographyDraft()
      : GeographyDraft.fromData(geography!);

  SiteRecord copyWith({SiteData? site, GeographyData? geography}) => SiteRecord(
    site: site ?? this.site,
    geography: geography ?? this.geography,
  );
}
