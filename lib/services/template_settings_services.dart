import 'dart:convert';

import 'package:nahpu/services/print_specimen_table_columns.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LabelSettingsServices {
  static const _kDuplex = 'label_duplex';
  static const _kMirrorFront = 'label_mirror_front';
  static const _kMirrorBack = 'label_mirror_back';
  static const _kWidthMm = 'label_width_mm';
  static const _kHeightMm = 'label_height_mm';
  static const _kTemplateName = 'label_template_name';
  static const _kPrintTableColumns = 'label_print_table_columns';
  static const _kPrintPageSizeKey = 'label_print_page_size_key';
  static const _kPrintRowsPerPage = 'label_print_rows_per_page';
  static const _kPrintColsPerPage = 'label_print_cols_per_page';
  static const _kPrintPagePadTopMm = 'label_print_page_pad_top_mm';
  static const _kPrintPagePadLeftMm = 'label_print_page_pad_left_mm';
  static const _kPrintPagePadRightMm = 'label_print_page_pad_right_mm';
  static const _kPrintPagePadBottomMm = 'label_print_page_pad_bottom_mm';
  static const _kPrintLabelPadTopMm = 'label_print_label_pad_top_mm';
  static const _kPrintLabelPadLeftMm = 'label_print_label_pad_left_mm';
  static const _kPrintLabelPadRightMm = 'label_print_label_pad_right_mm';
  static const _kPrintLabelPadBottomMm = 'label_print_label_pad_bottom_mm';

  Future<SharedPreferences> get _p async => SharedPreferences.getInstance();

  Future<bool> getDuplex() async {
    final p = await _p;
    return p.getBool(_kDuplex) ?? true;
  }

  Future<void> setDuplex(bool value) async {
    final p = await _p;
    await p.setBool(_kDuplex, value);
  }

  Future<bool> getMirrorFront() async {
    final p = await _p;
    return p.getBool(_kMirrorFront) ?? false;
  }

  Future<void> setMirrorFront(bool value) async {
    final p = await _p;
    await p.setBool(_kMirrorFront, value);
  }

  Future<bool> getMirrorBack() async {
    final p = await _p;
    return p.getBool(_kMirrorBack) ?? false;
  }

  Future<void> setMirrorBack(bool value) async {
    final p = await _p;
    await p.setBool(_kMirrorBack, value);
  }

  Future<double> getLabelWidthMm() async {
    final p = await _p;
    return p.getDouble(_kWidthMm) ?? 50.0;
  }

  Future<void> setLabelWidthMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kWidthMm, mm);
  }

  Future<double> getLabelHeightMm() async {
    final p = await _p;
    return p.getDouble(_kHeightMm) ?? 25.0;
  }

  Future<void> setLabelHeightMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kHeightMm, mm);
  }

  Future<String?> getCurrentTemplateName() async {
    final p = await _p;
    return p.getString(_kTemplateName);
  }

  Future<void> setCurrentTemplateName(String? name) async {
    final p = await _p;
    if (name == null || name.isEmpty) {
      await p.remove(_kTemplateName);
    } else {
      await p.setString(_kTemplateName, name);
    }
  }

  Future<List<String>> getPrintSpecimenTableColumnIds() async {
    final p = await _p;
    final raw = p.getString(_kPrintTableColumns);
    if (raw == null || raw.isEmpty) {
      return List<String>.from(kDefaultPrintSpecimenTableColumnIds);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return List<String>.from(kDefaultPrintSpecimenTableColumnIds);
      }
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return List<String>.from(kDefaultPrintSpecimenTableColumnIds);
    }
  }

  Future<void> setPrintSpecimenTableColumnIds(List<String> ids) async {
    final p = await _p;
    await p.setString(_kPrintTableColumns, jsonEncode(ids));
  }

  Future<String> getPrintPageSizeKey() async {
    final p = await _p;
    return p.getString(_kPrintPageSizeKey) ?? 'A4';
  }

  Future<void> setPrintPageSizeKey(String key) async {
    final p = await _p;
    await p.setString(_kPrintPageSizeKey, key);
  }

  Future<int> getPrintRowsPerPage() async {
    final p = await _p;
    return p.getInt(_kPrintRowsPerPage) ?? 8;
  }

  Future<void> setPrintRowsPerPage(int rows) async {
    final p = await _p;
    await p.setInt(_kPrintRowsPerPage, rows.clamp(1, 200));
  }

  Future<int> getPrintColsPerPage() async {
    final p = await _p;
    return p.getInt(_kPrintColsPerPage) ?? 4;
  }

  Future<void> setPrintColsPerPage(int cols) async {
    final p = await _p;
    await p.setInt(_kPrintColsPerPage, cols.clamp(1, 200));
  }

  Future<double> getPrintPagePadTopMm() async {
    final p = await _p;
    return p.getDouble(_kPrintPagePadTopMm) ?? 8.0;
  }

  Future<void> setPrintPagePadTopMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintPagePadTopMm, mm.clamp(0.0, 1000.0));
  }

  Future<double> getPrintPagePadLeftMm() async {
    final p = await _p;
    return p.getDouble(_kPrintPagePadLeftMm) ?? 8.0;
  }

  Future<void> setPrintPagePadLeftMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintPagePadLeftMm, mm.clamp(0.0, 1000.0));
  }

  Future<double> getPrintPagePadRightMm() async {
    final p = await _p;
    return p.getDouble(_kPrintPagePadRightMm) ?? 8.0;
  }

  Future<void> setPrintPagePadRightMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintPagePadRightMm, mm.clamp(0.0, 1000.0));
  }

  Future<double> getPrintPagePadBottomMm() async {
    final p = await _p;
    return p.getDouble(_kPrintPagePadBottomMm) ?? 8.0;
  }

  Future<void> setPrintPagePadBottomMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintPagePadBottomMm, mm.clamp(0.0, 1000.0));
  }

  Future<double> getPrintLabelPadTopMm() async {
    final p = await _p;
    return p.getDouble(_kPrintLabelPadTopMm) ?? 1.0;
  }

  Future<void> setPrintLabelPadTopMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintLabelPadTopMm, mm.clamp(0.0, 1000.0));
  }

  Future<double> getPrintLabelPadLeftMm() async {
    final p = await _p;
    return p.getDouble(_kPrintLabelPadLeftMm) ?? 1.0;
  }

  Future<void> setPrintLabelPadLeftMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintLabelPadLeftMm, mm.clamp(0.0, 1000.0));
  }

  Future<double> getPrintLabelPadRightMm() async {
    final p = await _p;
    return p.getDouble(_kPrintLabelPadRightMm) ?? 1.0;
  }

  Future<void> setPrintLabelPadRightMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintLabelPadRightMm, mm.clamp(0.0, 1000.0));
  }

  Future<double> getPrintLabelPadBottomMm() async {
    final p = await _p;
    return p.getDouble(_kPrintLabelPadBottomMm) ?? 1.0;
  }

  Future<void> setPrintLabelPadBottomMm(double mm) async {
    final p = await _p;
    await p.setDouble(_kPrintLabelPadBottomMm, mm.clamp(0.0, 1000.0));
  }
}
