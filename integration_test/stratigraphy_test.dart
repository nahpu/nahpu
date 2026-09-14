import 'package:integration_test/integration_test.dart';

import '../test/stratigraphy_form_test.dart' as persistence_tests;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  persistence_tests.main();
}
