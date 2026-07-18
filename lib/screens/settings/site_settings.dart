import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/map_settings.dart';
import 'package:nahpu/services/types/map_layers.dart';

class SiteSelection extends StatefulWidget {
  const SiteSelection({super.key});

  @override
  State<SiteSelection> createState() => _SiteSelectionState();
}

class _SiteSelectionState extends State<SiteSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Site Settings')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            bool isMobile = constraints.maxWidth < 600;
            return CommonSettingList(
              sections: [
                const SiteMapSettings(),
                SiteFormats(isMobile: isMobile),
                UserDefinedSettingField(
                  typePrefKey: siteTypePrefKey,
                  fmtPrefKey: siteTypeFmtPrefKey,
                  typeName: 'Site Type',
                ),
                UserDefinedSettingField(
                  typePrefKey: habitatTypePrefKey,
                  fmtPrefKey: habitatTypeFmtPrefKey,
                  typeName: 'Habitat Type',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SiteMapSettings extends ConsumerWidget {
  const SiteMapSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(spatialBasemapStyleProvider);
    return CommonSettingSection(
      title: 'Maps',
      isDivided: true,
      children: [
        CommonSettingTile(
          title: 'Basemap style',
          label: 'Choose the map appearance used by spatial statistics',
          icon: Icons.map_outlined,
          value: style.value?.label,
          isNavigation: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BasemapStyleSettings(),
            ),
          ),
        ),
        CommonSettingTile(
          title: 'Custom map layers',
          label: 'Import and manage local vector, raster, and elevation data',
          icon: Icons.layers_outlined,
          isNavigation: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserMapLayerSettings(),
            ),
          ),
        ),
      ],
    );
  }
}

class SiteFormats extends ConsumerWidget {
  const SiteFormats({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonSettingSection(
      title: 'Formats',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
          child: AdaptiveLayout(
            useHorizontalLayout: !isMobile,
            children: [
              TextCaseFmtDropDown(
                ref: ref,
                label: 'Site types',
                textCasePrefString: siteTypeFmtPrefKey,
              ),
              TextCaseFmtDropDown(
                ref: ref,
                label: 'Habitat types',
                textCasePrefString: habitatTypeFmtPrefKey,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
