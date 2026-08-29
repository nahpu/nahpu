import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';

class CollActivityFields extends ConsumerWidget {
  const CollActivityFields({
    super.key,
    required this.collEventId,
    required this.collEventCtr,
  });

  final int collEventId;
  final CollEventFormCtrModel collEventCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormCard(
      title: 'Activity',
      infoTopic: InfoTopic.eventActivity,
      mainAxisSize: MainAxisSize.min,
      child: CommonPadding(
        child: Column(
          children: [
            ref
                .watch(effectiveUserDefinedFieldProvider(collActivityPrefKey))
                .when(
                  data: (data) {
                    final options = includeCurrentVocabularyValue(
                      data,
                      collEventCtr.primaryCollMethodCtr,
                    );
                    return DropdownButtonFormField<String?>(
                      initialValue: collEventCtr.primaryCollMethodCtr,
                      decoration: const InputDecoration(
                        labelText: 'Primary activity',
                        hintText: 'Select an activity',
                      ),
                      items: options
                          .map(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: CommonDropdownText(text: value),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (newValue) {
                        CollEventServices(ref: ref).updateCollEvent(
                          collEventId,
                          CollEventCompanion(
                            primaryCollMethod: db.Value(newValue),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) =>
                      Text('Unable to load primary activities: $error'),
                ),
            TextField(
              maxLines: 5,
              controller: collEventCtr.noteCtr,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter notes about the activity',
              ),
              onChanged: (String? newValue) {
                CollEventServices(ref: ref).updateCollEvent(
                  collEventId,
                  CollEventCompanion(collMethodNotes: db.Value(newValue)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
