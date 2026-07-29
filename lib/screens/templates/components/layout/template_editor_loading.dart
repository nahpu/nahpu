import 'package:flutter/material.dart';

class TemplateEditorLoading extends StatelessWidget {
  const TemplateEditorLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
