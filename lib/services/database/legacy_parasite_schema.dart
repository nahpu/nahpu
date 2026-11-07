part of 'database.dart';

// The v25 `parasite` entities, spelled out for release steps before v26.
//
// v26 renamed them to `symbiont`, so the generated getters now create the v26
// shape. Steps that ran before v26 create these instead, matching what they
// created when v25 was current, and the v26 step renames them. Copied from the
// DDL Drift generated for v25; do not edit.

const String _v25ParasiteDetectionTable = r'''
CREATE TABLE "parasiteDetection" ("specimenUuid" TEXT NOT NULL, "parasiteExamined" INTEGER, "parasiteDetected" INTEGER, "detectionRemark" TEXT, FOREIGN KEY(specimenUuid)REFERENCES specimen(uuid))
''';

const String _v25ParasiteTable = r'''
CREATE TABLE "parasite" ("id" INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT, "specimenUuid" TEXT, "speciesID" INTEGER, "determinerID" TEXT REFERENCES personnel(uuid), "parasiteID" TEXT, "parasiteUuid" TEXT NOT NULL, "count" INTEGER, "preparationMethod" TEXT, "storage" TEXT, "storageLocation" TEXT, "treatment" TEXT, "anatomicalLocation" TEXT, "lifeStage" TEXT, "category" TEXT, "associationStatus" INTEGER, "detectionMethod" TEXT, "dateCollected" TEXT, "timeCollected" TEXT, "datePreserved" TEXT, "timePreserved" TEXT, "museumPermanent" TEXT, "museumLoan" TEXT, "remark" TEXT, "collectorID" TEXT REFERENCES personnel(uuid), "dateDetermined" TEXT, "determinationMethod" TEXT, FOREIGN KEY(specimenUuid)REFERENCES specimen(uuid), FOREIGN KEY(speciesID)REFERENCES taxonomy(id))
''';

const String _v25ParasiteIndividualTable = r'''
CREATE TABLE "parasiteIndividual" ("parasiteID" INTEGER NOT NULL, "individualID" INTEGER NOT NULL, PRIMARY KEY(parasiteID, individualID), FOREIGN KEY(parasiteID)REFERENCES parasite(id)ON DELETE CASCADE, FOREIGN KEY(individualID)REFERENCES specimenIndividual(id)ON DELETE CASCADE)
''';

const String _v25CustomFieldValueTable = r'''
CREATE TABLE "customFieldValue" ("id" INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT, "fieldDefinitionId" INTEGER NOT NULL, "projectUuid" TEXT, "value" TEXT NOT NULL, "unit" TEXT, "eventId" INTEGER, "siteId" INTEGER, "specimenUuid" TEXT, "specimenPartId" INTEGER, "parasiteId" INTEGER, "isLegacy" INTEGER NOT NULL DEFAULT 0 CHECK (isLegacy IN (0, 1)), FOREIGN KEY(fieldDefinitionId)REFERENCES customFieldDefinition(id)ON DELETE CASCADE, FOREIGN KEY(projectUuid)REFERENCES project(uuid)ON DELETE CASCADE, FOREIGN KEY(eventId)REFERENCES collEvent(id)ON DELETE CASCADE, FOREIGN KEY(siteId)REFERENCES site(id)ON DELETE CASCADE, FOREIGN KEY(specimenUuid)REFERENCES specimen(uuid)ON DELETE CASCADE, FOREIGN KEY(specimenPartId)REFERENCES specimenPart(id)ON DELETE CASCADE, FOREIGN KEY(parasiteId)REFERENCES parasite(id)ON DELETE CASCADE, CHECK((isLegacy = 1 AND eventId IS NULL AND siteId IS NULL AND specimenUuid IS NULL AND specimenPartId IS NULL AND parasiteId IS NULL)OR(isLegacy = 0 AND projectUuid IS NOT NULL AND((eventId IS NOT NULL)+(siteId IS NOT NULL)+(specimenUuid IS NOT NULL)+(specimenPartId IS NOT NULL)+(parasiteId IS NOT NULL))= 1)))
''';

