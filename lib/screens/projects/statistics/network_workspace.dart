import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/projects/statistics/network_canvas.dart';
import 'package:nahpu/screens/projects/statistics/network_node_details.dart';
import 'package:nahpu/screens/projects/statistics/network_options.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/localization/type_labels.dart';
import 'package:nahpu/services/providers/network_statistics.dart';
import 'package:nahpu/services/statistics/network_layout.dart';
import 'package:nahpu/services/types/network_statistics.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Tabs of the bottom sheet on narrow screens.
enum _SheetTab { details, options, legend }

/// Network canvas with its options, view tools, and selected-node details,
/// laid over the canvas so the network keeps the room.
///
/// Wide screens put the options beside the canvas, docked on the Explore
/// card and floating in full screen, and float the details over its corner.
/// Narrow screens float the tools over the canvas and keep the details,
/// options, and legend in a bottom sheet.
class NetworkWorkspace extends ConsumerStatefulWidget {
  const NetworkWorkspace({
    super.key,
    required this.projectUuid,
    this.onFullScreen,
    this.title = '',
    this.onExitFullScreen,
  });

  final String? projectUuid;

  /// Opens the full-screen view; null when already full screen.
  final VoidCallback? onFullScreen;

  /// Name shown over the canvas in full screen.
  final String title;

  /// Leaves the full-screen view; null on the Explore card.
  final VoidCallback? onExitFullScreen;

  @override
  ConsumerState<NetworkWorkspace> createState() => _NetworkWorkspaceState();
}

