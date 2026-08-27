import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/shared/forms/pickers.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/services/settings/controlled_vocabulary_services.dart';

class CommonDateField extends ConsumerStatefulWidget {
  const CommonDateField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.initialDate,
    required this.lastDate,
    required this.onTap,
    required this.onClear,
  });

  final DateEditingController controller;
  final String labelText;
  final String hintText;
  final DateTime initialDate;
  final DateTime lastDate;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  CommonDateFieldState createState() => CommonDateFieldState();
}

class CommonDateFieldState extends ConsumerState<CommonDateField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
      ),
      controller: widget.controller,
      onTap: () async {
        final result = await showCustomDatePicker(
          context: context,
          initialDate: widget.controller.dateTime ?? widget.initialDate,
          firstDate: DateTime(2000),
          lastDate: widget.lastDate,
        );

        final returnType = result?.$2 ?? DialogReturnType.cancel;
        final selectedDate = result?.$1;

        switch (returnType) {
          case DialogReturnType.confirm: // OK pressed
            if (selectedDate != null && mounted) {
              widget.controller.dateTime = selectedDate;
              widget.onTap();
            }
          case DialogReturnType.clear: // Clear pressed
            if (selectedDate == null && mounted) {
              widget.controller.dateTime = null;
              widget.onClear();
            }
          case DialogReturnType.cancel: // Cancel pressed or widget closed
          // No action needed
        }
      },
    );
  }
}

class CommonTimeField extends ConsumerStatefulWidget {
  const CommonTimeField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.initialTime,
    required this.onTap,
    required this.onClear,
  });

  final TimeEditingController controller;
  final String labelText;
  final String hintText;
  final TimeOfDay initialTime;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  CommonTimeFieldState createState() => CommonTimeFieldState();
}

class CommonTimeFieldState extends ConsumerState<CommonTimeField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTimeChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTimeChanged);
    super.dispose();
  }

  void _onTimeChanged() {
    // Call onTap whenever the time value changes
    if (widget.controller.time != null) {
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
      ),
      controller: widget.controller,
      onTap: () async {
        final result = await showCustomTimePicker(
          context: context,
          initialTime: widget.controller.timeOfDay ?? widget.initialTime,
        );

        final returnType = result?.$2 ?? DialogReturnType.cancel;
        final selectedTime = result?.$1;

        switch (returnType) {
          case DialogReturnType.confirm: // OK pressed
            if (selectedTime != null && mounted) {
              widget.controller.timeOfDay = selectedTime;
              widget.onTap();
            }
          case DialogReturnType.clear: // Clear pressed
            if (selectedTime == null && mounted) {
              widget.controller.timeOfDay = null;
              widget.onClear();
            }
          case DialogReturnType.cancel: // Cancel pressed or widget closed
          // No action needed
        }
      },
    );
  }
}

class ExpandedSearchBar extends StatelessWidget {
  const ExpandedSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.trailing,
    required this.hintText,
    required this.focusNode,
  });

  final TextEditingController controller;
  final void Function(String) onChanged;
  final Iterable<Widget> trailing;
  final String hintText;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: CommonSearchBar(
          controller: controller,
          focusNode: focusNode,
          hintText: hintText,
          trailing: trailing,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class CommonSearchBar extends StatelessWidget {
  const CommonSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.trailing,
    required this.hintText,
    required this.focusNode,
    this.constraints,
  });

  final TextEditingController controller;
  final void Function(String) onChanged;
  final Iterable<Widget> trailing;
  final String hintText;
  final FocusNode focusNode;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      focusNode: focusNode,
      leading: const Icon(Icons.search),
      padding: const WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: 8.0),
      ),
      constraints: constraints,
      elevation: WidgetStateProperty.all(0),
      hintText: hintText,
      backgroundColor: WidgetStateProperty.all(Colors.grey.withAlpha(48)),
      trailing: trailing,
      onChanged: onChanged,
    );
  }
}

class CommonDropdownText extends StatelessWidget {
  const CommonDropdownText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class HintDropdownText extends StatelessWidget {
  const HintDropdownText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    // attempts to copy the default hint text styling
    final hintStyle = Theme.of(context).inputDecorationTheme.hintStyle
        ?.copyWith(
          color: Theme.of(
            context,
          ).inputDecorationTheme.hintStyle?.color?.withValues(alpha: 0.6),
        );

    return Text(text, style: hintStyle, overflow: TextOverflow.ellipsis);
  }
}

