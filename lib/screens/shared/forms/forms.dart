import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/docs/documentation_widgets.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/common/platform_services.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';
import 'package:nahpu/styles/decoration.dart';
import 'package:nahpu/styles/design_tokens.dart';

export 'package:nahpu/services/docs/documentation_repository.dart'
    show InfoTopic;

class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    required this.child,
    this.infoTopic,
    this.title = '',
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.mainAxisSize = MainAxisSize.max,
    this.isPrimary = false,
    this.isWithTitle = true,
    this.isWithDivider = true,
    this.isWithSidePadding = true,
    this.isExpanded = false,
  });

  final Widget child;
  final String title;
  final InfoTopic? infoTopic;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool isPrimary;
  final bool isWithTitle;
  final bool isWithDivider;
  final bool isWithSidePadding;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(NahpuSpacing.xs),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(NahpuRadius.lg),
          color: isPrimary
              ? Color.lerp(
                  Theme.of(context).colorScheme.secondaryContainer,
                  Theme.of(context).colorScheme.surface,
                  0.2,
                )
              : Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withAlpha(80),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: NahpuStroke.thin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: [
            isWithTitle
                ? TitleForm(text: title, infoTopic: infoTopic)
                : const SizedBox.shrink(),
            isWithTitle && !isPrimary
                ? Divider(
                    thickness: NahpuStroke.thin,
                    color: Theme.of(context).tabBarTheme.dividerColor,
                  )
                : const SizedBox.shrink(),
            isExpanded
                ? Expanded(
                    child: isWithSidePadding
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                            child: child,
                          )
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: child,
                          ),
                  )
                : isWithSidePadding
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    child: child,
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: child,
                  ),
          ],
        ),
      ),
    );
  }
}

class CommonIDForm extends StatelessWidget {
  const CommonIDForm({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 4),
      child: Container(
        padding: const EdgeInsets.all(NahpuSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).disabledColor,
            width: NahpuStroke.thin,
          ),
          borderRadius: BorderRadius.circular(NahpuRadius.lg),
        ),
        child: child,
      ),
    );
  }
}

class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(NahpuSpacing.lg),
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NahpuSpacing.md),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(NahpuRadius.lg),
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withAlpha(80),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: NahpuStroke.thin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ...switch (trailing) {
                  null => const <Widget>[],
                  final trailing => <Widget>[trailing],
                },
              ],
            ),
            const SizedBox(height: NahpuSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class TitleForm extends StatelessWidget {
  const TitleForm({
    super.key,
    required this.text,
    this.isCentered = true,
    this.infoTopic,
  });

  final String text;
  final bool isCentered;
  final InfoTopic? infoTopic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isCentered
          ? const EdgeInsets.fromLTRB(46, 0, 0, 4)
          : const EdgeInsets.only(right: NahpuSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final title = Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          );
          return Row(
            mainAxisSize: constraints.hasBoundedWidth
                ? MainAxisSize.max
                : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (constraints.hasBoundedWidth)
                Flexible(child: title)
              else
                title,
              if (infoTopic case final topic?) InfoButton(topic: topic),
            ],
          );
        },
      ),
    );
  }
}

class InfoButton extends StatelessWidget {
  const InfoButton({super.key, required this.topic, this.platformOverride});

  final InfoTopic topic;
  final PlatformType? platformOverride;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        (platformOverride ?? systemPlatform) == PlatformType.mobile
            ? _showModalSheet(context)
            : _showInfoDialog(context);
      },
      tooltip: 'Show information',
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.info_outline_rounded,
        size: 20,
        color: Theme.of(context).dividerColor,
      ),
    );
  }

  Future<void> _showInfoDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.sizeOf(context).height * 0.7,
          ),
          scrollable: true,
          content: SizedBox(
            width: 520,
            child: _InfoDocumentContent(topic: topic),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showModalSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (BuildContext context) => _InfoBottomSheet(topic: topic),
    );
  }
}

class _InfoBottomSheet extends StatelessWidget {
  const _InfoBottomSheet({required this.topic});

  final InfoTopic topic;

