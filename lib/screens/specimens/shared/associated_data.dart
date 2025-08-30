import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/file_operation.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/io_services.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/utility_services.dart';
import 'package:path/path.dart' as path;

class AssociatedDataViewer extends ConsumerStatefulWidget {
  const AssociatedDataViewer({
    super.key,
    required this.specimenUuid,
  });

  final String specimenUuid;

  @override
  AssociatedDataViewerState createState() => AssociatedDataViewerState();
}

class AssociatedDataViewerState extends ConsumerState<AssociatedDataViewer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const TitleForm(
            text: 'Associated Data', infoContent: AssociateDataInfo()),
        SizedBox(
          height: 450,
          child: AssociatedDataList(
            specimenUuid: widget.specimenUuid,
          ),
        )
      ],
    );
  }
}

class AssociatedDataList extends ConsumerStatefulWidget {
  const AssociatedDataList({
    super.key,
    required this.specimenUuid,
  });

  final String specimenUuid;

  @override
  AssociatedDataListState createState() => AssociatedDataListState();
}

class AssociatedDataListState extends ConsumerState<AssociatedDataList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final associatedDataList = ref.watch(
      associatedDataProvider(specimenUuid: widget.specimenUuid),
    );
    return associatedDataList.when(
      data: (data) {
        return data.isEmpty
            ? EmptyAssociatedData(specimenUuid: widget.specimenUuid)
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: CommonScrollbar(
                      scrollController: _scrollController,
                      child: ListView.builder(
                          controller: _scrollController,
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return AssociateDataItem(
                              specimenUuid: widget.specimenUuid,
                              data: data[index],
                            );
                          }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AddAssociatedButton(specimenUuid: widget.specimenUuid)
                ],
              );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

class AssociateDataItem extends StatelessWidget {
  const AssociateDataItem({
    super.key,
    required this.specimenUuid,
    required this.data,
  });

  final String specimenUuid;
  final AssociatedDataData data;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(data.name ?? 'No name'),
      subtitle: Text(
        _subtitle,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditAssociatedData(
                  specimenUuid: specimenUuid,
                  associatedDataId: data.primaryId,
                  ctr: AssociatedDataCtr.fromData(data)),
            ),
          );
        },
      ),
    );
  }

  String get _subtitle {
    final type = data.type ?? '';
    final date = _getText(data.date);
    return '$type$date';
  }

  String _getText(String? text) {
    if (text == null) {
      return '';
    } else if (text.isEmpty) {
      return '';
    } else {
      return '$listTileSeparator$text';
    }
  }
}

class AddAssociatedButton extends StatelessWidget {
  const AddAssociatedButton({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: 'Add Associated Data',
      icon: Icons.add,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewAssociatedData(
              specimenUuid: specimenUuid,
            ),
          ),
        );
      },
    );
  }
}

class EmptyAssociatedData extends StatelessWidget {
  const EmptyAssociatedData({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('No associated data added'),
        const SizedBox(height: 8),
        AddAssociatedButton(specimenUuid: specimenUuid)
      ],
    );
  }
}

class EditAssociatedData extends StatelessWidget {
  const EditAssociatedData({
    super.key,
    required this.specimenUuid,
    required this.associatedDataId,
    required this.ctr,
  });

  final String specimenUuid;
  final int? associatedDataId;
  final AssociatedDataCtr ctr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit specimen parts'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: AssociatedDataForm(
          specimenUuid: specimenUuid,
          associatedDataId: associatedDataId,
          ctr: ctr,
          isEditing: true,
        ),
      ),
    );
  }
}

class NewAssociatedData extends StatelessWidget {
  const NewAssociatedData({
    super.key,
    required this.specimenUuid,
  });

  final String specimenUuid;

  @override
  Widget build(BuildContext context) {
    final associatedDataCtr = AssociatedDataCtr.empty();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Associated Data'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: AssociatedDataForm(
          specimenUuid: specimenUuid,
          ctr: associatedDataCtr,
          isEditing: false,
        ),
      ),
    );
  }
}

class AssociatedDataForm extends ConsumerStatefulWidget {
  const AssociatedDataForm({
    super.key,
    required this.specimenUuid,
    this.associatedDataId,
    required this.ctr,
    required this.isEditing,
  });

  final String specimenUuid;
  final int? associatedDataId;
  final AssociatedDataCtr ctr;
  final bool isEditing;

  @override
  AssociatedDataFormState createState() => AssociatedDataFormState();
}

class AssociatedDataFormState extends ConsumerState<AssociatedDataForm> {
  final List<String> dataOptions = ['Link', 'File'];
  XFile? _filePath;
  bool _isLoading = false;

