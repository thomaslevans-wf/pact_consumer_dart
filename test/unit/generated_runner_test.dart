import 'package:w_transport/w_transport_mock.dart';

import './pact_match_test.dart' as matchTest;
import './pact_http_test.dart' as httpTest;
import './pact_interaction_test.dart' as interactionTest;
import './pact_mock_service_requests_test.dart' as mockServiceRequestsTest;
import './pact_mock_service_test.dart' as mockServiceTest;

void main() {
  configureWTransportForTest();

  matchTest.main();
  httpTest.main();
  interactionTest.main();
  mockServiceRequestsTest.main();
  mockServiceTest.main();
}
