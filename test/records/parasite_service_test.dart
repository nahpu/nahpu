import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/parasite_queries.dart';
import 'package:nahpu/services/export/document_writer.dart';
import 'package:nahpu/services/export/dynamic_record_exporter.dart';
import 'package:nahpu/services/export/parasite_records.dart';
import 'package:nahpu/services/specimens/parasite_services.dart';
import 'package:nahpu/services/providers/database.dart';

void main() {
  testWidgets(
    'parasites persist identifiers, UUIDs, detection, and export rows',
    (tester) async {
      final database = Database.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
      addTearDown(database.close);
      WidgetRef? widgetRef;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                widgetRef = ref;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      await database
          .into(database.project)
          .insert(
            const ProjectCompanion(
              uuid: Value('project'),
              name: Value('Parasite project'),
            ),
          );
      await database
          .into(database.personnel)
          .insert(
            const PersonnelCompanion(
              uuid: Value('identifier'),
              name: Value('A. Identifier'),
            ),
          );
      final taxonId = await database
          .into(database.taxonomy)
          .insert(
            const TaxonomyCompanion(
              taxonRank: Value('species'),
              kingdom: Value('Animalia'),
              phylum: Value('Arthropoda'),
              taxonClass: Value('Insecta'),
              genus: Value('Pulex'),
              specificEpithet: Value('irritans'),
            ),
          );
      await database
          .into(database.specimen)
          .insert(
            const SpecimenCompanion(
              uuid: Value('specimen'),
              projectUuid: Value('project'),
              taxonGroup: Value('Mammals'),
            ),
          );
      await database
          .into(database.specimenPart)
          .insert(
            const SpecimenPartCompanion(
              specimenUuid: Value('specimen'),
              tissueID: Value('T-1'),
              storage: Value('Ethanol'),
              storageLocation: Value('Freezer 2'),
            ),
          );
      await database
          .into(database.specimenPart)
          .insert(
            const SpecimenPartCompanion(
              specimenUuid: Value('specimen'),
              tissueID: Value('T-2'),
            ),
          );

      final service = ParasiteServices(ref: widgetRef!);
      await service.updateDetection(
        'specimen',
        const ParasiteDetectionCompanion(
          parasiteExamined: Value(1),
          parasiteDetected: Value(1),
          detectionRemark: Value('Two fleas collected'),
        ),
      );
      for (final parasiteId in ['P-1', 'P-2']) {
        await service.createParasite(
          'specimen',
          ParasiteCompanion(
            specimenUuid: const Value('specimen'),
            speciesID: Value(taxonId),
            determinerID: const Value('identifier'),
            parasiteID: Value(parasiteId),
            parasiteUuid: parasiteId == 'P-1'
                ? const Value('uuid-P-1')
                : const Value.absent(),
            count: const Value(1),
            category: const Value('Ectoparasite'),
            associationStatus: const Value(1),
            storage: const Value('Slide'),
            storageLocation: const Value('Cabinet A'),
          ),
        );
      }

      final detection = await database
          .select(database.parasiteDetection)
          .getSingle();
      expect(detection.detectionRemark, 'Two fleas collected');
      final parasites = await database.select(database.parasite).get();
      expect(parasites, hasLength(2));
      expect(
        parasites.map((row) => row.determinerID),
        everyElement('identifier'),
      );
      expect(parasites.first.parasiteUuid, 'uuid-P-1');
      expect(
        parasites.last.parasiteUuid,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );

      final specimen = await database.select(database.specimen).getSingle();
      final concatenated = await DynamicRecordExporter(
        ref: widgetRef!,
        expansion: MultiEntryExpansion.concatenate,
      ).getRecord(specimen);
      expect(concatenated, hasLength(1));
      expect(concatenated.single['parasite::parasiteID'], 'P-1|P-2');
      expect(
        concatenated.single['parasite::determinerID'],
        'A. Identifier|A. Identifier',
      );
      expect(concatenated.single['parasiteDetection::parasiteDetected'], 'Yes');
      expect(
        concatenated.single['parasite::associationStatus'],
        'Confirmed|Confirmed',
      );
      expect(
        concatenated.single['parasite::storageLocation'],
        'Cabinet A|Cabinet A',
      );
      expect(concatenated.single['specimenPart::storage'], 'Ethanol|');
      expect(
        concatenated.single['specimenPart::storageLocation'],
        'Freezer 2|',
      );

      final expanded = await DynamicRecordExporter(
        ref: widgetRef!,
        expansion: MultiEntryExpansion.parasites,
      ).getRecord(specimen);
      expect(expanded, hasLength(2));
      expect(expanded.map((row) => row['parasite::parasiteID']), [
        'P-1',
        'P-2',
      ]);
      expect(
        expanded.map((row) => row['specimenPart::tissueID']),
        everyElement('T-1|T-2'),
      );

      // A parasite record is one row, with its host specimen's values.
      final records = await ParasiteQuery(
        database,
      ).getParasitesForProject('project');
      expect(records.map((record) => record.parasite.parasiteID), [
        'P-1',
        'P-2',
      ]);
      final fields = await documentFieldValuesForParasite(
        database,
        records.last,
        widgetRef!,
      );
      expect(fields['parasite::parasiteID'], 'P-2');
      expect(fields['specimenPart::tissueID'], 'T-1|T-2');

      final row = await ParasiteWriter(
        ref: widgetRef!,
      ).getRow(records.first.parasite, records.first.specimen);
      expect(row, hasLength(ParasiteWriter.header.length));
      String cell(String key) => row[ParasiteWriter.header.indexOf(key)];
      expect(cell('parasite::parasiteID'), 'P-1');
      expect(cell('parasite::scientificName'), 'Pulex irritans');
      expect(cell('parasite::determinerID'), 'A. Identifier');
      expect(cell('parasite::associationStatus'), 'Confirmed');
    },
  );
}
