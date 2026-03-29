import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/types/specimens.dart';

class CatalogFmtSelection extends ConsumerStatefulWidget {
  const CatalogFmtSelection({super.key});
  @override
  CatalogFmtSelectionState createState() => CatalogFmtSelectionState();
}

class CatalogFmtSelectionState extends ConsumerState<CatalogFmtSelection> {
  bool _isBatFieldsAlwaysShown = false;

  @override
  void initState() {
    _isBatFieldsAlwaysShown =
        SpecimenSettingServices(ref: ref).getSpecimenSettingField(batFieldsKey);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final services = SpecimenSettingServices(ref: ref);

    return ref.watch(catalogFmtNotifierProvider).when(
        data: (selectedFmt) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Catalog Format'),
            ),
            body: CommonSettingList(
              sections: [
                CommonSettingSection(
                    title: 'Catalog Format',
                    isDivided: true,
                    children: CatalogFmt.values.map((catalogFmt) {
                      String catalogFmtStr =
                          matchCatFmtToTaxonGroup(catalogFmt);
                      return CommonSettingTile(
                          title: catalogFmtStr,
                          icon: matchCatFmtToPartIcon(catalogFmt),
                          trailing: selectedFmt == catalogFmt
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () {
                            ref
                                .read(catalogFmtNotifierProvider.notifier)
                                .set(catalogFmt);
                          });
                    }).toList()),
                Visibility(
                  visible: selectedFmt == CatalogFmt.mammals,
                  child: CommonSettingSection(
                    title: 'Measurement records',
                    children: [
                      SwitchSettings(
                        value: _isBatFieldsAlwaysShown,
                        label: 'Always show bat fields',
                        onChanged: (bool value) async {
                          try {
                            await services.setSpecimenSettingField(
                                batFieldsKey, value);
                            setState(() {
                              _isBatFieldsAlwaysShown = value;
                            });
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 4, 8),
                        child: Text(
                          'If enabled, fields specific to bats are always '
                          'shown in the mammal measurement fields. '
                          'You can also choose to toggle the visibility of '
                          'bat-specific fields for each specimen record '
                          'in the specimen record screen.',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const CommonProgressIndicator(),
        error: (e, __) => Text(e.toString()));
  }
}
