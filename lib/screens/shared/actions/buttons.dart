import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/layout/project_shell.dart';
import 'package:nahpu/services/localization/l10n.dart';

class ProjectBackButton extends ConsumerWidget {
  const ProjectBackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackButton(
      onPressed: () => ProjectShell.returnToTab(context, ref, 0),
    );
  }
}

class ShowMoreButton extends StatelessWidget {
  const ShowMoreButton({
    super.key,
    required this.onPressed,
    required this.showMore,
  });

  final VoidCallback onPressed;
  final bool showMore;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        showMore ? context.l10n.sharedShowLess : context.l10n.sharedShowMore,
      ),
    );
  }
}

class ProgressButton extends StatelessWidget {
  const ProgressButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isRunning,
    required this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isRunning;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDisabled = isRunning || onPressed == null;
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: isDisabled
            ? Theme.of(context).colorScheme.onSurface.withAlpha(160)
            : Theme.of(context).colorScheme.onPrimaryContainer,
        backgroundColor: isDisabled
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.primaryContainer,
        disabledForegroundColor: Theme.of(
          context,
        ).colorScheme.onSurface.withAlpha(160),
        disabledBackgroundColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest,
        elevation: 0,
      ),
      icon: isRunning
          ? const SizedBox(
              height: NahpuControlSize.indicator,
              width: NahpuControlSize.indicator,
              child: CircularProgressIndicator(),
            )
          : Icon(icon),
      onPressed: isRunning ? null : onPressed,
      label: Text(label),
    );
  }
}

class ShareButton extends StatelessWidget {
  const ShareButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
      ),
      icon: Icon(Icons.adaptive.share_outlined),
      onPressed: onPressed,
      label: Text(context.l10n.sharedShare),
    );
  }
}

class FormElevButton extends StatelessWidget {
  const FormElevButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.enabled,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      onPressed: enabled ? onPressed : null,
      label: label,
      icon: icon,
    );
  }
}

class PrimaryIconButton extends StatelessWidget {
  const PrimaryIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 24,
    );
  }
}

class CommonChip extends StatelessWidget {
  const CommonChip({
    super.key,
    required this.index,
    required this.label,
    required this.selectedValue,
    required this.onSelected,
  });

  final int index;
  final int selectedValue;
  final Widget label;
  final void Function(bool) onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: ChoiceChip(
        shape: const StadiumBorder(side: BorderSide(color: Colors.transparent)),
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        label: label,
        selected: selectedValue == index,
        onSelected: onSelected,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isRunning = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  /// Swaps the icon for a spinner and blocks a second press while work runs.
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isRunning ? null : onPressed,
      icon: isRunning
          ? const SizedBox.square(
              dimension: NahpuControlSize.indicator,
              child: CircularProgressIndicator(
                strokeWidth: NahpuStroke.regular,
              ),
            )
          : Icon(icon),
      label: Text(label),
    );
  }
}

class FormButton extends StatelessWidget {
  const FormButton({
    super.key,
    required this.isEditing,
    required this.onSubmitted,
  });

  final bool isEditing;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.lg),
      child: Wrap(
        spacing: 16,
        children: [
          SecondaryButton(
            text: l10n.commonCancel,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 24),
          PrimaryButton(
            label: isEditing ? l10n.sharedUpdate : l10n.sharedAdd,
            icon: isEditing ? Icons.check : Icons.add,
            onPressed: onSubmitted,
          ),
        ],
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Theme.of(context).colorScheme.secondary),
        foregroundColor: Theme.of(context).colorScheme.secondary,
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class TertiaryButton extends StatelessWidget {
  const TertiaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}

class PdfExportMenuButton extends StatelessWidget {
  const PdfExportMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.picture_as_pdf_outlined),
      title: Text(context.l10n.sharedExportAs),
    );
  }
}

class FindMenuButton extends StatelessWidget {
  const FindMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.search_outlined),
      title: Text(context.l10n.sharedFind),
    );
  }
}

class ListCheckBox extends StatelessWidget {
  const ListCheckBox({
    super.key,
    required this.isDisabled,
    required this.value,
    required this.onChanged,
    this.isDense = false,
  });

  final bool isDisabled;
  final bool value;
  final void Function(bool?) onChanged;
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      materialTapTargetSize: isDense
          ? MaterialTapTargetSize.shrinkWrap
          : MaterialTapTargetSize.padded,
      visualDensity: isDense ? VisualDensity.compact : null,
      onChanged: isDisabled ? null : onChanged,
    );
  }
}

class DeleteItemsButton extends StatelessWidget {
  const DeleteItemsButton({
    super.key,
    required this.selectedItems,
    required this.onPressedFunction,
    this.customIconButtonText,
    this.customDialogHeader,
    this.customDialogText,
    this.customDialogButtonText,
  });

  final List<dynamic> selectedItems;
  final VoidCallback? onPressedFunction;
  final String? customIconButtonText;
  final String? customDialogHeader;
  final String? customDialogText;
  final String? customDialogButtonText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Visibility(
          visible: selectedItems.isNotEmpty,
          child: Text(
            customIconButtonText ??
                l10n.sharedDeleteSelectedCount(selectedItems.length),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        IconButton(
          color: Theme.of(context).colorScheme.error,
          onPressed: selectedItems.isEmpty
              ? null
              : () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          customDialogHeader ?? l10n.sharedDeleteSelectedTitle,
                        ),
                        content: Text(
                          customDialogText ?? l10n.sharedDeleteSelectedBody,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(l10n.commonCancel),
                          ),
                          TextButton(
                            onPressed: onPressedFunction,
                            child: Text(
                              customDialogButtonText ?? l10n.commonDelete,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
