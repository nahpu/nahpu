import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/providers/settings.dart';

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
        body: SafeArea(child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          bool isMobile = constraints.maxWidth < 600;
          return CommonSettingList(
            sections: [
              EventFormats(
                isMobile: isMobile,
              ),
              UserDefinedSettingField(
                typePrefKey: collMethodPrefKey,
                fmtPrefKey: collMethodFmtPrefKey,
                typeName: 'collection method',
              ),
              UserDefinedSettingField(
                typePrefKey: collRolePrefKey,
                fmtPrefKey: collRoleFmtPrefKey,
                typeName: 'Personnel role',
              ),
            ],
          );
        })));
  }
}

class EventFormats extends ConsumerWidget {
  const EventFormats({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonSettingSection(title: 'Formats', children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
          child: AdaptiveLayout(
            useHorizontalLayout: !isMobile,
            children: [
              TextCaseFmtDropDown(
                  ref: ref,
                  label: 'Collection methods',
                  textCasePrefString: collMethodFmtPrefKey),
              TextCaseFmtDropDown(
                  ref: ref,
                  label: 'Personnel roles',
                  textCasePrefString: collRoleFmtPrefKey),
            ],
          ))
    ]);
  }
}
