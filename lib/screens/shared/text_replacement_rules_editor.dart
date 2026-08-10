import 'package:flutter/material.dart';
import 'package:nahpu/services/export/text_replacements.dart';

/// Inline editor for ordered exact and regular-expression replacements.
class TextReplacementRulesEditor extends StatefulWidget {
  const TextReplacementRulesEditor({
    super.key,
    required this.rules,
    required this.onChanged,
    this.expandable = true,
  });

  final List<TextReplacementRule> rules;
  final ValueChanged<List<TextReplacementRule>> onChanged;
  final bool expandable;

  @override
  State<TextReplacementRulesEditor> createState() =>
      _TextReplacementRulesEditorState();
}

class _TextReplacementRulesEditorState
    extends State<TextReplacementRulesEditor> {
  late List<_ReplacementRuleDraft> _drafts;

  @override
  void initState() {
    super.initState();
    _drafts = widget.rules.map(_ReplacementRuleDraft.new).toList();
  }

  @override
  void didUpdateWidget(covariant TextReplacementRulesEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_rulesEqual(widget.rules, _currentRules())) return;
    _disposeDrafts();
    _drafts = widget.rules.map(_ReplacementRuleDraft.new).toList();
  }

  @override
  void dispose() {
    _disposeDrafts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      for (var index = 0; index < _drafts.length; index++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _TextReplacementRuleRow(
            key: ObjectKey(_drafts[index]),
            draft: _drafts[index],
            index: index,
            canMoveUp: index > 0,
            canMoveDown: index < _drafts.length - 1,
            onChanged: _notify,
            onMoveUp: () => _move(index, -1),
            onMoveDown: () => _move(index, 1),
            onRemove: () => _remove(index),
          ),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          key: const ValueKey('add-replacement-rule'),
          onPressed: _add,
          icon: const Icon(Icons.add),
          label: const Text('Add replacement'),
        ),
      ),
      const SizedBox(height: 8),
    ];
    if (!widget.expandable) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }
    return ExpansionTile(
      key: const ValueKey('replace-text-section'),
      tilePadding: EdgeInsets.zero,
      initiallyExpanded: _drafts.isNotEmpty,
      title: const Text('Replace text'),
      subtitle: const Text('Applied in order after value formatting.'),
      children: children,
    );
  }

  List<TextReplacementRule> _currentRules() =>
      _drafts.map((draft) => draft.rule).toList(growable: false);

  void _notify() => widget.onChanged(_currentRules());

  void _add() {
    setState(() {
      _drafts.add(
        _ReplacementRuleDraft(
          const TextReplacementRule(pattern: '', replacement: ''),
        ),
      );
    });
    _notify();
  }

  void _remove(int index) {
    final removed = _drafts[index];
    setState(() => _drafts.removeAt(index));
    removed.dispose();
    _notify();
  }

  void _move(int index, int offset) {
    setState(() {
      final draft = _drafts.removeAt(index);
      _drafts.insert(index + offset, draft);
    });
    _notify();
  }

  void _disposeDrafts() {
    for (final draft in _drafts) {
      draft.dispose();
    }
  }

  bool _rulesEqual(
    List<TextReplacementRule> left,
    List<TextReplacementRule> right,
  ) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      final a = left[index];
      final b = right[index];
      if (a.pattern != b.pattern ||
          a.replacement != b.replacement ||
          a.matchType != b.matchType ||
          a.caseSensitive != b.caseSensitive) {
        return false;
      }
    }
    return true;
  }
}

/// Dialog that edits replacement rules without mutating its caller until Apply.
class TextReplacementRulesDialog extends StatefulWidget {
  const TextReplacementRulesDialog({super.key, required this.rules});

  final List<TextReplacementRule> rules;

  @override
  State<TextReplacementRulesDialog> createState() =>
      _TextReplacementRulesDialogState();
}

