import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';
import 'package:nahpu/styles/design_tokens.dart';

enum MdocAsideType { note, caution, tip }

sealed class MdocBlock {
  const MdocBlock();
}

final class MdocMarkdownBlock extends MdocBlock {
  const MdocMarkdownBlock(this.markdown);

  final String markdown;
}

final class MdocStepsBlock extends MdocBlock {
  const MdocStepsBlock(this.steps);

  final List<MdocStep> steps;
}

final class MdocAsideBlock extends MdocBlock {
  const MdocAsideBlock({
    required this.type,
    required this.markdown,
    this.title,
  });

  final MdocAsideType type;
  final String markdown;
  final String? title;
}

class MdocStep {
  const MdocStep({required this.number, required this.markdown});

  final int number;
  final String markdown;
}

/// Parses the small Markdoc subset used by bundled NAHPU documentation.
///
/// Unsupported or malformed tags stay in Markdown blocks so documentation
/// remains readable instead of failing at runtime.
class MdocParser {
  const MdocParser();

  static final RegExp _stepsOpen = RegExp(r'^\s*\{%\s+steps\s+%\}\s*$');
  static final RegExp _stepsClose = RegExp(r'^\s*\{%\s+/steps\s+%\}\s*$');
  static final RegExp _asideOpen = RegExp(r'^\s*\{%\s+aside(.*?)%\}\s*$');
  static final RegExp _asideClose = RegExp(r'^\s*\{%\s+/aside\s+%\}\s*$');
  static final RegExp _attribute = RegExp(r'\s+([a-z]+)="([^"]*)"');
  static final RegExp _stepStart = RegExp(r'^(\d+)\.\s+(.*)$');
  static final RegExp _markdocLine = RegExp(r'^\s*\{%.*%\}\s*$');

  List<MdocBlock> parse(String source) {
    final lines = source.replaceAll('\r\n', '\n').split('\n');
    final blocks = <MdocBlock>[];
    final markdownLines = <String>[];

    void flushMarkdown() {
      final markdown = markdownLines.join('\n').trim();
      if (markdown.isNotEmpty) blocks.add(MdocMarkdownBlock(markdown));
      markdownLines.clear();
    }

    var index = 0;
    while (index < lines.length) {
      final line = lines[index];
      if (_stepsOpen.hasMatch(line)) {
        final closingIndex = _findClosing(lines, index + 1, _stepsClose);
        if (closingIndex != null) {
          final innerLines = lines.sublist(index + 1, closingIndex);
          final steps = _parseSteps(innerLines);
          if (steps != null && !_containsMarkdocTag(innerLines)) {
            flushMarkdown();
            blocks.add(MdocStepsBlock(steps));
            index = closingIndex + 1;
            continue;
          }
          markdownLines.addAll(lines.sublist(index, closingIndex + 1));
          index = closingIndex + 1;
          continue;
        }
      }

      final asideMatch = _asideOpen.firstMatch(line);
      if (asideMatch != null) {
        final attributes = _parseAsideAttributes(asideMatch.group(1) ?? '');
        final closingIndex = _findClosing(lines, index + 1, _asideClose);
        if (attributes != null && closingIndex != null) {
          final innerLines = lines.sublist(index + 1, closingIndex);
          if (!_containsMarkdocTag(innerLines)) {
            flushMarkdown();
            blocks.add(
              MdocAsideBlock(
                type: attributes.type,
                title: attributes.title,
                markdown: innerLines.join('\n').trim(),
              ),
            );
            index = closingIndex + 1;
            continue;
          }
          markdownLines.addAll(lines.sublist(index, closingIndex + 1));
          index = closingIndex + 1;
          continue;
        }
      }

      markdownLines.add(line);
      index++;
    }
    flushMarkdown();
    return blocks;
  }

  int? _findClosing(List<String> lines, int start, RegExp closingTag) {
    for (var index = start; index < lines.length; index++) {
      if (closingTag.hasMatch(lines[index])) return index;
    }
    return null;
  }

  List<MdocStep>? _parseSteps(List<String> lines) {
    final steps = <MdocStep>[];
    int? number;
    final content = <String>[];

    void addStep() {
      final currentNumber = number;
      if (currentNumber == null) return;
      steps.add(
        MdocStep(number: currentNumber, markdown: content.join('\n').trim()),
      );
      content.clear();
    }

    for (final line in lines) {
      final match = _stepStart.firstMatch(line);
      if (match != null) {
        addStep();
        number = int.parse(match.group(1)!);
        content.add(match.group(2)!);
        continue;
      }
      if (number == null) {
        if (line.trim().isNotEmpty) return null;
        continue;
      }
      content.add(_removeListIndent(line));
    }
    addStep();
    if (steps.isEmpty || steps.any((step) => step.markdown.isEmpty)) {
      return null;
    }
    return steps;
  }

