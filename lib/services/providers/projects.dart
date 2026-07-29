/// Project module providers contain all the providers related to the project,
/// Except for the project form validation provider, which is in the validation.dart file.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/database/database.dart' as db;
import 'package:nahpu/services/database/project_queries.dart';

final projectListProvider = FutureProvider.autoDispose<List<ProjectSummary>>((
  ref,
) {
  return ProjectQuery(ref.read(databaseProvider)).getProjectList();
});

final projectInfoProvider = FutureProvider.family<db.ProjectData?, String>((
  ref,
  uuid,
) async {
  final projectInfo = ProjectQuery(
    ref.read(databaseProvider),
  ).getProjectByUuid(uuid);
  return await projectInfo;
});

final currProjInfoProvider = FutureProvider.autoDispose<db.ProjectData>((
  ref,
) async {
  final projectUuid = ref.read(projectUuidProvider);
  final currProjectInfo = ProjectQuery(
    ref.read(databaseProvider),
  ).getProjectByUuid(projectUuid);
  return await currProjectInfo;
});

final projectUuidProvider = NotifierProvider<ProjectUuid, String>(
  ProjectUuid.new,
);

class ProjectUuid extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void updateProjectUuid(String uuid) {
    state = uuid;
  }
}

final projectNavbarIndexProvider =
    NotifierProvider.autoDispose<ProjectNavbarIndex, int>(
  ProjectNavbarIndex.new,
);

class ProjectNavbarIndex extends Notifier<int> {
  @override
  int build() => 0;

  void updateState(int index) {
    state = index;
  }
}
