import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as db;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/site_name_display.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/narrative/components/media.dart';
import 'package:nahpu/screens/narrative/components/top_forms.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/narrative_services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

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
                        onSiteChanged: (siteId) {
                          setState(() {
                            widget.narrativeCtr.siteCtr = siteId;
                          });
                        },
                      ),
                      WriterForm(
                        narrativeId: widget.narrativeId,
                        narrativeCtr: widget.narrativeCtr,
                      ),
                    ],
                  ),
                  SiteNameDisplay(siteId: widget.narrativeCtr.siteCtr),
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

class NarrativeText extends ConsumerStatefulWidget {
  const NarrativeText({
    super.key,
    required this.narrativeCtr,
    required this.narrativeId,
  });

  final NarrativeFormCtrModel narrativeCtr;
  final int narrativeId;

  @override
  NarrativeTextState createState() => NarrativeTextState();
}

class NarrativeTextState extends ConsumerState<NarrativeText> {
  bool _isEditing = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Narrative',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
                icon: Icon(
                  _isEditing ? Icons.visibility : Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: _isEditing ? 'Preview' : 'Edit',
              ),
            ),
          ],
        ),
        CommonPadding(
          child: _isEditing
              ? TextField(
                  decoration: const InputDecoration(
                    hintText: 'Enter narrative (Markdown supported)',
                  ),
                  controller: widget.narrativeCtr.narrativeCtr,
                  maxLines: 20,
                  onChanged: (String? value) {
                    if (value != null) {
                      NarrativeServices(ref: ref).updateNarrative(
                        widget.narrativeId,
                        NarrativeCompanion(narrative: db.Value(value)),
                      );
                    }
                  },
                )
              : Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: MarkdownBody(
                    data: widget.narrativeCtr.narrativeCtr.text.isEmpty
                        ? '*No narrative. Use the Edit button above to start writing.*'
                        : widget.narrativeCtr.narrativeCtr.text,
                    selectable: true,
                  ),
                ),
        ),
      ],
    );
  }
}
