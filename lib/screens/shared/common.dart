import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nahpu/styles/decoration.dart';

/// Used by specimen forms to avoid the
/// bottom sheet covering the last field
class BottomPadding extends StatelessWidget {
  const BottomPadding({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding to avoid the bottom sheet covering the last field
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(height: MediaQuery.of(context).size.height * 0.05),
    );
  }
}

class CommonProgressIndicator extends StatelessWidget {
  const CommonProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 30,
        width: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class TileIcon extends StatelessWidget {
  const TileIcon({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 16,
    );
  }
}

class CommonDivider extends StatelessWidget {
  const CommonDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 5,
    );
  }
}

class CommonLineDivider extends StatelessWidget {
  const CommonLineDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(color: Colors.grey);
  }
}

class CommonAlertDialog extends StatelessWidget {
  const CommonAlertDialog({
    super.key,
    required this.titleText,
    this.descText,
    required this.confirmFunction
  });

  final String titleText;
  final String? descText;
  final Function() confirmFunction;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titleText),
      content: descText == null ? null: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child:
          Text(descText!)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          }, 
          child: const Text('Cancel')
        ),
        TextButton(
          onPressed: () {
            confirmFunction();
            if (context.mounted) {
              Navigator.pop(context);
            }
          }, 
          child: const Text('OK')
        )
      ],
    );
  }
}

class TileSvgIcon extends StatelessWidget {
  const TileSvgIcon({super.key, required this.iconPath});

  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconPath,
      height: 28,
      width: 28,
      colorFilter: ColorFilter.mode(
        getIconColor(context),
        BlendMode.srcIn,
      ),
    );
  }
}
