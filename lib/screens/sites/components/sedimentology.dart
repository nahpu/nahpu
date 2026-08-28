import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as db;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/fossils.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';

class Sedimentology extends ConsumerWidget {
  const Sedimentology({
    super.key,
    required this.id,
    required this.useHorizontalLayout,
    required this.siteFormCtr,
  });

  final int id;
  final bool useHorizontalLayout;
  final SiteFormCtrModel siteFormCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Natural-height card: the site form stacks Sedimentology and Stratigraphy
    // in one scrolling pane, so the scroll lives there rather than here.
    return FormCard(
      title: 'Sedimentology',
      infoContent: const SedimentologyInfoContent(),
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      child: ref
          .watch(fossilSiteProvider(id))
          .when(
            data: (fossilSite) => _buildContent(
              SedimentologyFields(siteId: id, fossilSite: fossilSite),
            ),
            loading: () => const CommonProgressIndicator(),
            error: (error, _) =>
                _buildContent(Text('Error loading sedimentology data: $error')),
          ),
    );
  }

  Widget _buildContent(Widget child) {
    return Padding(padding: const EdgeInsets.all(6), child: child);
  }
}

class SedimentologyFields extends ConsumerStatefulWidget {
  const SedimentologyFields({
    super.key,
    required this.siteId,
    required this.fossilSite,
  });

  final int siteId;
  final FossilSiteData? fossilSite;

  @override
  SedimentologyFieldsState createState() => SedimentologyFieldsState();
}

class SedimentologyFieldsState extends ConsumerState<SedimentologyFields> {
  late final FossilSiteFormCtrModel _ctr = FossilSiteFormCtrModel.fromData(
    widget.fossilSite,
  );

  @override
  void dispose() {
    _ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _ctr.rockTypeCtr,
          decoration: const InputDecoration(
            labelText: 'Rock Type(s)',
            hintText: 'E.g. "Sandstone", "Mudstone", "Limestone"',
          ),
          onChanged: (value) =>
              _updateFossilSite(FossilSiteCompanion(rockType: db.Value(value))),
        ),
        DropdownButtonFormField<DepositionalEnvironmentType>(
          isExpanded: true,
          initialValue: _environmentType,
          decoration: const InputDecoration(
            labelText: 'Depositional Environment Type',
            hintText: 'Select a depositional environment type',
          ),
          items: depositionalEnvironmentTypeList
              .map(
                (e) => DropdownMenuItem(
                  value: DepositionalEnvironmentType
                      .values[depositionalEnvironmentTypeList.indexOf(e)],
                  child: CommonDropdownText(text: e),
                ),
              )
              .toList(),
          onChanged: _onEnvironmentTypeChanged,
        ),
        DropdownButtonFormField<String>(
          // Keyed by the parent category so the field is rebuilt, and its
          // selection cleared, whenever the environment type changes.
          key: ValueKey(_environmentType),
          isExpanded: true,
          initialValue: _subEnvironment,
          decoration: InputDecoration(
            labelText: 'Depositional Environment Subtype',
            hintText: _isSubEnvironmentEnabled
                ? 'Select a depositional sub-environment'
                : 'Select a Continental or Marine type first',
          ),
          items: _subEnvironmentOptions
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: CommonDropdownText(text: e),
                ),
              )
              .toList(),
          onChanged: _isSubEnvironmentEnabled ? _onSubEnvironmentChanged : null,
        ),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _ctr.standardPreservationTypeCtr,
          decoration: const InputDecoration(
            labelText: 'Standard Preservation Type',
            hintText: 'Select a preservation type',
          ),
          items: standardPreservationTypeList
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: CommonDropdownText(text: e),
                ),
              )
              .toList(),
          onChanged: (String? newValue) {
            if (newValue == null) {
              return;
            }
            _ctr.standardPreservationTypeCtr = newValue;
            _updateFossilSite(
              FossilSiteCompanion(standardPreservationType: db.Value(newValue)),
            );
          },
        ),
        TextFormField(
          maxLines: 4,
          controller: _ctr.sedimentologyRemarkCtr,
          decoration: const InputDecoration(
            labelText: 'Comments on sedimentology and paleoenvironment',
            hintText:
                'E.g. sediment oxidation, erosion, pedogenic'
                ' reworking, grain size, or sedimentary wave forms.',
          ),
          onChanged: (value) => _updateFossilSite(
            FossilSiteCompanion(sedimentologyRemark: db.Value(value)),
          ),
        ),
      ],
    );
  }

  DepositionalEnvironmentType? get _environmentType =>
      getDepositionalEnvironmentType(_ctr.depositionalEnvironmentTypeCtr);

  /// The sub-environment options that correspond to the currently selected
  /// depositional environment type.
  List<String> get _subEnvironmentOptions {
    switch (_environmentType) {
      case DepositionalEnvironmentType.continental:
        return continentalSubEnvironmentList;
      case DepositionalEnvironmentType.marine:
        return marineSubEnvironmentList;
      default:
        return const [];
    }
  }

  /// Continental and marine sub-environments are stored in separate columns,
  /// so the value shown depends on the selected parent category.
  String? get _subEnvironment {
    switch (_environmentType) {
      case DepositionalEnvironmentType.continental:
        return _ctr.depositionalContinentCtr;
      case DepositionalEnvironmentType.marine:
        return _ctr.depositionalMarineCtr;
      default:
        return null;
    }
  }

  bool get _isSubEnvironmentEnabled => _subEnvironmentOptions.isNotEmpty;

  void _onEnvironmentTypeChanged(DepositionalEnvironmentType? newValue) {
    if (newValue == null) {
      return;
    }
    setState(() {
      _ctr.depositionalEnvironmentTypeCtr = newValue.index;
      // Reset the dependent sub-environments when the parent category changes.
      _ctr.depositionalContinentCtr = null;
      _ctr.depositionalMarineCtr = null;
    });
    _updateFossilSite(
      FossilSiteCompanion(
        depositionalEnvironmentType: db.Value(newValue.index),
        depositionalContinent: const db.Value(null),
        depositionalMarine: const db.Value(null),
      ),
    );
  }

  void _onSubEnvironmentChanged(String? newValue) {
    if (newValue == null) {
      return;
    }
    final isContinental =
        _environmentType == DepositionalEnvironmentType.continental;
    setState(() {
      if (isContinental) {
        _ctr.depositionalContinentCtr = newValue;
      } else {
        _ctr.depositionalMarineCtr = newValue;
      }
    });
    _updateFossilSite(
      isContinental
          ? FossilSiteCompanion(depositionalContinent: db.Value(newValue))
          : FossilSiteCompanion(depositionalMarine: db.Value(newValue)),
    );
  }

  void _updateFossilSite(FossilSiteCompanion entries) {
    FossilSiteServices(ref: ref).updateFossilSite(widget.siteId, entries);
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
              ' size, or sedimentary wave forms.',
        ),
      ],
    );
  }
}