  @override
  void dispose() {
    widget.ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableConstrainedLayout(
      child: Column(
        children: [
          DropdownButtonFormField(
            decoration: const InputDecoration(
              labelText: 'Data Type',
              hintText: 'Select data type',
            ),
            initialValue: widget.ctr.typeCtr,
            items: dataOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                widget.ctr.typeCtr = newValue;
              });
            },
          ),
          CommonTextField(
            labelText: 'Name',
            hintText: 'e.g., GenBank, MorphoSource, etc.',
            controller: widget.ctr.nameCtr,
            isLastField: false,
          ),
          CommonTextField(
            labelText: 'Description',
            hintText: 'e.g., GenBank accession number',
            controller: widget.ctr.descriptionCtr,
            isLastField: false,
          ),
          CommonDateField(
            labelText: 'Date',
            hintText: 'Enter date',
            controller: widget.ctr.dateCtr,
            initialDate: DateTime.now(),
            lastDate: DateTime.now(),
            onTap: () {},
          ),
          Visibility(
            visible: widget.ctr.typeCtr == 'Link',
            child: CommonTextField(
              labelText: 'URL',
              hintText: 'e.g., https://www.ncbi.nlm.nih.gov/genbank/',
              controller: widget.ctr.urlCtr,
              isLastField: false,
            ),
          ),
          const SizedBox(height: 12),
          Visibility(
              visible: widget.ctr.typeCtr == 'File',
              child: widget.ctr.urlCtr.text.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.file_present,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          path.basename(widget.ctr.urlCtr.text),
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            setState(() {
                              widget.ctr.urlCtr.text = '';
                            });
                          },
                        )
                      ],
                    )
                  : SelectFileField(
                      filePath: _filePath,
                      isLoading: _isLoading,
                      width: double.infinity,
                      maxWidth: double.infinity,
                      onCleared: () {
                        setState(() {
                          _filePath = null;
                        });
                      },
                      onPressed: () {
                        _getFile();
                      },
                    )),
          const SizedBox(height: 16),
          FormButtonWithDelete(
            isEditing: widget.isEditing,
            onDeleted: () async {
              if (widget.associatedDataId != null) {
                await AssociatedDataServices(ref: ref)
                    .deleteAssociatedData(widget.associatedDataId!);
                if (context.mounted) Navigator.pop(context);
              }
            },
            onSubmitted: () async {
              if (widget.isEditing) {
                try {
                  await _updateData();
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                      ),
                    );
                  }
                }
              } else {
                try {
                  await _createData();
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                      ),
                    );
                  }
                }
              }
            },
          )
        ],
      ),
    );
  }

  Future<void> _createData() async {
    final data = _getForm();
    await AssociatedDataServices(ref: ref).createAssociatedData(data);
  }

  Future<void> _updateData() async {
    final data = _getForm();
    final service = AssociatedDataServices(ref: ref);
    try {
      await service.updateAssociatedData(widget.associatedDataId!, data);
      if (_filePath != null) {
        final path =
            await service.copyAssociatedDataFile(File(_filePath!.path));
        if (context.mounted) {
          _showPath(path);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(e.toString());
      }
    }
  }

  void _showPath(File path) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File copied to $path'),
      ),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $error'),
      ),
    );
  }

  AssociatedDataCompanion _getForm() {
    widget.ctr.urlCtr.text = _filePath != null
        ? path.basename(_filePath!.path)
        : widget.ctr.urlCtr.text;

    return AssociatedDataCompanion(
      specimenUuid: db.Value(widget.specimenUuid),
      name: db.Value(widget.ctr.nameCtr.text),
      type: db.Value(widget.ctr.typeCtr),
      date: db.Value(widget.ctr.dateCtr.text),
      description: db.Value(widget.ctr.descriptionCtr.text),
      url: db.Value(widget.ctr.urlCtr.text),
    );
  }

  Future<void> _getFile() async {
    setState(() {
      _isLoading = true;
    });
    XFile? file = await FilePickerServices().selectAnyFile();
    if (file != null) {
      setState(() {
        _filePath = file;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class AssociateDataInfo extends StatelessWidget {
  const AssociateDataInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          header: 'Overview',
          content: 'Associated data of the project. It includes data, such as '
              'the GenBank accession number and other digital data associated with the specimen.',
        ),
        InfoContent(
          content:
              'Some of digital data can also be added in the specimen part or media sections.'
              ' Use the associated data section to add data '
              'that is not covered in other sections.',
        )
      ],
    );
  }
}
