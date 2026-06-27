import 'dart:convert';
import 'dart:io';

/// Non-empty path that exists on disk (safe for file-based image widgets).
bool isLabelImagePathUsable(String path) {
  final p = path.trim();
  if (p.isEmpty) return false;
  try {
    return File(p).existsSync();
  } catch (_) {
    return false;
  }
}

/// Whole-line text `[mammal.sex]-img` → show sex as a resizable icon (see [isLabelBracketGenderIconText]).
final RegExp kLabelGenderIconBracketText = RegExp(
  r'^\s*\[([^\]]+)\]-img\s*$',
  caseSensitive: false,
);

/// Field id inside brackets, e.g. `mammal.sex`, when [text] is `[mammal.sex]-img`.
String? labelGenderIconFieldKeyFromBracketText(String text) {
  final m = kLabelGenderIconBracketText.firstMatch(text.trim());
  if (m == null) return null;
  final key = m.group(1)!.trim();
  if (!key.toLowerCase().endsWith('.sex')) return null;
  return key;
}

bool isLabelBracketGenderIconText(String text) =>
    labelGenderIconFieldKeyFromBracketText(text) != null;

const double kLabelGenderIconDefaultWidthMm = 6.0;
const double kLabelGenderIconDefaultHeightMm = 6.0;

class CustomTextElement {
  const CustomTextElement({
    required this.id,
    required this.text,
    required this.xMm,
    required this.yMm,
    this.fontSizePt = 10.0,
    this.fontFamily = '',
    this.bold = false,
    this.italic = false,
    this.rotationDegrees = 0,
    this.iconWidthMm,
    this.iconHeightMm,
  });

  final String id;
  final String text;
  final double xMm;
  final double yMm;
  final double fontSizePt;
  final String fontFamily;
  final bool bold;
  final bool italic;
  final int rotationDegrees;

  /// For [isLabelBracketGenderIconText] only: box size in mm (defaults in editor/PDF).
  final double? iconWidthMm;
  final double? iconHeightMm;

  CustomTextElement copyWith({
    String? id,
    String? text,
    double? xMm,
    double? yMm,
    double? fontSizePt,
    String? fontFamily,
    bool? bold,
    bool? italic,
    int? rotationDegrees,
    double? iconWidthMm,
    double? iconHeightMm,
  }) {
    return CustomTextElement(
      id: id ?? this.id,
      text: text ?? this.text,
      xMm: xMm ?? this.xMm,
      yMm: yMm ?? this.yMm,
      fontSizePt: fontSizePt ?? this.fontSizePt,
      fontFamily: fontFamily ?? this.fontFamily,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      iconWidthMm: iconWidthMm ?? this.iconWidthMm,
      iconHeightMm: iconHeightMm ?? this.iconHeightMm,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'xMm': xMm,
        'yMm': yMm,
        'fontSizePt': fontSizePt,
        'fontFamily': fontFamily,
        'bold': bold,
        'italic': italic,
        'rotationDegrees': rotationDegrees,
        if (iconWidthMm != null) 'iconWidthMm': iconWidthMm,
        if (iconHeightMm != null) 'iconHeightMm': iconHeightMm,
      };

  factory CustomTextElement.fromJson(Map<String, dynamic> json) {
    return CustomTextElement(
      id: json['id'] as String,
      text: json['text'] as String? ?? '',
      xMm: (json['xMm'] as num?)?.toDouble() ?? 0,
      yMm: (json['yMm'] as num?)?.toDouble() ?? 0,
      fontSizePt: (json['fontSizePt'] as num?)?.toDouble() ?? 10,
      fontFamily: json['fontFamily'] as String? ?? '',
      bold: json['bold'] as bool? ?? false,
      italic: json['italic'] as bool? ?? false,
      rotationDegrees: (json['rotationDegrees'] as num?)?.toInt() ?? 0,
      iconWidthMm: (json['iconWidthMm'] as num?)?.toDouble(),
      iconHeightMm: (json['iconHeightMm'] as num?)?.toDouble(),
    );
  }
}

class CustomImageElement {
  const CustomImageElement({
    required this.id,
    required this.imagePath,
    required this.xMm,
    required this.yMm,
    required this.widthMm,
    required this.heightMm,
    this.rotationDegrees = 0,
  });

  final String id;
  final String imagePath;
  final double xMm;
  final double yMm;
  final double widthMm;
  final double heightMm;
  final int rotationDegrees;

