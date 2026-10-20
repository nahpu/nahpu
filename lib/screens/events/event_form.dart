import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart' show CollEventData;
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/screens/events/components/activities.dart';
import 'package:nahpu/screens/events/components/effort.dart';
import 'package:nahpu/screens/events/components/general_info.dart';
import 'package:nahpu/screens/events/components/media.dart';
import 'package:nahpu/screens/events/components/tab_bar.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/styles/catalog_pages.dart';

/// The collecting event record form.
///
/// Owns the field controllers for as long as the record is on screen. Rebuilding
/// them from the record on every provider update would replace them mid-edit and
/// leak the superseded set.
class CollEventForm extends ConsumerStatefulWidget {
  const CollEventForm({super.key, required this.collEvent});

  final CollEventData collEvent;

  @override
  CollEventFormState createState() => CollEventFormState();
}

class CollEventFormState extends ConsumerState<CollEventForm> {
  late final CollEventFormCtrModel _collEventCtr =
      CollEventFormCtrModel.fromData(widget.collEvent);

  @override
  void didUpdateWidget(covariant CollEventForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collEvent == widget.collEvent) return;
    _collEventCtr.syncFrom(widget.collEvent);
  }

  @override
  void dispose() {
    _collEventCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        bool useHorizontalLayout = c.maxWidth > 600;
        return FocusDetectedLayout(
          children: [
            AdaptiveMainLayout(
              useHorizontalLayout: useHorizontalLayout,
              height: topCollEventHeight,
              children: [
                EventInfoField(
                  collEventId: widget.collEvent.id,
                  useHorizontalLayout: useHorizontalLayout,
                  collEventCtr: _collEventCtr,
                ),
                CollActivityFields(
                  collEventId: widget.collEvent.id,
                  collEventCtr: _collEventCtr,
                ),
              ],
            ),
            AdaptiveMainLayout(
              useHorizontalLayout: useHorizontalLayout,
              height: bottomCollEventHeight,
              children: [
                CollEffort(collEventId: widget.collEvent.id),
                CollEventTabBar(
                  eventID: widget.collEvent.id,
                  useHorizontalLayout: useHorizontalLayout,
                ),
              ],
            ),
            EventMediaForm(eventId: widget.collEvent.id),
            const BottomPadding(),
          ],
        );
      },
    );
  }
}
