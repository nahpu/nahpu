// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'validation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectForm {
  ProjectFormField get projectName;
  ProjectFormField get existingProject;

  /// Create a copy of ProjectForm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProjectFormCopyWith<ProjectForm> get copyWith =>
      _$ProjectFormCopyWithImpl<ProjectForm>(this as ProjectForm, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProjectForm &&
            (identical(other.projectName, projectName) ||
                other.projectName == projectName) &&
            (identical(other.existingProject, existingProject) ||
                other.existingProject == existingProject));
  }

  @override
  int get hashCode => Object.hash(runtimeType, projectName, existingProject);

  @override
  String toString() {
    return 'ProjectForm(projectName: $projectName, existingProject: $existingProject)';
  }
}

/// @nodoc
abstract mixin class $ProjectFormCopyWith<$Res> {
  factory $ProjectFormCopyWith(
          ProjectForm value, $Res Function(ProjectForm) _then) =
      _$ProjectFormCopyWithImpl;
  @useResult
  $Res call({ProjectFormField projectName, ProjectFormField existingProject});

  $ProjectFormFieldCopyWith<$Res> get projectName;
  $ProjectFormFieldCopyWith<$Res> get existingProject;
}

/// @nodoc
class _$ProjectFormCopyWithImpl<$Res> implements $ProjectFormCopyWith<$Res> {
  _$ProjectFormCopyWithImpl(this._self, this._then);

  final ProjectForm _self;
  final $Res Function(ProjectForm) _then;

  /// Create a copy of ProjectForm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? projectName = null,
    Object? existingProject = null,
  }) {
    return _then(_self.copyWith(
      projectName: null == projectName
          ? _self.projectName
          : projectName // ignore: cast_nullable_to_non_nullable
              as ProjectFormField,
      existingProject: null == existingProject
          ? _self.existingProject
          : existingProject // ignore: cast_nullable_to_non_nullable
              as ProjectFormField,
    ));
  }

  /// Create a copy of ProjectForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProjectFormFieldCopyWith<$Res> get projectName {
    return $ProjectFormFieldCopyWith<$Res>(_self.projectName, (value) {
      return _then(_self.copyWith(projectName: value));
    });
  }

  /// Create a copy of ProjectForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProjectFormFieldCopyWith<$Res> get existingProject {
    return $ProjectFormFieldCopyWith<$Res>(_self.existingProject, (value) {
      return _then(_self.copyWith(existingProject: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ProjectForm].
extension ProjectFormPatterns on ProjectForm {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ProjectForm value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProjectForm() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ProjectForm value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectForm():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ProjectForm value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectForm() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            ProjectFormField projectName, ProjectFormField existingProject)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProjectForm() when $default != null:
        return $default(_that.projectName, _that.existingProject);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            ProjectFormField projectName, ProjectFormField existingProject)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectForm():
        return $default(_that.projectName, _that.existingProject);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            ProjectFormField projectName, ProjectFormField existingProject)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectForm() when $default != null:
        return $default(_that.projectName, _that.existingProject);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ProjectForm extends ProjectForm {
  const _ProjectForm({required this.projectName, required this.existingProject})
      : super._();

  @override
  final ProjectFormField projectName;
  @override
  final ProjectFormField existingProject;

  /// Create a copy of ProjectForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProjectFormCopyWith<_ProjectForm> get copyWith =>
      __$ProjectFormCopyWithImpl<_ProjectForm>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProjectForm &&
            (identical(other.projectName, projectName) ||
                other.projectName == projectName) &&
            (identical(other.existingProject, existingProject) ||
                other.existingProject == existingProject));
  }

  @override
  int get hashCode => Object.hash(runtimeType, projectName, existingProject);

  @override
  String toString() {
    return 'ProjectForm(projectName: $projectName, existingProject: $existingProject)';
  }
}

/// @nodoc
abstract mixin class _$ProjectFormCopyWith<$Res>
    implements $ProjectFormCopyWith<$Res> {
  factory _$ProjectFormCopyWith(
          _ProjectForm value, $Res Function(_ProjectForm) _then) =
      __$ProjectFormCopyWithImpl;
  @override
  @useResult
  $Res call({ProjectFormField projectName, ProjectFormField existingProject});

  @override
  $ProjectFormFieldCopyWith<$Res> get projectName;
  @override
  $ProjectFormFieldCopyWith<$Res> get existingProject;
}