  CustomImageElement copyWith({
    String? id,
    String? imagePath,
    double? xMm,
    double? yMm,
    double? widthMm,
    double? heightMm,
    int? rotationDegrees,
  }) {
    return CustomImageElement(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      xMm: xMm ?? this.xMm,
      yMm: yMm ?? this.yMm,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'xMm': xMm,
        'yMm': yMm,
        'widthMm': widthMm,
        'heightMm': heightMm,
        'rotationDegrees': rotationDegrees,
      };

  factory CustomImageElement.fromJson(Map<String, dynamic> json) {
    return CustomImageElement(
      id: json['id'] as String,
      imagePath: (json['imagePath'] as String?)?.trim() ?? '',
      xMm: (json['xMm'] as num?)?.toDouble() ?? 0,
      yMm: (json['yMm'] as num?)?.toDouble() ?? 0,
      widthMm: (json['widthMm'] as num?)?.toDouble() ?? 20,
      heightMm: (json['heightMm'] as num?)?.toDouble() ?? 20,
      rotationDegrees: (json['rotationDegrees'] as num?)?.toInt() ?? 0,
    );
  }

  /// Snap rotation to whole degrees in [0, 359].
  static int normalizeImageRotationDegrees(num degrees) {
    var d = degrees.round() % 360;
    if (d < 0) d += 360;
    return d;
  }
}

class LabelPageTemplate {
  const LabelPageTemplate({
    this.customTexts = const [],
    this.customImages = const [],
  });

  final List<CustomTextElement> customTexts;
  final List<CustomImageElement> customImages;

  LabelPageTemplate copyWith({
    List<CustomTextElement>? customTexts,
    List<CustomImageElement>? customImages,
  }) {
    return LabelPageTemplate(
      customTexts: customTexts ?? this.customTexts,
      customImages: customImages ?? this.customImages,
    );
  }

  LabelPageTemplate withCustomText(CustomTextElement e) {
    final next = [...customTexts];
    final i = next.indexWhere((t) => t.id == e.id);
    if (i >= 0) {
      next[i] = e;
    } else {
      next.add(e);
    }
    return copyWith(customTexts: next);
  }

  LabelPageTemplate withoutCustomText(String id) {
    return copyWith(customTexts: customTexts.where((t) => t.id != id).toList());
  }

  LabelPageTemplate withCustomImage(CustomImageElement e) {
    final next = [...customImages];
    final i = next.indexWhere((im) => im.id == e.id);
    if (i >= 0) {
      next[i] = e;
    } else {
      next.add(e);
    }
    return copyWith(customImages: next);
  }

  LabelPageTemplate withoutCustomImage(String id) {
    return copyWith(
        customImages: customImages.where((im) => im.id != id).toList());
  }

  Map<String, dynamic> toJson() => {
        'customTexts': customTexts.map((e) => e.toJson()).toList(),
        'customImages': customImages.map((e) => e.toJson()).toList(),
      };

