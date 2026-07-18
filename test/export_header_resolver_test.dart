import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/export/export_header_resolver.dart';
import 'package:nahpu/services/export/preset_record_exporter.dart';
import 'package:nahpu/services/types/export.dart';

void main() {
  const basePreset = ExportPresetModel(
    recordType: RecordType.specimenRecord,
    specimenRecordType: SpecimenRecordType.allTaxa,
    headerFormat: ExportHeaderFormat.darwinCore,
    mappings: [],
  );

  test('resolves Darwin Core headers and NAHPU namespace fallbacks', () {
    final resolver = ExportHeaderResolver.forTesting(basePreset, {
      'specimen::uuid': 'dwc:occurrenceID',
    });

    expect(
      resolver
          .headerFor(const ExportFieldMapping(expression: '[specimen::uuid]')),
      'dwc:occurrenceID',
    );
    expect(
      resolver.headerFor(
        const ExportFieldMapping(expression: '[taxonomy::citesStatus]'),
      ),
      'nahpu:taxonomy.citesStatus',
    );
  });

  test('preserves repeated MeasurementOrFact headers in source order', () {
    final resolver = ExportHeaderResolver.forDwcMappingsTesting(basePreset, {
      'mammalMeasurement::tailLength': const DwcSourceMapping(
        headers: [
          'dwc:measurementType',
          'dwc:measurementValue',
          'dwc:measurementUnit',
        ],
        measurementType: 'tail length',
        measurementUnit: 'mm',
      ),
    });

    expect(
      resolver.headersForSource('mammalMeasurement::tailLength'),
      [
        'dwc:measurementType',
        'dwc:measurementValue',
        'dwc:measurementUnit',
      ],
    );
    expect(
      resolver
          .dwcMappingForSource('mammalMeasurement::tailLength')
          ?.isMeasurement,
      isTrue,
    );
  });

  test('generates NAHPU namespace and indexed nested headers', () {
    const preset = ExportPresetModel(
      recordType: RecordType.site,
      specimenRecordType: SpecimenRecordType.allTaxa,
      headerFormat: ExportHeaderFormat.nahpuNamespace,
      mappings: [],
    );
    final resolver = ExportHeaderResolver.forTesting(preset, const {});
    const mapping = ExportFieldMapping(
      expression: '',
      nestedNamespace: 'coordinate',
      nestedFields: ['decimalLatitude'],
      nestedMode: NestedExportMode.spreadColumns,
    );

    expect(
      resolver.nestedHeader(mapping, 'decimalLatitude', index: 2),
      'nahpu:coordinate.decimalLatitude_2',
    );
  });

  test('requires explicit headers for standardized composite mappings', () {
    const mapping = ExportFieldMapping(
      expression: '[specimen::uuid]-[specimen::fieldNumber]',
    );
    expect(
      mappingRequiresHeaderOverride(ExportHeaderFormat.darwinCore, mapping),
      isTrue,
    );
    expect(
      mappingRequiresHeaderOverride(ExportHeaderFormat.nahpuNamespace, mapping),
      isTrue,
    );
    expect(
      mappingRequiresHeaderOverride(ExportHeaderFormat.fieldName, mapping),
      isFalse,
    );
  });

  test('uses the Darwin Core list delimiter only for non-empty values', () {
    expect(formatDarwinCoreList(['A', '', ' B ']), 'A | B');
    expect(formatDarwinCoreList(const []), isEmpty);
  });

  test('validates standardized composite mappings before export', () {
    const preset = ExportPresetModel(
      recordType: RecordType.specimenRecord,
      specimenRecordType: SpecimenRecordType.allTaxa,
      headerFormat: ExportHeaderFormat.darwinCore,
      mappings: [
        ExportFieldMapping(
            expression: '[specimen::uuid]-[specimen::fieldNumber]'),
      ],
    );

    expect(
      validateExportPreset(preset),
      contains(
          'Standardized header modes require a custom header for composite mappings.'),
    );
  });
}
