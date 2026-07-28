import 'package:shared_preferences/shared_preferences.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

const String _kCurrentDocumentLayoutName =
    'document_current_document_layout_name';
const String _legacyCurrentDocumentLayoutName =
    'label_current_document_layout_name';

class DocumentLayoutService {
  const DocumentLayoutService();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<List<rust_config.DocumentLayoutStatus>> listLayoutStatuses() async {
    final statuses = await rust_config.getDocumentLayoutStatuses();
    statuses.sort((a, b) => a.name.compareTo(b.name));
    return statuses;
  }

  Future<String?> getStoredCurrentLayoutName() async {
    final prefs = await _prefs;
    return prefs.getString(_kCurrentDocumentLayoutName) ??
        prefs.getString(_legacyCurrentDocumentLayoutName);
  }

  Future<List<String>> listLayoutNames() async {
    final statuses = await listLayoutStatuses();
    final names = statuses
        .where((status) => status.isCompatible)
        .map((status) => status.name)
        .toList();
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
    final stored = await getStoredCurrentLayoutName();
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

  Future<rust_config.DocumentLayoutPreset> getDefaultLayout([
    String name = 'Default',
  ]) async {
    final templateNames = await rust_config.listTemplatePresets();
    final templateName = templateNames.isNotEmpty
        ? templateNames.first
        : 'Default';

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
          templateCount: 1,
          rows: 1,
          cols: 1,
          templatePadTopMm: 1.0,
          templatePadLeftMm: 1.0,
          templatePadRightMm: 1.0,
          templatePadBottomMm: 1.0,
          pageBreakAfter: false,
          sortField: null,
          sortDirection: rust_config.DocumentSortDirection.ascending,
        ),
      ],
      fillPage: false,
      multiBlockMode: 'Continuous',
    );
  }
}

extension DocumentLayoutBlockExtension on rust_config.DocumentLayoutBlock {
  /// A negative row count stores auto-fill at block scope while preserving the
  /// last fixed row count for when auto-fill is disabled again.
  bool get autoFillPage => rows < 0;

  int get fixedRows => rows.abs().clamp(1, 200);

  rust_config.DocumentLayoutBlock copyWith({
    String? templateName,
    int? templateCount,
    int? rows,
    int? cols,
    double? templatePadTopMm,
    double? templatePadLeftMm,
    double? templatePadRightMm,
    double? templatePadBottomMm,
    bool? pageBreakAfter,
    String? sortField,
    bool clearSortField = false,
    rust_config.DocumentSortDirection? sortDirection,
  }) {
    return rust_config.DocumentLayoutBlock(
      templateName: templateName ?? this.templateName,
      templateCount: templateCount ?? this.templateCount,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      templatePadTopMm: templatePadTopMm ?? this.templatePadTopMm,
      templatePadLeftMm: templatePadLeftMm ?? this.templatePadLeftMm,
      templatePadRightMm: templatePadRightMm ?? this.templatePadRightMm,
      templatePadBottomMm: templatePadBottomMm ?? this.templatePadBottomMm,
      pageBreakAfter: pageBreakAfter ?? this.pageBreakAfter,
      sortField: clearSortField ? null : sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }

  rust_config.DocumentLayoutBlock copyWithAutoFill(bool enabled) {
    return copyWith(rows: enabled ? -fixedRows : fixedRows);
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
    bool? fillPage,
    String? multiBlockMode,
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
      fillPage: fillPage ?? this.fillPage,
      multiBlockMode: multiBlockMode ?? this.multiBlockMode,
    );
  }
}

extension DocumentLayoutBlockJson on rust_config.DocumentLayoutBlock {
  Map<String, dynamic> toJson() => {
    'templateName': templateName,
    'templateCount': templateCount,
    'rows': rows,
    'cols': cols,
    'templatePadTopMm': templatePadTopMm,
    'templatePadLeftMm': templatePadLeftMm,
    'templatePadRightMm': templatePadRightMm,
    'templatePadBottomMm': templatePadBottomMm,
    'pageBreakAfter': pageBreakAfter,
    'sortField': sortField,
    'sortDirection': sortDirection.name,
  };

