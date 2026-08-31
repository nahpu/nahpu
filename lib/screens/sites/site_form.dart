import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/sites/components/habitats.dart';
import 'package:nahpu/screens/sites/components/sedimentology.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/screens/sites/components/geography.dart';
import 'package:nahpu/screens/sites/components/media.dart';
import 'package:nahpu/screens/sites/components/site_info.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/sites/components/tab_bar.dart';
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
        bool useHorizontalLayout = c.maxWidth > NahpuBreakpoints.compact;
        return FocusDetectedLayout(
          children: [
            SiteInfo(
              id: widget.id,
              useHorizontalLayout: useHorizontalLayout,
              siteFormCtr: widget.siteFormCtr,
            ),
            SiteGeography(
              id: widget.id,
              useHorizontalLayout: useHorizontalLayout,
              siteFormCtr: widget.siteFormCtr,
            ),
            AdaptiveMainLayout(
              useHorizontalLayout: useHorizontalLayout,
              height: bottomSiteHeight,
              children: [
                SiteContextFields(
                  id: widget.id,
                  useHorizontalLayout: useHorizontalLayout,
                  siteFormCtr: widget.siteFormCtr,
                ),
                SiteDataTabBar(siteId: widget.id),
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

/// Catalog format is a device-wide preference, matching the rest of NAHPU.
class SiteContextFields extends ConsumerWidget {
  const SiteContextFields({
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
        .watch(catalogFmtNotifierProvider)
        .when(
          data: (format) => format == CatalogFmt.fossils
              ? Sedimentology(id: id, useHorizontalLayout: useHorizontalLayout)
              : Habitat(
                  id: id,
                  useHorizontalLayout: useHorizontalLayout,
                  siteFormCtr: siteFormCtr,
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Could not load catalog format: $error'),
        );
  }
}
