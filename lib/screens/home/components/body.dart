import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nahpu/services/database/database.dart' as db;
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/screens/projects/dashboard.dart';
import 'package:nahpu/screens/projects/components/project_info.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/utility_services.dart';

enum MenuSelection { details, deleteProject }

class HomeBody extends ConsumerStatefulWidget {
  const HomeBody({super.key});

  @override
  HomeBodyState createState() => HomeBodyState();
}

class HomeBodyState extends ConsumerState<HomeBody> {
  // Table size
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ref.watch(projectListProvider).when(
              data: (data) {
                return _buildBody(data.reversed.toList());
              },
              loading: () {
                return const CommonProgressIndicator();
              },
              error: (error, stackTrace) {
                return Text(error.toString());
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<ListProjectResult> projectList) {
    if (projectList.isEmpty) {
      return const ProjectNotFound();
    } else {
      return ToggleView(projectList: projectList);
    }
  }
}

class ToggleView extends StatefulWidget {
  const ToggleView({super.key, required this.projectList});

  final List<ListProjectResult> projectList;

  @override
  State<ToggleView> createState() => _ToggleViewState();
}

class _ToggleViewState extends State<ToggleView> {
  bool isListSelected = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Existing projects',
                style: Theme.of(context).textTheme.labelLarge),
            IconButton(
                onPressed: () {
                  setState(() {
                    isListSelected = !isListSelected;
                  });
                },
                iconSize: 24,
                icon: isListSelected
                    ? const Icon(Icons.grid_view)
                    : const Icon(Icons.list_alt)),
          ],
        ),
        // Divider(
        //   color: Theme.of(context).colorScheme.onSurface,
        //   thickness: 1.5,
        // ),
        isListSelected
            ? ProjectListView(projectList: widget.projectList)
            : ProjectGridView(
                projectList: widget.projectList,
              ),
      ],
    );
  }
}

class ProjectNotFound extends StatelessWidget {
  const ProjectNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/icons/box.svg',
              height: 64,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.tertiary,
                BlendMode.srcIn,
              )),
          const SizedBox(height: 16),
          Text(
            'No projects found.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'Create a new project to get started.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class ProjectListView extends StatelessWidget {
  const ProjectListView({super.key, required this.projectList});
  final List<ListProjectResult> projectList;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: projectList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ProjectView(
            isList: true,
            project: projectList[index],
          );
        },
      ),
    );
  }
}

class ProjectGridView extends StatelessWidget {
  const ProjectGridView({
    super.key,
    required this.projectList,
  });

  final List<ListProjectResult> projectList;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    const int gridSize = 400;
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: getCrossAxisCount(width, gridSize),
          childAspectRatio: 1.2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: projectList.length,
        itemBuilder: (context, index) {
          return ProjectView(isList: false, project: projectList[index]);
        },
      ),
    );
  }
}

class ProjectView extends ConsumerStatefulWidget {
  const ProjectView({
    super.key,
    required this.isList,
    required this.project,
  });

  final bool isList;
  final ListProjectResult project;

  @override
  ProjectViewState createState() => ProjectViewState();
}

class ProjectViewState extends ConsumerState<ProjectView> {
  @override
  Widget build(BuildContext context) {
    return widget.isList
        ? ListProjectCard(project: widget.project, onTap: _openProject())
        : GridProjectCard(project: widget.project, onPressed: _openProject());
  }

  VoidCallback _openProject() {
    return () {
      ProjectServices(ref: ref).updateProjectUuid(widget.project.uuid);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    };
  }
}

class ListProjectCard extends StatelessWidget {
  const ListProjectCard(
      {super.key, required this.project, required this.onTap});

  final ListProjectResult project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ProjectIcon(
          color: Theme.of(context).colorScheme.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withAlpha(40),
            width: 1.5,
          ),
        ),
        tileColor:
            Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
        dense: true,
        title: Text(
          project.name,
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Accessed: $_lastAccessedDate'
          '${listTileSeparator}Created: $_creationDate',
          style: Theme.of(context).textTheme.labelSmall,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: ProjectPopUpMenu(project: project),
        onTap: onTap,
      ),
    );
  }

  String get _creationDate {
    final value = parseDate(project.created);
    return '${value.date} ${value.time}';
  }

  String get _lastAccessedDate {
    final value = parseDate(project.lastAccessed);
    return '${value.date} ${value.time}';
  }
}

class GridProjectCard extends StatelessWidget {
  const GridProjectCard(
      {super.key, required this.project, required this.onPressed});

  final ListProjectResult project;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GridTile(
        footer: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            dense: true,
            title: Text(
              project.name,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _lastAccessedDate,
              style: const TextStyle(
                fontSize: 12,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: ProjectPopUpMenu(project: project),
            onTap: onPressed,
          ),
        ),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 68),
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withAlpha(80),
                  // color: Theme.of(context)
                  //     .colorScheme
                  //     .primaryContainer
                  //     .withAlpha(120),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withAlpha(40),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(32),
                child: ProjectIcon(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )));
  }

  String get _lastAccessedDate {
    final value = parseDate(project.lastAccessed);
    return 'Accessed: ${value.date} ${value.time}';
  }
}

class ProjectPopUpMenu extends ConsumerStatefulWidget {
  const ProjectPopUpMenu({super.key, required this.project});

  final ListProjectResult project;

  @override
  ProjectPopUpMenuState createState() => ProjectPopUpMenuState();
}

class ProjectPopUpMenuState extends ConsumerState<ProjectPopUpMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuSelection>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuSelection>>[
        PopupMenuItem<MenuSelection>(
          value: MenuSelection.details,
          child: const ListTile(
            leading: Icon(Icons.info_outlined),
            title: Text('Details'),
          ),
          onTap: () async {
            db.ProjectData data = await _getProjectInfo(widget.project.uuid);
            _showProjectDialog(data);
          },
        ),
      ],
    );
  }

  Future<db.ProjectData> _getProjectInfo(String projectUuid) async {
    // We technically can directly call the projectInfoProvider here,
    // but for the popup menu to work, we need to implement Future.delayed
    // and call the provider from the onTap function of the popup menu.
    // when we tested this, users have to tap twice to get the popup menu to work.
    // This solution works well.
    db.ProjectData data =
        await ProjectServices(ref: ref).getProjectByUuid(projectUuid);
    return data;
  }

  void _showProjectDialog(db.ProjectData? value) => {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Project information'),
              content:
                  SingleChildScrollView(child: ProjectInfo(projectData: value)),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        ),
      };
}

class ProjectIcon extends StatelessWidget {
  const ProjectIcon({super.key, required this.color, this.size = 32});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/project.svg',
      height: size,
      colorFilter: ColorFilter.mode(
        color,
        BlendMode.srcIn,
      ),
    );
  }
}
