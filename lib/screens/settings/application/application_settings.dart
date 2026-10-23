import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/settings/application/data_usage.dart';
import 'package:nahpu/screens/settings/settings_destination.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/localization/app_language.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/regional_format.dart';
import 'package:nahpu/services/providers/localization.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/styles/design_tokens.dart';

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
    final l10n = context.l10n;
    final theme = ref.watch(themeSettingProvider);
    final language = ref.watch(appLanguageSettingProvider);
    final regionalFormat = ref.watch(regionalFormatSettingProvider);
    return CommonSettingSection(
      title: l10n.settingsApplications,
      isDivided: true,
      children: [
        theme.when(
          data: (themeValue) => CommonSettingTile(
            isNavigation: true,
            icon: Icons.color_lens_outlined,
            title: l10n.settingsTheme,
            label: l10n.settingsThemeLabel,
            value: _ThemeOption.of(themeValue).label(l10n),
            isSelected: selected == SettingsDestination.theme,
            onTap: () => onOpen(SettingsDestination.theme),
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, stackTrace) => Text(l10n.commonError),
        ),
        CommonSettingTile(
          isNavigation: true,
          icon: Icons.translate_rounded,
          title: l10n.settingsLanguage,
          titleBadge: const BetaBadge(),
          // The choice sits under the title, not beside it, so long names
          // like "Bahasa Indonesia" never squeeze the title onto two lines.
          label: language?.nativeLabel ?? l10n.settingsLanguageSystem,
          isSelected: selected == SettingsDestination.language,
          onTap: () => onOpen(SettingsDestination.language),
        ),
        CommonSettingTile(
          isNavigation: true,
          icon: Icons.public_rounded,
          title: l10n.settingsRegionalFormat,
          label:
              regionalFormat?.nativeLabel ??
              l10n.settingsRegionalFormatMatchLanguage,
          isSelected: selected == SettingsDestination.regionalFormat,
          onTap: () => onOpen(SettingsDestination.regionalFormat),
        ),
        CommonSettingTile(
          isNavigation: true,
          icon: Icons.handyman_outlined,
          title: l10n.settingsTools,
          label: l10n.settingsToolsLabel,
          value: '${ref.watch(projectToolsProvider).length}',
          isSelected: selected == SettingsDestination.projectTools,
          onTap: () => onOpen(SettingsDestination.projectTools),
        ),
        DataUsage(
          isSelected: selected == SettingsDestination.dataUsage,
          onTap: () => onOpen(SettingsDestination.dataUsage),
        ),
      ],
    );
  }
}

enum _ThemeOption {
  dark(ThemeMode.dark, Icons.brightness_3_rounded),
  light(ThemeMode.light, Icons.wb_sunny_rounded),
  system(ThemeMode.system, null);

  const _ThemeOption(this.mode, this._icon);

  final ThemeMode mode;
  final IconData? _icon;

  IconData get icon => _icon ?? systemIcon;

  String label(AppLocalizations l10n) => switch (this) {
    _ThemeOption.dark => l10n.settingsThemeDark,
    _ThemeOption.light => l10n.settingsThemeLight,
    _ThemeOption.system => l10n.settingsThemeSystem,
  };

  static _ThemeOption of(ThemeMode mode) =>
      values.firstWhere((option) => option.mode == mode);
}

class ThemeSettings extends ConsumerStatefulWidget {
  const ThemeSettings({super.key});

  @override
  ThemeSettingState createState() => ThemeSettingState();
}

