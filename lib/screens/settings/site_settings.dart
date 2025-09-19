import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/providers/sites.dart';

class SiteSelection extends StatefulWidget {
  const SiteSelection({super.key});

  @override
  State<SiteSelection> createState() => _SiteSelectionState();
}

class _SiteSelectionState extends State<SiteSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Settings'),
      ),
      body: const SafeArea(
        child: CommonSettingList(
          sections: [
            HabitatTypeSettings(),
          ],
        ),
      ),
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
