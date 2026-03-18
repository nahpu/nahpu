import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:kdl/kdl.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/types/sites.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/types/collecting.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/specimens.dart';

enum PrefType {
  string,
  bool,
  strList,
}

List<({String key, PrefType type, dynamic def})> prefs = [
  (key: themeModePrefKey, type: PrefType.string, def: 'system'),
  (key: catalogFmtPrefKey, type: PrefType.string, def: 'General Mammals'),
  (key: specimenTypePrefKey, type: PrefType.strList, def: defaultSpecimenType),
  (key: treatmentPrefKey, type: PrefType.strList, def: defaultTreatment),
  (key: collMethodPrefKey, type: PrefType.strList, def: defaultCollMethods),
  (key: collRolePrefKey, type: PrefType.strList, def: defaultCollRoles),
  (key: siteTypePrefKey, type: PrefType.strList, def: defaultSiteTypes),
  (key: habitatTypePrefKey, type: PrefType.strList, def: defaultHabitatTypes),
  (key: specimenTypeFmtPrefKey, type: PrefType.string, def: 'anyCase'),
  (key: treatmentFmtPrefKey, type: PrefType.string, def: 'anyCase'),
  (key: collMethodFmtPrefKey, type: PrefType.string, def: 'anyCase'),
  (key: collRoleFmtPrefKey, type: PrefType.string, def: 'anyCase'),
  (key: siteTypeFmtPrefKey, type: PrefType.string, def: 'anyCase'),
  (key: habitatTypeFmtPrefKey, type: PrefType.string, def: 'anyCase'),
  (key: collectorFieldKey, type: PrefType.bool, def: false),
  (key: batFieldsKey, type: PrefType.bool, def: false),
];

class SharedPref {
  SharedPref._internal({
    required this.key,
    required this.type,
    required this.defaultValue,
  });

  static SharedPref create(String key, PrefType type, dynamic value) {
    SharedPref sp =
        SharedPref._internal(key: key, type: type, defaultValue: null);
    sp.value = value;

    return sp;
  }

  static Future<SharedPref> createAndGetValue(
      String key, PrefType type, dynamic defaultValue) async {
    SharedPref sp =
        SharedPref._internal(key: key, type: type, defaultValue: defaultValue);
    sp._getValue();
    return sp;
  }

  final String key;
  final PrefType type;
  dynamic value;
  final dynamic defaultValue;

  void _getValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(key)) {
      switch (type) {
        case PrefType.string:
          value = prefs.getString(key);
          break;
        case PrefType.bool:
          value = prefs.getBool(key);
          break;
        case PrefType.strList:
          value = prefs.getStringList(key);
          break;
      }
    }
  }

  void updateSharedPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (value != null) {
      switch (type) {
        case PrefType.string:
          prefs.setString(key, value as String);
          break;
        case PrefType.bool:
          prefs.setBool(key, value as bool);
          break;
        case PrefType.strList:
          prefs.setStringList(key, value.cast<String>());
          break;
      }
    }
  }

  KdlNode createKDLNode() {
    dynamic args;

    switch (type) {
      case PrefType.string:
        args = [KdlString(value ?? defaultValue)];
        break;
      case PrefType.bool:
        args = [KdlBool(value ?? defaultValue)];
        break;
      case PrefType.strList:
        args = kdlStrList(value ?? defaultValue);
        break;
    }

    return KdlNode(key, arguments: args);
  }
}

List<KdlString> kdlStrList(List<String> items) {
  return items.map((e) {
    return KdlString(e);
  }).toList();
}

class KdlServices {
  Future<File> write(String filePath) async {
    List<SharedPref> sPList = [];

    for (var pref in prefs) {
      sPList.add(
          await SharedPref.createAndGetValue(pref.key, pref.type, pref.def));
    }

    KdlDocument kdl = KdlDocument();
    for (SharedPref sp in sPList) {
      kdl.nodes.add(sp.createKDLNode());
    }

    File kdlFile = File(filePath);
    kdlFile.writeAsString(kdl.toString());

    return kdlFile;
  }

  Future<void> readAndUpdateSettings(String filePath) async {
    final kdlString = await File(filePath).readAsString();
    final kdl = KdlDocument.parse(kdlString);

    // Build list of settings to update
    List<SharedPref> sPList = [];
    for (var pref in prefs) {
      try {
        dynamic value = (pref.type == PrefType.strList)
            ? kdl.args(pref.key).toList()
            : kdl.args(pref.key).singleOrNull;
        sPList.add(SharedPref.create(pref.key, pref.type, value));
      } catch (e) {
        // Setting not found, skip
        continue;
      }
    }

    // Update settings
    for (var pref in sPList) {
      pref.updateSharedPref();
    }
  }
}
