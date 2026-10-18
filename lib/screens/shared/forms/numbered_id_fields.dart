import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/specimens/numbered_id.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Prefix, next number, and suffix for an auto-numbered ID, with a preview of
/// the next one. Each field saves to [store] as it changes.
class NumberedIdFields extends StatefulWidget {
  const NumberedIdFields({
    super.key,
    required this.store,
    required this.useHorizontalLayout,
    this.previewLabel = 'Next ID',
    this.prefixHint = 'M',
    this.numberHint = '0001',
    this.suffixHint = '-T',
  });

  final NumberedIdStore store;
  final bool useHorizontalLayout;

  /// Names the preview, such as `Next tissue ID`.
  final String previewLabel;
  final String prefixHint;
  final String numberHint;
  final String suffixHint;

  @override
  State<NumberedIdFields> createState() => _NumberedIdFieldsState();
}

class _NumberedIdFieldsState extends State<NumberedIdFields> {
  late final NumberedIdFormat _initial = widget.store.format;
  late final TextEditingController _prefixCtr = TextEditingController(
    text: _initial.prefix,
  );
  late final TextEditingController _numberCtr = TextEditingController(
    text: _initial.number,
  );
  late final TextEditingController _suffixCtr = TextEditingController(
    text: _initial.suffix,
  );

  @override
  void dispose() {
    _prefixCtr.dispose();
    _numberCtr.dispose();
    _suffixCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = NumberedIdFormat(
      prefix: _prefixCtr.text,
      number: _numberCtr.text,
      suffix: _suffixCtr.text,
    ).nextTag;
    final store = widget.store;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            TextField(
              key: const ValueKey('numbered-id-prefix'),
              controller: _prefixCtr,
              decoration: InputDecoration(
                labelText: 'Prefix',
                hintText: widget.prefixHint,
              ),
              onChanged: (value) async {
                setState(() {});
                await store.setPrefix(value);
              },
            ),
            TextField(
              key: const ValueKey('numbered-id-number'),
              controller: _numberCtr,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Next number',
                hintText: widget.numberHint,
              ),
              onChanged: (value) async {
                setState(() {});
                await store.setNumber(value);
              },
            ),
            TextField(
              key: const ValueKey('numbered-id-suffix'),
              controller: _suffixCtr,
              decoration: InputDecoration(
                labelText: 'Suffix',
                hintText: widget.suffixHint,
              ),
              onChanged: (value) async {
                setState(() {});
                await store.setSuffix(value);
              },
            ),
          ],
        ),
        const SizedBox(height: NahpuSpacing.md),
        CommonPadding(
          child: Text(
            preview == null
                ? 'Set a next number to auto-number · Leading zeros are kept'
                : '${widget.previewLabel}: $preview · Leading zeros are kept',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
