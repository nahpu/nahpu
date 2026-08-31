import 'dart:convert';

import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/taxon_entry.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';

/// Encodes and validates portable QR payloads for registered taxa.
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

  static TaxonEntryData decodeQr(String payload) {
    final Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException {
      throw const FormatException('Not a valid NAHPU taxon QR code.');
    }
    if (decoded is! Map ||
        decoded['nahpu_taxon'] is! int ||
        decoded['nahpu_taxon'] != 1) {
      throw const FormatException('Not a supported NAHPU taxon QR code.');
    }
    final values = decoded['taxon'];
    if (values is! Map) {
      throw const FormatException('The QR code has no taxon data.');
    }
    return validateQrData(
      TaxonEntryData(
        taxonRank: _text(values, 'taxonRank'),
        kingdom: _text(values, 'kingdom'),
        phylum: _text(values, 'phylum'),
        taxonClass: _text(values, 'taxonClass') ?? '',
        taxonOrder: _text(values, 'taxonOrder') ?? '',
        taxonFamily: _text(values, 'taxonFamily') ?? '',
        genus: _text(values, 'genus') ?? '',
        specificEpithet: _text(values, 'specificEpithet') ?? '',
        subspecificEpithet: _text(values, 'subspecificEpithet') ?? '',
        authors: _text(values, 'authors'),
        commonName: _text(values, 'commonName'),
        citesStatus: _text(values, 'citesStatus'),
        redListCategory: _text(values, 'redListCategory'),
        countryStatus: _text(values, 'countryStatus'),
      ),
    );
  }

  /// QR records follow manual registration rules, not spreadsheet rules.
  /// Return a snapshot, preserving supplied classification and metadata.
  static TaxonEntryData validateQrData(TaxonEntryData data) {
    final names = [
      data.taxonClass,
      data.taxonOrder,
      data.taxonFamily,
      data.genus,
      data.specificEpithet,
      data.subspecificEpithet,
    ];
    TaxonRank? rank;
    if (data.taxonRank?.trim().isNotEmpty == true) {
      rank = taxonRankFromString(data.taxonRank);
      if (rank == null) {
        throw const FormatException(
          'The QR code has an unsupported Taxon rank.',
        );
      }
    } else {
      for (final candidate in TaxonRank.values.reversed) {
        if (names[candidate.index].trim().isNotEmpty) {
          rank = candidate;
          break;
        }
      }
    }
    if (rank == null || names[rank.index].trim().isEmpty) {
      throw const FormatException(
        'The QR code is missing the taxon name for its rank.',
      );
    }
    return data.copyWith(taxonRank: rank.databaseValue);
  }

  static String? _text(Map values, String field) {
    final value = values[field];
    if (value == null || value is String) return value as String?;
    throw FormatException('Invalid $field in taxon QR code.');
  }
}
