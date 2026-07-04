import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _pageSetupsDirName = 'label_page_setups';
const String _kCurrentPageSetupName = 'label_current_page_setup_name';

class LabelPageSetup {
  const LabelPageSetup({
    required this.name,
    required this.pageSizeKey,
    required this.pageOrientation,
    required this.customPageWidthMm,
    required this.customPageHeightMm,
    required this.rowsPerPage,
    required this.colsPerPage,
    required this.pagePadTopMm,
    required this.pagePadLeftMm,
    required this.pagePadRightMm,
    required this.pagePadBottomMm,
    required this.labelPadTopMm,
    required this.labelPadLeftMm,
    required this.labelPadRightMm,
    required this.labelPadBottomMm,
  });

  final String name;
  final String pageSizeKey;
  final String pageOrientation;
  final double customPageWidthMm;
  final double customPageHeightMm;
  final int rowsPerPage;
  final int colsPerPage;
  final double pagePadTopMm;
  final double pagePadLeftMm;
  final double pagePadRightMm;
  final double pagePadBottomMm;
  final double labelPadTopMm;
  final double labelPadLeftMm;
  final double labelPadRightMm;
  final double labelPadBottomMm;

  LabelPageSetup copyWith({
    String? name,
    String? pageSizeKey,
    String? pageOrientation,
    double? customPageWidthMm,
    double? customPageHeightMm,
    int? rowsPerPage,
    int? colsPerPage,
    double? pagePadTopMm,
    double? pagePadLeftMm,
    double? pagePadRightMm,
    double? pagePadBottomMm,
    double? labelPadTopMm,
    double? labelPadLeftMm,
    double? labelPadRightMm,
    double? labelPadBottomMm,
  }) {
    return LabelPageSetup(
      name: name ?? this.name,
      pageSizeKey: pageSizeKey ?? this.pageSizeKey,
      pageOrientation: pageOrientation ?? this.pageOrientation,
      customPageWidthMm: customPageWidthMm ?? this.customPageWidthMm,
      customPageHeightMm: customPageHeightMm ?? this.customPageHeightMm,
      rowsPerPage: rowsPerPage ?? this.rowsPerPage,
      colsPerPage: colsPerPage ?? this.colsPerPage,
      pagePadTopMm: pagePadTopMm ?? this.pagePadTopMm,
      pagePadLeftMm: pagePadLeftMm ?? this.pagePadLeftMm,
      pagePadRightMm: pagePadRightMm ?? this.pagePadRightMm,
      pagePadBottomMm: pagePadBottomMm ?? this.pagePadBottomMm,
      labelPadTopMm: labelPadTopMm ?? this.labelPadTopMm,
      labelPadLeftMm: labelPadLeftMm ?? this.labelPadLeftMm,
      labelPadRightMm: labelPadRightMm ?? this.labelPadRightMm,
      labelPadBottomMm: labelPadBottomMm ?? this.labelPadBottomMm,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'pageSizeKey': pageSizeKey,
        'pageOrientation': pageOrientation,
        'customPageWidthMm': customPageWidthMm,
        'customPageHeightMm': customPageHeightMm,
        'rowsPerPage': rowsPerPage,
        'colsPerPage': colsPerPage,
        'pagePadTopMm': pagePadTopMm,
        'pagePadLeftMm': pagePadLeftMm,
        'pagePadRightMm': pagePadRightMm,
        'pagePadBottomMm': pagePadBottomMm,
        'labelPadTopMm': labelPadTopMm,
        'labelPadLeftMm': labelPadLeftMm,
        'labelPadRightMm': labelPadRightMm,
        'labelPadBottomMm': labelPadBottomMm,
      };

  factory LabelPageSetup.fromJson(Map<String, dynamic> json) {
    return LabelPageSetup(
      name: (json['name'] as String? ?? 'Default').trim().isEmpty
          ? 'Default'
          : (json['name'] as String).trim(),
      pageSizeKey: json['pageSizeKey'] as String? ?? 'Letter',
      pageOrientation: json['pageOrientation'] as String? ?? 'portrait',
      customPageWidthMm: (json['customPageWidthMm'] as num?)?.toDouble() ?? 210,
      customPageHeightMm:
          (json['customPageHeightMm'] as num?)?.toDouble() ?? 297,
      rowsPerPage: (json['rowsPerPage'] as num?)?.toInt().clamp(1, 200) ?? 8,
      colsPerPage: (json['colsPerPage'] as num?)?.toInt().clamp(1, 200) ?? 4,
      pagePadTopMm: (json['pagePadTopMm'] as num?)?.toDouble() ?? 8.0,
      pagePadLeftMm: (json['pagePadLeftMm'] as num?)?.toDouble() ?? 8.0,
      pagePadRightMm: (json['pagePadRightMm'] as num?)?.toDouble() ?? 8.0,
      pagePadBottomMm: (json['pagePadBottomMm'] as num?)?.toDouble() ?? 8.0,
      labelPadTopMm: (json['labelPadTopMm'] as num?)?.toDouble() ?? 1.0,
      labelPadLeftMm: (json['labelPadLeftMm'] as num?)?.toDouble() ?? 1.0,
      labelPadRightMm: (json['labelPadRightMm'] as num?)?.toDouble() ?? 1.0,
      labelPadBottomMm: (json['labelPadBottomMm'] as num?)?.toDouble() ?? 1.0,
    );
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  static LabelPageSetup fromJsonString(String text) {
    final decoded = jsonDecode(text);
    if (decoded is! Map) {
      throw const FormatException('Page setup JSON must be an object');
    }
    return LabelPageSetup.fromJson(Map<String, dynamic>.from(decoded));
  }

  static LabelPageSetup defaults([String name = 'Default']) {
    return LabelPageSetup(
      name: name,
      pageSizeKey: 'Letter',
      pageOrientation: 'portrait',
      customPageWidthMm: 215.9,
      customPageHeightMm: 279.4,
      rowsPerPage: 8,
      colsPerPage: 4,
      pagePadTopMm: 8,
      pagePadLeftMm: 8,
      pagePadRightMm: 8,
      pagePadBottomMm: 8,
      labelPadTopMm: 1,
      labelPadLeftMm: 1,
      labelPadRightMm: 1,
      labelPadBottomMm: 1,
    );
  }
}

class LabelPageSetupService {
  const LabelPageSetupService();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<Directory> _setupsDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, _pageSetupsDirName));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  Future<List<String>> listSetupNames() async {
    final dir = await _setupsDir();
    final names = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .map((f) => p.basenameWithoutExtension(f.path))
        .toList()
      ..sort();
    if (!names.contains('Default')) {
      await saveSetup(LabelPageSetup.defaults());
      names.add('Default');
      names.sort();
    }
    return names;
  }

