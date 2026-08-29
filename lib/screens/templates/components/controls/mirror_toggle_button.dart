import 'package:material_ui/material_ui.dart';

class MirrorToggleButton extends StatelessWidget {
  const MirrorToggleButton({
    super.key,
    required this.isMirrorActive,
    required this.sideLabel,
    required this.onToggle,
  });

  final bool isMirrorActive;
  final String sideLabel;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      icon: const Icon(Icons.rotate_right),
      tooltip: isMirrorActive
          ? '$sideLabel: rotated 180° for print (tap to turn off)'
          : '$sideLabel: tap to rotate template 180° for print',
      onPressed: onToggle,
    );
  }
}
