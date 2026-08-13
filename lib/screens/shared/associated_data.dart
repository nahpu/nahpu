import 'dart:io';

import 'package:drift/drift.dart' as db;
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/file/file_operation.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/associated_data/associated_data_services.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/associated_data.dart';
import 'package:nahpu/services/types/associated_data.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

const double associatedDataCompactBreakpoint = 600;

class AssociatedDataViewer extends StatelessWidget {
  const AssociatedDataViewer({super.key, required this.target});

  final AssociatedDataTarget target;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const TitleForm(
          text: 'Associated Data',
          infoContent: AssociatedDataInfoContent(),
        ),
        SizedBox(height: 450, child: AssociatedDataList(target: target)),
      ],
    );
  }
}

class AssociatedDataList extends ConsumerStatefulWidget {
  const AssociatedDataList({super.key, required this.target});

  final AssociatedDataTarget target;

  @override
  ConsumerState<AssociatedDataList> createState() => _AssociatedDataListState();
}

class _AssociatedDataListState extends ConsumerState<AssociatedDataList> {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _selected = {};
  bool _isSelecting = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(associatedDataProvider(widget.target))
        .when(
          data: (data) {
            _pruneSelection(data);
            if (data.isEmpty) {
              return EmptyAssociatedData(target: widget.target);
            }
            return Column(
              children: [
                SelectItemsInterface(
                  isSelecting: _isSelecting,
                  onClearPressed: _selected.isEmpty
                      ? null
                      : () => setState(_selected.clear),
                  onSelectAllPressed: () {
                    setState(() {
                      _selected
                        ..clear()
                        ..addAll(
                          data.map((item) => item.primaryId).whereType<int>(),
                        );
                    });
                  },
                  onSelectPressed: () {
                    setState(() {
                      _isSelecting = !_isSelecting;
                      _selected.clear();
                    });
                  },
                ),
                Flexible(
                  child: CommonScrollbar(
                    scrollController: _scrollController,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return AssociatedDataItem(
                          target: widget.target,
                          data: item,
                          isSelecting: _isSelecting,
                          isSelected: _selected.contains(item.primaryId),
                          onSelectionChanged: (selected) {
                            setState(() {
                              final id = item.primaryId;
                              if (id == null) return;
                              if (selected) {
                                _selected.add(id);
                              } else {
                                _selected.remove(id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_isSelecting)
                  DeleteItemsButton(
                    selectedItems: _selected.toList(),
                    itemName: _selected.length == 1
                        ? 'associated data entry'
                        : 'associated data entries',
                    customIconButtonText:
                        'Remove ${_selected.length} associated data '
                        '${_selected.length == 1 ? 'entry' : 'entries'}',
                    customDialogHeader: 'Remove associated data',
                    customDialogText:
                        'Remove the selected associated data from this record? '
                        'Data shared with other records will be preserved.',
                    customDialogButtonText: 'Remove',
                    onPressedFunction: _removeSelected,
                  )
                else
                  AddAssociatedDataButton(target: widget.target),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
  }

  void _pruneSelection(List<AssociatedDataData> data) {
    final available = data.map((item) => item.primaryId).toSet();
    _selected.removeWhere((id) => !available.contains(id));
  }

  Future<void> _removeSelected() async {
    try {
      final service = AssociatedDataServices(ref: ref);
      for (final id in _selected.toList()) {
        await service.detachFromTarget(id, widget.target);
      }
      if (mounted) {
        setState(() {
          _selected.clear();
          _isSelecting = false;
        });
        // DeleteItemsButton opens its confirmation dialog on the root
        // navigator. Close that dialog explicitly so the containing record
        // page remains visible, including when the record is hosted in a
        // nested navigator.
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}

class AssociatedDataItem extends StatelessWidget {
  const AssociatedDataItem({
    super.key,
    required this.target,
    required this.data,
    required this.isSelecting,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  final AssociatedDataTarget target;
  final AssociatedDataData data;
  final bool isSelecting;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        onTap: isSelecting ? () => onSelectionChanged(!isSelected) : null,
        leading: isSelecting
            ? ListCheckBox(
                isDisabled: false,
                value: isSelected,
                onChanged: (value) => onSelectionChanged(value ?? false),
              )
            : AssociatedDataLeadingIcon(data: data),
        title: Text(_title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: AssociatedDataSubtitle(data: data),
        trailing: isSelecting
            ? null
            : AssociatedDataActions(target: target, data: data),
      ),
    );
  }

  String get _title {
    final name = data.name?.trim() ?? '';
    if (name.isNotEmpty) return name;
    final resource = data.uri?.trim() ?? '';
    if (resource.isNotEmpty) {
      if (data.type == 'File') {
        final uri = Uri.tryParse(resource);
        return path.basename(uri?.scheme == 'file' ? uri!.path : resource);
      }
      return Uri.tryParse(resource)?.host.isNotEmpty == true
          ? Uri.parse(resource).host
          : resource;
    }
    return 'Unnamed associated data';
  }
}

class AssociatedDataLeadingIcon extends ConsumerWidget {
  const AssociatedDataLeadingIcon({super.key, required this.data});

  final AssociatedDataData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox.square(
      dimension: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(data.type == 'File' ? Icons.description_outlined : Icons.link),
          if (data.type == 'File')
            FutureBuilder<bool>(
              future: _exists(ref),
              builder: (context, snapshot) {
                if (snapshot.data != false) return const SizedBox.shrink();
                return Positioned(
                  right: 0,
                  bottom: 0,
                  child: Tooltip(
                    message: 'File unavailable',
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<bool> _exists(WidgetRef ref) async {
    try {
      final file = await AssociatedDataServices(ref: ref).resolveFile(data);
      return file.existsSync();
    } catch (_) {
      return false;
    }
  }
}

class AssociatedDataSubtitle extends StatelessWidget {
  const AssociatedDataSubtitle({super.key, required this.data});

  final AssociatedDataData data;

  @override
  Widget build(BuildContext context) {
    final resource = data.uri?.trim() ?? '';
    return Row(
      children: [
        Text(data.type ?? 'Unknown type'),
        const Text(' · '),
        Expanded(
          child: Tooltip(
            message: resource.isEmpty ? 'No resource' : resource,
            child: Text(
              _compactResource(resource),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  String _compactResource(String resource) {
    if (resource.isEmpty) return 'No resource';
    final uri = Uri.tryParse(resource);
    if (data.type == 'File') {
      return path.basename(uri?.scheme == 'file' ? uri!.path : resource);
    }
    if (uri?.host.isNotEmpty == true) return uri!.host;
    return resource;
  }
}

enum AssociatedDataAction { edit, info, share, open }

class AssociatedDataActions extends ConsumerWidget {
  const AssociatedDataActions({
    super.key,
    required this.target,
    required this.data,
  });

  final AssociatedDataTarget target;
  final AssociatedDataData data;

  List<AssociatedDataAction> get _actions => [
    AssociatedDataAction.edit,
    AssociatedDataAction.info,
    AssociatedDataAction.share,
    if (data.type == 'Link' ||
        (data.type == 'File' && systemPlatform == PlatformType.desktop))
      AssociatedDataAction.open,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (MediaQuery.sizeOf(context).width < associatedDataCompactBreakpoint) {
      return IconButton(
        tooltip: 'Associated data actions',
        onPressed: () => _showActionSheet(context, ref),
        icon: const Icon(Icons.more_vert),
      );
    }
    return PopupMenuButton<AssociatedDataAction>(
      tooltip: 'Associated data actions',
      icon: const Icon(Icons.more_vert),
      onSelected: (action) => _handleAction(context, ref, action),
      itemBuilder: (context) => [
        for (final action in _actions) ...[
          if (action == AssociatedDataAction.share) const PopupMenuDivider(),
          PopupMenuItem(
            value: action,
            child: _AssociatedDataActionTile(action: action, data: data),
          ),
        ],
      ],
    );
  }

  Future<void> _showActionSheet(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<AssociatedDataAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final action in _actions) ...[
              if (action == AssociatedDataAction.share) const Divider(),
              _AssociatedDataActionTile(
                action: action,
                data: data,
                onTap: () => Navigator.of(sheetContext).pop(action),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (action != null && context.mounted) {
      await _handleAction(context, ref, action);
    }
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    AssociatedDataAction action,
  ) async {
    try {
      switch (action) {
        case AssociatedDataAction.edit:
          await showAssociatedDataEditor(context, target: target, data: data);
        case AssociatedDataAction.info:
          await showAssociatedDataInfo(context, ref: ref, data: data);
        case AssociatedDataAction.share:
          await _share(context, ref);
        case AssociatedDataAction.open:
          await _open(ref);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    if (data.type == 'Link') {
      final uri = data.uri?.trim() ?? '';
      if (uri.isEmpty) throw const FormatException('No URI to share.');
      await FilePickerServices().shareText(context, uri);
      return;
    }
    final file = await AssociatedDataServices(ref: ref).resolveFile(data);
    if (!await file.exists()) throw const FileSystemException('File not found');
    if (context.mounted) await FilePickerServices().shareFile(context, file);
  }

  Future<void> _open(WidgetRef ref) async {
    Uri uri;
    if (data.type == 'Link') {
      uri = Uri.tryParse(data.uri?.trim() ?? '') ?? Uri();
      if (!uri.hasScheme) throw const FormatException('Invalid URI.');
    } else {
      final file = await AssociatedDataServices(ref: ref).resolveFile(data);
      if (!await file.exists()) {
        throw const FileSystemException('File not found');
      }
      uri = Uri.file(file.path, windows: Platform.isWindows);
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw FormatException('Could not open $uri');
    }
  }
}

class _AssociatedDataActionTile extends StatelessWidget {
  const _AssociatedDataActionTile({
    required this.action,
    required this.data,
    this.onTap,
  });

  final AssociatedDataAction action;
  final AssociatedDataData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(onTap: onTap, leading: Icon(_icon), title: Text(_label));
  }

  IconData get _icon => switch (action) {
    AssociatedDataAction.edit => Icons.edit_outlined,
    AssociatedDataAction.info => Icons.info_outline,
    AssociatedDataAction.share => Icons.adaptive.share,
    AssociatedDataAction.open => Icons.open_in_new,
  };

  String get _label => switch (action) {
    AssociatedDataAction.edit => 'Edit',
    AssociatedDataAction.info => 'Show info',
    AssociatedDataAction.share => 'Share',
    AssociatedDataAction.open =>
      data.type == 'File' ? 'Open in default app' : 'Open link',
  };
}

class AddAssociatedDataButton extends StatelessWidget {
  const AddAssociatedDataButton({super.key, required this.target});

  final AssociatedDataTarget target;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: 'Add associated data',
      icon: Icons.add,
      onPressed: () => showAssociatedDataEditor(context, target: target),
    );
  }
}

class EmptyAssociatedData extends StatelessWidget {
  const EmptyAssociatedData({super.key, required this.target});

  final AssociatedDataTarget target;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('No associated data added'),
        const SizedBox(height: 8),
        AddAssociatedDataButton(target: target),
      ],
    );
  }
}

Future<void> showAssociatedDataEditor(
  BuildContext context, {
  required AssociatedDataTarget target,
  AssociatedDataData? data,
}) {
  final editor = AssociatedDataForm(target: target, data: data);
  final title = data == null ? 'Add associated data' : 'Edit associated data';
  if (MediaQuery.sizeOf(context).width < associatedDataCompactBreakpoint) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.9,
          child: Column(
            children: [
              Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
              const Divider(),
              Expanded(child: editor),
            ],
          ),
        ),
      ),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 560,
        height: MediaQuery.sizeOf(dialogContext).height * 0.75,
        child: editor,
      ),
    ),
  );
}

class AssociatedDataForm extends ConsumerStatefulWidget {
  const AssociatedDataForm({super.key, required this.target, this.data});

  final AssociatedDataTarget target;
  final AssociatedDataData? data;

  @override
  ConsumerState<AssociatedDataForm> createState() => _AssociatedDataFormState();
}

class _AssociatedDataFormState extends ConsumerState<AssociatedDataForm> {
  late final AssociatedDataCtr _controller;
  XFile? _selectedFile;
  AssociatedDataFileStorageMode _storageMode =
      AssociatedDataFileStorageMode.copyToProject;
  bool _isSelectingFile = false;
  bool _isSubmitting = false;
  String? _error;

  bool get _isEditing => widget.data != null;

  @override
  void initState() {
    super.initState();
    _controller = widget.data == null
        ? AssociatedDataCtr.empty()
        : AssociatedDataCtr.fromData(widget.data!);
    if (widget.data != null &&
        AssociatedDataServices(ref: ref).isExternalFile(widget.data!)) {
      _storageMode = AssociatedDataFileStorageMode.linkOriginal;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableConstrainedLayout(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FormSection(
            title: 'Details',
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Data type',
                    hintText: 'Select data type',
                  ),
                  initialValue: _controller.typeCtr,
                  items: const [
                    DropdownMenuItem(value: 'Link', child: Text('Link')),
                    DropdownMenuItem(value: 'File', child: Text('File')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (_controller.typeCtr != value) {
                        _controller.uriCtr.clear();
                        _selectedFile = null;
                      }
                      _controller.typeCtr = value;
                      _error = null;
                    });
                  },
                ),
                CommonTextField(
                  labelText: 'Name',
                  hintText: 'e.g., GenBank or MorphoSource',
                  controller: _controller.nameCtr,
                  isLastField: false,
                ),
                CommonTextField(
                  labelText: 'Description',
                  hintText: 'Describe the associated data',
                  controller: _controller.descriptionCtr,
                  isLastField: false,
                ),
                CommonDateField(
                  labelText: 'Date',
                  hintText: 'Enter date',
                  controller: _controller.dateCtr,
                  initialDate: DateTime.now(),
                  lastDate: DateTime.now(),
                  onTap: () {},
                  onClear: () {},
                ),
              ],
            ),
          ),
          FormSection(title: 'Resource', child: _resourceFields()),
          if (_error != null) ...[
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
          ],
          FormButton(
            isEditing: _isEditing,
            onSubmitted: _isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _resourceFields() {
    switch (_controller.typeCtr) {
      case 'Link':
        return CommonTextField(
          labelText: 'URI',
          hintText: 'https://example.org/data',
          controller: _controller.uriCtr,
          isLastField: true,
        );
      case 'File':
        return Column(
          children: [
            if (_selectedFile == null && _controller.uriCtr.text.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(
                  _resourceName(_controller.uriCtr.text),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _controller.uriCtr.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  tooltip: 'Clear file',
                  onPressed: () => setState(_controller.uriCtr.clear),
                  icon: const Icon(Icons.clear_rounded),
                ),
              )
            else
              SelectFileField(
                filePath: _selectedFile,
                isLoading: _isSelectingFile,
                width: double.infinity,
                maxWidth: double.infinity,
                supportedFormat: 'Non-media files',
                onCleared: () => setState(() => _selectedFile = null),
                onPressed: _selectFile,
              ),
            if (systemPlatform == PlatformType.desktop) ...[
              const SizedBox(height: 12),
              SegmentedButton<AssociatedDataFileStorageMode>(
                segments: const [
                  ButtonSegment(
                    value: AssociatedDataFileStorageMode.copyToProject,
                    icon: Icon(Icons.copy_outlined),
                    label: Text('Copy to project'),
                  ),
                  ButtonSegment(
                    value: AssociatedDataFileStorageMode.linkOriginal,
                    icon: Icon(Icons.link),
                    label: Text('Link original'),
                  ),
                ],
                selected: {_storageMode},
                onSelectionChanged: (selection) {
                  setState(() => _storageMode = selection.single);
                },
              ),
              if (_storageMode ==
                  AssociatedDataFileStorageMode.linkOriginal) ...[
                const SizedBox(height: 8),
                const Text(
                  'The link will stop working if the original file is moved '
                  'or deleted.',
                ),
              ],
            ],
          ],
        );
      default:
        return const Text('Select a data type.');
    }
  }

  String _resourceName(String resource) {
    final uri = Uri.tryParse(resource);
    return path.basename(uri?.scheme == 'file' ? uri!.path : resource);
  }

  Future<void> _selectFile() async {
    setState(() {
      _isSelectingFile = true;
      _error = null;
    });
    try {
      final selected = await FilePickerServices().selectAnyFile();
      if (selected == null) return;
      await const AssociatedDataFileValidator().validate(File(selected.path));
      if (mounted) {
        setState(() {
          _selectedFile = selected;
          _controller.uriCtr.clear();
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSelectingFile = false);
    }
  }

  Future<void> _submit() async {
    final type = _controller.typeCtr;
    if (type == null) {
      setState(() => _error = 'Select a data type.');
      return;
    }
    if (type == 'Link') {
      final uri = Uri.tryParse(_controller.uriCtr.text.trim());
      if (uri == null || !uri.hasScheme) {
        setState(() => _error = 'Enter a valid URI.');
        return;
      }
    }
    if (type == 'File' &&
        _selectedFile == null &&
        _controller.uriCtr.text.trim().isEmpty) {
      setState(() => _error = 'Select a file.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final form = AssociatedDataCompanion(
      name: db.Value(_nullIfEmpty(_controller.nameCtr.text)),
      type: db.Value(type),
      date: db.Value(_controller.dateCtr.date),
      description: db.Value(_nullIfEmpty(_controller.descriptionCtr.text)),
      uri: db.Value(_nullIfEmpty(_controller.uriCtr.text)),
    );
    try {
      final service = AssociatedDataServices(ref: ref);
      if (_isEditing) {
        final associatedDataId = widget.data!.primaryId;
        if (associatedDataId == null) {
          throw StateError('Associated data has no identifier.');
        }
        await service.updateAssociatedData(
          target: widget.target,
          associatedDataId: associatedDataId,
          form: form,
          selectedFile: _selectedFile == null
              ? null
              : File(_selectedFile!.path),
          storageMode: _storageMode,
        );
      } else {
        await service.createAssociatedData(
          target: widget.target,
          form: form,
          selectedFile: _selectedFile == null
              ? null
              : File(_selectedFile!.path),
          storageMode: _storageMode,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

Future<void> showAssociatedDataInfo(
  BuildContext context, {
  required WidgetRef ref,
  required AssociatedDataData data,
}) {
  final content = AssociatedDataDetails(data: data);
  if (MediaQuery.sizeOf(context).width < associatedDataCompactBreakpoint) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.8,
          child: Column(
            children: [
              Text(
                'Associated data info',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const Divider(),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Associated data info'),
      content: SizedBox(width: 480, child: content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class AssociatedDataDetails extends ConsumerWidget {
  const AssociatedDataDetails({super.key, required this.data});

  final AssociatedDataData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayDate = dateStdToDateDisplay(data.date) ?? '';
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        _DetailRowsSection(
          title: 'Details',
          entries: [
            MapEntry('Name', data.name),
            MapEntry('Data type', data.type),
            MapEntry('Date', displayDate),
            MapEntry('Description', data.description),
          ],
        ),
        FormSection(
          title: 'Resource',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DetailRow(
                label: data.type == 'File' ? 'Origin storage path' : 'URI',
                value: data.uri,
              ),
              if (data.type == 'File') ...[
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Storage',
                  value: AssociatedDataServices(ref: ref).isExternalFile(data)
                      ? 'Linked original'
                      : 'Project copy',
                ),
                const SizedBox(height: 12),
                FutureBuilder<bool>(
                  future: _fileExists(ref),
                  builder: (context, snapshot) => _DetailRow(
                    label: 'Availability',
                    value: snapshot.connectionState != ConnectionState.done
                        ? 'Checking…'
                        : snapshot.data == true
                        ? 'Available'
                        : 'File unavailable',
                  ),
                ),
              ],
            ],
          ),
        ),
        _DetailRowsSection(
          title: 'Identifiers',
          entries: [MapEntry('Project UUID', data.projectUuid)],
        ),
      ],
    );
  }

  Future<bool> _fileExists(WidgetRef ref) async {
    try {
      final file = await AssociatedDataServices(ref: ref).resolveFile(data);
      return file.existsSync();
    } catch (_) {
      return false;
    }
  }
}

class _DetailRowsSection extends StatelessWidget {
  const _DetailRowsSection({required this.title, required this.entries});

  final String title;
  final List<MapEntry<String, String?>> entries;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, entry) in entries.indexed) ...[
            if (index > 0) const SizedBox(height: 12),
            _DetailRow(label: entry.key, value: entry.value),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        SelectableText(
          displayValue == null || displayValue.isEmpty
              ? 'Not provided'
              : displayValue,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class AssociatedDataInfoContent extends StatelessWidget {
  const AssociatedDataInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          header: 'Overview',
          content:
              'Add links and non-media files associated with this record, '
              'such as accession numbers, datasets, and supporting documents.',
        ),
        InfoContent(
          content:
              'Add supported images, audio, and video through the Media '
              'section instead.',
        ),
      ],
    );
  }
}
