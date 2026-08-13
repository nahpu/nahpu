import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/custom_field_definition_editor.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/custom_fields.dart';
import 'package:nahpu/services/types/custom_field.dart';

class CustomFieldForm extends ConsumerStatefulWidget {
  const CustomFieldForm({super.key, required this.owner});

  final CustomFieldOwner owner;

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
            entries: entries,
            onAdd: _addDefinition,
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
      ref.invalidate(customFieldEntriesProvider(widget.owner));
      ref.invalidate(
        manageableCustomFieldsProvider(creationContext.projectUuid),
      );
    } catch (error) {
      if (!mounted) return;
      _showError(error);
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
    required this.onChanged,
  });

  final FieldUISection placement;
  final String specimenUuid;
  final void Function(int definitionId, String? value) onChanged;

  @override
  ConsumerState<CustomFieldDraftForm> createState() =>
      _CustomFieldDraftFormState();
}

class _CustomFieldDraftFormState extends ConsumerState<CustomFieldDraftForm> {
  late Future<List<CustomFieldDefinitionData>> _definitions;

  @override
  void initState() {
    super.initState();
    _definitions = _loadDefinitions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CustomFieldDefinitionData>>(
      future: _definitions,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Unable to load custom fields: ${snapshot.error}');
        }
        if (!snapshot.hasData) return const LinearProgressIndicator();
        return _CustomFieldArea(
          entries: snapshot.data!
              .map((definition) => CustomFieldEntry(definition: definition))
              .toList(growable: false),
          onAdd: _addDefinition,
          onChanged: (definition, value) =>
              widget.onChanged(definition.id!, value),
        );
      },
    );
  }

  Future<List<CustomFieldDefinitionData>> _loadDefinitions() => ref
      .read(customFieldServiceProvider)
      .getDefinitionsForSpecimenContext(
        placement: widget.placement,
        specimenUuid: widget.specimenUuid,
      );

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
      setState(() => _definitions = _loadDefinitions());
      ref.invalidate(
        manageableCustomFieldsProvider(creationContext.projectUuid),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _CustomFieldArea extends StatelessWidget {
  const _CustomFieldArea({
    required this.entries,
    required this.onAdd,
    required this.onChanged,
  });

  final List<CustomFieldEntry> entries;
  final VoidCallback onAdd;
  final void Function(CustomFieldDefinitionData definition, String? value)
  onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (entries.isNotEmpty)
          _CustomFieldSection(entries: entries, onChanged: onChanged),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add custom field'),
          ),
        ),
      ],
    );
  }
}

class _CustomFieldSection extends StatelessWidget {
  const _CustomFieldSection({required this.entries, required this.onChanged});

  final List<CustomFieldEntry> entries;
  final void Function(CustomFieldDefinitionData definition, String? value)
  onChanged;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: 'Custom fields',
      child: Column(
        children: [
          for (final entry in entries)
            _CustomFieldInput(
              key: ValueKey(
                '${entry.definition.uuid}:${entry.value?.value ?? ''}',
              ),
              entry: entry,
              onChanged: (value) => onChanged(entry.definition, value),
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

  final CustomFieldEntry entry;
  final ValueChanged<String?> onChanged;

  @override
  State<_CustomFieldInput> createState() => _CustomFieldInputState();
}

class _CustomFieldInputState extends State<_CustomFieldInput> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.entry.value?.value ?? '',
  );
  late String _boolean = widget.entry.value?.value ?? 'unset';

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
        initialValue: widget.entry.value?.value,
        decoration: InputDecoration(labelText: definition.name),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: CommonDropdownText(text: 'Unset'),
          ),
          for (final option in definition.dropdownOptions)
            if (!option.isArchived || option.uuid == widget.entry.value?.value)
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
