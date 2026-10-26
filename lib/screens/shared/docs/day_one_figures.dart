import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/docs/mdoc_body.dart';
import 'package:nahpu/services/docs/day_one_figures.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// Widest the record-map artwork grows before the detail sits beside it.
const double _recordMapMaxWidth = 416;
const Duration _figureAnimation = Duration(milliseconds: 250);

/// Day One record map: tap a record to read what it holds.
///
/// The artwork is shared with the website; titles and details come from the
/// page so they follow the document language.
class DayOneRecordMap extends ConsumerStatefulWidget {
  const DayOneRecordMap({super.key, required this.block});

  final MdocRecordMapBlock block;

  @override
  ConsumerState<DayOneRecordMap> createState() => _DayOneRecordMapState();
}

class _DayOneRecordMapState extends ConsumerState<DayOneRecordMap> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final figures = ref.watch(dayOneFiguresProvider).value;
    if (figures == null) return const SizedBox.shrink();
    final nodes = {for (final node in widget.block.nodes) node.id: node};
    final stage = _RecordMapStage(
      figures: figures,
      nodes: nodes,
      selectedId: _selectedId,
      onSelected: (id) => setState(() => _selectedId = id),
    );
    final detail = _FigureDetail(
      key: ValueKey('day-one-record-detail-$_selectedId'),
      title: nodes[_selectedId]?.title,
      body: nodes[_selectedId]?.detail ?? widget.block.hint,
    );
    return Semantics(
      container: true,
      label: widget.block.label,
      child: _FigureCard(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < NahpuBreakpoints.compact) {
              return Column(
                children: [
                  stage,
                  const SizedBox(height: NahpuSpacing.lg),
                  _AnimatedDetail(child: detail),
                ],
              );
            }
            return Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _recordMapMaxWidth,
                  ),
                  child: stage,
                ),
                const SizedBox(width: NahpuSpacing.xl),
                Expanded(child: _AnimatedDetail(child: detail)),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Day One practice trail: one waypoint per practice step. A waypoint scrolls
/// to its step and stays checked for the rest of the session.
class DayOneFieldTrail extends ConsumerStatefulWidget {
  const DayOneFieldTrail({
    super.key,
    required this.block,
    required this.steps,
    required this.stepKeys,
  });

  final MdocFieldTrailBlock block;
  final List<MdocStep> steps;

  /// Keys on the rendered steps, in step order, used to scroll to them.
  final List<GlobalKey> stepKeys;

  @override
  ConsumerState<DayOneFieldTrail> createState() => _DayOneFieldTrailState();
}

