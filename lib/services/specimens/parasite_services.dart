import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/parasite_queries.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/projects/project_services.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

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

  Future<int> createParasite(
    String specimenUuid,
    ParasiteCompanion form,
  ) async {
    final entry = form.parasiteUuid.present
        ? form
        : form.copyWith(parasiteUuid: db.Value(uuid));
    final id = await ParasiteQuery(dbAccess).createParasite(entry);
    _invalidate(specimenUuid);
    return id;
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

class ParasiteIdServices {
  const ParasiteIdServices();

  Future<String> getNewNumber() async {
    final prefix = await getPrefix();
    final number = await getNumber();
    await setNumber((number + 1).toString());
    return '$prefix$number';
  }

  Future<String> getPrefix() async {
    return await rust_config.getUserConfigString(
          key: parasiteIdPrefixPrefKey,
        ) ??
        '';
  }

  Future<int> getNumber() async {
    final value = await rust_config.getUserConfigString(
      key: parasiteIdNumberPrefKey,
    );
    return int.tryParse(value ?? '') ?? 0;
  }

  Future<String> getNumberString() async {
    final value = await rust_config.getUserConfigString(
      key: parasiteIdNumberPrefKey,
    );
    return value ?? '';
  }

  Future<void> setPrefix(String prefix) {
    return rust_config.setUserConfigString(
      key: parasiteIdPrefixPrefKey,
      value: prefix.trim(),
    );
  }

  Future<void> setNumber(String number) {
    final parsed = int.tryParse(number.trim()) ?? 0;
    return rust_config.setUserConfigString(
      key: parasiteIdNumberPrefKey,
      value: parsed.toString(),
    );
  }
}
