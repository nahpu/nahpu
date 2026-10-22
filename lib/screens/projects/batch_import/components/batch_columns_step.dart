import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/screens/shared/layout/wizard.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_import_targets.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Third step: check and change which field each column fills.
class BatchColumnsStep extends StatelessWidget {
  const BatchColumnsStep({
    super.key,
    required this.table,
    required this.type,
    required this.targets,
    required this.mode,
    required this.headerMode,
    required this.matches,
    required this.selectedKey,
    required this.onHeaderModeChanged,
    required this.onFieldChanged,
    required this.onKeyChanged,
  });

  final BatchImportTable table;
  final DataTableRecordType type;

  /// Fields the columns can fill.
  final List<BatchImportTarget> targets;
  final BatchImportMode mode;
  final BatchImportHeaderMode headerMode;
  final List<BatchColumnMatch> matches;
  final BatchImportKey? selectedKey;
  final ValueChanged<BatchImportHeaderMode> onHeaderModeChanged;
  final void Function(int column, String? fieldKey) onFieldChanged;
  final ValueChanged<BatchImportKey?> onKeyChanged;

  @override
  Widget build(BuildContext context) {
    final mapped = matches.where((match) => match.fieldKey != null).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NahpuStepHeading(
          title: 'Match columns',
          message:
              '$mapped of ${matches.length} columns match a field. Change any '
              'match, or skip a column. Your changes are remembered for '
              'files with the same columns.',
        ),
        const SizedBox(height: NahpuSpacing.xl),
        SegmentedButton<BatchImportHeaderMode>(
          segments: [
            for (final value in BatchImportHeaderMode.values)
              ButtonSegment(value: value, label: Text(value.label)),
          ],
          selected: {headerMode},
          onSelectionChanged: (selection) =>
              onHeaderModeChanged(selection.single),
        ),
        if (mode == BatchImportMode.update) ...[
          const SizedBox(height: NahpuSpacing.xl),
          BatchKeyPicker(
            type: type,
            matches: matches,
            selectedKey: selectedKey,
            onChanged: onKeyChanged,
          ),
        ],
        const SizedBox(height: NahpuSpacing.xl),
        for (final match in matches) ...[
          BatchColumnRow(
            match: match,
            samples: table.samples(match.column),
            targets: targets,
            usedKeys: {
              for (final other in matches)
                if (other.column != match.column) ?other.fieldKey,
            },
            onChanged: (key) => onFieldChanged(match.column, key),
          ),
          const SizedBox(height: NahpuSpacing.md),
        ],
      ],
    );
  }
}

/// Chooses how update rows find their record.
class BatchKeyPicker extends StatelessWidget {
  const BatchKeyPicker({
    super.key,
    required this.type,
    required this.matches,
    required this.selectedKey,
    required this.onChanged,
  });

  final DataTableRecordType type;
  final List<BatchColumnMatch> matches;
  final BatchImportKey? selectedKey;
  final ValueChanged<BatchImportKey?> onChanged;

  @override
  Widget build(BuildContext context) {
    final available = BatchImportKey.available(type, [
      for (final match in matches) match.fieldKey,
    ]);
    final colors = Theme.of(context).colorScheme;
    return NahpuPanel(
      borderColor: selectedKey == null ? colors.error : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Key column', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: NahpuSpacing.xs),
          Text(
            available.isEmpty
                ? 'Map a column to one of: '
                      '${BatchImportKey.forType(type).map((k) => k.label).join(', ')}.'
                : 'Rows update the record with the same value.',
          ),
          if (available.isNotEmpty) ...[
            const SizedBox(height: NahpuSpacing.lg),
            DropdownButtonFormField<BatchImportKey>(
              initialValue: available.contains(selectedKey)
                  ? selectedKey
                  : null,
              decoration: const InputDecoration(labelText: 'Match records by'),
              items: [
                for (final key in available)
                  DropdownMenuItem(value: key, child: Text(key.label)),
              ],
              onChanged: onChanged,
            ),
          ],
        ],
      ),
    );
  }
}

