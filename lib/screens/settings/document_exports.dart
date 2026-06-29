import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/services/providers/settings.dart';

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
      body: const SafeArea(
        child: CommonSettingList(
          sections: [
            CommonSettingSection(
              title: 'PDF Generation',
              isDivided: true,
              children: [
                FontSettingTile(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FontSettingTile extends ConsumerWidget {
  const FontSettingTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontName = ref.watch(pdfExportFontNotifierProvider);

    return fontName.when(
      data: (font) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: DropdownButtonFormField<String>(
                initialValue: font,
                decoration: const InputDecoration(
                  labelText: 'Default Font',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.font_download_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Merriweather', child: Text('Merriweather')),
                  DropdownMenuItem(
                      value: 'DejaVuSans', child: Text('DejaVu Sans')),
                  DropdownMenuItem(
                      value: 'DejaVuSerif', child: Text('DejaVu Serif')),
                  DropdownMenuItem(
                      value: 'LibertinusSans', child: Text('Libertinus Sans')),
                  DropdownMenuItem(
                      value: 'LibertinusSerif',
                      child: Text('Libertinus Serif')),
                  DropdownMenuItem(
                      value: 'PlusJakartaSans',
                      child: Text('Plus Jakarta Sans')),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    ref
                        .read(pdfExportFontNotifierProvider.notifier)
                        .set(newValue);
                  }
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'The quick brown fox jumps over the lazy dog.',
                  style: TextStyle(fontFamily: font, fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error: $e'),
    );
  }
}
