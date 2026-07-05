part of '../document_writer.dart';

/// Orchestrates the process of converting specimen data into a generated
/// PDF document file using the Typst rendering engine.
class DocumentWriter {
  /// Creates a document writer that reads selected records and settings from
  /// Riverpod providers.
  DocumentWriter({required this.ref});

  /// Provider reference used to access database, selection, and settings state.
  final WidgetRef ref;

  Database get _db => ref.read(databaseProvider);

  _DocumentPdfBuilder get _pdfBuilder => _DocumentPdfBuilder(ref: ref, db: _db);

  Future<File> _writePdf({
    required Directory selectedDir,
    required String fileStem,
    required rust_config.DocumentLayoutPreset layout,
    required Future<Uint8List> Function(
      double sheetWidthPt,
      double sheetHeightPt,
    ) generatePdf,
  }) async {
    final page = _DocumentPageGeometry.fromLayout(layout);
    final pdfBytes = await generatePdf(page.widthPt, page.heightPt);
    final savePath =
        await AppIOServices(dir: selectedDir, fileStem: fileStem, ext: 'pdf')
            .getSavePath();
    await savePath.writeAsBytes(pdfBytes);
    return savePath;
  }

  /// Writes a PDF preview of the configured [layout] to [selectedDir].
  ///
  /// The generated file name is derived from [fileStem], with collisions handled
  /// by the app IO service.
  Future<File> writeLayout(
      {required Directory selectedDir,
      required String fileStem,
      required rust_config.DocumentLayoutPreset layout}) {
    return _writePdf(
        selectedDir: selectedDir,
        fileStem: fileStem,
        layout: layout,
        generatePdf: (w, h) => generateLayoutPdf(
            sheetWidthPt: w, sheetHeightPt: h, layout: layout));
  }

  /// Writes specimen document records as a PDF using [layout].
  ///
  /// Each selected specimen in [picked] is converted to document field values
  /// before being placed into the configured template blocks.
  Future<File> writeDocuments(
      {required List<SpecimenData> picked,
      required Directory selectedDir,
      required String fileStem,
      required rust_config.DocumentLayoutPreset layout}) {
    return _writePdf(
        selectedDir: selectedDir,
        fileStem: fileStem,
        layout: layout,
        generatePdf: (w, h) => generateDocumentsPdf(picked,
            sheetWidthPt: w, sheetHeightPt: h, layout: layout));
  }

  /// Writes site document records as a PDF using [layout].
  ///
  /// Each selected site in [picked] is converted to document field values before
  /// rendering.
  Future<File> writeSites(
      {required List<SiteData> picked,
      required Directory selectedDir,
      required String fileStem,
      required rust_config.DocumentLayoutPreset layout}) {
    return _writePdf(
        selectedDir: selectedDir,
        fileStem: fileStem,
        layout: layout,
        generatePdf: (w, h) => generateSitesPdf(picked,
            sheetWidthPt: w, sheetHeightPt: h, layout: layout));
  }

  /// Writes collecting event document records as a PDF using [layout].
  ///
  /// Each selected event in [picked] is expanded with related site, effort, and
  /// personnel values before rendering.
  Future<File> writeEvents(
      {required List<CollEventData> picked,
      required Directory selectedDir,
      required String fileStem,
      required rust_config.DocumentLayoutPreset layout}) {
    return _writePdf(
        selectedDir: selectedDir,
        fileStem: fileStem,
        layout: layout,
        generatePdf: (w, h) => generateEventsPdf(picked,
            sheetWidthPt: w, sheetHeightPt: h, layout: layout));
  }

  /// Writes narrative document records as a PDF using [layout].
  ///
  /// Each selected narrative in [picked] is expanded with related site and
  /// personnel values before rendering.
  Future<File> writeNarratives(
      {required List<NarrativeData> picked,
      required Directory selectedDir,
      required String fileStem,
      required rust_config.DocumentLayoutPreset layout}) {
    return _writePdf(
        selectedDir: selectedDir,
        fileStem: fileStem,
        layout: layout,
        generatePdf: (w, h) => generateNarrativesPdf(picked,
            sheetWidthPt: w, sheetHeightPt: h, layout: layout));
  }

