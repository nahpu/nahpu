import 'package:flutter/material.dart';

class FrontBackPagePickers extends StatelessWidget {
  const FrontBackPagePickers({
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
    if (!isDuplex) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final fg = scheme.onSurface;
    final frontActive = isPage1;

    TextStyle labelStyle(bool active) => TextStyle(
          fontSize: 15,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? scheme.primary : fg.withValues(alpha: 0.38),
        );

    Color mirrorColor(bool active) =>
        active ? scheme.primary : fg.withValues(alpha: 0.38);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => onPageChanged(0),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: fg,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Front', style: labelStyle(frontActive)),
              if (mirrorFront) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.rotate_right,
                  size: 16,
                  color: mirrorColor(frontActive),
                ),
              ],
            ],
          ),
        ),
        TextButton(
          onPressed: () => onPageChanged(1),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: fg,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Back', style: labelStyle(!frontActive)),
              if (mirrorBack) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.rotate_right,
                  size: 16,
                  color: mirrorColor(!frontActive),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
