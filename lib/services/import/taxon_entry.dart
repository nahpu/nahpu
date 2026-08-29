import 'dart:collection';

import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/services/types/import.dart';

class CsvData {
  CsvData({required this.header, required this.headerMap, required this.data});

  List<String> header;
  Map<int, TaxonEntryHeader> headerMap;
  List<List<String>> data;

  factory CsvData.empty() {
    return CsvData(header: [], headerMap: {}, data: []);
  }

  void parseTaxonEntryFromList(List<List<dynamic>> parsedCsv) {
    header = parsedCsv[0].map((e) => e.toString().trim()).toList();
    if (header.isNotEmpty) {
      header[0] = header[0].replaceFirst('\uFEFF', '');
    }
    _mapHeader();
    for (var row in parsedCsv.sublist(1)) {
      List<String> rowData = [];
      for (var value in row) {
        rowData.add(value.toString().trim());
      }
      data.add(rowData);
    }
  }

  void _mapHeader() {
    for (int i = 0; i < header.length; i++) {
      String value = header[i];
      TaxonEntryHeader headerKey =
          knownTaxonHeader[value.toLowerCase().replaceAll(' ', '')] ??
          TaxonEntryHeader.ignore;

      headerMap[i] = headerKey;
    }
  }
}

class ParsedCSVdata {
  ParsedCSVdata({
    required this.skippedSpecies,
    required this.importedSpeciesCount,
    required this.importedFamilyCount,
  });

  HashSet<String> skippedSpecies;
  int recordCount = 0;
  int importedSpeciesCount;
  int importedFamilyCount;

  factory ParsedCSVdata.empty() {
    return ParsedCSVdata(
      skippedSpecies: HashSet(),
      importedSpeciesCount: 0,
      importedFamilyCount: 0,
    );
  }

  void countAll(HashSet<String> species, HashSet<String> families) {
    importedSpeciesCount = species.length;
    importedFamilyCount = families.length;
  }
}

class TaxonParser {
  TaxonParser({required this.headerMap, required this.data});

  final Map<int, TaxonEntryHeader> headerMap;
  final List<List<String>> data;

  List<TaxonEntryData> parseData() {
    List<TaxonEntryData> parsedData = data.map((e) => _parseData(e)).toList();

    return parsedData;
  }

  TaxonEntryData _parseData(List<String> values) {
    TaxonEntryData taxonEntryCsv = TaxonEntryData.empty();
    for (int index = 0; index < values.length; index++) {
      String value = values[index];
      TaxonEntryHeader header = headerMap[index] ?? TaxonEntryHeader.ignore;
      switch (header) {
        case TaxonEntryHeader.taxonRank:
          taxonEntryCsv.taxonRank = value;
          break;
        case TaxonEntryHeader.taxonClass:
          taxonEntryCsv.taxonClass = value;
          break;
        case TaxonEntryHeader.taxonOrder:
          taxonEntryCsv.taxonOrder = value;
          break;
        case TaxonEntryHeader.taxonFamily:
          taxonEntryCsv.taxonFamily = value;
          break;
        case TaxonEntryHeader.genus:
          taxonEntryCsv.genus = value;
          break;
        case TaxonEntryHeader.specificEpithet:
          taxonEntryCsv.specificEpithet = value;
          break;
        case TaxonEntryHeader.subspecificEpithet:
          taxonEntryCsv.subspecificEpithet = value;
          break;
        case TaxonEntryHeader.authors:
          taxonEntryCsv.authors = value;
          break;
        case TaxonEntryHeader.commonName:
          taxonEntryCsv.commonName = value;
          break;
        case TaxonEntryHeader.redListCategory:
          taxonEntryCsv.redListCategory = value;
          break;
        case TaxonEntryHeader.citesStatus:
          taxonEntryCsv.citesStatus = value;
          break;
        case TaxonEntryHeader.countryStatus:
          taxonEntryCsv.countryStatus = value;
          break;
        case TaxonEntryHeader.sortingOrder:
          taxonEntryCsv.sortingOrder = int.tryParse(value);
          break;
        case TaxonEntryHeader.notes:
          taxonEntryCsv.notes = value;
          break;
        case TaxonEntryHeader.ignore:
          break;
      }
    }

    return taxonEntryCsv;
  }
}

