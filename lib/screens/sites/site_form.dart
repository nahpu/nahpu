import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/sites/components/habitats.dart';
import 'package:nahpu/screens/sites/components/sedimentology.dart';
import 'package:nahpu/screens/sites/components/stratigraphy.dart';
import 'package:nahpu/screens/sites/components/geography.dart';
import 'package:nahpu/screens/sites/components/media.dart';
import 'package:nahpu/screens/sites/components/site_info.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/sites/components/coordinates.dart';
import 'package:nahpu/styles/catalog_pages.dart';

class SiteForm extends ConsumerStatefulWidget {
  const SiteForm({super.key, required this.id, required this.siteFormCtr});

  final int id;
  final SiteFormCtrModel siteFormCtr;

  @override
  SiteFormState createState() => SiteFormState();
}

class SiteFormState extends ConsumerState<SiteForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.siteFormCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        bool useHorizontalLayout = c.maxWidth > 600.0;
        return FocusDetectedLayout(
          children: [
            SiteInfo(
              id: widget.id,
              useHorizontalLayout: useHorizontalLayout,
              siteFormCtr: widget.siteFormCtr,
            ),
            Geography(
              id: widget.id,
              useHorizontalLayout: useHorizontalLayout,
              siteFormCtr: widget.siteFormCtr,
            ),
            AdaptiveMainLayout(
              useHorizontalLayout: useHorizontalLayout,
              height: bottomSiteHeight,
              children: [
                _buildSiteContext(useHorizontalLayout),
                CoordinateFields(siteId: widget.id),
              ],
            ),
            SiteMediaForm(siteId: widget.id),
            const BottomPadding()
          ],
        );
      },
    );
  }

  /// The left pane beside the coordinates panel. Paleontology (fossil) projects
  /// record stratigraphic and sedimentological information instead of the
  /// extant habitat of a site, so this pane stacks the Sedimentology and
  /// Stratigraphy sections (scrolling to fit the fixed pane height) in place of
  /// Habitat.
  ///
  /// Detection currently rides on the global catalog-format setting, which is
  /// written when a project is created. This is a placeholder: it does not yet
  /// track a project's type when an existing project is reopened, because the
  /// catalog format is not persisted per project. Once the project's catalog
  /// format is stored in the database (and restored on open), swap the source
  /// below for that per-project value so switching projects re-detects.
  Widget _buildSiteContext(bool useHorizontalLayout) {
    final habitat = Habitat(
      id: widget.id,
      useHorizontalLayout: useHorizontalLayout,
      siteFormCtr: widget.siteFormCtr,
    );

    return ref.watch(catalogFmtNotifierProvider).when(
          data: (catalogFmt) => catalogFmt == CatalogFmt.fossils
              ? _buildPaleoPane(useHorizontalLayout)
              : habitat,
          loading: () => habitat,
          error: (e, s) => habitat,
        );
  }

  /// Stacks the two paleontology sections in the single site-context pane. The
  /// pane is height-capped in the horizontal layout, so the sections scroll
  /// within it (mirroring the specimen part panel); in the vertical layout the
  /// whole site form already scrolls, so an inner scroll would be unbounded.
  Widget _buildPaleoPane(bool useHorizontalLayout) {
    final sections = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Sedimentology(
          id: widget.id,
          useHorizontalLayout: useHorizontalLayout,
          siteFormCtr: widget.siteFormCtr,
        ),
        Stratigraphy(
          id: widget.id,
          useHorizontalLayout: useHorizontalLayout,
          siteFormCtr: widget.siteFormCtr,
        ),
      ],
    );

    return useHorizontalLayout
        ? SingleChildScrollView(child: sections)
        : sections;
  }
}
