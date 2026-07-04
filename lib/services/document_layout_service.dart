import 'package:shared_preferences/shared_preferences.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

const String _kCurrentDocumentLayoutName = 'label_current_document_layout_name';

class DocumentLayoutService {
  const DocumentLayoutService();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<List<String>> listLayoutNames() async {
    final layouts = await rust_config.getAllDocumentLayouts();
    final names = layouts.map((l) => l.name).toList()..sort();
    if (!names.contains('Default')) {
      final defaultLayout = await getDefaultLayout('Default');
      await saveLayout(defaultLayout);
      names.add('Default');
      names.sort();
    }
    return names;
  }

  Future<rust_config.DocumentLayoutPreset?> getLayout(String name) async {
    return await rust_config.getDocumentLayout(name: name);
  }

  Future<void> saveLayout(rust_config.DocumentLayoutPreset layout) async {
    await rust_config.setDocumentLayout(name: layout.name, layout: layout);
  }

  Future<void> deleteLayout(String name) async {
    await rust_config.deleteDocumentLayout(name: name);
    final names = await listLayoutNames();
    final current = await getCurrentLayoutName();
    if (current == name) {
      await setCurrentLayoutName(names.first);
    }
  }

  Future<String> getCurrentLayoutName() async {
    final prefs = await _prefs;
    final stored = prefs.getString(_kCurrentDocumentLayoutName);
    final names = await listLayoutNames();
    if (stored != null && names.contains(stored)) return stored;
    return names.first;
  }

  Future<void> setCurrentLayoutName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_kCurrentDocumentLayoutName, name);
  }

  Future<rust_config.DocumentLayoutPreset> getCurrentLayout() async {
    final name = await getCurrentLayoutName();
    final layout = await getLayout(name);
    if (layout != null) return layout;
    return await getDefaultLayout(name);
  }

  Future<rust_config.DocumentLayoutPreset> getDefaultLayout(
      [String name = 'Default']) async {
    final templateNames = await rust_config.listTemplatePresets();
    final templateName =
        templateNames.isNotEmpty ? templateNames.first : 'Default';

    return rust_config.DocumentLayoutPreset(
      name: name,
      layoutType: 'WholePage',
      pageSizeKey: 'Letter',
      pageOrientation: 'portrait',
      customPageWidthMm: null,
      customPageHeightMm: null,
      pagePadTopMm: 8.0,
      pagePadLeftMm: 8.0,
      pagePadRightMm: 8.0,
      pagePadBottomMm: 8.0,
      blocks: [
        rust_config.DocumentLayoutBlock(
          templateName: templateName,
          labelCount: 1,
          rows: 8,
          cols: 4,
          labelPadTopMm: 1.0,
          labelPadLeftMm: 1.0,
          labelPadRightMm: 1.0,
          labelPadBottomMm: 1.0,
          pageBreakAfter: false,
        ),
      ],
    );
  }
}

extension DocumentLayoutBlockExtension on rust_config.DocumentLayoutBlock {
  rust_config.DocumentLayoutBlock copyWith({
    String? templateName,
    int? labelCount,
    int? rows,
    int? cols,
    double? labelPadTopMm,
    double? labelPadLeftMm,
    double? labelPadRightMm,
    double? labelPadBottomMm,
    bool? pageBreakAfter,
  }) {
    return rust_config.DocumentLayoutBlock(
      templateName: templateName ?? this.templateName,
      labelCount: labelCount ?? this.labelCount,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      labelPadTopMm: labelPadTopMm ?? this.labelPadTopMm,
      labelPadLeftMm: labelPadLeftMm ?? this.labelPadLeftMm,
      labelPadRightMm: labelPadRightMm ?? this.labelPadRightMm,
      labelPadBottomMm: labelPadBottomMm ?? this.labelPadBottomMm,
      pageBreakAfter: pageBreakAfter ?? this.pageBreakAfter,
    );
  }
}