class _NetworkWorkspaceState extends ConsumerState<NetworkWorkspace>
    with SingleTickerProviderStateMixin {
  static const _sheetMotion = Duration(milliseconds: 240);

  /// Keeps the canvas, with its zoom and pan, when the details open or close
  /// or the screen crosses between the wide and narrow layouts.
  final _canvasKey = GlobalKey();
  final _sheet = DraggableScrollableController();
  late final _tabs = TabController(
    length: _SheetTab.values.length,
    vsync: this,
  );

  /// The full-screen view starts with the options folded to give the
  /// network the room.
  late bool _isOptionsOpen = widget.onExitFullScreen == null;

  /// Last network drawn, kept on screen while a new page loads.
  NetworkLayoutResult? _last;
  int _fitCount = 0;

  @override
  void initState() {
    super.initState();
    // A record picked before this view opened, such as on the Explore card
    // before going full screen, shows its details once the sheet is laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final view = ref.read(networkViewProvider(widget.projectUuid));
      if (view.selected != null) _revealSheet(_SheetTab.details);
    });
  }

  @override
  void dispose() {
    _sheet.dispose();
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final provider = networkViewProvider(widget.projectUuid);
    ref.listen(provider.select((view) => view.selected), (previous, next) {
      if (next != null && next != previous) _revealSheet(_SheetTab.details);
    });
    final view = ref.watch(provider);
    final result = ref.watch(networkLayoutProvider(widget.projectUuid));
    if (result.value case final layout?) _last = layout;
    final layout = _last;
    final selected = view.selected == null
        ? null
        : layout?.nodeFor(view.selected!);

    final facts = selected == null || !selected.key.isRecord
        ? null
        : ref.watch(networkRecordDetailsProvider(selected.key)).value;
    final details = selected == null
        ? null
        : NetworkNodeDetails(
            node: selected,
            layout: view.layout,
            facts: facts,
            isExpanded: view.isExpanded(selected.key),
            onToggleLinks:
                view.layout == NetworkLayout.radial &&
                    selected.kind == NetworkNodeKind.record
                ? () => ref.read(provider.notifier).toggleExpanded(selected.key)
                : null,
            onClear: () => ref.read(provider.notifier).select(null),
          );

    final layoutLabel = view.layout.localizedLabel(l10n);
    final summary = switch (view.layout) {
      NetworkLayout.radial => l10n.projectStatsNetworkSummaryRadial(
        layoutLabel,
        view.rootType.localizedLabel(l10n),
      ),
      NetworkLayout.layered => l10n.projectStatsNetworkSummaryLayered(
        layoutLabel,
        view.columns.length,
      ),
    };

    // Full screen runs under the home indicator; the Explore card sits clear
    // of it.
    final bottomInset = widget.onExitFullScreen == null
        ? 0.0
        : MediaQuery.paddingOf(context).bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= NahpuBreakpoints.desktop;
        final Widget body;
        if (layout == null) {
          body = result.hasError
              ? _NetworkError(
                  message: l10n.projectStatsNetworkLoadError('${result.error}'),
                  onRetry: () =>
                      ref.invalidate(networkLayoutProvider(widget.projectUuid)),
                )
              : const Center(child: CircularProgressIndicator());
        } else if (layout.nodes.length <= 1 && _isEmpty(layout)) {
          body = Center(child: Text(l10n.projectStatsNetworkEmpty));
        } else {
          body = NetworkCanvas(
            key: _canvasKey,
            layout: layout,
            selected: view.selected,
            fitSignal: (
              view.layout,
              view.rootType,
              Object.hashAll(view.columns),
              _fitCount,
              // The canvas changes width when the options open or close.
              _isOptionsOpen,
            ),
            fitInsets: isWide
                ? _NetworkWideLayout.fitInsets(
                    isFullScreen: widget.onExitFullScreen != null,
                    isOptionsOpen: _isOptionsOpen,
                    bottomInset: bottomInset,
                  )
                : _NetworkSheetLayout.fitInsets,
            labels: NetworkCanvasLabels(
              columnLabel: (column) => column.localizedLabel(l10n),
              overflowLabel: l10n.projectStatsNetworkMore,
            ),
            onNodeTap: (node) => _onNodeTap(view, node),
          );
        }
        final canvas = ColoredBox(
          color: theme.colorScheme.surfaceContainerLowest,
          child: body,
        );

        if (isWide) {
          return _NetworkWideLayout(
            projectUuid: widget.projectUuid,
            canvas: canvas,
            details: details,
            tools: _NetworkTools(
              isLoading: result.isLoading,
              onFit: _fit,
              onReset: _reset,
              onFullScreen: widget.onFullScreen,
              onExitFullScreen: widget.onExitFullScreen,
            ),
            title: widget.title,
            onExitFullScreen: widget.onExitFullScreen,
            bottomInset: bottomInset,
            isOptionsOpen: _isOptionsOpen,
            onToggleOptions: () =>
                setState(() => _isOptionsOpen = !_isOptionsOpen),
          );
        }
        // The back button beside the title leaves full screen here, so the
        // tools leave out their own exit button.
        return _NetworkSheetLayout(
          projectUuid: widget.projectUuid,
          canvas: canvas,
          details: details,
          legendTypes: view.shownTypes,
          tools: _NetworkTools(
            isLoading: result.isLoading,
            onFit: _fit,
            onReset: _reset,
            onFullScreen: widget.onFullScreen,
          ),
          summary: summary,
          title: widget.title,
          onExitFullScreen: widget.onExitFullScreen,
          bottomInset: bottomInset,
          sheet: _sheet,
          tabs: _tabs,
          onTabTap: _onSheetTabTap,
        );
      },
    );
  }

  static bool _isEmpty(NetworkLayoutResult layout) =>
      layout.nodes.every((node) => node.count == 0);

  void _fit() => setState(() => _fitCount++);

  void _reset() {
    ref.read(networkViewProvider(widget.projectUuid).notifier).reset();
    _fit();
  }

  /// Raises the bottom sheet to its peek height, switching to [tab] when
  /// given. Wide screens have no sheet, so only the tab changes there.
  void _revealSheet(_SheetTab? tab) {
    if (tab != null) _tabs.index = tab.index;
    if (!_sheet.isAttached || _sheet.size >= _NetworkSheetLayout.peekSize) {
      return;
    }
    _sheet.animateTo(
      _NetworkSheetLayout.peekSize,
      duration: _sheetMotion,
      curve: Curves.easeOutCubic,
    );
  }

  /// A method tear-off, so the sheet header gets an equal callback on every
  /// build and rebuilds only when its tabs or labels change.
  void _onSheetTabTap() => _revealSheet(null);

  void _onNodeTap(NetworkViewState view, NetworkLayoutNode? node) {
    final controller = ref.read(
      networkViewProvider(widget.projectUuid).notifier,
    );
    if (node == null || node.kind == NetworkNodeKind.hub) {
      controller.select(null);
      return;
    }
    if (node.kind == NetworkNodeKind.overflow) {
      controller.showMore(node.key, parent: node.parent);
      return;
    }
    if (view.layout == NetworkLayout.radial) {
      controller.toggleExpanded(node.key);
      return;
    }
    controller.select(view.selected == node.key ? null : node.key);
  }
}

