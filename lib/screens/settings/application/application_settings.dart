import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/settings/application/data_usage.dart';
import 'package:nahpu/screens/settings/settings_destination.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/providers/settings.dart';

class ApplicationSettings extends ConsumerWidget {
  const ApplicationSettings({
    super.key,
    required this.selected,
    required this.onOpen,
  });

  final SettingsDestination? selected;
  final ValueChanged<SettingsDestination> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeSettingProvider);
    return CommonSettingSection(
      title: 'Applications',
      isDivided: true,
      children: [
        theme.when(
          data: (themeValue) => CommonSettingTile(
            isNavigation: true,
            icon: Icons.color_lens_outlined,
            title: 'Theme',
            label: 'Set light or dark appearance',
            value: themeValue.name.toSentenceCase(),
            isSelected: selected == SettingsDestination.theme,
            onTap: () => onOpen(SettingsDestination.theme),
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, stackTrace) => const Text('Error'),
        ),
        DataUsage(
          isSelected: selected == SettingsDestination.dataUsage,
          onTap: () => onOpen(SettingsDestination.dataUsage),
        ),
      ],
    );
  }
}

class ThemeSettings extends ConsumerStatefulWidget {
  const ThemeSettings({super.key});

  @override
  ThemeSettingState createState() => ThemeSettingState();
}

class ThemeSettingState extends ConsumerState<ThemeSettings> {
  final List<String> themes = ['Dark', 'Light', 'System'];
  final List<IconData> icons = [
    Icons.brightness_3_rounded,
    Icons.wb_sunny_rounded,
    systemIcon,
  ];
  @override
  Widget build(BuildContext context) {
    // Watched here, not passed in, so the check mark follows the change when
    // the page stays open beside the settings list.
    final selectedTheme = ref
        .watch(themeSettingProvider)
        .asData
        ?.value
        .name
        .toSentenceCase();
    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: CommonSettingList(
        sections: [
          CommonSettingSection(
            title: 'Theme',
            isDivided: true,
            children: themes.map((e) {
              final index = themes.indexOf(e);
              return CommonSettingTile(
                title: e,
                icon: icons[index],
                trailing: selectedTheme == e ? const Icon(Icons.check) : null,
                onTap: () {
                  ref.read(themeSettingProvider.notifier).setTheme(e);
                  // Returns from a pushed page; as the first page in the
                  // settings pane there is nothing to pop.
                  Navigator.maybePop(context);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
