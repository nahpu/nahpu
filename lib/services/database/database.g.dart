// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Project extends Table with TableInfo<Project, ProjectData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Project(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL UNIQUE');
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _principalInvestigatorMeta =
      const VerificationMeta('principalInvestigator');
  late final GeneratedColumn<String> principalInvestigator =
      GeneratedColumn<String>('principalInvestigator', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'startDate', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
      'endDate', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _createdMeta =
      const VerificationMeta('created');
  late final GeneratedColumn<String> created = GeneratedColumn<String>(
      'created', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _lastAccessedMeta =
      const VerificationMeta('lastAccessed');
  late final GeneratedColumn<String> lastAccessed = GeneratedColumn<String>(
      'lastAccessed', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        name,
        description,
        principalInvestigator,
        location,
        startDate,
        endDate,
        created,
        lastAccessed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project';
  @override
  VerificationContext validateIntegrity(Insertable<ProjectData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('principalInvestigator')) {
      context.handle(
          _principalInvestigatorMeta,
          principalInvestigator.isAcceptableOrUnknown(
              data['principalInvestigator']!, _principalInvestigatorMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('startDate')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['startDate']!, _startDateMeta));
    }
    if (data.containsKey('endDate')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['endDate']!, _endDateMeta));
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created']!, _createdMeta));
    }
    if (data.containsKey('lastAccessed')) {
      context.handle(
          _lastAccessedMeta,
          lastAccessed.isAcceptableOrUnknown(
              data['lastAccessed']!, _lastAccessedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  ProjectData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectData(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      principalInvestigator: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}principalInvestigator']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}startDate']),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}endDate']),
      created: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created']),
      lastAccessed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lastAccessed']),
    );
  }

  @override
  Project createAlias(String alias) {
    return Project(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ProjectData extends DataClass implements Insertable<ProjectData> {
  final String uuid;
  final String name;
  final String? description;
  final String? principalInvestigator;
  final String? location;
  final String? startDate;
  final String? endDate;
  final String? created;
  final String? lastAccessed;
  const ProjectData(
      {required this.uuid,
      required this.name,
      this.description,
      this.principalInvestigator,
      this.location,
      this.startDate,
      this.endDate,
      this.created,
      this.lastAccessed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || principalInvestigator != null) {
      map['principalInvestigator'] = Variable<String>(principalInvestigator);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || startDate != null) {
      map['startDate'] = Variable<String>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['endDate'] = Variable<String>(endDate);
    }
    if (!nullToAbsent || created != null) {
      map['created'] = Variable<String>(created);
    }
    if (!nullToAbsent || lastAccessed != null) {
      map['lastAccessed'] = Variable<String>(lastAccessed);
    }
    return map;
  }

  ProjectCompanion toCompanion(bool nullToAbsent) {
    return ProjectCompanion(
      uuid: Value(uuid),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      principalInvestigator: principalInvestigator == null && nullToAbsent
          ? const Value.absent()
          : Value(principalInvestigator),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      created: created == null && nullToAbsent
          ? const Value.absent()
          : Value(created),
      lastAccessed: lastAccessed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccessed),
    );
  }

  factory ProjectData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectData(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      principalInvestigator:
          serializer.fromJson<String?>(json['principalInvestigator']),
      location: serializer.fromJson<String?>(json['location']),
      startDate: serializer.fromJson<String?>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      created: serializer.fromJson<String?>(json['created']),
      lastAccessed: serializer.fromJson<String?>(json['lastAccessed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'principalInvestigator':
          serializer.toJson<String?>(principalInvestigator),
      'location': serializer.toJson<String?>(location),
      'startDate': serializer.toJson<String?>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'created': serializer.toJson<String?>(created),
      'lastAccessed': serializer.toJson<String?>(lastAccessed),
    };
  }

  ProjectData copyWith(
          {String? uuid,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> principalInvestigator = const Value.absent(),
          Value<String?> location = const Value.absent(),
          Value<String?> startDate = const Value.absent(),
          Value<String?> endDate = const Value.absent(),
          Value<String?> created = const Value.absent(),
          Value<String?> lastAccessed = const Value.absent()}) =>
      ProjectData(
        uuid: uuid ?? this.uuid,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        principalInvestigator: principalInvestigator.present
            ? principalInvestigator.value
            : this.principalInvestigator,
        location: location.present ? location.value : this.location,
        startDate: startDate.present ? startDate.value : this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        created: created.present ? created.value : this.created,
        lastAccessed:
            lastAccessed.present ? lastAccessed.value : this.lastAccessed,
      );
  ProjectData copyWithCompanion(ProjectCompanion data) {
    return ProjectData(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      principalInvestigator: data.principalInvestigator.present
          ? data.principalInvestigator.value
          : this.principalInvestigator,
      location: data.location.present ? data.location.value : this.location,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      created: data.created.present ? data.created.value : this.created,
      lastAccessed: data.lastAccessed.present
          ? data.lastAccessed.value
          : this.lastAccessed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectData(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('principalInvestigator: $principalInvestigator, ')
          ..write('location: $location, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('created: $created, ')
          ..write('lastAccessed: $lastAccessed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      uuid,
      name,
      description,
      principalInvestigator,
      location,
      startDate,
      endDate,
      created,
      lastAccessed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectData &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.description == this.description &&
          other.principalInvestigator == this.principalInvestigator &&
          other.location == this.location &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.created == this.created &&
          other.lastAccessed == this.lastAccessed);
}

class ProjectCompanion extends UpdateCompanion<ProjectData> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> principalInvestigator;
  final Value<String?> location;
  final Value<String?> startDate;
  final Value<String?> endDate;
  final Value<String?> created;
  final Value<String?> lastAccessed;
  final Value<int> rowid;
  const ProjectCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.principalInvestigator = const Value.absent(),
    this.location = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.created = const Value.absent(),
    this.lastAccessed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectCompanion.insert({
    required String uuid,
    required String name,
    this.description = const Value.absent(),
    this.principalInvestigator = const Value.absent(),
    this.location = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.created = const Value.absent(),
    this.lastAccessed = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uuid = Value(uuid),
        name = Value(name);
  static Insertable<ProjectData> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? principalInvestigator,
    Expression<String>? location,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? created,
    Expression<String>? lastAccessed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (principalInvestigator != null)
        'principalInvestigator': principalInvestigator,
      if (location != null) 'location': location,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      if (created != null) 'created': created,
      if (lastAccessed != null) 'lastAccessed': lastAccessed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectCompanion copyWith(
      {Value<String>? uuid,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? principalInvestigator,
      Value<String?>? location,
      Value<String?>? startDate,
      Value<String?>? endDate,
      Value<String?>? created,
      Value<String?>? lastAccessed,
      Value<int>? rowid}) {
    return ProjectCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      principalInvestigator:
          principalInvestigator ?? this.principalInvestigator,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      created: created ?? this.created,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (principalInvestigator.present) {
      map['principalInvestigator'] =
          Variable<String>(principalInvestigator.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (startDate.present) {
      map['startDate'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['endDate'] = Variable<String>(endDate.value);
    }
    if (created.present) {
      map['created'] = Variable<String>(created.value);
    }
    if (lastAccessed.present) {
      map['lastAccessed'] = Variable<String>(lastAccessed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('principalInvestigator: $principalInvestigator, ')
          ..write('location: $location, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('created: $created, ')
          ..write('lastAccessed: $lastAccessed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Personnel extends Table with TableInfo<Personnel, PersonnelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Personnel(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL PRIMARY KEY');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _initialMeta =
      const VerificationMeta('initial');
  late final GeneratedColumn<String> initial = GeneratedColumn<String>(
      'initial', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _affiliationMeta =
      const VerificationMeta('affiliation');
  late final GeneratedColumn<String> affiliation = GeneratedColumn<String>(
      'affiliation', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _currentFieldNumberMeta =
      const VerificationMeta('currentFieldNumber');
  late final GeneratedColumn<int> currentFieldNumber = GeneratedColumn<int>(
      'currentFieldNumber', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photoPath', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        name,
        initial,
        email,
        phone,
        affiliation,
        role,
        currentFieldNumber,
        notes,
        photoPath
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personnel';
  @override
  VerificationContext validateIntegrity(Insertable<PersonnelData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('initial')) {
      context.handle(_initialMeta,
          initial.isAcceptableOrUnknown(data['initial']!, _initialMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('affiliation')) {
      context.handle(
          _affiliationMeta,
          affiliation.isAcceptableOrUnknown(
              data['affiliation']!, _affiliationMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('currentFieldNumber')) {
      context.handle(
          _currentFieldNumberMeta,
          currentFieldNumber.isAcceptableOrUnknown(
              data['currentFieldNumber']!, _currentFieldNumberMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('photoPath')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photoPath']!, _photoPathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  PersonnelData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonnelData(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      initial: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}initial']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      affiliation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}affiliation']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role']),
      currentFieldNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}currentFieldNumber']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photoPath']),
    );
  }

  @override
  Personnel createAlias(String alias) {
    return Personnel(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class PersonnelData extends DataClass implements Insertable<PersonnelData> {
  final String uuid;
  final String? name;
  final String? initial;
  final String? email;
  final String? phone;
  final String? affiliation;
  final String? role;
  final int? currentFieldNumber;

  /// the next input for field number
  final String? notes;
  final String? photoPath;
  const PersonnelData(
      {required this.uuid,
      this.name,
      this.initial,
      this.email,
      this.phone,
      this.affiliation,
      this.role,
      this.currentFieldNumber,
      this.notes,
      this.photoPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || initial != null) {
      map['initial'] = Variable<String>(initial);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || affiliation != null) {
      map['affiliation'] = Variable<String>(affiliation);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || currentFieldNumber != null) {
      map['currentFieldNumber'] = Variable<int>(currentFieldNumber);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photoPath'] = Variable<String>(photoPath);
    }
    return map;
  }

  PersonnelCompanion toCompanion(bool nullToAbsent) {
    return PersonnelCompanion(
      uuid: Value(uuid),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      initial: initial == null && nullToAbsent
          ? const Value.absent()
          : Value(initial),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      affiliation: affiliation == null && nullToAbsent
          ? const Value.absent()
          : Value(affiliation),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      currentFieldNumber: currentFieldNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(currentFieldNumber),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
    );
  }

  factory PersonnelData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonnelData(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String?>(json['name']),
      initial: serializer.fromJson<String?>(json['initial']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      affiliation: serializer.fromJson<String?>(json['affiliation']),
      role: serializer.fromJson<String?>(json['role']),
      currentFieldNumber: serializer.fromJson<int?>(json['currentFieldNumber']),
      notes: serializer.fromJson<String?>(json['notes']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String?>(name),
      'initial': serializer.toJson<String?>(initial),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'affiliation': serializer.toJson<String?>(affiliation),
      'role': serializer.toJson<String?>(role),
      'currentFieldNumber': serializer.toJson<int?>(currentFieldNumber),
      'notes': serializer.toJson<String?>(notes),
      'photoPath': serializer.toJson<String?>(photoPath),
    };
  }

  PersonnelData copyWith(
          {String? uuid,
          Value<String?> name = const Value.absent(),
          Value<String?> initial = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> affiliation = const Value.absent(),
          Value<String?> role = const Value.absent(),
          Value<int?> currentFieldNumber = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> photoPath = const Value.absent()}) =>
      PersonnelData(
        uuid: uuid ?? this.uuid,
        name: name.present ? name.value : this.name,
        initial: initial.present ? initial.value : this.initial,
        email: email.present ? email.value : this.email,
        phone: phone.present ? phone.value : this.phone,
        affiliation: affiliation.present ? affiliation.value : this.affiliation,
        role: role.present ? role.value : this.role,
        currentFieldNumber: currentFieldNumber.present
            ? currentFieldNumber.value
            : this.currentFieldNumber,
        notes: notes.present ? notes.value : this.notes,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
      );
  PersonnelData copyWithCompanion(PersonnelCompanion data) {
    return PersonnelData(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      initial: data.initial.present ? data.initial.value : this.initial,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      affiliation:
          data.affiliation.present ? data.affiliation.value : this.affiliation,
      role: data.role.present ? data.role.value : this.role,
      currentFieldNumber: data.currentFieldNumber.present
          ? data.currentFieldNumber.value
          : this.currentFieldNumber,
      notes: data.notes.present ? data.notes.value : this.notes,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonnelData(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('initial: $initial, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('affiliation: $affiliation, ')
          ..write('role: $role, ')
          ..write('currentFieldNumber: $currentFieldNumber, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, name, initial, email, phone,
      affiliation, role, currentFieldNumber, notes, photoPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonnelData &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.initial == this.initial &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.affiliation == this.affiliation &&
          other.role == this.role &&
          other.currentFieldNumber == this.currentFieldNumber &&
          other.notes == this.notes &&
          other.photoPath == this.photoPath);
}

class PersonnelCompanion extends UpdateCompanion<PersonnelData> {
  final Value<String> uuid;
  final Value<String?> name;
  final Value<String?> initial;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> affiliation;
  final Value<String?> role;
  final Value<int?> currentFieldNumber;
  final Value<String?> notes;
  final Value<String?> photoPath;
  final Value<int> rowid;
  const PersonnelCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.initial = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.affiliation = const Value.absent(),
    this.role = const Value.absent(),
    this.currentFieldNumber = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonnelCompanion.insert({
    required String uuid,
    this.name = const Value.absent(),
    this.initial = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.affiliation = const Value.absent(),
    this.role = const Value.absent(),
    this.currentFieldNumber = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid);
  static Insertable<PersonnelData> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<String>? initial,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? affiliation,
    Expression<String>? role,
    Expression<int>? currentFieldNumber,
    Expression<String>? notes,
    Expression<String>? photoPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (initial != null) 'initial': initial,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (affiliation != null) 'affiliation': affiliation,
      if (role != null) 'role': role,
      if (currentFieldNumber != null) 'currentFieldNumber': currentFieldNumber,
      if (notes != null) 'notes': notes,
      if (photoPath != null) 'photoPath': photoPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonnelCompanion copyWith(
      {Value<String>? uuid,
      Value<String?>? name,
      Value<String?>? initial,
      Value<String?>? email,
      Value<String?>? phone,
      Value<String?>? affiliation,
      Value<String?>? role,
      Value<int?>? currentFieldNumber,
      Value<String?>? notes,
      Value<String?>? photoPath,
      Value<int>? rowid}) {
    return PersonnelCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      initial: initial ?? this.initial,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      affiliation: affiliation ?? this.affiliation,
      role: role ?? this.role,
      currentFieldNumber: currentFieldNumber ?? this.currentFieldNumber,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (initial.present) {
      map['initial'] = Variable<String>(initial.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (affiliation.present) {
      map['affiliation'] = Variable<String>(affiliation.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (currentFieldNumber.present) {
      map['currentFieldNumber'] = Variable<int>(currentFieldNumber.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photoPath.present) {
      map['photoPath'] = Variable<String>(photoPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonnelCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('initial: $initial, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('affiliation: $affiliation, ')
          ..write('role: $role, ')
          ..write('currentFieldNumber: $currentFieldNumber, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Media extends Table with TableInfo<Media, MediaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Media(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _primaryIdMeta =
      const VerificationMeta('primaryId');
  late final GeneratedColumn<int> primaryId = GeneratedColumn<int>(
      'primaryId', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _projectUuidMeta =
      const VerificationMeta('projectUuid');
  late final GeneratedColumn<String> projectUuid = GeneratedColumn<String>(
      'projectUuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _secondaryIdMeta =
      const VerificationMeta('secondaryId');
  late final GeneratedColumn<String> secondaryId = GeneratedColumn<String>(
      'secondaryId', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
      'tag', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _takenMeta = const VerificationMeta('taken');
  late final GeneratedColumn<String> taken = GeneratedColumn<String>(
      'taken', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _cameraMeta = const VerificationMeta('camera');
  late final GeneratedColumn<String> camera = GeneratedColumn<String>(
      'camera', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _lensesMeta = const VerificationMeta('lenses');
  late final GeneratedColumn<String> lenses = GeneratedColumn<String>(
      'lenses', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _additionalExifMeta =
      const VerificationMeta('additionalExif');
  late final GeneratedColumn<String> additionalExif = GeneratedColumn<String>(
      'additionalExif', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _personnelIdMeta =
      const VerificationMeta('personnelId');
  late final GeneratedColumn<String> personnelId = GeneratedColumn<String>(
      'personnelId', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'fileName', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _captionMeta =
      const VerificationMeta('caption');
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
      'caption', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        primaryId,
        projectUuid,
        secondaryId,
        category,
        tag,
        taken,
        camera,
        lenses,
        additionalExif,
        personnelId,
        fileName,
        caption
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media';
  @override
  VerificationContext validateIntegrity(Insertable<MediaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('primaryId')) {
      context.handle(_primaryIdMeta,
          primaryId.isAcceptableOrUnknown(data['primaryId']!, _primaryIdMeta));
    }
    if (data.containsKey('projectUuid')) {
      context.handle(
          _projectUuidMeta,
          projectUuid.isAcceptableOrUnknown(
              data['projectUuid']!, _projectUuidMeta));
    }
    if (data.containsKey('secondaryId')) {
      context.handle(
          _secondaryIdMeta,
          secondaryId.isAcceptableOrUnknown(
              data['secondaryId']!, _secondaryIdMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('tag')) {
      context.handle(
          _tagMeta, tag.isAcceptableOrUnknown(data['tag']!, _tagMeta));
    }
    if (data.containsKey('taken')) {
      context.handle(
          _takenMeta, taken.isAcceptableOrUnknown(data['taken']!, _takenMeta));
    }
    if (data.containsKey('camera')) {
      context.handle(_cameraMeta,
          camera.isAcceptableOrUnknown(data['camera']!, _cameraMeta));
    }
    if (data.containsKey('lenses')) {
      context.handle(_lensesMeta,
          lenses.isAcceptableOrUnknown(data['lenses']!, _lensesMeta));
    }
    if (data.containsKey('additionalExif')) {
      context.handle(
          _additionalExifMeta,
          additionalExif.isAcceptableOrUnknown(
              data['additionalExif']!, _additionalExifMeta));
    }
    if (data.containsKey('personnelId')) {
      context.handle(
          _personnelIdMeta,
          personnelId.isAcceptableOrUnknown(
              data['personnelId']!, _personnelIdMeta));
    }
    if (data.containsKey('fileName')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['fileName']!, _fileNameMeta));
    }
    if (data.containsKey('caption')) {
      context.handle(_captionMeta,
          caption.isAcceptableOrUnknown(data['caption']!, _captionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {primaryId};
  @override
  MediaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaData(
      primaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}primaryId'])!,
      projectUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}projectUuid']),
      secondaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}secondaryId']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      tag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag']),
      taken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}taken']),
      camera: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}camera']),
      lenses: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lenses']),
      additionalExif: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}additionalExif']),
      personnelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}personnelId']),
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fileName']),
      caption: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}caption']),
    );
  }

  @override
  Media createAlias(String alias) {
    return Media(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'FOREIGN KEY(personnelId)REFERENCES personnel(uuid)',
        'FOREIGN KEY(projectUuid)REFERENCES project(uuid)'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class MediaData extends DataClass implements Insertable<MediaData> {
  final int primaryId;
  final String? projectUuid;
  final String? secondaryId;
  final String? category;
  final String? tag;
  final String? taken;
  final String? camera;
  final String? lenses;
  final String? additionalExif;
  final String? personnelId;
  final String? fileName;
  final String? caption;
  const MediaData(
      {required this.primaryId,
      this.projectUuid,
      this.secondaryId,
      this.category,
      this.tag,
      this.taken,
      this.camera,
      this.lenses,
      this.additionalExif,
      this.personnelId,
      this.fileName,
      this.caption});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['primaryId'] = Variable<int>(primaryId);
    if (!nullToAbsent || projectUuid != null) {
      map['projectUuid'] = Variable<String>(projectUuid);
    }
    if (!nullToAbsent || secondaryId != null) {
      map['secondaryId'] = Variable<String>(secondaryId);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || tag != null) {
      map['tag'] = Variable<String>(tag);
    }
    if (!nullToAbsent || taken != null) {
      map['taken'] = Variable<String>(taken);
    }
    if (!nullToAbsent || camera != null) {
      map['camera'] = Variable<String>(camera);
    }
    if (!nullToAbsent || lenses != null) {
      map['lenses'] = Variable<String>(lenses);
    }
    if (!nullToAbsent || additionalExif != null) {
      map['additionalExif'] = Variable<String>(additionalExif);
    }
    if (!nullToAbsent || personnelId != null) {
      map['personnelId'] = Variable<String>(personnelId);
    }
    if (!nullToAbsent || fileName != null) {
      map['fileName'] = Variable<String>(fileName);
    }
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    return map;
  }

  MediaCompanion toCompanion(bool nullToAbsent) {
    return MediaCompanion(
      primaryId: Value(primaryId),
      projectUuid: projectUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(projectUuid),
      secondaryId: secondaryId == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryId),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      tag: tag == null && nullToAbsent ? const Value.absent() : Value(tag),
      taken:
          taken == null && nullToAbsent ? const Value.absent() : Value(taken),
      camera:
          camera == null && nullToAbsent ? const Value.absent() : Value(camera),
      lenses:
          lenses == null && nullToAbsent ? const Value.absent() : Value(lenses),
      additionalExif: additionalExif == null && nullToAbsent
          ? const Value.absent()
          : Value(additionalExif),
      personnelId: personnelId == null && nullToAbsent
          ? const Value.absent()
          : Value(personnelId),
      fileName: fileName == null && nullToAbsent
          ? const Value.absent()
          : Value(fileName),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
    );
  }

  factory MediaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaData(
      primaryId: serializer.fromJson<int>(json['primaryId']),
      projectUuid: serializer.fromJson<String?>(json['projectUuid']),
      secondaryId: serializer.fromJson<String?>(json['secondaryId']),
      category: serializer.fromJson<String?>(json['category']),
      tag: serializer.fromJson<String?>(json['tag']),
      taken: serializer.fromJson<String?>(json['taken']),
      camera: serializer.fromJson<String?>(json['camera']),
      lenses: serializer.fromJson<String?>(json['lenses']),
      additionalExif: serializer.fromJson<String?>(json['additionalExif']),
      personnelId: serializer.fromJson<String?>(json['personnelId']),
      fileName: serializer.fromJson<String?>(json['fileName']),
      caption: serializer.fromJson<String?>(json['caption']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'primaryId': serializer.toJson<int>(primaryId),
      'projectUuid': serializer.toJson<String?>(projectUuid),
      'secondaryId': serializer.toJson<String?>(secondaryId),
      'category': serializer.toJson<String?>(category),
      'tag': serializer.toJson<String?>(tag),
      'taken': serializer.toJson<String?>(taken),
      'camera': serializer.toJson<String?>(camera),
      'lenses': serializer.toJson<String?>(lenses),
      'additionalExif': serializer.toJson<String?>(additionalExif),
      'personnelId': serializer.toJson<String?>(personnelId),
      'fileName': serializer.toJson<String?>(fileName),
      'caption': serializer.toJson<String?>(caption),
    };
  }

  MediaData copyWith(
          {int? primaryId,
          Value<String?> projectUuid = const Value.absent(),
          Value<String?> secondaryId = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<String?> tag = const Value.absent(),
          Value<String?> taken = const Value.absent(),
          Value<String?> camera = const Value.absent(),
          Value<String?> lenses = const Value.absent(),
          Value<String?> additionalExif = const Value.absent(),
          Value<String?> personnelId = const Value.absent(),
          Value<String?> fileName = const Value.absent(),
          Value<String?> caption = const Value.absent()}) =>
      MediaData(
        primaryId: primaryId ?? this.primaryId,
        projectUuid: projectUuid.present ? projectUuid.value : this.projectUuid,
        secondaryId: secondaryId.present ? secondaryId.value : this.secondaryId,
        category: category.present ? category.value : this.category,
        tag: tag.present ? tag.value : this.tag,
        taken: taken.present ? taken.value : this.taken,
        camera: camera.present ? camera.value : this.camera,
        lenses: lenses.present ? lenses.value : this.lenses,
        additionalExif:
            additionalExif.present ? additionalExif.value : this.additionalExif,
        personnelId: personnelId.present ? personnelId.value : this.personnelId,
        fileName: fileName.present ? fileName.value : this.fileName,
        caption: caption.present ? caption.value : this.caption,
      );
  MediaData copyWithCompanion(MediaCompanion data) {
    return MediaData(
      primaryId: data.primaryId.present ? data.primaryId.value : this.primaryId,
      projectUuid:
          data.projectUuid.present ? data.projectUuid.value : this.projectUuid,
      secondaryId:
          data.secondaryId.present ? data.secondaryId.value : this.secondaryId,
      category: data.category.present ? data.category.value : this.category,
      tag: data.tag.present ? data.tag.value : this.tag,
      taken: data.taken.present ? data.taken.value : this.taken,
      camera: data.camera.present ? data.camera.value : this.camera,
      lenses: data.lenses.present ? data.lenses.value : this.lenses,
      additionalExif: data.additionalExif.present
          ? data.additionalExif.value
          : this.additionalExif,
      personnelId:
          data.personnelId.present ? data.personnelId.value : this.personnelId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      caption: data.caption.present ? data.caption.value : this.caption,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaData(')
          ..write('primaryId: $primaryId, ')
          ..write('projectUuid: $projectUuid, ')
          ..write('secondaryId: $secondaryId, ')
          ..write('category: $category, ')
          ..write('tag: $tag, ')
          ..write('taken: $taken, ')
          ..write('camera: $camera, ')
          ..write('lenses: $lenses, ')
          ..write('additionalExif: $additionalExif, ')
          ..write('personnelId: $personnelId, ')
          ..write('fileName: $fileName, ')
          ..write('caption: $caption')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      primaryId,
      projectUuid,
      secondaryId,
      category,
      tag,
      taken,
      camera,
      lenses,
      additionalExif,
      personnelId,
      fileName,
      caption);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaData &&
          other.primaryId == this.primaryId &&
          other.projectUuid == this.projectUuid &&
          other.secondaryId == this.secondaryId &&
          other.category == this.category &&
          other.tag == this.tag &&
          other.taken == this.taken &&
          other.camera == this.camera &&
          other.lenses == this.lenses &&
          other.additionalExif == this.additionalExif &&
          other.personnelId == this.personnelId &&
          other.fileName == this.fileName &&
          other.caption == this.caption);
}

class MediaCompanion extends UpdateCompanion<MediaData> {
  final Value<int> primaryId;
  final Value<String?> projectUuid;
  final Value<String?> secondaryId;
  final Value<String?> category;
  final Value<String?> tag;
  final Value<String?> taken;
  final Value<String?> camera;
  final Value<String?> lenses;
  final Value<String?> additionalExif;
  final Value<String?> personnelId;
  final Value<String?> fileName;
  final Value<String?> caption;
  const MediaCompanion({
    this.primaryId = const Value.absent(),
    this.projectUuid = const Value.absent(),
    this.secondaryId = const Value.absent(),
    this.category = const Value.absent(),
    this.tag = const Value.absent(),
    this.taken = const Value.absent(),
    this.camera = const Value.absent(),
    this.lenses = const Value.absent(),
    this.additionalExif = const Value.absent(),
    this.personnelId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.caption = const Value.absent(),
  });
  MediaCompanion.insert({
    this.primaryId = const Value.absent(),
    this.projectUuid = const Value.absent(),
    this.secondaryId = const Value.absent(),
    this.category = const Value.absent(),
    this.tag = const Value.absent(),
    this.taken = const Value.absent(),
    this.camera = const Value.absent(),
    this.lenses = const Value.absent(),
    this.additionalExif = const Value.absent(),
    this.personnelId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.caption = const Value.absent(),
  });
  static Insertable<MediaData> custom({
    Expression<int>? primaryId,
    Expression<String>? projectUuid,
    Expression<String>? secondaryId,
    Expression<String>? category,
    Expression<String>? tag,
    Expression<String>? taken,
    Expression<String>? camera,
    Expression<String>? lenses,
    Expression<String>? additionalExif,
    Expression<String>? personnelId,
    Expression<String>? fileName,
    Expression<String>? caption,
  }) {
    return RawValuesInsertable({
      if (primaryId != null) 'primaryId': primaryId,
      if (projectUuid != null) 'projectUuid': projectUuid,
      if (secondaryId != null) 'secondaryId': secondaryId,
      if (category != null) 'category': category,
      if (tag != null) 'tag': tag,
      if (taken != null) 'taken': taken,
      if (camera != null) 'camera': camera,
      if (lenses != null) 'lenses': lenses,
      if (additionalExif != null) 'additionalExif': additionalExif,
      if (personnelId != null) 'personnelId': personnelId,
      if (fileName != null) 'fileName': fileName,
      if (caption != null) 'caption': caption,
    });
  }

  MediaCompanion copyWith(
      {Value<int>? primaryId,
      Value<String?>? projectUuid,
      Value<String?>? secondaryId,
      Value<String?>? category,
      Value<String?>? tag,
      Value<String?>? taken,
      Value<String?>? camera,
      Value<String?>? lenses,
      Value<String?>? additionalExif,
      Value<String?>? personnelId,
      Value<String?>? fileName,
      Value<String?>? caption}) {
    return MediaCompanion(
      primaryId: primaryId ?? this.primaryId,
      projectUuid: projectUuid ?? this.projectUuid,
      secondaryId: secondaryId ?? this.secondaryId,
      category: category ?? this.category,
      tag: tag ?? this.tag,
      taken: taken ?? this.taken,
      camera: camera ?? this.camera,
      lenses: lenses ?? this.lenses,
      additionalExif: additionalExif ?? this.additionalExif,
      personnelId: personnelId ?? this.personnelId,
      fileName: fileName ?? this.fileName,
      caption: caption ?? this.caption,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (primaryId.present) {
      map['primaryId'] = Variable<int>(primaryId.value);
    }
    if (projectUuid.present) {
      map['projectUuid'] = Variable<String>(projectUuid.value);
    }
    if (secondaryId.present) {
      map['secondaryId'] = Variable<String>(secondaryId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (taken.present) {
      map['taken'] = Variable<String>(taken.value);
    }
    if (camera.present) {
      map['camera'] = Variable<String>(camera.value);
    }
    if (lenses.present) {
      map['lenses'] = Variable<String>(lenses.value);
    }
    if (additionalExif.present) {
      map['additionalExif'] = Variable<String>(additionalExif.value);
    }
    if (personnelId.present) {
      map['personnelId'] = Variable<String>(personnelId.value);
    }
    if (fileName.present) {
      map['fileName'] = Variable<String>(fileName.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaCompanion(')
          ..write('primaryId: $primaryId, ')
          ..write('projectUuid: $projectUuid, ')
          ..write('secondaryId: $secondaryId, ')
          ..write('category: $category, ')
          ..write('tag: $tag, ')
          ..write('taken: $taken, ')
          ..write('camera: $camera, ')
          ..write('lenses: $lenses, ')
          ..write('additionalExif: $additionalExif, ')
          ..write('personnelId: $personnelId, ')
          ..write('fileName: $fileName, ')
          ..write('caption: $caption')
          ..write(')'))
        .toString();
  }
}

class Site extends Table with TableInfo<Site, SiteData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Site(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _siteIDMeta = const VerificationMeta('siteID');
  late final GeneratedColumn<String> siteID = GeneratedColumn<String>(
      'siteID', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _projectUuidMeta =
      const VerificationMeta('projectUuid');
  late final GeneratedColumn<String> projectUuid = GeneratedColumn<String>(
      'projectUuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _leadStaffIdMeta =
      const VerificationMeta('leadStaffId');
  late final GeneratedColumn<String> leadStaffId = GeneratedColumn<String>(
      'leadStaffId', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _siteTypeMeta =
      const VerificationMeta('siteType');
  late final GeneratedColumn<String> siteType = GeneratedColumn<String>(
      'siteType', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _countryMeta =
      const VerificationMeta('country');
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
      'country', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _stateProvinceMeta =
      const VerificationMeta('stateProvince');
  late final GeneratedColumn<String> stateProvince = GeneratedColumn<String>(
      'stateProvince', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _countyMeta = const VerificationMeta('county');
  late final GeneratedColumn<String> county = GeneratedColumn<String>(
      'county', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _municipalityMeta =
      const VerificationMeta('municipality');
  late final GeneratedColumn<String> municipality = GeneratedColumn<String>(
      'municipality', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _mediaIDMeta =
      const VerificationMeta('mediaID');
  late final GeneratedColumn<String> mediaID = GeneratedColumn<String>(
      'mediaID', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _localityMeta =
      const VerificationMeta('locality');
  late final GeneratedColumn<String> locality = GeneratedColumn<String>(
      'locality', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
      'remark', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _habitatTypeMeta =
      const VerificationMeta('habitatType');
  late final GeneratedColumn<String> habitatType = GeneratedColumn<String>(
      'habitatType', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _habitatConditionMeta =
      const VerificationMeta('habitatCondition');
  late final GeneratedColumn<String> habitatCondition = GeneratedColumn<String>(
      'habitatCondition', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _habitatDescriptionMeta =
      const VerificationMeta('habitatDescription');
  late final GeneratedColumn<String> habitatDescription =
      GeneratedColumn<String>('habitatDescription', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        siteID,
        projectUuid,
        leadStaffId,
        siteType,
        country,
        stateProvince,
        county,
        municipality,
        mediaID,
        locality,
        remark,
        habitatType,
        habitatCondition,
        habitatDescription
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'site';
  @override
  VerificationContext validateIntegrity(Insertable<SiteData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('siteID')) {
      context.handle(_siteIDMeta,
          siteID.isAcceptableOrUnknown(data['siteID']!, _siteIDMeta));
    }
    if (data.containsKey('projectUuid')) {
      context.handle(
          _projectUuidMeta,
          projectUuid.isAcceptableOrUnknown(
              data['projectUuid']!, _projectUuidMeta));
    }
    if (data.containsKey('leadStaffId')) {
      context.handle(
          _leadStaffIdMeta,
          leadStaffId.isAcceptableOrUnknown(
              data['leadStaffId']!, _leadStaffIdMeta));
    }
    if (data.containsKey('siteType')) {
      context.handle(_siteTypeMeta,
          siteType.isAcceptableOrUnknown(data['siteType']!, _siteTypeMeta));
    }
    if (data.containsKey('country')) {
      context.handle(_countryMeta,
          country.isAcceptableOrUnknown(data['country']!, _countryMeta));
    }
    if (data.containsKey('stateProvince')) {
      context.handle(
          _stateProvinceMeta,
          stateProvince.isAcceptableOrUnknown(
              data['stateProvince']!, _stateProvinceMeta));
    }
    if (data.containsKey('county')) {
      context.handle(_countyMeta,
          county.isAcceptableOrUnknown(data['county']!, _countyMeta));
    }
    if (data.containsKey('municipality')) {
      context.handle(
          _municipalityMeta,
          municipality.isAcceptableOrUnknown(
              data['municipality']!, _municipalityMeta));
    }
    if (data.containsKey('mediaID')) {
      context.handle(_mediaIDMeta,
          mediaID.isAcceptableOrUnknown(data['mediaID']!, _mediaIDMeta));
    }
    if (data.containsKey('locality')) {
      context.handle(_localityMeta,
          locality.isAcceptableOrUnknown(data['locality']!, _localityMeta));
    }
    if (data.containsKey('remark')) {
      context.handle(_remarkMeta,
          remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta));
    }
    if (data.containsKey('habitatType')) {
      context.handle(
          _habitatTypeMeta,
          habitatType.isAcceptableOrUnknown(
              data['habitatType']!, _habitatTypeMeta));
    }
    if (data.containsKey('habitatCondition')) {
      context.handle(
          _habitatConditionMeta,
          habitatCondition.isAcceptableOrUnknown(
              data['habitatCondition']!, _habitatConditionMeta));
    }
    if (data.containsKey('habitatDescription')) {
      context.handle(
          _habitatDescriptionMeta,
          habitatDescription.isAcceptableOrUnknown(
              data['habitatDescription']!, _habitatDescriptionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SiteData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SiteData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      siteID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}siteID']),
      projectUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}projectUuid']),
      leadStaffId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}leadStaffId']),
      siteType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}siteType']),
      country: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country']),
      stateProvince: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stateProvince']),
      county: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}county']),
      municipality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}municipality']),
      mediaID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mediaID']),
      locality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}locality']),
      remark: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remark']),
      habitatType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}habitatType']),
      habitatCondition: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}habitatCondition']),
      habitatDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}habitatDescription']),
    );
  }

  @override
  Site createAlias(String alias) {
    return Site(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'FOREIGN KEY(mediaID)REFERENCES media(primaryId)',
        'FOREIGN KEY(leadStaffId)REFERENCES personnel(uuid)'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class SiteData extends DataClass implements Insertable<SiteData> {
  final int id;
  final String? siteID;
  final String? projectUuid;
  final String? leadStaffId;
  final String? siteType;
  final String? country;
  final String? stateProvince;
  final String? county;
  final String? municipality;
  final String? mediaID;
  final String? locality;

  /// verbatim locality in DWC
  final String? remark;
  final String? habitatType;
  final String? habitatCondition;
  final String? habitatDescription;
  const SiteData(
      {required this.id,
      this.siteID,
      this.projectUuid,
      this.leadStaffId,
      this.siteType,
      this.country,
      this.stateProvince,
      this.county,
      this.municipality,
      this.mediaID,
      this.locality,
      this.remark,
      this.habitatType,
      this.habitatCondition,
      this.habitatDescription});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || siteID != null) {
      map['siteID'] = Variable<String>(siteID);
    }
    if (!nullToAbsent || projectUuid != null) {
      map['projectUuid'] = Variable<String>(projectUuid);
    }
    if (!nullToAbsent || leadStaffId != null) {
      map['leadStaffId'] = Variable<String>(leadStaffId);
    }
    if (!nullToAbsent || siteType != null) {
      map['siteType'] = Variable<String>(siteType);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || stateProvince != null) {
      map['stateProvince'] = Variable<String>(stateProvince);
    }
    if (!nullToAbsent || county != null) {
      map['county'] = Variable<String>(county);
    }
    if (!nullToAbsent || municipality != null) {
      map['municipality'] = Variable<String>(municipality);
    }
    if (!nullToAbsent || mediaID != null) {
      map['mediaID'] = Variable<String>(mediaID);
    }
    if (!nullToAbsent || locality != null) {
      map['locality'] = Variable<String>(locality);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    if (!nullToAbsent || habitatType != null) {
      map['habitatType'] = Variable<String>(habitatType);
    }
    if (!nullToAbsent || habitatCondition != null) {
      map['habitatCondition'] = Variable<String>(habitatCondition);
    }
    if (!nullToAbsent || habitatDescription != null) {
      map['habitatDescription'] = Variable<String>(habitatDescription);
    }
    return map;
  }

  SiteCompanion toCompanion(bool nullToAbsent) {
    return SiteCompanion(
      id: Value(id),
      siteID:
          siteID == null && nullToAbsent ? const Value.absent() : Value(siteID),
      projectUuid: projectUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(projectUuid),
      leadStaffId: leadStaffId == null && nullToAbsent
          ? const Value.absent()
          : Value(leadStaffId),
      siteType: siteType == null && nullToAbsent
          ? const Value.absent()
          : Value(siteType),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      stateProvince: stateProvince == null && nullToAbsent
          ? const Value.absent()
          : Value(stateProvince),
      county:
          county == null && nullToAbsent ? const Value.absent() : Value(county),
      municipality: municipality == null && nullToAbsent
          ? const Value.absent()
          : Value(municipality),
      mediaID: mediaID == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaID),
      locality: locality == null && nullToAbsent
          ? const Value.absent()
          : Value(locality),
      remark:
          remark == null && nullToAbsent ? const Value.absent() : Value(remark),
      habitatType: habitatType == null && nullToAbsent
          ? const Value.absent()
          : Value(habitatType),
      habitatCondition: habitatCondition == null && nullToAbsent
          ? const Value.absent()
          : Value(habitatCondition),
      habitatDescription: habitatDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(habitatDescription),
    );
  }

  factory SiteData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SiteData(
      id: serializer.fromJson<int>(json['id']),
      siteID: serializer.fromJson<String?>(json['siteID']),
      projectUuid: serializer.fromJson<String?>(json['projectUuid']),
      leadStaffId: serializer.fromJson<String?>(json['leadStaffId']),
      siteType: serializer.fromJson<String?>(json['siteType']),
      country: serializer.fromJson<String?>(json['country']),
      stateProvince: serializer.fromJson<String?>(json['stateProvince']),
      county: serializer.fromJson<String?>(json['county']),
      municipality: serializer.fromJson<String?>(json['municipality']),
      mediaID: serializer.fromJson<String?>(json['mediaID']),
      locality: serializer.fromJson<String?>(json['locality']),
      remark: serializer.fromJson<String?>(json['remark']),
      habitatType: serializer.fromJson<String?>(json['habitatType']),
      habitatCondition: serializer.fromJson<String?>(json['habitatCondition']),
      habitatDescription:
          serializer.fromJson<String?>(json['habitatDescription']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'siteID': serializer.toJson<String?>(siteID),
      'projectUuid': serializer.toJson<String?>(projectUuid),
      'leadStaffId': serializer.toJson<String?>(leadStaffId),
      'siteType': serializer.toJson<String?>(siteType),
      'country': serializer.toJson<String?>(country),
      'stateProvince': serializer.toJson<String?>(stateProvince),
      'county': serializer.toJson<String?>(county),
      'municipality': serializer.toJson<String?>(municipality),
      'mediaID': serializer.toJson<String?>(mediaID),
      'locality': serializer.toJson<String?>(locality),
      'remark': serializer.toJson<String?>(remark),
      'habitatType': serializer.toJson<String?>(habitatType),
      'habitatCondition': serializer.toJson<String?>(habitatCondition),
      'habitatDescription': serializer.toJson<String?>(habitatDescription),
    };
  }

  SiteData copyWith(
          {int? id,
          Value<String?> siteID = const Value.absent(),
          Value<String?> projectUuid = const Value.absent(),
          Value<String?> leadStaffId = const Value.absent(),
          Value<String?> siteType = const Value.absent(),
          Value<String?> country = const Value.absent(),
          Value<String?> stateProvince = const Value.absent(),
          Value<String?> county = const Value.absent(),
          Value<String?> municipality = const Value.absent(),
          Value<String?> mediaID = const Value.absent(),
          Value<String?> locality = const Value.absent(),
          Value<String?> remark = const Value.absent(),
          Value<String?> habitatType = const Value.absent(),
          Value<String?> habitatCondition = const Value.absent(),
          Value<String?> habitatDescription = const Value.absent()}) =>
      SiteData(
        id: id ?? this.id,
        siteID: siteID.present ? siteID.value : this.siteID,
        projectUuid: projectUuid.present ? projectUuid.value : this.projectUuid,
        leadStaffId: leadStaffId.present ? leadStaffId.value : this.leadStaffId,
        siteType: siteType.present ? siteType.value : this.siteType,
        country: country.present ? country.value : this.country,
        stateProvince:
            stateProvince.present ? stateProvince.value : this.stateProvince,
        county: county.present ? county.value : this.county,
        municipality:
            municipality.present ? municipality.value : this.municipality,
        mediaID: mediaID.present ? mediaID.value : this.mediaID,
        locality: locality.present ? locality.value : this.locality,
        remark: remark.present ? remark.value : this.remark,
        habitatType: habitatType.present ? habitatType.value : this.habitatType,
        habitatCondition: habitatCondition.present
            ? habitatCondition.value
            : this.habitatCondition,
        habitatDescription: habitatDescription.present
            ? habitatDescription.value
            : this.habitatDescription,
      );
  SiteData copyWithCompanion(SiteCompanion data) {
    return SiteData(
      id: data.id.present ? data.id.value : this.id,
      siteID: data.siteID.present ? data.siteID.value : this.siteID,
      projectUuid:
          data.projectUuid.present ? data.projectUuid.value : this.projectUuid,
      leadStaffId:
          data.leadStaffId.present ? data.leadStaffId.value : this.leadStaffId,
      siteType: data.siteType.present ? data.siteType.value : this.siteType,
      country: data.country.present ? data.country.value : this.country,
      stateProvince: data.stateProvince.present
          ? data.stateProvince.value
          : this.stateProvince,
      county: data.county.present ? data.county.value : this.county,
      municipality: data.municipality.present
          ? data.municipality.value
          : this.municipality,
      mediaID: data.mediaID.present ? data.mediaID.value : this.mediaID,
      locality: data.locality.present ? data.locality.value : this.locality,
      remark: data.remark.present ? data.remark.value : this.remark,
      habitatType:
          data.habitatType.present ? data.habitatType.value : this.habitatType,
      habitatCondition: data.habitatCondition.present
          ? data.habitatCondition.value
          : this.habitatCondition,
      habitatDescription: data.habitatDescription.present
          ? data.habitatDescription.value
          : this.habitatDescription,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SiteData(')
          ..write('id: $id, ')
          ..write('siteID: $siteID, ')
          ..write('projectUuid: $projectUuid, ')
          ..write('leadStaffId: $leadStaffId, ')
          ..write('siteType: $siteType, ')
          ..write('country: $country, ')
          ..write('stateProvince: $stateProvince, ')
          ..write('county: $county, ')
          ..write('municipality: $municipality, ')
          ..write('mediaID: $mediaID, ')
          ..write('locality: $locality, ')
          ..write('remark: $remark, ')
          ..write('habitatType: $habitatType, ')
          ..write('habitatCondition: $habitatCondition, ')
          ..write('habitatDescription: $habitatDescription')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      siteID,
      projectUuid,
      leadStaffId,
      siteType,
      country,
      stateProvince,
      county,
      municipality,
      mediaID,
      locality,
      remark,
      habitatType,
      habitatCondition,
      habitatDescription);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SiteData &&
          other.id == this.id &&
          other.siteID == this.siteID &&
          other.projectUuid == this.projectUuid &&
          other.leadStaffId == this.leadStaffId &&
          other.siteType == this.siteType &&
          other.country == this.country &&
          other.stateProvince == this.stateProvince &&
          other.county == this.county &&
          other.municipality == this.municipality &&
          other.mediaID == this.mediaID &&
          other.locality == this.locality &&
          other.remark == this.remark &&
          other.habitatType == this.habitatType &&
          other.habitatCondition == this.habitatCondition &&
          other.habitatDescription == this.habitatDescription);
}

class SiteCompanion extends UpdateCompanion<SiteData> {
  final Value<int> id;
  final Value<String?> siteID;
  final Value<String?> projectUuid;
  final Value<String?> leadStaffId;
  final Value<String?> siteType;
  final Value<String?> country;
  final Value<String?> stateProvince;
  final Value<String?> county;
  final Value<String?> municipality;
  final Value<String?> mediaID;
  final Value<String?> locality;
  final Value<String?> remark;
  final Value<String?> habitatType;
  final Value<String?> habitatCondition;
  final Value<String?> habitatDescription;
  const SiteCompanion({
    this.id = const Value.absent(),
    this.siteID = const Value.absent(),
    this.projectUuid = const Value.absent(),
    this.leadStaffId = const Value.absent(),
    this.siteType = const Value.absent(),
    this.country = const Value.absent(),
    this.stateProvince = const Value.absent(),
    this.county = const Value.absent(),
    this.municipality = const Value.absent(),
    this.mediaID = const Value.absent(),
    this.locality = const Value.absent(),
    this.remark = const Value.absent(),
    this.habitatType = const Value.absent(),
    this.habitatCondition = const Value.absent(),
    this.habitatDescription = const Value.absent(),
  });
  SiteCompanion.insert({
    this.id = const Value.absent(),
    this.siteID = const Value.absent(),
    this.projectUuid = const Value.absent(),
    this.leadStaffId = const Value.absent(),
    this.siteType = const Value.absent(),
    this.country = const Value.absent(),
    this.stateProvince = const Value.absent(),
    this.county = const Value.absent(),
    this.municipality = const Value.absent(),
    this.mediaID = const Value.absent(),
    this.locality = const Value.absent(),
    this.remark = const Value.absent(),
    this.habitatType = const Value.absent(),
    this.habitatCondition = const Value.absent(),
    this.habitatDescription = const Value.absent(),
  });
  static Insertable<SiteData> custom({
    Expression<int>? id,
    Expression<String>? siteID,
    Expression<String>? projectUuid,
    Expression<String>? leadStaffId,
    Expression<String>? siteType,
    Expression<String>? country,
    Expression<String>? stateProvince,
    Expression<String>? county,
    Expression<String>? municipality,
    Expression<String>? mediaID,
    Expression<String>? locality,
    Expression<String>? remark,
    Expression<String>? habitatType,
    Expression<String>? habitatCondition,
    Expression<String>? habitatDescription,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteID != null) 'siteID': siteID,
      if (projectUuid != null) 'projectUuid': projectUuid,
      if (leadStaffId != null) 'leadStaffId': leadStaffId,
      if (siteType != null) 'siteType': siteType,
      if (country != null) 'country': country,
      if (stateProvince != null) 'stateProvince': stateProvince,
      if (county != null) 'county': county,
      if (municipality != null) 'municipality': municipality,
      if (mediaID != null) 'mediaID': mediaID,
      if (locality != null) 'locality': locality,
      if (remark != null) 'remark': remark,
      if (habitatType != null) 'habitatType': habitatType,
      if (habitatCondition != null) 'habitatCondition': habitatCondition,
      if (habitatDescription != null) 'habitatDescription': habitatDescription,
    });
  }

  SiteCompanion copyWith(
      {Value<int>? id,
      Value<String?>? siteID,
      Value<String?>? projectUuid,
      Value<String?>? leadStaffId,
      Value<String?>? siteType,
      Value<String?>? country,
      Value<String?>? stateProvince,
      Value<String?>? county,
      Value<String?>? municipality,
      Value<String?>? mediaID,
      Value<String?>? locality,
      Value<String?>? remark,
      Value<String?>? habitatType,
      Value<String?>? habitatCondition,
      Value<String?>? habitatDescription}) {
    return SiteCompanion(
      id: id ?? this.id,
      siteID: siteID ?? this.siteID,
      projectUuid: projectUuid ?? this.projectUuid,
      leadStaffId: leadStaffId ?? this.leadStaffId,
      siteType: siteType ?? this.siteType,
      country: country ?? this.country,
      stateProvince: stateProvince ?? this.stateProvince,
      county: county ?? this.county,
      municipality: municipality ?? this.municipality,
      mediaID: mediaID ?? this.mediaID,
      locality: locality ?? this.locality,
      remark: remark ?? this.remark,
      habitatType: habitatType ?? this.habitatType,
      habitatCondition: habitatCondition ?? this.habitatCondition,
      habitatDescription: habitatDescription ?? this.habitatDescription,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (siteID.present) {
      map['siteID'] = Variable<String>(siteID.value);
    }
    if (projectUuid.present) {
      map['projectUuid'] = Variable<String>(projectUuid.value);
    }
    if (leadStaffId.present) {
      map['leadStaffId'] = Variable<String>(leadStaffId.value);
    }
    if (siteType.present) {
      map['siteType'] = Variable<String>(siteType.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (stateProvince.present) {
      map['stateProvince'] = Variable<String>(stateProvince.value);
    }
    if (county.present) {
      map['county'] = Variable<String>(county.value);
    }
    if (municipality.present) {
      map['municipality'] = Variable<String>(municipality.value);
    }
    if (mediaID.present) {
      map['mediaID'] = Variable<String>(mediaID.value);
    }
    if (locality.present) {
      map['locality'] = Variable<String>(locality.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (habitatType.present) {
      map['habitatType'] = Variable<String>(habitatType.value);
    }
    if (habitatCondition.present) {
      map['habitatCondition'] = Variable<String>(habitatCondition.value);
    }
    if (habitatDescription.present) {
      map['habitatDescription'] = Variable<String>(habitatDescription.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SiteCompanion(')
          ..write('id: $id, ')
          ..write('siteID: $siteID, ')
          ..write('projectUuid: $projectUuid, ')
          ..write('leadStaffId: $leadStaffId, ')
          ..write('siteType: $siteType, ')
          ..write('country: $country, ')
          ..write('stateProvince: $stateProvince, ')
          ..write('county: $county, ')
          ..write('municipality: $municipality, ')
          ..write('mediaID: $mediaID, ')
          ..write('locality: $locality, ')
          ..write('remark: $remark, ')
          ..write('habitatType: $habitatType, ')
          ..write('habitatCondition: $habitatCondition, ')
          ..write('habitatDescription: $habitatDescription')
          ..write(')'))
        .toString();
  }
}

class Coordinate extends Table with TableInfo<Coordinate, CoordinateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Coordinate(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'UNIQUE PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _nameIdMeta = const VerificationMeta('nameId');
  late final GeneratedColumn<String> nameId = GeneratedColumn<String>(
      'nameId', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _decimalLatitudeMeta =
      const VerificationMeta('decimalLatitude');
  late final GeneratedColumn<double> decimalLatitude = GeneratedColumn<double>(
      'decimalLatitude', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _decimalLongitudeMeta =
      const VerificationMeta('decimalLongitude');
  late final GeneratedColumn<double> decimalLongitude = GeneratedColumn<double>(
      'decimalLongitude', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _elevationInMeterMeta =
      const VerificationMeta('elevationInMeter');
  late final GeneratedColumn<double> elevationInMeter = GeneratedColumn<double>(
      'elevationInMeter', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _datumMeta = const VerificationMeta('datum');
  late final GeneratedColumn<String> datum = GeneratedColumn<String>(
      'datum', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _uncertaintyInMetersMeta =
      const VerificationMeta('uncertaintyInMeters');
  late final GeneratedColumn<int> uncertaintyInMeters = GeneratedColumn<int>(
      'uncertaintyInMeters', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _gpsUnitMeta =
      const VerificationMeta('gpsUnit');
  late final GeneratedColumn<String> gpsUnit = GeneratedColumn<String>(
      'gpsUnit', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _siteIDMeta = const VerificationMeta('siteID');
  late final GeneratedColumn<int> siteID = GeneratedColumn<int>(
      'siteID', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nameId,
        decimalLatitude,
        decimalLongitude,
        elevationInMeter,
        datum,
        uncertaintyInMeters,
        gpsUnit,
        notes,
        siteID
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'coordinate';
  @override
  VerificationContext validateIntegrity(Insertable<CoordinateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nameId')) {
      context.handle(_nameIdMeta,
          nameId.isAcceptableOrUnknown(data['nameId']!, _nameIdMeta));
    }
    if (data.containsKey('decimalLatitude')) {
      context.handle(
          _decimalLatitudeMeta,
          decimalLatitude.isAcceptableOrUnknown(
              data['decimalLatitude']!, _decimalLatitudeMeta));
    }
    if (data.containsKey('decimalLongitude')) {
      context.handle(
          _decimalLongitudeMeta,
          decimalLongitude.isAcceptableOrUnknown(
              data['decimalLongitude']!, _decimalLongitudeMeta));
    }
    if (data.containsKey('elevationInMeter')) {
      context.handle(
          _elevationInMeterMeta,
          elevationInMeter.isAcceptableOrUnknown(
              data['elevationInMeter']!, _elevationInMeterMeta));
    }
    if (data.containsKey('datum')) {
      context.handle(
          _datumMeta, datum.isAcceptableOrUnknown(data['datum']!, _datumMeta));
    }
    if (data.containsKey('uncertaintyInMeters')) {
      context.handle(
          _uncertaintyInMetersMeta,
          uncertaintyInMeters.isAcceptableOrUnknown(
              data['uncertaintyInMeters']!, _uncertaintyInMetersMeta));
    }
    if (data.containsKey('gpsUnit')) {
      context.handle(_gpsUnitMeta,
          gpsUnit.isAcceptableOrUnknown(data['gpsUnit']!, _gpsUnitMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('siteID')) {
      context.handle(_siteIDMeta,
          siteID.isAcceptableOrUnknown(data['siteID']!, _siteIDMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoordinateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoordinateData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      nameId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nameId']),
      decimalLatitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}decimalLatitude']),
      decimalLongitude: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}decimalLongitude']),
      elevationInMeter: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}elevationInMeter']),
      datum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}datum']),
      uncertaintyInMeters: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}uncertaintyInMeters']),
      gpsUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gpsUnit']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      siteID: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}siteID']),
    );
  }

  @override
  Coordinate createAlias(String alias) {
    return Coordinate(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['FOREIGN KEY(siteID)REFERENCES site(id)'];
  @override
  bool get dontWriteConstraints => true;
}

class CoordinateData extends DataClass implements Insertable<CoordinateData> {
  final int? id;

  /// internal id for easy access
  final String? nameId;

  /// users assigned id.
  final double? decimalLatitude;
  final double? decimalLongitude;
  final double? elevationInMeter;
  final String? datum;
  final int? uncertaintyInMeters;
  final String? gpsUnit;
  final String? notes;
  final int? siteID;
  const CoordinateData(
      {this.id,
      this.nameId,
      this.decimalLatitude,
      this.decimalLongitude,
      this.elevationInMeter,
      this.datum,
      this.uncertaintyInMeters,
      this.gpsUnit,
      this.notes,
      this.siteID});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || nameId != null) {
      map['nameId'] = Variable<String>(nameId);
    }
    if (!nullToAbsent || decimalLatitude != null) {
      map['decimalLatitude'] = Variable<double>(decimalLatitude);
    }
    if (!nullToAbsent || decimalLongitude != null) {
      map['decimalLongitude'] = Variable<double>(decimalLongitude);
    }
    if (!nullToAbsent || elevationInMeter != null) {
      map['elevationInMeter'] = Variable<double>(elevationInMeter);
    }
    if (!nullToAbsent || datum != null) {
      map['datum'] = Variable<String>(datum);
    }
    if (!nullToAbsent || uncertaintyInMeters != null) {
      map['uncertaintyInMeters'] = Variable<int>(uncertaintyInMeters);
    }
    if (!nullToAbsent || gpsUnit != null) {
      map['gpsUnit'] = Variable<String>(gpsUnit);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || siteID != null) {
      map['siteID'] = Variable<int>(siteID);
    }
    return map;
  }

  CoordinateCompanion toCompanion(bool nullToAbsent) {
    return CoordinateCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      nameId:
          nameId == null && nullToAbsent ? const Value.absent() : Value(nameId),
      decimalLatitude: decimalLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(decimalLatitude),
      decimalLongitude: decimalLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(decimalLongitude),
      elevationInMeter: elevationInMeter == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationInMeter),
      datum:
          datum == null && nullToAbsent ? const Value.absent() : Value(datum),
      uncertaintyInMeters: uncertaintyInMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(uncertaintyInMeters),
      gpsUnit: gpsUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsUnit),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      siteID:
          siteID == null && nullToAbsent ? const Value.absent() : Value(siteID),
    );
  }

  factory CoordinateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoordinateData(
      id: serializer.fromJson<int?>(json['id']),
      nameId: serializer.fromJson<String?>(json['nameId']),
      decimalLatitude: serializer.fromJson<double?>(json['decimalLatitude']),
      decimalLongitude: serializer.fromJson<double?>(json['decimalLongitude']),
      elevationInMeter: serializer.fromJson<double?>(json['elevationInMeter']),
      datum: serializer.fromJson<String?>(json['datum']),
      uncertaintyInMeters:
          serializer.fromJson<int?>(json['uncertaintyInMeters']),
      gpsUnit: serializer.fromJson<String?>(json['gpsUnit']),
      notes: serializer.fromJson<String?>(json['notes']),
      siteID: serializer.fromJson<int?>(json['siteID']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'nameId': serializer.toJson<String?>(nameId),
      'decimalLatitude': serializer.toJson<double?>(decimalLatitude),
      'decimalLongitude': serializer.toJson<double?>(decimalLongitude),
      'elevationInMeter': serializer.toJson<double?>(elevationInMeter),
      'datum': serializer.toJson<String?>(datum),
      'uncertaintyInMeters': serializer.toJson<int?>(uncertaintyInMeters),
      'gpsUnit': serializer.toJson<String?>(gpsUnit),
      'notes': serializer.toJson<String?>(notes),
      'siteID': serializer.toJson<int?>(siteID),
    };
  }

  CoordinateData copyWith(
          {Value<int?> id = const Value.absent(),
          Value<String?> nameId = const Value.absent(),
          Value<double?> decimalLatitude = const Value.absent(),
          Value<double?> decimalLongitude = const Value.absent(),
          Value<double?> elevationInMeter = const Value.absent(),
          Value<String?> datum = const Value.absent(),
          Value<int?> uncertaintyInMeters = const Value.absent(),
          Value<String?> gpsUnit = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<int?> siteID = const Value.absent()}) =>
      CoordinateData(
        id: id.present ? id.value : this.id,
        nameId: nameId.present ? nameId.value : this.nameId,
        decimalLatitude: decimalLatitude.present
            ? decimalLatitude.value
            : this.decimalLatitude,
        decimalLongitude: decimalLongitude.present
            ? decimalLongitude.value
            : this.decimalLongitude,
        elevationInMeter: elevationInMeter.present
            ? elevationInMeter.value
            : this.elevationInMeter,
        datum: datum.present ? datum.value : this.datum,
        uncertaintyInMeters: uncertaintyInMeters.present
            ? uncertaintyInMeters.value
            : this.uncertaintyInMeters,
        gpsUnit: gpsUnit.present ? gpsUnit.value : this.gpsUnit,
        notes: notes.present ? notes.value : this.notes,
        siteID: siteID.present ? siteID.value : this.siteID,
      );
  CoordinateData copyWithCompanion(CoordinateCompanion data) {
    return CoordinateData(
      id: data.id.present ? data.id.value : this.id,
      nameId: data.nameId.present ? data.nameId.value : this.nameId,
      decimalLatitude: data.decimalLatitude.present
          ? data.decimalLatitude.value
          : this.decimalLatitude,
      decimalLongitude: data.decimalLongitude.present
          ? data.decimalLongitude.value
          : this.decimalLongitude,
      elevationInMeter: data.elevationInMeter.present
          ? data.elevationInMeter.value
          : this.elevationInMeter,
      datum: data.datum.present ? data.datum.value : this.datum,
      uncertaintyInMeters: data.uncertaintyInMeters.present
          ? data.uncertaintyInMeters.value
          : this.uncertaintyInMeters,
      gpsUnit: data.gpsUnit.present ? data.gpsUnit.value : this.gpsUnit,
      notes: data.notes.present ? data.notes.value : this.notes,
      siteID: data.siteID.present ? data.siteID.value : this.siteID,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoordinateData(')
          ..write('id: $id, ')
          ..write('nameId: $nameId, ')
          ..write('decimalLatitude: $decimalLatitude, ')
          ..write('decimalLongitude: $decimalLongitude, ')
          ..write('elevationInMeter: $elevationInMeter, ')
          ..write('datum: $datum, ')
          ..write('uncertaintyInMeters: $uncertaintyInMeters, ')
          ..write('gpsUnit: $gpsUnit, ')
          ..write('notes: $notes, ')
          ..write('siteID: $siteID')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nameId, decimalLatitude, decimalLongitude,
      elevationInMeter, datum, uncertaintyInMeters, gpsUnit, notes, siteID);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoordinateData &&
          other.id == this.id &&
          other.nameId == this.nameId &&
          other.decimalLatitude == this.decimalLatitude &&
          other.decimalLongitude == this.decimalLongitude &&
          other.elevationInMeter == this.elevationInMeter &&
          other.datum == this.datum &&
          other.uncertaintyInMeters == this.uncertaintyInMeters &&
          other.gpsUnit == this.gpsUnit &&
          other.notes == this.notes &&
          other.siteID == this.siteID);
}

class CoordinateCompanion extends UpdateCompanion<CoordinateData> {
  final Value<int?> id;
  final Value<String?> nameId;
  final Value<double?> decimalLatitude;
  final Value<double?> decimalLongitude;
  final Value<double?> elevationInMeter;
  final Value<String?> datum;
  final Value<int?> uncertaintyInMeters;
  final Value<String?> gpsUnit;
  final Value<String?> notes;
  final Value<int?> siteID;
  const CoordinateCompanion({
    this.id = const Value.absent(),
    this.nameId = const Value.absent(),
    this.decimalLatitude = const Value.absent(),
    this.decimalLongitude = const Value.absent(),
    this.elevationInMeter = const Value.absent(),
    this.datum = const Value.absent(),
    this.uncertaintyInMeters = const Value.absent(),
    this.gpsUnit = const Value.absent(),
    this.notes = const Value.absent(),
    this.siteID = const Value.absent(),
  });
  CoordinateCompanion.insert({
    this.id = const Value.absent(),
    this.nameId = const Value.absent(),
    this.decimalLatitude = const Value.absent(),
    this.decimalLongitude = const Value.absent(),
    this.elevationInMeter = const Value.absent(),
    this.datum = const Value.absent(),
    this.uncertaintyInMeters = const Value.absent(),
    this.gpsUnit = const Value.absent(),
    this.notes = const Value.absent(),
    this.siteID = const Value.absent(),
  });
  static Insertable<CoordinateData> custom({
    Expression<int>? id,
    Expression<String>? nameId,
    Expression<double>? decimalLatitude,
    Expression<double>? decimalLongitude,
    Expression<double>? elevationInMeter,
    Expression<String>? datum,
    Expression<int>? uncertaintyInMeters,
    Expression<String>? gpsUnit,
    Expression<String>? notes,
    Expression<int>? siteID,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameId != null) 'nameId': nameId,
      if (decimalLatitude != null) 'decimalLatitude': decimalLatitude,
      if (decimalLongitude != null) 'decimalLongitude': decimalLongitude,
      if (elevationInMeter != null) 'elevationInMeter': elevationInMeter,
      if (datum != null) 'datum': datum,
      if (uncertaintyInMeters != null)
        'uncertaintyInMeters': uncertaintyInMeters,
      if (gpsUnit != null) 'gpsUnit': gpsUnit,
      if (notes != null) 'notes': notes,
      if (siteID != null) 'siteID': siteID,
    });
  }

  CoordinateCompanion copyWith(
      {Value<int?>? id,
      Value<String?>? nameId,
      Value<double?>? decimalLatitude,
      Value<double?>? decimalLongitude,
      Value<double?>? elevationInMeter,
      Value<String?>? datum,
      Value<int?>? uncertaintyInMeters,
      Value<String?>? gpsUnit,
      Value<String?>? notes,
      Value<int?>? siteID}) {
    return CoordinateCompanion(
      id: id ?? this.id,
      nameId: nameId ?? this.nameId,
      decimalLatitude: decimalLatitude ?? this.decimalLatitude,
      decimalLongitude: decimalLongitude ?? this.decimalLongitude,
      elevationInMeter: elevationInMeter ?? this.elevationInMeter,
      datum: datum ?? this.datum,
      uncertaintyInMeters: uncertaintyInMeters ?? this.uncertaintyInMeters,
      gpsUnit: gpsUnit ?? this.gpsUnit,
      notes: notes ?? this.notes,
      siteID: siteID ?? this.siteID,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nameId.present) {
      map['nameId'] = Variable<String>(nameId.value);
    }
    if (decimalLatitude.present) {
      map['decimalLatitude'] = Variable<double>(decimalLatitude.value);
    }
    if (decimalLongitude.present) {
      map['decimalLongitude'] = Variable<double>(decimalLongitude.value);
    }
    if (elevationInMeter.present) {
      map['elevationInMeter'] = Variable<double>(elevationInMeter.value);
    }
    if (datum.present) {
      map['datum'] = Variable<String>(datum.value);
    }
    if (uncertaintyInMeters.present) {
      map['uncertaintyInMeters'] = Variable<int>(uncertaintyInMeters.value);
    }
    if (gpsUnit.present) {
      map['gpsUnit'] = Variable<String>(gpsUnit.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (siteID.present) {
      map['siteID'] = Variable<int>(siteID.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoordinateCompanion(')
          ..write('id: $id, ')
          ..write('nameId: $nameId, ')
          ..write('decimalLatitude: $decimalLatitude, ')
          ..write('decimalLongitude: $decimalLongitude, ')
          ..write('elevationInMeter: $elevationInMeter, ')
          ..write('datum: $datum, ')
          ..write('uncertaintyInMeters: $uncertaintyInMeters, ')
          ..write('gpsUnit: $gpsUnit, ')
          ..write('notes: $notes, ')
          ..write('siteID: $siteID')
          ..write(')'))
        .toString();
  }
}

class CollEvent extends Table with TableInfo<CollEvent, CollEventData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CollEvent(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _idSuffixMeta =
      const VerificationMeta('idSuffix');
  late final GeneratedColumn<String> idSuffix = GeneratedColumn<String>(
      'idSuffix', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _projectUuidMeta =
      const VerificationMeta('projectUuid');
  late final GeneratedColumn<String> projectUuid = GeneratedColumn<String>(
      'projectUuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'startDate', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
      'startTime', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
      'endDate', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
      'endTime', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _primaryCollMethodMeta =
      const VerificationMeta('primaryCollMethod');
  late final GeneratedColumn<String> primaryCollMethod =
      GeneratedColumn<String>('primaryCollMethod', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _collMethodNotesMeta =
      const VerificationMeta('collMethodNotes');
  late final GeneratedColumn<String> collMethodNotes = GeneratedColumn<String>(
      'collMethodNotes', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _siteIDMeta = const VerificationMeta('siteID');
  late final GeneratedColumn<int> siteID = GeneratedColumn<int>(
      'siteID', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES site(id)');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        idSuffix,
        projectUuid,
        startDate,
        startTime,
        endDate,
        endTime,
        primaryCollMethod,
        collMethodNotes,
        siteID
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collEvent';
  @override
  VerificationContext validateIntegrity(Insertable<CollEventData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('idSuffix')) {
      context.handle(_idSuffixMeta,
          idSuffix.isAcceptableOrUnknown(data['idSuffix']!, _idSuffixMeta));
    }
    if (data.containsKey('projectUuid')) {
      context.handle(
          _projectUuidMeta,
          projectUuid.isAcceptableOrUnknown(
              data['projectUuid']!, _projectUuidMeta));
    }
    if (data.containsKey('startDate')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['startDate']!, _startDateMeta));
    }
    if (data.containsKey('startTime')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['startTime']!, _startTimeMeta));
    }
    if (data.containsKey('endDate')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['endDate']!, _endDateMeta));
    }
    if (data.containsKey('endTime')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['endTime']!, _endTimeMeta));
    }
    if (data.containsKey('primaryCollMethod')) {
      context.handle(
          _primaryCollMethodMeta,
          primaryCollMethod.isAcceptableOrUnknown(
              data['primaryCollMethod']!, _primaryCollMethodMeta));
    }
    if (data.containsKey('collMethodNotes')) {
      context.handle(
          _collMethodNotesMeta,
          collMethodNotes.isAcceptableOrUnknown(
              data['collMethodNotes']!, _collMethodNotesMeta));
    }
    if (data.containsKey('siteID')) {
      context.handle(_siteIDMeta,
          siteID.isAcceptableOrUnknown(data['siteID']!, _siteIDMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollEventData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollEventData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      idSuffix: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}idSuffix']),
      projectUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}projectUuid']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}startDate']),
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}startTime']),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}endDate']),
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}endTime']),
      primaryCollMethod: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}primaryCollMethod']),
      collMethodNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collMethodNotes']),
      siteID: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}siteID']),
    );
  }

  @override
  CollEvent createAlias(String alias) {
    return CollEvent(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['FOREIGN KEY(projectUuid)REFERENCES project(uuid)'];
  @override
  bool get dontWriteConstraints => true;
}

class CollEventData extends DataClass implements Insertable<CollEventData> {
  final int id;
  final String? idSuffix;

  /// v4 new name
  final String? projectUuid;
  final String? startDate;
  final String? startTime;
  final String? endDate;
  final String? endTime;
  final String? primaryCollMethod;
  final String? collMethodNotes;
  final int? siteID;
  const CollEventData(
      {required this.id,
      this.idSuffix,
      this.projectUuid,
      this.startDate,
      this.startTime,
      this.endDate,
      this.endTime,
      this.primaryCollMethod,
      this.collMethodNotes,
      this.siteID});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || idSuffix != null) {
      map['idSuffix'] = Variable<String>(idSuffix);
    }
    if (!nullToAbsent || projectUuid != null) {
      map['projectUuid'] = Variable<String>(projectUuid);
    }
    if (!nullToAbsent || startDate != null) {
      map['startDate'] = Variable<String>(startDate);
    }
    if (!nullToAbsent || startTime != null) {
      map['startTime'] = Variable<String>(startTime);
    }
    if (!nullToAbsent || endDate != null) {
      map['endDate'] = Variable<String>(endDate);
    }
    if (!nullToAbsent || endTime != null) {
      map['endTime'] = Variable<String>(endTime);
    }
    if (!nullToAbsent || primaryCollMethod != null) {
      map['primaryCollMethod'] = Variable<String>(primaryCollMethod);
    }
    if (!nullToAbsent || collMethodNotes != null) {
      map['collMethodNotes'] = Variable<String>(collMethodNotes);
    }
    if (!nullToAbsent || siteID != null) {
      map['siteID'] = Variable<int>(siteID);
    }
    return map;
  }

  CollEventCompanion toCompanion(bool nullToAbsent) {
    return CollEventCompanion(
      id: Value(id),
      idSuffix: idSuffix == null && nullToAbsent
          ? const Value.absent()
          : Value(idSuffix),
      projectUuid: projectUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(projectUuid),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      primaryCollMethod: primaryCollMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryCollMethod),
      collMethodNotes: collMethodNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(collMethodNotes),
      siteID:
          siteID == null && nullToAbsent ? const Value.absent() : Value(siteID),
    );
  }

  factory CollEventData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollEventData(
      id: serializer.fromJson<int>(json['id']),
      idSuffix: serializer.fromJson<String?>(json['idSuffix']),
      projectUuid: serializer.fromJson<String?>(json['projectUuid']),
      startDate: serializer.fromJson<String?>(json['startDate']),
      startTime: serializer.fromJson<String?>(json['startTime']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      endTime: serializer.fromJson<String?>(json['endTime']),
      primaryCollMethod:
          serializer.fromJson<String?>(json['primaryCollMethod']),
      collMethodNotes: serializer.fromJson<String?>(json['collMethodNotes']),
      siteID: serializer.fromJson<int?>(json['siteID']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'idSuffix': serializer.toJson<String?>(idSuffix),
      'projectUuid': serializer.toJson<String?>(projectUuid),
      'startDate': serializer.toJson<String?>(startDate),
      'startTime': serializer.toJson<String?>(startTime),
      'endDate': serializer.toJson<String?>(endDate),
      'endTime': serializer.toJson<String?>(endTime),
      'primaryCollMethod': serializer.toJson<String?>(primaryCollMethod),
      'collMethodNotes': serializer.toJson<String?>(collMethodNotes),
      'siteID': serializer.toJson<int?>(siteID),
    };
  }

  CollEventData copyWith(
          {int? id,
          Value<String?> idSuffix = const Value.absent(),
          Value<String?> projectUuid = const Value.absent(),
          Value<String?> startDate = const Value.absent(),
          Value<String?> startTime = const Value.absent(),
          Value<String?> endDate = const Value.absent(),
          Value<String?> endTime = const Value.absent(),
          Value<String?> primaryCollMethod = const Value.absent(),
          Value<String?> collMethodNotes = const Value.absent(),
          Value<int?> siteID = const Value.absent()}) =>
      CollEventData(
        id: id ?? this.id,
        idSuffix: idSuffix.present ? idSuffix.value : this.idSuffix,
        projectUuid: projectUuid.present ? projectUuid.value : this.projectUuid,
        startDate: startDate.present ? startDate.value : this.startDate,
        startTime: startTime.present ? startTime.value : this.startTime,
        endDate: endDate.present ? endDate.value : this.endDate,
        endTime: endTime.present ? endTime.value : this.endTime,
        primaryCollMethod: primaryCollMethod.present
            ? primaryCollMethod.value
            : this.primaryCollMethod,
        collMethodNotes: collMethodNotes.present
            ? collMethodNotes.value
            : this.collMethodNotes,
        siteID: siteID.present ? siteID.value : this.siteID,
      );
  CollEventData copyWithCompanion(CollEventCompanion data) {
    return CollEventData(
      id: data.id.present ? data.id.value : this.id,
      idSuffix: data.idSuffix.present ? data.idSuffix.value : this.idSuffix,
      projectUuid:
          data.projectUuid.present ? data.projectUuid.value : this.projectUuid,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      primaryCollMethod: data.primaryCollMethod.present
          ? data.primaryCollMethod.value
          : this.primaryCollMethod,
      collMethodNotes: data.collMethodNotes.present
          ? data.collMethodNotes.value
          : this.collMethodNotes,
      siteID: data.siteID.present ? data.siteID.value : this.siteID,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollEventData(')
          ..write('id: $id, ')
          ..write('idSuffix: $idSuffix, ')
          ..write('projectUuid: $projectUuid, ')
          ..write('startDate: $startDate, ')
          ..write('startTime: $startTime, ')
          ..write('endDate: $endDate, ')
          ..write('endTime: $endTime, ')
          ..write('primaryCollMethod: $primaryCollMethod, ')
          ..write('collMethodNotes: $collMethodNotes, ')
          ..write('siteID: $siteID')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, idSuffix, projectUuid, startDate,
      startTime, endDate, endTime, primaryCollMethod, collMethodNotes, siteID);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollEventData &&
          other.id == this.id &&
          other.idSuffix == this.idSuffix &&
          other.projectUuid == this.projectUuid &&
          other.startDate == this.startDate &&
          other.startTime == this.startTime &&
          other.endDate == this.endDate &&
          other.endTime == this.endTime &&
          other.primaryCollMethod == this.primaryCollMethod &&
          other.collMethodNotes == this.collMethodNotes &&
          other.siteID == this.siteID);
}

class CollEventCompanion extends UpdateCompanion<CollEventData> {
  final Value<int> id;
  final Value<String?> idSuffix;
  final Value<String?> projectUuid;
  final Value<String?> startDate;
  final Value<String?> startTime;
  final Value<String?> endDate;
  final Value<String?> endTime;
  final Value<String?> primaryCollMethod;
  final Value<String?> collMethodNotes;
  final Value<int?> siteID;
  const CollEventCompanion({
    this.id = const Value.absent(),
    this.idSuffix = const Value.absent(),
    this.projectUuid = const Value.absent(),
    this.startDate = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endDate = const Value.absent(),
    this.endTime = const Value.absent(),
    this.primaryCollMethod = const Value.absent(),
    this.collMethodNotes = const Value.absent(),
    this.siteID = const Value.absent(),
  });
  CollEventCompanion.insert({
    this.id = const Value.absent(),
    this.idSuffix = const Value.absent(),
    this.projectUuid = const Value.absent(),
    this.startDate = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endDate = const Value.absent(),
    this.endTime = const Value.absent(),
    this.primaryCollMethod = const Value.absent(),
    this.collMethodNotes = const Value.absent(),
    this.siteID = const Value.absent(),
  });
  static Insertable<CollEventData> custom({
    Expression<int>? id,
    Expression<String>? idSuffix,
    Expression<String>? projectUuid,
    Expression<String>? startDate,
    Expression<String>? startTime,
    Expression<String>? endDate,
    Expression<String>? endTime,
    Expression<String>? primaryCollMethod,
    Expression<String>? collMethodNotes,
    Expression<int>? siteID,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idSuffix != null) 'idSuffix': idSuffix,
      if (projectUuid != null) 'projectUuid': projectUuid,
      if (startDate != null) 'startDate': startDate,
      if (startTime != null) 'startTime': startTime,
      if (endDate != null) 'endDate': endDate,
      if (endTime != null) 'endTime': endTime,
      if (primaryCollMethod != null) 'primaryCollMethod': primaryCollMethod,
      if (collMethodNotes != null) 'collMethodNotes': collMethodNotes,
      if (siteID != null) 'siteID': siteID,
    });
  }

  CollEventCompanion copyWith(
      {Value<int>? id,
      Value<String?>? idSuffix,
      Value<String?>? projectUuid,
      Value<String?>? startDate,
      Value<String?>? startTime,
      Value<String?>? endDate,
      Value<String?>? endTime,
      Value<String?>? primaryCollMethod,
      Value<String?>? collMethodNotes,
      Value<int?>? siteID}) {
    return CollEventCompanion(
      id: id ?? this.id,
      idSuffix: idSuffix ?? this.idSuffix,
      projectUuid: projectUuid ?? this.projectUuid,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      primaryCollMethod: primaryCollMethod ?? this.primaryCollMethod,
      collMethodNotes: collMethodNotes ?? this.collMethodNotes,
      siteID: siteID ?? this.siteID,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (idSuffix.present) {
      map['idSuffix'] = Variable<String>(idSuffix.value);
    }
    if (projectUuid.present) {
      map['projectUuid'] = Variable<String>(projectUuid.value);
    }
    if (startDate.present) {
      map['startDate'] = Variable<String>(startDate.value);
    }
    if (startTime.present) {
      map['startTime'] = Variable<String>(startTime.value);
    }
    if (endDate.present) {
      map['endDate'] = Variable<String>(endDate.value);
    }
    if (endTime.present) {
      map['endTime'] = Variable<String>(endTime.value);
    }
    if (primaryCollMethod.present) {
      map['primaryCollMethod'] = Variable<String>(primaryCollMethod.value);
    }
    if (collMethodNotes.present) {
      map['collMethodNotes'] = Variable<String>(collMethodNotes.value);
    }
    if (siteID.present) {
      map['siteID'] = Variable<int>(siteID.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollEventCompanion(')
          ..write('id: $id, ')
          ..write('idSuffix: $idSuffix, ')
          ..write('projectUuid: $projectUuid, ')
          ..write('startDate: $startDate, ')
          ..write('startTime: $startTime, ')
          ..write('endDate: $endDate, ')
          ..write('endTime: $endTime, ')
          ..write('primaryCollMethod: $primaryCollMethod, ')
          ..write('collMethodNotes: $collMethodNotes, ')
          ..write('siteID: $siteID')
          ..write(')'))
        .toString();
  }
}

class Weather extends Table with TableInfo<Weather, WeatherData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Weather(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIDMeta =
      const VerificationMeta('eventID');
  late final GeneratedColumn<int> eventID = GeneratedColumn<int>(
      'eventID', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _lowestDayTempCMeta =
      const VerificationMeta('lowestDayTempC');
  late final GeneratedColumn<double> lowestDayTempC = GeneratedColumn<double>(
      'lowestDayTempC', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _highestDayTempCMeta =
      const VerificationMeta('highestDayTempC');
  late final GeneratedColumn<double> highestDayTempC = GeneratedColumn<double>(
      'highestDayTempC', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _lowestNightTempCMeta =
      const VerificationMeta('lowestNightTempC');
  late final GeneratedColumn<double> lowestNightTempC = GeneratedColumn<double>(
      'lowestNightTempC', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _highestNightTempCMeta =
      const VerificationMeta('highestNightTempC');
  late final GeneratedColumn<double> highestNightTempC =
      GeneratedColumn<double>('highestNightTempC', aliasedName, true,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _averageHumidityMeta =
      const VerificationMeta('averageHumidity');
  late final GeneratedColumn<double> averageHumidity = GeneratedColumn<double>(
      'averageHumidity', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _dewPointTempMeta =
      const VerificationMeta('dewPointTemp');
  late final GeneratedColumn<double> dewPointTemp = GeneratedColumn<double>(
      'dewPointTemp', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _sunriseTimeMeta =
      const VerificationMeta('sunriseTime');
  late final GeneratedColumn<String> sunriseTime = GeneratedColumn<String>(
      'sunriseTime', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _sunsetTimeMeta =
      const VerificationMeta('sunsetTime');
  late final GeneratedColumn<String> sunsetTime = GeneratedColumn<String>(
      'sunsetTime', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _moonPhaseMeta =
      const VerificationMeta('moonPhase');
  late final GeneratedColumn<String> moonPhase = GeneratedColumn<String>(
      'moonPhase', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        eventID,
        lowestDayTempC,
        highestDayTempC,
        lowestNightTempC,
        highestNightTempC,
        averageHumidity,
        dewPointTemp,
        sunriseTime,
        sunsetTime,
        moonPhase,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weather';
  @override
  VerificationContext validateIntegrity(Insertable<WeatherData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('eventID')) {
      context.handle(_eventIDMeta,
          eventID.isAcceptableOrUnknown(data['eventID']!, _eventIDMeta));
    }
    if (data.containsKey('lowestDayTempC')) {
      context.handle(
          _lowestDayTempCMeta,
          lowestDayTempC.isAcceptableOrUnknown(
              data['lowestDayTempC']!, _lowestDayTempCMeta));
    }
    if (data.containsKey('highestDayTempC')) {
      context.handle(
          _highestDayTempCMeta,
          highestDayTempC.isAcceptableOrUnknown(
              data['highestDayTempC']!, _highestDayTempCMeta));
    }
    if (data.containsKey('lowestNightTempC')) {
      context.handle(
          _lowestNightTempCMeta,
          lowestNightTempC.isAcceptableOrUnknown(
              data['lowestNightTempC']!, _lowestNightTempCMeta));
    }
    if (data.containsKey('highestNightTempC')) {
      context.handle(
          _highestNightTempCMeta,
          highestNightTempC.isAcceptableOrUnknown(
              data['highestNightTempC']!, _highestNightTempCMeta));
    }
    if (data.containsKey('averageHumidity')) {
      context.handle(
          _averageHumidityMeta,
          averageHumidity.isAcceptableOrUnknown(
              data['averageHumidity']!, _averageHumidityMeta));
    }
    if (data.containsKey('dewPointTemp')) {
      context.handle(
          _dewPointTempMeta,
          dewPointTemp.isAcceptableOrUnknown(
              data['dewPointTemp']!, _dewPointTempMeta));
    }
    if (data.containsKey('sunriseTime')) {
      context.handle(
          _sunriseTimeMeta,
          sunriseTime.isAcceptableOrUnknown(
              data['sunriseTime']!, _sunriseTimeMeta));
    }
    if (data.containsKey('sunsetTime')) {
      context.handle(
          _sunsetTimeMeta,
          sunsetTime.isAcceptableOrUnknown(
              data['sunsetTime']!, _sunsetTimeMeta));
    }
    if (data.containsKey('moonPhase')) {
      context.handle(_moonPhaseMeta,
          moonPhase.isAcceptableOrUnknown(data['moonPhase']!, _moonPhaseMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  WeatherData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeatherData(
      eventID: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}eventID']),
      lowestDayTempC: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lowestDayTempC']),
      highestDayTempC: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}highestDayTempC']),
      lowestNightTempC: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}lowestNightTempC']),
      highestNightTempC: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}highestNightTempC']),
      averageHumidity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}averageHumidity']),
      dewPointTemp: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}dewPointTemp']),
      sunriseTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sunriseTime']),
      sunsetTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sunsetTime']),
      moonPhase: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}moonPhase']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  Weather createAlias(String alias) {
    return Weather(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['FOREIGN KEY(eventID)REFERENCES collEvent(id)'];
  @override
  bool get dontWriteConstraints => true;
}

class WeatherData extends DataClass implements Insertable<WeatherData> {
  final int? eventID;
  final double? lowestDayTempC;
  final double? highestDayTempC;
  final double? lowestNightTempC;
  final double? highestNightTempC;
  final double? averageHumidity;
  final double? dewPointTemp;
  final String? sunriseTime;
  final String? sunsetTime;
  final String? moonPhase;
  final String? notes;
  const WeatherData(
      {this.eventID,
      this.lowestDayTempC,
      this.highestDayTempC,
      this.lowestNightTempC,
      this.highestNightTempC,
      this.averageHumidity,
      this.dewPointTemp,
      this.sunriseTime,
      this.sunsetTime,
      this.moonPhase,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || eventID != null) {
      map['eventID'] = Variable<int>(eventID);
    }
    if (!nullToAbsent || lowestDayTempC != null) {
      map['lowestDayTempC'] = Variable<double>(lowestDayTempC);
    }
    if (!nullToAbsent || highestDayTempC != null) {
      map['highestDayTempC'] = Variable<double>(highestDayTempC);
    }
    if (!nullToAbsent || lowestNightTempC != null) {
      map['lowestNightTempC'] = Variable<double>(lowestNightTempC);
    }
    if (!nullToAbsent || highestNightTempC != null) {
      map['highestNightTempC'] = Variable<double>(highestNightTempC);
    }
    if (!nullToAbsent || averageHumidity != null) {
      map['averageHumidity'] = Variable<double>(averageHumidity);
    }
    if (!nullToAbsent || dewPointTemp != null) {
      map['dewPointTemp'] = Variable<double>(dewPointTemp);
    }
    if (!nullToAbsent || sunriseTime != null) {
      map['sunriseTime'] = Variable<String>(sunriseTime);
    }
    if (!nullToAbsent || sunsetTime != null) {
      map['sunsetTime'] = Variable<String>(sunsetTime);
    }
    if (!nullToAbsent || moonPhase != null) {
      map['moonPhase'] = Variable<String>(moonPhase);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  WeatherCompanion toCompanion(bool nullToAbsent) {
    return WeatherCompanion(
      eventID: eventID == null && nullToAbsent
          ? const Value.absent()
          : Value(eventID),
      lowestDayTempC: lowestDayTempC == null && nullToAbsent
          ? const Value.absent()
          : Value(lowestDayTempC),
      highestDayTempC: highestDayTempC == null && nullToAbsent
          ? const Value.absent()
          : Value(highestDayTempC),
      lowestNightTempC: lowestNightTempC == null && nullToAbsent
          ? const Value.absent()
          : Value(lowestNightTempC),
      highestNightTempC: highestNightTempC == null && nullToAbsent
          ? const Value.absent()
          : Value(highestNightTempC),
      averageHumidity: averageHumidity == null && nullToAbsent
          ? const Value.absent()
          : Value(averageHumidity),
      dewPointTemp: dewPointTemp == null && nullToAbsent
          ? const Value.absent()
          : Value(dewPointTemp),
      sunriseTime: sunriseTime == null && nullToAbsent
          ? const Value.absent()
          : Value(sunriseTime),
      sunsetTime: sunsetTime == null && nullToAbsent
          ? const Value.absent()
          : Value(sunsetTime),
      moonPhase: moonPhase == null && nullToAbsent
          ? const Value.absent()
          : Value(moonPhase),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory WeatherData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeatherData(
      eventID: serializer.fromJson<int?>(json['eventID']),
      lowestDayTempC: serializer.fromJson<double?>(json['lowestDayTempC']),
      highestDayTempC: serializer.fromJson<double?>(json['highestDayTempC']),
      lowestNightTempC: serializer.fromJson<double?>(json['lowestNightTempC']),
      highestNightTempC:
          serializer.fromJson<double?>(json['highestNightTempC']),
      averageHumidity: serializer.fromJson<double?>(json['averageHumidity']),
      dewPointTemp: serializer.fromJson<double?>(json['dewPointTemp']),
      sunriseTime: serializer.fromJson<String?>(json['sunriseTime']),
      sunsetTime: serializer.fromJson<String?>(json['sunsetTime']),
      moonPhase: serializer.fromJson<String?>(json['moonPhase']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventID': serializer.toJson<int?>(eventID),
      'lowestDayTempC': serializer.toJson<double?>(lowestDayTempC),
      'highestDayTempC': serializer.toJson<double?>(highestDayTempC),
      'lowestNightTempC': serializer.toJson<double?>(lowestNightTempC),
      'highestNightTempC': serializer.toJson<double?>(highestNightTempC),
      'averageHumidity': serializer.toJson<double?>(averageHumidity),
      'dewPointTemp': serializer.toJson<double?>(dewPointTemp),
      'sunriseTime': serializer.toJson<String?>(sunriseTime),
      'sunsetTime': serializer.toJson<String?>(sunsetTime),
      'moonPhase': serializer.toJson<String?>(moonPhase),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  WeatherData copyWith(
          {Value<int?> eventID = const Value.absent(),
          Value<double?> lowestDayTempC = const Value.absent(),
          Value<double?> highestDayTempC = const Value.absent(),
          Value<double?> lowestNightTempC = const Value.absent(),
          Value<double?> highestNightTempC = const Value.absent(),
          Value<double?> averageHumidity = const Value.absent(),
          Value<double?> dewPointTemp = const Value.absent(),
          Value<String?> sunriseTime = const Value.absent(),
          Value<String?> sunsetTime = const Value.absent(),
          Value<String?> moonPhase = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      WeatherData(
        eventID: eventID.present ? eventID.value : this.eventID,
        lowestDayTempC:
            lowestDayTempC.present ? lowestDayTempC.value : this.lowestDayTempC,
        highestDayTempC: highestDayTempC.present
            ? highestDayTempC.value
            : this.highestDayTempC,
        lowestNightTempC: lowestNightTempC.present
            ? lowestNightTempC.value
            : this.lowestNightTempC,
        highestNightTempC: highestNightTempC.present
            ? highestNightTempC.value
            : this.highestNightTempC,
        averageHumidity: averageHumidity.present
            ? averageHumidity.value
            : this.averageHumidity,
        dewPointTemp:
            dewPointTemp.present ? dewPointTemp.value : this.dewPointTemp,
        sunriseTime: sunriseTime.present ? sunriseTime.value : this.sunriseTime,
        sunsetTime: sunsetTime.present ? sunsetTime.value : this.sunsetTime,
        moonPhase: moonPhase.present ? moonPhase.value : this.moonPhase,
        notes: notes.present ? notes.value : this.notes,
      );
  WeatherData copyWithCompanion(WeatherCompanion data) {
    return WeatherData(
      eventID: data.eventID.present ? data.eventID.value : this.eventID,
      lowestDayTempC: data.lowestDayTempC.present
          ? data.lowestDayTempC.value
          : this.lowestDayTempC,
      highestDayTempC: data.highestDayTempC.present
          ? data.highestDayTempC.value
          : this.highestDayTempC,
      lowestNightTempC: data.lowestNightTempC.present
          ? data.lowestNightTempC.value
          : this.lowestNightTempC,
      highestNightTempC: data.highestNightTempC.present
          ? data.highestNightTempC.value
          : this.highestNightTempC,
      averageHumidity: data.averageHumidity.present
          ? data.averageHumidity.value
          : this.averageHumidity,
      dewPointTemp: data.dewPointTemp.present
          ? data.dewPointTemp.value
          : this.dewPointTemp,
      sunriseTime:
          data.sunriseTime.present ? data.sunriseTime.value : this.sunriseTime,
      sunsetTime:
          data.sunsetTime.present ? data.sunsetTime.value : this.sunsetTime,
      moonPhase: data.moonPhase.present ? data.moonPhase.value : this.moonPhase,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeatherData(')
          ..write('eventID: $eventID, ')
          ..write('lowestDayTempC: $lowestDayTempC, ')
          ..write('highestDayTempC: $highestDayTempC, ')
          ..write('lowestNightTempC: $lowestNightTempC, ')
          ..write('highestNightTempC: $highestNightTempC, ')
          ..write('averageHumidity: $averageHumidity, ')
          ..write('dewPointTemp: $dewPointTemp, ')
          ..write('sunriseTime: $sunriseTime, ')
          ..write('sunsetTime: $sunsetTime, ')
          ..write('moonPhase: $moonPhase, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      eventID,
      lowestDayTempC,
      highestDayTempC,
      lowestNightTempC,
      highestNightTempC,
      averageHumidity,
      dewPointTemp,
      sunriseTime,
      sunsetTime,
      moonPhase,
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeatherData &&
          other.eventID == this.eventID &&
          other.lowestDayTempC == this.lowestDayTempC &&
          other.highestDayTempC == this.highestDayTempC &&
          other.lowestNightTempC == this.lowestNightTempC &&
          other.highestNightTempC == this.highestNightTempC &&
          other.averageHumidity == this.averageHumidity &&
          other.dewPointTemp == this.dewPointTemp &&
          other.sunriseTime == this.sunriseTime &&
          other.sunsetTime == this.sunsetTime &&
          other.moonPhase == this.moonPhase &&
          other.notes == this.notes);
}

class WeatherCompanion extends UpdateCompanion<WeatherData> {
  final Value<int?> eventID;
  final Value<double?> lowestDayTempC;
  final Value<double?> highestDayTempC;
  final Value<double?> lowestNightTempC;
  final Value<double?> highestNightTempC;
  final Value<double?> averageHumidity;
  final Value<double?> dewPointTemp;
  final Value<String?> sunriseTime;
  final Value<String?> sunsetTime;
  final Value<String?> moonPhase;
  final Value<String?> notes;
  final Value<int> rowid;
  const WeatherCompanion({
    this.eventID = const Value.absent(),
    this.lowestDayTempC = const Value.absent(),
    this.highestDayTempC = const Value.absent(),
    this.lowestNightTempC = const Value.absent(),
    this.highestNightTempC = const Value.absent(),
    this.averageHumidity = const Value.absent(),
    this.dewPointTemp = const Value.absent(),
    this.sunriseTime = const Value.absent(),
    this.sunsetTime = const Value.absent(),
    this.moonPhase = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeatherCompanion.insert({
    this.eventID = const Value.absent(),
    this.lowestDayTempC = const Value.absent(),
    this.highestDayTempC = const Value.absent(),
    this.lowestNightTempC = const Value.absent(),
    this.highestNightTempC = const Value.absent(),
    this.averageHumidity = const Value.absent(),
    this.dewPointTemp = const Value.absent(),
    this.sunriseTime = const Value.absent(),
    this.sunsetTime = const Value.absent(),
    this.moonPhase = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<WeatherData> custom({
    Expression<int>? eventID,
    Expression<double>? lowestDayTempC,
    Expression<double>? highestDayTempC,
    Expression<double>? lowestNightTempC,
    Expression<double>? highestNightTempC,
    Expression<double>? averageHumidity,
    Expression<double>? dewPointTemp,
    Expression<String>? sunriseTime,
    Expression<String>? sunsetTime,
    Expression<String>? moonPhase,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventID != null) 'eventID': eventID,
      if (lowestDayTempC != null) 'lowestDayTempC': lowestDayTempC,
      if (highestDayTempC != null) 'highestDayTempC': highestDayTempC,
      if (lowestNightTempC != null) 'lowestNightTempC': lowestNightTempC,
      if (highestNightTempC != null) 'highestNightTempC': highestNightTempC,
      if (averageHumidity != null) 'averageHumidity': averageHumidity,
      if (dewPointTemp != null) 'dewPointTemp': dewPointTemp,
      if (sunriseTime != null) 'sunriseTime': sunriseTime,
      if (sunsetTime != null) 'sunsetTime': sunsetTime,
      if (moonPhase != null) 'moonPhase': moonPhase,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeatherCompanion copyWith(
      {Value<int?>? eventID,
      Value<double?>? lowestDayTempC,
      Value<double?>? highestDayTempC,
      Value<double?>? lowestNightTempC,
      Value<double?>? highestNightTempC,
      Value<double?>? averageHumidity,
      Value<double?>? dewPointTemp,
      Value<String?>? sunriseTime,
      Value<String?>? sunsetTime,
      Value<String?>? moonPhase,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return WeatherCompanion(
      eventID: eventID ?? this.eventID,
      lowestDayTempC: lowestDayTempC ?? this.lowestDayTempC,
      highestDayTempC: highestDayTempC ?? this.highestDayTempC,
      lowestNightTempC: lowestNightTempC ?? this.lowestNightTempC,
      highestNightTempC: highestNightTempC ?? this.highestNightTempC,
      averageHumidity: averageHumidity ?? this.averageHumidity,
      dewPointTemp: dewPointTemp ?? this.dewPointTemp,
      sunriseTime: sunriseTime ?? this.sunriseTime,
      sunsetTime: sunsetTime ?? this.sunsetTime,
      moonPhase: moonPhase ?? this.moonPhase,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventID.present) {
      map['eventID'] = Variable<int>(eventID.value);
    }
    if (lowestDayTempC.present) {
      map['lowestDayTempC'] = Variable<double>(lowestDayTempC.value);
    }
    if (highestDayTempC.present) {
      map['highestDayTempC'] = Variable<double>(highestDayTempC.value);
    }
    if (lowestNightTempC.present) {
      map['lowestNightTempC'] = Variable<double>(lowestNightTempC.value);
    }
    if (highestNightTempC.present) {
      map['highestNightTempC'] = Variable<double>(highestNightTempC.value);
    }
    if (averageHumidity.present) {
      map['averageHumidity'] = Variable<double>(averageHumidity.value);
    }
    if (dewPointTemp.present) {
      map['dewPointTemp'] = Variable<double>(dewPointTemp.value);
    }
    if (sunriseTime.present) {
      map['sunriseTime'] = Variable<String>(sunriseTime.value);
    }
    if (sunsetTime.present) {
      map['sunsetTime'] = Variable<String>(sunsetTime.value);
    }
    if (moonPhase.present) {
      map['moonPhase'] = Variable<String>(moonPhase.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeatherCompanion(')
          ..write('eventID: $eventID, ')
          ..write('lowestDayTempC: $lowestDayTempC, ')
          ..write('highestDayTempC: $highestDayTempC, ')
          ..write('lowestNightTempC: $lowestNightTempC, ')
          ..write('highestNightTempC: $highestNightTempC, ')
          ..write('averageHumidity: $averageHumidity, ')
          ..write('dewPointTemp: $dewPointTemp, ')
          ..write('sunriseTime: $sunriseTime, ')
          ..write('sunsetTime: $sunsetTime, ')
          ..write('moonPhase: $moonPhase, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class CollPersonnel extends Table
    with TableInfo<CollPersonnel, CollPersonnelData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CollPersonnel(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _eventIDMeta =
      const VerificationMeta('eventID');
  late final GeneratedColumn<int> eventID = GeneratedColumn<int>(
      'eventID', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _personnelIdMeta =
      const VerificationMeta('personnelId');
  late final GeneratedColumn<String> personnelId = GeneratedColumn<String>(
      'personnelId', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [id, eventID, personnelId, name, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collPersonnel';
  @override
  VerificationContext validateIntegrity(Insertable<CollPersonnelData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('eventID')) {
      context.handle(_eventIDMeta,
          eventID.isAcceptableOrUnknown(data['eventID']!, _eventIDMeta));
    }
    if (data.containsKey('personnelId')) {
      context.handle(
          _personnelIdMeta,
          personnelId.isAcceptableOrUnknown(
              data['personnelId']!, _personnelIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollPersonnelData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollPersonnelData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      eventID: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}eventID']),
      personnelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}personnelId']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role']),
    );
  }

  @override
  CollPersonnel createAlias(String alias) {
    return CollPersonnel(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'FOREIGN KEY(eventID)REFERENCES collEvent(id)',
        'FOREIGN KEY(personnelId)REFERENCES personnel(uuid)'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class CollPersonnelData extends DataClass
    implements Insertable<CollPersonnelData> {
  final int id;
  final int? eventID;
  final String? personnelId;
  final String? name;

  /// we add it here to save time pulling it from personnel data
  final String? role;
  const CollPersonnelData(
      {required this.id, this.eventID, this.personnelId, this.name, this.role});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || eventID != null) {
      map['eventID'] = Variable<int>(eventID);
    }
    if (!nullToAbsent || personnelId != null) {
      map['personnelId'] = Variable<String>(personnelId);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    return map;
  }

  CollPersonnelCompanion toCompanion(bool nullToAbsent) {
    return CollPersonnelCompanion(
      id: Value(id),
      eventID: eventID == null && nullToAbsent
          ? const Value.absent()
          : Value(eventID),
      personnelId: personnelId == null && nullToAbsent
          ? const Value.absent()
          : Value(personnelId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
    );
  }

  factory CollPersonnelData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollPersonnelData(
      id: serializer.fromJson<int>(json['id']),
      eventID: serializer.fromJson<int?>(json['eventID']),
      personnelId: serializer.fromJson<String?>(json['personnelId']),
      name: serializer.fromJson<String?>(json['name']),
      role: serializer.fromJson<String?>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventID': serializer.toJson<int?>(eventID),
      'personnelId': serializer.toJson<String?>(personnelId),
      'name': serializer.toJson<String?>(name),
      'role': serializer.toJson<String?>(role),
    };
  }

  CollPersonnelData copyWith(
          {int? id,
          Value<int?> eventID = const Value.absent(),
          Value<String?> personnelId = const Value.absent(),
          Value<String?> name = const Value.absent(),
          Value<String?> role = const Value.absent()}) =>
      CollPersonnelData(
        id: id ?? this.id,
        eventID: eventID.present ? eventID.value : this.eventID,
        personnelId: personnelId.present ? personnelId.value : this.personnelId,
        name: name.present ? name.value : this.name,
        role: role.present ? role.value : this.role,
      );
  CollPersonnelData copyWithCompanion(CollPersonnelCompanion data) {
    return CollPersonnelData(
      id: data.id.present ? data.id.value : this.id,
      eventID: data.eventID.present ? data.eventID.value : this.eventID,
      personnelId:
          data.personnelId.present ? data.personnelId.value : this.personnelId,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollPersonnelData(')
          ..write('id: $id, ')
          ..write('eventID: $eventID, ')
          ..write('personnelId: $personnelId, ')
          ..write('name: $name, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, eventID, personnelId, name, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollPersonnelData &&
          other.id == this.id &&
          other.eventID == this.eventID &&
          other.personnelId == this.personnelId &&
          other.name == this.name &&
          other.role == this.role);
}

class CollPersonnelCompanion extends UpdateCompanion<CollPersonnelData> {
  final Value<int> id;
  final Value<int?> eventID;
  final Value<String?> personnelId;
  final Value<String?> name;
  final Value<String?> role;
  const CollPersonnelCompanion({
    this.id = const Value.absent(),
    this.eventID = const Value.absent(),
    this.personnelId = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
  });
  CollPersonnelCompanion.insert({
    this.id = const Value.absent(),
    this.eventID = const Value.absent(),
    this.personnelId = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
  });
  static Insertable<CollPersonnelData> custom({
    Expression<int>? id,
    Expression<int>? eventID,
    Expression<String>? personnelId,
    Expression<String>? name,
    Expression<String>? role,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventID != null) 'eventID': eventID,
      if (personnelId != null) 'personnelId': personnelId,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
    });
  }

  CollPersonnelCompanion copyWith(
      {Value<int>? id,
      Value<int?>? eventID,
      Value<String?>? personnelId,
      Value<String?>? name,
      Value<String?>? role}) {
    return CollPersonnelCompanion(
      id: id ?? this.id,
      eventID: eventID ?? this.eventID,
      personnelId: personnelId ?? this.personnelId,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventID.present) {
      map['eventID'] = Variable<int>(eventID.value);
    }
    if (personnelId.present) {
      map['personnelId'] = Variable<String>(personnelId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollPersonnelCompanion(')
          ..write('id: $id, ')
          ..write('eventID: $eventID, ')
          ..write('personnelId: $personnelId, ')
          ..write('name: $name, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }
}

class CollEffort extends Table with TableInfo<CollEffort, CollEffortData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CollEffort(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _eventIDMeta =
      const VerificationMeta('eventID');
  late final GeneratedColumn<int> eventID = GeneratedColumn<int>(
      'eventID', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
      'count', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  late final GeneratedColumn<String> size = GeneratedColumn<String>(
      'size', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns =>
      [id, eventID, method, brand, count, size, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collEffort';
  @override
  VerificationContext validateIntegrity(Insertable<CollEffortData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('eventID')) {
      context.handle(_eventIDMeta,
          eventID.isAcceptableOrUnknown(data['eventID']!, _eventIDMeta));
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    }
    if (data.containsKey('count')) {
      context.handle(
          _countMeta, count.isAcceptableOrUnknown(data['count']!, _countMeta));
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollEffortData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollEffortData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      eventID: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}eventID']),
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method']),
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand']),
      count: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}count']),
      size: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}size']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  CollEffort createAlias(String alias) {
    return CollEffort(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['FOREIGN KEY(eventID)REFERENCES collEvent(id)'];
  @override
  bool get dontWriteConstraints => true;
}

class CollEffortData extends DataClass implements Insertable<CollEffortData> {
  final int id;
  final int? eventID;
  final String? method;

  /// v4 rename
  final String? brand;
  final int? count;
  final String? size;
  final String? notes;
  const CollEffortData(
      {required this.id,
      this.eventID,
      this.method,
      this.brand,
      this.count,
      this.size,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || eventID != null) {
      map['eventID'] = Variable<int>(eventID);
    }
    if (!nullToAbsent || method != null) {
      map['method'] = Variable<String>(method);
    }
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || count != null) {
      map['count'] = Variable<int>(count);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<String>(size);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CollEffortCompanion toCompanion(bool nullToAbsent) {
    return CollEffortCompanion(
      id: Value(id),
      eventID: eventID == null && nullToAbsent
          ? const Value.absent()
          : Value(eventID),
      method:
          method == null && nullToAbsent ? const Value.absent() : Value(method),
      brand:
          brand == null && nullToAbsent ? const Value.absent() : Value(brand),
      count:
          count == null && nullToAbsent ? const Value.absent() : Value(count),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory CollEffortData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollEffortData(
      id: serializer.fromJson<int>(json['id']),
      eventID: serializer.fromJson<int?>(json['eventID']),
      method: serializer.fromJson<String?>(json['method']),
      brand: serializer.fromJson<String?>(json['brand']),
      count: serializer.fromJson<int?>(json['count']),
      size: serializer.fromJson<String?>(json['size']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventID': serializer.toJson<int?>(eventID),
      'method': serializer.toJson<String?>(method),
      'brand': serializer.toJson<String?>(brand),
      'count': serializer.toJson<int?>(count),
      'size': serializer.toJson<String?>(size),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CollEffortData copyWith(
          {int? id,
          Value<int?> eventID = const Value.absent(),
          Value<String?> method = const Value.absent(),
          Value<String?> brand = const Value.absent(),
          Value<int?> count = const Value.absent(),
          Value<String?> size = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      CollEffortData(
        id: id ?? this.id,
        eventID: eventID.present ? eventID.value : this.eventID,
        method: method.present ? method.value : this.method,
        brand: brand.present ? brand.value : this.brand,
        count: count.present ? count.value : this.count,
        size: size.present ? size.value : this.size,
        notes: notes.present ? notes.value : this.notes,
      );
  CollEffortData copyWithCompanion(CollEffortCompanion data) {
    return CollEffortData(
      id: data.id.present ? data.id.value : this.id,
      eventID: data.eventID.present ? data.eventID.value : this.eventID,
      method: data.method.present ? data.method.value : this.method,
      brand: data.brand.present ? data.brand.value : this.brand,
      count: data.count.present ? data.count.value : this.count,
      size: data.size.present ? data.size.value : this.size,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollEffortData(')
          ..write('id: $id, ')
          ..write('eventID: $eventID, ')
          ..write('method: $method, ')
          ..write('brand: $brand, ')
          ..write('count: $count, ')
          ..write('size: $size, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, eventID, method, brand, count, size, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollEffortData &&
          other.id == this.id &&
          other.eventID == this.eventID &&
          other.method == this.method &&
          other.brand == this.brand &&
          other.count == this.count &&
          other.size == this.size &&
          other.notes == this.notes);
}

class CollEffortCompanion extends UpdateCompanion<CollEffortData> {
  final Value<int> id;
  final Value<int?> eventID;
  final Value<String?> method;
  final Value<String?> brand;
  final Value<int?> count;
  final Value<String?> size;
  final Value<String?> notes;
  const CollEffortCompanion({
    this.id = const Value.absent(),
    this.eventID = const Value.absent(),
    this.method = const Value.absent(),
    this.brand = const Value.absent(),
    this.count = const Value.absent(),
    this.size = const Value.absent(),
    this.notes = const Value.absent(),
  });
  CollEffortCompanion.insert({
    this.id = const Value.absent(),
    this.eventID = const Value.absent(),
    this.method = const Value.absent(),
    this.brand = const Value.absent(),
    this.count = const Value.absent(),
    this.size = const Value.absent(),
    this.notes = const Value.absent(),
  });
  static Insertable<CollEffortData> custom({
    Expression<int>? id,
    Expression<int>? eventID,
    Expression<String>? method,
    Expression<String>? brand,
    Expression<int>? count,
    Expression<String>? size,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventID != null) 'eventID': eventID,
      if (method != null) 'method': method,
      if (brand != null) 'brand': brand,
      if (count != null) 'count': count,
      if (size != null) 'size': size,
      if (notes != null) 'notes': notes,
    });
  }

  CollEffortCompanion copyWith(
      {Value<int>? id,
      Value<int?>? eventID,
      Value<String?>? method,
      Value<String?>? brand,
      Value<int?>? count,
      Value<String?>? size,
      Value<String?>? notes}) {
    return CollEffortCompanion(
      id: id ?? this.id,
      eventID: eventID ?? this.eventID,
      method: method ?? this.method,
      brand: brand ?? this.brand,
      count: count ?? this.count,
      size: size ?? this.size,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventID.present) {
      map['eventID'] = Variable<int>(eventID.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollEffortCompanion(')
          ..write('id: $id, ')
          ..write('eventID: $eventID, ')
          ..write('method: $method, ')
          ..write('brand: $brand, ')
          ..write('count: $count, ')
          ..write('size: $size, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class Narrative extends Table with TableInfo<Narrative, NarrativeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Narrative(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _projectUuidMeta =
      const VerificationMeta('projectUuid');
  late final GeneratedColumn<String> projectUuid = GeneratedColumn<String>(
      'projectUuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _siteIDMeta = const VerificationMeta('siteID');
  late final GeneratedColumn<int> siteID = GeneratedColumn<int>(
      'siteID', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _narrativeMeta =
      const VerificationMeta('narrative');
  late final GeneratedColumn<String> narrative = GeneratedColumn<String>(
      'narrative', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _mediaIDMeta =
      const VerificationMeta('mediaID');
  late final GeneratedColumn<int> mediaID = GeneratedColumn<int>(
      'mediaID', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES media(primaryId)');
  @override
  List<GeneratedColumn> get $columns =>
      [id, projectUuid, date, siteID, narrative, mediaID];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'narrative';
  @override
  VerificationContext validateIntegrity(Insertable<NarrativeData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('projectUuid')) {
      context.handle(
          _projectUuidMeta,
          projectUuid.isAcceptableOrUnknown(
              data['projectUuid']!, _projectUuidMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    }
    if (data.containsKey('siteID')) {
      context.handle(_siteIDMeta,
          siteID.isAcceptableOrUnknown(data['siteID']!, _siteIDMeta));
    }
    if (data.containsKey('narrative')) {
      context.handle(_narrativeMeta,
          narrative.isAcceptableOrUnknown(data['narrative']!, _narrativeMeta));
    }
    if (data.containsKey('mediaID')) {
      context.handle(_mediaIDMeta,
          mediaID.isAcceptableOrUnknown(data['mediaID']!, _mediaIDMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NarrativeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NarrativeData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      projectUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}projectUuid']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date']),
      siteID: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}siteID']),
      narrative: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}narrative']),
      mediaID: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mediaID']),
    );
  }

  @override
  Narrative createAlias(String alias) {
    return Narrative(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'FOREIGN KEY(projectUuid)REFERENCES project(uuid)',
        'FOREIGN KEY(siteID)REFERENCES site(id)'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class NarrativeData extends DataClass implements Insertable<NarrativeData> {
  final int id;
  final String? projectUuid;
  final String? date;
  final int? siteID;
  final String? narrative;
  final int? mediaID;
  const NarrativeData(
      {required this.id,
      this.projectUuid,
      this.date,
      this.siteID,
      this.narrative,
      this.mediaID});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || projectUuid != null) {
      map['projectUuid'] = Variable<String>(projectUuid);
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<String>(date);
    }
    if (!nullToAbsent || siteID != null) {
      map['siteID'] = Variable<int>(siteID);
    }
    if (!nullToAbsent || narrative != null) {
      map['narrative'] = Variable<String>(narrative);
    }
    if (!nullToAbsent || mediaID != null) {
      map['mediaID'] = Variable<int>(mediaID);
    }
    return map;
  }

  NarrativeCompanion toCompanion(bool nullToAbsent) {
    return NarrativeCompanion(
      id: Value(id),
      projectUuid: projectUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(projectUuid),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      siteID:
          siteID == null && nullToAbsent ? const Value.absent() : Value(siteID),
      narrative: narrative == null && nullToAbsent
          ? const Value.absent()
          : Value(narrative),
      mediaID: mediaID == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaID),
    );
  }

  factory NarrativeData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NarrativeData(
      id: serializer.fromJson<int>(json['id']),
      projectUuid: serializer.fromJson<String?>(json['projectUuid']),
      date: serializer.fromJson<String?>(json['date']),
      siteID: serializer.fromJson<int?>(json['siteID']),
      narrative: serializer.fromJson<String?>(json['narrative']),
      mediaID: serializer.fromJson<int?>(json['mediaID']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectUuid': serializer.toJson<String?>(projectUuid),
      'date': serializer.toJson<String?>(date),
      'siteID': serializer.toJson<int?>(siteID),
      'narrative': serializer.toJson<String?>(narrative),
      'mediaID': serializer.toJson<int?>(mediaID),
    };
  }

  NarrativeData copyWith(
          {int? id,
          Value<String?> projectUuid = const Value.absent(),
          Value<String?> date = const Value.absent(),
          Value<int?> siteID = const Value.absent(),
          Value<String?> narrative = const Value.absent(),
          Value<int?> mediaID = const Value.absent()}) =>
      NarrativeData(
        id: id ?? this.id,
        projectUuid: projectUuid.present ? projectUuid.value : this.projectUuid,
        date: date.present ? date.value : this.date,
        siteID: siteID.present ? siteID.value : this.siteID,
        narrative: narrative.present ? narrative.value : this.narrative,
        mediaID: mediaID.present ? mediaID.value : this.mediaID,
      );
  NarrativeData copyWithCompanion(NarrativeCompanion data) {
    return NarrativeData(
      id: data.id.present ? data.id.value : this.id,
      projectUuid:
          data.projectUuid.present ? data.projectUuid.value : this.projectUuid,
      date: data.date.present ? data.date.value : this.date,
      siteID: data.siteID.present ? data.siteID.value : this.siteID,
      narrative: data.narrative.present ? data.narrative.value : this.narrative,
      mediaID: data.mediaID.present ? data.mediaID.value : this.mediaID,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NarrativeData(')
          ..write('id: $id, ')
          ..write('projectUuid: $projectUuid, ')
          ..write('date: $date, ')
          ..write('siteID: $siteID, ')
          ..write('narrative: $narrative, ')
          ..write('mediaID: $mediaID')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, projectUuid, date, siteID, narrative, mediaID);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NarrativeData &&
          other.id == this.id &&
          other.projectUuid == this.projectUuid &&
          other.date == this.date &&
          other.siteID == this.siteID &&
          other.narrative == this.narrative &&
          other.mediaID == this.mediaID);
}

class NarrativeCompanion extends UpdateCompanion<NarrativeData> {
  final Value<int> id;
  final Value<String?> projectUuid;
  final Value<String?> date;
  final Value<int?> siteID;
  final Value<String?> narrative;
  final Value<int?> mediaID;
  const NarrativeCompanion({
    this.id = const Value.absent(),
    this.projectUuid = const Value.absent(),
    this.date = const Value.absent(),
    this.siteID = const Value.absent(),
    this.narrative = const Value.absent(),
    this.mediaID = const Value.absent(),
  });
  NarrativeCompanion.insert({
    this.id = const Value.absent(),
    this.projectUuid = const Value.absent(),
    this.date = const Value.absent(),
    this.siteID = const Value.absent(),
    this.narrative = const Value.absent(),
    this.mediaID = const Value.absent(),
  });
  static Insertable<NarrativeData> custom({
    Expression<int>? id,
    Expression<String>? projectUuid,
    Expression<String>? date,
    Expression<int>? siteID,
    Expression<String>? narrative,
    Expression<int>? mediaID,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectUuid != null) 'projectUuid': projectUuid,
      if (date != null) 'date': date,
      if (siteID != null) 'siteID': siteID,
      if (narrative != null) 'narrative': narrative,
      if (mediaID != null) 'mediaID': mediaID,
    });
  }

  NarrativeCompanion copyWith(
      {Value<int>? id,
      Value<String?>? projectUuid,
      Value<String?>? date,
      Value<int?>? siteID,
      Value<String?>? narrative,
      Value<int?>? mediaID}) {
    return NarrativeCompanion(
      id: id ?? this.id,
      projectUuid: projectUuid ?? this.projectUuid,
      date: date ?? this.date,
      siteID: siteID ?? this.siteID,
      narrative: narrative ?? this.narrative,
      mediaID: mediaID ?? this.mediaID,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectUuid.present) {
      map['projectUuid'] = Variable<String>(projectUuid.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (siteID.present) {
      map['siteID'] = Variable<int>(siteID.value);
    }
    if (narrative.present) {
      map['narrative'] = Variable<String>(narrative.value);
    }
    if (mediaID.present) {
      map['mediaID'] = Variable<int>(mediaID.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NarrativeCompanion(')
          ..write('id: $id, ')
          ..write('projectUuid: $projectUuid, ')
          ..write('date: $date, ')
          ..write('siteID: $siteID, ')
          ..write('narrative: $narrative, ')
          ..write('mediaID: $mediaID')
          ..write(')'))
        .toString();
  }
}

class NarrativeMedia extends Table
    with TableInfo<NarrativeMedia, NarrativeMediaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  NarrativeMedia(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _narrativeIdMeta =
      const VerificationMeta('narrativeId');
  late final GeneratedColumn<int> narrativeId = GeneratedColumn<int>(
      'narrativeId', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _mediaIdMeta =
      const VerificationMeta('mediaId');
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
      'mediaId', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [narrativeId, mediaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'narrativeMedia';
  @override
  VerificationContext validateIntegrity(Insertable<NarrativeMediaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('narrativeId')) {
      context.handle(
          _narrativeIdMeta,
          narrativeId.isAcceptableOrUnknown(
              data['narrativeId']!, _narrativeIdMeta));
    } else if (isInserting) {
      context.missing(_narrativeIdMeta);
    }
    if (data.containsKey('mediaId')) {
      context.handle(_mediaIdMeta,
          mediaId.isAcceptableOrUnknown(data['mediaId']!, _mediaIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  NarrativeMediaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NarrativeMediaData(
      narrativeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}narrativeId'])!,
      mediaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mediaId']),
    );
  }

  @override
  NarrativeMedia createAlias(String alias) {
    return NarrativeMedia(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'FOREIGN KEY(narrativeId)REFERENCES narrative(id)',
        'FOREIGN KEY(mediaId)REFERENCES media(primaryId)'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class NarrativeMediaData extends DataClass
    implements Insertable<NarrativeMediaData> {
  final int narrativeId;
  final int? mediaId;
  const NarrativeMediaData({required this.narrativeId, this.mediaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['narrativeId'] = Variable<int>(narrativeId);
    if (!nullToAbsent || mediaId != null) {
      map['mediaId'] = Variable<int>(mediaId);
    }
    return map;
  }

  NarrativeMediaCompanion toCompanion(bool nullToAbsent) {
    return NarrativeMediaCompanion(
      narrativeId: Value(narrativeId),
      mediaId: mediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaId),
    );
  }

  factory NarrativeMediaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NarrativeMediaData(
      narrativeId: serializer.fromJson<int>(json['narrativeId']),
      mediaId: serializer.fromJson<int?>(json['mediaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'narrativeId': serializer.toJson<int>(narrativeId),
      'mediaId': serializer.toJson<int?>(mediaId),
    };
  }

  NarrativeMediaData copyWith(
          {int? narrativeId, Value<int?> mediaId = const Value.absent()}) =>
      NarrativeMediaData(
        narrativeId: narrativeId ?? this.narrativeId,
        mediaId: mediaId.present ? mediaId.value : this.mediaId,
      );
  NarrativeMediaData copyWithCompanion(NarrativeMediaCompanion data) {
    return NarrativeMediaData(
      narrativeId:
          data.narrativeId.present ? data.narrativeId.value : this.narrativeId,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NarrativeMediaData(')
          ..write('narrativeId: $narrativeId, ')
          ..write('mediaId: $mediaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(narrativeId, mediaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NarrativeMediaData &&
          other.narrativeId == this.narrativeId &&
          other.mediaId == this.mediaId);
}

class NarrativeMediaCompanion extends UpdateCompanion<NarrativeMediaData> {
  final Value<int> narrativeId;
  final Value<int?> mediaId;
  final Value<int> rowid;
  const NarrativeMediaCompanion({
    this.narrativeId = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NarrativeMediaCompanion.insert({
    required int narrativeId,
    this.mediaId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : narrativeId = Value(narrativeId);
  static Insertable<NarrativeMediaData> custom({
    Expression<int>? narrativeId,
    Expression<int>? mediaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (narrativeId != null) 'narrativeId': narrativeId,
      if (mediaId != null) 'mediaId': mediaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NarrativeMediaCompanion copyWith(
      {Value<int>? narrativeId, Value<int?>? mediaId, Value<int>? rowid}) {
    return NarrativeMediaCompanion(
      narrativeId: narrativeId ?? this.narrativeId,
      mediaId: mediaId ?? this.mediaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (narrativeId.present) {
      map['narrativeId'] = Variable<int>(narrativeId.value);
    }
    if (mediaId.present) {
      map['mediaId'] = Variable<int>(mediaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NarrativeMediaCompanion(')
          ..write('narrativeId: $narrativeId, ')
          ..write('mediaId: $mediaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SiteMedia extends Table with TableInfo<SiteMedia, SiteMediaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SiteMedia(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  late final GeneratedColumn<int> siteId = GeneratedColumn<int>(
      'siteId', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _mediaIdMeta =
      const VerificationMeta('mediaId');
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
      'mediaId', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [siteId, mediaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'siteMedia';
  @override
  VerificationContext validateIntegrity(Insertable<SiteMediaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('siteId')) {
      context.handle(_siteIdMeta,
          siteId.isAcceptableOrUnknown(data['siteId']!, _siteIdMeta));
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('mediaId')) {
      context.handle(_mediaIdMeta,
          mediaId.isAcceptableOrUnknown(data['mediaId']!, _mediaIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  SiteMediaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SiteMediaData(
      siteId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}siteId'])!,
      mediaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mediaId']),
    );
  }

  @override
  SiteMedia createAlias(String alias) {
    return SiteMedia(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'FOREIGN KEY(siteId)REFERENCES site(id)',
        'FOREIGN KEY(mediaId)REFERENCES media(primaryId)'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class SiteMediaData extends DataClass implements Insertable<SiteMediaData> {
  final int siteId;
  final int? mediaId;
  const SiteMediaData({required this.siteId, this.mediaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['siteId'] = Variable<int>(siteId);
    if (!nullToAbsent || mediaId != null) {
      map['mediaId'] = Variable<int>(mediaId);
    }
    return map;
  }

  SiteMediaCompanion toCompanion(bool nullToAbsent) {
    return SiteMediaCompanion(
      siteId: Value(siteId),
      mediaId: mediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaId),
    );
  }

  factory SiteMediaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SiteMediaData(
      siteId: serializer.fromJson<int>(json['siteId']),
      mediaId: serializer.fromJson<int?>(json['mediaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'siteId': serializer.toJson<int>(siteId),
      'mediaId': serializer.toJson<int?>(mediaId),
    };
  }

  SiteMediaData copyWith(
          {int? siteId, Value<int?> mediaId = const Value.absent()}) =>
      SiteMediaData(
        siteId: siteId ?? this.siteId,
        mediaId: mediaId.present ? mediaId.value : this.mediaId,
      );
  SiteMediaData copyWithCompanion(SiteMediaCompanion data) {
    return SiteMediaData(
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SiteMediaData(')
          ..write('siteId: $siteId, ')
          ..write('mediaId: $mediaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(siteId, mediaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SiteMediaData &&
          other.siteId == this.siteId &&
          other.mediaId == this.mediaId);
}

class SiteMediaCompanion extends UpdateCompanion<SiteMediaData> {
  final Value<int> siteId;
  final Value<int?> mediaId;
  final Value<int> rowid;
  const SiteMediaCompanion({
    this.siteId = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SiteMediaCompanion.insert({
    required int siteId,
    this.mediaId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : siteId = Value(siteId);
  static Insertable<SiteMediaData> custom({
    Expression<int>? siteId,
    Expression<int>? mediaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (siteId != null) 'siteId': siteId,
      if (mediaId != null) 'mediaId': mediaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SiteMediaCompanion copyWith(
      {Value<int>? siteId, Value<int?>? mediaId, Value<int>? rowid}) {
    return SiteMediaCompanion(
      siteId: siteId ?? this.siteId,
      mediaId: mediaId ?? this.mediaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (siteId.present) {
      map['siteId'] = Variable<int>(siteId.value);
    }
    if (mediaId.present) {
      map['mediaId'] = Variable<int>(mediaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SiteMediaCompanion(')
          ..write('siteId: $siteId, ')
          ..write('mediaId: $mediaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Taxonomy extends Table with TableInfo<Taxonomy, TaxonomyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Taxonomy(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _taxonClassMeta =
      const VerificationMeta('taxonClass');
  late final GeneratedColumn<String> taxonClass = GeneratedColumn<String>(
      'taxonClass', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _taxonOrderMeta =
      const VerificationMeta('taxonOrder');
  late final GeneratedColumn<String> taxonOrder = GeneratedColumn<String>(
      'taxonOrder', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _taxonFamilyMeta =
      const VerificationMeta('taxonFamily');
  late final GeneratedColumn<String> taxonFamily = GeneratedColumn<String>(
      'taxonFamily', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _genusMeta = const VerificationMeta('genus');
  late final GeneratedColumn<String> genus = GeneratedColumn<String>(
      'genus', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _specificEpithetMeta =
      const VerificationMeta('specificEpithet');
  late final GeneratedColumn<String> specificEpithet = GeneratedColumn<String>(
      'specificEpithet', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _authorsMeta =
      const VerificationMeta('authors');
  late final GeneratedColumn<String> authors = GeneratedColumn<String>(
      'authors', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _commonNameMeta =
      const VerificationMeta('commonName');
  late final GeneratedColumn<String> commonName = GeneratedColumn<String>(
      'commonName', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _citesStatusMeta =
      const VerificationMeta('citesStatus');
  late final GeneratedColumn<String> citesStatus = GeneratedColumn<String>(
      'citesStatus', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _redListCategoryMeta =
      const VerificationMeta('redListCategory');
  late final GeneratedColumn<String> redListCategory = GeneratedColumn<String>(
      'redListCategory', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _countryStatusMeta =
      const VerificationMeta('countryStatus');
  late final GeneratedColumn<String> countryStatus = GeneratedColumn<String>(
      'countryStatus', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _sortingOrderMeta =
      const VerificationMeta('sortingOrder');
  late final GeneratedColumn<int> sortingOrder = GeneratedColumn<int>(
      'sortingOrder', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _mediaIdMeta =
      const VerificationMeta('mediaId');
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
      'mediaId', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        taxonClass,
        taxonOrder,
        taxonFamily,
        genus,
        specificEpithet,
        authors,
        commonName,
        notes,
        citesStatus,
        redListCategory,
        countryStatus,
        sortingOrder,
        mediaId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'taxonomy';
  @override
  VerificationContext validateIntegrity(Insertable<TaxonomyData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('taxonClass')) {
      context.handle(
          _taxonClassMeta,
          taxonClass.isAcceptableOrUnknown(
              data['taxonClass']!, _taxonClassMeta));
    }
    if (data.containsKey('taxonOrder')) {
      context.handle(
          _taxonOrderMeta,
          taxonOrder.isAcceptableOrUnknown(
              data['taxonOrder']!, _taxonOrderMeta));
    }
    if (data.containsKey('taxonFamily')) {
      context.handle(
          _taxonFamilyMeta,
          taxonFamily.isAcceptableOrUnknown(
              data['taxonFamily']!, _taxonFamilyMeta));
    }
    if (data.containsKey('genus')) {
      context.handle(
          _genusMeta, genus.isAcceptableOrUnknown(data['genus']!, _genusMeta));
    }
    if (data.containsKey('specificEpithet')) {
      context.handle(
          _specificEpithetMeta,
          specificEpithet.isAcceptableOrUnknown(
              data['specificEpithet']!, _specificEpithetMeta));
    }
    if (data.containsKey('authors')) {
      context.handle(_authorsMeta,
          authors.isAcceptableOrUnknown(data['authors']!, _authorsMeta));
    }
    if (data.containsKey('commonName')) {
      context.handle(
          _commonNameMeta,
          commonName.isAcceptableOrUnknown(
              data['commonName']!, _commonNameMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('citesStatus')) {
      context.handle(
          _citesStatusMeta,
          citesStatus.isAcceptableOrUnknown(
              data['citesStatus']!, _citesStatusMeta));
    }
    if (data.containsKey('redListCategory')) {
      context.handle(
          _redListCategoryMeta,
          redListCategory.isAcceptableOrUnknown(
              data['redListCategory']!, _redListCategoryMeta));
    }
    if (data.containsKey('countryStatus')) {
      context.handle(
          _countryStatusMeta,
          countryStatus.isAcceptableOrUnknown(
              data['countryStatus']!, _countryStatusMeta));
    }
    if (data.containsKey('sortingOrder')) {
      context.handle(
          _sortingOrderMeta,
          sortingOrder.isAcceptableOrUnknown(
              data['sortingOrder']!, _sortingOrderMeta));
    }
    if (data.containsKey('mediaId')) {
      context.handle(_mediaIdMeta,
          mediaId.isAcceptableOrUnknown(data['mediaId']!, _mediaIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaxonomyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaxonomyData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      taxonClass: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}taxonClass']),
      taxonOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}taxonOrder']),
      taxonFamily: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}taxonFamily']),
      genus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}genus']),
      specificEpithet: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specificEpithet']),
      authors: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}authors']),
      commonName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}commonName']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      citesStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}citesStatus']),
      redListCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}redListCategory']),
      countryStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}countryStatus']),
      sortingOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sortingOrder']),
      mediaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mediaId']),
    );
  }

  @override
  Taxonomy createAlias(String alias) {
    return Taxonomy(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['FOREIGN KEY(mediaId)REFERENCES media(primaryId)'];
  @override
  bool get dontWriteConstraints => true;
}

class TaxonomyData extends DataClass implements Insertable<TaxonomyData> {
  final int id;
  final String? taxonClass;
  final String? taxonOrder;
  final String? taxonFamily;
  final String? genus;
  final String? specificEpithet;
  final String? authors;
  final String? commonName;
  final String? notes;
  final String? citesStatus;
  final String? redListCategory;
  final String? countryStatus;
  final int? sortingOrder;
  final int? mediaId;
  const TaxonomyData(
      {required this.id,
      this.taxonClass,
      this.taxonOrder,
      this.taxonFamily,
      this.genus,
      this.specificEpithet,
      this.authors,
      this.commonName,
      this.notes,
      this.citesStatus,
      this.redListCategory,
      this.countryStatus,
      this.sortingOrder,
      this.mediaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || taxonClass != null) {
      map['taxonClass'] = Variable<String>(taxonClass);
    }
    if (!nullToAbsent || taxonOrder != null) {
      map['taxonOrder'] = Variable<String>(taxonOrder);
    }
    if (!nullToAbsent || taxonFamily != null) {
      map['taxonFamily'] = Variable<String>(taxonFamily);
    }
    if (!nullToAbsent || genus != null) {
      map['genus'] = Variable<String>(genus);
    }
    if (!nullToAbsent || specificEpithet != null) {
      map['specificEpithet'] = Variable<String>(specificEpithet);
    }
    if (!nullToAbsent || authors != null) {
      map['authors'] = Variable<String>(authors);
    }
    if (!nullToAbsent || commonName != null) {
      map['commonName'] = Variable<String>(commonName);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || citesStatus != null) {
      map['citesStatus'] = Variable<String>(citesStatus);
    }
    if (!nullToAbsent || redListCategory != null) {
      map['redListCategory'] = Variable<String>(redListCategory);
    }
    if (!nullToAbsent || countryStatus != null) {
      map['countryStatus'] = Variable<String>(countryStatus);
    }
    if (!nullToAbsent || sortingOrder != null) {
      map['sortingOrder'] = Variable<int>(sortingOrder);
    }
    if (!nullToAbsent || mediaId != null) {
      map['mediaId'] = Variable<int>(mediaId);
    }
    return map;
  }

  TaxonomyCompanion toCompanion(bool nullToAbsent) {
    return TaxonomyCompanion(
      id: Value(id),
      taxonClass: taxonClass == null && nullToAbsent
          ? const Value.absent()
          : Value(taxonClass),
      taxonOrder: taxonOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(taxonOrder),
      taxonFamily: taxonFamily == null && nullToAbsent
          ? const Value.absent()
          : Value(taxonFamily),
      genus:
          genus == null && nullToAbsent ? const Value.absent() : Value(genus),
      specificEpithet: specificEpithet == null && nullToAbsent
          ? const Value.absent()
          : Value(specificEpithet),
      authors: authors == null && nullToAbsent
          ? const Value.absent()
          : Value(authors),
      commonName: commonName == null && nullToAbsent
          ? const Value.absent()
          : Value(commonName),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      citesStatus: citesStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(citesStatus),
      redListCategory: redListCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(redListCategory),
      countryStatus: countryStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(countryStatus),
      sortingOrder: sortingOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortingOrder),
      mediaId: mediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaId),
    );
  }

  factory TaxonomyData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaxonomyData(
      id: serializer.fromJson<int>(json['id']),
      taxonClass: serializer.fromJson<String?>(json['taxonClass']),
      taxonOrder: serializer.fromJson<String?>(json['taxonOrder']),
      taxonFamily: serializer.fromJson<String?>(json['taxonFamily']),
      genus: serializer.fromJson<String?>(json['genus']),
      specificEpithet: serializer.fromJson<String?>(json['specificEpithet']),
      authors: serializer.fromJson<String?>(json['authors']),
      commonName: serializer.fromJson<String?>(json['commonName']),
      notes: serializer.fromJson<String?>(json['notes']),
      citesStatus: serializer.fromJson<String?>(json['citesStatus']),
      redListCategory: serializer.fromJson<String?>(json['redListCategory']),
      countryStatus: serializer.fromJson<String?>(json['countryStatus']),
      sortingOrder: serializer.fromJson<int?>(json['sortingOrder']),
      mediaId: serializer.fromJson<int?>(json['mediaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taxonClass': serializer.toJson<String?>(taxonClass),
      'taxonOrder': serializer.toJson<String?>(taxonOrder),
      'taxonFamily': serializer.toJson<String?>(taxonFamily),
      'genus': serializer.toJson<String?>(genus),
      'specificEpithet': serializer.toJson<String?>(specificEpithet),
      'authors': serializer.toJson<String?>(authors),
      'commonName': serializer.toJson<String?>(commonName),
      'notes': serializer.toJson<String?>(notes),
      'citesStatus': serializer.toJson<String?>(citesStatus),
      'redListCategory': serializer.toJson<String?>(redListCategory),
      'countryStatus': serializer.toJson<String?>(countryStatus),
      'sortingOrder': serializer.toJson<int?>(sortingOrder),
      'mediaId': serializer.toJson<int?>(mediaId),
    };
  }

  TaxonomyData copyWith(
          {int? id,
          Value<String?> taxonClass = const Value.absent(),
          Value<String?> taxonOrder = const Value.absent(),
          Value<String?> taxonFamily = const Value.absent(),
          Value<String?> genus = const Value.absent(),
          Value<String?> specificEpithet = const Value.absent(),
          Value<String?> authors = const Value.absent(),
          Value<String?> commonName = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> citesStatus = const Value.absent(),
          Value<String?> redListCategory = const Value.absent(),
          Value<String?> countryStatus = const Value.absent(),
          Value<int?> sortingOrder = const Value.absent(),
          Value<int?> mediaId = const Value.absent()}) =>
      TaxonomyData(
        id: id ?? this.id,
        taxonClass: taxonClass.present ? taxonClass.value : this.taxonClass,
        taxonOrder: taxonOrder.present ? taxonOrder.value : this.taxonOrder,
        taxonFamily: taxonFamily.present ? taxonFamily.value : this.taxonFamily,
        genus: genus.present ? genus.value : this.genus,
        specificEpithet: specificEpithet.present
            ? specificEpithet.value
            : this.specificEpithet,
        authors: authors.present ? authors.value : this.authors,
        commonName: commonName.present ? commonName.value : this.commonName,
        notes: notes.present ? notes.value : this.notes,
        citesStatus: citesStatus.present ? citesStatus.value : this.citesStatus,
        redListCategory: redListCategory.present
            ? redListCategory.value
            : this.redListCategory,
        countryStatus:
            countryStatus.present ? countryStatus.value : this.countryStatus,
        sortingOrder:
            sortingOrder.present ? sortingOrder.value : this.sortingOrder,
        mediaId: mediaId.present ? mediaId.value : this.mediaId,
      );
  TaxonomyData copyWithCompanion(TaxonomyCompanion data) {
    return TaxonomyData(
      id: data.id.present ? data.id.value : this.id,
      taxonClass:
          data.taxonClass.present ? data.taxonClass.value : this.taxonClass,
      taxonOrder:
          data.taxonOrder.present ? data.taxonOrder.value : this.taxonOrder,
      taxonFamily:
          data.taxonFamily.present ? data.taxonFamily.value : this.taxonFamily,
      genus: data.genus.present ? data.genus.value : this.genus,
      specificEpithet: data.specificEpithet.present
          ? data.specificEpithet.value
          : this.specificEpithet,
      authors: data.authors.present ? data.authors.value : this.authors,
      commonName:
          data.commonName.present ? data.commonName.value : this.commonName,
      notes: data.notes.present ? data.notes.value : this.notes,
      citesStatus:
          data.citesStatus.present ? data.citesStatus.value : this.citesStatus,
      redListCategory: data.redListCategory.present
          ? data.redListCategory.value
          : this.redListCategory,
      countryStatus: data.countryStatus.present
          ? data.countryStatus.value
          : this.countryStatus,
      sortingOrder: data.sortingOrder.present
          ? data.sortingOrder.value
          : this.sortingOrder,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaxonomyData(')
          ..write('id: $id, ')
          ..write('taxonClass: $taxonClass, ')
          ..write('taxonOrder: $taxonOrder, ')
          ..write('taxonFamily: $taxonFamily, ')
          ..write('genus: $genus, ')
          ..write('specificEpithet: $specificEpithet, ')
          ..write('authors: $authors, ')
          ..write('commonName: $commonName, ')
          ..write('notes: $notes, ')
          ..write('citesStatus: $citesStatus, ')
          ..write('redListCategory: $redListCategory, ')
          ..write('countryStatus: $countryStatus, ')
          ..write('sortingOrder: $sortingOrder, ')
          ..write('mediaId: $mediaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      taxonClass,
      taxonOrder,
      taxonFamily,
      genus,
      specificEpithet,
      authors,
      commonName,
      notes,
      citesStatus,
      redListCategory,
      countryStatus,
      sortingOrder,
      mediaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaxonomyData &&
          other.id == this.id &&
          other.taxonClass == this.taxonClass &&
          other.taxonOrder == this.taxonOrder &&
          other.taxonFamily == this.taxonFamily &&
          other.genus == this.genus &&
          other.specificEpithet == this.specificEpithet &&
          other.authors == this.authors &&
          other.commonName == this.commonName &&
          other.notes == this.notes &&
          other.citesStatus == this.citesStatus &&
          other.redListCategory == this.redListCategory &&
          other.countryStatus == this.countryStatus &&
          other.sortingOrder == this.sortingOrder &&
          other.mediaId == this.mediaId);
}

class TaxonomyCompanion extends UpdateCompanion<TaxonomyData> {
  final Value<int> id;
  final Value<String?> taxonClass;
  final Value<String?> taxonOrder;
  final Value<String?> taxonFamily;
  final Value<String?> genus;
  final Value<String?> specificEpithet;
  final Value<String?> authors;
  final Value<String?> commonName;
  final Value<String?> notes;
  final Value<String?> citesStatus;
  final Value<String?> redListCategory;
  final Value<String?> countryStatus;
  final Value<int?> sortingOrder;
  final Value<int?> mediaId;
  const TaxonomyCompanion({
    this.id = const Value.absent(),
    this.taxonClass = const Value.absent(),
    this.taxonOrder = const Value.absent(),
    this.taxonFamily = const Value.absent(),
    this.genus = const Value.absent(),
    this.specificEpithet = const Value.absent(),
    this.authors = const Value.absent(),
    this.commonName = const Value.absent(),
    this.notes = const Value.absent(),
    this.citesStatus = const Value.absent(),
    this.redListCategory = const Value.absent(),
    this.countryStatus = const Value.absent(),
    this.sortingOrder = const Value.absent(),
    this.mediaId = const Value.absent(),
  });
  TaxonomyCompanion.insert({
    this.id = const Value.absent(),
    this.taxonClass = const Value.absent(),
    this.taxonOrder = const Value.absent(),
    this.taxonFamily = const Value.absent(),
    this.genus = const Value.absent(),
    this.specificEpithet = const Value.absent(),
    this.authors = const Value.absent(),
    this.commonName = const Value.absent(),
    this.notes = const Value.absent(),
    this.citesStatus = const Value.absent(),
    this.redListCategory = const Value.absent(),
    this.countryStatus = const Value.absent(),
    this.sortingOrder = const Value.absent(),
    this.mediaId = const Value.absent(),
  });
  static Insertable<TaxonomyData> custom({
    Expression<int>? id,
    Expression<String>? taxonClass,
    Expression<String>? taxonOrder,
    Expression<String>? taxonFamily,
    Expression<String>? genus,
    Expression<String>? specificEpithet,
    Expression<String>? authors,
    Expression<String>? commonName,
    Expression<String>? notes,
    Expression<String>? citesStatus,
    Expression<String>? redListCategory,
    Expression<String>? countryStatus,
    Expression<int>? sortingOrder,
    Expression<int>? mediaId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taxonClass != null) 'taxonClass': taxonClass,
      if (taxonOrder != null) 'taxonOrder': taxonOrder,
      if (taxonFamily != null) 'taxonFamily': taxonFamily,
      if (genus != null) 'genus': genus,
      if (specificEpithet != null) 'specificEpithet': specificEpithet,
      if (authors != null) 'authors': authors,
      if (commonName != null) 'commonName': commonName,
      if (notes != null) 'notes': notes,
      if (citesStatus != null) 'citesStatus': citesStatus,
      if (redListCategory != null) 'redListCategory': redListCategory,
      if (countryStatus != null) 'countryStatus': countryStatus,
      if (sortingOrder != null) 'sortingOrder': sortingOrder,
      if (mediaId != null) 'mediaId': mediaId,
    });
  }

  TaxonomyCompanion copyWith(
      {Value<int>? id,
      Value<String?>? taxonClass,
      Value<String?>? taxonOrder,
      Value<String?>? taxonFamily,
      Value<String?>? genus,
      Value<String?>? specificEpithet,
      Value<String?>? authors,
      Value<String?>? commonName,
      Value<String?>? notes,
      Value<String?>? citesStatus,
      Value<String?>? redListCategory,
      Value<String?>? countryStatus,
      Value<int?>? sortingOrder,
      Value<int?>? mediaId}) {
    return TaxonomyCompanion(
      id: id ?? this.id,
      taxonClass: taxonClass ?? this.taxonClass,
      taxonOrder: taxonOrder ?? this.taxonOrder,
      taxonFamily: taxonFamily ?? this.taxonFamily,
      genus: genus ?? this.genus,
      specificEpithet: specificEpithet ?? this.specificEpithet,
      authors: authors ?? this.authors,
      commonName: commonName ?? this.commonName,
      notes: notes ?? this.notes,
      citesStatus: citesStatus ?? this.citesStatus,
      redListCategory: redListCategory ?? this.redListCategory,
      countryStatus: countryStatus ?? this.countryStatus,
      sortingOrder: sortingOrder ?? this.sortingOrder,
      mediaId: mediaId ?? this.mediaId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taxonClass.present) {
      map['taxonClass'] = Variable<String>(taxonClass.value);
    }
    if (taxonOrder.present) {
      map['taxonOrder'] = Variable<String>(taxonOrder.value);
    }
    if (taxonFamily.present) {
      map['taxonFamily'] = Variable<String>(taxonFamily.value);
    }
    if (genus.present) {
      map['genus'] = Variable<String>(genus.value);
    }
    if (specificEpithet.present) {
      map['specificEpithet'] = Variable<String>(specificEpithet.value);
    }
    if (authors.present) {
      map['authors'] = Variable<String>(authors.value);
    }
    if (commonName.present) {
      map['commonName'] = Variable<String>(commonName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (citesStatus.present) {
      map['citesStatus'] = Variable<String>(citesStatus.value);
    }
    if (redListCategory.present) {
      map['redListCategory'] = Variable<String>(redListCategory.value);
    }
    if (countryStatus.present) {
      map['countryStatus'] = Variable<String>(countryStatus.value);
    }
    if (sortingOrder.present) {
      map['sortingOrder'] = Variable<int>(sortingOrder.value);
    }
    if (mediaId.present) {
      map['mediaId'] = Variable<int>(mediaId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaxonomyCompanion(')
          ..write('id: $id, ')
          ..write('taxonClass: $taxonClass, ')
          ..write('taxonOrder: $taxonOrder, ')
          ..write('taxonFamily: $taxonFamily, ')
          ..write('genus: $genus, ')
          ..write('specificEpithet: $specificEpithet, ')
          ..write('authors: $authors, ')
          ..write('commonName: $commonName, ')
          ..write('notes: $notes, ')
          ..write('citesStatus: $citesStatus, ')
          ..write('redListCategory: $redListCategory, ')
          ..write('countryStatus: $countryStatus, ')
          ..write('sortingOrder: $sortingOrder, ')
          ..write('mediaId: $mediaId')
          ..write(')'))
        .toString();
  }
}

class Specimen extends Table with TableInfo<Specimen, SpecimenData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Specimen(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL PRIMARY KEY');
  static const VerificationMeta _projectUuidMeta =
      const VerificationMeta('projectUuid');
  late final GeneratedColumn<String> projectUuid = GeneratedColumn<String>(
      'projectUuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _speciesIDMeta =
      const VerificationMeta('speciesID');
  late final GeneratedColumn<int> speciesID = GeneratedColumn<int>(
      'speciesID', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _iDConfidenceMeta =
      const VerificationMeta('iDConfidence');
  late final GeneratedColumn<int> iDConfidence = GeneratedColumn<int>(
      'iDConfidence', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _iDMethodMeta =
      const VerificationMeta('iDMethod');
  late final GeneratedColumn<String> iDMethod = GeneratedColumn<String>(
      'iDMethod', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _taxonGroupMeta =
      const VerificationMeta('taxonGroup');
  late final GeneratedColumn<String> taxonGroup = GeneratedColumn<String>(
      'taxonGroup', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _conditionMeta =
      const VerificationMeta('condition');
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
      'condition', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _prepDateMeta =
      const VerificationMeta('prepDate');
  late final GeneratedColumn<String> prepDate = GeneratedColumn<String>(
      'prepDate', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _prepTimeMeta =
      const VerificationMeta('prepTime');
  late final GeneratedColumn<String> prepTime = GeneratedColumn<String>(
      'prepTime', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _collectionTimeMeta =
      const VerificationMeta('collectionTime');
  late final GeneratedColumn<String> collectionTime = GeneratedColumn<String>(
      'collectionTime', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _captureDateMeta =
      const VerificationMeta('captureDate');
  late final GeneratedColumn<String> captureDate = GeneratedColumn<String>(
      'captureDate', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _isRelativeTimeMeta =
      const VerificationMeta('isRelativeTime');
  late final GeneratedColumn<int> isRelativeTime = GeneratedColumn<int>(
      'isRelativeTime', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _captureTimeMeta =
      const VerificationMeta('captureTime');
  late final GeneratedColumn<String> captureTime = GeneratedColumn<String>(
      'captureTime', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _trapTypeMeta =
      const VerificationMeta('trapType');
  late final GeneratedColumn<String> trapType = GeneratedColumn<String>(
      'trapType', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _methodIDMeta =
      const VerificationMeta('methodID');
  late final GeneratedColumn<String> methodID = GeneratedColumn<String>(
      'methodID', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _coordinateIDMeta =
      const VerificationMeta('coordinateID');
  late final GeneratedColumn<int> coordinateID = GeneratedColumn<int>(
      'coordinateID', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _catalogerIDMeta =
      const VerificationMeta('catalogerID');
  late final GeneratedColumn<String> catalogerID = GeneratedColumn<String>(
      'catalogerID', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _fieldNumberMeta =
      const VerificationMeta('fieldNumber');
  late final GeneratedColumn<int> fieldNumber = GeneratedColumn<int>(
      'fieldNumber', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _collEventIDMeta =
      const VerificationMeta('collEventID');
  late final GeneratedColumn<int> collEventID = GeneratedColumn<int>(
      'collEventID', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _isMultipleCollectorMeta =
      const VerificationMeta('isMultipleCollector');
  late final GeneratedColumn<int> isMultipleCollector = GeneratedColumn<int>(
      'isMultipleCollector', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _collPersonnelIDMeta =
      const VerificationMeta('collPersonnelID');
  late final GeneratedColumn<int> collPersonnelID = GeneratedColumn<int>(
      'collPersonnelID', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _collMethodIDMeta =
      const VerificationMeta('collMethodID');
  late final GeneratedColumn<int> collMethodID = GeneratedColumn<int>(
      'collMethodID', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _museumIDMeta =
      const VerificationMeta('museumID');
  late final GeneratedColumn<String> museumID = GeneratedColumn<String>(
      'museumID', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _preparatorIDMeta =
      const VerificationMeta('preparatorID');
  late final GeneratedColumn<String> preparatorID = GeneratedColumn<String>(
      'preparatorID', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES personnel(uuid)');
  @override
  List<GeneratedColumn> get $columns => [
        uuid,
        projectUuid,
        speciesID,
        iDConfidence,
        iDMethod,
        taxonGroup,
        condition,
        prepDate,
        prepTime,
        collectionTime,
        captureDate,
        isRelativeTime,
        captureTime,
        trapType,
        methodID,
        coordinateID,
        catalogerID,
        fieldNumber,
        collEventID,
        isMultipleCollector,
        collPersonnelID,
        collMethodID,
        museumID,
        preparatorID
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'specimen';
  @override
  VerificationContext validateIntegrity(Insertable<SpecimenData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('projectUuid')) {
      context.handle(
          _projectUuidMeta,
          projectUuid.isAcceptableOrUnknown(
              data['projectUuid']!, _projectUuidMeta));
    }
    if (data.containsKey('speciesID')) {
      context.handle(_speciesIDMeta,
          speciesID.isAcceptableOrUnknown(data['speciesID']!, _speciesIDMeta));
    }
    if (data.containsKey('iDConfidence')) {
      context.handle(
          _iDConfidenceMeta,
          iDConfidence.isAcceptableOrUnknown(
              data['iDConfidence']!, _iDConfidenceMeta));
    }
    if (data.containsKey('iDMethod')) {
      context.handle(_iDMethodMeta,
          iDMethod.isAcceptableOrUnknown(data['iDMethod']!, _iDMethodMeta));
    }
    if (data.containsKey('taxonGroup')) {
      context.handle(
          _taxonGroupMeta,
          taxonGroup.isAcceptableOrUnknown(
              data['taxonGroup']!, _taxonGroupMeta));
    }
    if (data.containsKey('condition')) {
      context.handle(_conditionMeta,
          condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta));
    }
    if (data.containsKey('prepDate')) {
      context.handle(_prepDateMeta,
          prepDate.isAcceptableOrUnknown(data['prepDate']!, _prepDateMeta));
    }
    if (data.containsKey('prepTime')) {
      context.handle(_prepTimeMeta,
          prepTime.isAcceptableOrUnknown(data['prepTime']!, _prepTimeMeta));
    }
    if (data.containsKey('collectionTime')) {
      context.handle(
          _collectionTimeMeta,
          collectionTime.isAcceptableOrUnknown(
              data['collectionTime']!, _collectionTimeMeta));
    }
    if (data.containsKey('captureDate')) {
      context.handle(
          _captureDateMeta,
          captureDate.isAcceptableOrUnknown(
              data['captureDate']!, _captureDateMeta));
    }
    if (data.containsKey('isRelativeTime')) {
      context.handle(
          _isRelativeTimeMeta,
          isRelativeTime.isAcceptableOrUnknown(
              data['isRelativeTime']!, _isRelativeTimeMeta));
    }
    if (data.containsKey('captureTime')) {
      context.handle(
          _captureTimeMeta,
          captureTime.isAcceptableOrUnknown(
              data['captureTime']!, _captureTimeMeta));
    }
    if (data.containsKey('trapType')) {
      context.handle(_trapTypeMeta,
          trapType.isAcceptableOrUnknown(data['trapType']!, _trapTypeMeta));
    }
    if (data.containsKey('methodID')) {
      context.handle(_methodIDMeta,
          methodID.isAcceptableOrUnknown(data['methodID']!, _methodIDMeta));
    }
    if (data.containsKey('coordinateID')) {
      context.handle(
          _coordinateIDMeta,
          coordinateID.isAcceptableOrUnknown(
              data['coordinateID']!, _coordinateIDMeta));
    }
    if (data.containsKey('catalogerID')) {
      context.handle(
          _catalogerIDMeta,
          catalogerID.isAcceptableOrUnknown(
              data['catalogerID']!, _catalogerIDMeta));
    }
    if (data.containsKey('fieldNumber')) {
      context.handle(
          _fieldNumberMeta,
          fieldNumber.isAcceptableOrUnknown(
              data['fieldNumber']!, _fieldNumberMeta));
    }
    if (data.containsKey('collEventID')) {
      context.handle(
          _collEventIDMeta,
          collEventID.isAcceptableOrUnknown(
              data['collEventID']!, _collEventIDMeta));
    }
    if (data.containsKey('isMultipleCollector')) {
      context.handle(
          _isMultipleCollectorMeta,
          isMultipleCollector.isAcceptableOrUnknown(
              data['isMultipleCollector']!, _isMultipleCollectorMeta));
    }
    if (data.containsKey('collPersonnelID')) {
      context.handle(
          _collPersonnelIDMeta,
          collPersonnelID.isAcceptableOrUnknown(
              data['collPersonnelID']!, _collPersonnelIDMeta));
    }
    if (data.containsKey('collMethodID')) {
      context.handle(
          _collMethodIDMeta,
          collMethodID.isAcceptableOrUnknown(
              data['collMethodID']!, _collMethodIDMeta));
    }
    if (data.containsKey('museumID')) {
      context.handle(_museumIDMeta,
          museumID.isAcceptableOrUnknown(data['museumID']!, _museumIDMeta));
    }
    if (data.containsKey('preparatorID')) {
      context.handle(
          _preparatorIDMeta,
          preparatorID.isAcceptableOrUnknown(
              data['preparatorID']!, _preparatorIDMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  SpecimenData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpecimenData(
      uuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      projectUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}projectUuid']),
      speciesID: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}speciesID']),
      iDConfidence: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}iDConfidence']),
      iDMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}iDMethod']),
      taxonGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}taxonGroup']),
      condition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition']),
      prepDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prepDate']),
      prepTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prepTime']),
      collectionTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collectionTime']),
      captureDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}captureDate']),
      isRelativeTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}isRelativeTime']),
      captureTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}captureTime']),
      trapType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trapType']),
      methodID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}methodID']),
      coordinateID: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}coordinateID']),
      catalogerID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}catalogerID']),
      fieldNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fieldNumber']),
      collEventID: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}collEventID']),
      isMultipleCollector: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}isMultipleCollector']),
      collPersonnelID: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}collPersonnelID']),
      collMethodID: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}collMethodID']),
      museumID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}museumID']),
      preparatorID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}preparatorID']),
    );
  }

  @override
  Specimen createAlias(String alias) {
    return Specimen(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'FOREIGN KEY(projectUuid)REFERENCES project(uuid)',
        'FOREIGN KEY(catalogerID)REFERENCES personnel(uuid)',
        'FOREIGN KEY(collPersonnelID)REFERENCES collPersonnel(id)',
        'FOREIGN KEY(collMethodID)REFERENCES collEffort(id)',
        'FOREIGN KEY(speciesID)REFERENCES taxonomy(id)',
        'FOREIGN KEY(collEventID)REFERENCES collEvent(id)'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class SpecimenData extends DataClass implements Insertable<SpecimenData> {
  final String uuid;
  final String? projectUuid;
  final int? speciesID;
  final int? iDConfidence;
  final String? iDMethod;
  final String? taxonGroup;

  /// use for catalog formats
  final String? condition;
  final String? prepDate;
  final String? prepTime;
  final String? collectionTime;

  /// v4 update
  final String? captureDate;
  final int? isRelativeTime;
  final String? captureTime;
  final String? trapType;
  final String? methodID;

  /// v4 rename
  final int? coordinateID;
  final String? catalogerID;
  final int? fieldNumber;
  final int? collEventID;
  final int? isMultipleCollector;
  final int? collPersonnelID;
  final int? collMethodID;
  final String? museumID;
  final String? preparatorID;
  const SpecimenData(
      {required this.uuid,
      this.projectUuid,
      this.speciesID,
      this.iDConfidence,
      this.iDMethod,
      this.taxonGroup,
      this.condition,
      this.prepDate,
      this.prepTime,
      this.collectionTime,
      this.captureDate,
      this.isRelativeTime,
      this.captureTime,
      this.trapType,
      this.methodID,
      this.coordinateID,
      this.catalogerID,
      this.fieldNumber,
      this.collEventID,
      this.isMultipleCollector,
      this.collPersonnelID,
      this.collMethodID,
      this.museumID,
      this.preparatorID});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || projectUuid != null) {
      map['projectUuid'] = Variable<String>(projectUuid);
    }
    if (!nullToAbsent || speciesID != null) {
      map['speciesID'] = Variable<int>(speciesID);
    }
    if (!nullToAbsent || iDConfidence != null) {
      map['iDConfidence'] = Variable<int>(iDConfidence);
    }
    if (!nullToAbsent || iDMethod != null) {
      map['iDMethod'] = Variable<String>(iDMethod);
    }
    if (!nullToAbsent || taxonGroup != null) {
      map['taxonGroup'] = Variable<String>(taxonGroup);
    }
    if (!nullToAbsent || condition != null) {
      map['condition'] = Variable<String>(condition);
    }
    if (!nullToAbsent || prepDate != null) {
      map['prepDate'] = Variable<String>(prepDate);
    }
    if (!nullToAbsent || prepTime != null) {
      map['prepTime'] = Variable<String>(prepTime);
    }
    if (!nullToAbsent || collectionTime != null) {
      map['collectionTime'] = Variable<String>(collectionTime);
    }
    if (!nullToAbsent || captureDate != null) {
      map['captureDate'] = Variable<String>(captureDate);
    }
    if (!nullToAbsent || isRelativeTime != null) {
      map['isRelativeTime'] = Variable<int>(isRelativeTime);
    }
    if (!nullToAbsent || captureTime != null) {
      map['captureTime'] = Variable<String>(captureTime);
    }
    if (!nullToAbsent || trapType != null) {
      map['trapType'] = Variable<String>(trapType);
    }
    if (!nullToAbsent || methodID != null) {
      map['methodID'] = Variable<String>(methodID);
    }
    if (!nullToAbsent || coordinateID != null) {
      map['coordinateID'] = Variable<int>(coordinateID);
    }
    if (!nullToAbsent || catalogerID != null) {
      map['catalogerID'] = Variable<String>(catalogerID);
    }
    if (!nullToAbsent || fieldNumber != null) {
      map['fieldNumber'] = Variable<int>(fieldNumber);
    }
    if (!nullToAbsent || collEventID != null) {
      map['collEventID'] = Variable<int>(collEventID);
    }
    if (!nullToAbsent || isMultipleCollector != null) {
      map['isMultipleCollector'] = Variable<int>(isMultipleCollector);
    }
    if (!nullToAbsent || collPersonnelID != null) {
      map['collPersonnelID'] = Variable<int>(collPersonnelID);
    }
    if (!nullToAbsent || collMethodID != null) {
      map['collMethodID'] = Variable<int>(collMethodID);
    }
    if (!nullToAbsent || museumID != null) {
      map['museumID'] = Variable<String>(museumID);
    }
    if (!nullToAbsent || preparatorID != null) {
      map['preparatorID'] = Variable<String>(preparatorID);
    }
    return map;
  }

  SpecimenCompanion toCompanion(bool nullToAbsent) {
    return SpecimenCompanion(
      uuid: Value(uuid),
      projectUuid: projectUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(projectUuid),
      speciesID: speciesID == null && nullToAbsent
          ? const Value.absent()
          : Value(speciesID),
      iDConfidence: iDConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(iDConfidence),
      iDMethod: iDMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(iDMethod),
      taxonGroup: taxonGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(taxonGroup),
      condition: condition == null && nullToAbsent
          ? const Value.absent()
          : Value(condition),
      prepDate: prepDate == null && nullToAbsent
          ? const Value.absent()
          : Value(prepDate),
      prepTime: prepTime == null && nullToAbsent
          ? const Value.absent()
          : Value(prepTime),
      collectionTime: collectionTime == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionTime),
      captureDate: captureDate == null && nullToAbsent
          ? const Value.absent()
          : Value(captureDate),
      isRelativeTime: isRelativeTime == null && nullToAbsent
          ? const Value.absent()
          : Value(isRelativeTime),
      captureTime: captureTime == null && nullToAbsent
          ? const Value.absent()
          : Value(captureTime),
      trapType: trapType == null && nullToAbsent
          ? const Value.absent()
          : Value(trapType),
      methodID: methodID == null && nullToAbsent
          ? const Value.absent()
          : Value(methodID),
      coordinateID: coordinateID == null && nullToAbsent
          ? const Value.absent()
          : Value(coordinateID),
      catalogerID: catalogerID == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogerID),
      fieldNumber: fieldNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldNumber),
      collEventID: collEventID == null && nullToAbsent
          ? const Value.absent()
          : Value(collEventID),
      isMultipleCollector: isMultipleCollector == null && nullToAbsent
          ? const Value.absent()
          : Value(isMultipleCollector),
      collPersonnelID: collPersonnelID == null && nullToAbsent
          ? const Value.absent()
          : Value(collPersonnelID),
      collMethodID: collMethodID == null && nullToAbsent
          ? const Value.absent()
          : Value(collMethodID),
      museumID: museumID == null && nullToAbsent
          ? const Value.absent()
          : Value(museumID),
      preparatorID: preparatorID == null && nullToAbsent
          ? const Value.absent()
          : Value(preparatorID),
    );
  }

  factory SpecimenData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpecimenData(
      uuid: serializer.fromJson<String>(json['uuid']),
      projectUuid: serializer.fromJson<String?>(json['projectUuid']),
      speciesID: serializer.fromJson<int?>(json['speciesID']),
      iDConfidence: serializer.fromJson<int?>(json['iDConfidence']),
      iDMethod: serializer.fromJson<String?>(json['iDMethod']),
      taxonGroup: serializer.fromJson<String?>(json['taxonGroup']),
      condition: serializer.fromJson<String?>(json['condition']),
      prepDate: serializer.fromJson<String?>(json['prepDate']),
      prepTime: serializer.fromJson<String?>(json['prepTime']),
      collectionTime: serializer.fromJson<String?>(json['collectionTime']),
      captureDate: serializer.fromJson<String?>(json['captureDate']),
      isRelativeTime: serializer.fromJson<int?>(json['isRelativeTime']),
      captureTime: serializer.fromJson<String?>(json['captureTime']),
      trapType: serializer.fromJson<String?>(json['trapType']),
      methodID: serializer.fromJson<String?>(json['methodID']),
      coordinateID: serializer.fromJson<int?>(json['coordinateID']),
      catalogerID: serializer.fromJson<String?>(json['catalogerID']),
      fieldNumber: serializer.fromJson<int?>(json['fieldNumber']),
      collEventID: serializer.fromJson<int?>(json['collEventID']),
      isMultipleCollector:
          serializer.fromJson<int?>(json['isMultipleCollector']),
      collPersonnelID: serializer.fromJson<int?>(json['collPersonnelID']),
      collMethodID: serializer.fromJson<int?>(json['collMethodID']),
      museumID: serializer.fromJson<String?>(json['museumID']),
      preparatorID: serializer.fromJson<String?>(json['preparatorID']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'projectUuid': serializer.toJson<String?>(projectUuid),
      'speciesID': serializer.toJson<int?>(speciesID),
      'iDConfidence': serializer.toJson<int?>(iDConfidence),
      'iDMethod': serializer.toJson<String?>(iDMethod),
      'taxonGroup': serializer.toJson<String?>(taxonGroup),
      'condition': serializer.toJson<String?>(condition),
      'prepDate': serializer.toJson<String?>(prepDate),
      'prepTime': serializer.toJson<String?>(prepTime),
      'collectionTime': serializer.toJson<String?>(collectionTime),
      'captureDate': serializer.toJson<String?>(captureDate),
      'isRelativeTime': serializer.toJson<int?>(isRelativeTime),
      'captureTime': serializer.toJson<String?>(captureTime),
      'trapType': serializer.toJson<String?>(trapType),
      'methodID': serializer.toJson<String?>(methodID),
      'coordinateID': serializer.toJson<int?>(coordinateID),
      'catalogerID': serializer.toJson<String?>(catalogerID),
      'fieldNumber': serializer.toJson<int?>(fieldNumber),
      'collEventID': serializer.toJson<int?>(collEventID),
      'isMultipleCollector': serializer.toJson<int?>(isMultipleCollector),
      'collPersonnelID': serializer.toJson<int?>(collPersonnelID),
      'collMethodID': serializer.toJson<int?>(collMethodID),
      'museumID': serializer.toJson<String?>(museumID),
      'preparatorID': serializer.toJson<String?>(preparatorID),
    };
  }

  SpecimenData copyWith(
          {String? uuid,
          Value<String?> projectUuid = const Value.absent(),
          Value<int?> speciesID = const Value.absent(),
          Value<int?> iDConfidence = const Value.absent(),
          Value<String?> iDMethod = const Value.absent(),
          Value<String?> taxonGroup = const Value.absent(),
          Value<String?> condition = const Value.absent(),
          Value<String?> prepDate = const Value.absent(),
          Value<String?> prepTime = const Value.absent(),
          Value<String?> collectionTime = const Value.absent(),
          Value<String?> captureDate = const Value.absent(),
          Value<int?> isRelativeTime = const Value.absent(),
          Value<String?> captureTime = const Value.absent(),
          Value<String?> trapType = const Value.absent(),
          Value<String?> methodID = const Value.absent(),
          Value<int?> coordinateID = const Value.absent(),
          Value<String?> catalogerID = const Value.absent(),
          Value<int?> fieldNumber = const Value.absent(),
          Value<int?> collEventID = const Value.absent(),
          Value<int?> isMultipleCollector = const Value.absent(),
          Value<int?> collPersonnelID = const Value.absent(),
          Value<int?> collMethodID = const Value.absent(),
          Value<String?> museumID = const Value.absent(),
          Value<String?> preparatorID = const Value.absent()}) =>
      SpecimenData(
        uuid: uuid ?? this.uuid,
        projectUuid: projectUuid.present ? projectUuid.value : this.projectUuid,
        speciesID: speciesID.present ? speciesID.value : this.speciesID,
        iDConfidence:
            iDConfidence.present ? iDConfidence.value : this.iDConfidence,
        iDMethod: iDMethod.present ? iDMethod.value : this.iDMethod,
        taxonGroup: taxonGroup.present ? taxonGroup.value : this.taxonGroup,
        condition: condition.present ? condition.value : this.condition,
        prepDate: prepDate.present ? prepDate.value : this.prepDate,
        prepTime: prepTime.present ? prepTime.value : this.prepTime,
        collectionTime:
            collectionTime.present ? collectionTime.value : this.collectionTime,
        captureDate: captureDate.present ? captureDate.value : this.captureDate,
        isRelativeTime:
            isRelativeTime.present ? isRelativeTime.value : this.isRelativeTime,
        captureTime: captureTime.present ? captureTime.value : this.captureTime,
        trapType: trapType.present ? trapType.value : this.trapType,
        methodID: methodID.present ? methodID.value : this.methodID,
        coordinateID:
            coordinateID.present ? coordinateID.value : this.coordinateID,
        catalogerID: catalogerID.present ? catalogerID.value : this.catalogerID,
        fieldNumber: fieldNumber.present ? fieldNumber.value : this.fieldNumber,
        collEventID: collEventID.present ? collEventID.value : this.collEventID,
        isMultipleCollector: isMultipleCollector.present
            ? isMultipleCollector.value
            : this.isMultipleCollector,
        collPersonnelID: collPersonnelID.present
            ? collPersonnelID.value
            : this.collPersonnelID,
        collMethodID:
            collMethodID.present ? collMethodID.value : this.collMethodID,
        museumID: museumID.present ? museumID.value : this.museumID,
        preparatorID:
            preparatorID.present ? preparatorID.value : this.preparatorID,
      );
  SpecimenData copyWithCompanion(SpecimenCompanion data) {
    return SpecimenData(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      projectUuid:
          data.projectUuid.present ? data.projectUuid.value : this.projectUuid,
      speciesID: data.speciesID.present ? data.speciesID.value : this.speciesID,
      iDConfidence: data.iDConfidence.present
          ? data.iDConfidence.value
          : this.iDConfidence,
      iDMethod: data.iDMethod.present ? data.iDMethod.value : this.iDMethod,
      taxonGroup:
          data.taxonGroup.present ? data.taxonGroup.value : this.taxonGroup,
      condition: data.condition.present ? data.condition.value : this.condition,
      prepDate: data.prepDate.present ? data.prepDate.value : this.prepDate,
      prepTime: data.prepTime.present ? data.prepTime.value : this.prepTime,
      collectionTime: data.collectionTime.present
          ? data.collectionTime.value
          : this.collectionTime,
      captureDate:
          data.captureDate.present ? data.captureDate.value : this.captureDate,
      isRelativeTime: data.isRelativeTime.present
          ? data.isRelativeTime.value
          : this.isRelativeTime,
      captureTime:
          data.captureTime.present ? data.captureTime.value : this.captureTime,
      trapType: data.trapType.present ? data.trapType.value : this.trapType,
      methodID: data.methodID.present ? data.methodID.value : this.methodID,
      coordinateID: data.coordinateID.present
          ? data.coordinateID.value
          : this.coordinateID,
      catalogerID:
          data.catalogerID.present ? data.catalogerID.value : this.catalogerID,
      fieldNumber:
          data.fieldNumber.present ? data.fieldNumber.value : this.fieldNumber,
      collEventID:
          data.collEventID.present ? data.collEventID.value : this.collEventID,
      isMultipleCollector: data.isMultipleCollector.present
          ? data.isMultipleCollector.value
          : this.isMultipleCollector,
      collPersonnelID: data.collPersonnelID.present
          ? data.collPersonnelID.value
          : this.collPersonnelID,
      collMethodID: data.collMethodID.present
          ? data.collMethodID.value
          : this.collMethodID,
      museumID: data.museumID.present ? data.museumID.value : this.museumID,
      preparatorID: data.preparatorID.present
          ? data.preparatorID.value
          : this.preparatorID,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpecimenData(')
          ..write('uuid: $uuid, ')
          ..write('projectUuid: $projectUuid, ')
          ..write('speciesID: $speciesID, ')
          ..write('iDConfidence: $iDConfidence, ')
          ..write('iDMethod: $iDMethod, ')
          ..write('taxonGroup: $taxonGroup, ')
          ..write('condition: $condition, ')
          ..write('prepDate: $prepDate, ')
          ..write('prepTime: $prepTime, ')
          ..write('collectionTime: $collectionTime, ')
          ..write('captureDate: $captureDate, ')
          ..write('isRelativeTime: $isRelativeTime, ')
          ..write('captureTime: $captureTime, ')
          ..write('trapType: $trapType, ')
          ..write('methodID: $methodID, ')
          ..write('coordinateID: $coordinateID, ')
          ..write('catalogerID: $catalogerID, ')
          ..write('fieldNumber: $fieldNumber, ')
          ..write('collEventID: $collEventID, ')
          ..write('isMultipleCollector: $isMultipleCollector, ')
          ..write('collPersonnelID: $collPersonnelID, ')
          ..write('collMethodID: $collMethodID, ')
          ..write('museumID: $museumID, ')
          ..write('preparatorID: $preparatorID')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        uuid,
        projectUuid,
        speciesID,
        iDConfidence,
        iDMethod,
        taxonGroup,
        condition,
        prepDate,
        prepTime,
        collectionTime,
        captureDate,
        isRelativeTime,
        captureTime,
        trapType,
        methodID,
        coordinateID,
        catalogerID,
        fieldNumber,
        collEventID,
        isMultipleCollector,
        collPersonnelID,
        collMethodID,
        museumID,
        preparatorID
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpecimenData &&
          other.uuid == this.uuid &&
          other.projectUuid == this.projectUuid &&
          other.speciesID == this.speciesID &&
          other.iDConfidence == this.iDConfidence &&
          other.iDMethod == this.iDMethod &&
          other.taxonGroup == this.taxonGroup &&
          other.condition == this.condition &&
          other.prepDate == this.prepDate &&
          other.prepTime == this.prepTime &&
          other.collectionTime == this.collectionTime &&
          other.captureDate == this.captureDate &&
          other.isRelativeTime == this.isRelativeTime &&
          other.captureTime == this.captureTime &&
          other.trapType == this.trapType &&
          other.methodID == this.methodID &&
          other.coordinateID == this.coordinateID &&
          other.catalogerID == this.catalogerID &&
          other.fieldNumber == this.fieldNumber &&
          other.collEventID == this.collEventID &&
          other.isMultipleCollector == this.isMultipleCollector &&
          other.collPersonnelID == this.collPersonnelID &&
          other.collMethodID == this.collMethodID &&
          other.museumID == this.museumID &&
          other.preparatorID == this.preparatorID);
}

class SpecimenCompanion extends UpdateCompanion<SpecimenData> {
  final Value<String> uuid;
  final Value<String?> projectUuid;
  final Value<int?> speciesID;
  final Value<int?> iDConfidence;
  final Value<String?> iDMethod;
  final Value<String?> taxonGroup;
  final Value<String?> condition;
  final Value<String?> prepDate;
  final Value<String?> prepTime;
  final Value<String?> collectionTime;
  final Value<String?> captureDate;
  final Value<int?> isRelativeTime;
  final Value<String?> captureTime;
  final Value<String?> trapType;
  final Value<String?> methodID;
  final Value<int?> coordinateID;
  final Value<String?> catalogerID;
  final Value<int?> fieldNumber;
  final Value<int?> collEventID;
  final Value<int?> isMultipleCollector;
  final Value<int?> collPersonnelID;
  final Value<int?> collMethodID;
  final Value<String?> museumID;
  final Value<String?> preparatorID;
  final Value<int> rowid;
  const SpecimenCompanion({
    this.uuid = const Value.absent(),
    this.projectUuid = const Value.absent(),
    this.speciesID = const Value.absent(),
    this.iDConfidence = const Value.absent(),
    this.iDMethod = const Value.absent(),
    this.taxonGroup = const Value.absent(),
    this.condition = const Value.absent(),
    this.prepDate = const Value.absent(),
    this.prepTime = const Value.absent(),
    this.collectionTime = const Value.absent(),
    this.captureDate = const Value.absent(),
    this.isRelativeTime = const Value.absent(),
    this.captureTime = const Value.absent(),
    this.trapType = const Value.absent(),
    this.methodID = const Value.absent(),
    this.coordinateID = const Value.absent(),
    this.catalogerID = const Value.absent(),
    this.fieldNumber = const Value.absent(),
    this.collEventID = const Value.absent(),
    this.isMultipleCollector = const Value.absent(),
    this.collPersonnelID = const Value.absent(),
    this.collMethodID = const Value.absent(),
    this.museumID = const Value.absent(),
    this.preparatorID = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpecimenCompanion.insert({
    required String uuid,
    this.projectUuid = const Value.absent(),
    this.speciesID = const Value.absent(),
    this.iDConfidence = const Value.absent(),
    this.iDMethod = const Value.absent(),
    this.taxonGroup = const Value.absent(),
    this.condition = const Value.absent(),
    this.prepDate = const Value.absent(),
    this.prepTime = const Value.absent(),
    this.collectionTime = const Value.absent(),
    this.captureDate = const Value.absent(),
    this.isRelativeTime = const Value.absent(),
    this.captureTime = const Value.absent(),
    this.trapType = const Value.absent(),
    this.methodID = const Value.absent(),
    this.coordinateID = const Value.absent(),
    this.catalogerID = const Value.absent(),
    this.fieldNumber = const Value.absent(),
    this.collEventID = const Value.absent(),
    this.isMultipleCollector = const Value.absent(),
    this.collPersonnelID = const Value.absent(),
    this.collMethodID = const Value.absent(),
    this.museumID = const Value.absent(),
    this.preparatorID = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid);
  static Insertable<SpecimenData> custom({
    Expression<String>? uuid,
    Expression<String>? projectUuid,
    Expression<int>? speciesID,
    Expression<int>? iDConfidence,
    Expression<String>? iDMethod,
    Expression<String>? taxonGroup,
    Expression<String>? condition,
    Expression<String>? prepDate,
    Expression<String>? prepTime,
    Expression<String>? collectionTime,
    Expression<String>? captureDate,
    Expression<int>? isRelativeTime,
    Expression<String>? captureTime,
    Expression<String>? trapType,
    Expression<String>? methodID,
    Expression<int>? coordinateID,
    Expression<String>? catalogerID,
    Expression<int>? fieldNumber,
    Expression<int>? collEventID,
    Expression<int>? isMultipleCollector,
    Expression<int>? collPersonnelID,
    Expression<int>? collMethodID,
    Expression<String>? museumID,
    Expression<String>? preparatorID,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (projectUuid != null) 'projectUuid': projectUuid,
      if (speciesID != null) 'speciesID': speciesID,
      if (iDConfidence != null) 'iDConfidence': iDConfidence,
      if (iDMethod != null) 'iDMethod': iDMethod,
      if (taxonGroup != null) 'taxonGroup': taxonGroup,
      if (condition != null) 'condition': condition,
      if (prepDate != null) 'prepDate': prepDate,
      if (prepTime != null) 'prepTime': prepTime,
      if (collectionTime != null) 'collectionTime': collectionTime,
      if (captureDate != null) 'captureDate': captureDate,
      if (isRelativeTime != null) 'isRelativeTime': isRelativeTime,
      if (captureTime != null) 'captureTime': captureTime,
      if (trapType != null) 'trapType': trapType,
      if (methodID != null) 'methodID': methodID,
      if (coordinateID != null) 'coordinateID': coordinateID,
      if (catalogerID != null) 'catalogerID': catalogerID,
      if (fieldNumber != null) 'fieldNumber': fieldNumber,
      if (collEventID != null) 'collEventID': collEventID,
      if (isMultipleCollector != null)
        'isMultipleCollector': isMultipleCollector,
      if (collPersonnelID != null) 'collPersonnelID': collPersonnelID,
      if (collMethodID != null) 'collMethodID': collMethodID,
      if (museumID != null) 'museumID': museumID,
      if (preparatorID != null) 'preparatorID': preparatorID,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpecimenCompanion copyWith(
      {Value<String>? uuid,
      Value<String?>? projectUuid,
      Value<int?>? speciesID,
      Value<int?>? iDConfidence,
      Value<String?>? iDMethod,
      Value<String?>? taxonGroup,
      Value<String?>? condition,
      Value<String?>? prepDate,
      Value<String?>? prepTime,
      Value<String?>? collectionTime,
      Value<String?>? captureDate,
      Value<int?>? isRelativeTime,
      Value<String?>? captureTime,
      Value<String?>? trapType,
      Value<String?>? methodID,
      Value<int?>? coordinateID,
      Value<String?>? catalogerID,
      Value<int?>? fieldNumber,
      Value<int?>? collEventID,
      Value<int?>? isMultipleCollector,
      Value<int?>? collPersonnelID,
      Value<int?>? collMethodID,
      Value<String?>? museumID,
      Value<String?>? preparatorID,
      Value<int>? rowid}) {
    return SpecimenCompanion(
      uuid: uuid ?? this.uuid,
      projectUuid: projectUuid ?? this.projectUuid,
      speciesID: speciesID ?? this.speciesID,
      iDConfidence: iDConfidence ?? this.iDConfidence,
      iDMethod: iDMethod ?? this.iDMethod,
      taxonGroup: taxonGroup ?? this.taxonGroup,
      condition: condition ?? this.condition,
      prepDate: prepDate ?? this.prepDate,
      prepTime: prepTime ?? this.prepTime,
      collectionTime: collectionTime ?? this.collectionTime,
      captureDate: captureDate ?? this.captureDate,
      isRelativeTime: isRelativeTime ?? this.isRelativeTime,
      captureTime: captureTime ?? this.captureTime,
      trapType: trapType ?? this.trapType,
      methodID: methodID ?? this.methodID,
      coordinateID: coordinateID ?? this.coordinateID,
      catalogerID: catalogerID ?? this.catalogerID,
      fieldNumber: fieldNumber ?? this.fieldNumber,
      collEventID: collEventID ?? this.collEventID,
      isMultipleCollector: isMultipleCollector ?? this.isMultipleCollector,
      collPersonnelID: collPersonnelID ?? this.collPersonnelID,
      collMethodID: collMethodID ?? this.collMethodID,
      museumID: museumID ?? this.museumID,
      preparatorID: preparatorID ?? this.preparatorID,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (projectUuid.present) {
      map['projectUuid'] = Variable<String>(projectUuid.value);
    }
    if (speciesID.present) {
      map['speciesID'] = Variable<int>(speciesID.value);
    }
    if (iDConfidence.present) {
      map['iDConfidence'] = Variable<int>(iDConfidence.value);
    }
    if (iDMethod.present) {
      map['iDMethod'] = Variable<String>(iDMethod.value);
    }
    if (taxonGroup.present) {
      map['taxonGroup'] = Variable<String>(taxonGroup.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (prepDate.present) {
      map['prepDate'] = Variable<String>(prepDate.value);
    }
    if (prepTime.present) {
      map['prepTime'] = Variable<String>(prepTime.value);
    }
    if (collectionTime.present) {
      map['collectionTime'] = Variable<String>(collectionTime.value);
    }
    if (captureDate.present) {
      map['captureDate'] = Variable<String>(captureDate.value);
    }
    if (isRelativeTime.present) {
      map['isRelativeTime'] = Variable<int>(isRelativeTime.value);
    }
    if (captureTime.present) {
      map['captureTime'] = Variable<String>(captureTime.value);
    }
    if (trapType.present) {
      map['trapType'] = Variable<String>(trapType.value);
    }
    if (methodID.present) {
      map['methodID'] = Variable<String>(methodID.value);
    }
    if (coordinateID.present) {
      map['coordinateID'] = Variable<int>(coordinateID.value);
    }
    if (catalogerID.present) {
      map['catalogerID'] = Variable<String>(catalogerID.value);
    }
    if (fieldNumber.present) {
      map['fieldNumber'] = Variable<int>(fieldNumber.value);
    }
    if (collEventID.present) {
      map['collEventID'] = Variable<int>(collEventID.value);
    }
    if (isMultipleCollector.present) {
      map['isMultipleCollector'] = Variable<int>(isMultipleCollector.value);
    }
    if (collPersonnelID.present) {
      map['collPersonnelID'] = Variable<int>(collPersonnelID.value);
    }
    if (collMethodID.present) {
      map['collMethodID'] = Variable<int>(collMethodID.value);
    }
    if (museumID.present) {
      map['museumID'] = Variable<String>(museumID.value);
    }
    if (preparatorID.present) {
      map['preparatorID'] = Variable<String>(preparatorID.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpecimenCompanion(')
          ..write('uuid: $uuid, ')
          ..write('projectUuid: $projectUuid, ')
          ..write('speciesID: $speciesID, ')
          ..write('iDConfidence: $iDConfidence, ')
          ..write('iDMethod: $iDMethod, ')
          ..write('taxonGroup: $taxonGroup, ')
          ..write('condition: $condition, ')
          ..write('prepDate: $prepDate, ')
          ..write('prepTime: $prepTime, ')
          ..write('collectionTime: $collectionTime, ')
          ..write('captureDate: $captureDate, ')
          ..write('isRelativeTime: $isRelativeTime, ')
          ..write('captureTime: $captureTime, ')
          ..write('trapType: $trapType, ')
          ..write('methodID: $methodID, ')
          ..write('coordinateID: $coordinateID, ')
          ..write('catalogerID: $catalogerID, ')
          ..write('fieldNumber: $fieldNumber, ')
          ..write('collEventID: $collEventID, ')
          ..write('isMultipleCollector: $isMultipleCollector, ')
          ..write('collPersonnelID: $collPersonnelID, ')
          ..write('collMethodID: $collMethodID, ')
          ..write('museumID: $museumID, ')
          ..write('preparatorID: $preparatorID, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SpecimenMedia extends Table
    with TableInfo<SpecimenMedia, SpecimenMediaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SpecimenMedia(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _specimenUuidMeta =
      const VerificationMeta('specimenUuid');
  late final GeneratedColumn<String> specimenUuid = GeneratedColumn<String>(
      'specimenUuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _mediaIdMeta =
      const VerificationMeta('mediaId');
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
      'mediaId', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [specimenUuid, mediaId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'specimenMedia';
  @override
  VerificationContext validateIntegrity(Insertable<SpecimenMediaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('specimenUuid')) {
      context.handle(
          _specimenUuidMeta,
          specimenUuid.isAcceptableOrUnknown(
              data['specimenUuid']!, _specimenUuidMeta));
    } else if (isInserting) {
      context.missing(_specimenUuidMeta);
    }
    if (data.containsKey('mediaId')) {
      context.handle(_mediaIdMeta,
          mediaId.isAcceptableOrUnknown(data['mediaId']!, _mediaIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  SpecimenMediaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpecimenMediaData(
      specimenUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specimenUuid'])!,
      mediaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mediaId']),
    );
  }

  @override
  SpecimenMedia createAlias(String alias) {
    return SpecimenMedia(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'FOREIGN KEY(specimenUuid)REFERENCES specimen(uuid)',
        'FOREIGN KEY(mediaId)REFERENCES media(primaryId)'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class SpecimenMediaData extends DataClass
    implements Insertable<SpecimenMediaData> {
  final String specimenUuid;
  final int? mediaId;
  const SpecimenMediaData({required this.specimenUuid, this.mediaId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['specimenUuid'] = Variable<String>(specimenUuid);
    if (!nullToAbsent || mediaId != null) {
      map['mediaId'] = Variable<int>(mediaId);
    }
    return map;
  }

  SpecimenMediaCompanion toCompanion(bool nullToAbsent) {
    return SpecimenMediaCompanion(
      specimenUuid: Value(specimenUuid),
      mediaId: mediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaId),
    );
  }

  factory SpecimenMediaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpecimenMediaData(
      specimenUuid: serializer.fromJson<String>(json['specimenUuid']),
      mediaId: serializer.fromJson<int?>(json['mediaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'specimenUuid': serializer.toJson<String>(specimenUuid),
      'mediaId': serializer.toJson<int?>(mediaId),
    };
  }

  SpecimenMediaData copyWith(
          {String? specimenUuid, Value<int?> mediaId = const Value.absent()}) =>
      SpecimenMediaData(
        specimenUuid: specimenUuid ?? this.specimenUuid,
        mediaId: mediaId.present ? mediaId.value : this.mediaId,
      );
  SpecimenMediaData copyWithCompanion(SpecimenMediaCompanion data) {
    return SpecimenMediaData(
      specimenUuid: data.specimenUuid.present
          ? data.specimenUuid.value
          : this.specimenUuid,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpecimenMediaData(')
          ..write('specimenUuid: $specimenUuid, ')
          ..write('mediaId: $mediaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(specimenUuid, mediaId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpecimenMediaData &&
          other.specimenUuid == this.specimenUuid &&
          other.mediaId == this.mediaId);
}

class SpecimenMediaCompanion extends UpdateCompanion<SpecimenMediaData> {
  final Value<String> specimenUuid;
  final Value<int?> mediaId;
  final Value<int> rowid;
  const SpecimenMediaCompanion({
    this.specimenUuid = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpecimenMediaCompanion.insert({
    required String specimenUuid,
    this.mediaId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : specimenUuid = Value(specimenUuid);
  static Insertable<SpecimenMediaData> custom({
    Expression<String>? specimenUuid,
    Expression<int>? mediaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (specimenUuid != null) 'specimenUuid': specimenUuid,
      if (mediaId != null) 'mediaId': mediaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpecimenMediaCompanion copyWith(
      {Value<String>? specimenUuid, Value<int?>? mediaId, Value<int>? rowid}) {
    return SpecimenMediaCompanion(
      specimenUuid: specimenUuid ?? this.specimenUuid,
      mediaId: mediaId ?? this.mediaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (specimenUuid.present) {
      map['specimenUuid'] = Variable<String>(specimenUuid.value);
    }
    if (mediaId.present) {
      map['mediaId'] = Variable<int>(mediaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpecimenMediaCompanion(')
          ..write('specimenUuid: $specimenUuid, ')
          ..write('mediaId: $mediaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AssociatedData extends Table
    with TableInfo<AssociatedData, AssociatedDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AssociatedData(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _primaryIdMeta =
      const VerificationMeta('primaryId');
  late final GeneratedColumn<int> primaryId = GeneratedColumn<int>(
      'primaryId', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _specimenUuidMeta =
      const VerificationMeta('specimenUuid');
  late final GeneratedColumn<String> specimenUuid = GeneratedColumn<String>(
      'specimenUuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns =>
      [primaryId, specimenUuid, name, type, date, description, url];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'associatedData';
  @override
  VerificationContext validateIntegrity(Insertable<AssociatedDataData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('primaryId')) {
      context.handle(_primaryIdMeta,
          primaryId.isAcceptableOrUnknown(data['primaryId']!, _primaryIdMeta));
    }
    if (data.containsKey('specimenUuid')) {
      context.handle(
          _specimenUuidMeta,
          specimenUuid.isAcceptableOrUnknown(
              data['specimenUuid']!, _specimenUuidMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {primaryId};
  @override
  AssociatedDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssociatedDataData(
      primaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}primaryId']),
      specimenUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specimenUuid']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url']),
    );
  }

  @override
  AssociatedData createAlias(String alias) {
    return AssociatedData(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['FOREIGN KEY(specimenUuid)REFERENCES specimen(uuid)'];
  @override
  bool get dontWriteConstraints => true;
}

class AssociatedDataData extends DataClass
    implements Insertable<AssociatedDataData> {
  final int? primaryId;
  final String? specimenUuid;
  final String? name;
  final String? type;
  final String? date;
  final String? description;
  final String? url;
  const AssociatedDataData(
      {this.primaryId,
      this.specimenUuid,
      this.name,
      this.type,
      this.date,
      this.description,
      this.url});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || primaryId != null) {
      map['primaryId'] = Variable<int>(primaryId);
    }
    if (!nullToAbsent || specimenUuid != null) {
      map['specimenUuid'] = Variable<String>(specimenUuid);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<String>(date);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    return map;
  }

  AssociatedDataCompanion toCompanion(bool nullToAbsent) {
    return AssociatedDataCompanion(
      primaryId: primaryId == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryId),
      specimenUuid: specimenUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(specimenUuid),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
    );
  }

  factory AssociatedDataData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssociatedDataData(
      primaryId: serializer.fromJson<int?>(json['primaryId']),
      specimenUuid: serializer.fromJson<String?>(json['specimenUuid']),
      name: serializer.fromJson<String?>(json['name']),
      type: serializer.fromJson<String?>(json['type']),
      date: serializer.fromJson<String?>(json['date']),
      description: serializer.fromJson<String?>(json['description']),
      url: serializer.fromJson<String?>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'primaryId': serializer.toJson<int?>(primaryId),
      'specimenUuid': serializer.toJson<String?>(specimenUuid),
      'name': serializer.toJson<String?>(name),
      'type': serializer.toJson<String?>(type),
      'date': serializer.toJson<String?>(date),
      'description': serializer.toJson<String?>(description),
      'url': serializer.toJson<String?>(url),
    };
  }

  AssociatedDataData copyWith(
          {Value<int?> primaryId = const Value.absent(),
          Value<String?> specimenUuid = const Value.absent(),
          Value<String?> name = const Value.absent(),
          Value<String?> type = const Value.absent(),
          Value<String?> date = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> url = const Value.absent()}) =>
      AssociatedDataData(
        primaryId: primaryId.present ? primaryId.value : this.primaryId,
        specimenUuid:
            specimenUuid.present ? specimenUuid.value : this.specimenUuid,
        name: name.present ? name.value : this.name,
        type: type.present ? type.value : this.type,
        date: date.present ? date.value : this.date,
        description: description.present ? description.value : this.description,
        url: url.present ? url.value : this.url,
      );
  AssociatedDataData copyWithCompanion(AssociatedDataCompanion data) {
    return AssociatedDataData(
      primaryId: data.primaryId.present ? data.primaryId.value : this.primaryId,
      specimenUuid: data.specimenUuid.present
          ? data.specimenUuid.value
          : this.specimenUuid,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      date: data.date.present ? data.date.value : this.date,
      description:
          data.description.present ? data.description.value : this.description,
      url: data.url.present ? data.url.value : this.url,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssociatedDataData(')
          ..write('primaryId: $primaryId, ')
          ..write('specimenUuid: $specimenUuid, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(primaryId, specimenUuid, name, type, date, description, url);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssociatedDataData &&
          other.primaryId == this.primaryId &&
          other.specimenUuid == this.specimenUuid &&
          other.name == this.name &&
          other.type == this.type &&
          other.date == this.date &&
          other.description == this.description &&
          other.url == this.url);
}

class AssociatedDataCompanion extends UpdateCompanion<AssociatedDataData> {
  final Value<int?> primaryId;
  final Value<String?> specimenUuid;
  final Value<String?> name;
  final Value<String?> type;
  final Value<String?> date;
  final Value<String?> description;
  final Value<String?> url;
  const AssociatedDataCompanion({
    this.primaryId = const Value.absent(),
    this.specimenUuid = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.url = const Value.absent(),
  });
  AssociatedDataCompanion.insert({
    this.primaryId = const Value.absent(),
    this.specimenUuid = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.url = const Value.absent(),
  });
  static Insertable<AssociatedDataData> custom({
    Expression<int>? primaryId,
    Expression<String>? specimenUuid,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? date,
    Expression<String>? description,
    Expression<String>? url,
  }) {
    return RawValuesInsertable({
      if (primaryId != null) 'primaryId': primaryId,
      if (specimenUuid != null) 'specimenUuid': specimenUuid,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (url != null) 'url': url,
    });
  }

  AssociatedDataCompanion copyWith(
      {Value<int?>? primaryId,
      Value<String?>? specimenUuid,
      Value<String?>? name,
      Value<String?>? type,
      Value<String?>? date,
      Value<String?>? description,
      Value<String?>? url}) {
    return AssociatedDataCompanion(
      primaryId: primaryId ?? this.primaryId,
      specimenUuid: specimenUuid ?? this.specimenUuid,
      name: name ?? this.name,
      type: type ?? this.type,
      date: date ?? this.date,
      description: description ?? this.description,
      url: url ?? this.url,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (primaryId.present) {
      map['primaryId'] = Variable<int>(primaryId.value);
    }
    if (specimenUuid.present) {
      map['specimenUuid'] = Variable<String>(specimenUuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssociatedDataCompanion(')
          ..write('primaryId: $primaryId, ')
          ..write('specimenUuid: $specimenUuid, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }
}

class PersonnelList extends Table
    with TableInfo<PersonnelList, PersonnelListData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  PersonnelList(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _projectUuidMeta =
      const VerificationMeta('projectUuid');
  late final GeneratedColumn<String> projectUuid = GeneratedColumn<String>(
      'projectUuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _personnelUuidMeta =
      const VerificationMeta('personnelUuid');
  late final GeneratedColumn<String> personnelUuid = GeneratedColumn<String>(
      'personnelUuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [projectUuid, personnelUuid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personnelList';
  @override
  VerificationContext validateIntegrity(Insertable<PersonnelListData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('projectUuid')) {
      context.handle(
          _projectUuidMeta,
          projectUuid.isAcceptableOrUnknown(
              data['projectUuid']!, _projectUuidMeta));
    }
    if (data.containsKey('personnelUuid')) {
      context.handle(
          _personnelUuidMeta,
          personnelUuid.isAcceptableOrUnknown(
              data['personnelUuid']!, _personnelUuidMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  PersonnelListData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonnelListData(
      projectUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}projectUuid']),
      personnelUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}personnelUuid']),
    );
  }

  @override
  PersonnelList createAlias(String alias) {
    return PersonnelList(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'FOREIGN KEY(projectUuid)REFERENCES project(uuid)',
        'FOREIGN KEY(personnelUuid)REFERENCES personnel(uuid)'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class PersonnelListData extends DataClass
    implements Insertable<PersonnelListData> {
  final String? projectUuid;
  final String? personnelUuid;
  const PersonnelListData({this.projectUuid, this.personnelUuid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || projectUuid != null) {
      map['projectUuid'] = Variable<String>(projectUuid);
    }
    if (!nullToAbsent || personnelUuid != null) {
      map['personnelUuid'] = Variable<String>(personnelUuid);
    }
    return map;
  }

  PersonnelListCompanion toCompanion(bool nullToAbsent) {
    return PersonnelListCompanion(
      projectUuid: projectUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(projectUuid),
      personnelUuid: personnelUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(personnelUuid),
    );
  }

  factory PersonnelListData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonnelListData(
      projectUuid: serializer.fromJson<String?>(json['projectUuid']),
      personnelUuid: serializer.fromJson<String?>(json['personnelUuid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'projectUuid': serializer.toJson<String?>(projectUuid),
      'personnelUuid': serializer.toJson<String?>(personnelUuid),
    };
  }

  PersonnelListData copyWith(
          {Value<String?> projectUuid = const Value.absent(),
          Value<String?> personnelUuid = const Value.absent()}) =>
      PersonnelListData(
        projectUuid: projectUuid.present ? projectUuid.value : this.projectUuid,
        personnelUuid:
            personnelUuid.present ? personnelUuid.value : this.personnelUuid,
      );
  PersonnelListData copyWithCompanion(PersonnelListCompanion data) {
    return PersonnelListData(
      projectUuid:
          data.projectUuid.present ? data.projectUuid.value : this.projectUuid,
      personnelUuid: data.personnelUuid.present
          ? data.personnelUuid.value
          : this.personnelUuid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonnelListData(')
          ..write('projectUuid: $projectUuid, ')
          ..write('personnelUuid: $personnelUuid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(projectUuid, personnelUuid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonnelListData &&
          other.projectUuid == this.projectUuid &&
          other.personnelUuid == this.personnelUuid);
}

class PersonnelListCompanion extends UpdateCompanion<PersonnelListData> {
  final Value<String?> projectUuid;
  final Value<String?> personnelUuid;
  final Value<int> rowid;
  const PersonnelListCompanion({
    this.projectUuid = const Value.absent(),
    this.personnelUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonnelListCompanion.insert({
    this.projectUuid = const Value.absent(),
    this.personnelUuid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<PersonnelListData> custom({
    Expression<String>? projectUuid,
    Expression<String>? personnelUuid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (projectUuid != null) 'projectUuid': projectUuid,
      if (personnelUuid != null) 'personnelUuid': personnelUuid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonnelListCompanion copyWith(
      {Value<String?>? projectUuid,
      Value<String?>? personnelUuid,
      Value<int>? rowid}) {
    return PersonnelListCompanion(
      projectUuid: projectUuid ?? this.projectUuid,
      personnelUuid: personnelUuid ?? this.personnelUuid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (projectUuid.present) {
      map['projectUuid'] = Variable<String>(projectUuid.value);
    }
    if (personnelUuid.present) {
      map['personnelUuid'] = Variable<String>(personnelUuid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonnelListCompanion(')
          ..write('projectUuid: $projectUuid, ')
          ..write('personnelUuid: $personnelUuid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MammalMeasurement extends Table
    with TableInfo<MammalMeasurement, MammalMeasurementData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MammalMeasurement(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _specimenUuidMeta =
      const VerificationMeta('specimenUuid');
  late final GeneratedColumn<String> specimenUuid = GeneratedColumn<String>(
      'specimenUuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _totalLengthMeta =
      const VerificationMeta('totalLength');
  late final GeneratedColumn<double> totalLength = GeneratedColumn<double>(
      'totalLength', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _tailLengthMeta =
      const VerificationMeta('tailLength');
  late final GeneratedColumn<double> tailLength = GeneratedColumn<double>(
      'tailLength', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _hindFootLengthMeta =
      const VerificationMeta('hindFootLength');
  late final GeneratedColumn<double> hindFootLength = GeneratedColumn<double>(
      'hindFootLength', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _earLengthMeta =
      const VerificationMeta('earLength');
  late final GeneratedColumn<double> earLength = GeneratedColumn<double>(
      'earLength', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _forearmMeta =
      const VerificationMeta('forearm');
  late final GeneratedColumn<double> forearm = GeneratedColumn<double>(
      'forearm', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  late final GeneratedColumn<String> accuracy = GeneratedColumn<String>(
      'accuracy', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _accuracySpecifyMeta =
      const VerificationMeta('accuracySpecify');
  late final GeneratedColumn<String> accuracySpecify = GeneratedColumn<String>(
      'accuracySpecify', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  late final GeneratedColumn<int> sex = GeneratedColumn<int>(
      'sex', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _testisPositionMeta =
      const VerificationMeta('testisPosition');
  late final GeneratedColumn<int> testisPosition = GeneratedColumn<int>(
      'testisPosition', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _testisLengthMeta =
      const VerificationMeta('testisLength');
  late final GeneratedColumn<double> testisLength = GeneratedColumn<double>(
      'testisLength', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _testisWidthMeta =
      const VerificationMeta('testisWidth');
  late final GeneratedColumn<double> testisWidth = GeneratedColumn<double>(
      'testisWidth', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _epididymisAppearanceMeta =
      const VerificationMeta('epididymisAppearance');
  late final GeneratedColumn<int> epididymisAppearance = GeneratedColumn<int>(
      'epididymisAppearance', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _reproductiveStageMeta =
      const VerificationMeta('reproductiveStage');
  late final GeneratedColumn<int> reproductiveStage = GeneratedColumn<int>(
      'reproductiveStage', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _leftPlacentalScarsMeta =
      const VerificationMeta('leftPlacentalScars');
  late final GeneratedColumn<int> leftPlacentalScars = GeneratedColumn<int>(
      'leftPlacentalScars', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _rightPlacentalScarsMeta =
      const VerificationMeta('rightPlacentalScars');
  late final GeneratedColumn<int> rightPlacentalScars = GeneratedColumn<int>(
      'rightPlacentalScars', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _mammaeConditionMeta =
      const VerificationMeta('mammaeCondition');
  late final GeneratedColumn<int> mammaeCondition = GeneratedColumn<int>(
      'mammaeCondition', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _mammaeInguinalCountMeta =
      const VerificationMeta('mammaeInguinalCount');
  late final GeneratedColumn<int> mammaeInguinalCount = GeneratedColumn<int>(
      'mammaeInguinalCount', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _mammaeAxillaryCountMeta =
      const VerificationMeta('mammaeAxillaryCount');
  late final GeneratedColumn<int> mammaeAxillaryCount = GeneratedColumn<int>(
      'mammaeAxillaryCount', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _mammaeAbdominalCountMeta =
      const VerificationMeta('mammaeAbdominalCount');
  late final GeneratedColumn<int> mammaeAbdominalCount = GeneratedColumn<int>(
      'mammaeAbdominalCount', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _vaginaOpeningMeta =
      const VerificationMeta('vaginaOpening');
  late final GeneratedColumn<int> vaginaOpening = GeneratedColumn<int>(
      'vaginaOpening', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _pubicSymphysisMeta =
      const VerificationMeta('pubicSymphysis');
  late final GeneratedColumn<int> pubicSymphysis = GeneratedColumn<int>(
      'pubicSymphysis', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _embryoLeftCountMeta =
      const VerificationMeta('embryoLeftCount');
  late final GeneratedColumn<int> embryoLeftCount = GeneratedColumn<int>(
      'embryoLeftCount', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _embryoRightCountMeta =
      const VerificationMeta('embryoRightCount');
  late final GeneratedColumn<int> embryoRightCount = GeneratedColumn<int>(
      'embryoRightCount', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _embryoCRMeta =
      const VerificationMeta('embryoCR');
  late final GeneratedColumn<int> embryoCR = GeneratedColumn<int>(
      'embryoCR', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
      'remark', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        specimenUuid,
        totalLength,
        tailLength,
        hindFootLength,
        earLength,
        forearm,
        weight,
        accuracy,
        accuracySpecify,
        sex,
        age,
        testisPosition,
        testisLength,
        testisWidth,
        epididymisAppearance,
        reproductiveStage,
        leftPlacentalScars,
        rightPlacentalScars,
        mammaeCondition,
        mammaeInguinalCount,
        mammaeAxillaryCount,
        mammaeAbdominalCount,
        vaginaOpening,
        pubicSymphysis,
        embryoLeftCount,
        embryoRightCount,
        embryoCR,
        remark
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mammalMeasurement';
  @override
  VerificationContext validateIntegrity(
      Insertable<MammalMeasurementData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('specimenUuid')) {
      context.handle(
          _specimenUuidMeta,
          specimenUuid.isAcceptableOrUnknown(
              data['specimenUuid']!, _specimenUuidMeta));
    } else if (isInserting) {
      context.missing(_specimenUuidMeta);
    }
    if (data.containsKey('totalLength')) {
      context.handle(
          _totalLengthMeta,
          totalLength.isAcceptableOrUnknown(
              data['totalLength']!, _totalLengthMeta));
    }
    if (data.containsKey('tailLength')) {
      context.handle(
          _tailLengthMeta,
          tailLength.isAcceptableOrUnknown(
              data['tailLength']!, _tailLengthMeta));
    }
    if (data.containsKey('hindFootLength')) {
      context.handle(
          _hindFootLengthMeta,
          hindFootLength.isAcceptableOrUnknown(
              data['hindFootLength']!, _hindFootLengthMeta));
    }
    if (data.containsKey('earLength')) {
      context.handle(_earLengthMeta,
          earLength.isAcceptableOrUnknown(data['earLength']!, _earLengthMeta));
    }
    if (data.containsKey('forearm')) {
      context.handle(_forearmMeta,
          forearm.isAcceptableOrUnknown(data['forearm']!, _forearmMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    }
    if (data.containsKey('accuracySpecify')) {
      context.handle(
          _accuracySpecifyMeta,
          accuracySpecify.isAcceptableOrUnknown(
              data['accuracySpecify']!, _accuracySpecifyMeta));
    }
    if (data.containsKey('sex')) {
      context.handle(
          _sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('testisPosition')) {
      context.handle(
          _testisPositionMeta,
          testisPosition.isAcceptableOrUnknown(
              data['testisPosition']!, _testisPositionMeta));
    }
    if (data.containsKey('testisLength')) {
      context.handle(
          _testisLengthMeta,
          testisLength.isAcceptableOrUnknown(
              data['testisLength']!, _testisLengthMeta));
    }
    if (data.containsKey('testisWidth')) {
      context.handle(
          _testisWidthMeta,
          testisWidth.isAcceptableOrUnknown(
              data['testisWidth']!, _testisWidthMeta));
    }
    if (data.containsKey('epididymisAppearance')) {
      context.handle(
          _epididymisAppearanceMeta,
          epididymisAppearance.isAcceptableOrUnknown(
              data['epididymisAppearance']!, _epididymisAppearanceMeta));
    }
    if (data.containsKey('reproductiveStage')) {
      context.handle(
          _reproductiveStageMeta,
          reproductiveStage.isAcceptableOrUnknown(
              data['reproductiveStage']!, _reproductiveStageMeta));
    }
    if (data.containsKey('leftPlacentalScars')) {
      context.handle(
          _leftPlacentalScarsMeta,
          leftPlacentalScars.isAcceptableOrUnknown(
              data['leftPlacentalScars']!, _leftPlacentalScarsMeta));
    }
    if (data.containsKey('rightPlacentalScars')) {
      context.handle(
          _rightPlacentalScarsMeta,
          rightPlacentalScars.isAcceptableOrUnknown(
              data['rightPlacentalScars']!, _rightPlacentalScarsMeta));
    }
    if (data.containsKey('mammaeCondition')) {
      context.handle(
          _mammaeConditionMeta,
          mammaeCondition.isAcceptableOrUnknown(
              data['mammaeCondition']!, _mammaeConditionMeta));
    }
    if (data.containsKey('mammaeInguinalCount')) {
      context.handle(
          _mammaeInguinalCountMeta,
          mammaeInguinalCount.isAcceptableOrUnknown(
              data['mammaeInguinalCount']!, _mammaeInguinalCountMeta));
    }
    if (data.containsKey('mammaeAxillaryCount')) {
      context.handle(
          _mammaeAxillaryCountMeta,
          mammaeAxillaryCount.isAcceptableOrUnknown(
              data['mammaeAxillaryCount']!, _mammaeAxillaryCountMeta));
    }
    if (data.containsKey('mammaeAbdominalCount')) {
      context.handle(
          _mammaeAbdominalCountMeta,
          mammaeAbdominalCount.isAcceptableOrUnknown(
              data['mammaeAbdominalCount']!, _mammaeAbdominalCountMeta));
    }
    if (data.containsKey('vaginaOpening')) {
      context.handle(
          _vaginaOpeningMeta,
          vaginaOpening.isAcceptableOrUnknown(
              data['vaginaOpening']!, _vaginaOpeningMeta));
    }
    if (data.containsKey('pubicSymphysis')) {
      context.handle(
          _pubicSymphysisMeta,
          pubicSymphysis.isAcceptableOrUnknown(
              data['pubicSymphysis']!, _pubicSymphysisMeta));
    }
    if (data.containsKey('embryoLeftCount')) {
      context.handle(
          _embryoLeftCountMeta,
          embryoLeftCount.isAcceptableOrUnknown(
              data['embryoLeftCount']!, _embryoLeftCountMeta));
    }
    if (data.containsKey('embryoRightCount')) {
      context.handle(
          _embryoRightCountMeta,
          embryoRightCount.isAcceptableOrUnknown(
              data['embryoRightCount']!, _embryoRightCountMeta));
    }
    if (data.containsKey('embryoCR')) {
      context.handle(_embryoCRMeta,
          embryoCR.isAcceptableOrUnknown(data['embryoCR']!, _embryoCRMeta));
    }
    if (data.containsKey('remark')) {
      context.handle(_remarkMeta,
          remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  MammalMeasurementData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MammalMeasurementData(
      specimenUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specimenUuid'])!,
      totalLength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}totalLength']),
      tailLength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tailLength']),
      hindFootLength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}hindFootLength']),
      earLength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}earLength']),
      forearm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}forearm']),
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight']),
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}accuracy']),
      accuracySpecify: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}accuracySpecify']),
      sex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sex']),
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age']),
      testisPosition: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}testisPosition']),
      testisLength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}testisLength']),
      testisWidth: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}testisWidth']),
      epididymisAppearance: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}epididymisAppearance']),
      reproductiveStage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reproductiveStage']),
      leftPlacentalScars: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}leftPlacentalScars']),
      rightPlacentalScars: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}rightPlacentalScars']),
      mammaeCondition: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mammaeCondition']),
      mammaeInguinalCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}mammaeInguinalCount']),
      mammaeAxillaryCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}mammaeAxillaryCount']),
      mammaeAbdominalCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}mammaeAbdominalCount']),
      vaginaOpening: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vaginaOpening']),
      pubicSymphysis: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pubicSymphysis']),
      embryoLeftCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}embryoLeftCount']),
      embryoRightCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}embryoRightCount']),
      embryoCR: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}embryoCR']),
      remark: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remark']),
    );
  }

  @override
  MammalMeasurement createAlias(String alias) {
    return MammalMeasurement(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['FOREIGN KEY(specimenUuid)REFERENCES specimen(uuid)'];
  @override
  bool get dontWriteConstraints => true;
}

class MammalMeasurementData extends DataClass
    implements Insertable<MammalMeasurementData> {
  final String specimenUuid;
  final double? totalLength;
  final double? tailLength;
  final double? hindFootLength;
  final double? earLength;
  final double? forearm;
  final double? weight;
  final String? accuracy;
  final String? accuracySpecify;
  final int? sex;
  final int? age;
  final int? testisPosition;

  /// encode using enum
  final double? testisLength;
  final double? testisWidth;
  final int? epididymisAppearance;
  final int? reproductiveStage;
  final int? leftPlacentalScars;
  final int? rightPlacentalScars;
  final int? mammaeCondition;
  final int? mammaeInguinalCount;
  final int? mammaeAxillaryCount;
  final int? mammaeAbdominalCount;
  final int? vaginaOpening;
  final int? pubicSymphysis;
  final int? embryoLeftCount;
  final int? embryoRightCount;
  final int? embryoCR;
  final String? remark;
  const MammalMeasurementData(
      {required this.specimenUuid,
      this.totalLength,
      this.tailLength,
      this.hindFootLength,
      this.earLength,
      this.forearm,
      this.weight,
      this.accuracy,
      this.accuracySpecify,
      this.sex,
      this.age,
      this.testisPosition,
      this.testisLength,
      this.testisWidth,
      this.epididymisAppearance,
      this.reproductiveStage,
      this.leftPlacentalScars,
      this.rightPlacentalScars,
      this.mammaeCondition,
      this.mammaeInguinalCount,
      this.mammaeAxillaryCount,
      this.mammaeAbdominalCount,
      this.vaginaOpening,
      this.pubicSymphysis,
      this.embryoLeftCount,
      this.embryoRightCount,
      this.embryoCR,
      this.remark});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['specimenUuid'] = Variable<String>(specimenUuid);
    if (!nullToAbsent || totalLength != null) {
      map['totalLength'] = Variable<double>(totalLength);
    }
    if (!nullToAbsent || tailLength != null) {
      map['tailLength'] = Variable<double>(tailLength);
    }
    if (!nullToAbsent || hindFootLength != null) {
      map['hindFootLength'] = Variable<double>(hindFootLength);
    }
    if (!nullToAbsent || earLength != null) {
      map['earLength'] = Variable<double>(earLength);
    }
    if (!nullToAbsent || forearm != null) {
      map['forearm'] = Variable<double>(forearm);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<String>(accuracy);
    }
    if (!nullToAbsent || accuracySpecify != null) {
      map['accuracySpecify'] = Variable<String>(accuracySpecify);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<int>(sex);
    }
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || testisPosition != null) {
      map['testisPosition'] = Variable<int>(testisPosition);
    }
    if (!nullToAbsent || testisLength != null) {
      map['testisLength'] = Variable<double>(testisLength);
    }
    if (!nullToAbsent || testisWidth != null) {
      map['testisWidth'] = Variable<double>(testisWidth);
    }
    if (!nullToAbsent || epididymisAppearance != null) {
      map['epididymisAppearance'] = Variable<int>(epididymisAppearance);
    }
    if (!nullToAbsent || reproductiveStage != null) {
      map['reproductiveStage'] = Variable<int>(reproductiveStage);
    }
    if (!nullToAbsent || leftPlacentalScars != null) {
      map['leftPlacentalScars'] = Variable<int>(leftPlacentalScars);
    }
    if (!nullToAbsent || rightPlacentalScars != null) {
      map['rightPlacentalScars'] = Variable<int>(rightPlacentalScars);
    }
    if (!nullToAbsent || mammaeCondition != null) {
      map['mammaeCondition'] = Variable<int>(mammaeCondition);
    }
    if (!nullToAbsent || mammaeInguinalCount != null) {
      map['mammaeInguinalCount'] = Variable<int>(mammaeInguinalCount);
    }
    if (!nullToAbsent || mammaeAxillaryCount != null) {
      map['mammaeAxillaryCount'] = Variable<int>(mammaeAxillaryCount);
    }
    if (!nullToAbsent || mammaeAbdominalCount != null) {
      map['mammaeAbdominalCount'] = Variable<int>(mammaeAbdominalCount);
    }
    if (!nullToAbsent || vaginaOpening != null) {
      map['vaginaOpening'] = Variable<int>(vaginaOpening);
    }
    if (!nullToAbsent || pubicSymphysis != null) {
      map['pubicSymphysis'] = Variable<int>(pubicSymphysis);
    }
    if (!nullToAbsent || embryoLeftCount != null) {
      map['embryoLeftCount'] = Variable<int>(embryoLeftCount);
    }
    if (!nullToAbsent || embryoRightCount != null) {
      map['embryoRightCount'] = Variable<int>(embryoRightCount);
    }
    if (!nullToAbsent || embryoCR != null) {
      map['embryoCR'] = Variable<int>(embryoCR);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  MammalMeasurementCompanion toCompanion(bool nullToAbsent) {
    return MammalMeasurementCompanion(
      specimenUuid: Value(specimenUuid),
      totalLength: totalLength == null && nullToAbsent
          ? const Value.absent()
          : Value(totalLength),
      tailLength: tailLength == null && nullToAbsent
          ? const Value.absent()
          : Value(tailLength),
      hindFootLength: hindFootLength == null && nullToAbsent
          ? const Value.absent()
          : Value(hindFootLength),
      earLength: earLength == null && nullToAbsent
          ? const Value.absent()
          : Value(earLength),
      forearm: forearm == null && nullToAbsent
          ? const Value.absent()
          : Value(forearm),
      weight:
          weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      accuracySpecify: accuracySpecify == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracySpecify),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      testisPosition: testisPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(testisPosition),
      testisLength: testisLength == null && nullToAbsent
          ? const Value.absent()
          : Value(testisLength),
      testisWidth: testisWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(testisWidth),
      epididymisAppearance: epididymisAppearance == null && nullToAbsent
          ? const Value.absent()
          : Value(epididymisAppearance),
      reproductiveStage: reproductiveStage == null && nullToAbsent
          ? const Value.absent()
          : Value(reproductiveStage),
      leftPlacentalScars: leftPlacentalScars == null && nullToAbsent
          ? const Value.absent()
          : Value(leftPlacentalScars),
      rightPlacentalScars: rightPlacentalScars == null && nullToAbsent
          ? const Value.absent()
          : Value(rightPlacentalScars),
      mammaeCondition: mammaeCondition == null && nullToAbsent
          ? const Value.absent()
          : Value(mammaeCondition),
      mammaeInguinalCount: mammaeInguinalCount == null && nullToAbsent
          ? const Value.absent()
          : Value(mammaeInguinalCount),
      mammaeAxillaryCount: mammaeAxillaryCount == null && nullToAbsent
          ? const Value.absent()
          : Value(mammaeAxillaryCount),
      mammaeAbdominalCount: mammaeAbdominalCount == null && nullToAbsent
          ? const Value.absent()
          : Value(mammaeAbdominalCount),
      vaginaOpening: vaginaOpening == null && nullToAbsent
          ? const Value.absent()
          : Value(vaginaOpening),
      pubicSymphysis: pubicSymphysis == null && nullToAbsent
          ? const Value.absent()
          : Value(pubicSymphysis),
      embryoLeftCount: embryoLeftCount == null && nullToAbsent
          ? const Value.absent()
          : Value(embryoLeftCount),
      embryoRightCount: embryoRightCount == null && nullToAbsent
          ? const Value.absent()
          : Value(embryoRightCount),
      embryoCR: embryoCR == null && nullToAbsent
          ? const Value.absent()
          : Value(embryoCR),
      remark:
          remark == null && nullToAbsent ? const Value.absent() : Value(remark),
    );
  }

  factory MammalMeasurementData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MammalMeasurementData(
      specimenUuid: serializer.fromJson<String>(json['specimenUuid']),
      totalLength: serializer.fromJson<double?>(json['totalLength']),
      tailLength: serializer.fromJson<double?>(json['tailLength']),
      hindFootLength: serializer.fromJson<double?>(json['hindFootLength']),
      earLength: serializer.fromJson<double?>(json['earLength']),
      forearm: serializer.fromJson<double?>(json['forearm']),
      weight: serializer.fromJson<double?>(json['weight']),
      accuracy: serializer.fromJson<String?>(json['accuracy']),
      accuracySpecify: serializer.fromJson<String?>(json['accuracySpecify']),
      sex: serializer.fromJson<int?>(json['sex']),
      age: serializer.fromJson<int?>(json['age']),
      testisPosition: serializer.fromJson<int?>(json['testisPosition']),
      testisLength: serializer.fromJson<double?>(json['testisLength']),
      testisWidth: serializer.fromJson<double?>(json['testisWidth']),
      epididymisAppearance:
          serializer.fromJson<int?>(json['epididymisAppearance']),
      reproductiveStage: serializer.fromJson<int?>(json['reproductiveStage']),
      leftPlacentalScars: serializer.fromJson<int?>(json['leftPlacentalScars']),
      rightPlacentalScars:
          serializer.fromJson<int?>(json['rightPlacentalScars']),
      mammaeCondition: serializer.fromJson<int?>(json['mammaeCondition']),
      mammaeInguinalCount:
          serializer.fromJson<int?>(json['mammaeInguinalCount']),
      mammaeAxillaryCount:
          serializer.fromJson<int?>(json['mammaeAxillaryCount']),
      mammaeAbdominalCount:
          serializer.fromJson<int?>(json['mammaeAbdominalCount']),
      vaginaOpening: serializer.fromJson<int?>(json['vaginaOpening']),
      pubicSymphysis: serializer.fromJson<int?>(json['pubicSymphysis']),
      embryoLeftCount: serializer.fromJson<int?>(json['embryoLeftCount']),
      embryoRightCount: serializer.fromJson<int?>(json['embryoRightCount']),
      embryoCR: serializer.fromJson<int?>(json['embryoCR']),
      remark: serializer.fromJson<String?>(json['remark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'specimenUuid': serializer.toJson<String>(specimenUuid),
      'totalLength': serializer.toJson<double?>(totalLength),
      'tailLength': serializer.toJson<double?>(tailLength),
      'hindFootLength': serializer.toJson<double?>(hindFootLength),
      'earLength': serializer.toJson<double?>(earLength),
      'forearm': serializer.toJson<double?>(forearm),
      'weight': serializer.toJson<double?>(weight),
      'accuracy': serializer.toJson<String?>(accuracy),
      'accuracySpecify': serializer.toJson<String?>(accuracySpecify),
      'sex': serializer.toJson<int?>(sex),
      'age': serializer.toJson<int?>(age),
      'testisPosition': serializer.toJson<int?>(testisPosition),
      'testisLength': serializer.toJson<double?>(testisLength),
      'testisWidth': serializer.toJson<double?>(testisWidth),
      'epididymisAppearance': serializer.toJson<int?>(epididymisAppearance),
      'reproductiveStage': serializer.toJson<int?>(reproductiveStage),
      'leftPlacentalScars': serializer.toJson<int?>(leftPlacentalScars),
      'rightPlacentalScars': serializer.toJson<int?>(rightPlacentalScars),
      'mammaeCondition': serializer.toJson<int?>(mammaeCondition),
      'mammaeInguinalCount': serializer.toJson<int?>(mammaeInguinalCount),
      'mammaeAxillaryCount': serializer.toJson<int?>(mammaeAxillaryCount),
      'mammaeAbdominalCount': serializer.toJson<int?>(mammaeAbdominalCount),
      'vaginaOpening': serializer.toJson<int?>(vaginaOpening),
      'pubicSymphysis': serializer.toJson<int?>(pubicSymphysis),
      'embryoLeftCount': serializer.toJson<int?>(embryoLeftCount),
      'embryoRightCount': serializer.toJson<int?>(embryoRightCount),
      'embryoCR': serializer.toJson<int?>(embryoCR),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  MammalMeasurementData copyWith(
          {String? specimenUuid,
          Value<double?> totalLength = const Value.absent(),
          Value<double?> tailLength = const Value.absent(),
          Value<double?> hindFootLength = const Value.absent(),
          Value<double?> earLength = const Value.absent(),
          Value<double?> forearm = const Value.absent(),
          Value<double?> weight = const Value.absent(),
          Value<String?> accuracy = const Value.absent(),
          Value<String?> accuracySpecify = const Value.absent(),
          Value<int?> sex = const Value.absent(),
          Value<int?> age = const Value.absent(),
          Value<int?> testisPosition = const Value.absent(),
          Value<double?> testisLength = const Value.absent(),
          Value<double?> testisWidth = const Value.absent(),
          Value<int?> epididymisAppearance = const Value.absent(),
          Value<int?> reproductiveStage = const Value.absent(),
          Value<int?> leftPlacentalScars = const Value.absent(),
          Value<int?> rightPlacentalScars = const Value.absent(),
          Value<int?> mammaeCondition = const Value.absent(),
          Value<int?> mammaeInguinalCount = const Value.absent(),
          Value<int?> mammaeAxillaryCount = const Value.absent(),
          Value<int?> mammaeAbdominalCount = const Value.absent(),
          Value<int?> vaginaOpening = const Value.absent(),
          Value<int?> pubicSymphysis = const Value.absent(),
          Value<int?> embryoLeftCount = const Value.absent(),
          Value<int?> embryoRightCount = const Value.absent(),
          Value<int?> embryoCR = const Value.absent(),
          Value<String?> remark = const Value.absent()}) =>
      MammalMeasurementData(
        specimenUuid: specimenUuid ?? this.specimenUuid,
        totalLength: totalLength.present ? totalLength.value : this.totalLength,
        tailLength: tailLength.present ? tailLength.value : this.tailLength,
        hindFootLength:
            hindFootLength.present ? hindFootLength.value : this.hindFootLength,
        earLength: earLength.present ? earLength.value : this.earLength,
        forearm: forearm.present ? forearm.value : this.forearm,
        weight: weight.present ? weight.value : this.weight,
        accuracy: accuracy.present ? accuracy.value : this.accuracy,
        accuracySpecify: accuracySpecify.present
            ? accuracySpecify.value
            : this.accuracySpecify,
        sex: sex.present ? sex.value : this.sex,
        age: age.present ? age.value : this.age,
        testisPosition:
            testisPosition.present ? testisPosition.value : this.testisPosition,
        testisLength:
            testisLength.present ? testisLength.value : this.testisLength,
        testisWidth: testisWidth.present ? testisWidth.value : this.testisWidth,
        epididymisAppearance: epididymisAppearance.present
            ? epididymisAppearance.value
            : this.epididymisAppearance,
        reproductiveStage: reproductiveStage.present
            ? reproductiveStage.value
            : this.reproductiveStage,
        leftPlacentalScars: leftPlacentalScars.present
            ? leftPlacentalScars.value
            : this.leftPlacentalScars,
        rightPlacentalScars: rightPlacentalScars.present
            ? rightPlacentalScars.value
            : this.rightPlacentalScars,
        mammaeCondition: mammaeCondition.present
            ? mammaeCondition.value
            : this.mammaeCondition,
        mammaeInguinalCount: mammaeInguinalCount.present
            ? mammaeInguinalCount.value
            : this.mammaeInguinalCount,
        mammaeAxillaryCount: mammaeAxillaryCount.present
            ? mammaeAxillaryCount.value
            : this.mammaeAxillaryCount,
        mammaeAbdominalCount: mammaeAbdominalCount.present
            ? mammaeAbdominalCount.value
            : this.mammaeAbdominalCount,
        vaginaOpening:
            vaginaOpening.present ? vaginaOpening.value : this.vaginaOpening,
        pubicSymphysis:
            pubicSymphysis.present ? pubicSymphysis.value : this.pubicSymphysis,
        embryoLeftCount: embryoLeftCount.present
            ? embryoLeftCount.value
            : this.embryoLeftCount,
        embryoRightCount: embryoRightCount.present
            ? embryoRightCount.value
            : this.embryoRightCount,
        embryoCR: embryoCR.present ? embryoCR.value : this.embryoCR,
        remark: remark.present ? remark.value : this.remark,
      );
  MammalMeasurementData copyWithCompanion(MammalMeasurementCompanion data) {
    return MammalMeasurementData(
      specimenUuid: data.specimenUuid.present
          ? data.specimenUuid.value
          : this.specimenUuid,
      totalLength:
          data.totalLength.present ? data.totalLength.value : this.totalLength,
      tailLength:
          data.tailLength.present ? data.tailLength.value : this.tailLength,
      hindFootLength: data.hindFootLength.present
          ? data.hindFootLength.value
          : this.hindFootLength,
      earLength: data.earLength.present ? data.earLength.value : this.earLength,
      forearm: data.forearm.present ? data.forearm.value : this.forearm,
      weight: data.weight.present ? data.weight.value : this.weight,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      accuracySpecify: data.accuracySpecify.present
          ? data.accuracySpecify.value
          : this.accuracySpecify,
      sex: data.sex.present ? data.sex.value : this.sex,
      age: data.age.present ? data.age.value : this.age,
      testisPosition: data.testisPosition.present
          ? data.testisPosition.value
          : this.testisPosition,
      testisLength: data.testisLength.present
          ? data.testisLength.value
          : this.testisLength,
      testisWidth:
          data.testisWidth.present ? data.testisWidth.value : this.testisWidth,
      epididymisAppearance: data.epididymisAppearance.present
          ? data.epididymisAppearance.value
          : this.epididymisAppearance,
      reproductiveStage: data.reproductiveStage.present
          ? data.reproductiveStage.value
          : this.reproductiveStage,
      leftPlacentalScars: data.leftPlacentalScars.present
          ? data.leftPlacentalScars.value
          : this.leftPlacentalScars,
      rightPlacentalScars: data.rightPlacentalScars.present
          ? data.rightPlacentalScars.value
          : this.rightPlacentalScars,
      mammaeCondition: data.mammaeCondition.present
          ? data.mammaeCondition.value
          : this.mammaeCondition,
      mammaeInguinalCount: data.mammaeInguinalCount.present
          ? data.mammaeInguinalCount.value
          : this.mammaeInguinalCount,
      mammaeAxillaryCount: data.mammaeAxillaryCount.present
          ? data.mammaeAxillaryCount.value
          : this.mammaeAxillaryCount,
      mammaeAbdominalCount: data.mammaeAbdominalCount.present
          ? data.mammaeAbdominalCount.value
          : this.mammaeAbdominalCount,
      vaginaOpening: data.vaginaOpening.present
          ? data.vaginaOpening.value
          : this.vaginaOpening,
      pubicSymphysis: data.pubicSymphysis.present
          ? data.pubicSymphysis.value
          : this.pubicSymphysis,
      embryoLeftCount: data.embryoLeftCount.present
          ? data.embryoLeftCount.value
          : this.embryoLeftCount,
      embryoRightCount: data.embryoRightCount.present
          ? data.embryoRightCount.value
          : this.embryoRightCount,
      embryoCR: data.embryoCR.present ? data.embryoCR.value : this.embryoCR,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MammalMeasurementData(')
          ..write('specimenUuid: $specimenUuid, ')
          ..write('totalLength: $totalLength, ')
          ..write('tailLength: $tailLength, ')
          ..write('hindFootLength: $hindFootLength, ')
          ..write('earLength: $earLength, ')
          ..write('forearm: $forearm, ')
          ..write('weight: $weight, ')
          ..write('accuracy: $accuracy, ')
          ..write('accuracySpecify: $accuracySpecify, ')
          ..write('sex: $sex, ')
          ..write('age: $age, ')
          ..write('testisPosition: $testisPosition, ')
          ..write('testisLength: $testisLength, ')
          ..write('testisWidth: $testisWidth, ')
          ..write('epididymisAppearance: $epididymisAppearance, ')
          ..write('reproductiveStage: $reproductiveStage, ')
          ..write('leftPlacentalScars: $leftPlacentalScars, ')
          ..write('rightPlacentalScars: $rightPlacentalScars, ')
          ..write('mammaeCondition: $mammaeCondition, ')
          ..write('mammaeInguinalCount: $mammaeInguinalCount, ')
          ..write('mammaeAxillaryCount: $mammaeAxillaryCount, ')
          ..write('mammaeAbdominalCount: $mammaeAbdominalCount, ')
          ..write('vaginaOpening: $vaginaOpening, ')
          ..write('pubicSymphysis: $pubicSymphysis, ')
          ..write('embryoLeftCount: $embryoLeftCount, ')
          ..write('embryoRightCount: $embryoRightCount, ')
          ..write('embryoCR: $embryoCR, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        specimenUuid,
        totalLength,
        tailLength,
        hindFootLength,
        earLength,
        forearm,
        weight,
        accuracy,
        accuracySpecify,
        sex,
        age,
        testisPosition,
        testisLength,
        testisWidth,
        epididymisAppearance,
        reproductiveStage,
        leftPlacentalScars,
        rightPlacentalScars,
        mammaeCondition,
        mammaeInguinalCount,
        mammaeAxillaryCount,
        mammaeAbdominalCount,
        vaginaOpening,
        pubicSymphysis,
        embryoLeftCount,
        embryoRightCount,
        embryoCR,
        remark
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MammalMeasurementData &&
          other.specimenUuid == this.specimenUuid &&
          other.totalLength == this.totalLength &&
          other.tailLength == this.tailLength &&
          other.hindFootLength == this.hindFootLength &&
          other.earLength == this.earLength &&
          other.forearm == this.forearm &&
          other.weight == this.weight &&
          other.accuracy == this.accuracy &&
          other.accuracySpecify == this.accuracySpecify &&
          other.sex == this.sex &&
          other.age == this.age &&
          other.testisPosition == this.testisPosition &&
          other.testisLength == this.testisLength &&
          other.testisWidth == this.testisWidth &&
          other.epididymisAppearance == this.epididymisAppearance &&
          other.reproductiveStage == this.reproductiveStage &&
          other.leftPlacentalScars == this.leftPlacentalScars &&
          other.rightPlacentalScars == this.rightPlacentalScars &&
          other.mammaeCondition == this.mammaeCondition &&
          other.mammaeInguinalCount == this.mammaeInguinalCount &&
          other.mammaeAxillaryCount == this.mammaeAxillaryCount &&
          other.mammaeAbdominalCount == this.mammaeAbdominalCount &&
          other.vaginaOpening == this.vaginaOpening &&
          other.pubicSymphysis == this.pubicSymphysis &&
          other.embryoLeftCount == this.embryoLeftCount &&
          other.embryoRightCount == this.embryoRightCount &&
          other.embryoCR == this.embryoCR &&
          other.remark == this.remark);
}

class MammalMeasurementCompanion
    extends UpdateCompanion<MammalMeasurementData> {
  final Value<String> specimenUuid;
  final Value<double?> totalLength;
  final Value<double?> tailLength;
  final Value<double?> hindFootLength;
  final Value<double?> earLength;
  final Value<double?> forearm;
  final Value<double?> weight;
  final Value<String?> accuracy;
  final Value<String?> accuracySpecify;
  final Value<int?> sex;
  final Value<int?> age;
  final Value<int?> testisPosition;
  final Value<double?> testisLength;
  final Value<double?> testisWidth;
  final Value<int?> epididymisAppearance;
  final Value<int?> reproductiveStage;
  final Value<int?> leftPlacentalScars;
  final Value<int?> rightPlacentalScars;
  final Value<int?> mammaeCondition;
  final Value<int?> mammaeInguinalCount;
  final Value<int?> mammaeAxillaryCount;
  final Value<int?> mammaeAbdominalCount;
  final Value<int?> vaginaOpening;
  final Value<int?> pubicSymphysis;
  final Value<int?> embryoLeftCount;
  final Value<int?> embryoRightCount;
  final Value<int?> embryoCR;
  final Value<String?> remark;
  final Value<int> rowid;
  const MammalMeasurementCompanion({
    this.specimenUuid = const Value.absent(),
    this.totalLength = const Value.absent(),
    this.tailLength = const Value.absent(),
    this.hindFootLength = const Value.absent(),
    this.earLength = const Value.absent(),
    this.forearm = const Value.absent(),
    this.weight = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.accuracySpecify = const Value.absent(),
    this.sex = const Value.absent(),
    this.age = const Value.absent(),
    this.testisPosition = const Value.absent(),
    this.testisLength = const Value.absent(),
    this.testisWidth = const Value.absent(),
    this.epididymisAppearance = const Value.absent(),
    this.reproductiveStage = const Value.absent(),
    this.leftPlacentalScars = const Value.absent(),
    this.rightPlacentalScars = const Value.absent(),
    this.mammaeCondition = const Value.absent(),
    this.mammaeInguinalCount = const Value.absent(),
    this.mammaeAxillaryCount = const Value.absent(),
    this.mammaeAbdominalCount = const Value.absent(),
    this.vaginaOpening = const Value.absent(),
    this.pubicSymphysis = const Value.absent(),
    this.embryoLeftCount = const Value.absent(),
    this.embryoRightCount = const Value.absent(),
    this.embryoCR = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MammalMeasurementCompanion.insert({
    required String specimenUuid,
    this.totalLength = const Value.absent(),
    this.tailLength = const Value.absent(),
    this.hindFootLength = const Value.absent(),
    this.earLength = const Value.absent(),
    this.forearm = const Value.absent(),
    this.weight = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.accuracySpecify = const Value.absent(),
    this.sex = const Value.absent(),
    this.age = const Value.absent(),
    this.testisPosition = const Value.absent(),
    this.testisLength = const Value.absent(),
    this.testisWidth = const Value.absent(),
    this.epididymisAppearance = const Value.absent(),
    this.reproductiveStage = const Value.absent(),
    this.leftPlacentalScars = const Value.absent(),
    this.rightPlacentalScars = const Value.absent(),
    this.mammaeCondition = const Value.absent(),
    this.mammaeInguinalCount = const Value.absent(),
    this.mammaeAxillaryCount = const Value.absent(),
    this.mammaeAbdominalCount = const Value.absent(),
    this.vaginaOpening = const Value.absent(),
    this.pubicSymphysis = const Value.absent(),
    this.embryoLeftCount = const Value.absent(),
    this.embryoRightCount = const Value.absent(),
    this.embryoCR = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : specimenUuid = Value(specimenUuid);
  static Insertable<MammalMeasurementData> custom({
    Expression<String>? specimenUuid,
    Expression<double>? totalLength,
    Expression<double>? tailLength,
    Expression<double>? hindFootLength,
    Expression<double>? earLength,
    Expression<double>? forearm,
    Expression<double>? weight,
    Expression<String>? accuracy,
    Expression<String>? accuracySpecify,
    Expression<int>? sex,
    Expression<int>? age,
    Expression<int>? testisPosition,
    Expression<double>? testisLength,
    Expression<double>? testisWidth,
    Expression<int>? epididymisAppearance,
    Expression<int>? reproductiveStage,
    Expression<int>? leftPlacentalScars,
    Expression<int>? rightPlacentalScars,
    Expression<int>? mammaeCondition,
    Expression<int>? mammaeInguinalCount,
    Expression<int>? mammaeAxillaryCount,
    Expression<int>? mammaeAbdominalCount,
    Expression<int>? vaginaOpening,
    Expression<int>? pubicSymphysis,
    Expression<int>? embryoLeftCount,
    Expression<int>? embryoRightCount,
    Expression<int>? embryoCR,
    Expression<String>? remark,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (specimenUuid != null) 'specimenUuid': specimenUuid,
      if (totalLength != null) 'totalLength': totalLength,
      if (tailLength != null) 'tailLength': tailLength,
      if (hindFootLength != null) 'hindFootLength': hindFootLength,
      if (earLength != null) 'earLength': earLength,
      if (forearm != null) 'forearm': forearm,
      if (weight != null) 'weight': weight,
      if (accuracy != null) 'accuracy': accuracy,
      if (accuracySpecify != null) 'accuracySpecify': accuracySpecify,
      if (sex != null) 'sex': sex,
      if (age != null) 'age': age,
      if (testisPosition != null) 'testisPosition': testisPosition,
      if (testisLength != null) 'testisLength': testisLength,
      if (testisWidth != null) 'testisWidth': testisWidth,
      if (epididymisAppearance != null)
        'epididymisAppearance': epididymisAppearance,
      if (reproductiveStage != null) 'reproductiveStage': reproductiveStage,
      if (leftPlacentalScars != null) 'leftPlacentalScars': leftPlacentalScars,
      if (rightPlacentalScars != null)
        'rightPlacentalScars': rightPlacentalScars,
      if (mammaeCondition != null) 'mammaeCondition': mammaeCondition,
      if (mammaeInguinalCount != null)
        'mammaeInguinalCount': mammaeInguinalCount,
      if (mammaeAxillaryCount != null)
        'mammaeAxillaryCount': mammaeAxillaryCount,
      if (mammaeAbdominalCount != null)
        'mammaeAbdominalCount': mammaeAbdominalCount,
      if (vaginaOpening != null) 'vaginaOpening': vaginaOpening,
      if (pubicSymphysis != null) 'pubicSymphysis': pubicSymphysis,
      if (embryoLeftCount != null) 'embryoLeftCount': embryoLeftCount,
      if (embryoRightCount != null) 'embryoRightCount': embryoRightCount,
      if (embryoCR != null) 'embryoCR': embryoCR,
      if (remark != null) 'remark': remark,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MammalMeasurementCompanion copyWith(
      {Value<String>? specimenUuid,
      Value<double?>? totalLength,
      Value<double?>? tailLength,
      Value<double?>? hindFootLength,
      Value<double?>? earLength,
      Value<double?>? forearm,
      Value<double?>? weight,
      Value<String?>? accuracy,
      Value<String?>? accuracySpecify,
      Value<int?>? sex,
      Value<int?>? age,
      Value<int?>? testisPosition,
      Value<double?>? testisLength,
      Value<double?>? testisWidth,
      Value<int?>? epididymisAppearance,
      Value<int?>? reproductiveStage,
      Value<int?>? leftPlacentalScars,
      Value<int?>? rightPlacentalScars,
      Value<int?>? mammaeCondition,
      Value<int?>? mammaeInguinalCount,
      Value<int?>? mammaeAxillaryCount,
      Value<int?>? mammaeAbdominalCount,
      Value<int?>? vaginaOpening,
      Value<int?>? pubicSymphysis,
      Value<int?>? embryoLeftCount,
      Value<int?>? embryoRightCount,
      Value<int?>? embryoCR,
      Value<String?>? remark,
      Value<int>? rowid}) {
    return MammalMeasurementCompanion(
      specimenUuid: specimenUuid ?? this.specimenUuid,
      totalLength: totalLength ?? this.totalLength,
      tailLength: tailLength ?? this.tailLength,
      hindFootLength: hindFootLength ?? this.hindFootLength,
      earLength: earLength ?? this.earLength,
      forearm: forearm ?? this.forearm,
      weight: weight ?? this.weight,
      accuracy: accuracy ?? this.accuracy,
      accuracySpecify: accuracySpecify ?? this.accuracySpecify,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      testisPosition: testisPosition ?? this.testisPosition,
      testisLength: testisLength ?? this.testisLength,
      testisWidth: testisWidth ?? this.testisWidth,
      epididymisAppearance: epididymisAppearance ?? this.epididymisAppearance,
      reproductiveStage: reproductiveStage ?? this.reproductiveStage,
      leftPlacentalScars: leftPlacentalScars ?? this.leftPlacentalScars,
      rightPlacentalScars: rightPlacentalScars ?? this.rightPlacentalScars,
      mammaeCondition: mammaeCondition ?? this.mammaeCondition,
      mammaeInguinalCount: mammaeInguinalCount ?? this.mammaeInguinalCount,
      mammaeAxillaryCount: mammaeAxillaryCount ?? this.mammaeAxillaryCount,
      mammaeAbdominalCount: mammaeAbdominalCount ?? this.mammaeAbdominalCount,
      vaginaOpening: vaginaOpening ?? this.vaginaOpening,
      pubicSymphysis: pubicSymphysis ?? this.pubicSymphysis,
      embryoLeftCount: embryoLeftCount ?? this.embryoLeftCount,
      embryoRightCount: embryoRightCount ?? this.embryoRightCount,
      embryoCR: embryoCR ?? this.embryoCR,
      remark: remark ?? this.remark,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (specimenUuid.present) {
      map['specimenUuid'] = Variable<String>(specimenUuid.value);
    }
    if (totalLength.present) {
      map['totalLength'] = Variable<double>(totalLength.value);
    }
    if (tailLength.present) {
      map['tailLength'] = Variable<double>(tailLength.value);
    }
    if (hindFootLength.present) {
      map['hindFootLength'] = Variable<double>(hindFootLength.value);
    }
    if (earLength.present) {
      map['earLength'] = Variable<double>(earLength.value);
    }
    if (forearm.present) {
      map['forearm'] = Variable<double>(forearm.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<String>(accuracy.value);
    }
    if (accuracySpecify.present) {
      map['accuracySpecify'] = Variable<String>(accuracySpecify.value);
    }
    if (sex.present) {
      map['sex'] = Variable<int>(sex.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (testisPosition.present) {
      map['testisPosition'] = Variable<int>(testisPosition.value);
    }
    if (testisLength.present) {
      map['testisLength'] = Variable<double>(testisLength.value);
    }
    if (testisWidth.present) {
      map['testisWidth'] = Variable<double>(testisWidth.value);
    }
    if (epididymisAppearance.present) {
      map['epididymisAppearance'] = Variable<int>(epididymisAppearance.value);
    }
    if (reproductiveStage.present) {
      map['reproductiveStage'] = Variable<int>(reproductiveStage.value);
    }
    if (leftPlacentalScars.present) {
      map['leftPlacentalScars'] = Variable<int>(leftPlacentalScars.value);
    }
    if (rightPlacentalScars.present) {
      map['rightPlacentalScars'] = Variable<int>(rightPlacentalScars.value);
    }
    if (mammaeCondition.present) {
      map['mammaeCondition'] = Variable<int>(mammaeCondition.value);
    }
    if (mammaeInguinalCount.present) {
      map['mammaeInguinalCount'] = Variable<int>(mammaeInguinalCount.value);
    }
    if (mammaeAxillaryCount.present) {
      map['mammaeAxillaryCount'] = Variable<int>(mammaeAxillaryCount.value);
    }
    if (mammaeAbdominalCount.present) {
      map['mammaeAbdominalCount'] = Variable<int>(mammaeAbdominalCount.value);
    }
    if (vaginaOpening.present) {
      map['vaginaOpening'] = Variable<int>(vaginaOpening.value);
    }
    if (pubicSymphysis.present) {
      map['pubicSymphysis'] = Variable<int>(pubicSymphysis.value);
    }
    if (embryoLeftCount.present) {
      map['embryoLeftCount'] = Variable<int>(embryoLeftCount.value);
    }
    if (embryoRightCount.present) {
      map['embryoRightCount'] = Variable<int>(embryoRightCount.value);
    }
    if (embryoCR.present) {
      map['embryoCR'] = Variable<int>(embryoCR.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MammalMeasurementCompanion(')
          ..write('specimenUuid: $specimenUuid, ')
          ..write('totalLength: $totalLength, ')
          ..write('tailLength: $tailLength, ')
          ..write('hindFootLength: $hindFootLength, ')
          ..write('earLength: $earLength, ')
          ..write('forearm: $forearm, ')
          ..write('weight: $weight, ')
          ..write('accuracy: $accuracy, ')
          ..write('accuracySpecify: $accuracySpecify, ')
          ..write('sex: $sex, ')
          ..write('age: $age, ')
          ..write('testisPosition: $testisPosition, ')
          ..write('testisLength: $testisLength, ')
          ..write('testisWidth: $testisWidth, ')
          ..write('epididymisAppearance: $epididymisAppearance, ')
          ..write('reproductiveStage: $reproductiveStage, ')
          ..write('leftPlacentalScars: $leftPlacentalScars, ')
          ..write('rightPlacentalScars: $rightPlacentalScars, ')
          ..write('mammaeCondition: $mammaeCondition, ')
          ..write('mammaeInguinalCount: $mammaeInguinalCount, ')
          ..write('mammaeAxillaryCount: $mammaeAxillaryCount, ')
          ..write('mammaeAbdominalCount: $mammaeAbdominalCount, ')
          ..write('vaginaOpening: $vaginaOpening, ')
          ..write('pubicSymphysis: $pubicSymphysis, ')
          ..write('embryoLeftCount: $embryoLeftCount, ')
          ..write('embryoRightCount: $embryoRightCount, ')
          ..write('embryoCR: $embryoCR, ')
          ..write('remark: $remark, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AvianMeasurement extends Table
    with TableInfo<AvianMeasurement, AvianMeasurementData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AvianMeasurement(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _specimenUuidMeta =
      const VerificationMeta('specimenUuid');
  late final GeneratedColumn<String> specimenUuid = GeneratedColumn<String>(
      'specimenUuid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _wingspanMeta =
      const VerificationMeta('wingspan');
  late final GeneratedColumn<double> wingspan = GeneratedColumn<double>(
      'wingspan', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _irisColorMeta =
      const VerificationMeta('irisColor');
  late final GeneratedColumn<String> irisColor = GeneratedColumn<String>(
      'irisColor', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _irisHexMeta =
      const VerificationMeta('irisHex');
  late final GeneratedColumn<String> irisHex = GeneratedColumn<String>(
      'irisHex', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _billColorMeta =
      const VerificationMeta('billColor');
  late final GeneratedColumn<String> billColor = GeneratedColumn<String>(
      'billColor', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _billHexMeta =
      const VerificationMeta('billHex');
  late final GeneratedColumn<String> billHex = GeneratedColumn<String>(
      'billHex', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _footColorMeta =
      const VerificationMeta('footColor');
  late final GeneratedColumn<String> footColor = GeneratedColumn<String>(
      'footColor', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _footHexMeta =
      const VerificationMeta('footHex');
  late final GeneratedColumn<String> footHex = GeneratedColumn<String>(
      'footHex', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _tarsusColorMeta =
      const VerificationMeta('tarsusColor');
  late final GeneratedColumn<String> tarsusColor = GeneratedColumn<String>(
      'tarsusColor', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _tarsusHexMeta =
      const VerificationMeta('tarsusHex');
  late final GeneratedColumn<String> tarsusHex = GeneratedColumn<String>(
      'tarsusHex', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  late final GeneratedColumn<int> sex = GeneratedColumn<int>(
      'sex', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _broodPatchMeta =
      const VerificationMeta('broodPatch');
  late final GeneratedColumn<int> broodPatch = GeneratedColumn<int>(
      'broodPatch', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _skullOssificationMeta =
      const VerificationMeta('skullOssification');
  late final GeneratedColumn<int> skullOssification = GeneratedColumn<int>(
      'skullOssification', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _hasBursaMeta =
      const VerificationMeta('hasBursa');
  late final GeneratedColumn<int> hasBursa = GeneratedColumn<int>(
      'hasBursa', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _bursaWidthMeta =
      const VerificationMeta('bursaWidth');
  late final GeneratedColumn<double> bursaWidth = GeneratedColumn<double>(
      'bursaWidth', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _bursaLengthMeta =
      const VerificationMeta('bursaLength');
  late final GeneratedColumn<double> bursaLength = GeneratedColumn<double>(
      'bursaLength', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  late final GeneratedColumn<int> fat = GeneratedColumn<int>(
      'fat', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _stomachContentMeta =
      const VerificationMeta('stomachContent');
  late final GeneratedColumn<String> stomachContent = GeneratedColumn<String>(
      'stomachContent', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _testisLengthMeta =
      const VerificationMeta('testisLength');
  late final GeneratedColumn<double> testisLength = GeneratedColumn<double>(
      'testisLength', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _testisWidthMeta =
      const VerificationMeta('testisWidth');
  late final GeneratedColumn<double> testisWidth = GeneratedColumn<double>(
      'testisWidth', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _testisRemarkMeta =
      const VerificationMeta('testisRemark');
  late final GeneratedColumn<String> testisRemark = GeneratedColumn<String>(
      'testisRemark', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _ovaryLengthMeta =
      const VerificationMeta('ovaryLength');
  late final GeneratedColumn<double> ovaryLength = GeneratedColumn<double>(
      'ovaryLength', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _ovaryWidthMeta =
      const VerificationMeta('ovaryWidth');
  late final GeneratedColumn<double> ovaryWidth = GeneratedColumn<double>(
      'ovaryWidth', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _oviductWidthMeta =
      const VerificationMeta('oviductWidth');
  late final GeneratedColumn<double> oviductWidth = GeneratedColumn<double>(
      'oviductWidth', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _ovaryAppearanceMeta =
      const VerificationMeta('ovaryAppearance');
  late final GeneratedColumn<int> ovaryAppearance = GeneratedColumn<int>(
      'ovaryAppearance', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _firstOvaSizeMeta =
      const VerificationMeta('firstOvaSize');
  late final GeneratedColumn<double> firstOvaSize = GeneratedColumn<double>(
      'firstOvaSize', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _secondOvaSizeMeta =
      const VerificationMeta('secondOvaSize');
  late final GeneratedColumn<double> secondOvaSize = GeneratedColumn<double>(
      'secondOvaSize', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _thirdOvaSizeMeta =
      const VerificationMeta('thirdOvaSize');
  late final GeneratedColumn<double> thirdOvaSize = GeneratedColumn<double>(
      'thirdOvaSize', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _oviductAppearanceMeta =
      const VerificationMeta('oviductAppearance');
  late final GeneratedColumn<int> oviductAppearance = GeneratedColumn<int>(
      'oviductAppearance', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _ovaryRemarkMeta =
      const VerificationMeta('ovaryRemark');
  late final GeneratedColumn<String> ovaryRemark = GeneratedColumn<String>(
      'ovaryRemark', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _wingIsMoltMeta =
      const VerificationMeta('wingIsMolt');
  late final GeneratedColumn<int> wingIsMolt = GeneratedColumn<int>(
      'wingIsMolt', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _wingMoltMeta =
      const VerificationMeta('wingMolt');
  late final GeneratedColumn<String> wingMolt = GeneratedColumn<String>(
      'wingMolt', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _tailIsMoltMeta =
      const VerificationMeta('tailIsMolt');
  late final GeneratedColumn<int> tailIsMolt = GeneratedColumn<int>(
      'tailIsMolt', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _tailMoltMeta =
      const VerificationMeta('tailMolt');
  late final GeneratedColumn<String> tailMolt = GeneratedColumn<String>(
      'tailMolt', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _bodyMoltMeta =
      const VerificationMeta('bodyMolt');
  late final GeneratedColumn<int> bodyMolt = GeneratedColumn<int>(
      'bodyMolt', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _moltRemarkMeta =
      const VerificationMeta('moltRemark');
  late final GeneratedColumn<String> moltRemark = GeneratedColumn<String>(
      'moltRemark', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _specimenRemarkMeta =
      const VerificationMeta('specimenRemark');
  late final GeneratedColumn<String> specimenRemark = GeneratedColumn<String>(
      'specimenRemark', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _habitatRemarkMeta =
      const VerificationMeta('habitatRemark');
  late final GeneratedColumn<String> habitatRemark = GeneratedColumn<String>(
      'habitatRemark', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        specimenUuid,
        weight,
        wingspan,
        irisColor,
        irisHex,
        billColor,
        billHex,
        footColor,
        footHex,
        tarsusColor,
        tarsusHex,
        sex,
        broodPatch,
        skullOssification,
        hasBursa,
        bursaWidth,
        bursaLength,
        fat,
        stomachContent,
        testisLength,
        testisWidth,
        testisRemark,
        ovaryLength,
        ovaryWidth,
        oviductWidth,
        ovaryAppearance,
        firstOvaSize,
        secondOvaSize,
        thirdOvaSize,
        oviductAppearance,
        ovaryRemark,
        wingIsMolt,
        wingMolt,
        tailIsMolt,
        tailMolt,
        bodyMolt,
        moltRemark,
        specimenRemark,
        habitatRemark
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'avianMeasurement';
  @override
  VerificationContext validateIntegrity(
      Insertable<AvianMeasurementData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('specimenUuid')) {
      context.handle(
          _specimenUuidMeta,
          specimenUuid.isAcceptableOrUnknown(
              data['specimenUuid']!, _specimenUuidMeta));
    } else if (isInserting) {
      context.missing(_specimenUuidMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('wingspan')) {
      context.handle(_wingspanMeta,
          wingspan.isAcceptableOrUnknown(data['wingspan']!, _wingspanMeta));
    }
    if (data.containsKey('irisColor')) {
      context.handle(_irisColorMeta,
          irisColor.isAcceptableOrUnknown(data['irisColor']!, _irisColorMeta));
    }
    if (data.containsKey('irisHex')) {
      context.handle(_irisHexMeta,
          irisHex.isAcceptableOrUnknown(data['irisHex']!, _irisHexMeta));
    }
    if (data.containsKey('billColor')) {
      context.handle(_billColorMeta,
          billColor.isAcceptableOrUnknown(data['billColor']!, _billColorMeta));
    }
    if (data.containsKey('billHex')) {
      context.handle(_billHexMeta,
          billHex.isAcceptableOrUnknown(data['billHex']!, _billHexMeta));
    }
    if (data.containsKey('footColor')) {
      context.handle(_footColorMeta,
          footColor.isAcceptableOrUnknown(data['footColor']!, _footColorMeta));
    }
    if (data.containsKey('footHex')) {
      context.handle(_footHexMeta,
          footHex.isAcceptableOrUnknown(data['footHex']!, _footHexMeta));
    }
    if (data.containsKey('tarsusColor')) {
      context.handle(
          _tarsusColorMeta,
          tarsusColor.isAcceptableOrUnknown(
              data['tarsusColor']!, _tarsusColorMeta));
    }
    if (data.containsKey('tarsusHex')) {
      context.handle(_tarsusHexMeta,
          tarsusHex.isAcceptableOrUnknown(data['tarsusHex']!, _tarsusHexMeta));
    }
    if (data.containsKey('sex')) {
      context.handle(
          _sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    }
    if (data.containsKey('broodPatch')) {
      context.handle(
          _broodPatchMeta,
          broodPatch.isAcceptableOrUnknown(
              data['broodPatch']!, _broodPatchMeta));
    }
    if (data.containsKey('skullOssification')) {
      context.handle(
          _skullOssificationMeta,
          skullOssification.isAcceptableOrUnknown(
              data['skullOssification']!, _skullOssificationMeta));
    }
    if (data.containsKey('hasBursa')) {
      context.handle(_hasBursaMeta,
          hasBursa.isAcceptableOrUnknown(data['hasBursa']!, _hasBursaMeta));
    }
    if (data.containsKey('bursaWidth')) {
      context.handle(
          _bursaWidthMeta,
          bursaWidth.isAcceptableOrUnknown(
              data['bursaWidth']!, _bursaWidthMeta));
    }
    if (data.containsKey('bursaLength')) {
      context.handle(
          _bursaLengthMeta,
          bursaLength.isAcceptableOrUnknown(
              data['bursaLength']!, _bursaLengthMeta));
    }
    if (data.containsKey('fat')) {
      context.handle(
          _fatMeta, fat.isAcceptableOrUnknown(data['fat']!, _fatMeta));
    }
    if (data.containsKey('stomachContent')) {
      context.handle(
          _stomachContentMeta,
          stomachContent.isAcceptableOrUnknown(
              data['stomachContent']!, _stomachContentMeta));
    }
    if (data.containsKey('testisLength')) {
      context.handle(
          _testisLengthMeta,
          testisLength.isAcceptableOrUnknown(
              data['testisLength']!, _testisLengthMeta));
    }
    if (data.containsKey('testisWidth')) {
      context.handle(
          _testisWidthMeta,
          testisWidth.isAcceptableOrUnknown(
              data['testisWidth']!, _testisWidthMeta));
    }
    if (data.containsKey('testisRemark')) {
      context.handle(
          _testisRemarkMeta,
          testisRemark.isAcceptableOrUnknown(
              data['testisRemark']!, _testisRemarkMeta));
    }
    if (data.containsKey('ovaryLength')) {
      context.handle(
          _ovaryLengthMeta,
          ovaryLength.isAcceptableOrUnknown(
              data['ovaryLength']!, _ovaryLengthMeta));
    }
    if (data.containsKey('ovaryWidth')) {
      context.handle(
          _ovaryWidthMeta,
          ovaryWidth.isAcceptableOrUnknown(
              data['ovaryWidth']!, _ovaryWidthMeta));
    }
    if (data.containsKey('oviductWidth')) {
      context.handle(
          _oviductWidthMeta,
          oviductWidth.isAcceptableOrUnknown(
              data['oviductWidth']!, _oviductWidthMeta));
    }
    if (data.containsKey('ovaryAppearance')) {
      context.handle(
          _ovaryAppearanceMeta,
          ovaryAppearance.isAcceptableOrUnknown(
              data['ovaryAppearance']!, _ovaryAppearanceMeta));
    }
    if (data.containsKey('firstOvaSize')) {
      context.handle(
          _firstOvaSizeMeta,
          firstOvaSize.isAcceptableOrUnknown(
              data['firstOvaSize']!, _firstOvaSizeMeta));
    }
    if (data.containsKey('secondOvaSize')) {
      context.handle(
          _secondOvaSizeMeta,
          secondOvaSize.isAcceptableOrUnknown(
              data['secondOvaSize']!, _secondOvaSizeMeta));
    }
    if (data.containsKey('thirdOvaSize')) {
      context.handle(
          _thirdOvaSizeMeta,
          thirdOvaSize.isAcceptableOrUnknown(
              data['thirdOvaSize']!, _thirdOvaSizeMeta));
    }
    if (data.containsKey('oviductAppearance')) {
      context.handle(
          _oviductAppearanceMeta,
          oviductAppearance.isAcceptableOrUnknown(
              data['oviductAppearance']!, _oviductAppearanceMeta));
    }
    if (data.containsKey('ovaryRemark')) {
      context.handle(
          _ovaryRemarkMeta,
          ovaryRemark.isAcceptableOrUnknown(
              data['ovaryRemark']!, _ovaryRemarkMeta));
    }
    if (data.containsKey('wingIsMolt')) {
      context.handle(
          _wingIsMoltMeta,
          wingIsMolt.isAcceptableOrUnknown(
              data['wingIsMolt']!, _wingIsMoltMeta));
    }
    if (data.containsKey('wingMolt')) {
      context.handle(_wingMoltMeta,
          wingMolt.isAcceptableOrUnknown(data['wingMolt']!, _wingMoltMeta));
    }
    if (data.containsKey('tailIsMolt')) {
      context.handle(
          _tailIsMoltMeta,
          tailIsMolt.isAcceptableOrUnknown(
              data['tailIsMolt']!, _tailIsMoltMeta));
    }
    if (data.containsKey('tailMolt')) {
      context.handle(_tailMoltMeta,
          tailMolt.isAcceptableOrUnknown(data['tailMolt']!, _tailMoltMeta));
    }
    if (data.containsKey('bodyMolt')) {
      context.handle(_bodyMoltMeta,
          bodyMolt.isAcceptableOrUnknown(data['bodyMolt']!, _bodyMoltMeta));
    }
    if (data.containsKey('moltRemark')) {
      context.handle(
          _moltRemarkMeta,
          moltRemark.isAcceptableOrUnknown(
              data['moltRemark']!, _moltRemarkMeta));
    }
    if (data.containsKey('specimenRemark')) {
      context.handle(
          _specimenRemarkMeta,
          specimenRemark.isAcceptableOrUnknown(
              data['specimenRemark']!, _specimenRemarkMeta));
    }
    if (data.containsKey('habitatRemark')) {
      context.handle(
          _habitatRemarkMeta,
          habitatRemark.isAcceptableOrUnknown(
              data['habitatRemark']!, _habitatRemarkMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  AvianMeasurementData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AvianMeasurementData(
      specimenUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specimenUuid'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight']),
      wingspan: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}wingspan']),
      irisColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}irisColor']),
      irisHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}irisHex']),
      billColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}billColor']),
      billHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}billHex']),
      footColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}footColor']),
      footHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}footHex']),
      tarsusColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tarsusColor']),
      tarsusHex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tarsusHex']),
      sex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sex']),
      broodPatch: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}broodPatch']),
      skullOssification: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}skullOssification']),
      hasBursa: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hasBursa']),
      bursaWidth: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bursaWidth']),
      bursaLength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bursaLength']),
      fat: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fat']),
      stomachContent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stomachContent']),
      testisLength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}testisLength']),
      testisWidth: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}testisWidth']),
      testisRemark: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}testisRemark']),
      ovaryLength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ovaryLength']),
      ovaryWidth: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ovaryWidth']),
      oviductWidth: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}oviductWidth']),
      ovaryAppearance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ovaryAppearance']),
      firstOvaSize: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}firstOvaSize']),
      secondOvaSize: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}secondOvaSize']),
      thirdOvaSize: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}thirdOvaSize']),
      oviductAppearance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}oviductAppearance']),
      ovaryRemark: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ovaryRemark']),
      wingIsMolt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wingIsMolt']),
      wingMolt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wingMolt']),
      tailIsMolt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tailIsMolt']),
      tailMolt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tailMolt']),
      bodyMolt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bodyMolt']),
      moltRemark: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}moltRemark']),
      specimenRemark: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specimenRemark']),
      habitatRemark: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}habitatRemark']),
    );
  }

  @override
  AvianMeasurement createAlias(String alias) {
    return AvianMeasurement(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints =>
      const ['FOREIGN KEY(specimenUuid)REFERENCES specimen(uuid)'];
  @override
  bool get dontWriteConstraints => true;
}

class AvianMeasurementData extends DataClass
    implements Insertable<AvianMeasurementData> {
  final String specimenUuid;
  final double? weight;
  final double? wingspan;
  final String? irisColor;
  final String? irisHex;

  /// Hex number for iris color
  final String? billColor;
  final String? billHex;
  final String? footColor;
  final String? footHex;
  final String? tarsusColor;
  final String? tarsusHex;
  final int? sex;
  final int? broodPatch;
  final int? skullOssification;
  final int? hasBursa;
  final double? bursaWidth;
  final double? bursaLength;
  final int? fat;
  final String? stomachContent;
  final double? testisLength;
  final double? testisWidth;
  final String? testisRemark;
  final double? ovaryLength;
  final double? ovaryWidth;
  final double? oviductWidth;
  final int? ovaryAppearance;
  final double? firstOvaSize;
  final double? secondOvaSize;
  final double? thirdOvaSize;
  final int? oviductAppearance;

  /// encode to int to save space
  final String? ovaryRemark;
  final int? wingIsMolt;

  /// encode text
  final String? wingMolt;
  final int? tailIsMolt;
  final String? tailMolt;
  final int? bodyMolt;

  /// encode text
  final String? moltRemark;
  final String? specimenRemark;
  final String? habitatRemark;
  const AvianMeasurementData(
      {required this.specimenUuid,
      this.weight,
      this.wingspan,
      this.irisColor,
      this.irisHex,
      this.billColor,
      this.billHex,
      this.footColor,
      this.footHex,
      this.tarsusColor,
      this.tarsusHex,
      this.sex,
      this.broodPatch,
      this.skullOssification,
      this.hasBursa,
      this.bursaWidth,
      this.bursaLength,
      this.fat,
      this.stomachContent,
      this.testisLength,
      this.testisWidth,
      this.testisRemark,
      this.ovaryLength,
      this.ovaryWidth,
      this.oviductWidth,
      this.ovaryAppearance,
      this.firstOvaSize,
      this.secondOvaSize,
      this.thirdOvaSize,
      this.oviductAppearance,
      this.ovaryRemark,
      this.wingIsMolt,
      this.wingMolt,
      this.tailIsMolt,
      this.tailMolt,
      this.bodyMolt,
      this.moltRemark,
      this.specimenRemark,
      this.habitatRemark});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['specimenUuid'] = Variable<String>(specimenUuid);
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || wingspan != null) {
      map['wingspan'] = Variable<double>(wingspan);
    }
    if (!nullToAbsent || irisColor != null) {
      map['irisColor'] = Variable<String>(irisColor);
    }
    if (!nullToAbsent || irisHex != null) {
      map['irisHex'] = Variable<String>(irisHex);
    }
    if (!nullToAbsent || billColor != null) {
      map['billColor'] = Variable<String>(billColor);
    }
    if (!nullToAbsent || billHex != null) {
      map['billHex'] = Variable<String>(billHex);
    }
    if (!nullToAbsent || footColor != null) {
      map['footColor'] = Variable<String>(footColor);
    }
    if (!nullToAbsent || footHex != null) {
      map['footHex'] = Variable<String>(footHex);
    }
    if (!nullToAbsent || tarsusColor != null) {
      map['tarsusColor'] = Variable<String>(tarsusColor);
    }
    if (!nullToAbsent || tarsusHex != null) {
      map['tarsusHex'] = Variable<String>(tarsusHex);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<int>(sex);
    }
    if (!nullToAbsent || broodPatch != null) {
      map['broodPatch'] = Variable<int>(broodPatch);
    }
    if (!nullToAbsent || skullOssification != null) {
      map['skullOssification'] = Variable<int>(skullOssification);
    }
    if (!nullToAbsent || hasBursa != null) {
      map['hasBursa'] = Variable<int>(hasBursa);
    }
    if (!nullToAbsent || bursaWidth != null) {
      map['bursaWidth'] = Variable<double>(bursaWidth);
    }
    if (!nullToAbsent || bursaLength != null) {
      map['bursaLength'] = Variable<double>(bursaLength);
    }
    if (!nullToAbsent || fat != null) {
      map['fat'] = Variable<int>(fat);
    }
    if (!nullToAbsent || stomachContent != null) {
      map['stomachContent'] = Variable<String>(stomachContent);
    }
    if (!nullToAbsent || testisLength != null) {
      map['testisLength'] = Variable<double>(testisLength);
    }
    if (!nullToAbsent || testisWidth != null) {
      map['testisWidth'] = Variable<double>(testisWidth);
    }
    if (!nullToAbsent || testisRemark != null) {
      map['testisRemark'] = Variable<String>(testisRemark);
    }
    if (!nullToAbsent || ovaryLength != null) {
      map['ovaryLength'] = Variable<double>(ovaryLength);
    }
    if (!nullToAbsent || ovaryWidth != null) {
      map['ovaryWidth'] = Variable<double>(ovaryWidth);
    }
    if (!nullToAbsent || oviductWidth != null) {
      map['oviductWidth'] = Variable<double>(oviductWidth);
    }
    if (!nullToAbsent || ovaryAppearance != null) {
      map['ovaryAppearance'] = Variable<int>(ovaryAppearance);
    }
    if (!nullToAbsent || firstOvaSize != null) {
      map['firstOvaSize'] = Variable<double>(firstOvaSize);
    }
    if (!nullToAbsent || secondOvaSize != null) {
      map['secondOvaSize'] = Variable<double>(secondOvaSize);
    }
    if (!nullToAbsent || thirdOvaSize != null) {
      map['thirdOvaSize'] = Variable<double>(thirdOvaSize);
    }
    if (!nullToAbsent || oviductAppearance != null) {
      map['oviductAppearance'] = Variable<int>(oviductAppearance);
    }
    if (!nullToAbsent || ovaryRemark != null) {
      map['ovaryRemark'] = Variable<String>(ovaryRemark);
    }
    if (!nullToAbsent || wingIsMolt != null) {
      map['wingIsMolt'] = Variable<int>(wingIsMolt);
    }
    if (!nullToAbsent || wingMolt != null) {
      map['wingMolt'] = Variable<String>(wingMolt);
    }
    if (!nullToAbsent || tailIsMolt != null) {
      map['tailIsMolt'] = Variable<int>(tailIsMolt);
    }
    if (!nullToAbsent || tailMolt != null) {
      map['tailMolt'] = Variable<String>(tailMolt);
    }
    if (!nullToAbsent || bodyMolt != null) {
      map['bodyMolt'] = Variable<int>(bodyMolt);
    }
    if (!nullToAbsent || moltRemark != null) {
      map['moltRemark'] = Variable<String>(moltRemark);
    }
    if (!nullToAbsent || specimenRemark != null) {
      map['specimenRemark'] = Variable<String>(specimenRemark);
    }
    if (!nullToAbsent || habitatRemark != null) {
      map['habitatRemark'] = Variable<String>(habitatRemark);
    }
    return map;
  }

  AvianMeasurementCompanion toCompanion(bool nullToAbsent) {
    return AvianMeasurementCompanion(
      specimenUuid: Value(specimenUuid),
      weight:
          weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      wingspan: wingspan == null && nullToAbsent
          ? const Value.absent()
          : Value(wingspan),
      irisColor: irisColor == null && nullToAbsent
          ? const Value.absent()
          : Value(irisColor),
      irisHex: irisHex == null && nullToAbsent
          ? const Value.absent()
          : Value(irisHex),
      billColor: billColor == null && nullToAbsent
          ? const Value.absent()
          : Value(billColor),
      billHex: billHex == null && nullToAbsent
          ? const Value.absent()
          : Value(billHex),
      footColor: footColor == null && nullToAbsent
          ? const Value.absent()
          : Value(footColor),
      footHex: footHex == null && nullToAbsent
          ? const Value.absent()
          : Value(footHex),
      tarsusColor: tarsusColor == null && nullToAbsent
          ? const Value.absent()
          : Value(tarsusColor),
      tarsusHex: tarsusHex == null && nullToAbsent
          ? const Value.absent()
          : Value(tarsusHex),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      broodPatch: broodPatch == null && nullToAbsent
          ? const Value.absent()
          : Value(broodPatch),
      skullOssification: skullOssification == null && nullToAbsent
          ? const Value.absent()
          : Value(skullOssification),
      hasBursa: hasBursa == null && nullToAbsent
          ? const Value.absent()
          : Value(hasBursa),
      bursaWidth: bursaWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(bursaWidth),
      bursaLength: bursaLength == null && nullToAbsent
          ? const Value.absent()
          : Value(bursaLength),
      fat: fat == null && nullToAbsent ? const Value.absent() : Value(fat),
      stomachContent: stomachContent == null && nullToAbsent
          ? const Value.absent()
          : Value(stomachContent),
      testisLength: testisLength == null && nullToAbsent
          ? const Value.absent()
          : Value(testisLength),
      testisWidth: testisWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(testisWidth),
      testisRemark: testisRemark == null && nullToAbsent
          ? const Value.absent()
          : Value(testisRemark),
      ovaryLength: ovaryLength == null && nullToAbsent
          ? const Value.absent()
          : Value(ovaryLength),
      ovaryWidth: ovaryWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(ovaryWidth),
      oviductWidth: oviductWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(oviductWidth),
      ovaryAppearance: ovaryAppearance == null && nullToAbsent
          ? const Value.absent()
          : Value(ovaryAppearance),
      firstOvaSize: firstOvaSize == null && nullToAbsent
          ? const Value.absent()
          : Value(firstOvaSize),
      secondOvaSize: secondOvaSize == null && nullToAbsent
          ? const Value.absent()
          : Value(secondOvaSize),
      thirdOvaSize: thirdOvaSize == null && nullToAbsent
          ? const Value.absent()
          : Value(thirdOvaSize),
      oviductAppearance: oviductAppearance == null && nullToAbsent
          ? const Value.absent()
          : Value(oviductAppearance),
      ovaryRemark: ovaryRemark == null && nullToAbsent
          ? const Value.absent()
          : Value(ovaryRemark),
      wingIsMolt: wingIsMolt == null && nullToAbsent
          ? const Value.absent()
          : Value(wingIsMolt),
      wingMolt: wingMolt == null && nullToAbsent
          ? const Value.absent()
          : Value(wingMolt),
      tailIsMolt: tailIsMolt == null && nullToAbsent
          ? const Value.absent()
          : Value(tailIsMolt),
      tailMolt: tailMolt == null && nullToAbsent
          ? const Value.absent()
          : Value(tailMolt),
      bodyMolt: bodyMolt == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyMolt),
      moltRemark: moltRemark == null && nullToAbsent
          ? const Value.absent()
          : Value(moltRemark),
      specimenRemark: specimenRemark == null && nullToAbsent
          ? const Value.absent()
          : Value(specimenRemark),
      habitatRemark: habitatRemark == null && nullToAbsent
          ? const Value.absent()
          : Value(habitatRemark),
    );
  }

  factory AvianMeasurementData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AvianMeasurementData(
      specimenUuid: serializer.fromJson<String>(json['specimenUuid']),
      weight: serializer.fromJson<double?>(json['weight']),
      wingspan: serializer.fromJson<double?>(json['wingspan']),
      irisColor: serializer.fromJson<String?>(json['irisColor']),
      irisHex: serializer.fromJson<String?>(json['irisHex']),
      billColor: serializer.fromJson<String?>(json['billColor']),
      billHex: serializer.fromJson<String?>(json['billHex']),
      footColor: serializer.fromJson<String?>(json['footColor']),
      footHex: serializer.fromJson<String?>(json['footHex']),
      tarsusColor: serializer.fromJson<String?>(json['tarsusColor']),
      tarsusHex: serializer.fromJson<String?>(json['tarsusHex']),
      sex: serializer.fromJson<int?>(json['sex']),
      broodPatch: serializer.fromJson<int?>(json['broodPatch']),
      skullOssification: serializer.fromJson<int?>(json['skullOssification']),
      hasBursa: serializer.fromJson<int?>(json['hasBursa']),
      bursaWidth: serializer.fromJson<double?>(json['bursaWidth']),
      bursaLength: serializer.fromJson<double?>(json['bursaLength']),
      fat: serializer.fromJson<int?>(json['fat']),
      stomachContent: serializer.fromJson<String?>(json['stomachContent']),
      testisLength: serializer.fromJson<double?>(json['testisLength']),
      testisWidth: serializer.fromJson<double?>(json['testisWidth']),
      testisRemark: serializer.fromJson<String?>(json['testisRemark']),
      ovaryLength: serializer.fromJson<double?>(json['ovaryLength']),
      ovaryWidth: serializer.fromJson<double?>(json['ovaryWidth']),
      oviductWidth: serializer.fromJson<double?>(json['oviductWidth']),
      ovaryAppearance: serializer.fromJson<int?>(json['ovaryAppearance']),
      firstOvaSize: serializer.fromJson<double?>(json['firstOvaSize']),
      secondOvaSize: serializer.fromJson<double?>(json['secondOvaSize']),
      thirdOvaSize: serializer.fromJson<double?>(json['thirdOvaSize']),
      oviductAppearance: serializer.fromJson<int?>(json['oviductAppearance']),
      ovaryRemark: serializer.fromJson<String?>(json['ovaryRemark']),
      wingIsMolt: serializer.fromJson<int?>(json['wingIsMolt']),
      wingMolt: serializer.fromJson<String?>(json['wingMolt']),
      tailIsMolt: serializer.fromJson<int?>(json['tailIsMolt']),
      tailMolt: serializer.fromJson<String?>(json['tailMolt']),
      bodyMolt: serializer.fromJson<int?>(json['bodyMolt']),
      moltRemark: serializer.fromJson<String?>(json['moltRemark']),
      specimenRemark: serializer.fromJson<String?>(json['specimenRemark']),
      habitatRemark: serializer.fromJson<String?>(json['habitatRemark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'specimenUuid': serializer.toJson<String>(specimenUuid),
      'weight': serializer.toJson<double?>(weight),
      'wingspan': serializer.toJson<double?>(wingspan),
      'irisColor': serializer.toJson<String?>(irisColor),
      'irisHex': serializer.toJson<String?>(irisHex),
      'billColor': serializer.toJson<String?>(billColor),
      'billHex': serializer.toJson<String?>(billHex),
      'footColor': serializer.toJson<String?>(footColor),
      'footHex': serializer.toJson<String?>(footHex),
      'tarsusColor': serializer.toJson<String?>(tarsusColor),
      'tarsusHex': serializer.toJson<String?>(tarsusHex),
      'sex': serializer.toJson<int?>(sex),
      'broodPatch': serializer.toJson<int?>(broodPatch),
      'skullOssification': serializer.toJson<int?>(skullOssification),
      'hasBursa': serializer.toJson<int?>(hasBursa),
      'bursaWidth': serializer.toJson<double?>(bursaWidth),
      'bursaLength': serializer.toJson<double?>(bursaLength),
      'fat': serializer.toJson<int?>(fat),
      'stomachContent': serializer.toJson<String?>(stomachContent),
      'testisLength': serializer.toJson<double?>(testisLength),
      'testisWidth': serializer.toJson<double?>(testisWidth),
      'testisRemark': serializer.toJson<String?>(testisRemark),
      'ovaryLength': serializer.toJson<double?>(ovaryLength),
      'ovaryWidth': serializer.toJson<double?>(ovaryWidth),
      'oviductWidth': serializer.toJson<double?>(oviductWidth),
      'ovaryAppearance': serializer.toJson<int?>(ovaryAppearance),
      'firstOvaSize': serializer.toJson<double?>(firstOvaSize),
      'secondOvaSize': serializer.toJson<double?>(secondOvaSize),
      'thirdOvaSize': serializer.toJson<double?>(thirdOvaSize),
      'oviductAppearance': serializer.toJson<int?>(oviductAppearance),
      'ovaryRemark': serializer.toJson<String?>(ovaryRemark),
      'wingIsMolt': serializer.toJson<int?>(wingIsMolt),
      'wingMolt': serializer.toJson<String?>(wingMolt),
      'tailIsMolt': serializer.toJson<int?>(tailIsMolt),
      'tailMolt': serializer.toJson<String?>(tailMolt),
      'bodyMolt': serializer.toJson<int?>(bodyMolt),
      'moltRemark': serializer.toJson<String?>(moltRemark),
      'specimenRemark': serializer.toJson<String?>(specimenRemark),
      'habitatRemark': serializer.toJson<String?>(habitatRemark),
    };
  }

  AvianMeasurementData copyWith(
          {String? specimenUuid,
          Value<double?> weight = const Value.absent(),
          Value<double?> wingspan = const Value.absent(),
          Value<String?> irisColor = const Value.absent(),
          Value<String?> irisHex = const Value.absent(),
          Value<String?> billColor = const Value.absent(),
          Value<String?> billHex = const Value.absent(),
          Value<String?> footColor = const Value.absent(),
          Value<String?> footHex = const Value.absent(),
          Value<String?> tarsusColor = const Value.absent(),
          Value<String?> tarsusHex = const Value.absent(),
          Value<int?> sex = const Value.absent(),
          Value<int?> broodPatch = const Value.absent(),
          Value<int?> skullOssification = const Value.absent(),
          Value<int?> hasBursa = const Value.absent(),
          Value<double?> bursaWidth = const Value.absent(),
          Value<double?> bursaLength = const Value.absent(),
          Value<int?> fat = const Value.absent(),
          Value<String?> stomachContent = const Value.absent(),
          Value<double?> testisLength = const Value.absent(),
          Value<double?> testisWidth = const Value.absent(),
          Value<String?> testisRemark = const Value.absent(),
          Value<double?> ovaryLength = const Value.absent(),
          Value<double?> ovaryWidth = const Value.absent(),
          Value<double?> oviductWidth = const Value.absent(),
          Value<int?> ovaryAppearance = const Value.absent(),
          Value<double?> firstOvaSize = const Value.absent(),
          Value<double?> secondOvaSize = const Value.absent(),
          Value<double?> thirdOvaSize = const Value.absent(),
          Value<int?> oviductAppearance = const Value.absent(),
          Value<String?> ovaryRemark = const Value.absent(),
          Value<int?> wingIsMolt = const Value.absent(),
          Value<String?> wingMolt = const Value.absent(),
          Value<int?> tailIsMolt = const Value.absent(),
          Value<String?> tailMolt = const Value.absent(),
          Value<int?> bodyMolt = const Value.absent(),
          Value<String?> moltRemark = const Value.absent(),
          Value<String?> specimenRemark = const Value.absent(),
          Value<String?> habitatRemark = const Value.absent()}) =>
      AvianMeasurementData(
        specimenUuid: specimenUuid ?? this.specimenUuid,
        weight: weight.present ? weight.value : this.weight,
        wingspan: wingspan.present ? wingspan.value : this.wingspan,
        irisColor: irisColor.present ? irisColor.value : this.irisColor,
        irisHex: irisHex.present ? irisHex.value : this.irisHex,
        billColor: billColor.present ? billColor.value : this.billColor,
        billHex: billHex.present ? billHex.value : this.billHex,
        footColor: footColor.present ? footColor.value : this.footColor,
        footHex: footHex.present ? footHex.value : this.footHex,
        tarsusColor: tarsusColor.present ? tarsusColor.value : this.tarsusColor,
        tarsusHex: tarsusHex.present ? tarsusHex.value : this.tarsusHex,
        sex: sex.present ? sex.value : this.sex,
        broodPatch: broodPatch.present ? broodPatch.value : this.broodPatch,
        skullOssification: skullOssification.present
            ? skullOssification.value
            : this.skullOssification,
        hasBursa: hasBursa.present ? hasBursa.value : this.hasBursa,
        bursaWidth: bursaWidth.present ? bursaWidth.value : this.bursaWidth,
        bursaLength: bursaLength.present ? bursaLength.value : this.bursaLength,
        fat: fat.present ? fat.value : this.fat,
        stomachContent:
            stomachContent.present ? stomachContent.value : this.stomachContent,
        testisLength:
            testisLength.present ? testisLength.value : this.testisLength,
        testisWidth: testisWidth.present ? testisWidth.value : this.testisWidth,
        testisRemark:
            testisRemark.present ? testisRemark.value : this.testisRemark,
        ovaryLength: ovaryLength.present ? ovaryLength.value : this.ovaryLength,
        ovaryWidth: ovaryWidth.present ? ovaryWidth.value : this.ovaryWidth,
        oviductWidth:
            oviductWidth.present ? oviductWidth.value : this.oviductWidth,
        ovaryAppearance: ovaryAppearance.present
            ? ovaryAppearance.value
            : this.ovaryAppearance,
        firstOvaSize:
            firstOvaSize.present ? firstOvaSize.value : this.firstOvaSize,
        secondOvaSize:
            secondOvaSize.present ? secondOvaSize.value : this.secondOvaSize,
        thirdOvaSize:
            thirdOvaSize.present ? thirdOvaSize.value : this.thirdOvaSize,
        oviductAppearance: oviductAppearance.present
            ? oviductAppearance.value
            : this.oviductAppearance,
        ovaryRemark: ovaryRemark.present ? ovaryRemark.value : this.ovaryRemark,
        wingIsMolt: wingIsMolt.present ? wingIsMolt.value : this.wingIsMolt,
        wingMolt: wingMolt.present ? wingMolt.value : this.wingMolt,
        tailIsMolt: tailIsMolt.present ? tailIsMolt.value : this.tailIsMolt,
        tailMolt: tailMolt.present ? tailMolt.value : this.tailMolt,
        bodyMolt: bodyMolt.present ? bodyMolt.value : this.bodyMolt,
        moltRemark: moltRemark.present ? moltRemark.value : this.moltRemark,
        specimenRemark:
            specimenRemark.present ? specimenRemark.value : this.specimenRemark,
        habitatRemark:
            habitatRemark.present ? habitatRemark.value : this.habitatRemark,
      );
  AvianMeasurementData copyWithCompanion(AvianMeasurementCompanion data) {
    return AvianMeasurementData(
      specimenUuid: data.specimenUuid.present
          ? data.specimenUuid.value
          : this.specimenUuid,
      weight: data.weight.present ? data.weight.value : this.weight,
      wingspan: data.wingspan.present ? data.wingspan.value : this.wingspan,
      irisColor: data.irisColor.present ? data.irisColor.value : this.irisColor,
      irisHex: data.irisHex.present ? data.irisHex.value : this.irisHex,
      billColor: data.billColor.present ? data.billColor.value : this.billColor,
      billHex: data.billHex.present ? data.billHex.value : this.billHex,
      footColor: data.footColor.present ? data.footColor.value : this.footColor,
      footHex: data.footHex.present ? data.footHex.value : this.footHex,
      tarsusColor:
          data.tarsusColor.present ? data.tarsusColor.value : this.tarsusColor,
      tarsusHex: data.tarsusHex.present ? data.tarsusHex.value : this.tarsusHex,
      sex: data.sex.present ? data.sex.value : this.sex,
      broodPatch:
          data.broodPatch.present ? data.broodPatch.value : this.broodPatch,
      skullOssification: data.skullOssification.present
          ? data.skullOssification.value
          : this.skullOssification,
      hasBursa: data.hasBursa.present ? data.hasBursa.value : this.hasBursa,
      bursaWidth:
          data.bursaWidth.present ? data.bursaWidth.value : this.bursaWidth,
      bursaLength:
          data.bursaLength.present ? data.bursaLength.value : this.bursaLength,
      fat: data.fat.present ? data.fat.value : this.fat,
      stomachContent: data.stomachContent.present
          ? data.stomachContent.value
          : this.stomachContent,
      testisLength: data.testisLength.present
          ? data.testisLength.value
          : this.testisLength,
      testisWidth:
          data.testisWidth.present ? data.testisWidth.value : this.testisWidth,
      testisRemark: data.testisRemark.present
          ? data.testisRemark.value
          : this.testisRemark,
      ovaryLength:
          data.ovaryLength.present ? data.ovaryLength.value : this.ovaryLength,
      ovaryWidth:
          data.ovaryWidth.present ? data.ovaryWidth.value : this.ovaryWidth,
      oviductWidth: data.oviductWidth.present
          ? data.oviductWidth.value
          : this.oviductWidth,
      ovaryAppearance: data.ovaryAppearance.present
          ? data.ovaryAppearance.value
          : this.ovaryAppearance,
      firstOvaSize: data.firstOvaSize.present
          ? data.firstOvaSize.value
          : this.firstOvaSize,
      secondOvaSize: data.secondOvaSize.present
          ? data.secondOvaSize.value
          : this.secondOvaSize,
      thirdOvaSize: data.thirdOvaSize.present
          ? data.thirdOvaSize.value
          : this.thirdOvaSize,
      oviductAppearance: data.oviductAppearance.present
          ? data.oviductAppearance.value
          : this.oviductAppearance,
      ovaryRemark:
          data.ovaryRemark.present ? data.ovaryRemark.value : this.ovaryRemark,
      wingIsMolt:
          data.wingIsMolt.present ? data.wingIsMolt.value : this.wingIsMolt,
      wingMolt: data.wingMolt.present ? data.wingMolt.value : this.wingMolt,
      tailIsMolt:
          data.tailIsMolt.present ? data.tailIsMolt.value : this.tailIsMolt,
      tailMolt: data.tailMolt.present ? data.tailMolt.value : this.tailMolt,
      bodyMolt: data.bodyMolt.present ? data.bodyMolt.value : this.bodyMolt,
      moltRemark:
          data.moltRemark.present ? data.moltRemark.value : this.moltRemark,
      specimenRemark: data.specimenRemark.present
          ? data.specimenRemark.value
          : this.specimenRemark,
      habitatRemark: data.habitatRemark.present
          ? data.habitatRemark.value
          : this.habitatRemark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AvianMeasurementData(')
          ..write('specimenUuid: $specimenUuid, ')
          ..write('weight: $weight, ')
          ..write('wingspan: $wingspan, ')
          ..write('irisColor: $irisColor, ')
          ..write('irisHex: $irisHex, ')
          ..write('billColor: $billColor, ')
          ..write('billHex: $billHex, ')
          ..write('footColor: $footColor, ')
          ..write('footHex: $footHex, ')
          ..write('tarsusColor: $tarsusColor, ')
          ..write('tarsusHex: $tarsusHex, ')
          ..write('sex: $sex, ')
          ..write('broodPatch: $broodPatch, ')
          ..write('skullOssification: $skullOssification, ')
          ..write('hasBursa: $hasBursa, ')
          ..write('bursaWidth: $bursaWidth, ')
          ..write('bursaLength: $bursaLength, ')
          ..write('fat: $fat, ')
          ..write('stomachContent: $stomachContent, ')
          ..write('testisLength: $testisLength, ')
          ..write('testisWidth: $testisWidth, ')
          ..write('testisRemark: $testisRemark, ')
          ..write('ovaryLength: $ovaryLength, ')
          ..write('ovaryWidth: $ovaryWidth, ')
          ..write('oviductWidth: $oviductWidth, ')
          ..write('ovaryAppearance: $ovaryAppearance, ')
          ..write('firstOvaSize: $firstOvaSize, ')
          ..write('secondOvaSize: $secondOvaSize, ')
          ..write('thirdOvaSize: $thirdOvaSize, ')
          ..write('oviductAppearance: $oviductAppearance, ')
          ..write('ovaryRemark: $ovaryRemark, ')
          ..write('wingIsMolt: $wingIsMolt, ')
          ..write('wingMolt: $wingMolt, ')
          ..write('tailIsMolt: $tailIsMolt, ')
          ..write('tailMolt: $tailMolt, ')
          ..write('bodyMolt: $bodyMolt, ')
          ..write('moltRemark: $moltRemark, ')
          ..write('specimenRemark: $specimenRemark, ')
          ..write('habitatRemark: $habitatRemark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        specimenUuid,
        weight,
        wingspan,
        irisColor,
        irisHex,
        billColor,
        billHex,
        footColor,
        footHex,
        tarsusColor,
        tarsusHex,
        sex,
        broodPatch,
        skullOssification,
        hasBursa,
        bursaWidth,
        bursaLength,
        fat,
        stomachContent,
        testisLength,
        testisWidth,
        testisRemark,
        ovaryLength,
        ovaryWidth,
        oviductWidth,
        ovaryAppearance,
        firstOvaSize,
        secondOvaSize,
        thirdOvaSize,
        oviductAppearance,
        ovaryRemark,
        wingIsMolt,
        wingMolt,
        tailIsMolt,
        tailMolt,
        bodyMolt,
        moltRemark,
        specimenRemark,
        habitatRemark
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AvianMeasurementData &&
          other.specimenUuid == this.specimenUuid &&
          other.weight == this.weight &&
          other.wingspan == this.wingspan &&
          other.irisColor == this.irisColor &&
          other.irisHex == this.irisHex &&
          other.billColor == this.billColor &&
          other.billHex == this.billHex &&
          other.footColor == this.footColor &&
          other.footHex == this.footHex &&
          other.tarsusColor == this.tarsusColor &&
          other.tarsusHex == this.tarsusHex &&
          other.sex == this.sex &&
          other.broodPatch == this.broodPatch &&
          other.skullOssification == this.skullOssification &&
          other.hasBursa == this.hasBursa &&
          other.bursaWidth == this.bursaWidth &&
          other.bursaLength == this.bursaLength &&
          other.fat == this.fat &&
          other.stomachContent == this.stomachContent &&
          other.testisLength == this.testisLength &&
          other.testisWidth == this.testisWidth &&
          other.testisRemark == this.testisRemark &&
          other.ovaryLength == this.ovaryLength &&
          other.ovaryWidth == this.ovaryWidth &&
          other.oviductWidth == this.oviductWidth &&
          other.ovaryAppearance == this.ovaryAppearance &&
          other.firstOvaSize == this.firstOvaSize &&
          other.secondOvaSize == this.secondOvaSize &&
          other.thirdOvaSize == this.thirdOvaSize &&
          other.oviductAppearance == this.oviductAppearance &&
          other.ovaryRemark == this.ovaryRemark &&
          other.wingIsMolt == this.wingIsMolt &&
          other.wingMolt == this.wingMolt &&
          other.tailIsMolt == this.tailIsMolt &&
          other.tailMolt == this.tailMolt &&
          other.bodyMolt == this.bodyMolt &&
          other.moltRemark == this.moltRemark &&
          other.specimenRemark == this.specimenRemark &&
          other.habitatRemark == this.habitatRemark);
}

class AvianMeasurementCompanion extends UpdateCompanion<AvianMeasurementData> {
  final Value<String> specimenUuid;
  final Value<double?> weight;
  final Value<double?> wingspan;
  final Value<String?> irisColor;
  final Value<String?> irisHex;
  final Value<String?> billColor;
  final Value<String?> billHex;
  final Value<String?> footColor;
  final Value<String?> footHex;
  final Value<String?> tarsusColor;
  final Value<String?> tarsusHex;
  final Value<int?> sex;
  final Value<int?> broodPatch;
  final Value<int?> skullOssification;
  final Value<int?> hasBursa;
  final Value<double?> bursaWidth;
  final Value<double?> bursaLength;
  final Value<int?> fat;
  final Value<String?> stomachContent;
  final Value<double?> testisLength;
  final Value<double?> testisWidth;
  final Value<String?> testisRemark;
  final Value<double?> ovaryLength;
  final Value<double?> ovaryWidth;
  final Value<double?> oviductWidth;
  final Value<int?> ovaryAppearance;
  final Value<double?> firstOvaSize;
  final Value<double?> secondOvaSize;
  final Value<double?> thirdOvaSize;
  final Value<int?> oviductAppearance;
  final Value<String?> ovaryRemark;
  final Value<int?> wingIsMolt;
  final Value<String?> wingMolt;
  final Value<int?> tailIsMolt;
  final Value<String?> tailMolt;
  final Value<int?> bodyMolt;
  final Value<String?> moltRemark;
  final Value<String?> specimenRemark;
  final Value<String?> habitatRemark;
  final Value<int> rowid;
  const AvianMeasurementCompanion({
    this.specimenUuid = const Value.absent(),
    this.weight = const Value.absent(),
    this.wingspan = const Value.absent(),
    this.irisColor = const Value.absent(),
    this.irisHex = const Value.absent(),
    this.billColor = const Value.absent(),
    this.billHex = const Value.absent(),
    this.footColor = const Value.absent(),
    this.footHex = const Value.absent(),
    this.tarsusColor = const Value.absent(),
    this.tarsusHex = const Value.absent(),
    this.sex = const Value.absent(),
    this.broodPatch = const Value.absent(),
    this.skullOssification = const Value.absent(),
    this.hasBursa = const Value.absent(),
    this.bursaWidth = const Value.absent(),
    this.bursaLength = const Value.absent(),
    this.fat = const Value.absent(),
    this.stomachContent = const Value.absent(),
    this.testisLength = const Value.absent(),
    this.testisWidth = const Value.absent(),
    this.testisRemark = const Value.absent(),
    this.ovaryLength = const Value.absent(),
    this.ovaryWidth = const Value.absent(),
    this.oviductWidth = const Value.absent(),
    this.ovaryAppearance = const Value.absent(),
    this.firstOvaSize = const Value.absent(),
    this.secondOvaSize = const Value.absent(),
    this.thirdOvaSize = const Value.absent(),
    this.oviductAppearance = const Value.absent(),
    this.ovaryRemark = const Value.absent(),
    this.wingIsMolt = const Value.absent(),
    this.wingMolt = const Value.absent(),
    this.tailIsMolt = const Value.absent(),
    this.tailMolt = const Value.absent(),
    this.bodyMolt = const Value.absent(),
    this.moltRemark = const Value.absent(),
    this.specimenRemark = const Value.absent(),
    this.habitatRemark = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AvianMeasurementCompanion.insert({
    required String specimenUuid,
    this.weight = const Value.absent(),
    this.wingspan = const Value.absent(),
    this.irisColor = const Value.absent(),
    this.irisHex = const Value.absent(),
    this.billColor = const Value.absent(),
    this.billHex = const Value.absent(),
    this.footColor = const Value.absent(),
    this.footHex = const Value.absent(),
    this.tarsusColor = const Value.absent(),
    this.tarsusHex = const Value.absent(),
    this.sex = const Value.absent(),
    this.broodPatch = const Value.absent(),
    this.skullOssification = const Value.absent(),
    this.hasBursa = const Value.absent(),
    this.bursaWidth = const Value.absent(),
    this.bursaLength = const Value.absent(),
    this.fat = const Value.absent(),
    this.stomachContent = const Value.absent(),
    this.testisLength = const Value.absent(),
    this.testisWidth = const Value.absent(),
    this.testisRemark = const Value.absent(),
    this.ovaryLength = const Value.absent(),
    this.ovaryWidth = const Value.absent(),
    this.oviductWidth = const Value.absent(),
    this.ovaryAppearance = const Value.absent(),
    this.firstOvaSize = const Value.absent(),
    this.secondOvaSize = const Value.absent(),
    this.thirdOvaSize = const Value.absent(),
    this.oviductAppearance = const Value.absent(),
    this.ovaryRemark = const Value.absent(),
    this.wingIsMolt = const Value.absent(),
    this.wingMolt = const Value.absent(),
    this.tailIsMolt = const Value.absent(),
    this.tailMolt = const Value.absent(),
    this.bodyMolt = const Value.absent(),
    this.moltRemark = const Value.absent(),
    this.specimenRemark = const Value.absent(),
    this.habitatRemark = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : specimenUuid = Value(specimenUuid);
  static Insertable<AvianMeasurementData> custom({
    Expression<String>? specimenUuid,
    Expression<double>? weight,
    Expression<double>? wingspan,
    Expression<String>? irisColor,
    Expression<String>? irisHex,
    Expression<String>? billColor,
    Expression<String>? billHex,
    Expression<String>? footColor,
    Expression<String>? footHex,
    Expression<String>? tarsusColor,
    Expression<String>? tarsusHex,
    Expression<int>? sex,
    Expression<int>? broodPatch,
    Expression<int>? skullOssification,
    Expression<int>? hasBursa,
    Expression<double>? bursaWidth,
    Expression<double>? bursaLength,
    Expression<int>? fat,
    Expression<String>? stomachContent,
    Expression<double>? testisLength,
    Expression<double>? testisWidth,
    Expression<String>? testisRemark,
    Expression<double>? ovaryLength,
    Expression<double>? ovaryWidth,
    Expression<double>? oviductWidth,
    Expression<int>? ovaryAppearance,
    Expression<double>? firstOvaSize,
    Expression<double>? secondOvaSize,
    Expression<double>? thirdOvaSize,
    Expression<int>? oviductAppearance,
    Expression<String>? ovaryRemark,
    Expression<int>? wingIsMolt,
    Expression<String>? wingMolt,
    Expression<int>? tailIsMolt,
    Expression<String>? tailMolt,
    Expression<int>? bodyMolt,
    Expression<String>? moltRemark,
    Expression<String>? specimenRemark,
    Expression<String>? habitatRemark,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (specimenUuid != null) 'specimenUuid': specimenUuid,
      if (weight != null) 'weight': weight,
      if (wingspan != null) 'wingspan': wingspan,
      if (irisColor != null) 'irisColor': irisColor,
      if (irisHex != null) 'irisHex': irisHex,
      if (billColor != null) 'billColor': billColor,
      if (billHex != null) 'billHex': billHex,
      if (footColor != null) 'footColor': footColor,
      if (footHex != null) 'footHex': footHex,
      if (tarsusColor != null) 'tarsusColor': tarsusColor,
      if (tarsusHex != null) 'tarsusHex': tarsusHex,
      if (sex != null) 'sex': sex,
      if (broodPatch != null) 'broodPatch': broodPatch,
      if (skullOssification != null) 'skullOssification': skullOssification,
      if (hasBursa != null) 'hasBursa': hasBursa,
      if (bursaWidth != null) 'bursaWidth': bursaWidth,
      if (bursaLength != null) 'bursaLength': bursaLength,
      if (fat != null) 'fat': fat,
      if (stomachContent != null) 'stomachContent': stomachContent,
      if (testisLength != null) 'testisLength': testisLength,
      if (testisWidth != null) 'testisWidth': testisWidth,
      if (testisRemark != null) 'testisRemark': testisRemark,
      if (ovaryLength != null) 'ovaryLength': ovaryLength,
      if (ovaryWidth != null) 'ovaryWidth': ovaryWidth,
      if (oviductWidth != null) 'oviductWidth': oviductWidth,
      if (ovaryAppearance != null) 'ovaryAppearance': ovaryAppearance,
      if (firstOvaSize != null) 'firstOvaSize': firstOvaSize,
      if (secondOvaSize != null) 'secondOvaSize': secondOvaSize,
      if (thirdOvaSize != null) 'thirdOvaSize': thirdOvaSize,
      if (oviductAppearance != null) 'oviductAppearance': oviductAppearance,
      if (ovaryRemark != null) 'ovaryRemark': ovaryRemark,
      if (wingIsMolt != null) 'wingIsMolt': wingIsMolt,
      if (wingMolt != null) 'wingMolt': wingMolt,
      if (tailIsMolt != null) 'tailIsMolt': tailIsMolt,
      if (tailMolt != null) 'tailMolt': tailMolt,
      if (bodyMolt != null) 'bodyMolt': bodyMolt,
      if (moltRemark != null) 'moltRemark': moltRemark,
      if (specimenRemark != null) 'specimenRemark': specimenRemark,
      if (habitatRemark != null) 'habitatRemark': habitatRemark,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AvianMeasurementCompanion copyWith(
      {Value<String>? specimenUuid,
      Value<double?>? weight,
      Value<double?>? wingspan,
      Value<String?>? irisColor,
      Value<String?>? irisHex,
      Value<String?>? billColor,
      Value<String?>? billHex,
      Value<String?>? footColor,
      Value<String?>? footHex,
      Value<String?>? tarsusColor,
      Value<String?>? tarsusHex,
      Value<int?>? sex,
      Value<int?>? broodPatch,
      Value<int?>? skullOssification,
      Value<int?>? hasBursa,
      Value<double?>? bursaWidth,
      Value<double?>? bursaLength,
      Value<int?>? fat,
      Value<String?>? stomachContent,
      Value<double?>? testisLength,
      Value<double?>? testisWidth,
      Value<String?>? testisRemark,
      Value<double?>? ovaryLength,
      Value<double?>? ovaryWidth,
      Value<double?>? oviductWidth,
      Value<int?>? ovaryAppearance,
      Value<double?>? firstOvaSize,
      Value<double?>? secondOvaSize,
      Value<double?>? thirdOvaSize,
      Value<int?>? oviductAppearance,
      Value<String?>? ovaryRemark,
      Value<int?>? wingIsMolt,
      Value<String?>? wingMolt,
      Value<int?>? tailIsMolt,
      Value<String?>? tailMolt,
      Value<int?>? bodyMolt,
      Value<String?>? moltRemark,
      Value<String?>? specimenRemark,
      Value<String?>? habitatRemark,
      Value<int>? rowid}) {
    return AvianMeasurementCompanion(
      specimenUuid: specimenUuid ?? this.specimenUuid,
      weight: weight ?? this.weight,
      wingspan: wingspan ?? this.wingspan,
      irisColor: irisColor ?? this.irisColor,
      irisHex: irisHex ?? this.irisHex,
      billColor: billColor ?? this.billColor,
      billHex: billHex ?? this.billHex,
      footColor: footColor ?? this.footColor,
      footHex: footHex ?? this.footHex,
      tarsusColor: tarsusColor ?? this.tarsusColor,
      tarsusHex: tarsusHex ?? this.tarsusHex,
      sex: sex ?? this.sex,
      broodPatch: broodPatch ?? this.broodPatch,
      skullOssification: skullOssification ?? this.skullOssification,
      hasBursa: hasBursa ?? this.hasBursa,
      bursaWidth: bursaWidth ?? this.bursaWidth,
      bursaLength: bursaLength ?? this.bursaLength,
      fat: fat ?? this.fat,
      stomachContent: stomachContent ?? this.stomachContent,
      testisLength: testisLength ?? this.testisLength,
      testisWidth: testisWidth ?? this.testisWidth,
      testisRemark: testisRemark ?? this.testisRemark,
      ovaryLength: ovaryLength ?? this.ovaryLength,
      ovaryWidth: ovaryWidth ?? this.ovaryWidth,
      oviductWidth: oviductWidth ?? this.oviductWidth,
      ovaryAppearance: ovaryAppearance ?? this.ovaryAppearance,
      firstOvaSize: firstOvaSize ?? this.firstOvaSize,
      secondOvaSize: secondOvaSize ?? this.secondOvaSize,
      thirdOvaSize: thirdOvaSize ?? this.thirdOvaSize,
      oviductAppearance: oviductAppearance ?? this.oviductAppearance,
      ovaryRemark: ovaryRemark ?? this.ovaryRemark,
      wingIsMolt: wingIsMolt ?? this.wingIsMolt,
      wingMolt: wingMolt ?? this.wingMolt,
      tailIsMolt: tailIsMolt ?? this.tailIsMolt,
      tailMolt: tailMolt ?? this.tailMolt,
      bodyMolt: bodyMolt ?? this.bodyMolt,
      moltRemark: moltRemark ?? this.moltRemark,
      specimenRemark: specimenRemark ?? this.specimenRemark,
      habitatRemark: habitatRemark ?? this.habitatRemark,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (specimenUuid.present) {
      map['specimenUuid'] = Variable<String>(specimenUuid.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (wingspan.present) {
      map['wingspan'] = Variable<double>(wingspan.value);
    }
    if (irisColor.present) {
      map['irisColor'] = Variable<String>(irisColor.value);
    }
    if (irisHex.present) {
      map['irisHex'] = Variable<String>(irisHex.value);
    }
    if (billColor.present) {
      map['billColor'] = Variable<String>(billColor.value);
    }
    if (billHex.present) {
      map['billHex'] = Variable<String>(billHex.value);
    }
    if (footColor.present) {
      map['footColor'] = Variable<String>(footColor.value);
    }
    if (footHex.present) {
      map['footHex'] = Variable<String>(footHex.value);
    }
    if (tarsusColor.present) {
      map['tarsusColor'] = Variable<String>(tarsusColor.value);
    }
    if (tarsusHex.present) {
      map['tarsusHex'] = Variable<String>(tarsusHex.value);
    }
    if (sex.present) {
      map['sex'] = Variable<int>(sex.value);
    }
    if (broodPatch.present) {
      map['broodPatch'] = Variable<int>(broodPatch.value);
    }
    if (skullOssification.present) {
      map['skullOssification'] = Variable<int>(skullOssification.value);
    }
    if (hasBursa.present) {
      map['hasBursa'] = Variable<int>(hasBursa.value);
    }
    if (bursaWidth.present) {
      map['bursaWidth'] = Variable<double>(bursaWidth.value);
    }
    if (bursaLength.present) {
      map['bursaLength'] = Variable<double>(bursaLength.value);
    }
    if (fat.present) {
      map['fat'] = Variable<int>(fat.value);
    }
    if (stomachContent.present) {
      map['stomachContent'] = Variable<String>(stomachContent.value);
    }
    if (testisLength.present) {
      map['testisLength'] = Variable<double>(testisLength.value);
    }
    if (testisWidth.present) {
      map['testisWidth'] = Variable<double>(testisWidth.value);
    }
    if (testisRemark.present) {
      map['testisRemark'] = Variable<String>(testisRemark.value);
    }
    if (ovaryLength.present) {
      map['ovaryLength'] = Variable<double>(ovaryLength.value);
    }
    if (ovaryWidth.present) {
      map['ovaryWidth'] = Variable<double>(ovaryWidth.value);
    }
    if (oviductWidth.present) {
      map['oviductWidth'] = Variable<double>(oviductWidth.value);
    }
    if (ovaryAppearance.present) {
      map['ovaryAppearance'] = Variable<int>(ovaryAppearance.value);
    }
    if (firstOvaSize.present) {
      map['firstOvaSize'] = Variable<double>(firstOvaSize.value);
    }
    if (secondOvaSize.present) {
      map['secondOvaSize'] = Variable<double>(secondOvaSize.value);
    }
    if (thirdOvaSize.present) {
      map['thirdOvaSize'] = Variable<double>(thirdOvaSize.value);
    }
    if (oviductAppearance.present) {
      map['oviductAppearance'] = Variable<int>(oviductAppearance.value);
    }
    if (ovaryRemark.present) {
      map['ovaryRemark'] = Variable<String>(ovaryRemark.value);
    }
    if (wingIsMolt.present) {
      map['wingIsMolt'] = Variable<int>(wingIsMolt.value);
    }
    if (wingMolt.present) {
      map['wingMolt'] = Variable<String>(wingMolt.value);
    }
    if (tailIsMolt.present) {
      map['tailIsMolt'] = Variable<int>(tailIsMolt.value);
    }
    if (tailMolt.present) {
      map['tailMolt'] = Variable<String>(tailMolt.value);
    }
    if (bodyMolt.present) {
      map['bodyMolt'] = Variable<int>(bodyMolt.value);
    }
    if (moltRemark.present) {
      map['moltRemark'] = Variable<String>(moltRemark.value);
    }
    if (specimenRemark.present) {
      map['specimenRemark'] = Variable<String>(specimenRemark.value);
    }
    if (habitatRemark.present) {
      map['habitatRemark'] = Variable<String>(habitatRemark.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AvianMeasurementCompanion(')
          ..write('specimenUuid: $specimenUuid, ')
          ..write('weight: $weight, ')
          ..write('wingspan: $wingspan, ')
          ..write('irisColor: $irisColor, ')
          ..write('irisHex: $irisHex, ')
          ..write('billColor: $billColor, ')
          ..write('billHex: $billHex, ')
          ..write('footColor: $footColor, ')
          ..write('footHex: $footHex, ')
          ..write('tarsusColor: $tarsusColor, ')
          ..write('tarsusHex: $tarsusHex, ')
          ..write('sex: $sex, ')
          ..write('broodPatch: $broodPatch, ')
          ..write('skullOssification: $skullOssification, ')
          ..write('hasBursa: $hasBursa, ')
          ..write('bursaWidth: $bursaWidth, ')
          ..write('bursaLength: $bursaLength, ')
          ..write('fat: $fat, ')
          ..write('stomachContent: $stomachContent, ')
          ..write('testisLength: $testisLength, ')
          ..write('testisWidth: $testisWidth, ')
          ..write('testisRemark: $testisRemark, ')
          ..write('ovaryLength: $ovaryLength, ')
          ..write('ovaryWidth: $ovaryWidth, ')
          ..write('oviductWidth: $oviductWidth, ')
          ..write('ovaryAppearance: $ovaryAppearance, ')
          ..write('firstOvaSize: $firstOvaSize, ')
          ..write('secondOvaSize: $secondOvaSize, ')
          ..write('thirdOvaSize: $thirdOvaSize, ')
          ..write('oviductAppearance: $oviductAppearance, ')
          ..write('ovaryRemark: $ovaryRemark, ')
          ..write('wingIsMolt: $wingIsMolt, ')
          ..write('wingMolt: $wingMolt, ')
          ..write('tailIsMolt: $tailIsMolt, ')
          ..write('tailMolt: $tailMolt, ')
          ..write('bodyMolt: $bodyMolt, ')
          ..write('moltRemark: $moltRemark, ')
          ..write('specimenRemark: $specimenRemark, ')
          ..write('habitatRemark: $habitatRemark, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SpecimenPart extends Table
    with TableInfo<SpecimenPart, SpecimenPartData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SpecimenPart(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, true,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'UNIQUE PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _specimenUuidMeta =
      const VerificationMeta('specimenUuid');
  late final GeneratedColumn<String> specimenUuid = GeneratedColumn<String>(
      'specimenUuid', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _personnelIdMeta =
      const VerificationMeta('personnelId');
  late final GeneratedColumn<String> personnelId = GeneratedColumn<String>(
      'personnelId', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _tissueIDMeta =
      const VerificationMeta('tissueID');
  late final GeneratedColumn<String> tissueID = GeneratedColumn<String>(
      'tissueID', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _barcodeIDMeta =
      const VerificationMeta('barcodeID');
  late final GeneratedColumn<String> barcodeID = GeneratedColumn<String>(
      'barcodeID', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  late final GeneratedColumn<String> count = GeneratedColumn<String>(
      'count', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _treatmentMeta =
      const VerificationMeta('treatment');
  late final GeneratedColumn<String> treatment = GeneratedColumn<String>(
      'treatment', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _additionalTreatmentMeta =
      const VerificationMeta('additionalTreatment');
  late final GeneratedColumn<String> additionalTreatment =
      GeneratedColumn<String>('additionalTreatment', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  static const VerificationMeta _dateTakenMeta =
      const VerificationMeta('dateTaken');
  late final GeneratedColumn<String> dateTaken = GeneratedColumn<String>(
      'dateTaken', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _timeTakenMeta =
      const VerificationMeta('timeTaken');
  late final GeneratedColumn<String> timeTaken = GeneratedColumn<String>(
      'timeTaken', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _pmiMeta = const VerificationMeta('pmi');
  late final GeneratedColumn<String> pmi = GeneratedColumn<String>(
      'pmi', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _museumPermanentMeta =
      const VerificationMeta('museumPermanent');
  late final GeneratedColumn<String> museumPermanent = GeneratedColumn<String>(
      'museumPermanent', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _museumLoanMeta =
      const VerificationMeta('museumLoan');
  late final GeneratedColumn<String> museumLoan = GeneratedColumn<String>(
      'museumLoan', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
      'remark', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        specimenUuid,
        personnelId,
        tissueID,
        barcodeID,
        type,
        count,
        treatment,
        additionalTreatment,
        dateTaken,
        timeTaken,
        pmi,
        museumPermanent,
        museumLoan,
        remark
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'specimenPart';
  @override
  VerificationContext validateIntegrity(Insertable<SpecimenPartData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('specimenUuid')) {
      context.handle(
          _specimenUuidMeta,
          specimenUuid.isAcceptableOrUnknown(
              data['specimenUuid']!, _specimenUuidMeta));
    }
    if (data.containsKey('personnelId')) {
      context.handle(
          _personnelIdMeta,
          personnelId.isAcceptableOrUnknown(
              data['personnelId']!, _personnelIdMeta));
    }
    if (data.containsKey('tissueID')) {
      context.handle(_tissueIDMeta,
          tissueID.isAcceptableOrUnknown(data['tissueID']!, _tissueIDMeta));
    }
    if (data.containsKey('barcodeID')) {
      context.handle(_barcodeIDMeta,
          barcodeID.isAcceptableOrUnknown(data['barcodeID']!, _barcodeIDMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('count')) {
      context.handle(
          _countMeta, count.isAcceptableOrUnknown(data['count']!, _countMeta));
    }
    if (data.containsKey('treatment')) {
      context.handle(_treatmentMeta,
          treatment.isAcceptableOrUnknown(data['treatment']!, _treatmentMeta));
    }
    if (data.containsKey('additionalTreatment')) {
      context.handle(
          _additionalTreatmentMeta,
          additionalTreatment.isAcceptableOrUnknown(
              data['additionalTreatment']!, _additionalTreatmentMeta));
    }
    if (data.containsKey('dateTaken')) {
      context.handle(_dateTakenMeta,
          dateTaken.isAcceptableOrUnknown(data['dateTaken']!, _dateTakenMeta));
    }
    if (data.containsKey('timeTaken')) {
      context.handle(_timeTakenMeta,
          timeTaken.isAcceptableOrUnknown(data['timeTaken']!, _timeTakenMeta));
    }
    if (data.containsKey('pmi')) {
      context.handle(
          _pmiMeta, pmi.isAcceptableOrUnknown(data['pmi']!, _pmiMeta));
    }
    if (data.containsKey('museumPermanent')) {
      context.handle(
          _museumPermanentMeta,
          museumPermanent.isAcceptableOrUnknown(
              data['museumPermanent']!, _museumPermanentMeta));
    }
    if (data.containsKey('museumLoan')) {
      context.handle(
          _museumLoanMeta,
          museumLoan.isAcceptableOrUnknown(
              data['museumLoan']!, _museumLoanMeta));
    }
    if (data.containsKey('remark')) {
      context.handle(_remarkMeta,
          remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpecimenPartData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpecimenPartData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id']),
      specimenUuid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specimenUuid']),
      personnelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}personnelId']),
      tissueID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tissueID']),
      barcodeID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcodeID']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type']),
      count: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}count']),
      treatment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}treatment']),
      additionalTreatment: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}additionalTreatment']),
      dateTaken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dateTaken']),
      timeTaken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timeTaken']),
      pmi: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pmi']),
      museumPermanent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}museumPermanent']),
      museumLoan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}museumLoan']),
      remark: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remark']),
    );
  }

  @override
  SpecimenPart createAlias(String alias) {
    return SpecimenPart(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
        'FOREIGN KEY(specimenUuid)REFERENCES specimen(uuid)',
        'FOREIGN KEY(personnelId)REFERENCES personnel(uuid)'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class SpecimenPartData extends DataClass
    implements Insertable<SpecimenPartData> {
  final int? id;

  /// internal id
  final String? specimenUuid;
  final String? personnelId;
  final String? tissueID;
  final String? barcodeID;
  final String? type;
  final String? count;
  final String? treatment;
  final String? additionalTreatment;
  final String? dateTaken;
  final String? timeTaken;
  final String? pmi;
  final String? museumPermanent;
  final String? museumLoan;
  final String? remark;
  const SpecimenPartData(
      {this.id,
      this.specimenUuid,
      this.personnelId,
      this.tissueID,
      this.barcodeID,
      this.type,
      this.count,
      this.treatment,
      this.additionalTreatment,
      this.dateTaken,
      this.timeTaken,
      this.pmi,
      this.museumPermanent,
      this.museumLoan,
      this.remark});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || specimenUuid != null) {
      map['specimenUuid'] = Variable<String>(specimenUuid);
    }
    if (!nullToAbsent || personnelId != null) {
      map['personnelId'] = Variable<String>(personnelId);
    }
    if (!nullToAbsent || tissueID != null) {
      map['tissueID'] = Variable<String>(tissueID);
    }
    if (!nullToAbsent || barcodeID != null) {
      map['barcodeID'] = Variable<String>(barcodeID);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || count != null) {
      map['count'] = Variable<String>(count);
    }
    if (!nullToAbsent || treatment != null) {
      map['treatment'] = Variable<String>(treatment);
    }
    if (!nullToAbsent || additionalTreatment != null) {
      map['additionalTreatment'] = Variable<String>(additionalTreatment);
    }
    if (!nullToAbsent || dateTaken != null) {
      map['dateTaken'] = Variable<String>(dateTaken);
    }
    if (!nullToAbsent || timeTaken != null) {
      map['timeTaken'] = Variable<String>(timeTaken);
    }
    if (!nullToAbsent || pmi != null) {
      map['pmi'] = Variable<String>(pmi);
    }
    if (!nullToAbsent || museumPermanent != null) {
      map['museumPermanent'] = Variable<String>(museumPermanent);
    }
    if (!nullToAbsent || museumLoan != null) {
      map['museumLoan'] = Variable<String>(museumLoan);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  SpecimenPartCompanion toCompanion(bool nullToAbsent) {
    return SpecimenPartCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      specimenUuid: specimenUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(specimenUuid),
      personnelId: personnelId == null && nullToAbsent
          ? const Value.absent()
          : Value(personnelId),
      tissueID: tissueID == null && nullToAbsent
          ? const Value.absent()
          : Value(tissueID),
      barcodeID: barcodeID == null && nullToAbsent
          ? const Value.absent()
          : Value(barcodeID),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      count:
          count == null && nullToAbsent ? const Value.absent() : Value(count),
      treatment: treatment == null && nullToAbsent
          ? const Value.absent()
          : Value(treatment),
      additionalTreatment: additionalTreatment == null && nullToAbsent
          ? const Value.absent()
          : Value(additionalTreatment),
      dateTaken: dateTaken == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTaken),
      timeTaken: timeTaken == null && nullToAbsent
          ? const Value.absent()
          : Value(timeTaken),
      pmi: pmi == null && nullToAbsent ? const Value.absent() : Value(pmi),
      museumPermanent: museumPermanent == null && nullToAbsent
          ? const Value.absent()
          : Value(museumPermanent),
      museumLoan: museumLoan == null && nullToAbsent
          ? const Value.absent()
          : Value(museumLoan),
      remark:
          remark == null && nullToAbsent ? const Value.absent() : Value(remark),
    );
  }

  factory SpecimenPartData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpecimenPartData(
      id: serializer.fromJson<int?>(json['id']),
      specimenUuid: serializer.fromJson<String?>(json['specimenUuid']),
      personnelId: serializer.fromJson<String?>(json['personnelId']),
      tissueID: serializer.fromJson<String?>(json['tissueID']),
      barcodeID: serializer.fromJson<String?>(json['barcodeID']),
      type: serializer.fromJson<String?>(json['type']),
      count: serializer.fromJson<String?>(json['count']),
      treatment: serializer.fromJson<String?>(json['treatment']),
      additionalTreatment:
          serializer.fromJson<String?>(json['additionalTreatment']),
      dateTaken: serializer.fromJson<String?>(json['dateTaken']),
      timeTaken: serializer.fromJson<String?>(json['timeTaken']),
      pmi: serializer.fromJson<String?>(json['pmi']),
      museumPermanent: serializer.fromJson<String?>(json['museumPermanent']),
      museumLoan: serializer.fromJson<String?>(json['museumLoan']),
      remark: serializer.fromJson<String?>(json['remark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int?>(id),
      'specimenUuid': serializer.toJson<String?>(specimenUuid),
      'personnelId': serializer.toJson<String?>(personnelId),
      'tissueID': serializer.toJson<String?>(tissueID),
      'barcodeID': serializer.toJson<String?>(barcodeID),
      'type': serializer.toJson<String?>(type),
      'count': serializer.toJson<String?>(count),
      'treatment': serializer.toJson<String?>(treatment),
      'additionalTreatment': serializer.toJson<String?>(additionalTreatment),
      'dateTaken': serializer.toJson<String?>(dateTaken),
      'timeTaken': serializer.toJson<String?>(timeTaken),
      'pmi': serializer.toJson<String?>(pmi),
      'museumPermanent': serializer.toJson<String?>(museumPermanent),
      'museumLoan': serializer.toJson<String?>(museumLoan),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  SpecimenPartData copyWith(
          {Value<int?> id = const Value.absent(),
          Value<String?> specimenUuid = const Value.absent(),
          Value<String?> personnelId = const Value.absent(),
          Value<String?> tissueID = const Value.absent(),
          Value<String?> barcodeID = const Value.absent(),
          Value<String?> type = const Value.absent(),
          Value<String?> count = const Value.absent(),
          Value<String?> treatment = const Value.absent(),
          Value<String?> additionalTreatment = const Value.absent(),
          Value<String?> dateTaken = const Value.absent(),
          Value<String?> timeTaken = const Value.absent(),
          Value<String?> pmi = const Value.absent(),
          Value<String?> museumPermanent = const Value.absent(),
          Value<String?> museumLoan = const Value.absent(),
          Value<String?> remark = const Value.absent()}) =>
      SpecimenPartData(
        id: id.present ? id.value : this.id,
        specimenUuid:
            specimenUuid.present ? specimenUuid.value : this.specimenUuid,
        personnelId: personnelId.present ? personnelId.value : this.personnelId,
        tissueID: tissueID.present ? tissueID.value : this.tissueID,
        barcodeID: barcodeID.present ? barcodeID.value : this.barcodeID,
        type: type.present ? type.value : this.type,
        count: count.present ? count.value : this.count,
        treatment: treatment.present ? treatment.value : this.treatment,
        additionalTreatment: additionalTreatment.present
            ? additionalTreatment.value
            : this.additionalTreatment,
        dateTaken: dateTaken.present ? dateTaken.value : this.dateTaken,
        timeTaken: timeTaken.present ? timeTaken.value : this.timeTaken,
        pmi: pmi.present ? pmi.value : this.pmi,
        museumPermanent: museumPermanent.present
            ? museumPermanent.value
            : this.museumPermanent,
        museumLoan: museumLoan.present ? museumLoan.value : this.museumLoan,
        remark: remark.present ? remark.value : this.remark,
      );
  SpecimenPartData copyWithCompanion(SpecimenPartCompanion data) {
    return SpecimenPartData(
      id: data.id.present ? data.id.value : this.id,
      specimenUuid: data.specimenUuid.present
          ? data.specimenUuid.value
          : this.specimenUuid,
      personnelId:
          data.personnelId.present ? data.personnelId.value : this.personnelId,
      tissueID: data.tissueID.present ? data.tissueID.value : this.tissueID,
      barcodeID: data.barcodeID.present ? data.barcodeID.value : this.barcodeID,
      type: data.type.present ? data.type.value : this.type,
      count: data.count.present ? data.count.value : this.count,
      treatment: data.treatment.present ? data.treatment.value : this.treatment,
      additionalTreatment: data.additionalTreatment.present
          ? data.additionalTreatment.value
          : this.additionalTreatment,
      dateTaken: data.dateTaken.present ? data.dateTaken.value : this.dateTaken,
      timeTaken: data.timeTaken.present ? data.timeTaken.value : this.timeTaken,
      pmi: data.pmi.present ? data.pmi.value : this.pmi,
      museumPermanent: data.museumPermanent.present
          ? data.museumPermanent.value
          : this.museumPermanent,
      museumLoan:
          data.museumLoan.present ? data.museumLoan.value : this.museumLoan,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpecimenPartData(')
          ..write('id: $id, ')
          ..write('specimenUuid: $specimenUuid, ')
          ..write('personnelId: $personnelId, ')
          ..write('tissueID: $tissueID, ')
          ..write('barcodeID: $barcodeID, ')
          ..write('type: $type, ')
          ..write('count: $count, ')
          ..write('treatment: $treatment, ')
          ..write('additionalTreatment: $additionalTreatment, ')
          ..write('dateTaken: $dateTaken, ')
          ..write('timeTaken: $timeTaken, ')
          ..write('pmi: $pmi, ')
          ..write('museumPermanent: $museumPermanent, ')
          ..write('museumLoan: $museumLoan, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      specimenUuid,
      personnelId,
      tissueID,
      barcodeID,
      type,
      count,
      treatment,
      additionalTreatment,
      dateTaken,
      timeTaken,
      pmi,
      museumPermanent,
      museumLoan,
      remark);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpecimenPartData &&
          other.id == this.id &&
          other.specimenUuid == this.specimenUuid &&
          other.personnelId == this.personnelId &&
          other.tissueID == this.tissueID &&
          other.barcodeID == this.barcodeID &&
          other.type == this.type &&
          other.count == this.count &&
          other.treatment == this.treatment &&
          other.additionalTreatment == this.additionalTreatment &&
          other.dateTaken == this.dateTaken &&
          other.timeTaken == this.timeTaken &&
          other.pmi == this.pmi &&
          other.museumPermanent == this.museumPermanent &&
          other.museumLoan == this.museumLoan &&
          other.remark == this.remark);
}

class SpecimenPartCompanion extends UpdateCompanion<SpecimenPartData> {
  final Value<int?> id;
  final Value<String?> specimenUuid;
  final Value<String?> personnelId;
  final Value<String?> tissueID;
  final Value<String?> barcodeID;
  final Value<String?> type;
  final Value<String?> count;
  final Value<String?> treatment;
  final Value<String?> additionalTreatment;
  final Value<String?> dateTaken;
  final Value<String?> timeTaken;
  final Value<String?> pmi;
  final Value<String?> museumPermanent;
  final Value<String?> museumLoan;
  final Value<String?> remark;
  const SpecimenPartCompanion({
    this.id = const Value.absent(),
    this.specimenUuid = const Value.absent(),
    this.personnelId = const Value.absent(),
    this.tissueID = const Value.absent(),
    this.barcodeID = const Value.absent(),
    this.type = const Value.absent(),
    this.count = const Value.absent(),
    this.treatment = const Value.absent(),
    this.additionalTreatment = const Value.absent(),
    this.dateTaken = const Value.absent(),
    this.timeTaken = const Value.absent(),
    this.pmi = const Value.absent(),
    this.museumPermanent = const Value.absent(),
    this.museumLoan = const Value.absent(),
    this.remark = const Value.absent(),
  });
  SpecimenPartCompanion.insert({
    this.id = const Value.absent(),
    this.specimenUuid = const Value.absent(),
    this.personnelId = const Value.absent(),
    this.tissueID = const Value.absent(),
    this.barcodeID = const Value.absent(),
    this.type = const Value.absent(),
    this.count = const Value.absent(),
    this.treatment = const Value.absent(),
    this.additionalTreatment = const Value.absent(),
    this.dateTaken = const Value.absent(),
    this.timeTaken = const Value.absent(),
    this.pmi = const Value.absent(),
    this.museumPermanent = const Value.absent(),
    this.museumLoan = const Value.absent(),
    this.remark = const Value.absent(),
  });
  static Insertable<SpecimenPartData> custom({
    Expression<int>? id,
    Expression<String>? specimenUuid,
    Expression<String>? personnelId,
    Expression<String>? tissueID,
    Expression<String>? barcodeID,
    Expression<String>? type,
    Expression<String>? count,
    Expression<String>? treatment,
    Expression<String>? additionalTreatment,
    Expression<String>? dateTaken,
    Expression<String>? timeTaken,
    Expression<String>? pmi,
    Expression<String>? museumPermanent,
    Expression<String>? museumLoan,
    Expression<String>? remark,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (specimenUuid != null) 'specimenUuid': specimenUuid,
      if (personnelId != null) 'personnelId': personnelId,
      if (tissueID != null) 'tissueID': tissueID,
      if (barcodeID != null) 'barcodeID': barcodeID,
      if (type != null) 'type': type,
      if (count != null) 'count': count,
      if (treatment != null) 'treatment': treatment,
      if (additionalTreatment != null)
        'additionalTreatment': additionalTreatment,
      if (dateTaken != null) 'dateTaken': dateTaken,
      if (timeTaken != null) 'timeTaken': timeTaken,
      if (pmi != null) 'pmi': pmi,
      if (museumPermanent != null) 'museumPermanent': museumPermanent,
      if (museumLoan != null) 'museumLoan': museumLoan,
      if (remark != null) 'remark': remark,
    });
  }

  SpecimenPartCompanion copyWith(
      {Value<int?>? id,
      Value<String?>? specimenUuid,
      Value<String?>? personnelId,
      Value<String?>? tissueID,
      Value<String?>? barcodeID,
      Value<String?>? type,
      Value<String?>? count,
      Value<String?>? treatment,
      Value<String?>? additionalTreatment,
      Value<String?>? dateTaken,
      Value<String?>? timeTaken,
      Value<String?>? pmi,
      Value<String?>? museumPermanent,
      Value<String?>? museumLoan,
      Value<String?>? remark}) {
    return SpecimenPartCompanion(
      id: id ?? this.id,
      specimenUuid: specimenUuid ?? this.specimenUuid,
      personnelId: personnelId ?? this.personnelId,
      tissueID: tissueID ?? this.tissueID,
      barcodeID: barcodeID ?? this.barcodeID,
      type: type ?? this.type,
      count: count ?? this.count,
      treatment: treatment ?? this.treatment,
      additionalTreatment: additionalTreatment ?? this.additionalTreatment,
      dateTaken: dateTaken ?? this.dateTaken,
      timeTaken: timeTaken ?? this.timeTaken,
      pmi: pmi ?? this.pmi,
      museumPermanent: museumPermanent ?? this.museumPermanent,
      museumLoan: museumLoan ?? this.museumLoan,
      remark: remark ?? this.remark,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (specimenUuid.present) {
      map['specimenUuid'] = Variable<String>(specimenUuid.value);
    }
    if (personnelId.present) {
      map['personnelId'] = Variable<String>(personnelId.value);
    }
    if (tissueID.present) {
      map['tissueID'] = Variable<String>(tissueID.value);
    }
    if (barcodeID.present) {
      map['barcodeID'] = Variable<String>(barcodeID.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (count.present) {
      map['count'] = Variable<String>(count.value);
    }
    if (treatment.present) {
      map['treatment'] = Variable<String>(treatment.value);
    }
    if (additionalTreatment.present) {
      map['additionalTreatment'] = Variable<String>(additionalTreatment.value);
    }
    if (dateTaken.present) {
      map['dateTaken'] = Variable<String>(dateTaken.value);
    }
    if (timeTaken.present) {
      map['timeTaken'] = Variable<String>(timeTaken.value);
    }
    if (pmi.present) {
      map['pmi'] = Variable<String>(pmi.value);
    }
    if (museumPermanent.present) {
      map['museumPermanent'] = Variable<String>(museumPermanent.value);
    }
    if (museumLoan.present) {
      map['museumLoan'] = Variable<String>(museumLoan.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpecimenPartCompanion(')
          ..write('id: $id, ')
          ..write('specimenUuid: $specimenUuid, ')
          ..write('personnelId: $personnelId, ')
          ..write('tissueID: $tissueID, ')
          ..write('barcodeID: $barcodeID, ')
          ..write('type: $type, ')
          ..write('count: $count, ')
          ..write('treatment: $treatment, ')
          ..write('additionalTreatment: $additionalTreatment, ')
          ..write('dateTaken: $dateTaken, ')
          ..write('timeTaken: $timeTaken, ')
          ..write('pmi: $pmi, ')
          ..write('museumPermanent: $museumPermanent, ')
          ..write('museumLoan: $museumLoan, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final Project project = Project(this);
  late final Personnel personnel = Personnel(this);
  late final Media media = Media(this);
  late final Site site = Site(this);
  late final Coordinate coordinate = Coordinate(this);
  late final CollEvent collEvent = CollEvent(this);
  late final Weather weather = Weather(this);
  late final CollPersonnel collPersonnel = CollPersonnel(this);
  late final CollEffort collEffort = CollEffort(this);
  late final Narrative narrative = Narrative(this);
  late final NarrativeMedia narrativeMedia = NarrativeMedia(this);
  late final SiteMedia siteMedia = SiteMedia(this);
  late final Taxonomy taxonomy = Taxonomy(this);
  late final Specimen specimen = Specimen(this);
  late final SpecimenMedia specimenMedia = SpecimenMedia(this);
  late final AssociatedData associatedData = AssociatedData(this);
  late final PersonnelList personnelList = PersonnelList(this);
  late final MammalMeasurement mammalMeasurement = MammalMeasurement(this);
  late final AvianMeasurement avianMeasurement = AvianMeasurement(this);
  late final SpecimenPart specimenPart = SpecimenPart(this);
  Selectable<ListProjectResult> listProject() {
    return customSelect('SELECT uuid, name, created, lastAccessed FROM project',
        variables: [],
        readsFrom: {
          project,
        }).map((QueryRow row) => ListProjectResult(
          uuid: row.read<String>('uuid'),
          name: row.read<String>('name'),
          created: row.readNullable<String>('created'),
          lastAccessed: row.readNullable<String>('lastAccessed'),
        ));
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        project,
        personnel,
        media,
        site,
        coordinate,
        collEvent,
        weather,
        collPersonnel,
        collEffort,
        narrative,
        narrativeMedia,
        siteMedia,
        taxonomy,
        specimen,
        specimenMedia,
        associatedData,
        personnelList,
        mammalMeasurement,
        avianMeasurement,
        specimenPart
      ];
}

typedef $ProjectCreateCompanionBuilder = ProjectCompanion Function({
  required String uuid,
  required String name,
  Value<String?> description,
  Value<String?> principalInvestigator,
  Value<String?> location,
  Value<String?> startDate,
  Value<String?> endDate,
  Value<String?> created,
  Value<String?> lastAccessed,
  Value<int> rowid,
});
typedef $ProjectUpdateCompanionBuilder = ProjectCompanion Function({
  Value<String> uuid,
  Value<String> name,
  Value<String?> description,
  Value<String?> principalInvestigator,
  Value<String?> location,
  Value<String?> startDate,
  Value<String?> endDate,
  Value<String?> created,
  Value<String?> lastAccessed,
  Value<int> rowid,
});

class $ProjectFilterComposer extends Composer<_$Database, Project> {
  $ProjectFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get principalInvestigator => $composableBuilder(
      column: $table.principalInvestigator,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get created => $composableBuilder(
      column: $table.created, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastAccessed => $composableBuilder(
      column: $table.lastAccessed, builder: (column) => ColumnFilters(column));
}

class $ProjectOrderingComposer extends Composer<_$Database, Project> {
  $ProjectOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get principalInvestigator => $composableBuilder(
      column: $table.principalInvestigator,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get created => $composableBuilder(
      column: $table.created, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastAccessed => $composableBuilder(
      column: $table.lastAccessed,
      builder: (column) => ColumnOrderings(column));
}

class $ProjectAnnotationComposer extends Composer<_$Database, Project> {
  $ProjectAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get principalInvestigator => $composableBuilder(
      column: $table.principalInvestigator, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<String> get lastAccessed => $composableBuilder(
      column: $table.lastAccessed, builder: (column) => column);
}

class $ProjectTableManager extends RootTableManager<
    _$Database,
    Project,
    ProjectData,
    $ProjectFilterComposer,
    $ProjectOrderingComposer,
    $ProjectAnnotationComposer,
    $ProjectCreateCompanionBuilder,
    $ProjectUpdateCompanionBuilder,
    (ProjectData, BaseReferences<_$Database, Project, ProjectData>),
    ProjectData,
    PrefetchHooks Function()> {
  $ProjectTableManager(_$Database db, Project table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ProjectFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ProjectOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ProjectAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> principalInvestigator = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> startDate = const Value.absent(),
            Value<String?> endDate = const Value.absent(),
            Value<String?> created = const Value.absent(),
            Value<String?> lastAccessed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectCompanion(
            uuid: uuid,
            name: name,
            description: description,
            principalInvestigator: principalInvestigator,
            location: location,
            startDate: startDate,
            endDate: endDate,
            created: created,
            lastAccessed: lastAccessed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> principalInvestigator = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> startDate = const Value.absent(),
            Value<String?> endDate = const Value.absent(),
            Value<String?> created = const Value.absent(),
            Value<String?> lastAccessed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectCompanion.insert(
            uuid: uuid,
            name: name,
            description: description,
            principalInvestigator: principalInvestigator,
            location: location,
            startDate: startDate,
            endDate: endDate,
            created: created,
            lastAccessed: lastAccessed,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $ProjectProcessedTableManager = ProcessedTableManager<
    _$Database,
    Project,
    ProjectData,
    $ProjectFilterComposer,
    $ProjectOrderingComposer,
    $ProjectAnnotationComposer,
    $ProjectCreateCompanionBuilder,
    $ProjectUpdateCompanionBuilder,
    (ProjectData, BaseReferences<_$Database, Project, ProjectData>),
    ProjectData,
    PrefetchHooks Function()>;
typedef $PersonnelCreateCompanionBuilder = PersonnelCompanion Function({
  required String uuid,
  Value<String?> name,
  Value<String?> initial,
  Value<String?> email,
  Value<String?> phone,
  Value<String?> affiliation,
  Value<String?> role,
  Value<int?> currentFieldNumber,
  Value<String?> notes,
  Value<String?> photoPath,
  Value<int> rowid,
});
typedef $PersonnelUpdateCompanionBuilder = PersonnelCompanion Function({
  Value<String> uuid,
  Value<String?> name,
  Value<String?> initial,
  Value<String?> email,
  Value<String?> phone,
  Value<String?> affiliation,
  Value<String?> role,
  Value<int?> currentFieldNumber,
  Value<String?> notes,
  Value<String?> photoPath,
  Value<int> rowid,
});

final class $PersonnelReferences
    extends BaseReferences<_$Database, Personnel, PersonnelData> {
  $PersonnelReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Specimen, List<SpecimenData>> _specimenRefsTable(
          _$Database db) =>
      MultiTypedResultKey.fromTable(db.specimen,
          aliasName: $_aliasNameGenerator(
              db.personnel.uuid, db.specimen.preparatorID));

  $SpecimenProcessedTableManager get specimenRefs {
    final manager = $SpecimenTableManager($_db, $_db.specimen).filter(
        (f) => f.preparatorID.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_specimenRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $PersonnelFilterComposer extends Composer<_$Database, Personnel> {
  $PersonnelFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get initial => $composableBuilder(
      column: $table.initial, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get affiliation => $composableBuilder(
      column: $table.affiliation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentFieldNumber => $composableBuilder(
      column: $table.currentFieldNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  Expression<bool> specimenRefs(
      Expression<bool> Function($SpecimenFilterComposer f) f) {
    final $SpecimenFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.specimen,
        getReferencedColumn: (t) => t.preparatorID,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $SpecimenFilterComposer(
              $db: $db,
              $table: $db.specimen,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $PersonnelOrderingComposer extends Composer<_$Database, Personnel> {
  $PersonnelOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get initial => $composableBuilder(
      column: $table.initial, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get affiliation => $composableBuilder(
      column: $table.affiliation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentFieldNumber => $composableBuilder(
      column: $table.currentFieldNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));
}

class $PersonnelAnnotationComposer extends Composer<_$Database, Personnel> {
  $PersonnelAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get initial =>
      $composableBuilder(column: $table.initial, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get affiliation => $composableBuilder(
      column: $table.affiliation, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get currentFieldNumber => $composableBuilder(
      column: $table.currentFieldNumber, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  Expression<T> specimenRefs<T extends Object>(
      Expression<T> Function($SpecimenAnnotationComposer a) f) {
    final $SpecimenAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.uuid,
        referencedTable: $db.specimen,
        getReferencedColumn: (t) => t.preparatorID,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $SpecimenAnnotationComposer(
              $db: $db,
              $table: $db.specimen,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $PersonnelTableManager extends RootTableManager<
    _$Database,
    Personnel,
    PersonnelData,
    $PersonnelFilterComposer,
    $PersonnelOrderingComposer,
    $PersonnelAnnotationComposer,
    $PersonnelCreateCompanionBuilder,
    $PersonnelUpdateCompanionBuilder,
    (PersonnelData, $PersonnelReferences),
    PersonnelData,
    PrefetchHooks Function({bool specimenRefs})> {
  $PersonnelTableManager(_$Database db, Personnel table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PersonnelFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PersonnelOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PersonnelAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> initial = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> affiliation = const Value.absent(),
            Value<String?> role = const Value.absent(),
            Value<int?> currentFieldNumber = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PersonnelCompanion(
            uuid: uuid,
            name: name,
            initial: initial,
            email: email,
            phone: phone,
            affiliation: affiliation,
            role: role,
            currentFieldNumber: currentFieldNumber,
            notes: notes,
            photoPath: photoPath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            Value<String?> name = const Value.absent(),
            Value<String?> initial = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> affiliation = const Value.absent(),
            Value<String?> role = const Value.absent(),
            Value<int?> currentFieldNumber = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PersonnelCompanion.insert(
            uuid: uuid,
            name: name,
            initial: initial,
            email: email,
            phone: phone,
            affiliation: affiliation,
            role: role,
            currentFieldNumber: currentFieldNumber,
            notes: notes,
            photoPath: photoPath,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $PersonnelReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({specimenRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (specimenRefs) db.specimen],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (specimenRefs)
                    await $_getPrefetchedData<PersonnelData, Personnel,
                            SpecimenData>(
                        currentTable: table,
                        referencedTable:
                            $PersonnelReferences._specimenRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $PersonnelReferences(db, table, p0).specimenRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.preparatorID == item.uuid),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $PersonnelProcessedTableManager = ProcessedTableManager<
    _$Database,
    Personnel,
    PersonnelData,
    $PersonnelFilterComposer,
    $PersonnelOrderingComposer,
    $PersonnelAnnotationComposer,
    $PersonnelCreateCompanionBuilder,
    $PersonnelUpdateCompanionBuilder,
    (PersonnelData, $PersonnelReferences),
    PersonnelData,
    PrefetchHooks Function({bool specimenRefs})>;
typedef $MediaCreateCompanionBuilder = MediaCompanion Function({
  Value<int> primaryId,
  Value<String?> projectUuid,
  Value<String?> secondaryId,
  Value<String?> category,
  Value<String?> tag,
  Value<String?> taken,
  Value<String?> camera,
  Value<String?> lenses,
  Value<String?> additionalExif,
  Value<String?> personnelId,
  Value<String?> fileName,
  Value<String?> caption,
});
typedef $MediaUpdateCompanionBuilder = MediaCompanion Function({
  Value<int> primaryId,
  Value<String?> projectUuid,
  Value<String?> secondaryId,
  Value<String?> category,
  Value<String?> tag,
  Value<String?> taken,
  Value<String?> camera,
  Value<String?> lenses,
  Value<String?> additionalExif,
  Value<String?> personnelId,
  Value<String?> fileName,
  Value<String?> caption,
});

final class $MediaReferences
    extends BaseReferences<_$Database, Media, MediaData> {
  $MediaReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Narrative, List<NarrativeData>>
      _narrativeRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
          db.narrative,
          aliasName:
              $_aliasNameGenerator(db.media.primaryId, db.narrative.mediaID));

  $NarrativeProcessedTableManager get narrativeRefs {
    final manager = $NarrativeTableManager($_db, $_db.narrative).filter(
        (f) => f.mediaID.primaryId.sqlEquals($_itemColumn<int>('primaryId')!));

    final cache = $_typedResult.readTableOrNull(_narrativeRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $MediaFilterComposer extends Composer<_$Database, Media> {
  $MediaFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get primaryId => $composableBuilder(
      column: $table.primaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get secondaryId => $composableBuilder(
      column: $table.secondaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taken => $composableBuilder(
      column: $table.taken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get camera => $composableBuilder(
      column: $table.camera, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lenses => $composableBuilder(
      column: $table.lenses, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get additionalExif => $composableBuilder(
      column: $table.additionalExif,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personnelId => $composableBuilder(
      column: $table.personnelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnFilters(column));

  Expression<bool> narrativeRefs(
      Expression<bool> Function($NarrativeFilterComposer f) f) {
    final $NarrativeFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.primaryId,
        referencedTable: $db.narrative,
        getReferencedColumn: (t) => t.mediaID,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $NarrativeFilterComposer(
              $db: $db,
              $table: $db.narrative,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $MediaOrderingComposer extends Composer<_$Database, Media> {
  $MediaOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get primaryId => $composableBuilder(
      column: $table.primaryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get secondaryId => $composableBuilder(
      column: $table.secondaryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taken => $composableBuilder(
      column: $table.taken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get camera => $composableBuilder(
      column: $table.camera, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lenses => $composableBuilder(
      column: $table.lenses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get additionalExif => $composableBuilder(
      column: $table.additionalExif,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personnelId => $composableBuilder(
      column: $table.personnelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caption => $composableBuilder(
      column: $table.caption, builder: (column) => ColumnOrderings(column));
}

class $MediaAnnotationComposer extends Composer<_$Database, Media> {
  $MediaAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get primaryId =>
      $composableBuilder(column: $table.primaryId, builder: (column) => column);

  GeneratedColumn<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => column);

  GeneratedColumn<String> get secondaryId => $composableBuilder(
      column: $table.secondaryId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get taken =>
      $composableBuilder(column: $table.taken, builder: (column) => column);

  GeneratedColumn<String> get camera =>
      $composableBuilder(column: $table.camera, builder: (column) => column);

  GeneratedColumn<String> get lenses =>
      $composableBuilder(column: $table.lenses, builder: (column) => column);

  GeneratedColumn<String> get additionalExif => $composableBuilder(
      column: $table.additionalExif, builder: (column) => column);

  GeneratedColumn<String> get personnelId => $composableBuilder(
      column: $table.personnelId, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  Expression<T> narrativeRefs<T extends Object>(
      Expression<T> Function($NarrativeAnnotationComposer a) f) {
    final $NarrativeAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.primaryId,
        referencedTable: $db.narrative,
        getReferencedColumn: (t) => t.mediaID,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $NarrativeAnnotationComposer(
              $db: $db,
              $table: $db.narrative,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $MediaTableManager extends RootTableManager<
    _$Database,
    Media,
    MediaData,
    $MediaFilterComposer,
    $MediaOrderingComposer,
    $MediaAnnotationComposer,
    $MediaCreateCompanionBuilder,
    $MediaUpdateCompanionBuilder,
    (MediaData, $MediaReferences),
    MediaData,
    PrefetchHooks Function({bool narrativeRefs})> {
  $MediaTableManager(_$Database db, Media table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MediaFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MediaOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MediaAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> primaryId = const Value.absent(),
            Value<String?> projectUuid = const Value.absent(),
            Value<String?> secondaryId = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> tag = const Value.absent(),
            Value<String?> taken = const Value.absent(),
            Value<String?> camera = const Value.absent(),
            Value<String?> lenses = const Value.absent(),
            Value<String?> additionalExif = const Value.absent(),
            Value<String?> personnelId = const Value.absent(),
            Value<String?> fileName = const Value.absent(),
            Value<String?> caption = const Value.absent(),
          }) =>
              MediaCompanion(
            primaryId: primaryId,
            projectUuid: projectUuid,
            secondaryId: secondaryId,
            category: category,
            tag: tag,
            taken: taken,
            camera: camera,
            lenses: lenses,
            additionalExif: additionalExif,
            personnelId: personnelId,
            fileName: fileName,
            caption: caption,
          ),
          createCompanionCallback: ({
            Value<int> primaryId = const Value.absent(),
            Value<String?> projectUuid = const Value.absent(),
            Value<String?> secondaryId = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> tag = const Value.absent(),
            Value<String?> taken = const Value.absent(),
            Value<String?> camera = const Value.absent(),
            Value<String?> lenses = const Value.absent(),
            Value<String?> additionalExif = const Value.absent(),
            Value<String?> personnelId = const Value.absent(),
            Value<String?> fileName = const Value.absent(),
            Value<String?> caption = const Value.absent(),
          }) =>
              MediaCompanion.insert(
            primaryId: primaryId,
            projectUuid: projectUuid,
            secondaryId: secondaryId,
            category: category,
            tag: tag,
            taken: taken,
            camera: camera,
            lenses: lenses,
            additionalExif: additionalExif,
            personnelId: personnelId,
            fileName: fileName,
            caption: caption,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $MediaReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({narrativeRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (narrativeRefs) db.narrative],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (narrativeRefs)
                    await $_getPrefetchedData<MediaData, Media, NarrativeData>(
                        currentTable: table,
                        referencedTable:
                            $MediaReferences._narrativeRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $MediaReferences(db, table, p0).narrativeRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.mediaID == item.primaryId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $MediaProcessedTableManager = ProcessedTableManager<
    _$Database,
    Media,
    MediaData,
    $MediaFilterComposer,
    $MediaOrderingComposer,
    $MediaAnnotationComposer,
    $MediaCreateCompanionBuilder,
    $MediaUpdateCompanionBuilder,
    (MediaData, $MediaReferences),
    MediaData,
    PrefetchHooks Function({bool narrativeRefs})>;
typedef $SiteCreateCompanionBuilder = SiteCompanion Function({
  Value<int> id,
  Value<String?> siteID,
  Value<String?> projectUuid,
  Value<String?> leadStaffId,
  Value<String?> siteType,
  Value<String?> country,
  Value<String?> stateProvince,
  Value<String?> county,
  Value<String?> municipality,
  Value<String?> mediaID,
  Value<String?> locality,
  Value<String?> remark,
  Value<String?> habitatType,
  Value<String?> habitatCondition,
  Value<String?> habitatDescription,
});
typedef $SiteUpdateCompanionBuilder = SiteCompanion Function({
  Value<int> id,
  Value<String?> siteID,
  Value<String?> projectUuid,
  Value<String?> leadStaffId,
  Value<String?> siteType,
  Value<String?> country,
  Value<String?> stateProvince,
  Value<String?> county,
  Value<String?> municipality,
  Value<String?> mediaID,
  Value<String?> locality,
  Value<String?> remark,
  Value<String?> habitatType,
  Value<String?> habitatCondition,
  Value<String?> habitatDescription,
});

final class $SiteReferences extends BaseReferences<_$Database, Site, SiteData> {
  $SiteReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<CollEvent, List<CollEventData>>
      _collEventRefsTable(_$Database db) =>
          MultiTypedResultKey.fromTable(db.collEvent,
              aliasName: $_aliasNameGenerator(db.site.id, db.collEvent.siteID));

  $CollEventProcessedTableManager get collEventRefs {
    final manager = $CollEventTableManager($_db, $_db.collEvent)
        .filter((f) => f.siteID.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_collEventRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $SiteFilterComposer extends Composer<_$Database, Site> {
  $SiteFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get siteID => $composableBuilder(
      column: $table.siteID, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get leadStaffId => $composableBuilder(
      column: $table.leadStaffId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get siteType => $composableBuilder(
      column: $table.siteType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get country => $composableBuilder(
      column: $table.country, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stateProvince => $composableBuilder(
      column: $table.stateProvince, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get county => $composableBuilder(
      column: $table.county, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get municipality => $composableBuilder(
      column: $table.municipality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaID => $composableBuilder(
      column: $table.mediaID, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locality => $composableBuilder(
      column: $table.locality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remark => $composableBuilder(
      column: $table.remark, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get habitatType => $composableBuilder(
      column: $table.habitatType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get habitatCondition => $composableBuilder(
      column: $table.habitatCondition,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get habitatDescription => $composableBuilder(
      column: $table.habitatDescription,
      builder: (column) => ColumnFilters(column));

  Expression<bool> collEventRefs(
      Expression<bool> Function($CollEventFilterComposer f) f) {
    final $CollEventFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.collEvent,
        getReferencedColumn: (t) => t.siteID,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $CollEventFilterComposer(
              $db: $db,
              $table: $db.collEvent,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $SiteOrderingComposer extends Composer<_$Database, Site> {
  $SiteOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get siteID => $composableBuilder(
      column: $table.siteID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get leadStaffId => $composableBuilder(
      column: $table.leadStaffId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get siteType => $composableBuilder(
      column: $table.siteType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get country => $composableBuilder(
      column: $table.country, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stateProvince => $composableBuilder(
      column: $table.stateProvince,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get county => $composableBuilder(
      column: $table.county, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get municipality => $composableBuilder(
      column: $table.municipality,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaID => $composableBuilder(
      column: $table.mediaID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locality => $composableBuilder(
      column: $table.locality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remark => $composableBuilder(
      column: $table.remark, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get habitatType => $composableBuilder(
      column: $table.habitatType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get habitatCondition => $composableBuilder(
      column: $table.habitatCondition,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get habitatDescription => $composableBuilder(
      column: $table.habitatDescription,
      builder: (column) => ColumnOrderings(column));
}

class $SiteAnnotationComposer extends Composer<_$Database, Site> {
  $SiteAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get siteID =>
      $composableBuilder(column: $table.siteID, builder: (column) => column);

  GeneratedColumn<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => column);

  GeneratedColumn<String> get leadStaffId => $composableBuilder(
      column: $table.leadStaffId, builder: (column) => column);

  GeneratedColumn<String> get siteType =>
      $composableBuilder(column: $table.siteType, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get stateProvince => $composableBuilder(
      column: $table.stateProvince, builder: (column) => column);

  GeneratedColumn<String> get county =>
      $composableBuilder(column: $table.county, builder: (column) => column);

  GeneratedColumn<String> get municipality => $composableBuilder(
      column: $table.municipality, builder: (column) => column);

  GeneratedColumn<String> get mediaID =>
      $composableBuilder(column: $table.mediaID, builder: (column) => column);

  GeneratedColumn<String> get locality =>
      $composableBuilder(column: $table.locality, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);

  GeneratedColumn<String> get habitatType => $composableBuilder(
      column: $table.habitatType, builder: (column) => column);

  GeneratedColumn<String> get habitatCondition => $composableBuilder(
      column: $table.habitatCondition, builder: (column) => column);

  GeneratedColumn<String> get habitatDescription => $composableBuilder(
      column: $table.habitatDescription, builder: (column) => column);

  Expression<T> collEventRefs<T extends Object>(
      Expression<T> Function($CollEventAnnotationComposer a) f) {
    final $CollEventAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.collEvent,
        getReferencedColumn: (t) => t.siteID,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $CollEventAnnotationComposer(
              $db: $db,
              $table: $db.collEvent,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $SiteTableManager extends RootTableManager<
    _$Database,
    Site,
    SiteData,
    $SiteFilterComposer,
    $SiteOrderingComposer,
    $SiteAnnotationComposer,
    $SiteCreateCompanionBuilder,
    $SiteUpdateCompanionBuilder,
    (SiteData, $SiteReferences),
    SiteData,
    PrefetchHooks Function({bool collEventRefs})> {
  $SiteTableManager(_$Database db, Site table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SiteFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SiteOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SiteAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> siteID = const Value.absent(),
            Value<String?> projectUuid = const Value.absent(),
            Value<String?> leadStaffId = const Value.absent(),
            Value<String?> siteType = const Value.absent(),
            Value<String?> country = const Value.absent(),
            Value<String?> stateProvince = const Value.absent(),
            Value<String?> county = const Value.absent(),
            Value<String?> municipality = const Value.absent(),
            Value<String?> mediaID = const Value.absent(),
            Value<String?> locality = const Value.absent(),
            Value<String?> remark = const Value.absent(),
            Value<String?> habitatType = const Value.absent(),
            Value<String?> habitatCondition = const Value.absent(),
            Value<String?> habitatDescription = const Value.absent(),
          }) =>
              SiteCompanion(
            id: id,
            siteID: siteID,
            projectUuid: projectUuid,
            leadStaffId: leadStaffId,
            siteType: siteType,
            country: country,
            stateProvince: stateProvince,
            county: county,
            municipality: municipality,
            mediaID: mediaID,
            locality: locality,
            remark: remark,
            habitatType: habitatType,
            habitatCondition: habitatCondition,
            habitatDescription: habitatDescription,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> siteID = const Value.absent(),
            Value<String?> projectUuid = const Value.absent(),
            Value<String?> leadStaffId = const Value.absent(),
            Value<String?> siteType = const Value.absent(),
            Value<String?> country = const Value.absent(),
            Value<String?> stateProvince = const Value.absent(),
            Value<String?> county = const Value.absent(),
            Value<String?> municipality = const Value.absent(),
            Value<String?> mediaID = const Value.absent(),
            Value<String?> locality = const Value.absent(),
            Value<String?> remark = const Value.absent(),
            Value<String?> habitatType = const Value.absent(),
            Value<String?> habitatCondition = const Value.absent(),
            Value<String?> habitatDescription = const Value.absent(),
          }) =>
              SiteCompanion.insert(
            id: id,
            siteID: siteID,
            projectUuid: projectUuid,
            leadStaffId: leadStaffId,
            siteType: siteType,
            country: country,
            stateProvince: stateProvince,
            county: county,
            municipality: municipality,
            mediaID: mediaID,
            locality: locality,
            remark: remark,
            habitatType: habitatType,
            habitatCondition: habitatCondition,
            habitatDescription: habitatDescription,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $SiteReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({collEventRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (collEventRefs) db.collEvent],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (collEventRefs)
                    await $_getPrefetchedData<SiteData, Site, CollEventData>(
                        currentTable: table,
                        referencedTable:
                            $SiteReferences._collEventRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $SiteReferences(db, table, p0).collEventRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.siteID == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $SiteProcessedTableManager = ProcessedTableManager<
    _$Database,
    Site,
    SiteData,
    $SiteFilterComposer,
    $SiteOrderingComposer,
    $SiteAnnotationComposer,
    $SiteCreateCompanionBuilder,
    $SiteUpdateCompanionBuilder,
    (SiteData, $SiteReferences),
    SiteData,
    PrefetchHooks Function({bool collEventRefs})>;
typedef $CoordinateCreateCompanionBuilder = CoordinateCompanion Function({
  Value<int?> id,
  Value<String?> nameId,
  Value<double?> decimalLatitude,
  Value<double?> decimalLongitude,
  Value<double?> elevationInMeter,
  Value<String?> datum,
  Value<int?> uncertaintyInMeters,
  Value<String?> gpsUnit,
  Value<String?> notes,
  Value<int?> siteID,
});
typedef $CoordinateUpdateCompanionBuilder = CoordinateCompanion Function({
  Value<int?> id,
  Value<String?> nameId,
  Value<double?> decimalLatitude,
  Value<double?> decimalLongitude,
  Value<double?> elevationInMeter,
  Value<String?> datum,
  Value<int?> uncertaintyInMeters,
  Value<String?> gpsUnit,
  Value<String?> notes,
  Value<int?> siteID,
});

class $CoordinateFilterComposer extends Composer<_$Database, Coordinate> {
  $CoordinateFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameId => $composableBuilder(
      column: $table.nameId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get decimalLatitude => $composableBuilder(
      column: $table.decimalLatitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get decimalLongitude => $composableBuilder(
      column: $table.decimalLongitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get elevationInMeter => $composableBuilder(
      column: $table.elevationInMeter,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get datum => $composableBuilder(
      column: $table.datum, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get uncertaintyInMeters => $composableBuilder(
      column: $table.uncertaintyInMeters,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gpsUnit => $composableBuilder(
      column: $table.gpsUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get siteID => $composableBuilder(
      column: $table.siteID, builder: (column) => ColumnFilters(column));
}

class $CoordinateOrderingComposer extends Composer<_$Database, Coordinate> {
  $CoordinateOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameId => $composableBuilder(
      column: $table.nameId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get decimalLatitude => $composableBuilder(
      column: $table.decimalLatitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get decimalLongitude => $composableBuilder(
      column: $table.decimalLongitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get elevationInMeter => $composableBuilder(
      column: $table.elevationInMeter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get datum => $composableBuilder(
      column: $table.datum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get uncertaintyInMeters => $composableBuilder(
      column: $table.uncertaintyInMeters,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gpsUnit => $composableBuilder(
      column: $table.gpsUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get siteID => $composableBuilder(
      column: $table.siteID, builder: (column) => ColumnOrderings(column));
}

class $CoordinateAnnotationComposer extends Composer<_$Database, Coordinate> {
  $CoordinateAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameId =>
      $composableBuilder(column: $table.nameId, builder: (column) => column);

  GeneratedColumn<double> get decimalLatitude => $composableBuilder(
      column: $table.decimalLatitude, builder: (column) => column);

  GeneratedColumn<double> get decimalLongitude => $composableBuilder(
      column: $table.decimalLongitude, builder: (column) => column);

  GeneratedColumn<double> get elevationInMeter => $composableBuilder(
      column: $table.elevationInMeter, builder: (column) => column);

  GeneratedColumn<String> get datum =>
      $composableBuilder(column: $table.datum, builder: (column) => column);

  GeneratedColumn<int> get uncertaintyInMeters => $composableBuilder(
      column: $table.uncertaintyInMeters, builder: (column) => column);

  GeneratedColumn<String> get gpsUnit =>
      $composableBuilder(column: $table.gpsUnit, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get siteID =>
      $composableBuilder(column: $table.siteID, builder: (column) => column);
}

class $CoordinateTableManager extends RootTableManager<
    _$Database,
    Coordinate,
    CoordinateData,
    $CoordinateFilterComposer,
    $CoordinateOrderingComposer,
    $CoordinateAnnotationComposer,
    $CoordinateCreateCompanionBuilder,
    $CoordinateUpdateCompanionBuilder,
    (CoordinateData, BaseReferences<_$Database, Coordinate, CoordinateData>),
    CoordinateData,
    PrefetchHooks Function()> {
  $CoordinateTableManager(_$Database db, Coordinate table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CoordinateFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CoordinateOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CoordinateAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int?> id = const Value.absent(),
            Value<String?> nameId = const Value.absent(),
            Value<double?> decimalLatitude = const Value.absent(),
            Value<double?> decimalLongitude = const Value.absent(),
            Value<double?> elevationInMeter = const Value.absent(),
            Value<String?> datum = const Value.absent(),
            Value<int?> uncertaintyInMeters = const Value.absent(),
            Value<String?> gpsUnit = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> siteID = const Value.absent(),
          }) =>
              CoordinateCompanion(
            id: id,
            nameId: nameId,
            decimalLatitude: decimalLatitude,
            decimalLongitude: decimalLongitude,
            elevationInMeter: elevationInMeter,
            datum: datum,
            uncertaintyInMeters: uncertaintyInMeters,
            gpsUnit: gpsUnit,
            notes: notes,
            siteID: siteID,
          ),
          createCompanionCallback: ({
            Value<int?> id = const Value.absent(),
            Value<String?> nameId = const Value.absent(),
            Value<double?> decimalLatitude = const Value.absent(),
            Value<double?> decimalLongitude = const Value.absent(),
            Value<double?> elevationInMeter = const Value.absent(),
            Value<String?> datum = const Value.absent(),
            Value<int?> uncertaintyInMeters = const Value.absent(),
            Value<String?> gpsUnit = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> siteID = const Value.absent(),
          }) =>
              CoordinateCompanion.insert(
            id: id,
            nameId: nameId,
            decimalLatitude: decimalLatitude,
            decimalLongitude: decimalLongitude,
            elevationInMeter: elevationInMeter,
            datum: datum,
            uncertaintyInMeters: uncertaintyInMeters,
            gpsUnit: gpsUnit,
            notes: notes,
            siteID: siteID,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $CoordinateProcessedTableManager = ProcessedTableManager<
    _$Database,
    Coordinate,
    CoordinateData,
    $CoordinateFilterComposer,
    $CoordinateOrderingComposer,
    $CoordinateAnnotationComposer,
    $CoordinateCreateCompanionBuilder,
    $CoordinateUpdateCompanionBuilder,
    (CoordinateData, BaseReferences<_$Database, Coordinate, CoordinateData>),
    CoordinateData,
    PrefetchHooks Function()>;
typedef $CollEventCreateCompanionBuilder = CollEventCompanion Function({
  Value<int> id,
  Value<String?> idSuffix,
  Value<String?> projectUuid,
  Value<String?> startDate,
  Value<String?> startTime,
  Value<String?> endDate,
  Value<String?> endTime,
  Value<String?> primaryCollMethod,
  Value<String?> collMethodNotes,
  Value<int?> siteID,
});
typedef $CollEventUpdateCompanionBuilder = CollEventCompanion Function({
  Value<int> id,
  Value<String?> idSuffix,
  Value<String?> projectUuid,
  Value<String?> startDate,
  Value<String?> startTime,
  Value<String?> endDate,
  Value<String?> endTime,
  Value<String?> primaryCollMethod,
  Value<String?> collMethodNotes,
  Value<int?> siteID,
});

final class $CollEventReferences
    extends BaseReferences<_$Database, CollEvent, CollEventData> {
  $CollEventReferences(super.$_db, super.$_table, super.$_typedResult);

  static Site _siteIDTable(_$Database db) => db.site
      .createAlias($_aliasNameGenerator(db.collEvent.siteID, db.site.id));

  $SiteProcessedTableManager? get siteID {
    final $_column = $_itemColumn<int>('siteID');
    if ($_column == null) return null;
    final manager = $SiteTableManager($_db, $_db.site)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_siteIDTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $CollEventFilterComposer extends Composer<_$Database, CollEvent> {
  $CollEventFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idSuffix => $composableBuilder(
      column: $table.idSuffix, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get primaryCollMethod => $composableBuilder(
      column: $table.primaryCollMethod,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collMethodNotes => $composableBuilder(
      column: $table.collMethodNotes,
      builder: (column) => ColumnFilters(column));

  $SiteFilterComposer get siteID {
    final $SiteFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteID,
        referencedTable: $db.site,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $SiteFilterComposer(
              $db: $db,
              $table: $db.site,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $CollEventOrderingComposer extends Composer<_$Database, CollEvent> {
  $CollEventOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idSuffix => $composableBuilder(
      column: $table.idSuffix, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get primaryCollMethod => $composableBuilder(
      column: $table.primaryCollMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collMethodNotes => $composableBuilder(
      column: $table.collMethodNotes,
      builder: (column) => ColumnOrderings(column));

  $SiteOrderingComposer get siteID {
    final $SiteOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteID,
        referencedTable: $db.site,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $SiteOrderingComposer(
              $db: $db,
              $table: $db.site,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $CollEventAnnotationComposer extends Composer<_$Database, CollEvent> {
  $CollEventAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get idSuffix =>
      $composableBuilder(column: $table.idSuffix, builder: (column) => column);

  GeneratedColumn<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get primaryCollMethod => $composableBuilder(
      column: $table.primaryCollMethod, builder: (column) => column);

  GeneratedColumn<String> get collMethodNotes => $composableBuilder(
      column: $table.collMethodNotes, builder: (column) => column);

  $SiteAnnotationComposer get siteID {
    final $SiteAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.siteID,
        referencedTable: $db.site,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $SiteAnnotationComposer(
              $db: $db,
              $table: $db.site,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $CollEventTableManager extends RootTableManager<
    _$Database,
    CollEvent,
    CollEventData,
    $CollEventFilterComposer,
    $CollEventOrderingComposer,
    $CollEventAnnotationComposer,
    $CollEventCreateCompanionBuilder,
    $CollEventUpdateCompanionBuilder,
    (CollEventData, $CollEventReferences),
    CollEventData,
    PrefetchHooks Function({bool siteID})> {
  $CollEventTableManager(_$Database db, CollEvent table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CollEventFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CollEventOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CollEventAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> idSuffix = const Value.absent(),
            Value<String?> projectUuid = const Value.absent(),
            Value<String?> startDate = const Value.absent(),
            Value<String?> startTime = const Value.absent(),
            Value<String?> endDate = const Value.absent(),
            Value<String?> endTime = const Value.absent(),
            Value<String?> primaryCollMethod = const Value.absent(),
            Value<String?> collMethodNotes = const Value.absent(),
            Value<int?> siteID = const Value.absent(),
          }) =>
              CollEventCompanion(
            id: id,
            idSuffix: idSuffix,
            projectUuid: projectUuid,
            startDate: startDate,
            startTime: startTime,
            endDate: endDate,
            endTime: endTime,
            primaryCollMethod: primaryCollMethod,
            collMethodNotes: collMethodNotes,
            siteID: siteID,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> idSuffix = const Value.absent(),
            Value<String?> projectUuid = const Value.absent(),
            Value<String?> startDate = const Value.absent(),
            Value<String?> startTime = const Value.absent(),
            Value<String?> endDate = const Value.absent(),
            Value<String?> endTime = const Value.absent(),
            Value<String?> primaryCollMethod = const Value.absent(),
            Value<String?> collMethodNotes = const Value.absent(),
            Value<int?> siteID = const Value.absent(),
          }) =>
              CollEventCompanion.insert(
            id: id,
            idSuffix: idSuffix,
            projectUuid: projectUuid,
            startDate: startDate,
            startTime: startTime,
            endDate: endDate,
            endTime: endTime,
            primaryCollMethod: primaryCollMethod,
            collMethodNotes: collMethodNotes,
            siteID: siteID,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $CollEventReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({siteID = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (siteID) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.siteID,
                    referencedTable: $CollEventReferences._siteIDTable(db),
                    referencedColumn: $CollEventReferences._siteIDTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $CollEventProcessedTableManager = ProcessedTableManager<
    _$Database,
    CollEvent,
    CollEventData,
    $CollEventFilterComposer,
    $CollEventOrderingComposer,
    $CollEventAnnotationComposer,
    $CollEventCreateCompanionBuilder,
    $CollEventUpdateCompanionBuilder,
    (CollEventData, $CollEventReferences),
    CollEventData,
    PrefetchHooks Function({bool siteID})>;
typedef $WeatherCreateCompanionBuilder = WeatherCompanion Function({
  Value<int?> eventID,
  Value<double?> lowestDayTempC,
  Value<double?> highestDayTempC,
  Value<double?> lowestNightTempC,
  Value<double?> highestNightTempC,
  Value<double?> averageHumidity,
  Value<double?> dewPointTemp,
  Value<String?> sunriseTime,
  Value<String?> sunsetTime,
  Value<String?> moonPhase,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $WeatherUpdateCompanionBuilder = WeatherCompanion Function({
  Value<int?> eventID,
  Value<double?> lowestDayTempC,
  Value<double?> highestDayTempC,
  Value<double?> lowestNightTempC,
  Value<double?> highestNightTempC,
  Value<double?> averageHumidity,
  Value<double?> dewPointTemp,
  Value<String?> sunriseTime,
  Value<String?> sunsetTime,
  Value<String?> moonPhase,
  Value<String?> notes,
  Value<int> rowid,
});

class $WeatherFilterComposer extends Composer<_$Database, Weather> {
  $WeatherFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get eventID => $composableBuilder(
      column: $table.eventID, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lowestDayTempC => $composableBuilder(
      column: $table.lowestDayTempC,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get highestDayTempC => $composableBuilder(
      column: $table.highestDayTempC,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lowestNightTempC => $composableBuilder(
      column: $table.lowestNightTempC,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get highestNightTempC => $composableBuilder(
      column: $table.highestNightTempC,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get averageHumidity => $composableBuilder(
      column: $table.averageHumidity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get dewPointTemp => $composableBuilder(
      column: $table.dewPointTemp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sunriseTime => $composableBuilder(
      column: $table.sunriseTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sunsetTime => $composableBuilder(
      column: $table.sunsetTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get moonPhase => $composableBuilder(
      column: $table.moonPhase, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $WeatherOrderingComposer extends Composer<_$Database, Weather> {
  $WeatherOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get eventID => $composableBuilder(
      column: $table.eventID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lowestDayTempC => $composableBuilder(
      column: $table.lowestDayTempC,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get highestDayTempC => $composableBuilder(
      column: $table.highestDayTempC,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lowestNightTempC => $composableBuilder(
      column: $table.lowestNightTempC,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get highestNightTempC => $composableBuilder(
      column: $table.highestNightTempC,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get averageHumidity => $composableBuilder(
      column: $table.averageHumidity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get dewPointTemp => $composableBuilder(
      column: $table.dewPointTemp,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sunriseTime => $composableBuilder(
      column: $table.sunriseTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sunsetTime => $composableBuilder(
      column: $table.sunsetTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get moonPhase => $composableBuilder(
      column: $table.moonPhase, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $WeatherAnnotationComposer extends Composer<_$Database, Weather> {
  $WeatherAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get eventID =>
      $composableBuilder(column: $table.eventID, builder: (column) => column);

  GeneratedColumn<double> get lowestDayTempC => $composableBuilder(
      column: $table.lowestDayTempC, builder: (column) => column);

  GeneratedColumn<double> get highestDayTempC => $composableBuilder(
      column: $table.highestDayTempC, builder: (column) => column);

  GeneratedColumn<double> get lowestNightTempC => $composableBuilder(
      column: $table.lowestNightTempC, builder: (column) => column);

  GeneratedColumn<double> get highestNightTempC => $composableBuilder(
      column: $table.highestNightTempC, builder: (column) => column);

  GeneratedColumn<double> get averageHumidity => $composableBuilder(
      column: $table.averageHumidity, builder: (column) => column);

  GeneratedColumn<double> get dewPointTemp => $composableBuilder(
      column: $table.dewPointTemp, builder: (column) => column);

  GeneratedColumn<String> get sunriseTime => $composableBuilder(
      column: $table.sunriseTime, builder: (column) => column);

  GeneratedColumn<String> get sunsetTime => $composableBuilder(
      column: $table.sunsetTime, builder: (column) => column);

  GeneratedColumn<String> get moonPhase =>
      $composableBuilder(column: $table.moonPhase, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $WeatherTableManager extends RootTableManager<
    _$Database,
    Weather,
    WeatherData,
    $WeatherFilterComposer,
    $WeatherOrderingComposer,
    $WeatherAnnotationComposer,
    $WeatherCreateCompanionBuilder,
    $WeatherUpdateCompanionBuilder,
    (WeatherData, BaseReferences<_$Database, Weather, WeatherData>),
    WeatherData,
    PrefetchHooks Function()> {
  $WeatherTableManager(_$Database db, Weather table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $WeatherFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $WeatherOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $WeatherAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int?> eventID = const Value.absent(),
            Value<double?> lowestDayTempC = const Value.absent(),
            Value<double?> highestDayTempC = const Value.absent(),
            Value<double?> lowestNightTempC = const Value.absent(),
            Value<double?> highestNightTempC = const Value.absent(),
            Value<double?> averageHumidity = const Value.absent(),
            Value<double?> dewPointTemp = const Value.absent(),
            Value<String?> sunriseTime = const Value.absent(),
            Value<String?> sunsetTime = const Value.absent(),
            Value<String?> moonPhase = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeatherCompanion(
            eventID: eventID,
            lowestDayTempC: lowestDayTempC,
            highestDayTempC: highestDayTempC,
            lowestNightTempC: lowestNightTempC,
            highestNightTempC: highestNightTempC,
            averageHumidity: averageHumidity,
            dewPointTemp: dewPointTemp,
            sunriseTime: sunriseTime,
            sunsetTime: sunsetTime,
            moonPhase: moonPhase,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<int?> eventID = const Value.absent(),
            Value<double?> lowestDayTempC = const Value.absent(),
            Value<double?> highestDayTempC = const Value.absent(),
            Value<double?> lowestNightTempC = const Value.absent(),
            Value<double?> highestNightTempC = const Value.absent(),
            Value<double?> averageHumidity = const Value.absent(),
            Value<double?> dewPointTemp = const Value.absent(),
            Value<String?> sunriseTime = const Value.absent(),
            Value<String?> sunsetTime = const Value.absent(),
            Value<String?> moonPhase = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeatherCompanion.insert(
            eventID: eventID,
            lowestDayTempC: lowestDayTempC,
            highestDayTempC: highestDayTempC,
            lowestNightTempC: lowestNightTempC,
            highestNightTempC: highestNightTempC,
            averageHumidity: averageHumidity,
            dewPointTemp: dewPointTemp,
            sunriseTime: sunriseTime,
            sunsetTime: sunsetTime,
            moonPhase: moonPhase,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $WeatherProcessedTableManager = ProcessedTableManager<
    _$Database,
    Weather,
    WeatherData,
    $WeatherFilterComposer,
    $WeatherOrderingComposer,
    $WeatherAnnotationComposer,
    $WeatherCreateCompanionBuilder,
    $WeatherUpdateCompanionBuilder,
    (WeatherData, BaseReferences<_$Database, Weather, WeatherData>),
    WeatherData,
    PrefetchHooks Function()>;
typedef $CollPersonnelCreateCompanionBuilder = CollPersonnelCompanion Function({
  Value<int> id,
  Value<int?> eventID,
  Value<String?> personnelId,
  Value<String?> name,
  Value<String?> role,
});
typedef $CollPersonnelUpdateCompanionBuilder = CollPersonnelCompanion Function({
  Value<int> id,
  Value<int?> eventID,
  Value<String?> personnelId,
  Value<String?> name,
  Value<String?> role,
});

class $CollPersonnelFilterComposer extends Composer<_$Database, CollPersonnel> {
  $CollPersonnelFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get eventID => $composableBuilder(
      column: $table.eventID, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personnelId => $composableBuilder(
      column: $table.personnelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));
}

class $CollPersonnelOrderingComposer
    extends Composer<_$Database, CollPersonnel> {
  $CollPersonnelOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get eventID => $composableBuilder(
      column: $table.eventID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personnelId => $composableBuilder(
      column: $table.personnelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));
}

class $CollPersonnelAnnotationComposer
    extends Composer<_$Database, CollPersonnel> {
  $CollPersonnelAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get eventID =>
      $composableBuilder(column: $table.eventID, builder: (column) => column);

  GeneratedColumn<String> get personnelId => $composableBuilder(
      column: $table.personnelId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);
}

class $CollPersonnelTableManager extends RootTableManager<
    _$Database,
    CollPersonnel,
    CollPersonnelData,
    $CollPersonnelFilterComposer,
    $CollPersonnelOrderingComposer,
    $CollPersonnelAnnotationComposer,
    $CollPersonnelCreateCompanionBuilder,
    $CollPersonnelUpdateCompanionBuilder,
    (
      CollPersonnelData,
      BaseReferences<_$Database, CollPersonnel, CollPersonnelData>
    ),
    CollPersonnelData,
    PrefetchHooks Function()> {
  $CollPersonnelTableManager(_$Database db, CollPersonnel table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CollPersonnelFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CollPersonnelOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CollPersonnelAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> eventID = const Value.absent(),
            Value<String?> personnelId = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> role = const Value.absent(),
          }) =>
              CollPersonnelCompanion(
            id: id,
            eventID: eventID,
            personnelId: personnelId,
            name: name,
            role: role,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> eventID = const Value.absent(),
            Value<String?> personnelId = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> role = const Value.absent(),
          }) =>
              CollPersonnelCompanion.insert(
            id: id,
            eventID: eventID,
            personnelId: personnelId,
            name: name,
            role: role,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $CollPersonnelProcessedTableManager = ProcessedTableManager<
    _$Database,
    CollPersonnel,
    CollPersonnelData,
    $CollPersonnelFilterComposer,
    $CollPersonnelOrderingComposer,
    $CollPersonnelAnnotationComposer,
    $CollPersonnelCreateCompanionBuilder,
    $CollPersonnelUpdateCompanionBuilder,
    (
      CollPersonnelData,
      BaseReferences<_$Database, CollPersonnel, CollPersonnelData>
    ),
    CollPersonnelData,
    PrefetchHooks Function()>;
typedef $CollEffortCreateCompanionBuilder = CollEffortCompanion Function({
  Value<int> id,
  Value<int?> eventID,
  Value<String?> method,
  Value<String?> brand,
  Value<int?> count,
  Value<String?> size,
  Value<String?> notes,
});
typedef $CollEffortUpdateCompanionBuilder = CollEffortCompanion Function({
  Value<int> id,
  Value<int?> eventID,
  Value<String?> method,
  Value<String?> brand,
  Value<int?> count,
  Value<String?> size,
  Value<String?> notes,
});

class $CollEffortFilterComposer extends Composer<_$Database, CollEffort> {
  $CollEffortFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get eventID => $composableBuilder(
      column: $table.eventID, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $CollEffortOrderingComposer extends Composer<_$Database, CollEffort> {
  $CollEffortOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get eventID => $composableBuilder(
      column: $table.eventID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $CollEffortAnnotationComposer extends Composer<_$Database, CollEffort> {
  $CollEffortAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get eventID =>
      $composableBuilder(column: $table.eventID, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $CollEffortTableManager extends RootTableManager<
    _$Database,
    CollEffort,
    CollEffortData,
    $CollEffortFilterComposer,
    $CollEffortOrderingComposer,
    $CollEffortAnnotationComposer,
    $CollEffortCreateCompanionBuilder,
    $CollEffortUpdateCompanionBuilder,
    (CollEffortData, BaseReferences<_$Database, CollEffort, CollEffortData>),
    CollEffortData,
    PrefetchHooks Function()> {
  $CollEffortTableManager(_$Database db, CollEffort table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CollEffortFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CollEffortOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CollEffortAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> eventID = const Value.absent(),
            Value<String?> method = const Value.absent(),
            Value<String?> brand = const Value.absent(),
            Value<int?> count = const Value.absent(),
            Value<String?> size = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              CollEffortCompanion(
            id: id,
            eventID: eventID,
            method: method,
            brand: brand,
            count: count,
            size: size,
            notes: notes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> eventID = const Value.absent(),
            Value<String?> method = const Value.absent(),
            Value<String?> brand = const Value.absent(),
            Value<int?> count = const Value.absent(),
            Value<String?> size = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              CollEffortCompanion.insert(
            id: id,
            eventID: eventID,
            method: method,
            brand: brand,
            count: count,
            size: size,
            notes: notes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $CollEffortProcessedTableManager = ProcessedTableManager<
    _$Database,
    CollEffort,
    CollEffortData,
    $CollEffortFilterComposer,
    $CollEffortOrderingComposer,
    $CollEffortAnnotationComposer,
    $CollEffortCreateCompanionBuilder,
    $CollEffortUpdateCompanionBuilder,
    (CollEffortData, BaseReferences<_$Database, CollEffort, CollEffortData>),
    CollEffortData,
    PrefetchHooks Function()>;
typedef $NarrativeCreateCompanionBuilder = NarrativeCompanion Function({
  Value<int> id,
  Value<String?> projectUuid,
  Value<String?> date,
  Value<int?> siteID,
  Value<String?> narrative,
  Value<int?> mediaID,
});
typedef $NarrativeUpdateCompanionBuilder = NarrativeCompanion Function({
  Value<int> id,
  Value<String?> projectUuid,
  Value<String?> date,
  Value<int?> siteID,
  Value<String?> narrative,
  Value<int?> mediaID,
});

final class $NarrativeReferences
    extends BaseReferences<_$Database, Narrative, NarrativeData> {
  $NarrativeReferences(super.$_db, super.$_table, super.$_typedResult);

  static Media _mediaIDTable(_$Database db) => db.media.createAlias(
      $_aliasNameGenerator(db.narrative.mediaID, db.media.primaryId));

  $MediaProcessedTableManager? get mediaID {
    final $_column = $_itemColumn<int>('mediaID');
    if ($_column == null) return null;
    final manager = $MediaTableManager($_db, $_db.media)
        .filter((f) => f.primaryId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIDTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $NarrativeFilterComposer extends Composer<_$Database, Narrative> {
  $NarrativeFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get siteID => $composableBuilder(
      column: $table.siteID, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get narrative => $composableBuilder(
      column: $table.narrative, builder: (column) => ColumnFilters(column));

  $MediaFilterComposer get mediaID {
    final $MediaFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaID,
        referencedTable: $db.media,
        getReferencedColumn: (t) => t.primaryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $MediaFilterComposer(
              $db: $db,
              $table: $db.media,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $NarrativeOrderingComposer extends Composer<_$Database, Narrative> {
  $NarrativeOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get siteID => $composableBuilder(
      column: $table.siteID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get narrative => $composableBuilder(
      column: $table.narrative, builder: (column) => ColumnOrderings(column));

  $MediaOrderingComposer get mediaID {
    final $MediaOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaID,
        referencedTable: $db.media,
        getReferencedColumn: (t) => t.primaryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $MediaOrderingComposer(
              $db: $db,
              $table: $db.media,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $NarrativeAnnotationComposer extends Composer<_$Database, Narrative> {
  $NarrativeAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get siteID =>
      $composableBuilder(column: $table.siteID, builder: (column) => column);

  GeneratedColumn<String> get narrative =>
      $composableBuilder(column: $table.narrative, builder: (column) => column);

  $MediaAnnotationComposer get mediaID {
    final $MediaAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaID,
        referencedTable: $db.media,
        getReferencedColumn: (t) => t.primaryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $MediaAnnotationComposer(
              $db: $db,
              $table: $db.media,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $NarrativeTableManager extends RootTableManager<
    _$Database,
    Narrative,
    NarrativeData,
    $NarrativeFilterComposer,
    $NarrativeOrderingComposer,
    $NarrativeAnnotationComposer,
    $NarrativeCreateCompanionBuilder,
    $NarrativeUpdateCompanionBuilder,
    (NarrativeData, $NarrativeReferences),
    NarrativeData,
    PrefetchHooks Function({bool mediaID})> {
  $NarrativeTableManager(_$Database db, Narrative table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $NarrativeFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $NarrativeOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $NarrativeAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> projectUuid = const Value.absent(),
            Value<String?> date = const Value.absent(),
            Value<int?> siteID = const Value.absent(),
            Value<String?> narrative = const Value.absent(),
            Value<int?> mediaID = const Value.absent(),
          }) =>
              NarrativeCompanion(
            id: id,
            projectUuid: projectUuid,
            date: date,
            siteID: siteID,
            narrative: narrative,
            mediaID: mediaID,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> projectUuid = const Value.absent(),
            Value<String?> date = const Value.absent(),
            Value<int?> siteID = const Value.absent(),
            Value<String?> narrative = const Value.absent(),
            Value<int?> mediaID = const Value.absent(),
          }) =>
              NarrativeCompanion.insert(
            id: id,
            projectUuid: projectUuid,
            date: date,
            siteID: siteID,
            narrative: narrative,
            mediaID: mediaID,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $NarrativeReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({mediaID = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (mediaID) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mediaID,
                    referencedTable: $NarrativeReferences._mediaIDTable(db),
                    referencedColumn:
                        $NarrativeReferences._mediaIDTable(db).primaryId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $NarrativeProcessedTableManager = ProcessedTableManager<
    _$Database,
    Narrative,
    NarrativeData,
    $NarrativeFilterComposer,
    $NarrativeOrderingComposer,
    $NarrativeAnnotationComposer,
    $NarrativeCreateCompanionBuilder,
    $NarrativeUpdateCompanionBuilder,
    (NarrativeData, $NarrativeReferences),
    NarrativeData,
    PrefetchHooks Function({bool mediaID})>;
typedef $NarrativeMediaCreateCompanionBuilder = NarrativeMediaCompanion
    Function({
  required int narrativeId,
  Value<int?> mediaId,
  Value<int> rowid,
});
typedef $NarrativeMediaUpdateCompanionBuilder = NarrativeMediaCompanion
    Function({
  Value<int> narrativeId,
  Value<int?> mediaId,
  Value<int> rowid,
});

class $NarrativeMediaFilterComposer
    extends Composer<_$Database, NarrativeMedia> {
  $NarrativeMediaFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get narrativeId => $composableBuilder(
      column: $table.narrativeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnFilters(column));
}

class $NarrativeMediaOrderingComposer
    extends Composer<_$Database, NarrativeMedia> {
  $NarrativeMediaOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get narrativeId => $composableBuilder(
      column: $table.narrativeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnOrderings(column));
}

class $NarrativeMediaAnnotationComposer
    extends Composer<_$Database, NarrativeMedia> {
  $NarrativeMediaAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get narrativeId => $composableBuilder(
      column: $table.narrativeId, builder: (column) => column);

  GeneratedColumn<int> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);
}

class $NarrativeMediaTableManager extends RootTableManager<
    _$Database,
    NarrativeMedia,
    NarrativeMediaData,
    $NarrativeMediaFilterComposer,
    $NarrativeMediaOrderingComposer,
    $NarrativeMediaAnnotationComposer,
    $NarrativeMediaCreateCompanionBuilder,
    $NarrativeMediaUpdateCompanionBuilder,
    (
      NarrativeMediaData,
      BaseReferences<_$Database, NarrativeMedia, NarrativeMediaData>
    ),
    NarrativeMediaData,
    PrefetchHooks Function()> {
  $NarrativeMediaTableManager(_$Database db, NarrativeMedia table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $NarrativeMediaFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $NarrativeMediaOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $NarrativeMediaAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> narrativeId = const Value.absent(),
            Value<int?> mediaId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NarrativeMediaCompanion(
            narrativeId: narrativeId,
            mediaId: mediaId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int narrativeId,
            Value<int?> mediaId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NarrativeMediaCompanion.insert(
            narrativeId: narrativeId,
            mediaId: mediaId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $NarrativeMediaProcessedTableManager = ProcessedTableManager<
    _$Database,
    NarrativeMedia,
    NarrativeMediaData,
    $NarrativeMediaFilterComposer,
    $NarrativeMediaOrderingComposer,
    $NarrativeMediaAnnotationComposer,
    $NarrativeMediaCreateCompanionBuilder,
    $NarrativeMediaUpdateCompanionBuilder,
    (
      NarrativeMediaData,
      BaseReferences<_$Database, NarrativeMedia, NarrativeMediaData>
    ),
    NarrativeMediaData,
    PrefetchHooks Function()>;
typedef $SiteMediaCreateCompanionBuilder = SiteMediaCompanion Function({
  required int siteId,
  Value<int?> mediaId,
  Value<int> rowid,
});
typedef $SiteMediaUpdateCompanionBuilder = SiteMediaCompanion Function({
  Value<int> siteId,
  Value<int?> mediaId,
  Value<int> rowid,
});

class $SiteMediaFilterComposer extends Composer<_$Database, SiteMedia> {
  $SiteMediaFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get siteId => $composableBuilder(
      column: $table.siteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnFilters(column));
}

class $SiteMediaOrderingComposer extends Composer<_$Database, SiteMedia> {
  $SiteMediaOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get siteId => $composableBuilder(
      column: $table.siteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnOrderings(column));
}

class $SiteMediaAnnotationComposer extends Composer<_$Database, SiteMedia> {
  $SiteMediaAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<int> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);
}

class $SiteMediaTableManager extends RootTableManager<
    _$Database,
    SiteMedia,
    SiteMediaData,
    $SiteMediaFilterComposer,
    $SiteMediaOrderingComposer,
    $SiteMediaAnnotationComposer,
    $SiteMediaCreateCompanionBuilder,
    $SiteMediaUpdateCompanionBuilder,
    (SiteMediaData, BaseReferences<_$Database, SiteMedia, SiteMediaData>),
    SiteMediaData,
    PrefetchHooks Function()> {
  $SiteMediaTableManager(_$Database db, SiteMedia table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SiteMediaFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SiteMediaOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SiteMediaAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> siteId = const Value.absent(),
            Value<int?> mediaId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SiteMediaCompanion(
            siteId: siteId,
            mediaId: mediaId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int siteId,
            Value<int?> mediaId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SiteMediaCompanion.insert(
            siteId: siteId,
            mediaId: mediaId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $SiteMediaProcessedTableManager = ProcessedTableManager<
    _$Database,
    SiteMedia,
    SiteMediaData,
    $SiteMediaFilterComposer,
    $SiteMediaOrderingComposer,
    $SiteMediaAnnotationComposer,
    $SiteMediaCreateCompanionBuilder,
    $SiteMediaUpdateCompanionBuilder,
    (SiteMediaData, BaseReferences<_$Database, SiteMedia, SiteMediaData>),
    SiteMediaData,
    PrefetchHooks Function()>;
typedef $TaxonomyCreateCompanionBuilder = TaxonomyCompanion Function({
  Value<int> id,
  Value<String?> taxonClass,
  Value<String?> taxonOrder,
  Value<String?> taxonFamily,
  Value<String?> genus,
  Value<String?> specificEpithet,
  Value<String?> authors,
  Value<String?> commonName,
  Value<String?> notes,
  Value<String?> citesStatus,
  Value<String?> redListCategory,
  Value<String?> countryStatus,
  Value<int?> sortingOrder,
  Value<int?> mediaId,
});
typedef $TaxonomyUpdateCompanionBuilder = TaxonomyCompanion Function({
  Value<int> id,
  Value<String?> taxonClass,
  Value<String?> taxonOrder,
  Value<String?> taxonFamily,
  Value<String?> genus,
  Value<String?> specificEpithet,
  Value<String?> authors,
  Value<String?> commonName,
  Value<String?> notes,
  Value<String?> citesStatus,
  Value<String?> redListCategory,
  Value<String?> countryStatus,
  Value<int?> sortingOrder,
  Value<int?> mediaId,
});

class $TaxonomyFilterComposer extends Composer<_$Database, Taxonomy> {
  $TaxonomyFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxonClass => $composableBuilder(
      column: $table.taxonClass, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxonOrder => $composableBuilder(
      column: $table.taxonOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxonFamily => $composableBuilder(
      column: $table.taxonFamily, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get genus => $composableBuilder(
      column: $table.genus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specificEpithet => $composableBuilder(
      column: $table.specificEpithet,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authors => $composableBuilder(
      column: $table.authors, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commonName => $composableBuilder(
      column: $table.commonName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get citesStatus => $composableBuilder(
      column: $table.citesStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get redListCategory => $composableBuilder(
      column: $table.redListCategory,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get countryStatus => $composableBuilder(
      column: $table.countryStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortingOrder => $composableBuilder(
      column: $table.sortingOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnFilters(column));
}

class $TaxonomyOrderingComposer extends Composer<_$Database, Taxonomy> {
  $TaxonomyOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxonClass => $composableBuilder(
      column: $table.taxonClass, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxonOrder => $composableBuilder(
      column: $table.taxonOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxonFamily => $composableBuilder(
      column: $table.taxonFamily, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get genus => $composableBuilder(
      column: $table.genus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specificEpithet => $composableBuilder(
      column: $table.specificEpithet,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authors => $composableBuilder(
      column: $table.authors, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commonName => $composableBuilder(
      column: $table.commonName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get citesStatus => $composableBuilder(
      column: $table.citesStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get redListCategory => $composableBuilder(
      column: $table.redListCategory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get countryStatus => $composableBuilder(
      column: $table.countryStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortingOrder => $composableBuilder(
      column: $table.sortingOrder,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnOrderings(column));
}

class $TaxonomyAnnotationComposer extends Composer<_$Database, Taxonomy> {
  $TaxonomyAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taxonClass => $composableBuilder(
      column: $table.taxonClass, builder: (column) => column);

  GeneratedColumn<String> get taxonOrder => $composableBuilder(
      column: $table.taxonOrder, builder: (column) => column);

  GeneratedColumn<String> get taxonFamily => $composableBuilder(
      column: $table.taxonFamily, builder: (column) => column);

  GeneratedColumn<String> get genus =>
      $composableBuilder(column: $table.genus, builder: (column) => column);

  GeneratedColumn<String> get specificEpithet => $composableBuilder(
      column: $table.specificEpithet, builder: (column) => column);

  GeneratedColumn<String> get authors =>
      $composableBuilder(column: $table.authors, builder: (column) => column);

  GeneratedColumn<String> get commonName => $composableBuilder(
      column: $table.commonName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get citesStatus => $composableBuilder(
      column: $table.citesStatus, builder: (column) => column);

  GeneratedColumn<String> get redListCategory => $composableBuilder(
      column: $table.redListCategory, builder: (column) => column);

  GeneratedColumn<String> get countryStatus => $composableBuilder(
      column: $table.countryStatus, builder: (column) => column);

  GeneratedColumn<int> get sortingOrder => $composableBuilder(
      column: $table.sortingOrder, builder: (column) => column);

  GeneratedColumn<int> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);
}

class $TaxonomyTableManager extends RootTableManager<
    _$Database,
    Taxonomy,
    TaxonomyData,
    $TaxonomyFilterComposer,
    $TaxonomyOrderingComposer,
    $TaxonomyAnnotationComposer,
    $TaxonomyCreateCompanionBuilder,
    $TaxonomyUpdateCompanionBuilder,
    (TaxonomyData, BaseReferences<_$Database, Taxonomy, TaxonomyData>),
    TaxonomyData,
    PrefetchHooks Function()> {
  $TaxonomyTableManager(_$Database db, Taxonomy table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TaxonomyFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TaxonomyOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TaxonomyAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> taxonClass = const Value.absent(),
            Value<String?> taxonOrder = const Value.absent(),
            Value<String?> taxonFamily = const Value.absent(),
            Value<String?> genus = const Value.absent(),
            Value<String?> specificEpithet = const Value.absent(),
            Value<String?> authors = const Value.absent(),
            Value<String?> commonName = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> citesStatus = const Value.absent(),
            Value<String?> redListCategory = const Value.absent(),
            Value<String?> countryStatus = const Value.absent(),
            Value<int?> sortingOrder = const Value.absent(),
            Value<int?> mediaId = const Value.absent(),
          }) =>
              TaxonomyCompanion(
            id: id,
            taxonClass: taxonClass,
            taxonOrder: taxonOrder,
            taxonFamily: taxonFamily,
            genus: genus,
            specificEpithet: specificEpithet,
            authors: authors,
            commonName: commonName,
            notes: notes,
            citesStatus: citesStatus,
            redListCategory: redListCategory,
            countryStatus: countryStatus,
            sortingOrder: sortingOrder,
            mediaId: mediaId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> taxonClass = const Value.absent(),
            Value<String?> taxonOrder = const Value.absent(),
            Value<String?> taxonFamily = const Value.absent(),
            Value<String?> genus = const Value.absent(),
            Value<String?> specificEpithet = const Value.absent(),
            Value<String?> authors = const Value.absent(),
            Value<String?> commonName = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> citesStatus = const Value.absent(),
            Value<String?> redListCategory = const Value.absent(),
            Value<String?> countryStatus = const Value.absent(),
            Value<int?> sortingOrder = const Value.absent(),
            Value<int?> mediaId = const Value.absent(),
          }) =>
              TaxonomyCompanion.insert(
            id: id,
            taxonClass: taxonClass,
            taxonOrder: taxonOrder,
            taxonFamily: taxonFamily,
            genus: genus,
            specificEpithet: specificEpithet,
            authors: authors,
            commonName: commonName,
            notes: notes,
            citesStatus: citesStatus,
            redListCategory: redListCategory,
            countryStatus: countryStatus,
            sortingOrder: sortingOrder,
            mediaId: mediaId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $TaxonomyProcessedTableManager = ProcessedTableManager<
    _$Database,
    Taxonomy,
    TaxonomyData,
    $TaxonomyFilterComposer,
    $TaxonomyOrderingComposer,
    $TaxonomyAnnotationComposer,
    $TaxonomyCreateCompanionBuilder,
    $TaxonomyUpdateCompanionBuilder,
    (TaxonomyData, BaseReferences<_$Database, Taxonomy, TaxonomyData>),
    TaxonomyData,
    PrefetchHooks Function()>;
typedef $SpecimenCreateCompanionBuilder = SpecimenCompanion Function({
  required String uuid,
  Value<String?> projectUuid,
  Value<int?> speciesID,
  Value<int?> iDConfidence,
  Value<String?> iDMethod,
  Value<String?> taxonGroup,
  Value<String?> condition,
  Value<String?> prepDate,
  Value<String?> prepTime,
  Value<String?> collectionTime,
  Value<String?> captureDate,
  Value<int?> isRelativeTime,
  Value<String?> captureTime,
  Value<String?> trapType,
  Value<String?> methodID,
  Value<int?> coordinateID,
  Value<String?> catalogerID,
  Value<int?> fieldNumber,
  Value<int?> collEventID,
  Value<int?> isMultipleCollector,
  Value<int?> collPersonnelID,
  Value<int?> collMethodID,
  Value<String?> museumID,
  Value<String?> preparatorID,
  Value<int> rowid,
});
typedef $SpecimenUpdateCompanionBuilder = SpecimenCompanion Function({
  Value<String> uuid,
  Value<String?> projectUuid,
  Value<int?> speciesID,
  Value<int?> iDConfidence,
  Value<String?> iDMethod,
  Value<String?> taxonGroup,
  Value<String?> condition,
  Value<String?> prepDate,
  Value<String?> prepTime,
  Value<String?> collectionTime,
  Value<String?> captureDate,
  Value<int?> isRelativeTime,
  Value<String?> captureTime,
  Value<String?> trapType,
  Value<String?> methodID,
  Value<int?> coordinateID,
  Value<String?> catalogerID,
  Value<int?> fieldNumber,
  Value<int?> collEventID,
  Value<int?> isMultipleCollector,
  Value<int?> collPersonnelID,
  Value<int?> collMethodID,
  Value<String?> museumID,
  Value<String?> preparatorID,
  Value<int> rowid,
});

final class $SpecimenReferences
    extends BaseReferences<_$Database, Specimen, SpecimenData> {
  $SpecimenReferences(super.$_db, super.$_table, super.$_typedResult);

  static Personnel _preparatorIDTable(_$Database db) =>
      db.personnel.createAlias(
          $_aliasNameGenerator(db.specimen.preparatorID, db.personnel.uuid));

  $PersonnelProcessedTableManager? get preparatorID {
    final $_column = $_itemColumn<String>('preparatorID');
    if ($_column == null) return null;
    final manager = $PersonnelTableManager($_db, $_db.personnel)
        .filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_preparatorIDTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $SpecimenFilterComposer extends Composer<_$Database, Specimen> {
  $SpecimenFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get speciesID => $composableBuilder(
      column: $table.speciesID, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get iDConfidence => $composableBuilder(
      column: $table.iDConfidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iDMethod => $composableBuilder(
      column: $table.iDMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxonGroup => $composableBuilder(
      column: $table.taxonGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prepDate => $composableBuilder(
      column: $table.prepDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prepTime => $composableBuilder(
      column: $table.prepTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectionTime => $composableBuilder(
      column: $table.collectionTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get captureDate => $composableBuilder(
      column: $table.captureDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isRelativeTime => $composableBuilder(
      column: $table.isRelativeTime,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get captureTime => $composableBuilder(
      column: $table.captureTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trapType => $composableBuilder(
      column: $table.trapType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get methodID => $composableBuilder(
      column: $table.methodID, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get coordinateID => $composableBuilder(
      column: $table.coordinateID, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get catalogerID => $composableBuilder(
      column: $table.catalogerID, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fieldNumber => $composableBuilder(
      column: $table.fieldNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get collEventID => $composableBuilder(
      column: $table.collEventID, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isMultipleCollector => $composableBuilder(
      column: $table.isMultipleCollector,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get collPersonnelID => $composableBuilder(
      column: $table.collPersonnelID,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get collMethodID => $composableBuilder(
      column: $table.collMethodID, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get museumID => $composableBuilder(
      column: $table.museumID, builder: (column) => ColumnFilters(column));

  $PersonnelFilterComposer get preparatorID {
    final $PersonnelFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.preparatorID,
        referencedTable: $db.personnel,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $PersonnelFilterComposer(
              $db: $db,
              $table: $db.personnel,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $SpecimenOrderingComposer extends Composer<_$Database, Specimen> {
  $SpecimenOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
      column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get speciesID => $composableBuilder(
      column: $table.speciesID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get iDConfidence => $composableBuilder(
      column: $table.iDConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iDMethod => $composableBuilder(
      column: $table.iDMethod, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxonGroup => $composableBuilder(
      column: $table.taxonGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prepDate => $composableBuilder(
      column: $table.prepDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prepTime => $composableBuilder(
      column: $table.prepTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectionTime => $composableBuilder(
      column: $table.collectionTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get captureDate => $composableBuilder(
      column: $table.captureDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isRelativeTime => $composableBuilder(
      column: $table.isRelativeTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get captureTime => $composableBuilder(
      column: $table.captureTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trapType => $composableBuilder(
      column: $table.trapType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get methodID => $composableBuilder(
      column: $table.methodID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get coordinateID => $composableBuilder(
      column: $table.coordinateID,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get catalogerID => $composableBuilder(
      column: $table.catalogerID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fieldNumber => $composableBuilder(
      column: $table.fieldNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get collEventID => $composableBuilder(
      column: $table.collEventID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isMultipleCollector => $composableBuilder(
      column: $table.isMultipleCollector,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get collPersonnelID => $composableBuilder(
      column: $table.collPersonnelID,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get collMethodID => $composableBuilder(
      column: $table.collMethodID,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get museumID => $composableBuilder(
      column: $table.museumID, builder: (column) => ColumnOrderings(column));

  $PersonnelOrderingComposer get preparatorID {
    final $PersonnelOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.preparatorID,
        referencedTable: $db.personnel,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $PersonnelOrderingComposer(
              $db: $db,
              $table: $db.personnel,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $SpecimenAnnotationComposer extends Composer<_$Database, Specimen> {
  $SpecimenAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => column);

  GeneratedColumn<int> get speciesID =>
      $composableBuilder(column: $table.speciesID, builder: (column) => column);

  GeneratedColumn<int> get iDConfidence => $composableBuilder(
      column: $table.iDConfidence, builder: (column) => column);

  GeneratedColumn<String> get iDMethod =>
      $composableBuilder(column: $table.iDMethod, builder: (column) => column);

  GeneratedColumn<String> get taxonGroup => $composableBuilder(
      column: $table.taxonGroup, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get prepDate =>
      $composableBuilder(column: $table.prepDate, builder: (column) => column);

  GeneratedColumn<String> get prepTime =>
      $composableBuilder(column: $table.prepTime, builder: (column) => column);

  GeneratedColumn<String> get collectionTime => $composableBuilder(
      column: $table.collectionTime, builder: (column) => column);

  GeneratedColumn<String> get captureDate => $composableBuilder(
      column: $table.captureDate, builder: (column) => column);

  GeneratedColumn<int> get isRelativeTime => $composableBuilder(
      column: $table.isRelativeTime, builder: (column) => column);

  GeneratedColumn<String> get captureTime => $composableBuilder(
      column: $table.captureTime, builder: (column) => column);

  GeneratedColumn<String> get trapType =>
      $composableBuilder(column: $table.trapType, builder: (column) => column);

  GeneratedColumn<String> get methodID =>
      $composableBuilder(column: $table.methodID, builder: (column) => column);

  GeneratedColumn<int> get coordinateID => $composableBuilder(
      column: $table.coordinateID, builder: (column) => column);

  GeneratedColumn<String> get catalogerID => $composableBuilder(
      column: $table.catalogerID, builder: (column) => column);

  GeneratedColumn<int> get fieldNumber => $composableBuilder(
      column: $table.fieldNumber, builder: (column) => column);

  GeneratedColumn<int> get collEventID => $composableBuilder(
      column: $table.collEventID, builder: (column) => column);

  GeneratedColumn<int> get isMultipleCollector => $composableBuilder(
      column: $table.isMultipleCollector, builder: (column) => column);

  GeneratedColumn<int> get collPersonnelID => $composableBuilder(
      column: $table.collPersonnelID, builder: (column) => column);

  GeneratedColumn<int> get collMethodID => $composableBuilder(
      column: $table.collMethodID, builder: (column) => column);

  GeneratedColumn<String> get museumID =>
      $composableBuilder(column: $table.museumID, builder: (column) => column);

  $PersonnelAnnotationComposer get preparatorID {
    final $PersonnelAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.preparatorID,
        referencedTable: $db.personnel,
        getReferencedColumn: (t) => t.uuid,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $PersonnelAnnotationComposer(
              $db: $db,
              $table: $db.personnel,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $SpecimenTableManager extends RootTableManager<
    _$Database,
    Specimen,
    SpecimenData,
    $SpecimenFilterComposer,
    $SpecimenOrderingComposer,
    $SpecimenAnnotationComposer,
    $SpecimenCreateCompanionBuilder,
    $SpecimenUpdateCompanionBuilder,
    (SpecimenData, $SpecimenReferences),
    SpecimenData,
    PrefetchHooks Function({bool preparatorID})> {
  $SpecimenTableManager(_$Database db, Specimen table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SpecimenFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SpecimenOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SpecimenAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uuid = const Value.absent(),
            Value<String?> projectUuid = const Value.absent(),
            Value<int?> speciesID = const Value.absent(),
            Value<int?> iDConfidence = const Value.absent(),
            Value<String?> iDMethod = const Value.absent(),
            Value<String?> taxonGroup = const Value.absent(),
            Value<String?> condition = const Value.absent(),
            Value<String?> prepDate = const Value.absent(),
            Value<String?> prepTime = const Value.absent(),
            Value<String?> collectionTime = const Value.absent(),
            Value<String?> captureDate = const Value.absent(),
            Value<int?> isRelativeTime = const Value.absent(),
            Value<String?> captureTime = const Value.absent(),
            Value<String?> trapType = const Value.absent(),
            Value<String?> methodID = const Value.absent(),
            Value<int?> coordinateID = const Value.absent(),
            Value<String?> catalogerID = const Value.absent(),
            Value<int?> fieldNumber = const Value.absent(),
            Value<int?> collEventID = const Value.absent(),
            Value<int?> isMultipleCollector = const Value.absent(),
            Value<int?> collPersonnelID = const Value.absent(),
            Value<int?> collMethodID = const Value.absent(),
            Value<String?> museumID = const Value.absent(),
            Value<String?> preparatorID = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpecimenCompanion(
            uuid: uuid,
            projectUuid: projectUuid,
            speciesID: speciesID,
            iDConfidence: iDConfidence,
            iDMethod: iDMethod,
            taxonGroup: taxonGroup,
            condition: condition,
            prepDate: prepDate,
            prepTime: prepTime,
            collectionTime: collectionTime,
            captureDate: captureDate,
            isRelativeTime: isRelativeTime,
            captureTime: captureTime,
            trapType: trapType,
            methodID: methodID,
            coordinateID: coordinateID,
            catalogerID: catalogerID,
            fieldNumber: fieldNumber,
            collEventID: collEventID,
            isMultipleCollector: isMultipleCollector,
            collPersonnelID: collPersonnelID,
            collMethodID: collMethodID,
            museumID: museumID,
            preparatorID: preparatorID,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uuid,
            Value<String?> projectUuid = const Value.absent(),
            Value<int?> speciesID = const Value.absent(),
            Value<int?> iDConfidence = const Value.absent(),
            Value<String?> iDMethod = const Value.absent(),
            Value<String?> taxonGroup = const Value.absent(),
            Value<String?> condition = const Value.absent(),
            Value<String?> prepDate = const Value.absent(),
            Value<String?> prepTime = const Value.absent(),
            Value<String?> collectionTime = const Value.absent(),
            Value<String?> captureDate = const Value.absent(),
            Value<int?> isRelativeTime = const Value.absent(),
            Value<String?> captureTime = const Value.absent(),
            Value<String?> trapType = const Value.absent(),
            Value<String?> methodID = const Value.absent(),
            Value<int?> coordinateID = const Value.absent(),
            Value<String?> catalogerID = const Value.absent(),
            Value<int?> fieldNumber = const Value.absent(),
            Value<int?> collEventID = const Value.absent(),
            Value<int?> isMultipleCollector = const Value.absent(),
            Value<int?> collPersonnelID = const Value.absent(),
            Value<int?> collMethodID = const Value.absent(),
            Value<String?> museumID = const Value.absent(),
            Value<String?> preparatorID = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpecimenCompanion.insert(
            uuid: uuid,
            projectUuid: projectUuid,
            speciesID: speciesID,
            iDConfidence: iDConfidence,
            iDMethod: iDMethod,
            taxonGroup: taxonGroup,
            condition: condition,
            prepDate: prepDate,
            prepTime: prepTime,
            collectionTime: collectionTime,
            captureDate: captureDate,
            isRelativeTime: isRelativeTime,
            captureTime: captureTime,
            trapType: trapType,
            methodID: methodID,
            coordinateID: coordinateID,
            catalogerID: catalogerID,
            fieldNumber: fieldNumber,
            collEventID: collEventID,
            isMultipleCollector: isMultipleCollector,
            collPersonnelID: collPersonnelID,
            collMethodID: collMethodID,
            museumID: museumID,
            preparatorID: preparatorID,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $SpecimenReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({preparatorID = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (preparatorID) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.preparatorID,
                    referencedTable: $SpecimenReferences._preparatorIDTable(db),
                    referencedColumn:
                        $SpecimenReferences._preparatorIDTable(db).uuid,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $SpecimenProcessedTableManager = ProcessedTableManager<
    _$Database,
    Specimen,
    SpecimenData,
    $SpecimenFilterComposer,
    $SpecimenOrderingComposer,
    $SpecimenAnnotationComposer,
    $SpecimenCreateCompanionBuilder,
    $SpecimenUpdateCompanionBuilder,
    (SpecimenData, $SpecimenReferences),
    SpecimenData,
    PrefetchHooks Function({bool preparatorID})>;
typedef $SpecimenMediaCreateCompanionBuilder = SpecimenMediaCompanion Function({
  required String specimenUuid,
  Value<int?> mediaId,
  Value<int> rowid,
});
typedef $SpecimenMediaUpdateCompanionBuilder = SpecimenMediaCompanion Function({
  Value<String> specimenUuid,
  Value<int?> mediaId,
  Value<int> rowid,
});

class $SpecimenMediaFilterComposer extends Composer<_$Database, SpecimenMedia> {
  $SpecimenMediaFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnFilters(column));
}

class $SpecimenMediaOrderingComposer
    extends Composer<_$Database, SpecimenMedia> {
  $SpecimenMediaOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnOrderings(column));
}

class $SpecimenMediaAnnotationComposer
    extends Composer<_$Database, SpecimenMedia> {
  $SpecimenMediaAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid, builder: (column) => column);

  GeneratedColumn<int> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);
}

class $SpecimenMediaTableManager extends RootTableManager<
    _$Database,
    SpecimenMedia,
    SpecimenMediaData,
    $SpecimenMediaFilterComposer,
    $SpecimenMediaOrderingComposer,
    $SpecimenMediaAnnotationComposer,
    $SpecimenMediaCreateCompanionBuilder,
    $SpecimenMediaUpdateCompanionBuilder,
    (
      SpecimenMediaData,
      BaseReferences<_$Database, SpecimenMedia, SpecimenMediaData>
    ),
    SpecimenMediaData,
    PrefetchHooks Function()> {
  $SpecimenMediaTableManager(_$Database db, SpecimenMedia table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SpecimenMediaFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SpecimenMediaOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SpecimenMediaAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> specimenUuid = const Value.absent(),
            Value<int?> mediaId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpecimenMediaCompanion(
            specimenUuid: specimenUuid,
            mediaId: mediaId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String specimenUuid,
            Value<int?> mediaId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SpecimenMediaCompanion.insert(
            specimenUuid: specimenUuid,
            mediaId: mediaId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $SpecimenMediaProcessedTableManager = ProcessedTableManager<
    _$Database,
    SpecimenMedia,
    SpecimenMediaData,
    $SpecimenMediaFilterComposer,
    $SpecimenMediaOrderingComposer,
    $SpecimenMediaAnnotationComposer,
    $SpecimenMediaCreateCompanionBuilder,
    $SpecimenMediaUpdateCompanionBuilder,
    (
      SpecimenMediaData,
      BaseReferences<_$Database, SpecimenMedia, SpecimenMediaData>
    ),
    SpecimenMediaData,
    PrefetchHooks Function()>;
typedef $AssociatedDataCreateCompanionBuilder = AssociatedDataCompanion
    Function({
  Value<int?> primaryId,
  Value<String?> specimenUuid,
  Value<String?> name,
  Value<String?> type,
  Value<String?> date,
  Value<String?> description,
  Value<String?> url,
});
typedef $AssociatedDataUpdateCompanionBuilder = AssociatedDataCompanion
    Function({
  Value<int?> primaryId,
  Value<String?> specimenUuid,
  Value<String?> name,
  Value<String?> type,
  Value<String?> date,
  Value<String?> description,
  Value<String?> url,
});

class $AssociatedDataFilterComposer
    extends Composer<_$Database, AssociatedData> {
  $AssociatedDataFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get primaryId => $composableBuilder(
      column: $table.primaryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));
}

class $AssociatedDataOrderingComposer
    extends Composer<_$Database, AssociatedData> {
  $AssociatedDataOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get primaryId => $composableBuilder(
      column: $table.primaryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));
}

class $AssociatedDataAnnotationComposer
    extends Composer<_$Database, AssociatedData> {
  $AssociatedDataAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get primaryId =>
      $composableBuilder(column: $table.primaryId, builder: (column) => column);

  GeneratedColumn<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);
}

class $AssociatedDataTableManager extends RootTableManager<
    _$Database,
    AssociatedData,
    AssociatedDataData,
    $AssociatedDataFilterComposer,
    $AssociatedDataOrderingComposer,
    $AssociatedDataAnnotationComposer,
    $AssociatedDataCreateCompanionBuilder,
    $AssociatedDataUpdateCompanionBuilder,
    (
      AssociatedDataData,
      BaseReferences<_$Database, AssociatedData, AssociatedDataData>
    ),
    AssociatedDataData,
    PrefetchHooks Function()> {
  $AssociatedDataTableManager(_$Database db, AssociatedData table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AssociatedDataFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AssociatedDataOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AssociatedDataAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int?> primaryId = const Value.absent(),
            Value<String?> specimenUuid = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<String?> date = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> url = const Value.absent(),
          }) =>
              AssociatedDataCompanion(
            primaryId: primaryId,
            specimenUuid: specimenUuid,
            name: name,
            type: type,
            date: date,
            description: description,
            url: url,
          ),
          createCompanionCallback: ({
            Value<int?> primaryId = const Value.absent(),
            Value<String?> specimenUuid = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<String?> date = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> url = const Value.absent(),
          }) =>
              AssociatedDataCompanion.insert(
            primaryId: primaryId,
            specimenUuid: specimenUuid,
            name: name,
            type: type,
            date: date,
            description: description,
            url: url,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $AssociatedDataProcessedTableManager = ProcessedTableManager<
    _$Database,
    AssociatedData,
    AssociatedDataData,
    $AssociatedDataFilterComposer,
    $AssociatedDataOrderingComposer,
    $AssociatedDataAnnotationComposer,
    $AssociatedDataCreateCompanionBuilder,
    $AssociatedDataUpdateCompanionBuilder,
    (
      AssociatedDataData,
      BaseReferences<_$Database, AssociatedData, AssociatedDataData>
    ),
    AssociatedDataData,
    PrefetchHooks Function()>;
typedef $PersonnelListCreateCompanionBuilder = PersonnelListCompanion Function({
  Value<String?> projectUuid,
  Value<String?> personnelUuid,
  Value<int> rowid,
});
typedef $PersonnelListUpdateCompanionBuilder = PersonnelListCompanion Function({
  Value<String?> projectUuid,
  Value<String?> personnelUuid,
  Value<int> rowid,
});

class $PersonnelListFilterComposer extends Composer<_$Database, PersonnelList> {
  $PersonnelListFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personnelUuid => $composableBuilder(
      column: $table.personnelUuid, builder: (column) => ColumnFilters(column));
}

class $PersonnelListOrderingComposer
    extends Composer<_$Database, PersonnelList> {
  $PersonnelListOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personnelUuid => $composableBuilder(
      column: $table.personnelUuid,
      builder: (column) => ColumnOrderings(column));
}

class $PersonnelListAnnotationComposer
    extends Composer<_$Database, PersonnelList> {
  $PersonnelListAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get projectUuid => $composableBuilder(
      column: $table.projectUuid, builder: (column) => column);

  GeneratedColumn<String> get personnelUuid => $composableBuilder(
      column: $table.personnelUuid, builder: (column) => column);
}

class $PersonnelListTableManager extends RootTableManager<
    _$Database,
    PersonnelList,
    PersonnelListData,
    $PersonnelListFilterComposer,
    $PersonnelListOrderingComposer,
    $PersonnelListAnnotationComposer,
    $PersonnelListCreateCompanionBuilder,
    $PersonnelListUpdateCompanionBuilder,
    (
      PersonnelListData,
      BaseReferences<_$Database, PersonnelList, PersonnelListData>
    ),
    PersonnelListData,
    PrefetchHooks Function()> {
  $PersonnelListTableManager(_$Database db, PersonnelList table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $PersonnelListFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $PersonnelListOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $PersonnelListAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> projectUuid = const Value.absent(),
            Value<String?> personnelUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PersonnelListCompanion(
            projectUuid: projectUuid,
            personnelUuid: personnelUuid,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> projectUuid = const Value.absent(),
            Value<String?> personnelUuid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PersonnelListCompanion.insert(
            projectUuid: projectUuid,
            personnelUuid: personnelUuid,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $PersonnelListProcessedTableManager = ProcessedTableManager<
    _$Database,
    PersonnelList,
    PersonnelListData,
    $PersonnelListFilterComposer,
    $PersonnelListOrderingComposer,
    $PersonnelListAnnotationComposer,
    $PersonnelListCreateCompanionBuilder,
    $PersonnelListUpdateCompanionBuilder,
    (
      PersonnelListData,
      BaseReferences<_$Database, PersonnelList, PersonnelListData>
    ),
    PersonnelListData,
    PrefetchHooks Function()>;
typedef $MammalMeasurementCreateCompanionBuilder = MammalMeasurementCompanion
    Function({
  required String specimenUuid,
  Value<double?> totalLength,
  Value<double?> tailLength,
  Value<double?> hindFootLength,
  Value<double?> earLength,
  Value<double?> forearm,
  Value<double?> weight,
  Value<String?> accuracy,
  Value<String?> accuracySpecify,
  Value<int?> sex,
  Value<int?> age,
  Value<int?> testisPosition,
  Value<double?> testisLength,
  Value<double?> testisWidth,
  Value<int?> epididymisAppearance,
  Value<int?> reproductiveStage,
  Value<int?> leftPlacentalScars,
  Value<int?> rightPlacentalScars,
  Value<int?> mammaeCondition,
  Value<int?> mammaeInguinalCount,
  Value<int?> mammaeAxillaryCount,
  Value<int?> mammaeAbdominalCount,
  Value<int?> vaginaOpening,
  Value<int?> pubicSymphysis,
  Value<int?> embryoLeftCount,
  Value<int?> embryoRightCount,
  Value<int?> embryoCR,
  Value<String?> remark,
  Value<int> rowid,
});
typedef $MammalMeasurementUpdateCompanionBuilder = MammalMeasurementCompanion
    Function({
  Value<String> specimenUuid,
  Value<double?> totalLength,
  Value<double?> tailLength,
  Value<double?> hindFootLength,
  Value<double?> earLength,
  Value<double?> forearm,
  Value<double?> weight,
  Value<String?> accuracy,
  Value<String?> accuracySpecify,
  Value<int?> sex,
  Value<int?> age,
  Value<int?> testisPosition,
  Value<double?> testisLength,
  Value<double?> testisWidth,
  Value<int?> epididymisAppearance,
  Value<int?> reproductiveStage,
  Value<int?> leftPlacentalScars,
  Value<int?> rightPlacentalScars,
  Value<int?> mammaeCondition,
  Value<int?> mammaeInguinalCount,
  Value<int?> mammaeAxillaryCount,
  Value<int?> mammaeAbdominalCount,
  Value<int?> vaginaOpening,
  Value<int?> pubicSymphysis,
  Value<int?> embryoLeftCount,
  Value<int?> embryoRightCount,
  Value<int?> embryoCR,
  Value<String?> remark,
  Value<int> rowid,
});

class $MammalMeasurementFilterComposer
    extends Composer<_$Database, MammalMeasurement> {
  $MammalMeasurementFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalLength => $composableBuilder(
      column: $table.totalLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tailLength => $composableBuilder(
      column: $table.tailLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hindFootLength => $composableBuilder(
      column: $table.hindFootLength,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get earLength => $composableBuilder(
      column: $table.earLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get forearm => $composableBuilder(
      column: $table.forearm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accuracySpecify => $composableBuilder(
      column: $table.accuracySpecify,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get testisPosition => $composableBuilder(
      column: $table.testisPosition,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get testisLength => $composableBuilder(
      column: $table.testisLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get testisWidth => $composableBuilder(
      column: $table.testisWidth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get epididymisAppearance => $composableBuilder(
      column: $table.epididymisAppearance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reproductiveStage => $composableBuilder(
      column: $table.reproductiveStage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get leftPlacentalScars => $composableBuilder(
      column: $table.leftPlacentalScars,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rightPlacentalScars => $composableBuilder(
      column: $table.rightPlacentalScars,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mammaeCondition => $composableBuilder(
      column: $table.mammaeCondition,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mammaeInguinalCount => $composableBuilder(
      column: $table.mammaeInguinalCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mammaeAxillaryCount => $composableBuilder(
      column: $table.mammaeAxillaryCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mammaeAbdominalCount => $composableBuilder(
      column: $table.mammaeAbdominalCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get vaginaOpening => $composableBuilder(
      column: $table.vaginaOpening, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pubicSymphysis => $composableBuilder(
      column: $table.pubicSymphysis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get embryoLeftCount => $composableBuilder(
      column: $table.embryoLeftCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get embryoRightCount => $composableBuilder(
      column: $table.embryoRightCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get embryoCR => $composableBuilder(
      column: $table.embryoCR, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remark => $composableBuilder(
      column: $table.remark, builder: (column) => ColumnFilters(column));
}

class $MammalMeasurementOrderingComposer
    extends Composer<_$Database, MammalMeasurement> {
  $MammalMeasurementOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalLength => $composableBuilder(
      column: $table.totalLength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tailLength => $composableBuilder(
      column: $table.tailLength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hindFootLength => $composableBuilder(
      column: $table.hindFootLength,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get earLength => $composableBuilder(
      column: $table.earLength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get forearm => $composableBuilder(
      column: $table.forearm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accuracySpecify => $composableBuilder(
      column: $table.accuracySpecify,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get testisPosition => $composableBuilder(
      column: $table.testisPosition,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get testisLength => $composableBuilder(
      column: $table.testisLength,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get testisWidth => $composableBuilder(
      column: $table.testisWidth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get epididymisAppearance => $composableBuilder(
      column: $table.epididymisAppearance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reproductiveStage => $composableBuilder(
      column: $table.reproductiveStage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get leftPlacentalScars => $composableBuilder(
      column: $table.leftPlacentalScars,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rightPlacentalScars => $composableBuilder(
      column: $table.rightPlacentalScars,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mammaeCondition => $composableBuilder(
      column: $table.mammaeCondition,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mammaeInguinalCount => $composableBuilder(
      column: $table.mammaeInguinalCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mammaeAxillaryCount => $composableBuilder(
      column: $table.mammaeAxillaryCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mammaeAbdominalCount => $composableBuilder(
      column: $table.mammaeAbdominalCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get vaginaOpening => $composableBuilder(
      column: $table.vaginaOpening,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pubicSymphysis => $composableBuilder(
      column: $table.pubicSymphysis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get embryoLeftCount => $composableBuilder(
      column: $table.embryoLeftCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get embryoRightCount => $composableBuilder(
      column: $table.embryoRightCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get embryoCR => $composableBuilder(
      column: $table.embryoCR, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remark => $composableBuilder(
      column: $table.remark, builder: (column) => ColumnOrderings(column));
}

class $MammalMeasurementAnnotationComposer
    extends Composer<_$Database, MammalMeasurement> {
  $MammalMeasurementAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid, builder: (column) => column);

  GeneratedColumn<double> get totalLength => $composableBuilder(
      column: $table.totalLength, builder: (column) => column);

  GeneratedColumn<double> get tailLength => $composableBuilder(
      column: $table.tailLength, builder: (column) => column);

  GeneratedColumn<double> get hindFootLength => $composableBuilder(
      column: $table.hindFootLength, builder: (column) => column);

  GeneratedColumn<double> get earLength =>
      $composableBuilder(column: $table.earLength, builder: (column) => column);

  GeneratedColumn<double> get forearm =>
      $composableBuilder(column: $table.forearm, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<String> get accuracySpecify => $composableBuilder(
      column: $table.accuracySpecify, builder: (column) => column);

  GeneratedColumn<int> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<int> get testisPosition => $composableBuilder(
      column: $table.testisPosition, builder: (column) => column);

  GeneratedColumn<double> get testisLength => $composableBuilder(
      column: $table.testisLength, builder: (column) => column);

  GeneratedColumn<double> get testisWidth => $composableBuilder(
      column: $table.testisWidth, builder: (column) => column);

  GeneratedColumn<int> get epididymisAppearance => $composableBuilder(
      column: $table.epididymisAppearance, builder: (column) => column);

  GeneratedColumn<int> get reproductiveStage => $composableBuilder(
      column: $table.reproductiveStage, builder: (column) => column);

  GeneratedColumn<int> get leftPlacentalScars => $composableBuilder(
      column: $table.leftPlacentalScars, builder: (column) => column);

  GeneratedColumn<int> get rightPlacentalScars => $composableBuilder(
      column: $table.rightPlacentalScars, builder: (column) => column);

  GeneratedColumn<int> get mammaeCondition => $composableBuilder(
      column: $table.mammaeCondition, builder: (column) => column);

  GeneratedColumn<int> get mammaeInguinalCount => $composableBuilder(
      column: $table.mammaeInguinalCount, builder: (column) => column);

  GeneratedColumn<int> get mammaeAxillaryCount => $composableBuilder(
      column: $table.mammaeAxillaryCount, builder: (column) => column);

  GeneratedColumn<int> get mammaeAbdominalCount => $composableBuilder(
      column: $table.mammaeAbdominalCount, builder: (column) => column);

  GeneratedColumn<int> get vaginaOpening => $composableBuilder(
      column: $table.vaginaOpening, builder: (column) => column);

  GeneratedColumn<int> get pubicSymphysis => $composableBuilder(
      column: $table.pubicSymphysis, builder: (column) => column);

  GeneratedColumn<int> get embryoLeftCount => $composableBuilder(
      column: $table.embryoLeftCount, builder: (column) => column);

  GeneratedColumn<int> get embryoRightCount => $composableBuilder(
      column: $table.embryoRightCount, builder: (column) => column);

  GeneratedColumn<int> get embryoCR =>
      $composableBuilder(column: $table.embryoCR, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $MammalMeasurementTableManager extends RootTableManager<
    _$Database,
    MammalMeasurement,
    MammalMeasurementData,
    $MammalMeasurementFilterComposer,
    $MammalMeasurementOrderingComposer,
    $MammalMeasurementAnnotationComposer,
    $MammalMeasurementCreateCompanionBuilder,
    $MammalMeasurementUpdateCompanionBuilder,
    (
      MammalMeasurementData,
      BaseReferences<_$Database, MammalMeasurement, MammalMeasurementData>
    ),
    MammalMeasurementData,
    PrefetchHooks Function()> {
  $MammalMeasurementTableManager(_$Database db, MammalMeasurement table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MammalMeasurementFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MammalMeasurementOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MammalMeasurementAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> specimenUuid = const Value.absent(),
            Value<double?> totalLength = const Value.absent(),
            Value<double?> tailLength = const Value.absent(),
            Value<double?> hindFootLength = const Value.absent(),
            Value<double?> earLength = const Value.absent(),
            Value<double?> forearm = const Value.absent(),
            Value<double?> weight = const Value.absent(),
            Value<String?> accuracy = const Value.absent(),
            Value<String?> accuracySpecify = const Value.absent(),
            Value<int?> sex = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<int?> testisPosition = const Value.absent(),
            Value<double?> testisLength = const Value.absent(),
            Value<double?> testisWidth = const Value.absent(),
            Value<int?> epididymisAppearance = const Value.absent(),
            Value<int?> reproductiveStage = const Value.absent(),
            Value<int?> leftPlacentalScars = const Value.absent(),
            Value<int?> rightPlacentalScars = const Value.absent(),
            Value<int?> mammaeCondition = const Value.absent(),
            Value<int?> mammaeInguinalCount = const Value.absent(),
            Value<int?> mammaeAxillaryCount = const Value.absent(),
            Value<int?> mammaeAbdominalCount = const Value.absent(),
            Value<int?> vaginaOpening = const Value.absent(),
            Value<int?> pubicSymphysis = const Value.absent(),
            Value<int?> embryoLeftCount = const Value.absent(),
            Value<int?> embryoRightCount = const Value.absent(),
            Value<int?> embryoCR = const Value.absent(),
            Value<String?> remark = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MammalMeasurementCompanion(
            specimenUuid: specimenUuid,
            totalLength: totalLength,
            tailLength: tailLength,
            hindFootLength: hindFootLength,
            earLength: earLength,
            forearm: forearm,
            weight: weight,
            accuracy: accuracy,
            accuracySpecify: accuracySpecify,
            sex: sex,
            age: age,
            testisPosition: testisPosition,
            testisLength: testisLength,
            testisWidth: testisWidth,
            epididymisAppearance: epididymisAppearance,
            reproductiveStage: reproductiveStage,
            leftPlacentalScars: leftPlacentalScars,
            rightPlacentalScars: rightPlacentalScars,
            mammaeCondition: mammaeCondition,
            mammaeInguinalCount: mammaeInguinalCount,
            mammaeAxillaryCount: mammaeAxillaryCount,
            mammaeAbdominalCount: mammaeAbdominalCount,
            vaginaOpening: vaginaOpening,
            pubicSymphysis: pubicSymphysis,
            embryoLeftCount: embryoLeftCount,
            embryoRightCount: embryoRightCount,
            embryoCR: embryoCR,
            remark: remark,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String specimenUuid,
            Value<double?> totalLength = const Value.absent(),
            Value<double?> tailLength = const Value.absent(),
            Value<double?> hindFootLength = const Value.absent(),
            Value<double?> earLength = const Value.absent(),
            Value<double?> forearm = const Value.absent(),
            Value<double?> weight = const Value.absent(),
            Value<String?> accuracy = const Value.absent(),
            Value<String?> accuracySpecify = const Value.absent(),
            Value<int?> sex = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<int?> testisPosition = const Value.absent(),
            Value<double?> testisLength = const Value.absent(),
            Value<double?> testisWidth = const Value.absent(),
            Value<int?> epididymisAppearance = const Value.absent(),
            Value<int?> reproductiveStage = const Value.absent(),
            Value<int?> leftPlacentalScars = const Value.absent(),
            Value<int?> rightPlacentalScars = const Value.absent(),
            Value<int?> mammaeCondition = const Value.absent(),
            Value<int?> mammaeInguinalCount = const Value.absent(),
            Value<int?> mammaeAxillaryCount = const Value.absent(),
            Value<int?> mammaeAbdominalCount = const Value.absent(),
            Value<int?> vaginaOpening = const Value.absent(),
            Value<int?> pubicSymphysis = const Value.absent(),
            Value<int?> embryoLeftCount = const Value.absent(),
            Value<int?> embryoRightCount = const Value.absent(),
            Value<int?> embryoCR = const Value.absent(),
            Value<String?> remark = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MammalMeasurementCompanion.insert(
            specimenUuid: specimenUuid,
            totalLength: totalLength,
            tailLength: tailLength,
            hindFootLength: hindFootLength,
            earLength: earLength,
            forearm: forearm,
            weight: weight,
            accuracy: accuracy,
            accuracySpecify: accuracySpecify,
            sex: sex,
            age: age,
            testisPosition: testisPosition,
            testisLength: testisLength,
            testisWidth: testisWidth,
            epididymisAppearance: epididymisAppearance,
            reproductiveStage: reproductiveStage,
            leftPlacentalScars: leftPlacentalScars,
            rightPlacentalScars: rightPlacentalScars,
            mammaeCondition: mammaeCondition,
            mammaeInguinalCount: mammaeInguinalCount,
            mammaeAxillaryCount: mammaeAxillaryCount,
            mammaeAbdominalCount: mammaeAbdominalCount,
            vaginaOpening: vaginaOpening,
            pubicSymphysis: pubicSymphysis,
            embryoLeftCount: embryoLeftCount,
            embryoRightCount: embryoRightCount,
            embryoCR: embryoCR,
            remark: remark,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $MammalMeasurementProcessedTableManager = ProcessedTableManager<
    _$Database,
    MammalMeasurement,
    MammalMeasurementData,
    $MammalMeasurementFilterComposer,
    $MammalMeasurementOrderingComposer,
    $MammalMeasurementAnnotationComposer,
    $MammalMeasurementCreateCompanionBuilder,
    $MammalMeasurementUpdateCompanionBuilder,
    (
      MammalMeasurementData,
      BaseReferences<_$Database, MammalMeasurement, MammalMeasurementData>
    ),
    MammalMeasurementData,
    PrefetchHooks Function()>;
typedef $AvianMeasurementCreateCompanionBuilder = AvianMeasurementCompanion
    Function({
  required String specimenUuid,
  Value<double?> weight,
  Value<double?> wingspan,
  Value<String?> irisColor,
  Value<String?> irisHex,
  Value<String?> billColor,
  Value<String?> billHex,
  Value<String?> footColor,
  Value<String?> footHex,
  Value<String?> tarsusColor,
  Value<String?> tarsusHex,
  Value<int?> sex,
  Value<int?> broodPatch,
  Value<int?> skullOssification,
  Value<int?> hasBursa,
  Value<double?> bursaWidth,
  Value<double?> bursaLength,
  Value<int?> fat,
  Value<String?> stomachContent,
  Value<double?> testisLength,
  Value<double?> testisWidth,
  Value<String?> testisRemark,
  Value<double?> ovaryLength,
  Value<double?> ovaryWidth,
  Value<double?> oviductWidth,
  Value<int?> ovaryAppearance,
  Value<double?> firstOvaSize,
  Value<double?> secondOvaSize,
  Value<double?> thirdOvaSize,
  Value<int?> oviductAppearance,
  Value<String?> ovaryRemark,
  Value<int?> wingIsMolt,
  Value<String?> wingMolt,
  Value<int?> tailIsMolt,
  Value<String?> tailMolt,
  Value<int?> bodyMolt,
  Value<String?> moltRemark,
  Value<String?> specimenRemark,
  Value<String?> habitatRemark,
  Value<int> rowid,
});
typedef $AvianMeasurementUpdateCompanionBuilder = AvianMeasurementCompanion
    Function({
  Value<String> specimenUuid,
  Value<double?> weight,
  Value<double?> wingspan,
  Value<String?> irisColor,
  Value<String?> irisHex,
  Value<String?> billColor,
  Value<String?> billHex,
  Value<String?> footColor,
  Value<String?> footHex,
  Value<String?> tarsusColor,
  Value<String?> tarsusHex,
  Value<int?> sex,
  Value<int?> broodPatch,
  Value<int?> skullOssification,
  Value<int?> hasBursa,
  Value<double?> bursaWidth,
  Value<double?> bursaLength,
  Value<int?> fat,
  Value<String?> stomachContent,
  Value<double?> testisLength,
  Value<double?> testisWidth,
  Value<String?> testisRemark,
  Value<double?> ovaryLength,
  Value<double?> ovaryWidth,
  Value<double?> oviductWidth,
  Value<int?> ovaryAppearance,
  Value<double?> firstOvaSize,
  Value<double?> secondOvaSize,
  Value<double?> thirdOvaSize,
  Value<int?> oviductAppearance,
  Value<String?> ovaryRemark,
  Value<int?> wingIsMolt,
  Value<String?> wingMolt,
  Value<int?> tailIsMolt,
  Value<String?> tailMolt,
  Value<int?> bodyMolt,
  Value<String?> moltRemark,
  Value<String?> specimenRemark,
  Value<String?> habitatRemark,
  Value<int> rowid,
});

class $AvianMeasurementFilterComposer
    extends Composer<_$Database, AvianMeasurement> {
  $AvianMeasurementFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get wingspan => $composableBuilder(
      column: $table.wingspan, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get irisColor => $composableBuilder(
      column: $table.irisColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get irisHex => $composableBuilder(
      column: $table.irisHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get billColor => $composableBuilder(
      column: $table.billColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get billHex => $composableBuilder(
      column: $table.billHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get footColor => $composableBuilder(
      column: $table.footColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get footHex => $composableBuilder(
      column: $table.footHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tarsusColor => $composableBuilder(
      column: $table.tarsusColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tarsusHex => $composableBuilder(
      column: $table.tarsusHex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get broodPatch => $composableBuilder(
      column: $table.broodPatch, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get skullOssification => $composableBuilder(
      column: $table.skullOssification,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hasBursa => $composableBuilder(
      column: $table.hasBursa, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bursaWidth => $composableBuilder(
      column: $table.bursaWidth, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bursaLength => $composableBuilder(
      column: $table.bursaLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stomachContent => $composableBuilder(
      column: $table.stomachContent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get testisLength => $composableBuilder(
      column: $table.testisLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get testisWidth => $composableBuilder(
      column: $table.testisWidth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get testisRemark => $composableBuilder(
      column: $table.testisRemark, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get ovaryLength => $composableBuilder(
      column: $table.ovaryLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get ovaryWidth => $composableBuilder(
      column: $table.ovaryWidth, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get oviductWidth => $composableBuilder(
      column: $table.oviductWidth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ovaryAppearance => $composableBuilder(
      column: $table.ovaryAppearance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get firstOvaSize => $composableBuilder(
      column: $table.firstOvaSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get secondOvaSize => $composableBuilder(
      column: $table.secondOvaSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get thirdOvaSize => $composableBuilder(
      column: $table.thirdOvaSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get oviductAppearance => $composableBuilder(
      column: $table.oviductAppearance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ovaryRemark => $composableBuilder(
      column: $table.ovaryRemark, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wingIsMolt => $composableBuilder(
      column: $table.wingIsMolt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wingMolt => $composableBuilder(
      column: $table.wingMolt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tailIsMolt => $composableBuilder(
      column: $table.tailIsMolt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tailMolt => $composableBuilder(
      column: $table.tailMolt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bodyMolt => $composableBuilder(
      column: $table.bodyMolt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get moltRemark => $composableBuilder(
      column: $table.moltRemark, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specimenRemark => $composableBuilder(
      column: $table.specimenRemark,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get habitatRemark => $composableBuilder(
      column: $table.habitatRemark, builder: (column) => ColumnFilters(column));
}

class $AvianMeasurementOrderingComposer
    extends Composer<_$Database, AvianMeasurement> {
  $AvianMeasurementOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get wingspan => $composableBuilder(
      column: $table.wingspan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get irisColor => $composableBuilder(
      column: $table.irisColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get irisHex => $composableBuilder(
      column: $table.irisHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billColor => $composableBuilder(
      column: $table.billColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billHex => $composableBuilder(
      column: $table.billHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get footColor => $composableBuilder(
      column: $table.footColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get footHex => $composableBuilder(
      column: $table.footHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tarsusColor => $composableBuilder(
      column: $table.tarsusColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tarsusHex => $composableBuilder(
      column: $table.tarsusHex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get broodPatch => $composableBuilder(
      column: $table.broodPatch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get skullOssification => $composableBuilder(
      column: $table.skullOssification,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hasBursa => $composableBuilder(
      column: $table.hasBursa, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bursaWidth => $composableBuilder(
      column: $table.bursaWidth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bursaLength => $composableBuilder(
      column: $table.bursaLength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fat => $composableBuilder(
      column: $table.fat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stomachContent => $composableBuilder(
      column: $table.stomachContent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get testisLength => $composableBuilder(
      column: $table.testisLength,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get testisWidth => $composableBuilder(
      column: $table.testisWidth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get testisRemark => $composableBuilder(
      column: $table.testisRemark,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get ovaryLength => $composableBuilder(
      column: $table.ovaryLength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get ovaryWidth => $composableBuilder(
      column: $table.ovaryWidth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get oviductWidth => $composableBuilder(
      column: $table.oviductWidth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ovaryAppearance => $composableBuilder(
      column: $table.ovaryAppearance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get firstOvaSize => $composableBuilder(
      column: $table.firstOvaSize,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get secondOvaSize => $composableBuilder(
      column: $table.secondOvaSize,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get thirdOvaSize => $composableBuilder(
      column: $table.thirdOvaSize,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get oviductAppearance => $composableBuilder(
      column: $table.oviductAppearance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ovaryRemark => $composableBuilder(
      column: $table.ovaryRemark, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wingIsMolt => $composableBuilder(
      column: $table.wingIsMolt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wingMolt => $composableBuilder(
      column: $table.wingMolt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tailIsMolt => $composableBuilder(
      column: $table.tailIsMolt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tailMolt => $composableBuilder(
      column: $table.tailMolt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bodyMolt => $composableBuilder(
      column: $table.bodyMolt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get moltRemark => $composableBuilder(
      column: $table.moltRemark, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specimenRemark => $composableBuilder(
      column: $table.specimenRemark,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get habitatRemark => $composableBuilder(
      column: $table.habitatRemark,
      builder: (column) => ColumnOrderings(column));
}

class $AvianMeasurementAnnotationComposer
    extends Composer<_$Database, AvianMeasurement> {
  $AvianMeasurementAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<double> get wingspan =>
      $composableBuilder(column: $table.wingspan, builder: (column) => column);

  GeneratedColumn<String> get irisColor =>
      $composableBuilder(column: $table.irisColor, builder: (column) => column);

  GeneratedColumn<String> get irisHex =>
      $composableBuilder(column: $table.irisHex, builder: (column) => column);

  GeneratedColumn<String> get billColor =>
      $composableBuilder(column: $table.billColor, builder: (column) => column);

  GeneratedColumn<String> get billHex =>
      $composableBuilder(column: $table.billHex, builder: (column) => column);

  GeneratedColumn<String> get footColor =>
      $composableBuilder(column: $table.footColor, builder: (column) => column);

  GeneratedColumn<String> get footHex =>
      $composableBuilder(column: $table.footHex, builder: (column) => column);

  GeneratedColumn<String> get tarsusColor => $composableBuilder(
      column: $table.tarsusColor, builder: (column) => column);

  GeneratedColumn<String> get tarsusHex =>
      $composableBuilder(column: $table.tarsusHex, builder: (column) => column);

  GeneratedColumn<int> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get broodPatch => $composableBuilder(
      column: $table.broodPatch, builder: (column) => column);

  GeneratedColumn<int> get skullOssification => $composableBuilder(
      column: $table.skullOssification, builder: (column) => column);

  GeneratedColumn<int> get hasBursa =>
      $composableBuilder(column: $table.hasBursa, builder: (column) => column);

  GeneratedColumn<double> get bursaWidth => $composableBuilder(
      column: $table.bursaWidth, builder: (column) => column);

  GeneratedColumn<double> get bursaLength => $composableBuilder(
      column: $table.bursaLength, builder: (column) => column);

  GeneratedColumn<int> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<String> get stomachContent => $composableBuilder(
      column: $table.stomachContent, builder: (column) => column);

  GeneratedColumn<double> get testisLength => $composableBuilder(
      column: $table.testisLength, builder: (column) => column);

  GeneratedColumn<double> get testisWidth => $composableBuilder(
      column: $table.testisWidth, builder: (column) => column);

  GeneratedColumn<String> get testisRemark => $composableBuilder(
      column: $table.testisRemark, builder: (column) => column);

  GeneratedColumn<double> get ovaryLength => $composableBuilder(
      column: $table.ovaryLength, builder: (column) => column);

  GeneratedColumn<double> get ovaryWidth => $composableBuilder(
      column: $table.ovaryWidth, builder: (column) => column);

  GeneratedColumn<double> get oviductWidth => $composableBuilder(
      column: $table.oviductWidth, builder: (column) => column);

  GeneratedColumn<int> get ovaryAppearance => $composableBuilder(
      column: $table.ovaryAppearance, builder: (column) => column);

  GeneratedColumn<double> get firstOvaSize => $composableBuilder(
      column: $table.firstOvaSize, builder: (column) => column);

  GeneratedColumn<double> get secondOvaSize => $composableBuilder(
      column: $table.secondOvaSize, builder: (column) => column);

  GeneratedColumn<double> get thirdOvaSize => $composableBuilder(
      column: $table.thirdOvaSize, builder: (column) => column);

  GeneratedColumn<int> get oviductAppearance => $composableBuilder(
      column: $table.oviductAppearance, builder: (column) => column);

  GeneratedColumn<String> get ovaryRemark => $composableBuilder(
      column: $table.ovaryRemark, builder: (column) => column);

  GeneratedColumn<int> get wingIsMolt => $composableBuilder(
      column: $table.wingIsMolt, builder: (column) => column);

  GeneratedColumn<String> get wingMolt =>
      $composableBuilder(column: $table.wingMolt, builder: (column) => column);

  GeneratedColumn<int> get tailIsMolt => $composableBuilder(
      column: $table.tailIsMolt, builder: (column) => column);

  GeneratedColumn<String> get tailMolt =>
      $composableBuilder(column: $table.tailMolt, builder: (column) => column);

  GeneratedColumn<int> get bodyMolt =>
      $composableBuilder(column: $table.bodyMolt, builder: (column) => column);

  GeneratedColumn<String> get moltRemark => $composableBuilder(
      column: $table.moltRemark, builder: (column) => column);

  GeneratedColumn<String> get specimenRemark => $composableBuilder(
      column: $table.specimenRemark, builder: (column) => column);

  GeneratedColumn<String> get habitatRemark => $composableBuilder(
      column: $table.habitatRemark, builder: (column) => column);
}

class $AvianMeasurementTableManager extends RootTableManager<
    _$Database,
    AvianMeasurement,
    AvianMeasurementData,
    $AvianMeasurementFilterComposer,
    $AvianMeasurementOrderingComposer,
    $AvianMeasurementAnnotationComposer,
    $AvianMeasurementCreateCompanionBuilder,
    $AvianMeasurementUpdateCompanionBuilder,
    (
      AvianMeasurementData,
      BaseReferences<_$Database, AvianMeasurement, AvianMeasurementData>
    ),
    AvianMeasurementData,
    PrefetchHooks Function()> {
  $AvianMeasurementTableManager(_$Database db, AvianMeasurement table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AvianMeasurementFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AvianMeasurementOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AvianMeasurementAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> specimenUuid = const Value.absent(),
            Value<double?> weight = const Value.absent(),
            Value<double?> wingspan = const Value.absent(),
            Value<String?> irisColor = const Value.absent(),
            Value<String?> irisHex = const Value.absent(),
            Value<String?> billColor = const Value.absent(),
            Value<String?> billHex = const Value.absent(),
            Value<String?> footColor = const Value.absent(),
            Value<String?> footHex = const Value.absent(),
            Value<String?> tarsusColor = const Value.absent(),
            Value<String?> tarsusHex = const Value.absent(),
            Value<int?> sex = const Value.absent(),
            Value<int?> broodPatch = const Value.absent(),
            Value<int?> skullOssification = const Value.absent(),
            Value<int?> hasBursa = const Value.absent(),
            Value<double?> bursaWidth = const Value.absent(),
            Value<double?> bursaLength = const Value.absent(),
            Value<int?> fat = const Value.absent(),
            Value<String?> stomachContent = const Value.absent(),
            Value<double?> testisLength = const Value.absent(),
            Value<double?> testisWidth = const Value.absent(),
            Value<String?> testisRemark = const Value.absent(),
            Value<double?> ovaryLength = const Value.absent(),
            Value<double?> ovaryWidth = const Value.absent(),
            Value<double?> oviductWidth = const Value.absent(),
            Value<int?> ovaryAppearance = const Value.absent(),
            Value<double?> firstOvaSize = const Value.absent(),
            Value<double?> secondOvaSize = const Value.absent(),
            Value<double?> thirdOvaSize = const Value.absent(),
            Value<int?> oviductAppearance = const Value.absent(),
            Value<String?> ovaryRemark = const Value.absent(),
            Value<int?> wingIsMolt = const Value.absent(),
            Value<String?> wingMolt = const Value.absent(),
            Value<int?> tailIsMolt = const Value.absent(),
            Value<String?> tailMolt = const Value.absent(),
            Value<int?> bodyMolt = const Value.absent(),
            Value<String?> moltRemark = const Value.absent(),
            Value<String?> specimenRemark = const Value.absent(),
            Value<String?> habitatRemark = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AvianMeasurementCompanion(
            specimenUuid: specimenUuid,
            weight: weight,
            wingspan: wingspan,
            irisColor: irisColor,
            irisHex: irisHex,
            billColor: billColor,
            billHex: billHex,
            footColor: footColor,
            footHex: footHex,
            tarsusColor: tarsusColor,
            tarsusHex: tarsusHex,
            sex: sex,
            broodPatch: broodPatch,
            skullOssification: skullOssification,
            hasBursa: hasBursa,
            bursaWidth: bursaWidth,
            bursaLength: bursaLength,
            fat: fat,
            stomachContent: stomachContent,
            testisLength: testisLength,
            testisWidth: testisWidth,
            testisRemark: testisRemark,
            ovaryLength: ovaryLength,
            ovaryWidth: ovaryWidth,
            oviductWidth: oviductWidth,
            ovaryAppearance: ovaryAppearance,
            firstOvaSize: firstOvaSize,
            secondOvaSize: secondOvaSize,
            thirdOvaSize: thirdOvaSize,
            oviductAppearance: oviductAppearance,
            ovaryRemark: ovaryRemark,
            wingIsMolt: wingIsMolt,
            wingMolt: wingMolt,
            tailIsMolt: tailIsMolt,
            tailMolt: tailMolt,
            bodyMolt: bodyMolt,
            moltRemark: moltRemark,
            specimenRemark: specimenRemark,
            habitatRemark: habitatRemark,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String specimenUuid,
            Value<double?> weight = const Value.absent(),
            Value<double?> wingspan = const Value.absent(),
            Value<String?> irisColor = const Value.absent(),
            Value<String?> irisHex = const Value.absent(),
            Value<String?> billColor = const Value.absent(),
            Value<String?> billHex = const Value.absent(),
            Value<String?> footColor = const Value.absent(),
            Value<String?> footHex = const Value.absent(),
            Value<String?> tarsusColor = const Value.absent(),
            Value<String?> tarsusHex = const Value.absent(),
            Value<int?> sex = const Value.absent(),
            Value<int?> broodPatch = const Value.absent(),
            Value<int?> skullOssification = const Value.absent(),
            Value<int?> hasBursa = const Value.absent(),
            Value<double?> bursaWidth = const Value.absent(),
            Value<double?> bursaLength = const Value.absent(),
            Value<int?> fat = const Value.absent(),
            Value<String?> stomachContent = const Value.absent(),
            Value<double?> testisLength = const Value.absent(),
            Value<double?> testisWidth = const Value.absent(),
            Value<String?> testisRemark = const Value.absent(),
            Value<double?> ovaryLength = const Value.absent(),
            Value<double?> ovaryWidth = const Value.absent(),
            Value<double?> oviductWidth = const Value.absent(),
            Value<int?> ovaryAppearance = const Value.absent(),
            Value<double?> firstOvaSize = const Value.absent(),
            Value<double?> secondOvaSize = const Value.absent(),
            Value<double?> thirdOvaSize = const Value.absent(),
            Value<int?> oviductAppearance = const Value.absent(),
            Value<String?> ovaryRemark = const Value.absent(),
            Value<int?> wingIsMolt = const Value.absent(),
            Value<String?> wingMolt = const Value.absent(),
            Value<int?> tailIsMolt = const Value.absent(),
            Value<String?> tailMolt = const Value.absent(),
            Value<int?> bodyMolt = const Value.absent(),
            Value<String?> moltRemark = const Value.absent(),
            Value<String?> specimenRemark = const Value.absent(),
            Value<String?> habitatRemark = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AvianMeasurementCompanion.insert(
            specimenUuid: specimenUuid,
            weight: weight,
            wingspan: wingspan,
            irisColor: irisColor,
            irisHex: irisHex,
            billColor: billColor,
            billHex: billHex,
            footColor: footColor,
            footHex: footHex,
            tarsusColor: tarsusColor,
            tarsusHex: tarsusHex,
            sex: sex,
            broodPatch: broodPatch,
            skullOssification: skullOssification,
            hasBursa: hasBursa,
            bursaWidth: bursaWidth,
            bursaLength: bursaLength,
            fat: fat,
            stomachContent: stomachContent,
            testisLength: testisLength,
            testisWidth: testisWidth,
            testisRemark: testisRemark,
            ovaryLength: ovaryLength,
            ovaryWidth: ovaryWidth,
            oviductWidth: oviductWidth,
            ovaryAppearance: ovaryAppearance,
            firstOvaSize: firstOvaSize,
            secondOvaSize: secondOvaSize,
            thirdOvaSize: thirdOvaSize,
            oviductAppearance: oviductAppearance,
            ovaryRemark: ovaryRemark,
            wingIsMolt: wingIsMolt,
            wingMolt: wingMolt,
            tailIsMolt: tailIsMolt,
            tailMolt: tailMolt,
            bodyMolt: bodyMolt,
            moltRemark: moltRemark,
            specimenRemark: specimenRemark,
            habitatRemark: habitatRemark,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $AvianMeasurementProcessedTableManager = ProcessedTableManager<
    _$Database,
    AvianMeasurement,
    AvianMeasurementData,
    $AvianMeasurementFilterComposer,
    $AvianMeasurementOrderingComposer,
    $AvianMeasurementAnnotationComposer,
    $AvianMeasurementCreateCompanionBuilder,
    $AvianMeasurementUpdateCompanionBuilder,
    (
      AvianMeasurementData,
      BaseReferences<_$Database, AvianMeasurement, AvianMeasurementData>
    ),
    AvianMeasurementData,
    PrefetchHooks Function()>;
typedef $SpecimenPartCreateCompanionBuilder = SpecimenPartCompanion Function({
  Value<int?> id,
  Value<String?> specimenUuid,
  Value<String?> personnelId,
  Value<String?> tissueID,
  Value<String?> barcodeID,
  Value<String?> type,
  Value<String?> count,
  Value<String?> treatment,
  Value<String?> additionalTreatment,
  Value<String?> dateTaken,
  Value<String?> timeTaken,
  Value<String?> pmi,
  Value<String?> museumPermanent,
  Value<String?> museumLoan,
  Value<String?> remark,
});
typedef $SpecimenPartUpdateCompanionBuilder = SpecimenPartCompanion Function({
  Value<int?> id,
  Value<String?> specimenUuid,
  Value<String?> personnelId,
  Value<String?> tissueID,
  Value<String?> barcodeID,
  Value<String?> type,
  Value<String?> count,
  Value<String?> treatment,
  Value<String?> additionalTreatment,
  Value<String?> dateTaken,
  Value<String?> timeTaken,
  Value<String?> pmi,
  Value<String?> museumPermanent,
  Value<String?> museumLoan,
  Value<String?> remark,
});

class $SpecimenPartFilterComposer extends Composer<_$Database, SpecimenPart> {
  $SpecimenPartFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personnelId => $composableBuilder(
      column: $table.personnelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tissueID => $composableBuilder(
      column: $table.tissueID, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcodeID => $composableBuilder(
      column: $table.barcodeID, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get treatment => $composableBuilder(
      column: $table.treatment, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get additionalTreatment => $composableBuilder(
      column: $table.additionalTreatment,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateTaken => $composableBuilder(
      column: $table.dateTaken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeTaken => $composableBuilder(
      column: $table.timeTaken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pmi => $composableBuilder(
      column: $table.pmi, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get museumPermanent => $composableBuilder(
      column: $table.museumPermanent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get museumLoan => $composableBuilder(
      column: $table.museumLoan, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remark => $composableBuilder(
      column: $table.remark, builder: (column) => ColumnFilters(column));
}

class $SpecimenPartOrderingComposer extends Composer<_$Database, SpecimenPart> {
  $SpecimenPartOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personnelId => $composableBuilder(
      column: $table.personnelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tissueID => $composableBuilder(
      column: $table.tissueID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcodeID => $composableBuilder(
      column: $table.barcodeID, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get treatment => $composableBuilder(
      column: $table.treatment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get additionalTreatment => $composableBuilder(
      column: $table.additionalTreatment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateTaken => $composableBuilder(
      column: $table.dateTaken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeTaken => $composableBuilder(
      column: $table.timeTaken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pmi => $composableBuilder(
      column: $table.pmi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get museumPermanent => $composableBuilder(
      column: $table.museumPermanent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get museumLoan => $composableBuilder(
      column: $table.museumLoan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remark => $composableBuilder(
      column: $table.remark, builder: (column) => ColumnOrderings(column));
}

class $SpecimenPartAnnotationComposer
    extends Composer<_$Database, SpecimenPart> {
  $SpecimenPartAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get specimenUuid => $composableBuilder(
      column: $table.specimenUuid, builder: (column) => column);

  GeneratedColumn<String> get personnelId => $composableBuilder(
      column: $table.personnelId, builder: (column) => column);

  GeneratedColumn<String> get tissueID =>
      $composableBuilder(column: $table.tissueID, builder: (column) => column);

  GeneratedColumn<String> get barcodeID =>
      $composableBuilder(column: $table.barcodeID, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get treatment =>
      $composableBuilder(column: $table.treatment, builder: (column) => column);

  GeneratedColumn<String> get additionalTreatment => $composableBuilder(
      column: $table.additionalTreatment, builder: (column) => column);

  GeneratedColumn<String> get dateTaken =>
      $composableBuilder(column: $table.dateTaken, builder: (column) => column);

  GeneratedColumn<String> get timeTaken =>
      $composableBuilder(column: $table.timeTaken, builder: (column) => column);

  GeneratedColumn<String> get pmi =>
      $composableBuilder(column: $table.pmi, builder: (column) => column);

  GeneratedColumn<String> get museumPermanent => $composableBuilder(
      column: $table.museumPermanent, builder: (column) => column);

  GeneratedColumn<String> get museumLoan => $composableBuilder(
      column: $table.museumLoan, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $SpecimenPartTableManager extends RootTableManager<
    _$Database,
    SpecimenPart,
    SpecimenPartData,
    $SpecimenPartFilterComposer,
    $SpecimenPartOrderingComposer,
    $SpecimenPartAnnotationComposer,
    $SpecimenPartCreateCompanionBuilder,
    $SpecimenPartUpdateCompanionBuilder,
    (
      SpecimenPartData,
      BaseReferences<_$Database, SpecimenPart, SpecimenPartData>
    ),
    SpecimenPartData,
    PrefetchHooks Function()> {
  $SpecimenPartTableManager(_$Database db, SpecimenPart table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SpecimenPartFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SpecimenPartOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SpecimenPartAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int?> id = const Value.absent(),
            Value<String?> specimenUuid = const Value.absent(),
            Value<String?> personnelId = const Value.absent(),
            Value<String?> tissueID = const Value.absent(),
            Value<String?> barcodeID = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<String?> count = const Value.absent(),
            Value<String?> treatment = const Value.absent(),
            Value<String?> additionalTreatment = const Value.absent(),
            Value<String?> dateTaken = const Value.absent(),
            Value<String?> timeTaken = const Value.absent(),
            Value<String?> pmi = const Value.absent(),
            Value<String?> museumPermanent = const Value.absent(),
            Value<String?> museumLoan = const Value.absent(),
            Value<String?> remark = const Value.absent(),
          }) =>
              SpecimenPartCompanion(
            id: id,
            specimenUuid: specimenUuid,
            personnelId: personnelId,
            tissueID: tissueID,
            barcodeID: barcodeID,
            type: type,
            count: count,
            treatment: treatment,
            additionalTreatment: additionalTreatment,
            dateTaken: dateTaken,
            timeTaken: timeTaken,
            pmi: pmi,
            museumPermanent: museumPermanent,
            museumLoan: museumLoan,
            remark: remark,
          ),
          createCompanionCallback: ({
            Value<int?> id = const Value.absent(),
            Value<String?> specimenUuid = const Value.absent(),
            Value<String?> personnelId = const Value.absent(),
            Value<String?> tissueID = const Value.absent(),
            Value<String?> barcodeID = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<String?> count = const Value.absent(),
            Value<String?> treatment = const Value.absent(),
            Value<String?> additionalTreatment = const Value.absent(),
            Value<String?> dateTaken = const Value.absent(),
            Value<String?> timeTaken = const Value.absent(),
            Value<String?> pmi = const Value.absent(),
            Value<String?> museumPermanent = const Value.absent(),
            Value<String?> museumLoan = const Value.absent(),
            Value<String?> remark = const Value.absent(),
          }) =>
              SpecimenPartCompanion.insert(
            id: id,
            specimenUuid: specimenUuid,
            personnelId: personnelId,
            tissueID: tissueID,
            barcodeID: barcodeID,
            type: type,
            count: count,
            treatment: treatment,
            additionalTreatment: additionalTreatment,
            dateTaken: dateTaken,
            timeTaken: timeTaken,
            pmi: pmi,
            museumPermanent: museumPermanent,
            museumLoan: museumLoan,
            remark: remark,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $SpecimenPartProcessedTableManager = ProcessedTableManager<
    _$Database,
    SpecimenPart,
    SpecimenPartData,
    $SpecimenPartFilterComposer,
    $SpecimenPartOrderingComposer,
    $SpecimenPartAnnotationComposer,
    $SpecimenPartCreateCompanionBuilder,
    $SpecimenPartUpdateCompanionBuilder,
    (
      SpecimenPartData,
      BaseReferences<_$Database, SpecimenPart, SpecimenPartData>
    ),
    SpecimenPartData,
    PrefetchHooks Function()>;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $ProjectTableManager get project => $ProjectTableManager(_db, _db.project);
  $PersonnelTableManager get personnel =>
      $PersonnelTableManager(_db, _db.personnel);
  $MediaTableManager get media => $MediaTableManager(_db, _db.media);
  $SiteTableManager get site => $SiteTableManager(_db, _db.site);
  $CoordinateTableManager get coordinate =>
      $CoordinateTableManager(_db, _db.coordinate);
  $CollEventTableManager get collEvent =>
      $CollEventTableManager(_db, _db.collEvent);
  $WeatherTableManager get weather => $WeatherTableManager(_db, _db.weather);
  $CollPersonnelTableManager get collPersonnel =>
      $CollPersonnelTableManager(_db, _db.collPersonnel);
  $CollEffortTableManager get collEffort =>
      $CollEffortTableManager(_db, _db.collEffort);
  $NarrativeTableManager get narrative =>
      $NarrativeTableManager(_db, _db.narrative);
  $NarrativeMediaTableManager get narrativeMedia =>
      $NarrativeMediaTableManager(_db, _db.narrativeMedia);
  $SiteMediaTableManager get siteMedia =>
      $SiteMediaTableManager(_db, _db.siteMedia);
  $TaxonomyTableManager get taxonomy =>
      $TaxonomyTableManager(_db, _db.taxonomy);
  $SpecimenTableManager get specimen =>
      $SpecimenTableManager(_db, _db.specimen);
  $SpecimenMediaTableManager get specimenMedia =>
      $SpecimenMediaTableManager(_db, _db.specimenMedia);
  $AssociatedDataTableManager get associatedData =>
      $AssociatedDataTableManager(_db, _db.associatedData);
  $PersonnelListTableManager get personnelList =>
      $PersonnelListTableManager(_db, _db.personnelList);
  $MammalMeasurementTableManager get mammalMeasurement =>
      $MammalMeasurementTableManager(_db, _db.mammalMeasurement);
  $AvianMeasurementTableManager get avianMeasurement =>
      $AvianMeasurementTableManager(_db, _db.avianMeasurement);
  $SpecimenPartTableManager get specimenPart =>
      $SpecimenPartTableManager(_db, _db.specimenPart);
}

class ListProjectResult {
  final String uuid;
  final String name;
  final String? created;
  final String? lastAccessed;
  ListProjectResult({
    required this.uuid,
    required this.name,
    this.created,
    this.lastAccessed,
  });
}
