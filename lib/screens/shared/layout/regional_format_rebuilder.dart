import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/services/providers/localization.dart';

/// Redraws the app when the regional format changes.
///
/// Dates and numbers are formatted through intl's default locale, which no
/// widget depends on, so nothing would redraw on its own. Marking every
/// element dirty rebuilds them in place: open pages, scroll positions, and
/// form input keep their state.
class RegionalFormatRebuilder extends ConsumerWidget {
  const RegionalFormatRebuilder({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String>(formatLocaleProvider, (previous, formatLocale) {
      if (previous == formatLocale) return;
      // Set here as well as at startup, so the new locale is in place before
      // anything redraws.
      Intl.defaultLocale = formatLocale;
      _markAllNeedsBuild(context as Element);
    });
    return child;
  }

  void _markAllNeedsBuild(Element root) {
    void mark(Element element) {
      element.markNeedsBuild();
      element.visitChildren(mark);
    }

    root.visitChildren(mark);
  }
}
