import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/symbiont_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/projects/project_services.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

class SymbiontServices extends AppServices {
  const SymbiontServices({required super.ref});

  Future<void> ensureDetection(String specimenUuid) async {
    await SymbiontQuery(dbAccess).ensureDetection(specimenUuid);
    ref.invalidate(symbiontDetectionProvider(specimenUuid));
  }

  Future<void> updateDetection(
    String specimenUuid,
    SymbiontDetectionCompanion form,
  ) async {
    await SymbiontQuery(dbAccess).updateDetection(specimenUuid, form);
    ref.invalidate(symbiontDetectionProvider(specimenUuid));
  }

  /// The active project's symbionts, each with its parent specimen.
  Future<List<SymbiontProjectRecord>> getProjectSymbionts() {
    return SymbiontQuery(dbAccess).getSymbiontsForProject(currentProjectUuid);
  }

  Future<int> createSymbiont(
    String specimenUuid,
    SymbiontCompanion form,
  ) async {
    final entry = form.symbiontUuid.present
        ? form
        : form.copyWith(symbiontUuid: db.Value(uuid));
    final id = await SymbiontQuery(dbAccess).createSymbiont(entry);
    _invalidate(specimenUuid);
    return id;
  }

  Future<void> updateSymbiont(
    int id,
    String specimenUuid,
    SymbiontCompanion form,
  ) async {
    await SymbiontQuery(dbAccess).updateSymbiont(id, form);
    _invalidate(specimenUuid);
  }

  Future<void> deleteSymbionts(String specimenUuid, List<int> ids) async {
    await SymbiontQuery(dbAccess).deleteSymbionts(ids);
    _invalidate(specimenUuid);
  }

  Future<void> deleteAllForSpecimen(String specimenUuid) async {
    await SymbiontQuery(dbAccess).deleteAllForSpecimen(specimenUuid);
    _invalidate(specimenUuid);
    ref.invalidate(symbiontDetectionProvider(specimenUuid));
  }

  /// The collector and collection date a new symbiont on [specimenUuid]
  /// starts with, taken from the host.
  Future<({String? collectorId, String? dateCollected})> getHostDefaults(
    String specimenUuid,
  ) async {
    final host = await (dbAccess.select(
      dbAccess.specimen,
    )..where((t) => t.uuid.equals(specimenUuid))).getSingleOrNull();
    return (
      collectorId: defaultSymbiontCollector(host),
      dateCollected: defaultSymbiontCollectionDate(host),
    );
  }

  Future<List<int>> getIndividualIdsForSymbiont(int symbiontId) {
    return SymbiontIndividualQuery(
      dbAccess,
    ).getIndividualIdsForSymbiont(symbiontId);
  }

  /// Replaces the lot individuals [symbiontId] was found on.
  Future<void> setSymbiontIndividuals(
    int symbiontId,
    Iterable<int> individualIds,
  ) {
    return SymbiontIndividualQuery(
      dbAccess,
    ).setIndividualsForSymbiont(symbiontId, individualIds);
  }

  void invalidateSymbiontIndividuals(int symbiontId) {
    ref.invalidate(individualsBySymbiontProvider(symbiontId));
  }

  void _invalidate(String specimenUuid) {
    ref.invalidate(symbiontBySpecimenProvider(specimenUuid));
    ref.invalidate(symbiontEntryProvider);
  }
}

/// Whoever processes the host usually sweeps and necropsies it for symbionts.
String? defaultSymbiontCollector(SpecimenData? host) {
  final preparator = host?.preparatorID;
  if (preparator != null && preparator.isNotEmpty) return preparator;
  final cataloger = host?.catalogerID;
  if (cataloger != null && cataloger.isNotEmpty) return cataloger;
  return null;
}

/// The host's collection date, or its preparation date when none is set,
/// since symbionts are often taken while the host is prepared.
String? defaultSymbiontCollectionDate(SpecimenData? host) {
  final collected = host?.collectionDate;
  if (collected != null && collected.isNotEmpty) return collected;
  final prepared = host?.prepDate;
  if (prepared != null && prepared.isNotEmpty) return prepared;
  return null;
}

class SymbiontIdServices {
  const SymbiontIdServices();

  Future<String> getNewNumber() async {
    final prefix = await getPrefix();
    final number = await getNumber();
    await setNumber((number + 1).toString());
    return '$prefix$number';
  }

  Future<String> getPrefix() async {
    return await rust_config.getUserConfigString(
          key: symbiontIdPrefixPrefKey,
        ) ??
        '';
  }

  Future<int> getNumber() async {
    final value = await rust_config.getUserConfigString(
      key: symbiontIdNumberPrefKey,
    );
    return int.tryParse(value ?? '') ?? 0;
  }

  Future<String> getNumberString() async {
    final value = await rust_config.getUserConfigString(
      key: symbiontIdNumberPrefKey,
    );
    return value ?? '';
  }

  Future<void> setPrefix(String prefix) {
    return rust_config.setUserConfigString(
      key: symbiontIdPrefixPrefKey,
      value: prefix.trim(),
    );
  }

  Future<void> setNumber(String number) {
    final parsed = int.tryParse(number.trim()) ?? 0;
    return rust_config.setUserConfigString(
      key: symbiontIdNumberPrefKey,
      value: parsed.toString(),
    );
  }
}
