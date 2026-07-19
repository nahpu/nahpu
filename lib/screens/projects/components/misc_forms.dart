import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/statistics/statistics.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';

class StatViewer extends ConsumerStatefulWidget {
  const StatViewer({super.key});

  @override
  StatViewerState createState() => StatViewerState();
}

class StatViewerState extends ConsumerState<StatViewer>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final int _length = 1;

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
      child: StatisticViewer(),
      // CommonTabBars(
      //   tabController: _tabController,
      //   length: _length,
      //   height: 392,
      //   tabs: const [
      //     Tab(icon: Icon(Icons.analytics_outlined)),
      //   ],
      //   children: const [
      //     StatisticViewer(),
      //   ],
      // ),
    );
  }
}
