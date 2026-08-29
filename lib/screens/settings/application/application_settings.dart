import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/settings/application/data_usage.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/providers/settings.dart';

class ApplicationSettings extends ConsumerWidget {
  const ApplicationSettings({super.key});

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
            value: themeValue.name.toSentenceCase(),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ThemeSettings(isSelected: themeValue.name.toSentenceCase()),
              ),
            ),
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, stackTrace) => const Text('Error'),
        ),
        const DataUsage(),
      ],
    );
  }
}

class ThemeSettings extends ConsumerStatefulWidget {
  const ThemeSettings({super.key, required this.isSelected});
  final String isSelected;
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
                trailing: widget.isSelected == e
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  ref.read(themeSettingProvider.notifier).setTheme(e);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
