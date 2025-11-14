import 'package:flutter/material.dart';
import 'package:nahpu/screens/projects/taxonomy/specimen_list.dart';
import 'package:nahpu/services/validation/models.dart';

class ValidationResultsView extends StatelessWidget {
  const ValidationResultsView({super.key, required this.results});

  final List<ValidationResult> results;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation Results'),
      ),
      body: results.isEmpty
          ? const Center(
              child: Text('No issues found!'),
            )
          : SpecimenList(
              data: results.map((e) => e.specimen).toList(),
              validationResults: results,
              additionalHeight:
                  0, // No search options here, so no extra height needed.
            ),
    );
  }
}