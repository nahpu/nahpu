import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/fonts/font_preview.dart';
import 'package:nahpu/screens/templates/template_fonts.dart';
import 'package:nahpu/services/providers/fonts.dart';
import 'package:nahpu/services/templates/font_registry.dart';
import 'package:nahpu/services/templates/template_service.dart';
import 'package:nahpu/services/templates/user_font_service.dart';
import 'package:nahpu/services/types/user_fonts.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:url_launcher/url_launcher.dart';

/// Manages the fonts available to document templates.
///
/// Bundled families ship with the app. User families are installed from local
/// font files into `UserConfigs/fonts/`, which makes them available to both
/// the template canvas and the PDF compiler on this installation only.
class FontManager extends ConsumerStatefulWidget {
  const FontManager({super.key});

  @override
  ConsumerState<FontManager> createState() => _FontManagerState();
}

class _FontManagerState extends ConsumerState<FontManager>
    with TickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  String _query = '';
  String? _selectedFamily;
  Map<String, List<String>> _usageByFamily = const {};

  @override
  void initState() {
    super.initState();
    _loadUsages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen =
        MediaQuery.sizeOf(context).width > NahpuBreakpoints.compact;
    final registryValue = ref.watch(fontRegistryProvider);

    return registryValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Unable to read fonts: $error')),
      data: (registry) {
        final entries = _visibleEntries(registry);
        final selected =
            registry.entryFor(_selectedFamily ?? '') ??
            (entries.isEmpty ? null : entries.first);

        final list = _FontListColumn(
          entries: entries,
          selectedFamily: selected?.family,
          usageByFamily: _usageByFamily,
          onQueryChanged: (value) => setState(() => _query = value),
          onSelected: (family) {
            setState(() => _selectedFamily = family);
            if (!isLargeScreen) _tabController.animateTo(1);
          },
          onImport: _importFont,
          onDelete: _deleteFont,
        );
        final preview = _FontPreviewPanel(
          entry: selected,
          usedBy: selected == null
              ? const []
              : _usageByFamily[selected.family] ?? const [],
        );

        if (!isLargeScreen) {
          return Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Fonts'),
                  Tab(text: 'Preview'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [list, preview],
                ),
              ),
            ],
          );
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
            NahpuSpacing.md,
            NahpuSpacing.md,
            NahpuSpacing.md,
            NahpuSpacing.xl,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: list),
              SizedBox(width: NahpuSpacing.xl),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(NahpuSpacing.xs),
                  child: Material(
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NahpuRadius.lg),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    child: preview,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<FontFamilyEntry> _visibleEntries(FontRegistry registry) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return registry.entries;
    return registry.entries
        .where((entry) => entry.family.toLowerCase().contains(query))
        .toList(growable: false);
  }

  /// Maps each font family to the templates that use it, so a font in use
  /// cannot be removed without warning.
  Future<void> _loadUsages() async {
    const service = TemplateService();
    final usages = <String, List<String>>{};
    try {
      for (final name in await service.listTemplateNames()) {
        final template = await service.getTemplate(name);
        if (template == null) continue;
        for (final family in collectTemplateTextFontKeys(template)) {
          final normalized = normalizeTemplateFontFamily(family);
          usages.putIfAbsent(normalized, () => []).add(name);
        }
      }
    } on Object {
      return;
    }
    if (mounted) setState(() => _usageByFamily = usages);
  }

  Future<void> _importFont() async {
    final selected = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: UserFontService.supportedExtensions,
    );
    final filePath = selected?.path;
    if (filePath == null) return;
    try {
      final font = await ref
          .read(fontRegistryProvider.notifier)
          .importFile(File(filePath));
      if (!mounted) return;
      setState(() => _selectedFamily = font.family);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Installed ${font.family}')));
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to install font: $error')));
    }
  }

  Future<void> _deleteFont(UserFont font) async {
    final usedBy = _usageByFamily[font.family] ?? const [];
    if (usedBy.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${font.family} is in use'),
          content: Text(
            'Remove or change this font in '
            '${usedBy.length == 1 ? 'this template' : 'these templates'} '
            'before deleting it:\n\n${usedBy.join('\n')}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${font.family}?'),
        content: const Text(
          'The font files are removed from this installation. Templates that '
          'use it elsewhere are not changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(fontRegistryProvider.notifier).delete(font);
    if (!mounted) return;
    if (_selectedFamily == font.family) {
      setState(() => _selectedFamily = null);
    }
  }
}

class _FontListColumn extends StatelessWidget {
  const _FontListColumn({
    required this.entries,
    required this.selectedFamily,
    required this.usageByFamily,
    required this.onQueryChanged,
    required this.onSelected,
    required this.onImport,
    required this.onDelete,
  });

  final List<FontFamilyEntry> entries;
  final String? selectedFamily;
  final Map<String, List<String>> usageByFamily;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onSelected;
  final Future<void> Function() onImport;
  final Future<void> Function(UserFont) onDelete;

  @override
  Widget build(BuildContext context) {
    final bundled = entries.where((entry) => entry.isBundled).toList();
    final installed = entries.where((entry) => !entry.isBundled).toList();

    return Padding(
      padding: EdgeInsets.all(NahpuSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search fonts',
              border: OutlineInputBorder(),
            ),
            onChanged: onQueryChanged,
          ),
          SizedBox(height: NahpuSpacing.lg),
          Wrap(
            spacing: NahpuSpacing.md,
            runSpacing: NahpuSpacing.md,
            children: [
              OutlinedButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.add),
                label: const Text('Install font'),
              ),
              TextButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse('https://fonts.google.com'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Find fonts'),
              ),
            ],
          ),
          SizedBox(height: NahpuSpacing.md),
          Text(
            'Download a font in your browser, then install the .ttf or .otf '
            'file here. You are responsible for the license of any font you '
            'install.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: NahpuSpacing.lg),
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('No fonts match your search'))
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      if (installed.isNotEmpty) ...[
                        _SectionLabel(label: 'Installed by you'),
                        for (final entry in installed)
                          _FontTile(
                            entry: entry,
                            isSelected: entry.family == selectedFamily,
                            usageCount:
                                usageByFamily[entry.family]?.length ?? 0,
                            onTap: () => onSelected(entry.family),
                            onDelete: () => onDelete(entry.userFont!),
                          ),
                        SizedBox(height: NahpuSpacing.lg),
                      ],
                      if (bundled.isNotEmpty) ...[
                        _SectionLabel(label: 'Bundled with NAHPU'),
                        for (final entry in bundled)
                          _FontTile(
                            entry: entry,
                            isSelected: entry.family == selectedFamily,
                            usageCount:
                                usageByFamily[entry.family]?.length ?? 0,
                            onTap: () => onSelected(entry.family),
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: NahpuSpacing.md),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _FontTile extends StatelessWidget {
  const _FontTile({
    required this.entry,
    required this.isSelected,
    required this.usageCount,
    required this.onTap,
    this.onDelete,
  });

  final FontFamilyEntry entry;
  final bool isSelected;
  final int usageCount;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final font = entry.userFont;
    final details = [
      if (font != null)
        '${font.variants.length} file'
            '${font.variants.length == 1 ? '' : 's'} · '
            '${_formatSize(font.byteSize)}',
      usageCount == 0
          ? 'Unused'
          : 'Used by $usageCount template${usageCount == 1 ? '' : 's'}',
    ].join(' · ');

    return Card(
      child: ListTile(
        selected: isSelected,
        onTap: onTap,
        leading: Icon(
          entry.isBundled
              ? Icons.inventory_2_outlined
              : Icons.font_download_outlined,
        ),
        title: Text(
          entry.family,
          style: customTemplateCanvasTextStyle(
            fontFamilyRaw: entry.family,
            fontSize: 16,
          ),
        ),
        subtitle: Text(details),
        trailing: onDelete == null
            ? null
            : IconButton(
                tooltip: 'Delete font',
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _FontPreviewPanel extends StatefulWidget {
  const _FontPreviewPanel({required this.entry, required this.usedBy});

  final FontFamilyEntry? entry;
  final List<String> usedBy;

  @override
  State<_FontPreviewPanel> createState() => _FontPreviewPanelState();
}

class _FontPreviewPanelState extends State<_FontPreviewPanel> {
  double _fontSize = 16;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    if (entry == null) {
      return const Center(child: Text('Select a font to preview it'));
    }
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            NahpuSpacing.xl,
            NahpuSpacing.lg,
            NahpuSpacing.xl,
            NahpuSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.family, style: theme.textTheme.titleMedium),
              SizedBox(height: NahpuSpacing.md),
              Wrap(
                spacing: NahpuSpacing.md,
                runSpacing: NahpuSpacing.xs,
                children: [
                  Chip(
                    label: Text(entry.isBundled ? 'Bundled' : 'Installed'),
                    visualDensity: VisualDensity.compact,
                  ),
                  for (final variant in entry.userFont?.variants ?? const [])
                    Chip(
                      label: Text(variant.label),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              if (widget.usedBy.isNotEmpty) ...[
                SizedBox(height: NahpuSpacing.md),
                Text(
                  'Used by ${widget.usedBy.join(', ')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              SizedBox(height: NahpuSpacing.md),
              Row(
                children: [
                  Text('Size', style: theme.textTheme.labelMedium),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      min: 10,
                      max: 40,
                      divisions: 30,
                      label: '${_fontSize.round()} pt',
                      onChanged: (value) => setState(() => _fontSize = value),
                    ),
                  ),
                  Text(
                    '${_fontSize.round()} pt',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(NahpuSpacing.xl),
            child: FontSamplePreview(
              family: entry.family,
              fontSize: _fontSize,
              showStyles: true,
            ),
          ),
        ),
      ],
    );
  }
}
