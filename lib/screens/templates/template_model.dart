import 'dart:convert';
import 'dart:io';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/mammals.dart' as mammals;
import 'package:nahpu/services/types/birds.dart' as birds;
import 'package:nahpu/services/types/specimens.dart' as specimens;
import 'package:nahpu/services/types/herps.dart' as herps;

/// Non-empty path that exists on disk (safe for file-based image widgets).
bool isTemplateImagePathUsable(String path) {
  final p = path.trim();
  if (p.isEmpty) return false;
  try {
    return File(p).existsSync();
  } catch (_) {
    return false;
  }
}

/// Whole-line text `[mammal.sex]-img` → show sex as a resizable icon (see [isTemplateBracketSpecimenSexIconText]).
final RegExp kTemplateSpecimenSexIconBracketText = RegExp(
  r'^\s*\[([^\]]+)\]-img\s*$',
  caseSensitive: false,
);

/// Field id inside brackets, e.g. `mammal.sex`, when [text] is `[mammal.sex]-img`.
String? templateSpecimenSexIconFieldKeyFromBracketText(String text) {
  final m = kTemplateSpecimenSexIconBracketText.firstMatch(text.trim());
  if (m == null) return null;
  final key = m.group(1)!.trim();
  if (!key.toLowerCase().endsWith('.sex')) return null;
  return key;
}

bool isTemplateBracketSpecimenSexIconText(String text) =>
    templateSpecimenSexIconFieldKeyFromBracketText(text) != null;

const double kTemplateSpecimenSexIconDefaultWidthMm = 6.0;
const double kTemplateSpecimenSexIconDefaultHeightMm = 6.0;

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

String formatDateTimeText(String text, String formatOption) {
  final dateTimeRegex = RegExp(
    r'(\d{4}-\d{2}-\d{2})(?:[T\s]+)(\d{2}:\d{2}(?::\d{2})?)(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2})?',
  );
  final match = dateTimeRegex.firstMatch(text);
  if (match != null) {
    final raw = '${match.group(1)}T${match.group(2)}';
    final dt = DateTime.tryParse(raw);
    if (dt != null) {
      return text.replaceFirst(
          match.group(0)!, _formatDateTime(dt, formatOption));
    }
  }

  final dt = DateTime.tryParse(text);
  if (dt != null) {
    return _formatDateTime(dt, formatOption);
  }

  return text;
}

String _formatDateTime(DateTime dt, String format) {
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
  final h24 = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  final sec = dt.second.toString().padLeft(2, '0');
  final hour12Value = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final h12 = hour12Value.toString();
  final h12Padded = hour12Value.toString().padLeft(2, '0');
  final ampm = dt.hour < 12 ? 'AM' : 'PM';

  switch (format) {
    case 'iso-minutes':
      return '$y-$m-${d}T$h24:$min';
    case 'iso-seconds':
      return '$y-$m-${d}T$h24:$min:$sec';
    case 'yyyy-mm-dd-hm':
      return '$y-$m-$d $h24:$min';
    case 'yyyy-mm-dd-hms':
      return '$y-$m-$d $h24:$min:$sec';
    case 'dd-mm-yyyy-hm':
      return '$d-$m-$y $h24:$min';
    case 'mm-dd-yyyy-hm':
      return '$m-$d-$y $h24:$min';
    case 'dd/mm/yyyy-hm':
      return '$d/$m/$y $h24:$min';
    case 'mm/dd/yyyy-hm':
      return '$m/$d/$y $h12:$min $ampm';
    case 'yyyy/mm/dd-hm':
      return '$y/$m/$d $h24:$min';
    case 'dd-month-yyyy-hm':
      return '${dt.day} ${months[dt.month - 1]} $y $h24:$min';
    case 'month-dd-yyyy-hm':
      return '${months[dt.month - 1]} ${dt.day}, $y $h12:$min $ampm';
    case 'dd-month-abbr-yyyy-hm':
      return '${dt.day} ${monthAbbr[dt.month - 1]} $y $h24:$min';
    case 'month-abbr-dd-yyyy-hm':
      return '${monthAbbr[dt.month - 1]} ${dt.day}, $y $h12:$min $ampm';
    case 'time-24':
      return '$h24:$min';
    case 'time-24-seconds':
      return '$h24:$min:$sec';
    case 'time-12':
      return '$h12:$min $ampm';
    case 'time-12-padded':
      return '$h12Padded:$min $ampm';
    default:
      return '$y-$m-$d $h24:$min';
  }
}

