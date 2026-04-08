import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/screens/projects/dashboard.dart';

class ProjectBackButton extends ConsumerWidget {
  const ProjectBackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const Dashboard();
        }));
        ref.read(projectNavbarIndexProvider.notifier).state = 0;
      },
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
      child: Text(showMore ? 'Show less' : 'Show more'),
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
        disabledForegroundColor:
            Theme.of(context).colorScheme.onSurface.withAlpha(160),
        disabledBackgroundColor:
            Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 0,
      ),
      icon: isRunning
          ? const SizedBox(
              height: 10,
              width: 10,
              child: CircularProgressIndicator(),
            )
          : Icon(icon),
      onPressed: isRunning ? null : onPressed,
      label: Text(label),
    );
  }
}

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    required this.onPressed,
  });

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
      label: const Text('Share'),
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

class FormButtonWithDelete extends StatelessWidget {
  const FormButtonWithDelete({
    super.key,
    required this.isEditing,
    required this.onDeleted,
    required this.onSubmitted,
  });

  final bool isEditing;
  final VoidCallback onDeleted;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return isEditing
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onDeleted,
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              _buildFormButton(),
            ],
          )
        : _buildFormButton();
  }

  Widget _buildFormButton() {
    return FormButton(
      isEditing: isEditing,
      onSubmitted: onSubmitted,
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
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Icon(icon));
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
          shape: const StadiumBorder(
            side: BorderSide(color: Colors.transparent),
          ),
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          label: label,
          selected: selectedValue == index,
          onSelected: onSelected,
        ));
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
      ),
      onPressed: onPressed,
      icon: Icon(icon),
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
    return Wrap(
      children: [
        SecondaryButton(
          text: 'Cancel',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(width: 10),
        PrimaryButton(
          label: isEditing ? 'Update' : 'Add',
          icon: isEditing ? Icons.check : Icons.add,
          onPressed: onSubmitted,
        ),
      ],
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(
      {super.key, required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
        foregroundColor: Theme.of(context).colorScheme.secondary,
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class TertiaryButton extends StatelessWidget {
  const TertiaryButton(
      {super.key, required this.text, required this.onPressed});

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

class DeleteMenuButton extends StatelessWidget {
  const DeleteMenuButton({
    super.key,
    required this.deleteAll,
  });

  final bool deleteAll;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        deleteAll ? Icons.delete_forever_outlined : Icons.delete_outline,
        color: Theme.of(context).colorScheme.error,
      ),
      title: Text(
        deleteAll ? 'Delete all records' : 'Delete record',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

class CreateMenuButton extends StatelessWidget {
  const CreateMenuButton({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.create_outlined),
      title: Text(
        text,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class DuplicateMenuButton extends StatelessWidget {
  const DuplicateMenuButton({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.copy_outlined),
      title: Text(text),
    );
  }
}

class PdfExportMenuButton extends StatelessWidget {
  const PdfExportMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: Icon(Icons.picture_as_pdf_outlined),
      title: Text('Export to PDF'),
    );
  }
}

class FindMenuButton extends StatelessWidget {
  const FindMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: Icon(Icons.search_outlined),
      title: Text('Find'),
    );
  }
}

class ListCheckBox extends StatelessWidget {
  const ListCheckBox({
    super.key,
    required this.isDisabled,
    required this.value,
    required this.onChanged,
  });

  final bool isDisabled;
  final bool value;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Checkbox.adaptive(
        activeColor: Theme.of(context).colorScheme.onSurface,
        checkColor: Theme.of(context).colorScheme.surface,
        side: BorderSide(
          width: 1.5,
          color: isDisabled
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Theme.of(context).colorScheme.onSurface,
        ),
        value: value,
        onChanged: isDisabled ? null : onChanged);
  }
}

class DeleteItemsButton extends StatelessWidget {
  const DeleteItemsButton({
    super.key,
    required this.selectedItems,
    required this.itemName,
    required this.onPressedFunction,
    this.customIconButtonText,
    this.customDialogHeader,
    this.customDialogText,
    this.customDialogButtonText,
  });

  final List<dynamic> selectedItems;
  final String itemName;
  final VoidCallback? onPressedFunction;
  final String? customIconButtonText;
  final String? customDialogHeader;
  final String? customDialogText;
  final String? customDialogButtonText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
            visible: selectedItems.isNotEmpty,
            child: Text(
                customIconButtonText ??
                    'Delete ${selectedItems.length} $itemName',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ))),
        IconButton(
          color: Theme.of(context).colorScheme.error,
          onPressed: selectedItems.isEmpty
              ? null
              : () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(customDialogHeader ?? 'Delete $itemName'),
                          content: Text(customDialogText ??
                              'Are you sure you want to delete the selected $itemName?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: onPressedFunction,
                              child: Text(customDialogButtonText ?? 'Delete',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  )),
                            ),
                          ],
                        );
                      });
                },
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
