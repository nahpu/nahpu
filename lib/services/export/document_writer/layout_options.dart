part of '../document_writer.dart';

/// Layout options for configuring the precise physical dimensions
/// and padding of a printed document sheet.
class DocumentPrintLayoutOptions {
  /// Creates a new layout configuration.
  const DocumentPrintLayoutOptions({
    required this.rowsPerPage,
    required this.colsPerPage,
    required this.pagePadTopMm,
    required this.pagePadLeftMm,
    required this.pagePadRightMm,
    required this.pagePadBottomMm,
    required this.templatePadTopMm,
    required this.templatePadLeftMm,
    required this.templatePadRightMm,
    required this.templatePadBottomMm,
  });

  final int rowsPerPage;
  final int colsPerPage;
  final double pagePadTopMm;
  final double pagePadLeftMm;
  final double pagePadRightMm;
  final double pagePadBottomMm;
  final double templatePadTopMm;
  final double templatePadLeftMm;
  final double templatePadRightMm;
  final double templatePadBottomMm;
}