  String _removeListIndent(String line) {
    if (line.startsWith('    ')) return line.substring(4);
    if (line.startsWith('\t')) return line.substring(1);
    return line;
  }

  bool _containsMarkdocTag(List<String> lines) {
    return lines.any(_markdocLine.hasMatch);
  }

  _MdocAsideAttributes? _parseAsideAttributes(String source) {
    final values = <String, String>{};
    var cursor = 0;
    for (final match in _attribute.allMatches(source)) {
      if (source.substring(cursor, match.start).trim().isNotEmpty) return null;
      final name = match.group(1)!;
      if (values.containsKey(name)) return null;
      values[name] = match.group(2)!;
      cursor = match.end;
    }
    if (source.substring(cursor).trim().isNotEmpty) return null;
    if (values.keys.any((name) => name != 'type' && name != 'title')) {
      return null;
    }
    final type = switch (values['type']) {
      'note' => MdocAsideType.note,
      'caution' => MdocAsideType.caution,
      'tip' => MdocAsideType.tip,
      _ => null,
    };
    if (type == null) return null;
    final rawTitle = values['title']?.trim();
    return _MdocAsideAttributes(
      type: type,
      title: rawTitle == null || rawTitle.isEmpty ? null : rawTitle,
    );
  }
}

class MdocBody extends StatelessWidget {
  const MdocBody({
    super.key,
    required this.data,
    required this.language,
    required this.styleSheet,
    this.onTapLink,
  });

  final String data;
  final DocsLanguage language;
  final MarkdownStyleSheet styleSheet;
  final MarkdownTapLinkCallback? onTapLink;

  @override
  Widget build(BuildContext context) {
    final blocks = const MdocParser().parse(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < blocks.length; index++) ...[
          _MdocBlockView(
            block: blocks[index],
            language: language,
            styleSheet: styleSheet,
            onTapLink: onTapLink,
          ),
          if (index != blocks.length - 1)
            const SizedBox(height: NahpuSpacing.md),
        ],
      ],
    );
  }
}

class _MdocBlockView extends StatelessWidget {
  const _MdocBlockView({
    required this.block,
    required this.language,
    required this.styleSheet,
    required this.onTapLink,
  });

  final MdocBlock block;
  final DocsLanguage language;
  final MarkdownStyleSheet styleSheet;
  final MarkdownTapLinkCallback? onTapLink;

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      MdocMarkdownBlock(:final markdown) => _markdownBody(markdown),
      MdocStepsBlock(:final steps) => _MdocSteps(
        steps: steps,
        styleSheet: styleSheet,
        onTapLink: onTapLink,
      ),
      MdocAsideBlock(:final type, :final markdown, :final title) => _MdocAside(
        type: type,
        markdown: markdown,
        title: title ?? _defaultAsideTitle(language, type),
        styleSheet: styleSheet,
        onTapLink: onTapLink,
      ),
    };
  }

  Widget _markdownBody(String markdown) {
    return MarkdownBody(
      data: markdown,
      selectable: false,
      listItemCrossAxisAlignment: MarkdownListItemCrossAxisAlignment.start,
      styleSheet: styleSheet,
      onTapLink: onTapLink,
    );
  }
}

class _MdocSteps extends StatelessWidget {
  const _MdocSteps({
    required this.steps,
    required this.styleSheet,
    required this.onTapLink,
  });

