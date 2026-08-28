import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/settings/transfer/user_config_transfer_widgets.dart';
import 'package:nahpu/src/rust/api/config.dart' as rust_config;

void main() {
  testWidgets('preview lists vocabulary items and summarizes presets', (
    tester,
  ) async {
    const preview = rust_config.UserConfigTransferPreview(
      schemaVersion: 2,
      includedSections: rust_config.UserConfigSection.values,
      userConfigs: [
        rust_config.UserConfigValuePreview(
          key: 'siteTypes',
          label: 'Site types',
          values: ['Forest', 'Stream'],
          isControlledVocabulary: true,
        ),
      ],
      recordExportPresets: [
        rust_config.RecordExportPresetPreview(
          name: 'Specimen table',
          recordType: 'Specimen records',
          mappingCount: 8,
          isCompatible: true,
        ),
      ],
      templatePresets: [
        rust_config.TemplatePresetPreview(
          name: 'Specimen label',
          recordType: 'Specimen records',
          description: 'A label template',
        ),
      ],
      documentLayouts: [
        rust_config.DocumentLayoutPreview(
          name: 'Letter sheet',
          layoutType: 'WholePage',
          pageSizeKey: 'Letter',
          blockCount: 2,
        ),
      ],
      templateTablePreviewColumns: [
        'specimen::fieldNumber',
        'taxonomy::species',
      ],
      customFields: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 700,
            child: UserConfigPreviewPane(
              title: 'Will export',
              preview: preview,
              selectedSections: Set.of(userConfigSectionOrder),
              isLoading: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Forest'), findsOneWidget);
    expect(find.text('Stream'), findsOneWidget);
    expect(find.text('Specimen table'), findsOneWidget);
    expect(find.text('8 mappings · Specimen records'), findsOneWidget);
    expect(find.text('Specimen label'), findsOneWidget);
    expect(find.text('Letter sheet'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('specimen::fieldNumber'), findsOneWidget);
  });
}
