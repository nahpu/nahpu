import re

file_path = "lib/screens/export/labels/label_template_editor_screen.dart"

with open(file_path, "r") as f:
    content = f.read()

# Add _isPreviewMode state variable
state_var_pattern = r"(  bool _fieldsPanelExpanded = false;)"
state_var_replacement = r"\1\n  bool _isPreviewMode = true;\n"
content = re.sub(state_var_pattern, state_var_replacement, content)


# Replace the print preview button
print_preview_btn = r"""                                IconButton.filledTonal\(
                                  onPressed: _showPrintPreviewDialog,
                                  icon: const Icon\(Icons.print_outlined\),
                                  tooltip: 'Print preview',
                                \),"""

edit_preview_segmented_btn = r"""                                SegmentedButton<bool>(
                                  showSelectedIcon: false,
                                  segments: const [
                                    ButtonSegment(value: false, label: Text('Edit', style: TextStyle(fontSize: 12))),
                                    ButtonSegment(value: true, label: Text('Preview', style: TextStyle(fontSize: 12))),
                                  ],
                                  selected: {_isPreviewMode},
                                  onSelectionChanged: (values) {
                                    _deferSetState(() => _isPreviewMode = values.first);
                                  },
                                ),"""

content = re.sub(print_preview_btn, edit_preview_segmented_btn, content)

# Change the text rendering
text_chip_pattern = r"label: element\.text\.isEmpty \? '\(empty\)' : substituteLabelPlaceholders\(element\.text, _editorLabelFieldPreview\),"
text_chip_replacement = r"label: element.text.isEmpty ? '(empty)' : (_isPreviewMode ? substituteLabelPlaceholders(element.text, _editorLabelFieldPreview) : element.text),"
content = re.sub(text_chip_pattern, text_chip_replacement, content)

with open(file_path, "w") as f:
    f.write(content)