const String _v25CustomFieldValueValidateInsert = r'''
CREATE TRIGGER custom_field_value_validate_insert BEFORE INSERT ON customFieldValue WHEN NEW.isLegacy = 0 BEGIN SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM customFieldDefinition AS d WHERE d.id = NEW.fieldDefinitionId AND d.uiSection = CASE WHEN NEW.eventId IS NOT NULL THEN 'environmentalData' WHEN NEW.siteId IS NOT NULL THEN 'siteAttribute' WHEN NEW.specimenUuid IS NOT NULL THEN 'specimenAttribute' WHEN NEW.specimenPartId IS NOT NULL THEN 'specimenPart' WHEN NEW.parasiteId IS NOT NULL THEN 'parasite' END AND(d.scope = 'global' OR d.projectUuid = NEW.projectUuid)) THEN RAISE (ABORT, 'Custom field definition does not match its value owner') END;SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM customFieldDefinition AS d WHERE d.id = NEW.fieldDefinitionId AND((NEW.eventId IS NOT NULL AND EXISTS (SELECT 1 FROM collEvent AS e WHERE e.id = NEW.eventId AND e.projectUuid = NEW.projectUuid))OR(NEW.siteId IS NOT NULL AND EXISTS (SELECT 1 FROM site AS s WHERE s.id = NEW.siteId AND s.projectUuid = NEW.projectUuid))OR(NEW.specimenUuid IS NOT NULL AND EXISTS (SELECT 1 FROM specimen AS s WHERE s.uuid = NEW.specimenUuid AND s.projectUuid = NEW.projectUuid AND(d.catalogFormat IS NULL OR d.catalogFormat = CASE lower(s.taxonGroup) WHEN 'birds' THEN 'ornithology' WHEN 'herpetofauna' THEN 'herpetology' WHEN 'invertebrates' THEN 'invertebrateZoology' WHEN 'arthropods' THEN 'invertebrateZoology' WHEN 'fishes' THEN 'ichthyology' ELSE 'mammalogy' END)))OR(NEW.specimenPartId IS NOT NULL AND EXISTS (SELECT 1 FROM specimenPart AS p JOIN specimen AS s ON s.uuid = p.specimenUuid WHERE p.id = NEW.specimenPartId AND s.projectUuid = NEW.projectUuid AND(d.catalogFormat IS NULL OR d.catalogFormat = CASE lower(s.taxonGroup) WHEN 'birds' THEN 'ornithology' WHEN 'herpetofauna' THEN 'herpetology' WHEN 'invertebrates' THEN 'invertebrateZoology' WHEN 'arthropods' THEN 'invertebrateZoology' WHEN 'fishes' THEN 'ichthyology' ELSE 'mammalogy' END)))OR(NEW.parasiteId IS NOT NULL AND EXISTS (SELECT 1 FROM parasite AS p JOIN specimen AS s ON s.uuid = p.specimenUuid WHERE p.id = NEW.parasiteId AND s.projectUuid = NEW.projectUuid AND(d.catalogFormat IS NULL OR d.catalogFormat = CASE lower(s.taxonGroup) WHEN 'birds' THEN 'ornithology' WHEN 'herpetofauna' THEN 'herpetology' WHEN 'invertebrates' THEN 'invertebrateZoology' WHEN 'arthropods' THEN 'invertebrateZoology' WHEN 'fishes' THEN 'ichthyology' ELSE 'mammalogy' END))))) THEN RAISE (ABORT, 'Custom field value project or catalog does not match its owner') END;END
''';

