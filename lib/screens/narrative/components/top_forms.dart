import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/screens/shared/features.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/narrative_services.dart';

class SiteForm extends ConsumerWidget {
  const SiteForm({
    super.key,
    required this.narrativeId,
    required this.narrativeCtr,
  });

  final int narrativeId;
  final NarrativeFormCtrModel narrativeCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<SiteData> data = [];
    final siteEntry = ref.watch(siteEntryProvider);
    siteEntry.whenData(
      (siteEntry) => data = siteEntry,
    );
    return SiteIdField(
      value: narrativeCtr.siteCtr,
      siteData: data,
      onChanges: (int? value) {
        NarrativeServices(ref: ref).updateNarrative(
          narrativeId,
          NarrativeCompanion(siteID: db.Value(value)),
        );
      },
    );
  }
}

class DateForm extends ConsumerWidget {
  const DateForm({
    super.key,
    required this.narrativeId,
    required this.narrativeCtr,
  });

  final int narrativeId;
  final NarrativeFormCtrModel narrativeCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonDateField(
      labelText: 'Date',
      hintText: 'Enter date',
      initialDate: DateTime.now(),
      lastDate: DateTime.now(),
      controller: narrativeCtr.dateCtr,
      onTap: () {
        NarrativeServices(ref: ref).updateNarrative(
          narrativeId,
          NarrativeCompanion(date: db.Value(narrativeCtr.dateCtr.text)),
        );
      },
      onClear: () {
        NarrativeServices(ref: ref).updateNarrative(
          narrativeId,
          NarrativeCompanion(date: db.Value(null)),
        );
      }
    );
  }
}
