import 'package:drift/drift.dart' as db;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/forms/custom_fields.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/screens/specimens/shared/attributes.dart';
import 'package:nahpu/screens/specimens/shared/weight_field.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/specimens/specimen_services.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/styles/design_tokens.dart';

class FossilAttributeForms extends ConsumerWidget {
  const FossilAttributeForms({
    super.key,
    required this.specimenUuid,
    required this.useHorizontalLayout,
  });

  final String specimenUuid;
  final bool useHorizontalLayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref
        .watch(fossilAttributeProvider(specimenUuid))
        .when(
          data: (data) => FossilAttributeFields(
            key: ValueKey(specimenUuid),
            specimenUuid: specimenUuid,
            attributes: data,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Column(
            children: [
              Text('Could not load fossil attributes: $error'),
              TextButton(
                onPressed: () =>
                    ref.invalidate(fossilAttributeProvider(specimenUuid)),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
    return FormCard(
      title: 'Fossil Attributes',
      mainAxisAlignment: MainAxisAlignment.start,
      isExpanded: useHorizontalLayout,
      child: useHorizontalLayout
          ? SingleChildScrollView(child: content)
          : content,
    );
  }
}

class FossilAttributeFields extends ConsumerStatefulWidget {
  const FossilAttributeFields({
    super.key,
    required this.specimenUuid,
    required this.attributes,
  });

  final String specimenUuid;
  final FossilAttributeData? attributes;

  @override
  ConsumerState<FossilAttributeFields> createState() =>
      _FossilAttributeFieldsState();
}

class _FossilAttributeFieldsState extends ConsumerState<FossilAttributeFields> {
  final _type = TextEditingController();
  final _stage = TextEditingController();
  final _weight = TextEditingController();
  final _description = TextEditingController();
  final _remark = TextEditingController();
  int? _sex;
  String _unit = 'g';
  String? _saveError;
  int _pendingWrites = 0;
  int _saveGeneration = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant FossilAttributeFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.specimenUuid != widget.specimenUuid) {
      _saveGeneration++;
      _saveError = null;
      _load();
    } else if (_pendingWrites == 0 &&
        _saveError == null &&
        oldWidget.attributes != widget.attributes) {
      _load();
    }
  }

  @override
  void dispose() {
    for (final controller in [_type, _stage, _weight, _description, _remark]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _type,
          decoration: const InputDecoration(labelText: 'Fossil type'),
          onChanged: (_) => _save(),
        ),
        SpecimenSexDropdown(
          key: ValueKey(_sex),
          currentCode: _sex,
          onChanged: (sex) {
            setState(() => _sex = sex == null ? null : getSpecimenSexCode(sex));
            _save();
          },
        ),
        TextFormField(
          controller: _stage,
          decoration: const InputDecoration(labelText: 'Ontogenetic stage'),
          onChanged: (_) => _save(),
        ),
        WeightField(
          controller: _weight,
          unit: _unit,
          onChanged: (_) => _save(),
          onUnitChanged: (unit) {
            setState(() => _unit = unit);
            _save();
          },
        ),
        TextFormField(
          controller: _description,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Specimen description'),
          onChanged: (_) => _save(),
        ),
        TextFormField(
          controller: _remark,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Remarks'),
          onChanged: (_) => _save(),
        ),
        if (_saveError != null) ...[
          const SizedBox(height: NahpuSpacing.md),
          Text(
            _saveError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          TextButton(onPressed: _save, child: const Text('Retry saving')),
        ],
        CustomFieldForm(owner: CustomFieldOwner.specimen(widget.specimenUuid)),
      ],
    );
  }

  void _load() {
    final data = widget.attributes;
    final values = {
      _type: data?.fossilType,
      _stage: data?.ontogeneticStage,
      _weight: data?.weight?.toString(),
      _description: data?.specimenDescription,
      _remark: data?.remark,
    };
    for (final entry in values.entries) {
      if (entry.key.text != (entry.value ?? '')) {
        entry.key.text = entry.value ?? '';
      }
    }
    _sex = data?.sex;
    _unit = data?.weightUnit ?? 'g';
  }

  Future<void> _save() async {
    final generation = ++_saveGeneration;
    _pendingWrites++;
    final entries = FossilAttributeCompanion(
      fossilType: db.Value(_type.text),
      sex: db.Value(_sex),
      ontogeneticStage: db.Value(_stage.text),
      weight: db.Value(double.tryParse(_weight.text)),
      weightUnit: db.Value(_unit),
      specimenDescription: db.Value(_description.text),
      remark: db.Value(_remark.text),
    );
    try {
      await SpecimenServices(
        ref: ref,
      ).updateFossilAttribute(widget.specimenUuid, entries);
      if (mounted && generation == _saveGeneration) {
        setState(() => _saveError = null);
      }
    } catch (error) {
      if (mounted && generation == _saveGeneration) {
        setState(() => _saveError = 'Could not save fossil attributes: $error');
      }
    } finally {
      _pendingWrites--;
    }
  }
}