  @override
  Widget build(BuildContext context) {
    // The modal sheet keeps the bottom inset, so the content has to clear the
    // home indicator itself or its last lines are hidden behind it.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.sizeOf(context).height * 0.9 -
              NahpuControlSize.touchTarget -
              bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Info', style: Theme.of(context).textTheme.titleLarge),
            Divider(
              thickness: NahpuStroke.thin,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(24),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  NahpuSpacing.xl,
                  0,
                  NahpuSpacing.xl,
                  NahpuSpacing.md + bottomInset,
                ),
                child: _InfoDocumentContent(topic: topic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoDocumentContent extends ConsumerStatefulWidget {
  const _InfoDocumentContent({required this.topic});

  final InfoTopic topic;

  @override
  ConsumerState<_InfoDocumentContent> createState() =>
      _InfoDocumentContentState();
}

class _InfoDocumentContentState extends ConsumerState<_InfoDocumentContent> {
  DocsLanguage _language = DocsLanguage.english;
  Future<MarkdownDocument>? _document;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DocsLanguageSelector(
          selectedLanguage: _language,
          onSelected: _selectLanguage,
        ),
        const SizedBox(height: NahpuSpacing.lg),
        FutureBuilder<MarkdownDocument>(
          future: _document ??= _loadDocument(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: NahpuControlSize.prominent,
                child: Center(child: CommonProgressIndicator()),
              );
            }
            final document = snapshot.data;
            if (snapshot.hasError || document == null) {
              return DocumentationErrorView(onRetry: _retry);
            }
            return MarkdownDocumentView(document: document);
          },
        ),
      ],
    );
  }

  Future<MarkdownDocument> _loadDocument() {
    return ref
        .read(documentationRepositoryProvider)
        .loadInfo(widget.topic, _language);
  }

  void _selectLanguage(DocsLanguage language) {
    setState(() {
      _language = language;
      _document = _loadDocument();
    });
  }

  void _retry() {
    setState(() => _document = _loadDocument());
  }
}

void showDeleteAlertOnMenu({
  required BuildContext context,
  required String deletePrompt,
  required String title,
  required FutureOr<void> Function() onDelete,
  String? requiredConfirmationText,
}) {
  Future.delayed(const Duration(milliseconds: 0), () {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DeleteAlerts(
            deletePrompt: deletePrompt,
            title: title,
            onDelete: onDelete,
            requiredConfirmationText: requiredConfirmationText,
          );
        },
      );
    }
  });
}

class DeleteAlerts extends ConsumerStatefulWidget {
  const DeleteAlerts({
    super.key,
    required this.title,
    required this.deletePrompt,
    required this.onDelete,
    this.requiredConfirmationText,
  });

  final String title;
  final String deletePrompt;
  final FutureOr<void> Function() onDelete;
  final String? requiredConfirmationText;

  @override
  ConsumerState<DeleteAlerts> createState() => _DeleteAlertsState();
}

class _DeleteAlertsState extends ConsumerState<DeleteAlerts> {
  late final TextEditingController _confirmationController;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _confirmationController = TextEditingController();
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  bool get _isDeleteEnabled {
    final requiredConfirmation = widget.requiredConfirmationText;
    if (requiredConfirmation == null) {
      return true;
    }
    return _confirmationController.text == requiredConfirmation;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.deletePrompt, textAlign: TextAlign.center),
          if (widget.requiredConfirmationText != null) ...[
            const SizedBox(height: 16),
            Text(
              'Type `${widget.requiredConfirmationText}` to enable delete',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmationController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              enabled: !_isDeleting,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                hintText: 'Enter confirmation text',
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            disabledForegroundColor: Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha(160),
          ),
          onPressed: _isDeleteEnabled && !_isDeleting
              ? () async {
                  setState(() => _isDeleting = true);
                  try {
                    await widget.onDelete();
                  } finally {
                    if (mounted) {
                      setState(() => _isDeleting = false);
                    }
                  }
                }
              : null,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class CommonTabBars extends ConsumerWidget {
  const CommonTabBars({
    super.key,
    required this.tabController,
    required this.length,
    required this.tabs,
    required this.children,
    required this.height,
  });

  final TabController tabController;
  final int length;
  final List<Tab> tabs;
  final List<Widget> children;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        DefaultTabController(
          length: length,
          child: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            controller: tabController,
            tabs: tabs,
          ),
        ),
        SizedBox(
          height: height,
          child: CommonPadding(
            child: TabBarView(controller: tabController, children: children),
          ),
        ),
      ],
    );
  }
}

class CommonEmptyForm extends StatelessWidget {
  const CommonEmptyForm({
    super.key,
    required this.iconPath,
    required this.text,
    this.child,
  });

  final String iconPath;
  final String text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          iconPath,
          height: 64,
          colorFilter: ColorFilter.mode(getIconColor(context), BlendMode.srcIn),
        ),
        const SizedBox(height: 8),
        Text(text, style: Theme.of(context).textTheme.labelLarge),
        child ?? const SizedBox.shrink(),
      ],
    );
  }
}