/// Wide layout: options beside the canvas, the view tools in its top right
/// corner, and the details floating under the tools.
class _NetworkWideLayout extends StatelessWidget {
  const _NetworkWideLayout({
    required this.projectUuid,
    required this.canvas,
    required this.details,
    required this.tools,
    required this.title,
    required this.onExitFullScreen,
    required this.bottomInset,
    required this.isOptionsOpen,
    required this.onToggleOptions,
  });

  static const _inset = NahpuSpacing.xl;

  /// Top of the options and details, below the row holding the title or
  /// heading on the left and the tools on the right.
  static const _belowTopRow = _inset * 2 + NahpuControlSize.touchTarget;

  /// Right edge of the title or heading, clear of the tools and of the
  /// details card under them.
  static const _titleEnd = NahpuContentWidth.statisticsDetails + _inset * 2;

  final String? projectUuid;
  final Widget canvas;
  final Widget? details;
  final Widget tools;
  final String title;
  final VoidCallback? onExitFullScreen;

  /// Room kept clear at the bottom for the home indicator in full screen.
  final double bottomInset;
  final bool isOptionsOpen;
  final VoidCallback onToggleOptions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final details = this.details;
    final options = isOptionsOpen
        ? NetworkOptionsPane(
            projectUuid: projectUuid,
            onCollapse: onToggleOptions,
          )
        : NetworkOptionsRail(
            projectUuid: projectUuid,
            onExpand: onToggleOptions,
          );
    final overlays = [
      Positioned(top: _inset, right: _inset, child: tools),
      if (details != null)
        Positioned(
          top: _belowTopRow,
          right: _inset,
          bottom: _inset + bottomInset,
          width: NahpuContentWidth.statisticsDetails,
          child: Align(
            alignment: Alignment.topCenter,
            child: _NetworkFloatingSurface(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(NahpuSpacing.lg),
                child: details,
              ),
            ),
          ),
        ),
    ];

    final onExitFullScreen = this.onExitFullScreen;
    if (onExitFullScreen == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                right: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: isOptionsOpen
                ? SizedBox(
                    width: NahpuContentWidth.statisticsOptions,
                    child: options,
                  )
                : options,
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: canvas),
                Positioned(
                  top: _inset,
                  left: _inset,
                  right: _titleEnd,
                  // Lets taps through to the nodes under the heading.
                  child: const IgnorePointer(child: _NetworkHeading()),
                ),
                ...overlays,
              ],
            ),
          ),
        ],
      );
    }
    return Stack(
      children: [
        Positioned.fill(child: canvas),
        Positioned(
          top: _inset,
          left: _inset,
          right: _titleEnd,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _NetworkFloatingSurface(
              child: _NetworkTitleBar(title: title, onBack: onExitFullScreen),
            ),
          ),
        ),
        Positioned(
          top: _belowTopRow,
          left: _inset,
          bottom: _inset + bottomInset,
          width: isOptionsOpen ? NahpuContentWidth.statisticsOptions : null,
          child: Align(
            alignment: Alignment.topLeft,
            child: _NetworkFloatingSurface(child: options),
          ),
        ),
        ...overlays,
      ],
    );
  }

  /// Room the fitted network leaves for the controls over the canvas.
  static EdgeInsets fitInsets({
    required bool isFullScreen,
    required bool isOptionsOpen,
    required double bottomInset,
  }) {
    // The docked options pane already sits outside the canvas.
    final optionsWidth = !isFullScreen
        ? 0.0
        : isOptionsOpen
        ? NahpuContentWidth.statisticsOptions
        : NahpuControlSize.touchTarget;
    return EdgeInsets.fromLTRB(
      optionsWidth + _inset * 2,
      _belowTopRow,
      _inset,
      _inset + bottomInset,
    );
  }
}

