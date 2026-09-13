import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/sites/components/habitats.dart';
import 'package:nahpu/screens/sites/components/site_attributes.dart';
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
                SiteContext(
                  id: widget.id,
                  useHorizontalLayout: useHorizontalLayout,
                  siteFormCtr: widget.siteFormCtr,
                ),
                CoordinateFields(siteId: widget.id),
              ],
            ),
            SiteMediaForm(siteId: widget.id),
            const BottomPadding(),
          ],
        );
      },
    );
  }
}

/// Uses the global catalog format until it is persisted per project.
class SiteContext extends ConsumerWidget {
  const SiteContext({
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
    final habitat = Habitat(
      id: id,
      useHorizontalLayout: useHorizontalLayout,
      siteFormCtr: siteFormCtr,
    );
    return ref
        .watch(catalogFmtNotifierProvider)
        .when(
          data: (catalogFmt) => catalogFmt == CatalogFmt.fossils
              ? SiteAttributes(id: id, useHorizontalLayout: useHorizontalLayout)
              : habitat,
          loading: () => habitat,
          error: (e, s) => habitat,
        );
  }
}
