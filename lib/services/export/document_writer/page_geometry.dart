part of '../document_writer.dart';

class _DocumentPageGeometry {
  const _DocumentPageGeometry({required this.widthPt, required this.heightPt});

  final double widthPt;
  final double heightPt;

  static _DocumentPageGeometry fromLayout(
    rust_config.DocumentLayoutPreset layout,
  ) {
    double widthMm = _pageWidthMm(layout.pageSizeKey, layout.customPageWidthMm);
    double heightMm = _pageHeightMm(
      layout.pageSizeKey,
      layout.customPageHeightMm,
    );

    if (layout.pageOrientation == 'landscape') {
      final tmp = widthMm;
      widthMm = heightMm;
      heightMm = tmp;
    }

    return _DocumentPageGeometry(
      widthPt: documentPdfMmToPt(widthMm),
      heightPt: documentPdfMmToPt(heightMm),
    );
  }

  static double _pageWidthMm(String pageSizeKey, double? customPageWidthMm) {
    switch (pageSizeKey) {
      case 'A0':
        return 841.0;
      case 'A1':
        return 594.0;
      case 'A2':
        return 420.0;
      case 'A3':
        return 297.0;
      case 'Letter':
        return 215.9;
      case 'A5':
        return 148.0;
      case 'A6':
        return 105.0;
      case 'A7':
        return 74.0;
      case 'A8':
        return 52.0;
      case 'Legal':
        return 215.9;
      case 'Custom':
        return customPageWidthMm?.clamp(40.0, 1200.0) ?? 210.0;
      case 'A4':
      default:
        return 210.0;
    }
  }

  static double _pageHeightMm(String pageSizeKey, double? customPageHeightMm) {
    switch (pageSizeKey) {
      case 'A0':
        return 1188.0;
      case 'A1':
        return 841.0;
      case 'A2':
        return 594.0;
      case 'A3':
        return 420.0;
      case 'Letter':
        return 279.4;
      case 'A5':
        return 210.0;
      case 'A6':
        return 148.0;
      case 'A7':
        return 105.0;
      case 'A8':
        return 74.0;
      case 'Legal':
        return 355.6;
      case 'Custom':
        return customPageHeightMm?.clamp(40.0, 1200.0) ?? 297.0;
      case 'A4':
      default:
        return 297.0;
    }
  }
}
