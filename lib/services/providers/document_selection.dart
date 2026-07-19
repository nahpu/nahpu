import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/templates/template_service.dart';

final documentSpecimenSelectionProvider =
    NotifierProvider.autoDispose<DocumentSpecimenSelection, Set<String>>(
  DocumentSpecimenSelection.new,
);

class DocumentSpecimenSelection extends Notifier<Set<String>> {
  bool _hasUserSelection = false;
  Set<String> _selection = <String>{};

  @override
  Set<String> build() {
    final specimens = ref.watch(specimenEntryProvider).value ?? [];
    final allIds = specimens.map((e) => e.uuid).toSet();
    if (!_hasUserSelection) {
      _selection = allIds;
      return allIds;
    }
    _selection = _selection.intersection(allIds);
    return _selection;
  }

  void updateSelection(Set<String> selection) {
    _hasUserSelection = true;
    _selection = selection;
    state = _selection;
  }
}

final documentSiteSelectionProvider =
    NotifierProvider.autoDispose<DocumentSiteSelection, Set<int>>(
  DocumentSiteSelection.new,
);

class DocumentSiteSelection extends Notifier<Set<int>> {
  bool _hasUserSelection = false;
  Set<int> _selection = <int>{};

  @override
  Set<int> build() {
    final sites = ref.watch(siteEntryProvider).value ?? [];
    final allIds = sites.map((e) => e.id).toSet();
    if (!_hasUserSelection) {
      _selection = allIds;
      return allIds;
    }
    _selection = _selection.intersection(allIds);
    return _selection;
  }

  void updateSelection(Set<int> selection) {
    _hasUserSelection = true;
    _selection = selection;
    state = _selection;
  }
}

final documentEventSelectionProvider =
    NotifierProvider.autoDispose<DocumentEventSelection, Set<int>>(
  DocumentEventSelection.new,
);

class DocumentEventSelection extends Notifier<Set<int>> {
  bool _hasUserSelection = false;
  Set<int> _selection = <int>{};

  @override
  Set<int> build() {
    final events = ref.watch(collEventEntryProvider).value ?? [];
    final allIds = events.map((e) => e.id).toSet();
    if (!_hasUserSelection) {
      _selection = allIds;
      return allIds;
    }
    _selection = _selection.intersection(allIds);
    return _selection;
  }

  void updateSelection(Set<int> selection) {
    _hasUserSelection = true;
    _selection = selection;
    state = _selection;
  }
}

final documentNarrativeSelectionProvider =
    NotifierProvider.autoDispose<DocumentNarrativeSelection, Set<int>>(
  DocumentNarrativeSelection.new,
);

class DocumentNarrativeSelection extends Notifier<Set<int>> {
  bool _hasUserSelection = false;
  Set<int> _selection = <int>{};

  @override
  Set<int> build() {
    final narratives = ref.watch(narrativeEntryProvider).value ?? [];
    final allIds = narratives.map((e) => e.id).toSet();
    if (!_hasUserSelection) {
      _selection = allIds;
      return allIds;
    }
    _selection = _selection.intersection(allIds);
    return _selection;
  }

  void updateSelection(Set<int> selection) {
    _hasUserSelection = true;
    _selection = selection;
    state = _selection;
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
  bool _hasUserSelection = false;
  Set<String> _selection = <String>{};

  bool get hasUserSelection => _hasUserSelection;

  @override
  Set<String> build() {
    final allIds = _allRecordIds();
    if (!_hasUserSelection) {
      _selection = allIds;
      return allIds;
    }
    _selection = _selection.intersection(allIds);
    return _selection;
  }

  Set<String> _allRecordIds() {
    if (arg.recordType == RecordType.specimenRecord) {
      final specimens = ref.watch(specimenEntryProvider).value ?? [];
      return specimens.map((e) => e.uuid).toSet();
    } else if (arg.recordType == RecordType.specimenParts) {
      final parts = ref.watch(specimenPartEntryProvider).value ?? [];
      return parts.map((e) => e.recordId).whereType<String>().toSet();
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
    _hasUserSelection = true;
    _selection = selection;
    state = _selection;
  }
}

final templateRecordTypeProvider =
    FutureProvider.family<RecordType, String>((ref, templateName) async {
  final tmpl = await const TemplateService().getTemplate(templateName);
  return tmpl?.recordType ?? RecordType.specimenRecord;
});
