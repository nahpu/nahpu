import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/taxonomy_queries.dart';
import 'package:nahpu/services/projects/taxonomy_services.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/record_exchange/taxon_exchange_service.dart';
import 'package:nahpu/screens/shared/dialogs/qr_code_dialog.dart';
import 'package:nahpu/screens/shared/media/qr.dart';
import 'package:nahpu/styles/design_tokens.dart';

class TaxonManagementDetails extends StatelessWidget {
  const TaxonManagementDetails({
    super.key,
    required this.taxon,
    required this.onEdit,
  });

  final TaxonomyData taxon;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('taxon-management-details'),
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(NahpuSpacing.xxl),
            child: Column(
              children: [
                TaxonInfoTitle(
                  displayName: getTaxonDisplayName(taxon),
                  authors: taxon.authors,
                  commonName: taxon.commonName,
                ),
                Expanded(child: TaxonDetailsView(taxonData: taxon)),
              ],
            ),
          ),
        ),
        const Divider(height: NahpuStroke.thin),
        Padding(
          padding: const EdgeInsets.all(NahpuSpacing.xl),
          child: Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              label: 'Edit taxon',
              icon: Icons.edit_outlined,
              onPressed: onEdit,
            ),
          ),
        ),
      ],
    );
  }
}

class TaxonInfoTitle extends StatelessWidget {
  const TaxonInfoTitle({
    super.key,
    required this.displayName,
    required this.authors,
    required this.commonName,
  });

  final String displayName;
  final String? authors;
  final String? commonName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            fontFamily: 'Merriweather',
          ),
        ),
        if (_hasValue(authors))
          Text(authors!, style: Theme.of(context).textTheme.titleMedium),
        if (_hasValue(commonName))
          Text(
            commonName!.toCommonName(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        Divider(
          color: Theme.of(context).colorScheme.outlineVariant,
          thickness: NahpuStroke.thin,
        ),
      ],
    );
  }
}

class TaxonDetailsView extends ConsumerWidget {
  const TaxonDetailsView({super.key, required this.taxonData});

  final TaxonomyData taxonData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final species = _scientificName([
      taxonData.genus,
      taxonData.specificEpithet,
    ]);
    final subspecies = _scientificName([
      taxonData.genus,
      taxonData.specificEpithet,
      taxonData.subspecificEpithet,
    ]);
    final recordCounts = ref.watch(taxonRecordCountsProvider(taxonData.id));
    final useHorizontalQr =
        MediaQuery.sizeOf(context).width >= NahpuBreakpoints.compact;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (useHorizontalQr)
            Row(
              key: const ValueKey('taxon-classification-qr-row'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ClassificationSection(
                    taxonData: taxonData,
                    species: species,
                    subspecies: subspecies,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: NahpuSpacing.lg),
                  child: TaxonQrIcon(taxon: taxonData),
                ),
              ],
            )
          else ...[
            Center(child: TaxonQrIcon(taxon: taxonData)),
            _ClassificationSection(
              taxonData: taxonData,
              species: species,
              subspecies: subspecies,
            ),
          ],
          _ConservationSection(taxonData: taxonData),
          TaxonDetailRow(
            label: 'Notes',
            isStacked: true,
            value: taxonData.notes,
          ),
          _TotalRecordsSection(recordCounts: recordCounts),
        ],
      ),
    );
  }
}

class _ClassificationSection extends StatelessWidget {
  const _ClassificationSection({
    required this.taxonData,
    required this.species,
    required this.subspecies,
  });

  final TaxonomyData taxonData;
  final String species;
  final String subspecies;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('taxon-classification-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Classification', style: Theme.of(context).textTheme.titleMedium),
        TaxonDetailRow(
          label: 'Rank',
          value: taxonRankFromString(taxonData.taxonRank)?.label,
        ),
        TaxonDetailRow(
          label: 'Kingdom',
          value: taxonData.kingdom ?? getKingdom(taxonData.taxonClass),
        ),
        TaxonDetailRow(
          label: 'Phylum',
          value: taxonData.phylum ?? getPhylum(taxonData.taxonClass),
        ),
        TaxonDetailRow(label: 'Class', value: taxonData.taxonClass),
        TaxonDetailRow(label: 'Order', value: taxonData.taxonOrder),
        TaxonDetailRow(label: 'Family', value: taxonData.taxonFamily),
        TaxonDetailRow(label: 'Genus', value: taxonData.genus, isItalic: true),
        if (_hasValue(taxonData.specificEpithet))
          TaxonDetailRow(label: 'Species', value: species, isItalic: true),
        if (_hasValue(taxonData.subspecificEpithet))
          TaxonDetailRow(
            label: 'Subspecies',
            value: subspecies,
            isItalic: true,
          ),
        TaxonDetailRow(label: 'Authors', value: taxonData.authors),
      ],
    );
  }
}

