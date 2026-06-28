import 'package:flutter/material.dart';
import 'package:nahpu/screens/exports/labels/label_template_editor_screen.dart';

class LabelSettingsScreen extends StatelessWidget {
  const LabelSettingsScreen({super.key});

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
            title: const Text('Label template editor'),
            subtitle: const Text('Design front/back layouts and placeholders'),
            onTap: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const LabelTemplateEditorScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
