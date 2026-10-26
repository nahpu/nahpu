import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// How much room the tissue curation workbench has.
enum TissueCurationWidth {
  /// Box, Setup, and Log tabs, with the scan card pinned below them.
  phone,

  /// The box beside the scan card and a Setup and Log inspector.
  wide,

  /// As wide, with the session log in a column of its own.
  extraWide;

  static TissueCurationWidth of(double width) {
    if (width >= NahpuBreakpoints.wide) return extraWide;
    if (width >= NahpuBreakpoints.desktop) return wide;
    return phone;
  }
}

/// Phones: the box, setup, and log each get a tab that scrolls on its own,
/// and the scan card stays pinned at the bottom on every tab.
class TissueCurationPhoneLayout extends StatelessWidget {
  const TissueCurationPhoneLayout({
    super.key,
    required this.header,
    required this.box,
    required this.setup,
    required this.log,
    required this.logCount,
    required this.scan,
  });

  final Widget header;
  final Widget box;
  final Widget setup;
  final Widget log;
  final int logCount;
  final Widget scan;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            key: const ValueKey('tissue-phone-tabs'),
            tabs: [
              Tab(text: context.l10n.projectTissueTabBox),
              Tab(text: context.l10n.projectTissueTabSetup),
              Tab(text: context.l10n.projectTissueTabLog(logCount)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                TissueCurationScrollPane(children: [header, box]),
                TissueCurationScrollPane(
                  children: [TissueCurationPanelCard(child: setup)],
                ),
                TissueCurationScrollPane(
                  children: [TissueCurationPanelCard(child: log)],
                ),
              ],
            ),
          ),
          TissueCurationScanDock(child: scan),
        ],
      ),
    );
  }
}

/// Wide screens: the box on the left, sized so the whole grid fits the
/// window, and the scan card above the inspector on the right. The box sets
/// the row's height and the other columns match it, each scrolling on its
/// own, so a growing panel never moves the box. The widest screens give the
/// session log its own column.
class TissueCurationWideLayout extends StatelessWidget {
  const TissueCurationWideLayout({
    super.key,
    required this.header,
    required this.box,
    required this.setup,
    required this.log,
    required this.logCount,
    required this.scan,
    this.logColumn = false,
  });

  final Widget header;
  final Widget box;
  final Widget setup;
  final Widget log;
  final int logCount;
  final Widget scan;

  /// Shows the log in a third column instead of an inspector tab.
  final bool logColumn;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Short windows scroll the page rather than squeeze the panes.
        final height = math.max(
          constraints.maxHeight,
          NahpuCurationLayout.minHeight,
        );
        return SingleChildScrollView(
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                NahpuSpacing.xl,
                NahpuPageMargin.top,
                NahpuSpacing.xl,
                NahpuSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: NahpuContentWidth.curation,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      header,
                      const SizedBox(height: NahpuSpacing.xl),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, area) => TissueCurationPanes(
                            boxWidth: _boxWidth(area),
                            box: box,
                            scan: scan,
                            inspector: TissueCurationInspector(
                              setup: setup,
                              log: logColumn ? null : log,
                              logCount: logCount,
                            ),
                            logColumn: logColumn
                                ? Card(
                                    key: const ValueKey('tissue-log-column'),
                                    margin: EdgeInsets.zero,
                                    clipBehavior: Clip.antiAlias,
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(
                                        NahpuSpacing.xl,
                                      ),
                                      child: log,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The grid is square, so the box is as wide as the height leaves for
  /// it, capped at a share of the row so the inspector keeps its room.
  double _boxWidth(BoxConstraints area) {
    final maxShare = area.maxWidth * (logColumn ? 0.42 : 0.55);
    return (area.maxHeight - NahpuCurationLayout.boxChrome)
        .clamp(
          NahpuCurationLayout.minBoxWidth,
          math.max(NahpuCurationLayout.minBoxWidth, maxShare),
        )
        .toDouble();
  }
}

/// The workbench row: the box at its natural height, then the scan card
/// and inspector, and the log column, all cut to the box's height.
class TissueCurationPanes extends StatelessWidget {
  const TissueCurationPanes({
    super.key,
    required this.boxWidth,
    required this.box,
    required this.scan,
    required this.inspector,
    this.logColumn,
  });

  final double boxWidth;
  final Widget box;
  final Widget scan;
  final Widget inspector;

  /// Null leaves the log to the inspector's tab.
  final Widget? logColumn;

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: TissueCurationPanesDelegate(
        boxWidth: boxWidth,
        gap: NahpuSpacing.xl,
        logWidth: logColumn == null ? null : NahpuCurationLayout.logWidth,
      ),
      children: [
        LayoutId(
          id: TissueCurationPane.box,
          child: SingleChildScrollView(child: box),
        ),
        LayoutId(
          id: TissueCurationPane.scan,
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // A long work list scrolls inside the card, leaving the
                // inspector below it on screen.
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.6,
                  ),
                  child: SingleChildScrollView(child: scan),
                ),
                const SizedBox(height: NahpuSpacing.xl),
                Expanded(child: inspector),
              ],
            ),
          ),
        ),
        if (logColumn != null)
          LayoutId(id: TissueCurationPane.log, child: logColumn!),
      ],
    );
  }
}