class CommonNumField extends ConsumerWidget {
  const CommonNumField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.enabled = true,
    required this.isLastField,
    this.isDouble = false,
    this.isSigned = false,
    this.errorText,
    this.focusNode,
    this.helperText,
    this.isBracketed = false,
  });

  final String labelText;
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(String?)? onChanged;
  final bool isLastField;
  final bool isDouble;
  final bool enabled;
  final bool isSigned;
  final String? errorText;
  final String? helperText;
  final bool isBracketed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String suffixLabelText = '$labelText${isBracketed ? "*" : ""}';
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: suffixLabelText,
        hintText: hintText,
        errorText: errorText,
        helperText: helperText,
        errorMaxLines: 3,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(
            '${isSigned ? r'^-?' : ''}${r'\d*'}${isDouble ? r'\.?\d*' : ''}',
          ),
        ),
      ],
      keyboardType: TextInputType.numberWithOptions(
        decimal: isDouble,
        signed: isSigned,
      ),
      onChanged: onChanged,
      textInputAction: isLastField
          ? TextInputAction.done
          : TextInputAction.next,
    );
  }
}

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.focusNode,
    required this.hintText,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    required this.isLastField,
    this.maxLines,
  });

  final bool enabled;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final void Function(String?)? onChanged;
  final bool isLastField;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      maxLines: maxLines,
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(labelText: labelText, hintText: hintText),
      keyboardType: keyboardType,
      onChanged: onChanged,
      textInputAction: keyboardType == TextInputType.multiline
          ? TextInputAction.newline
          : isLastField
          ? TextInputAction.done
          : TextInputAction.next,
    );
  }
}

class SwitchField extends StatelessWidget {
  const SwitchField({
    super.key,
    required this.label,
    required this.value,
    required this.onPressed,
    this.disabled,
  });

  final String label;
  final bool value;
  final void Function(bool) onPressed;
  final bool? disabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        Switch(value: value, onChanged: (disabled ?? false) ? null : onPressed),
      ],
    );
  }
}

/// A text field that suggests entries from [options] as the user types.
///
/// Generic over the option type so a selection carries its record. Matching an
/// option back to its record by display string would be ambiguous whenever two
/// records render the same text.
class AutoCompleteField<T extends Object> extends StatelessWidget {
  const AutoCompleteField({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.options,
    required this.displayStringFor,
    required this.onSelected,
    required this.labelText,
    required this.hintText,
    this.isProminent = false,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final List<T> options;

  /// The text shown for an option, and the text matched against as they type.
  final String Function(T) displayStringFor;
  final void Function(T) onSelected;
  final String labelText;
  final String hintText;

  /// Draws a full border instead of the form default underline.
  ///
  /// Use for a lookup that fills other fields, so it does not read as one more
  /// value to type.
  final bool isProminent;

  /// Caps the overlay so a long list scrolls instead of covering the form.
  static const double _maxOptionsHeight = 320;

  @override
  Widget build(BuildContext context) {
    // The overlay is positioned over the field but sized independently, so the
    // field's width has to be measured and handed to the options view.
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : null;
        return RawAutocomplete<T>(
          focusNode: focusNode,
          textEditingController: controller,
          displayStringForOption: displayStringFor,
          optionsBuilder: (TextEditingValue textEditingValue) {
            final query = textEditingValue.text.trim().toLowerCase();
            if (query.isEmpty) return const Iterable.empty();
            return options.where(
              (option) =>
                  displayStringFor(option).toLowerCase().contains(query),
            );
          },
          onSelected: onSelected,
          fieldViewBuilder:
              (
                BuildContext context,
                TextEditingController controller,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                return AutoCompleteText(
                  controller: controller,
                  enable: true,
                  focusNode: focusNode,
                  labelText: labelText,
                  hintText: hintText,
                  isProminent: isProminent,
                  onFieldSubmitted: (String value) {
                    onFieldSubmitted();
                  },
                );
              },
          optionsViewBuilder:
              (
                BuildContext context,
                AutocompleteOnSelected<T> onSelected,
                Iterable<T> options,
              ) {
                final colors = Theme.of(context).colorScheme;
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    // Opaque so the form does not show through, and bordered
                    // rather than shadowed to match every other NAHPU surface
                    // (see the card theme in themes.dart).
                    color: colors.surfaceContainerHighest,
                    elevation: NahpuElevation.none,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NahpuRadius.lg),
                      side: BorderSide(
                        color: colors.outlineVariant,
                        width: NahpuStroke.thin,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      width: fieldWidth,
                      constraints: const BoxConstraints(
                        maxHeight: _maxOptionsHeight,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          vertical: NahpuSpacing.md,
                        ),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            dense: true,
                            title: Text(
                              displayStringFor(option),
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
        );
      },
    );
  }
}

class AutoCompleteText extends StatelessWidget {
  const AutoCompleteText({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.labelText,
    required this.hintText,
    required this.onFieldSubmitted,
    required this.enable,
    this.isProminent = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onFieldSubmitted;
  final String labelText;
  final String hintText;
  final bool enable;
  final bool isProminent;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enable,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        // Record-entry fields keep the theme underline; a prominent lookup
        // takes the full border used elsewhere for non-entry controls.
        border: isProminent
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(NahpuRadius.md),
              )
            : null,
        isDense: isProminent,
        prefixIcon: isProminent ? const Icon(Icons.travel_explore) : null,
      ),
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
    );
  }
}

