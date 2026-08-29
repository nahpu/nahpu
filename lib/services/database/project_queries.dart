import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';

part 'project_queries.g.dart';

@DriftAccessor(include: {'tables.drift'})
class ProjectQuery extends DatabaseAccessor<Database> with _$ProjectQueryMixin {
  ProjectQuery(super.db);

  Future<void> createProject(ProjectCompanion form) =>
      into(project).insert(form);

  Future<List<ProjectData>> getAllProjects() => select(project).get();

  Future<List<String>> getAllProjectNames() =>
      select(project).map((e) => e.name).get();

  Future<ProjectData> getProjectByUuid(String uuid) async {
    return await (select(
      project,
    )..where((t) => t.uuid.equals(uuid))).getSingle();
  }

  Future<bool> projectUuidExists(String uuid) async {
    final row =
        await (selectOnly(project)
              ..addColumns([project.uuid])
              ..where(project.uuid.equals(uuid))
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  Future<ProjectData?> getProjectByName(String name) async {
    try {
      return await (select(
        project,
      )..where((t) => t.name.equals(name))).getSingle();
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProjectEntry(String uuid, ProjectCompanion entry) {
    return (update(project)..where((t) => t.uuid.equals(uuid))).write(entry);
  }

  Future<bool> hasProjectFieldNumbers(String projectUuid) async {
    final row =
        await (selectOnly(db.specimen)
              ..addColumns([db.specimen.uuid])
              ..where(db.specimen.projectUuid.equals(projectUuid))
              ..where(db.specimen.projectFieldNumber.isNotNull())
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  Future<List<ProjectSummary>> getProjectList() async {
    final query = selectOnly(project)
      ..addColumns([
        project.uuid,
        project.name,
        project.created,
        project.lastAccessed,
      ]);

    final rows = await query.get();
    return rows
        .map(
          (row) => ProjectSummary(
            uuid: row.read(project.uuid)!,
            name: row.read(project.name)!,
            created: row.read(project.created),
            lastAccessed: row.read(project.lastAccessed),
          ),
        )
        .toList(growable: false);
  }

  Future<int> deleteProject(String id) async {
    return await (delete(project)..where((t) => t.uuid.equals(id))).go();
  }

  Future<void> deleteAllProjects() {
    return (delete(project)).go();
  }
}

class ProjectSummary {
  const ProjectSummary({
    required this.uuid,
    required this.name,
    required this.created,
    required this.lastAccessed,
  });

  final String uuid;
  final String name;
  final String? created;
  final String? lastAccessed;
}
