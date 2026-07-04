import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _pageSetupsDirName = 'document_page_setups';
const String _legacyPageSetupsDirName = 'label_page_setups';
const String _kCurrentPageSetupName = 'document_current_page_setup_name';
const String _legacyCurrentPageSetupName = 'label_current_page_setup_name';

class DocumentPageSetup {
  const DocumentPageSetup({
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
    required this.documentPadTopMm,
    required this.documentPadLeftMm,
    required this.documentPadRightMm,
    required this.documentPadBottomMm,
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
  final double documentPadTopMm;
  final double documentPadLeftMm;
  final double documentPadRightMm;
  final double documentPadBottomMm;

  DocumentPageSetup copyWith({
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
    double? documentPadTopMm,
    double? documentPadLeftMm,
    double? documentPadRightMm,
    double? documentPadBottomMm,
  }) {
    return DocumentPageSetup(
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
      documentPadTopMm: documentPadTopMm ?? this.documentPadTopMm,
      documentPadLeftMm: documentPadLeftMm ?? this.documentPadLeftMm,
      documentPadRightMm: documentPadRightMm ?? this.documentPadRightMm,
      documentPadBottomMm: documentPadBottomMm ?? this.documentPadBottomMm,
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
        'documentPadTopMm': documentPadTopMm,
        'documentPadLeftMm': documentPadLeftMm,
        'documentPadRightMm': documentPadRightMm,
        'documentPadBottomMm': documentPadBottomMm,
      };

  factory DocumentPageSetup.fromJson(Map<String, dynamic> json) {
    double readDouble(String key, String legacyKey, double fallback) {
      return (json[key] as num?)?.toDouble() ??
          (json[legacyKey] as num?)?.toDouble() ??
          fallback;
    }

    return DocumentPageSetup(
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
      documentPadTopMm: readDouble('documentPadTopMm', 'labelPadTopMm', 1.0),
      documentPadLeftMm: readDouble('documentPadLeftMm', 'labelPadLeftMm', 1.0),
      documentPadRightMm:
          readDouble('documentPadRightMm', 'labelPadRightMm', 1.0),
      documentPadBottomMm:
          readDouble('documentPadBottomMm', 'labelPadBottomMm', 1.0),
    );
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  static DocumentPageSetup fromJsonString(String text) {
    final decoded = jsonDecode(text);
    if (decoded is! Map) {
      throw const FormatException('Page setup JSON must be an object');
    }
    return DocumentPageSetup.fromJson(Map<String, dynamic>.from(decoded));
  }

  static DocumentPageSetup defaults([String name = 'Default']) {
    return DocumentPageSetup(
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
      documentPadTopMm: 1,
      documentPadLeftMm: 1,
      documentPadRightMm: 1,
      documentPadBottomMm: 1,
    );
  }
}

class DocumentPageSetupService {
  const DocumentPageSetupService();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<Directory> _setupsDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, _pageSetupsDirName));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  Future<Directory> _legacySetupsDir() async {
    final root = await getApplicationDocumentsDirectory();
    return Directory(p.join(root.path, _legacyPageSetupsDirName));
  }

  Future<List<String>> listSetupNames() async {
    final dir = await _setupsDir();
    final legacyDir = await _legacySetupsDir();
    final files = [
      ...dir.listSync().whereType<File>(),
      if (legacyDir.existsSync()) ...legacyDir.listSync().whereType<File>(),
    ];
    final names = files
        .where((f) => f.path.endsWith('.json'))
        .map((f) => p.basenameWithoutExtension(f.path))
        .toSet()
        .toList()
      ..sort();
    if (!names.contains('Default')) {
      await saveSetup(DocumentPageSetup.defaults());
      names.add('Default');
      names.sort();
    }
    return names;
  }

  Future<DocumentPageSetup?> getSetup(String name) async {
    final dir = await _setupsDir();
    final file = File(p.join(dir.path, '$name.json'));
    if (file.existsSync()) {
      return DocumentPageSetup.fromJsonString(await file.readAsString());
    }
    final legacyDir = await _legacySetupsDir();
    final legacyFile = File(p.join(legacyDir.path, '$name.json'));
    if (!legacyFile.existsSync()) return null;
    return DocumentPageSetup.fromJsonString(await legacyFile.readAsString());
  }

  Future<void> saveSetup(DocumentPageSetup setup) async {
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
    final stored = prefs.getString(_kCurrentPageSetupName) ??
        prefs.getString(_legacyCurrentPageSetupName);
    final names = await listSetupNames();
    if (stored != null && names.contains(stored)) return stored;
    return names.first;
  }

  Future<void> setCurrentSetupName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_kCurrentPageSetupName, name);
  }

  Future<DocumentPageSetup> getCurrentSetup() async {
    final name = await getCurrentSetupName();
    return (await getSetup(name)) ?? DocumentPageSetup.defaults(name);
  }

  Future<DocumentPageSetup?> importFromPath(String path) async {
    try {
      final text = await File(path).readAsString();
      return DocumentPageSetup.fromJsonString(text);
    } catch (_) {
      return null;
    }
  }

  Future<void> exportToPath(DocumentPageSetup setup, String path) async {
    await File(path).writeAsString(setup.toJsonString());
  }
}
