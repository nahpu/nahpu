import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/screens/shared/dialogs/adaptive_sheet_dialog.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/services/custom_fields/custom_field_service.dart';
import 'package:nahpu/services/custom_fields/dwc_terms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';

Future<CustomFieldDefinitionData?> showCustomFieldDefinitionEditor({
  required BuildContext context,
  required FieldUISection placement,
  required CustomFieldCreationContext creationContext,
  CustomFieldDefinitionData? definition,
}) {
  // Not dismissible, so a stray tap outside does not discard the input.
  return showAdaptiveSheetDialog<CustomFieldDefinitionData>(
    context: context,
    isDismissible: false,
    builder: (context, _) => CustomFieldDefinitionForm(
      placement: placement,
      creationContext: creationContext,
      definition: definition,
      onSaved: (saved) => Navigator.pop(context, saved),
      onCancel: () => Navigator.pop(context),
    ),
  );
}

/// The inputs of a custom field definition, for creating or editing one.
///
/// [showCustomFieldDefinitionEditor] shows it in a sheet or dialog. Set
/// [isInline] to place it in a page instead, such as custom field settings,
/// where the page supplies the title and scrolling.
class CustomFieldDefinitionForm extends ConsumerStatefulWidget {
  const CustomFieldDefinitionForm({
    super.key,
    required this.placement,
    required this.creationContext,
    required this.onSaved,
    this.definition,
    this.onCancel,
    this.isInline = false,
  });

  final FieldUISection placement;
  final CustomFieldCreationContext creationContext;

  /// The definition to edit, or null to create one.
  final CustomFieldDefinitionData? definition;

  /// Runs after the definition is saved and its providers are refreshed.
  final ValueChanged<CustomFieldDefinitionData> onSaved;

  /// Discards the input. The button is hidden when null.
  final VoidCallback? onCancel;
  final bool isInline;

  @override
  ConsumerState<CustomFieldDefinitionForm> createState() =>
      _CustomFieldDefinitionFormState();
}