class ThemeSettingState extends ConsumerState<ThemeSettings> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Watched here, not passed in, so the check mark follows the change when
    // the page stays open beside the settings list.
    final selectedTheme = ref.watch(themeSettingProvider).asData?.value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTheme)),
      body: CommonSettingList(
        sections: [
          CommonSettingSection(
            title: l10n.settingsTheme,
            isDivided: true,
            children: [
              for (final option in _ThemeOption.values)
                CommonSettingTile(
                  title: option.label(l10n),
                  icon: option.icon,
                  trailing: selectedTheme == option.mode
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    ref
                        .read(themeSettingProvider.notifier)
                        .setTheme(option.mode.name);
                    // Returns from a pushed page; as the first page in the
                    // settings pane there is nothing to pop.
                    Navigator.maybePop(context);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Picks the UI language, which documentation also opens in.
class LanguageSettings extends ConsumerWidget {
  const LanguageSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(appLanguageSettingProvider);
    final deviceLanguage = AppLanguage.resolve(
      ref.watch(deviceLocalesProvider),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsLanguage)),
      body: CommonSettingList(
        sections: [
          _SettingNote(
            key: const ValueKey('language-beta-note'),
            badge: const BetaBadge(),
            text: l10n.settingsLanguageBetaNote,
          ),
          CommonSettingSection(
            title: l10n.settingsLanguage,
            isDivided: true,
            children: [
              CommonSettingTile(
                icon: systemIcon,
                title: l10n.settingsLanguageSystem,
                label: l10n.settingsLanguageSystemLabel(
                  deviceLanguage.nativeLabel,
                ),
                trailing: selected == null ? const Icon(Icons.check) : null,
                onTap: () => _select(context, ref, null),
              ),
              for (final language in AppLanguage.values)
                CommonSettingTile(
                  key: ValueKey('language-${language.code}'),
                  icon: Icons.translate_rounded,
                  title: language.nativeLabel,
                  titleBadge: language.isBeta ? const BetaBadge() : null,
                  trailing: selected == language
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => _select(context, ref, language),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, WidgetRef ref, AppLanguage? language) {
    ref.read(appLanguageSettingProvider.notifier).set(language);
    Navigator.maybePop(context);
  }
}

/// Picks how dates and numbers appear on screen, apart from the language.
class RegionalFormatSettings extends ConsumerWidget {
  const RegionalFormatSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(regionalFormatSettingProvider);
    final language = ref.watch(appLanguageProvider);
    final today = DateTime.now();
    final current = regionalFormatSample(
      ref.watch(formatLocaleProvider),
      today,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsRegionalFormat)),
      body: CommonSettingList(
        sections: [
          _SettingNote(
            key: const ValueKey('regional-format-note'),
            text:
                '${l10n.settingsRegionalFormatNote}\n'
                '${l10n.settingsRegionalFormatPreview(current.date, current.number)}',
          ),
          CommonSettingSection(
            title: l10n.settingsRegionalFormat,
            isDivided: true,
            children: [
              CommonSettingTile(
                icon: Icons.translate_rounded,
                title: l10n.settingsRegionalFormatMatchLanguage,
                label: _sampleLabel(
                  regionalFormatSample(language.formatLocale, today),
                ),
                trailing: selected == null ? const Icon(Icons.check) : null,
                onTap: () => _select(context, ref, null),
              ),
              for (final format in RegionalFormat.all)
                CommonSettingTile(
                  key: ValueKey('regional-format-${format.tag}'),
                  icon: Icons.public_rounded,
                  title: format.nativeLabel,
                  label: _sampleLabel(regionalFormatSample(format.tag, today)),
                  trailing: selected == format ? const Icon(Icons.check) : null,
                  onTap: () => _select(context, ref, format),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _sampleLabel(({String date, String number}) sample) {
    return '${sample.date} · ${sample.number}';
  }

  void _select(BuildContext context, WidgetRef ref, RegionalFormat? format) {
    ref.read(regionalFormatSettingProvider.notifier).set(format);
    Navigator.maybePop(context);
  }
}

/// A short explanation above a settings list.
class _SettingNote extends StatelessWidget {
  const _SettingNote({super.key, required this.text, this.badge});

  final String text;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: NahpuSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge case final badge?) ...[
            badge,
            const SizedBox(width: NahpuSpacing.md),
          ],
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