/// @nodoc
class __$ProjectFormCopyWithImpl<$Res> implements _$ProjectFormCopyWith<$Res> {
  __$ProjectFormCopyWithImpl(this._self, this._then);

  final _ProjectForm _self;
  final $Res Function(_ProjectForm) _then;

  /// Create a copy of ProjectForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? projectName = null,
    Object? existingProject = null,
  }) {
    return _then(_ProjectForm(
      projectName: null == projectName
          ? _self.projectName
          : projectName // ignore: cast_nullable_to_non_nullable
              as ProjectFormField,
      existingProject: null == existingProject
          ? _self.existingProject
          : existingProject // ignore: cast_nullable_to_non_nullable
              as ProjectFormField,
    ));
  }

  /// Create a copy of ProjectForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProjectFormFieldCopyWith<$Res> get projectName {
    return $ProjectFormFieldCopyWith<$Res>(_self.projectName, (value) {
      return _then(_self.copyWith(projectName: value));
    });
  }

  /// Create a copy of ProjectForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProjectFormFieldCopyWith<$Res> get existingProject {
    return $ProjectFormFieldCopyWith<$Res>(_self.existingProject, (value) {
      return _then(_self.copyWith(existingProject: value));
    });
  }
}

/// @nodoc
mixin _$ProjectFormField {
  String? get errMsg;
  bool get isValid;

  /// Create a copy of ProjectFormField
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProjectFormFieldCopyWith<ProjectFormField> get copyWith =>
      _$ProjectFormFieldCopyWithImpl<ProjectFormField>(
          this as ProjectFormField, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProjectFormField &&
            (identical(other.errMsg, errMsg) || other.errMsg == errMsg) &&
            (identical(other.isValid, isValid) || other.isValid == isValid));
  }

  @override
  int get hashCode => Object.hash(runtimeType, errMsg, isValid);

  @override
  String toString() {
    return 'ProjectFormField(errMsg: $errMsg, isValid: $isValid)';
  }
}

/// @nodoc
abstract mixin class $ProjectFormFieldCopyWith<$Res> {
  factory $ProjectFormFieldCopyWith(
          ProjectFormField value, $Res Function(ProjectFormField) _then) =
      _$ProjectFormFieldCopyWithImpl;
  @useResult
  $Res call({String? errMsg, bool isValid});
}

/// @nodoc
class _$ProjectFormFieldCopyWithImpl<$Res>
    implements $ProjectFormFieldCopyWith<$Res> {
  _$ProjectFormFieldCopyWithImpl(this._self, this._then);

  final ProjectFormField _self;
  final $Res Function(ProjectFormField) _then;

  /// Create a copy of ProjectFormField
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? errMsg = freezed,
    Object? isValid = null,
  }) {
    return _then(_self.copyWith(
      errMsg: freezed == errMsg
          ? _self.errMsg
          : errMsg // ignore: cast_nullable_to_non_nullable
              as String?,
      isValid: null == isValid
          ? _self.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [ProjectFormField].
extension ProjectFormFieldPatterns on ProjectFormField {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ProjectFormField value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProjectFormField() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ProjectFormField value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectFormField():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ProjectFormField value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectFormField() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String? errMsg, bool isValid)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProjectFormField() when $default != null:
        return $default(_that.errMsg, _that.isValid);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String? errMsg, bool isValid) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectFormField():
        return $default(_that.errMsg, _that.isValid);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String? errMsg, bool isValid)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProjectFormField() when $default != null:
        return $default(_that.errMsg, _that.isValid);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ProjectFormField implements ProjectFormField {
  _ProjectFormField({required this.errMsg, this.isValid = false});

  @override
  final String? errMsg;
  @override
  @JsonKey()
  final bool isValid;

  /// Create a copy of ProjectFormField
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProjectFormFieldCopyWith<_ProjectFormField> get copyWith =>
      __$ProjectFormFieldCopyWithImpl<_ProjectFormField>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProjectFormField &&
            (identical(other.errMsg, errMsg) || other.errMsg == errMsg) &&
            (identical(other.isValid, isValid) || other.isValid == isValid));
  }

  @override
  int get hashCode => Object.hash(runtimeType, errMsg, isValid);

  @override
  String toString() {
    return 'ProjectFormField(errMsg: $errMsg, isValid: $isValid)';
  }
}