class _TextReplacementRulesDialogState
    extends State<TextReplacementRulesDialog> {
  late List<TextReplacementRule> _rules;

  @override
  void initState() {
    super.initState();
    _rules = List<TextReplacementRule>.from(widget.rules);
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _rules.every(
      (rule) => validateTextReplacementRule(rule) == null,
    );
    return AlertDialog(
      title: const Text('Find and replace'),
      content: SizedBox(
        width: 760,
        child: SingleChildScrollView(
          child: TextReplacementRulesEditor(
            rules: _rules,
            onChanged: (rules) => setState(() => _rules = rules),
            expandable: false,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey('apply-replacement-rules'),
          onPressed: isValid
              ? () => Navigator.pop(
                  context,
                  List<TextReplacementRule>.unmodifiable(_rules),
                )
              : null,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _ReplacementRuleDraft {
  _ReplacementRuleDraft(TextReplacementRule rule)
    : patternController = TextEditingController(text: rule.pattern),
      replacementController = TextEditingController(text: rule.replacement),
      matchType = rule.matchType,
      caseSensitive = rule.caseSensitive;

  final TextEditingController patternController;
  final TextEditingController replacementController;
  TextReplacementMatchType matchType;
  bool caseSensitive;

  TextReplacementRule get rule => TextReplacementRule(
    pattern: patternController.text,
    replacement: replacementController.text,
    matchType: matchType,
    caseSensitive: caseSensitive,
  );

  void dispose() {
    patternController.dispose();
    replacementController.dispose();
  }
}

class _TextReplacementRuleRow extends StatefulWidget {
  const _TextReplacementRuleRow({
    super.key,
    required this.draft,
    required this.index,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onChanged,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
  });

  final _ReplacementRuleDraft draft;
  final int index;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onChanged;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onRemove;

  @override
  State<_TextReplacementRuleRow> createState() =>
      _TextReplacementRuleRowState();
}

class _TextReplacementRuleRowState extends State<_TextReplacementRuleRow> {
  @override
  Widget build(BuildContext context) {
    final error = validateTextReplacementRule(widget.draft.rule);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 130,
                  child: DropdownButtonFormField<TextReplacementMatchType>(
                    key: ValueKey('replacement-match-${widget.index}'),
                    initialValue: widget.draft.matchType,
                    decoration: const InputDecoration(
                      labelText: 'Match',
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: TextReplacementMatchType.exact,
                        child: Text('Exact'),
                      ),
                      DropdownMenuItem(
                        value: TextReplacementMatchType.regex,
                        child: Text('Regex'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => widget.draft.matchType = value);
                      widget.onChanged();
                    },
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: TextFormField(
                    key: ValueKey('replacement-find-${widget.index}'),
                    controller: widget.draft.patternController,
                    decoration: const InputDecoration(
                      labelText: 'Find',
                      isDense: true,
                    ),
                    onChanged: (_) {
                      setState(() {});
                      widget.onChanged();
                    },
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: TextFormField(
                    key: ValueKey('replacement-text-${widget.index}'),
                    controller: widget.draft.replacementController,
                    decoration: const InputDecoration(
                      labelText: 'Replace with',
                      isDense: true,
                    ),
                    onChanged: (_) => widget.onChanged(),
                  ),
                ),
                FilterChip(
                  label: const Text('Ignore case'),
                  selected: !widget.draft.caseSensitive,
                  onSelected: (selected) {
                    setState(() {
                      widget.draft.caseSensitive = !selected;
                    });
                    widget.onChanged();
                  },
                ),
                IconButton(
                  tooltip: 'Move replacement up',
                  onPressed: widget.canMoveUp ? widget.onMoveUp : null,
                  icon: const Icon(Icons.arrow_upward),
                ),
                IconButton(
                  tooltip: 'Move replacement down',
                  onPressed: widget.canMoveDown ? widget.onMoveDown : null,
                  icon: const Icon(Icons.arrow_downward),
                ),
                IconButton(
                  tooltip: 'Remove replacement',
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ] else if (widget.draft.matchType ==
                TextReplacementMatchType.regex) ...[
              const SizedBox(height: 4),
              const Text(
                r'Use $0 for the full match, $1…$n for groups, and $$ for $.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
