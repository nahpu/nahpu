import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nahpu/screens/home/components/menu_drawer.dart';
import 'package:nahpu/screens/home/components/body.dart';
import 'package:nahpu/screens/projects/new_project.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/db_services.dart';
import 'package:nahpu/services/providers/database.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> {
  Future<void>? _checkNewDbFuture;

  @override
  Widget build(BuildContext context) {
    final databaseState = ref.watch(databaseReadyProvider);

    return FalseWillPop(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/logo/nahpu-nobg.svg',
                fit: BoxFit.contain,
                height: 32,
                width: 32,
              ),
              const SizedBox(width: 8),
              Text("NAHPU", style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        resizeToAvoidBottomInset: false,
        drawer: const HomeMenuDrawer(),
        body: databaseState.when(
          loading: () => const Center(child: CommonProgressIndicator()),
          error: (error, stackTrace) => _DatabaseErrorView(
            onRetry: () => ref.invalidate(databaseProvider),
          ),
          data: (_) => FutureBuilder<void>(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const HomeBody();
              } else {
                return const Center(child: CommonProgressIndicator());
              }
            },
            future: _checkNewDbFuture ??= _checkNewDb(),
          ),
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add_rounded,
          activeIcon: Icons.close_rounded,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          children: [
            SpeedDialChild(
              child: Icon(
                Icons.create_rounded,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              label: 'New project',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateProjectForm(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkNewDb() async {
    final db = DbServices(ref: ref);
    final newDb = await db.checkNewDatabase();
    if (newDb) {
      await DbServices(ref: ref).syncSettingWithDb();
    }
  }
}

class _DatabaseErrorView extends StatelessWidget {
  const _DatabaseErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storage_rounded, size: 48),
            const SizedBox(height: 16),
            Text(
              'Unable to open the NAHPU database.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your data was not deleted. Retry the database migration or '
              'restart NAHPU.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
