part of '../document_writer.dart';

/// Coordinates PDF input resolution, Typst composition, and Rust compilation.
class _DocumentPdfBuilder {
  _DocumentPdfBuilder({required this.ref, required this.db})
    : _collector = _DocumentLayoutRecordCollector(ref: ref, db: db),
      _substitutor = _DocumentTemplateSubstitutor(ref: ref);

  final WidgetRef ref;
  final Database db;
  final _DocumentLayoutRecordCollector _collector;
  final _DocumentTemplateSubstitutor _substitutor;

  _DocumentPdfInputResolver get _inputs =>
      _DocumentPdfInputResolver(collector: _collector);

  Future<Uint8List> _composeAndCompile({
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
    required List<_DocumentPdfBlockInput> blocks,
  }) async {
    final typst =
        await _DocumentPdfComposer(
          substitutePage: _substitutor.substitutePage,
        ).compose(
          sheetWidthPt: sheetWidthPt,
          sheetHeightPt: sheetHeightPt,
          layout: layout,
          blocks: blocks,
        );
    final fontBytes = await const _DocumentFontLoader().loadFontBytes();
    return rust_document.compileTypstToPdf(
      typstContent: typst,
      fontBytes: fontBytes,
    );
  }

  Future<Uint8List> _generateRecordsPdfGeneric<T>(
    List<T> records, {
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
    required Future<Map<String, String>> Function(T) recordToFields,
  }) async {
    final blocks = await _inputs.fromRecords(
      records: records,
      layout: layout,
      recordToFields: recordToFields,
    );
    return _composeAndCompile(
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
      blocks: blocks,
    );
  }

  Future<Uint8List> generateDocumentsPdf(
    List<SpecimenData> specimens, {
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
  }) {
    return _generateRecordsPdfGeneric<SpecimenData>(
      specimens,
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
      recordToFields: (specimen) =>
          documentFieldValuesForSpecimen(db, specimen, ref),
    );
  }

  Future<Uint8List> generateSitesPdf(
    List<SiteRecord> sites, {
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
  }) {
    return _generateRecordsPdfGeneric<SiteRecord>(
      sites,
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
      recordToFields: (site) => documentFieldValuesForSite(db, site, ref),
    );
  }

  Future<Uint8List> generateEventsPdf(
    List<CollEventData> events, {
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
  }) {
    return _generateRecordsPdfGeneric<CollEventData>(
      events,
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
      recordToFields: (event) =>
          documentFieldValuesForCollEvent(db, event, ref),
    );
  }

  Future<Uint8List> generateNarrativesPdf(
    List<NarrativeData> narratives, {
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
  }) {
    return _generateRecordsPdfGeneric<NarrativeData>(
      narratives,
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
      recordToFields: (narrative) =>
          documentFieldValuesForNarrative(db, narrative, ref),
    );
  }

  Future<Uint8List> generateLayoutPdf({
    required double sheetWidthPt,
    required double sheetHeightPt,
    required rust_config.DocumentLayoutPreset layout,
    bool isPreview = false,
    List<String>? previewRecords,
  }) async {
    final blocks = await _inputs.fromLayout(
      layout: layout,
      isPreview: isPreview,
      previewRecords: previewRecords,
    );
    return _composeAndCompile(
      sheetWidthPt: sheetWidthPt,
      sheetHeightPt: sheetHeightPt,
      layout: layout,
      blocks: blocks,
    );
  }
}
