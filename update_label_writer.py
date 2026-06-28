import re

file_path = "lib/services/export/label_writer.dart"

with open(file_path, "r") as f:
    content = f.read()

# Add visibleForTesting import if not present
if "import 'package:flutter/foundation.dart';" not in content:
    content = "import 'package:flutter/foundation.dart';\n" + content

sort_elements_method = """
  @visibleForTesting
  static List<dynamic> sortElementsForTesting(LabelPageTemplate page) {
    return <dynamic>[
      ...page.customImages,
      ...page.customTexts,
      ...page.customLines,
      ...page.customShapes,
    ]..sort((a, b) => (a.zIndex as int).compareTo(b.zIndex as int));
  }
"""

# replace the sort in _writeSingleLabelCell
inline_sort_pattern = r"    final allElements = <dynamic>\[\n      \.\.\.page\.customImages,\n      \.\.\.page\.customTexts,\n      \.\.\.page\.customLines,\n      \.\.\.page\.customShapes,\n    \]\.\.sort\(\(a, b\) => \(a\.zIndex as int\)\.compareTo\(b\.zIndex as int\)\);"
new_inline_sort = r"    final allElements = sortElementsForTesting(page);"

content = re.sub(inline_sort_pattern, new_inline_sort, content)

# insert the sortElementsForTesting method
content = re.sub(r"(  void _writeSingleCustomImage)", sort_elements_method + r"\n\1", content)

with open(file_path, "w") as f:
    f.write(content)
