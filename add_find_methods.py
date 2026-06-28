import re

file_path = "lib/screens/export/labels/label_template_editor_screen.dart"

with open(file_path, "r") as f:
    content = f.read()

find_text_pattern = r"(  CustomTextElement\? _findCustomText\(bool page1, String id\) \{[\s\S]*?return null;\n  \})"

new_find_methods = """  CustomTextElement? _findCustomText(bool page1, String id) {
    final page = page1 ? _template.page1 : _template.page2;
    for (final ct in page.customTexts) {
      if (ct.id == id) return ct;
    }
    return null;
  }

  CustomImageElement? _findCustomImage(bool page1, String id) {
    final page = page1 ? _template.page1 : _template.page2;
    for (final ct in page.customImages) {
      if (ct.id == id) return ct;
    }
    return null;
  }

  CustomLineElement? _findCustomLine(bool page1, String id) {
    final page = page1 ? _template.page1 : _template.page2;
    for (final ct in page.customLines) {
      if (ct.id == id) return ct;
    }
    return null;
  }

  CustomShapeElement? _findCustomShape(bool page1, String id) {
    final page = page1 ? _template.page1 : _template.page2;
    for (final ct in page.customShapes) {
      if (ct.id == id) return ct;
    }
    return null;
  }"""

new_content = re.sub(find_text_pattern, new_find_methods, content, count=1)

if content == new_content:
    print("Failed to replace _findCustomText")
else:
    with open(file_path, "w") as f:
        f.write(new_content)
    print("Successfully added _find methods")
