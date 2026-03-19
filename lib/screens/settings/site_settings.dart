import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/providers/settings.dart';

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
        body: SafeArea(child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          bool isMobile = constraints.maxWidth < 600;
          return CommonSettingList(
            sections: [
              SiteFormats(
                isMobile: isMobile,
              ),
              UserDefinedSettingField(
                typePrefKey: siteTypePrefKey,
                fmtPrefKey: siteTypeFmtPrefKey,
                typeName: 'Site Type',
              ),
              UserDefinedSettingField(
                typePrefKey: habitatTypePrefKey,
                fmtPrefKey: habitatTypeFmtPrefKey,
                typeName: 'Habitat Type',
              ),
            ],
          );
        })));
  }
}

class SiteFormats extends ConsumerWidget {
  const SiteFormats({super.key, required this.isMobile});

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
                  label: 'Site types',
                  textCasePrefString: siteTypeFmtPrefKey),
              TextCaseFmtDropDown(
                  ref: ref,
                  label: 'Habitat types',
                  textCasePrefString: habitatTypeFmtPrefKey),
            ],
          ))
    ]);
  }
}
