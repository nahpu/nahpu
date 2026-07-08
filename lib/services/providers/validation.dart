import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/utility_services.dart';

class ProjectFormField {
  final String? errMsg;
  final bool isValid;

  ProjectFormField({
    required this.errMsg,
    this.isValid = false,
  });

  ProjectFormField copyWith({
    String? errMsg,
    bool? isValid,
  }) {
    return ProjectFormField(
      errMsg: errMsg ?? this.errMsg,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectFormField &&
          runtimeType == other.runtimeType &&
          errMsg == other.errMsg &&
          isValid == other.isValid;

  @override
  int get hashCode => Object.hash(errMsg, isValid);
}

class ProjectForm {
  final ProjectFormField projectName;
  final ProjectFormField existingProject;

  const ProjectForm({
    required this.projectName,
    required this.existingProject,
  });

  factory ProjectForm.empty() => ProjectForm(
        projectName: ProjectFormField(errMsg: null, isValid: false),
        existingProject: ProjectFormField(errMsg: null, isValid: false),
      );

  bool get isValid {
    return projectName.isValid && existingProject.isValid;
  }

  ProjectForm copyWith({
    ProjectFormField? projectName,
    ProjectFormField? existingProject,
  }) {
    return ProjectForm(
      projectName: projectName ?? this.projectName,
      existingProject: existingProject ?? this.existingProject,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectForm &&
          runtimeType == other.runtimeType &&
          projectName == other.projectName &&
          existingProject == other.existingProject;

  @override
  int get hashCode => Object.hash(projectName, existingProject);
}

class PersonnelFormField {
  final String? errMsg;
  final bool isValid;

  PersonnelFormField({
    required this.errMsg,
    this.isValid = false,
  });

  PersonnelFormField copyWith({
    String? errMsg,
    bool? isValid,
  }) {
    return PersonnelFormField(
      errMsg: errMsg ?? this.errMsg,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonnelFormField &&
          runtimeType == other.runtimeType &&
          errMsg == other.errMsg &&
          isValid == other.isValid;

  @override
  int get hashCode => Object.hash(errMsg, isValid);
}

class PersonnelForm {
  final PersonnelFormField name;
  final PersonnelFormField email;
  final PersonnelFormField initial;
  final PersonnelFormField collNum;

  const PersonnelForm({
    required this.name,
    required this.email,
    required this.initial,
    required this.collNum,
  });

  factory PersonnelForm.empty() => PersonnelForm(
        name: PersonnelFormField(errMsg: null, isValid: false),
        email: PersonnelFormField(errMsg: null, isValid: true),
        initial: PersonnelFormField(errMsg: null, isValid: false),
        collNum: PersonnelFormField(errMsg: null, isValid: false),
      );

  bool get isValidCataloger {
    return name.isValid && email.isValid && initial.isValid && collNum.isValid;
  }

  bool get isValidOther => name.isValid && email.isValid;

  PersonnelForm copyWith({
    PersonnelFormField? name,
    PersonnelFormField? email,
    PersonnelFormField? initial,
    PersonnelFormField? collNum,
  }) {
    return PersonnelForm(
      name: name ?? this.name,
      email: email ?? this.email,
      initial: initial ?? this.initial,
      collNum: collNum ?? this.collNum,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonnelForm &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email &&
          initial == other.initial &&
          collNum == other.collNum;

  @override
  int get hashCode => Object.hash(name, email, initial, collNum);
}

final projectFormValidatorProvider =
    AsyncNotifierProvider.autoDispose<ProjectFormValidator, ProjectForm>(
        ProjectFormValidator.new);

class ProjectFormValidator extends AsyncNotifier<ProjectForm> {
  Future<ProjectForm> _fetch() {
    return Future.value(ProjectForm.empty());
  }

  @override
  Future<ProjectForm> build() {
    return _fetch();
  }

  Future<void> validateOnCreate(String? projectName) async {
    await validateProjectName(projectName);
    await checkProjectNameExists(projectName);
  }

  Future<void> validateOnEditing(
      String? initialProjectName, String? projectName) async {
    await validateProjectName(projectName);
    if (initialProjectName != projectName) {
      await checkProjectNameExists(projectName);
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
    if (value == null || value.isEmpty) return;

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

final personnelFormValidatorProvider =
    AsyncNotifierProvider.autoDispose<PersonnelFormValidator, PersonnelForm>(
        PersonnelFormValidator.new);

class PersonnelFormValidator extends AsyncNotifier<PersonnelForm> {
  Future<PersonnelForm> _fetch() {
    return Future.value(PersonnelForm.empty());
  }

  @override
  Future<PersonnelForm> build() {
    return _fetch();
  }

  Future<void> validateAll(PersonnelFormCtrModel formCtr) async {
    await validateName(formCtr.nameCtr.text);
    await validateEmail(formCtr.emailCtr.text);
    await validateInitial(formCtr.initialCtr.text, formCtr.isRegisterField);
    await validateCollNum(
        formCtr.collectorNumCtr.text, formCtr.isRegisterField);
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

  Future<void> validateInitial(String? value, bool isRegister) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (!isRegister) {
        return state.value!
            .copyWith(initial: PersonnelFormField(errMsg: null, isValid: true));
      }

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

  Future<void> validateCollNum(String? value, bool isRegister) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (!isRegister) {
        return state.value!
            .copyWith(collNum: PersonnelFormField(errMsg: null, isValid: true));
      }

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
