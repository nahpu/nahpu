import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:nahpu/styles/decoration.dart';

class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    required this.child,
    this.infoContent,
    this.title = '',
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.mainAxisSize = MainAxisSize.max,
    this.isPrimary = false,
    this.isWithTitle = true,
    this.isWithDivider = true,
    this.isWithSidePadding = true,
  });

  final Widget child;
  final String title;
  final Widget? infoContent;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool isPrimary;
  final bool isWithTitle;
  final bool isWithDivider;
  final bool isWithSidePadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isPrimary
              ? Color.lerp(Theme.of(context).colorScheme.secondaryContainer,
                  Theme.of(context).colorScheme.surface, 0.2)
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withAlpha(80),
          border: Border.all(
            color: isPrimary
                ? Theme.of(context).colorScheme.secondary.withAlpha(50)
                : Theme.of(context).dividerColor.withAlpha(50),
            width: 1.5,
          ),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: mainAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: [
              isWithTitle
                  ? TitleForm(
                      text: title,
                      infoContent: infoContent ?? const SizedBox.shrink(),
                    )
                  : const SizedBox.shrink(),
              isWithTitle && !isPrimary
                  ? Divider(
                      thickness: 0.6,
                      color: Theme.of(context).tabBarTheme.dividerColor)
                  : const SizedBox.shrink(),
              isWithSidePadding
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      child: child)
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: child,
                    )
            ]),
      ),
    );
  }
}

class CommonIDForm extends StatelessWidget {
  const CommonIDForm({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).disabledColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}

class TitleForm extends StatelessWidget {
  const TitleForm({
    super.key,
    required this.text,
    this.isCentered = true,
    required this.infoContent,
  });

  final String text;
  final bool isCentered;
  final Widget infoContent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isCentered
          ? const EdgeInsets.fromLTRB(46, 0, 0, 4)
          : const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.values[1],
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          InfoButton(content: infoContent)
        ],
      ),
    );
  }
}

class InfoButton extends StatefulWidget {
  const InfoButton({super.key, required this.content});

  final Widget content;

  @override
  State<InfoButton> createState() => _InfoButtonState();
}

class _InfoButtonState extends State<InfoButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        systemPlatform == PlatformType.mobile
            ? showModalSheet()
            : showInfoDialog();
      },
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.info_outline_rounded,
        size: 20,
        color: Theme.of(context).dividerColor,
      ),
    );
  }

  void showInfoDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          content: Container(
            width: 400,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.75),
            child: InfoContainer(
              content: [
                widget.content,
              ],
            ),
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

  void showModalSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (BuildContext context) {
          return Container(
            width: double.infinity,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Info',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Divider(
                  thickness: 1.2,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(24),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.75),
                    child: widget.content,
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class InfoContainer extends StatefulWidget {
  const InfoContainer({
    super.key,
    required this.content,
  });

  final List<Widget> content;

  @override
  State<InfoContainer> createState() => _InfoContainerState();
}

class _InfoContainerState extends State<InfoContainer> {
  final ScrollController _scrollController = ScrollController();
  final ScrollPhysics _scrollPhysics = const ClampingScrollPhysics();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScrollbar(
      scrollController: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        physics: _scrollPhysics,
        shrinkWrap: true,
        itemCount: widget.content.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 4),
            child: widget.content[index],
          );
        },
      ),
    );
  }
}

class InfoContent extends StatelessWidget {
  const InfoContent({
    super.key,
    this.header,
    this.richContent,
    required this.content,
  });

  final String? header;
  final Widget? richContent;
  final String? content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        header != null
            ? Text(
                header!,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
                ),
              )
            : const SizedBox.shrink(),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.primary.withAlpha(16),
          ),
          child: richContent ??
              Text(
                content ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
        )
      ],
    );
  }
}

void showDeleteAlertOnMenu({
  required BuildContext context,
  required String deletePrompt,
  required String title,
  required VoidCallback onDelete,
}) {
  Future.delayed(
    const Duration(milliseconds: 0),
    () {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return DeleteAlerts(
              deletePrompt: deletePrompt,
              title: title,
              onDelete: onDelete,
            );
          },
        );
      }
    },
  );
}

class DeleteAlerts extends ConsumerWidget {
  const DeleteAlerts({
    super.key,
    required this.title,
    required this.deletePrompt,
    required this.onDelete,
  });

  final String title;
  final String deletePrompt;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(title),
      content: Text(
        deletePrompt,
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onDelete();
          },
          child: Text('Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
              child: TabBarView(
            controller: tabController,
            children: children,
          )),
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
          colorFilter: ColorFilter.mode(
            getIconColor(context),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        child ?? const SizedBox.shrink(),
      ],
    );
  }
}
