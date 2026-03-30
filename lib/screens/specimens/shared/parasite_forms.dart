import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/services/types/specimens.dart';

class ParasiteForms extends StatelessWidget {
  const ParasiteForms(
      {super.key, required this.specimenUuid, required this.catalogFmt});

  final String specimenUuid;
  final CatalogFmt catalogFmt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TitleForm(
          text: 'Parasite records',
          infoContent: ParasiteRecordInfoContent(),
        ),
        SizedBox(
          height: 450,
          child: Text(
            'Specimen UUID: $specimenUuid\n'
            'Catalog Format: ${matchCatFmtToTaxonGroup(catalogFmt)}\n\n'
            'This is where the parasite records form will be.',
          ),
        )
      ],
    );
  }
}

class ParasiteRecordInfoContent extends StatelessWidget {
  const ParasiteRecordInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(content: [
      InfoContent(
        header: 'Overview',
        content: 'This section is for recording parasite data associated with'
            ' the specimen. The form will allow you to input details about'
            ' any parasites found on or within the specimen, including type,'
            ' location, and any relevant measurements.',
      ),
    ]);
  }
}
