import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/shared/pickers.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/services/providers/settings.dart';

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
            lastDate: widget.lastDate);

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
          )),
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
  });

  final TextEditingController controller;
  final void Function(String) onChanged;
  final Iterable<Widget> trailing;
  final String hintText;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      focusNode: focusNode,
      leading: const Icon(Icons.search),
      padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 8.0)),
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
    final hintStyle = Theme.of(context)
        .inputDecorationTheme
        .hintStyle
        ?.copyWith(
            color: Theme.of(context)
                .inputDecorationTheme
                .hintStyle
                ?.color
                ?.withValues(alpha: 0.6));

    return Text(
      text,
      style: hintStyle,
      overflow: TextOverflow.ellipsis,
    );
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
  });

  final String labelText;
  final String hintText;
  final TextEditingController? controller;
  final void Function(String?)? onChanged;
  final bool isLastField;
  final bool isDouble;
  final bool enabled;
  final bool isSigned;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        errorMaxLines: 3,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(
            '${isSigned ? r'^-?' : ''}${r'\d*'}${isDouble ? r'\.?\d*' : ''}'))
      ],
      keyboardType:
          TextInputType.numberWithOptions(decimal: isDouble, signed: isSigned),
      onChanged: onChanged,
      textInputAction:
          isLastField ? TextInputAction.done : TextInputAction.next,
    );
  }
}

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    required this.labelText,
    this.controller,
    required this.hintText,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    required this.isLastField,
    this.maxLines,
  });

  final bool enabled;
  final TextEditingController? controller;
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
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
      ),
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
  const SwitchField(
      {super.key,
      required this.label,
      required this.value,
      required this.onPressed,
      this.disabled});

  final String label;
  final bool value;
  final void Function(bool) onPressed;
  final bool? disabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(
          value: value,
          onChanged: (disabled ?? false) ? null : onPressed,
        ),
      ],
    );
  }
}

class AutoCompleteField extends StatelessWidget {
  const AutoCompleteField({
    super.key,
    required this.focusNode,
    required this.controller,
    required this.options,
    required this.onSelected,
    required this.labelText,
    required this.hintText,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final List<String> options;
  final void Function(String) onSelected;
  final String labelText;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      focusNode: focusNode,
      textEditingController: controller,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: onSelected,
      fieldViewBuilder: (
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
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: Container(
              width: 300,
              constraints: const BoxConstraints(maxHeight: 350),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(option),
                    ),
                  );
                },
              ),
            ),
          ),
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
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onFieldSubmitted;
  final String labelText;
  final String hintText;
  final bool enable;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enable,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
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
      value: null, child: HintDropdownText(text: 'Choose one'));

  static List<DropdownMenuItem<int?>> booleanDropDownItems() {
    return [
      chooseOneListItem,
      DropdownMenuItem(value: 1, child: CommonDropdownText(text: 'Yes')),
      DropdownMenuItem(value: 0, child: CommonDropdownText(text: 'No'))
    ];
  }

  static List<DropdownMenuItem<int?>> addChooseOneToList(
      List<DropdownMenuItem<int?>> list) {
    list.insert(0, chooseOneListItem);
    return list;
  }
}

class UserDefinedSettingField extends ConsumerWidget {
  const UserDefinedSettingField(
      {super.key,
      required this.typePrefKey,
      required this.fmtPrefKey,
      required this.typeName});

  final String typePrefKey;
  final String fmtPrefKey;
  final String typeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController controller = TextEditingController();
    return SettingChips(
      title: '${typeName.toTitleCase()}s',
      controller: controller,
      ref: ref,
      textCasePrefString: fmtPrefKey,
      chipList: ref.watch(userDefinedFieldProvider(typePrefKey)).when(
            data: (data) {
              return data.map((e) {
                return CommonSettingChip(
                  text: e,
                  primaryColor: Theme.of(context).colorScheme.tertiary,
                  onDeleted: () {
                    UtilityServices(ref: ref).removeOption(typePrefKey, e);
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
        UtilityServices(ref: ref)
            .addOption(typePrefKey, controller.text.trim());
        controller.clear();
      },
      resetLabel: 'Match database ${typeName.toLowerCase()}s',
      onReset: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CommonAlertDialog(
                titleText: 'Match database ${typeName.toLowerCase()}s?',
                descText: 'Matching database types will'
                    ' delete all unused ${typeName.toLowerCase()}s',
                confirmFunction: () {
                  UtilityServices(ref: ref).getAllOptions(typePrefKey);
                },
              );
            });
      },
    );
  }
}