/// Narrow layout: the canvas with tools floating at the top and a bottom
/// sheet holding the details, options, and legend.
class _NetworkSheetLayout extends StatelessWidget {
  const _NetworkSheetLayout({
    required this.projectUuid,
    required this.canvas,
    required this.details,
    required this.legendTypes,
    required this.tools,
    required this.summary,
    required this.title,
    required this.onExitFullScreen,
    required this.bottomInset,
    required this.sheet,
    required this.tabs,
    required this.onTabTap,
  });

  /// Drag handle and tab bar, the part of the sheet that never folds away.
  static const headerHeight = NahpuSpacing.xxl + kTextTabBarHeight;

  /// Sheet height, as a share of the view, after a node is tapped: enough
  /// for the summary of a record while the network stays in sight.
  static const peekSize = 0.45;
  static const _maxSize = 0.9;
  static const _inset = NahpuSpacing.md;

  /// Room the fitted network leaves for the tools above it.
  static const fitInsets = EdgeInsets.fromLTRB(
    _inset,
    _inset * 2 + NahpuControlSize.touchTarget,
    _inset,
    _inset,
  );

  final String? projectUuid;
  final Widget canvas;
  final Widget? details;
  final List<NetworkNodeType> legendTypes;
  final Widget tools;
  final String summary;
  final String title;
  final VoidCallback? onExitFullScreen;

