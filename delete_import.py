import re

file_path = "lib/screens/export/labels/label_template_editor_screen.dart"

with open(file_path, "r") as f:
    content = f.read()

content = content.replace("import 'package:nahpu/screens/export/labels/label_template_live_preview.dart';\n", "")

with open(file_path, "w") as f:
    f.write(content)
