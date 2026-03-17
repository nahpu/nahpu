import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/utility_services.dart';

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
              SiteTypeSettings(
                typePrefKey: siteTypePrefKey,
                fmtPrefKey: siteTypeFmtPrefKey,
                typeName: 'site',
              ),
              SiteTypeSettings(
                typePrefKey: habitatTypePrefKey,
                fmtPrefKey: habitatTypeFmtPrefKey,
                typeName: 'habitat',
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

class SiteTypeSettings extends ConsumerWidget {
  const SiteTypeSettings(
      {super.key,
      required this.typePrefKey,
      required this.fmtPrefKey,
      required this.typeName});

  final String typePrefKey;
  final String fmtPrefKey;
  final String typeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController controller = TextEditingController();
    return SettingChips(
      title: '${typeName.toTitleCase()} types',
      controller: controller,
      ref: ref,
      textCasePrefString: fmtPrefKey,
      chipList: ref.watch(userDefinedTypeProvider(typePrefKey)).when(
            data: (data) {
              return data.map((e) {
                return CommonSettingChip(
                  text: e,
                  primaryColor: Theme.of(context).colorScheme.tertiary,
                  onDeleted: () {
                    SiteServices(ref: ref).removeType(typePrefKey, e);
                  },
                );
              }).toList();
            },
            loading: () => [const CommonProgressIndicator()],
            error: (e, _) => [Text('Error: $e')],
          ),
      labelText: 'Add $typeName type',
      hintText: 'Enter $typeName type',
      onPressed: () {
        SiteServices(ref: ref).addType(typePrefKey, controller.text.trim());
        controller.clear();
      },
      resetLabel: 'Match database $typeName types',
      onReset: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CommonAlertDialog(
                titleText: 'Match database $typeName types?',
                descText: 'Matching database types will'
                    ' delete all unused $typeName types',
                confirmFunction: () {
                  SiteServices(ref: ref).getAllTypes(typePrefKey);
                },
              );
            });
      },
    );
  }
}