class TaxonEntryData {
  TaxonEntryData({
    this.taxonRank,
    required this.taxonClass,
    required this.taxonOrder,
    required this.taxonFamily,
    required this.genus,
    required this.specificEpithet,
    required this.subspecificEpithet,
    this.authors,
    this.commonName,
    this.redListCategory,
    this.citesStatus,
    this.countryStatus,
    this.sortingOrder,
    this.notes,
  });

  String? taxonRank;
  String taxonClass;
  String taxonOrder;
  String taxonFamily;
  String genus;
  String specificEpithet;
  String subspecificEpithet;
  String? authors;
  String? commonName;
  String? redListCategory;
  String? citesStatus;
  String? countryStatus;
  int? sortingOrder;
  String? notes;

  factory TaxonEntryData.empty() {
    return TaxonEntryData(
      taxonRank: null,
      taxonClass: '',
      taxonOrder: '',
      taxonFamily: '',
      genus: '',
      specificEpithet: '',
      subspecificEpithet: '',
      authors: null,
      commonName: null,
      redListCategory: null,
      citesStatus: null,
      countryStatus: null,
      sortingOrder: null,
      notes: null,
    );
  }

  TaxonEntryData copyWith({
    String? taxonRank,
    String? taxonClass,
    String? taxonOrder,
    String? taxonFamily,
    String? genus,
    String? specificEpithet,
    String? subspecificEpithet,
    String? authors,
    String? commonName,
    String? redListCategory,
    String? citesStatus,
    String? countryStatus,
    int? sortingOrder,
    String? notes,
  }) {
    return TaxonEntryData(
      taxonRank: taxonRank ?? this.taxonRank,
      taxonClass: taxonClass ?? this.taxonClass,
      taxonOrder: taxonOrder ?? this.taxonOrder,
      taxonFamily: taxonFamily ?? this.taxonFamily,
      genus: genus ?? this.genus,
      specificEpithet: specificEpithet ?? this.specificEpithet,
      subspecificEpithet: subspecificEpithet ?? this.subspecificEpithet,
      authors: authors ?? this.authors,
      commonName: commonName ?? this.commonName,
      redListCategory: redListCategory ?? this.redListCategory,
      citesStatus: citesStatus ?? this.citesStatus,
      countryStatus: countryStatus ?? this.countryStatus,
      sortingOrder: sortingOrder ?? this.sortingOrder,
      notes: notes ?? this.notes,
    );
  }
}

enum TaxonImportStatus { ready, alreadyRegistered, duplicateInFile }

class TaxonImportCandidate {
  const TaxonImportCandidate({
    required this.sourceRow,
    required this.data,
    required this.status,
  });

  final int sourceRow;
  final TaxonEntryData data;
  final TaxonImportStatus status;

  bool get isSelectable => status == TaxonImportStatus.ready;

  TaxonRank get rank =>
      taxonRankFromString(data.taxonRank) ?? TaxonRank.species;

  String get displayName => switch (rank) {
    TaxonRank.taxonClass => data.taxonClass,
    TaxonRank.order => data.taxonOrder,
    TaxonRank.family => data.taxonFamily,
    TaxonRank.genus => data.genus,
    TaxonRank.species => '${data.genus} ${data.specificEpithet}'.trim(),
    TaxonRank.subspecies =>
      '${data.genus} ${data.specificEpithet} ${data.subspecificEpithet}'.trim(),
  };

  bool get usesItalicName => rank.index >= TaxonRank.genus.index;
}

class TaxonImportReview {
  const TaxonImportReview({required this.candidates});

  final List<TaxonImportCandidate> candidates;

  List<TaxonImportCandidate> get selectableCandidates =>
      candidates.where((candidate) => candidate.isSelectable).toList();

  int get duplicateCount => candidates
      .where(
        (candidate) => candidate.status == TaxonImportStatus.duplicateInFile,
      )
      .length;

  int get alreadyRegisteredCount => candidates
      .where(
        (candidate) => candidate.status == TaxonImportStatus.alreadyRegistered,
      )
      .length;
}

class TaxonImportResult {
  const TaxonImportResult({
    required this.importedTaxaCount,
    required this.importedFamilyCount,
  });

  final int importedTaxaCount;
  final int importedFamilyCount;
}
