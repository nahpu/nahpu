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

String formatTextWithCase(String rawText, String caseFormat) {
  switch (caseFormat) {
    case 'uppercase':
      return rawText.toUpperCase();
    case 'lowercase':
      return rawText.toLowerCase();
    case 'capitalize':
      if (rawText.isEmpty) return rawText;
      return rawText.split(' ').map((word) {
        if (word.isEmpty) return word;
        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      }).join(' ');
    default:
      return rawText;
  }
}

String formatCoordinatesText(String text, String format) {
  final pairRegex = RegExp(
    r'(-?\d+\.\d+|-?\d+)\s*[\s,;/|]\s*(-?\d+\.\d+|-?\d+)',
  );
  final match = pairRegex.firstMatch(text);
  if (match != null) {
    final latStr = match.group(1)!;
    final lngStr = match.group(2)!;
    final lat = double.tryParse(latStr);
    final lng = double.tryParse(lngStr);
    if (lat != null && lng != null) {
      final formatted = _formatPair(lat, lng, format);
      return text.replaceFirst(pairRegex, formatted);
    }
  }
  return text;
}

String _formatSingle(double value, String type, String format) {
  final isLat = type == 'lat';
  final cardinal = isLat ? (value >= 0 ? 'N' : 'S') : (value >= 0 ? 'E' : 'W');
  final absVal = value.abs();

  if (format == 'cardinalDecimal') {
    return "${absVal.toStringAsFixed(5)}° $cardinal";
  } else if (format == 'dms') {
    final d = absVal.floor();
    final mVal = (absVal - d) * 60;
    final m = mVal.floor();
    final s = ((mVal - m) * 60).toStringAsFixed(1);
    return "$d° $m' $s\" $cardinal";
  } else if (format == 'ddm') {
    final d = absVal.floor();
    final mVal = (absVal - d) * 60;
    final m = mVal.toStringAsFixed(3);
    return "$d° $m' $cardinal";
  } else {
    return value.toStringAsFixed(5);
  }
}

String _formatPair(double lat, double lng, String format) {
  if (format == 'decimal') {
    return "${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}";
  }
  final latFmt = _formatSingle(lat, 'lat', format);
  final lngFmt = _formatSingle(lng, 'lng', format);
  return "$latFmt, $lngFmt";
}

String formatDateText(String text, String formatOption) {
  final dateRegex = RegExp(r'(\d{4})-(\d{2})-(\d{2})');
  final match = dateRegex.firstMatch(text);
  if (match != null) {
    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final day = int.tryParse(match.group(3)!);
    if (year != null && month != null && day != null) {
      final dt = DateTime(year, month, day);
      final formatted = _formatDate(dt, formatOption);
      return text.replaceFirst(dateRegex, formatted);
    }
  }

  final dt = DateTime.tryParse(text);
  if (dt != null) {
    return _formatDate(dt, formatOption);
  }

  return text;
}

String _formatDate(DateTime dt, String format) {
  final months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  final monthAbbr = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  final y = dt.year.toString();
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');

  switch (format) {
    case 'yyyy-mm-dd':
      return "$y-$m-$d";
    case 'dd-mm-yyyy':
      return "$d-$m-$y";
    case 'mm-dd-yyyy':
      return "$m-$d-$y";
    case 'dd/mm/yyyy':
      return "$d/$m/$y";
    case 'mm/dd/yyyy':
      return "$m/$d/$y";
    case 'month-dd-yyyy':
      return "${months[dt.month - 1]} ${dt.day}, $y";
    case 'dd-month-yyyy':
      return "${dt.day} ${months[dt.month - 1]} $y";
    case 'dd-month-abbr-yyyy':
      return "${dt.day} ${monthAbbr[dt.month - 1]} $y";
    default:
      return "$y-$m-$d";
  }
}

String formatListText(String text, String formatOption) {
  List<String> items;
  if (text.contains(' | ')) {
    items = text.split(' | ').map((s) => s.trim()).toList();
  } else if (text.contains('; ')) {
    items = text.split('; ').map((s) => s.trim()).toList();
  } else {
    items = [text];
  }

  items = items.where((item) => item.isNotEmpty).toList();
  if (items.isEmpty) return text;

  if (formatOption.startsWith('custom:')) {
    final customSep = formatOption.substring(7);
    return items.join(customSep);
  }

  switch (formatOption) {
    case 'comma':
      return items.join(', ');
    case 'semicolon':
      return items.join('; ');
    case 'slash':
      return items.join(' / ');
    case 'newline':
      return items.join('\n');
    case 'bullet':
      return items.map((e) => '• $e').join('\n');
    default:
      return text;
  }
}

