import 'dart:convert';

import 'package:nahpu/services/database/database.dart';

/// Builds a compact, portable QR payload for a registered taxon.
class TaxonExchangeService {
  const TaxonExchangeService();

  static String encodeQr(TaxonomyData taxon) {
    return jsonEncode({
      'nahpu_taxon': 1,
      'taxon': {
        'taxonRank': taxon.taxonRank,
        'kingdom': taxon.kingdom,
        'phylum': taxon.phylum,
        'taxonClass': taxon.taxonClass,
        'taxonOrder': taxon.taxonOrder,
        'taxonFamily': taxon.taxonFamily,
        'genus': taxon.genus,
        'specificEpithet': taxon.specificEpithet,
        'subspecificEpithet': taxon.subspecificEpithet,
        'authors': taxon.authors,
        'commonName': taxon.commonName,
        'citesStatus': taxon.citesStatus,
        'redListCategory': taxon.redListCategory,
        'countryStatus': taxon.countryStatus,
      },
    });
  }
}
