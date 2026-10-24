import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/events/collevent_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/events.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/localization/l10n.dart';

enum CollMethodPopUpMenuItems { edit, delete }

class CollMethodSection extends StatelessWidget {
  const CollMethodSection({super.key, required this.collEventId});

  final int collEventId;

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Collection methods',
      infoTopic: InfoTopic.eventMethods,
      child: SizedBox(
        height: 484,
        child: CollMethodList(collEventId: collEventId),
      ),
    );
  }
}

class AddCollMethodButton extends StatelessWidget {
  const AddCollMethodButton({super.key, required this.collEventId});

  final int collEventId;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewCollMethod(collEventId: collEventId),
          ),
        );
      },
      label: 'Add collection method',
      icon: Icons.add,
    );
  }
}

class CollMethodList extends ConsumerStatefulWidget {
  const CollMethodList({super.key, required this.collEventId});

  final int collEventId;

  @override
  CollMethodListState createState() => CollMethodListState();
}

class CollMethodListState extends ConsumerState<CollMethodList> {
  bool _isSelecting = false;
  final List<int> _selectedCollMethods = [];

  @override
  Widget build(BuildContext context) {
    final collMethod = ref.watch(collMethodByEventProvider(widget.collEventId));
    ScrollController scrollController = ScrollController();
    return collMethod.when(
      data: (data) {
        return data.isEmpty
            ? EmptyCollMethod(collEventId: widget.collEventId)
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectItemsInterface(
                    isSelecting: _isSelecting,
                    onClearPressed: _selectedCollMethods.isEmpty
                        ? null
                        : () {
                            setState(() {
                              _selectedCollMethods.clear();
                            });
                          },
                    onSelectAllPressed: () {
                      setState(() {
                        _selectedCollMethods.clear();
                        _selectedCollMethods.addAll(
                          data.map((e) => e.id).toList(),
                        );
                      });
                    },
                    onSelectPressed: () {
                      setState(() {
                        _isSelecting = !_isSelecting;
                        _selectedCollMethods.clear();
                      });
                    },
                  ),
                  Flexible(
                    child: CommonScrollbar(
                      scrollController: scrollController,
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: scrollController,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return CollMethodTile(
                            collMethod: data[index],
                            isSelecting: _isSelecting,
                            selectedCollMethods: _selectedCollMethods,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedCollMethods.add(data[index].id);
                                } else {
                                  _selectedCollMethods.remove(data[index].id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  !_isSelecting
                      ? AddCollMethodButton(collEventId: widget.collEventId)
                      : DeleteItemsButton(
                          selectedItems: _selectedCollMethods,
                          customIconButtonText: context.l10n
                              .deleteCollMethodsCount(
                                _selectedCollMethods.length,
                              ),
                          customDialogHeader: context.l10n
                              .deleteCollMethodsTitle(
                                _selectedCollMethods.length,
                              ),
                          customDialogText: context.l10n.deleteCollMethodsBody(
                            _selectedCollMethods.length,
                          ),
                          onPressedFunction: () async {
                            await _deleteCollMethods();
                            setState(() {
                              _selectedCollMethods.clear();
                            });
                          },
                        ),
                ],
              );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text(error.toString()),
    );
  }

  Future<void> _deleteCollMethods() async {
    try {
      await CollEventServices(
        ref: ref,
      ).deleteCollMethodFromList(_selectedCollMethods);
      ref.invalidate(collMethodByEventProvider);
      setState(() {
        _isSelecting = false;
      });
      if (context.mounted) {
        _pop();
      }
    } catch (e) {
      if (context.mounted) {
        _showError(e.toString());
      }
    }
  }

  void _pop() {
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 10)),
    );
  }
}

class EmptyCollMethod extends StatelessWidget {
  const EmptyCollMethod({super.key, required this.collEventId});

  final int collEventId;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('No collection methods added'),
        const SizedBox(height: 8),
        AddCollMethodButton(collEventId: collEventId),
      ],
    );
  }
}

class NewCollMethod extends ConsumerWidget {
  const NewCollMethod({super.key, required this.collEventId});

  final int collEventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collMethodCtr = CollMethodCtrModel.empty();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Collection Method'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: CollMethodForm(
          collMethodId: null,
          collEventId: collEventId,
          collMethodCtr: collMethodCtr,
        ),
      ),
    );
  }
}

class EditCollMethod extends ConsumerWidget {
  const EditCollMethod({
    super.key,
    required this.collMethodId,
    required this.collEventId,
    required this.collMethodCtr,
  });

  final int collMethodId;
  final int collEventId;
  final CollMethodCtrModel collMethodCtr;
  final bool isEditing = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Collection Method'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: CollMethodForm(
          collMethodId: collMethodId,
          collEventId: collEventId,
          collMethodCtr: collMethodCtr,
          isEditing: true,
        ),
      ),
    );
  }
}

class CollMethodTile extends StatelessWidget {
  const CollMethodTile({
    super.key,
    required this.collMethod,
    required this.isSelecting,
    required this.selectedCollMethods,
    required this.onChanged,
  });