String formatSexText(String text, String formatOption) {
  final cleanText = text.trim().toLowerCase();

  final parts = formatOption.split(':');
  final presentation = parts.isNotEmpty ? parts[0] : 'text';
  final missingOpt = parts.length > 1 ? parts[1] : 'unknown';

  final isMale = cleanText == '0' || cleanText == 'male' || cleanText == 'm';
  final isFemale =
      cleanText == '1' || cleanText == 'female' || cleanText == 'f';

  if (isMale) {
    if (presentation == 'symbol') return '\u2642'; // ♂
    if (presentation == 'letter') return 'M';
    return 'Male';
  } else if (isFemale) {
    if (presentation == 'symbol') return '\u2640'; // ♀
    if (presentation == 'letter') return 'F';
    return 'Female';
  } else {
    switch (missingOpt) {
      case 'na':
        return 'N/A';
      case 'none':
        return '';
      case 'unknown':
      default:
        if (presentation == 'symbol') return '?';
        if (presentation == 'letter') return 'U';
        return 'Unknown';
    }
  }
}

String formatNumberText(String text, String formatOption) {
  if (formatOption == 'original' || formatOption == 'normal') return text;

  final decimals = int.tryParse(formatOption);
  if (decimals == null) return text;

  final numRegex = RegExp(r'\b\d+\.\d+\b|\b\d+\b');
  return text.replaceAllMapped(numRegex, (match) {
    final valStr = match.group(0)!;
    final val = double.tryParse(valStr);
    if (val != null) {
      return val.toStringAsFixed(decimals);
    }
    return valStr;
  });
}

String formatFieldPlaceholderText(String text, bool showFieldOnly) {
  if (!showFieldOnly) return text;
  final regex = RegExp(r'\[([^\]\s]+)::([^\]\s]+)\]');
  return text.replaceAllMapped(regex, (match) => '[${match.group(2)}]');
}

String formatLabelText(
  String rawText,
  String textType,
  String formatOption, [
  String? oldCaseFormat,
]) {
  if (rawText.isEmpty && textType != 'sex') return rawText;

  String result;
  switch (textType) {
    case 'coordinates':
      result = formatCoordinatesText(rawText, formatOption);
      break;
    case 'date':
      result = formatDateText(rawText, formatOption);
      break;
    case 'list':
      result = formatListText(rawText, formatOption);
      break;
    case 'sex':
      result = formatSexText(rawText, formatOption);
      break;
    case 'number':
      result = formatNumberText(rawText, formatOption);
      break;
    case 'normal':
    default:
      String currentCase = formatOption;
      if (currentCase == 'normal' &&
          oldCaseFormat != null &&
          oldCaseFormat != 'normal') {
        currentCase = oldCaseFormat;
      }
      result = formatTextWithCase(rawText, currentCase);
      break;
  }
  return result;
}

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
    this.textAlign = 'left',
    this.caseFormat = 'normal',
    this.rotationDegrees = 0,
    this.iconWidthMm,
    this.iconHeightMm,
    this.maxWidthMm,
    this.zIndex = 0,
    this.colorArgb = 0xFF000000,
    this.textType = 'normal',
    this.formatOption = 'normal',
  });

  final String id;
  final String text;
  final double xMm;
  final double yMm;
  final double fontSizePt;
  final String fontFamily;
  final bool bold;
  final bool italic;
  final String textAlign;
  final String caseFormat;
  final int rotationDegrees;
  final int zIndex;
  final int colorArgb;
  final String textType;
  final String formatOption;

  /// For [isLabelBracketGenderIconText] only: box size in mm (defaults in editor/PDF).
  final double? iconWidthMm;
  final double? iconHeightMm;

  /// If non-null, text wraps to this width.
  final double? maxWidthMm;

  CustomTextElement copyWith({
    String? id,
    String? text,
    double? xMm,
    double? yMm,
    double? fontSizePt,
    String? fontFamily,
    bool? bold,
    bool? italic,
    String? textAlign,
    String? caseFormat,
    int? rotationDegrees,
    double? iconWidthMm,
    double? iconHeightMm,
    double? maxWidthMm,
    int? zIndex,
    int? colorArgb,
    bool clearMaxWidthMm = false,
    String? textType,
    String? formatOption,
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
      textAlign: textAlign ?? this.textAlign,
      caseFormat: caseFormat ?? this.caseFormat,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      iconWidthMm: iconWidthMm ?? this.iconWidthMm,
      iconHeightMm: iconHeightMm ?? this.iconHeightMm,
      maxWidthMm: clearMaxWidthMm ? null : (maxWidthMm ?? this.maxWidthMm),
      zIndex: zIndex ?? this.zIndex,
      colorArgb: colorArgb ?? this.colorArgb,
      textType: textType ?? this.textType,
      formatOption: formatOption ?? this.formatOption,
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
        'textAlign': textAlign,
        'caseFormat': caseFormat,
        'rotationDegrees': rotationDegrees,
        if (iconWidthMm != null) 'iconWidthMm': iconWidthMm,
        if (iconHeightMm != null) 'iconHeightMm': iconHeightMm,
        if (maxWidthMm != null) 'maxWidthMm': maxWidthMm,
        'zIndex': zIndex,
        'colorArgb': colorArgb,
        'textType': textType,
        'formatOption': formatOption,
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
      textAlign: json['textAlign'] as String? ?? 'left',
      caseFormat: json['caseFormat'] as String? ?? 'normal',
      rotationDegrees: (json['rotationDegrees'] as num?)?.toInt() ?? 0,
      iconWidthMm: (json['iconWidthMm'] as num?)?.toDouble(),
      iconHeightMm: (json['iconHeightMm'] as num?)?.toDouble(),
      maxWidthMm: (json['maxWidthMm'] as num?)?.toDouble(),
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
      colorArgb: (json['colorArgb'] as num?)?.toInt() ?? 0xFF000000,
      textType: json['textType'] as String? ?? 'normal',
      formatOption: json['formatOption'] as String? ?? 'normal',
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
    this.zIndex = 0,
  });

  final String id;
  final String imagePath;
  final double xMm;
  final double yMm;
  final double widthMm;
  final double heightMm;
  final int rotationDegrees;
  final int zIndex;

  CustomImageElement copyWith({
    String? id,
    String? imagePath,
    double? xMm,
    double? yMm,
    double? widthMm,
    double? heightMm,
    int? rotationDegrees,
    int? zIndex,
  }) {
    return CustomImageElement(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      xMm: xMm ?? this.xMm,
      yMm: yMm ?? this.yMm,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      zIndex: zIndex ?? this.zIndex,
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
        'zIndex': zIndex,
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
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
    );
  }

  /// Snap rotation to whole degrees in [0, 359].
  static int normalizeImageRotationDegrees(num degrees) {
    var d = degrees.round() % 360;
    if (d < 0) d += 360;
    return d;
  }
}

