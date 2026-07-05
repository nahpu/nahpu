import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/narrative.dart';

final documentSpecimenSelectionProvider =
    NotifierProvider.autoDispose<DocumentSpecimenSelection, Set<String>>(
  DocumentSpecimenSelection.new,
);

class DocumentSpecimenSelection extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final specimens = ref.watch(specimenEntryProvider).value ?? [];
    return specimens.map((e) => e.uuid).toSet();
  }

  void updateSelection(Set<String> selection) {
    state = selection;
  }
}

final documentSiteSelectionProvider =
    NotifierProvider.autoDispose<DocumentSiteSelection, Set<int>>(
  DocumentSiteSelection.new,
);

class DocumentSiteSelection extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    final sites = ref.watch(siteEntryProvider).value ?? [];
    return sites.map((e) => e.id).toSet();
  }

  void updateSelection(Set<int> selection) {
    state = selection;
  }
}

final documentEventSelectionProvider =
    NotifierProvider.autoDispose<DocumentEventSelection, Set<int>>(
  DocumentEventSelection.new,
);

class DocumentEventSelection extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    final events = ref.watch(collEventEntryProvider).value ?? [];
    return events.map((e) => e.id).toSet();
  }

  void updateSelection(Set<int> selection) {
    state = selection;
  }
}

final documentNarrativeSelectionProvider =
    NotifierProvider.autoDispose<DocumentNarrativeSelection, Set<int>>(
  DocumentNarrativeSelection.new,
);

class DocumentNarrativeSelection extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    final narratives = ref.watch(narrativeEntryProvider).value ?? [];
    return narratives.map((e) => e.id).toSet();
  }

  void updateSelection(Set<int> selection) {
    state = selection;
  }
}
