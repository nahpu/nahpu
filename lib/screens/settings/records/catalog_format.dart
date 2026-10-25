import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/screens/shared/common/catalog_fmt_icon.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/localization/l10n.dart';

class CatalogFmtSelection extends ConsumerStatefulWidget {
  const CatalogFmtSelection({super.key});
  @override
  CatalogFmtSelectionState createState() => CatalogFmtSelectionState();
}

class CatalogFmtSelectionState extends ConsumerState<CatalogFmtSelection> {
  bool _isBatFieldsAlwaysShown = false;

  @override
  void initState() {
    _isBatFieldsAlwaysShown = SpecimenSettingServices(
      ref: ref,
    ).getSpecimenSettingField(batFieldsKey);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final services = SpecimenSettingServices(ref: ref);
    final l10n = context.l10n;

    return ref
        .watch(catalogFmtNotifierProvider)
        .when(
          data: (selectedFmt) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.recordsCatalogFormat)),
              body: CommonSettingList(
                sections: [
                  CommonSettingSection(
                    title: l10n.recordsCatalogFormat,
                    isDivided: true,
                    children: CatalogFmt.values.map((catalogFmt) {
                      String catalogFmtStr = catalogFmt.localizedLabel(l10n);
                      return CommonSettingTile(
                        title: catalogFmtStr,
                        titleBadge: isCatalogFmtBeta(catalogFmt)
                            ? const BetaBadge()
                            : null,
                        leading: CatalogFmtIcon(catalogFmt: catalogFmt),
                        trailing: selectedFmt == catalogFmt
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () {
                          ref
                              .read(catalogFmtNotifierProvider.notifier)
                              .set(catalogFmt);
                        },
                      );
                    }).toList(),
                  ),
                  Visibility(
                    visible: selectedFmt == CatalogFmt.mammalogy,
                    child: CommonSettingSection(
                      title: l10n.recordsCatalogMeasurementRecords,
                      children: [
                        SwitchSettings(
                          value: _isBatFieldsAlwaysShown,
                          label: l10n.recordsCatalogAlwaysShowBatFields,
                          onChanged: (bool value) async {
                            try {
                              await services.setSpecimenSettingField(
                                batFieldsKey,
                                value,
                              );
                              setState(() {
                                _isBatFieldsAlwaysShown = value;
                              });
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 4, 8),
                          child: Text(
                            l10n.recordsCatalogBatFieldsNote,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
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
          error: (e, _) => Text(e.toString()),
        );
  }
}
