import 'package:test/test.dart';
import 'package:w_transport/w_transport_mock.dart';

import 'package:pact_consumer_dart/src/pact_mock_service.dart';
import 'package:pact_consumer_dart/src/pact_interaction.dart';

import '../fixtures/pact_mock_service_fixture.dart';
import 'package:w_transport/w_transport.dart';

main() {
  group('MockService', () {
    Map fixture = pactMockServiceFixture;

    group('constructor params', () {
      PactMockService mockService;

      group('when `host` is provided', () {
        setUp(() {
          var opts = fixture;
          Uri uri = Uri.parse(
              'http://' + opts['host'] + ':' + opts['port'] + '/interactions');

          MockTransports.reset();
          MockTransports.http
              .expect('DELETE', uri, respondWith: new MockResponse.ok());

          mockService = new PactMockService(opts);
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
          var opts = {
            'consumer': 'Consumer',
            'provider': 'Provider',
            'port': '1234'
          };
          Uri uri =
              Uri.parse('http://127.0.0.1:' + opts['port'] + '/interactions');

          MockTransports.reset();
          MockTransports.http
              .expect('DELETE', uri, respondWith: new MockResponse.ok());

          mockService = new PactMockService(opts);
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
        test('should throw a StateError', () {
          var opts = {'consumer': 'Consumer', 'provider': 'Provider'};
          var callConst = () {
            new PactMockService(opts);
          };
          expect(callConst, throwsStateError);
        });
      });

      group('when `port` is provided', () {
        test('should NOT throw a StateError', () {
          var opts = {
            'consumer': 'Consumer',
            'provider': 'Provider',
            'port': '1234'
          };
          var callConst = () {
            new PactMockService(opts);
          };
          expect(callConst, returnsNormally);
        });
      });
    });

    group('resetSession', () {
      PactMockService mockService;

      setUp(() {
        mockService = new PactMockService(fixture);
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
          mockService = new PactMockService(fixture);
        });

        test('should return an instance of PactInteraction', () {
          var match =
              mockService.given('a provider state', 'that has a description');

          expect(match, new isInstanceOf<PactInteraction>());
        });
      });

      group('when passed an invalid String as `providerState`', () {
        setUp(() {
          mockService = new PactMockService(fixture);
        });

        test('should throw StateError', () {
          var callGiven = () {
            mockService.given('', 'that has a description');
          };

          expect(callGiven, throwsStateError);
        });
      });

      group('when passed an invalid String as `description`', () {
        setUp(() {
          mockService = new PactMockService(fixture);
        });

        test('should throw StateError', () {
          var callGiven = () {
            mockService.given('a providerState', '');
          };

          expect(callGiven, throwsStateError);
        });
      });
    });

    group('setup', () {
      PactMockService mockService;

      setUp(() {
        mockService = new PactMockService(fixture);
      });

      group('when called and there is an interaction staged', () {
        setUp(() {
          Uri uri = Uri.parse('http://localhost:1234/interactions');

          // create some interactions
          var interaction = mockService
              .given('a Provider state', 'a request for a resource')
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
          expect(match, new isInstanceOf<PactMockService>());
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
        mockService = new PactMockService(fixture);
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
