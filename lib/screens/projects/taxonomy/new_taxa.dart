import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/taxonomy_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:flutter/services.dart';
import 'package:nahpu/services/types/export.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/utility_services.dart';

class TaxonRegistryLayout extends StatelessWidget {
  const TaxonRegistryLayout({
    super.key,
    required this.children,
  });
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool viewRow = constraints.maxWidth > 400;
      return viewRow
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            )
          : SliderView(items: children);
    });
  }
}

class SliderView extends StatelessWidget {
  const SliderView({super.key, required this.items});

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      itemExtent: 340,
      children: items,
    );
  }
}

class NewTaxon extends StatelessWidget {
  const NewTaxon({super.key});

  @override
  Widget build(BuildContext context) {
    final TaxonRegistryCtrModel ctr = TaxonRegistryCtrModel.empty();
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Taxon'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: TaxonRegistryForm(
            taxonId: null,
            ctr: ctr,
            isEditing: false,
          ),
        ),
      ),
    );
  }
}

class EditTaxon extends StatelessWidget {
  const EditTaxon({
    super.key,
    required this.taxonId,
    required this.ctr,
  });

  final int taxonId;
  final TaxonRegistryCtrModel ctr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Taxon'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: TaxonRegistryForm(
            taxonId: taxonId,
            ctr: ctr,
            isEditing: true,
          ),
        ),
      ),
    );
  }
}

class TaxonRegistryForm extends ConsumerStatefulWidget {
  const TaxonRegistryForm(
      {super.key,
      required this.taxonId,
      required this.ctr,
      required this.isEditing});

  final int? taxonId;
  final TaxonRegistryCtrModel ctr;
  final bool isEditing;

  @override
  TaxonRegistryFormState createState() => TaxonRegistryFormState();
}

class TaxonRegistryFormState extends ConsumerState<TaxonRegistryForm> {
  bool _isShowMore = false;

