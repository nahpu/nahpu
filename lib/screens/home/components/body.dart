import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nahpu/services/database/database.dart' as db;
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/screens/shared/layout/project_shell.dart';
import 'package:nahpu/screens/projects/components/project_info.dart';
import 'package:nahpu/screens/projects/edit_project.dart';
import 'package:nahpu/screens/settings/onboarding/setup_wizard.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/record_exchange/project_exchange_service.dart';
import 'package:nahpu/services/projects/project_services.dart';
import 'package:nahpu/screens/shared/dialogs/project_exchange_dialogs.dart';
import 'package:nahpu/screens/shared/dialogs/qr_code_dialog.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/providers/media.dart';
import 'package:nahpu/styles/design_tokens.dart';

enum MenuSelection { editInfo, details, exportInfo, showQr, deleteProject }

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
          constraints: const BoxConstraints(maxWidth: NahpuContentWidth.home),
          child: Padding(
            padding: const EdgeInsets.all(NahpuSpacing.xxl),
            child: ref
                .watch(projectListProvider)
                .when(
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

  Widget _buildBody(List<ProjectSummary> projectList) {
    if (projectList.isEmpty) {
      return const ProjectNotFound();
    } else {
      return ToggleView(projectList: projectList);
    }
  }
}

class ToggleView extends StatefulWidget {
  const ToggleView({super.key, required this.projectList});

  final List<ProjectSummary> projectList;

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
            Text(
              'Existing projects',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  isListSelected = !isListSelected;
                });
              },
              iconSize: 24,
              icon: isListSelected
                  ? const Icon(Icons.grid_view)
                  : const Icon(Icons.list_alt),
            ),
          ],
        ),
        isListSelected
            ? ProjectListView(projectList: widget.projectList)
            : ProjectGridView(projectList: widget.projectList),
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
          SvgPicture.asset(
            'assets/icons/box.svg',
            height: 64,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.tertiary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No projects found.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'Create or import a project to get started.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: NahpuSpacing.xxl),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SetupWizardScreen(),
              ),
            ),
            icon: const Icon(Icons.auto_fix_high_outlined),
            label: const Text('Setup NAHPU'),
          ),
        ],
      ),
    );
  }
}

class ProjectListView extends StatelessWidget {
  const ProjectListView({super.key, required this.projectList});
  final List<ProjectSummary> projectList;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: projectList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final project = projectList[index];
          return ProjectView(
            key: ValueKey(project.uuid),
            isList: true,
            project: project,
          );
        },
      ),
    );
  }
}

class ProjectGridView extends StatelessWidget {
  const ProjectGridView({super.key, required this.projectList});

  final List<ProjectSummary> projectList;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth < NahpuBreakpoints.compact
              ? 1
              : 2;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.2,
              crossAxisSpacing: NahpuSpacing.md,
              mainAxisSpacing: NahpuSpacing.md,
            ),
            itemCount: projectList.length,
            itemBuilder: (context, index) {
              final project = projectList[index];
              return ProjectView(
                key: ValueKey(project.uuid),
                isList: false,
                project: project,
              );
            },
          );
        },
      ),
    );
  }
}

class ProjectView extends ConsumerStatefulWidget {
  const ProjectView({super.key, required this.isList, required this.project});

  final bool isList;
  final ProjectSummary project;

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
    return () async {
      final projectUuid = widget.project.uuid;
      ProjectServices(ref: ref).updateProjectUuid(projectUuid);
      // Always open a project on the Dashboard tab.
      ref.read(projectNavbarIndexProvider.notifier).updateState(0);

      await Navigator.push(context, ProjectShell.route());
      if (!mounted) return;
      ref.invalidate(projectPreviewImageFilesProvider(projectUuid));
    };
  }
}

class ListProjectCard extends StatelessWidget {
  const ListProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  final ProjectSummary project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ProjectIcon(color: Theme.of(context).colorScheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withAlpha(40),
            width: NahpuStroke.thin,
          ),
        ),
        tileColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withAlpha(80),
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
  const GridProjectCard({
    super.key,
    required this.project,
    required this.onPressed,
  });

  final ProjectSummary project;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: NahpuElevation.none,
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerHighest.withAlpha(80),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NahpuRadius.lg),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withAlpha(40),
          width: NahpuStroke.thin,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: onPressed,
              child: ProjectGridPreview(projectUuid: project.uuid),
            ),
          ),
          ListTile(
            dense: true,
            title: Text(
              project.name,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _lastAccessedDate,
              style: Theme.of(context).textTheme.labelSmall,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: ProjectPopUpMenu(project: project),
            onTap: onPressed,
          ),
        ],
      ),
    );
  }

  String get _lastAccessedDate {
    final value = parseDate(project.lastAccessed);
    return 'Accessed: ${value.date} ${value.time}';
  }
}

class ProjectGridPreview extends ConsumerWidget {
  const ProjectGridPreview({super.key, required this.projectUuid});

  final String projectUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(projectPreviewImageFilesProvider(projectUuid));
    return images.when(
      data: (files) => files.isEmpty
          ? const ProjectGridIcon()
          : ProjectImageSlideshow(images: files),
      error: (error, stackTrace) => const ProjectGridIcon(),
      loading: () => const ProjectGridIcon(),
    );
  }
}

class ProjectGridIcon extends StatelessWidget {
  const ProjectGridIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide * 0.8;
        return Center(
          child: SizedBox.square(
            key: const ValueKey('project-grid-icon-size'),
            dimension: size,
            child: ProjectIcon(
              color: Theme.of(context).colorScheme.primary,
              size: size,
            ),
          ),
        );
      },
    );
  }
}

class ProjectImageSlideshow extends StatefulWidget {
  const ProjectImageSlideshow({super.key, required this.images})
    : assert(images.length > 0);

