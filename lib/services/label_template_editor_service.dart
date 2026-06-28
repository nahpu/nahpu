import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as path;

import 'package:nahpu/screens/exports/labels/label_template_model.dart';
import 'package:nahpu/services/label_logo_service.dart';

class LabelTemplateEditorService {
  final LabelLogoService _logoService = const LabelLogoService();

  Future<String?> promptSaveTemplate(
      BuildContext context, String currentName) async {
    final ctrl = TextEditingController(text: currentName.trim());
    final formKey = GlobalKey<FormState>();
    try {
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Save template'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Template name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Enter a name';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, ctrl.text.trim());
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, ctrl.text.trim());
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
      return name;
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.dispose();
      });
    }
  }

  Future<String?> promptImportNewName(BuildContext context,
      String conflictingName, Set<String> takenNames) async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    try {
      return await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Save imported template as'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: ctrl,
              decoration: InputDecoration(
                labelText: 'Template name',
                hintText: 'Must differ from "$conflictingName"',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Enter a name';
                if (takenNames.contains(t)) {
                  return 'A template with this name already exists';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, ctrl.text.trim());
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, ctrl.text.trim());
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.dispose();
      });
    }
  }

  Future<void> exportTemplate(
      BuildContext context, LabelTemplate template) async {
    final raw = template.name.trim();
    final safe =
        raw.isEmpty ? 'template' : raw.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final suggested = 'label_template_$safe.json';
    final location = await getSaveLocation(suggestedName: suggested);
    if (location == null || !context.mounted) return;
    final savePath = location.path;
    final out =
        savePath.toLowerCase().endsWith('.json') ? savePath : '$savePath.json';
    try {
      await File(out).writeAsString(template.toJsonString());
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved ${path.basename(out)}')),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<bool> confirmDeleteTemplate(BuildContext context, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete template'),
        content: Text('Permanently delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<String?> copyPickedImageToLogos() async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return null;
    final filePath = result.files.single.path;
    if (filePath == null) return null;
    final ext = result.files.single.extension;
    final added = ext != null && ext.isNotEmpty
        ? await _logoService.addLogoFromFile(filePath)
        : await _logoService.addLogoFromFileWithExtension(filePath, '.png');
    return added;
  }
}
