import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/taxonomy/specimen_list.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/specimens/specimen_view.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/validation/models.dart';
import 'package:nahpu/services/validation/specimen_validation_services.dart';

class ValidationResultsView extends ConsumerStatefulWidget {
  const ValidationResultsView({
    super.key,
    required this.results,
    required this.taxonIds,
    required this.detectOutliers,
    required this.findMissingFields,
  });

  final List<ValidationResult> results;
  final List<int> taxonIds;
  final bool detectOutliers;
  final bool findMissingFields;

  @override
  ValidationResultsViewState createState() => ValidationResultsViewState();
}

class ValidationResultsViewState extends ConsumerState<ValidationResultsView> {
  late List<ValidationResult> _results;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _results = widget.results;
  }

  Future<void> _refreshValidation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final newResults =
          await SpecimenValidationServices(ref: ref).runValidation(
        widget.taxonIds,
        detectOutliers: widget.detectOutliers,
        findMissingFields: widget.findMissingFields,
      );

      if (mounted) {
        setState(() {
          _results = newResults;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation Results'),
      ),
      body: _isLoading
          ? const CommonProgressIndicator()
          : _results.isEmpty
              ? const Center(
                  child: Text('No issues found!'),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final data = _results[index].specimen;
                      final issues = _results[index].issues;
                      return ListTile(
                        leading: Icon(_getLeadingIcon(data.taxonGroup)),
                        title: SpecimenListTitle(
                          catalogerID: data.catalogerID,
                          fieldNumber: data.fieldNumber,
                          speciesID: data.speciesID,
                        ),
                        subtitle: SpecimenListSubtitle(
                          data: data,
                          issues: issues,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SpecimenFormView(
                                      specimenUuid: data.uuid,
                                    )),
                          );
                          _refreshValidation();
                        },
                      );
                    },
                  ),
                ),
    );
  }

  IconData _getLeadingIcon(String? taxonGroup) {
    CatalogFmt fmt = matchTaxonGroupToCatFmt(taxonGroup);
    return matchCatFmtToIcon(fmt, false);
  }
}