  final List<File> images;

  @override
  State<ProjectImageSlideshow> createState() => _ProjectImageSlideshowState();
}

class _ProjectImageSlideshowState extends State<ProjectImageSlideshow> {
  Timer? _timer;
  int _index = 0;
  bool _animationsEnabled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animationsEnabled =
        TickerMode.valuesOf(context).enabled &&
        (ModalRoute.isCurrentOf(context) ?? true) &&
        !MediaQuery.of(context).disableAnimations;
    if (_animationsEnabled == animationsEnabled) return;
    _animationsEnabled = animationsEnabled;
    _restartTimer();
  }

  @override
  void didUpdateWidget(ProjectImageSlideshow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_sameImages(oldWidget.images, widget.images)) return;
    _index = 0;
    _restartTimer();
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.images[_index];
    final mediaQuery = MediaQuery.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedSwitcher(
          duration: mediaQuery.disableAnimations
              ? Duration.zero
              : const Duration(seconds: 1),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: Image.file(
            image,
            key: ValueKey(image.path),
            width: double.infinity,
            height: double.infinity,
            cacheWidth: (constraints.maxWidth * mediaQuery.devicePixelRatio)
                .ceil(),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const ProjectGridIcon();
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (!_animationsEnabled || widget.images.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % widget.images.length;
      });
    });
  }

  bool _sameImages(List<File> oldImages, List<File> newImages) {
    if (oldImages.length != newImages.length) return false;
    for (var index = 0; index < oldImages.length; index++) {
      if (oldImages[index].path != newImages[index].path) return false;
    }
    return true;
  }
}

class ProjectPopUpMenu extends ConsumerStatefulWidget {
  const ProjectPopUpMenu({super.key, required this.project});

  final ProjectSummary project;

  @override
  ProjectPopUpMenuState createState() => ProjectPopUpMenuState();
}

class ProjectPopUpMenuState extends ConsumerState<ProjectPopUpMenu> {
  static const _actions = [
    MenuSelection.editInfo,
    MenuSelection.showQr,
    MenuSelection.exportInfo,
    MenuSelection.details,
  ];

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact) {
      return IconButton(
        tooltip: 'Project actions',
        onPressed: _showActionSheet,
        icon: const Icon(Icons.more_vert),
      );
    }
    return PopupMenuButton<MenuSelection>(
      tooltip: 'Project actions',
      icon: const Icon(Icons.more_vert),
      onSelected: _onSelected,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuSelection>>[
        for (final action in _actions) ...[
          if (_hasDividerBefore(action))
            const PopupMenuDivider(height: NahpuSpacing.md),
          PopupMenuItem<MenuSelection>(
            value: action,
            child: _ProjectMenuTile(action: action),
          ),
        ],
      ],
    );
  }

  Future<void> _showActionSheet() async {
    final action = await showModalBottomSheet<MenuSelection>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final action in _actions) ...[
                if (_hasDividerBefore(action)) const Divider(),
                _ProjectMenuTile(
                  action: action,
                  onTap: () => Navigator.of(sheetContext).pop(action),
                ),
              ],
              const SizedBox(height: NahpuSpacing.md),
            ],
          ),
        ),
      ),
    );
    if (action != null && mounted) await _onSelected(action);
  }

  Future<void> _onSelected(MenuSelection action) async {
    switch (action) {
      case MenuSelection.editInfo:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditProject(
              projectUuid: widget.project.uuid,
              returnToHome: true,
            ),
          ),
        );
      case MenuSelection.showQr:
        final data = await _getProjectInfo(widget.project.uuid);
        if (!mounted) return;
        _showProjectQr(data);
      case MenuSelection.exportInfo:
        final data = await _getProjectInfo(widget.project.uuid);
        if (!mounted) return;
        await showProjectExportDialog(context: context, projectData: data);
      case MenuSelection.details:
        final data = await _getProjectInfo(widget.project.uuid);
        if (!mounted) return;
        _showProjectDialog(data);
      case MenuSelection.deleteProject:
        return;
    }
  }

  Future<db.ProjectData> _getProjectInfo(String projectUuid) async {
    return ProjectServices(ref: ref).getProjectByUuid(projectUuid);
  }

  void _showProjectDialog(db.ProjectData? value) => {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Project information'),
          content: SingleChildScrollView(
            child: ProjectInfo(projectData: value, showExport: false),
          ),
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

  void _showProjectQr(db.ProjectData value) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return QrCodeDialog(
          title: 'Project QR code',
          data: ProjectExchangeService.encodeQr(value),
          description:
              'Scan this code when creating a new project to transfer '
              'project information.',
        );
      },
    );
  }
}

bool _hasDividerBefore(MenuSelection action) {
  return action == MenuSelection.showQr || action == MenuSelection.details;
}

class _ProjectMenuTile extends StatelessWidget {
  const _ProjectMenuTile({required this.action, this.onTap});

  final MenuSelection action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(_icon), title: Text(_label), onTap: onTap);
  }

  IconData get _icon => switch (action) {
    MenuSelection.editInfo => Icons.edit_outlined,
    MenuSelection.showQr => Icons.qr_code_outlined,
    MenuSelection.exportInfo => Icons.file_upload_outlined,
    MenuSelection.details => Icons.info_outlined,
    MenuSelection.deleteProject => Icons.delete_outline,
  };

  String get _label => switch (action) {
    MenuSelection.editInfo => 'Edit info',
    MenuSelection.showQr => 'Show QR',
    MenuSelection.exportInfo => 'Export info',
    MenuSelection.details => 'Details',
    MenuSelection.deleteProject => 'Delete project',
  };
}

class ProjectIcon extends StatelessWidget {
  const ProjectIcon({super.key, required this.color, this.size = 40});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/catalog.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
