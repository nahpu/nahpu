import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/localization/l10n.dart';

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
          ? context.l10n.templateMirrorOn(sideLabel)
          : context.l10n.templateMirrorOff(sideLabel),
      onPressed: onToggle,
    );
  }
}