/// @nodoc
abstract mixin class _$ProjectFormFieldCopyWith<$Res>
    implements $ProjectFormFieldCopyWith<$Res> {
  factory _$ProjectFormFieldCopyWith(
          _ProjectFormField value, $Res Function(_ProjectFormField) _then) =
      __$ProjectFormFieldCopyWithImpl;
  @override
  @useResult
  $Res call({String? errMsg, bool isValid});
}

/// @nodoc
class __$ProjectFormFieldCopyWithImpl<$Res>
    implements _$ProjectFormFieldCopyWith<$Res> {
  __$ProjectFormFieldCopyWithImpl(this._self, this._then);

  final _ProjectFormField _self;
  final $Res Function(_ProjectFormField) _then;

  /// Create a copy of ProjectFormField
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? errMsg = freezed,
    Object? isValid = null,
  }) {
    return _then(_ProjectFormField(
      errMsg: freezed == errMsg
          ? _self.errMsg
          : errMsg // ignore: cast_nullable_to_non_nullable
              as String?,
      isValid: null == isValid
          ? _self.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$PersonnelForm {
  PersonnelFormField get name;
  PersonnelFormField get email;
  PersonnelFormField get initial;
  PersonnelFormField get collNum;

  /// Create a copy of PersonnelForm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PersonnelFormCopyWith<PersonnelForm> get copyWith =>
      _$PersonnelFormCopyWithImpl<PersonnelForm>(
          this as PersonnelForm, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PersonnelForm &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.initial, initial) || other.initial == initial) &&
            (identical(other.collNum, collNum) || other.collNum == collNum));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, email, initial, collNum);

  @override
  String toString() {
    return 'PersonnelForm(name: $name, email: $email, initial: $initial, collNum: $collNum)';
  }
}

/// @nodoc
abstract mixin class $PersonnelFormCopyWith<$Res> {
  factory $PersonnelFormCopyWith(
          PersonnelForm value, $Res Function(PersonnelForm) _then) =
      _$PersonnelFormCopyWithImpl;
  @useResult
  $Res call(
      {PersonnelFormField name,
      PersonnelFormField email,
      PersonnelFormField initial,
      PersonnelFormField collNum});

  $PersonnelFormFieldCopyWith<$Res> get name;
  $PersonnelFormFieldCopyWith<$Res> get email;
  $PersonnelFormFieldCopyWith<$Res> get initial;
  $PersonnelFormFieldCopyWith<$Res> get collNum;
}

/// @nodoc
class _$PersonnelFormCopyWithImpl<$Res>
    implements $PersonnelFormCopyWith<$Res> {
  _$PersonnelFormCopyWithImpl(this._self, this._then);

  final PersonnelForm _self;
  final $Res Function(PersonnelForm) _then;

  /// Create a copy of PersonnelForm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? email = null,
    Object? initial = null,
    Object? collNum = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as PersonnelFormField,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as PersonnelFormField,
      initial: null == initial
          ? _self.initial
          : initial // ignore: cast_nullable_to_non_nullable
              as PersonnelFormField,
      collNum: null == collNum
          ? _self.collNum
          : collNum // ignore: cast_nullable_to_non_nullable
              as PersonnelFormField,
    ));
  }

  /// Create a copy of PersonnelForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PersonnelFormFieldCopyWith<$Res> get name {
    return $PersonnelFormFieldCopyWith<$Res>(_self.name, (value) {
      return _then(_self.copyWith(name: value));
    });
  }

  /// Create a copy of PersonnelForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PersonnelFormFieldCopyWith<$Res> get email {
    return $PersonnelFormFieldCopyWith<$Res>(_self.email, (value) {
      return _then(_self.copyWith(email: value));
    });
  }

  /// Create a copy of PersonnelForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PersonnelFormFieldCopyWith<$Res> get initial {
    return $PersonnelFormFieldCopyWith<$Res>(_self.initial, (value) {
      return _then(_self.copyWith(initial: value));
    });
  }

  /// Create a copy of PersonnelForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PersonnelFormFieldCopyWith<$Res> get collNum {
    return $PersonnelFormFieldCopyWith<$Res>(_self.collNum, (value) {
      return _then(_self.copyWith(collNum: value));
    });
  }
}

