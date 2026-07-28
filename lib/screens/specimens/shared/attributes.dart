import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/parasite_services.dart';
import 'package:nahpu/services/providers/specimens.dart';

class AttributeForm extends StatefulWidget {
  const AttributeForm({super.key, required this.children});

  final List<Widget> children;

  @override
  State<AttributeForm> createState() => _AttributeFormState();
}

class _AttributeFormState extends State<AttributeForm> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: 'Specimen Attributes',
      infoContent: const AttributeInfoContent(),
      mainAxisAlignment: MainAxisAlignment.start,
      child: SizedBox(
        height: 484,
        child: CommonScrollbar(
          scrollController: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const ScrollPhysics(),
            child: Column(children: widget.children),
          ),
        ),
      ),
    );
  }
}

class AttributeInfoContent extends StatelessWidget {
  const AttributeInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(
      content: [
        InfoContent(
          content:
              'Measurements and other biological attributes of the '
              'specimen, including age, sex, reproductive condition, and '
              'taxon-specific observations.',
        ),
      ],
    );
  }
}

class ParasiteDetectionForm extends ConsumerWidget {
  const ParasiteDetectionForm({super.key, required this.specimenUuid});

  final String specimenUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(parasiteDetectionProvider(specimenUuid))
        .when(
          data: (detection) => _ParasiteDetectionFields(
            detection: detection,
            onUpdate: (form) => _update(ref, form),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (error, _) =>
              Text('Unable to load parasite detection: $error'),
        );
  }

  void _update(WidgetRef ref, ParasiteDetectionCompanion form) {
    ParasiteServices(ref: ref).updateDetection(specimenUuid, form);
  }
}

class _ParasiteDetectionFields extends StatefulWidget {
  const _ParasiteDetectionFields({
    required this.detection,
    required this.onUpdate,
  });

  final ParasiteDetectionData? detection;
  final ValueChanged<ParasiteDetectionCompanion> onUpdate;

  @override
  State<_ParasiteDetectionFields> createState() =>
      _ParasiteDetectionFieldsState();
}

class _ParasiteDetectionFieldsState extends State<_ParasiteDetectionFields> {
  late final TextEditingController _remarkController;
  bool _remarkHasFocus = false;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(
      text: widget.detection?.detectionRemark ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _ParasiteDetectionFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    final remark = widget.detection?.detectionRemark ?? '';
    if (!_remarkHasFocus && _remarkController.text != remark) {
      _remarkController.text = remark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final detection = widget.detection;
    return Column(
      children: [
        const CommonDivider(),
        Text('Parasites', style: Theme.of(context).textTheme.titleMedium),
        DropdownButtonFormField<int?>(
          key: ValueKey('examined-${detection?.parasiteExamined}'),
          initialValue: detection?.parasiteExamined,
          decoration: const InputDecoration(labelText: 'Parasites examined'),
          items: DropDownMenuItems.booleanDropDownItems(),
          onChanged: (value) => widget.onUpdate(
            ParasiteDetectionCompanion(parasiteExamined: db.Value(value)),
          ),
        ),
        DropdownButtonFormField<int?>(
          key: ValueKey('detected-${detection?.parasiteDetected}'),
          initialValue: detection?.parasiteDetected,
          decoration: const InputDecoration(labelText: 'Parasites detected'),
          items: DropDownMenuItems.booleanDropDownItems(),
          onChanged: (value) => widget.onUpdate(
            ParasiteDetectionCompanion(parasiteDetected: db.Value(value)),
          ),
        ),
        Focus(
          onFocusChange: (hasFocus) => _remarkHasFocus = hasFocus,
          child: CommonTextField(
            controller: _remarkController,
            labelText: 'Detection remarks',
            hintText: 'Enter parasite examination or detection remarks',
            maxLines: 3,
            isLastField: true,
            onChanged: (value) => widget.onUpdate(
              ParasiteDetectionCompanion(
                detectionRemark: db.Value(
                  value?.trim().isEmpty == true ? null : value,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }
}
