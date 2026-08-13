import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/controlled_vocabulary.dart';

class CollEventSelection extends StatefulWidget {
  const CollEventSelection({super.key});

  @override
  State<CollEventSelection> createState() => _CollEventSelectionState();
}

class _CollEventSelectionState extends State<CollEventSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collection Event Settings')),
      body: SafeArea(
        child: CommonSettingList(
          sections: const [
            ControlledVocabularySetting(
              title: 'Collection methods',
              typePrefKey: collMethodPrefKey,
              fmtPrefKey: collMethodFmtPrefKey,
              typeName: 'collection method',
            ),
            ControlledVocabularySetting(
              title: 'Personnel roles',
              typePrefKey: collRolePrefKey,
              fmtPrefKey: collRoleFmtPrefKey,
              typeName: 'personnel role',
            ),
          ],
        ),
      ),
    );
  }
}
