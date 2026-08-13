import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/associated_data.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/sites/components/coordinates.dart';
import 'package:nahpu/services/types/associated_data.dart';

class SiteDataTabBar extends StatefulWidget {
  const SiteDataTabBar({super.key, required this.siteId});

  final int siteId;

  @override
  State<SiteDataTabBar> createState() => _SiteDataTabBarState();
}

class _SiteDataTabBarState extends State<SiteDataTabBar>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormCard(
      isWithTitle: false,
      isWithSidePadding: false,
      child: CommonTabBars(
        tabController: _tabController,
        length: 2,
        height: 502,
        tabs: const [
          Tab(icon: Icon(Icons.location_on_outlined)),
          Tab(icon: Icon(Icons.storage_rounded)),
        ],
        children: [
          CoordinateTabView(siteId: widget.siteId),
          AssociatedDataViewer(
            target: AssociatedDataTarget.site(widget.siteId),
          ),
        ],
      ),
    );
  }
}
