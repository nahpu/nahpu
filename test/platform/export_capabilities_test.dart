import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/common/platform_services.dart';

/// The host runs these, so only its own arm is exercised here. The iOS and
/// Android answers reach the widgets through injected values instead — see
/// `test/exports/export_location_card_test.dart` and
/// `test/exports/export_destination_field_test.dart`.
void main() {
  test('this platform reports one destination rule and one action', () {
    final destination = platformExportDestination;
    final action = platformSavedFileAction;

    if (Platform.isIOS) {
      expect(destination, ExportDestinationMode.temporary);
      expect(action, SavedFileAction.none);
    } else if (Platform.isAndroid) {
      expect(destination, ExportDestinationMode.chooseDirectory);
      expect(action, SavedFileAction.saveCopy);
    } else {
      expect(destination, ExportDestinationMode.chooseDirectory);
      expect(action, SavedFileAction.reveal);
    }
  });

  test('only a platform that can choose a folder can reveal one', () {
    // Revealing a file means handing its folder to a file browser, which only
    // makes sense where the user picked that folder in the first place.
    if (platformSavedFileAction == SavedFileAction.reveal) {
      expect(platformExportDestination, ExportDestinationMode.chooseDirectory);
    }
  });

  test('a temporary destination offers nothing but Share', () {
    if (platformExportDestination == ExportDestinationMode.temporary) {
      expect(platformSavedFileAction, SavedFileAction.none);
    }
  });
}
