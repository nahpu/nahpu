import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/settings/custom_fields.dart';
import 'package:nahpu/screens/shared/forms/custom_field_definition_editor.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';

class CustomFieldForm extends ConsumerStatefulWidget {
  const CustomFieldForm({super.key, required this.owner, this.showAll = true});

  final CustomFieldOwner owner;
  final bool showAll;

  @override
  ConsumerState<CustomFieldForm> createState() => _CustomFieldFormState();
}

class _CustomFieldFormState extends ConsumerState<CustomFieldForm> {
  @override
  Widget build(BuildContext context) {
    return ref
        .watch(customFieldEntriesProvider(widget.owner))
        .when(
          data: (entries) => _CustomFieldArea(
            entries: entries
                .map(
                  (entry) => _CustomFieldDisplayEntry(
                    definition: entry.definition,
                    value: entry.value?.value,
                  ),
                )
                .toList(growable: false),
            showAll: widget.showAll,
            onAdd: _addDefinition,
            onManage: _openSettings,
            onChanged: _setValue,
          ),
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text('Unable to load custom fields: $error'),
        );
  }

  Future<void> _addDefinition() async {
    try {
      final service = ref.read(customFieldServiceProvider);
      final creationContext = await service.getCreationContext(widget.owner);
      if (!mounted) return;
      final definition = await showCustomFieldDefinitionEditor(
        context: context,
        placement: widget.owner.placement,
        creationContext: creationContext,
      );
      if (definition == null) return;
      invalidateCustomFieldDefinitionProviders(ref);
    } catch (error) {
      if (!mounted) return;
      _showError(error);
    }
  }

  Future<void> _openSettings() async {
    try {
      final creationContext = await ref
          .read(customFieldServiceProvider)
          .getCreationContext(widget.owner);
      if (!mounted) return;
      final catalog =
          creationContext.catalogFormat ??
          await ref.read(catalogFmtNotifierProvider.future) ??
          CatalogFmt.mammals;
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => CustomFieldsSettings(
            projectUuid: creationContext.projectUuid.isEmpty
                ? null
                : creationContext.projectUuid,
            currentCatalog: catalog,
          ),
        ),
      );
      if (mounted) invalidateCustomFieldDefinitionProviders(ref);
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _setValue(
    CustomFieldDefinitionData definition,
    String? value,
  ) async {
    try {
      await ref
          .read(customFieldServiceProvider)
          .setValue(widget.owner, definition.id!, value);
      ref.invalidate(customFieldEntriesProvider(widget.owner));
    } catch (error) {
      if (!mounted) return;
      _showError(error);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }
}

class CustomFieldDraftForm extends ConsumerStatefulWidget {
  const CustomFieldDraftForm({
    super.key,
    required this.placement,
    required this.specimenUuid,
    required this.controller,
    this.showAll = true,
  });

  final FieldUISection placement;
  final String specimenUuid;
  final CustomFieldDraftController controller;
  final bool showAll;

  @override
  ConsumerState<CustomFieldDraftForm> createState() =>
      _CustomFieldDraftFormState();
}

class _CustomFieldDraftFormState extends ConsumerState<CustomFieldDraftForm> {
  @override
  Widget build(BuildContext context) {
    final provider = customFieldSpecimenDefinitionsProvider((
      placement: widget.placement,
      specimenUuid: widget.specimenUuid,
    ));
    ref.listen(provider, (_, next) {
      next.whenData(
        (definitions) => widget.controller.retainDefinitionIds(
          definitions.map((definition) => definition.id!),
        ),
      );
    });
    return ref
        .watch(provider)
        .when(
          data: (definitions) => ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) => _CustomFieldArea(
              entries: definitions
                  .map(
                    (definition) => _CustomFieldDisplayEntry(
                      definition: definition,
                      value: widget.controller.valueFor(definition.id!),
                    ),
                  )
                  .toList(growable: false),
              showAll: widget.showAll,
              onAdd: _addDefinition,
              onManage: _openSettings,
              onChanged: (definition, value) =>
                  widget.controller.setValue(definition.id!, value),
            ),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text('Unable to load custom fields: $error'),
        );
  }

