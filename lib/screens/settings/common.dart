import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/common/utility_services.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/forms/fields.dart';
import 'package:nahpu/styles/design_tokens.dart';

class CommonSettingList extends StatelessWidget {
  const CommonSettingList({super.key, required this.sections});

  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: NahpuContentWidth.settings),
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: NahpuSpacing.xl,
            vertical: NahpuSpacing.md,
          ),
          children: sections,
        ),
      ),
    );
  }
}

class CommonSettingSection extends StatelessWidget {
  const CommonSettingSection({
    super.key,
    this.title,
    this.titleTrailing,
    required this.children,
    this.isDivided = false,
  });

  final String? title;
  final Widget? titleTrailing;
  final List<Widget> children;
  final bool isDivided;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  title!,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(180),
                  ),
                ),
              ),
              if (titleTrailing != null)
                Flexible(
                  flex: 4,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: titleTrailing!,
                  ),
                ),
            ],
          ),
        Material(
          clipBehavior: Clip.hardEdge,
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withAlpha(120),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NahpuRadius.lg),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: NahpuStroke.thin,
            ),
          ),
          child: Column(
            children: isDivided
                // If [isDivided] is true, then add a divider after each child
                ? [
                    for (final (index, e) in children.indexed) ...[
                      e,
                      if (index != children.length - 1) const SettingDivider(),
                    ],
                  ]
                : children,
          ),
        ),
        const SizedBox(height: NahpuSpacing.xl),
      ],
    );
  }
}

class CommonSettingTile extends StatelessWidget {
  const CommonSettingTile({
    super.key,
    required this.title,
    this.label,
    this.icon,
    this.leading,
    this.value,
    required this.onTap,
    this.trailing,
    this.titleBadge,
    this.isNavigation = false,
  });

  final String title;
  final String? label;
  final IconData? icon;
  final Widget? leading;
  final VoidCallback? onTap;
  final String? value;
  final Widget? trailing;

  /// Optional marker shown next to [title], such as a beta badge.
  final Widget? titleBadge;
  final bool isNavigation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: ListTile(
        minVerticalPadding: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (titleBadge != null) ...[
              const SizedBox(width: NahpuSpacing.md),
              titleBadge!,
            ],
          ],
        ),
        subtitle: label != null
            ? Text(
                label!,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        leading:
            leading ??
            (icon != null
                ? Icon(icon, color: Theme.of(context).colorScheme.primary)
                : null),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            value != null
                ? Text(
                    value!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(120),
                    ),
                  )
                : const SizedBox.shrink(),
            const SizedBox(width: 4),
            trailing ?? const SizedBox.shrink(),
            isNavigation
                ? const Icon(Icons.arrow_forward_ios)
                : const SizedBox.shrink(),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class SwitchSettings extends StatelessWidget {
  const SwitchSettings({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class SettingDivider extends StatelessWidget {
  const SettingDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      thickness: NahpuStroke.regular,
      indent: 60,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(24),
    );
  }
}

class SettingChips extends StatelessWidget {
  const SettingChips({
    super.key,
    this.title,
    required this.controller,
    required this.ref,
    required this.textCasePrefString,
    required this.labelText,
    required this.chipList,
    required this.hintText,
    required this.onPressed,
    this.onCaseFormatPressed,
    required this.resetLabel,
    required this.onReset,
  });

  final String? title;
  final TextEditingController controller;
  final WidgetRef ref;
  final String textCasePrefString;
  final String labelText;
  final List<Widget> chipList;
  final String hintText;
  final VoidCallback onPressed;
  final VoidCallback? onCaseFormatPressed;
  final String resetLabel;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final content = [
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: chipList,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: AsyncTextField(
                  controller: controller,
                  labelText: labelText,
                  hintText: hintText,
                  onPressed: onPressed,
                  ref: ref,
                  textCasePrefString: textCasePrefString,
                ),
              ),
            ),
            IconButton(
              iconSize: NahpuControlSize.icon,
              color: Theme.of(context).colorScheme.onSurface,
              icon: const Icon(Icons.add),
              onPressed: onPressed,
            ),
            if (onCaseFormatPressed != null)
              IconButton(
                tooltip: 'Set case format',
                icon: const Icon(Icons.text_format_outlined),
                onPressed: onCaseFormatPressed,
              ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: TextButton(
          onPressed: onReset,
          child: Text(resetLabel, style: const TextStyle(fontSize: 14)),
        ),
      ),
    ];

    return title == null
        ? Column(children: content)
        : CommonSettingSection(title: title, children: content);
  }
}

class AsyncTextField extends StatelessWidget {
  const AsyncTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.onPressed,
    required this.ref,
    required this.textCasePrefString,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final VoidCallback onPressed;
  final WidgetRef ref;
  final String textCasePrefString;

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(textCaseFmtProvider(textCasePrefString))
        .when(
          data: (fmt) => TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
            ),
            onChanged: (String value) {
              if (value.isNotEmpty) {
                controller.value = TextEditingValue(
                  text: value.toTextCaseFmt(fmt),
                  selection: controller.selection,
                );
              }
            },
            onSubmitted: (String? value) {
              if (value != null && value.isNotEmpty) {
                onPressed();
              }
            },
          ),
          loading: () => CommonProgressIndicator(),
          error: (e, s) => Text('Error'),
        );
  }
}

class TextCaseFmtDropDown extends StatelessWidget {
  const TextCaseFmtDropDown({
    super.key,
    required this.ref,
    required this.label,
    required this.textCasePrefString,
  });

  final WidgetRef ref;
  final String label;
  final String textCasePrefString;

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(textCaseFmtProvider(textCasePrefString))
        .when(
          data: (fmt) => DropdownButtonFormField<TextCaseFmt>(
            isExpanded: true,
            initialValue: fmt,
            decoration: InputDecoration(labelText: label),
            items: textCaseFmtMap.entries
                .map(
                  (e) => DropdownMenuItem<TextCaseFmt>(
                    value: e.key,
                    child: CommonDropdownText(text: e.value),
                  ),
                )
                .toList(),
            onChanged: (TextCaseFmt? selectedFmt) async {
              if (selectedFmt != null) {
                await ref
                    .read(userConfigSettingsServiceProvider)
                    .setTextCaseFormat(textCasePrefString, selectedFmt.name);
                ref.invalidate(textCaseFmtProvider(textCasePrefString));
              }
            },
          ),
          loading: () => const CommonProgressIndicator(),
          error: (e, s) => const Text('Error'),
        );
  }
}

class CommonSettingChip extends StatelessWidget {
  const CommonSettingChip({
    super.key,
    required this.text,
    required this.primaryColor,
    required this.onDeleted,
  });

  final String text;
  final Color primaryColor;
  final void Function() onDeleted;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      shape: const StadiumBorder(side: BorderSide(color: Colors.transparent)),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      onDeleted: onDeleted,
    );
  }
}
