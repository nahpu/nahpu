import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/symbiont_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';

/// The table a curated tube comes from.
enum TissueItemKind { part, symbiont }

/// A tube the curation tool can box: a specimen part or a symbiont, with the
/// specimen it belongs to.
class TissueItemRecord {
  TissueItemRecord.part(SpecimenPartProjectRecord record)
    : kind = TissueItemKind.part,
      part = record.part,
      symbiont = null,
      specimen = record.specimen;

  TissueItemRecord.symbiont(SymbiontProjectRecord record)
    : kind = TissueItemKind.symbiont,
      part = null,
      symbiont = record.symbiont,
      specimen = record.specimen;

  final TissueItemKind kind;

  /// Set when [kind] is [TissueItemKind.part].
  final SpecimenPartData? part;

  /// Set when [kind] is [TissueItemKind.symbiont].
  final SymbiontData? symbiont;
  final SpecimenData specimen;

  bool get isSymbiont => kind == TissueItemKind.symbiont;

  /// Set when [kind] is [TissueItemKind.part], for part export lookups.
  SpecimenPartProjectRecord? get partRecord => part == null
      ? null
      : SpecimenPartProjectRecord(part: part!, specimen: specimen);

  /// Set when [kind] is [TissueItemKind.symbiont].
  SymbiontProjectRecord? get symbiontRecord => symbiont == null
      ? null
      : SymbiontProjectRecord(symbiont: symbiont!, specimen: specimen);

  /// The database id within its table.
  int get id => (part?.id ?? symbiont?.id)!;

  /// Identifies the tube across both tables.
  (TissueItemKind, int) get key => (kind, id);

  /// The tissue ID of a part, or the symbiont ID of a symbiont.
  String? get code => part?.tissueID ?? symbiont?.symbiontID;

  String? get barcode => part?.barcodeID;

  /// The part type, such as Liver. Symbionts have none.
  String? get type => part?.type;

  /// The symbiont category, such as Ectoparasite. Parts have none.
  String? get category => symbiont?.category;

  String? get treatment => part?.treatment ?? symbiont?.treatment;

  String? get count => part?.count ?? symbiont?.count?.toString();

  String? get storageLocation =>
      part?.storageLocation ?? symbiont?.storageLocation;

  String? readField(TissueCheckField field) {
    return switch (field) {
      TissueCheckField.museumPermanent =>
        part?.museumPermanent ?? symbiont?.museumPermanent,
      TissueCheckField.museumLoan => part?.museumLoan ?? symbiont?.museumLoan,
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