/// One file column: its header and sample values, the field it fills, and
/// why.
class BatchColumnRow extends StatelessWidget {
  const BatchColumnRow({
    super.key,
    required this.match,
    required this.samples,
    required this.targets,
    required this.usedKeys,
    required this.onChanged,
  });

  final BatchColumnMatch match;
  final List<String> samples;
  final List<BatchImportTarget> targets;

  /// Fields other columns already fill.
  final Set<String> usedKeys;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= NahpuBreakpoints.compact;
    final source = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(match.header, style: theme.textTheme.titleSmall),
        const SizedBox(height: NahpuSpacing.xxs),
        Text(
          samples.isEmpty ? 'No values' : samples.join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: NahpuSpacing.xs),
        BatchMatchChip(match: match),
      ],
    );
    final picker = BatchFieldDropdown(
      value: match.fieldKey,
      targets: targets,
      usedKeys: usedKeys,
      onChanged: onChanged,
    );
    return NahpuPanel(
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      child: wide
          ? Row(
              children: [
                Expanded(child: source),
                const SizedBox(width: NahpuSpacing.xl),
                Expanded(child: picker),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                source,
                const SizedBox(height: NahpuSpacing.md),
                picker,
              ],
            ),
    );
  }
}

/// The target fields, grouped by section, with "Skip" first.
class BatchFieldDropdown extends StatelessWidget {
  const BatchFieldDropdown({
    super.key,
    required this.value,
    required this.targets,
    required this.usedKeys,
    required this.onChanged,
  });

  final String? value;
  final List<BatchImportTarget> targets;
  final Set<String> usedKeys;
  final ValueChanged<String?> onChanged;

  static const _skip = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = <String, List<BatchImportTarget>>{};
    for (final target in targets) {
      groups.putIfAbsent(target.group, () => []).add(target);
    }
    return DropdownButtonFormField<String>(
      // Rebuilt when the match changes from outside, such as a new mode.
      key: ValueKey(value),
      initialValue: value ?? _skip,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'NAHPU field'),
      items: [
        const DropdownMenuItem(value: _skip, child: Text('Skip column')),
        for (final entry in groups.entries) ...[
          DropdownMenuItem(
            value: '#${entry.key}',
            enabled: false,
            child: Text(
              entry.key,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          for (final target in entry.value)
            DropdownMenuItem(
              value: target.key,
              enabled: !usedKeys.contains(target.key),
              child: Padding(
                padding: const EdgeInsets.only(left: NahpuSpacing.lg),
                child: Text(
                  usedKeys.contains(target.key)
                      ? '${target.label} (in use)'
                      : target.label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ],
      selectedItemBuilder: (context) => [
        const Text('Skip column'),
        for (final entry in groups.entries) ...[
          Text(entry.key),
          for (final target in entry.value)
            Text('${target.label} · ${target.group}'),
        ],
      ],
      onChanged: (key) => onChanged(key == null || key == _skip ? null : key),
    );
  }
}

/// Says how a column was matched.
class BatchMatchChip extends StatelessWidget {
  const BatchMatchChip({super.key, required this.match});

  final BatchColumnMatch match;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, icon, color) = switch (match.origin) {
      BatchMatchOrigin.darwinCore => (
        'Darwin Core',
        Icons.verified_outlined,
        colors.primary,
      ),
      BatchMatchOrigin.exactName => (
        'Name match',
        Icons.check_circle_outline_rounded,
        colors.primary,
      ),
      BatchMatchOrigin.fuzzyName => (
        'Close match ${(match.score * 100).round()}%',
        Icons.auto_fix_high_outlined,
        colors.tertiary,
      ),
      BatchMatchOrigin.saved || BatchMatchOrigin.user => (
        match.fieldKey == null ? 'Skipped by you' : 'Your choice',
        Icons.person_outline_rounded,
        colors.secondary,
      ),
      BatchMatchOrigin.none => (
        'No match',
        Icons.help_outline_rounded,
        colors.outline,
      ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: NahpuControlSize.iconSmall, color: color),
        const SizedBox(width: NahpuSpacing.xs),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
