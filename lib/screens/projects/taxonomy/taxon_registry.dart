import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/taxonomy/add_taxon.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_list.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/taxon_entry.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/styles/design_tokens.dart';

class TaxonRegistryViewer extends ConsumerStatefulWidget {
  const TaxonRegistryViewer({super.key});

  @override
  TaxonRegistryViewerState createState() => TaxonRegistryViewerState();
}

class TaxonRegistryViewerState extends ConsumerState<TaxonRegistryViewer> {
  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Taxon Registry',
      infoTopic: InfoTopic.taxonRegistry,
      mainAxisAlignment: MainAxisAlignment.start,
      child: DashboardPanelBody(
        content: const RegistryInfo(),
        actions: Wrap(
          key: const ValueKey('taxon-registry-actions'),
          spacing: 8,
          children: [
            SecondaryButton(
              text: 'Manage',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ManageTaxa()),
                );
              },
            ),
            PrimaryButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddTaxon()),
                );
                if (!context.mounted || result is! TaxonImportResult) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Imported ${result.importedTaxaCount} taxa across '
                      '${result.importedFamilyCount} families.',
                    ),
                  ),
                );
              },
              label: 'Add taxon',
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}

class RegistryInfo extends ConsumerWidget {
  const RegistryInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(taxonRegistryProvider)
        .when(
          data: (data) => data.isEmpty
              ? const EmptyTaxa()
              : RegisteredTaxa(taxonData: data),
          loading: () => const CommonProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        );
  }
}

class EmptyTaxa extends StatelessWidget {
  const EmptyTaxa({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No taxon found.\nAdd/import taxa to start recording captures.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class RegisteredTaxa extends StatelessWidget {
  const RegisteredTaxa({super.key, required this.taxonData});

  final List<TaxonomyData> taxonData;

  @override
  Widget build(BuildContext context) {
    final metrics = _metrics(taxonData);
    return TaxonDataContainer(
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final useTwoColumns = constraints.maxWidth >= 320;
              final hasTotalTaxa = metrics.any(
                (metric) => metric.key == 'taxa',
              );
              final spacing = NahpuSpacing.lg;
              final width = useTwoColumns
                  ? (constraints.maxWidth - spacing) / 2
                  : constraints.maxWidth;
              final height = useTwoColumns ? 104.0 : 64.0;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final metric in metrics)
                    SizedBox(
                      key: ValueKey('registry-stat-${metric.key}'),
                      width: !hasTotalTaxa && metric.key == 'species'
                          ? constraints.maxWidth
                          : width,
                      height: height,
                      child: _RegistryMetric(
                        metric: metric,
                        compact: !useTwoColumns,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<_RegistryMetricData> _metrics(List<TaxonomyData> data) {
    final species = <String>{};
    final families = <String>{};
    final orders = <String>{};
    for (final taxon in data) {
      _addNormalized(families, taxon.taxonFamily);
      _addNormalized(orders, taxon.taxonOrder);
      final speciesName = [taxon.genus, taxon.specificEpithet]
          .whereType<String>()
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .join(' ')
          .toLowerCase();
      if (speciesName.isNotEmpty &&
          taxon.genus?.trim().isNotEmpty == true &&
          taxon.specificEpithet?.trim().isNotEmpty == true) {
        species.add(speciesName);
      }
    }
    final metrics = [
      _RegistryMetricData(key: 'orders', label: 'orders', value: orders.length),
      _RegistryMetricData(
        key: 'families',
        label: 'families',
        value: families.length,
      ),
      _RegistryMetricData(
        key: 'species',
        label: 'species registered',
        value: species.length,
      ),
    ];
    if (data.length > species.length) {
      metrics.add(
        _RegistryMetricData(key: 'taxa', label: 'taxa', value: data.length),
      );
    }
    return metrics;
  }

  void _addNormalized(Set<String> values, String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized?.isNotEmpty == true) values.add(normalized!);
  }
}

class _RegistryMetricData {
  const _RegistryMetricData({
    required this.key,
    required this.label,
    required this.value,
  });

  final String key;
  final String label;
  final int value;
}

class _RegistryMetric extends StatelessWidget {
  const _RegistryMetric({required this.metric, required this.compact});

  final _RegistryMetricData metric;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = colorScheme.onSecondaryContainer;
    final backgroundColor = colorScheme.secondaryContainer.withValues(
      alpha: 0.16,
    );
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(
        compact ? NahpuSpacing.md : NahpuSpacing.lg,
        compact ? NahpuSpacing.lg : NahpuSpacing.xl,
        compact ? NahpuSpacing.md : NahpuSpacing.lg,
        compact ? NahpuSpacing.xs : NahpuSpacing.md,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(NahpuRadius.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              '${metric.value}',
              textAlign: TextAlign.center,
              style:
                  (compact
                          ? Theme.of(context).textTheme.titleMedium
                          : Theme.of(context).textTheme.headlineSmall)
                      ?.copyWith(color: foregroundColor),
            ),
          ),
          SizedBox(height: compact ? NahpuSpacing.xxs : NahpuSpacing.xs),
          Text(
            metric.label,
            textAlign: TextAlign.center,
            style:
                (compact
                        ? Theme.of(context).textTheme.bodySmall
                        : Theme.of(context).textTheme.titleSmall)
                    ?.copyWith(color: foregroundColor),
          ),
        ],
      ),
    );
  }
}

class TaxonDataContainer extends StatelessWidget {
  const TaxonDataContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }
}
