import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/data_table/data_table_screen.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/database/database_health/database_health_service.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/service_labels.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:path/path.dart' as p;

/// Scans the database for problems users can fix in the app, opens the
/// records involved, and applies the safe repairs.
class CheckDatabaseScreen extends ConsumerStatefulWidget {
  const CheckDatabaseScreen({super.key});

  @override
  ConsumerState<CheckDatabaseScreen> createState() =>
      _CheckDatabaseScreenState();
}

class _CheckDatabaseScreenState extends ConsumerState<CheckDatabaseScreen> {
  HealthReport? _report;
  String? _scanError;
  bool _isScanning = false;
  bool _isFixing = false;
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scan());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final report = _report;
    final busy = _isScanning || _isFixing;
    final fixable = report?.fixable ?? const <HealthIssue>[];
    final selectedCount = fixable
        .where((issue) => _selected.contains(issue.id))
        .length;
    return PopScope(
      // Fixes run one transaction each; leaving midway would hide which ones
      // were applied.
      canPop: !_isFixing,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsNavCheckDatabase),
          actions: [
            IconButton(
              tooltip: l10n.healthRescan,
              icon: const Icon(Icons.refresh_rounded),
              onPressed: busy ? null : _scan,
            ),
          ],
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: NahpuContentWidth.projectForm,
              ),
              child: ListView(
                padding: const EdgeInsets.all(NahpuSpacing.xl),
                children: [
                  _HealthSummaryCard(
                    report: report,
                    error: _scanError,
                    isScanning: _isScanning,
                    isFixing: _isFixing,
                    onScan: busy ? null : _scan,
                  ),
                  if (fixable.isNotEmpty) ...[
                    const SizedBox(height: NahpuSpacing.xl),
                    _FixBar(
                      selectedCount: selectedCount,
                      totalCount: fixable.length,
                      enabled: !busy,
                      onToggleAll: (value) => setState(() {
                        if (value) {
                          _selected.addAll(fixable.map((issue) => issue.id));
                        } else {
                          _selected.clear();
                        }
                      }),
                      onFix: selectedCount == 0 ? null : _confirmAndFix,
                    ),
                  ],
                  if (report != null)
                    for (final MapEntry(key: kind, value: issues)
                        in report.byKind.entries) ...[
                      const SizedBox(height: NahpuSpacing.xl),
                      _HealthKindSection(
                        kind: kind,
                        issues: issues,
                        selected: _selected,
                        enabled: !busy,
                        onToggle: _toggle,
                        onOpen: _openRecords,
                      ),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _scan() async {
    setState(() {
      _isScanning = true;
      _scanError = null;
    });
    try {
      final report = await DatabaseHealthService(ref: ref).scan();
      if (!mounted) return;
      setState(() {
        _report = report;
        final ids = report.fixable.map((issue) => issue.id).toSet();
        _selected.retainAll(ids);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _scanError = '$error');
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _toggle(HealthIssue issue, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(issue.id);
      } else {
        _selected.remove(issue.id);
      }
    });
  }

  Future<void> _openRecords(HealthIssue issue) async {
    final target = issue.target;
    if (target == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DataTableScreen(
          initialType: target.type,
          initialScope: DataTableKeyScope(
            keys: target.keys,
            label: '${issue.kind.title(context.l10n)}: ${issue.recordLabel}',
          ),
          allProjects: true,
        ),
      ),
    );
    // The user may have fixed the record by hand.
    if (mounted) await _scan();
  }

  Future<void> _confirmAndFix() async {
    final issues = (_report?.fixable ?? const <HealthIssue>[])
        .where((issue) => _selected.contains(issue.id))
        .toList(growable: false);
    if (issues.isEmpty) return;
    final backup = await showDialog<bool>(
      context: context,
      builder: (_) => _ApplyFixesDialog(count: issues.length),
    );
    if (backup == null || !mounted) return;
    setState(() => _isFixing = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final result = await DatabaseHealthService(
        ref: ref,
      ).applyFixes(issues, backup: backup);
      final lines = [
        l10n.healthFixedCount(result.fixed),
        if (result.failed.isNotEmpty)
          l10n.healthFixFailedCount(result.failed.length),
        if (result.backup != null)
          l10n.healthBackupSaved(p.basename(result.backup!.path)),
      ];
      messenger.showSnackBar(SnackBar(content: Text(lines.join('\n'))));
      _selected.clear();
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.healthFixFailed('$error'))),
      );
    } finally {
      if (mounted) setState(() => _isFixing = false);
    }
    if (mounted) await _scan();
  }
}

class _HealthSummaryCard extends StatelessWidget {
  const _HealthSummaryCard({
    required this.report,
    required this.error,
    required this.isScanning,
    required this.isFixing,
    required this.onScan,
  });

