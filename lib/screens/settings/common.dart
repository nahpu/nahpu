import 'package:flutter/material.dart';
import 'package:nahpu/services/utility_services.dart';

class CommonSettingList extends StatelessWidget {
  const CommonSettingList({
    super.key,
    required this.sections,
  });

  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ListView(
              children: sections,
            ),
          )),
    );
  }
}

class CommonSettingSection extends StatelessWidget {
  const CommonSettingSection({
    super.key,
    this.title,
    required this.children,
    this.isDivided = false,
  });

  final String? title;
  final List<Widget> children;
  final bool isDivided;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withAlpha(120),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withAlpha(240),
              width: 1.2,
            ),
          ),
          child: Column(
            children: isDivided
                // If [isDivided] is true, then add a divider after each child
                ? [
                    for (final (index, e) in children.indexed) ...[
                      e,
                      if (index != children.length - 1) const SettingDivider(),
                    ]
                  ]
                : children,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class CommonSettingTile extends StatelessWidget {
  const CommonSettingTile({
    super.key,
    required this.title,
    this.label,
    required this.icon,
    this.value,
    required this.onTap,
    this.trailing,
    this.isNavigation = false,
  });

  final String title;
  final String? label;
  final IconData icon;
  final VoidCallback? onTap;
  final String? value;
  final Widget? trailing;
  final bool isNavigation;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          minVerticalPadding: 0,
          title: Text(title,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface)),
          subtitle: label != null
              ? Text(
                  label!,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(160),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : null,
          leading: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
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
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(120)),
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
        ));
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
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Switch(
              value: value,
              onChanged: onChanged,
            )
          ],
        ));
  }
}

class SettingDivider extends StatelessWidget {
  const SettingDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      thickness: 1.2,
      indent: 60,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(24),
    );
  }
}

class SettingChips extends StatelessWidget {
  const SettingChips({
    super.key,
    required this.title,
    required this.controller,
    required this.labelText,
    required this.chipList,
    required this.hintText,
    required this.onPressed,
    required this.resetLabel,
    required this.onReset,
    required this.forceSentenceCase,
  });

  final String title;
  final String labelText;
  final String hintText;
  final List<Widget> chipList;
  final VoidCallback onPressed;
  final TextEditingController controller;
  final String resetLabel;
  final VoidCallback onReset;
  final bool forceSentenceCase;

  @override
  Widget build(BuildContext context) {
    return CommonSettingSection(
      title: title,
      children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: chipList,
            )),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 270),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: labelText,
                  hintText: hintText,
                ),
                onChanged: (String value) {
                  if (value.isNotEmpty) {
                    controller.value = TextEditingValue(
                      text: forceSentenceCase ? value.toSentenceCase() : value,
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
            ),
            IconButton(
              iconSize: 25,
              color: Theme.of(context).colorScheme.onSurface,
              icon: const Icon(Icons.add),
              onPressed: onPressed,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
          child: TextButton(
            onPressed: onReset,
            child: Text(
              resetLabel,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        )
      ],
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
      backgroundColor: Color.lerp(
        primaryColor,
        Theme.of(context).colorScheme.surface,
        0.85,
      ),
      onDeleted: onDeleted,
    );
  }
}
