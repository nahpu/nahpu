import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/sites/components/habitats.dart';
import 'package:nahpu/screens/sites/components/geography.dart';
import 'package:nahpu/screens/sites/components/media.dart';
import 'package:nahpu/screens/sites/components/site_info.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/geography.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/screens/sites/components/tab_bar.dart';
import 'package:nahpu/styles/catalog_pages.dart';

/// The site record form.
///
/// Owns the field controllers for as long as the record is on screen. Rebuilding
/// them from the record on every provider update would replace them mid-edit and
/// leak the superseded set.
class SiteForm extends ConsumerStatefulWidget {
  const SiteForm({super.key, required this.site, required this.attribute});

  final SiteRecord site;
  final SiteAttributeData? attribute;

  @override
  SiteFormState createState() => SiteFormState();
}

class SiteFormState extends ConsumerState<SiteForm> {
  late final SiteFormCtrModel _siteFormCtr = SiteFormCtrModel.fromData(
    widget.site,
    widget.attribute,
  );

  @override
  void didUpdateWidget(covariant SiteForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.site == widget.site &&
        oldWidget.attribute == widget.attribute) {
      return;
    }
    _siteFormCtr.syncFrom(widget.site, widget.attribute);
  }

  @override
  void dispose() {
    _siteFormCtr.dispose();
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
              id: widget.site.id,
              useHorizontalLayout: useHorizontalLayout,
              siteFormCtr: _siteFormCtr,
            ),
            SiteGeography(
              id: widget.site.id,
              useHorizontalLayout: useHorizontalLayout,
              siteFormCtr: _siteFormCtr,
            ),
            AdaptiveMainLayout(
              useHorizontalLayout: useHorizontalLayout,
              height: bottomSiteHeight,
              children: [
                Habitat(
                  id: widget.site.id,
                  useHorizontalLayout: useHorizontalLayout,
                  siteFormCtr: _siteFormCtr,
                ),
                SiteDataTabBar(siteId: widget.site.id),
              ],
            ),
            SiteMediaForm(siteId: widget.site.id),
            const BottomPadding(),
          ],
        );
      },
    );
  }
}