  Future<void> _addDefinition() async {
    try {
      final service = ref.read(customFieldServiceProvider);
      final creationContext = await service.getSpecimenCreationContext(
        widget.specimenUuid,
      );
      if (!mounted) return;
      final definition = await showCustomFieldDefinitionEditor(
        context: context,
        placement: widget.placement,
        creationContext: creationContext,
      );
      if (definition == null || !mounted) return;
      invalidateCustomFieldDefinitionProviders(ref);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _openSettings() async {
    try {
      final creationContext = await ref
          .read(customFieldServiceProvider)
          .getSpecimenCreationContext(widget.specimenUuid);
      if (!mounted) return;
      final catalog =
          creationContext.catalogFormat ??
          await ref.read(catalogFmtNotifierProvider.future) ??
          CatalogFmt.mammals;
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => CustomFieldsSettings(
            projectUuid: creationContext.projectUuid.isEmpty
                ? null
                : creationContext.projectUuid,
            currentCatalog: catalog,
          ),
        ),
      );
      if (mounted) invalidateCustomFieldDefinitionProviders(ref);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _CustomFieldDisplayEntry {
  const _CustomFieldDisplayEntry({required this.definition, this.value});

  final CustomFieldDefinitionData definition;
  final String? value;

  bool get hasValue => value?.trim().isNotEmpty ?? false;
}

class _CustomFieldArea extends StatelessWidget {
  const _CustomFieldArea({
    required this.entries,
    required this.showAll,
    required this.onAdd,
    required this.onManage,
    required this.onChanged,
  });

  final List<_CustomFieldDisplayEntry> entries;
  final bool showAll;
  final VoidCallback onAdd;
  final VoidCallback onManage;
  final void Function(CustomFieldDefinitionData definition, String? value)
  onChanged;

  @override
  Widget build(BuildContext context) {
    final visibleEntries = showAll
        ? entries
        : entries.where((entry) => entry.hasValue).toList(growable: false);
    if (!showAll && visibleEntries.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: NahpuSpacing.md),
      child: _CustomFieldSection(
        entries: visibleEntries,
        showAdd: showAll,
        onAdd: onAdd,
        onManage: onManage,
        onChanged: onChanged,
      ),
    );
  }
}

class _CustomFieldSection extends StatelessWidget {
  const _CustomFieldSection({
    required this.entries,
    required this.showAdd,
    required this.onAdd,
    required this.onManage,
    required this.onChanged,
  });

  final List<_CustomFieldDisplayEntry> entries;
  final bool showAdd;
  final VoidCallback onAdd;
  final VoidCallback onManage;
  final void Function(CustomFieldDefinitionData definition, String? value)
  onChanged;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: 'Custom fields',
      trailing: IconButton(
        onPressed: onManage,
        icon: const Icon(Icons.settings_outlined),
        tooltip: 'Manage custom fields',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in entries)
            _CustomFieldInput(
              key: ValueKey(
                '${entry.definition.uuid}:${entry.definition.type}',
              ),
              entry: entry,
              onChanged: (value) => onChanged(entry.definition, value),
            ),
          if (showAdd)
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add custom field'),
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomFieldInput extends StatefulWidget {
  const _CustomFieldInput({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final _CustomFieldDisplayEntry entry;
  final ValueChanged<String?> onChanged;

  @override
  State<_CustomFieldInput> createState() => _CustomFieldInputState();
}

class _CustomFieldInputState extends State<_CustomFieldInput> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.entry.value ?? '',
  );
  late String _boolean = widget.entry.value ?? 'unset';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final definition = widget.entry.definition;
    return switch (definition.fieldType) {
      FieldType.text => CommonTextField(
        controller: _controller,
        labelText: definition.name,
        hintText: 'Enter ${definition.name.toLowerCase()}',
        isLastField: false,
        onChanged: widget.onChanged,
      ),
      FieldType.number => CommonNumField(
        controller: _controller,
        labelText: definition.name,
        hintText: 'Enter a number',
        isDouble: true,
        isLastField: false,
        onChanged: widget.onChanged,
      ),
      FieldType.dropdown => DropdownButtonFormField<String?>(
        isExpanded: true,
        initialValue: widget.entry.value,
        decoration: InputDecoration(labelText: definition.name),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: CommonDropdownText(text: 'Unset'),
          ),
          for (final option in definition.dropdownOptions)
            if (!option.isArchived || option.uuid == widget.entry.value)
              DropdownMenuItem<String?>(
                value: option.uuid,
                child: CommonDropdownText(
                  text: option.isArchived
                      ? '${option.label} (archived)'
                      : option.label,
                ),
              ),
        ],
        onChanged: (value) {
          widget.onChanged(value);
        },
      ),
      FieldType.boolean => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(definition.name),
            const SizedBox(height: 6),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'unset', label: Text('Unset')),
                ButtonSegment(value: 'true', label: Text('Yes')),
                ButtonSegment(value: 'false', label: Text('No')),
              ],
              selected: {_boolean},
              onSelectionChanged: (selected) {
                final value = selected.single;
                setState(() => _boolean = value);
                widget.onChanged(value == 'unset' ? null : value);
              },
            ),
          ],
        ),
      ),
    };
  }
}
