import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/specimens/shared/main_forms.dart';

class SpecimenForm extends ConsumerStatefulWidget {
  const SpecimenForm(
      {super.key,
      required this.specimenUuid,
      required this.specimenCtr,
      required this.catalogFmt});

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;
  final CatalogFmt catalogFmt;

  @override
  SpecimenFormState createState() => SpecimenFormState();
}

class SpecimenFormState extends ConsumerState<SpecimenForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.specimenCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainForms(
      catalogFmt: widget.catalogFmt,
      specimenUuid: widget.specimenUuid, 
      specimenCtr: widget.specimenCtr
    );
  }
}