  /// Generates PDF bytes for specimen document records without writing a file.
  ///
  /// [sheetWidthPt] and [sheetHeightPt] are the physical output page dimensions
  /// in Typst points.
  Future<Uint8List> generateDocumentsPdf(List<SpecimenData> specimens,
      {required double sheetWidthPt,
      required double sheetHeightPt,
      required rust_config.DocumentLayoutPreset layout}) {
    return _pdfBuilder.generateDocumentsPdf(specimens,
        sheetWidthPt: sheetWidthPt,
        sheetHeightPt: sheetHeightPt,
        layout: layout);
  }

  /// Generates PDF bytes for site document records without writing a file.
  ///
  /// [sheetWidthPt] and [sheetHeightPt] are the physical output page dimensions
  /// in Typst points.
  Future<Uint8List> generateSitesPdf(List<SiteData> sites,
      {required double sheetWidthPt,
      required double sheetHeightPt,
      required rust_config.DocumentLayoutPreset layout}) {
    return _pdfBuilder.generateSitesPdf(sites,
        sheetWidthPt: sheetWidthPt,
        sheetHeightPt: sheetHeightPt,
        layout: layout);
  }

  /// Generates PDF bytes for collecting event document records without writing
  /// a file.
  ///
  /// [sheetWidthPt] and [sheetHeightPt] are the physical output page dimensions
  /// in Typst points.
  Future<Uint8List> generateEventsPdf(List<CollEventData> events,
      {required double sheetWidthPt,
      required double sheetHeightPt,
      required rust_config.DocumentLayoutPreset layout}) {
    return _pdfBuilder.generateEventsPdf(events,
        sheetWidthPt: sheetWidthPt,
        sheetHeightPt: sheetHeightPt,
        layout: layout);
  }

  /// Generates PDF bytes for narrative document records without writing a file.
  ///
  /// [sheetWidthPt] and [sheetHeightPt] are the physical output page dimensions
  /// in Typst points.
  Future<Uint8List> generateNarrativesPdf(List<NarrativeData> narratives,
      {required double sheetWidthPt,
      required double sheetHeightPt,
      required rust_config.DocumentLayoutPreset layout}) {
    return _pdfBuilder.generateNarrativesPdf(narratives,
        sheetWidthPt: sheetWidthPt,
        sheetHeightPt: sheetHeightPt,
        layout: layout);
  }

  /// Generates PDF bytes for the full mixed-record document [layout].
  ///
  /// When [isPreview] is true, [previewRecords] supplies the record identifiers
  /// used for each template block instead of the current provider selection.
  Future<Uint8List> generateLayoutPdf(
      {required double sheetWidthPt,
      required double sheetHeightPt,
      required rust_config.DocumentLayoutPreset layout,
      bool isPreview = false,
      List<String>? previewRecords}) {
    return _pdfBuilder.generateLayoutPdf(
        sheetWidthPt: sheetWidthPt,
        sheetHeightPt: sheetHeightPt,
        layout: layout,
        isPreview: isPreview,
        previewRecords: previewRecords);
  }

  /// Returns the page-break plan used by tiled document rendering.
  ///
  /// This exposes pagination behavior for regression tests without generating a
  /// full Typst document.
  @visibleForTesting
  static List<bool> pageBreakPlanForTesting(
      {required int specimenCount,
      required int documentsPerSheet,
      required bool duplex}) {
    return _DocumentPdfBuilder.pageBreakPlanForTesting(
        specimenCount: specimenCount,
        documentsPerSheet: documentsPerSheet,
        duplex: duplex);
  }

  /// Returns all page elements sorted by their z-index.
  ///
  /// This mirrors the render order used when writing a template page to Typst.
  @visibleForTesting
  static List<dynamic> sortElementsForTesting(TemplatePage page) {
    return _DocumentTypstRenderer.sortElements(page);
  }
}
