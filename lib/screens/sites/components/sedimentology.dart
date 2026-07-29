import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';

/// Top-level depositional environment categories.
const List<String> _depositionalEnvironmentTypes = [
  'Continental',
  'Marine',
  'Mixed',
  'Unknown',
  'Not Applicable',
];

/// Conditional sub-environments shown when the type is "Continental".
const List<String> _continentalSubEnvironments = [
  'Aeolian',
  'Alluvial',
  'Colluvial (landslide, etc)',
  'Deltaic',
  'Estuarine',
  'Evaporitic',
  'Fluvial',
  'Glacial',
  'Lacustrine',
  'Peat Swamp',
  'Coal Mire',
  'Tidal',
  'Volcaniclastic',
  'Other',
  'Varied',
  'Unknown',
  'Not Applicable',
];

/// Conditional sub-environments shown when the type is "Marine".
const List<String> _marineSubEnvironments = [
  'Shallow-Marine',
  'Carbonate',
  'Continental Margin',
  'Deep-Marine / Pelagic',
  'Other',
  'Varied',
  'Unknown',
  'Not Applicable',
];

const List<String> _preservationTypes = [
  'Amber',
  'Carbonization',
  'Concretion',
  'Desiccation',
  'Fluvial Accumulation',
  'Mummification',
  'Phosphatization',
  'Pyritization',
  'Rapid Burial',
  'Silicification',
  'Tar Pit',
  'Tidal Accumulation',
  'Varied',
  'Other',
  'Unknown',
  'Not Applicable',
];

class Sedimentology extends ConsumerStatefulWidget {
  const Sedimentology(
      {super.key,
      required this.id,
      required this.useHorizontalLayout,
      required this.siteFormCtr});

  final int id;
  final bool useHorizontalLayout;
  final SiteFormCtrModel siteFormCtr;

  @override
  SedimentologyState createState() => SedimentologyState();
}

class SedimentologyState extends ConsumerState<Sedimentology> {
  // Local, UI-only state. Not yet persisted to the database.
  final TextEditingController _rockTypeCtr = TextEditingController();
  final TextEditingController _commentsCtr = TextEditingController();
  String? _depositionalEnvironmentType;
  String? _depositionalSubEnvironment;

  /// Returns the sub-environment options that correspond to the currently
  /// selected depositional environment type.
  List<String> get _subEnvironmentOptions {
    switch (_depositionalEnvironmentType) {
      case 'Continental':
        return _continentalSubEnvironments;
      case 'Marine':
        return _marineSubEnvironments;
      default:
        return const [];
    }
  }

  bool get _isSubEnvironmentEnabled => _subEnvironmentOptions.isNotEmpty;

  @override
  void dispose() {
    _rockTypeCtr.dispose();
    _commentsCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(6),
      child: _buildFields(),
    );

    return FormCard(
      title: 'Sedimentology',
      infoContent: const SedimentologyInfoContent(),
      mainAxisAlignment: MainAxisAlignment.start,
      // In the horizontal layout the card is height-capped, so its content
      // must scroll within an Expanded region. In the vertical layout the
      // whole form already scrolls, so keep the content unconstrained.
      isExpanded: widget.useHorizontalLayout,
      child: widget.useHorizontalLayout
          ? SingleChildScrollView(child: content)
          : content,
    );
  }

  Widget _buildFields() {
    return Column(
      children: [
        TextFormField(
              controller: _rockTypeCtr,
              decoration: const InputDecoration(
                labelText: 'Rock Type(s)',
                hintText: 'E.g. "Sandstone", "Mudstone", "Limestone"',
              ),
            ),
            DropdownButtonFormField<String?>(
              isExpanded: true,
              initialValue: _depositionalEnvironmentType,
              decoration: const InputDecoration(
                labelText: 'Depositional Environment Type',
                hintText: 'Select a depositional environment type',
              ),
              items: _depositionalEnvironmentTypes
                  .map(
                    (e) => DropdownMenuItem<String?>(
                      value: e,
                      child: CommonDropdownText(text: e),
                    ),
                  )
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _depositionalEnvironmentType = newValue;
                  // Reset the dependent sub-environment when the parent
                  // category changes.
                  _depositionalSubEnvironment = null;
                });
              },
            ),
            DropdownButtonFormField<String?>(
              isExpanded: true,
              initialValue: _depositionalSubEnvironment,
              decoration: InputDecoration(
                labelText: 'Depositional Environment Subtype',
                hintText: _isSubEnvironmentEnabled
                    ? 'Select a depositional sub-environment'
                    : 'Select a Continental or Marine type first',
              ),
              items: _subEnvironmentOptions
                  .map(
                    (e) => DropdownMenuItem<String?>(
                      value: e,
                      child: CommonDropdownText(text: e),
                    ),
                  )
                  .toList(),
              onChanged: _isSubEnvironmentEnabled
                  ? (String? newValue) {
                      setState(() {
                        _depositionalSubEnvironment = newValue;
                      });
                    }
                  : null,
            ),
            DropdownButtonFormField<String?>(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Standard Preservation Type',
                hintText: 'Select a preservation type',
              ),
              items: _preservationTypes
                  .map(
                    (e) => DropdownMenuItem<String?>(
                      value: e,
                      child: CommonDropdownText(text: e),
                    ),
                  )
                  .toList(),
              onChanged: (String? newValue) {},
            ),
            TextFormField(
              maxLines: 4,
              controller: _commentsCtr,
              decoration: const InputDecoration(
                labelText: 'Comments on sedimentology and paleoenvironment',
                hintText: 'E.g. sediment oxidation, erosion, pedogenic'
                    ' reworking, grain size, or sedimentary wave forms.',
              ),
            ),
          ],
        );
  }
}

class SedimentologyInfoContent extends StatelessWidget {
  const SedimentologyInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
            content:
                'Information about the sedimentology and paleoenvironment of'
                ' the site. Comments should note observations concerning'
                ' sediment oxidation, erosion, pedogenic reworking, grain'
                ' size, or sedimentary wave forms.'),
      ],
    );
  }
}
