import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';

class ResponsiveMasterDetail extends StatelessWidget {
  const ResponsiveMasterDetail({
    super.key,
    required this.listPane,
    required this.detailsPane,
    this.wideLayoutKey,
  });

  final Widget listPane;
  final Widget detailsPane;
  final Key? wideLayoutKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= NahpuBreakpoints.compact;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: NahpuContentWidth.settings,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                NahpuSpacing.xl,
                0,
                NahpuSpacing.xl,
                NahpuSpacing.xl,
              ),
              child: isWide ? _wideLayout(constraints.maxWidth) : listPane,
            ),
          ),
        );
      },
    );
  }

  Widget _wideLayout(double availableWidth) {
    final constrainedWidth = math.min(
      availableWidth,
      NahpuContentWidth.settings,
    );
    final contentWidth = constrainedWidth - (NahpuSpacing.xl * 2);
    final listWidth = math.min(380.0, contentWidth * 0.45);
    return Row(
      key: wideLayoutKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: listWidth,
          child: OutlinedSurface(child: listPane),
        ),
        const SizedBox(width: NahpuSpacing.lg),
        Expanded(child: OutlinedSurface(child: detailsPane)),
      ],
    );
  }
}

class OutlinedSurface extends StatelessWidget {
  const OutlinedSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withAlpha(80),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NahpuRadius.large),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class OutlinedListTile extends StatelessWidget {
  const OutlinedListTile({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.trailing,
    this.isFocused = false,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NahpuSpacing.md,
        NahpuSpacing.xs,
        NahpuSpacing.md,
        NahpuSpacing.xs,
      ),
      child: Material(
        color: isFocused
            ? colorScheme.secondaryContainer.withAlpha(110)
            : colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NahpuRadius.medium),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          onTap: onTap,
        ),
      ),
    );
  }
}

class EmptyDetailsPrompt extends StatelessWidget {
  const EmptyDetailsPrompt({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
