import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/collevent_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/providers/collevents.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/utility_services.dart';

enum EffortPopUpMenuItems { edit, delete }

class CollEffort extends StatelessWidget {
  const CollEffort({
    super.key,
    required this.collEventId,
  });

  final int collEventId;

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Effort',
      infoContent: const EffortInfoContent(),
      child: SizedBox(
        height: 402,
        child: CollEffortList(collEventId: collEventId),
      ),
    );
  }
}

class AddEffortButton extends StatelessWidget {
  const AddEffortButton({
    super.key,
    required this.collEventId,
  });

  final int collEventId;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewCollEffort(collEventId: collEventId),
          ),
        );
      },
      label: 'Add effort',
      icon: Icons.add,
    );
  }
}

class CollEffortList extends ConsumerStatefulWidget {
  const CollEffortList({
    super.key,
    required this.collEventId,
  });

  final int collEventId;

  @override
  CollEffortListState createState() => CollEffortListState();
}

class CollEffortListState extends ConsumerState<CollEffortList> {
  bool _isSelecting = false;
  final List<int> _selectedCollEfforts = [];

  @override
  Widget build(BuildContext context) {
    final collEffort = ref.watch(collEffortByEventProvider(widget.collEventId));
    ScrollController scrollController = ScrollController();
    return collEffort.when(
      data: (data) {
        return data.isEmpty
            ? EmptyEffort(collEventId: widget.collEventId)
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectItemsInterface(
                      isSelecting: _isSelecting,
                      onClearPressed: _selectedCollEfforts.isEmpty
                          ? null
                          : () {
                              setState(() {
                                _selectedCollEfforts.clear();
                              });
                            },
                      onSelectAllPressed: () {
                        setState(() {
                          _selectedCollEfforts.clear();
                          _selectedCollEfforts
                              .addAll(data.map((e) => e.id).toList());
                        });
                      },
                      onSelectPressed: () {
                        setState(() {
                          _isSelecting = !_isSelecting;
                          _selectedCollEfforts.clear();
                        });
                      }),
                  Flexible(
                    child: CommonScrollbar(
                      scrollController: scrollController,
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: scrollController,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return CollEffortTile(
                            collEffort: data[index],
                            isSelecting: _isSelecting,
                            selectedCollEfforts: _selectedCollEfforts,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedCollEfforts.add(data[index].id);
                                } else {
                                  _selectedCollEfforts.remove(data[index].id);
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
                      ? AddEffortButton(collEventId: widget.collEventId)
                      : DeleteItemsButton(
                          selectedItems: _selectedCollEfforts,
                          itemName: _selectedCollEfforts.length == 1
                              ? 'effort'
                              : 'efforts',
                          onPressedFunction: () async {
                            await _deleteCollEfforts();
                            setState(() {
                              _selectedCollEfforts.clear();
                            });
                          }),
                ],
              );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text(error.toString()),
    );
  }

  Future<void> _deleteCollEfforts() async {
    try {
      await CollEventServices(ref: ref)
          .deleteCollEffortFromList(_selectedCollEfforts);
      ref.invalidate(collEffortByEventProvider);
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 10),
    ));
  }
}

class EmptyEffort extends StatelessWidget {
  const EmptyEffort({
    super.key,
    required this.collEventId,
  });

  final int collEventId;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('No effort added'),
        const SizedBox(height: 8),
        AddEffortButton(collEventId: collEventId),
      ],
    );
  }
}

class NewCollEffort extends ConsumerWidget {
  const NewCollEffort({
    super.key,
    required this.collEventId,
  });

  final int collEventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collToolCtr = CollEffortCtrModel.empty();
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Method'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
          child: CollEffortForm(
        collEffortId: null,
        collEventId: collEventId,
        collToolCtr: collToolCtr,
      )),
    );
  }
}

class EditCollEffort extends ConsumerWidget {
  const EditCollEffort({
    super.key,
    required this.collEffortId,
    required this.collEventId,
    required this.collToolCtr,
  });

  final int collEffortId;
  final int collEventId;
  final CollEffortCtrModel collToolCtr;
  final bool isEditing = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Collecting Method'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: CollEffortForm(
          collEffortId: collEffortId,
          collEventId: collEventId,
          collToolCtr: collToolCtr,
          isEditing: true,
        ),
      ),
    );
  }
}

class CollEffortTile extends StatelessWidget {
  const CollEffortTile({
    super.key,
    required this.collEffort,
    required this.isSelecting,
    required this.selectedCollEfforts,
    required this.onChanged,
  });

