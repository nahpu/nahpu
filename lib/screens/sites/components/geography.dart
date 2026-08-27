import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:drift/drift.dart' as db;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/geography_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/sites/geography_services.dart';
import 'package:nahpu/services/sites/site_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/geography.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';

/// The site geography card.
///
/// Named `SiteGeography` because drift generates a `Geography` table class
/// from the `geography` table.
///
/// Geography lives in the shared `geography` table, so the fields here are a
/// draft that is resolved to a locality record when the card loses focus. That
/// timing matters: resolving on every keystroke would create a record for every
/// prefix the user types, and unreferenced records are kept on purpose.
class SiteGeography extends ConsumerStatefulWidget {
  const SiteGeography({
    super.key,
    required this.id,
    required this.useHorizontalLayout,
    required this.siteFormCtr,
  });

  final int id;
  final bool useHorizontalLayout;
  final SiteFormCtrModel siteFormCtr;

  @override
  ConsumerState<SiteGeography> createState() => _SiteGeographyState();
}

class _SiteGeographyState extends ConsumerState<SiteGeography> {
  /// Held so the card can still save while it is being disposed, when `ref` is
  /// no longer safe to read.
  Database? _database;

  /// The last draft written, so an unchanged card does not rewrite on every
  /// focus change.
  GeographyDraft? _saved;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _database ??= ref.read(databaseProvider);
    _saved ??= widget.siteFormCtr.geographyDraft;
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(userDefinedFieldProvider(siteGeographyFieldsPrefKey))
        .when(
          data: (visibleFields) => Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) _resolveGeography();
            },
            child: FormCard(
              title: 'Geography',
              infoTopic: InfoTopic.siteGeography,
              child: Column(
                children: [
                  LocalityLookup(
                    id: widget.id,
                    siteFormCtr: widget.siteFormCtr,
                    onSelected: _applyGeography,
                  ),
                  MainSiteLocality(
                    id: widget.id,
                    useHorizontalLayout: widget.useHorizontalLayout,
                    siteFormCtr: widget.siteFormCtr,
                    visibleFields: visibleFields.toSet(),
                  ),
                  AdaptiveLayout(
                    useHorizontalLayout: widget.useHorizontalLayout,
                    children: [
                      PreciseLocality(
                        id: widget.id,
                        useHorizontalLayout: widget.useHorizontalLayout,
                        siteFormCtr: widget.siteFormCtr,
                      ),
                      LocalityNote(
                        id: widget.id,
                        useHorizontalLayout: widget.useHorizontalLayout,
                        siteFormCtr: widget.siteFormCtr,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          loading: () => const CommonProgressIndicator(),
          error: (error, _) =>
              Text('Unable to load geography settings: $error'),
        );
  }

  @override
  void deactivate() {
    // The page can be swiped away without the fields ever losing focus, so the
    // card saves here too -- through the held database, since `ref` is already
    // unsafe at this point.
    final database = _database;
    final draft = widget.siteFormCtr.geographyDraft;
    if (database != null && draft != _saved) {
      _saved = draft;
      unawaited(GeographyServices.resolveForSiteIn(database, widget.id, draft));
    }
    super.deactivate();
  }

  void _applyGeography(GeographyData geography) {
    setState(() {
      widget.siteFormCtr.applyGeography(GeographyDraft.fromData(geography));
    });
    _resolveGeography();
  }

  void _resolveGeography() {
    final draft = widget.siteFormCtr.geographyDraft;
    if (draft == _saved) return;
    _saved = draft;
    unawaited(GeographyServices(ref: ref).resolveForSite(widget.id, draft));
  }
}

/// Matches what the user types against every locality already in the database.
///
/// Selecting a suggestion fills the whole hierarchy at once. The option carries
/// its record so selection never has to parse the display string back into
/// fields.
class LocalityLookup extends ConsumerStatefulWidget {
  const LocalityLookup({
    super.key,
    required this.id,
    required this.siteFormCtr,
    required this.onSelected,
  });

  final int id;
  final SiteFormCtrModel siteFormCtr;
  final void Function(GeographyData) onSelected;

  @override
  ConsumerState<LocalityLookup> createState() => _LocalityLookupState();
}

class _LocalityLookupState extends ConsumerState<LocalityLookup> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(geographyListProvider)
        .when(
          data: (records) {
            if (records.isEmpty) return const SizedBox.shrink();
            final byLabel = <String, GeographyData>{
              for (final record in records)
                GeographyDraft.fromData(record).displayName: record,
            };
            return Tooltip(
              message:
                  'Type a locality and select a saved one to fill '
                  'every geography field',
              child: AutoCompleteField(
                focusNode: _focusNode,
                controller: _controller,
                options: byLabel.keys.toList(growable: false),
                labelText: 'Find existing locality',
                hintText: 'Type to reuse a saved locality',
                onSelected: (selection) {
                  final record = byLabel[selection];
                  if (record == null) return;
                  widget.onSelected(record);
                  _controller.clear();
                },
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
          GeographyValueField(
            controller: siteFormCtr.countryCtr,
            field: GeographyField.country,
            labelText: 'Country',
            hintText: 'Enter a country',
          ),
        if (visibleFields.contains('islandGroup'))
          GeographyValueField(
            controller: siteFormCtr.islandGroupCtr,
            field: GeographyField.islandGroup,
            labelText: 'Island group',
            hintText: 'Enter an island group',
          ),
        if (visibleFields.contains('stateProvince'))
          GeographyValueField(
            controller: siteFormCtr.stateProvinceCtr,
            field: GeographyField.stateProvince,
            labelText: 'State/Province',
            hintText: 'Enter a state/province',
          ),
        if (visibleFields.contains('county'))
          GeographyValueField(
            controller: siteFormCtr.countyCtr,
            field: GeographyField.county,
            labelText: 'County/Parish/District',
            hintText: 'Enter a county/parish/district',
          ),
        if (visibleFields.contains('municipality'))
          GeographyValueField(
            controller: siteFormCtr.municipalityCtr,
            field: GeographyField.municipality,
            labelText: 'Municipality/City/Town',
            hintText: 'Enter a municipality/city/town',
          ),
      ],
    );
  }
}

/// One geography field, suggesting values already recorded for that field.
class GeographyValueField extends ConsumerStatefulWidget {
  const GeographyValueField({
    super.key,
    required this.controller,
    required this.field,
    required this.labelText,
    required this.hintText,
  });

  final TextEditingController controller;
  final GeographyField field;
  final String labelText;
  final String hintText;

  @override
  ConsumerState<GeographyValueField> createState() =>
      _GeographyValueFieldState();
}

class _GeographyValueFieldState extends ConsumerState<GeographyValueField> {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final options = ref
        .watch(geographyListProvider)
        .maybeWhen(
          data: (records) => _optionsFrom(records),
          orElse: () => const <String>[],
        );
    return AutoCompleteField(
      focusNode: _focusNode,
      controller: widget.controller,
      options: options,
      labelText: widget.labelText,
      hintText: widget.hintText,
      // The card resolves the whole draft on focus loss, so selecting a value
      // only needs to leave it in the controller.
      onSelected: (_) {},
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  List<String> _optionsFrom(List<GeographyData> records) {
    final values = <String>{};
    for (final record in records) {
      final value = switch (widget.field) {
        GeographyField.country => record.country,
        GeographyField.islandGroup => record.islandGroup,
        GeographyField.stateProvince => record.stateProvince,
        GeographyField.county => record.county,
        GeographyField.municipality => record.municipality,
        GeographyField.locality => record.locality,
      };
      final cleaned = cleanGeographyValue(value);
      if (cleaned != null) values.add(cleaned);
    }
    final sorted = values.toList()..sort();
    return sorted;
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
      // Remarks stay on the site row, so they keep saving as they are typed.
      onChanged: (value) {
        SiteServices(
          ref: ref,
        ).updateSite(id, SiteCompanion(remark: db.Value(value)));
      },
    );
  }
}
