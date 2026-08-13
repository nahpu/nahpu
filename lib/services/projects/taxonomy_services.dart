import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/taxonomy_queries.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:material_ui/material_ui.dart';

class TaxonomyServices extends AppServices {
  const TaxonomyServices({required super.ref});

  Future<TaxonomyData> getTaxonById(int id) async {
    return await TaxonomyQuery(dbAccess).getTaxonById(id);
  }

  Future<List<int>> searchTaxa(String query) async {
    List<TaxonomyData> results = await TaxonomyQuery(
      dbAccess,
    ).searchTaxon(query);
    return results.map((e) => e.id).toList();
  }

  Future<TaxonomyData?> getTaxonBySpecies(String genus, String epithet) async {
    return await TaxonomyQuery(
      dbAccess,
    ).getTaxonIdByGenusEpithet(genus, epithet);
  }

  Future<List<int>> getUsedTaxa() async {
    return await TaxonomyQuery(dbAccess).getAllUniqueTaxonInUse();
  }

  Future<List<TaxonomyData>> getTaxonList() {
    return TaxonomyQuery(dbAccess).getTaxonList();
  }

  Future<int> createTaxon(TaxonomyCompanion form) {
    return TaxonomyQuery(dbAccess).createTaxon(form);
  }

  Future<void> updateTaxonEntry(int id, TaxonomyCompanion entry) {
    return TaxonomyQuery(dbAccess).updateTaxonEntry(id, entry);
  }

  Future<void> deleteTaxonFromList(List<int> idList) async {
    for (var id in idList) {
      await deleteTaxon(id);
    }
    invalidateTaxonList();
  }

  Future<void> deleteTaxon(int id) {
    return TaxonomyQuery(dbAccess).deleteTaxon(id);
  }

  Future<void> deleteAllTaxon() {
    return TaxonomyQuery(dbAccess).deleteAllTaxon();
  }

  void invalidateTaxonList() {
    ref.invalidate(taxonRegistryProvider);
  }
}

enum TaxonRank { taxonClass, order, family, genus, species, subspecies }

extension TaxonRankDetails on TaxonRank {
  String get databaseValue => switch (this) {
    TaxonRank.taxonClass => 'class',
    _ => name,
  };

  String get label => switch (this) {
    TaxonRank.taxonClass => 'Class',
    TaxonRank.order => 'Order',
    TaxonRank.family => 'Family',
    TaxonRank.genus => 'Genus',
    TaxonRank.species => 'Species',
    TaxonRank.subspecies => 'Subspecies',
  };
}

TaxonRank? taxonRankFromString(String? value) {
  final normalized = value?.trim().toLowerCase();
  for (final rank in TaxonRank.values) {
    if (rank.databaseValue == normalized) return rank;
  }
  return null;
}

String getTaxonDisplayName(TaxonomyData data) {
  final rank = taxonRankFromString(data.taxonRank);
  final scientific = [
    data.genus,
    data.specificEpithet,
    data.subspecificEpithet,
  ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');
  return switch (rank) {
    TaxonRank.taxonClass => data.taxonClass ?? '',
    TaxonRank.order => data.taxonOrder ?? '',
    TaxonRank.family => data.taxonFamily ?? '',
    TaxonRank.genus => data.genus ?? '',
    TaxonRank.species || TaxonRank.subspecies => scientific,
    null =>
      scientific.isNotEmpty
          ? scientific
          : data.genus ??
                data.taxonFamily ??
                data.taxonOrder ??
                data.taxonClass ??
                '',
  };
}

class TaxonFilterServices {
  TaxonFilterServices();

  List<TaxonomyData> filterTaxonList(
    List<TaxonomyData> data,
    String searchValue,
  ) {
    return data
        .where((taxon) => _isTaxonMatch(taxon, searchValue.toLowerCase()))
        .toList();
  }

  bool _isTaxonMatch(TaxonomyData data, String searchValue) {
    return _getSpecies(data).contains(searchValue) ||
        _getFamily(data).contains(searchValue) ||
        _getOrder(data).contains(searchValue);
  }

  String _getSpecies(TaxonomyData taxon) {
    return getSpeciesName(taxon).toLowerCase();
  }

  String _getFamily(TaxonomyData taxon) {
    return (taxon.taxonFamily ?? '').toLowerCase();
  }

  String _getOrder(TaxonomyData taxon) {
    return (taxon.taxonOrder ?? '').toLowerCase();
  }
}

String getSpeciesName(TaxonomyData data) {
  return getTaxonDisplayName(data);
}

// String _getAxisLabel(String value) {
//   if (value.contains(' ')) {
//     return _getTaxonFirstThreeLetters(value);
//   } else {
//     if (value.length > 5) {
//       return value.substring(0, 5);
//     } else {
//       return value;
//     }
//   }
// }

String getKingdom(String? taxonClass) {
  return 'Animalia';
}

String getPhylum(String? taxonClass) {
  if (taxonClass == null || taxonClass.isEmpty) return '';
  switch (taxonClass.toLowerCase()) {
    case 'insecta':
    case 'arachnida':
    case 'chilopoda':
    case 'diplopoda':
      return 'Arthropoda';
    case 'gastropoda':
    case 'bivalvia':
    case 'cephalopoda':
      return 'Mollusca';
    default:
      return 'Chordata';
  }
}

Color matchRedListCategoryColor(String category) {
  final lowerCategory = category.toLowerCase();
  if (RegExp(r'\b(ex|extinct)\b').hasMatch(lowerCategory)) {
    return Colors.black;
  } else if (RegExp(r'\b(ew|extinct in the wild)\b').hasMatch(lowerCategory)) {
    return Colors.brown;
  } else if (RegExp(
    r'\b(cr|critically endangered)\b',
  ).hasMatch(lowerCategory)) {
    return Colors.red[900]!;
  } else if (RegExp(r'\b(en|endangered)\b').hasMatch(lowerCategory)) {
    return Colors.red;
  } else if (RegExp(r'\b(vu|vulnerable)\b').hasMatch(lowerCategory)) {
    return Colors.orange;
  } else if (RegExp(r'\b(nt|near threatened)\b').hasMatch(lowerCategory)) {
    return Colors.yellow[700]!;
  } else if (RegExp(r'\b(lc|least concern)\b').hasMatch(lowerCategory)) {
    return Colors.green;
  } else if (RegExp(r'\b(dd|data deficient)\b').hasMatch(lowerCategory)) {
    return Colors.grey;
  } else {
    return Colors.grey;
  }
}

class TaxonData {
  TaxonData({
    this.taxonClass,
    this.taxonOrder,
    this.taxonFamily,
    this.genus,
    this.specificEpithet,
  });

  String? taxonClass;
  String? taxonOrder;
  String? taxonFamily;
  String? genus;
  String? specificEpithet;

  factory TaxonData.fromTaxonomyData(TaxonomyData taxonomyData) {
    return TaxonData(
      taxonClass: taxonomyData.taxonClass,
      taxonOrder: taxonomyData.taxonOrder,
      taxonFamily: taxonomyData.taxonFamily,
      genus: taxonomyData.genus,
      specificEpithet: taxonomyData.specificEpithet,
    );
  }

  String get speciesName {
    if (genus != null && specificEpithet != null) {
      return '$genus $specificEpithet';
    } else {
      return '';
    }
  }
}
