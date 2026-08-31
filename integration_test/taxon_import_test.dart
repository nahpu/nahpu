import 'package:integration_test/integration_test.dart';

import '../test/projects/taxon_import_flow_test.dart';
import '../test/projects/taxon_qr_flow_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  taxonImportFlowTests(useAppLibrary: true);
  taxonQrFlowTests();
}
