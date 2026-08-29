import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/src/rust/api/dwc.dart' as rust_dwc;

/// Darwin Core's recommended delimiter for multiple values of one term.
const String kDarwinCoreListDelimiter = ' | ';

/// Formats a one-based index using the style selected for an export mapping.
String formatIndexedExportHeader(
  String base,
  int index,
  IndexedHeaderStyle style,
) {
  return switch (style) {
    IndexedHeaderStyle.underscore => '${base}_$index',
    IndexedHeaderStyle.compact => '$base$index',
    IndexedHeaderStyle.brackets => '$base[$index]',
  };
}

bool usesStandardizedExportHeaders(ExportHeaderFormat format) =>
    format == ExportHeaderFormat.darwinCore ||
    format == ExportHeaderFormat.nahpuNamespace;

String? directExportSourceField(String expression) {
  return RegExp(
    r'^\s*\[([^\]]+)\]\s*$',
  ).firstMatch(expression)?.group(1)?.trim();
}

bool mappingRequiresHeaderOverride(
  ExportHeaderFormat format,
  ExportFieldMapping mapping,
) {
  if (!usesStandardizedExportHeaders(format) ||
      (mapping.headerOverride?.trim().isNotEmpty ?? false)) {
    return false;
  }
  if (!mapping.isNested) {
    return directExportSourceField(mapping.expression) == null;
  }
  return mapping.nestedMode == NestedExportMode.concatenate &&
      mapping.nestedFields.length != 1;
}

String formatDarwinCoreList(Iterable<String> values) => values
    .map((value) => value.trim())
    .where((value) => value.isNotEmpty)
    .join(kDarwinCoreListDelimiter);

/// Resolves all generated headers for one export preset.
class DwcSourceMapping {
  const DwcSourceMapping({
    required this.headers,
    this.measurementType,
    this.measurementUnit,
    this.measurementUnitSource,
  });

  final List<String> headers;
  final String? measurementType;
  final String? measurementUnit;
  final String? measurementUnitSource;

  bool get isMeasurement => measurementType != null;
}

class ExportHeaderResolver {
  ExportHeaderResolver._(this.preset, this._dwcMappings, this._customLabels);

  /// Creates a resolver with known mappings for synchronous tests.
  ExportHeaderResolver.forTesting(this.preset, Map<String, String> dwcHeaders)
    : _dwcMappings = Map.unmodifiable({
        for (final entry in dwcHeaders.entries)
          entry.key: DwcSourceMapping(headers: [entry.value]),
      }),
      _customLabels = const {};

  /// Creates a resolver with full mapping descriptors for tabular tests.
  ExportHeaderResolver.forDwcMappingsTesting(
    this.preset,
    Map<String, DwcSourceMapping> dwcMappings,
  ) : _dwcMappings = Map.unmodifiable(dwcMappings),
      _customLabels = const {};

  final ExportPresetModel preset;
  final Map<String, DwcSourceMapping> _dwcMappings;
  final Map<String, String> _customLabels;

  static Future<ExportHeaderResolver> create(
    ExportPresetModel preset, {
    Database? database,
  }) async {
    final definitions = database == null
        ? const <CustomFieldDefinitionData>[]
        : await database.select(database.customFieldDefinition).get();
    final labels = {
      for (final definition in definitions) definition.uuid: definition.name,
    };
    if (preset.headerFormat != ExportHeaderFormat.darwinCore) {
      return ExportHeaderResolver._(preset, const {}, labels);
    }

    final sourceKeys = <String>{};
    for (final mapping in preset.mappings) {
      if (mapping.isNested) {
        for (final field in mapping.nestedFields) {
          sourceKeys.add('${mapping.nestedNamespace}::$field');
        }
      } else {
        final source = directExportSourceField(mapping.expression);
        if (source != null) sourceKeys.add(source);
      }
    }
    if (sourceKeys.isEmpty) {
      return ExportHeaderResolver._(preset, const {}, labels);
    }

    final resolved = await rust_dwc.getDwcHeaders(
      sourceKeys: sourceKeys.toList(),
    );
    final mappings = {
      for (final entry in resolved)
        entry.sourceKey: DwcSourceMapping(
          headers: entry.headers,
          measurementType: entry.measurementType,
          measurementUnit: entry.measurementUnit,
          measurementUnitSource: entry.measurementUnitSource,
        ),
    };
    for (final definition in definitions) {
      final mapping = definition.dwcMapping;
      if (mapping == null) continue;
      final source =
          '${_namespaceForPlacement(definition.placement)}::'
          '${definition.uuid}';
      mappings[source] = mapping.mode == DwcMappingMode.assertion
          ? DwcSourceMapping(
              headers: const [
                'measurementType',
                'measurementValue',
                'measurementUnit',
              ],
              measurementType: definition.name,
            )
          : DwcSourceMapping(headers: [mapping.field]);
    }
    return ExportHeaderResolver._(preset, mappings, labels);
  }

