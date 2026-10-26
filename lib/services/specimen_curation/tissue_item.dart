import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/parasite_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';

/// The table a curated tube comes from.
enum TissueItemKind { part, parasite }

/// A tube the curation tool can box: a specimen part or a parasite, with the
/// specimen it belongs to.
class TissueItemRecord {
  TissueItemRecord.part(SpecimenPartProjectRecord record)
    : kind = TissueItemKind.part,
      part = record.part,
      parasite = null,
      specimen = record.specimen;

  TissueItemRecord.parasite(ParasiteProjectRecord record)
    : kind = TissueItemKind.parasite,
      part = null,
      parasite = record.parasite,
      specimen = record.specimen;

  final TissueItemKind kind;

  /// Set when [kind] is [TissueItemKind.part].
  final SpecimenPartData? part;

  /// Set when [kind] is [TissueItemKind.parasite].
  final ParasiteData? parasite;
  final SpecimenData specimen;

  bool get isParasite => kind == TissueItemKind.parasite;

  /// Set when [kind] is [TissueItemKind.part], for part export lookups.
  SpecimenPartProjectRecord? get partRecord => part == null
      ? null
      : SpecimenPartProjectRecord(part: part!, specimen: specimen);

  /// Set when [kind] is [TissueItemKind.parasite].
  ParasiteProjectRecord? get parasiteRecord => parasite == null
      ? null
      : ParasiteProjectRecord(parasite: parasite!, specimen: specimen);

  /// The database id within its table.
  int get id => (part?.id ?? parasite?.id)!;

  /// Identifies the tube across both tables.
  (TissueItemKind, int) get key => (kind, id);

  /// The tissue ID of a part, or the parasite ID of a parasite.
  String? get code => part?.tissueID ?? parasite?.parasiteID;

  String? get barcode => part?.barcodeID;

  /// The part type, such as Liver. Parasites have none.
  String? get type => part?.type;

  /// The parasite category, such as Ectoparasite. Parts have none.
  String? get category => parasite?.category;

  String? get treatment => part?.treatment ?? parasite?.treatment;

  String? get count => part?.count ?? parasite?.count?.toString();

  String? get storageLocation =>
      part?.storageLocation ?? parasite?.storageLocation;

  String? readField(TissueCheckField field) {
    return switch (field) {
      TissueCheckField.museumPermanent =>
        part?.museumPermanent ?? parasite?.museumPermanent,
      TissueCheckField.museumLoan => part?.museumLoan ?? parasite?.museumLoan,
    };
  }
}

/// The indexes of [records] whose [textFor] contains every word of [query],
/// ignoring case. An empty query matches nothing.
List<int> searchTissueItems(
  List<TissueItemRecord> records,
  String query,
  String Function(TissueItemRecord record) textFor,
) {
  final words = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();
  if (words.isEmpty) return const [];
  return [
    for (final (index, record) in records.indexed)
      if (words.every(textFor(record).toLowerCase().contains)) index,
  ];
}