  Future<LabelPageSetup?> getSetup(String name) async {
    final dir = await _setupsDir();
    final file = File(p.join(dir.path, '$name.json'));
    if (!file.existsSync()) return null;
    return LabelPageSetup.fromJsonString(await file.readAsString());
  }

  Future<void> saveSetup(LabelPageSetup setup) async {
    final dir = await _setupsDir();
    final safeName = setup.name.trim().isEmpty ? 'Default' : setup.name.trim();
    final file = File(p.join(dir.path, '$safeName.json'));
    await file.writeAsString(setup.copyWith(name: safeName).toJsonString());
  }

  Future<void> deleteSetup(String name) async {
    final dir = await _setupsDir();
    final file = File(p.join(dir.path, '$name.json'));
    if (file.existsSync()) await file.delete();
    final names = await listSetupNames();
    if (!names.contains(name)) {
      final current = await getCurrentSetupName();
      if (current == name) {
        await setCurrentSetupName(names.first);
      }
    }
  }

  Future<String> getCurrentSetupName() async {
    final prefs = await _prefs;
    final stored = prefs.getString(_kCurrentPageSetupName);
    final names = await listSetupNames();
    if (stored != null && names.contains(stored)) return stored;
    return names.first;
  }

  Future<void> setCurrentSetupName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_kCurrentPageSetupName, name);
  }

  Future<LabelPageSetup> getCurrentSetup() async {
    final name = await getCurrentSetupName();
    return (await getSetup(name)) ?? LabelPageSetup.defaults(name);
  }

  Future<LabelPageSetup?> importFromPath(String path) async {
    try {
      final text = await File(path).readAsString();
      return LabelPageSetup.fromJsonString(text);
    } catch (_) {
      return null;
    }
  }

  Future<void> exportToPath(LabelPageSetup setup, String path) async {
    await File(path).writeAsString(setup.toJsonString());
  }
}
