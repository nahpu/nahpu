import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/application/map_settings.dart';
import 'package:nahpu/screens/settings/records/controlled_vocabulary.dart';
import 'package:nahpu/services/types/sites.dart';
import 'package:nahpu/services/types/specimens.dart';

class SiteSelection extends ConsumerStatefulWidget {
  const SiteSelection({super.key});

  @override
  SiteSelectionState createState() => SiteSelectionState();
}

class SiteSelectionState extends ConsumerState<SiteSelection> {
  @override
  Widget build(BuildContext context) {
    final catalogFmt = ref.watch(catalogFmtNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Site settings')),
      body: SafeArea(
        child: CommonSettingList(
          sections: [
            const SiteMapSettings(),
            const SiteGeographyFieldSettings(),
            const ControlledVocabularySetting(
              title: 'Site types',
              typePrefKey: siteTypePrefKey,
              fmtPrefKey: siteTypeFmtPrefKey,
              typeName: 'site type',
            ),
            const ControlledVocabularySetting(
              title: 'Habitat types',
              typePrefKey: habitatTypePrefKey,
              fmtPrefKey: habitatTypeFmtPrefKey,
              typeName: 'habitat type',
            ),
            ...catalogFmt.when(
              data: (format) => format == CatalogFmt.paleontology
                  ? [
                      const ControlledVocabularySetting(
                        title: 'Standard Preservation types',
                        typePrefKey: standardPreservationTypePrefKey,
                        fmtPrefKey: standardPreservationTypeFmtPrefKey,
                        typeName: 'standard preservation type',
                      ),
                    ]
                  : const <Widget>[],
              loading: () => const <Widget>[],
              error: (_, _) => const <Widget>[],
            ),
            const ControlledVocabularySetting(
              title: 'Datums',
              typePrefKey: datumPrefKey,
              fmtPrefKey: datumFmtPrefKey,
              typeName: 'datum',
              pluralName: 'datums',
            ),
          ],
        ),
      ),
    );
  }
}

class SiteGeographyFieldSettings extends ConsumerWidget {
  const SiteGeographyFieldSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonSettingSection(
      title: 'Geography fields',
      isDivided: true,
      children: [
        ref
            .watch(userDefinedFieldProvider(siteGeographyFieldsPrefKey))
            .when(
              data: (selected) => Column(
                children: [
                  for (final field in siteGeographyFields)
                    CheckboxListTile(
                      value: selected.contains(field),
                      title: Text(siteGeographyFieldLabels[field]!),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (visible) async {
                        final next = selected.toSet();
                        if (visible == true) {
                          next.add(field);
                        } else {
                          next.remove(field);
                        }
                        await ref
                            .read(userConfigSettingsServiceProvider)
                            .replaceOptions(
                              siteGeographyFieldsPrefKey,
                              siteGeographyFields
                                  .where(next.contains)
                                  .toList(growable: false),
                            );
                        ref.invalidate(
                          userDefinedFieldProvider(siteGeographyFieldsPrefKey),
                        );
                      },
                    ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (error, _) =>
                  Text('Unable to load geography fields: $error'),
            ),
      ],
    );
  }
}

class SiteMapSettings extends ConsumerWidget {
  const SiteMapSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonSettingSection(
      title: 'Maps',
      isDivided: true,
      children: [
        CommonSettingTile(
          title: 'Map layers',
          label: 'Choose a base layer or import and manage custom layers',
          icon: Icons.layers_outlined,
          isNavigation: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapLayerSettings()),
          ),
        ),
      ],
    );
  }
}
