import 'package:drift/drift.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/database/narrative_queries.dart';
import 'package:intl/intl.dart';

Future<void> castColumnsIntToReal(
    Migrator m, dynamic table, List<String> colsToCast) async {
  final db = m.database as Database;

  final List<String> columnNames =
      table.$columns.map((column) => column.name).toList().cast<String>();

  final columnNamesCasted = columnNames.map((column) {
    return (colsToCast.contains(column)) ? 'CAST($column AS REAL)' : column;
  }).toList();

  await db.customStatement(
      'ALTER TABLE ${table.actualTableName} RENAME TO tmp_${table.actualTableName}');
  await m.createTable(table);
  await db.customStatement('''
        INSERT INTO ${table.actualTableName} (${columnNames.join(', ')})
        SELECT ${columnNamesCasted.join(', ')} FROM tmp_${table.actualTableName}
      ''');
  await db.customStatement('DROP TABLE tmp_${table.actualTableName}');
}

// Primarily used to drop columns
Future<void> alterTableHelper(Migrator m, dynamic table) async {
  final db = m.database as Database;

  final List<String> columnNames =
      table.$columns.map((column) => column.name).toList().cast<String>();

  await db.customStatement(
      'ALTER TABLE ${table.actualTableName} RENAME TO tmp_${table.actualTableName}');
  await m.createTable(table);
  await db.customStatement('''
        INSERT INTO ${table.actualTableName} (${columnNames.join(', ')})
        SELECT ${columnNames.join(', ')} FROM tmp_${table.actualTableName}
      ''');
  await db.customStatement('DROP TABLE tmp_${table.actualTableName}');
}

Future<void> castMammalType(Migrator m) async {
  final mammalMeasurement = (m.database as Database).mammalMeasurement;
  final columnsToUpdate = [
    'totalLength',
    'tailLength',
    'hindFootLength',
    'earLength',
    'forearm',
    'testisLength',
    'testisWidth'
  ];

  await castColumnsIntToReal(m, mammalMeasurement, columnsToUpdate);
}

String convertDateString(String inputDateString) {
  DateTime? parsedDate = DateFormat.yMMMd().tryParse(inputDateString);
  if (parsedDate == null) return inputDateString;
  return DateFormat('yyyy-MM-dd').format(parsedDate);
}

String convertTimeString(String inputTimeString) {
  DateTime? parsedTime = DateFormat('h:m a').tryParse(inputTimeString) ??
      DateFormat('H:m').tryParse(inputTimeString);
  if (parsedTime == null) return inputTimeString;
  return DateFormat.Hms().format(parsedTime);
}

Future<void> migrateProjectDateTimeFormat(Migrator m) async {
  final db = m.database as Database;

  final fieldsToUpdate = ['startDate', 'endDate'];
  final projects = await ProjectQuery(db).getAllProjects();

  for (final projectData in projects) {
    bool doUpdate = false;
    List<String> updateStrings = [];
    final projectJson = projectData.toJson();

    for (final field in fieldsToUpdate) {
      final dateString = projectJson[field];

      if (dateString != null && dateString.isNotEmpty) {
        final updatedDateString = convertDateString(dateString);

        if (updatedDateString != dateString) {
          doUpdate = true;
          updateStrings.add('$field = \'$updatedDateString\'');
        }
      }
    }

    if (doUpdate) {
      db.customStatement('''UPDATE project 
        SET ${updateStrings.join(',')} 
        WHERE uuid = '${projectJson['uuid']}'
        ''');
    }
  }
}