  factory LabelPageTemplate.fromJson(Map<String, dynamic> json) {
    return LabelPageTemplate(
      customTexts: (json['customTexts'] as List<dynamic>?)
              ?.map(
                  (e) => CustomTextElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      customImages: (json['customImages'] as List<dynamic>?)
              ?.map(
                  (e) => CustomImageElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Duplex and 180° print rotation per side; stored in template JSON.
class LabelTemplatePrintOptions {
  const LabelTemplatePrintOptions({
    required this.isDuplex,
    required this.mirrorFront,
    required this.mirrorBack,
    this.pageSizeKey,
    this.rowsPerPage,
    this.colsPerPage,
    this.pagePadTopMm,
    this.pagePadLeftMm,
    this.pagePadRightMm,
    this.pagePadBottomMm,
    this.labelPadTopMm,
    this.labelPadLeftMm,
    this.labelPadRightMm,
    this.labelPadBottomMm,
  });

  final bool isDuplex;
  final bool mirrorFront;
  final bool mirrorBack;
  final String? pageSizeKey;
  final int? rowsPerPage;
  final int? colsPerPage;
  final double? pagePadTopMm;
  final double? pagePadLeftMm;
  final double? pagePadRightMm;
  final double? pagePadBottomMm;
  final double? labelPadTopMm;
  final double? labelPadLeftMm;
  final double? labelPadRightMm;
  final double? labelPadBottomMm;

  Map<String, dynamic> toJson() => {
        'isDuplex': isDuplex,
        'mirrorFront': mirrorFront,
        'mirrorBack': mirrorBack,
        if (pageSizeKey != null) 'pageSizeKey': pageSizeKey,
        if (rowsPerPage != null) 'rowsPerPage': rowsPerPage,
        if (colsPerPage != null) 'colsPerPage': colsPerPage,
        if (pagePadTopMm != null) 'pagePadTopMm': pagePadTopMm,
        if (pagePadLeftMm != null) 'pagePadLeftMm': pagePadLeftMm,
        if (pagePadRightMm != null) 'pagePadRightMm': pagePadRightMm,
        if (pagePadBottomMm != null) 'pagePadBottomMm': pagePadBottomMm,
        if (labelPadTopMm != null) 'labelPadTopMm': labelPadTopMm,
        if (labelPadLeftMm != null) 'labelPadLeftMm': labelPadLeftMm,
        if (labelPadRightMm != null) 'labelPadRightMm': labelPadRightMm,
        if (labelPadBottomMm != null) 'labelPadBottomMm': labelPadBottomMm,
      };

  factory LabelTemplatePrintOptions.fromJson(Map<String, dynamic> json) {
    return LabelTemplatePrintOptions(
      isDuplex: json['isDuplex'] as bool? ?? false,
      mirrorFront: json['mirrorFront'] as bool? ?? false,
      mirrorBack: json['mirrorBack'] as bool? ?? false,
      pageSizeKey: json['pageSizeKey'] as String?,
      rowsPerPage: (json['rowsPerPage'] as num?)?.toInt(),
      colsPerPage: (json['colsPerPage'] as num?)?.toInt(),
      pagePadTopMm: (json['pagePadTopMm'] as num?)?.toDouble(),
      pagePadLeftMm: (json['pagePadLeftMm'] as num?)?.toDouble(),
      pagePadRightMm: (json['pagePadRightMm'] as num?)?.toDouble(),
      pagePadBottomMm: (json['pagePadBottomMm'] as num?)?.toDouble(),
      labelPadTopMm: (json['labelPadTopMm'] as num?)?.toDouble(),
      labelPadLeftMm: (json['labelPadLeftMm'] as num?)?.toDouble(),
      labelPadRightMm: (json['labelPadRightMm'] as num?)?.toDouble(),
      labelPadBottomMm: (json['labelPadBottomMm'] as num?)?.toDouble(),
    );
  }
}

LabelTemplatePrintOptions? labelTemplatePrintOptionsFromJson(
  Map<String, dynamic> json,
) {
  final nested = json['printOptions'];
  if (nested is Map) {
    return LabelTemplatePrintOptions.fromJson(
      Map<String, dynamic>.from(nested),
    );
  }
  if (json.containsKey('isDuplex') ||
      json.containsKey('mirrorFront') ||
      json.containsKey('mirrorBack') ||
      json.containsKey('pageSizeKey') ||
      json.containsKey('rowsPerPage') ||
      json.containsKey('colsPerPage') ||
      json.containsKey('pagePadTopMm') ||
      json.containsKey('pagePadLeftMm') ||
      json.containsKey('pagePadRightMm') ||
      json.containsKey('pagePadBottomMm') ||
      json.containsKey('labelPadTopMm') ||
      json.containsKey('labelPadLeftMm') ||
      json.containsKey('labelPadRightMm') ||
      json.containsKey('labelPadBottomMm')) {
    return LabelTemplatePrintOptions.fromJson(json);
  }
  return null;
}

LabelTemplateOutlineStyle labelTemplateOutlineStyleFromJson(String? s) {
  switch (s) {
    case 'dashed':
      return LabelTemplateOutlineStyle.dashed;
    case 'dotted':
      return LabelTemplateOutlineStyle.dotted;
    case 'double':
      return LabelTemplateOutlineStyle.doubleLine;
    default:
      return LabelTemplateOutlineStyle.solid;
  }
}

String labelTemplateOutlineStyleToJson(LabelTemplateOutlineStyle s) {
  switch (s) {
    case LabelTemplateOutlineStyle.solid:
      return 'solid';
    case LabelTemplateOutlineStyle.dashed:
      return 'dashed';
    case LabelTemplateOutlineStyle.dotted:
      return 'dotted';
    case LabelTemplateOutlineStyle.doubleLine:
      return 'double';
  }
}

/// Line style for the optional rectangle drawn around the label in editor, preview, and PDF.
enum LabelTemplateOutlineStyle {
  solid,
  dashed,
  dotted,
  doubleLine,
}

/// Per-template outline around the label area (saved with the template JSON).
class LabelTemplateOutline {
  const LabelTemplateOutline({
    this.style = LabelTemplateOutlineStyle.solid,
    this.widthPt = 1.5,
    this.colorArgb = 0xFF757575,
  });

  final LabelTemplateOutlineStyle style;

  /// Stroke width in PDF points (1 pt = 1/72 in).
  final double widthPt;

  /// 0xAARRGGBB (same convention as [Color.value]).
  final int colorArgb;

  LabelTemplateOutline copyWith({
    LabelTemplateOutlineStyle? style,
    double? widthPt,
    int? colorArgb,
  }) {
    return LabelTemplateOutline(
      style: style ?? this.style,
      widthPt: widthPt ?? this.widthPt,
      colorArgb: colorArgb ?? this.colorArgb,
    );
  }

  Map<String, dynamic> toJson() => {
        'style': labelTemplateOutlineStyleToJson(style),
        'widthPt': widthPt,
        'colorArgb': colorArgb,
      };

  factory LabelTemplateOutline.fromJson(Map<String, dynamic> json) {
    return LabelTemplateOutline(
      style: labelTemplateOutlineStyleFromJson(json['style'] as String?),
      widthPt: (json['widthPt'] as num?)?.toDouble() ?? 1.5,
      colorArgb: (json['colorArgb'] as num?)?.toInt() ?? 0xFF757575,
    );
  }
}

class LabelTemplate {
  const LabelTemplate({
    required this.name,
    required this.page1,
    required this.page2,
    this.printOptions,
    this.outline,
  });

  final String name;
  final LabelPageTemplate page1;
  final LabelPageTemplate page2;

  /// When null (legacy files), the editor uses app label settings instead.
  final LabelTemplatePrintOptions? printOptions;

  /// When null, no outline is drawn on the label.
  final LabelTemplateOutline? outline;

  LabelTemplate copyWith({
    String? name,
    LabelPageTemplate? page1,
    LabelPageTemplate? page2,
    LabelTemplatePrintOptions? printOptions,
    bool clearPrintOptions = false,
    LabelTemplateOutline? outline,
    bool clearOutline = false,
  }) {
    return LabelTemplate(
      name: name ?? this.name,
      page1: page1 ?? this.page1,
      page2: page2 ?? this.page2,
      printOptions:
          clearPrintOptions ? null : (printOptions ?? this.printOptions),
      outline: clearOutline ? null : (outline ?? this.outline),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'page1': page1.toJson(),
        'page2': page2.toJson(),
        if (printOptions != null) 'printOptions': printOptions!.toJson(),
        if (outline != null) 'outline': outline!.toJson(),
      };

  factory LabelTemplate.fromJson(Map<String, dynamic> json) {
    final opts = labelTemplatePrintOptionsFromJson(json);
    LabelTemplateOutline? outline;
    final o = json['outline'];
    if (o is Map) {
      final m = Map<String, dynamic>.from(o);
      if (m['enabled'] == false) {
        outline = null;
      } else {
        outline = LabelTemplateOutline.fromJson(m);
      }
    }
    return LabelTemplate(
      name: json['name'] as String? ?? 'Default',
      page1: LabelPageTemplate.fromJson(
        json['page1'] as Map<String, dynamic>? ?? {},
      ),
      page2: LabelPageTemplate.fromJson(
        json['page2'] as Map<String, dynamic>? ?? {},
      ),
      printOptions: opts,
      outline: outline,
    );
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  static LabelTemplate fromJsonString(String s) {
    final decoded = jsonDecode(s);
    if (decoded is! Map) {
      throw FormatException('Label template JSON must be an object');
    }
    return LabelTemplate.fromJson(Map<String, dynamic>.from(decoded));
  }
}

class DefaultLabelTemplate {
  static LabelTemplate defaultTemplate([String name = 'Default']) {
    return LabelTemplate(
      name: name,
      page1: const LabelPageTemplate(),
      page2: const LabelPageTemplate(),
      printOptions: null,
    );
  }
}
