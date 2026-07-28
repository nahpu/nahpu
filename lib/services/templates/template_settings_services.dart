import 'package:shared_preferences/shared_preferences.dart';

class DocumentSettingsServices {
  static const _kDuplex = 'document_duplex';
  static const _kMirrorFront = 'document_mirror_front';
  static const _kMirrorBack = 'document_mirror_back';
  static const _kWidthMm = 'document_width_mm';
  static const _kHeightMm = 'document_height_mm';
  static const _kTemplateName = 'document_template_name';
  static const _kPrintPageSizeKey = 'document_print_page_size_key';
  static const _kPrintRowsPerPage = 'document_print_rows_per_page';
  static const _kPrintColsPerPage = 'document_print_cols_per_page';
  static const _kPrintPagePadTopMm = 'document_print_page_pad_top_mm';
  static const _kPrintPagePadLeftMm = 'document_print_page_pad_left_mm';
  static const _kPrintPagePadRightMm = 'document_print_page_pad_right_mm';
  static const _kPrintPagePadBottomMm = 'document_print_page_pad_bottom_mm';
  static const _kPrintDocumentPadTopMm = 'document_print_document_pad_top_mm';
  static const _kPrintDocumentPadLeftMm = 'document_print_document_pad_left_mm';
  static const _kPrintDocumentPadRightMm =
      'document_print_document_pad_right_mm';
  static const _kPrintDocumentPadBottomMm =
      'document_print_document_pad_bottom_mm';

  static const _legacyPrefix = 'label';

  Future<SharedPreferences> get _p async => SharedPreferences.getInstance();

  Future<bool> getDuplex() async {
    final p = await _p;
    return p.getBool(_kDuplex) ?? p.getBool('${_legacyPrefix}_duplex') ?? true;
  }

  Future<void> setDuplex(bool value) async {
    final p = await _p;
    await p.setBool(_kDuplex, value);
  }

  Future<bool> getMirrorFront() async {
    final p = await _p;
    return p.getBool(_kMirrorFront) ??
        p.getBool('${_legacyPrefix}_mirror_front') ??
        false;
  }

  Future<void> setMirrorFront(bool value) async {
    final p = await _p;
    await p.setBool(_kMirrorFront, value);
  }

  Future<bool> getMirrorBack() async {
    final p = await _p;
    return p.getBool(_kMirrorBack) ??
        p.getBool('${_legacyPrefix}_mirror_back') ??
        false;
  }

  Future<void> setMirrorBack(bool value) async {
    final p = await _p;
    await p.setBool(_kMirrorBack, value);
  }

  Future<double> getDocumentWidthMm() async {
    final p = await _p;
    return p.getDouble(_kWidthMm) ??
        p.getDouble('${_legacyPrefix}_width_mm') ??
        50.0;
  }

