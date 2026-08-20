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
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(maxWidth: 460, maxHeight: 250),
              padding: const EdgeInsets.all(8),
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
    return TaxonDataContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const TaxonStatText(text: 'Registered'),
          FittedBox(
            fit: BoxFit.fill,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${taxonData.length}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextSpan(
                    text: ' taxa\n',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextSpan(
                    text: '${_countFamily(taxonData)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextSpan(
                    text: ' families',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _countFamily(List<TaxonomyData> data) {
    return data.fold(<String, int>{}, (Map<String, int> map, taxon) {
      final family = taxon.taxonFamily?.trim();
      if (family?.isNotEmpty == true) {
        map[family!] = (map[family] ?? 0) + 1;
      }
      return map;
    }).length;
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
        height: 220,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor.withAlpha(50),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: child,
      ),
    );
  }
}

class TaxonStatText extends StatelessWidget {
  const TaxonStatText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(left: 16),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
