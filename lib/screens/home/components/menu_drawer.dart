import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/exports/export_db.dart';
import 'package:nahpu/screens/exports/export_settings.dart';
import 'package:nahpu/screens/home/components/cookbook.dart';
import 'package:nahpu/screens/projects/new_project.dart';
import 'package:nahpu/screens/projects/project_transfer/import_project.dart';
import 'package:nahpu/screens/settings/settings.dart';
import 'package:nahpu/screens/settings/onboarding/setup_wizard.dart';
import 'package:nahpu/screens/settings/transfer/app_settings_import.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/common/legal_links.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/tropical_mountains.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/database/database.dart' show kSchemaVersion;
import 'package:nahpu/services/providers/app_info.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:url_launcher/url_launcher.dart';

const String nahpuWebsite = 'https://nahpu.app/';
const String versionName = 'Tropical Mountains';
const String appName = 'NAHPU';

class HomeMenuDrawer extends StatelessWidget {
  const HomeMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Color.lerp(
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.surface,
              0.2,
            ),
          ),
          child: SvgPicture.asset(
            'assets/logo/nahpu-fg.svg',
            fit: BoxFit.contain,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.create_outlined),
          title: const Text('Create project'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateProjectForm(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('Import project'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ImportProjectScreen.newProject(),
              ),
            );
          },
        ),
        const CommonLineDivider(),
        ListTile(
          leading: const Icon(Icons.storage_outlined),
          title: const Text('Backup database'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExportDbForm()),
            );
          },
        ),
        const CommonLineDivider(),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Settings'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppSettings()),
            );
          },
        ),

        ListTile(
          leading: Icon(Icons.adaptive.share_outlined),
          title: const Text('Export user configs'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExportSettingsForm(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('Import user configs'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AppSettingsImport(),
              ),
            );
          },
        ),
        const CommonLineDivider(),
        const SetupWizardTile(),
        const CommonLineDivider(),
        const CookbookTile(),
        const CommonLineDivider(),
        ListTile(
          leading: const Icon(Icons.info_outlined),
          title: const Text('About'),
          onTap: () {
            showAdaptiveSheetDialog<void>(
              context: context,
              maxWidth: NahpuContentWidth.dialog,
              builder: (context, isSheet) =>
                  AppAbout(showCloseButton: !isSheet),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.web_outlined),
          title: const Text('NAHPU website'),
          onTap: () {
            _launchHelpUrl();
          },
        ),
        const PrivacyPolicyTile(),
        const TermsTile(),
        const SizedBox(height: 32),
        const DocQrCode(),
      ],
    );
  }

  Future<void> _launchHelpUrl() async {
    final Uri url = Uri.parse(nahpuWebsite);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}

/// About NAHPU, shown as a bottom sheet on compact screens and as a dialog on
/// wider ones, over the Tropical Mountains skyline the release is named after.
class AppAbout extends ConsumerWidget {
  const AppAbout({super.key, this.showCloseButton = true});

  /// A bottom sheet is dismissed with its drag handle instead.
  final bool showCloseButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final appVersion = ref
        .watch(packageInfoProvider)
        .when(
          data: (info) => 'v${info.version} (build ${info.buildNumber})',
          loading: () => null,
          error: (error, stackTrace) => 'Unavailable',
        );
    final schema = ref.watch(databaseSchemaVersionProvider);
    final schemaVersion = schema.asData?.value;
    return Stack(
      children: [
        const Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 0.45,
              child: TropicalMountainsBackdrop(),
            ),
          ),
        ),
        AdaptiveSheetDialogBody(
          title: 'About $appName',
          showCloseButton: showCloseButton,
          actions: [
            TextButton(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: appName,
                applicationVersion: appVersion,
                applicationIcon: const _AboutLogo(),
              ),
              child: const Text('Licenses'),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AboutHeader(),
              const SizedBox(height: NahpuSpacing.xl),
              // Translucent, so the ridges still show through the details.
              NahpuPanel(
                color: colors.surface.withValues(alpha: 0.72),
                padding: const EdgeInsets.symmetric(
                  horizontal: NahpuSpacing.lg,
                  vertical: NahpuSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AboutInfoRow(label: 'App version', value: appVersion),
                    const Divider(height: NahpuSpacing.md),
                    const _AboutInfoRow(
                      label: 'Codename',
                      value: versionName,
                      note:
                          'From NAHPU’s first real-world field test on '
                          'Mt. Gede, West Java, Indonesia.',
                    ),
                    const Divider(height: NahpuSpacing.md),
                    _AboutInfoRow(
                      label: 'Database schema',
                      value: schema.hasError
                          ? 'Unavailable'
                          : schemaVersion == null
                          ? null
                          : 'v$schemaVersion',
                      note:
                          schemaVersion != null &&
                              schemaVersion != kSchemaVersion
                          ? 'App supports v$kSchemaVersion'
                          : null,
                      isNoteWarning: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NahpuSpacing.xl),
              const Text(
                '$appName is a cross-platform digital catalog app designed '
                'for natural history specimen data collection and '
                'management, providing insights at the point of collection.',
              ),
              // Leaves the lower ridges clear of the text.
              const SizedBox(height: NahpuSpacing.displayLarge),
            ],
          ),
        ),
      ],
    );
  }
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const _AboutLogo(),
        const SizedBox(width: NahpuSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Merriweather',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: NahpuSpacing.xxs),
              Text(
                'Rethinking biodiversity inventories in the digital age',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Merriweather',
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AboutLogo extends StatelessWidget {
  const _AboutLogo();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logo/nahpu-nobg.svg',
      width: NahpuControlSize.prominent,
      height: NahpuControlSize.prominent,
      semanticsLabel: appName,
    );
  }
}

/// A label and its value, which wraps under the label when the row is narrow.
class _AboutInfoRow extends StatelessWidget {
  const _AboutInfoRow({
    required this.label,
    required this.value,
    this.note,
    this.isNoteWarning = false,
  });

  final String label;

  /// Null while the value is still loading.
  final String? value;

  final String? note;
  final bool isNoteWarning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final value = this.value;
    final note = this.note;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: NahpuSpacing.lg,
            runSpacing: NahpuSpacing.xxs,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              if (value == null)
                const SizedBox.square(
                  dimension: NahpuControlSize.iconSmall,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(value, style: theme.textTheme.titleSmall),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: NahpuSpacing.xxs),
            Text(
              note,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isNoteWarning ? colors.error : colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SetupWizardTile extends StatelessWidget {
  const SetupWizardTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.auto_fix_high_outlined),
      title: const Text('Setup NAHPU'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SetupWizardScreen()),
        );
      },
    );
  }
}

class CookbookTile extends StatelessWidget {
  const CookbookTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.menu_book_outlined),
      title: const Text('Cookbook'),
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CookbookScreen()),
        );
      },
    );
  }
}

class DocQrCode extends StatelessWidget {
  const DocQrCode({super.key});

  @override
  Widget build(BuildContext context) {
    bool isPhone = getScreenType(context) == ScreenType.phone;
    return Container(
      alignment: Alignment.center,
      child: QrImageView(
        data: nahpuWebsite,
        size: isPhone ? 80 : 120,
        backgroundColor: Colors.transparent,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
