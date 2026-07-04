import 'package:flutter/material.dart';

/// A layout that centers its child and constrains its width to 500.
/// Add padding to the child.
/// Mostly used for forms with one column fields.
class ScrollableConstrainedLayout extends StatelessWidget {
  const ScrollableConstrainedLayout({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedLayout(
        child: child,
      ),
    );
  }
}

class ConstrainedLayout extends StatelessWidget {
  const ConstrainedLayout({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
          child: child,
        ),
      ),
    );
  }
}

/// A layout that disables the back gesture on Android and iOS.
class FalseWillPop extends StatelessWidget {
  const FalseWillPop({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: child,
    );
  }
}

class CommonScrollbar extends StatelessWidget {
  const CommonScrollbar({
    super.key,
    required this.scrollController,
    required this.child,
  });

  final ScrollController scrollController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        thumbVisibility: true,
        controller: scrollController,
        thickness: 3,
        child: child);
  }
}

class CommonPadding extends StatelessWidget {
  const CommonPadding({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0), child: child);
  }
}

class AdaptiveMainLayout extends StatelessWidget {
  const AdaptiveMainLayout({
    super.key,
    required this.useHorizontalLayout,
    required this.children,
    required this.height,
  });

  final List<Widget> children;
  final bool useHorizontalLayout;
  final double height;

  @override
  Widget build(BuildContext context) {
    return useHorizontalLayout
        ? ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: height,
            ),
            child: LayoutRow(
              withPadding: false,
              children: children,
            ))
        : LayoutContainer(children: children);
  }
}

class FocusDetectedLayout extends StatelessWidget {
  const FocusDetectedLayout({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: ListView(
          children: children,
        ));
  }
}

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.useHorizontalLayout,
    required this.children,
  });

  final List<Widget> children;
  final bool useHorizontalLayout;
  @override
  Widget build(BuildContext context) {
    return useHorizontalLayout
        ? LayoutRow(
            children: children,
          )
        : CommonPadding(
            child: LayoutContainer(children: children),
          );
  }
}

class LayoutContainer extends StatelessWidget {
  const LayoutContainer({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children,
    );
  }
}

class LayoutRow extends StatelessWidget {
  const LayoutRow({
    super.key,
    required this.children,
    this.withPadding = true,
  });

  final List<Widget> children;
  final bool withPadding;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var child in children)
          Expanded(
            child: withPadding ? CommonPadding(child: child) : child,
          ),
      ],
    );
  }
}
