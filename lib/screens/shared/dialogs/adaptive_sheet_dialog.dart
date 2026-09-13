import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Builds the content of [showAdaptiveSheetDialog]. [isSheet] is true when the
/// content shows in a bottom sheet rather than a dialog.
typedef AdaptiveSheetDialogBuilder =
    Widget Function(BuildContext context, bool isSheet);

/// Shows [builder] as a bottom sheet on compact screens, where a dialog is
/// cramped, and as a dialog on wider screens.
///
/// Set [isDismissible] to false for content that holds unsaved input, so a
/// stray tap outside it or a drag does not throw the input away.
Future<T?> showAdaptiveSheetDialog<T>({
  required BuildContext context,
  required AdaptiveSheetDialogBuilder builder,
  bool isDismissible = true,
  double maxWidth = NahpuContentWidth.form,
}) {
  if (MediaQuery.sizeOf(context).width < NahpuBreakpoints.compact) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: isDismissible,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      builder: (context) => builder(context, true),
    );
  }
  return showDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: builder(context, false),
      ),
    ),
  );
}

/// Asks the user to confirm an action. Returns true only when confirmed.
Future<bool> showAdaptiveConfirmation({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  IconData? confirmIcon,
  bool isDestructive = false,
}) async {
  final confirmed = await showAdaptiveSheetDialog<bool>(
    context: context,
    maxWidth: NahpuContentWidth.dialog,
    builder: (context, _) => _AdaptiveConfirmation(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      confirmIcon: confirmIcon,
      isDestructive: isDestructive,
    ),
  );
  return confirmed ?? false;
}

/// The standard layout for [showAdaptiveSheetDialog] content: a title, a
/// scrolling body, and actions pinned below the body so they stay reachable
/// however long the body grows.
class AdaptiveSheetDialogBody extends StatelessWidget {
  const AdaptiveSheetDialogBody({
    super.key,
    required this.title,
    required this.child,
    this.description,
    this.actions = const [],
    this.showCloseButton = true,
    this.isCloseEnabled = true,
  });

  final String title;
  final Widget child;
  final String? description;

  /// Buttons below the body. They wrap onto more lines when the row is full.
  final List<Widget> actions;

  /// A bottom sheet is dismissed with its drag handle instead.
  final bool showCloseButton;

  /// Turn off while work is running that closing would interrupt.
  final bool isCloseEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = this.description;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          NahpuSpacing.xl,
          NahpuSpacing.md,
          NahpuSpacing.xl,
          MediaQuery.viewInsetsOf(context).bottom + NahpuSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Keeps the title in the same place with or without the button.
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: NahpuControlSize.touchTarget,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title, style: theme.textTheme.headlineSmall),
                  ),
                  if (showCloseButton)
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close),
                      onPressed: isCloseEnabled
                          ? () => Navigator.of(context).pop()
                          : null,
                    ),
                ],
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: NahpuSpacing.xs),
              Text(description, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: NahpuSpacing.lg),
            Flexible(child: SingleChildScrollView(child: child)),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: NahpuSpacing.xl),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                overflowAlignment: OverflowBarAlignment.end,
                spacing: NahpuSpacing.md,
                overflowSpacing: NahpuSpacing.md,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdaptiveConfirmation extends StatelessWidget {
  const _AdaptiveConfirmation({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmIcon,
    required this.isDestructive,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final IconData? confirmIcon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = isDestructive
        ? FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          )
        : null;
    final confirmIcon = this.confirmIcon;
    return AdaptiveSheetDialogBody(
      title: title,
      showCloseButton: false,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        if (confirmIcon == null)
          FilledButton(
            style: style,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          )
        else
          FilledButton.icon(
            style: style,
            onPressed: () => Navigator.of(context).pop(true),
            icon: Icon(confirmIcon),
            label: Text(confirmLabel),
          ),
      ],
      child: Text(message),
    );
  }
}
