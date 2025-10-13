import 'package:flutter/material.dart';
import 'package:nahpu/screens/projects/taxonomy/specimen_list.dart';
import 'package:nahpu/services/database/database.dart';

class OutlierResultsView extends StatelessWidget {
  const OutlierResultsView({super.key, required this.outlierSpecimens});

  final List<SpecimenData> outlierSpecimens;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outlier Results'),
      ),
      body: outlierSpecimens.isEmpty
          ? const Center(
              child: Text('No outliers found!'),
            )
          : SpecimenList(
              data: outlierSpecimens,
              additionalHeight:
                  0, // No search options here, so no extra height needed.
            ),
    );
  }
}