class CustomLineElement {
  const CustomLineElement({
    required this.id,
    required this.xMm,
    required this.yMm,
    required this.lengthMm,
    this.rotationDegrees = 0,
    this.thicknessPt = 1.0,
    this.colorArgb = 0xFF000000,
    this.zIndex = 0,
  });

  final String id;
  final double xMm;
  final double yMm;
  final double lengthMm;
  final int rotationDegrees;
  final double thicknessPt;
  final int colorArgb;
  final int zIndex;

  CustomLineElement copyWith({
    String? id,
    double? xMm,
    double? yMm,
    double? lengthMm,
    int? rotationDegrees,
    double? thicknessPt,
    int? colorArgb,
    int? zIndex,
  }) {
    return CustomLineElement(
      id: id ?? this.id,
      xMm: xMm ?? this.xMm,
      yMm: yMm ?? this.yMm,
      lengthMm: lengthMm ?? this.lengthMm,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      thicknessPt: thicknessPt ?? this.thicknessPt,
      colorArgb: colorArgb ?? this.colorArgb,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'xMm': xMm,
        'yMm': yMm,
        'lengthMm': lengthMm,
        'rotationDegrees': rotationDegrees,
        'thicknessPt': thicknessPt,
        'colorArgb': colorArgb,
        'zIndex': zIndex,
      };

  factory CustomLineElement.fromJson(Map<String, dynamic> json) {
    return CustomLineElement(
      id: json['id'] as String,
      xMm: (json['xMm'] as num?)?.toDouble() ?? 0,
      yMm: (json['yMm'] as num?)?.toDouble() ?? 0,
      lengthMm: (json['lengthMm'] as num?)?.toDouble() ?? 20,
      rotationDegrees: (json['rotationDegrees'] as num?)?.toInt() ?? 0,
      thicknessPt: (json['thicknessPt'] as num?)?.toDouble() ?? 1.0,
      colorArgb: (json['colorArgb'] as num?)?.toInt() ?? 0xFF000000,
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
    );
  }
}

class CustomShapeElement {
  const CustomShapeElement({
    required this.id,
    required this.xMm,
    required this.yMm,
    required this.widthMm,
    required this.heightMm,
    required this.shapeType,
    this.rotationDegrees = 0,
    this.strokeThicknessPt = 1.0,
    this.strokeColorArgb = 0xFF000000,
    this.fillColorArgb,
    this.zIndex = 0,
  });

  final String id;
  final double xMm;
  final double yMm;
  final double widthMm;
  final double heightMm;
  final String shapeType; // 'rect', 'ellipse'
  final int rotationDegrees;
  final double strokeThicknessPt;
  final int strokeColorArgb;
  final int? fillColorArgb;
  final int zIndex;