const String _v25CustomFieldValueValidateUpdate = r'''
CREATE TRIGGER custom_field_value_validate_update BEFORE UPDATE ON customFieldValue WHEN NEW.isLegacy = 0 BEGIN SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM customFieldDefinition AS d WHERE d.id = NEW.fieldDefinitionId AND d.uiSection = CASE WHEN NEW.eventId IS NOT NULL THEN 'environmentalData' WHEN NEW.siteId IS NOT NULL THEN 'siteAttribute' WHEN NEW.specimenUuid IS NOT NULL THEN 'specimenAttribute' WHEN NEW.specimenPartId IS NOT NULL THEN 'specimenPart' WHEN NEW.parasiteId IS NOT NULL THEN 'parasite' END AND(d.scope = 'global' OR d.projectUuid = NEW.projectUuid)) THEN RAISE (ABORT, 'Custom field definition does not match its value owner') END;SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM customFieldDefinition AS d WHERE d.id = NEW.fieldDefinitionId AND((NEW.eventId IS NOT NULL AND EXISTS (SELECT 1 FROM collEvent AS e WHERE e.id = NEW.eventId AND e.projectUuid = NEW.projectUuid))OR(NEW.siteId IS NOT NULL AND EXISTS (SELECT 1 FROM site AS s WHERE s.id = NEW.siteId AND s.projectUuid = NEW.projectUuid))OR(NEW.specimenUuid IS NOT NULL AND EXISTS (SELECT 1 FROM specimen AS s WHERE s.uuid = NEW.specimenUuid AND s.projectUuid = NEW.projectUuid AND(d.catalogFormat IS NULL OR d.catalogFormat = CASE lower(s.taxonGroup) WHEN 'birds' THEN 'ornithology' WHEN 'herpetofauna' THEN 'herpetology' WHEN 'invertebrates' THEN 'invertebrateZoology' WHEN 'arthropods' THEN 'invertebrateZoology' WHEN 'fishes' THEN 'ichthyology' ELSE 'mammalogy' END)))OR(NEW.specimenPartId IS NOT NULL AND EXISTS (SELECT 1 FROM specimenPart AS p JOIN specimen AS s ON s.uuid = p.specimenUuid WHERE p.id = NEW.specimenPartId AND s.projectUuid = NEW.projectUuid AND(d.catalogFormat IS NULL OR d.catalogFormat = CASE lower(s.taxonGroup) WHEN 'birds' THEN 'ornithology' WHEN 'herpetofauna' THEN 'herpetology' WHEN 'invertebrates' THEN 'invertebrateZoology' WHEN 'arthropods' THEN 'invertebrateZoology' WHEN 'fishes' THEN 'ichthyology' ELSE 'mammalogy' END)))OR(NEW.parasiteId IS NOT NULL AND EXISTS (SELECT 1 FROM parasite AS p JOIN specimen AS s ON s.uuid = p.specimenUuid WHERE p.id = NEW.parasiteId AND s.projectUuid = NEW.projectUuid AND(d.catalogFormat IS NULL OR d.catalogFormat = CASE lower(s.taxonGroup) WHEN 'birds' THEN 'ornithology' WHEN 'herpetofauna' THEN 'herpetology' WHEN 'invertebrates' THEN 'invertebrateZoology' WHEN 'arthropods' THEN 'invertebrateZoology' WHEN 'fishes' THEN 'ichthyology' ELSE 'mammalogy' END))))) THEN RAISE (ABORT, 'Custom field value project or catalog does not match its owner') END;END
''';

const String _v25ParasiteDetectionSpecimenIdx =
    'CREATE UNIQUE INDEX parasite_detection_specimen_idx '
    'ON parasiteDetection (specimenUuid)';

const String _v25ParasiteSpecimenIdx =
    'CREATE INDEX parasite_specimen_idx ON parasite (specimenUuid)';

const String _v25ParasiteUuidIdx =
    'CREATE UNIQUE INDEX parasite_uuid_idx ON parasite (parasiteUuid)';

const String _v25ParasiteIndividualIndividualIdx =
    'CREATE INDEX parasite_individual_individual_idx '
    'ON parasiteIndividual (individualID)';

extension _LegacyParasiteSchema on Database {
  /// Creates the v25 custom-field validation triggers, which join `parasite`.
  Future<void> _createV25CustomFieldValueTriggers() async {
    await customStatement(_v25CustomFieldValueValidateInsert);
    await customStatement(_v25CustomFieldValueValidateUpdate);
  }
}