String formatTimeText(String text, String formatOption) {
  final timeRegex = RegExp(r'\b(\d{1,2}):(\d{2})(?::(\d{2}))?\b');
  final match = timeRegex.firstMatch(text);
  if (match != null) {
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    final second = int.tryParse(match.group(3) ?? '0') ?? 0;
    if (hour != null && minute != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, hour, minute, second);
      return text.replaceFirst(
          match.group(0)!, _formatDateTime(dt, formatOption));
    }
  }
  return formatDateTimeText(text, formatOption);
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

String? getEncodedDefaultValue(String key, String value) {
  final cleanKey = key.toLowerCase();
  final intVal = int.tryParse(value);
  if (intVal == null) return null;

  if (cleanKey.endsWith('::sex')) {
    if (intVal >= 0 && intVal < specimens.specimenSexList.length) {
      return specimens.specimenSexList[intVal];
    }
  } else if (cleanKey == 'mammalmeasurement::age') {
    if (intVal >= 0 && intVal < mammals.specimenAgeList.length) {
      return mammals.specimenAgeList[intVal];
    }
  } else if (cleanKey == 'herpmeasurement::age') {
    if (intVal >= 0 && intVal < herps.specimenAgeList.length) {
      return herps.specimenAgeList[intVal];
    }
  } else if (cleanKey.endsWith('::testisposition')) {
    if (intVal >= 0 && intVal < mammals.testisPositionList.length) {
      return mammals.testisPositionList[intVal];
    }
  } else if (cleanKey.endsWith('::epididymisappearance')) {
    if (intVal >= 0 && intVal < mammals.epididymisAppearanceList.length) {
      return mammals.epididymisAppearanceList[intVal];
    }
  } else if (cleanKey.endsWith('::vaginaopening')) {
    if (intVal >= 0 && intVal < mammals.vaginaOpeningList.length) {
      return mammals.vaginaOpeningList[intVal];
    }
  } else if (cleanKey.endsWith('::pubicsymphysis')) {
    if (intVal >= 0 && intVal < mammals.pubicSymphysisList.length) {
      return mammals.pubicSymphysisList[intVal];
    }
  } else if (cleanKey.endsWith('::reproductivestage')) {
    if (intVal >= 0 && intVal < mammals.reproductiveStageList.length) {
      return mammals.reproductiveStageList[intVal];
    }
  } else if (cleanKey.endsWith('::mammaecondition')) {
    if (intVal >= 0 && intVal < mammals.mammaeConditionList.length) {
      return mammals.mammaeConditionList[intVal];
    }
  } else if (cleanKey.endsWith('::ovaryappearance')) {
    if (intVal >= 0 && intVal < birds.ovaryAppearanceList.length) {
      return birds.ovaryAppearanceList[intVal];
    }
  } else if (cleanKey.endsWith('::oviductappearance')) {
    if (intVal >= 0 && intVal < birds.oviductAppearanceList.length) {
      return birds.oviductAppearanceList[intVal];
    }
  } else if (cleanKey.endsWith('::fat')) {
    if (intVal >= 0 && intVal < birds.fatCategoryList.length) {
      return birds.fatCategoryList[intVal];
    }
  } else if (cleanKey.endsWith('::bodymolt')) {
    if (intVal >= 0 && intVal < birds.bodyMoltList.length) {
      return birds.bodyMoltList[intVal];
    }
  } else if (cleanKey.endsWith('::echolocation')) {
    if (intVal >= 0 && intVal < mammals.echolocationList.length) {
      return mammals.echolocationList[intVal];
    }
  } else if (cleanKey.endsWith('::broodpatch') ||
      cleanKey.endsWith('::hasbursa') ||
      cleanKey.endsWith('::wingismolt') ||
      cleanKey.endsWith('::tailismolt') ||
      cleanKey.endsWith('::showbatfields') ||
      cleanKey.endsWith('::showechofields')) {
    if (intVal == 1) return 'Yes';
    if (intVal == 0) return 'No';
  }

  return null;
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
  final regex = RegExp(r'\[([^\]\s?]+)::([^\]\s?]+)(\?\?[^\]]+)?\]');
  return text.replaceAllMapped(
    regex,
    (match) => '[${match.group(2)}${match.group(3) ?? ''}]',
  );
}

