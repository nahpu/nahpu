import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/layout/panel.dart';
import 'package:nahpu/styles/design_tokens.dart';

/// The standard NAHPU wizard chrome: one step rail, one set of step chips, one
/// action bar.
///
/// The project transfer and setup wizards had grown the same rail, chips, and
/// action bar side by side, so a change to one silently drifted from the other.
/// The transfer wizard's look is the one everything else matches.
class NahpuWizardScaffold extends StatefulWidget {
  const NahpuWizardScaffold({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.maxVisitedStep,
    required this.onStepSelected,
    required this.child,
  });

  final List<String> steps;
  final int currentStep;

  /// Steps past this one cannot be jumped to, so a wizard cannot be skipped
  /// ahead into a step whose inputs are not ready.
  final int maxVisitedStep;

  final ValueChanged<int> onStepSelected;

  /// The content of [currentStep]. Swapped with an animation keyed on the step.
  final Widget child;

  @override
  State<NahpuWizardScaffold> createState() => NahpuWizardScaffoldState();
}

class NahpuWizardScaffoldState extends State<NahpuWizardScaffold> {
  final _stepChipScrollController = ScrollController();
  List<GlobalKey> _stepChipKeys = const [];

  @override
  void initState() {
    super.initState();
    _syncStepChipKeys();
  }

  @override
  void didUpdateWidget(NahpuWizardScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The setup wizard adds and drops steps as the catalog format changes, so
    // the key list cannot be a fixed length.
    if (oldWidget.steps.length != widget.steps.length) _syncStepChipKeys();
    if (oldWidget.currentStep != widget.currentStep) scrollActiveStepChip();
  }

  @override
  void dispose() {
    _stepChipScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide =
        MediaQuery.sizeOf(context).width >= NahpuBreakpoints.projectWizardRail;
    return wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  NahpuSpacing.lg,
                  NahpuSpacing.lg,
                  0,
                  NahpuSpacing.lg,
                ),
                child: SizedBox(width: _railWidth, child: _StepRail(this)),
              ),
              Expanded(child: _StepBody(this)),
            ],
          )
        : Column(
            children: [
              SizedBox(
                height: NahpuControlSize.prominent,
                child: _StepChips(this),
              ),
              const Divider(height: NahpuStroke.regular),
              Expanded(child: _StepBody(this)),
            ],
          );
  }

  /// Keeps the active chip centred as the wizard advances, so the step a user
  /// is on is never scrolled off the edge of a narrow screen.
  void scrollActiveStepChip() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.currentStep >= _stepChipKeys.length) return;
      final chipContext = _stepChipKeys[widget.currentStep].currentContext;
      if (chipContext == null) return;
      Scrollable.ensureVisible(
        chipContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _syncStepChipKeys() {
    _stepChipKeys = List<GlobalKey>.generate(
      widget.steps.length,
      (_) => GlobalKey(),
    );
  }

  static const double _railWidth = 248;
}

class _StepRail extends StatelessWidget {
  const _StepRail(this.state);

