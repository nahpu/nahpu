import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/forms/bundled_preset_checklist.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/bundled_preset_service.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Lets the user pick which bundled presets of [kinds] to add.
///
/// Presets that suit any catalog format start checked. Presets written for one
/// catalog format are listed under that format and start unchecked, since
/// they are optional.
///
/// Returns the load result, or null when the picker is dismissed.
Future<BundledPresetLoadResult?> showLoadDefaultsDialog({
  required BuildContext context,
  required Set<BundledPresetKind> kinds,
}) async {
  if (MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact) {
    return showModalBottomSheet<BundledPresetLoadResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: LoadDefaultsDialog(kinds: kinds, showCloseButton: false),
      ),
    );
  }
  return showDialog<BundledPresetLoadResult>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: NahpuContentWidth.form,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: LoadDefaultsDialog(kinds: kinds),
      ),
    ),
  );
}

class LoadDefaultsDialog extends ConsumerStatefulWidget {
  const LoadDefaultsDialog({
    super.key,
    required this.kinds,
    this.showCloseButton = true,
  });

  final Set<BundledPresetKind> kinds;

  /// The bottom sheet is dismissed with its drag handle instead.
  final bool showCloseButton;

  @override
  ConsumerState<LoadDefaultsDialog> createState() => _LoadDefaultsDialogState();
}

class _LoadDefaultsDialogState extends ConsumerState<LoadDefaultsDialog> {
  /// Checkbox choices keyed by asset path, overriding each preset's default.
  final Map<String, bool> _choices = {};
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statuses = ref.watch(allBundledPresetStatusProvider);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        NahpuSpacing.xl,
        NahpuSpacing.md,
        NahpuSpacing.xl,
        MediaQuery.viewInsetsOf(context).bottom + NahpuSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Load defaults',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              if (widget.showCloseButton)
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close),
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
            ],
          ),
          const SizedBox(height: NahpuSpacing.xs),
          Text(
            'Choose the bundled presets to add. Presets you already have are '
            'left unchanged.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: NahpuSpacing.lg),
          statuses.when(
            data: (all) {
              final offered = [
                for (final status in all)
                  if (widget.kinds.contains(status.preset.kind)) status,
              ];
              if (offered.isEmpty) {
                return const Text('No default presets of this type.');
              }
              final generic = [
                for (final status in offered)
                  if (status.preset.isGeneric) status,
              ];
              final formats = [
                for (final catalogFmt in CatalogFmt.values)
                  if (offered.any((s) => s.preset.catalogFmt == catalogFmt))
                    catalogFmt,
              ];
              final selected = [
                for (final status in offered)
                  if (!status.isInstalled && _isChecked(status)) status.preset,
              ];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (generic.isNotEmpty)
                    BundledPresetChecklist(
                      title: formats.isEmpty ? null : 'Defaults',
                      message: formats.isEmpty
                          ? null
                          : 'Presets that suit any catalog format.',
                      statuses: generic,
                      isChecked: _isChecked,
                      onChanged: _setChoice,
                    ),
                  for (final (index, catalogFmt) in formats.indexed) ...[
                    if (index > 0 || generic.isNotEmpty)
                      const SizedBox(height: NahpuSpacing.lg),
                    BundledPresetChecklist(
                      title: 'For ${catalogFmtDisplayName(catalogFmt)}',
                      message:
                          'Optional presets written for this catalog format.',
                      statuses: [
                        for (final status in offered)
                          if (status.preset.catalogFmt == catalogFmt) status,
                      ],
                      isChecked: _isChecked,
                      onChanged: _setChoice,
                    ),
                  ],
                  if (widget.kinds.contains(BundledPresetKind.document)) ...[
                    const SizedBox(height: NahpuSpacing.md),
                    Text(
                      'Layouts bring the templates they print with.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: NahpuSpacing.xl),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: selected.isEmpty || _loading
                          ? null
                          : () => _loadSelected(selected),
                      icon: const Icon(Icons.restore_outlined),
                      label: const Text('Load selected'),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Unable to load bundled presets: $error'),
          ),
        ],
      ),
    );
  }

  bool _isChecked(BundledPresetStatus status) {
    return status.isInstalled ||
        (_choices[status.preset.assetPath] ?? status.preset.isGeneric);
  }

  void _setChoice(BundledPreset preset, bool value) {
    setState(() => _choices[preset.assetPath] = value);
  }

  Future<void> _loadSelected(List<BundledPreset> presets) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    try {
      final result = await ref
          .read(bundledPresetServiceProvider)
          .loadSelected(presets);
      ref.invalidate(bundledPresetStatusProvider);
      ref.invalidate(allBundledPresetStatusProvider);
      navigator.pop(result);
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to load default presets: $error')),
      );
      if (mounted) setState(() => _loading = false);
    }
  }
}
