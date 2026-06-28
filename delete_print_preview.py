import re

file_path = "lib/screens/export/labels/label_template_editor_screen.dart"

with open(file_path, "r") as f:
    content = f.read()

# Delete the _showPrintPreviewDialog method
# It starts at line 1240: "Future<void> _showPrintPreviewDialog() async {"
# Let's find it using regex and replace it with an empty string

pattern = r"  Future<void> _showPrintPreviewDialog\(\) async \{.*?\n  \}\n"
# Because the method has nested blocks, simple regex might not work if there are many braces.
# But we can just use a python script to count braces.

start_str = "  Future<void> _showPrintPreviewDialog() async {"
start_idx = content.find(start_str)

if start_idx != -1:
    brace_count = 0
    in_method = False
    end_idx = -1
    for i in range(start_idx, len(content)):
        if content[i] == '{':
            brace_count += 1
            in_method = True
        elif content[i] == '}':
            brace_count -= 1
            if in_method and brace_count == 0:
                end_idx = i + 1
                break
    
    if end_idx != -1:
        content = content[:start_idx] + content[end_idx:]
        with open(file_path, "w") as f:
            f.write(content)
