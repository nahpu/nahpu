import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/specimens/arthropods/attributes.dart';
import 'package:nahpu/screens/specimens/birds/attributes.dart';
import 'package:nahpu/screens/specimens/mammalian/attributes.dart';
import 'package:nahpu/screens/specimens/herpetofauna/attributes.dart';
import 'package:nahpu/screens/specimens/shared/capture_records.dart';
import 'package:nahpu/screens/specimens/shared/general_records.dart';
import 'package:nahpu/screens/specimens/shared/media.dart';
import 'package:nahpu/screens/specimens/shared/specimen_parts.dart';
import 'package:nahpu/screens/specimens/shared/taxonomy.dart';
import 'package:nahpu/styles/catalog_pages.dart';

class MainForms extends ConsumerStatefulWidget {
  const MainForms({
    super.key,
    required this.catalogFmt,
    required this.specimenUuid,
    required this.specimenCtr,
  });

  final CatalogFmt catalogFmt;
  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  MainFormsState createState() => MainFormsState();
}

class MainFormsState extends ConsumerState<MainForms> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        bool useHorizontalLayout = c.maxWidth > 600;
        return FocusDetectedLayout(
          children: [
            AdaptiveMainLayout(
              useHorizontalLayout: useHorizontalLayout,
              height: topSpecimenRecordHeight,
              children: [
                GeneralRecordField(
                  specimenUuid: widget.specimenUuid,
                  specimenCtr: widget.specimenCtr,
                  useHorizontalLayout: useHorizontalLayout,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TaxonomicForm(
                      useHorizontalLayout: useHorizontalLayout,
                      specimenUuid: widget.specimenUuid,
                    ),
                    CaptureRecordFields(
                      specimenUuid: widget.specimenUuid,
                      useHorizontalLayout: useHorizontalLayout,
                      specimenCtr: widget.specimenCtr,
                    ),
                  ],
                ),
              ],
            ),
            AdaptiveMainLayout(
              useHorizontalLayout: useHorizontalLayout,
              height: bottomSpecimenRecordHeight,
              children: [
                getAttributeForm(widget.catalogFmt, useHorizontalLayout),
                PartDataForm(
                  specimenUuid: widget.specimenUuid,
                  catalogFmt: widget.catalogFmt,
                ),
              ],
            ),
            SpecimenMediaForm(specimenUuid: widget.specimenUuid),
            const BottomPadding(),
          ],
        );
      },
    );
  }

  Widget getAttributeForm(CatalogFmt fmt, bool useHorizontalLayout) {
    switch (widget.catalogFmt) {
      case CatalogFmt.birds:
        return BirdAttributeForms(
          useHorizontalLayout: useHorizontalLayout,
          specimenUuid: widget.specimenUuid,
        );
      case CatalogFmt.mammals:
        return MammalAttributeForms(
          useHorizontalLayout: useHorizontalLayout,
          specimenUuid: widget.specimenUuid,
        );
      case CatalogFmt.herpetofauna:
        return HerpAttributeForms(
          useHorizontalLayout: useHorizontalLayout,
          specimenUuid: widget.specimenUuid,
        );
      case CatalogFmt.arthropods:
        return ArthropodAttributeForms(
          useHorizontalLayout: useHorizontalLayout,
          specimenUuid: widget.specimenUuid,
        );
    }
  }
}