enum TissueCurationPane { box, scan, log }

/// Lays out the box first, then sizes the other columns to its height. A
/// box taller than the row, as with a cell inspector open, scrolls.
class TissueCurationPanesDelegate extends MultiChildLayoutDelegate {
  TissueCurationPanesDelegate({
    required this.boxWidth,
    required this.gap,
    this.logWidth,
  });

  final double boxWidth;
  final double gap;

  /// Null when there is no log column.
  final double? logWidth;

  @override
  void performLayout(Size size) {
    final box = layoutChild(
      TissueCurationPane.box,
      BoxConstraints(
        minWidth: boxWidth,
        maxWidth: boxWidth,
        maxHeight: size.height,
      ),
    );
    positionChild(TissueCurationPane.box, Offset.zero);
    final height = box.height;
    final logWidth = this.logWidth;
    final logSpace = logWidth == null ? 0.0 : gap + logWidth;
    final scanWidth = math.max(0.0, size.width - boxWidth - gap - logSpace);
    layoutChild(
      TissueCurationPane.scan,
      BoxConstraints.tight(Size(scanWidth, height)),
    );
    positionChild(TissueCurationPane.scan, Offset(boxWidth + gap, 0));
    if (logWidth != null && hasChild(TissueCurationPane.log)) {
      layoutChild(
        TissueCurationPane.log,
        BoxConstraints.tight(Size(logWidth, height)),
      );
      positionChild(TissueCurationPane.log, Offset(size.width - logWidth, 0));
    }
  }

  @override
  bool shouldRelayout(TissueCurationPanesDelegate oldDelegate) {
    return boxWidth != oldDelegate.boxWidth ||
        gap != oldDelegate.gap ||
        logWidth != oldDelegate.logWidth;
  }
}

/// The setup panel in a card that keeps its height and scrolls inside,
/// with a Log tab beside it unless the log has its own column.
class TissueCurationInspector extends StatelessWidget {
  const TissueCurationInspector({
    super.key,
    required this.setup,
    required this.logCount,
    this.log,
  });

  final Widget setup;
  final int logCount;

  /// Null leaves Setup as the only pane, without tabs.
  final Widget? log;

  @override
  Widget build(BuildContext context) {
    final setupPane = SingleChildScrollView(
      key: const ValueKey('tissue-setup-scroll'),
      padding: const EdgeInsets.all(NahpuSpacing.xl),
      child: setup,
    );
    return Card(
      key: const ValueKey('tissue-inspector'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: log == null
          ? setupPane
          : DefaultTabController(
              length: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: context.l10n.projectTissueTabSetup),
                      Tab(text: context.l10n.projectTissueTabLog(logCount)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        setupPane,
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(NahpuSpacing.xl),
                          child: log,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// A phone tab's content, scrolling under the tab bar.
class TissueCurationScrollPane extends StatelessWidget {
  const TissueCurationScrollPane({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        NahpuPageMargin.horizontal,
        NahpuPageMargin.top,
        NahpuPageMargin.horizontal,
        NahpuPageMargin.top,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const SizedBox(height: NahpuSpacing.xl),
            child,
          ],
        ],
      ),
    );
  }
}

/// A padded card for a panel that has none of its own.
class TissueCurationPanelCard extends StatelessWidget {
  const TissueCurationPanelCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(NahpuSpacing.xl),
        child: child,
      ),
    );
  }
}

/// The scan card pinned to the bottom of a phone screen, above the soft
/// keyboard. A long work list scrolls inside it so the tabs keep room.
class TissueCurationScanDock extends StatelessWidget {
  const TissueCurationScanDock({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    final visibleHeight = media.size.height - media.viewInsets.bottom;
    // A Material, not a colored box, so the switch tiles inside still
    // paint their ink.
    return Material(
      key: const ValueKey('tissue-scan-dock'),
      color: colorScheme.surfaceContainerLow,
      shape: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          NahpuSpacing.xl,
          NahpuSpacing.md,
          NahpuSpacing.xl,
          NahpuSpacing.xs,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: visibleHeight * 0.5),
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }
}
