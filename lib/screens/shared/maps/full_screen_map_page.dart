import 'package:flutter/material.dart';

class FullScreenMapPage extends StatelessWidget {
  const FullScreenMapPage({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(child: SizedBox.expand(child: child)),
  );
}
