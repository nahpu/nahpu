import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/database/site_queries.dart';

class UtilityServices extends AppServices {
  const UtilityServices({required super.ref});

  Future<List<String>> getDistinctOptions(String prefKey) async {
    switch (prefKey) {
      case siteTypePrefKey:
        return await SiteQuery(dbAccess).getDistinctSiteTypes();
      case habitatTypePrefKey:
        return await SiteQuery(dbAccess).getDistinctHabitatTypes();
      case collMethodPrefKey:
        return await CollEffortQuery(dbAccess).getDistinctMethods();
      case collRolePrefKey:
        return await CollPersonnelQuery(dbAccess).getDistinctRoles();
      case specimenTypePrefKey:
        return await SpecimenPartQuery(dbAccess).getDistinctTypes();
      case treatmentPrefKey:
        return await SpecimenPartQuery(dbAccess).getDistinctTreatments();
      default:
        return [];
    }
  }

  Future<void> getAllOptions(String prefKey) async {
    List<String> data = await getDistinctOptions(prefKey);
    final notifier = ref.read(userDefinedFieldProvider(prefKey).notifier);
    List<String> options = data.isEmpty ? getDefaultOptionsList(prefKey) : data;
    notifier.replaceAll(options);
    _invalidateOptions(prefKey);
  }

  Future<void> addOption(String prefKey, String option) async {
    await ref.read(userDefinedFieldProvider(prefKey).notifier).add(option);
    _invalidateOptions(prefKey);
  }

  Future<void> removeOption(String prefKey, String option) async {
    await ref.read(userDefinedFieldProvider(prefKey).notifier).remove(option);
    _invalidateOptions(prefKey);
  }

  Future<void> removeAllOptions(String prefKey) async {
    await ref.read(userDefinedFieldProvider(prefKey).notifier).clear();
    _invalidateOptions(prefKey);
  }

  void _invalidateOptions(String prefKey) {
    ref.invalidate(userDefinedFieldProvider(prefKey));
  }
}

String get listTileSeparator => " · ";

int getCrossAxisCount(double screenWidth, int elementSize) {
  int crossAxisCount = 1;
  double safeWidth = screenWidth - 48;
  while (safeWidth > elementSize) {
    crossAxisCount++;
    safeWidth -= elementSize;
  }
  return crossAxisCount;
}

String getSystemDateTime() {
  DateTime currentDate = DateTime.now();
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(currentDate);
}

({String date, String time}) parseDate(String? date) {
  if (date == null) return (date: '', time: '');

  DateTime? parsedDate = DateTime.tryParse(date);

  if (parsedDate == null) return (date: '', time: '');

  String formattedDate = DateFormat.yMMMMd().format(parsedDate);
  String formattedTime = DateFormat.jm().format(parsedDate);
  return (date: formattedDate, time: formattedTime);
}

extension TimeOfDayFormatter on TimeOfDay {
  String toTimeStd() {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    final second = '00';
    return '$hour:$minute:$second';
  }

  String toTimeDisplay() {
    final hour = hourOfPeriod.toString();
    final minute = this.minute.toString().padLeft(2, '0');
    final amPM = period.name.toUpperCase();
    return '$hour:$minute $amPM';
  }
}

// Given a datetime, format it for display to the user (yMMMd)
String dateTimeToDateDisplay(DateTime? inputDateTime) {
  if (inputDateTime == null) return '';
  return DateFormat.yMMMd().format(inputDateTime);
}

// Given a TimeOfDay, format it for display to the user (h:m a)
String timeOfDayToTimeDisplay(TimeOfDay? inputTimeOfDay) {
  if (inputTimeOfDay == null) return '';
  return inputTimeOfDay.toTimeDisplay();
}

// Given a datetime, format it for storage (yyyy-MM-dd)
String dateTimeToDateStd(DateTime? inputDateTime) {
  if (inputDateTime == null) return '';
  return DateFormat('yyyy-MM-dd').format(inputDateTime);
}

// Given a TimeOfDay, format it for storage (h:m:s)
String timeOfDayToTimeStd(TimeOfDay? inputTimeOfDay) {
  if (inputTimeOfDay == null) return '';
  return inputTimeOfDay.toTimeStd();
}

// Given a date string in the standard storage format (yyyy-MM-dd)
// return a string in the standard display format (yMMMd)
String? dateStdToDateDisplay(String? inputDateString) {
  if (inputDateString == null) return '';
  DateTime? parsedDate = DateFormat('yyyy-MM-dd').tryParse(inputDateString);
  if (parsedDate == null) return '';
  return DateFormat.yMMMd().format(parsedDate);
}