/// Adds pattern-matching-related methods to [PersonnelForm].
extension PersonnelFormPatterns on PersonnelForm {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PersonnelForm value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PersonnelForm() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PersonnelForm value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonnelForm():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PersonnelForm value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonnelForm() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(PersonnelFormField name, PersonnelFormField email,
            PersonnelFormField initial, PersonnelFormField collNum)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PersonnelForm() when $default != null:
        return $default(_that.name, _that.email, _that.initial, _that.collNum);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(PersonnelFormField name, PersonnelFormField email,
            PersonnelFormField initial, PersonnelFormField collNum)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonnelForm():
        return $default(_that.name, _that.email, _that.initial, _that.collNum);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(PersonnelFormField name, PersonnelFormField email,
            PersonnelFormField initial, PersonnelFormField collNum)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonnelForm() when $default != null:
        return $default(_that.name, _that.email, _that.initial, _that.collNum);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PersonnelForm extends PersonnelForm {
  const _PersonnelForm(
      {required this.name,
      required this.email,
      required this.initial,
      required this.collNum})
      : super._();

  @override
  final PersonnelFormField name;
  @override
  final PersonnelFormField email;
  @override
  final PersonnelFormField initial;
  @override
  final PersonnelFormField collNum;

  /// Create a copy of PersonnelForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PersonnelFormCopyWith<_PersonnelForm> get copyWith =>
      __$PersonnelFormCopyWithImpl<_PersonnelForm>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PersonnelForm &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.initial, initial) || other.initial == initial) &&
            (identical(other.collNum, collNum) || other.collNum == collNum));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, email, initial, collNum);

  @override
  String toString() {
    return 'PersonnelForm(name: $name, email: $email, initial: $initial, collNum: $collNum)';
  }
}

/// @nodoc
abstract mixin class _$PersonnelFormCopyWith<$Res>
    implements $PersonnelFormCopyWith<$Res> {
  factory _$PersonnelFormCopyWith(
          _PersonnelForm value, $Res Function(_PersonnelForm) _then) =
      __$PersonnelFormCopyWithImpl;
  @override
  @useResult
  $Res call(
      {PersonnelFormField name,
      PersonnelFormField email,
      PersonnelFormField initial,
      PersonnelFormField collNum});

  @override
  $PersonnelFormFieldCopyWith<$Res> get name;
  @override
  $PersonnelFormFieldCopyWith<$Res> get email;
  @override
  $PersonnelFormFieldCopyWith<$Res> get initial;
  @override
  $PersonnelFormFieldCopyWith<$Res> get collNum;
}

/// @nodoc
class __$PersonnelFormCopyWithImpl<$Res>
    implements _$PersonnelFormCopyWith<$Res> {
  __$PersonnelFormCopyWithImpl(this._self, this._then);

  final _PersonnelForm _self;
  final $Res Function(_PersonnelForm) _then;

  /// Create a copy of PersonnelForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? email = null,
    Object? initial = null,
    Object? collNum = null,
  }) {
    return _then(_PersonnelForm(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as PersonnelFormField,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as PersonnelFormField,
      initial: null == initial
          ? _self.initial
          : initial // ignore: cast_nullable_to_non_nullable
              as PersonnelFormField,
      collNum: null == collNum
          ? _self.collNum
          : collNum // ignore: cast_nullable_to_non_nullable
              as PersonnelFormField,
    ));
  }

  /// Create a copy of PersonnelForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PersonnelFormFieldCopyWith<$Res> get name {
    return $PersonnelFormFieldCopyWith<$Res>(_self.name, (value) {
      return _then(_self.copyWith(name: value));
    });
  }

  /// Create a copy of PersonnelForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PersonnelFormFieldCopyWith<$Res> get email {
    return $PersonnelFormFieldCopyWith<$Res>(_self.email, (value) {
      return _then(_self.copyWith(email: value));
    });
  }

  /// Create a copy of PersonnelForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PersonnelFormFieldCopyWith<$Res> get initial {
    return $PersonnelFormFieldCopyWith<$Res>(_self.initial, (value) {
      return _then(_self.copyWith(initial: value));
    });
  }

  /// Create a copy of PersonnelForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PersonnelFormFieldCopyWith<$Res> get collNum {
    return $PersonnelFormFieldCopyWith<$Res>(_self.collNum, (value) {
      return _then(_self.copyWith(collNum: value));
    });
  }
}

