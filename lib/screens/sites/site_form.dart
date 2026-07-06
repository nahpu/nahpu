import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/sites/components/habitats.dart';
import 'package:nahpu/screens/sites/components/sedimentology.dart';
import 'package:nahpu/screens/sites/components/geography.dart';
import 'package:nahpu/screens/sites/components/media.dart';
import 'package:nahpu/screens/sites/components/site_info.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/shared/layout.dart';
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
                CoordinateFields(
                  siteId: widget.id,
                ),
              ],
            ),
            SiteMediaForm(siteId: widget.id),
            const BottomPadding()
          ],
        );
      },
    );
  }

  /// Paleontology (fossil) projects record stratigraphic and sedimentological
  /// information instead of the extant habitat of a site.
  Widget _buildSiteContext(bool useHorizontalLayout) {
    return ref.watch(catalogFmtNotifierProvider).when(
          data: (catalogFmt) {
            return catalogFmt == CatalogFmt.fossils
                ? Sedimentology(
                    id: widget.id,
                    useHorizontalLayout: useHorizontalLayout,
                    siteFormCtr: widget.siteFormCtr,
                  )
                : Habitat(
                    id: widget.id,
                    useHorizontalLayout: useHorizontalLayout,
                    siteFormCtr: widget.siteFormCtr,
                  );
          },
          loading: () => Habitat(
            id: widget.id,
            useHorizontalLayout: useHorizontalLayout,
            siteFormCtr: widget.siteFormCtr,
          ),
          error: (e, s) => Habitat(
            id: widget.id,
            useHorizontalLayout: useHorizontalLayout,
            siteFormCtr: widget.siteFormCtr,
          ),
        );
  }
}
