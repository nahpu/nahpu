import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/maps/maplibre_gesture_surface.dart';

void main() {
  testWidgets('forwards a tap position to the map owner', (tester) async {
    MapLibreTapDetails? tapDetails;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 200,
            height: 120,
            child: MapLibreGestureSurface(
              onTapUp: (details) => tapDetails = details,
            ),
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(342, 276));

    expect(tapDetails?.localPosition, const Offset(42, 36));
    expect(tapDetails?.viewportSize, const Size(200, 120));
  });
}
