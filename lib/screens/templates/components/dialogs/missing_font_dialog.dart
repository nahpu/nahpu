import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/fonts/font_preview.dart';
import 'package:nahpu/screens/templates/template_model.dart';
import 'package:nahpu/services/providers/fonts.dart';
import 'package:nahpu/services/templates/font_registry.dart';
import 'package:nahpu/services/templates/template_font_resolution_service.dart';
import 'package:nahpu/services/templates/template_service.dart';
import 'package:nahpu/services/templates/template_transfer_service.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Repairs the fonts of [templates] before they are stored.
///
/// Returns the templates with every unavailable font replaced, or `null` when
/// the user cancels the import. When nothing is missing the templates are
/// returned untouched and no dialog is shown. Resolution runs once for the
/// whole batch, so a user importing many templates answers once per font
/// rather than once per template.
Future<List<Template>?> resolveMissingTemplateFonts(
  BuildContext context,
  WidgetRef ref,
  List<Template> templates, {
  bool promptUser = true,
}) async {
  const resolver = TemplateFontResolutionService();
  // A registry that cannot be read (a corrupt catalog, say) degrades to the
  // bundled families rather than blocking the import outright.
  FontRegistry registry;
  try {
    registry = await ref.read(fontRegistryProvider.future);
  } on Object {
    registry = const FontRegistry();
  }
  final missing = resolver.missingFamilies(templates, registry);
  if (missing.isEmpty) return templates;

  if (!promptUser) {
    return resolver.applySubstitutionsToAll(templates, {
      for (final family in missing) family: kFallbackFontFamily,
    });
  }

  if (!context.mounted) return null;
  final substitutions = await showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => MissingFontDialog(
      missingFamilies: missing,
      registry: registry,
      templateCount: templates.length,
    ),
  );
  if (substitutions == null) return null;
  return resolver.applySubstitutionsToAll(templates, substitutions);
}

/// Repairs the fonts of every stored template after an import replaced them.
///
/// A whole-config transfer writes template presets straight into storage, so
/// there is no in-memory batch to resolve first. Returns the number of
/// templates rewritten, or `null` when the user cancels.
Future<int?> resolveStoredTemplateFonts(
  BuildContext context,
  WidgetRef ref, {
  TemplateService templateService = const TemplateService(),
}) async {
  final transfer = TemplateTransferService(templateService: templateService);
  final stored = await transfer.loadAll();
  if (stored.isEmpty) return 0;
  if (!context.mounted) return 0;

  final resolved = await resolveMissingTemplateFonts(context, ref, stored);
  if (resolved == null) return null;

  var rewritten = 0;
  for (var index = 0; index < stored.length; index++) {
    if (identical(stored[index], resolved[index])) continue;
    await templateService.updateTemplate(resolved[index]);
    rewritten++;
  }
  return rewritten;
}

/// Asks the user to replace font families the incoming templates reference but
/// this installation cannot render.
///
/// Returns a map of missing family to chosen replacement, or `null` when the
/// import is cancelled. Every missing family always has a replacement, so a
/// template is never stored referencing a font that cannot be rendered.
class MissingFontDialog extends StatefulWidget {
  const MissingFontDialog({
    super.key,
    required this.missingFamilies,
    required this.registry,
    this.templateCount = 1,
  });

  final Set<String> missingFamilies;
  final FontRegistry registry;
  final int templateCount;

  @override
  State<MissingFontDialog> createState() => _MissingFontDialogState();
}

class _MissingFontDialogState extends State<MissingFontDialog> {
  late final Map<String, String> _choices = {
    for (final family in widget.missingFamilies) family: kFallbackFontFamily,
  };
  late String _previewFamily = widget.missingFamilies.first;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = widget.registry.availableFamilies;
    final isNarrow =
        MediaQuery.sizeOf(context).width <= NahpuBreakpoints.compact;

    return AlertDialog(
      title: const Text('Fonts not installed'),
      content: SizedBox(
        width: isNarrow ? double.maxFinite : 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.missingFamilies.length == 1
                    ? 'This installation does not have 1 font used by the '
                          'imported $_templateWord. Choose a replacement.'
                    : 'This installation does not have '
                          '${widget.missingFamilies.length} fonts used by the '
                          'imported $_templateWord. Choose a replacement for '
                          'each.',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: NahpuSpacing.xs),
              Text(
                'Install the original fonts under Documents > Fonts if you '
                'need an exact match.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: NahpuSpacing.xl),
              for (final family in widget.missingFamilies) ...[
                _MissingFontRow(
                  missingFamily: family,
                  replacement: _choices[family]!,
                  available: available,
                  isSelected: _previewFamily == family,
                  onChanged: (value) => setState(() {
                    _choices[family] = value;
                    _previewFamily = family;
                  }),
                  onFocus: () => setState(() => _previewFamily = family),
                ),
                SizedBox(height: NahpuSpacing.lg),
              ],
              Divider(color: theme.colorScheme.outlineVariant),
              SizedBox(height: NahpuSpacing.lg),
              Text(
                'Preview: ${_choices[_previewFamily]}',
                style: theme.textTheme.labelMedium,
              ),
              SizedBox(height: NahpuSpacing.md),
              FontSamplePreview(
                family: _choices[_previewFamily]!,
                fontSize: 14,
                samples: const [kFontPreviewSampleA],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel import'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, Map<String, String>.from(_choices)),
          child: const Text('Replace and import'),
        ),
      ],
    );
  }

  String get _templateWord =>
      widget.templateCount == 1 ? 'template' : 'templates';
}

class _MissingFontRow extends StatelessWidget {
  const _MissingFontRow({
    required this.missingFamily,
    required this.replacement,
    required this.available,
    required this.isSelected,
    required this.onChanged,
    required this.onFocus,
  });

  final String missingFamily;
  final String replacement;
  final List<String> available;
  final bool isSelected;
  final ValueChanged<String> onChanged;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onFocus,
      borderRadius: BorderRadius.circular(NahpuRadius.md),
      child: Ink(
        padding: EdgeInsets.all(NahpuSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(NahpuRadius.md),
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
            width: isSelected ? NahpuStroke.regular : NahpuStroke.thin,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.font_download_off_outlined, color: scheme.error),
            SizedBox(width: NahpuSpacing.lg),
            Expanded(
              child: Text(
                missingFamily,
                style: Theme.of(context).textTheme.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: NahpuSpacing.md),
            const Icon(Icons.arrow_forward, size: 18),
            SizedBox(width: NahpuSpacing.md),
            DropdownButton<String>(
              value: replacement,
              isDense: true,
              underline: const SizedBox.shrink(),
              items: [
                for (final family in available)
                  DropdownMenuItem<String>(value: family, child: Text(family)),
              ],
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