Future<void> migrateSpecimenDateTimeFormat(Migrator m) async {
  final db = m.database as Database;

  final specimenDateFields = ['prepDate', 'collectionDate', 'captureDate'];
  final specimenTimeFields = ['prepTime', 'collectionTime', 'captureTime'];
  final projects = await ProjectQuery(db).getAllProjects();

  for (final projectData in projects) {
    final specimens = await SpecimenQuery(db).getAllSpecimens(projectData.uuid);

    for (final specimenData in specimens) {
      // Specimen general records and capture records update
      bool doSpecimenUpdate = false;
      List<String> updateStrings = [];
      final specimenJson = specimenData.toJson();

      for (final field in specimenDateFields) {
        final dateString = specimenJson[field];

        if (dateString != null && dateString.isNotEmpty) {
          final updatedDateString = convertDateString(dateString);

          if (updatedDateString != dateString) {
            doSpecimenUpdate = true;
            updateStrings.add('$field = \'$updatedDateString\'');
          }
        }
      }

      for (final field in specimenTimeFields) {
        final timeString = specimenJson[field];

        if (timeString != null && timeString.isNotEmpty) {
          final updatedTimeString = convertTimeString(timeString);

          if (updatedTimeString != timeString) {
            doSpecimenUpdate = true;
            updateStrings.add('$field = \'$updatedTimeString\'');
          }
        }
      }

      if (doSpecimenUpdate) {
        db.customStatement('''UPDATE specimen 
          SET ${updateStrings.join(',')} 
          WHERE uuid = '${specimenJson['uuid']}'
          ''');
      }

      // Specimen part update
      final specimenParts =
          await SpecimenPartQuery(db).getSpecimenParts(specimenData.uuid);

      for (final specimenPartData in specimenParts) {
        bool doSpecimenPartUpdate = false;
        final specimenPartJson = specimenPartData.toJson();

        final dateString = specimenPartJson['dateTaken'];
        if (dateString != null && dateString.isNotEmpty) {
          final updatedDateString = convertDateString(dateString);

          if (updatedDateString != dateString) {
            doSpecimenPartUpdate = true;
            specimenPartJson['dateTaken'] = updatedDateString;
          }
        }

        final timeString = specimenPartJson['timeTaken'];
        if (timeString != null && timeString.isNotEmpty) {
          final updatedTimeString = convertTimeString(timeString);

          if (updatedTimeString != timeString) {
            doSpecimenPartUpdate = true;
            specimenPartJson['timeTaken'] = updatedTimeString;
          }
        }

        if (doSpecimenPartUpdate) {
          db.customStatement('''UPDATE specimenPart 
            SET dateTaken = '${specimenPartJson['dateTaken']}',
              timeTaken = '${specimenPartJson['timeTaken']}'
            WHERE id = '${specimenPartJson['id']}'
            ''');
        }
      }

      // Associated data update
      final associatedDataList =
          await AssociatedDataQuery(db).getAllAssociatedData(specimenData.uuid);

      for (final associatedDatum in associatedDataList) {
        final associatedDatumJson = associatedDatum.toJson();
        final dateString = associatedDatumJson['date'];

        if (dateString != null && dateString.isNotEmpty) {
          final updatedDateString = convertDateString(dateString);

          if (updatedDateString != dateString) {
            db.customStatement('''UPDATE associatedData 
              SET date = '${associatedDatumJson['date']}'
              WHERE primaryId = '${associatedDatumJson['primaryId']}'
              ''');
          }
        }
      }
    }
  }
}

Future<void> migrateNarrativeDateTimeFormat(Migrator m) async {
  final db = m.database as Database;
  final projects = await ProjectQuery(db).getAllProjects();

  for (final projectData in projects) {
    final narrativeList =
        await NarrativeQuery(db).getAllNarrative(projectData.uuid);

    for (final narrativeData in narrativeList) {
      final narrativeJson = narrativeData.toJson();
      final dateString = narrativeJson['date'];

      if (dateString != null && dateString.isNotEmpty) {
        final updatedDateString = convertDateString(dateString);

        if (updatedDateString != dateString) {
          db.customStatement('''UPDATE narrative 
            SET date = '$updatedDateString'
            WHERE id = '${narrativeJson['id']}'
            ''');
        }
      }
    }
  }
}

Future<void> migrateCollEventDateTimeFormat(Migrator m) async {
  final db = m.database as Database;
  final projects = await ProjectQuery(db).getAllProjects();

  final collEventDateFields = ['startDate', 'endDate'];
  final collEventTimeFields = ['startTime', 'endTime'];

  for (final projectData in projects) {
    final eventList =
        await CollEventQuery(db).getAllCollEvents(projectData.uuid);

    for (final eventData in eventList) {
      bool doUpdate = false;
      List<String> updateStrings = [];
      final eventJson = eventData.toJson();

      for (final field in collEventDateFields) {
        final dateString = eventJson[field];

        if (dateString != null && dateString.isNotEmpty) {
          final updatedDateString = convertDateString(dateString);

          if (updatedDateString != dateString) {
            doUpdate = true;
            updateStrings.add('$field = \'$updatedDateString\'');
          }
        }
      }

      for (final field in collEventTimeFields) {
        final timeString = eventJson[field];

        if (timeString != null && timeString.isNotEmpty) {
          final updatedTimeString = convertTimeString(timeString);

          if (updatedTimeString != timeString) {
            doUpdate = true;
            updateStrings.add('$field = \'$updatedTimeString\'');
          }
        }
      }

      if (doUpdate) {
        db.customStatement('''UPDATE collEvent 
          SET ${updateStrings.join(',')} 
          WHERE id = '${eventJson['id']}'
          ''');
      }
    }
  }
}

Future<void> moveRelativeCaptureTimes(Migrator m) async {
  final db = m.database as Database;
  return db.customStatement('''
      UPDATE specimen 
      SET relativeCaptureTime = captureTime,
        captureTime = NULL
      WHERE isRelativeTime
        AND captureTime IN ('Dawn', 'Morning', 'Afternoon', 'Dusk', 'Night')   
    ''');
}

Future<void> setShowBatFieldsBoolean(Migrator m) async {
  final db = m.database as Database;
  return db.customStatement('''
      UPDATE mammalMeasurement AS mm
      SET showBatFields = 
        CASE
          WHEN s.taxonGroup = 'Bats' THEN 1 
          ELSE 0 
        END
      FROM specimen AS s
      WHERE mm.specimenUuid = s.uuid
    ''');
}
