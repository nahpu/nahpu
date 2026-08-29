import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/events/components/personnel.dart';
import 'package:nahpu/screens/events/components/environment_data.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/associated_data.dart';
import 'package:nahpu/services/types/associated_data.dart';

class CollEventTabBar extends StatefulWidget {
  const CollEventTabBar({
    super.key,
    required this.useHorizontalLayout,
    required this.eventID,
  });

  final bool useHorizontalLayout;
  final int eventID;

  @override
  State<CollEventTabBar> createState() => _CollEventTabBarState();
}

class _CollEventTabBarState extends State<CollEventTabBar>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final int _length = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _length, vsync: this);
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
        length: _length,
        tabController: _tabController,
        height: 502,
        tabs: [
          const Tab(icon: Icon(Icons.groups_2_outlined)),
          const Tab(icon: Icon(Icons.wb_cloudy_outlined)),
          const Tab(icon: Icon(Icons.storage_rounded)),
        ],
        children: [
          EventPersonnel(eventID: widget.eventID),
          EnvironmentDataView(
            useHorizontalLayout: widget.useHorizontalLayout,
            eventID: widget.eventID,
          ),
          AssociatedDataViewer(
            target: AssociatedDataTarget.event(widget.eventID),
          ),
        ],
      ),
    );
  }
}
