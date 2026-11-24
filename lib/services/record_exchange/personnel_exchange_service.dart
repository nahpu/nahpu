import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as db;
import 'package:file_selector/file_selector.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/database/database.dart';

/// Encodes, decodes, and writes one personnel record exchanged between NAHPU
/// installations by QR code or JSON file.
///
/// The photo never travels in the payload: it is too large for a QR code and
/// is shared on its own as an image file.
class PersonnelExchangeService {
  const PersonnelExchangeService();

  static const String marker = 'nahpu_personnel';
  static const int version = 1;

  /// Compact form for QR codes.
  static String encodeQr(PersonnelData person) => jsonEncode(_envelope(person));

  /// Indented form for JSON files.
  static String encode(PersonnelData person) {
    return const JsonEncoder.withIndent('  ').convert(_envelope(person));
  }

  /// Parses a QR or file payload. Throws [FormatException] when it is not a
  /// supported NAHPU personnel record.
  static PersonnelData decode(String payload) {
    final Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException {
      throw const FormatException('Not a valid NAHPU personnel record.');
    }
    if (decoded is! Map || decoded[marker] is! int) {
      throw const FormatException('Not a NAHPU personnel record.');
    }
    if (decoded[marker] != version) {
      throw const FormatException(
        'This personnel record needs a newer version of NAHPU.',
      );
    }
    final values = decoded['personnel'];
    if (values is! Map) {
      throw const FormatException('The record has no personnel data.');
    }
    final uuid = _text(values, 'uuid');
    final name = _text(values, 'name');
    if (uuid == null) {
      throw const FormatException('The personnel record has no ID.');
    }
    if (name == null) {
      throw const FormatException('The personnel record has no name.');
    }
    final fieldNumber = values['currentFieldNumber'];
    final isRegisterField = values['isRegisterField'];
    return PersonnelData(
      uuid: uuid,
      name: name,
      initial: _text(values, 'initial'),
      email: _text(values, 'email'),
      phone: _text(values, 'phone'),
      affiliation: _text(values, 'affiliation'),
      orcid: _text(values, 'orcid'),
      role: _text(values, 'role'),
      currentFieldNumber: fieldNumber is int ? fieldNumber : null,
      notes: _text(values, 'notes'),
      isRegisterField: isRegisterField is bool ? isRegisterField : true,
    );
  }

  Future<File> save(
    PersonnelData person, {
    required String fileStem,
    Directory? destinationDirectory,
  }) async {
    final output = await AppIOServices(
      dir: destinationDirectory,
      fileStem: safeFileStem(fileStem),
      ext: 'json',
    ).getSavePath();
    await output.writeAsString(encode(person));
    return output;
  }

  Future<PersonnelData> read(XFile file) async {
    return decode(await File(file.path).readAsString());
  }

  /// A file name stem built from the person's name, safe on every platform.
  static String safeFileStem(String value) {
    final withoutExtension = value.trim().replaceFirst(
      RegExp(r'\.json$', caseSensitive: false),
      '',
    );
    final cleaned = withoutExtension
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return cleaned.isEmpty ? 'personnel' : cleaned;
  }

  static Map<String, Object?> _envelope(PersonnelData person) {
    return {
      marker: version,
      'personnel': {
        'uuid': person.uuid,
        'name': person.name,
        'initial': person.initial,
        'email': person.email,
        'phone': person.phone,
        'affiliation': person.affiliation,
        'orcid': person.orcid,
        'role': person.role,
        'currentFieldNumber': person.currentFieldNumber,
        'notes': person.notes,
        'isRegisterField': person.isRegisterField,
      },
    };
  }

  static String? _text(Map values, String key) {
    final value = values[key];
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// A personnel field whose value differs between this device and an import.
enum PersonnelField {
  name,
  initial,
  email,
  phone,
  affiliation,
  orcid,
  role,
  currentFieldNumber,
  notes,
  isRegisterField;

  Object? valueOf(PersonnelData person) => switch (this) {
    name => person.name,
    initial => person.initial,
    email => person.email,
    phone => person.phone,
    affiliation => person.affiliation,
    orcid => person.orcid,
    role => person.role,
    currentFieldNumber => person.currentFieldNumber,
    notes => person.notes,
    isRegisterField => person.isRegisterField,
  };
}

class PersonnelFieldChange {
  const PersonnelFieldChange({
    required this.field,
    required this.current,
    required this.incoming,
  });

  final PersonnelField field;
  final Object? current;
  final Object? incoming;
}

/// What importing a shared person would do on this device.
class PersonnelImportPreview {
  const PersonnelImportPreview({
    required this.incoming,
    this.existing,
    this.changes = const [],
  });

  final PersonnelData incoming;

  /// The person already on this device with the same ID, if any.
  final PersonnelData? existing;

  /// Fields that differ from [existing]. Empty for a new person.
  final List<PersonnelFieldChange> changes;

  bool get isNew => existing == null;
}

/// Adds a shared person to the database and links them to a project.
class PersonnelImporter {
  const PersonnelImporter(this.database);

  final Database database;

  Future<PersonnelImportPreview> preview(PersonnelData incoming) async {
    final existing = await _find(incoming.uuid);
    if (existing == null) return PersonnelImportPreview(incoming: incoming);
    final changes = [
      for (final field in PersonnelField.values)
        if (field.valueOf(existing) != field.valueOf(incoming))
          PersonnelFieldChange(
            field: field,
            current: field.valueOf(existing),
            incoming: field.valueOf(incoming),
          ),
    ];
    return PersonnelImportPreview(
      incoming: incoming,
      existing: existing,
      changes: changes,
    );
  }

  /// Inserts a new person, or updates an existing one when
  /// [updateExisting] is true, keeping their photo. Links them to
  /// [projectUuid] when one is open.
  Future<void> apply(
    PersonnelData incoming, {
    required bool updateExisting,
    String? projectUuid,
  }) {
    return database.transaction(() async {
      final existing = await _find(incoming.uuid);
      if (existing == null) {
        await database
            .into(database.personnel)
            .insert(incoming.copyWith(photoPath: const db.Value(null)));
      } else if (updateExisting) {
        await (database.update(
          database.personnel,
        )..where((row) => row.uuid.equals(incoming.uuid))).write(
          incoming
              .copyWith(photoPath: db.Value(existing.photoPath))
              .toCompanion(false),
        );
      }
      if (projectUuid != null && projectUuid.isNotEmpty) {
        await linkPersonnelToProject(
          database,
          projectUuid: projectUuid,
          personnelUuid: incoming.uuid,
        );
      }
    });
  }

  Future<PersonnelData?> _find(String uuid) {
    return (database.select(
      database.personnel,
    )..where((row) => row.uuid.equals(uuid))).getSingleOrNull();
  }
}

/// Adds the project link for a person unless it is already there.
Future<void> linkPersonnelToProject(
  Database database, {
  required String projectUuid,
  required String personnelUuid,
}) async {
  final link =
      await (database.select(database.personnelList)
            ..where((row) => row.projectUuid.equals(projectUuid))
            ..where((row) => row.personnelUuid.equals(personnelUuid)))
          .getSingleOrNull();
  if (link != null) return;
  await database
      .into(database.personnelList)
      .insert(
        PersonnelListCompanion(
          projectUuid: db.Value(projectUuid),
          personnelUuid: db.Value(personnelUuid),
        ),
      );
}
