import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/shared/features.dart';
import 'package:nahpu/screens/shared/layout.dart';
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

class SiteNameField extends ConsumerWidget {
  const SiteNameField({
    super.key,
    required this.siteId,
  });

  final int? siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<SiteData> siteData = [];
    final siteEntry = ref.watch(siteEntryProvider);
    siteEntry.whenData(
      (data) => siteData = data,
    );

    if (siteId == null) {
      return const SizedBox.shrink();
    }
    
    // We cannot use firstWhereOrNull because it is not available in Iterable
    // by default on older Dart SDKs and we don't want to add a dependency
    // if not needed. Using standard where + isEmpty check.
    final selectedSiteIterable = siteData.where((e) => e.id == siteId);
    if (selectedSiteIterable.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final site = selectedSiteIterable.first;
    
    final List<String?> localityList = [
      site.country,
      site.stateProvince,
      site.county,
      site.municipality,
      site.locality,
    ];

    // Filter out null or empty strings
    final String siteName = localityList
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');

    if (siteName.isEmpty) {
      return const SizedBox.shrink();
    }

    return CommonPadding(
      child: TextField(
        controller: TextEditingController(text: siteName),
        enabled: true,
        readOnly: true,
        maxLines: null,
        decoration: const InputDecoration(
          labelText: 'Site Name',
          hintText: 'Broad locality',
        ),
      ),
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
        // Persist date and (optionally) time into separate columns.
        String? dateStd = narrativeCtr.dateCtr.date;
        String? timeStd = narrativeCtr.timeCtr.time;
        NarrativeServices(ref: ref).updateNarrative(
          narrativeId,
          NarrativeCompanion(
            date: db.Value(dateStd),
            time: db.Value(timeStd),
          ),
        );
      },
      onClear: () {
        // Clearing date should remove the stored date (and time)
        narrativeCtr.timeCtr.time = null;
        NarrativeServices(ref: ref).updateNarrative(
          narrativeId,
          NarrativeCompanion(date: db.Value(null), time: db.Value(null)),
        );
      }
    );
  }
}

class TimeForm extends ConsumerWidget {
  const TimeForm({
    super.key,
    required this.narrativeId,
    required this.narrativeCtr,
  });

  final int narrativeId;
  final NarrativeFormCtrModel narrativeCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void persistTimeChange(String? timeStd) {
      String? dateStd = narrativeCtr.dateCtr.date;
      
      // If setting a time and no date is set, default to today
      if (timeStd != null && timeStd.isNotEmpty && (dateStd == null || dateStd.isEmpty)) {
        final today = DateTime.now();
        dateStd = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        // Update both date and time
        NarrativeServices(ref: ref).updateNarrative(
          narrativeId,
          NarrativeCompanion(
            date: db.Value(dateStd),
            time: db.Value(timeStd),
          ),
        );
      } else {
        // Just update time
        NarrativeServices(ref: ref).updateNarrative(
          narrativeId,
          NarrativeCompanion(time: db.Value(timeStd)),
        );
      }
    }

    return CommonTimeField(
      labelText: 'Time',
      hintText: 'Enter time',
      initialTime: TimeOfDay.now(),
      controller: narrativeCtr.timeCtr,
      onTap: () => persistTimeChange(narrativeCtr.timeCtr.time),
      onClear: () {
        // Clearing time keeps date only
        NarrativeServices(ref: ref).updateNarrative(
          narrativeId,
          NarrativeCompanion(time: db.Value(null)),
        );
      },
    );
  }
}

class WriterForm extends ConsumerWidget {
  const WriterForm({
    super.key,
    required this.narrativeId,
    required this.narrativeCtr,
  });

  final int narrativeId;
  final NarrativeFormCtrModel narrativeCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<PersonnelData> personnelList = [];
    final personnelEntry = ref.watch(projectPersonnelProvider);
    personnelEntry.whenData(
      (personnelEntry) => personnelList = personnelEntry,
    );

    return DropdownButtonFormField<String?>(
      initialValue: narrativeCtr.writerCtr,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Writer',
        hintText: 'Choose a person name',
      ),
      items: personnelList
          .map(
            (e) => DropdownMenuItem(
              value: e.uuid,
              child: CommonDropdownText(text: e.name ?? ''),
            ),
          )
          .toList(),
      onChanged: (String? uuid) async {
        narrativeCtr.writerCtr = uuid;
        await NarrativeServices(ref: ref).updateNarrativeWriter(narrativeId, uuid);
      },
    );
  }
}