class _ConservationSection extends StatelessWidget {
  const _ConservationSection({required this.taxonData});

  final TaxonomyData taxonData;

  @override
  Widget build(BuildContext context) {
    if (!_hasValue(taxonData.redListCategory) &&
        !_hasValue(taxonData.citesStatus) &&
        !_hasValue(taxonData.countryStatus)) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: NahpuSpacing.md),
        Text('Conservation', style: Theme.of(context).textTheme.titleMedium),
        if (_hasValue(taxonData.redListCategory))
          TaxonDetailRow(
            label: 'Red List category',
            isStacked: true,
            customValue: RedListCategoryPill(
              category: taxonData.redListCategory!,
            ),
          ),
        TaxonDetailRow(label: 'CITES status', value: taxonData.citesStatus),
        TaxonDetailRow(
          label: 'Country status',
          isStacked: true,
          value: taxonData.countryStatus,
        ),
      ],
    );
  }
}

class _TotalRecordsSection extends StatelessWidget {
  const _TotalRecordsSection({required this.recordCounts});

  final AsyncValue<TaxonRecordCounts> recordCounts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: NahpuSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          Text('Total records', style: Theme.of(context).textTheme.titleMedium),
          recordCounts.when(
            data: (counts) => Column(
              children: [
                TaxonDetailRow(
                  key: const ValueKey('taxon-records-active'),
                  label: 'Current project',
                  value: counts.activeProject?.toString() ?? '—',
                ),
                TaxonDetailRow(
                  key: const ValueKey('taxon-records-all'),
                  label: 'All projects',
                  value: counts.allProjects.toString(),
                ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: NahpuSpacing.md),
              child: LinearProgressIndicator(),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.md),
              child: Text('Unable to load record totals: $error'),
            ),
          ),
        ],
      ),
    );
  }
}

class TaxonQrIcon extends StatelessWidget {
  const TaxonQrIcon({super.key, required this.taxon});

  final TaxonomyData taxon;

  @override
  Widget build(BuildContext context) {
    final data = TaxonExchangeService.encodeQr(taxon);
    return Tooltip(
      message: 'Taxon QR code. Tap to view full.',
      child: GestureDetector(
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => QrCodeDialog(
            title: 'Taxon QR code',
            data: data,
            description: 'Scan this code in NAHPU to import this taxon.',
          ),
        ),
        child: SizedBox(
          width: 96,
          height: 96,
          child: QrCodeViewer(data: data, maxSize: 96),
        ),
      ),
    );
  }
}

class RedListCategoryPill extends StatelessWidget {
  const RedListCategoryPill({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = matchRedListCategoryColor(category);
    final textColor = backgroundColor.computeLuminance() > 0.3
        ? Colors.black
        : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NahpuSpacing.md,
        vertical: NahpuSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(NahpuRadius.xl),
      ),
      child: Text(
        category,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TaxonDetailRow extends StatelessWidget {
  const TaxonDetailRow({
    super.key,
    required this.label,
    this.value,
    this.customValue,
    this.isItalic = false,
    this.isStacked = false,
  });

  final String label;
  final String? value;
  final Widget? customValue;
  final bool isItalic;
  final bool isStacked;

  @override
  Widget build(BuildContext context) {
    if (!_hasValue(value) && customValue == null) {
      return const SizedBox.shrink();
    }
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontStyle: isItalic ? FontStyle.italic : null,
    );
    if (isStacked) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: NahpuSpacing.xs),
            customValue ?? Text(value!, style: textStyle),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: Theme.of(context).textTheme.titleSmall),
          ),
          Expanded(child: customValue ?? Text(value!, style: textStyle)),
        ],
      ),
    );
  }
}

bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

String _scientificName(List<String?> parts) {
  return parts
      .whereType<String>()
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .join(' ');
}