  final HealthReport? report;
  final String? error;
  final bool isScanning;
  final bool isFixing;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final report = this.report;
    final error = this.error;
    final status = switch (report) {
      _ when isFixing => l10n.healthFixing,
      _ when isScanning => l10n.healthScanning,
      null => l10n.healthNotScanned,
      HealthReport(isHealthy: true) => l10n.healthNoIssues,
      _ => l10n.healthSummary(report.errorCount, report.warningCount),
    };
    final healthy = report?.isHealthy ?? false;
    return NahpuPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.healthIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: NahpuSpacing.lg),
          Row(
            children: [
              Icon(
                healthy
                    ? Icons.check_circle_outline_rounded
                    : report == null
                    ? Icons.health_and_safety_outlined
                    : Icons.error_outline_rounded,
                color: healthy
                    ? colors.primary
                    : report == null || report.errorCount == 0
                    ? colors.onSurfaceVariant
                    : colors.error,
              ),
              const SizedBox(width: NahpuSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(status, style: theme.textTheme.titleMedium),
                    if (report != null && !isScanning)
                      Text(
                        l10n.healthLastScan(_formatTime(report)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onScan,
                icon: const Icon(Icons.search_rounded),
                label: Text(
                  report == null ? l10n.healthScan : l10n.healthRescan,
                ),
              ),
            ],
          ),
          if (isScanning || isFixing) ...[
            const SizedBox(height: NahpuSpacing.lg),
            const LinearProgressIndicator(),
          ],
          if (error != null) ...[
            const SizedBox(height: NahpuSpacing.lg),
            Text(
              l10n.healthScanFailed(error),
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.error),
            ),
          ],
        ],
      ),
    );
  }

  /// Follows the regional format, like the other dates in the app.
  String _formatTime(HealthReport report) {
    final value = parseDate(report.scannedAt.toIso8601String());
    return '${value.date} ${value.time}';
  }
}

class _FixBar extends StatelessWidget {
  const _FixBar({
    required this.selectedCount,
    required this.totalCount,
    required this.enabled,
    required this.onToggleAll,
    required this.onFix,
  });

  final int selectedCount;
  final int totalCount;
  final bool enabled;
  final ValueChanged<bool> onToggleAll;
  final VoidCallback? onFix;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final allSelected = selectedCount == totalCount;
    return Wrap(
      spacing: NahpuSpacing.md,
      runSpacing: NahpuSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(NahpuRadius.sm),
          onTap: enabled ? () => onToggleAll(!allSelected) : null,
          child: Padding(
            padding: const EdgeInsets.only(right: NahpuSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: selectedCount == 0
                      ? false
                      : allSelected
                      ? true
                      : null,
                  tristate: true,
                  onChanged: enabled ? (_) => onToggleAll(!allSelected) : null,
                ),
                Text(l10n.healthSelectAllFixes),
              ],
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: enabled ? onFix : null,
          icon: const Icon(Icons.build_outlined),
          label: Text(l10n.healthFixSelected(selectedCount)),
        ),
      ],
    );
  }
}

class _HealthKindSection extends StatelessWidget {
  const _HealthKindSection({
    required this.kind,
    required this.issues,
    required this.selected,
    required this.enabled,
    required this.onToggle,
    required this.onOpen,
  });

  final HealthIssueKind kind;
  final List<HealthIssue> issues;
  final Set<String> selected;
  final bool enabled;
  final void Function(HealthIssue issue, bool selected) onToggle;
  final ValueChanged<HealthIssue> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isError = kind.severity == HealthSeverity.error;
    return NahpuPanel(
      padding: EdgeInsets.zero,
      borderColor: isError ? colors.error : null,
      child: ExpansionTile(
        initiallyExpanded: issues.length <= 10,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(
          isError ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
          color: isError ? colors.error : colors.tertiary,
        ),
        title: Text('${kind.title(l10n)} (${issues.length})'),
        subtitle: Text(kind.help(l10n)),
        childrenPadding: const EdgeInsets.only(bottom: NahpuSpacing.md),
        children: [
          for (final issue in issues)
            _HealthIssueTile(
              issue: issue,
              isSelected: selected.contains(issue.id),
              enabled: enabled,
              onToggle: (value) => onToggle(issue, value),
              onOpen: () => onOpen(issue),
            ),
        ],
      ),
    );
  }
}

class _HealthIssueTile extends StatelessWidget {
  const _HealthIssueTile({
    required this.issue,
    required this.isSelected,
    required this.enabled,
    required this.onToggle,
    required this.onOpen,
  });

  final HealthIssue issue;
  final bool isSelected;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final description = issue.description(l10n);
    final canFix = issue.fix != null;
    final title = issue.kind == HealthIssueKind.databaseIntegrity
        ? description ?? ''
        : issue.table.isEmpty
        ? issue.recordLabel
        : '${issue.recordLabel} · ${databaseTableLabel(l10n, issue.table)}';
    return ListTile(
      leading: Checkbox(
        value: canFix && isSelected,
        onChanged: canFix && enabled ? (value) => onToggle(value!) : null,
      ),
      title: Text(title),
      subtitle: Text(
        [
          if (description != null &&
              issue.kind != HealthIssueKind.databaseIntegrity)
            description,
          issue.fix.label(l10n),
        ].join(' · '),
        style: theme.textTheme.bodySmall,
      ),
      trailing: issue.target == null
          ? null
          : IconButton(
              tooltip: l10n.healthOpenRecords,
              icon: const Icon(Icons.open_in_new_rounded),
              onPressed: enabled ? onOpen : null,
            ),
    );
  }
}

/// Confirms the fixes. Pops with whether to take a safety backup first, or
/// null when cancelled.
class _ApplyFixesDialog extends StatefulWidget {
  const _ApplyFixesDialog({required this.count});

  final int count;

  @override
  State<_ApplyFixesDialog> createState() => _ApplyFixesDialogState();
}

class _ApplyFixesDialogState extends State<_ApplyFixesDialog> {
  bool _backup = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.healthConfirmTitle(widget.count)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: NahpuContentWidth.dialog),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.healthConfirmBody),
            const SizedBox(height: NahpuSpacing.lg),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _backup,
              title: Text(l10n.healthBackupFirst),
              subtitle: Text(l10n.healthBackupFirstSubtitle),
              onChanged: (value) => setState(() => _backup = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_backup),
          child: Text(l10n.healthApplyFixes),
        ),
      ],
    );
  }
}