  CustomShapeElement copyWith({
    String? id,
    double? xMm,
    double? yMm,
    double? widthMm,
    double? heightMm,
    String? shapeType,
    int? rotationDegrees,
    double? strokeThicknessPt,
    int? strokeColorArgb,
    int? fillColorArgb,
    bool clearFillColor = false,
    int? zIndex,
  }) {
    return CustomShapeElement(
      id: id ?? this.id,
      xMm: xMm ?? this.xMm,
      yMm: yMm ?? this.yMm,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      shapeType: shapeType ?? this.shapeType,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      strokeThicknessPt: strokeThicknessPt ?? this.strokeThicknessPt,
      strokeColorArgb: strokeColorArgb ?? this.strokeColorArgb,
      fillColorArgb:
          clearFillColor ? null : (fillColorArgb ?? this.fillColorArgb),
      zIndex: zIndex ?? this.zIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'xMm': xMm,
        'yMm': yMm,
        'widthMm': widthMm,
        'heightMm': heightMm,
        'shapeType': shapeType,
        'rotationDegrees': rotationDegrees,
        'strokeThicknessPt': strokeThicknessPt,
        'strokeColorArgb': strokeColorArgb,
        if (fillColorArgb != null) 'fillColorArgb': fillColorArgb,
        'zIndex': zIndex,
      };

  factory CustomShapeElement.fromJson(Map<String, dynamic> json) {
    return CustomShapeElement(
      id: json['id'] as String,
      xMm: (json['xMm'] as num?)?.toDouble() ?? 0,
      yMm: (json['yMm'] as num?)?.toDouble() ?? 0,
      widthMm: (json['widthMm'] as num?)?.toDouble() ?? 20,
      heightMm: (json['heightMm'] as num?)?.toDouble() ?? 20,
      shapeType: json['shapeType'] as String? ?? 'rect',
      rotationDegrees: (json['rotationDegrees'] as num?)?.toInt() ?? 0,
      strokeThicknessPt: (json['strokeThicknessPt'] as num?)?.toDouble() ?? 1.0,
      strokeColorArgb: (json['strokeColorArgb'] as num?)?.toInt() ?? 0xFF000000,
      fillColorArgb: (json['fillColorArgb'] as num?)?.toInt(),
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
    );
  }
}

class LabelPageTemplate {
  const LabelPageTemplate({
    this.customTexts = const [],
    this.customImages = const [],
    this.customLines = const [],
    this.customShapes = const [],
  });

  final List<CustomTextElement> customTexts;
  final List<CustomImageElement> customImages;
  final List<CustomLineElement> customLines;
  final List<CustomShapeElement> customShapes;

  LabelPageTemplate copyWith({
    List<CustomTextElement>? customTexts,
    List<CustomImageElement>? customImages,
    List<CustomLineElement>? customLines,
    List<CustomShapeElement>? customShapes,
  }) {
    return LabelPageTemplate(
      customTexts: customTexts ?? this.customTexts,
      customImages: customImages ?? this.customImages,
      customLines: customLines ?? this.customLines,
      customShapes: customShapes ?? this.customShapes,
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

  LabelPageTemplate withCustomLine(CustomLineElement e) {
    final next = [...customLines];
    final i = next.indexWhere((l) => l.id == e.id);
    if (i >= 0) {
      next[i] = e;
    } else {
      next.add(e);
    }
    return copyWith(customLines: next);
  }

  LabelPageTemplate withoutCustomLine(String id) {
    return copyWith(customLines: customLines.where((l) => l.id != id).toList());
  }

  LabelPageTemplate withCustomShape(CustomShapeElement e) {
    final next = [...customShapes];
    final i = next.indexWhere((s) => s.id == e.id);
    if (i >= 0) {
      next[i] = e;
    } else {
      next.add(e);
    }
    return copyWith(customShapes: next);
  }

  LabelPageTemplate withoutCustomShape(String id) {
    return copyWith(
        customShapes: customShapes.where((s) => s.id != id).toList());
  }

  Map<String, dynamic> toJson() => {
        'customTexts': customTexts.map((e) => e.toJson()).toList(),
        'customImages': customImages.map((e) => e.toJson()).toList(),
        'customLines': customLines.map((e) => e.toJson()).toList(),
        'customShapes': customShapes.map((e) => e.toJson()).toList(),
      };

  factory LabelPageTemplate.fromJson(Map<String, dynamic> json) {
    return LabelPageTemplate(
      customTexts: (json['customTexts'] as List<dynamic>?)
              ?.map(
                  (e) => CustomTextElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      customImages: (json['customImages'] as List<dynamic>?)
              ?.map(
                  (e) => CustomImageElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      customLines: (json['customLines'] as List<dynamic>?)
              ?.map(
                  (e) => CustomLineElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      customShapes: (json['customShapes'] as List<dynamic>?)
              ?.map(
                  (e) => CustomShapeElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
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
