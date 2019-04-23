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

import 'package:pact_consumer_dart/src/pact_mock_service.dart';
import 'package:pact_consumer_dart/src/pact_interaction.dart';

import '../fixtures/pact_mock_service_fixture.dart';
import 'package:w_transport/w_transport.dart';

main() {
  group('PactMockService', () {
    Map fixture = pactMockServiceFixture;

    group('constructor params', () {
      PactMockService mockService;

      group('when `host` is provided', () {
        setUp(() {
          configureWTransportForTest();
          Uri uri = Uri.parse('http://' +
              fixture['host'] +
              ':' +
              fixture['port'] +
              '/interactions');

          MockTransports.reset();
          MockTransports.http
              .expect('DELETE', uri, respondWith: new MockResponse.ok());

          mockService = new PactMockService(
              fixture['consumer'], fixture['provider'],
              host: fixture['host'], dir : '~/pacts');
        });

        test('should use the host option in request', () {
          // use completes to assert the Future completed
          expect(mockService.resetSession(), completes);
        });

        tearDown(() {
          // this will throw if the val passed for host was not used
          MockTransports.verifyNoOutstandingExceptions();
        });
      });

      group('when no `host` is provided', () {
        setUp(() {
          Uri uri = Uri
              .parse('http://127.0.0.1:' + fixture['port'] + '/interactions');

          MockTransports.reset();
          MockTransports.http
              .expect('DELETE', uri, respondWith: new MockResponse.ok());

          mockService =
              new PactMockService(fixture['consumer'], fixture['provider']);
        });

        test('should use the default host in request', () {
          // use completes to assert the Future completed
          expect(mockService.resetSession(), completes);
        });

        tearDown(() {
          // this will throw if the val passed for host was not used
          MockTransports.verifyNoOutstandingExceptions();
        });
      });

      group('when `port` is NOT provided', () {
        setUp(() {
          Uri uri = Uri.parse('http://${fixture['host']}:1234/interactions');

          MockTransports.reset();
          MockTransports.http
              .expect('DELETE', uri, respondWith: new MockResponse.ok());

          mockService = new PactMockService(
              fixture['consumer'], fixture['provider'],
              host: fixture['host'], dir : '~/pacts');
        });

        test('should use the default port, 1234', () {
          expect(mockService.resetSession(), completes);
        });
      });

      group('when `port` is provided', () {
        setUp(() {
          var port = '4321';
          Uri uri = Uri.parse('http://127.0.0.1:$port/interactions');

          MockTransports.reset();
          MockTransports.http
              .expect('DELETE', uri, respondWith: new MockResponse.ok());

          mockService = new PactMockService(
              fixture['consumer'], fixture['provider'],
              port: port, dir : '~/pacts');
        });
        test('should use the provided port', () {
          expect(mockService.resetSession(), completes);
        });
      });
    });

    group('resetSession', () {
      PactMockService mockService;

      setUp(() {
        mockService = new PactMockService(
            fixture['consumer'], fixture['provider'],
            host: fixture['host'], dir : '~/pacts');
      });

      group('when there is a bad response', () {
        setUp(() {
          Uri uri = Uri.parse('http://localhost:1234/interactions');

          MockTransports.reset();

          MockResponse mockRes = new MockResponse.internalServerError();

          MockTransports.http.expect('DELETE', uri, respondWith: mockRes);
        });

        test('should throw an Exception', () {
          expect(mockService.resetSession(), throwsException);
        });

        tearDown(() {
          MockTransports.verifyNoOutstandingExceptions();
        });
      });

      group('when there is a success response', () {
        setUp(() {
          Uri uri = Uri.parse('http://localhost:1234/interactions');

          MockTransports.reset();

          MockResponse mockRes = new MockResponse.ok();

          MockTransports.http.expect('DELETE', uri, respondWith: mockRes);
        });

        test('should complete without an Exception', () {
          expect(mockService.resetSession(), completes);
        });

        tearDown(() {
          MockTransports.verifyNoOutstandingExceptions();
        });
      });
    });

    group('given', () {
      PactMockService mockService;

      group('when passed a valid String as `providerState`', () {
        setUp(() {
          mockService = new PactMockService(
              fixture['consumer'], fixture['provider'],
              host: fixture['host'], dir : '~/pacts');
        });

        test('should return an instance of PactInteraction', () {
          var match = mockService.given('that has a description',
              providerState: 'a provider state');

          expect(match, const TypeMatcher<PactInteraction>());
        });
      });

      group('when passed an invalid String as `description`', () {
        setUp(() {
          mockService = new PactMockService(
              fixture['consumer'], fixture['provider'],
              host: fixture['host'], dir : '~/pacts');
        });

        test('should throw StateError', () {
          var callGiven = () {
            mockService.given('');
          };

          expect(callGiven, throwsStateError);
        });
      });
    });

    group('setup', () {
      PactMockService mockService;

      setUp(() {
        mockService = new PactMockService(
            fixture['consumer'], fixture['provider'],
            host: fixture['host'], dir : '~/pacts');
      });

      group('when called and there is an interaction staged', () {
        setUp(() {
          Uri uri = Uri.parse('http://localhost:1234/interactions');

          // create some interactions
          var interaction = mockService
              .given('a request for a resource',
                  providerState: 'a Provider state')
              .when('GET', '/resource')
              .then(200,
                  headers: {'Content-Type': 'application/json'},
                  body: {'resource': 'a_resource'});

          // mock successful Pact response
          MockTransports.reset();

          // setup a handler to verify the interactions were part of the request
          var requestHandler = (FinalizedRequest request) async {
            if (request.method == 'POST') {
              HttpBody body = request.body;
              Map bodyMap = body.asJson();
              List mapKeys = interaction.toMap().keys.toList();

              // Check that all the properties of the interaction are received
              if (bodyMap.keys.every((elem) => mapKeys.contains(elem))) {
                return new MockResponse.ok();
              }
            }

            return new MockResponse.badRequest();
          };

          MockTransports.http.when(uri, requestHandler);
        });

        test('should `POST` the staged interaction', () async {
          var match = await mockService.setup();
          expect(match, const TypeMatcher<PactMockService>());
        });

        tearDown(() {
          MockTransports.verifyNoOutstandingExceptions();
        });
      });

      group('when called and there are NO interactions staged', () {
        test('should throw StateError', () {
          expect(mockService.setup(), throwsStateError);
        });
      });
    });

    group('verifyAndWrite', () {
      Uri verifyUri;
      Uri writeUri;
      PactMockService mockService;

      setUp(() {
        verifyUri =
            Uri.parse('http://localhost:1234/interactions/verification');
        writeUri = Uri.parse('http://localhost:1234/pact');
        mockService = new PactMockService(
            fixture['consumer'], fixture['provider'],
            host: fixture['host'], dir : '~/pacts');
      });

      group('when the interaction is verified and the pact is written', () {
        setUp(() {
          MockResponse ok = new MockResponse.ok();

          MockTransports.reset();
          MockTransports.http.expect('GET', verifyUri, respondWith: ok);
          MockTransports.http.expect('POST', writeUri, respondWith: ok);
        });

        test('should complete without any StateErrors', () {
          expect(mockService.verifyAndWrite(), completes);
        });

        tearDown(() {
          MockTransports.verifyNoOutstandingExceptions();
        });
      });

      group('when the interaction is not verified', () {
        setUp(() {
          MockResponse notFound = new MockResponse.notFound();

          MockTransports.reset();
          MockTransports.http.expect('GET', verifyUri, respondWith: notFound);
        });

        test('should throw an Exception', () {
          expect(mockService.verifyAndWrite(), throwsException);
        });

        tearDown(() {
          MockTransports.verifyNoOutstandingExceptions();
        });
      });

      group('when the interaction is verified and posting the pact fails', () {
        setUp(() {
          MockResponse ok = new MockResponse.ok();
          MockResponse serverErr = new MockResponse.internalServerError();

          MockTransports.reset();
          MockTransports.http.expect('GET', verifyUri, respondWith: ok);
          MockTransports.http.expect('POST', writeUri, respondWith: serverErr);
        });

        test('should throw a StateError', () {
          expect(mockService.verifyAndWrite(), throwsException);
        });

        tearDown(() {
          MockTransports.verifyNoOutstandingExceptions();
        });
      });
    });
  });
}
