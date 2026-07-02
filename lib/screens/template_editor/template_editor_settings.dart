import 'package:flutter/material.dart';
import 'package:nahpu/screens/template_editor/template_editor_screen.dart';

class TemplateEditorSettingsScreen extends StatelessWidget {
  const TemplateEditorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Labels'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_note_outlined),
            title: const Text('Template editor'),
            subtitle: const Text('Design front/back layouts and placeholders'),
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const TemplateEditorScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