  @override
  void dispose() {
    widget.ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableConstrainedLayout(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String?>(
              decoration: const InputDecoration(
                labelText: 'Class',
                hintText: 'Select a taxon class',
              ),
              initialValue: widget.ctr.taxonClassCtr,
              items: supportedTaxonClass
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    widget.ctr.taxonClassCtr = value;
                  });
                }
              }),
          TextField(
              controller: widget.ctr.taxonOrderCtr,
              decoration: const InputDecoration(
                labelText: 'Order',
                hintText: 'Enter an order',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z]+'),
                ),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  widget.ctr.taxonOrderCtr.value = TextEditingValue(
                    text: value.toSentenceCase(),
                    selection: widget.ctr.taxonOrderCtr.selection,
                  );
                }
              }),
          TextField(
            controller: widget.ctr.taxonFamilyCtr,
            decoration: const InputDecoration(
              labelText: 'Family',
              hintText: 'Enter a family',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z]+'),
              ),
            ],
            onChanged: (String? value) {
              if (value != null) {
                widget.ctr.taxonFamilyCtr.value = TextEditingValue(
                  text: value.toSentenceCase(),
                  selection: widget.ctr.taxonFamilyCtr.selection,
                );
              }
            },
          ),
          TextField(
            controller: widget.ctr.genusCtr,
            decoration: const InputDecoration(
              labelText: 'Genus',
              hintText: 'Enter a genus',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z]+'),
              ),
            ],
            onChanged: (String? value) {
              if (value != null) {
                widget.ctr.genusCtr.value = TextEditingValue(
                  text: value.toSentenceCase(),
                  selection: widget.ctr.genusCtr.selection,
                );
              }
            },
          ),
          TextField(
            controller: widget.ctr.specificEpithetCtr,
            decoration: const InputDecoration(
              labelText: 'Specific epithet',
              hintText: 'Enter specific epithet',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z]+'),
              ),
            ],
            onChanged: (String? value) {
              if (value != null) {
                widget.ctr.specificEpithetCtr.value = TextEditingValue(
                  text: value.toLowerCase(),
                  selection: widget.ctr.specificEpithetCtr.selection,
                );
              }
            },
          ),
          Visibility(
            visible: _isShowMore || widget.ctr.authorCtr.text.isNotEmpty,
            child: CommonTextField(
              controller: widget.ctr.authorCtr,
              labelText: 'Authors',
              hintText: 'Enter authors',
              isLastField: false,
            ),
          ),
          Visibility(
            visible: _isShowMore || widget.ctr.commonNameCtr.text.isNotEmpty,
            child: CommonTextField(
              controller: widget.ctr.commonNameCtr,
              labelText: 'Common name',
              hintText: 'Enter a common name',
              isLastField: false,
              onChanged: (String? value) {
                if (value != null) {
                  widget.ctr.commonNameCtr.value = TextEditingValue(
                    text: value.toSentenceCase(),
                    selection: widget.ctr.commonNameCtr.selection,
                  );
                }
              },
            ),
          ),
          Visibility(
            visible:
                _isShowMore || widget.ctr.redListCategoryCtr.text.isNotEmpty,
            child: CommonTextField(
              controller: widget.ctr.redListCategoryCtr,
              labelText: 'IUCN RedList Category',
              hintText: 'e.g. Endangered, Vulnerable, etc.',
              isLastField: false,
              onChanged: (String? value) {
                if (value != null) {
                  widget.ctr.redListCategoryCtr.value = TextEditingValue(
                    text: value.toSentenceCase(),
                    selection: widget.ctr.redListCategoryCtr.selection,
                  );
                }
              },
            ),
          ),
          Visibility(
            visible: _isShowMore || widget.ctr.citesCtr.text.isNotEmpty,
            child: CommonTextField(
              controller: widget.ctr.citesCtr,
              labelText: 'CITES Status',
              hintText: 'e.g. Appendix I, Appendix II, Non-CITES, etc.',
              isLastField: false,
              onChanged: (String? value) {
                if (value != null) {
                  widget.ctr.citesCtr.value = TextEditingValue(
                    text: value.toSentenceCase(),
                    selection: widget.ctr.citesCtr.selection,
                  );
                }
              },
            ),
          ),
          Visibility(
            visible: _isShowMore || widget.ctr.countryStatusCtr.text.isNotEmpty,
            child: CommonTextField(
              controller: widget.ctr.countryStatusCtr,
              labelText: 'Country conservation status',
              hintText: 'e.g. Protected, common, etc.',
              isLastField: false,
            ),
          ),
          Visibility(
            visible: _isShowMore || widget.ctr.sortingOrderCtr.text.isNotEmpty,
            child: CommonNumField(
              controller: widget.ctr.sortingOrderCtr,
              labelText: 'Sorting order',
              hintText: 'E.g., 1, 2, 3, etc.',
              isLastField: false,
            ),
          ),
          Visibility(
            visible: _isShowMore || widget.ctr.noteCtr.text.isNotEmpty,
            child: CommonTextField(
              controller: widget.ctr.noteCtr,
              labelText: 'Notes',
              hintText: 'Enter notes',
              maxLines: 3,
              isLastField: false,
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isShowMore = !_isShowMore;
              });
            },
            child: Text(_isShowMore ? 'Show less' : 'Show more'),
          ),
          const SizedBox(height: 16),
          FormButtonWithDelete(
            isEditing: widget.isEditing,
            onDeleted: () async {
              try {
                await _deleteTaxon();
                ref.invalidate(taxonRegistryProvider);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot delete taxon.'
                          ' It is in use in the specimen records.'),
                    ),
                  );
                }
              }
            },
            onSubmitted: () async {
              widget.isEditing ? await _updateTaxon() : await _createTaxon();
              ref.invalidate(taxonRegistryProvider);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _createTaxon() async {
    final taxon = _getForm();
    await TaxonomyServices(ref: ref).createTaxon(taxon);
  }

  Future<void> _updateTaxon() async {
    final taxon = _getForm();
    await TaxonomyServices(ref: ref).updateTaxonEntry(widget.taxonId!, taxon);
  }

  TaxonomyCompanion _getForm() {
    return TaxonomyCompanion(
      taxonClass: db.Value(widget.ctr.taxonClassCtr),
      taxonOrder: db.Value(widget.ctr.taxonOrderCtr.text),
      taxonFamily: db.Value(widget.ctr.taxonFamilyCtr.text),
      genus: db.Value(widget.ctr.genusCtr.text),
      specificEpithet: db.Value(widget.ctr.specificEpithetCtr.text),
      authors: db.Value(widget.ctr.authorCtr.text),
      commonName: db.Value(widget.ctr.commonNameCtr.text),
      redListCategory: db.Value(widget.ctr.redListCategoryCtr.text),
      citesStatus: db.Value(widget.ctr.citesCtr.text),
      countryStatus: db.Value(widget.ctr.countryStatusCtr.text),
      sortingOrder: db.Value(int.tryParse(widget.ctr.sortingOrderCtr.text)),
      notes: db.Value(widget.ctr.noteCtr.text),
    );
  }

  Future<void> _deleteTaxon() async {
    await TaxonomyServices(ref: ref).deleteTaxon(widget.taxonId!);
  }
}
