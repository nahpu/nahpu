import 'package:material_ui/material_ui.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// A layout that centers its child and constrains its width to 500.
/// Add padding to the child.
/// Mostly used for forms with one column fields.
class ScrollableConstrainedLayout extends StatelessWidget {
  const ScrollableConstrainedLayout({
    super.key,
    required this.child,
    this.footer,
  });

  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    if (footer == null) {
      return SingleChildScrollView(
        child: ConstrainedLayout(
          child: child,
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: ConstrainedLayout(
              child: child,
            ),
          ),
        ),
        ConstrainedLayout(child: footer!),
      ],
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
        constraints: const BoxConstraints(maxWidth: NahpuContentWidth.form),
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
        thickness: NahpuStroke.regular,
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
        padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.xs),
        child: child);
  }
}

class AdaptiveMainLayout extends StatelessWidget {
  const AdaptiveMainLayout({
    super.key,
    required this.useHorizontalLayout,
    required this.children,
    required this.height,
    this.stretchChildren = false,
  });

  final List<Widget> children;
  final bool useHorizontalLayout;
  final double height;
  final bool stretchChildren;

  @override
  Widget build(BuildContext context) {
    return useHorizontalLayout
        ? stretchChildren
              ? SizedBox(
                  height: height,
                  child: LayoutRow(
                    withPadding: false,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: height),
                  child: LayoutRow(withPadding: false, children: children),
                )
        : LayoutContainer(children: children);
  }
}

class DashboardPanelBody extends StatelessWidget {
  const DashboardPanelBody({
    super.key,
    required this.content,
    required this.actions,
    this.contentAlignment = Alignment.topCenter,
  });

  final Widget content;
  final Widget actions;
  final Alignment contentAlignment;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 360,
        maxHeight: 360,
        maxWidth: 460,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: contentAlignment,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: content,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Align(alignment: Alignment.center, child: actions),
        ],
      ),
    );
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
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final List<Widget> children;
  final bool withPadding;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
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
