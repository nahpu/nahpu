import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/screens/projects/components/project_form.dart';

class EditProject extends ConsumerStatefulWidget {
  const EditProject({
    super.key,
    required this.projectUuid,
    this.returnToHome = false,
  });

  final String projectUuid;
  final bool returnToHome;

  @override
  EditProjectState createState() => EditProjectState();
}

class EditProjectState extends ConsumerState<EditProject> {
  ProjectFormCtrModel? _projectCtr;

  @override
  void dispose() {
    _projectCtr?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit project'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ref
            .watch(projectInfoProvider(widget.projectUuid))
            .when(
              data: (data) => ProjectForm(
                projectCtr: _projectCtr ??= ProjectFormCtrModel.fromData(data),
                projectUuid: widget.projectUuid,
                isEditing: true,
                returnToHome: widget.returnToHome,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text(error.toString()),
            ),
      ),
    );
  }
}
