import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;

const List<String> collActivityList = [
  'Collecting',
  'Recording',
  'Observing',
  'Other',
];

class CollActivityFields extends ConsumerWidget {
  const CollActivityFields(
      {super.key, required this.collEventId, required this.collEventCtr});

  final int collEventId;
  final CollEventFormCtrModel collEventCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormCard(
      title: 'Activity',
      infoContent: const ActivityInfoContent(),
      mainAxisSize: MainAxisSize.min,
      child: CommonPadding(
        child: Column(
          children: [
            DropdownButtonFormField(
              initialValue: collEventCtr.primaryCollMethodCtr,
              decoration: const InputDecoration(
                labelText: 'Primary activity',
                hintText: 'Add activity',
              ),
              items: collActivityList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: CommonDropdownText(text: value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                CollEventServices(ref: ref).updateCollEvent(
                  collEventId,
                  CollEventCompanion(primaryCollMethod: db.Value(newValue)),
                );
              },
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

class ActivityInfoContent extends StatelessWidget {
  const ActivityInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(content: [
      InfoContent(
        content: 'Primary activity for the event.'
            'We recommend to add notes if you have a secondary activity'
            ' or select "Other".',
      ),
    ]);
  }
}