  final CollEffortData collEffort;
  final bool isSelecting;
  final List<int> selectedCollEfforts;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: CollEffortTitle(
        type: collEffort.method,
        count: collEffort.count,
      ),
      subtitle: Subtitle(data: collEffort),
      leading: isSelecting
          ? ListCheckBox(
              isDisabled: false,
              value: selectedCollEfforts.contains(collEffort.id),
              onChanged: onChanged)
          : const SizedBox.shrink(),
      trailing: !isSelecting
          ? IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditCollEffort(
                        collEffortId: collEffort.id,
                        collEventId: collEffort.eventID!,
                        collToolCtr: CollEffortCtrModel.fromData(collEffort),
                      ),
                    ));
              },
            )
          : SizedBox.shrink(),
    );
  }
}

class CollEffortTitle extends StatelessWidget {
  const CollEffortTitle({
    super.key,
    required this.type,
    required this.count,
  });

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
  const Subtitle({
    super.key,
    required this.data,
  });

  final CollEffortData data;

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

class CollEffortForm extends ConsumerStatefulWidget {
  const CollEffortForm({
    super.key,
    required this.collEffortId,
    required this.collEventId,
    required this.collToolCtr,
    this.isEditing = false,
  });

  final int? collEffortId;
  final int collEventId;
  final CollEffortCtrModel collToolCtr;
  final bool isEditing;

  @override
  CollEffortFormState createState() => CollEffortFormState();
}

class CollEffortFormState extends ConsumerState<CollEffortForm> {
  @override
  Widget build(BuildContext context) {
    return ScrollableConstrainedLayout(
      child: Column(
        children: [
          CollectionMethods(ctr: widget.collToolCtr),
          CommonTextField(
            controller: widget.collToolCtr.brandCtr,
            labelText: 'Brand and Model',
            hintText: 'Enter brand and Model of the tool',
            isLastField: false,
          ),
          CommonNumField(
            controller: widget.collToolCtr.countCtr,
            labelText: 'Count',
            hintText: 'How many of this tool were used?',
            isLastField: false,
          ),
          CommonTextField(
            controller: widget.collToolCtr.sizeCtr,
            labelText: 'Size',
            hintText: 'Enter size of the tool (if applicable)',
            isLastField: false,
          ),
          CommonTextField(
            controller: widget.collToolCtr.noteCtr,
            maxLines: 3,
            labelText: 'Notes',
            hintText: 'Enter any notes about the tool (if applicable)',
            isLastField: true,
          ),
          const SizedBox(height: 20),
          FormButton(
            isEditing: widget.isEditing,
            onSubmitted: () {
              widget.isEditing ? _updateCollEffort() : _addCollEffort();
              ref.invalidate(collEffortByEventProvider);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateCollEffort() async {
    final form = _getForm();
    try {
      await CollEventServices(ref: ref)
          .updateCollEffortEntry(widget.collEffortId!, form);
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

  Future<void> _addCollEffort() async {
    final form = _getForm();
    await CollEventServices(ref: ref).createCollEffort(form);
  }

  CollEffortCompanion _getForm() {
    return CollEffortCompanion(
      eventID: db.Value(widget.collEventId),
      method: db.Value(widget.collToolCtr.methodCtr),
      brand: db.Value(widget.collToolCtr.brandCtr.text),
      count: db.Value(int.tryParse(widget.collToolCtr.countCtr.text) ?? 0),
      size: db.Value(widget.collToolCtr.sizeCtr.text),
      notes: db.Value(widget.collToolCtr.noteCtr.text),
    );
  }
}

class CollectionMethods extends ConsumerWidget {
  const CollectionMethods({
    super.key,
    required this.ctr,
  });

  final CollEffortCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(UserDefinedFieldProvider(collMethodPrefKey)).when(
          data: (data) {
            if (kDebugMode) {
              print('Collection Methods: $data');
            }
            return DropdownButtonFormField(
              initialValue: ctr.methodCtr,
              decoration: const InputDecoration(
                labelText: 'Method',
                hintText: 'Select a method',
              ),
              items: data
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
          error: (e, __) => Text(e.toString()),
        );
  }
}

class EffortInfoContent extends StatelessWidget {
  const EffortInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          content: 'Effort information for the event. '
              'This includes the method used, the brand and model of the tool, '
              'the count of the tool, the size of the tool, and any notes about the '
              'tool.',
        )
      ],
    );
  }
}