  final CollMethodData collMethod;
  final bool isSelecting;
  final List<int> selectedCollMethods;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: CollMethodTitle(type: collMethod.method, count: collMethod.count),
      subtitle: Subtitle(data: collMethod),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          !isSelecting
              ? CollMethodTileIcon(method: collMethod.method)
              : ListCheckBox(
                  isDisabled: false,
                  value: selectedCollMethods.contains(collMethod.id),
                  onChanged: onChanged,
                ),
        ],
      ),
      trailing: !isSelecting
          ? IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditCollMethod(
                      collMethodId: collMethod.id,
                      collEventId: collMethod.eventID!,
                      collMethodCtr: CollMethodCtrModel.fromData(collMethod),
                    ),
                  ),
                );
              },
            )
          : SizedBox.shrink(),
    );
  }
}

class CollMethodTileIcon extends StatelessWidget {
  const CollMethodTileIcon({super.key, required this.method});

  final String? method;

  @override
  Widget build(BuildContext context) {
    return TileSvgIcon(iconPath: CollMethodIcon.fromMethod(method).iconPath);
  }
}

class CollMethodTitle extends StatelessWidget {
  const CollMethodTitle({super.key, required this.type, required this.count});

  final String? type;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${type ?? 'Unknown'}'
      '$listTileSeparator'
      '${count ?? 'No count'}',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class Subtitle extends StatelessWidget {
  const Subtitle({super.key, required this.data});

  final CollMethodData data;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_getSize()}'
      '$listTileSeparator'
      '${_getBrand()}',
    );
  }

  String _getBrand() {
    if (data.brand == null || data.brand!.isEmpty) {
      return 'Unknown';
    } else {
      return data.brand!;
    }
  }

  String _getSize() {
    if (data.size == null || data.size!.isEmpty) {
      return 'N/A';
    } else {
      return data.size!;
    }
  }
}

class CollMethodForm extends ConsumerStatefulWidget {
  const CollMethodForm({
    super.key,
    required this.collMethodId,
    required this.collEventId,
    required this.collMethodCtr,
    this.isEditing = false,
  });

  final int? collMethodId;
  final int collEventId;
  final CollMethodCtrModel collMethodCtr;
  final bool isEditing;

  @override
  CollMethodFormState createState() => CollMethodFormState();
}

class CollMethodFormState extends ConsumerState<CollMethodForm> {
  @override
  Widget build(BuildContext context) {
    return ScrollableConstrainedLayout(
      child: Column(
        children: [
          FormSection(
            title: 'Collection method',
            child: Column(
              children: [
                CollMethodDropdown(ctr: widget.collMethodCtr),
                CommonNumField(
                  controller: widget.collMethodCtr.countCtr,
                  labelText: 'Count',
                  hintText: 'How many of this tool were used (if applicable)?',
                  isLastField: false,
                ),
              ],
            ),
          ),
          FormSection(
            title: 'Method details',
            child: Column(
              children: [
                CommonTextField(
                  controller: widget.collMethodCtr.brandCtr,
                  labelText: 'Brand and Model',
                  hintText: 'Enter brand and model of the tool (if applicable)',
                  isLastField: false,
                ),
                CommonTextField(
                  controller: widget.collMethodCtr.sizeCtr,
                  labelText: 'Size',
                  hintText: 'Enter size of the tool (if applicable)',
                  isLastField: false,
                ),
                CommonTextField(
                  controller: widget.collMethodCtr.noteCtr,
                  maxLines: 3,
                  labelText: 'Notes',
                  hintText: 'Enter any notes about the tool (if applicable)',
                  isLastField: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FormButton(
            isEditing: widget.isEditing,
            onSubmitted: () {
              widget.isEditing ? _updateCollMethod() : _addCollMethod();
              ref.invalidate(collMethodByEventProvider);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateCollMethod() async {
    final form = _getForm();
    try {
      await CollEventServices(
        ref: ref,
      ).updateCollMethodEntry(widget.collMethodId!, form);
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _addCollMethod() async {
    final form = _getForm();
    await CollEventServices(ref: ref).createCollMethod(form);
  }

  CollMethodCompanion _getForm() {
    return CollMethodCompanion(
      eventID: db.Value(widget.collEventId),
      method: db.Value(widget.collMethodCtr.methodCtr),
      brand: db.Value(widget.collMethodCtr.brandCtr.text),
      count: db.Value(int.tryParse(widget.collMethodCtr.countCtr.text) ?? 0),
      size: db.Value(widget.collMethodCtr.sizeCtr.text),
      notes: db.Value(widget.collMethodCtr.noteCtr.text),
    );
  }
}

class CollMethodDropdown extends ConsumerWidget {
  const CollMethodDropdown({super.key, required this.ctr});

  final CollMethodCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(effectiveUserDefinedFieldProvider(collMethodPrefKey))
        .when(
          data: (data) {
            final options = includeCurrentVocabularyValue(data, ctr.methodCtr);
            if (kDebugMode) {
              print('Collection method options: $data');
            }
            return DropdownButtonFormField(
              initialValue: ctr.methodCtr,
              decoration: const InputDecoration(
                labelText: 'Method',
                hintText: 'Select a method',
              ),
              items: options
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: CommonDropdownText(text: e),
                    ),
                  )
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ctr.methodCtr = newValue;
                }
              },
            );
          },
          loading: () => const CommonProgressIndicator(),
          error: (e, _) => Text(e.toString()),
        );
  }
}
