import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as db;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common.dart';
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
    // Persist date and time (if any) before disposing controllers so that
    // unsaved changes are not lost when the user navigates away.
    try {
      String? dateStd = widget.narrativeCtr.dateCtr.date;
      String? timeStd = widget.narrativeCtr.timeCtr.time;

      NarrativeServices(ref: ref).updateNarrative(
        widget.narrativeId,
        NarrativeCompanion(
          date: db.Value(dateStd),
          time: db.Value(timeStd),
        ),
      );
    } catch (e) {
      // Best-effort: don't crash on dispose if update fails.
    }

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
              child: CommonPadding(
                child: TextField(
                  scrollPhysics: const ScrollPhysics(),
                  controller: widget.narrativeCtr.narrativeCtr,
                  maxLines: 20,
                  decoration: const InputDecoration(
                    labelText: 'Narrative',
                    hintText: 'Enter narrative',
                  ),
                  onChanged: (value) {
                    NarrativeServices(ref: ref).updateNarrative(
                      widget.narrativeId,
                      NarrativeCompanion(narrative: db.Value(value)),
                    );
                  },
                ),
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
