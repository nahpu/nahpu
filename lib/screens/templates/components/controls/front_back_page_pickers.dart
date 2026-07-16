import 'package:flutter/material.dart';

class TemplateSideSwitcher extends StatelessWidget {
  const TemplateSideSwitcher({
    super.key,
    required this.isDuplex,
    required this.isPage1,
    required this.mirrorFront,
    required this.mirrorBack,
    required this.onPageChanged,
  });

  final bool isDuplex;
  final bool isPage1;
  final bool mirrorFront;
  final bool mirrorBack;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!isDuplex) {
      return DecoratedBox(
        decoration: _decoration(scheme),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text('1 sided'),
        ),
      );
    }

    return DecoratedBox(
      decoration: _decoration(scheme),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SideButton(
            label: 'Front',
            active: isPage1,
            mirrored: mirrorFront,
            onPressed: () => onPageChanged(0),
          ),
          _SideButton(
            label: 'Back',
            active: !isPage1,
            mirrored: mirrorBack,
            onPressed: () => onPageChanged(1),
          ),
        ],
      ),
    );
  }

  BoxDecoration _decoration(ColorScheme scheme) => BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      );
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.label,
    required this.active,
    required this.mirrored,
    required this.onPressed,
  });

  final String label;
  final bool active;
  final bool mirrored;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: active,
      label: 'Edit $label side',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: active ? scheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: active
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
              if (mirrored) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.rotate_right,
                  size: 16,
                  color: active
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
