import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/template_service.dart';

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

class BlockRecordSelectionParam {
  const BlockRecordSelectionParam({
    required this.blockIndex,
    required this.recordType,
  });

  final int blockIndex;
  final RecordType recordType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockRecordSelectionParam &&
          runtimeType == other.runtimeType &&
          blockIndex == other.blockIndex &&
          recordType == other.recordType;

  @override
  int get hashCode => blockIndex.hashCode ^ recordType.hashCode;
}

final blockRecordSelectionProvider = NotifierProvider.family<
    BlockRecordSelection, Set<String>, BlockRecordSelectionParam>(
  BlockRecordSelection.new,
);

class BlockRecordSelection extends Notifier<Set<String>> {
  BlockRecordSelection(this.arg);
  final BlockRecordSelectionParam arg;

  @override
  Set<String> build() {
    if (arg.recordType == RecordType.specimenRecord) {
      final specimens = ref.watch(specimenEntryProvider).value ?? [];
      return specimens.map((e) => e.uuid).toSet();
    } else if (arg.recordType == RecordType.site) {
      final sites = ref.watch(siteEntryProvider).value ?? [];
      return sites.map((e) => e.id.toString()).toSet();
    } else if (arg.recordType == RecordType.collEvent) {
      final events = ref.watch(collEventEntryProvider).value ?? [];
      return events.map((e) => e.id.toString()).toSet();
    } else if (arg.recordType == RecordType.narrative) {
      final narratives = ref.watch(narrativeEntryProvider).value ?? [];
      return narratives.map((e) => e.id.toString()).toSet();
    }
    return <String>{};
  }

  void updateSelection(Set<String> selection) {
    state = selection;
  }
}

final templateRecordTypeProvider =
    FutureProvider.family<RecordType, String>((ref, templateName) async {
  final tmpl = await const TemplateService().getTemplate(templateName);
  return tmpl?.recordType ?? RecordType.specimenRecord;
});