  static rust_config.DocumentLayoutBlock fromJson(Map<String, dynamic> json) {
    return rust_config.DocumentLayoutBlock(
      templateName: _jsonValue(json, 'templateName', 'template_name') as String,
      templateCount: _jsonValue(json, 'templateCount', 'template_count') as int,
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      templatePadTopMm:
          (_jsonValue(json, 'templatePadTopMm', 'template_pad_top_mm') as num)
              .toDouble(),
      templatePadLeftMm:
          (_jsonValue(json, 'templatePadLeftMm', 'template_pad_left_mm') as num)
              .toDouble(),
      templatePadRightMm:
          (_jsonValue(json, 'templatePadRightMm', 'template_pad_right_mm')
                  as num)
              .toDouble(),
      templatePadBottomMm:
          (_jsonValue(json, 'templatePadBottomMm', 'template_pad_bottom_mm')
                  as num)
              .toDouble(),
      pageBreakAfter:
          _jsonValue(json, 'pageBreakAfter', 'page_break_after') as bool,
      sortField: _jsonValue(json, 'sortField', 'sort_field') as String?,
      sortDirection: rust_config.DocumentSortDirection.values.firstWhere(
        (direction) =>
            direction.name ==
            _jsonValue(json, 'sortDirection', 'sort_direction'),
        orElse: () => rust_config.DocumentSortDirection.ascending,
      ),
    );
  }
}

extension DocumentLayoutPresetJson on rust_config.DocumentLayoutPreset {
  Map<String, dynamic> toJson() => {
    'name': name,
    'layoutType': layoutType,
    'pageSizeKey': pageSizeKey,
    'pageOrientation': pageOrientation,
    'customPageWidthMm': customPageWidthMm,
    'customPageHeightMm': customPageHeightMm,
    'pagePadTopMm': pagePadTopMm,
    'pagePadLeftMm': pagePadLeftMm,
    'pagePadRightMm': pagePadRightMm,
    'pagePadBottomMm': pagePadBottomMm,
    'blocks': blocks.map((b) => b.toJson()).toList(),
    'fillPage': fillPage,
    'multiBlockMode': multiBlockMode,
  };

  static rust_config.DocumentLayoutPreset fromJson(Map<String, dynamic> json) {
    return rust_config.DocumentLayoutPreset(
      name: json['name'] as String,
      layoutType: _jsonValue(json, 'layoutType', 'layout_type') as String,
      pageSizeKey: _jsonValue(json, 'pageSizeKey', 'page_size_key') as String,
      pageOrientation:
          _jsonValue(json, 'pageOrientation', 'page_orientation') as String,
      customPageWidthMm:
          (_jsonValue(json, 'customPageWidthMm', 'custom_page_width_mm')
                  as num?)
              ?.toDouble(),
      customPageHeightMm:
          (_jsonValue(json, 'customPageHeightMm', 'custom_page_height_mm')
                  as num?)
              ?.toDouble(),
      pagePadTopMm: (_jsonValue(json, 'pagePadTopMm', 'page_pad_top_mm') as num)
          .toDouble(),
      pagePadLeftMm:
          (_jsonValue(json, 'pagePadLeftMm', 'page_pad_left_mm') as num)
              .toDouble(),
      pagePadRightMm:
          (_jsonValue(json, 'pagePadRightMm', 'page_pad_right_mm') as num)
              .toDouble(),
      pagePadBottomMm:
          (_jsonValue(json, 'pagePadBottomMm', 'page_pad_bottom_mm') as num)
              .toDouble(),
      blocks: (json['blocks'] as List)
          .map(
            (b) => DocumentLayoutBlockJson.fromJson(
              Map<String, dynamic>.from(b as Map),
            ),
          )
          .toList(),
      fillPage: _jsonValue(json, 'fillPage', 'fill_page') as bool? ?? false,
      multiBlockMode:
          _jsonValue(json, 'multiBlockMode', 'multi_block_mode') as String? ??
          'Continuous',
    );
  }
}

dynamic _jsonValue(
  Map<String, dynamic> json,
  String camelCaseKey,
  String snakeCaseKey,
) {
  return json[camelCaseKey] ?? json[snakeCaseKey];
}
