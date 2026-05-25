import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/events/components/menu_bar.dart';
import 'package:nahpu/screens/sites/components/menu_bar.dart';
import 'package:nahpu/screens/narrative/components/menu_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/specimens/shared/menu_bar.dart';
import 'package:nahpu/services/types/specimens.dart';

class ActionButtons extends ConsumerWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CatalogFmt catalogFmt = ref.read(catalogFmtNotifier);
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      direction: SpeedDialDirection.down,
      children: [
        SpeedDialChild(
          child: Icon(Icons.place_outlined,
              color: Theme.of(context).colorScheme.onSecondary),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          label: 'Create site',
          onTap: () async {
            await createNewSite(context, ref);
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.timeline,
              color: Theme.of(context).colorScheme.onSecondary),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          label: 'Create event',
          onTap: () async {
            await createNewCollEvents(context, ref);
          },
        ),
        SpeedDialChild(
          child: ref.watch(catalogFmtNotifierProvider).when(
                data: (catalogFmt) =>
                    Icon(matchCatFmtToIcon(catalogFmt, isFilledIcon: true)),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          label: 'Create specimen',
          onTap: () async {
            await createNewSpecimens(context, ref);
          },
        ),
        SpeedDialChild(
            child: Icon(Icons.book_outlined,
                color: Theme.of(context).colorScheme.onSecondary),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            label: 'Create narrative',
            onTap: () async {
              await createNewNarrative(context, ref);
            }),
      ],
    );
  }
}
