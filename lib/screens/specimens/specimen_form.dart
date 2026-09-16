import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/specimens/shared/main_forms.dart';

/// The specimen record form.
///
/// Owns the field controllers for as long as the record is on screen. Building
/// them from the record on every rebuild would replace them whenever the
/// specimen list is invalidated -- which happens on every taxon selection --
/// and take the form's scroll position and focus with them.
class SpecimenForm extends ConsumerStatefulWidget {
  const SpecimenForm({
    super.key,
    required this.specimen,
    required this.catalogFmt,
  });

  final SpecimenData specimen;
  final CatalogFmt catalogFmt;

  @override
  SpecimenFormState createState() => SpecimenFormState();
}

class SpecimenFormState extends ConsumerState<SpecimenForm> {
  late final SpecimenFormCtrModel _specimenCtr = SpecimenFormCtrModel.fromData(
    widget.specimen,
  );

  @override
  Widget build(BuildContext context) {
    return MainForms(
      catalogFmt: widget.catalogFmt,
      specimenUuid: widget.specimen.uuid,
      specimenCtr: _specimenCtr,
    );
  }

  @override
  void didUpdateWidget(covariant SpecimenForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.specimen == widget.specimen) return;
    _specimenCtr.syncFrom(widget.specimen);
  }

  @override
  void dispose() {
    _specimenCtr.dispose();
    super.dispose();
  }
}