  final List<MdocStep> steps;
  final MarkdownStyleSheet styleSheet;
  final MarkdownTapLinkCallback? onTapLink;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey('mdoc-steps'),
      children: [
        for (var index = 0; index < steps.length; index++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: NahpuControlSize.icon,
                  child: Column(
                    children: [
                      Container(
                        key: ValueKey('mdoc-step-marker-$index'),
                        width: NahpuControlSize.icon,
                        height: NahpuControlSize.icon,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.onSecondaryContainer,
                            width: NahpuStroke.thin,
                          ),
                        ),
                        child: Text(
                          '${steps[index].number}',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      if (index != steps.length - 1)
                        Expanded(
                          child: Container(
                            key: ValueKey('mdoc-step-connector-$index'),
                            width: NahpuStroke.thin,
                            color: colorScheme.onSurface,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: NahpuSpacing.md),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: index == steps.length - 1 ? 0 : NahpuSpacing.lg,
                    ),
                    child: MarkdownBody(
                      data: steps[index].markdown,
                      selectable: false,
                      listItemCrossAxisAlignment:
                          MarkdownListItemCrossAxisAlignment.start,
                      styleSheet: styleSheet,
                      onTapLink: onTapLink,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MdocAside extends StatelessWidget {
  const _MdocAside({
    required this.type,
    required this.markdown,
    required this.title,
    required this.styleSheet,
    required this.onTapLink,
  });

  final MdocAsideType type;
  final String markdown;
  final String title;
  final MarkdownStyleSheet styleSheet;
  final MarkdownTapLinkCallback? onTapLink;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground, icon) = switch (type) {
      MdocAsideType.note => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
        Icons.info_outline_rounded,
      ),
      MdocAsideType.caution => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        Icons.warning_amber_rounded,
      ),
      MdocAsideType.tip => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
        Icons.lightbulb_outline,
      ),
    };
    final asideStyleSheet = _asideMarkdownStyleSheet(
      styleSheet,
      foreground: foreground,
      background: background,
    );
    return Semantics(
      container: true,
      label: title,
      child: Container(
        key: ValueKey('mdoc-aside-${type.name}'),
        width: double.infinity,
        padding: const EdgeInsets.all(NahpuSpacing.md),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(NahpuRadius.sm),
          border: Border(
            left: BorderSide(color: foreground, width: NahpuStroke.regular),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: foreground,
                  size: NahpuControlSize.iconMedium,
                ),
                const SizedBox(width: NahpuSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (markdown.isNotEmpty) ...[
              const SizedBox(height: NahpuSpacing.sm),
              MarkdownBody(
                data: markdown,
                selectable: false,
                listItemCrossAxisAlignment:
                    MarkdownListItemCrossAxisAlignment.start,
                styleSheet: asideStyleSheet,
                onTapLink: onTapLink,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

MarkdownStyleSheet _asideMarkdownStyleSheet(
  MarkdownStyleSheet source, {
  required Color foreground,
  required Color background,
}) {
  TextStyle? withForeground(TextStyle? style) {
    return style?.copyWith(color: foreground);
  }

  return source.copyWith(
    a: source.a?.copyWith(
      color: foreground,
      decoration: TextDecoration.underline,
      decorationColor: foreground,
    ),
    p: withForeground(source.p),
    code: source.code?.copyWith(color: foreground, backgroundColor: background),
    h1: withForeground(source.h1),
    h2: withForeground(source.h2),
    h3: withForeground(source.h3),
    h4: withForeground(source.h4),
    h5: withForeground(source.h5),
    h6: withForeground(source.h6),
    em: withForeground(source.em),
    strong: withForeground(source.strong),
    del: withForeground(source.del),
    blockquote: withForeground(source.blockquote),
    checkbox: withForeground(source.checkbox),
    listBullet: withForeground(source.listBullet),
    tableHead: withForeground(source.tableHead),
    tableBody: withForeground(source.tableBody),
  );
}

class _MdocAsideAttributes {
  const _MdocAsideAttributes({required this.type, required this.title});

  final MdocAsideType type;
  final String? title;
}

String _defaultAsideTitle(DocsLanguage language, MdocAsideType type) {
  return switch ((language, type)) {
    (DocsLanguage.english, MdocAsideType.note) => 'Note',
    (DocsLanguage.english, MdocAsideType.caution) => 'Caution',
    (DocsLanguage.english, MdocAsideType.tip) => 'Tip',
    (DocsLanguage.portuguese, MdocAsideType.note) => 'Nota',
    (DocsLanguage.portuguese, MdocAsideType.caution) => 'Cuidado',
    (DocsLanguage.portuguese, MdocAsideType.tip) => 'Dica',
    (DocsLanguage.spanish, MdocAsideType.note) => 'Nota',
    (DocsLanguage.spanish, MdocAsideType.caution) => 'Precaución',
    (DocsLanguage.spanish, MdocAsideType.tip) => 'Consejo',
    (DocsLanguage.indonesian, MdocAsideType.note) => 'Catatan',
    (DocsLanguage.indonesian, MdocAsideType.caution) => 'Perhatian',
    (DocsLanguage.indonesian, MdocAsideType.tip) => 'Kiat',
  };
}
