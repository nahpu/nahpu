import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  final TextEditingController controller;
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
        final selectedDate = await showDatePicker(
            context: context,
            cancelText: "Clear",
            initialDate: widget.initialDate,
            firstDate: DateTime(2000),
            lastDate: widget.lastDate);

        // OK pressed
        if (selectedDate != null && mounted) {
          widget.controller.text = DateFormat.yMMMd().format(selectedDate);
          widget.onTap();
        }

        // Clear pressed (or picker closed)
        if (selectedDate == null && mounted) {
          widget.controller.text = "";
          widget.onClear();
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

  final TextEditingController controller;
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
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
      ),
      controller: widget.controller,
      onTap: () async {
        final time = await _showTimePicker(
          context: context,
          cancelText: "Clear",
          initialTime: widget.initialTime,
        );

        // OK pressed
        if (time != null && mounted) {
          widget.controller.text = _formatTimeOfDay(time);
          widget.onTap();
        }

        // Clear pressed (or picker closed)
        if (time == null && mounted) {
          widget.controller.text = "";
          widget.onClear();
        }
      },
    );
  }

  Future<TimeOfDay?> _showTimePicker({
    required BuildContext context,
    required String cancelText,
    required TimeOfDay initialTime,
  }) {
    return showTimePicker(
      context: context,
      cancelText: cancelText,
      initialTime: initialTime,
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return time.format(context);
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
  });

  final String labelText;
  final String hintText;
  final TextEditingController? controller;
  final void Function(String?)? onChanged;
  final bool isLastField;
  final bool isDouble;
  final bool enabled;
  final bool isSigned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
      ),
      inputFormatters: isDouble
          ? [FilteringTextInputFormatter.allow(RegExp(r"[0-9.-]"))]
          : [FilteringTextInputFormatter.digitsOnly],
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
      textInputAction:
          isLastField ? TextInputAction.done : TextInputAction.next,
    );
  }
}

class SwitchField extends StatelessWidget {
  const SwitchField({
    super.key,
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final bool value;
  final void Function(bool) onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(
          value: value,
          onChanged: onPressed,
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
