import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/export/specimen_part_filter.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/styles/design_tokens.dart';

Future<SpecimenPartFilter?> showSpecimenPartFilterDialog({
  required BuildContext context,
  required SpecimenPartFilter filter,
  required List<SpecimenPartTypeOption> typeOptions,
}) {
  final content = SpecimenPartFilterForm(
    filter: filter,
    typeOptions: typeOptions,
  );
  if (MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact) {
    return showModalBottomSheet<SpecimenPartFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: content,
      ),
    );
  }
  return showDialog<SpecimenPartFilter>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: NahpuContentWidth.form,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: content,
      ),
    ),
  );
}

class SpecimenPartFilterForm extends StatefulWidget {
  const SpecimenPartFilterForm({
    super.key,
    required this.filter,
    required this.typeOptions,
  });

  final SpecimenPartFilter filter;
  final List<SpecimenPartTypeOption> typeOptions;

  @override
  State<SpecimenPartFilterForm> createState() => _SpecimenPartFilterFormState();
}

class _SpecimenPartFilterFormState extends State<SpecimenPartFilterForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fromController;
  late final TextEditingController _toController;
  late Set<String> _partTypes;
  late SpecimenPartNumberType _numberType;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController(
      text: widget.filter.from?.toString() ?? '',
    );
    _toController = TextEditingController(
      text: widget.filter.to?.toString() ?? '',
    );
    _partTypes = Set.of(widget.filter.partTypes);
    _numberType = widget.filter.numberType;
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.documentPartFilterTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: NahpuSpacing.md),
              Text(l10n.documentPartFilterNote),
              const SizedBox(height: NahpuSpacing.xl),
              Text(
                l10n.documentPartFilterTypes,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(l10n.documentPartFilterTypesHint),
              for (final option in widget.typeOptions)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(option.label),
                  value: _partTypes.contains(option.value),
                  onChanged: (selected) => setState(() {
                    if (selected == true) {
                      _partTypes.add(option.value);
                    } else {
                      _partTypes.remove(option.value);
                    }
                  }),
                ),
              const SizedBox(height: NahpuSpacing.xl),
              DropdownButtonFormField<SpecimenPartNumberType>(
                key: ValueKey(_numberType),
                initialValue: _numberType,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.documentPartFilterNumberRange,
                ),
                items: [
                  DropdownMenuItem(
                    value: SpecimenPartNumberType.fieldNumber,
                    child: Text(l10n.documentPartFilterFieldNumber),
                  ),
                  DropdownMenuItem(
                    value: SpecimenPartNumberType.projectNumber,
                    child: Text(l10n.documentPartFilterProjectNumber),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _numberType = value);
                },
              ),
              const SizedBox(height: NahpuSpacing.lg),
              TextFormField(
                controller: _fromController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.documentPartFilterFrom,
                ),
                validator: (value) => _rangeErrorLabel(
                  SpecimenPartFilter.validateNumber(value),
                  l10n,
                ),
              ),
              const SizedBox(height: NahpuSpacing.lg),
              TextFormField(
                controller: _toController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.documentPartFilterTo,
                ),
                validator: (value) => _rangeErrorLabel(
                  SpecimenPartFilter.validateNumber(value) ??
                      SpecimenPartFilter.validateRange(
                        _fromController.text,
                        value ?? '',
                      ),
                  l10n,
                ),
                onFieldSubmitted: (_) => _apply(),
              ),
              const SizedBox(height: NahpuSpacing.md),
              Text(l10n.documentPartFilterRangeHint),
              const SizedBox(height: NahpuSpacing.xl),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: NahpuSpacing.md,
                runSpacing: NahpuSpacing.md,
                children: [
                  TextButton(
                    onPressed: _reset,
                    child: Text(l10n.documentPartFilterReset),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.commonCancel),
                  ),
                  FilledButton(
                    onPressed: _apply,
                    child: Text(l10n.commonApply),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reset() {
    _formKey.currentState!.reset();
    _fromController.clear();
    _toController.clear();
    setState(() {
      _partTypes.clear();
      _numberType = SpecimenPartNumberType.fieldNumber;
    });
  }

  void _apply() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      SpecimenPartFilter(
        partTypes: _partTypes,
        numberType: _numberType,
        from: int.tryParse(_fromController.text.trim()),
        to: int.tryParse(_toController.text.trim()),
      ),
    );
  }
}

String? _rangeErrorLabel(SpecimenPartRangeError? error, AppLocalizations l10n) {
  return switch (error) {
    null => null,
    SpecimenPartRangeError.invalidNumber =>
      l10n.documentPartFilterInvalidNumber,
    SpecimenPartRangeError.fromAfterTo => l10n.documentPartFilterFromAfterTo,
  };
}
