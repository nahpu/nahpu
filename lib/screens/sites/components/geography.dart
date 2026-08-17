import 'package:material_ui/material_ui.dart';
import 'package:drift/drift.dart' as db;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/shared/common/common.dart';

class Geography extends ConsumerWidget {
  const Geography({
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
    return ref
        .watch(userDefinedFieldProvider(siteGeographyFieldsPrefKey))
        .when(
          data: (visibleFields) => FormCard(
            title: 'Geography',
            infoTopic: InfoTopic.siteGeography,
            child: Column(
              children: [
                MainSiteLocality(
                  id: id,
                  useHorizontalLayout: useHorizontalLayout,
                  siteFormCtr: siteFormCtr,
                  visibleFields: visibleFields.toSet(),
                ),
                AdaptiveLayout(
                  useHorizontalLayout: useHorizontalLayout,
                  children: [
                    PreciseLocality(
                      id: id,
                      useHorizontalLayout: useHorizontalLayout,
                      siteFormCtr: siteFormCtr,
                    ),
                    LocalityNote(
                      id: id,
                      useHorizontalLayout: useHorizontalLayout,
                      siteFormCtr: siteFormCtr,
                    ),
                  ],
                ),
              ],
            ),
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, _) =>
              Text('Unable to load geography settings: $error'),
        );
  }
}

class MainSiteLocality extends ConsumerWidget {
  const MainSiteLocality({
    super.key,
    required this.id,
    required this.useHorizontalLayout,
    required this.siteFormCtr,
    required this.visibleFields,
  });

  final int id;
  final bool useHorizontalLayout;
  final SiteFormCtrModel siteFormCtr;
  final Set<String> visibleFields;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveLayout(
      useHorizontalLayout: useHorizontalLayout,
      children: [
        if (visibleFields.contains('country'))
          TextFormField(
            controller: siteFormCtr.countryCtr,
            decoration: const InputDecoration(
              labelText: 'Country',
              hintText: 'Enter a country',
            ),
            onChanged: (value) {
              SiteServices(
                ref: ref,
              ).updateSite(id, SiteCompanion(country: db.Value(value)));
            },
          ),
        if (visibleFields.contains('islandGroup'))
          TextFormField(
            controller: siteFormCtr.islandGroupCtr,
            decoration: const InputDecoration(
              labelText: 'Island group',
              hintText: 'Enter an island group',
            ),
            onChanged: (value) {
              SiteServices(
                ref: ref,
              ).updateSite(id, SiteCompanion(islandGroup: db.Value(value)));
            },
          ),
        if (visibleFields.contains('stateProvince'))
          TextFormField(
            controller: siteFormCtr.stateProvinceCtr,
            decoration: const InputDecoration(
              labelText: 'State/Province',
              hintText: 'Enter a state/province',
            ),
            onChanged: (value) {
              SiteServices(
                ref: ref,
              ).updateSite(id, SiteCompanion(stateProvince: db.Value(value)));
            },
          ),
        if (visibleFields.contains('county'))
          TextFormField(
            controller: siteFormCtr.countyCtr,
            decoration: const InputDecoration(
              labelText: 'County/Parish/District',
              hintText: 'Enter a county/parish/district',
            ),
            onChanged: (value) {
              SiteServices(
                ref: ref,
              ).updateSite(id, SiteCompanion(county: db.Value(value)));
            },
          ),
        if (visibleFields.contains('municipality'))
          TextFormField(
            controller: siteFormCtr.municipalityCtr,
            decoration: const InputDecoration(
              labelText: 'Municipality/City/Town',
              hintText: 'Enter a municipality/city/town',
            ),
            onChanged: (value) {
              SiteServices(
                ref: ref,
              ).updateSite(id, SiteCompanion(municipality: db.Value(value)));
            },
          ),
      ],
    );
  }
}

class PreciseLocality extends ConsumerWidget {
  const PreciseLocality({
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
    return TextFormField(
      controller: siteFormCtr.localityCtr,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Precise Locality',
        hintText: 'Enter a precise locality lower than municipality',
      ),
      onChanged: (value) {
        SiteServices(
          ref: ref,
        ).updateSite(id, SiteCompanion(locality: db.Value(value)));
      },
    );
  }
}

class LocalityNote extends ConsumerWidget {
  const LocalityNote({
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
    return TextFormField(
      controller: siteFormCtr.remarkCtr,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Remarks',
        hintText: 'Enter more info about the site (optional)',
      ),
      onChanged: (value) {
        SiteServices(
          ref: ref,
        ).updateSite(id, SiteCompanion(remark: db.Value(value)));
      },
    );
  }
}
