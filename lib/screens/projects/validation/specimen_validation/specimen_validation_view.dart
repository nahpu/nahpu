import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/taxonomy/specimen_list.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/screens/specimens/specimen_view.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/database/taxonomy_queries.dart';
import 'package:nahpu/services/taxonomy_services.dart';
import 'package:nahpu/services/providers/data_validation.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/validation/mandatory_fields.dart';
import 'package:nahpu/services/validation/models.dart';

final speciesListProvider =
    FutureProvider.autoDispose<List<TaxonomyData>>((ref) async {
  final projectUuid = ref.read(projectUuidProvider);
  final taxa = TaxonomyQuery(ref.read(databaseProvider))
      .getAllTaxaWithSpecimenData(projectUuid);
  return taxa;
});

class SpecimenValidationView extends ConsumerStatefulWidget {
  const SpecimenValidationView({super.key});

  @override
  SpecimenValidationViewState createState() => SpecimenValidationViewState();
}

class SpecimenValidationViewState
    extends ConsumerState<SpecimenValidationView> {
  final ScrollController _speciesScrollController = ScrollController();

  @override
  void dispose() {
    _speciesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncValidationState = ref.watch(dataValidationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Specimen Validation'),
      ),
      body: asyncValidationState.when(
        loading: () => const CommonProgressIndicator(),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (validationState) {
          final notifier = ref.read(dataValidationProvider.notifier);
          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: Column(
                            children: [
                              // Options Section
                              CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title:
                                    const Text('Detect statistical outliers'),
                                value: validationState.detectOutliers,
                                onChanged: (value) =>
                                    notifier.setDetectOutliers(value ?? false),
                              ),
                              CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: const Text(
                                    'Find missing mandatory fields'),
                                value: validationState.findMissingFields,
                                onChanged: (value) => notifier
                                    .setFindMissingFields(value ?? false),
                              ),
                              const Divider(),
                              // Species Selection
                              _buildSpeciesSelection(ref, validationState),
                              const Divider(),
                              // Field Selection
                              _buildFieldSelection(notifier, validationState),
                              const Divider(),
                              // Sort Options
                              _buildSortSelection(notifier, validationState),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Results List
                    if (validationState.results != null)
                      _buildResultsList(validationState.results!),

                    // Add some bottom padding so the last item isn't hidden by the footer
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
                    ),
                  ],
                ),
              ),
              // Fixed Action Footer
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ProgressButton(
                        label: validationState.results == null
                            ? 'Run Validation'
                            : 'Re-run',
                        icon: Icons.analytics_outlined,
                        isRunning: validationState.isLoading,
                        onPressed: _isValidToRun(validationState)
                            ? () => notifier.validate()
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isValidToRun(DataValidationState state) {
    if (state.selectedSpecies.isEmpty) return false;
    if (state.selectedFields.isEmpty) return false;
    if (!state.detectOutliers && !state.findMissingFields) return false;
    return true;
  }

  Widget _buildSortSelection(
      DataValidationNotifier notifier, DataValidationState state) {
    return ExpansionTile(
      title: const Text('Sort By'),
      subtitle: Text(_getSortLabel(state.sortOption)),
      children: [
        RadioListTile<ValidationSort>(
          title: const Text('Species'),
          value: ValidationSort.species,
          groupValue: state.sortOption,
          onChanged: (value) {
            if (value != null) notifier.setSortOption(value);
          },
        ),
        RadioListTile<ValidationSort>(
          title: const Text('Field Number'),
          value: ValidationSort.fieldNumber,
          groupValue: state.sortOption,
          onChanged: (value) {
            if (value != null) notifier.setSortOption(value);
          },
        ),
        RadioListTile<ValidationSort>(
          title: const Text('Page Number'),
          value: ValidationSort.pageNumber,
          groupValue: state.sortOption,
          onChanged: (value) {
            if (value != null) notifier.setSortOption(value);
          },
        ),
      ],
    );
  }

  String _getSortLabel(ValidationSort option) {
    switch (option) {
      case ValidationSort.species:
        return 'Species';
      case ValidationSort.fieldNumber:
        return 'Field Number';
      case ValidationSort.pageNumber:
        return 'Page Number';
    }
  }

  Widget _buildSpeciesSelection(
      WidgetRef ref, DataValidationState validationState) {
    final notifier = ref.read(dataValidationProvider.notifier);
    return ref.watch(speciesListProvider).when(
          data: (data) {
            if (data.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No species with enough data (min. 3 specimens).'),
              );
            }

            final isAllSelected =
                validationState.selectedSpecies.length == data.length;

            return ExpansionTile(
              title: const Text('Select Species'),
              subtitle: Text(
                  '${validationState.selectedSpecies.length} of ${data.length} selected'),
              leading: Checkbox(
                value: isAllSelected,
                onChanged: (_) {
                  if (isAllSelected) {
                    notifier.setSpeciesSelection([]);
                  } else {
                    notifier
                        .setSpeciesSelection(data.map((e) => e.id).toList());
                  }
                },
              ),
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: CommonScrollbar(
                    scrollController: _speciesScrollController,
                    child: ListView.builder(
                      controller: _speciesScrollController,
                      shrinkWrap: true,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(getSpeciesName(data[index])),
                          value: validationState.selectedSpecies
                              .contains(data[index].id),
                          onChanged: (bool? value) {
                            List<int> current =
                                List.from(validationState.selectedSpecies);
                            if (value == true) {
                              current.add(data[index].id);
                            } else {
                              current.remove(data[index].id);
                            }
                            notifier.setSpeciesSelection(current);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const CommonProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        );
  }

  Widget _buildFieldSelection(
      DataValidationNotifier notifier, DataValidationState state) {
    final groupedFields = MandatoryFieldService.groupedFields;
    final allValidFields = MandatoryFieldService.allSpecimenFields.toSet();
    final selectedCount =
        state.selectedFields.intersection(allValidFields).length;
    final isAllSelected = selectedCount == allValidFields.length;

    return ExpansionTile(
      title: const Text('Select Fields'),
      subtitle: Text('$selectedCount fields selected'),
      leading: Checkbox(
        value: isAllSelected,
        onChanged: (value) => notifier.toggleFieldGroup(
            allValidFields.toList(), value ?? false),
      ),
      children: groupedFields.keys.map((group) {
        final fields = groupedFields[group]!;
        final allSelected =
            fields.every((f) => state.selectedFields.contains(f));

        return ExpansionTile(
          title: Text(group),
          leading: Checkbox(
            value: allSelected,
            onChanged: (value) =>
                notifier.toggleFieldGroup(fields, value ?? false),
          ),
          children: fields.map((field) {
            final label = MandatoryFieldService.fieldLabels[field] ?? field;
            return CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(label),
              value: state.selectedFields.contains(field),
              onChanged: (_) => notifier.toggleField(field),
              contentPadding: const EdgeInsets.only(left: 32, right: 16),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildResultsList(List<ValidationResult> results) {
    if (results.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No issues found! 🎉')),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final result = results[index];
          final data = result.specimen;
          return ListTile(
            leading: Icon(_getLeadingIcon(data.taxonGroup)),
            title: SpecimenListTitle(
              catalogerID: data.catalogerID,
              fieldNumber: data.fieldNumber,
              speciesID: data.speciesID,
            ),
            subtitle: SpecimenListSubtitle(
              data: data,
              issues: result.issues,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SpecimenFormView(
                          specimenUuid: data.uuid,
                        )),
              );
            },
          );
        },
        childCount: results.length,
      ),
    );
  }

  IconData _getLeadingIcon(String? taxonGroup) {
    CatalogFmt fmt = matchTaxonGroupToCatFmt(taxonGroup);
    return matchCatFmtToIcon(fmt, false);
  }
}