class DropDownMenuItems {
  static DropdownMenuItem<int?> chooseOneListItem = DropdownMenuItem(
    value: null,
    child: HintDropdownText(text: 'Choose one'),
  );

  static List<DropdownMenuItem<int?>> booleanDropDownItems() {
    return [
      chooseOneListItem,
      DropdownMenuItem(value: 1, child: CommonDropdownText(text: 'Yes')),
      DropdownMenuItem(value: 0, child: CommonDropdownText(text: 'No')),
    ];
  }

  static List<DropdownMenuItem<int?>> addChooseOneToList(
    List<DropdownMenuItem<int?>> list,
  ) {
    list.insert(0, chooseOneListItem);
    return list;
  }
}

class UserDefinedSettingField extends ConsumerWidget {
  const UserDefinedSettingField({
    super.key,
    required this.typePrefKey,
    required this.fmtPrefKey,
    required this.typeName,
    this.onCaseFormatPressed,
    this.sectionTitle,
    this.pluralName,
  });

  final String typePrefKey;
  final String fmtPrefKey;
  final String typeName;
  final VoidCallback? onCaseFormatPressed;
  final String? sectionTitle;
  final String? pluralName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController controller = TextEditingController();
    final plural = pluralName ?? '${typeName.toTitleCase()}s';
    return SettingChips(
      title: sectionTitle,
      controller: controller,
      ref: ref,
      textCasePrefString: fmtPrefKey,
      chipList: ref
          .watch(effectiveUserDefinedFieldProvider(typePrefKey))
          .when(
            data: (data) {
              return data.map((e) {
                return CommonSettingChip(
                  text: e,
                  primaryColor: Theme.of(context).colorScheme.tertiary,
                  onDeleted: () {
                    UtilityServices(
                      ref: ref,
                    ).removeOption(context, typePrefKey, e);
                  },
                );
              }).toList();
            },
            loading: () => [const CommonProgressIndicator()],
            error: (e, _) => [Text('Error: $e')],
          ),
      labelText: 'Add ${typeName.toLowerCase()}',
      hintText: 'Enter ${typeName.toLowerCase()}',
      onPressed: () {
        UtilityServices(
          ref: ref,
        ).addOption(typePrefKey, controller.text.trim());
        controller.clear();
      },
      onCaseFormatPressed: onCaseFormatPressed,
      resetLabel: 'Match database',
      onReset: () => _showDatabaseMatchDialog(context, ref, plural),
    );
  }

  void _showDatabaseMatchDialog(
    BuildContext context,
    WidgetRef ref,
    String plural,
  ) {
    var mode = DatabaseMatchMode.appendMissing;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final description = switch (mode) {
            DatabaseMatchMode.appendMissing =>
              'Add values found in the database without changing your existing '
                  '$plural.',
            DatabaseMatchMode.overrideAll =>
              'Replace all configured $plural with the values currently found '
                  'in the database.',
          };
          return AlertDialog(
            title: Text('Match database ${plural.toLowerCase()}?'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SegmentedButton<DatabaseMatchMode>(
                    segments: const [
                      ButtonSegment(
                        value: DatabaseMatchMode.appendMissing,
                        label: Text('Append missing'),
                      ),
                      ButtonSegment(
                        value: DatabaseMatchMode.overrideAll,
                        label: Text('Override all'),
                      ),
                    ],
                    selected: {mode},
                    onSelectionChanged: (selection) {
                      setState(() => mode = selection.single);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(description),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  await UtilityServices(
                    ref: ref,
                  ).matchDatabaseOptions(typePrefKey, mode: mode);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Match database'),
              ),
            ],
          );
        },
      ),
    );
  }
}