  final NahpuWizardScaffoldState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final steps = state.widget.steps;
    return Container(
      key: const ValueKey('nahpu-wizard-step-rail'),
      decoration: NahpuPanel.decorationOf(context),
      child: ListView.builder(
        padding: const EdgeInsets.all(NahpuSpacing.lg),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final selected = index == state.widget.currentStep;
          final enabled = index <= state.widget.maxVisitedStep;
          return Padding(
            padding: const EdgeInsets.only(bottom: NahpuSpacing.sm),
            child: Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NahpuRadius.md),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                selected: selected,
                selectedTileColor: colors.primaryContainer,
                selectedColor: colors.onPrimaryContainer,
                enabled: enabled,
                leading: NahpuStepNumber(
                  number: index + 1,
                  selected: selected,
                  complete: index < state.widget.currentStep,
                ),
                title: Text(
                  steps[index],
                  style: selected
                      ? const TextStyle(fontWeight: FontWeight.w600)
                      : null,
                ),
                onTap: enabled
                    ? () => state.widget.onStepSelected(index)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StepChips extends StatelessWidget {
  const _StepChips(this.state);

  final NahpuWizardScaffoldState state;

  @override
  Widget build(BuildContext context) {
    final steps = state.widget.steps;
    return ListView.separated(
      controller: state._stepChipScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: NahpuSpacing.lg,
        vertical: NahpuSpacing.md,
      ),
      itemCount: steps.length,
      separatorBuilder: (_, _) => const SizedBox(width: NahpuSpacing.md),
      itemBuilder: (context, index) {
        final enabled = index <= state.widget.maxVisitedStep;
        return ChoiceChip(
          key: state._stepChipKeys[index],
          selected: index == state.widget.currentStep,
          label: Text('${index + 1}. ${steps[index]}'),
          onSelected: enabled
              ? (_) {
                  state.widget.onStepSelected(index);
                  state.scrollActiveStepChip();
                }
              : null,
        );
      },
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody(this.state);

  final NahpuWizardScaffoldState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        NahpuSpacing.md,
        NahpuSpacing.md,
        NahpuSpacing.md,
        NahpuSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: NahpuContentWidth.projectWizard,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: KeyedSubtree(
              key: ValueKey(state.widget.currentStep),
              child: state.widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// The bottom bar of a wizard: back on the left, the primary action on the
/// right, and an optional secondary action beside it.
class NahpuWizardActionBar extends StatelessWidget {
  const NahpuWizardActionBar({
    super.key,
    required this.step,
    required this.lastStep,
    required this.isRunning,
    required this.canContinue,
    required this.finalActionLabel,
    required this.finalActionIcon,
    required this.onBack,
    required this.onContinue,
    required this.onClose,
    this.secondaryLabel,
    this.onSecondary,
  });

  final int step;
  final int lastStep;
  final bool isRunning;
  final bool canContinue;
  final String finalActionLabel;
  final IconData finalActionIcon;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onClose;

  /// A text action shown before the primary button, such as skipping setup.
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final secondaryLabel = this.secondaryLabel;
    final onSecondary = this.onSecondary;
    return Material(
      elevation: NahpuElevation.none,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            NahpuSpacing.xl,
            NahpuSpacing.xl,
            NahpuSpacing.xl,
            NahpuSpacing.md,
          ),
          child: Row(
            children: [
              if (step > 0 && step < lastStep)
                OutlinedButton.icon(
                  onPressed: isRunning ? null : onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back'),
                ),
              const Spacer(),
              if (secondaryLabel != null && onSecondary != null) ...[
                TextButton(
                  onPressed: isRunning ? null : onSecondary,
                  child: Text(secondaryLabel),
                ),
                const SizedBox(width: NahpuSpacing.md),
              ],
              if (step == lastStep)
                FilledButton(onPressed: onClose, child: const Text('Done'))
              else
                FilledButton.icon(
                  onPressed: canContinue ? onContinue : null,
                  icon: isRunning
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          step == lastStep - 1
                              ? finalActionIcon
                              : Icons.arrow_forward_rounded,
                        ),
                  label: Text(
                    step == lastStep - 1 ? finalActionLabel : 'Continue',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NahpuStepNumber extends StatelessWidget {
  const NahpuStepNumber({
    super.key,
    required this.number,
    required this.selected,
    required this.complete,
  });

  final int number;
  final bool selected;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: NahpuRadius.md,
      backgroundColor: selected
          ? colors.primary
          : colors.surfaceContainerHighest,
      foregroundColor: selected ? colors.onPrimary : colors.onSurfaceVariant,
      child: complete
          ? const Icon(Icons.check_rounded, size: NahpuControlSize.iconSmall)
          : Text('$number', style: const TextStyle(fontSize: 12)),
    );
  }
}

class NahpuStepHeading extends StatelessWidget {
  const NahpuStepHeading({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: NahpuSpacing.sm),
        Text(message),
      ],
    );
  }
}
