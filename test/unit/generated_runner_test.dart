// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:w_transport/mock.dart';

import './flex_match_test.dart' as matchTest;
import './pact_interaction_test.dart' as interactionTest;
import './pact_mock_service_requests_test.dart' as mockServiceRequestsTest;
import './pact_mock_service_test.dart' as mockServiceTest;

void main() {
  configureWTransportForTest();

  matchTest.main();
  interactionTest.main();
  mockServiceRequestsTest.main();
  mockServiceTest.main();
}