  Future<void> setDocumentWidthMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kWidthMm, mm);
  }

  Future<double> getDocumentHeightMm() async {
    final p = await _p;
    return p.getDouble(_kHeightMm) ??
        p.getDouble('${_legacyPrefix}_height_mm') ??
        25.0;
  }

  Future<void> setDocumentHeightMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kHeightMm, mm);
  }

  Future<String?> getCurrentTemplateName() async {
    final p = await _p;
    return p.getString(_kTemplateName) ??
        p.getString('${_legacyPrefix}_template_name');
  }

  Future<void> setCurrentTemplateName(String? name) async {
    final p = await _p;
    if (name == null || name.isEmpty) {
      await p.remove(_kTemplateName);
    } else {
      await p.setString(_kTemplateName, name);
    }
  }

  Future<String> getPrintPageSizeKey() async {
    final p = await _p;
    return p.getString(_kPrintPageSizeKey) ??
        p.getString('${_legacyPrefix}_print_page_size_key') ??
        'A4';
  }

  Future<void> setPrintPageSizeKey(String key) async {
    final p = await _p;
    await p.setString(_kPrintPageSizeKey, key);
  }

  Future<int> getPrintRowsPerPage() async {
    final p = await _p;
    return p.getInt(_kPrintRowsPerPage) ??
        p.getInt('${_legacyPrefix}_print_rows_per_page') ??
        8;
  }

  Future<void> setPrintRowsPerPage(int rows) async {
    final p = await _p;
    await p.setInt(_kPrintRowsPerPage, rows.clamp(1, 200));
  }

  Future<int> getPrintColsPerPage() async {
    final p = await _p;
    return p.getInt(_kPrintColsPerPage) ??
        p.getInt('${_legacyPrefix}_print_cols_per_page') ??
        4;
  }

  Future<void> setPrintColsPerPage(int cols) async {
    final p = await _p;
    await p.setInt(_kPrintColsPerPage, cols.clamp(1, 200));
  }

  Future<double> getPrintPagePadTopMm() async {
    final p = await _p;
    return p.getDouble(_kPrintPagePadTopMm) ??
        p.getDouble('${_legacyPrefix}_print_page_pad_top_mm') ??
        8.0;
  }

  Future<void> setPrintPagePadTopMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintPagePadTopMm, mm.clamp(0.0, 1000.0));
  }

  Future<double> getPrintPagePadLeftMm() async {
    final p = await _p;
    return p.getDouble(_kPrintPagePadLeftMm) ??
        p.getDouble('${_legacyPrefix}_print_page_pad_left_mm') ??
        8.0;
  }

  Future<void> setPrintPagePadLeftMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintPagePadLeftMm, mm.clamp(0.0, 1000.0));
  }

  Future<double> getPrintPagePadRightMm() async {
    final p = await _p;
    return p.getDouble(_kPrintPagePadRightMm) ??
        p.getDouble('${_legacyPrefix}_print_page_pad_right_mm') ??
        8.0;
  }

  Future<void> setPrintPagePadRightMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintPagePadRightMm, mm.clamp(0.0, 1000.0));
  }

  Future<double> getPrintPagePadBottomMm() async {
    final p = await _p;
    return p.getDouble(_kPrintPagePadBottomMm) ??
        p.getDouble('${_legacyPrefix}_print_page_pad_bottom_mm') ??
        8.0;
  }

  Future<void> setPrintPagePadBottomMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintPagePadBottomMm, mm.clamp(0.0, 1000.0));
  }

  Future<double> getPrintDocumentPadTopMm() async {
    final p = await _p;
    return p.getDouble(_kPrintDocumentPadTopMm) ??
        p.getDouble('${_legacyPrefix}_print_label_pad_top_mm') ??
        1.0;
  }

  Future<void> setPrintDocumentPadTopMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintDocumentPadTopMm, mm.clamp(0.0, 1000.0));
  }

  Future<double> getPrintDocumentPadLeftMm() async {
    final p = await _p;
    return p.getDouble(_kPrintDocumentPadLeftMm) ??
        p.getDouble('${_legacyPrefix}_print_label_pad_left_mm') ??
        1.0;
  }

  Future<void> setPrintDocumentPadLeftMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintDocumentPadLeftMm, mm.clamp(0.0, 1000.0));
  }

  Future<double> getPrintDocumentPadRightMm() async {
    final p = await _p;
    return p.getDouble(_kPrintDocumentPadRightMm) ??
        p.getDouble('${_legacyPrefix}_print_label_pad_right_mm') ??
        1.0;
  }

  Future<void> setPrintDocumentPadRightMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintDocumentPadRightMm, mm.clamp(0.0, 1000.0));
  }

  Future<double> getPrintDocumentPadBottomMm() async {
    final p = await _p;
    return p.getDouble(_kPrintDocumentPadBottomMm) ??
        p.getDouble('${_legacyPrefix}_print_label_pad_bottom_mm') ??
        1.0;
  }

  Future<void> setPrintDocumentPadBottomMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintDocumentPadBottomMm, mm.clamp(0.0, 1000.0));
  }
}
