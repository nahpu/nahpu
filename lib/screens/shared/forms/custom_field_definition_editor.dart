import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/services/custom_fields/custom_field_service.dart';
import 'package:nahpu/services/custom_fields/dwc_terms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/specimens.dart';

Future<CustomFieldDefinitionData?> showCustomFieldDefinitionEditor({
  required BuildContext context,
  required FieldUISection placement,
  required CustomFieldCreationContext creationContext,
  CustomFieldDefinitionData? definition,
}) {
  return showDialog<CustomFieldDefinitionData>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CustomFieldDefinitionEditor(
      placement: placement,
      creationContext: creationContext,
      definition: definition,
    ),
  );
}

class _CustomFieldDefinitionEditor extends ConsumerStatefulWidget {
  const _CustomFieldDefinitionEditor({
    required this.placement,
    required this.creationContext,
    this.definition,
  });

  final FieldUISection placement;
  final CustomFieldCreationContext creationContext;
  final CustomFieldDefinitionData? definition;

  @override
  ConsumerState<_CustomFieldDefinitionEditor> createState() =>
      _CustomFieldDefinitionEditorState();
}

class _CustomFieldDefinitionEditorState
    extends ConsumerState<_CustomFieldDefinitionEditor> {
  late final TextEditingController _name = TextEditingController(
    text: widget.definition?.name,
  );
  late final TextEditingController _options = TextEditingController(
    text: widget.definition?.dropdownOptions
        .map((option) => option.label)
        .join('\n'),
  );
  late FieldType _type = widget.definition?.fieldType ?? FieldType.text;
  late FieldScope _scope = widget.definition?.fieldScope ?? FieldScope.project;
  late CatalogFmt? _catalog = widget.definition?.applicableCatalog;
  late DwcMappingMode _dwcMode =
      widget.definition?.dwcMapping?.mode ?? DwcMappingMode.direct;
  late String _dwcTarget =
      widget.definition?.dwcTarget ??
      dwcTargetsForPlacement(widget.placement).first;
  late bool _allowDwcConflict = widget.definition?.permitsDwcConflict ?? false;
  late bool _hasDwcMapping = widget.definition?.dwcField != null;
  TextEditingController? _dwcFieldController;
  String? _error;
  bool _saving = false;

  bool get _isEditing => widget.definition != null;

  @override
  void initState() {
    super.initState();
    if (!_isEditing && widget.creationContext.projectUuid.isEmpty) {
      _scope = FieldScope.global;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _options.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing
            ? 'Edit custom field'
            : 'Add custom field to ${widget.placement.label}',
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                autofocus: !_isEditing,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
              DropdownButtonFormField<FieldType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  for (final type in FieldType.values)
                    DropdownMenuItem(
                      value: type,
                      child: Text(_fieldTypeLabel(type)),
                    ),
                ],
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _type = value!),
              ),
              if (!_isEditing)
                DropdownButtonFormField<FieldScope>(
                  initialValue: _scope,
                  decoration: const InputDecoration(labelText: 'Scope'),
                  items: [
                    const DropdownMenuItem(
                      value: FieldScope.global,
                      child: Text('Global'),
                    ),
                    if (widget.creationContext.projectUuid.isNotEmpty)
                      const DropdownMenuItem(
                        value: FieldScope.project,
                        child: Text('Current project'),
                      ),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _scope = value!),
                ),
              if (widget.placement.isSpecimenRelated)
                DropdownButtonFormField<CatalogFmt?>(
                  initialValue: _catalog,
                  decoration: const InputDecoration(
                    labelText: 'Catalog applicability',
                  ),
                  items: [
                    const DropdownMenuItem<CatalogFmt?>(
                      value: null,
                      child: Text('All catalog formats'),
                    ),
                    for (final catalog in _availableCatalogs)
                      DropdownMenuItem<CatalogFmt?>(
                        value: catalog,
                        child: Text(_catalogLabel(catalog)),
                      ),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _catalog = value),
                ),
              if (_type == FieldType.dropdown)
                TextField(
                  controller: _options,
                  minLines: 3,
                  maxLines: 8,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Options',
                    helperText: 'Enter one option per line.',
                  ),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Map to Darwin Core'),
                subtitle: Text('Official terms $dwcTermsVersion'),
                value: _hasDwcMapping,
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _hasDwcMapping = value),
              ),
              if (_hasDwcMapping) ...[
                DropdownButtonFormField<String>(
                  initialValue: _dwcTarget,
                  decoration: const InputDecoration(labelText: 'DWC target'),
                  items: [
                    for (final target in dwcTargetsForPlacement(
                      widget.placement,
                    ))
                      DropdownMenuItem(value: target, child: Text(target)),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _dwcTarget = value!),
                ),
                DropdownButtonFormField<DwcMappingMode>(
                  initialValue: _dwcMode,
                  decoration: const InputDecoration(labelText: 'Mapping mode'),
                  items: const [
                    DropdownMenuItem(
                      value: DwcMappingMode.direct,
                      child: Text('Direct field'),
                    ),
                    DropdownMenuItem(
                      value: DwcMappingMode.assertion,
                      child: Text('Repeatable measurement / fact'),
                    ),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _dwcMode = value!),
                ),
                Autocomplete<String>(
                  initialValue: TextEditingValue(
                    text: widget.definition?.dwcField ?? '',
                  ),
                  optionsBuilder: (value) {
                    final query = value.text.trim().toLowerCase();
                    if (query.isEmpty) return officialDwcFields;
                    return officialDwcFields.where(
                      (field) => field.toLowerCase().contains(query),
                    );
                  },
                  onSelected: (value) {
                    _dwcFieldController?.text = value;
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onSubmitted) {
                        _dwcFieldController = controller;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                            labelText: 'DWC field',
                          ),
                        );
                      },
                ),
                if (_dwcMode == DwcMappingMode.direct)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _allowDwcConflict,
                    title: const Text('I understand duplicate values'),
                    subtitle: const Text(
                      'Conflicting scalar values will be joined with “ | ”.',
                    ),
                    onChanged: _saving
                        ? null
                        : (value) => setState(
                            () => _allowDwcConflict = value ?? false,
                          ),
                  ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          onPressed: _saving ? null : _save,
          label: _saving ? 'Saving' : 'Save',
          icon: Icons.save_outlined,
        ),
      ],
    );
  }

  List<CatalogFmt> get _availableCatalogs {
    final catalogs = <CatalogFmt>{};
    final current = widget.creationContext.catalogFormat;
    if (current != null) catalogs.add(current);
    final existing = widget.definition?.applicableCatalog;
    if (existing != null) catalogs.add(existing);
    return catalogs.toList(growable: false);
  }

  String _catalogLabel(CatalogFmt catalog) {
    final label = matchCatFmtToTaxonGroup(catalog);
    if (catalog == widget.creationContext.catalogFormat) {
      return 'Current catalog only ($label)';
    }
    return '$label only';
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final draft = _draft();
      final service = ref.read(customFieldServiceProvider);
      final saved = _isEditing
          ? await _update(service, draft)
          : await service.createDefinition(draft);
      ref.invalidate(allCustomFieldDefinitionsProvider);
      if (mounted) Navigator.pop(context, saved);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.toString();
      });
    }
  }

  Future<CustomFieldDefinitionData> _update(
    CustomFieldService service,
    CustomFieldDraft draft,
  ) async {
    await service.updateDefinition(widget.definition!.id!, draft);
    return service.getDefinition(widget.definition!.id!);
  }

  CustomFieldDraft _draft() {
    final existingOptions = widget.definition?.dropdownOptions ?? const [];
    final optionLabels = _options.text
        .split(RegExp(r'[\n,]'))
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList();
    final options = optionLabels.map((label) {
      return existingOptions
              .where(
                (option) => option.label.toLowerCase() == label.toLowerCase(),
              )
              .firstOrNull ??
          CustomFieldOption.create(label);
    }).toList();
    for (final option in existingOptions) {
      if (!options.any((candidate) => candidate.uuid == option.uuid)) {
        options.add(option.copyWith(isArchived: true));
      }
    }
    final scope = widget.definition?.fieldScope ?? _scope;
    return CustomFieldDraft(
      name: _name.text,
      type: _type,
      placement: widget.placement,
      scope: scope,
      projectUuid: scope == FieldScope.project
          ? widget.definition?.projectUuid ?? widget.creationContext.projectUuid
          : null,
      catalogFormat: widget.placement.isSpecimenRelated ? _catalog : null,
      options: options,
      sourceTemplateUuid: widget.definition?.sourceTemplateUuid,
      dwcMapping: !_hasDwcMapping
          ? null
          : DwcFieldMapping(
              target: _dwcTarget,
              field:
                  (_dwcFieldController?.text ??
                          widget.definition?.dwcField ??
                          '')
                      .trim(),
              mode: _dwcMode,
              allowConflict: _allowDwcConflict,
            ),
    );
  }
}

String _fieldTypeLabel(FieldType type) => switch (type) {
  FieldType.text => 'Text',
  FieldType.number => 'Number',
  FieldType.boolean => 'Yes / No',
  FieldType.dropdown => 'Dropdown',
};
