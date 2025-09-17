import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/site_services.dart';

class CollEventSelection extends StatefulWidget {
  const CollEventSelection({super.key});

  @override
  State<CollEventSelection> createState() => _CollEventSelectionState();
}

class _CollEventSelectionState extends State<CollEventSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Event Settings'),
      ),
      body: const SafeArea(
        child: CommonSettingList(
          sections: [
            CollMethodSettings(),
            PersonnelRoleSetting(),
            HabitatTypeSettings(),
          ],
        ),
      ),
    );
  }
}

class CollMethodSettings extends ConsumerWidget {
  const CollMethodSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController controller = TextEditingController();
    return SettingChips(
      title: 'Collection methods',
      controller: controller,
      chipList: ref.watch(collEventMethodProvider).when(
            data: (data) {
              return data.map((e) {
                return CommonSettingChip(
                  text: e,
                  primaryColor: Theme.of(context).colorScheme.primary,
                  onDeleted: () {
                    CollMethodServices(ref: ref).removeMethod(e);
                  },
                );
              }).toList();
            },
            loading: () => [const CommonProgressIndicator()],
            error: (e, _) => [Text('Error: $e')],
          ),
      labelText: 'Add method',
      hintText: 'Enter method',
      onPressed: () {
        CollMethodServices(ref: ref).addMethod(
          controller.text.trim(),
        );
        controller.clear();
      },
      resetLabel: 'Match database methods',
      onReset: () {
        CollMethodServices(ref: ref).getAllMethods();
      },
    );
  }
}

class PersonnelRoleSetting extends ConsumerWidget {
  const PersonnelRoleSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController controller = TextEditingController();
    return SettingChips(
      title: 'Personnel roles',
      controller: controller,
      chipList: ref.watch(collPersonnelRoleProvider).when(
            data: (data) {
              return data.map((e) {
                return CommonSettingChip(
                  text: e,
                  primaryColor: Theme.of(context).colorScheme.secondary,
                  onDeleted: () {
                    CollEvenPersonnelServices(ref: ref).removeRole(e);
                  },
                );
              }).toList();
            },
            loading: () => [const CommonProgressIndicator()],
            error: (e, _) => [Text('Error: $e')],
          ),
      labelText: 'Add role',
      hintText: 'Enter role',
      onPressed: () {
        CollEvenPersonnelServices(ref: ref).addRole(controller.text);
        controller.clear();
      },
      resetLabel: 'Match database roles',
      onReset: () {
        CollEvenPersonnelServices(ref: ref).getAllRoles();
      },
    );
  }
}

class HabitatTypeSettings extends ConsumerWidget {
  const HabitatTypeSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController controller = TextEditingController();
    return SettingChips(
      title: 'Habitat types',
      controller: controller,
      chipList: ref.watch(habitatTypeProvider).when(
            data: (data) {
              return data.map((e) {
                return CommonSettingChip(
                  text: e,
                  primaryColor: Theme.of(context).colorScheme.tertiary,
                  onDeleted: () {
                    HabitatServices(ref: ref).removeHabitat(e);
                  },
                );
              }).toList();
            },
            loading: () => [const CommonProgressIndicator()],
            error: (e, _) => [Text('Error: $e')],
          ),
      labelText: 'Add habitat type',
      hintText: 'Enter habitat type',
      onPressed: () {
        HabitatServices(ref: ref).addHabitat(controller.text.trim());
        controller.clear();
      },
      resetLabel: 'Match database habitat types',
      onReset: () {
        HabitatServices(ref: ref).getAllHabitats();
      },
    );
  }
}