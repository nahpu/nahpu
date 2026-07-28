import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/parasite_queries.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/providers/specimens.dart';

class ParasiteServices extends AppServices {
  const ParasiteServices({required super.ref});

  Future<void> ensureDetection(String specimenUuid) async {
    await ParasiteQuery(dbAccess).ensureDetection(specimenUuid);
    ref.invalidate(parasiteDetectionProvider(specimenUuid));
  }

  Future<void> updateDetection(
    String specimenUuid,
    ParasiteDetectionCompanion form,
  ) async {
    await ParasiteQuery(dbAccess).updateDetection(specimenUuid, form);
    ref.invalidate(parasiteDetectionProvider(specimenUuid));
  }

  Future<void> createParasite(
    String specimenUuid,
    ParasiteCompanion form,
  ) async {
    final entry = form.parasiteUuid.present
        ? form
        : form.copyWith(parasiteUuid: db.Value(uuid));
    await ParasiteQuery(dbAccess).createParasite(entry);
    _invalidate(specimenUuid);
  }

  Future<void> updateParasite(
    int id,
    String specimenUuid,
    ParasiteCompanion form,
  ) async {
    await ParasiteQuery(dbAccess).updateParasite(id, form);
    _invalidate(specimenUuid);
  }

  Future<void> deleteParasites(String specimenUuid, List<int> ids) async {
    await ParasiteQuery(dbAccess).deleteParasites(ids);
    _invalidate(specimenUuid);
  }

  Future<void> deleteAllForSpecimen(String specimenUuid) async {
    await ParasiteQuery(dbAccess).deleteAllForSpecimen(specimenUuid);
    _invalidate(specimenUuid);
    ref.invalidate(parasiteDetectionProvider(specimenUuid));
  }

  void _invalidate(String specimenUuid) {
    ref.invalidate(parasiteBySpecimenProvider(specimenUuid));
  }
}
