import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/exports/export_db.dart';
import 'package:nahpu/screens/exports/export_settings.dart';
import 'package:nahpu/screens/home/components/learning_resources.dart';
import 'package:nahpu/screens/projects/new_project.dart';
import 'package:nahpu/screens/projects/project_transfer/import_project.dart';
import 'package:nahpu/screens/settings/settings.dart';
import 'package:nahpu/screens/settings/app_settings_import.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
          title: const Text('Export settings'),
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
          leading: const Icon(Icons.input_outlined),
          title: const Text('Import settings'),
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
        // const LearningResourceTile(),
        // const CommonLineDivider(),
        ListTile(
          leading: const Icon(Icons.info_outlined),
          title: const Text('About'),
          onTap: () async {
            return showDialog(
              context: context,
              builder: (context) {
                return const AppAbout();
              },
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

class AppAbout extends StatelessWidget {
  const AppAbout({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: AboutDialog(
            applicationName: appName,
            applicationVersion:
                'v${snapshot.data?.version ?? ''} ($versionName)',
            applicationIcon: const Icon(Icons.info_outline),
            children: [
              Text(
                'Rethinking species inventories in the digital age',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                '$appName is a cross-platform '
                'digital catalog app designed for natural history '
                'specimen data collection and management, providing '
                'insights at the point of collection.',
              ),
            ],
          ),
        );
      },
      future: PackageInfo.fromPlatform(),
    );
  }
}

class LearningResourceTile extends StatelessWidget {
  const LearningResourceTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.school_rounded),
      title: const Text('Learning resources'),
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LearningResourcePage()),
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
