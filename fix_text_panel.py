import re

file_path = "lib/screens/export/labels/label_template_editor_screen.dart"

with open(file_path, "r") as f:
    content = f.read()

# Replace the Material wrapper in _buildCustomTextPanel
text_panel_start_pattern = r"(if \(isLabelBracketGenderIconText\(ct\.text\)\) \{\n      final content = Padding\(\n        padding: inToolbar\n            \? const EdgeInsets\.fromLTRB\(8, 8, 8, 8\)\n            : const EdgeInsets\.fromLTRB\(12, 10, 12, 10\),\n        child: Row\(\n          mainAxisAlignment: MainAxisAlignment\.end,\n          crossAxisAlignment: CrossAxisAlignment\.center,\n          children: \[)deleteButton\]"
new_text_panel_start = r"\1_buildZIndexControls(sel), const Spacer(), deleteButton]"
content = re.sub(text_panel_start_pattern, new_text_panel_start, content)

text_panel_mat_pattern = r"(      if \(inToolbar\) \{\n        return Material\(\n          elevation: 0,\n          color: scheme\.surfaceContainerHighest,\n          shape: RoundedRectangleBorder\(\n            borderRadius: BorderRadius\.circular\(8\),\n            side: BorderSide\(color: scheme\.outlineVariant\),\n          \),\n          clipBehavior: Clip\.antiAlias,\n          child: content,\n        \);\n      \}\n      return Material\(\n        elevation: 2,\n        color: scheme\.surfaceContainerHigh,\n        child: SafeArea\(\n          top: false,\n          child: content,\n        \),\n      \);\n    \})"

new_text_panel_mat = r"      return _buildPanelContainer(child: content, inToolbar: inToolbar);\n    }"
content = re.sub(text_panel_mat_pattern, new_text_panel_mat, content)


# Also need to add z-index controls to the main text property row
main_text_row_pattern = r"(    final mainRow = Row\(\n      mainAxisSize: MainAxisSize\.min,\n      children: \[)"
new_main_text_row = r"\1\n        _buildZIndexControls(sel),\n        const SizedBox(width: 8),"
content = re.sub(main_text_row_pattern, new_main_text_row, content)

with open(file_path, "w") as f:
    f.write(content)

