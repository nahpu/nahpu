import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/exports/fossil_record_export_test.dart' as exports;
import '../test/projects/create_project_wizard_test.dart' as wizard;
import '../test/projects/project_transfer_test.dart' as transfers;
import '../test/records/fossil_attributes_test.dart' as attributes;
import '../test/records/fossil_site_test.dart' as sites;
import '../test/records/sedimentology_form_test.dart' as sedimentology;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Fossil site persistence and exchange', sites.main);
  group('Fossil specimen attributes', attributes.main);
  group('Sedimentology forms', sedimentology.main);
  group('Native fossil exports', exports.main);
  group('Project wizard navigation', wizard.main);
  group('Project transfer IO', transfers.main);
}