  DwcSourceMapping? dwcMappingForSource(String source) => _dwcMappings[source];

  List<String> headersForSource(String source) {
    final mapping = _dwcMappings[source];
    if (preset.headerFormat != ExportHeaderFormat.darwinCore ||
        mapping == null) {
      return [_headerForSource(source)];
    }
    return mapping.headers;
  }

  String headerFor(ExportFieldMapping mapping) {
    final override = mapping.headerOverride?.trim();
    if (override != null && override.isNotEmpty) return override;
    if (mapping.isNested) {
      if (mapping.nestedMode == NestedExportMode.concatenate &&
          mapping.nestedFields.length == 1) {
        return _headerForSource(
          '${mapping.nestedNamespace}::${mapping.nestedFields.single}',
        );
      }
      return mapping.nestedNamespace!;
    }

    final source = directExportSourceField(mapping.expression);
    if (source == null) {
      final firstSource = RegExp(
        r'\[([^\]\s]+)\]',
      ).firstMatch(mapping.expression)?.group(1);
      if (firstSource != null) return _headerForSource(firstSource);
      return mapping.expression.trim();
    }
    return _headerForSource(source);
  }

  String nestedHeader(ExportFieldMapping mapping, String field, {int? index}) {
    final override = mapping.headerOverride?.trim();
    final source = '${mapping.nestedNamespace}::$field';
    if (usesStandardizedExportHeaders(preset.headerFormat) &&
        (override == null || override.isEmpty)) {
      final header = _headerForSource(source);
      return index == null
          ? header
          : formatIndexedExportHeader(
              header,
              index,
              mapping.indexedHeaderStyle,
            );
    }

    final prefix = override?.isNotEmpty == true
        ? override!
        : mapping.nestedNamespace!;
    final fieldName = preset.headerFormat == ExportHeaderFormat.fieldName
        ? field
        : usesStandardizedExportHeaders(preset.headerFormat)
        ? _headerForSource(source)
        : source;
    return index == null
        ? '${prefix}_$fieldName'
        : '${formatIndexedExportHeader(prefix, index, mapping.indexedHeaderStyle)}_$fieldName';
  }

  String _headerForSource(String source) {
    final customLabel = _customLabel(source);
    return switch (preset.headerFormat) {
      ExportHeaderFormat.tableFieldName => source,
      ExportHeaderFormat.fieldName => customLabel ?? source.split('::').last,
      ExportHeaderFormat.nahpuNamespace => _nahpuNamespace(
        source,
        customLabel: customLabel,
      ),
      ExportHeaderFormat.darwinCore =>
        _dwcMappings[source]?.headers.first ??
            _nahpuNamespace(source, customLabel: customLabel),
    };
  }

  String? _customLabel(String source) {
    if (!source.startsWith('custom')) return null;
    return _customLabels[source.split('::').last];
  }

  String _nahpuNamespace(String source, {String? customLabel}) {
    final parts = source.split('::');
    if (parts.length != 2 || parts.any((part) => part.isEmpty)) {
      return 'nahpu:$source';
    }
    return 'nahpu:${parts.first}.${customLabel ?? parts.last}';
  }
}

String _namespaceForPlacement(FieldUISection placement) => switch (placement) {
  FieldUISection.siteAttribute => 'customSite',
  FieldUISection.environmentalData => 'customEnvironment',
  FieldUISection.specimenAttribute => 'customSpecimen',
  FieldUISection.specimenPart => 'customSpecimenPart',
  FieldUISection.parasite => 'customParasite',
};
