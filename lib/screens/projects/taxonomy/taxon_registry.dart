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
      mainAxisAlignment: MainAxisAlignment.center,
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(
                maxWidth: NahpuContentWidth.form,
              ),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: const RegistryInfo(),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              children: [
                SecondaryButton(
                  text: 'Manage',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ManageTaxa(),
                      ),
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
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: NahpuSpacing.md),
                Text(
                  'Registered',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: NahpuSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = metrics.length >= 4
                    ? 2
                    : constraints.maxWidth >= 360
                    ? metrics.length
                    : 2;
                final spacing = NahpuSpacing.md * (columns - 1);
                final width = (constraints.maxWidth - spacing) / columns;
                return Wrap(
                  spacing: NahpuSpacing.md,
                  runSpacing: NahpuSpacing.md,
                  children: [
                    for (final metric in metrics)
                      SizedBox(
                        key: ValueKey('registry-stat-${metric.label}'),
                        width: width,
                        child: _RegistryMetric(metric: metric),
                      ),
                  ],
                );
              },
            ),
          ],
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
      _RegistryMetricData(label: 'orders', value: orders.length),
      _RegistryMetricData(label: 'families', value: families.length),
      _RegistryMetricData(label: 'species', value: species.length),
    ];
    if (data.length > species.length) {
      metrics.add(_RegistryMetricData(label: 'taxa', value: data.length));
    }
    return metrics;
  }

  void _addNormalized(Set<String> values, String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized?.isNotEmpty == true) values.add(normalized!);
  }
}

class _RegistryMetricData {
  const _RegistryMetricData({required this.label, required this.value});

  final String label;
  final int value;
}

class _RegistryMetric extends StatelessWidget {
  const _RegistryMetric({required this.metric});

  final _RegistryMetricData metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.symmetric(
        horizontal: NahpuSpacing.lg,
        vertical: NahpuSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(NahpuRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${metric.value}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(metric.label, style: Theme.of(context).textTheme.labelLarge),
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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: child,
      ),
    );
  }
}