String formatTemplateText(
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
    case 'datetime':
      result = formatDateTimeText(rawText, formatOption);
      break;
    case 'time':
      result = formatTimeText(rawText, formatOption);
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
    case 'markdown':
    case 'nestedList':
      result = rawText;
      break;
    case 'encoded':
      result = formatTextWithCase(rawText, oldCaseFormat ?? 'normal');
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

const kTemplateNullFallbackBlank = 'blank';
const kTemplateNullFallbackField = 'field';
const kTemplateNullFallbackNa = 'na';
const kTemplateNullFallbackNone = 'none';
const kTemplateNullFallbackCustom = 'custom';

String stripTemplatePlaceholderFallbacks(String text) {
  return text.replaceAllMapped(RegExp(r'\[([^\]]+)\]'), (match) {
    final placeholder = match.group(1);
    if (placeholder == null) return match.group(0)!;
    return '[${placeholder.split('??').first.trim()}]';
  });
}

String inferTemplateNullFallbackOption(String text) {
  for (final match in RegExp(r'\[([^\]]+)\]').allMatches(text)) {
    final placeholder = match.group(1);
    if (placeholder == null || placeholder.endsWith('-img')) continue;
    final parts = placeholder.split('??');
    if (parts.length <= 1) continue;
    final fieldId = parts.first.trim();
    final fallback = parts.sublist(1).join('??').trim();
    if (fallback == fieldId) return kTemplateNullFallbackField;
    if (fallback == 'N/A') return kTemplateNullFallbackNa;
    if (fallback == 'None') return kTemplateNullFallbackNone;
    return kTemplateNullFallbackCustom;
  }
  return kTemplateNullFallbackBlank;
}

String inferTemplateCustomNullFallback(String text) {
  for (final match in RegExp(r'\[([^\]]+)\]').allMatches(text)) {
    final placeholder = match.group(1);
    if (placeholder == null || placeholder.endsWith('-img')) continue;
    final parts = placeholder.split('??');
    if (parts.length <= 1) continue;
    final fieldId = parts.first.trim();
    final fallback = parts.sublist(1).join('??').trim();
    if (fallback == fieldId || fallback == 'N/A' || fallback == 'None') {
      continue;
    }
    return fallback;
  }
  return '';
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
    this.underline = false,
    this.strikethrough = false,
    this.textAlign = 'left',
    this.caseFormat = 'normal',
    this.rotationDegrees = 0,
    this.iconWidthMm,
    this.iconHeightMm,
    this.maxWidthMm,
    this.heightMm,
    this.zIndex = 0,
    this.colorArgb = 0xFF000000,
    this.backgroundColorArgb,
    this.borderColorArgb,
    this.borderWidthPt = 0.0,
    this.borderStrokeStyle = 'solid',
    this.cornerRadiusPt = 0.0,
    this.paddingPt = 2.0,
    this.textType = 'normal',
    this.formatOption = 'normal',
    this.nullFallbackOption = kTemplateNullFallbackBlank,
    this.customNullFallbackText = '',
    this.isQrCode = false,
    this.qrSizeMm = 15.0,
    this.qrBgColorArgb = 0xFFFFFFFF,
    this.qrShape = 'square',
    this.tempPath,
    this.isDynamic = false,
    this.isLocked = false,
    this.isVisible = true,
  });

  final String id;
  final String text;
  final double xMm;
  final double yMm;
  final double fontSizePt;
  final String fontFamily;
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final String textAlign;
  final String caseFormat;
  final int rotationDegrees;
  final int zIndex;
  final int colorArgb;
  final int? backgroundColorArgb;
  final int? borderColorArgb;
  final double borderWidthPt;
  final String borderStrokeStyle;
  final double cornerRadiusPt;
  final double paddingPt;
  final String textType;
  final String formatOption;
  final String nullFallbackOption;
  final String customNullFallbackText;

  /// For [isTemplateBracketSpecimenSexIconText] only: box size in mm (defaults in editor/PDF).
  final double? iconWidthMm;
  final double? iconHeightMm;

  /// If non-null, text wraps to this width.
  final double? maxWidthMm;

  /// If non-null, bounds the text box height.
  final double? heightMm;

  final bool isQrCode;
  final double qrSizeMm;
  final int qrBgColorArgb;
  final String qrShape;
  final String? tempPath;
  final bool isDynamic;
  final bool isLocked;
  final bool isVisible;

  CustomTextElement copyWith({
    String? id,
    String? text,
    double? xMm,
    double? yMm,
    double? fontSizePt,
    String? fontFamily,
    bool? bold,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    String? textAlign,
    String? caseFormat,
    int? rotationDegrees,
    double? iconWidthMm,
    double? iconHeightMm,
    double? maxWidthMm,
    double? heightMm,
    int? zIndex,
    int? colorArgb,
    int? backgroundColorArgb,
    int? borderColorArgb,
    double? borderWidthPt,
    String? borderStrokeStyle,
    double? cornerRadiusPt,
    double? paddingPt,
    bool clearBackgroundColor = false,
    bool clearBorderColor = false,
    bool clearMaxWidthMm = false,
    bool clearHeightMm = false,
    String? textType,
    String? formatOption,
    String? nullFallbackOption,
    String? customNullFallbackText,
    bool? isQrCode,
    double? qrSizeMm,
    int? qrBgColorArgb,
    String? qrShape,
    String? tempPath,
    bool clearTempPath = false,
    bool? isDynamic,
    bool? isLocked,
    bool? isVisible,
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
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      textAlign: textAlign ?? this.textAlign,
      caseFormat: caseFormat ?? this.caseFormat,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      iconWidthMm: iconWidthMm ?? this.iconWidthMm,
      iconHeightMm: iconHeightMm ?? this.iconHeightMm,
      maxWidthMm: clearMaxWidthMm ? null : (maxWidthMm ?? this.maxWidthMm),
      heightMm: clearHeightMm ? null : (heightMm ?? this.heightMm),
      zIndex: zIndex ?? this.zIndex,
      colorArgb: colorArgb ?? this.colorArgb,
      backgroundColorArgb: clearBackgroundColor
          ? null
          : (backgroundColorArgb ?? this.backgroundColorArgb),
      borderColorArgb:
          clearBorderColor ? null : (borderColorArgb ?? this.borderColorArgb),
      borderWidthPt: borderWidthPt ?? this.borderWidthPt,
      borderStrokeStyle: borderStrokeStyle ?? this.borderStrokeStyle,
      cornerRadiusPt: cornerRadiusPt ?? this.cornerRadiusPt,
      paddingPt: paddingPt ?? this.paddingPt,
      textType: textType ?? this.textType,
      formatOption: formatOption ?? this.formatOption,
      nullFallbackOption: nullFallbackOption ?? this.nullFallbackOption,
      customNullFallbackText:
          customNullFallbackText ?? this.customNullFallbackText,
      isQrCode: isQrCode ?? this.isQrCode,
      qrSizeMm: qrSizeMm ?? this.qrSizeMm,
      qrBgColorArgb: qrBgColorArgb ?? this.qrBgColorArgb,
      qrShape: qrShape ?? this.qrShape,
      tempPath: clearTempPath ? null : (tempPath ?? this.tempPath),
      isDynamic: isDynamic ?? this.isDynamic,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
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
        'underline': underline,
        'strikethrough': strikethrough,
        'textAlign': textAlign,
        'caseFormat': caseFormat,
        'rotationDegrees': rotationDegrees,
        if (iconWidthMm != null) 'iconWidthMm': iconWidthMm,
        if (iconHeightMm != null) 'iconHeightMm': iconHeightMm,
        if (maxWidthMm != null) 'maxWidthMm': maxWidthMm,
        if (heightMm != null) 'heightMm': heightMm,
        'zIndex': zIndex,
        'colorArgb': colorArgb,
        if (backgroundColorArgb != null)
          'backgroundColorArgb': backgroundColorArgb,
        if (borderColorArgb != null) 'borderColorArgb': borderColorArgb,
        'borderWidthPt': borderWidthPt,
        'borderStrokeStyle': borderStrokeStyle,
        'cornerRadiusPt': cornerRadiusPt,
        'paddingPt': paddingPt,
        'textType': textType,
        'formatOption': formatOption,
        'nullFallbackOption': nullFallbackOption,
        if (customNullFallbackText.isNotEmpty)
          'customNullFallbackText': customNullFallbackText,
        'isQrCode': isQrCode,
        'qrSizeMm': qrSizeMm,
        'qrBgColorArgb': qrBgColorArgb,
        'qrShape': qrShape,
        'isDynamic': isDynamic,
        'isLocked': isLocked,
        'isVisible': isVisible,
      };

  factory CustomTextElement.fromJson(Map<String, dynamic> json) {
    final rawText = json['text'] as String? ?? '';
    final legacyNullFallbackOption = inferTemplateNullFallbackOption(rawText);
    final nullFallbackOption =
        json['nullFallbackOption'] as String? ?? legacyNullFallbackOption;
    final customNullFallbackText = json['customNullFallbackText'] as String? ??
        inferTemplateCustomNullFallback(rawText);
    return CustomTextElement(
      id: json['id'] as String,
      text: stripTemplatePlaceholderFallbacks(rawText),
      xMm: (json['xMm'] as num?)?.toDouble() ?? 0,
      yMm: (json['yMm'] as num?)?.toDouble() ?? 0,
      fontSizePt: (json['fontSizePt'] as num?)?.toDouble() ?? 10,
      fontFamily: json['fontFamily'] as String? ?? '',
      bold: json['bold'] as bool? ?? false,
      italic: json['italic'] as bool? ?? false,
      underline: json['underline'] as bool? ?? false,
      strikethrough: json['strikethrough'] as bool? ?? false,
      textAlign: json['textAlign'] as String? ?? 'left',
      caseFormat: json['caseFormat'] as String? ?? 'normal',
      rotationDegrees: (json['rotationDegrees'] as num?)?.toInt() ?? 0,
      iconWidthMm: (json['iconWidthMm'] as num?)?.toDouble(),
      iconHeightMm: (json['iconHeightMm'] as num?)?.toDouble(),
      maxWidthMm: (json['maxWidthMm'] as num?)?.toDouble(),
      heightMm: (json['heightMm'] as num?)?.toDouble(),
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
      colorArgb: (json['colorArgb'] as num?)?.toInt() ?? 0xFF000000,
      backgroundColorArgb: (json['backgroundColorArgb'] as num?)?.toInt(),
      borderColorArgb: (json['borderColorArgb'] as num?)?.toInt(),
      borderWidthPt: (json['borderWidthPt'] as num?)?.toDouble() ?? 0.0,
      borderStrokeStyle: json['borderStrokeStyle'] as String? ?? 'solid',
      cornerRadiusPt: (json['cornerRadiusPt'] as num?)?.toDouble() ?? 0.0,
      paddingPt: (json['paddingPt'] as num?)?.toDouble() ?? 2.0,
      textType: json['textType'] as String? ?? 'normal',
      formatOption: json['formatOption'] as String? ?? 'normal',
      nullFallbackOption: nullFallbackOption,
      customNullFallbackText: customNullFallbackText,
      isQrCode: json['isQrCode'] as bool? ?? false,
      qrSizeMm: (json['qrSizeMm'] as num?)?.toDouble() ?? 15.0,
      qrBgColorArgb: (json['qrBgColorArgb'] as num?)?.toInt() ?? 0xFFFFFFFF,
      qrShape: json['qrShape'] as String? ?? 'square',
      isDynamic: json['isDynamic'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      isVisible: json['isVisible'] as bool? ?? true,
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
    this.isLocked = false,
    this.isVisible = true,
  });

  final String id;
  final String imagePath;
  final double xMm;
  final double yMm;
  final double widthMm;
  final double heightMm;
  final int rotationDegrees;
  final int zIndex;
  final bool isLocked;
  final bool isVisible;

  CustomImageElement copyWith({
    String? id,
    String? imagePath,
    double? xMm,
    double? yMm,
    double? widthMm,
    double? heightMm,
    int? rotationDegrees,
    int? zIndex,
    bool? isLocked,
    bool? isVisible,
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
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
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
        'isLocked': isLocked,
        'isVisible': isVisible,
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
      isLocked: json['isLocked'] as bool? ?? false,
      isVisible: json['isVisible'] as bool? ?? true,
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
    this.strokeStyle = 'solid',
    this.isLocked = false,
    this.isVisible = true,
  });

  final String id;
  final double xMm;
  final double yMm;
  final double lengthMm;
  final int rotationDegrees;
  final double thicknessPt;
  final int colorArgb;
  final int zIndex;
  final String strokeStyle;
  final bool isLocked;
  final bool isVisible;

  CustomLineElement copyWith({
    String? id,
    double? xMm,
    double? yMm,
    double? lengthMm,
    int? rotationDegrees,
    double? thicknessPt,
    int? colorArgb,
    int? zIndex,
    String? strokeStyle,
    bool? isLocked,
    bool? isVisible,
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
      strokeStyle: strokeStyle ?? this.strokeStyle,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
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
        'strokeStyle': strokeStyle,
        'isLocked': isLocked,
        'isVisible': isVisible,
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
      strokeStyle: json['strokeStyle'] as String? ?? 'solid',
      isLocked: json['isLocked'] as bool? ?? false,
      isVisible: json['isVisible'] as bool? ?? true,
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
    this.polygonSides = 5,
    this.rotationDegrees = 0,
    this.strokeThicknessPt = 1.0,
    this.strokeColorArgb = 0xFF000000,
    this.fillColorArgb,
    this.zIndex = 0,
    this.strokeStyle = 'solid',
    this.isLocked = false,
    this.isVisible = true,
  });

  final String id;
  final double xMm;
  final double yMm;
  final double widthMm;
  final double heightMm;
  final String shapeType; // 'rect', 'ellipse', 'circle', 'triangle', 'polygon'
  final int polygonSides;
  final int rotationDegrees;
  final double strokeThicknessPt;
  final int strokeColorArgb;
  final int? fillColorArgb;
  final int zIndex;
  final String strokeStyle;
  final bool isLocked;
  final bool isVisible;

  CustomShapeElement copyWith({
    String? id,
    double? xMm,
    double? yMm,
    double? widthMm,
    double? heightMm,
    String? shapeType,
    int? polygonSides,
    int? rotationDegrees,
    double? strokeThicknessPt,
    int? strokeColorArgb,
    int? fillColorArgb,
    bool clearFillColor = false,
    int? zIndex,
    String? strokeStyle,
    bool? isLocked,
    bool? isVisible,
  }) {
    return CustomShapeElement(
      id: id ?? this.id,
      xMm: xMm ?? this.xMm,
      yMm: yMm ?? this.yMm,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      shapeType: shapeType ?? this.shapeType,
      polygonSides: polygonSides ?? this.polygonSides,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      strokeThicknessPt: strokeThicknessPt ?? this.strokeThicknessPt,
      strokeColorArgb: strokeColorArgb ?? this.strokeColorArgb,
      fillColorArgb:
          clearFillColor ? null : (fillColorArgb ?? this.fillColorArgb),
      zIndex: zIndex ?? this.zIndex,
      strokeStyle: strokeStyle ?? this.strokeStyle,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'xMm': xMm,
        'yMm': yMm,
        'widthMm': widthMm,
        'heightMm': heightMm,
        'shapeType': shapeType,
        'polygonSides': polygonSides,
        'rotationDegrees': rotationDegrees,
        'strokeThicknessPt': strokeThicknessPt,
        'strokeColorArgb': strokeColorArgb,
        if (fillColorArgb != null) 'fillColorArgb': fillColorArgb,
        'zIndex': zIndex,
        'strokeStyle': strokeStyle,
        'isLocked': isLocked,
        'isVisible': isVisible,
      };

  factory CustomShapeElement.fromJson(Map<String, dynamic> json) {
    return CustomShapeElement(
      id: json['id'] as String,
      xMm: (json['xMm'] as num?)?.toDouble() ?? 0,
      yMm: (json['yMm'] as num?)?.toDouble() ?? 0,
      widthMm: (json['widthMm'] as num?)?.toDouble() ?? 20,
      heightMm: (json['heightMm'] as num?)?.toDouble() ?? 20,
      shapeType: json['shapeType'] as String? ?? 'rect',
      polygonSides: ((json['polygonSides'] as num?)?.toInt() ?? 5).clamp(3, 12),
      rotationDegrees: (json['rotationDegrees'] as num?)?.toInt() ?? 0,
      strokeThicknessPt: (json['strokeThicknessPt'] as num?)?.toDouble() ?? 1.0,
      strokeColorArgb: (json['strokeColorArgb'] as num?)?.toInt() ?? 0xFF000000,
      fillColorArgb: (json['fillColorArgb'] as num?)?.toInt(),
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
      strokeStyle: json['strokeStyle'] as String? ?? 'solid',
      isLocked: json['isLocked'] as bool? ?? false,
      isVisible: json['isVisible'] as bool? ?? true,
    );
  }
}

enum TemplateElementType { text, image, line, shape }

class TemplateSelection {
  const TemplateSelection({
    required this.type,
    required this.page1,
    required this.id,
  });

  final TemplateElementType type;
  final bool page1;
  final String id;

  static TemplateSelection? parse(String selectedElement) {
    final parts = selectedElement.split(':');
    if (parts.length != 3) return null;

    final type = switch (parts[0]) {
      'custom' => TemplateElementType.text,
      'image' => TemplateElementType.image,
      'line' => TemplateElementType.line,
      'shape' => TemplateElementType.shape,
      _ => null,
    };
    if (type == null) return null;

    return TemplateSelection(
      type: type,
      page1: parts[1] == '1',
      id: parts[2],
    );
  }
}

class TemplatePage {
  const TemplatePage({
    this.customTexts = const [],
    this.customImages = const [],
    this.customLines = const [],
    this.customShapes = const [],
  });

  final List<CustomTextElement> customTexts;
  final List<CustomImageElement> customImages;
  final List<CustomLineElement> customLines;
  final List<CustomShapeElement> customShapes;

  TemplatePage copyWith({
    List<CustomTextElement>? customTexts,
    List<CustomImageElement>? customImages,
    List<CustomLineElement>? customLines,
    List<CustomShapeElement>? customShapes,
  }) {
    return TemplatePage(
      customTexts: customTexts ?? this.customTexts,
      customImages: customImages ?? this.customImages,
      customLines: customLines ?? this.customLines,
      customShapes: customShapes ?? this.customShapes,
    );
  }

  TemplatePage withCustomText(CustomTextElement e) {
    final next = [...customTexts];
    final i = next.indexWhere((t) => t.id == e.id);
    if (i >= 0) {
      next[i] = e;
    } else {
      next.add(e);
    }
    return copyWith(customTexts: next);
  }

  TemplatePage withoutCustomText(String id) {
    return copyWith(customTexts: customTexts.where((t) => t.id != id).toList());
  }

  TemplatePage withCustomImage(CustomImageElement e) {
    final next = [...customImages];
    final i = next.indexWhere((im) => im.id == e.id);
    if (i >= 0) {
      next[i] = e;
    } else {
      next.add(e);
    }
    return copyWith(customImages: next);
  }

  TemplatePage withoutCustomImage(String id) {
    return copyWith(
        customImages: customImages.where((im) => im.id != id).toList());
  }

  TemplatePage withCustomLine(CustomLineElement e) {
    final next = [...customLines];
    final i = next.indexWhere((l) => l.id == e.id);
    if (i >= 0) {
      next[i] = e;
    } else {
      next.add(e);
    }
    return copyWith(customLines: next);
  }

  TemplatePage withoutCustomLine(String id) {
    return copyWith(customLines: customLines.where((l) => l.id != id).toList());
  }

  TemplatePage withCustomShape(CustomShapeElement e) {
    final next = [...customShapes];
    final i = next.indexWhere((s) => s.id == e.id);
    if (i >= 0) {
      next[i] = e;
    } else {
      next.add(e);
    }
    return copyWith(customShapes: next);
  }

  TemplatePage withoutCustomShape(String id) {
    return copyWith(
        customShapes: customShapes.where((s) => s.id != id).toList());
  }

  Map<String, dynamic> toJson() => {
        'customTexts': customTexts.map((e) => e.toJson()).toList(),
        'customImages': customImages.map((e) => e.toJson()).toList(),
        'customLines': customLines.map((e) => e.toJson()).toList(),
        'customShapes': customShapes.map((e) => e.toJson()).toList(),
      };

  factory TemplatePage.fromJson(Map<String, dynamic> json) {
    return TemplatePage(
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
class TemplatePrintOptions {
  const TemplatePrintOptions({
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
    this.documentPadTopMm,
    this.documentPadLeftMm,
    this.documentPadRightMm,
    this.documentPadBottomMm,
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
  final double? documentPadTopMm;
  final double? documentPadLeftMm;
  final double? documentPadRightMm;
  final double? documentPadBottomMm;

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
        if (documentPadTopMm != null) 'documentPadTopMm': documentPadTopMm,
        if (documentPadLeftMm != null) 'documentPadLeftMm': documentPadLeftMm,
        if (documentPadRightMm != null)
          'documentPadRightMm': documentPadRightMm,
        if (documentPadBottomMm != null)
          'documentPadBottomMm': documentPadBottomMm,
      };

  factory TemplatePrintOptions.fromJson(Map<String, dynamic> json) {
    double? readDouble(String key, String legacyKey) {
      return (json[key] as num?)?.toDouble() ??
          (json[legacyKey] as num?)?.toDouble();
    }

    return TemplatePrintOptions(
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
      documentPadTopMm: readDouble('documentPadTopMm', 'labelPadTopMm'),
      documentPadLeftMm: readDouble('documentPadLeftMm', 'labelPadLeftMm'),
      documentPadRightMm: readDouble('documentPadRightMm', 'labelPadRightMm'),
      documentPadBottomMm:
          readDouble('documentPadBottomMm', 'labelPadBottomMm'),
    );
  }
}

TemplatePrintOptions? templatePrintOptionsFromJson(
  Map<String, dynamic> json,
) {
  final nested = json['printOptions'];
  if (nested is Map) {
    return TemplatePrintOptions.fromJson(
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
      json.containsKey('documentPadTopMm') ||
      json.containsKey('documentPadLeftMm') ||
      json.containsKey('documentPadRightMm') ||
      json.containsKey('documentPadBottomMm') ||
      json.containsKey('labelPadTopMm') ||
      json.containsKey('labelPadLeftMm') ||
      json.containsKey('labelPadRightMm') ||
      json.containsKey('labelPadBottomMm')) {
    return TemplatePrintOptions.fromJson(json);
  }
  return null;
}

TemplateOutlineStyle templateOutlineStyleFromJson(String? s) {
  switch (s) {
    case 'dashed':
      return TemplateOutlineStyle.dashed;
    case 'dotted':
      return TemplateOutlineStyle.dotted;
    case 'double':
      return TemplateOutlineStyle.doubleLine;
    default:
      return TemplateOutlineStyle.solid;
  }
}

String templateOutlineStyleToJson(TemplateOutlineStyle s) {
  switch (s) {
    case TemplateOutlineStyle.solid:
      return 'solid';
    case TemplateOutlineStyle.dashed:
      return 'dashed';
    case TemplateOutlineStyle.dotted:
      return 'dotted';
    case TemplateOutlineStyle.doubleLine:
      return 'double';
  }
}

/// Line style for the optional rectangle drawn around the label in editor, preview, and PDF.
enum TemplateOutlineStyle {
  solid,
  dashed,
  dotted,
  doubleLine,
}

/// Per-template outline around the template area (saved with the template JSON).
class TemplateOutline {
  const TemplateOutline({
    this.style = TemplateOutlineStyle.solid,
    this.widthPt = 1.5,
    this.colorArgb = 0xFF757575,
  });

  final TemplateOutlineStyle style;

  /// Stroke width in PDF points (1 pt = 1/72 in).
  final double widthPt;

  /// 0xAARRGGBB (same convention as [Color.value]).
  final int colorArgb;

  TemplateOutline copyWith({
    TemplateOutlineStyle? style,
    double? widthPt,
    int? colorArgb,
  }) {
    return TemplateOutline(
      style: style ?? this.style,
      widthPt: widthPt ?? this.widthPt,
      colorArgb: colorArgb ?? this.colorArgb,
    );
  }

  Map<String, dynamic> toJson() => {
        'style': templateOutlineStyleToJson(style),
        'widthPt': widthPt,
        'colorArgb': colorArgb,
      };

  factory TemplateOutline.fromJson(Map<String, dynamic> json) {
    return TemplateOutline(
      style: templateOutlineStyleFromJson(json['style'] as String?),
      widthPt: (json['widthPt'] as num?)?.toDouble() ?? 1.5,
      colorArgb: (json['colorArgb'] as num?)?.toInt() ?? 0xFF757575,
    );
  }
}

class Template {
  const Template({
    required this.name,
    required this.page1,
    required this.page2,
    required this.widthMm,
    required this.heightMm,
    this.printOptions,
    this.outline,
    this.recordType = RecordType.specimenRecord,
    this.description = '',
  });

  final String name;
  final TemplatePage page1;
  final TemplatePage page2;
  final double widthMm;
  final double heightMm;

  /// When null (legacy files), the editor uses app template settings instead.
  final TemplatePrintOptions? printOptions;

  /// When null, no outline is drawn on the label.
  final TemplateOutline? outline;

  final RecordType recordType;
  final String description;

  Template copyWith({
    String? name,
    TemplatePage? page1,
    TemplatePage? page2,
    double? widthMm,
    double? heightMm,
    TemplatePrintOptions? printOptions,
    bool clearPrintOptions = false,
    TemplateOutline? outline,
    bool clearOutline = false,
    RecordType? recordType,
    String? description,
  }) {
    return Template(
      name: name ?? this.name,
      page1: page1 ?? this.page1,
      page2: page2 ?? this.page2,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      printOptions:
          clearPrintOptions ? null : (printOptions ?? this.printOptions),
      outline: clearOutline ? null : (outline ?? this.outline),
      recordType: recordType ?? this.recordType,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'page1': page1.toJson(),
        'page2': page2.toJson(),
        'widthMm': widthMm,
        'heightMm': heightMm,
        if (printOptions != null) 'printOptions': printOptions!.toJson(),
        if (outline != null) 'outline': outline!.toJson(),
        'recordType': recordTypeToString(recordType),
        'description': description,
      };

  factory Template.fromJson(Map<String, dynamic> json) {
    final opts = templatePrintOptionsFromJson(json);
    TemplateOutline? outline;
    final o = json['outline'];
    if (o is Map) {
      final m = Map<String, dynamic>.from(o);
      if (m['enabled'] == false) {
        outline = null;
      } else {
        outline = TemplateOutline.fromJson(m);
      }
    }
    return Template(
      name: json['name'] as String? ?? 'Default',
      page1: TemplatePage.fromJson(
        json['page1'] as Map<String, dynamic>? ?? {},
      ),
      page2: TemplatePage.fromJson(
        json['page2'] as Map<String, dynamic>? ?? {},
      ),
      widthMm: (json['widthMm'] as num?)?.toDouble() ?? 215.9,
      heightMm: (json['heightMm'] as num?)?.toDouble() ?? 279.4,
      printOptions: opts,
      outline: outline,
      recordType: parseRecordType(json['recordType'] as String?),
      description: json['description'] as String? ?? '',
    );
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  static Template fromJsonString(String s) {
    final decoded = jsonDecode(s);
    if (decoded is! Map) {
      throw FormatException('Template JSON must be an object');
    }
    return Template.fromJson(Map<String, dynamic>.from(decoded));
  }
}

class DefaultTemplate {
  static Template defaultTemplate([
    String name = 'Default',
    RecordType recordType = RecordType.specimenRecord,
    String description = '',
    double widthMm = 215.9,
    double heightMm = 279.4,
  ]) {
    return Template(
      name: name,
      page1: const TemplatePage(),
      page2: const TemplatePage(),
      widthMm: widthMm,
      heightMm: heightMm,
      printOptions: null,
      recordType: recordType,
      description: description,
    );
  }
}