/// @nodoc
mixin _$PersonnelFormField {
  String? get errMsg;
  bool get isValid;

  /// Create a copy of PersonnelFormField
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PersonnelFormFieldCopyWith<PersonnelFormField> get copyWith =>
      _$PersonnelFormFieldCopyWithImpl<PersonnelFormField>(
          this as PersonnelFormField, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PersonnelFormField &&
            (identical(other.errMsg, errMsg) || other.errMsg == errMsg) &&
            (identical(other.isValid, isValid) || other.isValid == isValid));
  }

  @override
  int get hashCode => Object.hash(runtimeType, errMsg, isValid);

  @override
  String toString() {
    return 'PersonnelFormField(errMsg: $errMsg, isValid: $isValid)';
  }
}

/// @nodoc
abstract mixin class $PersonnelFormFieldCopyWith<$Res> {
  factory $PersonnelFormFieldCopyWith(
          PersonnelFormField value, $Res Function(PersonnelFormField) _then) =
      _$PersonnelFormFieldCopyWithImpl;
  @useResult
  $Res call({String? errMsg, bool isValid});
}

/// @nodoc
class _$PersonnelFormFieldCopyWithImpl<$Res>
    implements $PersonnelFormFieldCopyWith<$Res> {
  _$PersonnelFormFieldCopyWithImpl(this._self, this._then);

  final PersonnelFormField _self;
  final $Res Function(PersonnelFormField) _then;

  /// Create a copy of PersonnelFormField
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? errMsg = freezed,
    Object? isValid = null,
  }) {
    return _then(_self.copyWith(
      errMsg: freezed == errMsg
          ? _self.errMsg
          : errMsg // ignore: cast_nullable_to_non_nullable
              as String?,
      isValid: null == isValid
          ? _self.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [PersonnelFormField].
extension PersonnelFormFieldPatterns on PersonnelFormField {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PersonnelFormField value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PersonnelFormField() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PersonnelFormField value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonnelFormField():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PersonnelFormField value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonnelFormField() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String? errMsg, bool isValid)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PersonnelFormField() when $default != null:
        return $default(_that.errMsg, _that.isValid);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String? errMsg, bool isValid) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonnelFormField():
        return $default(_that.errMsg, _that.isValid);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String? errMsg, bool isValid)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PersonnelFormField() when $default != null:
        return $default(_that.errMsg, _that.isValid);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PersonnelFormField implements PersonnelFormField {
  _PersonnelFormField({required this.errMsg, this.isValid = false});

  @override
  final String? errMsg;
  @override
  @JsonKey()
  final bool isValid;

  /// Create a copy of PersonnelFormField
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PersonnelFormFieldCopyWith<_PersonnelFormField> get copyWith =>
      __$PersonnelFormFieldCopyWithImpl<_PersonnelFormField>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PersonnelFormField &&
            (identical(other.errMsg, errMsg) || other.errMsg == errMsg) &&
            (identical(other.isValid, isValid) || other.isValid == isValid));
  }

  @override
  int get hashCode => Object.hash(runtimeType, errMsg, isValid);

  @override
  String toString() {
    return 'PersonnelFormField(errMsg: $errMsg, isValid: $isValid)';
  }
}

/// @nodoc
abstract mixin class _$PersonnelFormFieldCopyWith<$Res>
    implements $PersonnelFormFieldCopyWith<$Res> {
  factory _$PersonnelFormFieldCopyWith(
          _PersonnelFormField value, $Res Function(_PersonnelFormField) _then) =
      __$PersonnelFormFieldCopyWithImpl;
  @override
  @useResult
  $Res call({String? errMsg, bool isValid});
}

/// @nodoc
class __$PersonnelFormFieldCopyWithImpl<$Res>
    implements _$PersonnelFormFieldCopyWith<$Res> {
  __$PersonnelFormFieldCopyWithImpl(this._self, this._then);

  final _PersonnelFormField _self;
  final $Res Function(_PersonnelFormField) _then;

  /// Create a copy of PersonnelFormField
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? errMsg = freezed,
    Object? isValid = null,
  }) {
    return _then(_PersonnelFormField(
      errMsg: freezed == errMsg
          ? _self.errMsg
          : errMsg // ignore: cast_nullable_to_non_nullable
              as String?,
      isValid: null == isValid
          ? _self.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