// Given a time string in the standard storage format (H:m:s)
// return a string in the standard display format (h:m a), assuming a local timezone
String? timeStdToTimeDisplay(String? inputTimeString) {
  if (inputTimeString == null) return '';
  DateTime? parsedTime = DateFormat.Hms().tryParse(inputTimeString);
  if (parsedTime == null) return '';
  return TimeOfDay.fromDateTime(parsedTime).toTimeDisplay();
}

// Given a date string in the standard format (yyyy-MM-dd) return a DateTime
DateTime? dateStdToDateTime(String? inputDateString) {
  if (inputDateString == null) return null;
  return DateFormat('yyyy-MM-dd').tryParse(inputDateString);
}

// Given a time string in the standard storage format (H:m:s)
// return a TimeOfDay, assuming a local timezone
TimeOfDay? timeStdToTimeOfDay(String? inputTimeString) {
  if (inputTimeString == null) return null;
  DateTime? parsedTime = DateFormat.Hms().tryParse(inputTimeString);
  if (parsedTime == null) return null;
  return TimeOfDay.fromDateTime(parsedTime);
}

// Insert only unique values
List<String> getDistinctList(List<String?> list) {
  // Get unique value and remove empty string
  List<String> newList = list
      .toSet()
      .toList()
      .map((e) => e ?? '')
      .where((element) => element.isNotEmpty)
      .toList();

  return newList;
}

bool isListContains(List<String> list, String value) {
  return list.any((e) => e.toLowerCase() == value.toLowerCase());
}

enum TextCaseFmt {
  anyCase,
  sentenceCase,
  titleCase,
  upperCase,
  lowerCase,
}

Map<TextCaseFmt, String> textCaseFmtMap = {
  TextCaseFmt.anyCase: 'Any Case',
  TextCaseFmt.sentenceCase: 'Sentence Case',
  TextCaseFmt.titleCase: 'Title Case',
  TextCaseFmt.upperCase: 'Upper Case',
  TextCaseFmt.lowerCase: 'Lower Case',
};

extension StringExtension on String {
  String toSentenceCase() {
    try {
      return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
    } catch (e) {
      return '';
    }
  }

  String toTitleCase() {
    try {
      return split(' ').map((word) => word.toSentenceCase()).join(' ');
    } catch (e) {
      return '';
    }
  }

  String toTextCaseFmt(TextCaseFmt textCaseFmt) {
    switch (textCaseFmt) {
      case TextCaseFmt.anyCase:
        return this;
      case TextCaseFmt.sentenceCase:
        return toSentenceCase();
      case TextCaseFmt.titleCase:
        return toTitleCase();
      case TextCaseFmt.lowerCase:
        return toLowerCase();
      case TextCaseFmt.upperCase:
        return toUpperCase();
    }
  }
}

extension NullableStringExtension on String? {
  bool isContain(String value) {
    if (this == null || this!.isEmpty) {
      return false;
    }

    return this!.toLowerCase().contains(value.toLowerCase());
  }

  bool isMatch(String value) {
    if (this == null || this!.isEmpty) {
      return false;
    }
    return this!.toLowerCase() == value.toLowerCase();
  }

  bool isMatchExact(String value) {
    if (this == null || this!.isEmpty) {
      return false;
    }

    return this! == value;
  }
}

List<bool> checkListNumberContinuous(List<int> listNum) {
  List<bool> result = [];
  for (int i = 0; i < listNum.length - 1; i++) {
    if (listNum[i] + 1 == listNum[i + 1]) {
      result.add(true);
    } else {
      result.add(false);
    }
  }
  return result;
}

extension DoubleExtension on double {
  String truncateZero() {
    if (toString().endsWith('.0')) {
      // Remove trailing .0
      return toString().substring(0, toString().length - 2);
    } else {
      return toString();
    }
  }

  /// Truncate trailing zeros if exist in a decimal number.
  /// Otherwise, return the number as is.
  /// [fractionDigits] is the number of digits after the decimal point.
  String truncateZeroFixed(int fractionDigits) {
    if (toString().endsWith('.0')) {
      // Remove trailing .0
      return toStringAsFixed(fractionDigits)
          .substring(0, toString().length - 2);
    } else {
      return toStringAsFixed(fractionDigits);
    }
  }
}
