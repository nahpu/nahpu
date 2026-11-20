import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';

/// Refreshes every list that shows project records after the database
/// changed underneath them, such as an import or a repair.
void invalidateProjectRecordProviders(WidgetRef ref, String projectUuid) {
  ref.invalidate(projectListProvider);
  ref.invalidate(currProjInfoProvider);
  ref.invalidate(projectInfoProvider(projectUuid));
  ref.invalidate(projectPersonnelProvider);
  ref.invalidate(allPersonnelProvider);
  ref.invalidate(taxonRegistryProvider);
  ref.invalidate(taxonProvider);
  ref.invalidate(siteEntryProvider);
  ref.invalidate(coordinateByProjectProvider);
  ref.invalidate(collEventEntryProvider);
  ref.invalidate(specimenEntryProvider);
  ref.invalidate(narrativeEntryProvider);
  invalidateEffectiveControlledVocabularies(ref);
}
