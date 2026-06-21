import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nahpu/screens/home/components/menu_drawer.dart';
import 'package:nahpu/screens/home/components/body.dart';
import 'package:nahpu/screens/projects/new_project.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/db_services.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    return FalseWillPop(
        child: Scaffold(
      appBar: AppBar(
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SvgPicture.asset(
            'assets/logo/nahpu-nobg.svg',
            fit: BoxFit.contain,
            height: 32,
            width: 32,
          ),
          const SizedBox(width: 8),
          Text(
            "NAHPU",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ]),
      ),
      resizeToAvoidBottomInset: false,
      drawer: const HomeMenuDrawer(),
      body: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const HomeBody();
            } else {
              return const Center(child: CommonProgressIndicator());
            }
          },
          future: _checkNewDb()),
      floatingActionButton: SpeedDial(
        icon: Icons.add_rounded,
        activeIcon: Icons.close_rounded,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        children: [
          SpeedDialChild(
            child: Icon(Icons.create_rounded,
                color: Theme.of(context).colorScheme.onSecondary),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            label: 'New project',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateProjectForm()),
              );
            },
          ),
        ],
      ),
    ));
  }

  Future<void> _checkNewDb() async {
    final db = DbServices(ref: ref);
    final newDb = await db.checkNewDatabase();
    if (newDb) {
      await DbServices(ref: ref).syncSettingWithDb();
    }
  }
}