extension DocumentLayoutPresetExtension on rust_config.DocumentLayoutPreset {
  rust_config.DocumentLayoutPreset copyWith({
    String? name,
    String? layoutType,
    String? pageSizeKey,
    String? pageOrientation,
    double? customPageWidthMm,
    double? customPageHeightMm,
    double? pagePadTopMm,
    double? pagePadLeftMm,
    double? pagePadRightMm,
    double? pagePadBottomMm,
    List<rust_config.DocumentLayoutBlock>? blocks,
  }) {
    return rust_config.DocumentLayoutPreset(
      name: name ?? this.name,
      layoutType: layoutType ?? this.layoutType,
      pageSizeKey: pageSizeKey ?? this.pageSizeKey,
      pageOrientation: pageOrientation ?? this.pageOrientation,
      customPageWidthMm: customPageWidthMm ?? this.customPageWidthMm,
      customPageHeightMm: customPageHeightMm ?? this.customPageHeightMm,
      pagePadTopMm: pagePadTopMm ?? this.pagePadTopMm,
      pagePadLeftMm: pagePadLeftMm ?? this.pagePadLeftMm,
      pagePadRightMm: pagePadRightMm ?? this.pagePadRightMm,
      pagePadBottomMm: pagePadBottomMm ?? this.pagePadBottomMm,
      blocks: blocks ?? this.blocks,
    );
  }
}

Map<String, dynamic> documentLayoutPresetToJson(
    rust_config.DocumentLayoutPreset p) {
  return {
    'name': p.name,
    'layoutType': p.layoutType,
    'pageSizeKey': p.pageSizeKey,
    'pageOrientation': p.pageOrientation,
    'customPageWidthMm': p.customPageWidthMm,
    'customPageHeightMm': p.customPageHeightMm,
    'pagePadTopMm': p.pagePadTopMm,
    'pagePadLeftMm': p.pagePadLeftMm,
    'pagePadRightMm': p.pagePadRightMm,
    'pagePadBottomMm': p.pagePadBottomMm,
    'blocks': p.blocks
        .map((b) => {
              'templateName': b.templateName,
              'labelCount': b.labelCount,
              'rows': b.rows,
              'cols': b.cols,
              'labelPadTopMm': b.labelPadTopMm,
              'labelPadLeftMm': b.labelPadLeftMm,
              'labelPadRightMm': b.labelPadRightMm,
              'labelPadBottomMm': b.labelPadBottomMm,
              'pageBreakAfter': b.pageBreakAfter,
            })
        .toList(),
  };
}

rust_config.DocumentLayoutPreset documentLayoutPresetFromJson(
    Map<String, dynamic> map) {
  final blocksList = (map['blocks'] as List? ?? []).map((b) {
    final blockMap = b as Map<String, dynamic>;
    return rust_config.DocumentLayoutBlock(
      templateName: blockMap['templateName']?.toString() ?? 'Default',
      labelCount: int.tryParse(blockMap['labelCount']?.toString() ?? '') ?? 1,
      rows: int.tryParse(blockMap['rows']?.toString() ?? '') ?? 8,
      cols: int.tryParse(blockMap['cols']?.toString() ?? '') ?? 4,
      labelPadTopMm:
          double.tryParse(blockMap['labelPadTopMm']?.toString() ?? '') ?? 1.0,
      labelPadLeftMm:
          double.tryParse(blockMap['labelPadLeftMm']?.toString() ?? '') ?? 1.0,
      labelPadRightMm:
          double.tryParse(blockMap['labelPadRightMm']?.toString() ?? '') ?? 1.0,
      labelPadBottomMm:
          double.tryParse(blockMap['labelPadBottomMm']?.toString() ?? '') ??
              1.0,
      pageBreakAfter: blockMap['pageBreakAfter'] == true,
    );
  }).toList();

  return rust_config.DocumentLayoutPreset(
    name: map['name']?.toString() ?? 'Default',
    layoutType: map['layoutType']?.toString() ?? 'WholePage',
    pageSizeKey: map['pageSizeKey']?.toString() ?? 'Letter',
    pageOrientation: map['pageOrientation']?.toString() ?? 'portrait',
    customPageWidthMm:
        double.tryParse(map['customPageWidthMm']?.toString() ?? ''),
    customPageHeightMm:
        double.tryParse(map['customPageHeightMm']?.toString() ?? ''),
    pagePadTopMm: double.tryParse(map['pagePadTopMm']?.toString() ?? '') ?? 8.0,
    pagePadLeftMm:
        double.tryParse(map['pagePadLeftMm']?.toString() ?? '') ?? 8.0,
    pagePadRightMm:
        double.tryParse(map['pagePadRightMm']?.toString() ?? '') ?? 8.0,
    pagePadBottomMm:
        double.tryParse(map['pagePadBottomMm']?.toString() ?? '') ?? 8.0,
    blocks: blocksList,
  );
}
