import 'dart:math' as math;

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/docs/mdoc_body.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';
import 'package:nahpu/styles/design_tokens.dart';
import 'package:url_launcher/url_launcher.dart';

class DocsLanguageSelector extends StatelessWidget {
  const DocsLanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onSelected,
  });

  final DocsLanguage selectedLanguage;
  final ValueChanged<DocsLanguage> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: NahpuSpacing.md,
      runSpacing: NahpuSpacing.md,
      children: [
        for (final language in DocsLanguage.values)
          _DocsLanguageChip(
            language: language,
            isSelected: language == selectedLanguage,
            onSelected: onSelected,
          ),
      ],
    );
  }
}

class _DocsLanguageChip extends StatelessWidget {
  const _DocsLanguageChip({
    required this.language,
    required this.isSelected,
    required this.onSelected,
  });

  final DocsLanguage language;
  final bool isSelected;
  final ValueChanged<DocsLanguage> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      selected: isSelected,
      showCheckmark: false,
      tooltip: language.nativeLabel,
      label: Text(language.shortLabel, semanticsLabel: language.nativeLabel),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: isSelected
            ? colorScheme.onSecondaryContainer
            : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
        letterSpacing: 0.5,
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.sm),
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.secondaryContainer,
      side: BorderSide(
        color: isSelected ? colorScheme.secondary : colorScheme.outlineVariant,
        width: NahpuStroke.thin,
      ),
      visualDensity: VisualDensity.compact,
      onSelected: (_) => onSelected(language),
    );
  }
}

/// Tells the reader that a document was machine-translated.
///
/// Translations are produced with AI assistance, so every non-English document
/// carries this label. Naming reviewers in the `authors` front matter switches
/// it to the checked state.
class AiTranslationNotice extends StatelessWidget {
  const AiTranslationNotice({super.key, this.authors = const []});

  final List<String> authors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isReviewed = authors.isNotEmpty;
    final background = isReviewed
        ? colorScheme.secondaryContainer
        : colorScheme.tertiaryContainer;
    final foreground = isReviewed
        ? colorScheme.onSecondaryContainer
        : colorScheme.onTertiaryContainer;
    final labelStyle = (theme.textTheme.bodySmall ?? const TextStyle())
        .copyWith(color: foreground);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        key: ValueKey(
          'ai-translation-notice-${isReviewed ? 'reviewed' : 'unreviewed'}',
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: NahpuSpacing.lg,
          vertical: NahpuSpacing.md,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(NahpuRadius.xl),
          border: Border.all(color: foreground, width: NahpuStroke.thin),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isReviewed ? Icons.verified_outlined : Icons.translate_rounded,
              color: foreground,
              size: NahpuControlSize.iconMedium,
            ),
            const SizedBox(width: NahpuSpacing.sm),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'AI-assisted translation.',
                      style: labelStyle.copyWith(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: ' ${_detail(isReviewed)}',
                      style: labelStyle,
                    ),
                  ],
                ),
                style: labelStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _detail(bool isReviewed) {
    if (!isReviewed) return 'Check for accuracy';
    return 'Human-checked and revised by ${_reviewers()}.';
  }

  String _reviewers() {
    if (authors.length == 1) return authors.single;
    if (authors.length == 2) return '${authors.first} and ${authors.last}';
    final leading = authors.sublist(0, authors.length - 1).join(', ');
    return '$leading, and ${authors.last}';
  }
}

class MarkdownDocumentView extends StatelessWidget {
  const MarkdownDocumentView({super.key, required this.document});

