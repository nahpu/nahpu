import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/application/map_settings.dart';
import 'package:nahpu/screens/settings/records/controlled_vocabulary.dart';
import 'package:nahpu/services/types/sites.dart';
import 'package:nahpu/services/localization/l10n.dart';

class SiteSelection extends StatefulWidget {
  const SiteSelection({super.key});

  @override
  State<SiteSelection> createState() => _SiteSelectionState();
}

class _SiteSelectionState extends State<SiteSelection> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recordsSiteSettings)),
      body: SafeArea(
        child: CommonSettingList(
          sections: [
            const SiteMapSettings(),
            const SiteGeographyFieldSettings(),
            ControlledVocabularySetting(
              title: l10n.recordsSiteTypes,
              typePrefKey: siteTypePrefKey,
              fmtPrefKey: siteTypeFmtPrefKey,
              typeName: l10n.formsVocabSiteType,
              pluralName: l10n.formsVocabSiteTypePlural,
            ),
            ControlledVocabularySetting(
              title: l10n.recordsSiteHabitatTypes,
              typePrefKey: habitatTypePrefKey,
              fmtPrefKey: habitatTypeFmtPrefKey,
              typeName: l10n.formsVocabHabitatType,
              pluralName: l10n.formsVocabHabitatTypePlural,
            ),
            ControlledVocabularySetting(
              title: l10n.recordsSiteDatums,
              typePrefKey: datumPrefKey,
              fmtPrefKey: datumFmtPrefKey,
              typeName: l10n.formsVocabDatum,
              pluralName: l10n.formsVocabDatumPlural,
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
      title: context.l10n.recordsSiteGeographyFields,
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
                      title: Text(
                        siteGeographyFieldLocalizedLabel(context.l10n, field),
                      ),
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
              error: (error, _) => Text(
                context.l10n.recordsSiteGeographyFieldsLoadError(
                  error.toString(),
                ),
              ),
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
      title: context.l10n.recordsSiteMaps,
      isDivided: true,
      children: [
        CommonSettingTile(
          title: context.l10n.recordsSiteMapLayers,
          label: context.l10n.recordsSiteMapLayersLabel,
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
