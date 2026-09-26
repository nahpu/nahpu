import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/specimens/measurement_outlier_services.dart';

/// Warning state and popup handling shared by specimen measurement forms.
mixin MeasurementOutlierWarnings<
  W extends StatefulWidget,
  F extends MeasurementOutlierFieldInfo
>
    on State<W> {
  final Set<(F, double, double, double, String)> _shownOutlierWarnings = {};
  final Map<F, Timer> _outlierWarningTimers = {};
  bool _isShowingOutlierWarning = false;
  bool showOutlierWarnings = true;

  String get outlierWeightUnit;

  Future<MeasurementOutlierResult?> checkOutlierValue(F field, double value);

  @override
  void dispose() {
    _cancelOutlierTimers();
    super.dispose();
  }

  void setOutlierWarningsEnabled(bool enabled) {
    setState(() => showOutlierWarnings = enabled);
    if (!enabled) _cancelOutlierTimers();
  }

  void addOutlierListener(
    FocusNode focusNode,
    F field,
    double? Function() getValue,
  ) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        _showOutlierWarning(field, getValue());
      }
    });
  }

  void scheduleOutlierWarning(F field, double? value) {
    if (!showOutlierWarnings) return;

    _outlierWarningTimers[field]?.cancel();
    _outlierWarningTimers[field] = Timer(
      const Duration(milliseconds: 800),
      () => _showOutlierWarning(field, value),
    );
  }

  void _cancelOutlierTimers() {
    for (final timer in _outlierWarningTimers.values) {
      timer.cancel();
    }
    _outlierWarningTimers.clear();
  }

  Future<void> _showOutlierWarning(F field, double? value) async {
    if (!showOutlierWarnings || value == null || _isShowingOutlierWarning) {
      return;
    }

    final result = await checkOutlierValue(field, value);
    if (!mounted || !showOutlierWarnings || result == null) return;
    if (field.unit == 'g' && result.unit != outlierWeightUnit) return;

    final warningKey = (
      field,
      result.value,
      result.lowerBound,
      result.upperBound,
      result.unit,
    );
    if (!_shownOutlierWarnings.add(warningKey)) return;

    _isShowingOutlierWarning = true;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unusual measurement'),
        content: Text(result.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    _isShowingOutlierWarning = false;
  }
}