  final MarkdownDocument document;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            document.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (document.language != DocsLanguage.english) ...[
            const SizedBox(height: NahpuSpacing.md),
            AiTranslationNotice(authors: document.authors),
          ],
          const SizedBox(height: NahpuSpacing.md),
          MdocBody(
            data: document.markdown,
            language: document.language,
            styleSheet: documentationMarkdownStyleSheet(context),
            onTapLink: (text, href, title) => _openLink(href),
          ),
        ],
      ),
    );
  }

  Future<void> _openLink(String? href) async {
    final uri = href == null ? null : Uri.tryParse(href);
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

MarkdownStyleSheet documentationMarkdownStyleSheet(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final bodyStyle = (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
    color: colorScheme.onSurface,
  );
  final linkColor = _accessibleDocumentationLinkColor(colorScheme);

  return MarkdownStyleSheet(
    a: bodyStyle.copyWith(
      color: linkColor,
      decoration: TextDecoration.underline,
      decorationColor: linkColor,
    ),
    p: bodyStyle,
    pPadding: EdgeInsets.zero,
    code: bodyStyle.copyWith(
      backgroundColor: colorScheme.surfaceContainerHighest,
      fontFamily: 'monospace',
      fontSize: (bodyStyle.fontSize ?? 14) * 0.85,
    ),
    h1: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
    h1Padding: EdgeInsets.zero,
    h2: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
    h2Padding: EdgeInsets.zero,
    h3: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
    h3Padding: EdgeInsets.zero,
    h4: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
    h4Padding: EdgeInsets.zero,
    h5: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
    h5Padding: EdgeInsets.zero,
    h6: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
    h6Padding: EdgeInsets.zero,
    em: bodyStyle.copyWith(fontStyle: FontStyle.italic),
    strong: bodyStyle.copyWith(fontWeight: FontWeight.bold),
    del: bodyStyle.copyWith(decoration: TextDecoration.lineThrough),
    blockquote: bodyStyle,
    img: bodyStyle,
    checkbox: bodyStyle.copyWith(color: colorScheme.primary),
    blockSpacing: NahpuSpacing.md,
    listIndent: NahpuSpacing.xxl,
    listBullet: bodyStyle,
    listBulletPadding: const EdgeInsets.only(right: NahpuSpacing.xs),
    tableHead: bodyStyle.copyWith(fontWeight: FontWeight.w600),
    tableBody: bodyStyle,
    tableHeadAlign: TextAlign.center,
    tablePadding: const EdgeInsets.only(bottom: NahpuSpacing.xs),
    tableBorder: TableBorder.all(color: colorScheme.outlineVariant),
    tableColumnWidth: const FlexColumnWidth(),
    tableCellsPadding: const EdgeInsets.fromLTRB(
      NahpuSpacing.xl,
      NahpuSpacing.md,
      NahpuSpacing.xl,
      NahpuSpacing.md,
    ),
    tableCellsDecoration: const BoxDecoration(),
    tableHeadCellsPadding: const EdgeInsets.fromLTRB(
      NahpuSpacing.xl,
      NahpuSpacing.md,
      NahpuSpacing.xl,
      NahpuSpacing.md,
    ),
    tableHeadCellsDecoration: const BoxDecoration(),
    blockquotePadding: const EdgeInsets.all(NahpuSpacing.md),
    blockquoteDecoration: BoxDecoration(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(NahpuRadius.sm),
      border: Border(left: BorderSide(color: colorScheme.primary, width: 3)),
    ),
    codeblockPadding: const EdgeInsets.all(NahpuSpacing.md),
    codeblockDecoration: BoxDecoration(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(NahpuRadius.sm),
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
    ),
  );
}

Color _accessibleDocumentationLinkColor(ColorScheme colorScheme) {
  final backgrounds = [
    colorScheme.surface,
    colorScheme.surfaceContainerLow,
    colorScheme.surfaceContainer,
    colorScheme.surfaceContainerHigh,
    colorScheme.surfaceContainerHighest,
  ];
  final primaryMeetsContrast = backgrounds.every(
    (background) => _contrastRatio(colorScheme.primary, background) >= 4.5,
  );
  return primaryMeetsContrast ? colorScheme.primary : colorScheme.onSurface;
}

double _contrastRatio(Color first, Color second) {
  final lighter = math.max(first.computeLuminance(), second.computeLuminance());
  final darker = math.min(first.computeLuminance(), second.computeLuminance());
  return (lighter + 0.05) / (darker + 0.05);
}

class DocumentationErrorView extends StatelessWidget {
  const DocumentationErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40),
            const SizedBox(height: NahpuSpacing.md),
            const Text(
              'Unable to load this documentation.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NahpuSpacing.md),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
