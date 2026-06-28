import re

file_path = "lib/screens/export/labels/label_template_editor_screen.dart"

with open(file_path, "r") as f:
    content = f.read()

# Replace the segmented button
segmented_btn = r"""                                SegmentedButton<bool>\(
                                  showSelectedIcon: false,
                                  segments: const \[
                                    ButtonSegment\(value: false, label: Text\('Edit', style: TextStyle\(fontSize: 12\)\)\),
                                    ButtonSegment\(value: true, label: Text\('Preview', style: TextStyle\(fontSize: 12\)\)\),
                                  \],
                                  selected: \{_isPreviewMode\},
                                  onSelectionChanged: \(values\) \{
                                    _deferSetState\(\(\) => _isPreviewMode = values\.first\);
                                  \},
                                \),"""

icon_btn = r"""                                IconButton.filledTonal(
                                  onPressed: () {
                                    _deferSetState(() => _isPreviewMode = !_isPreviewMode);
                                  },
                                  icon: Icon(_isPreviewMode ? Icons.edit_outlined : Icons.visibility_outlined),
                                  tooltip: _isPreviewMode ? 'Edit' : 'Preview',
                                ),"""

content = re.sub(segmented_btn, icon_btn, content)

with open(file_path, "w") as f:
    f.write(content)
