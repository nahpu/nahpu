import 'dart:io';

import 'package:drift/drift.dart' as db;
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/adaptive_menu.dart';
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
import 'package:nahpu/services/localization/l10n.dart';

const double associatedDataCompactBreakpoint = 600;

class AssociatedDataViewer extends StatelessWidget {
  const AssociatedDataViewer({super.key, required this.target});

  final AssociatedDataTarget target;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TitleForm(
          text: context.l10n.labelTableAssociatedData,
          infoTopic: InfoTopic.associatedData,
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
                    customIconButtonText: context.l10n
                        .deleteAssociatedDataCount(_selected.length),
                    customDialogHeader: context.l10n.deleteAssociatedDataTitle,
                    customDialogText: context.l10n.deleteAssociatedDataBody,
                    customDialogButtonText: context.l10n.commonRemove,
                    onPressedFunction: _removeSelected,
                  )
                else
                  AddAssociatedDataButton(target: widget.target),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text(context.l10n.formsErrorDetail('$error'))),
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
        title: Text(
          _title(context.l10n),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: AssociatedDataSubtitle(data: data),
        trailing: isSelecting
            ? null
            : AssociatedDataActions(target: target, data: data),
      ),
    );
  }

  String _title(AppLocalizations l10n) {
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
    return l10n.associatedUnnamed;
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
                    message: context.l10n.associatedFileUnavailable,
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
        Text(switch (data.type) {
          'Link' => context.l10n.associatedTypeLink,
          'File' => context.l10n.projectBatchStepFile,
          final type? => type,
          null => context.l10n.associatedUnknownType,
        }),
        const Text(' · '),
        Expanded(
          child: Tooltip(
            message: resource.isEmpty
                ? context.l10n.associatedNoResource
                : resource,
            child: Text(
              _compactResource(context.l10n, resource),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  String _compactResource(AppLocalizations l10n, String resource) {
    if (resource.isEmpty) return l10n.associatedNoResource;
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveMenuButton<AssociatedDataAction>(
      tooltip: context.l10n.associatedActions,
      icon: const Icon(Icons.more_vert),
      itemBuilder: () => _items(context.l10n),
      onSelected: (action) => _handleAction(context, ref, action),
    );
  }

  List<AdaptiveMenuItem<AssociatedDataAction>> _items(AppLocalizations l10n) =>
      [
        AdaptiveMenuItem(
          value: AssociatedDataAction.edit,
          icon: Icons.edit_outlined,
          label: l10n.commonEdit,
        ),
        AdaptiveMenuItem(
          value: AssociatedDataAction.info,
          icon: Icons.info_outline,
          label: l10n.mediaShowInfo,
        ),
        AdaptiveMenuItem(
          value: AssociatedDataAction.share,
          icon: Icons.adaptive.share,
          label: l10n.sharedShare,
          hasDividerBefore: true,
        ),
        if (data.type == 'Link' ||
            (data.type == 'File' && systemPlatform == PlatformType.desktop))
          AdaptiveMenuItem(
            value: AssociatedDataAction.open,
            icon: Icons.open_in_new,
            label: data.type == 'File'
                ? l10n.associatedOpenInDefaultApp
                : l10n.associatedOpenLink,
          ),
      ];

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
          await _open(context.l10n, ref);
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
      if (uri.isEmpty) {
        throw FormatException(context.l10n.associatedNoUriToShare);
      }
      await FilePickerServices().shareText(context, uri);
      return;
    }
    final notFound = context.l10n.associatedFileNotFound;
    final file = await AssociatedDataServices(ref: ref).resolveFile(data);
    if (!await file.exists()) throw FileSystemException(notFound);
    if (context.mounted) await FilePickerServices().shareFile(context, file);
  }

  Future<void> _open(AppLocalizations l10n, WidgetRef ref) async {
    Uri uri;
    if (data.type == 'Link') {
      uri = Uri.tryParse(data.uri?.trim() ?? '') ?? Uri();
      if (!uri.hasScheme) throw FormatException(l10n.associatedInvalidUri);
    } else {
      final file = await AssociatedDataServices(ref: ref).resolveFile(data);
      if (!await file.exists()) {
        throw FileSystemException(l10n.associatedFileNotFound);
      }
      uri = Uri.file(file.path, windows: Platform.isWindows);
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw FormatException(l10n.associatedCouldNotOpen('$uri'));
    }
  }
}

class AddAssociatedDataButton extends StatelessWidget {
  const AddAssociatedDataButton({super.key, required this.target});

  final AssociatedDataTarget target;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: context.l10n.associatedAdd,
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
        Text(context.l10n.associatedNoneAdded),
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
  final title = data == null
      ? context.l10n.associatedAdd
      : context.l10n.associatedEdit;
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
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.75,
        ),
        child: SizedBox(width: 560, child: editor),
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
            title: context.l10n.homeProjectDetails,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: context.l10n.associatedDataType,
                    hintText: context.l10n.associatedDataTypeHint,
                  ),
                  initialValue: _controller.typeCtr,
                  items: [
                    DropdownMenuItem(
                      value: 'Link',
                      child: Text(context.l10n.associatedTypeLink),
                    ),
                    DropdownMenuItem(
                      value: 'File',
                      child: Text(context.l10n.projectBatchStepFile),
                    ),
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
                  labelText: context.l10n.projectStatsColumnName,
                  hintText: context.l10n.associatedNameHint,
                  controller: _controller.nameCtr,
                  isLastField: false,
                ),
                CommonTextField(
                  labelText: context.l10n.projectDescription,
                  hintText: context.l10n.associatedDescriptionHint,
                  controller: _controller.descriptionCtr,
                  isLastField: false,
                ),
                CommonDateField(
                  labelText: context.l10n.narrativeDate,
                  hintText: context.l10n.narrativeDateHint,
                  controller: _controller.dateCtr,
                  initialDate: DateTime.now(),
                  lastDate: DateTime.now(),
                  onTap: () {},
                  onClear: () {},
                ),
              ],
            ),
          ),
          FormSection(
            title: context.l10n.associatedResource,
            child: _resourceFields(),
          ),
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
                  tooltip: context.l10n.databaseClearFile,
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
                supportedFormat: context.l10n.associatedNonMediaFiles,
                onCleared: () => setState(() => _selectedFile = null),
                onPressed: _selectFile,
              ),
            if (systemPlatform == PlatformType.desktop) ...[
              const SizedBox(height: 12),
              SegmentedButton<AssociatedDataFileStorageMode>(
                segments: [
                  ButtonSegment(
                    value: AssociatedDataFileStorageMode.copyToProject,
                    icon: Icon(Icons.copy_outlined),
                    label: Text(context.l10n.associatedCopyToProject),
                  ),
                  ButtonSegment(
                    value: AssociatedDataFileStorageMode.linkOriginal,
                    icon: Icon(Icons.link),
                    label: Text(context.l10n.associatedLinkOriginal),
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
                Text(context.l10n.associatedLinkOriginalWarning),
              ],
            ],
          ],
        );
      default:
        return Text(context.l10n.associatedSelectDataType);
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
      setState(() => _error = context.l10n.associatedSelectDataType);
      return;
    }
    if (type == 'Link') {
      final uri = Uri.tryParse(_controller.uriCtr.text.trim());
      if (uri == null || !uri.hasScheme) {
        setState(() => _error = context.l10n.associatedEnterValidUri);
        return;
      }
    }
    if (type == 'File' &&
        _selectedFile == null &&
        _controller.uriCtr.text.trim().isEmpty) {
      setState(() => _error = context.l10n.associatedSelectFile);
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
          throw StateError(context.l10n.associatedNoIdentifier);
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
                context.l10n.associatedInfo,
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
      title: Text(context.l10n.associatedInfo),
      content: SizedBox(width: 480, child: content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.commonClose),
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
          title: context.l10n.homeProjectDetails,
          entries: [
            MapEntry(context.l10n.projectStatsColumnName, data.name),
            MapEntry(context.l10n.associatedDataType, data.type),
            MapEntry(context.l10n.narrativeDate, displayDate),
            MapEntry(context.l10n.projectDescription, data.description),
          ],
        ),
        FormSection(
          title: context.l10n.associatedResource,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DetailRow(
                label: data.type == 'File'
                    ? context.l10n.associatedOriginStoragePath
                    : 'URI',
                value: data.uri,
              ),
              if (data.type == 'File') ...[
                const SizedBox(height: 12),
                _DetailRow(
                  label: context.l10n.parasiteStorage,
                  value: AssociatedDataServices(ref: ref).isExternalFile(data)
                      ? context.l10n.associatedLinkedOriginal
                      : context.l10n.associatedProjectCopy,
                ),
                const SizedBox(height: 12),
                FutureBuilder<bool>(
                  future: _fileExists(ref),
                  builder: (context, snapshot) => _DetailRow(
                    label: context.l10n.associatedAvailability,
                    value: snapshot.connectionState != ConnectionState.done
                        ? context.l10n.associatedChecking
                        : snapshot.data == true
                        ? context.l10n.recordsCustomFieldDeletionAvailable
                        : context.l10n.associatedFileUnavailable,
                  ),
                ),
              ],
            ],
          ),
        ),
        _DetailRowsSection(
          title: context.l10n.setupIdentifiers,
          entries: [
            MapEntry(
              context.l10n.recordsCustomFieldProjectUuid,
              data.projectUuid,
            ),
          ],
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
              ? context.l10n.projectNotProvided
              : displayValue,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