  /// Room at the bottom for the home indicator in full screen, filled with
  /// the sheet color so the sheet reads as running to the screen edge.
  final double bottomInset;
  final DraggableScrollableController sheet;
  final TabController tabs;
  final VoidCallback onTabTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final onExitFullScreen = this.onExitFullScreen;
    return LayoutBuilder(
      builder: (context, constraints) {
        final minSize = math.min(
          headerHeight / (constraints.maxHeight - bottomInset),
          peekSize,
        );
        return Stack(
          children: [
            Positioned.fill(bottom: headerHeight + bottomInset, child: canvas),
            Positioned(
              top: _inset,
              left: _inset,
              right: _inset,
              child: Row(
                children: [
                  if (onExitFullScreen != null) ...[
                    _NetworkFloatingSurface(
                      child: IconButton(
                        tooltip: l10n.projectStatsNetworkExitFullScreen,
                        onPressed: onExitFullScreen,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    const SizedBox(width: NahpuSpacing.md),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ] else
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: NahpuSpacing.sm),
                        child: Text(
                          summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: NahpuSpacing.md),
                  tools,
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bottomInset,
              child: ColoredBox(color: theme.colorScheme.surfaceContainerLow),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: DraggableScrollableSheet(
                controller: sheet,
                initialChildSize: minSize,
                minChildSize: minSize,
                maxChildSize: _maxSize,
                snap: true,
                snapSizes: [if (minSize < peekSize) peekSize],
                builder: (context, scrollController) => _NetworkSheet(
                  projectUuid: projectUuid,
                  details: details,
                  legendTypes: legendTypes,
                  tabs: tabs,
                  scrollController: scrollController,
                  onTabTap: onTabTap,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Bottom sheet body: a pinned handle and tab bar over the chosen tab.
class _NetworkSheet extends StatelessWidget {
  const _NetworkSheet({
    required this.projectUuid,
    required this.details,
    required this.legendTypes,
    required this.tabs,
    required this.scrollController,
    required this.onTabTap,
  });

  final String? projectUuid;
  final Widget? details;
  final List<NetworkNodeType> legendTypes;
  final TabController tabs;
  final ScrollController scrollController;
  final VoidCallback onTabTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      key: const ValueKey('statistics-network-sheet'),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(NahpuRadius.xl),
        ),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _NetworkSheetHeader(
              tabs: tabs,
              labels: [
                for (final tab in _SheetTab.values)
                  switch (tab) {
                    _SheetTab.details => l10n.projectStatsNetworkDetails,
                    _SheetTab.options => l10n.projectStatsNetworkOptions,
                    _SheetTab.legend => l10n.projectStatsNetworkLegend,
                  },
              ],
              color: colorScheme.surfaceContainerLow,
              onTap: onTabTap,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(NahpuSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: ListenableBuilder(
                listenable: tabs,
                builder: (context, _) => switch (_SheetTab.values[tabs.index]) {
                  _SheetTab.details =>
                    details ?? Text(l10n.projectStatsNetworkHint),
                  _SheetTab.options => NetworkOptions(projectUuid: projectUuid),
                  _SheetTab.legend => NetworkLegend(types: legendTypes),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Drag handle and tab bar pinned to the top of the bottom sheet.
class _NetworkSheetHeader extends SliverPersistentHeaderDelegate {
  const _NetworkSheetHeader({
    required this.tabs,
    required this.labels,
    required this.color,
    required this.onTap,
  });

  final TabController tabs;
  final List<String> labels;
  final Color color;

  /// Called when a tab is tapped, so a folded sheet rises to show it.
  final VoidCallback onTap;

  @override
  double get minExtent => _NetworkSheetLayout.headerHeight;

  @override
  double get maxExtent => _NetworkSheetLayout.headerHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: color,
      child: Column(
        children: [
          SizedBox(
            height: NahpuSpacing.xxl,
            child: Center(
              child: Container(
                width: NahpuSpacing.xxxl,
                height: NahpuSpacing.xs,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(NahpuRadius.xs),
                ),
              ),
            ),
          ),
          TabBar(
            controller: tabs,
            onTap: (_) => onTap(),
            tabs: [for (final label in labels) Tab(text: label)],
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _NetworkSheetHeader oldDelegate) =>
      oldDelegate.tabs != tabs ||
      !listEquals(oldDelegate.labels, labels) ||
      oldDelegate.color != color ||
      oldDelegate.onTap != onTap;
}

/// Title and hint over the canvas on the Explore card.
class _NetworkHeading extends StatelessWidget {
  const _NetworkHeading();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.projectStatsNetworkTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
        Text(
          l10n.projectStatsNetworkHint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Back button and name of the full-screen network.
class _NetworkTitleBar extends StatelessWidget {
  const _NetworkTitleBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: context.l10n.projectStatsNetworkExitFullScreen,
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(right: NahpuSpacing.xl),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
      ],
    );
  }
}

/// Fit, reset, and full-screen buttons on one floating surface.
class _NetworkTools extends StatelessWidget {
  const _NetworkTools({
    required this.isLoading,
    required this.onFit,
    required this.onReset,
    this.onFullScreen,
    this.onExitFullScreen,
  });

  final bool isLoading;
  final VoidCallback onFit;
  final VoidCallback onReset;
  final VoidCallback? onFullScreen;
  final VoidCallback? onExitFullScreen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _NetworkFloatingSurface(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(NahpuSpacing.lg),
              child: SizedBox.square(
                dimension: NahpuControlSize.iconSmall,
                child: CircularProgressIndicator(
                  strokeWidth: NahpuStroke.regular,
                ),
              ),
            ),
          IconButton(
            tooltip: l10n.projectStatsNetworkFit,
            onPressed: onFit,
            icon: const Icon(Icons.fit_screen_outlined),
          ),
          IconButton(
            tooltip: l10n.projectStatsNetworkReset,
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
          if (onFullScreen != null)
            IconButton(
              key: const ValueKey('statistics-network-full-screen'),
              tooltip: l10n.projectStatsNetworkFullScreen,
              onPressed: onFullScreen,
              icon: const Icon(Icons.fullscreen_rounded),
            ),
          if (onExitFullScreen != null)
            IconButton(
              key: const ValueKey('statistics-network-exit-full-screen'),
              tooltip: l10n.projectStatsNetworkExitFullScreen,
              onPressed: onExitFullScreen,
              icon: const Icon(Icons.fullscreen_exit_rounded),
            ),
        ],
      ),
    );
  }
}

/// Flat, outlined surface for controls and details laid over the network
/// canvas.
class _NetworkFloatingSurface extends StatelessWidget {
  const _NetworkFloatingSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NahpuRadius.lg),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _NetworkError extends StatelessWidget {
  const _NetworkError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: NahpuSpacing.md),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.l10n.commonRetry),
          ),
        ],
      ),
    );
  }
}
