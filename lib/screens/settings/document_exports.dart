import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';

class DocumentExportSettings extends ConsumerStatefulWidget {
  const DocumentExportSettings({super.key});

  @override
  DocumentExportSettingsState createState() => DocumentExportSettingsState();
}

class DocumentExportSettingsState
    extends ConsumerState<DocumentExportSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Exports'),
      ),
      body: SafeArea(
        child: CommonSettingList(
          sections: [
            CommonSettingSection(
              title: 'Typst PDF Generation',
              isDivided: true,
              children: [
                CommonSettingTile(
                  title: 'Custom Fonts',
                  label: 'Import custom fonts for document generation',
                  isNavigation: false,
                  icon: Icons.font_download_outlined,
                  onTap: () {},
                ),
                CommonSettingTile(
                  title: 'Custom Icons',
                  label: 'Import custom icons for document generation',
                  isNavigation: false,
                  icon: Icons.insert_emoticon_outlined,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
