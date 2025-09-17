import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'validation.g.dart';
part 'validation.freezed.dart';

@freezed
abstract class ProjectForm with _$ProjectForm {
  const ProjectForm._();

  const factory ProjectForm({
    required ProjectFormField projectName,
    required ProjectFormField existingProject,
  }) = _ProjectForm;

  factory ProjectForm.empty() => ProjectForm(
        projectName: ProjectFormField(errMsg: null, isValid: false),
        existingProject: ProjectFormField(errMsg: null, isValid: false),
      );

  bool get isValid => projectName.isValid && existingProject.isValid;
}

@freezed
abstract class ProjectFormField with _$ProjectFormField {
  factory ProjectFormField({
    required String? errMsg,
    @Default(false) bool isValid,
  }) = _ProjectFormField;
}

@riverpod
class ProjectFormValidator extends _$ProjectFormValidator {
  Future<ProjectForm> _fetch() {
    return Future.value(ProjectForm.empty());
  }

  @override
  FutureOr<ProjectForm> build() {
    return _fetch();
  }

  Future<void> validateOnEditing(
      String? initialProjectName, String? value) async {
    await validateProjectName(value);
    if (initialProjectName != value) {
      await checkProjectNameExists(value);
    } else {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        if (state.value == null) return ProjectForm.empty();
        return state.value!.copyWith(
            existingProject: ProjectFormField(errMsg: null, isValid: true));
      });
    }
  }

  Future<void> validateProjectName(String? value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (state.value == null) return ProjectForm.empty();
      if (value == null || value.isEmpty) {
        return state.value!.copyWith(
            projectName: ProjectFormField(errMsg: null, isValid: false));
      }

      if (value.length < 3) {
        return state.value!.copyWith(
            projectName: ProjectFormField(
                errMsg: "Project name is too short", isValid: false));
      }

      if (!value.isValidProjectName) {
        return state.value!.copyWith(
            projectName: ProjectFormField(
                errMsg: "Project name is invalid", isValid: false));
      }

      if (value.length > 25) {
        return state.value!.copyWith(
            projectName: ProjectFormField(
                errMsg: "Project name is too long", isValid: false));
      }

      return state.value!
          .copyWith(projectName: ProjectFormField(errMsg: null, isValid: true));
    });
  }

  Future<void> checkProjectNameExists(String? value) async {
    if (value == null && value!.isEmpty) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (state.value == null) return ProjectForm.empty();
      List<String> data =
          await ProjectQuery(ref.read(databaseProvider)).getAllProjectNames();
      if (data.isEmpty) {
        return state.value!.copyWith(
            existingProject: ProjectFormField(errMsg: null, isValid: true));
      }

      bool isMatch = _findMatchingName(data, value);
      if (isMatch) {
        return state.value!.copyWith(
            existingProject: ProjectFormField(
                errMsg: "Project name already exists", isValid: false));
      }
      return state.value!.copyWith(
          existingProject: ProjectFormField(errMsg: null, isValid: true));
    });
  }

  bool _findMatchingName(List<String> projectNames, String value) {
    return isListContains(projectNames, value);
  }
}

@freezed
abstract class PersonnelForm with _$PersonnelForm {
  const PersonnelForm._();

  const factory PersonnelForm({
    required PersonnelFormField name,
    required PersonnelFormField email,
    required PersonnelFormField initial,
    required PersonnelFormField collNum,
  }) = _PersonnelForm;

  factory PersonnelForm.empty() => PersonnelForm(
        name: PersonnelFormField(errMsg: null, isValid: false),
        email: PersonnelFormField(errMsg: null, isValid: true),
        initial: PersonnelFormField(errMsg: null, isValid: false),
        collNum: PersonnelFormField(errMsg: null, isValid: false),
      );

  bool get isValidCataloger =>
      name.isValid && initial.isValid && collNum.isValid && email.isValid;

  bool get isValidOther => name.isValid && email.isValid;
}

@freezed
abstract class PersonnelFormField with _$PersonnelFormField {
  factory PersonnelFormField({
    required String? errMsg,
    @Default(false) bool isValid,
  }) = _PersonnelFormField;
}

@riverpod
class PersonnelFormValidator extends _$PersonnelFormValidator {
  Future<PersonnelForm> _fetch() {
    return Future.value(PersonnelForm.empty());
  }

  @override
  FutureOr<PersonnelForm> build() {
    return _fetch();
  }

  Future<void> validateAll(PersonnelFormCtrModel formCtr) async {
    await validateName(formCtr.nameCtr.text);
    await validateEmail(formCtr.emailCtr.text);
    await validateInitial(formCtr.initialCtr.text);
    await validateCollNum(formCtr.collectorNumCtr.text);
  }

  Future<void> validateName(String? value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (value == null || value.isEmpty || state.value == null) {
        return state.value!
            .copyWith(name: PersonnelFormField(errMsg: null, isValid: false));
      }

      if (value.length < 3) {
        return state.value!.copyWith(
            name: PersonnelFormField(
                errMsg: "Name is too short", isValid: false));
      }

      if (!value.isValidName) {
        return state.value!.copyWith(
            name: PersonnelFormField(
                errMsg: "Invalid characters", isValid: false));
      }

      return state.value!
          .copyWith(name: PersonnelFormField(errMsg: null, isValid: true));
    });
  }

  Future<void> validateEmail(String? value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // We allow email to be empty by default it is set to valid
      if (state.value == null) {
        return PersonnelForm.empty();
      }

      if (value == null || value.isEmpty) {
        return state.value!
            .copyWith(email: PersonnelFormField(errMsg: null, isValid: true));
      }

      if (!value.isValidEmail) {
        return state.value!.copyWith(
            email: PersonnelFormField(
                errMsg: "Invalid email address", isValid: false));
      }

      return state.value!
          .copyWith(email: PersonnelFormField(errMsg: null, isValid: true));
    });
  }

  Future<void> validateInitial(String? value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (value == null || value.isEmpty || state.value == null) {
        return state.value!.copyWith(
            initial: PersonnelFormField(errMsg: null, isValid: false));
      }

      if (value.length < 2) {
        return state.value!.copyWith(
            initial: PersonnelFormField(
                errMsg: "Initial is too short", isValid: false));
      }

      if (!value.isValidInitial) {
        return state.value!.copyWith(
            initial: PersonnelFormField(
                errMsg: "Invalid characters", isValid: false));
      }

      return state.value!
          .copyWith(initial: PersonnelFormField(errMsg: null, isValid: true));
    });
  }

  Future<void> validateCollNum(String? value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (value == null || value.isEmpty || state.value == null) {
        return state.value!.copyWith(
            collNum: PersonnelFormField(errMsg: null, isValid: false));
      }

      if (!value.isValidCollNum) {
        return state.value!.copyWith(
            collNum: PersonnelFormField(
                errMsg: "Invalid collector number", isValid: false));
      }

      return state.value!
          .copyWith(collNum: PersonnelFormField(errMsg: null, isValid: true));
    });
  }
}
