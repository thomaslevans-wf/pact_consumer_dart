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

import 'package:test/test.dart';
import 'package:w_transport/mock.dart';
import 'package:w_transport/vm.dart';

import 'package:w_transport/w_transport.dart';
import 'package:pact_consumer_dart/src/pact_mock_service_requests.dart';

main() {
  configureWTransportForVM();
  group('PactMockServiceRequests', () {
    String baseUrl = 'http://localhost:1234';

    group('getVerification', () {
      var fut; // Function Under Test

      setUp(() {
        Uri uri = Uri.parse(baseUrl + '/interactions/verification');
        fut = PactMockServiceRequests.getVerification;

        MockTransports.reset();

        MockResponse mockRes = new MockResponse.ok(body: '[]');

        MockTransports.http.expect('GET', uri, respondWith: mockRes);
      });

      group('when called with valid params', () {
        test('should return a Response', () async {
          var res = await fut(baseUrl);
          expect(res, isA<Response>());
          expect(res.status, equals(200));
        });
      });

      tearDown(() {
        MockTransports.verifyNoOutstandingExceptions();
      });
    });

    group('postInteractions', () {
      var fut; // Function Under Test

      setUp(() {
        Uri uri = Uri.parse(baseUrl + '/interactions');
        fut = PactMockServiceRequests.postInteraction;

        MockTransports.reset();

        MockResponse mockRes = new MockResponse.ok(body: '[]');

        MockTransports.http.expect('POST', uri, respondWith: mockRes);
      });

      group('when called with valid params', () {
        test('should return a Response', () async {
          var res = await fut({}, baseUrl);
          expect(res, isA<Response>());
          expect(res.status, equals(200));
        });
      });

      tearDown(() {
        MockTransports.verifyNoOutstandingExceptions();
      });
    });

    group('postPact', () {
      var fut; // Function Under Test

      setUp(() {
        Uri uri = Uri.parse(baseUrl + '/pact');
        fut = PactMockServiceRequests.postPact;

        MockTransports.reset();

        MockResponse mockRes = new MockResponse.ok(body: '[]');

        MockTransports.http.expect('POST', uri, respondWith: mockRes);
      });

      group('when called with valid params', () {
        test('should return a Response', () async {
          var res = await fut({}, baseUrl);
          expect(res, isA<MockResponse>());
          expect(res.status, equals(200));
        });
      });

      tearDown(() {
        MockTransports.verifyNoOutstandingExceptions();
      });
    });

    group('deleteSession', () {
      var fut; // Function Under Test

      setUp(() {
        Uri uri = Uri.parse(baseUrl + '/interactions');
        fut = PactMockServiceRequests.deleteSession;

        MockTransports.reset();

        MockResponse mockRes = new MockResponse.ok(body: '[]');

        MockTransports.http.expect('DELETE', uri, respondWith: mockRes);
      });

      group('when called with valid params', () {
        test('should return a Response', () async {
          var res = await fut(baseUrl);
          expect(res, isA<MockResponse>());
          expect(res.status, equals(200));
        });
      });

      tearDown(() {
        MockTransports.verifyNoOutstandingExceptions();
      });
    });
  });
}
