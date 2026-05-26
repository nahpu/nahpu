import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as db;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/narrative/components/media.dart';
import 'package:nahpu/screens/narrative/components/top_forms.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/narrative_services.dart';

class NarrativeForm extends ConsumerStatefulWidget {
  const NarrativeForm({
    super.key,
    required this.narrativeId,
    required this.narrativeCtr,
  });

  final int narrativeId;
  final NarrativeFormCtrModel narrativeCtr;

  @override
  NarrativeFormState createState() => NarrativeFormState();
}

class NarrativeFormState extends ConsumerState<NarrativeForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.narrativeCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        bool useHorizontalLayout = constraints.maxWidth > 400.0;
        return FocusDetectedLayout(
          children: [
            FormCard(
              isPrimary: true,
              isWithTitle: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AdaptiveLayout(
                    useHorizontalLayout: useHorizontalLayout,
                    children: [
                      DateForm(
                        narrativeId: widget.narrativeId,
                        narrativeCtr: widget.narrativeCtr,
                      ),
                      // Time field to the right of Date
                      TimeForm(
                        narrativeId: widget.narrativeId,
                        narrativeCtr: widget.narrativeCtr,
                      ),
                    ],
                  ),
                  AdaptiveLayout(
                    useHorizontalLayout: useHorizontalLayout,
                    children: [
                      SiteForm(
                        narrativeId: widget.narrativeId,
                        narrativeCtr: widget.narrativeCtr,
                      ),
                      WriterForm(
                        narrativeId: widget.narrativeId,
                        narrativeCtr: widget.narrativeCtr,
                      ),
                    ],
                  ),
                  SiteNameField(siteId: widget.narrativeCtr.siteCtr),
                ],
              ),
            ),
            FormCard(
              isPrimary: false,
              isWithTitle: false,
              child: NarrativeText(
                narrativeCtr: widget.narrativeCtr,
                narrativeId: widget.narrativeId,
              ),
            ),
            NarrativeMediaForm(
              narrativeId: widget.narrativeId,
            ),
            const BottomPadding()
          ],
        );
      },
    );
  }
}

class NarrativeText extends ConsumerWidget {
  const NarrativeText({
    super.key,
    required this.narrativeCtr,
    required this.narrativeId,
  });

  final NarrativeFormCtrModel narrativeCtr;
  final int narrativeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonPadding(
      child: CommonTextField(
        controller: narrativeCtr.narrativeCtr,
        maxLines: 20,
        labelText: 'Narrative',
        hintText: 'Enter narrative',
        isLastField: true,
        onChanged: (String? value) {
          if (value != null) {
            NarrativeServices(ref: ref).updateNarrative(
              narrativeId,
              NarrativeCompanion(narrative: db.Value(value)),
            );
          }
        },
      ),
    );
  }
}
