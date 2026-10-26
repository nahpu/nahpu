import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/localization/app_language.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/templates/print_specimen_table_columns.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/events.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:nahpu/services/types/map_layers.dart';
import 'package:nahpu/services/types/project_tools.dart';
import 'package:nahpu/services/types/sites.dart';
import 'package:nahpu/services/types/specimens.dart';

void main() {
  final en = localizationsFor(AppLanguage.english);

  test('English display labels match the English data labels', () {
    for (final fmt in CatalogFmt.values) {
      expect(fmt.localizedLabel(en), catalogFmtDisplayName(fmt));
    }
    for (final tool in ProjectTool.values) {
      expect(tool.localizedLabel(en), isNotEmpty);
      expect(tool.localizedDescription(en), isNotEmpty);
    }
    for (final category in ProjectToolCategory.values) {
      expect(category.localizedLabel(en), category.label);
    }
    for (final style in SpatialBasemapStyle.values) {
      expect(style.localizedLabel(en), style.label);
      expect(style.localizedDescription(en), style.description);
    }
    for (final kind in UserMapLayerKind.values) {
      expect(kind.localizedLabel(en), kind.label);
    }
    for (final section in FieldUISection.values) {
      expect(section.localizedLabel(en), section.label);
    }
    for (final field in siteGeographyFields) {
      expect(
        siteGeographyFieldLocalizedLabel(en, field),
        siteGeographyFieldLabels[field],
      );
    }
    for (final field in environmentalDataFieldLabels.keys) {
      expect(
        environmentalDataFieldLocalizedLabelWithUnit(en, field),
        environmentalDataFieldLabelWithUnit(field),
      );
    }
    for (final fmt in TextCaseFmt.values) {
      expect(fmt.localizedLabel(en), isNotEmpty);
    }
  });

  test('record type labels are readable, not raw keys', () {
    expect(RecordType.specimenRecord.localizedLabel(en), 'Specimen');
    expect(recordTypeToString(RecordType.specimenRecord), 'specimen');
    expect(RecordType.parasites.localizedLabel(en), 'Parasites');
    expect(
      parseRecordType(recordTypeToString(RecordType.parasites)),
      RecordType.parasites,
    );
    expect(SpecimenRecordType.allTaxa.localizedLabel(en), 'All taxa');
  });

  test('environmental units stay untranslated', () {
    final es = localizationsFor(AppLanguage.spanish);
    expect(
      environmentalDataFieldLocalizedLabelWithUnit(es, 'conductivity'),
      'Conductividad (µS/cm)',
    );
    expect(environmentalDataFieldLocalizedLabelWithUnit(es, 'pH'), 'pH');
  });

  test('table titles fall back for unknown tables', () {
    expect(databaseTableLocalizedTitle(en, 'collEvent'), 'Coll Event');
    expect(
      databaseTableLocalizedTitle(en, 'someNewTable'),
      databaseTableDisplayTitle('someNewTable'),
    );
  });
}