class _CustomFieldDefinitionFormState
    extends ConsumerState<CustomFieldDefinitionForm> {
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
    final l10n = context.l10n;
    final fields = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: NahpuSpacing.md,
      children: [
        TextField(
          controller: _name,
          autofocus: !_isEditing,
          enabled: !_saving,
          decoration: InputDecoration(labelText: l10n.fieldEditorLabel),
        ),
        DropdownButtonFormField<FieldType>(
          isExpanded: true,
          initialValue: _type,
          decoration: InputDecoration(labelText: l10n.fieldEditorType),
          items: [
            for (final type in FieldType.values)
              DropdownMenuItem(
                value: type,
                child: CommonDropdownText(text: _fieldTypeLabel(type, l10n)),
              ),
          ],
          onChanged: _saving ? null : (value) => setState(() => _type = value!),
        ),
        if (!_isEditing)
          DropdownButtonFormField<FieldScope>(
            isExpanded: true,
            initialValue: _scope,
            decoration: InputDecoration(
              labelText: l10n.recordsCustomFieldScope,
            ),
            items: [
              DropdownMenuItem(
                value: FieldScope.global,
                child: CommonDropdownText(
                  text: l10n.recordsCustomFieldScopeGlobal,
                ),
              ),
              if (widget.creationContext.projectUuid.isNotEmpty)
                DropdownMenuItem(
                  value: FieldScope.project,
                  child: CommonDropdownText(
                    text: l10n.recordsCustomFieldScopeProject,
                  ),
                ),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _scope = value!),
          ),
        if (widget.placement.isSpecimenRelated)
          DropdownButtonFormField<CatalogFmt?>(
            isExpanded: true,
            initialValue: _catalog,
            decoration: InputDecoration(
              labelText: l10n.fieldEditorCatalogApplicability,
            ),
            items: [
              DropdownMenuItem<CatalogFmt?>(
                value: null,
                child: CommonDropdownText(
                  text: l10n.recordsCustomFieldAllCatalogs,
                ),
              ),
              for (final catalog in _availableCatalogs)
                DropdownMenuItem<CatalogFmt?>(
                  value: catalog,
                  child: CommonDropdownText(text: _catalogLabel(catalog, l10n)),
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
            decoration: InputDecoration(
              labelText: l10n.fieldEditorOptions,
              helperText: l10n.fieldEditorOptionsHelper,
            ),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.fieldEditorMapToDwc),
          subtitle: Text(l10n.fieldEditorDwcOfficialTerms(dwcTermsVersion)),
          value: _hasDwcMapping,
          onChanged: _saving
              ? null
              : (value) => setState(() => _hasDwcMapping = value),
        ),
        if (_hasDwcMapping) ...[
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _dwcTarget,
            decoration: InputDecoration(labelText: l10n.fieldEditorDwcTarget),
            items: [
              for (final target in dwcTargetsForPlacement(widget.placement))
                DropdownMenuItem(
                  value: target,
                  child: CommonDropdownText(text: target),
                ),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _dwcTarget = value!),
          ),
          DropdownButtonFormField<DwcMappingMode>(
            isExpanded: true,
            initialValue: _dwcMode,
            decoration: InputDecoration(
              labelText: l10n.fieldEditorDwcMappingMode,
            ),
            items: [
              DropdownMenuItem(
                value: DwcMappingMode.direct,
                child: CommonDropdownText(text: l10n.fieldEditorDwcDirect),
              ),
              DropdownMenuItem(
                value: DwcMappingMode.assertion,
                child: CommonDropdownText(text: l10n.fieldEditorDwcAssertion),
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
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              _dwcFieldController = controller;
              return TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: !_saving,
                decoration: InputDecoration(
                  labelText: l10n.fieldEditorDwcField,
                ),
              );
            },
          ),
          if (_dwcMode == DwcMappingMode.direct)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _allowDwcConflict,
              title: Text(l10n.fieldEditorDwcAllowConflict),
              subtitle: Text(l10n.fieldEditorDwcAllowConflictNote),
              onChanged: _saving
                  ? null
                  : (value) =>
                        setState(() => _allowDwcConflict = value ?? false),
            ),
        ],
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
    final actions = [
      if (widget.onCancel != null)
        OutlinedButton(
          onPressed: _saving ? null : widget.onCancel,
          // Inline, editing stays open, so the button restores saved values.
          child: Text(
            widget.isInline && _isEditing
                ? l10n.commonReset
                : l10n.commonCancel,
          ),
        ),
      PrimaryButton(
        onPressed: _saving ? null : _save,
        label: _saving ? l10n.presetsSaving : l10n.commonSave,
        icon: Icons.save_outlined,
      ),
    ];
    if (!widget.isInline) {
      return AdaptiveSheetDialogBody(
        title: _isEditing
            ? l10n.fieldEditorEditTitle
            : l10n.fieldEditorAddTitle(widget.placement.localizedLabel(l10n)),
        // Cancel closes it, in the sheet and the dialog alike.
        showCloseButton: false,
        actions: actions,
        child: fields,
      );
    }
    // The switch and checkbox tiles paint their ink on the nearest Material,
    // which a decorated card around the form would otherwise hide.
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          fields,
          const SizedBox(height: NahpuSpacing.xl),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            overflowAlignment: OverflowBarAlignment.end,
            spacing: NahpuSpacing.md,
            overflowSpacing: NahpuSpacing.md,
            children: actions,
          ),
        ],
      ),
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

  String _catalogLabel(CatalogFmt catalog, AppLocalizations l10n) {
    final label = catalog.localizedLabel(l10n);
    if (catalog == widget.creationContext.catalogFormat) {
      return l10n.fieldEditorCurrentCatalogOnly(label);
    }
    return l10n.recordsCustomFieldCatalogOnly(label);
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
      invalidateCustomFieldDefinitionProviders(ref);
      if (!mounted) return;
      setState(() => _saving = false);
      widget.onSaved(saved);
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

String _fieldTypeLabel(FieldType type, AppLocalizations l10n) => switch (type) {
  FieldType.text => l10n.recordsCustomFieldTypeText,
  FieldType.number => l10n.recordsCustomFieldTypeNumber,
  FieldType.boolean => l10n.recordsCustomFieldTypeBoolean,
  FieldType.dropdown => l10n.recordsCustomFieldTypeDropdown,
};
