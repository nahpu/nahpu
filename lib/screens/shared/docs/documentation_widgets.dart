import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material_ui/material_ui.dart';
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
      spacing: NahpuSpacing.xs,
      runSpacing: NahpuSpacing.xs,
      children: [
        for (final language in DocsLanguage.values)
          Semantics(
            selected: language == selectedLanguage,
            button: true,
            child: TextButton(
              style: language == selectedLanguage
                  ? TextButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSecondaryContainer,
                    )
                  : null,
              onPressed: language == selectedLanguage
                  ? null
                  : () => onSelected(language),
              child: Text(language.nativeLabel),
            ),
          ),
      ],
    );
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
          const SizedBox(height: NahpuSpacing.md),
          MarkdownBody(
            data: document.markdown,
            selectable: false,
            styleSheet: MarkdownStyleSheet(
              a: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
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
