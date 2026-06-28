import re

file_path = "lib/screens/export/labels/label_template_editor_screen.dart"

with open(file_path, "r") as f:
    content = f.read()

# Replace _selectedElement!.startsWith('custom:') check in AnimatedSize
panel_call_pattern = r"child: _selectedElement != null &&\s*_selectedElement!\.startsWith\('custom:'\)\s*\?\s*Padding\(\s*padding: const EdgeInsets\.only\(top: 8\),\s*child: _buildCustomTextPanel\(_selectedElement!,\s*inToolbar: true\),\s*\)\s*: const SizedBox\(width: double\.infinity, height: 0\),"

new_panel_call = """child: _selectedElement != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _buildElementPanel(_selectedElement!, inToolbar: true),
                          )
                        : const SizedBox(width: double.infinity, height: 0),"""

content = re.sub(panel_call_pattern, new_panel_call, content, count=1)

# Add _buildElementPanel and Z-index helper
build_element_panel = """
  void _updateZIndex(String sel, int delta) {
    final parts = sel.split(':');
    final type = parts[0];
    final page1 = parts[1] == '1';
    final id = parts[2];
    setState(() {
      if (type == 'custom') {
        final ct = _findCustomText(page1, id);
        if (ct != null) _updateCustomText(page1, ct.copyWith(zIndex: ct.zIndex + delta));
      } else if (type == 'image') {
        final im = _findCustomImage(page1, id);
        if (im != null) _scheduleTemplateImageUpdate(page1, im.copyWith(zIndex: im.zIndex + delta));
      } else if (type == 'line') {
        final ln = _findCustomLine(page1, id);
        if (ln != null) _scheduleTemplateLineUpdate(page1, ln.copyWith(zIndex: ln.zIndex + delta));
      } else if (type == 'shape') {
        final sh = _findCustomShape(page1, id);
        if (sh != null) _scheduleTemplateShapeUpdate(page1, sh.copyWith(zIndex: sh.zIndex + delta));
      }
    });
  }

  Widget _buildElementPanel(String sel, {bool inToolbar = false}) {
    if (sel.startsWith('custom:')) {
      return _buildCustomTextPanel(sel, inToolbar: inToolbar);
    } else if (sel.startsWith('image:')) {
      return _buildImagePanel(sel, inToolbar: inToolbar);
    } else if (sel.startsWith('line:')) {
      return _buildLinePanel(sel, inToolbar: inToolbar);
    } else if (sel.startsWith('shape:')) {
      return _buildShapePanel(sel, inToolbar: inToolbar);
    }
    return const SizedBox.shrink();
  }

  Widget _buildPanelContainer({required Widget child, required bool inToolbar}) {
    final scheme = Theme.of(context).colorScheme;
    if (inToolbar) {
      return Material(
        elevation: 0,
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
    }
    return Material(
      elevation: 2,
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: child,
      ),
    );
  }

  Widget _buildZIndexControls(String sel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_down, size: 20),
          tooltip: 'Send to back',
          onPressed: () => _updateZIndex(sel, -1), // Simplistic, could be improved to find min/max
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          tooltip: 'Send backward',
          onPressed: () => _updateZIndex(sel, -1),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up, size: 20),
          tooltip: 'Bring forward',
          onPressed: () => _updateZIndex(sel, 1),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_double_arrow_up, size: 20),
          tooltip: 'Bring to front',
          onPressed: () => _updateZIndex(sel, 1),
        ),
      ],
    );
  }

  Widget _buildImagePanel(String sel, {bool inToolbar = false}) {
    final parts = sel.split(':');
    final page1 = parts[1] == '1';
    final id = parts[2];
    
    final scheme = Theme.of(context).colorScheme;
    final deleteButton = IconButton(
      icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
      tooltip: 'Delete image',
      onPressed: () => _removeCustomImage(page1, id),
    );

    return _buildPanelContainer(
      inToolbar: inToolbar,
      child: Padding(
        padding: inToolbar
            ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
            : const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildZIndexControls(sel),
            const Spacer(),
            deleteButton,
          ],
        ),
      ),
    );
  }

  Widget _buildLinePanel(String sel, {bool inToolbar = false}) {
    final parts = sel.split(':');
    final page1 = parts[1] == '1';
    final id = parts[2];
    final ln = _findCustomLine(page1, id);
    if (ln == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final deleteButton = IconButton(
      icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
      tooltip: 'Delete line',
      onPressed: () => _removeCustomLine(page1, id),
    );

    // TODO: Add Stroke width/color selectors

    return _buildPanelContainer(
      inToolbar: inToolbar,
      child: Padding(
        padding: inToolbar
            ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
            : const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildZIndexControls(sel),
            const Spacer(),
            deleteButton,
          ],
        ),
      ),
    );
  }

  Widget _buildShapePanel(String sel, {bool inToolbar = false}) {
    final parts = sel.split(':');
    final page1 = parts[1] == '1';
    final id = parts[2];
    final sh = _findCustomShape(page1, id);
    if (sh == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final deleteButton = IconButton(
      icon: Icon(Icons.delete_outline, color: scheme.error, size: 22),
      tooltip: 'Delete shape',
      onPressed: () => _removeCustomShape(page1, id),
    );

    // TODO: Add Fill/Stroke selectors

    return _buildPanelContainer(
      inToolbar: inToolbar,
      child: Padding(
        padding: inToolbar
            ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
            : const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildZIndexControls(sel),
            const Spacer(),
            deleteButton,
          ],
        ),
      ),
    );
  }
"""

content = re.sub(r"(  Widget _buildCustomTextPanel)", build_element_panel + r"\n\1", content, count=1)

with open(file_path, "w") as f:
    f.write(content)