class _DayOneFieldTrailState extends ConsumerState<DayOneFieldTrail> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final figures = ref.watch(dayOneFiguresProvider).value;
    if (figures == null || widget.steps.isEmpty) {
      return const SizedBox.shrink();
    }
    final visited = ref.watch(dayOneTrailVisitedProvider);
    final count = figures.waypoints.length < widget.steps.length
        ? figures.waypoints.length
        : widget.steps.length;
    final selected = _selected;
    return Semantics(
      container: true,
      label: widget.block.label,
      child: _FigureCard(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: figures.trailWidth / figures.trailHeight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scale = constraints.maxWidth / figures.trailWidth;
                  const size = NahpuControlSize.iconLarge;
                  return Stack(
                    children: [
                      const Positioned.fill(
                        child: _FigureArtwork(DayOneFigureAssets.fieldTrail),
                      ),
                      for (var index = 0; index < count; index++)
                        Positioned(
                          left: figures.waypoints[index].x * scale - size / 2,
                          top: figures.waypoints[index].y * scale - size / 2,
                          width: size,
                          height: size,
                          child: _Waypoint(
                            key: ValueKey('day-one-waypoint-$index'),
                            number: index + 1,
                            title: widget.steps[index].title,
                            visited: visited.contains(index),
                            selected: index == selected,
                            onTap: () => _open(index),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: NahpuSpacing.lg),
            _AnimatedDetail(
              child: _FigureDetail(
                key: ValueKey('day-one-trail-detail-$selected'),
                title: selected == null
                    ? null
                    : '${selected + 1}. ${widget.steps[selected].title}',
                body: selected == null
                    ? widget.block.hint
                    : widget.block.progress
                          .replaceAll('{visited}', '${visited.length}')
                          .replaceAll('{total}', '${widget.steps.length}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(int index) {
    ref.read(dayOneTrailVisitedProvider.notifier).visit(index);
    setState(() => _selected = index);
    final stepContext = index < widget.stepKeys.length
        ? widget.stepKeys[index].currentContext
        : null;
    if (stepContext == null) return;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    Scrollable.ensureVisible(
      stepContext,
      duration: reduceMotion ? Duration.zero : _figureAnimation,
      curve: Curves.easeOut,
    );
  }
}

class _RecordMapStage extends StatelessWidget {
  const _RecordMapStage({
    required this.figures,
    required this.nodes,
    required this.selectedId,
    required this.onSelected,
  });

  final DayOneFigures figures;
  final Map<String, MdocRecordNode> nodes;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: figures.recordMapWidth / figures.recordMapHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / figures.recordMapWidth;
          return Stack(
            children: [
              const Positioned.fill(
                child: _FigureArtwork(DayOneFigureAssets.recordMap),
              ),
              for (final box in figures.recordBoxes)
                if (nodes[box.id] case final node?)
                  Positioned(
                    left: box.x * scale,
                    top: box.y * scale,
                    width: box.width * scale,
                    height: box.height * scale,
                    child: _RecordNodeButton(
                      key: ValueKey('day-one-record-${box.id}'),
                      node: node,
                      tone: box.tone,
                      selected: node.id == selectedId,
                      onTap: () => onSelected(node.id),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _RecordNodeButton extends StatelessWidget {
  const _RecordNodeButton({
    super.key,
    required this.node,
    required this.tone,
    required this.selected,
    required this.onTap,
  });

  final MdocRecordNode node;
  final DayOneRecordTone tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (foreground, ring) = _toneColors(theme.colorScheme);
    final radius = BorderRadius.circular(NahpuRadius.md);
    final project = tone == DayOneRecordTone.project;
    return Semantics(
      button: true,
      selected: selected,
      label: '${node.title}, ${node.summary}',
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: AnimatedContainer(
            duration: _figureAnimation,
            padding: const EdgeInsets.symmetric(horizontal: NahpuSpacing.md),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? ring : Colors.transparent,
                width: NahpuStroke.regular,
              ),
            ),
            alignment: project ? Alignment.centerLeft : Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: project ? Alignment.centerLeft : Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: project
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Text(
                    node.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    node.summary,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color) _toneColors(ColorScheme colors) {
    return switch (tone) {
      DayOneRecordTone.project => (colors.onSurface, colors.outline),
      DayOneRecordTone.place => (colors.onSecondaryContainer, colors.secondary),
      DayOneRecordTone.record => (colors.onPrimaryContainer, colors.primary),
      DayOneRecordTone.shared => (colors.onTertiaryContainer, colors.tertiary),
    };
  }
}

class _Waypoint extends StatelessWidget {
  const _Waypoint({
    super.key,
    required this.number,
    required this.title,
    required this.visited,
    required this.selected,
    required this.onTap,
  });

  final int number;
  final String title;
  final bool visited;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final background = visited ? colors.primary : colors.surface;
    final foreground = visited ? colors.onPrimary : colors.onSurface;
    return Tooltip(
      message: title,
      child: Semantics(
        button: true,
        selected: selected,
        label: '$number. $title',
        excludeSemantics: true,
        child: Material(
          color: background,
          shape: CircleBorder(
            side: BorderSide(
              color: selected ? colors.tertiary : colors.secondary,
              width: selected ? NahpuStroke.regular : NahpuStroke.thin,
            ),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Center(
              child: visited && !selected
                  ? Icon(
                      Icons.check_rounded,
                      size: NahpuControlSize.iconSmall,
                      color: foreground,
                    )
                  : Text(
                      '$number',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FigureCard extends StatelessWidget {
  const _FigureCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(NahpuSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(NahpuRadius.lg),
        border: Border.all(
          color: colors.outlineVariant,
          width: NahpuStroke.thin,
        ),
      ),
      child: child,
    );
  }
}

class _AnimatedDetail extends StatelessWidget {
  const _AnimatedDetail({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : _figureAnimation,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topLeft,
        children: [...previous, ?current],
      ),
      child: child,
    );
  }
}

class _FigureDetail extends StatelessWidget {
  const _FigureDetail({super.key, required this.title, required this.body});

  final String? title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final title = this.title;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(NahpuSpacing.lg),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(NahpuRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FigureArtwork extends StatelessWidget {
  const _FigureArtwork(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      fit: BoxFit.fill,
      excludeFromSemantics: true,
      colorMapper: _ThemeColorMapper.of(Theme.of(context).colorScheme),
    );
  }
}

/// Repaints the shared artwork, drawn in the website's "Canopy" palette, with
/// the active color scheme so it follows light and dark themes.
class _ThemeColorMapper extends ColorMapper {
  const _ThemeColorMapper(this._colors);

  factory _ThemeColorMapper.of(ColorScheme scheme) {
    return _ThemeColorMapper({
      // Project boundary, outlines, and trees.
      0xfff3f6f4: scheme.surfaceContainerLow,
      0xff718e78: scheme.outline,
      0xff8199a2: scheme.outline,
      // Region of records shared across projects.
      0xfff4f7f8: scheme.surfaceContainer,
      0xffa9bcc2: scheme.outlineVariant,
      // Sites and events.
      0xffe2e9e3: scheme.secondaryContainer,
      0xff405847: scheme.secondary,
      // Specimens and the trail.
      0xffe8f1d2: scheme.primaryContainer,
      0xffd3e4a9: scheme.primaryContainer,
      0xff688a2c: scheme.primary,
      // Personnel and taxa.
      0xffe4ecee: scheme.tertiaryContainer,
      0xff637c86: scheme.tertiary,
      // Trail scenery.
      0xffb5d177: scheme.secondaryContainer,
      0xffcdd9dd: scheme.surfaceContainerHighest,
      0xffc5d3c8: scheme.surfaceContainerHigh,
    });
  }

  final Map<int, Color> _colors;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    return _colors[color.toARGB32()] ?? color;
  }

  // The SVG cache keys on the mapper, so a theme change must miss it.
  @override
  bool operator ==(Object other) {
    if (other is! _ThemeColorMapper) return false;
    if (other._colors.length != _colors.length) return false;
    for (final entry in _colors.entries) {
      if (other._colors[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAllUnordered(
    _colors.entries.map((entry) => Object.hash(entry.key, entry.value)),
  );
}
