import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/collection_records.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/narrative.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/screens/projects/taxonomy/import_taxa.dart';
import 'package:nahpu/screens/projects/taxonomy/new_taxa.dart';
import 'package:nahpu/screens/projects/taxonomy/taxon_list.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/database/database.dart';

class TaxonRegistryViewer extends ConsumerStatefulWidget {
  const TaxonRegistryViewer({
    super.key,
  });

  @override
  TaxonRegistryViewerState createState() => TaxonRegistryViewerState();
}

class TaxonRegistryViewerState extends ConsumerState<TaxonRegistryViewer> {
  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Project Registry',
      infoContent: const TaxonRegistryInfoContent(),
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
            const SizedBox(height: 25),
            Wrap(
              spacing: 8,
              children: [
                SecondaryButton(
                    text: 'Import from file',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TaxonImportForm(),
                        ),
                      );
                    }),
                PrimaryButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NewTaxon(),
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
  const RegistryInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(taxonRegistryProvider).when(
          data: (data) {
            return data.isEmpty
                ? const EmptyTaxa()
                : TaxonRegistryLayout(
                    children: [
                      RegisteredTaxa(taxonData: data),
                      const RecordedTaxa(),
                    ],
                  );
          },
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
        'No taxon found.\n'
        'Add/import taxa to start recording captures.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class RegisteredTaxa extends StatelessWidget {
  const RegisteredTaxa({
    super.key,
    required this.taxonData,
  });

  final List<TaxonomyData> taxonData;

  @override
  Widget build(BuildContext context) {
    return TaxonDataContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const TaxonStatText(
            text: 'Registered',
          ),
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
                      text: ' species\n',
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
              )),
          taxonData.isEmpty
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TaxonRegistryPage(),
                      ),
                    );
                  },
                  child: const Text('View all'),
                )
        ],
      ),
    );
  }

  int _countFamily(List<TaxonomyData> data) {
    return data.fold(<String, int>{}, (Map<String, int> map, e) {
      if (e.taxonFamily != null) {
        map[e.taxonFamily!] = (map[e.taxonFamily!] ?? 0) + 1;
      }
      return map;
    }).length;
  }
}

class RecordedTaxa extends StatelessWidget {
  const RecordedTaxa({super.key});

  @override
  Widget build(BuildContext context) {
    return TaxonDataContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const TaxonStatText(
            text: 'Collection Records',
          ),
          const Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: CollectionRecordCounts(),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CollectionRecordsPage(),
                ),
              );
            },
            child: const Text('View all'),
          ),
        ],
      ),
    );
  }
}

/// Counts of each collection record type, shown in the Collection Records
/// container. Reads the entry providers directly so the numbers update when
/// records are added or removed.
class CollectionRecordCounts extends ConsumerWidget {
  const CollectionRecordCounts({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sites = ref.watch(siteEntryProvider).value?.length;
    final events = ref.watch(collEventEntryProvider).value?.length;
    final specimens = ref.watch(specimenEntryProvider).value?.length;
    final narrative = ref.watch(narrativeEntryProvider).value?.length;

    if (sites == null ||
        events == null ||
        specimens == null ||
        narrative == null) {
      return const CommonProgressIndicator();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: RichText(
        text: TextSpan(
          children: [
            _countSpan(context, sites, ' sites\n'),
            _countSpan(context, events, ' events\n'),
            _countSpan(context, specimens, ' specimens\n'),
            _countSpan(context, narrative, ' narrative'),
          ],
        ),
      ),
    );
  }

  TextSpan _countSpan(BuildContext context, int count, String label) {
    return TextSpan(
      children: [
        TextSpan(
          text: '$count',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        TextSpan(
          text: label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class TaxonDataContainer extends StatelessWidget {
  const TaxonDataContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          height: 220,
          width: 200,
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withAlpha(50),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(
              20,
            ),
          ),
          child: child,
        ));
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
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class TaxonRegistryInfoContent extends StatelessWidget {
  const TaxonRegistryInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          header: 'Overview',
          content: 'List of taxa registered in the project.'
              ' You can add new taxa or import taxa from a file.',
        ),
        InfoContent(
          content: 'For file input, preferred formats are .xlsx, .csv, and '
              '.tsv. Delimiter follows extension (.csv = comma, .tsv = tab). '
              'For other file types, NAHPU makes a best-effort parsing '
              'attempt using auto detection and manual override options. '
              'Best support is for .xlsx.',
        ),
        InfoContent(
          header: 'Term definitions',
          content: 'Registered taxa - The number of taxa that are registered '
              'in the project. '
              '\nCollection Records - Counts of sites, events, specimens, and '
              'narrative recorded in the project. They update as you add or '
              'remove records.',
        ),
      ],
    );
  }
}
