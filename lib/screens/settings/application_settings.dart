import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nahpu/screens/settings/app_settings_import.dart';

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
        CommonSettingTile(
          isNavigation: true,
          icon: MdiIcons.cogSyncOutline,
          title: 'Replace app settings',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AppSettingsImport(),
            ),
          ),
        ),
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
    systemIcon
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
      ),
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
                trailing:
                    widget.isSelected == e ? const Icon(Icons.check) : null,
                onTap: () {
                  ref.read(themeSettingProvider.notifier).setTheme(e);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

class DataUsage extends ConsumerWidget {
  const DataUsage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CommonSettingTile(
                icon: Icons.data_usage_outlined,
                isNavigation: true,
                title: 'Data usage',
                label: 'Total data usage of the application',
                value: snapshot.data,
                onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DataUsageSettings(),
                      ),
                    ));
          } else if (snapshot.hasError) {
            return const Text('Error');
          } else {
            return const CommonProgressIndicator();
          }
        },
        future: _calculateDataUsage(ref));
  }

  Future<String> _calculateDataUsage(WidgetRef ref) async {
    return await DataUsageServices(ref: ref).appDataUsage;
  }
}

class DataUsageSettings extends ConsumerStatefulWidget {
  const DataUsageSettings({super.key});

  @override
  DataUsageSettingsState createState() => DataUsageSettingsState();
}

class DataUsageSettingsState extends ConsumerState<DataUsageSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data usage'),
      ),
      body: CommonSettingList(
        sections: [
          CommonSettingSection(
            isDivided: true,
            children: [
              FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CommonSettingTile(
                        icon: Icons.data_usage_outlined,
                        title: 'Total usage',
                        value: snapshot.data,
                        onTap: null,
                      );
                    } else if (snapshot.hasError) {
                      return const Text('Error');
                    } else {
                      return const CommonProgressIndicator();
                    }
                  },
                  future: _calculateDataUsage(ref)),
              FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CommonSettingTile(
                        icon: Icons.file_copy_outlined,
                        title: 'Files',
                        label: 'Include images and other files',
                        value: snapshot.data,
                        onTap: null,
                      );
                    } else if (snapshot.hasError) {
                      return const Text('Error');
                    } else {
                      return const CommonProgressIndicator();
                    }
                  },
                  future: _calculateFileCount(ref)),
              FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CommonSettingTile(
                        icon: Icons.photo_library_outlined,
                        title: 'Images',
                        label: 'Only images',
                        value: snapshot.data,
                        onTap: null,
                      );
                    } else if (snapshot.hasError) {
                      return const Text('Error');
                    } else {
                      return const CommonProgressIndicator();
                    }
                  },
                  future: _calculateImageCount(ref)),
            ],
          ),
        ],
      ),
    );
  }

  Future<String> _calculateDataUsage(WidgetRef ref) async {
    return await DataUsageServices(ref: ref).appDataUsage;
  }

  Future<String> _calculateFileCount(WidgetRef ref) async {
    int fileCount = await DataUsageServices(ref: ref).fileCount;
    if (fileCount <= 1) {
      return '$fileCount file';
    } else {
      return '$fileCount files';
    }
  }

  Future<String> _calculateImageCount(WidgetRef ref) async {
    int imageCount = await DataUsageServices(ref: ref).imageCount;
    if (imageCount <= 1) {
      return '$imageCount image';
    } else {
      return '$imageCount images';
    }
  }
}
