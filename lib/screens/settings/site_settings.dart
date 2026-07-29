import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/map_settings.dart';
import 'package:nahpu/screens/settings/controlled_vocabulary.dart';

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
        child: CommonSettingList(
          sections: const [
            SiteMapSettings(),
            ControlledVocabularySetting(
              title: 'Site types',
              typePrefKey: siteTypePrefKey,
              fmtPrefKey: siteTypeFmtPrefKey,
              typeName: 'site type',
            ),
            ControlledVocabularySetting(
              title: 'Habitat types',
              typePrefKey: habitatTypePrefKey,
              fmtPrefKey: habitatTypeFmtPrefKey,
              typeName: 'habitat type',
            ),
          ],
        ),
      ),
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
