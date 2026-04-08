import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/personnel/personnel_form.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/types/controllers.dart';

class NewPersonnel extends ConsumerWidget {
  const NewPersonnel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PersonnelFormCtrModel ctr = PersonnelFormCtrModel.empty();
    return PersonnelFormPage(
      ctr: ctr,
      personnelUuid: uuid,
      isEditing: false,
    );
  }
}

class EditPersonnelForm extends ConsumerWidget {
  const EditPersonnelForm({super.key, required this.personnelData});

  final PersonnelData personnelData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    PersonnelFormCtrModel ctr = _getController(personnelData);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit personnel'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ScrollableConstrainedLayout(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PersonnelFormPage(
                ctr: ctr,
                personnelUuid: personnelData.uuid,
                isEditing: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PersonnelFormCtrModel _getController(PersonnelData personnelData) {
    return PersonnelFormCtrModel.fromData(personnelData);
  }
}
